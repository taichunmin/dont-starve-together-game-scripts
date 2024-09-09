local FriendsManager = require "widgets/friendsmanager"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
require "os"

local PopupDialogScreen = require "screens/redux/popupdialog"
local EmailSignupScreen = require "screens/emailsignupscreen"
local MultiplayerMainScreen = require "screens/redux/multiplayermainscreen"
local NetworkLoginPopup = require "screens/redux/networkloginpopup"

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
	TheFrontEnd.MotdManager:Initialize()

	TheFrontEnd:GetGraphicsOptions():DisableStencil()
	TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()

	TheInputProxy:SetCursorVisible(true)

    --self.portal_root = self:AddChild(Widget("portal_root"))
    self.bg = self:AddChild(TEMPLATES.PlainBackground())
    --self.fg = self.portal_root:AddChild(TEMPLATES.AnimatedPortalForeground())

    self.fg = self:AddChild(TEMPLATES.ReduxForeground())


	-- FIXED ROOT
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

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


   	local updatename_x = RESOLUTION_X * .5 - 150
	local updatename_y = -RESOLUTION_Y * .5 + 55
	self.updatename = TEMPLATES.AddBuildString(self.fixed_root, {x = updatename_x, y = updatename_y, align = ANCHOR_RIGHT, w = 250, h = 45})

    self.play_button = self.fixed_root:AddChild(ImageButton("images/frontscreen.xml", "play_highlight.tex", nil, nil, nil, nil, {1,1}, {0,0}))--"highlight.tex", "highlight_hover.tex"))
    self.play_button.bg = self.play_button:AddChild(Image("images/frontscreen.xml", "play_highlight_hover.tex"))
    self.play_button.bg:SetScale(.69, .53)
    self.play_button.bg:MoveToBack()
    self.play_button.bg:Hide()
    if PLATFORM == "WIN32_RAIL" then
		self.play_button.image:SetPosition(0,0)
		self.play_button.bg:SetPosition(0,0)
	else
		self.play_button.image:SetPosition(0,3)
		self.play_button.bg:SetPosition(0,3)
	end
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
        if IsIntegrityChecking then
            return
        end
        playgainfocusfn(self.play_button)
		if PLATFORM == "WIN32_RAIL" then
			self.play_button:SetTextSize(48)
		else
			self.play_button:SetTextSize(58)
		end
        self.play_button.image:SetTint(1,1,1,1)
        self.play_button.bg:Show()
    end
    self.play_button.OnLoseFocus = function()
        if IsIntegrityChecking then
            return
        end
        playlosefocusfn(self.play_button)
        if PLATFORM == "WIN32_RAIL" then
			self.play_button:SetTextSize(45)
		else
			self.play_button:SetTextSize(55)
		end
        self.play_button.image:SetTint(1,1,1,.6)
        self.play_button.bg:Hide()
    end
    self.play_button:SetOnClick(function()
        if not IsIntegrityChecking then
            self.play_button:Disable()
            self:OnLoginButton(true)
        end
    end)
    self.play_button._TurnOff = function()
        self.play_button:Disable()
        self.play_button.image:SetTint(0.5,0.5,0.5,0.6)
        self.play_button:SetText(STRINGS.UI.NOTIFICATION.LOADING, true, {2,-3})
    end
    self.play_button._TurnOn = function()
        self.play_button:Enable()
        self.play_button.image:SetTint(1,1,1,0.6)
        self.play_button:SetText(STRINGS.UI.MAINSCREEN.PLAY, true, {2,-3})
    end
    HookLoginButtonForDataBundleFileHashes(self.play_button)

    self.exit_button = self.fixed_root:AddChild(TEMPLATES.BackButton(
        function()
            self:Quit()
        end,
        STRINGS.UI.MAINSCREEN.QUIT
        ))

    if TheInput:ControllerAttached() then
        local x,y = self.legalese_image:GetPosition():Get()
        self.legalese_image:SetPosition(x, y + 20)
        x,y = self.exit_button:GetPosition():Get()
        self.exit_button:SetPosition(x, y + 20)
    end

    self.onlinestatus = self.fixed_root:AddChild(OnlineStatus())

	self.filter_settings = nil

	--focus moving
    self.play_button:SetFocusChangeDir(MOVE_DOWN, self.exit_button)
    self.exit_button:SetFocusChangeDir(MOVE_UP, self.play_button)

	self:MakeDebugButtons()
    self.play_button:SetFocus()
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
        CacheCurrentVanityItems(self.profile)

		if push_mp_main_screen then
            local function session_mapping_cb(data)
				TheFrontEnd:FadeToScreen( self, function() return MultiplayerMainScreen(self, self.profile, offline, data) end, function(new_screen) new_screen:FinishedFadeIn() end, "swipe" )
            end
            if not TheNet:DeserializeAllLocalUserSessions(session_mapping_cb) then
                session_mapping_cb()
            end
        else
	        TheFrontEnd:Fade(FADE_OUT, PLAY_BUTTON_FADE_TIME, function()
                    TheFrontEnd:Fade(FADE_IN, PLAY_BUTTON_FADE_TIME, nil, nil, nil, "alpha")
			end, nil, nil, "alpha")
		end
    end

    local function onCancel()
        self.play_button:Enable()
        self.exit_button:Enable()
    end

    local function onLogin(forceOffline)
	    local account_manager = TheFrontEnd:GetAccountManager()
        local is_banned, banned_reason = account_manager:IsBanned()
	    local must_upgrade = account_manager:MustUpgradeClient()
	    local communication_succeeded = account_manager:CommunicationSucceeded()
	    local inventory_succeeded = TheInventory:HasDownloadedInventory()
		local has_auth_token = account_manager:HasAuthToken()

        if is_banned then -- We are banned
        	TheFrontEnd:PopScreen()
	        TheNet:NotifyAuthenticationFailure()
            OnNetworkDisconnect( banned_reason, true, nil, nil, function() TheFrontEnd:PopScreen() GoToMultiplayerMainMenu(true) end)
        -- We are on a deprecated version of the game
        elseif must_upgrade then
        	TheFrontEnd:PopScreen()
        	TheNet:NotifyAuthenticationFailure()
        	OnNetworkDisconnect( "E_UPGRADE", true)
        elseif ( has_auth_token and communication_succeeded ) or forceOffline then
            if hadPendingConnection then
                TheFrontEnd:PopScreen()
            else
                TheFrontEnd:PopScreen()
                GoToMultiplayerMainMenu(forceOffline or false )
            end
        elseif not communication_succeeded then  -- We could not communicate with our auth server or steam is down
            print ( "failed_communication" )
            TheFrontEnd:PopScreen()
            local confirm = PopupDialogScreen( STRINGS.UI.MAINSCREEN.OFFLINEMODE,STRINGS.UI.MAINSCREEN.OFFLINEMODEDESC,
								{
								  	{text=STRINGS.UI.MAINSCREEN.PLAYOFFLINE, cb = function()
								  		TheFrontEnd:PopScreen()
								  		GoToMultiplayerMainMenu(true)
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

	if TheSim:GetDataCollectionSetting() == false then
		if RUN_GLOBAL_INIT then
			local notice = PopupDialogScreen( STRINGS.UI.DATACOLLECTION_LOGIN.TITLE, STRINGS.UI.DATACOLLECTION_LOGIN.BODY,
							{
							 {text=STRINGS.UI.DATACOLLECTION_LOGIN.CONTINUE, cb = function() TheFrontEnd:PopScreen() GoToMultiplayerMainMenu(true) end },
							},
							nil, "big", "dark_wide")
			TheFrontEnd:PushScreen(notice)
		else
			TheFrontEnd:PopScreen()
			GoToMultiplayerMainMenu(true)
		end
	elseif TheSim:IsLoggedOn() or account_manager:HasAuthToken() then
		if TheSim:GetUserHasLicenseForApp(DONT_STARVE_TOGETHER_APPID) then
			account_manager:Login( "Client Login" )
            TheFrontEnd:PushScreen(NetworkLoginPopup(onLogin, onCancel, hadPendingConnection))
		else
			TheNet:NotifyAuthenticationFailure()
			OnNetworkDisconnect( "APP_OWNERSHIP_CHECK_FAILED", false, false )
		end
	else
		-- Set lan mode
        TheNet:NotifyAuthenticationFailure()
        local title = STRINGS.UI.MAINSCREEN.STEAMOFFLINEMODE
        local desc = STRINGS.UI.MAINSCREEN.STEAMOFFLINEMODEDESC
        if IsRail() then
            title = STRINGS.UI.MAINSCREEN.WEGAMEOFFLINEMODE
            desc = STRINGS.UI.MAINSCREEN.WEGAMEFFLINEMODEDESC
        end
		local confirm = PopupDialogScreen( title, desc,
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

function MainScreen:Quit()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.ASKQUIT, STRINGS.UI.MAINSCREEN.ASKQUITDESC, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() RequestShutdown() end },{text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  }))
end

function MainScreen:OnHostButton()
    CacheCurrentVanityItems(self.profile)
    ShardSaveGameIndex:LoadSlotEnabledServerMods()
    KnownModIndex:Save()
    local start_in_online_mode = false
    local slot = 1
    if TheNet:StartServer(start_in_online_mode, slot, ShardSaveGameIndex:GetSlotServerData(slot)) then
        DisableAllDLC()
        local shift_down = TheInput:IsKeyDown(KEY_SHIFT)
        if shift_down or TheInput:IsKeyDown(KEY_CTRL) then
            ShardSaveGameIndex:DeleteSlot(
                slot,
                function() if TheSim:EnsureShardIndexPathExists(slot) then StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot = slot }) end end,
                shift_down -- true causes world gen options to be preserved, false causes world gen options to be wiped!
            )
        else
            StartNextInstance({ reset_action = RESET_ACTION.LOAD_SLOT, save_slot =  slot })
        end
    end
