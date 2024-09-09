local Screen = require "widgets/screen"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local TextEdit = require "widgets/textedit"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local PlayerBadge = require "widgets/playerbadge"
local LobbyChatQueue = require "widgets/lobbychatqueue"
local Spinner = require "widgets/spinner"
local DressupPanel = require "widgets/dressuppanel"
local CharacterSelect = require "widgets/characterselect"
local PlayerList = require "widgets/playerlist"
local WaitingForPlayersWidget = require "widgets/waitingforplayers"

local PopupDialogScreen = require "screens/popupdialog"

local TEMPLATES = require "widgets/templates"

require("util")
require("networking")
require("stringutil")

local DEBUG_MODE = BRANCH == "dev"

local CHAT_INPUT_HISTORY = {}

local REFRESH_INTERVAL = .5

local lcol = -RESOLUTION_X/2

local function StartGame(this)
    if this.startbutton then
        this.startbutton:Disable()
    end

    if this.dressup then
        this.dressup:OnClose()
    end

    if this.cb and this.dressup then
        local skins = this.dressup:GetSkinsForGameStart()
        this.cb(this.dressup.currentcharacter, skins.base, skins.body, skins.hand, skins.legs, skins.feet) --parameters are base_prefab, skin_base, clothing_body, clothing_hand, then clothing_legs
    end
end

