local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"

local GetModuleDefinitionFromNetID = require("wx78_moduledefs").GetModuleDefinitionFromNetID

-------------------------------------------------------------------------------------------------------

local function chip_settint(obj, r, g, b, a)
    obj:GetAnimState():SetMultColour(r, g, b, a)
end

local UpgradeModulesDisplay = Class(Widget, function(self, owner, reversed)
    Widget._ctor(self, "UpgradeModulesDisplay")
    self:UpdateWhilePaused(false)
    self.owner = owner

    --self:SetHAnchor(ANCHOR_RIGHT)
    --self:SetVAnchor(ANCHOR_TOP)
    self.energy_level = TUNING.WX78_MAXELECTRICCHARGE
    self.slots_in_use = 0

    local scale = 0.7
    if IsGameInstance(Instances.Player2) then
        self.reversed = true
        self:SetScale(-scale, scale, scale)
    else
        self.reversed = false
        self:SetScale(scale, scale, scale)
    end

    self.battery_frame = self:AddChild(UIAnim())
    self.battery_frame:GetAnimState():SetBank("status_wx")
    self.battery_frame:GetAnimState():SetBuild("status_wx")
    self.battery_frame:GetAnimState():PlayAnimation("frame")
    self.battery_frame:GetAnimState():AnimateWhilePaused(false)

    self.energy_backing = self:AddChild(UIAnim())
    self.energy_backing:GetAnimState():SetBank("status_wx")
    self.energy_backing:GetAnimState():SetBuild("status_wx")
    self.energy_backing:GetAnimState():PlayAnimation("energy3")
    self.energy_backing:GetAnimState():AnimateWhilePaused(false)

    self.energy_blinking = self:AddChild(UIAnim())
    self.energy_blinking:GetAnimState():SetBank("status_wx")
    self.energy_blinking:GetAnimState():SetBuild("status_wx")
    self.energy_blinking:GetAnimState():PlayAnimation("energy2")
    self.energy_blinking:GetAnimState():AnimateWhilePaused(false)

    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("status_wx")
    self.anim:GetAnimState():SetBuild("status_wx")
    self.anim:GetAnimState():PlayAnimation("energy1")
    self.anim:GetAnimState():AnimateWhilePaused(false)

    self.chip_objectpool = {}
    for i = 1, 6 do
        local chip_object = self:AddChild(UIAnim())
        chip_object:GetAnimState():SetBank("status_wx")
        chip_object:GetAnimState():SetBuild("status_wx")
        chip_object:GetAnimState():AnimateWhilePaused(false)

        chip_object:GetAnimState():Hide("plug_on")
        chip_object._power_hidden = true

        chip_object:MoveToBack()
        chip_object:Hide()

        table.insert(self.chip_objectpool, chip_object)
    end
    self.chip_poolindex = 1
end)

-- Charge Displaying -----------------------------------------------------------

function UpgradeModulesDisplay:UpdateChipCharges(plugging_in)
    if self.chip_poolindex <= 1 then
        return
    end

    local charge = self.energy_level

    for i = 1, self.chip_poolindex - 1 do
        local chip = self.chip_objectpool[i]

        charge = charge - chip._used_modslots

        if charge < 0 and not chip._power_hidden then
            if not plugging_in then
                chip:GetAnimState():PlayAnimation((self.reversed and "chip_off_reverse") or "chip_off")
                chip:HookCallback("animover", function(chip_ui_inst)
                    chip:GetAnimState():Hide("plug_on")
                    chip:UnhookCallback("animover")
                end)
            else
                chip:GetAnimState():Hide("plug_on")
            end
            chip._power_hidden = true

            TheFrontEnd:GetSound():PlaySound("WX_rework/tube/HUD_off")

        elseif charge >= 0 and chip._power_hidden then
            -- In case we changed charge before the power off animation finished.
            chip:UnhookCallback("animover")

            chip:GetAnimState():Show("plug_on")
            if not plugging_in then
                chip:GetAnimState():PlayAnimation((self.reversed and "chip_on_reverse") or "chip_on")
            end
            chip._power_hidden = false

            TheFrontEnd:GetSound():PlaySound("WX_rework/tube/HUD_on")

        end
    end
end

--------------------------------------------------------------------------------

