local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local ShadowedText = require "widgets/redux/shadowedtext"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

local ANR_BETA_COUNTDOWN_LAYOUT = false -- BRANCH == "staging" or BRANCH == "dev"
local ANR_BETA_COUNTDOWN_DATE = {year = 2017, day = 23, month = 2, hour = 23}    -- nil, {year = 2016, day = 8, month = 12, hour = 23}
local ANR_BETA_COUNTDOWN_MODE = "released"                                       -- "text", "image", "reveal", "released"
local ANR_BETA_COUNTDOWN_IMAGE = "silhouette_beta_8b"                             -- "silhouette_beta_1", "silhouette_beta_2"
local ANR_BETA_COUNTDOWN_NAME = "\"Heart of the Ruins\""                         -- nil or "\"Update Name\""

local WorldGenScreen = require "screens/worldgenscreen"
local PopupDialogScreen = require "screens/popupdialog"
local RedeemDialog = require "screens/redeemdialog"
local PlayerHud = require "screens/playerhud"
local EmailSignupScreen = require "screens/emailsignupscreen"
local MovieDialog = require "screens/moviedialog"
local CreditsScreen = require "screens/creditsscreen"
local ModsScreen = require "screens/modsscreen"
local Countdown = require "widgets/countdown"
local CountdownBeta = require "widgets/countdownbeta"

local OptionsScreen = require "screens/optionsscreen"
local MorgueScreen = require "screens/morguescreen"
local QuickJoinScreen = require "screens/quickjoinscreen"
local ServerListingScreen = require "screens/serverlistingscreen"
local ServerCreationScreen = require "screens/servercreationscreen"
local SkinsScreen = require "screens/skinsscreen"

local SkinsAndEquipmentPuppet = require "widgets/skinsandequipmentpuppet"

local TEMPLATES = require "widgets/templates"

local OnlineStatus = require "widgets/onlinestatus"

local ThankYouPopup = require "screens/thankyoupopup"

local Stats = require("stats")

local SkinGifts = require("skin_gifts")


local rcol = RESOLUTION_X/2 -170
local lcol = -RESOLUTION_X/2 +200

local bottom_offset = 60

local titleX = lcol-35
local titleY = 195
local menuX = lcol-30
local menuY = -260

SHOW_DST_DEBUG_HOST_JOIN = false
SHOW_DEBUG_UNLOCK_RESET = false
if BRANCH == "dev" then
	SHOW_DST_DEBUG_HOST_JOIN = true
    SHOW_DEBUG_UNLOCK_RESET = true
end

