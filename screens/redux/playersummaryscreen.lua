local AchievementsPopup = require "screens/redux/achievementspopup"
local CollectionScreen = require "screens/redux/collectionscreen"
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

require("characterutil")
require("skinsutils")


local PlayerSummaryScreen = Class(Screen, function(self, prev_screen, user_profile)
	Screen._ctor(self, "PlayerSummaryScreen")
    self.prev_screen = prev_screen
    self.user_profile = user_profile

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
        if TheInventory:GetWXP() > 0 then
            self.festivals_badge = self.festivals_root:AddChild(self:_BuildFestivalHistory(PREVIOUS_FESTIVAL_EVENT))
            self.festivals_badge:SetPosition(-60,-10)
        else
            self.festivals_untouched = self.festivals_root:AddChild(Text(UIFONT, 30, STRINGS.UI.PLAYERSUMMARYSCREEN.NO_HISTORY))
            self.festivals_untouched:SetRegionSize(width,60)
            self.festivals_untouched:EnableWordWrap(true)
            self.festivals_untouched:SetPosition(60,0)
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
    self.most_friend = self.friend_root:AddChild(self:_BuildMostCommonFriend(width))

    self.musicstopped = true

    self.menu = self:_BuildMenu()
    self.menu.reverse = true

    if not TheInput:ControllerAttached() then
        self.back_button = self.root:AddChild(TEMPLATES.BackButton(
                function()
                    self:_Close()
                end
            ))
    end
end

function PlayerSummaryScreen:_DoFocusHookups()
    if self.festivals_badge then
        self.menu:SetFocusChangeDir(MOVE_RIGHT, self.festivals_badge)
        self.festivals_badge:SetFocusChangeDir(MOVE_LEFT, self.menu)
    end
end

function PlayerSummaryScreen:_BuildFestivalHistory(festival_key)
    local function onclick()
        local screen = AchievementsPopup(self.prev_screen, self.user_profile, festival_key)
        TheFrontEnd:PushScreen(screen)
    end
    -- Using ImageButton to get scaling on focus on image children.
    local w = ImageButton("images/ui.xml", "blank.tex")
    w:SetFont(UIFONT)
    w:SetTextSize(30)
    w:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
    w:SetTextFocusColour(UICOLOURS.GOLD_SELECTED)
    w:SetOnClick(onclick)

    w.badge = w.image:AddChild(TEMPLATES.FestivalNumberBadge(festival_key))
    -- TODO(event2): Retrieve level for past event by name instead of relying on the old data.
    local festival_rank = TheInventory:GetWXPLevel()
    w.badge:SetRank(festival_rank)
    w.badge.num:SetSize(30)


    local festival_title = STRINGS.UI.FESTIVALEVENTSCREEN.TITLE[string.upper(festival_key)]
    w:SetText(festival_title)

    local textwidth = 300
    local text_offset = 50
    local text_x = text_offset + .5*textwidth
    local text_y = 15
    local text_height = 40
    w.text:SetRegionSize(textwidth, text_height)
    w.text:SetPosition(text_x, text_y)
    w.text:SetHAlign(ANCHOR_LEFT)
    w.text:SetVAlign(ANCHOR_TOP)

    -- Make text clickable too
    w.bg = w.image:AddChild(Image("images/ui.xml", "blank.tex"))
    w.bg:ScaleToSize(textwidth + 20, text_height)
    w.bg:SetPosition(text_x - 20, text_y + 10)

    -- Button to make interaction obvious.
    w.btn = w.text:AddChild(TEMPLATES.StandardButton(onclick, STRINGS.UI.ACHIEVEMENTS.SCREENTITLE, {160,40}))
    w.btn:SetPosition(-80, -25)

    -- Ensure button is highlighted if text/badge are hovered.
    w.focus_forward = w.btn

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
        local inventory = GetSortedSkinsList()

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
    local top_cause = causes[1]
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
    friends.name:SetPosition(70, 10)

    friends.count = friends:AddChild(Text(CHATFONT, 30))
    friends.count:SetRegionSize(width,30)
    friends.count:SetPosition(70, -20)

    return friends
end

function PlayerSummaryScreen:_RefreshMostCommonFriend()
    local friends_info = {}
    local blackbook = PlayerHistory:GetRows()
    for i, data in ipairs(blackbook) do
        if data and data.name and data.server_name and data.prefab and data.sort_date then
            local info = friends_info[data.name]
            if info ~= nil then
                info.count = info.count + 1
                info.date = math.max(info.date, data.sort_date)
            else
                friends_info[data.name] = { row = i, count = 1, date = data.sort_date }
            end
        end
    end

    local friendslist = table.getkeys(friends_info)
    table.sort(friendslist, function(a, b)
        a, b = friends_info[a], friends_info[b]
        if a.count > b.count then
            return true
        elseif a.count < b.count then
            return false
        elseif a.date > b.date then
            return true
        elseif a.date < b.date then
            return false
        end
        return a.row < b.row
    end)

    local top_friend = friendslist[1]
    if top_friend ~= nil then
        self.most_friend.name:SetString(top_friend)
        self.most_friend.count:SetString(subfmt(STRINGS.UI.PLAYERSUMMARYSCREEN.ENCOUNTER_COUNT_FMT, { num_games = friends_info[top_friend].count }))
    else
        self.most_friend.name:SetString("")
        self.most_friend.count:SetString("")
    end
end

function PlayerSummaryScreen:_RefreshPuppet()
    local herocharacter = self.user_profile:GetLastSelectedCharacter()
    local base_skin = self.user_profile:GetBaseForCharacter(herocharacter)
    local clothing = self.user_profile:GetSkinsForCharacter(herocharacter, base_skin)
    local playerportrait = GetMostRecentlySelectedItem(self.user_profile, "playerportrait")
    -- Profileflair and rank are displayed on experiencebar when its visible.
    local profileflair = nil
    if not IsAnyFestivalEventActive() then
        profileflair = GetMostRecentlySelectedItem(self.user_profile, "profileflair")
    end
    self.puppet:UpdatePlayerListing(nil, nil, herocharacter, base_skin, clothing, playerportrait, profileflair)
end

function PlayerSummaryScreen:_BuildMenu()
    self.tooltip = self.root:AddChild(TEMPLATES.ScreenTooltip())

    local skins_button      = TEMPLATES.MenuButton(STRINGS.UI.MAINSCREEN.SKINS, function() self:OnSkinsButton() end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_SKINS, self.tooltip)
    local mysterybox_button = TEMPLATES.MenuButton(STRINGS.UI.MAINSCREEN.MYSTERYBOX, function() self:OnMysteryBoxButton() end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_MYSTERYBOX, self.tooltip)
    local history_button    = TEMPLATES.MenuButton(STRINGS.UI.MORGUESCREEN.HISTORY, function() self:OnHistoryButton() end,    STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_HISTORY,  self.tooltip)
    local trading_button    = TEMPLATES.MenuButton(STRINGS.UI.PLAYERSUMMARYSCREEN.TRADING, function() self:_FadeToScreen(TradeScreen, {}) end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_TRADE, self.tooltip)
    local purchase_button   = TEMPLATES.MenuButton(STRINGS.UI.PLAYERSUMMARYSCREEN.PURCHASE, function() self:_FadeToScreen(PurchasePackScreen, {}) end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_PURCHASE, self.tooltip)

    local menu_items = {
        {widget = purchase_button},
        {widget = trading_button},
        {widget = history_button},
        {widget = mysterybox_button},
        {widget = skins_button},
    }

    -- These won't be available when you first attempt to load this screen
    -- because they require the inventory to function correctly.
    self.waiting_for_inventory = {
        purchase_button,
        trading_button,
        history_button, -- There's no online data in history, but it looks weird as the lone available item.
        mysterybox_button,
        skins_button,
    }

    for i,w in ipairs(self.waiting_for_inventory) do
        w:Disable()
    end

    return self.root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))
