require "class"
local InvSlot = require "widgets/invslot"
local TileBG = require "widgets/tilebg"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local EquipSlot = require "widgets/equipslot"
local ItemTile = require "widgets/itemtile"
local Text = require "widgets/text"
local HudCompass = require "widgets/hudcompass"

local TEMPLATES = require "widgets/templates"

local HUD_ATLAS = "images/hud.xml"
local HUD2_ATLAS = "images/hud2.xml"

local HUD_CHARACTERS = 
{
    ["wanda"] = HUD2_ATLAS,
}

local W = 68
local SEP = 12
local YSEP = 8
local INTERSEP = 28

local CURSOR_STRING_DELAY = 10
local TIP_YFUDGE = 16
local HINT_UPDATE_INTERVAL = 2.0 -- once per second

local Inv = Class(Widget, function(self, owner)
    Widget._ctor(self, "Inventory")
    self.owner = owner

    self.out_pos = Vector3(0,W,0)
    self.in_pos = Vector3(0,W*1.5,0)

    self.base_scale = .6
    self.selected_scale = .8

    self:SetScale(self.base_scale)
    self:SetPosition(0,-16,0)

    self.inv = {}
    self.backpackinv = {}
    self.equip = {}
    self.equipslotinfo = {}

    self.root = self:AddChild(Widget("root"))

    self.hudcompass = self.root:AddChild(HudCompass(owner, true))
    self.hudcompass:SetScale(1.5, 1.5)
    self.hudcompass:SetMaster()

    self.hand_inv = self.root:AddChild(Widget("hand_inv"))
    self.hand_inv:SetScale(1.5, 1.5)

	if TheNet:GetServerGameMode() == "lavaarena" then
	    self.base_scale = .55
		self:SetScale(self.base_scale)
	    self:SetPosition(0,0,0)

		self.bg = self.root:AddChild(Image("images/lavaarena_hud.xml", "lavaarena_inventorybar.tex"))
		self.bgcover = self.root:AddChild(Widget("dummy"))
		self.in_pos = Vector3(41,W*1.5,0)
	elseif TheNet:GetServerGameMode() == "quagmire" then
		self.bg = self.root:AddChild(Image("images/quagmire_hud.xml", "inventory_bg.tex"))
		self.bgcover = self.root:AddChild(Widget("dummy"))
		self.in_pos = Vector3(0,72,0)
	    self.base_scale = .75
		self.selected_scale = .8
	    self:SetScale(self.base_scale)
	else
		self.bg = self.root:AddChild(Image(HUD_ATLAS, "inventory_bg.tex"))
		self.bgcover = self.root:AddChild(Image(HUD_ATLAS, "inventory_bg_cover.tex"))
	end

    self.hovertile = nil
    self.cursortile = nil

    self.repeat_time = .2
	self.reps = 0

    --this is for the keyboard / controller inventory controls
    self.actionstring = self.root:AddChild(Widget("actionstring"))
    self.actionstring:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.actionstringtitle = self.actionstring:AddChild(Text(TALKINGFONT, 35))
    self.actionstringtitle:SetColour(204/255, 180/255, 154/255, 1)

    self.actionstringbody = self.actionstring:AddChild(Text(TALKINGFONT, 25))
    self.actionstringbody:EnableWordWrap(true)
    self.actionstring:Hide()

    --default equip slots
	if TheNet:GetServerGameMode() == "quagmire" then
		self:AddEquipSlot(EQUIPSLOTS.HANDS, HUD_ATLAS, "equip_slot.tex")
	else
		self:AddEquipSlot(EQUIPSLOTS.HANDS, HUD_ATLAS, "equip_slot.tex")
		self:AddEquipSlot(EQUIPSLOTS.BODY, HUD_ATLAS, "equip_slot_body.tex")
		self:AddEquipSlot(EQUIPSLOTS.HEAD, HUD_ATLAS, "equip_slot_head.tex")
	end

    self.inst:ListenForEvent("builditem", function(inst, data) self:OnBuild() end, self.owner)
    self.inst:ListenForEvent("itemget", function(inst, data) self:OnItemGet(data.item, self.inv[data.slot], data.src_pos, data.ignore_stacksize_anim) end, self.owner)
    self.inst:ListenForEvent("equip", function(inst, data) self:OnItemEquip(data.item, data.eslot) end, self.owner)
    self.inst:ListenForEvent("unequip", function(inst, data) self:OnItemUnequip(data.item, data.eslot) end, self.owner)
    self.inst:ListenForEvent("newactiveitem", function(inst, data) self:OnNewActiveItem(data.item) end, self.owner)
    self.inst:ListenForEvent("itemlose", function(inst, data) self:OnItemLose(self.inv[data.slot]) end, self.owner)
	self.inst:ListenForEvent("refreshinventory", function() self:Refresh(true) end, self.owner)
    self.inst:ListenForEvent("onplacershown", function() self:OnPlacerChanged(true) end, self.owner)
    self.inst:ListenForEvent("onplacerhidden", function() self:OnPlacerChanged(false) end, self.owner)

    --NOTE: this is triggered on the swap SOURCE. we need to stop updates because
    --      playercontroller component is removed first, entity remove is delayed.
    self.inst:ListenForEvent("seamlessplayerswap", function() self:StopUpdating() end, self.owner)

    --NOTE: this is triggered on the swap TARGET.
    self.inst:ListenForEvent("finishseamlessplayerswap", function () if self.rebuild_pending then self.rebuild_snapping = true self:Rebuild() self:Refresh() end end, self.owner)

    self.root:SetPosition(self.in_pos)
    self:StartUpdating()

    self.actionstringtime = CURSOR_STRING_DELAY

    self.openhint = self:AddChild(Text(UIFONT, 52))
    self.openhint:SetRegionSize(300, 60)
    self.openhint:SetHAlign(ANCHOR_LEFT)
	if TheNet:GetServerGameMode() == "quagmire" then
	    self.openhint:SetPosition(400, 70, 0)
	else
	    self.openhint:SetPosition(940, 70, 0)
	end

    self.hint_update_check = HINT_UPDATE_INTERVAL

    self.controller_build = nil
    self.integrated_backpack = nil
    self.force_single_drop = false
	self.autopaused = false
	self.autopause_delay = 0
end)

