local AchievementsPopup = require "screens/redux/achievementspopup"
local CollectionScreen = require "screens/redux/collectionscreen"
local SkinDebugScreen = require "screens/redux/skindebugscreen"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local MorgueScreen = require "screens/redux/morguescreen"
local MysteryBoxScreen = require "screens/redux/mysteryboxscreen"
local OnlineStatus = require "widgets/onlinestatus"
local PlayerAvatarPortrait = require "widgets/redux/playeravatarportrait"
local PurchasePackScreen = require "screens/redux/purchasepackscreen"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"
local TradeScreen = require "screens/tradescreen"
local Widget = require "widgets/widget"
local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"
local PopupDialogScreen = require "screens/redux/popupdialog"
local RedeemDialog = require "screens/redeemdialog"

require("characterutil")
require("skinsutils")


local PlayerSummaryScreen = Class(Screen, function(self, prev_screen, user_profile)
	Screen._ctor(self, "PlayerSummaryScreen")
    self.prev_screen = prev_screen
    self.user_profile = user_profile
	self.can_shop = IsNotConsole()

    TheSim:PauseFileExistsAsync(true)

	self:DoInit()

    self:_DoFocusHookups()
	self.default_focus = self.menu
end)

function PlayerSummaryScreen:DoInit()
    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.BrightMenuBackground())	
    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.PLAYERSUMMARYSCREEN.TITLE, ""))

    self.onlinestatus = self.root:AddChild(OnlineStatus(true))

    self.experience_root = self.root:AddChild(Widget("experience_root"))
    self.experience_root:SetPosition(-40,150)

    self.puppet = self.experience_root:AddChild(PlayerAvatarPortrait())
    self.puppet:HideHoverText()
    self.puppet:SetPosition(-220, 40)
    if IsAnyFestivalEventActive() then
        -- Profileflair and rank are displayed on experiencebar when its visible.
        self.puppet:AlwaysHideRankBadge()
    end

    self.username = self.experience_root:AddChild(Text(CHATFONT, 30, TheNet:GetLocalUserName()))
    self.username:SetHAlign(ANCHOR_LEFT)
    self.username:SetRegionSize(600, 50)
    self.username:SetPosition(180,80)

    local width = 300

    if IsAnyFestivalEventActive() then
        self.experiencebar = self.experience_root:AddChild(TEMPLATES.WxpBar())
        self.experiencebar:SetPosition(240,40)
    else
        self.festivals_root = self.root:AddChild(Widget("festivals_root"))
        self.festivals_root:SetPosition(325,210)
        self.festivals_label = self.festivals_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.FESTIVAL_HISTORY, UICOLOURS.GOLD_SELECTED))
        self.festivals_label:SetPosition(60,70)
        self.festivals_label:SetRegionSize(width,30)
        self.festivals_divider_top = self.festivals_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
        self.festivals_divider_top:SetScale(0.5)
        self.festivals_divider_top:SetPosition(60,55)
        
        self.festivals_badges = {}
		for i, eventinfo in ipairs(PREVIOUS_FESTIVAL_EVENTS_ORDER) do
            table.insert(self.festivals_badges, self.festivals_root:AddChild(self:_BuildFestivalHistory(eventinfo.id, eventinfo.season)))
            self.festivals_badges[#self.festivals_badges]:SetPosition(60, 55 - i*40)
		end
    end

    self.doodad_root = self.root:AddChild(Widget("doodad_root"))
    self.doodad_root:SetPosition(325,-10)
    self.doodad_label = self.doodad_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.CURRENCY_LABEL, UICOLOURS.GOLD_SELECTED))
    self.doodad_label:SetPosition(60,70)
    self.doodad_label:SetRegionSize(width,30)
    self.doodad_divider_top = self.doodad_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
    self.doodad_divider_top:SetScale(0.5)
    self.doodad_divider_top:SetPosition(60,55)
    self.doodad_count = self.doodad_root:AddChild(TEMPLATES.DoodadCounter(TheInventory:GetCurrencyAmount()))
	self.doodad_count:SetScale(0.5)
    self.doodad_count:SetPosition(-60,-10)
    self.doodad_explainer = self.doodad_root:AddChild(Text(CHATFONT, 21, STRINGS.UI.PLAYERSUMMARYSCREEN.CURRENCY_EXPLAIN))
    self.doodad_explainer:EnableWordWrap(true)
    self.doodad_explainer:SetRegionSize(220, 90)
    self.doodad_explainer:SetPosition(100, -18)
	self.doodad_explainer:SetVAlign(ANCHOR_TOP)
	self.doodad_explainer:SetHAlign(ANCHOR_LEFT)


    self.new_items = self.root:AddChild(self:_BuildItemsSummary(width))
    self.new_items:SetPosition(-50, -10)

    self.death_root = self.root:AddChild(Widget("death_root"))
    self.death_root:SetPosition(-50, -230)
    self.death_label = self.death_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.MOST_COMMON_DEATH, UICOLOURS.GOLD_SELECTED))
    self.death_label:SetPosition(60,70)
    self.death_label:SetRegionSize(width,30)
    self.death_divider_top = self.death_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
    self.death_divider_top:SetScale(0.5)
    self.death_divider_top:SetPosition(60,55)
    self.most_died = self.death_root:AddChild(self:_BuildMostCommonDeath(width))
	self.most_died:SetPosition(-10,-10)


    self.friend_root = self.root:AddChild(Widget("friend_root"))
    self.friend_root:SetPosition(325,-230)
    self.friend_label = self.friend_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.MOST_COMMON_FRIEND, UICOLOURS.GOLD_SELECTED))
    self.friend_label:SetPosition(60,70)
    self.friend_label:SetRegionSize(width,30)
    self.friend_divider_top = self.friend_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
    self.friend_divider_top:SetScale(0.5)
    self.friend_divider_top:SetPosition(60,55)
    self.most_friend = self.friend_root:AddChild(self:_BuildMostCommonFriend(width + 20))

    self.musicstopped = true

    self.menu = self:_BuildMenu()
    self.menu.reverse = true

    if not TheInput:ControllerAttached() then
        self.back_button = self.root:AddChild(TEMPLATES.BackButton(
                function()
                    self:Close()
                end
            ))
    end
    
    if IsConsole() then
        self.task = self.inst:DoPeriodicTask(1, function() 
            if TheFrontEnd:GetActiveScreen() == self then
                TheInventory:RefreshDLCSkinOwnership() --this refreshes both player's inventories if a second is logged in.
                MakeSkinDLCPopup() --refresh any pending skin DLC (will only happen for player1, which is good, no need to double up the UI presentation)
            end
        end)
    end
