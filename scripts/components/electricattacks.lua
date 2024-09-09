local SourceModifierList = require("util/sourcemodifierlist")

local ElectricAttacks = Class(function(self, inst)
    self.inst = inst
    self._sources = SourceModifierList(inst, false, SourceModifierList.boolean)
end)

function ElectricAttacks:AddSource(source)
    self._sources:SetModifier(source, true)
end

function ElectricAttacks:RemoveSource(source)
    self._sources:RemoveModifier(source)
    if not self._sources:Get() then
        self.inst:RemoveComponent("electricattacks")
    end
end

return ElectricAttacks