function Inv:AddEquipSlot(slot, atlas, image, sortkey)
    sortkey = sortkey or #self.equipslotinfo
    table.insert(self.equipslotinfo, {slot = slot, atlas = atlas, image = image, sortkey = sortkey})
    table.sort(self.equipslotinfo, function(a,b) return a.sortkey < b.sortkey end)
    self.rebuild_pending = true
end

local function BackpackGet(inst, data)
    local owner = ThePlayer
    if owner ~= nil and owner.HUD ~= nil and owner.replica.inventory:IsHolding(inst) then
        local inv = owner.HUD.controls.inv
        if inv ~= nil then
            inv:OnItemGet(data.item, inv.backpackinv[data.slot], data.src_pos, data.ignore_stacksize_anim)
        end
    end
end

local function BackpackLose(inst, data)
    local owner = ThePlayer
    if owner ~= nil and owner.HUD ~= nil and owner.replica.inventory:IsHolding(inst) then
        local inv = owner.HUD.controls.inv
        if inv ~= nil then
            inv:OnItemLose(inv.backpackinv[data.slot])
        end
    end
end

local function BackpackRefresh(inst)
	local owner = ThePlayer
	local inventory = owner and owner.HUD and owner.replica.inventory or nil
	local overflow = inventory and inventory:GetOverflowContainer() or nil
	if overflow and overflow.inst == inst then
		local inv = owner.HUD.controls.inv
		if inv then
			inv:RefreshIntegratedContainer()
		end
	end
end

local function RebuildLayout_Quagmire(self, inventory, overflow, do_integrated_backpack, do_self_inspect)
	local inv_scale = 1
	local inv_w = 68 * inv_scale
	local inv_sep = 10 * inv_scale
	local inv_y = -77
	local inv_tip_y = inv_w + inv_sep + (30 * inv_scale)

    local num_slots = inventory:GetNumSlots()
    local x = -165
    for k = 1, num_slots do
        self.inv[k] = InvSlot(k, HUD_ATLAS, "inv_slot.tex", self.owner, self.owner.replica.inventory)
		local slot = self.toprow:AddChild(Widget("slot_scaler"..k))
		slot:AddChild(self.inv[k])
        slot:SetPosition(x, inv_y)
		slot:SetScale(inv_scale)
        slot.top_align_tip = inv_w + inv_sep + 30 -- tooltip text offset when using cursors

        local item = inventory:GetItemInSlot(k)
        if item ~= nil then
            self.inv[k]:SetTile(ItemTile(item))
        end

        x = x + 83
    end

	local equip_scale = 0.8
	local equip_y = -74

    local hand_slot = self.equipslotinfo[1]
    local slot = EquipSlot(hand_slot.slot, hand_slot.atlas, hand_slot.image, self.owner)
    slot:SetPosition(x, equip_y)
	slot.highlight_scale = 1
	slot.base_scale = equip_scale
	slot:SetScale(equip_scale)


    self.equip[hand_slot.slot] = self.toprow:AddChild(slot)

    local item = inventory:GetEquippedItem(hand_slot.slot)
    if item ~= nil then
        slot:SetTile(ItemTile(item))
    end


    self.toprow:SetPosition(0, 75)
    self.bg:SetPosition(0, 15)

    self.root:SetPosition(self.in_pos)
    self:UpdatePosition()
end