end

function PlayerSummaryScreen:OnBecomeActive()
    PlayerSummaryScreen._base.OnBecomeActive(self)

	self.menu:RestoreFocusTo(self.last_focus_widget)
    self.leaving = nil

    self:_RefreshMostCommonFriend()
    self:_RefreshClientData()
    self:StartMusic()
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
    
    local shopStr = STRINGS.UI.PLAYERSUMMARYSCREEN.PURCHASE
    if IsShopNew(self.user_profile) then
        shopStr = string.format("%s (%s)", shopStr, STRINGS.UI.COLLECTIONSCREEN.NEW)
    end
    
    self.menu:EditItem(5,skinsStr)
    self.menu:EditItem(4,mysteryboxStr)
    self.menu:EditItem(1,shopStr)
end

function PlayerSummaryScreen:_RefreshClientData()
    -- Always update the puppet so it doesn't have the rank unless appropriate.
    self:_RefreshPuppet()
    if TheInventory:HasDownloadedInventory() then
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
    else
        self:_ScheduleRefresh()
    end
end

function PlayerSummaryScreen:_ScheduleRefresh()
    -- Player could navigate to this screen before inventory finishes
    -- downloading. Keep looking for updated data until it's ready.
    if self.refresh_task then
        self.refresh_task:Cancel()
        self.refresh_task = nil
    end
    self.refresh_task = self.inst:DoTaskInTime(2, function()
        self:_RefreshClientData()
    end)
end

function PlayerSummaryScreen:OnControl(control, down)
    if PlayerSummaryScreen._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        self:_Close()
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

function PlayerSummaryScreen:_Close()
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