local LobbyScreen = Class(Screen, function(self, profile, cb, no_backbutton, default_character, days_survived)
    Screen._ctor(self, "LobbyScreen")

    self.profile = profile
    self.log = true
    self.issoundplaying = false

    self.no_cancel = no_backbutton

    if cb ~= nil then
        self.cb = function(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
            self:StopLobbyMusic()
            cb(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
        end
    end

    self.currentcharacter = nil
    self.time_to_refresh = REFRESH_INTERVAL
    self.active_tab = "players"

    if days_survived then
        self.days_survived = math.floor(days_survived)
    else
        self.days_survived = -1
    end

    self.anim_bg = self:AddChild(Image("images/bg_spiral_anim.xml", "spiral_bg.tex"))
    self.anim_bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.anim_bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.anim_bg:SetVAnchor(ANCHOR_MIDDLE)
    self.anim_bg:SetHAnchor(ANCHOR_MIDDLE)
    self.anim_bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.anim_bg:SetTint(unpack(FRONTEND_PORTAL_COLOUR))

    self.anim_root = self:AddChild(Widget("root"))
    self.anim_root:SetVAnchor(ANCHOR_MIDDLE)
    self.anim_root:SetHAnchor(ANCHOR_MIDDLE)
    self.anim_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --old big asset was removed
    --[[self.anim = self.anim_root:AddChild(UIAnim())
    self.anim:GetAnimState():SetBuild("spiral_bg")
    self.anim:GetAnimState():SetBank("spiral_bg")
    self.anim:GetAnimState():PlayAnimation("idle_loop", true)
    self.anim:GetAnimState():SetMultColour(unpack(FRONTEND_PORTAL_COLOUR))]]

    self.anim_root:SetPosition(160, 0)

    self.anim_ol = self:AddChild(Image("images/bg_spiral_anim_overlay.xml", "spiral_ol.tex"))
    self.anim_ol:SetVRegPoint(ANCHOR_MIDDLE)
    self.anim_ol:SetHRegPoint(ANCHOR_MIDDLE)
    self.anim_ol:SetVAnchor(ANCHOR_MIDDLE)
    self.anim_ol:SetHAnchor(ANCHOR_MIDDLE)
    self.anim_ol:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.anim_ol:SetTint(unpack(FRONTEND_PORTAL_COLOUR))

    self.vignette = self:AddChild(TEMPLATES.BackgroundVignette())
    self.vignette:SetTint(1,1,1,.8)

    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.fixed_root = self.root:AddChild(Widget("root"))
    self.fixed_root:SetPosition(-RESOLUTION_X/2, -RESOLUTION_Y/2, 0)

    self.sidebar_root = self.root:AddChild(Widget("Sidebar"))
    self.sidebar_root:SetPosition(lcol-5, -375)

    self.characterselect_root = self.fixed_root:AddChild(Widget("CharacterSelect root"))
    self.loadout_root = self.fixed_root:AddChild(Widget("Loadout"))
    self.waiting_for_players_root = self.fixed_root:AddChild(Widget("waiting_for_players_root"))

    self.heroname = self.loadout_root:AddChild(Image())
    self.heroname:SetScale(.34)
    self.heroname:SetPosition(RESOLUTION_X/2+115, RESOLUTION_Y-175)

    self.heroportrait = self.loadout_root:AddChild(Image())
    self.heroportrait:SetScale(.75)
    self.heroportrait:SetPosition(RESOLUTION_X/2-200, RESOLUTION_Y-345)

    local adjust = 16

    self.playerselect_title = self.characterselect_root:AddChild(Text(BUTTONFONT, 35))
    self.playerselect_title:SetHAlign(ANCHOR_LEFT)
    self.playerselect_title:SetVAlign(ANCHOR_TOP)
    self.playerselect_title:SetPosition(RESOLUTION_X/2 - 230, RESOLUTION_Y - 35)
    self.playerselect_title:SetRegionSize( 500, 60 )
    self.playerselect_title:EnableWordWrap( false )
    self.playerselect_title:SetString( STRINGS.UI.LOBBYSCREEN.SELECTION_TITLE )
    self.playerselect_title:SetColour(BLACK)

    self.characterquote = self.characterselect_root:AddChild(Text(BUTTONFONT, 35))
    self.characterquote:SetHAlign(ANCHOR_MIDDLE)
    self.characterquote:SetVAlign(ANCHOR_TOP)
    self.characterquote:SetPosition(RESOLUTION_X/2 +10, RESOLUTION_Y - 85)
    self.characterquote:SetRegionSize( 500, 60 )
    self.characterquote:EnableWordWrap( false )
    self.characterquote:SetString( "" )
    self.characterquote:SetColour(BLACK)

    self.basequote = self.loadout_root:AddChild(Text(BUTTONFONT, 35))
    self.basequote:SetHAlign(ANCHOR_MIDDLE)
    self.basequote:SetVAlign(ANCHOR_TOP)
    self.basequote:SetPosition(RESOLUTION_X/2+125, RESOLUTION_Y - 85)
    self.basequote:SetRegionSize( 600, 60 )
    self.basequote:EnableWordWrap( false )
    self.basequote:SetString( "" )
    self.basequote:SetColour(BLACK)

    self.basetitle = self.loadout_root:AddChild(Text(BUTTONFONT, 40))
    self.basetitle:SetHAlign(ANCHOR_MIDDLE)
    self.basetitle:SetVAlign(ANCHOR_TOP)
    self.basetitle:SetPosition(RESOLUTION_X/2 - 200, RESOLUTION_Y/2-320)
    self.basetitle:SetRegionSize( 300, 100 )
    self.basetitle:EnableWordWrap( false )
    self.basetitle:SetString( "" )
    self.basetitle:SetColour(BLACK)

    self.horizontal_line = self.fixed_root:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
    self.horizontal_line:SetScale(2.9, .3)
    self.horizontal_line:SetPosition(RESOLUTION_X/2 +130, RESOLUTION_Y-40, 0)

    self:BuildCharacterDetailsBox()
    self:BuildSidebar()

    --self.dressup_bg = self.loadout_root:AddChild(Image("images/lobbyscreen.xml", "playerlobby_whitebg_chat.tex"))
    --self.dressup_bg:SetPosition(1060, 335)
    --self.dressup_bg:SetScale(.8, .62)
    --self.dressup_bg:SetTint(1, 1, 1, .3)
    --self.dressup_bg:SetClickable(false)

    self.dressup = self.loadout_root:AddChild(DressupPanel(self, self.profile, nil, function() self:SetPortraitImage() end, nil, nil, true))
    self.dressup:SetPosition(RESOLUTION_X - 195, RESOLUTION_Y/2 + 25, 0)
    self.dressup:GetClothingOptions()
    self.dressup:SeparateAvatar()

    local client_obj = TheNet:GetClientTableForUser(TheNet:GetUserID())
    local name = subfmt(STRINGS.UI.LOBBYSCREEN.LOADOUT_TITLE, {name = TheNet:GetLocalUserName()})
    self.loadout_title = self.loadout_root:AddChild(Text(TALKINGFONT, 35, name, client_obj ~= nil and client_obj.colour or BLACK))
    self.loadout_title:SetPosition(RESOLUTION_X/2 - 110, RESOLUTION_Y - 25)
    self.loadout_title:SetRegionSize( 500, 60 )
    self.loadout_title:SetHAlign(ANCHOR_LEFT)

    if not TheInput:ControllerAttached() then
        --This button doesn't offer enough value, otherwise please make it controller accessible
        --[[
        self.invitebutton = self.sidebar_root:AddChild(TEMPLATES.Button(STRINGS.UI.LOBBYSCREEN.INVITE, function() TheNet:ViewNetFriends() end))
        self.invitebutton:SetPosition(190, RESOLUTION_Y-20, 0)
        self.invitebutton.image:SetScale(.4)
        self.invitebutton:SetTextSize(22)
        self.invitebutton.text:SetPosition(0, -3)
        ]]

        self.selectbutton = self.characterselect_root:AddChild(TEMPLATES.Button(STRINGS.UI.LOBBYSCREEN.SELECT, function()
			 self:StartLoadout()
		end))
        self.selectbutton:SetPosition(RESOLUTION_X - 300, 60, 0)

        self.startbutton = self.loadout_root:AddChild(TEMPLATES.Button(STRINGS.UI.LOBBYSCREEN.START, function() StartGame(self) end))
        self.startbutton:SetPosition(RESOLUTION_X - 180, 60, 0)

        self.randomcharbutton = self.characterselect_root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "random.tex", STRINGS.UI.LOBBYSCREEN.RANDOMCHAR, false, false, function()
                self.character_scroll_list:SelectRandomCharacter()
            end,
        {
            offset_y = -45
        }))
        self.randomcharbutton:SetPosition( RESOLUTION_X - 170, RESOLUTION_Y - 20, 0)
        self.randomcharbutton:SetScale(.6, .6, .6)

        self.randomskinsbutton = self.loadout_root:AddChild(TEMPLATES.IconButton("images/button_icons.xml", "random.tex", STRINGS.UI.LOBBYSCREEN.RANDOMCHAR, false, false, function()
                self.dressup:AllSpinnersToEnd()
            end,
        {
            offset_y = -45
        }))
        self.randomskinsbutton:SetPosition( RESOLUTION_X - 50, RESOLUTION_Y - 20, 0) -- x pos is 120 more than the randomcharbutton because characterselect_root gets moved over
        self.randomskinsbutton:SetScale(.6, .6, .6)

        if not no_backbutton then
            -- Note: putting these buttons in the characterselect_root or loadout_root results in the buttons behind the
            -- sidebar bg, even if MoveToFront is called. So they're in the sidebar_root instead.
            self.disconnectbutton = self.sidebar_root:AddChild(TEMPLATES.BackButton(function() self:DoConfirmQuit() end,
                                                                        STRINGS.UI.LOBBYSCREEN.DISCONNECT,
                                                                        {x=38, y=0}, --text offset
                                                                        {x=1, y=-1}, --drop shadow offset from text
                                                                        1)) -- scale
            self.disconnectbutton:SetPosition(100, BACK_BUTTON_Y)

            self.backbutton = self.sidebar_root:AddChild(TEMPLATES.BackButton(function() self:StartSelection() end,
                                                                        STRINGS.UI.LOBBYSCREEN.BACK,
                                                                        {x=38, y=0}, --text offset
                                                                        {x=1, y=-1}, --drop shadow offset from text
                                                                        1)) -- scale
            self.backbutton:SetPosition(100, BACK_BUTTON_Y)
        end
    end

    self.character_scroll_list = self.characterselect_root:AddChild(CharacterSelect(self, default_character, function() self:SelectPortrait() end,  {"random"}))
    self.character_scroll_list:SetPosition(RESOLUTION_X/2, RESOLUTION_Y-320, 0)
    self.character_scroll_list:SetScale(.8)
    self:SelectPortrait()

    self.characterselect_root:SetPosition(120, 0, 0)
    self.loadout_root:Hide()
    self.in_loadout = false


    self.waiting_for_players_root:SetPosition(0, 0, 0)
    self.waiting_for_players = self.waiting_for_players_root:AddChild(WaitingForPlayersWidget(self, 6))

    local waiting_for_players_title = self.waiting_for_players_root:AddChild(Text(BUTTONFONT, 35))
    waiting_for_players_title:SetHAlign(ANCHOR_LEFT)
    waiting_for_players_title:SetVAlign(ANCHOR_TOP)
    waiting_for_players_title:SetPosition(RESOLUTION_X/2 - 110, RESOLUTION_Y - 35)
    waiting_for_players_title:SetRegionSize( 500, 60 )
    waiting_for_players_title:EnableWordWrap( false )
    waiting_for_players_title:SetString( STRINGS.UI.LOBBYSCREEN.waiting_for_players_TITLE )
    waiting_for_players_title:SetColour(BLACK)

    self.spawndelaytext = self.waiting_for_players_root:AddChild(Text(BUTTONFONT, 35))
    self.spawndelaytext:SetHAlign(ANCHOR_MIDDLE)
    self.spawndelaytext:SetVAlign(ANCHOR_TOP)
    self.spawndelaytext:SetPosition(RESOLUTION_X/2 + 110, 60, 0)
    self.spawndelaytext:SetRegionSize( 500, 60 )
    self.spawndelaytext:SetColour(BLACK)
    self.spawndelaytext:Hide()

    self.in_readystate = false
	self.waiting_for_players_root:Hide()

    if self.backbutton ~= nil then
        self.backbutton:Hide()
    end

    self.default_focus = self.chatbox
    self:DoFocusHookups()

	self:StartSelection()

	self.inst:ListenForEvent("lobbyplayerspawndelay", function(world, data)
			if data and data.active then
                --subtract one so we hang on 0 for a second
                local str = subfmt(STRINGS.UI.LOBBYSCREEN.SPAWN_DELAY, { time = math.max(0, data.time - 1) })
                if str ~= self.spawndelaytext:GetString() or not self.spawndelaytext.shown then
                    self.spawndelaytext:SetString(str)
                    self.spawndelaytext:Show()
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/WorldDeathTick")
                end

				if self.backbutton ~= nil then
					self.backbutton:Hide()
				end

				if data.time == 0 then
					StartGame(self)
				end
			end
		end, TheWorld)

end)