local function RebuildLayout(self, inventory, overflow, do_integrated_backpack, do_self_inspect)
    local y = overflow ~= nil and ((W + YSEP) / 2) or 0
    local eslot_order = {}

    local num_slots = inventory:GetNumSlots()
    local num_equip = #self.equipslotinfo
    local num_buttons = do_self_inspect and 1 or 0
    local num_slotintersep = math.ceil(num_slots / 5)
    local num_equipintersep = num_buttons > 0 and 1 or 0
    local total_w = (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP

	local x = (W - total_w) * .5 + num_slots * W + (num_slots - num_slotintersep) * SEP + num_slotintersep * INTERSEP
    for k, v in ipairs(self.equipslotinfo) do
        local slot = EquipSlot(v.slot, v.atlas, v.image, self.owner)
        self.equip[v.slot] = self.toprow:AddChild(slot)
        slot:SetPosition(x, 0, 0)
        table.insert(eslot_order, slot)

        local item = inventory:GetEquippedItem(v.slot)
        if item ~= nil then
            slot:SetTile(ItemTile(item))
        end

        if v.slot == EQUIPSLOTS.HANDS then
            self.hudcompass:SetPosition(x, do_integrated_backpack and 80 or 40, 0)
            self.hand_inv:SetPosition(x, do_integrated_backpack and 80 or 40, 0)
        end

        x = x + W + SEP
    end

    x = (W - total_w) * .5
    for k = 1, num_slots do
        local slot = InvSlot(k, HUD_ATLAS, "inv_slot.tex", self.owner, self.owner.replica.inventory)
        self.inv[k] = self.toprow:AddChild(slot)
        slot:SetPosition(x, 0, 0)
        slot.top_align_tip = W * .5 + YSEP

        local item = inventory:GetItemInSlot(k)
        if item ~= nil then
            slot:SetTile(ItemTile(item))
        end

        x = x + W + (k % 5 == 0 and INTERSEP or SEP)
    end

    local owner_prefab = self.owner.prefab
    local image_name = "self_inspect_".. owner_prefab ..".tex"
    local atlas_name = "images/avatars/self_inspect_".. owner_prefab.. ".xml"
    if softresolvefilepath(atlas_name) == nil then
        atlas_name = HUD_CHARACTERS[owner_prefab] or HUD_ATLAS
    end

    if do_self_inspect then
        self.bg:SetScale(1.22, 1, 1)
        self.bgcover:SetScale(1.22, 1, 1)

        self.inspectcontrol = self.toprow:AddChild(TEMPLATES.IconButton(atlas_name, image_name, STRINGS.UI.HUD.INSPECT_SELF, false, false, function() self.owner.HUD:InspectSelf() end, nil, "self_inspect_mod.tex"))
        self.inspectcontrol.icon:SetScale(.7)
        self.inspectcontrol.icon:SetPosition(-4, 6)
        self.inspectcontrol:SetScale(1.25)
        self.inspectcontrol:SetPosition((total_w - W) * .5 + 3, -7, 0)
    else
        self.bg:SetScale(1.15, 1, 1)
        self.bgcover:SetScale(1.15, 1, 1)

        if self.inspectcontrol ~= nil then
            self.inspectcontrol:Kill()
            self.inspectcontrol = nil
        end
    end

    local hadbackpack = self.backpack ~= nil
    if hadbackpack then
        self.inst:RemoveEventCallback("itemget", BackpackGet, self.backpack)
        self.inst:RemoveEventCallback("itemlose", BackpackLose, self.backpack)
		self.inst:RemoveEventCallback("refresh", BackpackRefresh, self.backpack)
        self.backpack = nil
    end

    if do_integrated_backpack then
        local num = overflow:GetNumSlots()

        local x = - (num * (W+SEP) / 2)
        --local offset = #self.inv >= num and 1 or 0 --math.ceil((#self.inv - num)/2)
        local offset = 1 + #self.inv - num

		self.integrated_arrow = self.bottomrow:AddChild(Image(HUD_ATLAS, "inventory_bg_arrow.tex"))
		self.integrated_arrow:SetPosition(self.inv[#self.inv]:GetPosition().x + W * 0.5 + INTERSEP + 61, 8)

        for k = 1, num do
            local slot = InvSlot(k, HUD_ATLAS, "inv_slot.tex", self.owner, overflow)
            self.backpackinv[k] = self.bottomrow:AddChild(slot)

            slot.top_align_tip = W*1.5 + YSEP*2

            if offset > 0 then
                slot:SetPosition(self.inv[offset+k-1]:GetPosition().x,0,0)
            else
                slot:SetPosition(x,0,0)
                x = x + W + SEP
            end

            local item = overflow:GetItemInSlot(k)
            if item ~= nil then
                slot:SetTile(ItemTile(item))
            end
        end

        self.backpack = overflow.inst
        self.inst:ListenForEvent("itemget", BackpackGet, self.backpack)
        self.inst:ListenForEvent("itemlose", BackpackLose, self.backpack)
		self.inst:ListenForEvent("refresh", BackpackRefresh, self.backpack)
    end

    if hadbackpack and self.backpack == nil then
        self:SelectDefaultSlot()
    end

    if self.bg.Flow ~= nil then
        -- note: Flow is a 3-slice function
        self.bg:Flow(total_w + 60, 256, true)
    end

    if TheNet:GetServerGameMode() == "lavaarena" then
        self.bg:SetPosition(15, 0)
        self.bg:SetScale(1)
        self.toprow:SetPosition(0, 3)
        self.root:SetPosition(self.in_pos)
    elseif do_integrated_backpack then
        self.bg:SetPosition(0, -24)
        self.bgcover:SetPosition(0, -135)
        self.toprow:SetPosition(0, .5 * (W + YSEP))
        self.bottomrow:SetPosition(0, -.5 * (W + YSEP))

        if self.rebuild_snapping then
			self.root:CancelMoveTo()
            self.root:SetPosition(self.in_pos)
            self:UpdatePosition()
        else
            self.root:MoveTo(self.out_pos, self.in_pos, .5)
        end
    else
        self.bg:SetPosition(0, -64)
        self.bgcover:SetPosition(0, -100)
        self.toprow:SetPosition(0, 0)
        self.bottomrow:SetPosition(0, 0)

        if do_integrated_backpack and not self.rebuild_snapping then
            self.root:MoveTo(self.in_pos, self.out_pos, .2)
        else
			self.root:CancelMoveTo()
            self.root:SetPosition(self.out_pos)
            self:UpdatePosition()
        end
    end
end

function Inv:Rebuild()
    if self.cursor ~= nil then
        self.cursor:Kill()
        self.cursor = nil
    end

    if self.toprow ~= nil then
        self.toprow:Kill()
		self.inspectcontrol = nil
    end

    if self.bottomrow ~= nil then
        self.bottomrow:Kill()
    end

    self.toprow = self.root:AddChild(Widget("toprow"))
    self.bottomrow = self.root:AddChild(Widget("toprow"))

    self.inv = {}
    self.equip = {}
    self.backpackinv = {}

	local controller_attached = TheInput:ControllerAttached()
    self.controller_build = controller_attached
	self.integrated_backpack = controller_attached or Profile:GetIntegratedBackpack()

    local inventory = self.owner.replica.inventory

	local overflow = inventory:GetOverflowContainer()
	overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil

	local do_integrated_backpack = overflow ~= nil and self.integrated_backpack
    local do_self_inspect = not (self.controller_build or GetGameModeProperty("no_avatar_popup"))

	if TheNet:GetServerGameMode() == "quagmire" then
		RebuildLayout_Quagmire(self, inventory, overflow, do_integrated_backpack, do_self_inspect)
	else
		RebuildLayout(self, inventory, overflow, do_integrated_backpack, do_self_inspect)
	end

    self.actionstring:MoveToFront()

    self:SelectDefaultSlot()
    self:UpdateCursor()

    if self.cursor ~= nil then
        self.cursor:MoveToFront()
    end

    self.rebuild_pending = nil
    self.rebuild_snapping = nil
end

function Inv:RefreshRepeatDelay(control)
	if self.reps <= 1 then
		self.repeat_time = TheFrontEnd.inventory_repeat_base
	elseif self.reps >= 3 and Input:GetAnalogControlValue(control) > 0.95 then
		self.repeat_time = TheFrontEnd.inventory_repeat_ninja
	else
		self.repeat_time = TheFrontEnd.inventory_repeat_fast
	end
end

function Inv:OnUpdate(dt)
	if self.open and not self.autopaused then
		local playercontroller = self.owner.components.playercontroller
		if playercontroller ~= nil then
			local busy = playercontroller:IsDoingOrWorking() or playercontroller:IsBusy()
			if self.autopause_delay > 0 then
				if busy then
					--started doing the action
					self.autopause_delay = 0
				elseif self.autopause_delay > dt then
					--still waiting for action to start
					self.autopause_delay = self.autopause_delay - dt
				else
					--timed out before the action ever started
					self.autopause_delay = 0
					self:SetAutopausedInternal(true)
				end
			elseif not busy then
				--action finished
				self:SetAutopausedInternal(true)
			end
		end
	end

    self:UpdatePosition()

    self.hint_update_check = self.hint_update_check - dt
    if 0 > self.hint_update_check then
        if #self.inv <= 0 or not TheInput:ControllerAttached() then
            self.openhint:Hide()
        else
            self.openhint:Show()
            self.openhint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_OPEN_INVENTORY))
        end
        self.hint_update_check = HINT_UPDATE_INTERVAL
    end

    if not self.owner.HUD.shown or self.owner.HUD ~= TheFrontEnd:GetActiveScreen() then
        return
    end

    if self.rebuild_pending then
        self:Rebuild()
        self:Refresh()
    end

	if self.owner.HUD:IsCraftingOpen() or self.owner.HUD:IsSpellWheelOpen() then
        self.actionstring:Hide()
		return
	end

    --V2C: Don't set pause in multiplayer, all it does is change the
    --     audio settings, which we don't want to do now
    --if self.open and TheInput:ControllerAttached() then
    --    SetPause(true, "inv")
    --end

    if not self.open and self.actionstring and self.actionstringtime and self.actionstringtime > 0 then
        self.actionstringtime = self.actionstringtime - dt
        if self.actionstringtime <= 0 then
            self.actionstring:Hide()
        end
    end

    if self.repeat_time > 0 then
        self.repeat_time = self.repeat_time - dt
    end

    if self.active_slot ~= nil and not self.active_slot.inst:IsValid() then
        self:SelectDefaultSlot()

        if self.cursor ~= nil then
            self.cursor:Kill()
            self.cursor = nil
        end
    end

    self:UpdateCursor()

    if self.shown then
        --this is intentionally unaware of focus
        if self.repeat_time <= 0 then
            self.reps = self.reps and (self.reps + 1) or 1

			if self.open then
				if TheInput:IsControlPressed(CONTROL_MOVE_LEFT) then
					self:RefreshRepeatDelay(CONTROL_MOVE_LEFT)
	                self:CursorLeft()
					return
				elseif TheInput:IsControlPressed(CONTROL_MOVE_RIGHT) then
					self:RefreshRepeatDelay(CONTROL_MOVE_RIGHT)
					self:CursorRight()
					return
				elseif TheInput:IsControlPressed(CONTROL_MOVE_UP) then
					self:RefreshRepeatDelay(CONTROL_MOVE_UP)
					self:CursorUp()
					return
				elseif TheInput:IsControlPressed(CONTROL_MOVE_DOWN) then
					self:RefreshRepeatDelay(CONTROL_MOVE_DOWN)
					self:CursorDown()
					return
				end
			end

			local ignore_rstick = false
			if self.owner.components.playercontroller and
				self.owner.components.playercontroller.reticule and
				self.owner.components.playercontroller.reticule.twinstickmode
			then
				ignore_rstick = true
			elseif self.owner.components.strafer and self.owner.components.strafer:IsAiming() then
				ignore_rstick = true
			end

			if not ignore_rstick then
				if TheInput:IsControlPressed(CONTROL_INVENTORY_LEFT) then
					self:RefreshRepeatDelay(CONTROL_INVENTORY_LEFT)
					self:CursorLeft()
					return
				elseif TheInput:IsControlPressed(CONTROL_INVENTORY_RIGHT) then
					self:RefreshRepeatDelay(CONTROL_INVENTORY_RIGHT)
					self:CursorRight()
					return
				elseif TheInput:IsControlPressed(CONTROL_INVENTORY_UP) then
					self:RefreshRepeatDelay(CONTROL_INVENTORY_UP)
					self:CursorUp()
					return
				elseif TheInput:IsControlPressed(CONTROL_INVENTORY_DOWN) then
					self:RefreshRepeatDelay(CONTROL_INVENTORY_DOWN)
					self:CursorDown()
					return
				end
			end

			self.repeat_time = 0
			self.reps = 0
        end
    end
end

function Inv:OffsetCursor(offset, val, minval, maxval, slot_is_valid_fn)
    if val == nil then
        val = minval
    else
        local idx = val
        local start_idx = idx

        repeat
            idx = idx + offset

            if idx < minval then idx = maxval end
            if idx > maxval then idx = minval end

            if slot_is_valid_fn(idx) then
                val = idx
                break
            end

        until start_idx == idx
    end

    return val
end

function Inv:PinBarNav(select_pin)
	if select_pin ~= nil then
		self.actionstringtime = 0
		self.actionstring:Hide()
		self:SelectSlot(select_pin)
		return true
	end
end

function Inv:GetInventoryLists(same_container_only)
    if same_container_only then
        local lists = {self.current_list}

        if self.current_list == self.inv then
            table.insert(lists, self.equip)
        elseif self.current_list == self.equip then
            table.insert(lists, self.inv)
        end

        return lists
    else
        local lists = {self.inv, self.equip, self.backpackinv}
		for _, v in pairs(self.owner.HUD.controls.containers) do
            table.insert(lists, v.inv)
		end

        return lists
    end
end

function Inv:CursorNav(dir, same_container_only)
    ThePlayer.components.playercontroller:CancelDeployPlacement()

    if self:GetCursorItem() ~= nil then
        self.actionstringtime = CURSOR_STRING_DELAY
        self.actionstring:Show()
    end

	local _, current_list_first_slot = next(self.current_list)

    if self.active_slot == nil or not self.active_slot.inst:IsValid() or self.current_list == nil or current_list_first_slot == nil or not current_list_first_slot.inst:IsValid() then
        self.current_list = self.inv
        self:SelectDefaultSlot()
		return true
    end

    local lists = self:GetInventoryLists(same_container_only)
    local slot, list = self:GetClosestWidget(lists, self.active_slot:GetWorldPosition(), dir)
    if slot and list then
        self.current_list = list
        return self:SelectSlot(slot)
    end
end

function Inv:CursorLeft()
	if self.pin_nav and not self.owner.HUD.controls.craftingmenu.is_left_aligned then
		local k, slot = next(self.current_list or {})
		if slot == nil or not slot.inst:IsValid() then
			self.current_list = self.equip
		end
	end

    if self:CursorNav(Vector3(-1,0,0), true) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	elseif not self.open and not self.pin_nav and self.owner.HUD.controls.craftingmenu.is_left_aligned and self:PinBarNav(self.owner.HUD.controls.craftingmenu:InvNavToPin(self.active_slot, -1, 0)) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	elseif self.reps == 1 and (self.current_list == self.inv or self.current_list == self.equip or self.pin_nav) then
		self.current_list = self.equip[self.equipslotinfo[#self.equipslotinfo].slot] and self.equip or self.inv
	    self:SelectSlot(self.equip[self.equipslotinfo[#self.equipslotinfo].slot] or self.inv[#self.inv])
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    end
end

function Inv:CursorRight()
	if self.pin_nav and self.owner.HUD.controls.craftingmenu.is_left_aligned then
		local k, slot = next(self.current_list or {})
		if slot == nil or not slot.inst:IsValid() then
			self.current_list = self.inv
		end
	end

    if self:CursorNav(Vector3(1,0,0), true) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	elseif not self.open and not self.pin_nav and not self.owner.HUD.controls.craftingmenu.is_left_aligned and self:PinBarNav(self.owner.HUD.controls.craftingmenu:InvNavToPin(self.active_slot, 1, 0)) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
	elseif self.reps == 1 and (self.current_list == self.inv or self.current_list == self.equip or self.pin_nav) then
		self:SelectDefaultSlot()
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    end
end

function Inv:CursorUp()
	if self.pin_nav then
		self:PinBarNav(self.active_slot:FindPinUp())
    else
		if self:CursorNav(Vector3(0,1,0)) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		elseif not self.open and (self.current_list == self.inv or self.current_list == self.equip) then
			-- go into the pin bar if there are no other open containers above the inventory bar
			self:PinBarNav(self.owner.HUD.controls.craftingmenu:InvNavToPin(self.active_slot, 0, 1))
		end
    end
end

function Inv:CursorDown()
	local pin_nav = self.pin_nav
	if pin_nav then
		local next_pin = self.active_slot:FindPinDown()
		if next_pin then
			self:PinBarNav(next_pin)
		else
			pin_nav = false
			local k, slot = next(self.current_list or {})
			if slot == nil or not slot.inst:IsValid() then
				self.current_list = self.owner.HUD.controls.craftingmenu.is_left_aligned and self.inv or self.equip
			end
		end
    end
	
	if not pin_nav and self:CursorNav(Vector3(0,-1,0)) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
    end
end

function Inv:GetClosestWidget(lists, pos, dir)
    local closest = nil
    local closest_score = nil
    local closest_list = nil

	local x, y = pos.x, pos.y
	local dir_x, dir_y = dir.x, dir.y

    for kk, vv in pairs(lists) do
        for k,v in pairs(vv) do
            if v ~= self.active_slot then
				local vx, vy = v.inst.UITransform:GetWorldPosition()
				local local_dir_x, local_dir_y = vx-x, vy-y

				local dot = VecUtil_Dot(local_dir_x, local_dir_y, dir_x, dir_y)
                if dot > 0 then
					local score = local_dir_x * local_dir_x + local_dir_y * local_dir_y
	                if not closest or score < closest_score then
	                    closest = v
	                    closest_score = score
	                    closest_list = vv
	                end
				end
	        end
        end
    end

    return closest, closest_list
end

function Inv:GetCursorItem()
    return self.active_slot ~= nil and self.active_slot.tile ~= nil and self.active_slot.tile.item or nil
end

function Inv:GetCursorSlot()
    if self.active_slot ~= nil then
        return self.active_slot.num, self.active_slot.container
    end
end

function Inv:OnControl(control, down)
    if Inv._base.OnControl(self, control, down) then
        return true
    elseif not self.open then
        return
    end

    local was_force_single_drop = self.force_single_drop
    if was_force_single_drop and not TheInput:IsControlPressed(CONTROL_PUTSTACK) then
        self.force_single_drop = false
    end

    if down then
        return
    end

    local active_item = self.owner.replica.inventory:GetActiveItem()
    local inv_item = self:GetCursorItem()
    if inv_item ~= nil and inv_item.replica.inventoryitem == nil then
        inv_item = nil
    end

    if control == CONTROL_ACCEPT then
        if inv_item ~= nil and active_item == nil and
            (   (GetGameModeProperty("non_item_equips") and inv_item.replica.equippable ~= nil) or
                not inv_item.replica.inventoryitem:CanGoInContainer()
            ) then
            self.owner.replica.inventory:DropItemFromInvTile(inv_item)
            self:CloseControllerInventory()
            return true
        elseif self.active_slot ~= nil then
            self.active_slot:Click()
            return true
        end
    elseif control == CONTROL_PUTSTACK then
        if self.active_slot ~= nil then
            if not was_force_single_drop then
                self.active_slot:Click(true)
            end
            return true
        end
    elseif control == CONTROL_INVENTORY_DROP then
        if inv_item ~= nil and active_item == nil then
            if not was_force_single_drop and TheInput:IsControlPressed(CONTROL_PUTSTACK) then
                self.force_single_drop = true
            end
			self:SetAutopausedInternal(false)
			self.autopause_delay = .5
            self.owner.replica.inventory:DropItemFromInvTile(inv_item, self.force_single_drop)
            return true
        end
    elseif control == CONTROL_USE_ITEM_ON_ITEM then
        if inv_item ~= nil and active_item ~= nil then
			self:SetAutopausedInternal(false)
			self.autopause_delay = .5
            self.owner.replica.inventory:ControllerUseItemOnItemFromInvTile(inv_item, active_item)
            return true
        end
    end
end

function Inv:SetAutopausedInternal(pause)
	if not pause == self.autopaused then
		self.autopaused = not self.autopaused
		SetAutopaused(self.autopaused)
	end
end

function Inv:OpenControllerInventory()
    if not self.open then
        self.owner.HUD.controls:SetDark(true)
        --V2C: Don't set pause in multiplayer, all it does is change the
        --     audio settings, which we don't want to do now
        --SetPause(true, "inv")

		self:SetAutopausedInternal(true)

        self.open = true
        self.force_single_drop = false --reset the flag

		if self.pin_nav then
			self:CursorRight()
		end

        self:UpdateCursor()
        self:ScaleTo(self.base_scale,self.selected_scale,.2)

		for _, v in pairs(self.owner.HUD.controls.containers) do
            v:ScaleTo(self.base_scale,self.selected_scale,.2)
		end

        TheFrontEnd:LockFocus(true)
        self:SetFocus()
    end
end

function Inv:OnEnable()
    self:UpdateCursor()
end

function Inv:OnDisable()
    self.actionstring:Hide()
end

function Inv:CloseControllerInventory()
    if self.open then
        self.open = false
        --V2C: Don't set pause in multiplayer, all it does is change the
        --     audio settings, which we don't want to do now
        --SetPause(false)

		self:SetAutopausedInternal(false)

        self.owner.HUD.controls:SetDark(false)

        self.owner.replica.inventory:ReturnActiveItem()

        self:UpdateCursor()

        if self.active_slot ~= nil then
            self.active_slot:DeHighlight()
        end

        self:ScaleTo(self.selected_scale, self.base_scale, .1)

		for _, w in pairs(self.owner.HUD.controls.containers) do
            w:ScaleTo(self.selected_scale,self.base_scale, .1)
		end

        TheFrontEnd:LockFocus(false)
    end
end

function Inv:GetDescriptionString(item)
    if item == nil then
        return ""
    end
    local adjective = item:GetAdjective()
    return adjective ~= nil and (adjective.." "..item:GetDisplayName()) or item:GetDisplayName()
end

function Inv:SetTooltipColour(r, g, b, a)
   self.actionstringtitle:SetColour(r, g, b, a)
end

local function GetDropActionString(doer, item)
    return BufferedAction(doer, nil, ACTIONS.DROP, item, doer:GetPosition()):GetActionString()
end

function Inv:UpdateCursorText()
    local inv_item = self:GetCursorItem()
    local active_item = self.cursortile ~= nil and self.cursortile.item or nil
    if inv_item ~= nil and inv_item.replica.inventoryitem == nil then
        inv_item = nil
    end
    if active_item ~= nil and active_item.replica.inventoryitem == nil then
        active_item = nil
    end
    if active_item ~= nil or inv_item ~= nil then
        local controller_id = TheInput:GetControllerID()

        if inv_item ~= nil then
            local itemname = self:GetDescriptionString(inv_item)
            self.actionstringtitle:SetString(itemname)
            if inv_item:GetIsWet() then
                self:SetTooltipColour(unpack(WET_TEXT_COLOUR))
            else
                self:SetTooltipColour(unpack(NORMAL_TEXT_COLOUR))
            end
        elseif active_item ~= nil then
            local itemname = self:GetDescriptionString(active_item)
            self.actionstringtitle:SetString(itemname)
            if active_item:GetIsWet() then
                self:SetTooltipColour(unpack(WET_TEXT_COLOUR))
            else
                self:SetTooltipColour(unpack(NORMAL_TEXT_COLOUR))
            end
        end


        local is_equip_slot = self.active_slot and self.active_slot.equipslot
        local str = {}

        if not self.open then
            if inv_item ~= nil then
                table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE) .. " " .. STRINGS.UI.HUD.INSPECT)

                if not is_equip_slot then
                    if not inv_item.replica.inventoryitem:IsGrandOwner(self.owner) then
                        table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. STRINGS.UI.HUD.TAKE)
                    else
                        local scene_action = self.owner.components.playercontroller:GetItemUseAction(inv_item)
                        if scene_action ~= nil then
                            table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. scene_action:GetActionString())
                        end
                    end
                    local self_action = self.owner.components.playercontroller:GetItemSelfAction(inv_item)
                    if self_action ~= nil then
                        table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. self_action:GetActionString())
                    end
                else
                    local self_action = self.owner.components.playercontroller:GetItemSelfAction(inv_item)
                    if self_action ~= nil and self_action.action ~= ACTIONS.UNEQUIP then
                        table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. self_action:GetActionString())
                    end
                    if #self.inv > 0 and not (inv_item:HasTag("heavy") or GetGameModeProperty("non_item_equips")) then
                        table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.UI.HUD.UNEQUIP)
                    end
                end

                table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP) .. " " .. GetDropActionString(self.owner, inv_item))
            end
        else
            if is_equip_slot then
                --handle the quip slot stuff as a special case because not every item can go there
                if active_item ~= nil and active_item.replica.equippable ~= nil and active_item.replica.equippable:EquipSlot() == self.active_slot.equipslot and not active_item.replica.equippable:IsRestricted(self.owner) then
                    if inv_item and active_item then
                        table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HUD.SWAP)
                    elseif not inv_item and active_item then
                        table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HUD.EQUIP)
                    end
                elseif active_item == nil and inv_item ~= nil then
                    if not (GetGameModeProperty("non_item_equips") and inv_item.replica.equippable ~= nil) and
                        inv_item.replica.inventoryitem:CanGoInContainer() then
                        table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HUD.UNEQUIP)
                    else
                        table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. GetDropActionString(self.owner, inv_item))
                    end
                end
            else
                local can_take_active_item = active_item ~= nil and self.active_slot.container.CanTakeItemInSlot == nil or self.active_slot.container:CanTakeItemInSlot(active_item, self.active_slot.num)

                if active_item ~= nil and active_item.replica.stackable ~= nil and
                    ((inv_item ~= nil and inv_item.prefab == active_item.prefab and inv_item.skinname == active_item.skinname) or (inv_item == nil and can_take_active_item)) then
                    table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_PUTSTACK) .. " " .. STRINGS.UI.HUD.PUTONE)
                end

                if active_item == nil and inv_item ~= nil and inv_item.replica.stackable ~= nil and inv_item.replica.stackable:IsStack() then
                    table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_PUTSTACK) .. " " .. STRINGS.UI.HUD.GETHALF)
                end

                if inv_item ~= nil and active_item == nil then
                    table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HUD.SELECT)
                    table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP) .. " " .. GetDropActionString(self.owner, inv_item))
                elseif inv_item ~= nil and active_item ~= nil then
                    if inv_item.prefab == active_item.prefab and inv_item.skinname == active_item.skinname and active_item.replica.stackable ~= nil then
                        table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HUD.PUT)
                    elseif can_take_active_item then
                        table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HUD.SWAP)
                    else
                        table.insert(str, " ")
                    end
                elseif inv_item == nil and active_item ~= nil and can_take_active_item then
                    table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HUD.PUT)
                else
                    table.insert(str, " ")
                end
            end

            if active_item ~= nil and inv_item ~= nil then
                local use_action = self.owner.components.playercontroller:GetItemUseAction(active_item, inv_item)
                if use_action ~= nil then
                    table.insert(str, TheInput:GetLocalizedControl(controller_id, CONTROL_USE_ITEM_ON_ITEM) .. " " .. use_action:GetActionString())
                end
            end
        end

        local was_shown = self.actionstring.shown
        local old_string = self.actionstringbody:GetString()
        local new_string = table.concat(str, '\n')
        if old_string ~= new_string then
            self.actionstringbody:SetString(new_string)
            self.actionstringtime = CURSOR_STRING_DELAY
            self.actionstring:Show()
        end

        local w0, h0 = self.actionstringtitle:GetRegionSize()
        local w1, h1 = self.actionstringbody:GetRegionSize()

        local wmax = math.max(w0, w1)

        local dest_pos = self.active_slot:GetWorldPosition()

        local xscale, yscale, zscale = self.root:GetScale():Get()

        if self.active_slot.side_align_tip then
            -- in-game containers, chests, fridge
            self.actionstringtitle:SetPosition(wmax/2, h0/2)
            self.actionstringbody:SetPosition(wmax/2, -h1/2)

            dest_pos.x = dest_pos.x + self.active_slot.side_align_tip * xscale
        elseif self.active_slot.top_align_tip then
            -- main inventory
            self.actionstringtitle:SetPosition(0, h0/2 + h1)
            self.actionstringbody:SetPosition(0, h1/2)

            dest_pos.y = dest_pos.y + (self.active_slot.top_align_tip + TIP_YFUDGE) * yscale
        elseif self.active_slot.bottom_align_tip then
            
            self.actionstringtitle:SetPosition(0, -h0/2)
            self.actionstringbody:SetPosition(0, -(h1/2 + h0))

            dest_pos.y = dest_pos.y + (self.active_slot.bottom_align_tip + TIP_YFUDGE) * yscale
        else
            -- old default as fallback ?
            self.actionstringtitle:SetPosition(0, h0/2 + h1)
            self.actionstringbody:SetPosition(0, h1/2)

            dest_pos.y = dest_pos.y + (W/2 + TIP_YFUDGE) * yscale
        end

        -- print("self.active_slot:GetWorldPosition()", self.active_slot:GetWorldPosition())
        -- print("h0", h0)
        -- print("w0", w0)
        -- print("h1", h1)
        -- print("w1", h1)
        -- print("dest_pos", dest_pos)

        if dest_pos:DistSq(self.actionstring:GetPosition()) > 1 then
            self.actionstringtime = CURSOR_STRING_DELAY
            if was_shown then
                self.actionstring:MoveTo(self.actionstring:GetPosition(), dest_pos, .1)
            else
                self.actionstring:SetPosition(dest_pos)
                self.actionstring:Show()
            end
        end
    else
        self.actionstringbody:SetString("")
        self.actionstring:Hide()
    end
