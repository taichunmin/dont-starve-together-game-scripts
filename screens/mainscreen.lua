local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"
require "os"

local PopupDialogScreen = require "screens/popupdialog"
local EmailSignupScreen = require "screens/emailsignupscreen"
local MovieDialog = require "screens/moviedialog"
local MultiplayerMainScreen = require "screens/multiplayermainscreen"
local NetworkLoginPopup = require "screens/networkloginpopup"

local OnlineStatus = require "widgets/onlinestatus"

local rcol = RESOLUTION_X/2 -200
local lcol = -RESOLUTION_X/2 + 280
local title_x = 20
local title_y = 10
local subtitle_offset_x = 20
local subtitle_offset_y = -260

local bottom_offset = 60

local menuX = lcol+10
local menuY = -215

local DEBUG_MODE = BRANCH == "dev"

local MainScreen = Class(Screen, function(self, profile)
	Screen._ctor(self, "MainScreen")
    self.profile = profile
	self.log = true
    self.targetversion = -1
	self:DoInit()
    self.default_focus = self.play_button
    self.music_playing = false
end)

function MainScreen:DoInit()
    TheNet:LoadPermissionLists()

	TheFrontEnd:GetGraphicsOptions():DisableStencil()
	TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()

	TheInputProxy:SetCursorVisible(true)

    self.portal_root = self:AddChild(Widget("portal_root"))
    self.bg = self.portal_root:AddChild(TEMPLATES.AnimatedPortalBackground())
    self.fg = self.portal_root:AddChild(TEMPLATES.AnimatedPortalForeground())

	-- FIXED ROOT
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.dark_card = self.fixed_root:AddChild(Image("images/global.xml", "square.tex"))
    self.dark_card:SetVRegPoint(ANCHOR_MIDDLE)
    self.dark_card:SetHRegPoint(ANCHOR_MIDDLE)
    self.dark_card:SetVAnchor(ANCHOR_MIDDLE)
    self.dark_card:SetHAnchor(ANCHOR_MIDDLE)
    self.dark_card:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.dark_card:SetTint(0,0,0,.75)

	--LEFT COLUMN
    self.left_col = self.fixed_root:AddChild(Widget("left"))
	self.left_col:SetPosition(lcol-100, 0)

    self.title = self.fixed_root:AddChild(Image("images/frontscreen.xml", "title.tex"))
    self.title:SetScale(.65)
    self.title:SetPosition(title_x, title_y-5)
    self.title:SetTint(unpack(FRONTEND_TITLE_COLOUR))

    self.presents_image = self.fixed_root:AddChild(Image("images/frontscreen.xml", "kleipresents.tex"))
    self.presents_image:SetPosition(title_x+subtitle_offset_x-30, title_y-subtitle_offset_y+30, 0)
    self.presents_image:SetScale(.7)
    self.presents_image:SetTint(unpack(FRONTEND_TITLE_COLOUR))

    self.legalese_image = self.fixed_root:AddChild(Image("images/frontscreen.xml", "legalese.tex"))
    self.legalese_image:SetPosition(title_x+subtitle_offset_x, title_y+subtitle_offset_y-50, 0)
    self.legalese_image:SetScale(.7)
    self.legalese_image:SetTint(unpack(FRONTEND_TITLE_COLOUR))

    --RIGHT COLUMN
    self.right_col = self.fixed_root:AddChild(Widget("right"))
    self.right_col:SetPosition(rcol, 0)

    self.play_button = self.fixed_root:AddChild(ImageButton("images/frontscreen.xml", "play_highlight.tex", nil, nil, nil, nil, {1,1}, {0,0}))--"highlight.tex", "highlight_hover.tex"))
    self.play_button.bg = self.play_button:AddChild(Image("images/frontscreen.xml", "play_highlight_hover.tex"))
    self.play_button.bg:SetScale(.69, .53)
    self.play_button.bg:MoveToBack()
    self.play_button.bg:Hide()
    self.play_button.image:SetPosition(0,3)
    self.play_button.bg:SetPosition(0,3)
    self.play_button:SetPosition(-RESOLUTION_X*.35, 0)
    self.play_button:SetTextColour(1, 1, 1, 1)
    self.play_button:SetTextFocusColour(1, 1, 1, 1)
    self.play_button:SetTextDisabledColour({1,1,1,1})
    self.play_button:SetNormalScale(.65, .5)
    self.play_button:SetFocusScale(.7, .55)
    self.play_button:SetTextSize(55)
    self.play_button:SetFont(TITLEFONT)
    self.play_button:SetDisabledFont(TITLEFONT)
    self.play_button:SetText(STRINGS.UI.MAINSCREEN.PLAY, true, {2,-3})
    local playgainfocusfn = self.play_button.OnGainFocus
    local playlosefocusfn = self.play_button.OnLoseFocus
    self.play_button.OnGainFocus = function()
        playgainfocusfn(self.play_button)
        self.play_button:SetTextSize(58)
        self.play_button.image:SetTint(1,1,1,1)
        self.play_button.bg:Show()
    end
    self.play_button.OnLoseFocus = function()
        playlosefocusfn(self.play_button)
        self.play_button:SetTextSize(55)
        self.play_button.image:SetTint(1,1,1,.6)
        self.play_button.bg:Hide()
    end
    self.play_button:SetOnClick(function()
    	self.play_button:Disable()
        self:OnLoginButton(true)
    end)

    self.exit_button = self.fixed_root:AddChild(ImageButton("images/frontend.xml", "turnarrow_icon.tex", "turnarrow_icon_over.tex", nil, nil, nil, {1,1}, {0,0}))
    self.exit_button:SetPosition(-RESOLUTION_X*.4, -RESOLUTION_Y*.5 + BACK_BUTTON_Y)
    self.exit_button.image:SetPosition(-53, 2)
    self.exit_button.image:SetScale(.7)
    self.exit_button:SetTextColour(unpack(GOLD))
    self.exit_button:SetTextFocusColour(1,1,1,1)
    self.exit_button:SetText(STRINGS.UI.MAINSCREEN.QUIT, true, {2,-2})
    self.exit_button:SetFont(TITLEFONT)
    self.exit_button:SetDisabledFont(TITLEFONT)
    self.exit_button:SetTextDisabledColour({ unpack(GOLD) })
    self.exit_button.bg = self.exit_button:AddChild(Image("images/ui.xml", "blank.tex"))
    local w,h = self.exit_button.text:GetRegionSize()
    self.exit_button.bg:ScaleToSize(w+15, h+15)
    local exitgainfocusfn = self.exit_button.OnGainFocus
    local exitlosefocusfn = self.exit_button.OnLoseFocus
    self.exit_button.OnGainFocus = function()
        exitgainfocusfn(self.exit_button)
        self.exit_button:SetScale(1.05)
    end
    self.exit_button.OnLoseFocus = function()
        exitlosefocusfn(self.exit_button)
        self.exit_button:SetScale(1)
    end
    self.exit_button:SetOnClick(function()
        self:Quit()
    end)

    if TheInput:ControllerAttached() then
        self.legalese_image:SetPosition(title_x+subtitle_offset_x, title_y+subtitle_offset_y-50+20, 0)
        self.exit_button:SetPosition(-RESOLUTION_X*.4, -RESOLUTION_Y*.5 + BACK_BUTTON_Y+25)
    end

    self.onlinestatus = self.fixed_root:AddChild(OnlineStatus())

	self:UpdateCurrentVersion()

	self.filter_settings = nil

	--focus moving
    self.play_button:SetFocusChangeDir(MOVE_DOWN, self.exit_button)
    self.exit_button:SetFocusChangeDir(MOVE_UP, self.play_button)

	self:MakeDebugButtons()
    self.play_button:SetFocus()
