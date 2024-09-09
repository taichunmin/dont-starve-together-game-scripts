local PF_DIMS = 4 --equal to 4x4 grid of walls

local function UnregisterPathFinding(inst)
	local x = inst._pfpos.x - (PF_DIMS - 1) / 2
	local z = inst._pfpos.z - (PF_DIMS - 1) / 2
	local pathfinder = TheWorld.Pathfinder
	for i = 0, PF_DIMS - 1 do
		for j = 0, PF_DIMS - 1 do
			pathfinder:RemoveWall(x + i, 0, z + j)
		end
	end
end

local function RegisterPathFinding(inst)
	inst._pfpos = inst:GetPosition()
	local x = inst._pfpos.x - (PF_DIMS - 1) / 2
	local z = inst._pfpos.z - (PF_DIMS - 1) / 2
	local pathfinder = TheWorld.Pathfinder
	for i = 0, PF_DIMS - 1 do
		for j = 0, PF_DIMS - 1 do
			pathfinder:AddWall(x + i, 0, z + j)
		end
	end
	inst.OnRemoveEntity = UnregisterPathFinding
end

--------------------------------------------------------------------------

local CIRCLE_RADIUS_SCALE = 1888 / 150 / 2 -- Source art size / anim_scale / 2 (halved to get radius).

local function CreateHelperRadiusCircle()
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

    local scale = TUNING.QUAKE_BLOCKER_RANGE / CIRCLE_RADIUS_SCALE -- Convert to rescaling for our desired range.

    inst.AnimState:SetScale(scale, scale)

    return inst
end

local function OnEnableHelper(inst, enabled)
    if enabled and (TheWorld == nil or TheWorld:HasTag("cave")) then
        if inst.helper == nil then
            inst.helper = CreateHelperRadiusCircle()

            inst.helper.entity:SetParent(inst.entity)
        end

    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

--------------------------------------------------------------------------

local PHYSICS_RADIUS = 1.45
local DEPLOY_SMART_RADIUS = 2

--------------------------------------------------------------------------

local function GetMaterial(prefab)
	return CONSTRUCTION_PLANS[prefab][1].type
end

local DEBRIS_FX =
{
	HIT = 1,
	QUAKE = 2,
	COLLAPSE = 3,
}

local function OnDebrisFXDirty(inst)
	if inst._debrisfx:value() == 0 then
		return
	end

	local fx = CreateEntity()

	fx:AddTag("FX")
	fx:AddTag("NOCLICK")
	--[[Non-networked entity]]
	fx.entity:SetCanSleep(false)
	fx.persists = false

	fx.entity:AddTransform()
	fx.entity:AddAnimState()

	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

	fx.AnimState:SetBank(inst.debrisbank)
	fx.AnimState:SetBuild(inst.debrisbuild)
	fx.AnimState:SetFinalOffset(1)

	fx.persists = false

	if inst._debrisfx:value() == DEBRIS_FX.COLLAPSE then
		fx.Transform:SetEightFaced()
		fx.AnimState:PlayAnimation("collapse_top")

		if inst.debrisbuild == "support_pillar_dreadstone" then
			fx.AnimState:SetSymbolLightOverride("pillar_pieces_red", 1)
			fx.AnimState:SetSymbolLightOverride("pillar_pieces_red_90", 1)
		end

		ErodeAway(fx, 1)
	else
		fx.entity:AddSoundEmitter()
		fx.SoundEmitter:PlaySound("meta2/pillar/pillar_quake")
		fx.AnimState:PlayAnimation(inst._debrisfx:value() == 2 and "quake_debris" or "hit_debris")
		fx:ListenForEvent("animover", fx.Remove)
	end
end

local function PushDebrisFX(inst, fxlevel)
	--force dirty
	inst._debrisfx:set_local(fxlevel)
	inst._debrisfx:set(fxlevel)

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		OnDebrisFXDirty(inst)
	end
end