end

function PlayerSummaryScreen:_DoFocusHookups()
    if self.festivals_badges ~= nil then
        self.menu:SetFocusChangeDir(MOVE_RIGHT, self.festivals_badges[1])
        for i,_ in pairs(self.festivals_badges) do
            self.festivals_badges[i]:SetFocusChangeDir(MOVE_UP, self.festivals_badges[i-1])
            self.festivals_badges[i]:SetFocusChangeDir(MOVE_LEFT, self.menu)
            self.festivals_badges[i]:SetFocusChangeDir(MOVE_DOWN, self.festivals_badges[i+1])
        end
    end
end


local function PushWaitingPopup()
    local event_wait_popup = GenericWaitingPopup("ItemServerContactPopup", STRINGS.UI.ITEM_SERVER.CONNECT, nil, false)
    TheFrontEnd:PushScreen(event_wait_popup)
    return event_wait_popup
end

function PlayerSummaryScreen:_BuildFestivalHistory(festival_key, season)
    local function onclick()
        local event_wait_popup = PushWaitingPopup()
        wxputils.GetEventStatus(festival_key, season, function(success)
            self.inst:DoTaskInTime(0, function() --we need to delay a frame so that the popping of the screens happens at the right time in the frame.
                event_wait_popup:Close()

                if success then
                    local screen = AchievementsPopup(self.prev_screen, festival_key, season)
                    TheFrontEnd:PushScreen(screen)
                else
                    local ok_scr = PopupDialogScreen( STRINGS.UI.PLAYERSUMMARYSCREEN.FESTIVAL_HISTORY, STRINGS.UI.ITEM_SERVER.FAILED_DEFAULT,
					{
						{text=STRINGS.UI.PURCHASEPACKSCREEN.OK, cb = function() 
							TheFrontEnd:PopScreen()
						end }, 
					})
                    TheFrontEnd:PushScreen(ok_scr)
                end
            end, self)
        end)
    end

    local festival_title = STRINGS.UI.FESTIVALEVENTSCREEN.TITLE[string.upper(festival_key) .. (season > 1 and tostring(season) or "")]
	local w = TEMPLATES.StandardButton(onclick, festival_title, {225,40})

    return w
