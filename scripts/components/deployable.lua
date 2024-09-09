--Update inventoryitem_replica constructor if any more properties are added

local function onmode(self, mode)
	local inventoryitem = self.inst.replica.inventoryitem
	if inventoryitem then
		inventoryitem:SetDeployMode(mode)
    end
end

local function onspacing(self, spacing)
	local inventoryitem = self.inst.replica.inventoryitem
	if inventoryitem then
		inventoryitem:SetDeploySpacing(spacing)
    end
end

local function onrestrictedtag(self, restrictedtag)
	local inventoryitem = self.inst.replica.inventoryitem
	if inventoryitem then
		inventoryitem:SetDeployRestrictedTag(restrictedtag)
    end
end

local function onusegridplacer(self, usegridplacer)
	local inventoryitem = self.inst.replica.inventoryitem
	if inventoryitem then
		inventoryitem:SetUseGridPlacer(usegridplacer)
    end
end

local Deployable = Class(function(self, inst)
    self.inst = inst

    self.mode = DEPLOYMODE.DEFAULT
    self.spacing = DEPLOYSPACING.DEFAULT
    --self.restrictedtag = nil --only entities with this tag can deploy
	--self.usegridplacer = false

    self.ondeploy = nil

    -- keep_in_inventory_on_deploy = nil

	--self.deploytoss_symbol_override = nil

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
	self.inst:RemoveTag("deployable")
end

function Deployable:SetDeployMode(mode)
    self.mode = mode
end

function Deployable:SetDeploySpacing(spacing)
    self.spacing = spacing
end

function Deployable:SetUseGridPlacer(usegridplacer)
	self.usegridplacer = usegridplacer or nil
end

function Deployable:DeploySpacingRadius()
    return DEPLOYSPACING_RADIUS[self.spacing]
end

--For deploy toss, we need to override symbols during the deploytoss_pre anim
function Deployable:SetDeployTossSymbolOverride(data)
	self.deploytoss_symbol_override = data
end

function Deployable:IsDeployable(deployer)
	if self.restrictedtag and self.restrictedtag:len() > 0 and not (deployer and deployer:HasTag(self.restrictedtag)) then
		return false
	end
	local rider = deployer and deployer.components.rider or nil
	if rider and rider:IsRiding() then
		--can only deploy tossables while mounted
		return self.inst.components.complexprojectile ~= nil
	end
	return true
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