local function OnLevelDirty(inst)
	if inst._level:value() == 4 then
		inst:SetPrefabNameOverride(inst.prefab.."_broken")
	elseif inst._level:value() == 0 then
		inst:SetPrefabNameOverride(inst.prefab.."_complete")
	else
		inst:SetPrefabNameOverride(nil)
	end
end

local Increment, Decrement --forward declare

local function DoRegen(inst)
	local oldsuffix = inst.suffix
	if Increment(inst) then
		inst.components.workable:SetWorkLeft(5)
		if oldsuffix ~= inst.suffix then
			inst.AnimState:PlayAnimation("idle_repair"..inst.suffix)
			inst.AnimState:PushAnimation("idle"..inst.suffix, false)
			--In case we're interrupting something else (possible with LongUpdate)
			if inst.suffix ~= "" then
				inst.components.constructionsite:Enable()
			end
			inst.components.workable:SetWorkable(true)
		end
	end
	--Remove sanity aura once we reach the reinforced portion
	if inst.suffix == "" and inst.components.sanityaura ~= nil then
		inst:RemoveComponent("sanityaura")
	end
	if inst.reinforced >= TUNING.SUPPORT_PILLAR_REINFORCED_LEVELS then
		inst._regentask:Cancel()
		inst._regentask = nil
		inst.OnLongUpdate = nil
	end
end

local function OnLongUpdateRegen(inst, dt)
	if inst._regentask ~= nil then
		local remaining = GetTaskRemaining(inst._regentask)
		local timetonext = remaining
		while dt > 0 do
			if dt >= timetonext then
				DoRegen(inst)
				if inst._regentask == nil then
					--Finished repairing
					return
				end
				dt = dt - timetonext
				timetonext = inst._regentask.period
			else
				timetonext = timetonext - dt
				dt = 0
			end
		end
		if timetonext ~= remaining then
			inst._regentask:Cancel()
			inst._regentask = inst:DoPeriodicTask(TUNING.SUPPORT_PILLAR_DREADSTONE_REGEN_PERIOD, DoRegen, timetonext)
		end
	end
end

local function ToggleOrRestartRegen(inst, delay)
	if GetMaterial(inst.prefab) == "dreadstone" then
		--This will also reset the timer
		if inst._regentask ~= nil then
			inst._regentask:Cancel()
			inst._regentask = nil
			inst.OnLongUpdate = nil
		end
		if inst.reinforced < TUNING.SUPPORT_PILLAR_REINFORCED_LEVELS and inst.suffix ~= "_4" then
			inst._regentask = inst:DoPeriodicTask(TUNING.SUPPORT_PILLAR_DREADSTONE_REGEN_PERIOD, DoRegen, delay or TUNING.SUPPORT_PILLAR_DREADSTONE_REGEN_PERIOD + math.random())
			inst.OnLongUpdate = OnLongUpdateRegen
		end
		--Sanity aura only when repairing the non-reinforced portion
		if inst._regentask ~= nil and inst.suffix ~= "" then
			if inst.components.sanityaura == nil then
				inst:AddComponent("sanityaura")
				inst.components.sanityaura.max_distsq = TUNING.SUPPORT_PILLAR_DREADSTONE_AURA_RADIUS * TUNING.SUPPORT_PILLAR_DREADSTONE_AURA_RADIUS
				inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
			end
		elseif inst.components.sanityaura ~= nil then
			inst:RemoveComponent("sanityaura")
		end
	end
end

local function DoQuake(inst)
	inst._quaketask = nil
	inst.components.constructionsite:Disable()
	local oldsuffix = inst.suffix
	if Decrement(inst, nil, 1) then
		ToggleOrRestartRegen(inst)
	end
	if inst.AnimState:IsCurrentAnimation("collapse") then
		return
	elseif inst.suffix ~= "_4" then
		inst.AnimState:PlayAnimation("idle_quake"..inst.suffix)
		PushDebrisFX(inst, DEBRIS_FX.QUAKE)
	elseif oldsuffix ~= "_4" then
		inst.AnimState:PlayAnimation("idle_quake"..oldsuffix)
		PushDebrisFX(inst, DEBRIS_FX.QUAKE)
		inst.components.workable:SetWorkable(false)
	end