end

function PlayerSummaryScreen:_BuildItemsSummary(width)
    local new_root = Widget("new items root")
    new_root.new_label = new_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.NEW_STUFF, UICOLOURS.GOLD_SELECTED))
    new_root.new_label:SetPosition(60,70)
    new_root.new_label:SetRegionSize(width,30)

	new_root.divider_top = new_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
	new_root.divider_top:SetScale(0.5)
    new_root.divider_top:SetPosition(60,55)
	
    new_root.items = new_root:AddChild(TEMPLATES.ItemImageText())
    new_root.items:SetPosition(-50,0)
    new_root.items:Hide()

    new_root.no_items = new_root:AddChild(Text(CHATFONT, 30, STRINGS.UI.PLAYERSUMMARYSCREEN.NO_ITEMS))
    new_root.no_items:SetPosition(60,0)
    new_root.no_items:SetRegionSize(width,30)
    new_root.no_items:Hide()

    -- This msg will be stomped by UpdateItems!
    new_root.unopened_msg = new_root:AddChild(Text(CHATFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.LOADING_STUFF, UICOLOURS.WHITE))
    new_root.unopened_msg:SetPosition(60,-55)
    new_root.unopened_msg:SetRegionSize(width,30)


	
    new_root.UpdateItems = function()
        local inventory = GetInventorySkinsList()

        table.sort(inventory, 
            function(a, b) 
                return a.timestamp > b.timestamp
            end)

        local newest = nil
        for i,item_data in ipairs(inventory) do
            if item_data.type ~= "mysterybox" then
                newest = item_data
                break
            end
        end

        new_root.items:Hide()
        new_root.no_items:Hide()
        if newest then
            new_root.items:SetItem(newest.type, newest.item, newest.item_id, newest.timestamp)
            new_root.items:Show()
        else
            new_root.no_items:Show()
        end

        local box_count = 0
        for key,count in pairs(GetMysteryBoxCounts()) do
            box_count = box_count + count
        end
        local msg = subfmt(STRINGS.UI.PLAYERSUMMARYSCREEN.UNOPENED_BOXES_FMT, {num_boxes = box_count})
        new_root.unopened_msg:SetString(msg)
    end

    return new_root
end

function PlayerSummaryScreen:_BuildMostCommonDeath(width)
    local total_deaths = 0
    local cause_of_death = {}
    local morgue = Morgue:GetRows()
    for i,data in ipairs(morgue) do
        if data and data.character and data.days_survived and data.location and data.killed_by and (data.world or data.server) then
            local killed_by = GetKilledByFromMorgueRow(data)
            local prev_deaths = cause_of_death[killed_by] or 0
            cause_of_death[killed_by] = prev_deaths + 1
            total_deaths = total_deaths + 1
        end
    end

    local causes = table.getkeys(cause_of_death)
    table.sort(causes, function(a,b)
        local a_deaths = cause_of_death[a] or 0
        local b_deaths = cause_of_death[b] or 0
        return a_deaths > b_deaths
    end)

    local deaths = Widget("deaths")
    local top_cause = causes[1] or STRINGS.UI.PLAYERSUMMARYSCREEN.NO_DEATHS
    if top_cause then
        deaths.name = deaths:AddChild(Text(UIFONT, 30, top_cause))
        deaths.name:SetRegionSize(width,30)
        deaths.name:SetPosition(70,10)

        --~ local percent = string.format("%0.1f%%", cause_of_death[top_cause] / total_deaths * 100)
        --~ deaths.percent = deaths:AddChild(Text(CHATFONT, 30, percent))
        --~ deaths.percent:SetRegionSize(width,30)
        --~ deaths.percent:SetPosition(70,-20)
    end

    return deaths
