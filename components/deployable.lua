--Update inventoryitem_replica constructor if any more properties are added

local function onmode(self, mode)
    if self.inst.replica.inventoryitem ~= nil then
        self.inst.replica.inventoryitem:SetDeployMode(mode)
    end
end

local function onspacing(self, spacing)
    if self.inst.replica.inventoryitem ~= nil then
        self.inst.replica.inventoryitem:SetDeploySpacing(spacing)
    end
end

local function onusegridplacer(self, usegridplacer)
    if self.inst.replica.inventoryitem ~= nil then
        self.inst.replica.inventoryitem:SetUseGridPlacer(usegridplacer)
    end
end

local Deployable = Class(function(self, inst)
    self.inst = inst

    self.mode = DEPLOYMODE.DEFAULT
    self.spacing = DEPLOYSPACING.DEFAULT
    self.usegridplacer = false

    self.ondeploy = nil
end,
nil,
{
    mode = onmode,
    spacing = onspacing,
    usegridplacer = onusegridplacer,
})

function Deployable:SetDeployMode(mode)
    self.mode = mode
end

function Deployable:SetDeploySpacing(spacing)
    self.spacing = spacing
end

function Deployable:SetUseGridPlacer(usegridplacer)
    self.usegridplacer = usegridplacer
end

function Deployable:DeploySpacingRadius()
    return DEPLOYSPACING_RADIUS[self.spacing]
end

function Deployable:CanDeploy(pt, mouseover)
    if self.mode == DEPLOYMODE.ANYWHERE then
        return TheWorld.Map:IsPassableAtPoint(pt:Get())
    elseif self.mode == DEPLOYMODE.TURF then
        return TheWorld.Map:CanPlaceTurfAtPoint(pt:Get())
    elseif self.mode == DEPLOYMODE.PLANT then
        return TheWorld.Map:CanDeployPlantAtPoint(pt, self.inst)
    elseif self.mode == DEPLOYMODE.WALL then
        return TheWorld.Map:CanDeployWallAtPoint(pt, self.inst)
    elseif self.mode == DEPLOYMODE.DEFAULT then
        return TheWorld.Map:CanDeployAtPoint(pt, self.inst, mouseover)
    end
end

function Deployable:Deploy(pt, deployer, rot)
    if not self:CanDeploy(pt) then
        return
    end
    local prefab = self.inst.prefab
    if self.ondeploy ~= nil then
        self.ondeploy(self.inst, pt, deployer, rot or 0)
    end
    -- self.inst is removed during ondeploy
    deployer:PushEvent("deployitem", { prefab = prefab })
    return true
end

return Deployable