end

local function SetEnableWatchQuake(inst, enable, keeptask)
	if enable then
		if inst._onquake == nil then
			inst._onquake = function(_, data)
				if inst._quaketask ~= nil then
					inst._quaketask:Cancel()
				end
				--delay till the first camera shake period
				inst._quaketask = inst:DoTaskInTime(data ~= nil and data.debrisperiod or 0, DoQuake)
			end
			inst:ListenForEvent("startquake", inst._onquake, TheWorld.net)
		end
	else
		if inst._onquake ~= nil then
			inst:RemoveEventCallback("startquake", inst._onquake, TheWorld.net)
			inst._onquake = nil
		end
		if inst._quaketask ~= nil and not keeptask then
			inst._quaketask:Cancel()
			inst._quaketask = nil
		end
	end
end

local function UpdateLevel(inst)
	local num = inst.components.constructionsite:GetSlotCount(1)
	inst._level:set(
		(num >= 40 and 0) or
		(num >= 20 and 1) or
		(num >= 10 and 2) or
		(num > 0 and 3) or
		4
	)
	inst.suffix = inst._level:value() > 0 and "_"..tostring(inst._level:value()) or ""
	OnLevelDirty(inst)

	if inst.suffix == "_4" then
		inst:RemoveTag("quake_blocker")
	else
		inst:AddTag("quake_blocker")
		if inst.suffix == "" then
			inst.components.constructionsite:Disable()
		end
	end
	if not inst:IsAsleep() then
		SetEnableWatchQuake(inst, inst.suffix ~= "_4")
	end
end

local function OnEntitySleep(inst)
	SetEnableWatchQuake(inst, false, true)
end

local function OnEntityWake(inst)
	if inst.suffix ~= "_4" then
		SetEnableWatchQuake(inst, true)
	end
end

local function IsQuakeAnim(inst)
	return inst.AnimState:IsCurrentAnimation("idle_quake")
		or inst.AnimState:IsCurrentAnimation("idle_quake_1")
		or inst.AnimState:IsCurrentAnimation("idle_quake_2")
		or inst.AnimState:IsCurrentAnimation("idle_quake_3")
end

local function IsHitAnim(inst)
	return inst.AnimState:IsCurrentAnimation("idle_hit")
		or inst.AnimState:IsCurrentAnimation("idle_hit_1")
		or inst.AnimState:IsCurrentAnimation("idle_hit_2")
		or inst.AnimState:IsCurrentAnimation("idle_hit_3")
end

--forward declared
Increment = function(inst)
	local material = GetMaterial(inst.prefab)
	if inst.components.constructionsite:AddMaterial(material, 1) == 0 then
		UpdateLevel(inst)
		return true
	elseif inst.reinforced < TUNING.SUPPORT_PILLAR_REINFORCED_LEVELS then
		inst.reinforced = inst.reinforced + 1
		return true
	end
end

--forward declared
Decrement = function(inst, worker, numworks)
	local crit = numworks >= 1000
	if crit then
		inst.reinforced = 0
	elseif inst.reinforced > 0 then
		inst.reinforced = inst.reinforced - 1
		return true
	end
	local material = GetMaterial(inst.prefab)
	numworks = inst.components.constructionsite:RemoveMaterial(material, crit and inst.components.constructionsite:GetMaterialCount(material) or 1)
	if numworks > 0 then
		local oldsuffix = inst.suffix
		UpdateLevel(inst)
		if material ~= "dreadstone" then
			local numguaranteed = oldsuffix ~= inst.suffix and 1 or 0
			numworks = math.floor((numworks - numguaranteed) * math.random() * 0.3) + numguaranteed
			--# of material loot to drop
			if worker ~= nil and worker.components.locomotor ~= nil then
				inst.components.lootdropper:SetFlingTarget(worker:GetPosition(), 45)
			else
				inst.components.lootdropper:SetFlingTarget(nil, nil)
			end
			for i = 1, numworks do
				local loot = inst.components.lootdropper:SpawnLootPrefab(material)
				local x, y, z = loot.Transform:GetWorldPosition()
				loot.Physics:Teleport(x, 2 + math.random(), z)
			end
		end
		return true
	end