end

function PlayerSummaryScreen:_BuildMostCommonFriend(width)
    local friends = Widget("friends")
    friends.name = friends:AddChild(Text(UIFONT, 30))
    friends.name:SetRegionSize(width,30)
    friends.name:SetPosition(60, 10)

    friends.count = friends:AddChild(Text(CHATFONT, 25))
    friends.count:SetRegionSize(width,30)
    friends.count:SetPosition(60, -20)

    return friends
end

function PlayerSummaryScreen:_RefreshMostCommonFriend()
	local top_friend = nil
	for k, v in pairs(PlayerHistory.seen_players) do
		if top_friend == nil or (v.time_played_with or 0) > (top_friend.time_played_with or 0) then
			top_friend = v
		end
	end

    if top_friend ~= nil then
        self.most_friend.name:SetString(top_friend.name or "")
		self.most_friend.name:SetPosition(60, 10)
        self.most_friend.count:SetString(subfmt(STRINGS.UI.PLAYERSUMMARYSCREEN.ENCOUNTER_COUNT_FMT, {time = str_play_time(top_friend.time_played_with)}))
    else
        self.most_friend.name:SetString(STRINGS.UI.PLAYERSUMMARYSCREEN.NO_FRIENDS)
		self.most_friend.name:SetPosition(60, 0)
        self.most_friend.count:SetString("")
    end
end

function PlayerSummaryScreen:_RefreshPuppet()
    local herocharacter = self.user_profile:GetLastSelectedCharacter()
    local clothing = self.user_profile:GetSkinsForCharacter(herocharacter)
    local playerportrait = GetMostRecentlySelectedItem(self.user_profile, "playerportrait")
    -- Profileflair and rank are displayed on experiencebar when its visible.
    local profileflair = nil
    if not IsAnyFestivalEventActive() then
        profileflair = GetMostRecentlySelectedItem(self.user_profile, "profileflair")
    end
    self.puppet:UpdatePlayerListing(nil, nil, herocharacter, clothing.base, clothing, playerportrait, profileflair)
end