local function PickTwo(choices, no_dupe)
    local choice1 = math.random(1, #choices)
    local choice2 = math.random(2, #choices)
	if choice2 == choice1 then
		choice2 = 1
	end

	if no_dupe then
		local choice2_start = choice2
		while choices[choice1].name == choices[choice2].name do
			choice2 = ((choice2 + 1) % #choices) + 1
			--check if a player with this name is already chosen
			if choice2 == choice2_start then
				return {choices[choice1]} --no good second choice, so just return 1
			end
		end
	end

    return {choices[choice1], choices[choice2]}
end


local MultiplayerMainScreen = Class(Screen, function(self, prev_screen, profile, offline, session_data)
	Screen._ctor(self, "MultiplayerMainScreen")
    self.profile = profile
    self.offline = offline
    self.session_data = session_data
	self.log = true
    self.prev_screen = prev_screen
	self:DoInit()
	self.default_focus = self.menu
end)

function MultiplayerMainScreen:DoInit()
    -- Inherited from MainScreen
    self.portal_root = self:AddChild(Widget("portal_root"))
    self:TransferPortalOwnership(self.prev_screen, self)

    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--RIGHT COLUMN
    self.right_col = self.fixed_root:AddChild(Widget("right"))
	self.right_col:SetPosition(rcol, 0)

	--LEFT COLUMN
    self.left_col = self.fixed_root:AddChild(Widget("left"))
	self.left_col:SetPosition(lcol, 0)

	self.motd = self.right_col:AddChild(Widget("motd"))
	self.motd:SetScale(.9,.9,.9)
	self.motd:SetPosition(-30, RESOLUTION_Y/2-250, 0)
	self.motdbg = self.motd:AddChild( TEMPLATES.CurlyWindow(0, 153, .56, 1, 67, -42))
    self.motdbg:SetPosition(-8, -30)
    self.motdbg.fill = self.motd:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
    self.motdbg.fill:SetScale(-.405, -.7)
    self.motdbg.fill:SetPosition(-3, -18)
	self.motd.motdtitle = self.motd:AddChild(Text(BUTTONFONT, 43))
    self.motd.motdtitle:SetColour(0,0,0,1)
    self.motd.motdtitle:SetPosition(0, 70, 0)
	self.motd.motdtitle:SetRegionSize( 350, 60)
	self.motd.motdtitle:SetString(STRINGS.UI.MAINSCREEN.MOTDTITLE)

	self.motd.motdtext = self.motd:AddChild(Text(BUTTONFONT, 32))
    self.motd.motdtext:SetColour(0,0,0,1)
    self.motd.motdtext:SetHAlign(ANCHOR_MIDDLE)
    self.motd.motdtext:SetVAlign(ANCHOR_MIDDLE)
    self.motd.motdtext:SetPosition(0, -40, 0)
	self.motd.motdtext:SetRegionSize(240, 260)
	self.motd.motdtext:SetString(STRINGS.UI.MAINSCREEN.MOTD)

	self.motd.motdimage = self.motd:AddChild(ImageButton( "images/global.xml", "square.tex", "square.tex", "square.tex" ))
    self.motd.motdimage:SetPosition(-2, -15, 0)
    self.motd.motdimage:SetFocusScale(1, 1, 1)
    self.motd.motdimage:Hide()
	self.motd.motdimage:SetOnClick(
		function()
			self.motd.button.onclick()
		end)

    self.motd.button = self.motd:AddChild(ImageButton())
	self.motd.button:SetPosition(0,-160)
    self.motd.button:SetScale(.8*.9)
    self.motd.button:SetText(STRINGS.UI.MAINSCREEN.MOTDBUTTON)
    self.motd.button:SetOnClick( function() VisitURL("http://store.kleientertainment.com/") end )
	self.motd.motdtext:EnableWordWrap(true)


	local gainfocusfn_img = self.motd.motdimage.OnGainFocus
    local losefocusfn_img = self.motd.motdimage.OnLoseFocus

    self.motd.motdimage.OnGainFocus =
		function()
    		gainfocusfn_img(self.motd.motdimage)
    		self.motd.button.image:SetTexture(self.motd.button.atlas, self.motd.button.image_focus)
		end
	self.motd.motdimage.OnLoseFocus =
		function()
    		losefocusfn_img(self.motd.motdimage)
			if not self.motd.button.focus then
    			self.motd.button.image:SetTexture(self.motd.button.atlas, self.motd.button.image_normal)
    		end
		end

    self.motd.button.OnGainFocus =
		function()
    		self.motd.button._base.OnGainFocus(self.motd.button)
    		self.motd.button.image:SetTexture(self.motd.button.atlas, self.motd.button.image_focus)
		end
	self.motd.button.OnLoseFocus =
		function()
    		self.motd.button._base.OnLoseFocus(self.motd.button)
			if not self.motd.motdimage.focus then
    			self.motd.button.image:SetTexture(self.motd.button.atlas, self.motd.button.image_normal)
    		end
		end


	self.fixed_root:AddChild(Widget("left"))

	self.countdown = self.fixed_root:AddChild(Countdown())
    self.countdown:SetScale(1)
    self.countdown:SetPosition(-575, -330, 0)

    local puppet_data = {
        {
            startpos = {x=0,y=0},
            endpos = {x=95,y=-260},
            startscale = .1,
            endscale = .52,
        },
        {
            flip = true,
            startpos = {x=0,y=0},
            endpos = {x=-30,y=-275},
            startscale = .1,
            endscale = .6,
        },
    }
    local shadowpos = {x=-6,y=-5}
    local shadowscale = .3

    local characters = PickTwo(DST_CHARACTERLIST)

    self.puppets = {}

    for i,data in ipairs(puppet_data) do
        self.puppets[i] = self.fg.character_root:AddChild(SkinsAndEquipmentPuppet(characters[i], FRONTEND_CHARACTER_FAR_COLOUR, {(data.flip and -1 or 1)*data.endscale,data.endscale, data.endscale}))

        self.puppets[i]:StartAnimUpdate()
        self.puppets[i]:SetPosition(data.endpos.x, data.endpos.y,0)
        self.puppets[i].shadow = self.puppets[i]:AddChild(Image("images/frontend.xml", "char_shadow.tex"))
        self.puppets[i].shadow:SetPosition(shadowpos.x,shadowpos.y)
        self.puppets[i].shadow:SetScale(shadowscale)
        self.puppets[i].shadow:MoveToBack()

    end

    self.countdown:Hide()

    self.menu_bg = self.fixed_root:AddChild(TEMPLATES.LeftGradient())

    self.title = self.fixed_root:AddChild(Image("images/frontscreen.xml", "title.tex"))
    self.title:SetScale(.32)
    self.title:SetPosition(titleX, titleY)
    self.title:SetTint(unpack(FRONTEND_TITLE_COLOUR))


	local updatename_root_x = -RESOLUTION_X * .5 + 180
	local updatename_root_y = -RESOLUTION_Y * .5 + 55
	self.updatename_root_on = Vector3( updatename_root_x, updatename_root_y, 0 )
	self.updatename_root_off = Vector3( updatename_root_x-300, updatename_root_y, 0 )

    self.updatename_root = self.fixed_root:AddChild(Widget("updatename"))
    self.updatename_root:SetPosition( self.updatename_root_on )
    self.updatenameshadow = self.updatename_root:AddChild(Text(BUTTONFONT, 21))
    self.updatenameshadow:SetPosition(2, 2,0)
    self.updatenameshadow:SetColour(.1,.1,.1,1)
	self.updatenameshadow:SetHAlign(ANCHOR_LEFT)
    self.updatenameshadow:SetRegionSize(200,45)
    self.updatename = self.updatename_root:AddChild(Text(BUTTONFONT, 21))
    self.updatename:SetPosition(0,0,0)
    self.updatename:SetColour(1,1,1,1)
    self.updatename:SetHAlign(ANCHOR_LEFT)
    self.updatename:SetRegionSize(200,45)
    local suffix = ""
    if BRANCH == "dev" then
		suffix = " (internal v"..APP_VERSION..")"
    elseif BRANCH == "staging" then
		suffix = " (preview v"..APP_VERSION..")"
    else
        suffix = " (v"..APP_VERSION..")"
    end
    self.updatename:SetString(STRINGS.UI.MAINSCREEN.DST_UPDATENAME .. suffix)
    self.updatenameshadow:SetString(STRINGS.UI.MAINSCREEN.DST_UPDATENAME .. suffix)

    --hack to deal with updatename_root going outside the view box and is a less complex solution than trying to interleave the updatename between bg and fg while still being infront of the main menu gradient
    self.update_blackcover = self.fixed_root:AddChild(Image("images/global.xml", "square.tex"))
    self.update_blackcover:SetPosition( updatename_root_x-355, updatename_root_y )
    self.update_blackcover:ScaleToSize( 350, 45 )
	self.update_blackcover:SetTint(0, 0, 0, 1)

    self:MakeMainMenu()
	self:MakeSubMenu()

    self.onlinestatus = self.fixed_root:AddChild(OnlineStatus( true ))

	self:UpdateMOTD()
	--self:UpdateCountdown()
    ----------------------------------------------------------

	self.filter_settings = nil

	--focus moving
    if self.debug_menu then
        self.motd.button:SetFocusChangeDir(MOVE_LEFT, self.menu, -1)
        self.motd.button:SetFocusChangeDir(MOVE_DOWN, self.submenu)
        self.menu:SetFocusChangeDir(MOVE_RIGHT, self.motd.button)
        self.submenu:SetFocusChangeDir(MOVE_LEFT, self.menu, -1)
        self.submenu:SetFocusChangeDir(MOVE_UP, self.motd.button)

        self.debug_menu:SetFocusChangeDir(MOVE_DOWN, self.menu, -1)
        self.debug_menu:SetFocusChangeDir(MOVE_LEFT, self.menu, -1)
        self.menu:SetFocusChangeDir(MOVE_LEFT, self.debug_menu)
    else
    	self.motd.button:SetFocusChangeDir(MOVE_LEFT, self.menu, -1)
        self.motd.button:SetFocusChangeDir(MOVE_DOWN, self.submenu)
    	self.menu:SetFocusChangeDir(MOVE_RIGHT, self.motd.button)
    	self.submenu:SetFocusChangeDir(MOVE_LEFT, self.menu, -1)
        self.submenu:SetFocusChangeDir(MOVE_UP, self.motd.button)
    end

	if ANR_BETA_COUNTDOWN_LAYOUT then
		self.beta_countdown = self.right_col:AddChild(CountdownBeta(self, ANR_BETA_COUNTDOWN_MODE, ANR_BETA_COUNTDOWN_IMAGE, ANR_BETA_COUNTDOWN_NAME, ANR_BETA_COUNTDOWN_DATE))
		self.beta_countdown:SetScale(.8)
		self.beta_countdown:SetPosition(0, -150, 0)

		self.motd:SetScale(.8)
		self.motd:SetPosition(0, RESOLUTION_Y/2-180, 0)

		if self.beta_countdown.button ~= nil then
			self.beta_countdown:SetFocusChangeDir(MOVE_DOWN, self.submenu)
			self.beta_countdown:SetFocusChangeDir(MOVE_UP, self.motd.button)
			self.submenu:SetFocusChangeDir(MOVE_UP, self.beta_countdown)
			self.motd.button:SetFocusChangeDir(MOVE_DOWN, self.beta_countdown)
		end

		self.right_gradient = self.fixed_root:AddChild(TEMPLATES.RightGradient())
		self.right_gradient:MoveToBack()
	end

    self.menu:SetFocus(#self.menu.items)

    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        self.snowfall = self:AddChild(TEMPLATES.Snowfall())
        self.snowfall:SetVAnchor(ANCHOR_TOP)
        self.snowfall:SetHAnchor(ANCHOR_MIDDLE)
        self.snowfall:SetScaleMode(SCALEMODE_PROPORTIONAL)
        if self.fg ~= nil then
            self.fg.snowfall = self.snowfall
        end
    end

    --V2C: This is so the first time we become active will trigger OnShow to UpdatePuppets
    self:Hide()
end

function MultiplayerMainScreen:UpdatePuppets()
    PlayerHistory:SortBackwards("sort_date")
    self.player_history = PlayerHistory:GetRows()

    local tools = PickTwo(MAINSCREEN_TOOL_LIST)
    local torsos = PickTwo(MAINSCREEN_TORSO_LIST)
    local hats = PickTwo(MAINSCREEN_HAT_LIST)

	local players = {}
    local total_characters = {}
    if self.player_history and next(self.player_history) then
        for k,v in pairs(self.player_history) do
            table.insert(total_characters, v)
        end
    end
	local player_characters = {}--self.profile:GetAllRecentLoadouts()
    if #player_characters > 0 then
        table.insert(total_characters, player_characters[math.random(1, #player_characters)])
    end

    if #total_characters >= 2 then
        players = PickTwo(total_characters, true)
    elseif #total_characters == 1 then
		players[1] = total_characters[1]
    end

    for i,puppet in pairs(self.puppets) do
		if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
			local halloween_baseskins = {wilson="wilson_pigguard", willow="willow_dragonfly", wolfgang="wolfgang_walrus", wendy="wendy_lureplant",
										wx78="wx78_rhinorook", wickerbottom="wickerbottom_lightninggoat", woodie="woodie_treeguard", wes="wes_mandrake",
										waxwell="waxwell_krampus", wathgrithr="wathgrithr_deerclops", webber="webber_bat", winona="winona_grassgecko" }

			local data = (players[i] and table.contains(DST_CHARACTERLIST, players[i].prefab)) and players[i] or { prefab=DST_CHARACTERLIST[math.random(#DST_CHARACTERLIST)], name="" }
			data.base_skin = halloween_baseskins[data.prefab]
			data.body_skin = nil
			data.hand_skin = nil
			data.legs_skin = nil
			data.feet_skin = nil
            puppet:InitSkins(data)
		else
            if players[i] then
                puppet:InitSkins(players[i])
            end
		end
        puppet:SetTool(tools[i])
        puppet:SetTorso(torsos[i])
        puppet:SetHat(hats[i])

        local puppet_alpha = -30*FRAMES - (i-1)*45*FRAMES
        local puppet_lastalpha = puppet_alpha
        puppet.animstate:SetMultColour(0,0,0,1)
        if puppet.fadetask ~= nil then
            puppet.fadetask:Cancel()
        end
        puppet.fadetask = puppet.inst:DoPeriodicTask(0, function()
            puppet_alpha = puppet_alpha + FRAMES
            if puppet_alpha > -15*FRAMES and puppet_lastalpha <= -15*FRAMES then
                self.bg.anim_root.portal:GetAnimState():PlayAnimation("portal_spawnplayer", false)
                self.bg.anim_root.portal:GetAnimState():PushAnimation("portal_idle", true)
            end
            if puppet_alpha > -8*FRAMES and puppet_lastalpha <= -8*FRAMES then
                TheFrontEnd:GetSound():PlaySound("dontstarve/common/spawn/spawnportal_open")
            end
            if puppet_alpha > 0 and puppet_lastalpha <= 0 then
                self.puppets[i]:Show()
            end
            puppet_lastalpha = puppet_alpha
            if puppet_alpha < 1 then
                puppet.animstate:SetMultColour(puppet_alpha*puppet_alpha, puppet_alpha*puppet_alpha, puppet_alpha*puppet_alpha, 1)
            else
                puppet.animstate:SetMultColour(1,1,1,1)
                puppet.fadetask:Cancel()
                puppet.fadetask = nil
            end
        end)

        puppet:Hide()
    end
end

function MultiplayerMainScreen:OnShow()
    self._base:OnShow()
    self.fg.character_root:SetCanFadeAlpha(false)
    self.fg.character_root:Show()
    self:UpdatePuppets()
    if self.snowfall ~= nil then
        self.snowfall:StartSnowfall()
    end
    if self.fg.perds ~= nil then
        self.fg.perds:StartPerds()
    end
end

function MultiplayerMainScreen:OnHide()
    self._base:OnHide()
    self.fg.character_root:SetCanFadeAlpha(true)
    self.fg.character_root:Hide()
    for i, puppet in pairs(self.puppets) do
        if puppet.fadetask ~= nil then
            puppet.fadetask:Cancel()
            puppet.fadetask = nil
        end
        puppet:Hide()
    end
    if self.snowfall ~= nil then
        self.snowfall:StopSnowfall()
    end
    if self.fg.perds ~= nil then
        self.fg.perds:StopPerds()
    end
end

function MultiplayerMainScreen:TransferPortalOwnership(src, dest)
    --src and dest are Screens
    local bg_root = dest.portal_root or dest
    local fg_root = dest.portal_root or dest
    dest.bg = bg_root:AddChild(src.bg)
    dest.fg = fg_root:AddChild(src.fg)
end

function MultiplayerMainScreen:OnDestroy()
    self:OnHide()
    self.fg.character_root:KillAllChildren()
    self:TransferPortalOwnership(self, self.prev_screen)
    self._base.OnDestroy(self)
end

function MultiplayerMainScreen:OnRawKey(key, down)
end

function MultiplayerMainScreen:OnCreateServerButton()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true
    TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
        Profile:ShowedNewUserPopup()
        Profile:Save(function()
            TheFrontEnd:PushScreen(ServerCreationScreen(self))
            TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
            self:Hide()
        end)
    end)
end

function MultiplayerMainScreen:OnGameWizardButton()
    -- needs implementation...
end

function MultiplayerMainScreen:OnSkinsButton()
	self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true
    TheFrontEnd:Fade(false, SCREEN_FADE_TIME, function()
        TheFrontEnd:PushScreen(SkinsScreen(Profile))
        TheFrontEnd:Fade(true, SCREEN_FADE_TIME)
        self:Hide()
    end)
end

function MultiplayerMainScreen:OnBrowseServersButton()
    if self:CheckNewUser(self.OnBrowseServersButton, STRINGS.UI.MAINSCREEN.NEWUSER_NO) then
        return
    end

    local function cb(filters)
	    self.filter_settings = filters
	    Profile:SaveFilters(self.filter_settings)
    end

	if not self.filter_settings then
		self.filter_settings = Profile:GetSavedFilters()
	end

    if self.filter_settings and #self.filter_settings > 0 then
        for i,v in pairs(self.filter_settings) do
			if v.name == "SHOWLAN" then
				v.data = self.offline
			end
		end
    else
        self.filter_settings = {}
        table.insert(self.filter_settings, {name = "SHOWLAN", data=self.offline} )
    end

    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true
    TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
        Profile:ShowedNewUserPopup()
        Profile:Save(function()
            TheFrontEnd:PushScreen(ServerListingScreen(self, self.filter_settings, cb, self.offline, self.session_data))
            TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
            self:Hide()
        end)
    end)
end

function MultiplayerMainScreen:OnQuickJoinServersButton()
    if self:CheckNewUser(self.OnQuickJoinServersButton, STRINGS.UI.MAINSCREEN.NEWUSER_NO_QUICKJOIN) then
        return
    end

    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true

    TheFrontEnd:PushScreen(QuickJoinScreen(self, self.offline, self.session_data,
		"",
		CalcQuickJoinServerScore,
		function() self:OnCreateServerButton() end,
		function() self:OnBrowseServersButton() end))
end

-- MORGUE
function MultiplayerMainScreen:OnHistoryButton()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	self.menu:Disable()
	TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
		TheFrontEnd:PushScreen(MorgueScreen(self))
		TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
        self:Hide()
	end)
end

-- SUBSCREENS

function MultiplayerMainScreen:Settings()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	self.menu:Disable()
	TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
		TheFrontEnd:PushScreen(OptionsScreen(self))
		TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
        self:Hide()
	end)
end

function MultiplayerMainScreen:EmailSignup()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	TheFrontEnd:PushScreen(EmailSignupScreen())
end

function MultiplayerMainScreen:Forums()
	VisitURL("http://forums.kleientertainment.com/forum/73-dont-starve-together-beta/")
end

function MultiplayerMainScreen:Quit()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.ASKQUIT, STRINGS.UI.MAINSCREEN.ASKQUITDESC, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() RequestShutdown() end },{text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  }))
end

function MultiplayerMainScreen:OnModsButton()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	self.menu:Disable()
    if self.debug_menu then self.debug_menu:Disable() end
	TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
		TheFrontEnd:PushScreen(ModsScreen(self))
		TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
        self:Hide()
	end)
end

function MultiplayerMainScreen:ResetProfile()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.RESETPROFILE, STRINGS.UI.MAINSCREEN.SURE, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() self.profile:Reset() TheFrontEnd:PopScreen() end},{text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  }))
end

