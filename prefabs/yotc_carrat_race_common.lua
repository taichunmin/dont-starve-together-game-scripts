local PLACER_RING_SCALE = 1.38

local lightcolors =
{
	black = Vector3(205 / 255, 205 / 255, 195 / 255),
	blue = Vector3(150 / 255, 210 / 255, 220 / 255),
	brown = Vector3(215 / 255, 155 / 255, 95 / 255),
	green = Vector3(160 / 255, 200 / 255, 160 / 255), -- Also used by default color finish line
	pink = Vector3(245 / 255, 105 / 255, 138 / 255),
	purple = Vector3(220 / 255, 164 / 255, 240 / 255),
	white = Vector3(215 / 255, 218 / 255, 240 / 255),
	yellow = Vector3(222 / 255, 212 / 255, 100 / 255),

	-- There are no red color swaps -- red is only used for default color checkpoints
	red = Vector3(236 / 255, 115 / 255, 125 / 255),
}

----------------------
-- GetLightColor returns RGB values for use with light sources corresponding to color swaps of structures

local function GetLightColor(col)
	return col == nil and lightcolors.white or lightcolors[col] ~= nil and lightcolors[col] or lightcolors.white
end

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

    inst.AnimState:SetBank("winona_battery_placement")
    inst.AnimState:SetBuild("winona_battery_placement")
    inst.AnimState:PlayAnimation("idle_small")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(PLACER_RING_SCALE, PLACER_RING_SCALE)

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

local function CreatePlacerRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_spotlight_placement")
    inst.AnimState:SetBuild("winona_spotlight_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(PLACER_RING_SCALE, PLACER_RING_SCALE)

    return inst
end

local function PostInit_AddPlacerRing(inst, deployhelper_key)
	-- inst.deployhelper_key = "yotc_carrat_race_deploy_rings"
	inst.deployhelper_key = deployhelper_key

    local placer_ring = CreatePlacerRing()
    placer_ring.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(placer_ring)
end

-----------------
-- Adds the carpet and the PlacerRing

local function CreatePlacerRug()
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

	inst.AnimState:SetBank("carrat_rug")
	inst.AnimState:SetBuild("yotc_carrat_rug")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
	inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetSortOrder(1)
	return inst
end

local function PostInit_AddCarpetAndPlacerRing(inst, deployhelper_key)
	PostInit_AddPlacerRing(inst, deployhelper_key)

	local rug = CreatePlacerRug()
	rug.entity:SetParent(inst.entity)
	inst.components.placer:LinkEntity(rug)
end

return
{
	AddDeployHelper = AddDeployHelper,
	PlacerPostInit_AddPlacerRing = PostInit_AddPlacerRing,
	PlacerPostInit_AddCarpetAndPlacerRing = PostInit_AddCarpetAndPlacerRing,
	GetLightColor = GetLightColor,
	deployable_data = deployable_data,
}