function UpgradeModulesDisplay:UpdateEnergyLevel(new_level, old_level)
    self.energy_level = new_level

    for i = 1, TUNING.WX78_MAXELECTRICCHARGE do
        local slotn = "slot"..tostring(i)

        if i > new_level then
            self.anim:GetAnimState():Hide(slotn)
        else
            self.anim:GetAnimState():Show(slotn)
        end
        
        if i == new_level + 1 then
            self.energy_blinking:GetAnimState():Show(slotn)
        else
            self.energy_blinking:GetAnimState():Hide(slotn)
        end
    end

    -- Change which level our yellow "charging" UI is at.
    if self.energy_blinking._flicker_task ~= nil then
        self.energy_blinking._flicker_task:Cancel()
        self.energy_blinking._flicker_task = nil
    end
    if new_level < TUNING.WX78_MAXELECTRICCHARGE then
        self.energy_blinking._flicker_alternator = false
        self.energy_blinking._flicker_task = self.inst:DoSimPeriodicTask(
            25*FRAMES,
            function(ui_inst)
                if self.energy_blinking._flicker_alternator then
                    self.energy_blinking:GetAnimState():PlayAnimation("energy2")
                else
                    self.energy_blinking:GetAnimState():PlayAnimation("energy2b")
                end
                self.energy_blinking._flicker_alternator = not self.energy_blinking._flicker_alternator
            end,
            10*FRAMES
        )
    end

    if new_level > old_level then
        TheFrontEnd:GetSound():PlaySound("WX_rework/charge/up")
    elseif new_level < old_level then
        TheFrontEnd:GetSound():PlaySound("WX_rework/charge/down")
    end

    self:UpdateChipCharges(false)
end

function UpgradeModulesDisplay:OnModuleAdded(moduledefinition_index)
    local module_def = GetModuleDefinitionFromNetID(moduledefinition_index)
    if module_def == nil then
        return
    end

    local modname = module_def.name
    local modslots = module_def.slots

    local new_chip = self.chip_objectpool[self.chip_poolindex]
    self.chip_poolindex = self.chip_poolindex + 1

    new_chip:GetAnimState():PlayAnimation((self.reversed and "plug_reverse") or "plug")
    new_chip:GetAnimState():PushAnimation((self.reversed and "chip_idle_reverse") or "chip_idle")

    new_chip:GetAnimState():OverrideSymbol("movespeed2_chip", "status_wx", modname.."_chip")

    new_chip._used_modslots = modslots

    local slot_distance_from_bottom = self.slots_in_use + (modslots - 1) * 0.5
    local y_pos = (slot_distance_from_bottom * 20) - 50
    new_chip:SetPosition(0, y_pos)

    new_chip:Show()

    self.slots_in_use = self.slots_in_use + modslots
end

function UpgradeModulesDisplay:OnModulesDirty(modules_table)
    local first = true
    for i, module_index in ipairs(modules_table) do
        if module_index ~= 0 and i == self.chip_poolindex then
            self:OnModuleAdded(module_index)

            if first then
                TheFrontEnd:GetSound():PlaySound("WX_rework/tube/HUD_in")
                first = false
            end
        elseif module_index == 0 and i == (self.chip_poolindex - 1) then
            self:PopOneModule()

            if first then
                TheFrontEnd:GetSound():PlaySound("WX_rework/tube/HUD_out")
                first = false
            end
        end
    end

    self:UpdateChipCharges(true)
end

function UpgradeModulesDisplay:PopOneModule()
    local falling_chip = self.chip_objectpool[self.chip_poolindex - 1]

    self.chip_poolindex = self.chip_poolindex - 1
    self.slots_in_use = self.slots_in_use - falling_chip._used_modslots

    falling_chip:HookCallback("animover", function(ui_inst)
        falling_chip:GetAnimState():Hide("plug_on")
        falling_chip._power_hidden = true
        falling_chip:Hide()
        falling_chip:UnhookCallback("animover")
    end)

    falling_chip:GetAnimState():PlayAnimation((self.reversed and "chip_fall_reverse") or "chip_fall")
end

function UpgradeModulesDisplay:PopAllModules()
    if self.chip_poolindex > 1 then
        TheFrontEnd:GetSound():PlaySound("WX_rework/tube/HUD_out")

        while self.chip_poolindex > 1 do
            self.chip_poolindex = self.chip_poolindex - 1

            local falling_chip = self.chip_objectpool[self.chip_poolindex]
            falling_chip:HookCallback("animover", function(ui_inst)
                falling_chip:GetAnimState():Hide("plug_on")
                falling_chip._power_hidden = true
                falling_chip:Hide()
                falling_chip:UnhookCallback("animover")
            end)

            falling_chip:GetAnimState():PlayAnimation((self.reversed and "chip_fall_reverse") or "chip_fall")
        end
    end

    self.slots_in_use = 0
end

return UpgradeModulesDisplay
