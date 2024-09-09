local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local easing = require "easing"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"

local ImageButton = require "widgets/imagebutton"

local NUM_RECENT_ITEMS = 4

local MainMenuStatsPanel = Class(Widget, function(self, config)
    Widget._ctor(self, "MainMenuStatsPanel")

	self:SetPosition(50, 0)

	self.config = config

	local width = 300
	self.width = width

	local center_x = 0
	local center_y = 0
    local motd_w = width
	local motd_cell_size = {width = motd_w, height = motd_w/16*9}
	local text_padding = 13

    self.frame = self:AddChild(TEMPLATES.RectangleWindow(630, 320))
	self.frame:SetBackgroundTint(0,0,0,0.85)
	self.frame:SetPosition(115, -145)

	local item_root = self:AddChild(Widget("store_root"))
    item_root:SetPosition(-50, -90)

	self.image_bg = item_root:AddChild(ImageButton("images/stats_panel_motd.xml", "stats_panel_motd.tex"))
	self.image_bg:SetNormalScale(0.44,0.42)
	self.image_bg:SetFocusScale(0.44,0.42)
	self.image_bg:SetOnClick( function() config.store_cb() end )

	local featured_iap = GetRandomItem(GetFeaturedPacks())
	if featured_iap ~= nil then
		local iap_image = GetPurchaseDisplayForItem(featured_iap)

		self.image = item_root:AddChild(ImageButton(unpack(iap_image)))
		self.image:SetNormalScale(0.29,0.29)
		self.image:SetFocusScale(0.3,0.3)
		self.image:SetOnClick( function() config.store_cb() end )
		self.image:SetPosition(0, 5)
	end

	local max_w = motd_cell_size.width - text_padding * 2
	local title = item_root:AddChild(Text(BODYTEXTFONT, 22, "", UICOLOURS.HIGHLIGHT_GOLD))
	title:SetAutoSizingString(STRINGS.UI.STATSPANEL.MOTD_TITLE, max_w)
	title:SetHAlign(ANCHOR_LEFT)
	title:SetPosition(-110, 74)

	local body = item_root:AddChild(Text(BODYTEXTFONT, 20, "", UICOLOURS.GOLD_SELECTED))
	body:SetMultilineTruncatedString(STRINGS.UI.STATSPANEL.MOTD_BODY, 2, 355, nil, true)
	body:SetHAlign(ANCHOR_MIDDLE)
	body:SetVAlign(ANCHOR_MIDDLE)
	body:SetPosition(1,-74)


    item_root = self:AddChild(Widget("friend_root"))
    item_root:SetPosition(-50, -220)
    local friends_label = item_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.MOST_COMMON_FRIENDS, UICOLOURS.GOLD_SELECTED))
    friends_label:SetPosition(0,15)
    friends_label:SetRegionSize(width,30)
    local divider = item_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
    divider:SetScale(0.5)
    divider:SetPosition(0,5)


	self.friend_widgets = {}
	for i = 1, 3 do
		local friend = item_root:AddChild(Text(UIFONT, 22, ""))
		friend:SetPosition(0, 5 - i * 25)
		table.insert(self.friend_widgets, friend)
	end
	self:RefreshFriends()

	self.recent_items = self:AddChild(self:BuildItemsSummary(width))
	self.recent_items:SetPosition(300, -30)

	self.focus_forward = self.image

	self.hide_items = IsDailyGiftItemPending()
end)

function MainMenuStatsPanel:RefreshFriends()
	local friends = PlayerHistory:GetRows()
	if #friends == 0 then
		table.insert(friends, {name = STRINGS.UI.PLAYERSUMMARYSCREEN.NO_FRIENDS})
	end
	for i, w in ipairs(self.friend_widgets) do
		if friends[i] ~= nil then
			w:SetAutoSizingString(friends[i].name, self.width)
		else
			w:SetString("")
		end
	end
end

function MainMenuStatsPanel:OnBecomeActive()
	self.hide_items = IsDailyGiftItemPending()
    self.recent_items:UpdateItems()
	self:RefreshFriends()
end

function MainMenuStatsPanel:FindMostCommonDeaths()
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

	return causes
end

function MainMenuStatsPanel:BuildItemsSummary(width)
    local new_root = Widget("new items root")
    new_root.new_label = new_root:AddChild(Text(HEADERFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.NEW_STUFF, UICOLOURS.GOLD_SELECTED))
    new_root.new_label:SetPosition(0, 10)
    new_root.new_label:SetRegionSize(width, 30)

	local divider_top = new_root:AddChild( Image("images/frontend_redux.xml", "achievements_divider_top.tex") )
	divider_top:SetScale(0.5)
    divider_top:SetPosition(0, 0)

    local no_items = new_root:AddChild(Text(UIFONT, 25, STRINGS.UI.PLAYERSUMMARYSCREEN.NO_ITEMS))
    no_items:SetPosition(0, -35)
    no_items:SetRegionSize(width,60)
	no_items:EnableWordWrap(true)
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
			item:SetPosition(-80, 5 - i * 50)
			item:Hide()
			table.insert(items, item)
		end

		-- This msg will be stomped by UpdateItems!
		local unopened_msg = new_root:AddChild(Text(CHATFONT, 25, "", UICOLOURS.WHITE))
		unopened_msg:SetPosition(0,-240)
		unopened_msg:SetRegionSize(width,30)
		unopened_msg:Hide()

		new_root.UpdateItems = function()
			-- This first case checks if the Inventory download process has finished but the inventory hasn't actually been downloaded. 
			-- If this is true then replace the "Loading Discoveries..." message with an error rather than leaving it stuck on the panel.
			local isDownloadingInventory, progress = TheInventory:IsDownloadingInventory()
			if not isDownloadingInventory and not TheInventory:HasDownloadedInventory() then
				for i, item in ipairs(items) do
					item:Hide()
				end
				no_items:Show()
				no_items:SetString(STRINGS.UI.PLAYERSUMMARYSCREEN.FAILED_INVENTORY_TITLE)
				unopened_msg:Hide()
				return
			end

		    if self.hide_items or not TheInventory:HasDownloadedInventory() then
				for i, item in ipairs(items) do
					item:Hide()
				end
				no_items:Show()
				no_items:SetString(STRINGS.UI.PLAYERSUMMARYSCREEN.LOADING_STUFF)
				unopened_msg:Hide()

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
			if box_count > 0 then
				unopened_msg:SetString(subfmt(STRINGS.UI.PLAYERSUMMARYSCREEN.UNOPENED_BOXES_FMT, {num_boxes = box_count}))
				unopened_msg:Show()
			else
				unopened_msg:Hide()
			end
		end
	end

	new_root.ScheduleRefresh = function()
		-- Player could navigate to this screen before inventory finishes
		-- downloading. Keep looking for updated data until it's ready.
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


return MainMenuStatsPanel
