local CollectionScreen = require "screens/redux/collectionscreen"
local SkinDebugScreen = require "screens/redux/skindebugscreen"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
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
local Puppet = require "widgets/skinspuppet"
local WardrobeScreen = require "screens/redux/wardrobescreen"

local KitcoonPuppet = require "widgets/kitcoonpuppet"

require("characterutil")
require("skinsutils")


local PlayerSummaryScreen = Class(Screen, function(self, prev_screen, user_profile)
	Screen._ctor(self, "PlayerSummaryScreen")
    self.prev_screen = prev_screen
    self.user_profile = user_profile
	self.can_shop = IsNotConsole()
    
    self.character_list = GetFEVisibleCharacterList()

    TheSim:PauseFileExistsAsync(true)

    self:DoInit()

    self:StartUpdating()

	self.default_focus = self.menu
end)

function PlayerSummaryScreen:DoInit()
    self.letterbox = self:AddChild(TEMPLATES.old.ForegroundLetterbox())

    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.BrightMenuBackground())
    self.title = self.root:AddChild(TEMPLATES.ScreenTitle(STRINGS.UI.PLAYERSUMMARYSCREEN.TITLE, ""))
   
    self:_BuildPosse()

    self.bottom_root = self.root:AddChild(Widget("bottom_root"))
    self.bottom_root:SetPosition(100, -200)
    self.new_items = self.bottom_root:AddChild(self:_BuildItemsSummary())

    self.kit_puppet = self.root:AddChild(KitcoonPuppet( Profile, nil, {
        { x = -380, y = 50, scale = 0.75 },
        { x = -380, y = 170, scale = 0.75 },
        { x = -330, y = -300, scale = 0.75 },
    } ))

    self.onlinestatus = self.root:AddChild(OnlineStatus(true))

    self.puppet = self.root:AddChild(PlayerAvatarPortrait())
    self.puppet:SetScale(1.2)
    self.puppet:HideHoverText()
    self.puppet:SetPosition(-500, 140)
    if IsAnyFestivalEventActive() then
        -- Profileflair and rank are displayed on experiencebar when its visible.
        self.puppet:AlwaysHideRankBadge()
    end
    
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