function PlayerSummaryScreen:_BuildMenu()
		
	-- choose whether to use standard or wide menu buttons based on the length of the longest string
	local menu_button_character_limit = 22
	local menu_button_style = nil
    local skinsStr = STRINGS.UI.MAINSCREEN.SKINS
    if IsAnyItemNew(self.user_profile) then
        skinsStr = string.format("%s (%s)", skinsStr, STRINGS.UI.COLLECTIONSCREEN.NEW)
    end
    local numboxes = GetTotalMysteryBoxCount()
    local mysteryboxStr = ""
    if numboxes > 0 then
        mysteryboxStr = string.format("%s (%d)", STRINGS.UI.MAINSCREEN.MYSTERYBOX, numboxes)
    else
        mysteryboxStr = STRINGS.UI.MAINSCREEN.MYSTERYBOX
    end
	local shopStr = STRINGS.UI.PLAYERSUMMARYSCREEN.PURCHASE
	if IsShopNew(self.user_profile) then
		shopStr = string.format("%s (%s)", shopStr, STRINGS.UI.COLLECTIONSCREEN.NEW)
	end 
	local menu_strings = { skinsStr, 
						   mysteryboxStr, 
						   STRINGS.UI.MORGUESCREEN.HISTORY, 
						   STRINGS.UI.PLAYERSUMMARYSCREEN.TRADING, 
						   shopStr,
						   STRINGS.UI.REDEEMDIALOG.MENU_BUTTON_TITLE,
						 }
	for i, item in pairs(menu_strings) do
		if item:utf8len() > menu_button_character_limit then
			menu_button_style = "wide"
			break
		end
	end

    self.tooltip = self.root:AddChild(TEMPLATES.ScreenTooltip(menu_button_style))

    local skins_button      = TEMPLATES.MenuButton(STRINGS.UI.MAINSCREEN.SKINS, function() self:OnSkinsButton() end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_SKINS, self.tooltip, menu_button_style)
    local mysterybox_button = TEMPLATES.MenuButton(STRINGS.UI.MAINSCREEN.MYSTERYBOX, function() self:OnMysteryBoxButton() end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_MYSTERYBOX, self.tooltip, menu_button_style)
    local history_button    = TEMPLATES.MenuButton(STRINGS.UI.MORGUESCREEN.HISTORY, function() self:OnHistoryButton() end,    STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_HISTORY,  self.tooltip, menu_button_style)
    local trading_button    = TEMPLATES.MenuButton(STRINGS.UI.PLAYERSUMMARYSCREEN.TRADING, function() self:_FadeToScreen(TradeScreen, {}) end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_TRADE, self.tooltip, menu_button_style)
    local redeem_button     = nil

    local menu_items = {
        {widget = trading_button},
        {widget = history_button},
        {widget = mysterybox_button},
        {widget = skins_button},
    }
	
    -- These won't be available when you first attempt to load this screen
    -- because they require the inventory to function correctly.
    self.waiting_for_inventory = {
        trading_button,
        history_button, -- There's no online data in history, but it looks weird as the lone available item.
        mysterybox_button,
        skins_button,
    }

	local redeem_button = TEMPLATES.MenuButton(STRINGS.UI.REDEEMDIALOG.MENU_BUTTON_TITLE, function() self:_FadeToScreen(RedeemDialog, {}) end, STRINGS.UI.REDEEMDIALOG.MENU_BUTTON_DESC, self.tooltip, menu_button_style)
    table.insert(menu_items, 1, {widget = redeem_button})
    table.insert(self.waiting_for_inventory, 1, redeem_button)

    if SKIN_DEBUGGING then
        local skinsdebug_button = TEMPLATES.MenuButton("SKIN DEBUG", function() self:_FadeToScreen(SkinDebugScreen, {}) end, "SKIN DEBUG", self.tooltip, menu_button_style)
        table.insert(menu_items, 1, {widget = skinsdebug_button})
    end

	if self.can_shop then
		local purchase_button   = TEMPLATES.MenuButton(STRINGS.UI.PLAYERSUMMARYSCREEN.PURCHASE, function() self:_FadeToScreen(PurchasePackScreen, {}) end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_PURCHASE, self.tooltip, menu_button_style)	
        table.insert(menu_items, 1, {widget = purchase_button})
        table.insert(self.waiting_for_inventory, 1, purchase_button)
    else
        local purchase_button   = TEMPLATES.MenuButton(STRINGS.UI.PLAYERSUMMARYSCREEN.PURCHASE, function() TheSystemService:GotoSkinDLCStorePage()  end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_PURCHASE, self.tooltip, menu_button_style)	
        table.insert(menu_items, 1, {widget = purchase_button})
        table.insert(self.waiting_for_inventory, 1, purchase_button)
    end
	
    for i,w in ipairs(self.waiting_for_inventory) do
        w:Disable()
    end

    return self.root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))
end

function PlayerSummaryScreen:OnBecomeActive()
    PlayerSummaryScreen._base.OnBecomeActive(self)

	if self.last_focus_widget then
		self.menu:RestoreFocusTo(self.last_focus_widget)
	end
    self.leaving = nil

    self:_RefreshMostCommonFriend()
    self:_RefreshClientData()
    self:StartMusic()

    DisplayInventoryFailedPopup( self )
end

