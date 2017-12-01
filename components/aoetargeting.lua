local function OnEnabledDirty(inst)
    local self = inst.components.aoetargeting
    if not self.enabled:value() then
        self:StopTargeting()
    end
end

local AOETargeting = Class(function(self, inst)
    self.inst = inst
    self.reticule =
    {
        ease = false,
        smoothing = 6.66,
        targetfn = nil,
        reticuleprefab = "reticule",
        validcolour = { 204 / 255, 131 / 255, 57 / 255, .3 },
        invalidcolour = { 1, 0, 0, .3 },
        mouseenabled = false,
        pingprefab = nil,
    }
    self.targetprefab = nil
    self.alwaysvalid = false
    self.range = 8

    self.enabled = net_bool(inst.GUID, "aoetargeting.enabled", "enableddirty")
    self.enabled:set(true)
    if not TheWorld.ismastersim then
        inst:ListenForEvent("enableddirty", OnEnabledDirty)
    end
end)

function AOETargeting:IsEnabled()
    return self.enabled:value()
end

function AOETargeting:SetEnabled(enabled)
    if TheWorld.ismastersim then
        self.enabled:set(enabled)
        OnEnabledDirty(self.inst)
    end
end

function AOETargeting:SetTargetFX(prefab)
    self.targetprefab = prefab
end

function AOETargeting:SetAlwaysValid(val)
    self.alwaysvalid = val ~= false
end

function AOETargeting:SetRange(range)
    self.range = range
end

function AOETargeting:GetRange()
    return self.range
end

local function RefreshReticule(inst)
    local owner = ThePlayer
    if owner ~= nil then
        local inventoryitem = inst.replica.inventoryitem
        if inventoryitem ~= nil and inventoryitem:IsHeldBy(owner) and owner.components.playercontroller ~= nil then
            owner.components.playercontroller:RefreshReticule()
        end
    end
end

function AOETargeting:StartTargeting()
    if self.inst.components.reticule == nil then
        self.inst:AddComponent("reticule")
        for k, v in pairs(self.reticule) do
            self.inst.components.reticule[k] = v
        end
        RefreshReticule(self.inst)
    end
end

function AOETargeting:StopTargeting()
    if self.inst.components.reticule ~= nil then
        self.inst:RemoveComponent("reticule")
        RefreshReticule(self.inst)
    end
end

return AOETargeting
