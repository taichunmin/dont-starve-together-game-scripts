local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Menu = require "widgets/menu"
local LoadoutSelect = require "widgets/redux/loadoutselect"
local TEMPLATES = require "widgets/redux/templates"

local SCREEN_OFFSET = -.38 * RESOLUTION_X

local GridWardrobePopupScreen = Class(Screen, function(self, owner_player, profile, recent_item_types, recent_item_ids)
	Screen._ctor(self, "GridWardrobePopupScreen")

    self.owner_player = owner_player
	self.profile = profile

	self.previous_active_screen = TheFrontEnd:GetActiveScreen()

	--Copied from wardrobepopup.lua:

    --V2C: @liz
    -- recent_item_types and recent_item_ids are both tables of
    -- items that were just opened in the gift item popup.
    --
    -- Both params are nil if we did not come from GiftItemPopup.
    --
    -- They should be both in the same order, so recent_item_types[1]
    -- corresponds to recent_item_ids[1].
    -- (This is the exact same data that is passed into GiftItemPopup.)
    --
    -- Currently, it is safe to assume there will only be 1 item.
    --
    -- recent_item_ids is probably useless if we're only showing one
    -- of each item type in the spinners, and you should just match
    -- by recent_item_types[1].

	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.root = self.proot:AddChild(Widget("root"))
    self.root:SetPosition(-RESOLUTION_X/2, -RESOLUTION_Y/2, 0)

	local bg = self.proot:AddChild(Image("images/bg_redux_wardrobe_bg.xml", "wardrobe_bg.tex"))
	bg:SetScale(.8)
	bg:SetPosition(-200, 0)
	bg:SetTint(1, 1, 1, .76)

	local client_table = TheNet:GetClientTableForUser(ThePlayer.userid)
	if client_table ~= nil then
		local base_skin, clothing, _, _, _= GetSkinsDataFromClientTableData(client_table)

		self.initial_skins = { base = base_skin, body = clothing.body, feet = clothing.feet, hand = clothing.hand, legs = clothing.legs }
	else
		self.initial_skins = {}
	end


	self.previous_default_skins = profile:GetSkinsForCharacter(self.owner_player.prefab)

	if recent_item_types ~= nil and recent_item_types[1] ~= nil then
		local gift_item = recent_item_types[1]
		local gift_type = GetTypeForItem(gift_item)
		local new_skin_set = shallowcopy(self.initial_skins)

		new_skin_set[gift_type] = gift_item
		self.profile:SetSkinsForCharacter(self.owner_player.prefab, new_skin_set)
	else
		self.profile:SetSkinsForCharacter(self.owner_player.prefab, self.initial_skins)
	end

	local starting_skintype = GetSkinModeFromBuild(self.owner_player)

	self.loadout = self.proot:AddChild(LoadoutSelect(profile, self.owner_player.prefab, starting_skintype, true))
	self.loadout:SetDefaultMenuOption()


    local offline = not TheNet:IsOnlineMode()

	local buttons = {}
	if offline then
		table.insert(buttons, {text = STRINGS.UI.POPUPDIALOG.OK, cb = function() self:Close() end})
	else
		table.insert(buttons, {text = STRINGS.UI.WARDROBE_POPUP.CANCEL, cb=function() self:Cancel() end })
		table.insert(buttons, {text = STRINGS.UI.WARDROBE_POPUP.SET, cb=function() self:Close() end })
	end

	local spacing = 70
	self.menu = self.proot:AddChild(Menu(buttons, spacing, false, "carny_long", nil, 30))

	self.loadout:SetPosition(-306, 0)
	self.menu:SetPosition(493, -260, 0)

	self.default_focus = self.loadout

    TheCamera:PushScreenHOffset(self, SCREEN_OFFSET)

    self:DoFocusHookups()

    SetAutopaused(true)
end)

function GridWardrobePopupScreen:OffsetServerPausedWidget(serverpausewidget)
	serverpausewidget:SetOffset(-650,0)
end

function GridWardrobePopupScreen:OnDestroy()
    SetAutopaused(false)

    TheCamera:PushScreenHOffset(self, SCREEN_OFFSET)
    self._base.OnDestroy(self)

	self.profile:SetSkinsForCharacter(self.loadout.currentcharacter, self.previous_default_skins)

	-- All popups that are spawned from the wardrobe should be tagged with owned_by_wardrobe = true
	-- to ensure they are included when all screens are popped, with the exception of the server
	-- contact messages that need to stay up until the server communication is complete.

	local active_screen = TheFrontEnd:GetActiveScreen()
	while active_screen.owned_by_wardrobe do
		TheFrontEnd:PopScreen(active_screen)

		active_screen = TheFrontEnd:GetActiveScreen()
	end
end

function GridWardrobePopupScreen:OnBecomeActive()
	self._base.OnBecomeActive(self)

	if self.loadout and self.loadout.subscreener then
		for key,sub_screen in pairs(self.loadout.subscreener.sub_screens) do
			sub_screen:RefreshInventory()
		end
	end

    if TheInput:ControllerAttached() then
        self.default_focus:SetFocus()
    end
end

function GridWardrobePopupScreen:GetTimestamp()
	local templist = TheInventory:GetFullInventory()
	local timestamp = 0

	for k,v in ipairs(templist) do
		if v.modified_time > timestamp then
			timestamp = v.modified_time
		end
	end

	return timestamp
end

function GridWardrobePopupScreen:DoFocusHookups()
	self.menu:SetFocusChangeDir(MOVE_LEFT, self.loadout)
    self.loadout:SetFocusChangeDir(MOVE_RIGHT, self.menu)
end

function GridWardrobePopupScreen:OnControl(control, down)
    if GridWardrobePopupScreen._base.OnControl(self,control, down) then return true end

    if control == CONTROL_CANCEL and not down then
        self:Cancel()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end
end

function GridWardrobePopupScreen:Cancel()
	self:Reset()
	self:Close()
end

function GridWardrobePopupScreen:Reset()
	self.loadout.selected_skins = self.initial_skins
end

function GridWardrobePopupScreen:Close()
	local skins = self.loadout.selected_skins

    local data = {}
    if TheNet:IsOnlineMode() then
		data = skins
    end

	if not data.base or data.base == self.loadout.currentcharacter or data.base == "" or not TheInventory:CheckOwnership(data["base"]) then data.base = (self.loadout.currentcharacter.."_none") end
	if not IsValidClothing( data.body ) or not TheInventory:CheckOwnership(data["body"]) then data.body = "" end
	if not IsValidClothing( data.hand ) or not TheInventory:CheckOwnership(data["hand"]) then data.hand = "" end
	if not IsValidClothing( data.legs ) or not TheInventory:CheckOwnership(data["legs"]) then data.legs = "" end
	if not IsValidClothing( data.feet ) or not TheInventory:CheckOwnership(data["feet"]) then data.feet = "" end

    POPUPS.WARDROBE:Close(self.owner_player, data.base, data.body, data.hand, data.legs, data.feet)

	self.timestamp = self:GetTimestamp()
	self.profile:SetCollectionTimestamp(self.timestamp)

    TheFrontEnd:PopScreen(self)
end

function GridWardrobePopupScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CANCEL)
	return table.concat(t, "  ")

end

function GridWardrobePopupScreen:OnUpdate(dt)
    self.loadout:OnUpdate(dt)
end

return GridWardrobePopupScreen