function LobbyScreen:OnBecomeActive()
    self._base.OnBecomeActive(self)
    self:StartLobbyMusic()
end

function LobbyScreen:OnDestroy()
    self:StopLobbyMusic()
    self._base.OnDestroy(self)
end

function LobbyScreen:StartLobbyMusic()
    if not self.issoundplaying then
        self.issoundplaying = true
        TheMixer:SetLevel("master", 1)
        TheMixer:PushMix("lobby")
        TheFrontEnd:GetSound():KillSound("FEMusic")
        TheFrontEnd:GetSound():KillSound("FEPortalSFX")
        TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/DST_theme_portaled", "PortalMusic")
        TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_swirl", "PortalSFX")
    end
end

function LobbyScreen:StopLobbyMusic()
    if self.issoundplaying then
        self.issoundplaying = false
        TheFrontEnd:GetSound():KillSound("PortalMusic")
        TheFrontEnd:GetSound():KillSound("PortalSFX")
        TheMixer:PopMix("lobby")
    end
end

function LobbyScreen:BuildSidebar()
    self.sidebar_bg = self.sidebar_root:AddChild(Image("images/lobbyscreen.xml", "playerlobby_leftcolumn_bg.tex"))
    self.sidebar_bg:SetPosition(130, 375)
    self.sidebar_bg:SetScale(.75, .8)
    self.sidebar_bg:SetTint(1, 1, 1, 1)
    self.sidebar_bg:SetClickable(false)

    self.playerList = self.sidebar_root:AddChild(PlayerList(self, {right = self.character_scroll_list, down = self.chatbox}))
    self:BuildChatWindow()

    -- Don't use OnControl because we still need the standard Widget version of the function to
    -- call OnControl on the children.
    self.sidebar_root.BlockScroll = function(widget, control, down)
        local mouseX = TheInput:GetScreenPosition().x
        local w,h = TheSim:GetScreenSize()

        if mouseX and mouseX < (w*.2) then
            if down then
                -- Eat scroll commands so the character list doesn't scroll when the mouse is over the sidebar
                if control == CONTROL_SCROLLBACK or control == CONTROL_SCROLLFWD then
                    return true
                end
            end
        end
        return false
    end