end

function Inv:SelectSlot(slot)
    if slot and slot ~= self.active_slot then
        if self.active_slot and self.active_slot ~= slot then
            self.active_slot:DeHighlight()
        end

		if self.pin_nav and not slot.in_pinbar then
			self.pin_nav = false
			self.owner.HUD.controls.craftingmenu:ClearFocus()
		elseif slot.in_pinbar then
			self.pin_nav = true
		end

        self.active_slot = slot
        return true
    end
end

function Inv:SelectDefaultSlot()
    self.current_list = self.inv[1] and self.inv or self.equip
	self:SelectSlot(self.inv[1] or self.equip[self.equipslotinfo[1].slot])
end

function Inv:UpdateCursor()
    if not TheInput:ControllerAttached() then
        self.actionstring:Hide()
        if self.cursor ~= nil then
            self.cursor:Hide()
        end

        if self.cursortile ~= nil then
            self.cursortile:Kill()
            self.cursortile = nil
        end
        return
    end

    if self.hovertile ~= nil then
        self.hovertile:Kill()
        self.hovertile = nil
    end

    if self.active_slot == nil then
        self:SelectDefaultSlot()
    end

    if self.active_slot ~= nil and self.cursortile ~= nil then
        self.cursortile:SetPosition(self.active_slot:GetWorldPosition())
    end

    if self.active_slot ~= nil then
        if self.cursor ~= nil then
            self.cursor:Kill()
        end
        self.cursor = self.root:AddChild(Image(HUD_ATLAS, "slot_select.tex"))

        if self.active_slot.tile ~= nil and self.active_slot.tile:HasSpoilage() then
            self.cursor:Show()
            self.active_slot.tile:AddChild(self.cursor)
            self.active_slot:Highlight()

            self.cursor:MoveToBack()
            self.active_slot.tile.spoilage:MoveToBack()
            self.active_slot.tile.bg:MoveToBack()
        elseif self.active_slot.hide_cursor then
			self.cursor:Hide()
            self.active_slot:Highlight()
		else
            self.cursor:Show()
            self.active_slot:AddChild(self.cursor)
            self.active_slot:Highlight()

            self.cursor:MoveToBack()
			if self.active_slot.bgimage then
	            self.active_slot.bgimage:MoveToBack()
			end
        end
    else
        self.cursor:Hide()
    end

    --if self.open then
    local active_item = self.owner.replica.inventory:GetActiveItem()
    if active_item ~= nil then
        if self.cursortile == nil or active_item ~= self.cursortile.item then
            if self.cursortile ~= nil then
                self.cursortile:Kill()
            end
            self.cursortile = self.root:AddChild(ItemTile(active_item))
            self.cursortile.isactivetile = true
            self.cursortile.image:SetScale(1.3)
            self.cursortile:SetScaleMode(SCALEMODE_PROPORTIONAL)
            self.cursortile:StartDrag()
            self.cursortile:SetPosition(self.active_slot:GetWorldPosition())
        end
    elseif self.cursortile ~= nil then
        self.cursortile:Kill()
        self.cursortile = nil
    end

    self:UpdateCursorText()
