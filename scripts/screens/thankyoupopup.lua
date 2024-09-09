local Screen = require "widgets/screen"
local Button = require "widgets/button"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local TEMPLATES = require "widgets/templates"

local SkinGifts = require("skin_gifts")

require "skinsutils"


TRANSITION_DURATION = 0.5
DEFAULT_TITLE_SIZE = 55

local ItemIsCurrency = function(item)
    return item.item == ""
end

local GetThankYouBuild = function(item)
    if ItemIsCurrency(item) then
        local currency = item.currency
        if currency == "SPOOLS" then
            return "spool"
        elseif currency == "BOLTS" then
            return "bolt_of_cloth"
        elseif currency == "KLEI_POINTS" then
            return "kleipoints"
        end
    else
        return GetBuildForItem(item.item)
    end
end

local ThankYouPopup = Class(Screen, function(self, items, callbackfn)
    Screen._ctor(self, "ThankYouPopup")

    self.callbackfn = callbackfn

    global("TAB")
    TAB = self

    --darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,0)
    self.black:TintTo({r=0,g=0,b=0,a=0}, {r=0,g=0,b=0,a=0.75}, TRANSITION_DURATION, nil)



    self.center_root = self:AddChild(Widget("ROOT_C"))
    self.center_root:SetVAnchor(ANCHOR_MIDDLE)
    self.center_root:SetHAnchor(ANCHOR_MIDDLE)
    self.center_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.proot = self.center_root:AddChild(Widget("ROOT_P"))
    self.proot:MoveTo({x=0,y=RESOLUTION_Y,z=0}, {x=0,y=0,z=0}, TRANSITION_DURATION, nil)


    self.bg = self.proot:AddChild(Image())
	self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetScale(.97)

    --title
    self.title = self.proot:AddChild(Text(TITLEFONT, DEFAULT_TITLE_SIZE))
    self.title:SetPosition(0, 235, 0)

    -- Actual animation
    self.spawn_portal = self.proot:AddChild(UIAnim())
    self.spawn_portal:SetScale(.7)
    self.spawn_portal:SetPosition(0, -55, 0)
    self.spawn_portal:GetAnimState():SetBuild("skingift_popup") -- file name
    self.spawn_portal:GetAnimState():SetBank("gift_popup") -- top level symbol
    self.spawn_portal:GetAnimState():Hide("banner")
    self.spawn_portal:GetAnimState():Hide("BG")

    -- Text saying "you received" on the upper banner
    self.upper_banner_text = self.proot:AddChild(Text(UIFONT, 50, STRINGS.UI.ITEM_SCREEN.RECEIVED))
    self.upper_banner_text:SetPosition(0, 75, 0)
    self.upper_banner_text:SetColour(36/255, 118/255, 169/255, 1)

    --self.banner = self.proot:AddChild(Image("images/giftpopup.xml", "banner.tex"))
    --self.banner:SetPosition(0, -185, 0)
    --self.banner:SetScale(.9)

    ---- Name of the received item, parented to the banner so they show and hide together
    self.item_name = self.proot:AddChild(Text(UIFONT, 50))
    self.item_name:SetPosition(0, -205, 0)

    --self.banner:Hide()
    self.item_name:Hide()
    self.upper_banner_text:Hide()


    self.right_btn = self.proot:AddChild(ImageButton("images/lobbyscreen.xml", "DSTMenu_PlayerLobby_arrow_paper_R.tex", "DSTMenu_PlayerLobby_arrow_paperHL_R.tex"))
    self.right_btn:SetPosition(275, -55, 0)
    self.right_btn:SetScale(0.6)
    self.right_btn:SetOnClick(
        function() -- Item navigation
            self:ChangeGift(1)
        end)


    self.left_btn = self.proot:AddChild(ImageButton("images/lobbyscreen.xml", "DSTMenu_PlayerLobby_arrow_paper_L.tex", "DSTMenu_PlayerLobby_arrow_paperHL_L.tex"))
    self.left_btn:SetPosition(-275, -55, 0)
    self.left_btn:SetScale(0.6)
    self.left_btn:SetOnClick(
        function() -- Item navigation
            self:ChangeGift(-1)
        end)

    -- Open skin button
    self.open_btn = self.proot:AddChild(ImageButton("images/ui.xml", "button_large.tex", "button_large_over.tex", "button_large_disabled.tex"))
    self.open_btn:SetFont(BUTTONFONT)
    self.open_btn:SetText(STRINGS.UI.ITEM_SCREEN.OPEN_BUTTON)
    self.open_btn:SetScale(0.85)
    self.open_btn:SetPosition(0, -280, 0)
    self.open_btn:SetOnClick(function() self:OpenGift() end)
    self.open_btn:Hide()

    -- Close popup button, only shows up after ALL skins have been opened
    self.close_btn = self.proot:AddChild(ImageButton("images/ui.xml", "button_large.tex", "button_large_over.tex", "button_large_disabled.tex"))
    self.close_btn:SetFont(BUTTONFONT)
    self.close_btn:SetText(STRINGS.UI.ITEM_SCREEN.OK_BUTTON)
    self.close_btn:SetScale(0.85)
    self.close_btn:SetPosition(0, -280, 0)
    self.close_btn:SetOnClick(function() self:GoAway() end)
    self.close_btn:Hide()

    self.items = items
    self.revealed_items = {}
    self.current_item = 1

    self.can_open = false;
    self.can_close = false;
	self.can_right = false;
	self.can_left = false;

    self:EvaluateButtons()
    self:ChangeGift(0)

    self:AddChild(TEMPLATES.ForegroundLetterbox())