end

--[[function LobbyScreen:UpdateMessageIndicator()
    if self.active_tab ~= "chat" then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/chat_receive")
        --self.message_indicator:Show()
        --self.message_indicator.count:SetString(self.unread_count)
    else
        --self.unread_count = 0
        --self.message_indicator:Hide()
    end
end]]

function LobbyScreen:MakeTextEntryBox(parent)
    local chatbox = parent:AddChild(Widget("chatbox"))
    chatbox.bg = chatbox:AddChild( Image("images/lobbyscreen.xml", "playerlobby_whitebg_type.tex") )
    chatbox.bg:SetTint(1, 1, 1, .65)
    local box_size = 210
    local box_y = 25
    local nudgex = 60
    local nudgey = -20
    chatbox.bg:ScaleToSize( box_size+30, box_y + 30 )
    chatbox.textbox = chatbox:AddChild(TextEdit( NEWFONT, 20, nil, {0,0,0,1} ) )
    chatbox.textbox:SetForceEdit(true)
    chatbox.bg:SetPosition((box_size * .5) - 100 + 25 + nudgex, 8 + nudgey, 0)
    chatbox.textbox:SetPosition((box_size * .5) - 100 + 26 + nudgex, 8 + nudgey, 0)
    chatbox.textbox:SetRegionSize(box_size - 23, box_y)
    chatbox.textbox:SetHAlign(ANCHOR_LEFT)
    chatbox.textbox:SetVAlign(ANCHOR_MIDDLE)

    chatbox.bg_outline = chatbox:AddChild( Image("images/textboxes.xml", "textbox2_small_grey.tex") )
    chatbox.bg_outline:ScaleToSize( box_size + 4, box_y + 8)
    chatbox.bg_outline:SetPosition((box_size * .5) - 100 + 24 + nudgex, 7 + nudgey, 0)
    chatbox.textbox:SetFocusedImage( chatbox.bg_outline, "images/textboxes.xml", "textbox2_small_grey.tex", "textbox2_small_gold.tex", "textbox2_small_gold_greyfill.tex" )

    chatbox.textbox:SetTextLengthLimit(MAX_CHAT_INPUT_LENGTH)
    chatbox.textbox:EnableWordWrap(false)
    chatbox.textbox:EnableScrollEditWindow(true)
    chatbox.textbox:SetHelpTextEdit("")
    chatbox.textbox:SetHelpTextApply(STRINGS.UI.LOBBYSCREEN.CHAT)
    chatbox.textbox.OnTextEntered = function()
        local chat_string = self.chatbox.textbox:GetString()
        chat_string = chat_string ~= nil and chat_string:match("^%s*(.-%S)%s*$") or ""
        if chat_string ~= "" and chat_string:utf8len() <= MAX_CHAT_INPUT_LENGTH then
            TheNet:Say(chat_string)
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/chat_send")
        end
        self.chatbox.textbox:SetString("")
        self.chatbox.textbox:SetEditing(true)
    end

    chatbox.gobutton = chatbox:AddChild(ImageButton("images/lobbyscreen.xml", "button_send.tex", "button_send_over.tex", "button_send_down.tex", "button_send_down.tex", "button_send_down.tex", {1,1}, {0,0}))
    chatbox.gobutton:SetPosition(box_size - 59 + nudgex, 8 + nudgey)
    chatbox.gobutton:SetScale(.13)
    chatbox.gobutton.image:SetTint(.6,.6,.6,1)
    chatbox.gobutton:SetOnClick( function() self.chatbox.textbox:OnTextEntered() end )

     -- If chatbox ends up focused, highlight the textbox so we can tell something is focused.
    chatbox:SetOnGainFocus( function() chatbox.textbox:OnGainFocus() end )
    chatbox:SetOnLoseFocus( function() chatbox.textbox:OnLoseFocus() end )

    chatbox.GetHelpText = function()
        local t = {}
        local controller_id = TheInput:GetControllerID()

        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT, false, false ) .. " " .. STRINGS.UI.LOBBYSCREEN.CHAT)
        return table.concat(t, "  ")
    end

    chatbox:SetPosition(-52, -178)

    self.chatbox = chatbox
