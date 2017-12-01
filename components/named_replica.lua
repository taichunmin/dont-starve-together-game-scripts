local function OnNameDirty(inst)
    local name = inst.replica.named._name:value()
    inst.name = name ~= "" and name or STRINGS.NAMES[string.upper(inst.prefab)]
end

local Named = Class(function(self, inst)
    self.inst = inst

    self._name = net_string(inst.GUID, "named._name", "namedirty")

    if not TheWorld.ismastersim then
        inst:ListenForEvent("namedirty", OnNameDirty)
    end
end)

function Named:SetName(name)
    if TheWorld.ismastersim then
        self._name:set(name)
    end
end

return Named