function PlayerSummaryScreen:_BuildItemsSummary()
    local width = 300
    local NUM_RECENT_ITEMS = 6

    local new_root = Widget("new items root")
    new_root.new_label = new_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.NEW_STUFF, UICOLOURS.GOLD_SELECTED))
    new_root.new_label:SetPosition(0, 15)
    new_root.new_label:SetRegionSize(width, 30)

	local divider_top = new_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
	divider_top:SetScale(0.5)
    divider_top:SetPosition(0, 0)

    local no_items = new_root:AddChild(Text(UIFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.NO_ITEMS))
    no_items:SetPosition(0, -45)
    no_items:SetRegionSize(width,30)
    no_items:Hide()

    if not TheInventory:HasSupportForOfflineSkins() and (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
		no_items:SetString(STRINGS.UI.PLAYERSUMMARYSCREEN.OFFLINE_NO_ITEMS)
	    no_items:Show()

		new_root.UpdateItems = function() end
	else
		local items = {}
		for i = 1, NUM_RECENT_ITEMS do
			local item = new_root:AddChild(TEMPLATES.ItemImageText())
			item:SetScale(0.9)
            item.icon:SetScale(0.75)
            local x = math.fmod(i-1,3)
            local y = math.floor((i-1)/3)
			item:SetPosition(300 * x - 360, -50 * y - 50)
			item:Hide()
			table.insert(items, item)
		end

        local counter = 0
        new_root.UpdateItems = function()
		    if self.hide_items or not TheInventory:HasDownloadedInventory() then
				for i, item in ipairs(items) do
					item:Hide()
				end
				no_items:Show()
				no_items:SetString(STRINGS.UI.PLAYERSUMMARYSCREEN.LOADING_STUFF)

				new_root.ScheduleRefresh()
				return
			end

			local inventory = GetInventorySkinsList()
			table.sort(inventory, function(a, b) return (a.timestamp > b.timestamp) or (a.timestamp == b.timestamp and a.item_id < b.item_id) end)

			local count = 0
			for i, item_data in ipairs(inventory) do
				if item_data.type ~= "mysterybox" then
					count = count + 1
					items[count]:SetItem(item_data.type, item_data.item, item_data.item_id, item_data.timestamp)
					items[count]:Show()

					if count >= NUM_RECENT_ITEMS then
						break
					end
				end
			end
			if count == 0 then
				for i, item in ipairs(items) do
					item:Hide()
				end
				no_items:Show()
				no_items:SetString(STRINGS.UI.PLAYERSUMMARYSCREEN.NO_ITEMS)
			else
				no_items:Hide()
			end

			local box_count = 0
			for key,count in pairs(GetMysteryBoxCounts()) do
				box_count = box_count + count
			end
		end
    end

    new_root.ScheduleRefresh = function()
		-- Player could navigate to this screen before inventory finishes downloading. Keep looking for updated data until it's ready.
		if self.refresh_task then
			self.refresh_task:Cancel()
			self.refresh_task = nil
		end
		self.refresh_task = self.inst:DoTaskInTime(2, function()
			self.refresh_task = nil
			new_root.UpdateItems()
		end)
	end

    return new_root
end

function PlayerSummaryScreen:_BuildPosse()
    self.posse_root = self.root:AddChild(Widget("posse_root"))
    self.posse_root:SetPosition(-230, 150)
    --self.posse_root:SetScale(0.8)

    self.glow = self.posse_root:AddChild(Image("images/lobbyscreen.xml", "glow.tex"))
	self.glow:SetPosition(160, -80)
	self.glow:SetScale(5, 3)
	self.glow:SetTint(1, 1, 1, .5)
    self.glow:SetClickable(false)

    self.glow2 = self.posse_root:AddChild(Image("images/lobbyscreen.xml", "glow.tex"))
	self.glow2:SetPosition(640, -80)
	self.glow2:SetScale(5, 3)
	self.glow2:SetTint(1, 1, 1, .5)
    self.glow2:SetClickable(false)

    self.posse = {}

    local x_off = 114
    local y_off = -150

    local x = 0
    local y = 0
    local offset = 0

    for k,v in pairs( self.character_list ) do
        local puppet = self.posse_root:AddChild(Puppet( 15, 40 ))
        puppet.add_change_emote_for_idle = true
        puppet:SetScale(1.8)
        puppet:AddShadow()
        puppet:SetPosition(x * x_off + offset * (x_off/2), y * y_off)

        local clothing = self.user_profile:GetSkinsForCharacter(v)
        puppet:SetSkins(v, nil, {}, true)

        table.insert( self.posse, puppet )

        x = x + 1
        if k == 6 then
            x = 0
            y = y + 1
            offset = 1
        end
        if k == 12 then
            x = 0
            y = y + 1
            offset = 0
        end
    end
end

function PlayerSummaryScreen:_RefreshPuppets()
    local herocharacter = self.user_profile:GetLastSelectedCharacter()
    local clothing = self.user_profile:GetSkinsForCharacter(herocharacter)
    local playerportrait = GetMostRecentlySelectedItem(self.user_profile, "playerportrait")
    -- Profileflair and rank are displayed on experiencebar when its visible.
    local profileflair = nil
    if not IsAnyFestivalEventActive() then
        profileflair = GetMostRecentlySelectedItem(self.user_profile, "profileflair")
    end
    self.puppet:UpdatePlayerListing(nil, nil, herocharacter, clothing.base, clothing, playerportrait, profileflair)

    local keys = shuffledKeys(self.character_list)
    for k,rand_key in pairs(keys) do
        local prefab = self.character_list[rand_key]
        local clothing = self.user_profile:GetSkinsForCharacter(prefab)
        self.posse[k]:SetSkins(prefab, clothing.base, clothing, true)

        self.posse[k]:SetOnClick(function()
            TheFrontEnd:FadeToScreen( self, function() return WardrobeScreen(self.user_profile, prefab) end, nil )
        end )

        if IsRestrictedCharacter( prefab ) and not IsCharacterOwned( prefab ) then
            self.posse[k]:Sit()
        end
    end
end

function PlayerSummaryScreen:_BuildMenu()

    local menu_root = self.root:AddChild(Widget("meun_root"))
    menu_root:SetPosition(0, -50)

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

    self.tooltip = menu_root:AddChild(TEMPLATES.ScreenTooltip(menu_button_style))

    local skins_button      = TEMPLATES.MenuButton(STRINGS.UI.MAINSCREEN.SKINS, function() self:OnSkinsButton() end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_SKINS, self.tooltip, menu_button_style)
    local mysterybox_button = TEMPLATES.MenuButton(STRINGS.UI.MAINSCREEN.MYSTERYBOX, function() self:OnMysteryBoxButton() end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_MYSTERYBOX, self.tooltip, menu_button_style)
    local trading_button    = TEMPLATES.MenuButton(STRINGS.UI.PLAYERSUMMARYSCREEN.TRADING, function() self:_FadeToScreen(TradeScreen, {}) end, STRINGS.UI.PLAYERSUMMARYSCREEN.TOOLTIP_TRADE, self.tooltip, menu_button_style)
    local redeem_button     = nil

    local menu_items = {
        {widget = trading_button},
        {widget = mysterybox_button},
        {widget = skins_button},
    }

    -- These won't be available when you first attempt to load this screen
    -- because they require the inventory to function correctly.
    self.waiting_for_inventory = {
        trading_button,
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

    return menu_root:AddChild(TEMPLATES.StandardMenu(menu_items, 38, nil, nil, true))
end

function PlayerSummaryScreen:OnBecomeActive()
    PlayerSummaryScreen._base.OnBecomeActive(self)

    if self.kit_puppet then
        self.kit_puppet:Enable()
    end

	if self.last_focus_widget then
		self.menu:RestoreFocusTo(self.last_focus_widget)
	end
    self.leaving = nil

    self:_RefreshClientData()
    self:StartMusic()

    DisplayInventoryFailedPopup( self )
end

function PlayerSummaryScreen:OnBecomeInactive()
    PlayerSummaryScreen._base.OnBecomeInactive(self)

    if self.kit_puppet then
        self.kit_puppet:Disable()
    end
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
    self:_RefreshPuppets()

    for i,w in ipairs(self.waiting_for_inventory) do
        w:Enable()
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
    if (TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
        TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.OFFLINE, STRINGS.UI.PLAYERSUMMARYSCREEN.MYSTERYBOX_DISABLE, 
            {
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_LOGIN, cb = function()
                        SimReset()
                    end},
                {text=STRINGS.UI.FESTIVALEVENTSCREEN.OFFLINE_POPUP_BACK, cb=function() TheFrontEnd:PopScreen() end },
            }))
    else
        self:_FadeToScreen(MysteryBoxScreen, {})
    end
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

function PlayerSummaryScreen:OnUpdate(dt)
    for _,puppet in pairs( self.posse ) do
        puppet:EmoteUpdate(dt)
    end
end

return PlayerSummaryScreen
