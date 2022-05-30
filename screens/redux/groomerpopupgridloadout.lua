local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Menu = require "widgets/menu"
local LoadoutSelect_beefalo = require "widgets/redux/loadoutselect_beefalo"
local TEMPLATES = require "widgets/redux/templates"

local BEEFALO_COSTUMES = require("yotb_costumes")

local SCREEN_OFFSET = -.38 * RESOLUTION_X

local GridGroomerPopupScreen = Class(Screen, function(self, target, owner_player, profile, recent_item_types, recent_item_ids, filter)
	Screen._ctor(self, "GridWardrobePopupScreen")
	self.target = target
    self.owner_player = owner_player
	self.filter = filter
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

	local clothing = {
		beef_body = target.skins.beef_body:value(),
		beef_head = target.skins.beef_head:value(),
		beef_horn = target.skins.beef_horn:value(),
		beef_feet = target.skins.beef_feet:value(),
		beef_tail = target.skins.beef_tail:value(),
	}

	self.initial_skins = { beef_body = clothing.beef_body, beef_feet = clothing.beef_feet, beef_horn = clothing.beef_horn, beef_tail = clothing.beef_tail, beef_head = clothing.beef_head }

	self.loadout = self.proot:AddChild(LoadoutSelect_beefalo(profile, self.target, self.initial_skins, self.filter, self.owner_player))
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

function GridGroomerPopupScreen:OffsetServerPausedWidget(serverpausewidget)
	serverpausewidget:SetOffset(-650,0)
end

function GridGroomerPopupScreen:OnDestroy()
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

function GridGroomerPopupScreen:OnBecomeActive()
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

function GridGroomerPopupScreen:GetTimestamp()
	local templist = TheInventory:GetFullInventory()
	local timestamp = 0

	for k,v in ipairs(templist) do
		if v.modified_time > timestamp then
			timestamp = v.modified_time
		end
	end

	return timestamp
end

function GridGroomerPopupScreen:DoFocusHookups()
	self.menu:SetFocusChangeDir(MOVE_LEFT, self.loadout)
    self.loadout:SetFocusChangeDir(MOVE_RIGHT, self.menu)
end

function GridGroomerPopupScreen:OnControl(control, down)
    if GridGroomerPopupScreen._base.OnControl(self,control, down) then return true end

    if control == CONTROL_CANCEL and not down then
        self:Cancel()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end
end

function GridGroomerPopupScreen:Cancel()
	self:Reset()
	self:Close(true)
end

function GridGroomerPopupScreen:Reset()
	self.loadout.selected_skins = self.initial_skins
end

function GridGroomerPopupScreen:Close(cancel)
	local skins = self.loadout.selected_skins

    local data = {}
    if TheNet:IsOnlineMode() then
		data = skins
    end

    if cancel then
    	data.cancel = true
    end

	if not data.base or data.base == self.loadout.currentcharacter or data.base == "" or not TheInventory:CheckOwnership(data["base"]) then data.base = (self.loadout.currentcharacter.."_none") end
	if not self:YOTB_event_check(data.beef_body) or not IsValidBeefaloClothing( data.beef_body ) or not TheInventory:CheckOwnership(data["beef_body"]) then data.beef_body = "" end
	if not self:YOTB_event_check(data.beef_horn) or not IsValidBeefaloClothing( data.beef_horn ) or not TheInventory:CheckOwnership(data["beef_horn"]) then data.beef_horn = "" end
	if not self:YOTB_event_check(data.beef_head) or not IsValidBeefaloClothing( data.beef_head ) or not TheInventory:CheckOwnership(data["beef_head"]) then data.beef_head = "" end
	if not self:YOTB_event_check(data.beef_feet) or not IsValidBeefaloClothing( data.beef_feet ) or not TheInventory:CheckOwnership(data["beef_feet"]) then data.beef_feet = "" end
	if not self:YOTB_event_check(data.beef_tail) or not IsValidBeefaloClothing( data.beef_tail ) or not TheInventory:CheckOwnership(data["beef_tail"]) then data.beef_tail = "" end

	POPUPS.GROOMER:Close(self.owner_player, data.beef_body, data.beef_horn, data.beef_head, data.beef_feet, data.beef_tail, data.cancel)

	self.timestamp = self:GetTimestamp()
	self.profile:SetCollectionTimestamp(self.timestamp)

    TheFrontEnd:PopScreen(self)
end

function GridGroomerPopupScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CANCEL)
	return table.concat(t, "  ")

end

function GridGroomerPopupScreen:OnUpdate(dt)
    self.loadout:OnUpdate(dt)
end

function GridGroomerPopupScreen:YOTB_event_check(name)
    if not IsSpecialEventActive(SPECIAL_EVENTS.YOTB) then
    	return true
    end

    for i,set in pairs(BEEFALO_COSTUMES.costumes)do
        for t,setskin in ipairs(set.skins) do
            if setskin == name then
                if checkbit(self.owner_player.yotb_skins_sets:value(), YOTB_COSTUMES[i]) then
                    return true
                else
                    return false
                end
            end
        end
    end
end

return GridGroomerPopupScreen