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

local function onrestrictedtag(self, restrictedtag)
    if self.inst.replica.inventoryitem ~= nil then
        self.inst.replica.inventoryitem:SetDeployRestrictedTag(restrictedtag)
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
    --self.restrictedtag = nil --only entities with this tag can deploy
    self.usegridplacer = false

    self.ondeploy = nil

    -- keep_in_inventory_on_deploy = nil

    self.inst:AddTag("deployable")
end,
nil,
{
    mode = onmode,
    spacing = onspacing,
    restrictedtag = onrestrictedtag,
    usegridplacer = onusegridplacer,
})

function Deployable:OnRemoveFromEntity()
    local inventoryitem = self.inst.replica.inventoryitem
    if inventoryitem ~= nil then
        inventoryitem:SetDeployMode(DEPLOYMODE.NONE)
        inventoryitem:SetDeployRestrictedTag(nil)
    end
end

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

function Deployable:IsDeployable(deployer)
    return self.restrictedtag == nil
        or self.restrictedtag:len() <= 0
        or (deployer ~= nil and deployer:HasTag(self.restrictedtag))
end

function Deployable:CanDeploy(pt, mouseover, deployer, rot)
    if not self:IsDeployable(deployer) then
        return false
    elseif self.mode == DEPLOYMODE.ANYWHERE then
        local x,y,z = pt:Get()
        return TheWorld.Map:IsPassableAtPointWithPlatformRadiusBias(x,y,z,false,false,TUNING.BOAT.NO_BUILD_BORDER_RADIUS,true)
    elseif self.mode == DEPLOYMODE.TURF then
        return TheWorld.Map:CanPlaceTurfAtPoint(pt:Get())
    elseif self.mode == DEPLOYMODE.PLANT then
        return TheWorld.Map:CanDeployPlantAtPoint(pt, self.inst)
    elseif self.mode == DEPLOYMODE.WALL then
        return TheWorld.Map:CanDeployWallAtPoint(pt, self.inst)
    elseif self.mode == DEPLOYMODE.DEFAULT then
        return TheWorld.Map:CanDeployAtPoint(pt, self.inst, mouseover)
    elseif self.mode == DEPLOYMODE.WATER then
        return TheWorld.Map:CanDeployAtPointInWater(pt, self.inst, mouseover,
        {
            land = 0.2, boat = 0.2, radius = self:DeploySpacingRadius(),
        })
    elseif self.mode == DEPLOYMODE.CUSTOM then
        if self.inst._custom_candeploy_fn ~= nil then
            return self.inst._custom_candeploy_fn(self.inst, pt, mouseover, deployer, rot)
        else -- use old DEPLOYMODE.MAST logic
            return TheWorld.Map:CanDeployMastAtPoint(pt, self.inst, mouseover)
        end
    end
end

function Deployable:Deploy(pt, deployer, rot)
    if not self:CanDeploy(pt, nil, deployer, rot) then
        return
    end
    local isplant = self.inst:HasTag("deployedplant")
    if self.ondeploy ~= nil then
        self.ondeploy(self.inst, pt, deployer, rot or 0)
    end
    -- self.inst is removed during ondeploy
    deployer:PushEvent("deployitem", { prefab = self.inst.prefab })
    if isplant then
        TheWorld:PushEvent("itemplanted", { doer = deployer, pos = pt }) --this event is pushed in other places too
    end
    return true
end

return Deployable