end

function MainScreen:OnJoinButton()
    CacheCurrentVanityItems(self.profile)
    local start_worked = TheNet:StartClient(DEFAULT_JOIN_IP)
    if start_worked then
        DisableAllDLC()
    end
    ShowLoading()
end

function MainScreen:OnJoinPlayTestButton()
    CacheCurrentVanityItems(self.profile)
    local play_test_ip = TheSim:GetLocalSetting('misc', 'play_test_ip')
    local start_worked = TheNet:StartClient(play_test_ip)
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

        local play_test_ip = TheSim:GetLocalSetting('misc', 'play_test_ip')
        if play_test_ip ~= nil then
            local join_play_test_button = self.fixed_root:AddChild(ImageButton())
            join_play_test_button:SetScale(.8)
            join_play_test_button:SetPosition(lcol-100+300, 250)
            join_play_test_button:SetText(STRINGS.UI.MAINSCREEN.JOIN_PLAY_TEST)
            join_play_test_button:SetOnClick( function() self:OnJoinPlayTestButton() end )
        end
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

    local friendsmanager = self:AddChild(FriendsManager())
    friendsmanager:SetHAnchor(ANCHOR_RIGHT)
    friendsmanager:SetVAnchor(ANCHOR_BOTTOM)
    friendsmanager:SetScaleMode(SCALEMODE_PROPORTIONAL)

    if not self.auto_login_started then
        if Profile:GetAutoLoginEnabled() then
            local function TryAutoLogin()
                if TheFrontEnd:GetActiveScreen() == self and self.play_button:IsEnabled() and not global_error_widget and not IsIntegrityChecking then
                    if self.inst._AutoLoginTask ~= nil then -- Just in case.
                        self.inst._AutoLoginTask:Cancel()
                        self.inst._AutoLoginTask = nil
                    end
                    self.auto_login_started = true
                    print("Do AutoLogin")
                    self.play_button:Disable()
                    self:OnLoginButton(true)
                end
            end
            if self.inst._AutoLoginTask ~= nil then
                -- NOTES(JBK): This is to stop a duplicate entry for OnBecomeActive when other popups arrive.
                self.inst._AutoLoginTask:Cancel()
                self.inst._AutoLoginTask = nil
            end
            self.inst._AutoLoginTask = self.inst:DoPeriodicTask(0, TryAutoLogin)
        end
    end
end

function MainScreen:OnUpdate(dt)
    if not self.music_playing then
        TheFrontEnd:GetSound():PlaySound(FE_MUSIC, "FEMusic")
        TheFrontEnd:GetSound():SetParameter("FEMusic", "fade", 1)
        --TheFrontEnd:GetSound():PlaySound("dontstarve/together_FE/portal_idle_vines", "FEPortalSFX")
        self.music_playing = true
    end

    --[[if self.bg.anim_root.portal:GetAnimState():AnimDone() and not self.leaving then
    	if math.random() < .33 then
			self.bg.anim_root.portal:GetAnimState():PlayAnimation("portal_idle_eyescratch", false)
    	else
    		self.bg.anim_root.portal:GetAnimState():PlayAnimation("portal_idle", false)
    	end
    end]]
end

return MainScreen