end

function LobbyScreen:BuildChatWindow()
    self.chat_pane = self.sidebar_root:AddChild(Widget("chat_pane"))

    if not self.chat_pane.bg then
        self.chat_pane.bg = self.chat_pane:AddChild(Image("images/lobbyscreen.xml", "playerlobby_whitebg_chat.tex"))
        self.chat_pane.bg:SetScale(.79, .64)
        self.chat_pane.bg:SetTint(1,1,1,.65)
        self.chat_pane.bg:SetPosition(59, -20)
    end

    if not self.chat_pane.upper_horizontal_line then
        self.chat_pane.upper_horizontal_line = self.chat_pane:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
        self.chat_pane.upper_horizontal_line:SetScale(.66, .2)
        self.chat_pane.upper_horizontal_line:SetPosition(57, 115, 0)
    end

    if not self.chat_pane.right_line then
        self.chat_pane.right_line = self.chat_pane:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
        self.chat_pane.right_line:SetScale(.5, .41)
        self.chat_pane.right_line:SetPosition(170, -20)
    end

    if not self.chat_pane.left_line then
        self.chat_pane.left_line = self.chat_pane:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
        self.chat_pane.left_line:SetScale(.5, .41)
        self.chat_pane.left_line:SetPosition(-55, -20)
    end

    if not self.chat_pane.lower_horizontal_line then
        self.chat_pane.lower_horizontal_line = self.chat_pane:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
        self.chat_pane.lower_horizontal_line:SetScale(.66, .2)
        self.chat_pane.lower_horizontal_line:SetPosition(57, -150, 0)
    end

    self:MakeTextEntryBox(self.chat_pane)

    self.chatqueue = self.chat_pane:AddChild(LobbyChatQueue(TheNet:GetUserID(), self.chatbox.textbox, function() --[[TODO: put sounds back in!]] end))
    self.chatqueue:SetPosition(42,-20)

    self.chat_pane:SetPosition(75,RESOLUTION_Y-410,0)
end

function LobbyScreen:BuildCharacterDetailsBox()
    self.character_details = self.characterselect_root:AddChild(Widget("character_details"))

    self.biobox = self.character_details:AddChild(TEMPLATES.CurlyWindow(160, 45, .46, .46,  30, -18))

    self.charactername = self.character_details:AddChild(Text(TALKINGFONT, 28))
    self.charactername:SetHAlign(ANCHOR_MIDDLE)
    self.charactername:SetPosition(7, 35)
    self.charactername:SetRegionSize( 500, 70 )
    self.charactername:SetColour(GOLD)

    self.characterdetails = self.character_details:AddChild(Text(NEWFONT_OUTLINE, 21))
    self.characterdetails:SetHAlign(ANCHOR_MIDDLE)
    self.characterdetails:SetVAlign(ANCHOR_TOP)
    self.characterdetails:SetPosition(7, -35)
    self.characterdetails:SetRegionSize( 600, 120 )
    self.characterdetails:EnableWordWrap( true )
    self.characterdetails:SetString( "" )
    self.characterdetails:SetColour(unpack(PORTAL_TEXT_COLOUR))

    self.character_details:SetPosition(RESOLUTION_X/2, RESOLUTION_Y-618, 0)
    self.character_details:MoveToFront()