end

function Inv:Refresh(skipbackpack)
    local inventory = self.owner.replica.inventory
    local items = inventory:GetItems()
    local equips = inventory:GetEquips()
    local activeitem = inventory:GetActiveItem()

    for i, v in ipairs(self.inv) do
        local item = items[i]
        if item == nil then
            if v.tile ~= nil then
                v:SetTile(nil)
            end
        elseif v.tile == nil or v.tile.item ~= item then
            v:SetTile(ItemTile(item))
        else
            v.tile:Refresh()
        end
    end

    for k, v in pairs(self.equip) do
        local item = equips[k]
        if item == nil then
            if v.tile ~= nil then
                v:SetTile(nil)
            end
        elseif v.tile == nil or v.tile.item ~= item then
            v:SetTile(ItemTile(item))
        else
            v.tile:Refresh()
        end
    end

	if not skipbackpack then
		self:RefreshIntegratedContainer()
	end

    self:OnNewActiveItem(activeitem)
end

function Inv:RefreshIntegratedContainer()
    if #self.backpackinv > 0 then
		local inventory = self.owner.replica.inventory
        local overflow = inventory:GetOverflowContainer()
        if overflow ~= nil then
            for i, v in ipairs(self.backpackinv) do
                local item = overflow:GetItemInSlot(i)
                if item == nil then
                    if v.tile ~= nil then
                        v:SetTile(nil)
                    end
                elseif v.tile == nil or v.tile.item ~= item then
                    v:SetTile(ItemTile(item))
                else
                    v.tile:Refresh()
                end
            end
        end
    end
