local PLACER_RING_SCALE = 2
local HELPER_RING_SCALE = 1.38

----------------------
-- DeployHelper is the ring that shows up on other objects that match the filtering

local function DeployHelperRing_OnUpdate(helperinst)
	helperinst.parent.highlited = nil

	if not helperinst.placerinst:IsValid() then
		helperinst.components.updatelooper:RemoveOnUpdateFn(DeployHelperRing_OnUpdate)
		helperinst.AnimState:SetAddColour(0, 0, 0, 0)
	elseif helperinst:IsNear(helperinst.placerinst, TUNING.YOTC_RACER_CHECKPOINT_FIND_DIST) then
        if TheWorld.Map:GetPlatformAtPoint(helperinst.Transform:GetWorldPosition()) == TheWorld.Map:GetPlatformAtPoint(helperinst.placerinst.Transform:GetWorldPosition()) then
			helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())
			helperinst.parent.highlited = true
		else
			helperinst.AnimState:SetAddColour(0, 0, 0, 0)
		end
	else
		helperinst.AnimState:SetAddColour(0, 0, 0, 0)
	end
end

local function CreateDeployHelperRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("firefighter_placement")
    inst.AnimState:SetBuild("firefighter_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(2, 2)

    return inst
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
	if enabled then
		if inst.helper == nil and not inst:HasTag("burnt") then
			inst.helper = CreateDeployHelperRing()
			inst.helper.parent = inst
			inst.helper.entity:SetParent(inst.entity)
			if placerinst ~= nil then
				inst.helper:AddComponent("updatelooper")
				inst.helper.components.updatelooper:AddOnUpdateFn(DeployHelperRing_OnUpdate)
				inst.helper.placerinst = placerinst
				DeployHelperRing_OnUpdate(inst.helper)
			end
		end
	elseif inst.helper ~= nil then
		inst.helper:Remove()
		inst.helper = nil
	end
end

local function OnStartHelper(inst, recipename, placerinst)
	if inst.helper ~= nil then
		if inst.helper.placerinst ~= nil and inst.helper.placerinst ~= placerinst then
			inst.helper:Remove()
			inst.helper = nil
			inst.components.deployhelper:StopHelper()
		elseif placerinst.components.placer.mouse_blocked then
			inst.helper:Hide()
		else
			inst.helper:Show()
		end
	end
end

local function AddDeployHelper(inst, keyfilters)
	if not TheNet:IsDedicated() then
		inst:AddComponent("deployhelper")
		for _,v in pairs(keyfilters) do
			inst.components.deployhelper:AddKeyFilter(v)
		end
		inst.components.deployhelper.onenablehelper = OnEnableHelper
		inst.components.deployhelper.onstarthelper = OnStartHelper
    end
end

local deployable_data =
{
	deploymode = DEPLOYMODE.CUSTOM,
	custom_candeploy_fn = function(inst, pt, mouseover, deployer)
		local x, y, z = pt:Get()
		return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false)
	end,
}

-----------------
-- PlacerRing is the object that shows up on the object being deployed

local function CreatePlacerRing(ringdata)
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank(ringdata.bank)
    inst.AnimState:SetBuild(ringdata.build)
    inst.AnimState:PlayAnimation(ringdata.anim)
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.AnimState:SetScale(ringdata.scale, ringdata.scale)

    return inst
end

local function AddPlacerRing(inst, ringdata, deployhelper_key)
	-- inst.deployhelper_key = "yotc_carrat_race_deploy_rings"
	inst.deployhelper_key = deployhelper_key

    local placer_ring = CreatePlacerRing(ringdata)
    placer_ring.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer_ring)
end

return
{
	AddDeployHelper = AddDeployHelper,
	AddPlacerRing = AddPlacerRing,
	deployable_data = deployable_data,
}