end

function LobbyScreen:ReceiveChatMessage(...)
    self.chatqueue:OnMessageReceived(...)
end

local SCROLL_REPEAT_TIME = .15
local MOUSE_SCROLL_REPEAT_TIME = 0
local STICK_SCROLL_REPEAT_TIME = .25

function LobbyScreen:OnControl(control, down)
    if LobbyScreen._base.OnControl(self, control, down) then return true end

   -- print("Lobby got control", control, down)

    if self.chatbox ~= nil and ((self.chatbox.textbox ~= nil and self.chatbox.textbox.editing) or (self.chatbox.focus and control == CONTROL_ACCEPT)) then
        self.chatbox.textbox:OnControl(control, down)
        return true
    end

    if self.sidebar_root ~= nil and self.sidebar_root:BlockScroll(control, down) then
        return true
    end

    if not self.no_cancel and not down and control == CONTROL_CANCEL then
        if self.in_readystate then
            self:StartLoadout()
        elseif self.in_loadout then
            self:StartSelection()
        else
            self:DoConfirmQuit()
        end

        return true
    end

    if TheInput:ControllerAttached() and
        self.can_accept and not down and control == CONTROL_MENU_START then

        if (self.in_loadout) then
            StartGame(self)
        else
            self:StartLoadout()
        end

        return true
    end

    -- Use right stick for cycling players list
    if down then
        if not self.in_loadout and control == CONTROL_PREVVALUE then  -- r-stick left
            self:ScrollBack(control)
            return true
        elseif not self.in_loadout and control == CONTROL_NEXTVALUE then -- r-stick right
            self:ScrollFwd(control)
            return true
        elseif control == CONTROL_MENU_MISC_2 then
            if not self.in_loadout then
                self.character_scroll_list:SelectRandomCharacter()
            else
                self.dressup:AllSpinnersToEnd()
            end
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
            return true
        elseif not self.in_loadout then
            if control == CONTROL_SCROLLBACK then
                self:ScrollBack(control)
                return true
            elseif control == CONTROL_SCROLLFWD then
                self:ScrollFwd(control)
                return true
            end
        elseif self.in_loadout then
 			if control == CONTROL_PREVVALUE then  -- r-stick left
    			self.dressup:ScrollBack(control)
				return true
			elseif control == CONTROL_NEXTVALUE then -- r-stick right
				self.dressup:ScrollFwd(control)
				return true
			elseif control == CONTROL_SCROLLBACK then
				self.dressup:ScrollBack(control)
				return true
			elseif control == CONTROL_SCROLLFWD then
    			self.dressup:ScrollFwd(control)
				return true
			end
        end
    end

    return false
end

function LobbyScreen:ScrollBack(control)
    if not self.character_scroll_list.repeat_time or self.character_scroll_list.repeat_time <= 0 then
        self.character_scroll_list:Scroll(-1)
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        self.character_scroll_list.repeat_time =
            TheInput:GetControlIsMouseWheel(control)
            and MOUSE_SCROLL_REPEAT_TIME
            or (control == CONTROL_SCROLLBACK and SCROLL_REPEAT_TIME)
            or (control == CONTROL_PREVVALUE and STICK_SCROLL_REPEAT_TIME)
    end
end

function LobbyScreen:ScrollFwd(control)
    if not self.character_scroll_list.repeat_time or self.character_scroll_list.repeat_time <= 0 then
        self.character_scroll_list:Scroll(1)
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        self.character_scroll_list.repeat_time =
            TheInput:GetControlIsMouseWheel(control)
            and MOUSE_SCROLL_REPEAT_TIME
            or (control == CONTROL_SCROLLFWD and SCROLL_REPEAT_TIME)
            or (control == CONTROL_NEXTVALUE and STICK_SCROLL_REPEAT_TIME)
    end
end

function LobbyScreen:DoFocusHookups()
    if self.in_loadout then
        if self.dressup then
            self.playerList:SetFocusChangeDir(MOVE_RIGHT, self.dressup)
            self.chatbox:SetFocusChangeDir(MOVE_RIGHT, self.dressup)
            self.chatbox.textbox:SetFocusChangeDir(MOVE_RIGHT, self.dressup)
            self.dressup:SetFocusChangeDir(MOVE_LEFT, self.chatbox)
        end
    else
        self.playerList:SetFocusChangeDir(MOVE_RIGHT, self.character_scroll_list)
        self.chatbox:SetFocusChangeDir(MOVE_RIGHT, self.character_scroll_list)
        self.chatbox.textbox:SetFocusChangeDir(MOVE_RIGHT, self.character_scroll_list)
        self.character_scroll_list:SetFocusChangeDir(MOVE_LEFT, self.chatbox)
    end

    self.playerList:SetFocusChangeDir(MOVE_DOWN, self.chatbox)
    self.chatbox:SetFocusChangeDir(MOVE_UP, self.playerList)
    self.chatbox.textbox:SetFocusChangeDir(MOVE_UP, self.playerList)
