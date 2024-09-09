require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/farm_plow.zip"),
    Asset("ANIM", "anim/farm_soil.zip"),
}

local assets_item =
{
    Asset("ANIM", "anim/farm_plow.zip"),
}

local prefabs =
{
    "farm_soil_debris",
    "farm_soil",
	"dirt_puff",
}

local prefabs_item =
{
	"farm_plow",
	"farm_plow_item_placer",
	"tile_outline",
}

local function onhammered(inst)
	local x, y, z = inst.Transform:GetWorldPosition()

	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(x, y, z)

	if inst.deploy_item_save_record ~= nil then
        local item = SpawnSaveRecord(inst.deploy_item_save_record)
		item.Transform:SetPosition(x, y, z)
	end

    inst:Remove()
end

local function item_foldup_finished(inst)
	inst:RemoveEventCallback("animqueueover", item_foldup_finished)
	inst.AnimState:PlayAnimation("idle_packed")
	inst.components.inventoryitem.canbepickedup = true
end

local function Finished(inst, force_fx)
	local x, y, z = inst.Transform:GetWorldPosition()
	if inst.deploy_item_save_record ~= nil then
        local item = SpawnSaveRecord(inst.deploy_item_save_record)
		item.Transform:SetPosition(x, y, z)
		item.components.inventoryitem.canbepickedup = false

		item.AnimState:PlayAnimation("collapse", false)
		item:ListenForEvent("animover", item_foldup_finished)

	    item.SoundEmitter:PlaySound("farming/common/farm/plow/collapse")

		SpawnPrefab("dirt_puff").Transform:SetPosition(x, y, z)
	    item.SoundEmitter:PlaySound("farming/common/farm/plow/dirt_puff")
	else
		SpawnPrefab("collapse_small").Transform:SetPosition(x, y, z)
	end

	inst:PushEvent("finishplowing")
    inst:Remove()
end

local function IsPosWithin(x, z, positions, dist)
    dist = dist * dist
    for i, v in ipairs(positions) do
        local distance = VecUtil_DistSq(x, z, v.x, v.z)
        if distance < dist then
            return true
        end
    end
    return false
end

local function OnTerraform(inst, pt, old_tile_type, old_tile_turf_prefab)
    -- spawn some farm_soil_debris and farm_soil
    local cx, cy, cz = TheWorld.Map:GetTileCenterPoint(pt:Get())
    local TILE_EXTENTS = TILE_SCALE * 0.9
    local spawned_positions = {}
    for i = 1, math.random(TUNING.FARM_PLOW_DRILLING_DEBRIS_MIN, TUNING.FARM_PLOW_DRILLING_DEBRIS_MAX) do
        local x = cx + (math.random() * TILE_EXTENTS) - TILE_EXTENTS/2
        local z = cz + (math.random() * TILE_EXTENTS) - TILE_EXTENTS/2
        if not IsPosWithin(x, z, spawned_positions, 1) then
            table.insert(spawned_positions, {x = x, z = z})
			TheWorld.Map:CollapseSoilAtPoint(x, cy, z)
            SpawnPrefab("farm_soil_debris").Transform:SetPosition(x, cy, z)
        end
    end

	SpawnPrefab("dirt_puff").Transform:SetPosition(cx + math.random() + 1, cy, cz + math.random() + 1)
	SpawnPrefab("dirt_puff").Transform:SetPosition(cx - math.random() - 1, cy, cz + math.random() + 1)
	SpawnPrefab("dirt_puff").Transform:SetPosition(cx + math.random() + 1, cy, cz - math.random() - 1)
	SpawnPrefab("dirt_puff").Transform:SetPosition(cx - math.random() - 1, cy, cz - math.random() - 1)

	Finished(inst)
end

local function dirt_anim(inst, quad, timer)
	local x, y, z = inst.Transform:GetWorldPosition()
	local padding = 0.5
	local offset_x = math.random()
	local offset_z = math.random()
	offset_x = (1 - offset_x*offset_x) * 2
	offset_z = (1 - offset_z*offset_z) * 2
	if quad == 1 then
		offset_x = -offset_x
		offset_z = -offset_z
	elseif quad == 2 then
		offset_z = -offset_z
	elseif quad == 3 then
		offset_x = -offset_x
	end
	if offset_x*offset_x + offset_z*offset_z > 0.75*0.75 then
		local _x, _z = x + offset_x, z + offset_z
		if TheWorld.Map:CanTillSoilAtPoint(_x, 0, _z, true) then
			TheWorld.Map:CollapseSoilAtPoint(_x, 0, _z)
			local soil = SpawnPrefab("farm_soil")
			soil.Transform:SetPosition(_x, 0, _z)
			if soil.SetPlowing ~= nil then
				soil:SetPlowing(inst)
			end
		end
	end

	local t = math.min(1, timer/(TUNING.FARM_PLOW_DRILLING_DURATION))
	local duration_delay = Lerp(TUNING.FARM_PLOW_DRILLING_DIRT_DELAY_BASE_START, TUNING.FARM_PLOW_DRILLING_DIRT_DELAY_BASE_END, t)
	local delay = duration_delay + math.random() * TUNING.FARM_PLOW_DRILLING_DIRT_DELAY_VAR

	inst:DoTaskInTime(delay, dirt_anim, quad, timer + delay)
end

