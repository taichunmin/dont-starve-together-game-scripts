local Widget = require "widgets/widget"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Menu = require "widgets/menu"
local LoadoutSelect = require "widgets/redux/loadoutselect"
local TEMPLATES = require "widgets/redux/templates"

local SCREEN_OFFSET = -.38 * RESOLUTION_X
local GridScarecrowClothingPopupScreen = Class(Screen, function(self, owner_scarecrow, doer, profile)
	Screen._ctor(self, "GridScarecrowClothingPopupScreen")

    self.owner_scarecrow = owner_scarecrow
    self.doer = doer
	self.profile = profile

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

	local client_table = owner_scarecrow.components.playeravatardata and owner_scarecrow.components.playeravatardata:GetData() or nil
	if client_table ~= nil then
		local base_skin, clothing = GetSkinsDataFromClientTableData(client_table)

		self.initial_skins = { base = base_skin, body = clothing.body, feet = clothing.feet, hand = clothing.hand, legs = clothing.legs }
	else
		self.initial_skins = {}
	end
    --dumptable(self.initial_skins)

	self.loadout = self.proot:AddChild(LoadoutSelect(profile, self.owner_scarecrow.prefab, nil, true, nil, true, self.initial_skins))
	self.loadout:SetDefaultMenuOption()

    local offline = not TheInventory:HasSupportForOfflineSkins() and not TheNet:IsOnlineMode()

	local buttons = {}
	if offline then
		table.insert(buttons, {text = STRINGS.UI.POPUPDIALOG.OK, cb = function() self:Close() end})
	else
		table.insert(buttons, {text = STRINGS.UI.WARDROBE_POPUP.CANCEL, cb=function() self:Cancel() end })
		table.insert(buttons, {text = STRINGS.UI.WARDROBE_POPUP.SET, cb=function() self:Close(true) end })
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

function GridScarecrowClothingPopupScreen:OffsetServerPausedWidget(serverpausewidget)
	serverpausewidget:SetOffset(-650,0)
end

function GridScarecrowClothingPopupScreen:OnDestroy()
    SetAutopaused(false)

    TheCamera:PushScreenHOffset(self, SCREEN_OFFSET)
    self._base.OnDestroy(self)

	-- All popups that are spawned from the wardrobe should be tagged with owned_by_wardrobe = true
	-- to ensure they are included when all screens are popped, with the exception of the server
	-- contact messages that need to stay up until the server communication is complete.

	local active_screen = TheFrontEnd:GetActiveScreen()
	while active_screen.owned_by_wardrobe do
		TheFrontEnd:PopScreen(active_screen)

		active_screen = TheFrontEnd:GetActiveScreen()
	end
end

function GridScarecrowClothingPopupScreen:OnBecomeActive()
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

function GridScarecrowClothingPopupScreen:GetTimestamp()
	local templist = TheInventory:GetFullInventory()
	local timestamp = 0

	for k,v in ipairs(templist) do
		if v.modified_time > timestamp then
			timestamp = v.modified_time
		end
	end

	return timestamp
end

function GridScarecrowClothingPopupScreen:DoFocusHookups()
	self.menu:SetFocusChangeDir(MOVE_LEFT, self.loadout)
    self.loadout:SetFocusChangeDir(MOVE_RIGHT, self.menu)
end

function GridScarecrowClothingPopupScreen:OnControl(control, down)
    if GridScarecrowClothingPopupScreen._base.OnControl(self,control, down) then return true end

    if control == CONTROL_CANCEL and not down then
        self:Cancel()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end
end

function GridScarecrowClothingPopupScreen:Cancel()
	self:Reset()
	self:Close()
end

function GridScarecrowClothingPopupScreen:Reset()
	self.loadout.selected_skins = self.initial_skins
end

function GridScarecrowClothingPopupScreen:Close(apply_skins)
	if not apply_skins then -- Not applying anything bail!
		POPUPS.WARDROBE:Close(self.doer)
		TheFrontEnd:PopScreen(self)
		return
	end

	local skins = self.loadout.selected_skins

    local data = {}
    if TheInventory:HasSupportForOfflineSkins() or TheNet:IsOnlineMode() then
		data = skins
    end

	if not data.base or data.base == self.loadout.currentcharacter or data.base == "" or not TheInventory:CheckOwnership(data["base"]) then data.base = (self.loadout.currentcharacter.."_none") end
	if not IsValidClothing( data.body ) or not TheInventory:CheckOwnership(data["body"]) then data.body = "" end
	if not IsValidClothing( data.hand ) or not TheInventory:CheckOwnership(data["hand"]) then data.hand = "" end
	if not IsValidClothing( data.legs ) or not TheInventory:CheckOwnership(data["legs"]) then data.legs = "" end
	if not IsValidClothing( data.feet ) or not TheInventory:CheckOwnership(data["feet"]) then data.feet = "" end

    POPUPS.WARDROBE:Close(self.doer, data.base, data.body, data.hand, data.legs, data.feet)

	self.timestamp = self:GetTimestamp()
	self.profile:SetCollectionTimestamp(self.timestamp)

    TheFrontEnd:PopScreen(self)
end

function GridScarecrowClothingPopupScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	local t = {}
    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.CANCEL)
	return table.concat(t, "  ")
end

return GridScarecrowClothingPopupScreen