end

function Inv:OnPlacerChanged(placer_shown)
	if self.hovertile ~= nil then 
		if placer_shown then
			if self.hovertile.image ~= nil then
				self.hovertile.image:Hide() 
			end
			if self.hovertile.imagebg ~= nil then
				self.hovertile.imagebg:Hide() 
			end
		else
			if self.hovertile.image ~= nil then
				self.hovertile.image:Show() 
			end
			if self.hovertile.imagebg ~= nil then
				self.hovertile.imagebg:Show() 
			end
		end
	end
end

function Inv:Cancel()
    local inventory = self.owner.replica.inventory
    local active_item = inventory:GetActiveItem()
    if active_item ~= nil then
        inventory:ReturnActiveItem()
    end
end

function Inv:OnItemLose(slot)
    if slot then
        slot:SetTile(nil)
    end

    --self:UpdateCursor()
end

function Inv:OnBuild()
    if self.hovertile then
        self.hovertile:ScaleTo(3, 1, .5)
    end
end

function Inv:OnNewActiveItem(item)
    if TheInput:ControllerAttached() then
        if item == nil or self.owner.HUD.controls == nil then
            if self.cursortile ~= nil then
                self.cursortile:Kill()
                self.cursortile = nil
                self:UpdateCursorText()
            end
        elseif self.cursortile ~= nil and self.cursortile.item == item then
            self.cursortile:Refresh()
            self:UpdateCursorText()
        elseif self.active_slot ~= nil then
            if self.cursortile ~= nil then
                self.cursortile:Kill()
            end
            self.cursortile = self.root:AddChild(ItemTile(item))
            self.cursortile.isactivetile = true
            self.cursortile.image:SetScale(1.3)
            self.cursortile:SetScaleMode(SCALEMODE_PROPORTIONAL)
            self.cursortile:StartDrag()
            self.cursortile:SetPosition(self.active_slot:GetWorldPosition())
            self:UpdateCursorText()
        end
    elseif item == nil or self.owner.HUD.controls == nil then
        if self.hovertile ~= nil then
            self.hovertile:Kill()
            self.hovertile = nil
        end
    elseif self.hovertile ~= nil and self.hovertile.item == item then
        self.hovertile:Refresh()
    else
        if self.hovertile ~= nil then
            self.hovertile:Kill()
        end
        self.hovertile = self.owner.HUD.controls.mousefollow:AddChild(ItemTile(item))
        self.hovertile.isactivetile = true
        self.hovertile:StartDrag()
    end
