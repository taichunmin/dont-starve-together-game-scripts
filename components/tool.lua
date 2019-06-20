local function PercentChanged(inst, data)
    if data.percent ~= nil and
        data.percent <= 0 and
        inst.components.rechargeable == nil and
        inst.components.inventoryitem ~= nil and
        inst.components.inventoryitem.owner ~= nil then
        inst.components.inventoryitem.owner:PushEvent("toolbroke", { tool = inst })
    end
end

local Tool = Class(function(self, inst)
    self.inst = inst
    self.actions = {}
    inst:ListenForEvent("percentusedchange", PercentChanged)

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("tool")
end)

function Tool:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("percentusedchange", PercentChanged)
    self.inst:RemoveTag("tool")
    for k, v in pairs(self.actions) do
        self.inst:RemoveTag(k.id.."_tool")
    end
end

function Tool:GetEffectiveness(action)
    return self.actions[action] or 0
end

function Tool:SetAction(action, effectiveness)
    assert(TOOLACTIONS[action.id], "invalid tool action")
    self.actions[action] = effectiveness or 1
    self.inst:AddTag(action.id.."_tool")
end

function Tool:CanDoAction(action)
    return self.actions[action] ~= nil
end

return Tool
