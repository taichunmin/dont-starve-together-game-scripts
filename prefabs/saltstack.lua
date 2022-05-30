local assets =
{
	Asset("ANIM", "anim/salt_pillar.zip"),
	Asset("ANIM", "anim/salt_pillar2.zip"),
	Asset("ANIM", "anim/salt_pillar3.zip"),
}

local prefabs =
{
    "saltrock",
}

SetSharedLootTable("saltstack_low",
{
    {"rocks",     1.00},
    {"saltrock",  1.00},
})
SetSharedLootTable("saltstack_med",
{
    {"rocks",     1.00},
    {"saltrock",  1.00},
})
SetSharedLootTable("saltstack_full",
{
    {"rocks",     1.00},
    {"saltrock",  1.00},
    {"saltrock",  0.5},
})

local inspectionstatuses =
{
	"MINED_OUT",
	"GROWING",
	"GROWING",
	"GENERIC",
}

local loottables =
{
	"saltstack_low",
	"saltstack_med",
	"saltstack_full",
}

local workstageanims =
{
	"empty",
	"low",
	"med",
	"full",
}

local growanims =
{
	low = "empty_to_low",
	med = "low_to_med",
	full = "med_to_full",
}

local workstagetoworkleft = { 0, 3, 6, 10}

local function DropLoots(inst, lower, upper)
	lower = lower or 1
	upper = upper or #loottables

	for i=lower,upper do
		inst.components.lootdropper:SetChanceLootTable(loottables[i])
		inst.components.lootdropper:DropLoot()
	end
end

local function UpdateState(inst, workleft, loading_in)
	inst.workstage = (workleft > 6 and 4)
		or (workleft > 3 and 3)
		or (workleft > 0 and 2)
		or 1

	if inst.workstage ~= inst.workstageprevious then
		local anim = workstageanims[inst.workstage]

		if inst.workstage < inst.workstageprevious then
			-- Being mined
			if not loading_in then
				DropLoots(inst, inst.workstage, inst.workstageprevious - 1)
			end
			inst.AnimState:PlayAnimation(anim)
		else
			-- Growing
			if inst:IsInLimbo() then
				inst.AnimState:PlayAnimation(anim)
			else
				inst.AnimState:PlayAnimation(growanims[anim])
				inst.AnimState:PushAnimation(anim)
				inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
			end
		end

		inst.workstageprevious = inst.workstage
	end
end

local function StartGrowthTimer(inst)
	local time = TUNING.SALTSTACK_GROWTH_FREQUENCY + math.random() * TUNING.SALTSTACK_GROWTH_FREQUENCY_VARIANCE
	if TUNING.REGROWTH_TIME_MULTIPLIER > 0 then
		time = time / TUNING.REGROWTH_TIME_MULTIPLIER
	end
	inst.components.worldsettingstimer:StartTimer("growth", time)
end

local function Grow(inst)
	local nextworkstage = math.min(inst.workstage + 1, 4)
	inst.components.workable:SetWorkLeft(workstagetoworkleft[nextworkstage] or 10)
	UpdateState(inst, inst.components.workable.workleft)
	if inst.components.workable.workleft < 10 then
		StartGrowthTimer(inst)
	end
end

local function ontimerdonefn(inst, data)
	inst.components.worldsettingstimer:StopTimer("growth")
	Grow(inst)
end

local function OnWork(inst, worker, workleft, numworks)
	inst.components.worldsettingstimer:StopTimer("growth")
	StartGrowthTimer(inst)
	UpdateState(inst, workleft)
end

local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then
        local damage_scale = 0.5
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * damage_scale / boat_physics.max_velocity + 0.5)
		if hit_velocity > 0 then
			inst.components.workable:WorkedBy(data.other, hit_velocity * TUNING.SALTSTACK_WORK_REQUIRED)
		end
    end
end