end

function LobbyScreen:RequestResetLobbyCharacter()
	if not self.in_readystate then
		return true
	end

	if not self.pending_reset_character_request then
		self.pending_reset_character_request = true
		TheNet:SendLobbyCharacterRequestToServer("")
	else
		local client_obj = TheNet:GetClientTableForUser(TheNet:GetUserID())
		if client_obj == nil or client_obj.lobbycharacter == nil or client_obj.lobbycharacter == "" then
			self.in_readystate = false
			self.pending_reset_character_request = false
			self:StartSelection()
		end
	end

	return false
end

function LobbyScreen:StartSelection()
	if not self:RequestResetLobbyCharacter() then
		return  -- wait for response
	end

	self.in_readystate = false
	self.waiting_for_players_root:Hide()

    self.in_loadout = false

    if self.disconnectbutton then
        self.disconnectbutton:Show()
    end

    self.characterselect_root:Show()
    self.characterselect_root:MoveToFront()
    self.loadout_root:Hide()

    if self.backbutton ~= nil then
        self.backbutton:Hide()
    end

    self:DoFocusHookups()

    local right_widget = self.character_scroll_list
    local players = self.playerList:GetPlayerTable()
    self.playerList:BuildPlayerList(players, { right = right_widget, down = self.chatbox })

end

function LobbyScreen:StartLoadout()
	self.in_readystate = false
	self.waiting_for_players_root:Hide()

    self.in_loadout = true

    if self.disconnectbutton ~= nil then
        self.disconnectbutton:Hide()
    end

    self.characterselect_root:Hide()
    self.loadout_root:MoveToFront()
    self.loadout_root:Show()

    if self.backbutton ~= nil then
        self.backbutton:Show()
    end

    self:SetPortraitImage()

    self:DoFocusHookups()

    local right_widget = self.dressup
    local players = self.playerList:GetPlayerTable()
    self.playerList:BuildPlayerList(players, { right = right_widget, down = self.chatbox })

    self.dressup:SetFocus()
end

function LobbyScreen:PlayerReady()
    self.in_readystate = true
    self.in_loadout = false
    self.loadout_root:Hide()

    local skins = self.dressup:GetSkinsForGameStart()
	TheNet:SendLobbyCharacterRequestToServer(self.currentcharacter, skins.base, skins.body, skins.hand, skins.legs, skins.feet)

	self.waiting_for_players_root:Show()
	self.waiting_for_players:Refresh()
end