end

function MainScreen:OnRawKey(key, down)
end

function MainScreen:OnControl(control, down)
    if MainScreen._base.OnControl(self,control, down) then return true end

    if DEBUG_MODE then
        if control == CONTROL_MENU_START then
            -- Use gamepad start button to host game so you can keep mashing
            -- start to get into game.
            self:OnHostButton()
            return true

        elseif control == CONTROL_MENU_BACK then
            -- Make gamepad back a compliment to start: join instead of host.
            self:OnJoinButton()
            return true
        end
    end

    return false
end

local PLAY_BUTTON_FADE_TIME = 1.0

-- MULTIPLAYER PLAY
function MainScreen:OnLoginButton(push_mp_main_screen)
    local account_manager = TheFrontEnd:GetAccountManager()
	local hadPendingConnection = TheNet:HasPendingConnection()

    local function GoToMultiplayerMainMenu(offline)
		TheFrontEnd:SetOfflineMode(offline)
		--self.bg.anim_root.portal:GetAnimState():PlayAnimation("portal_blackout", false)
		if push_mp_main_screen then
            local function session_mapping_cb(data)
				local mp_main_screen = MultiplayerMainScreen(self, self.profile, offline, data)
                TheFrontEnd:PushScreen(mp_main_screen)
                TheFrontEnd:Fade(FADE_IN, PLAY_BUTTON_FADE_TIME, function() mp_main_screen:FinishedFadeIn() end, nil, nil, "alpha")
                self:Hide()
            end
            if not TheNet:DeserializeAllLocalUserSessions(session_mapping_cb) then
                session_mapping_cb()
            end
        else
            TheFrontEnd:Fade(FADE_IN, PLAY_BUTTON_FADE_TIME, nil, nil, nil, "alpha")
		end
    end

    local function onCancel()
        self.play_button:Enable()
        self.exit_button:Enable()
        -- self.menu:Enable()
    end

    local function checkVersion()
        if self.targetversion == -1 then
            return "waiting"
        elseif self.targetversion == -2 then
            return "error"
        elseif tonumber(APP_VERSION) < self.targetversion then
            return "old"
        else
            return "current"
        end
    end

    local function onLogin(forceOffline)
	    local account_manager = TheFrontEnd:GetAccountManager()
	    local is_banned = (account_manager:IsBanned() == true)
	    local must_upgrade = account_manager:MustUpgradeClient()
	    local communication_succeeded = account_manager:CommunicationSucceeded()
	    local inventory_succeeded = TheInventory:HasDownloadedInventory()
		local has_auth_token = account_manager:HasAuthToken()

        if is_banned then -- We are banned
        	TheFrontEnd:PopScreen()
	        TheNet:NotifyAuthenticationFailure()
        -- We are on a deprecated version of the game
        elseif must_upgrade then
        	TheFrontEnd:PopScreen()
        	TheNet:NotifyAuthenticationFailure()
        	OnNetworkDisconnect( "E_UPGRADE", true)
        elseif checkVersion() == "old" and not DEBUG_MODE then
            TheFrontEnd:PopScreen()
            local confirm = PopupDialogScreen( STRINGS.UI.MAINSCREEN.VERSION_OUT_OF_DATE_TITLE, STRINGS.UI.MAINSCREEN.VERSION_OUT_OF_DATE_BODY,
                        {
                         {text=STRINGS.UI.MAINSCREEN.VERSION_OUT_OF_DATE_PLAY,
                                    cb = function()
                                        TheFrontEnd:PopScreen()
                                        TheFrontEnd:Fade(FADE_OUT, PLAY_BUTTON_FADE_TIME,
                                            function()
                                                GoToMultiplayerMainMenu(true)
                                            end, nil, nil, "alpha")
                                    end },
                         {text=STRINGS.UI.MAINSCREEN.VERSION_OUT_OF_DATE_INSTRUCTIONS,
                                    cb = function()
                                        onCancel()
                                        TheFrontEnd:PopScreen()
                                        VisitURL("http://forums.kleientertainment.com/forum/86-check-for-latest-steam-build/")
                                    end },
                         {text=STRINGS.UI.MAINSCREEN.VERSION_OUT_OF_DATE_CANCEL,
                                    cb = function()
                                        onCancel()
                                        TheFrontEnd:PopScreen()
                                    end}
                        }, false, 140)
            for i,v in pairs(confirm.menu.items) do
                v.image:SetScale(.6, .7)
            end
            TheFrontEnd:PushScreen(confirm)
        elseif ( has_auth_token and communication_succeeded ) or forceOffline then
            if hadPendingConnection then
                TheFrontEnd:PopScreen()
            else
                --if not push_mp_main_screen then
                    TheFrontEnd:PopScreen()
                --end

                TheFrontEnd:Fade(FADE_OUT, PLAY_BUTTON_FADE_TIME, function()
                    --if push_mp_main_screen then
                        --TheFrontEnd:PopScreen()
                    --end

                    GoToMultiplayerMainMenu(forceOffline or false )

                    --TheFrontEnd:Fade(FADE_IN, PLAY_BUTTON_FADE_TIME)
                end, nil, nil, "alpha")
            end
        elseif not communication_succeeded then  -- We could not communicate with our auth server or steam is down
            print ( "failed_communication" )
            TheFrontEnd:PopScreen()
            local confirm = PopupDialogScreen( STRINGS.UI.MAINSCREEN.OFFLINEMODE,STRINGS.UI.MAINSCREEN.OFFLINEMODEDESC,
								{
								  	{text=STRINGS.UI.MAINSCREEN.PLAYOFFLINE, cb = function()
								  		TheFrontEnd:PopScreen()
								  		TheFrontEnd:Fade(FADE_OUT, PLAY_BUTTON_FADE_TIME, function()
								  			GoToMultiplayerMainMenu(true)
                                        end, nil, nil, "alpha")
								  	end },
								  	{text=STRINGS.UI.MAINSCREEN.CANCELOFFLINE,   cb = function()
								  		onCancel()
								  		TheFrontEnd:PopScreen()
								  	end}
								})
            TheFrontEnd:PushScreen(confirm)
            TheNet:NotifyAuthenticationFailure()
        elseif (not inventory_succeeded and has_auth_token) then
            print ( "[Warning] Failed to download local inventory" )
        end
    end

	if TheSim:IsLoggedOn() or account_manager:HasAuthToken() then
		if TheSim:GetUserHasLicenseForApp(DONT_STARVE_TOGETHER_APPID) then
			account_manager:Login( "Client Login" )
			TheFrontEnd:PushScreen(NetworkLoginPopup(onLogin, checkVersion, onCancel, hadPendingConnection))
		else
			TheNet:NotifyAuthenticationFailure()
			OnNetworkDisconnect( "APP_OWNERSHIP_CHECK_FAILED", false, false )
		end
	else
		-- Set lan mode
		TheNet:NotifyAuthenticationFailure()
		local confirm = PopupDialogScreen( STRINGS.UI.MAINSCREEN.STEAMOFFLINEMODE,STRINGS.UI.MAINSCREEN.STEAMOFFLINEMODEDESC,
						{
						 {text=STRINGS.UI.MAINSCREEN.PLAYOFFLINE, cb = function() TheFrontEnd:PopScreen() GoToMultiplayerMainMenu(true) end },
						 {text=STRINGS.UI.MAINSCREEN.CANCELOFFLINE,  cb = function() onCancel() TheFrontEnd:PopScreen() end}
						})
		TheFrontEnd:PushScreen(confirm)
	end

	-- self.menu:Disable()
    self.play_button:Disable()
    self.exit_button:Disable()