end

function Inv:OnItemGet(item, slot, source_pos, ignore_stacksize_anim)
    if slot ~= nil then
        local tile = ItemTile(item)
        slot:SetTile(tile)
        tile:Hide()
        tile.ignore_stacksize_anim = ignore_stacksize_anim

        if source_pos ~= nil then
            local dest_pos = slot:GetWorldPosition()
            local im = Image(item.replica.inventoryitem:GetAtlas(), item.replica.inventoryitem:GetImage())
            if GetGameModeProperty("icons_use_cc") then
                im:SetEffect("shaders/ui_cc.ksh")
            end
            if item.inv_image_bg ~= nil then
                local bg = Image(item.inv_image_bg.atlas, item.inv_image_bg.image)
                bg:AddChild(im)
                im = bg
                if GetGameModeProperty("icons_use_cc") then
                    im:SetEffect("shaders/ui_cc.ksh")
                end
            end
            im:MoveTo(Vector3(TheSim:GetScreenPos(source_pos:Get())), dest_pos, .3, function() tile:Show() tile:ScaleTo(2, 1, .25) im:Kill() end)
        else
            tile:Show()
            --tile:ScaleTo(2, 1, .25)
        end
    end
end

function Inv:OnItemEquip(item, slot)
    if slot ~= nil and self.equip[slot] ~= nil then
        self.equip[slot]:SetTile(ItemTile(item))
    end
end

function Inv:OnItemUnequip(item, slot)
    if slot ~= nil and self.equip[slot] ~= nil then
        self.equip[slot]:SetTile(nil)
    end
end

--Extended to autoposition world reset timer

function Inv:UpdatePosition()
    self.autoanchor:SetPosition(0, self:IsVisible() and (self.root:GetPosition().y - 10) or 0)
end

function Inv:OnShow()
    self:UpdatePosition()
    if self.hovertile ~= nil then
        self.hovertile:Show()
    end
end

function Inv:OnHide()
    self:UpdatePosition()
    if self.hovertile ~= nil then
        self.hovertile:Hide()
    end
end

return Inv