local function DoDrilling(inst)
	inst:RemoveEventCallback("animover", DoDrilling)

	inst.AnimState:PlayAnimation("drill_loop", true)
    inst.SoundEmitter:PlaySound("farming/common/farm/plow/LP", "loop")
	local fx_time = 0
	if not inst.components.timer:TimerExists("drilling") then
		inst.components.timer:StartTimer("drilling", TUNING.FARM_PLOW_DRILLING_DURATION)
	else
		fx_time = TUNING.FARM_PLOW_DRILLING_DURATION - inst.components.timer:GetTimeLeft("drilling")
	end
	inst:DoTaskInTime(math.random() * 0.2, dirt_anim, 1, fx_time)
	inst:DoTaskInTime(0.2 + math.random() * 0.3, dirt_anim, 2, fx_time)
	inst:DoTaskInTime(1.0 + math.random() * 0.5, dirt_anim, 3, fx_time)
	inst:DoTaskInTime(0.5 + math.random() * 0.3, dirt_anim, 4, fx_time)
end

local function timerdone(inst, data)
	if data ~= nil and data.name == "drilling" then
		if inst.components.terraformer ~= nil then
			if not inst.components.terraformer:Terraform(inst:GetPosition()) then
				Finished(inst)
			end
		else
			Finished(inst)
		end
	end
end

local function StartUp(inst)
    inst.AnimState:PlayAnimation("drill_pre")
	inst:ListenForEvent("animover", DoDrilling)
	inst.SoundEmitter:PlaySound("farming/common/farm/plow/drill_pre")

	inst.startup_task = nil
end

local function OnSave(inst, data)
	data.deploy_item = inst.deploy_item_save_record
end

local function OnLoadPostPass(inst, newents, data)
	if data ~= nil then
		inst.deploy_item_save_record = data.deploy_item
	end

	if inst.components.timer:TimerExists("drilling") then
		if inst.startup_task ~= nil then
			inst.startup_task:Cancel()
			inst.startup_task = nil
		end
		DoDrilling(inst)
	end
end

local function main_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

	inst:SetDeploySmartRadius(1) --match art (item uses CUSTOM spacing since snaps to tiles)
    MakeObstaclePhysics(inst, 0.5)

    inst.AnimState:SetBank("farm_plow")
    inst.AnimState:SetBuild("farm_plow")
    inst.AnimState:OverrideSymbol("soil01", "farm_soil", "soil01")
    inst.scrapbook_anim = "idle_place"
    inst.scrapbook_specialinfo = "FARMPLOW"

    inst:AddTag("scarytoprey")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("timer")

    MakeMediumBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)

    inst:AddComponent("terraformer")
    inst.components.terraformer.turf = WORLD_TILES.FARMING_SOIL
	inst.components.terraformer.onterraformfn = OnTerraform
	inst.components.terraformer.plow = true

	inst.deploy_item_save_record = nil

	inst.startup_task = inst:DoTaskInTime(0, StartUp)

	inst:ListenForEvent("timerdone", timerdone)


	inst.OnSave = OnSave
	inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

local function item_ondeploy(inst, pt, deployer)
    local cx, cy, cz = TheWorld.Map:GetTileCenterPoint(pt:Get())

    local obj = SpawnPrefab("farm_plow")
	obj.Transform:SetPosition(cx, cy, cz)

	inst.components.finiteuses:Use(1)
	if inst:IsValid() then
		obj.deploy_item_save_record = inst:GetSaveRecord()
		inst:Remove()
	end
end

local function can_plow_tile(inst, pt, mouseover, deployer)
	local x, z = pt.x, pt.z
	if not TheWorld.Map:CanPlantAtPoint(x, 0, z) or TheWorld.Map:GetTileAtPoint(x, 0, z) == WORLD_TILES.FARMING_SOIL then
		return false
	end

	local ents = TheWorld.Map:GetEntitiesOnTileAtPoint(x, 0, z)
	for _, ent in ipairs(ents) do
		if ent ~= inst and ent ~= deployer and not (ent:HasTag("NOBLOCK") or ent:HasTag("locomotor") or ent:HasTag("NOCLICK") or ent:HasTag("FX") or ent:HasTag("DECOR")) then
			return false
		end
	end

	return true
end

local function item_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("farm_plow")
    inst.AnimState:SetBuild("farm_plow")
    inst.AnimState:PlayAnimation("idle_packed")
    inst.scrapbook_anim = "idle_packed"

    inst.scrapbook_specialinfo = "FARMPLOW"

    inst:AddTag("usedeploystring")
    inst:AddTag("tile_deploy")

	MakeInventoryFloatable(inst, "small", 0.1, 0.8)

	inst._custom_candeploy_fn = can_plow_tile -- for DEPLOYMODE.CUSTOM

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
	inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
    inst.components.deployable.ondeploy = item_ondeploy

	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetMaxUses(TUNING.FARM_PLOW_USES)
    inst.components.finiteuses:SetUses(TUNING.FARM_PLOW_USES)

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

local function placer_invalid_fn(player, placer)
    if player and player.components.talker then
        player.components.talker:Say(GetString(player, "ANNOUNCE_CANTBUILDHERE_THRONE"))
    end
end

local function placer_fn()
    local inst = CreateEntity()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("farm_plow")
    inst.AnimState:SetBuild("farm_plow")
    inst.AnimState:PlayAnimation("idle_place")
    inst.AnimState:SetLightOverride(1)

    inst:AddComponent("placer")
    inst.components.placer.snap_to_tile = true

	inst.outline = SpawnPrefab("tile_outline")
	inst.outline.entity:SetParent(inst.entity)

	inst.components.placer:LinkEntity(inst.outline)

    return inst
end

return  Prefab("farm_plow", main_fn, assets, prefabs),
		Prefab("farm_plow_item", item_fn, assets_item, prefabs_item),
		Prefab("farm_plow_item_placer", placer_fn)