end

function MainScreen:EmailSignup()
	TheFrontEnd:PushScreen(EmailSignupScreen())
end

function MainScreen:Forums()
	VisitURL("http://forums.kleientertainment.com/forum/73-dont-starve-together-beta/")
end

function MainScreen:Quit()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.ASKQUIT, STRINGS.UI.MAINSCREEN.ASKQUITDESC, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() RequestShutdown() end },{text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  }))
end

function MainScreen:OnHostButton()
    SaveGameIndex:LoadServerEnabledModsFromSlot()
    KnownModIndex:Save()
    local start_in_online_mode = false
    local slot = SaveGameIndex:GetCurrentSaveSlot()
    if TheNet:StartServer(start_in_online_mode, slot, SaveGameIndex:GetSlotServerData(slot)) then
        DisableAllDLC()
        if TheInput:IsKeyDown(KEY_SHIFT) then
            SaveGameIndex:DeleteSlot(
                slot,
                function() StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = slot }) end,
                true -- true causes world gen options to be preserved
            )
        elseif TheInput:IsKeyDown(KEY_CTRL) then
            SaveGameIndex:DeleteSlot(
                slot,
                function() StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = slot }) end,
                false -- false causes world gen options to be wiped!
            )
        else
            StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot =  slot })
        end
    end