function MultiplayerMainScreen:UnlockEverything()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.UNLOCKEVERYTHING, STRINGS.UI.MAINSCREEN.SURE, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() self.profile:UnlockEverything() TheFrontEnd:PopScreen() end},{text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  }))
end

local function OnMovieDone()
    TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
    TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_idle_vines", "FEPortalSFX")
    TheFrontEnd:Fade(FADE_IN, 2)
end

function MultiplayerMainScreen:OnMovieButton()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    TheFrontEnd:GetSound():KillSound("FEMusic")
    TheFrontEnd:GetSound():KillSound("FEPortalSFX")
    self.menu:Disable()
    if self.debug_menu ~= nil then
        self.debug_menu:Disable()
    end
    TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
        TheFrontEnd:PushScreen(MovieDialog("movies/intro.ogv", OnMovieDone))
        TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
        self:Hide()
    end)
end

function MultiplayerMainScreen:OnCreditsButton()
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	TheFrontEnd:GetSound():KillSound("FEMusic")
    TheFrontEnd:GetSound():KillSound("FEPortalSFX")
	self.menu:Disable()
    if self.debug_menu then self.debug_menu:Disable() end
	TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, function()
		TheFrontEnd:PushScreen(CreditsScreen())
		TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
        self:Hide()
	end)