end

local function OnAnimOver(inst)
	local collapsing = inst.AnimState:IsCurrentAnimation("collapse")
	if not collapsing then
		if inst.AnimState:IsCurrentAnimation("build") then
			inst.AnimState:ClearAllOverrideSymbols()
		elseif not (IsHitAnim(inst) or IsQuakeAnim(inst)) then
			return
		end
	end
	if inst.suffix == "_4" and not collapsing then
		inst.AnimState:PlayAnimation("collapse")
		inst.SoundEmitter:PlaySound("meta2/pillar/pillar_collapse")
	else
		if collapsing and inst.suffix == "_4" then
			PushDebrisFX(inst, DEBRIS_FX.COLLAPSE)
		end
		inst.AnimState:PlayAnimation("idle"..inst.suffix)
		if inst.suffix ~= "" then
			inst.components.constructionsite:Enable()
		end
		inst.components.workable:SetWorkable(true)
	end
end

local function onhit(inst, worker, workleft, numworks)
	if numworks <= 0 then
		return
	end
	inst.components.constructionsite:ForceStopConstruction()
	local oldsuffix = inst.suffix
	if Decrement(inst, worker, numworks) then
		inst.components.workable:SetWorkLeft(5)
		ToggleOrRestartRegen(inst)
	end
	if IsQuakeAnim(inst) then
		if inst.AnimState:GetCurrentAnimationFrame() < 15 then
			return
		end
	elseif inst.AnimState:IsCurrentAnimation("collapse") then
		return
	elseif inst.suffix ~= "_4" then
		inst.AnimState:PlayAnimation("idle_hit"..inst.suffix)
		if inst.suffix ~= oldsuffix then
			PushDebrisFX(inst, DEBRIS_FX.HIT)
		end
	elseif oldsuffix ~= "_4" then
		inst.AnimState:PlayAnimation("idle_hit_3")
		if inst.suffix ~= oldsuffix then
			PushDebrisFX(inst, DEBRIS_FX.HIT)
		end
		inst.components.workable:SetWorkable(false)
		inst.components.constructionsite:Disable()
	end
end

local function onhammered(inst)
	local pt = inst:GetPosition()
	inst.components.lootdropper.spawn_loot_inside_prefab = true
	inst.components.lootdropper.y_speed = nil
	inst.components.lootdropper:SetFlingTarget(nil, nil)
	inst.components.lootdropper:DropLoot(pt)

	inst.components.constructionsite:DropAllMaterials(pt)

	local fx = SpawnPrefab("collapse_big")
	fx.Transform:SetPosition(pt:Get())
	fx:SetMaterial("rock")
	inst:Remove()
end

local function LootSetupFn(lootdropper)
	local recipe = AllRecipes[lootdropper.inst.prefab.."_scaffold"]
	local loot = {}
	for i, v in ipairs(recipe.ingredients) do
		if v.type ~= "boards" then
			for j = 1, v.amount do
				table.insert(loot, v.type)
			end
		end
	end
	lootdropper:SetLoot(loot)
end

local function OnConstructed(inst)
	inst.components.workable:SetWorkLeft(5)
	local oldsuffix = inst.suffix
	UpdateLevel(inst)
	if oldsuffix ~= inst.suffix then
		inst.AnimState:PlayAnimation("idle_repair"..inst.suffix)
		inst.AnimState:PushAnimation("idle"..inst.suffix, false)
		if inst.suffix == "" then
			inst.reinforced = TUNING.SUPPORT_PILLAR_REINFORCED_LEVELS
		else --In case we're interrupting something else
			inst.components.constructionsite:Enable()
		end
		inst.components.workable:SetWorkable(true)
	end
	ToggleOrRestartRegen(inst)