function LobbyScreen:DoConfirmQuit()
    self.active = false

    local function doquit()
        self.dressup:OnClose()
        self.parent:Disable()
        DoRestart(true)
    end

    if TheNet:GetIsServer() then
        local confirm = PopupDialogScreen(STRINGS.UI.LOBBYSCREEN.HOSTQUITTITLE, STRINGS.UI.LOBBYSCREEN.HOSTQUITBODY, {{text=STRINGS.UI.LOBBYSCREEN.YES, cb = doquit},{text=STRINGS.UI.LOBBYSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  })
        if JapaneseOnPS4() then
            confirm:SetTitleTextSize(40)
            confirm:SetButtonTextSize(30)
        end
        TheFrontEnd:PushScreen(confirm)
    else
        local confirm = PopupDialogScreen(STRINGS.UI.LOBBYSCREEN.CLIENTQUITTITLE, STRINGS.UI.LOBBYSCREEN.CLIENTQUITBODY, {{text=STRINGS.UI.LOBBYSCREEN.YES, cb = doquit},{text=STRINGS.UI.LOBBYSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  })
        if JapaneseOnPS4() then
            confirm:SetTitleTextSize(40)
            confirm:SetButtonTextSize(30)
        end
        TheFrontEnd:PushScreen(confirm)
    end
end

--[[function LobbyScreen:OnFocusMove(dir, down)
    if down then
        if dir == MOVE_LEFT then
                self:Scroll(-1)
                self:SelectPortrait()
            return true
        elseif dir == MOVE_RIGHT then
                self:Scroll(1)
                self:SelectPortrait()
            return true
        end
    end
end]]

function LobbyScreen:SetPortraitImage()
	if self.in_loadout then
		local name = self.dressup:GetBaseSkin()

		if softresolvefilepath("images/names_"..self.currentcharacter..".xml") then
			self.heroname:Show()
			self.heroname:SetTexture("images/names_"..self.currentcharacter..".xml", self.currentcharacter..".tex")
		else
			self.heroname:Hide()
		end

		self.basetitle:Hide()
		self.basequote:Hide()

		if name and name ~= "" and self.currentcharacter ~= "random" then
			self.heroportrait:SetTexture("bigportraits/"..name..".xml", name.."_oval.tex", self.currentcharacter.."_none.tex")

			if self.currentcharacter ~= "wes"  then
				self.basequote:Show()
				self.basequote:SetString("\""..(STRINGS.SKIN_QUOTES[name] or "").."\"")
			else
				self.basequote:Hide()
			end

			self.basetitle:Show()
			self.basetitle:SetString(GetSkinName(name))
		else
			if self.currentcharacter ~= "wes" and self.currentcharacter ~= "random" then
				self.basequote:Show()
				local str = "\""..(STRINGS.SKIN_QUOTES[name] or STRINGS.CHARACTER_QUOTES[self.currentcharacter] or "").."\""
				str = string.gsub(str, "\"\"", "\"")
				self.basequote:SetString(str)
			else
				self.basequote:Hide()
			end
			self.basetitle:Show()
			self.basetitle:SetString(STRINGS.CHARACTER_TITLES[self.currentcharacter])
			--self.basetitle:Hide()
			--self.basequote:Hide()
			--self.basequote:SetString(STRINGS.CHARACTER_QUOTES[self.currentcharacter] or "")
			--print("Loading image", "bigportraits/"..self.currentcharacter.."_none.xml", self.currentcharacter.."_none_oval.tex")

			if softresolvefilepath("bigportraits/"..self.currentcharacter.."_none.xml") then
				self.heroportrait:SetTexture("bigportraits/"..self.currentcharacter.."_none.xml", self.currentcharacter.."_none_oval.tex")
				self.heroportrait:SetPosition(RESOLUTION_X/2-200, RESOLUTION_Y-345)
			else
				self.heroportrait:SetTexture("bigportraits/"..self.currentcharacter..".xml", self.currentcharacter..".tex")
				self.heroportrait:SetPosition(RESOLUTION_X/2-180, RESOLUTION_Y-345)
			end

		end

		self.dressup:UpdatePuppet()
	end
end

function LobbyScreen:SelectPortrait()
    if not self.character_scroll_list then return end

    local herocharacter = self.character_scroll_list:GetCharacter()

    if herocharacter ~= nil then

        self.currentcharacter = herocharacter
        self.dressup:SetCurrentCharacter(herocharacter)

        if self.charactername then
            self.charactername:SetString(STRINGS.CHARACTER_TITLES[herocharacter] or "")
        end
        if self.characterquote then
            self.characterquote:SetString(STRINGS.CHARACTER_QUOTES[herocharacter] or "")
        end
        if self.characterdetails then
            self.characterdetails:SetString(GetCharacterDescription(herocharacter) or "")
        end

        self.dressup:UpdateSpinners()

        self.can_accept = true
        if self.startbutton ~= nil then
            self.startbutton:Enable()
        end
    else
        -- THIS SHOULD NEVER HAPPEN IN DST
        self.can_accept = false
        self.heroportrait:SetTexture("bigportraits/locked.xml", "locked.tex")
        self.charactername:SetString(STRINGS.CHARACTER_NAMES.unknown)
        self.characterquote:SetString("")
        self.characterdetails:SetString("")
        if self.startbutton then
            self.startbutton:Disable()
        end
    end
end

function LobbyScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    if not self.no_cancel then
        if not self.in_loadout then
            table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.LOBBYSCREEN.DISCONNECT)
        else
            table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
        end
    end

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.LOBBYSCREEN.RANDOMCHAR)

    if not self.in_loadout then
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_PREVVALUE) .. "/" .. TheInput:GetLocalizedControl(controller_id, CONTROL_NEXTVALUE) .." " .. STRINGS.UI.HELP.CHANGECHARACTER)
    end

    if self.can_accept then
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_START) .. " " .. STRINGS.UI.LOBBYSCREEN.SELECT)
    end

    return table.concat(t, "  ")
end

function LobbyScreen:OnUpdate(dt)
    if self.time_to_refresh > dt then
        self.time_to_refresh = self.time_to_refresh - dt
    else
        self.time_to_refresh = REFRESH_INTERVAL

		if self.in_readystate then
			self.waiting_for_players:Refresh()
		end

		local right_widget = self.in_loadout and self.dressup or self.character_scroll_list
		self.playerList:Refresh({right = right_widget, down = self.chatbox})
    end

    if self.dressup and self.dressup.puppet then
        self.dressup.puppet:EmoteUpdate(dt)
    end

    if self.pending_reset_character_request then
		self:RequestResetLobbyCharacter()
	end
end

function LobbyScreen:UpdateSpinners()
    self.dressup:UpdateSpinners()
    self:SetPortraitImage()
end

return LobbyScreen