end

function MultiplayerMainScreen:OnRedeemButton()
	self.last_focus_widget = TheFrontEnd:GetFocusWidget()
	TheFrontEnd:PushScreen(RedeemDialog())
end

function MultiplayerMainScreen:OnHostButton()
    SaveGameIndex:LoadServerEnabledModsFromSlot()
    KnownModIndex:Save()
    local start_in_online_mode = false
    local slot = SaveGameIndex:GetCurrentSaveSlot()
    if TheNet:StartServer(start_in_online_mode, slot, SaveGameIndex:GetSlotServerData(slot)) then
        DisableAllDLC()
        StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = slot })
    end
end

function MultiplayerMainScreen:OnJoinButton()
	local start_worked = TheNet:StartClient(DEFAULT_JOIN_IP)
	if start_worked then
        DisableAllDLC()
	end
	ShowLoading()
end

function MultiplayerMainScreen:MakeMainMenu()
	local menu_items = {}

    local function MakeMainMenuButton(text, onclick, tooltip)
        local btn = Button()
        btn:SetFont(BUTTONFONT)
        btn:SetDisabledFont(BUTTONFONT)
        btn:SetTextColour(unpack(GOLD))
        btn:SetTextFocusColour(1, 1, 1, 1)
        btn:SetText(text, true)
        btn.text:SetRegionSize(180,40)
        btn.text:SetHAlign(ANCHOR_LEFT)
        btn.text_shadow:SetRegionSize(180,40)
        btn.text_shadow:SetHAlign(ANCHOR_LEFT)
        btn:SetTextSize(35)

        btn.image = btn:AddChild(Image("images/frontscreen.xml", "highlight_hover.tex"))
        btn.image:MoveToBack()
        btn.image:SetScale(.6)
        btn.image:SetPosition(-20,3)
        btn.image:SetClickable(false)
        btn.image:Hide()

        btn.bg = btn:AddChild(Image("images/ui.xml", "blank.tex"))
        local w,h = btn.text:GetRegionSize()
        btn.bg:ScaleToSize(200, h+15)

        btn.OnGainFocus = function()
            if btn.text then btn.text:SetColour(btn.textfocuscolour[1],btn.textfocuscolour[2],btn.textfocuscolour[3],btn.textfocuscolour[4]) end
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
            btn.image:Show()
            self.tooltip:SetString(tooltip)

            self.updatename_root:CancelMoveTo()
			self.updatename_root:SetPosition( self.updatename_root_off )
        end

        btn.OnLoseFocus = function()
            if btn:IsEnabled() and not btn.selected then
                btn.text:SetColour(btn.textcolour)
            end
            if btn.o_pos then
                btn:SetPosition(btn.o_pos)
            end
            btn.down = false

            btn.image:Hide()
            if not self.menu.focus then
                self.tooltip:SetString("")
				self.updatename_root:MoveTo( self.updatename_root_off, self.updatename_root_on, .5 )
            end
        end
        btn:SetOnClick(onclick)
        -- btn:SetScale(.75)

        return btn
    end

    local quickjoin_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.QUICKJOIN, function() self:OnQuickJoinServersButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_QUICKJOIN)
    local browse_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.BROWSE, function() self:OnBrowseServersButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_BROWSE)
    local host_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.CREATE, function() self:OnCreateServerButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_HOST)
    --local wizard_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.GAMEWIZARD, function() self:OnGameWizardButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_WIZARD)
    local skins_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.SKINS, function() self:OnSkinsButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_SKINS)
    local history_button = MakeMainMenuButton(STRINGS.UI.MORGUESCREEN.HISTORY, function() self:OnHistoryButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_HISTORY)
    local options_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.OPTIONS, function() self:Settings() end, STRINGS.UI.MAINSCREEN.TOOLTIP_OPTIONS)
    local quit_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.QUIT, function() self:Quit() end, STRINGS.UI.MAINSCREEN.TOOLTIP_QUIT)

    if MODS_ENABLED then
        local mods_button = MakeMainMenuButton(STRINGS.UI.MAINSCREEN.MODS, function() self:OnModsButton() end, STRINGS.UI.MAINSCREEN.TOOLTIP_MODS)
        menu_items = {
            {widget = quit_button},
            {widget = mods_button},
            {widget = history_button},
            {widget = options_button},
            --{widget = wizard_button},
            {widget = skins_button},
            {widget = host_button},
            {widget = browse_button},
        }
    else
        menu_items = {
            {widget = quit_button},
            {widget = history_button},
            {widget = options_button},
            --{widget = wizard_button},
            {widget = skins_button},
            {widget = host_button},
            {widget = browse_button},
        }
    end

	if not TheFrontEnd:GetIsOfflineMode() then
		-- Disabling Quick Join (its is a work in progress)
		--table.insert(menu_items, {widget = quickjoin_button})
	end

    --if PLATFORM == "WIN32_STEAM" or PLATFORM == "WIN32" then
    --  table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.BROADCASTING, cb= function() self:BroadcastingMenu() end})
    --end
    self.menu = self.fixed_root:AddChild(Menu(menu_items, 43, nil, nil, true))
    self.menu:SetPosition(menuX, menuY)

    self.tooltip = self.fixed_root:AddChild(ShadowedText(NEWFONT, 30))
    self.tooltip:SetHAlign(ANCHOR_LEFT)
    self.tooltip:SetRegionSize(800,45)
    local tooltipX = menuX+310
    self.tooltip:SetPosition(tooltipX, -(RESOLUTION_Y*.5)+57, 0)

    -- For Debugging/Testing
    local debug_menu_items = {}

    if SHOW_DEBUG_UNLOCK_RESET then
        table.insert( debug_menu_items, {text=STRINGS.UI.MAINSCREEN.RESETPROFILE, cb= function() self:ResetProfile() end})
        table.insert( debug_menu_items, {text=STRINGS.UI.MAINSCREEN.UNLOCKEVERYTHING, cb= function() self:UnlockEverything() end})
    end

    if SHOW_DST_DEBUG_HOST_JOIN then
        table.insert( debug_menu_items, {text=STRINGS.UI.MAINSCREEN.JOIN, cb= function() self:OnJoinButton() end})
        table.insert( debug_menu_items, {text=STRINGS.UI.MAINSCREEN.HOST, cb= function() self:OnHostButton() end})
    end

    if #debug_menu_items > 0 then
        self.debug_menu = self.fixed_root:AddChild(Menu(debug_menu_items, 74))
        self.debug_menu:SetPosition(menuX+230, 120, 0)
        self.debug_menu:SetScale(.8)
        self.debug_menu.reverse = true
    end