end

function MainScreen:OnJoinButton()
    local start_worked = TheNet:StartClient(DEFAULT_JOIN_IP)
    if start_worked then
        DisableAllDLC()
    end
    ShowLoading()
end

function MainScreen:MakeDebugButtons()
	-- For Debugging/Testing
	if DEBUG_MODE then
        local host_button  = self.fixed_root:AddChild(ImageButton())
        host_button:SetScale(.8)
        host_button:SetPosition(lcol-100-20, 250)
        host_button:SetText(STRINGS.UI.MAINSCREEN.HOST)
        host_button:SetOnClick( function() self:OnHostButton() end )

        local join_button  = self.fixed_root:AddChild(ImageButton())
        join_button:SetScale(.8)
        join_button:SetPosition(lcol-100+140, 250)
        join_button:SetText(STRINGS.UI.MAINSCREEN.JOIN)
        join_button:SetOnClick( function() self:OnJoinButton() end )
	end
end

function MainScreen:OnBecomeActive()
    MainScreen._base.OnBecomeActive(self)

    self:Show()

    TheFrontEnd:SetOfflineMode(false)
    self.play_button:Enable()
    self.exit_button:Enable()
    self.play_button:SetFocus()
    self.leaving = nil
end

local function OnMovieDone()
    TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
    TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_idle_vines", "FEPortalSFX")
    TheFrontEnd:Fade(FADE_IN, 2)