end

local function MakeReinforced(inst, anim)
	inst.components.constructionsite:AddMaterial(GetMaterial(inst.prefab), 40)
	inst.components.constructionsite:Disable()
	inst.reinforced = TUNING.SUPPORT_PILLAR_REINFORCED_LEVELS
	UpdateLevel(inst)
	ToggleOrRestartRegen(inst)
	if anim == nil then
		inst.AnimState:PlayAnimation("idle"..inst.suffix)
	elseif anim == "build" then
		inst.components.workable:SetWorkable(false)
		if inst.AnimState:GetBuild() ~= "support_pillar" then
			inst.AnimState:OverrideSymbol("pillar_scaffold", "support_pillar", "pillar_scaffold")
			inst.AnimState:OverrideSymbol("pillar_scaffold_90s", "support_pillar", "pillar_scaffold_90s")
		end
		inst.AnimState:PlayAnimation("build")
		inst.SoundEmitter:PlaySound("meta2/pillar/pillar_build")
	else
		inst.AnimState:PlayAnimation(anim)
		inst.AnimState:PushAnimation("idle"..inst.suffix, false)
	end
end

local function OnSave(inst, data)
	data.reinforced = inst.reinforced ~= 0 and inst.reinforced or nil
	data.regen = inst._regentask ~= nil and GetTaskRemaining(inst._regentask) or nil
end

local function OnLoad(inst, data, ents)
	inst.reinforced = data ~= nil and data.reinforced or 0
	UpdateLevel(inst)
	ToggleOrRestartRegen(inst, data ~= nil and data.regen or nil)
	inst.AnimState:PlayAnimation("idle"..inst.suffix)
end

local function MakePillar(name, bank, build)
	local assets =
	{
		Asset("ANIM", "anim/"..bank..".zip"),
		Asset("MINIMAP_IMAGE", name),
	}
	if bank ~= build then
		table.insert(assets, Asset("ANIM", "anim/"..build..".zip"))
	end
	if bank ~= "support_pillar" and build ~= "support_pillar" then
		table.insert(assets, Asset("ANIM", "anim/support_pillar.zip"))
	end

	local prefabs =
	{
		"collapse_big",
		"construction_repair_container",
	}

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddMiniMapEntity()
		inst.entity:AddNetwork()

		inst.MiniMapEntity:SetIcon(name..".png")

		MakeObstaclePhysics(inst, PHYSICS_RADIUS, 6)
        inst.Physics:SetDontRemoveOnSleep(true)

		inst:SetDeploySmartRadius(DEPLOY_SMART_RADIUS)

		inst.Transform:SetEightFaced()

		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build)
		inst.AnimState:PlayAnimation("idle_4")

		if build == "support_pillar_dreadstone" then
			inst.AnimState:SetSymbolLightOverride("pillar_pieces_red", 1)
			inst.AnimState:SetSymbolLightOverride("pillar_pieces_red_90", 1)
		end

		inst:AddTag("structure")
		inst:AddTag("antlion_sinkhole_blocker")

		--constructionsite (from constructionsite component) added to pristine state for optimization
		inst:AddTag("constructionsite")

		--Repair action strings.
		inst:AddTag("repairconstructionsite")

		inst._level = net_tinybyte(inst.GUID, name.."._level", "leveldirty")
		inst._level:set(4)

		inst._debrisfx = net_tinybyte(inst.GUID, name.."._debrisfx", "debrisfxdirty")
		inst.debrisbank = bank
		inst.debrisbuild = build

		inst:SetPrefabNameOverride(name.."_broken")
		inst:DoTaskInTime(0, RegisterPathFinding)

		-- Dedicated server does not need deployhelper.
		if not TheNet:IsDedicated() then
			inst:AddComponent("deployhelper")
			inst.components.deployhelper.onenablehelper = OnEnableHelper
		end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			inst:ListenForEvent("leveldirty", OnLevelDirty)
			inst:DoTaskInTime(0, inst.ListenForEvent, "debrisfxdirty", OnDebrisFXDirty)

			return inst
		end

		inst.scrapbook_anim = "idle"

		inst.suffix = "_4"
		inst.reinforced = 0

		inst:AddComponent("constructionsite")
		inst.components.constructionsite:SetConstructionPrefab("construction_repair_container")
		inst.components.constructionsite:SetOnConstructedFn(OnConstructed)

		inst:AddComponent("inspectable")
		inst:AddComponent("lootdropper")
		inst.components.lootdropper:SetLootSetupFn(LootSetupFn)
		inst.components.lootdropper.y_speed = 4

		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(5)
		inst.components.workable:SetOnWorkCallback(onhit)
		inst.components.workable:SetOnFinishCallback(onhammered)
		inst.components.workable:SetRequiresToughWork(GetMaterial(name) == "dreadstone")

		inst:ListenForEvent("animover", OnAnimOver)
		inst:ListenForEvent("onsink", onhammered)

		inst.MakeReinforced = MakeReinforced
		inst.OnEntitySleep = OnEntitySleep
		inst.OnEntityWake = OnEntityWake
		inst.OnSave = OnSave
		inst.OnLoad = OnLoad

		return inst
	end

	return Prefab(name, fn, assets, prefabs)