end

function MultiplayerMainScreen:MakeSubMenu()
    local submenuitems = {}

    local function MakeSubMenuButton(name, text, onclick)
        local btn = ImageButton("images/frontscreen.xml", name..".tex", nil, nil, nil, nil, {1,1}, {0,0})
        btn.image:SetPosition(0, 70)
        btn:SetTextColour(unpack(GOLD))
        btn:SetTextFocusColour(unpack(GOLD))
        btn:SetFocusScale(1.05, 1.05, 1.05)
        btn:SetNormalScale(1, 1, 1)
        btn:SetText(text)
        btn.bg = btn:AddChild(Image("images/ui.xml", "blank.tex"))
        local w,h = btn.text:GetRegionSize()
        btn.bg:ScaleToSize(w+15, h+15)
        local gainfocusfn = btn.OnGainFocus
        local losefocusfn = btn.OnLoseFocus
        btn.OnGainFocus = function()
            gainfocusfn(btn)
            btn:SetTextSize(43)
        end
        btn.OnLoseFocus = function()
            losefocusfn(btn)
            btn:SetTextSize(40)
        end
        btn:SetOnClick(onclick)
        btn:SetScale(.75)

        return btn
    end

    local credits_button = TEMPLATES.IconButton("images/button_icons.xml", "credits.tex", STRINGS.UI.MAINSCREEN.CREDITS, false, true, function() self:OnCreditsButton() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})
    local movie_button = TEMPLATES.IconButton("images/button_icons.xml", "movie.tex", STRINGS.UI.MAINSCREEN.MOVIE, false, true, function() self:OnMovieButton() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})
    local forums_button = TEMPLATES.IconButton("images/button_icons.xml", "forums.tex", STRINGS.UI.MAINSCREEN.FORUM, false, true, function() self:Forums() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})
    local newsletter_button = TEMPLATES.IconButton("images/button_icons.xml", "newsletter.tex", STRINGS.UI.MAINSCREEN.NOTIFY, false, true, function() self:EmailSignup() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})

    if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then

        local more_games_button = TEMPLATES.IconButton("images/button_icons.xml", "more_games.tex", STRINGS.UI.MAINSCREEN.MOREGAMES, false, true, function() VisitURL("http://store.steampowered.com/search/?developer=Klei%20Entertainment") end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})

        if TheFrontEnd:GetAccountManager():HasSteamTicket() then

            local manage_account_button = TEMPLATES.IconButton("images/button_icons.xml", "profile.tex", STRINGS.UI.SERVERCREATIONSCREEN.MANAGE_ACCOUNT, false, true, function() TheFrontEnd:GetAccountManager():VisitAccountPage() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})

			local online = TheNet:IsOnlineMode() and not TheFrontEnd:GetIsOfflineMode()
			if online then
				local redeem_button = TEMPLATES.IconButton("images/button_icons.xml", "redeem.tex", STRINGS.UI.MAINSCREEN.REDEEM, false, true, function() self:OnRedeemButton() end, {font=NEWFONT_OUTLINE, focus_colour={1,1,1,1}})
	            submenuitems =
				{
            		{widget = redeem_button},
					{widget = manage_account_button},
                    {widget = movie_button},
					{widget = credits_button},
					{widget = forums_button},
					{widget = more_games_button},
					{widget = newsletter_button},
				}
			else
				--have steam ticket, but offline
				submenuitems =
				{
					{widget = manage_account_button},
                    {widget = movie_button},
					{widget = credits_button},
					{widget = forums_button},
					{widget = more_games_button},
					{widget = newsletter_button},
				}
			end
        else
			--no valid steam ticket
            submenuitems =
            {
                {widget = movie_button},
                {widget = credits_button},
                {widget = forums_button},
                {widget = more_games_button},
                {widget = newsletter_button},
            }
        end
    else
        submenuitems =
            {
                {widget = movie_button},
                {widget = credits_button},
                {widget = forums_button},
                {widget = newsletter_button},
            }
    end

    self.submenu = self.fixed_root:AddChild(Menu(submenuitems, 75, true))
    if TheInput:ControllerAttached() then
        self.submenu:SetPosition( RESOLUTION_X*.5 - (#submenuitems*60), -(RESOLUTION_Y*.5)+80, 0)
    else
        self.submenu:SetPosition( RESOLUTION_X*.5 - (#submenuitems*60), -(RESOLUTION_Y*.5)+77, 0)
    end
    self.submenu:SetScale(.8)
end

function MultiplayerMainScreen:OnBecomeActive()
    MultiplayerMainScreen._base.OnBecomeActive(self)

    if not self.shown then
        self:Show()
    end

	self.menu:RestoreFocusTo(self.last_focus_widget)

    if self.debug_menu then self.debug_menu:Enable() end

    self.leaving = nil

    --start a new query everytime we go back to the mainmenu
	if TheSim:IsLoggedOn() then
		TheSim:StartWorkshopQuery()
	end

end

function MultiplayerMainScreen:FinishedFadeIn()
	--Do new entitlement items
	local items = {} -- early access thank you gifts
    local entitlement_items = TheInventory:GetUnopenedEntitlementItems()
	for _,item in pairs(entitlement_items) do
		table.insert(items, { item = item.item_type, item_id = item.item_id, gifttype = SkinGifts.types[item.item_type] or "DEFAULT" })
	end

    if #items > 0 then
        local thankyou_popup = ThankYouPopup(items)
        TheFrontEnd:PushScreen(thankyou_popup)
    else
		--Make sure we only do one mainscreen popup at a time
		--Do language mods assistance popup
		local interface_lang = TheNet:GetLanguageCode()
		if interface_lang ~= "english" then
			if Profile:GetValue("language_mod_asked_"..interface_lang) ~= true then
				TheSim:QueryServer( "https://s3.amazonaws.com/ds-mod-language/dst_mod_languages.json",
				function( result, isSuccessful, resultCode )
 					if isSuccessful and string.len(result) > 1 and resultCode == 200 then
 						local status, language_mods = pcall( function() return json.decode(result) end )
						local lang_popup = language_mods[interface_lang]
						if status and lang_popup ~= nil then
							if lang_popup.collection ~= "" then
								local popup_screen = PopupDialogScreen( lang_popup.title, lang_popup.body,
										{
											{text=lang_popup.yes, cb = function() VisitURL("http://steamcommunity.com/workshop/filedetails/?id="..lang_popup.collection) TheFrontEnd:PopScreen() self:OnModsButton() end },
											{text=lang_popup.no, cb = function() TheFrontEnd:PopScreen() end}
										}
									)
								popup_screen.text:SetFont(BUTTONFONT)

								TheFrontEnd:PushScreen( popup_screen )
								Profile:SetValue("language_mod_asked_"..interface_lang, true)
								Profile:Save()
							end
						end
					end
				end, "GET" )
			end
		end
	end
end


local anims =
{
	scratch = .5,
	hungry = .5,
	eat = .5,
	eatquick = .33,
	wave1 = .1,
	wave2 = .1,
	wave3 = .1,
	happycheer = .1,
	sad = .1,
	angry = .1,
	annoyed = .1,
	facepalm = .1
}

function MultiplayerMainScreen:OnUpdate(dt)
	if self.bg.anim_root.portal:GetAnimState():AnimDone() and not self.leaving then
    	if math.random() < .33 then
			self.bg.anim_root.portal:GetAnimState():PlayAnimation("portal_idle_eyescratch", false)
    	else
    		self.bg.anim_root.portal:GetAnimState():PlayAnimation("portal_idle", false)
    	end
    end
end

function MultiplayerMainScreen:OnGetMOTDImageQueryComplete( is_successful )
	if is_successful then
		self.motd.motdimage:SetTextures( "images/motd.xml", "motd.tex", "motd.tex", "motd.tex", "motd.tex", "motd.tex" )
		self.motd.motdimage:Show()
	end
end

local function push_motd_event( event, url, image_version )
	local values = {}
	values.url = url .. "#" .. tostring(image_version)
	Stats.PushMetricsEvent(event, TheNet:GetUserID(), values)
end

function MultiplayerMainScreen:SetMOTD(str, cache)
	--print("MultiplayerMainScreen:SetMOTD", str, cache)

	local status, motd = pcall( function() return json.decode(str) end )
	--print("decode:", status, motd)
	if status and motd then
	    if cache then
	 		SavePersistentString("motd_image", str)
	    end

		local platform_motd = motd.dststeam

		if platform_motd then
			--make sure we have an actual valid URL
			if not string.match( platform_motd.link_url, "http://" ) and not string.match( platform_motd.link_url, "https://" ) then
				platform_motd.link_url = "http://" .. platform_motd.link_url
			end

		    self.motd:Show()
		    if platform_motd.motd_title and string.len(platform_motd.motd_title) > 0 and
			    	platform_motd.motd_body and string.len(platform_motd.motd_body) > 0 then

			    self.motdbg.fill:Show()
			    self.motd.motdtitle:Show()
				self.motd.motdtitle:SetString(platform_motd.motd_title)
				self.motd.motdtext:Show()
				self.motd.motdtext:SetString(platform_motd.motd_body)
				self.motd.motdimage:Hide()

			    if platform_motd.link_title and string.len(platform_motd.link_title) > 0 and
				    	platform_motd.link_url and string.len(platform_motd.link_url) > 0 then
				    self.motd.button:SetText(platform_motd.link_title)
				    self.motd.button:SetOnClick( function()
				    	push_motd_event( "motd.clicked", platform_motd.link_url, platform_motd.image_version or 0 )
						VisitURL(platform_motd.link_url)
					end )
				else
					self.motd.button:Hide()
				end
		    elseif platform_motd.image_url and string.len(platform_motd.image_url) > 0 then

			    self.motdbg.fill:Hide()
				self.motd.motdtitle:Hide()
				self.motd.motdtext:Hide()

				local use_disk_file = not cache
				if use_disk_file then
					self.motd.motdimage:Hide()
				end

				if platform_motd.link_title and string.len(platform_motd.link_title) > 0 and
				    	platform_motd.link_url and string.len(platform_motd.link_url) > 0 then
				    self.motd.button:SetText(platform_motd.link_title)
				    self.motd.button:SetOnClick( function()
				    	push_motd_event( "motd.clicked", platform_motd.link_url, platform_motd.image_version or 0 )
						VisitURL(platform_motd.link_url)
					end )
				else
					self.motd.button:Hide()
				end

				TheSim:GetMOTDImage( platform_motd.image_url, use_disk_file, platform_motd.image_version or "", function(...) self:OnGetMOTDImageQueryComplete(...) end )
		    else
				self.motd:Hide()
		    end


			if cache then --the one we cache is the latest we downloaded
				push_motd_event( "motd.seen", platform_motd.link_url, platform_motd.image_version or 0 )
			end
	    else
			self.motd:Hide()
		end
	end
end

function MultiplayerMainScreen:OnMOTDQueryComplete( result, isSuccessful, resultCode )
	--print( "MultiplayerMainScreen:OnMOTDQueryComplete", result, isSuccessful, resultCode )
 	if isSuccessful and string.len(result) > 1 and resultCode == 200 then
 		self:SetMOTD(result, true)
	end
end

function MultiplayerMainScreen:OnCachedMOTDLoad(load_success, str)
	--print("MultiplayerMainScreen:OnCachedMOTDLoad", load_success, str)
	if load_success and string.len(str) > 1 then
		self:SetMOTD(str, false)
	end
	TheSim:QueryServer( "https://d21wmy1ql1e52r.cloudfront.net/ds_image_motd.json", function(...) self:OnMOTDQueryComplete(...) end, "GET" )
	--TheSim:QueryServer( "https://s3-us-west-2.amazonaws.com/kleifiles/external/ds_image_motd.json", function(...) self:OnMOTDQueryComplete(...) end, "GET" )
end

function MultiplayerMainScreen:UpdateMOTD()
	TheSim:GetPersistentString("motd_image", function(...) self:OnCachedMOTDLoad(...) end)
end

function MultiplayerMainScreen:SetCountdown(str, cache)
	local status, ud = pcall( function() return json.decode(str) end )
	--print("decode:", status, ud)
	if status and ud then
	    if cache then
	 		SavePersistentString("updatecountdown", str)
	    end

	    local update_date = nil
		if PLATFORM == "WIN32_STEAM" or PLATFORM == "LINUX_STEAM" or PLATFORM == "OSX_STEAM" then
			if IsDLCInstalled(REIGN_OF_GIANTS) then
				update_date = {year = ud.rogsteam.update_year, day = ud.rogsteam.update_day, month = ud.rogsteam.update_month, hour = 13}
			else
				update_date = {year = ud.steam.update_year, day = ud.steam.update_day, month = ud.steam.update_month, hour = 13}
			end
		else
			if IsDLCInstalled(REIGN_OF_GIANTS) then
				update_date = {year = ud.rogstandalone.update_year, day = ud.rogstandalone.update_day, month = ud.rogstandalone.update_month, hour = 13}
			else
				update_date = {year = ud.standalone.update_year, day = ud.standalone.update_day, month = ud.standalone.update_month, hour = 13}
			end
		end

		if update_date and self.countdown:ShouldShowCountdown(update_date) then
		    self.countdown:Show()
            for i,puppet in ipairs(self.puppets) do
                puppet:Show()
            end
	    else
			self.countdown:Hide()
            for i,puppet in ipairs(self.puppets) do
                puppet:Hide()
            end
		end
	end
end

function MultiplayerMainScreen:OnCountdownQueryComplete( result, isSuccessful, resultCode )
	--print( "MultiplayerMainScreen:OnMOTDQueryComplete", result, isSuccessful, resultCode )
 	if isSuccessful and string.len(result) > 1 and resultCode == 200 then
 		self:SetCountdown(result, true)
	end
end

function MultiplayerMainScreen:OnCachedCountdownLoad(load_success, str)
	--print("MultiplayerMainScreen:OnCachedCountdownLoad", load_success, str)
	if load_success and string.len(str) > 1 then
		self:SetCountdown(str, false)
	end
	TheSim:QueryServer( "https://s3-us-west-2.amazonaws.com/kleifiles/external/ds_update.json", function(...) self:OnCountdownQueryComplete(...) end, "GET" )
end

function MultiplayerMainScreen:UpdateCountdown()
	--print("MultiplayerMainScreen:UpdateMOTD()")
	TheSim:GetPersistentString("updatecountdown", function(...) self:OnCachedCountdownLoad(...) end)
end

function MultiplayerMainScreen:CheckNewUser(onnofn, no_button_text)
    if Profile:SawNewUserPopup() then
        return false
    end

    local popup = PopupDialogScreen(
        STRINGS.UI.MAINSCREEN.NEWUSER_DETECTED_HEADER,
        STRINGS.UI.MAINSCREEN.NEWUSER_DETECTED_BODY,
        {
            {
                text = STRINGS.UI.MAINSCREEN.NEWUSER_YES,
                cb = function()
                    TheFrontEnd:PopScreen()
                    Profile:ShowedNewUserPopup()
                    self:OnCreateServerButton()
                end,
                offset = Vector3(-25, 0, 0),
            },
            {
                text = no_button_text,
                cb = function()
                    TheFrontEnd:PopScreen()
                    Profile:ShowedNewUserPopup()
                    onnofn(self)
                end,
                offset = Vector3(25, 0, 0),
            },
        }
    )

    for i, v in ipairs(popup.menu.items) do
        v:ForceImageSize(300, 65)
    end

    TheFrontEnd:PushScreen(popup)
    return true
end

return MultiplayerMainScreen