end)

function ThankYouPopup:OnUpdate(dt)
    if self.spawn_portal:GetAnimState():IsCurrentAnimation("skin_loop") then
        -- We just revealed a new skin
        if self.reveal_skin then
            self.reveal_skin = false
            self:EvaluateButtons()
            self:SetSkinName()
            if not TheFrontEnd:GetSound():PlayingSound("gift_idle") then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_recieves_gift_idle", "gift_idle")
            end
        -- We just navigated to an already revealed skin
        elseif self.transitioning then
            self.transitioning = false
            self:EvaluateButtons()
            self:SetSkinName()
            if not TheFrontEnd:GetSound():PlayingSound("gift_idle") then
                TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_recieves_gift_idle", "gift_idle")
            end
        end
    -- We're closing the popup
    elseif self.spawn_portal:GetAnimState():IsCurrentAnimation("skin_out") and self.spawn_portal:GetAnimState():AnimDone() and not self.transitioning then

        self.transitioning = true

        self.proot:MoveTo({x=0,y=0,z=0}, {x=0,y=RESOLUTION_Y,z=0}, TRANSITION_DURATION, nil)
        self.black:TintTo({r=0,g=0,b=0,a=0.75}, {r=0,g=0,b=0,a=0}, TRANSITION_DURATION, function()
            if self.callbackfn then
                self.callbackfn()
            end
            TheFrontEnd:PopScreen(self)
        end)

    -- We just navigated to an unrevealed skin
    elseif self.spawn_portal:GetAnimState():IsCurrentAnimation("idle") and self.transitioning then
        self.transitioning = false
        self.can_open = true
        self.open_btn:Show()
        if not TheFrontEnd:GetSound():PlayingSound("gift_idle") then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_recieves_gift_idle", "gift_idle")
        end
    end
end