end

--------------------------------------------------------------------------

local function onbuilt_scaffold(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("scaffold", false)
	inst.SoundEmitter:PlaySound("meta2/pillar/scaffold_place")
end

local function onconstructed_scaffold(inst, doer)
	if inst.components.constructionsite:IsComplete() then
		ReplacePrefab(inst, string.sub(inst.prefab, 1, -10)):MakeReinforced("build")
	else
		inst.components.workable:SetWorkLeft(5)
	end
end

local function onhit_scaffold(inst, worker, workleft, numworks)
	inst.AnimState:PlayAnimation("scaffold_hit")
	inst.AnimState:PushAnimation("scaffold", false)
	inst.SoundEmitter:PlaySound("meta2/pillar/scaffold_hit")

	inst.components.constructionsite:ForceStopConstruction()
	local material = GetMaterial(inst.prefab)
	if inst.components.constructionsite:RemoveMaterial(material, 1) > 0 then
		if workleft <= 0 then
			inst.components.workable:SetWorkLeft(1)
		end
		if math.random() < 0.3 then
			if worker ~= nil and worker.components.locomotor ~= nil then
				inst.components.lootdropper:SetFlingTarget(worker:GetPosition(), 45)
			else
				inst.components.lootdropper:SetFlingTarget(nil, nil)
			end
			local loot = inst.components.lootdropper:SpawnLootPrefab(material)
			local x, y, z = loot.Transform:GetWorldPosition()
			loot.Physics:Teleport(x, 2 + math.random(), z)
		end
	end
end

local function onhammered_scaffold(inst)
	local pt = inst:GetPosition()
	inst.components.lootdropper.spawn_loot_inside_prefab = true
	inst.components.lootdropper.y_speed = nil
	inst.components.lootdropper:SetFlingTarget(nil, nil)
	inst.components.lootdropper:DropLoot(pt)

	inst.components.constructionsite:DropAllMaterials(pt)

	local fx = SpawnPrefab("collapse_big")
	fx.Transform:SetPosition(pt:Get())
	fx:SetMaterial("rock")
	inst:Remove()
end

local function MakeScaffold(name, bank, build)
	local basename = string.sub(name, 1, -10)
	local assets =
	{
		Asset("ANIM", "anim/"..bank..".zip"),
		Asset("MINIMAP_IMAGE", basename),
		Asset("ANIM", "anim/firefighter_placement.zip"),
	}
	if bank ~= build then
		table.insert(assets, Asset("ANIM", "anim/"..build..".zip"))
	end
	if bank ~= "support_pillar" and build ~= "support_pillar" then
		table.insert(assets, Asset("ANIM", "anim/support_pillar.zip"))
	end

	local prefabs =
	{
		basename,
		"collapse_big",
		"construction_container",
	}

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddMiniMapEntity()
		inst.entity:AddNetwork()

		inst.MiniMapEntity:SetIcon(basename..".png")

		MakeObstaclePhysics(inst, PHYSICS_RADIUS, 6)
        inst.Physics:SetDontRemoveOnSleep(true)

		inst:SetDeploySmartRadius(DEPLOY_SMART_RADIUS)

		inst.Transform:SetEightFaced()

		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build)
		inst.AnimState:PlayAnimation("scaffold")

		if build ~= "support_pillar" then
			inst.AnimState:OverrideSymbol("pillar_scaffold", "support_pillar", "pillar_scaffold")
			inst.AnimState:OverrideSymbol("pillar_scaffold_90s", "support_pillar", "pillar_scaffold_90s")

			inst.scrapbook_overridedata = {{"pillar_scaffold", "support_pillar", "pillar_scaffold"}, {"pillar_scaffold_90s", "support_pillar", "pillar_scaffold_90s"}}
		end

		if build == "support_pillar_dreadstone" then
			inst.AnimState:SetSymbolLightOverride("pillar_pieces_red", 1)
			inst.AnimState:SetSymbolLightOverride("pillar_pieces_red_90", 1)
		end

		inst:AddTag("structure")
		inst:AddTag("antlion_sinkhole_blocker")

		--constructionsite (from constructionsite component) added to pristine state for optimization
		inst:AddTag("constructionsite")

		inst:DoTaskInTime(0, RegisterPathFinding)

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("constructionsite")
		inst.components.constructionsite:SetConstructionPrefab("construction_container")
		inst.components.constructionsite:SetOnConstructedFn(onconstructed_scaffold)

		inst:AddComponent("inspectable")
		inst:AddComponent("lootdropper")
		inst.components.lootdropper.y_speed = 4

		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(5)
		inst.components.workable:SetOnWorkCallback(onhit_scaffold)
		inst.components.workable:SetOnFinishCallback(onhammered_scaffold)

		inst:ListenForEvent("onbuilt", onbuilt_scaffold)
		inst:ListenForEvent("onsink", onhammered_scaffold)

		return inst
	end

	return Prefab(name, fn, assets, prefabs)