function PlayerSummaryScreen:_RefreshTitles()
    local numboxes = GetTotalMysteryBoxCount()
    local mysteryboxStr = ""
    if numboxes > 0 then
        mysteryboxStr = string.format("%s (%d)", STRINGS.UI.MAINSCREEN.MYSTERYBOX, numboxes)
    else
        mysteryboxStr = STRINGS.UI.MAINSCREEN.MYSTERYBOX
    end

    local skinsStr = STRINGS.UI.MAINSCREEN.SKINS
    if IsAnyItemNew(self.user_profile) then
        skinsStr = string.format("%s (%s)", skinsStr, STRINGS.UI.COLLECTIONSCREEN.NEW)
    end

	local max_menu_text_length = 28
	local default_menu_text_size = 25
	local text_font_size = 0
	if skinsStr:utf8len() > max_menu_text_length then
		text_font_size = 20
	else
		text_font_size = default_menu_text_size
	end
	self.menu:EditItem(#self.menu.items, skinsStr, text_font_size)				-- skins are the last item in the menu
		
	local text_font_size = 25
	if mysteryboxStr:utf8len() > max_menu_text_length then
		text_font_size = 20
	else
		text_font_size = default_menu_text_size
	end
	self.menu:EditItem(#self.menu.items - 1, mysteryboxStr, text_font_size)		-- mystery box is the second last item in the menu
    
	if self.can_shop then
		local shopStr = STRINGS.UI.PLAYERSUMMARYSCREEN.PURCHASE
		if IsShopNew(self.user_profile) then
			shopStr = string.format("%s (%s)", shopStr, STRINGS.UI.COLLECTIONSCREEN.NEW)
		end    
		
		if shopStr:utf8len() > max_menu_text_length then
			text_font_size = 20
		else
			text_font_size = default_menu_text_size
		end
		self.menu:EditItem(1, shopStr, text_font_size)
	end
	
end

function PlayerSummaryScreen:_RefreshClientData()
    -- Always update the puppet so it doesn't have the rank unless appropriate.
    self:_RefreshPuppet()
    
    for i,w in ipairs(self.waiting_for_inventory) do
        w:Enable()
    end
    -- Force focus to change to widgets are correctly redrawn.
    self.menu:SetFocus(2)
    self.menu:SetFocus()

    self.doodad_count:SetCount(TheInventory:GetCurrencyAmount())
    if self.experiencebar then
        local profileflair = GetMostRecentlySelectedItem(self.user_profile, "profileflair")
        self.experiencebar:UpdateExperienceForLocalUser(profileflair)
    end
    self.new_items:UpdateItems()
    self:_RefreshTitles()
end


function PlayerSummaryScreen:OnControl(control, down)
    if PlayerSummaryScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        self:Close()
        return true
    end
end

function PlayerSummaryScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SERVERLISTINGSCREEN.BACK)

    return table.concat(t, "  ")
end

function PlayerSummaryScreen:_FadeToScreen(screen_ctor, data)
    self.last_focus_widget = TheFrontEnd:GetFocusWidget()
    self.menu:Disable()
    self.leaving = true
    
    TheFrontEnd:FadeToScreen( self, function() return screen_ctor(self, self.user_profile, unpack(data)) end, nil )
end

function PlayerSummaryScreen:OnSkinsButton()
    self:_FadeToScreen(CollectionScreen, {})
end

function PlayerSummaryScreen:OnMysteryBoxButton()
    self:_FadeToScreen(MysteryBoxScreen, {})
end

function PlayerSummaryScreen:OnHistoryButton()
    self:_FadeToScreen(MorgueScreen, {})
end

function PlayerSummaryScreen:StopMusic()
    if not self.musicstopped then
        self.musicstopped = true
        TheFrontEnd:GetSound():KillSound("FEMusic")
        --TheFrontEnd:GetSound():KillSound("FEPortalSFX")
    elseif self.musictask ~= nil then
        self.musictask:Cancel()
        self.musictask = nil
    end
end

function PlayerSummaryScreen:Close()
    self:StopMusic()
    TheFrontEnd:FadeBack()
end

local function OnStartMusic(inst, self)
    self.musictask = nil
    self.musicstopped = false
    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/Together_HUD/collectionscreen/music/jukebox", "FEMusic")
end

function PlayerSummaryScreen:StartMusic()
    if self.musicstopped and self.musictask == nil then
        self.musictask = self.inst:DoTaskInTime(1.25, OnStartMusic, self)
    end
end

return PlayerSummaryScreen