-- Sets the name of the skin on the banner and enables the close button if needed
function ThankYouPopup:SetSkinName()
    if ItemIsCurrency(self.items[self.current_item]) then
        self.item_name:SetColour({ 1.000, 1.000, 1.000, 1 })

        local currency = self.items[self.current_item].currency
        if currency == "SPOOLS" then
            currency = STRINGS.UI.PLAYERSUMMARYSCREEN.CURRENCY_LABEL
        elseif currency == "BOLTS" then
            currency = STRINGS.UI.PURCHASEPACKSCREEN.VIRTUAL_CURRENCY
        elseif currency == "KLEI_POINTS" then
            currency = STRINGS.UI.PLAYERSUMMARYSCREEN.POINTS_LABEL
        end
        self.item_name:SetString( subfmt( STRINGS.UI.REDEEMDIALOG.CURRENCY_FMT, { currency = currency, currency_amt = self.items[self.current_item].currency_amt }) )
    else
        local skin_name = string.lower(self.items[self.current_item].item)

        self.item_name:SetColour(GetColorForItem(skin_name))
        self.item_name:SetString(GetSkinName(skin_name))
        --self.banner:Show()
    end

    self.item_name:Show()
    self.upper_banner_text:Show()
end

-- Enables or disables arrows according to our current item
function ThankYouPopup:EvaluateButtons()
    local revealed_items_size = 0
    for k,v in pairs(self.revealed_items) do
        revealed_items_size = revealed_items_size + 1
    end

    if revealed_items_size == #self.items and not self.transitioning then
        self.can_close = true
        self.close_btn:Show()
    end

    if #self.items == 1 then
        self.right_btn:Hide()
        self.left_btn:Hide()
		self.can_right = false;
		self.can_left = false;
    else
        if self.current_item == #self.items then
            self.right_btn:Hide()
            self.left_btn:Show()
			self.can_right = false;
			self.can_left = true;
        elseif self.current_item == 1 then
            self.right_btn:Show()
            self.left_btn:Hide()
			self.can_right = true;
			self.can_left = false;
        else
            self.right_btn:Show()
            self.left_btn:Show()
			self.can_right = true;
			self.can_left = true;
        end
    end
end