end

function MainScreen:OnUpdate(dt)
    if TheSim:ShouldPlayIntroMovie() then
        TheFrontEnd:PushScreen(MovieDialog("movies/intro.ogv", OnMovieDone))
        self.music_playing = true
    elseif not self.music_playing then
        TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
        TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_idle_vines", "FEPortalSFX")
        self.music_playing = true
    end

    if self.bg.anim_root.portal:GetAnimState():AnimDone() and not self.leaving then
    	if math.random() < .33 then
			self.bg.anim_root.portal:GetAnimState():PlayAnimation("portal_idle_eyescratch", false)
    	else
    		self.bg.anim_root.portal:GetAnimState():PlayAnimation("portal_idle", false)
    	end
    end
end

function MainScreen:SetCurrentVersion(str)
	local status, version = pcall( function() return json.decode(str) end )
	local most_recent_cl = -2
	if status and version then
		if version.main and table.getn(version.main) > 0 then
			for idx,changelist in ipairs(version.main) do
				if tonumber(changelist) > most_recent_cl then
					most_recent_cl = tonumber(changelist)
				end
			end
			self.currentversion = most_recent_cl
		end
	end
	self:SetTargetGameVersion(most_recent_cl)
end

function MainScreen:SetTargetGameVersion(ver)
    self.targetversion = ver
end

function MainScreen:OnCurrentVersionQueryComplete( result, isSuccessful, resultCode )
 	if isSuccessful and string.len(result) > 1 and resultCode == 200 then
 		self:SetCurrentVersion(result, true)
 	else
		self:SetTargetGameVersion(-2)
	end
end

function MainScreen:UpdateCurrentVersion()
	TheSim:QueryServer( "https://s3.amazonaws.com/dstbuilds/builds.json", function(...) self:OnCurrentVersionQueryComplete(...) end, "GET" )
end

return MainScreen