end

--------------------------------------------------------------------------

local function placer_override_build_point(inst)
	--Use placer's snapped position instead of mouse position
	return inst:GetPosition()
end

local function placer_postinit_fn(inst)
    local helper = CreateHelperRadiusCircle()
    helper.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(helper)
	inst.components.placer.override_build_point_fn = placer_override_build_point
end

--------------------------------------------------------------------------

--NOTE: -dreadstone has it's own bank because of the red layers.
--      -when adding other material builds, just use "support_pillar" bank!
return
	--rocks
	MakeScaffold("support_pillar_scaffold", "support_pillar", "support_pillar"),
	MakePlacer("support_pillar_scaffold_placer", "support_pillar", "support_pillar", "idle", nil, true, nil, nil, nil, "eight", placer_postinit_fn),
	MakePillar("support_pillar", "support_pillar", "support_pillar"),
	--dreadstone
	MakeScaffold("support_pillar_dreadstone_scaffold", "support_pillar_dreadstone", "support_pillar_dreadstone"),
	MakePlacer("support_pillar_dreadstone_scaffold_placer", "support_pillar_dreadstone", "support_pillar_dreadstone", "idle", nil, true, nil, nil, nil, "eight", placer_postinit_fn),
	MakePillar("support_pillar_dreadstone", "support_pillar_dreadstone", "support_pillar_dreadstone")