-- Sets the new Gift after we navigated
function ThankYouPopup:ChangeGift(offset)
    self.current_item = math.clamp(self.current_item + offset, 1, #self.items)

    self.item_name:Hide()
    self.upper_banner_text:Hide()
    local gt = self.items[self.current_item].gifttype
    local gt_data = SkinGifts.popupdata[gt] or SkinGifts.popupdata["DEFAULT"]
    self.bg:SetTexture(gt_data.atlas, gt_data.image)

	local message = self.items[self.current_item].message
    self.title:SetString( (message ~= "" and message) or STRINGS.THANKS_POPUP[gt] )
    self.title:SetSize( gt_data.title_size or DEFAULT_TITLE_SIZE )

    if gt_data.titleoffset ~= nil then
        self.title:SetPosition(
                gt_data.titleoffset[1] + 0,
                gt_data.titleoffset[2] + 235,
                gt_data.titleoffset[3] + 0
            )
    else
        self.title:SetPosition(0,235,0)
    end

    TheFrontEnd:GetSound():KillSound("gift_idle")

    if not self.revealed_items[self.current_item] then -- Unopened item
    	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_receives_gift_animation_spin", "ty_activate_sound")
        self.spawn_portal:GetAnimState():PlayAnimation("activate")
        self.spawn_portal:GetAnimState():PushAnimation("idle", true)
        self.open_btn:Hide()
        self.close_btn:Hide()

		self.can_open = false;
		self.can_close = false;

    else -- Already opened item
        local build = GetThankYouBuild(self.items[self.current_item])
        self.spawn_portal:GetAnimState():OverrideSkinSymbol("SWAP_ICON", build, "SWAP_ICON")
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_receives_gift_animation_spin", "ty_skin_in_sound")
        self.spawn_portal:GetAnimState():PlayAnimation("skin_in")
        self.spawn_portal:GetAnimState():PushAnimation("skin_loop", true)
        self.close_btn:Hide()
        self.open_btn:Hide()

		self.can_open = false;
		self.can_close = false;
    end

    self.transitioning = true
    self:EvaluateButtons()
end

-- Plays the closing animation
function ThankYouPopup:GoAway()
    self.can_close = false
	TheFrontEnd:GetSound():KillSound("gift_idle")
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_receives_gift_animation_skinout", "ty_close_sound")
    self.spawn_portal:GetAnimState():PlayAnimation("skin_out")

    --self.banner:Hide()
    self.item_name:Hide()
    self.upper_banner_text:Hide()
    self.right_btn:Hide()
    self.left_btn:Hide()
    self.close_btn:Hide()
end

-- Plays the open gift animation
function ThankYouPopup:OpenGift()
    self.can_open = false
    self.open_btn:Hide()
    self.right_btn:Hide()
    self.left_btn:Hide()

    local build = GetThankYouBuild(self.items[self.current_item])
    self.spawn_portal:GetAnimState():OverrideSkinSymbol("SWAP_ICON", build, "SWAP_ICON")

    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/player_receives_gift_animation", "ty_open_sound")
    self.spawn_portal:GetAnimState():PlayAnimation("open")
    self.spawn_portal:GetAnimState():PushAnimation("skin_loop", true)

    -- Mark the item as revealed
    self.revealed_items[self.current_item] = true
    self.reveal_skin = true -- Used on update
    if self.items[self.current_item].item_id ~= 0 then
        TheInventory:SetItemOpened(self.items[self.current_item].item_id)
    end
end

function ThankYouPopup:OnControl(control, down)
    if ThankYouPopup._base.OnControl(self,control, down) then
        return true
    end

    if not down and control == CONTROL_ACCEPT then
        if self.can_open then
            self:OpenGift()
        elseif self.can_close then
            self:GoAway()
        else
            local anim_state = self.spawn_portal:GetAnimState()
            if anim_state:IsCurrentAnimation("activate") then
                TheFrontEnd:GetSound():KillSound("ty_activate_sound")
                anim_state:PlayAnimation("idle", true)

            elseif anim_state:IsCurrentAnimation("open") then
                TheFrontEnd:GetSound():KillSound("ty_open_sound")
                anim_state:PlayAnimation("skin_loop", true)

            elseif anim_state:IsCurrentAnimation("skin_in") then
                TheFrontEnd:GetSound():KillSound("ty_skin_in_sound")
                anim_state:PlayAnimation("skin_loop", true)

            elseif anim_state:IsCurrentAnimation("skin_loop") then
                --we can't close, so we must have a left or right to go to, move to the right then loop back
                if self.can_right then
                    self:ChangeGift(1)
                else
                    self.current_item = 1
                    self:ChangeGift(0)
                end

            elseif anim_state:IsCurrentAnimation("skin_out") then
                anim_state:SetTime(anim_state:GetCurrentAnimationLength())
                TheFrontEnd:GetSound():KillSound("ty_close_sound")
            else
                print("I'm impatient! Can we speed up the popup anymore here?")
            end
        end
        return true
    end

    if not down and self.can_left and control == CONTROL_SCROLLBACK then
        self:ChangeGift(-1)
        return true
    elseif not down and self.can_right and control == CONTROL_SCROLLFWD then
        self:ChangeGift(1)
        return true
    end
end

function ThankYouPopup:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}

	if self.can_open then
    	table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.ITEM_SCREEN.OPEN_BUTTON)
    elseif self.can_close then
		table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.ITEM_SCREEN.OK_BUTTON)
    end

    if self.can_left then
		if self.can_right then
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK, false, false) .. "/" .. TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD, false, false) .. " " .. STRINGS.UI.HELP.CHANGEPAGE)
		else
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLBACK, false, false) .. " " .. STRINGS.UI.HELP.PREV)
		end
	elseif self.can_right then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_SCROLLFWD, false, false) .. " " .. STRINGS.UI.HELP.NEXT)
	end

    return table.concat(t, "  ")
end

return ThankYouPopup
