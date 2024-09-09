local EquipSlot = require("equipslotutil")

local function OnEquip(inst, data)
    inst.Network:SetPlayerEquip(EquipSlot.ToID(data.eslot), data.item:GetSkinName() or data.item.prefab)
end

local function OnUnequip(inst, data)
    inst.Network:SetPlayerEquip(EquipSlot.ToID(data.eslot), "")
end

local function OnSkillSelectionUpdated(inst, data)
    local skilltreeupdater = inst.components.skilltreeupdater
    if skilltreeupdater == nil then
        return
    end

    inst.Network:SetPlayerSkillSelection(skilltreeupdater:GetPlayerSkillSelection())
end

local PlayerInspectable = Class(function(self, inst)
    self.inst = inst

    inst:ListenForEvent("equip", OnEquip)
    inst:ListenForEvent("unequip", OnUnequip)
    inst:ListenForEvent("onactivateskill_server", OnSkillSelectionUpdated)
    inst:ListenForEvent("ondeactivateskill_server", OnSkillSelectionUpdated)
    inst:ListenForEvent("onsetskillselection_server", OnSkillSelectionUpdated)
end)

return PlayerInspectable