local function SetupStack(inst, stackid)
    if inst.stackid == nil then
        inst.stackid = stackid or math.random(1, 3)
    end

    if inst.stackid == 3 then
		inst.AnimState:SetBuild("salt_pillar3")
		inst.AnimState:SetBank("salt_pillar3")

        inst.components.floater:SetScale(0.52)
        inst.components.floater:SetSize("large")
    elseif inst.stackid == 2 then
		inst.AnimState:SetBuild("salt_pillar2")
		inst.AnimState:SetBank("salt_pillar2")

        inst.components.floater:SetScale(0.54)
        inst.components.floater:SetSize("large")
    else
		inst.AnimState:SetBuild("salt_pillar")
		inst.AnimState:SetBank("salt_pillar")

        inst.components.floater:SetScale(0.6)
        inst.components.floater:SetSize("large")
	end
end

local function getstatusfn(inst, viewer)
	return inspectionstatuses[inst.workstage] or inspectionstatuses[4]
end

local function onsave(inst, data)
    data.stackid = inst.stackid
	data.workleft = inst.components.workable.workleft
end

local function onloadpostpass(inst, newents, data)
	if data ~= nil then
		SetupStack(inst, data.stackid or nil)

		if data.workleft ~= nil then
			inst.components.workable:SetWorkLeft(data.workleft)
			UpdateState(inst, data.workleft, true) -- loading_in=true param prevents dropping loot when loading in to a mined state.

			if data.workleft <= 0 then
				inst.components.workable:SetWorkable(false)
				print("workleft == 0")
			end

			if data.workleft < 10 and not inst.components.worldsettingstimer:ActiveTimerExists("growth") then
				StartGrowthTimer(inst)
			end
		end
	else
		SetupStack(inst)
	end
end

local function OnPreLoad(inst, data)
	local maxtime = TUNING.SALTSTACK_GROWTH_FREQUENCY + TUNING.SALTSTACK_GROWTH_FREQUENCY_VARIANCE
	if TUNING.REGROWTH_TIME_MULTIPLIER > 0 then
		maxtime = maxtime / TUNING.REGROWTH_TIME_MULTIPLIER
	end
	WorldSettings_Timer_PreLoad(inst, data, "growth", maxtime)
    WorldSettings_Timer_PreLoad_Fix(inst, data, "growth", 1)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("saltstack.png")

    inst:SetPhysicsRadiusOverride(2.35)

    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

    inst:AddTag("ignorewalkableplatforms")

    inst.AnimState:SetBank("salt_pillar")
    inst.AnimState:SetBuild("salt_pillar")

	inst.AnimState:PlayAnimation("full")

    MakeInventoryFloatable(inst, "med", nil, 0.85)
    inst.components.floater.bob_percent = 0

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local land_time = (POPULATING and math.random()*5*FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("saltstack_full")
    inst.components.lootdropper.max_speed = 2
    inst.components.lootdropper.min_speed = 0.3
    inst.components.lootdropper.y_speed = 14
    inst.components.lootdropper.y_speed_variance = 4
    inst.components.lootdropper.spawn_loot_inside_prefab = true


    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.SALTSTACK_WORK_REQUIRED)
    inst.components.workable:SetOnWorkCallback(OnWork)
	inst.components.workable.savestate = true

	inst.workstage = 4
	inst.workstageprevious = inst.workstage

	inst:AddComponent("worldsettingstimer")
	local maxtime = TUNING.SALTSTACK_GROWTH_FREQUENCY + TUNING.SALTSTACK_GROWTH_FREQUENCY_VARIANCE
	if TUNING.REGROWTH_TIME_MULTIPLIER > 0 then
		maxtime = maxtime / TUNING.REGROWTH_TIME_MULTIPLIER
	end
	inst.components.worldsettingstimer:AddTimer("growth", maxtime, TUNING.SALTSTACK_GROWTH_ENABLED and TUNING.REGROWTH_TIME_MULTIPLIER > 0)
	inst:ListenForEvent("timerdone", ontimerdonefn)


    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatusfn

    MakeHauntableWork(inst)

    inst:ListenForEvent("on_collide", OnCollide)

	if not POPULATING then -- Used for variety in debug spawned saltstacks
		SetupStack(inst)
	end

    --------SaveLoad
    inst.OnSave = onsave
	inst.OnLoadPostPass = onloadpostpass
	inst.OnPreLoad = OnPreLoad

    return inst
end

local function spawnerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    return inst
end

return Prefab("saltstack", fn, assets, prefabs)