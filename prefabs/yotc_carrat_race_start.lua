local carratrace_common = require("prefabs/yotc_carrat_race_common")

local assets =
{
	Asset("ANIM", "anim/yotc_carrat_race_start.zip"),

	Asset("SCRIPT", "scripts/prefabs/yotc_carrat_race_common.lua"),
	Asset("ANIM", "anim/winona_battery_placement.zip"),
	Asset("ANIM", "anim/winona_spotlight_placement.zip"),
}

local prefabs =
{
	"small_puff",
	"yotc_carrat_rug",
	"carrat_ghostracer",
}

local sounds =
{
	onbuilt = "yotc_2020/gym/start/place",
	ongonghit = "yotc_2020/gym/start/gong",
}

local GONG_HIT_DELAY = 12*FRAMES

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
	inst.SoundEmitter:PlaySound(sounds.onbuilt)

	inst._rug:PushEvent("onbuilt")
end

local function OnGongHit(inst)
	inst.SoundEmitter:PlaySound(sounds.ongonghit)

    if TheWorld.components.yotc_raceprizemanager ~= nil then
        TheWorld.components.yotc_raceprizemanager:BeginRace(inst)
    end
end

local function SpawnGhostRacer(inst, num_stat_points)
	local ghost_racer = SpawnPrefab("carrat_ghostracer")
	local pt = inst:GetPosition()

    local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 2, 16, true, false) or
					FindWalkableOffset(pt, math.random() * 2 * PI, 1.5, 16, true, false) or
					FindWalkableOffset(pt, math.random() * 2 * PI, 1, 16, true, false) or
					Vector3(0, 0, 0)

	ghost_racer.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)

    if TheWorld.components.yotc_raceprizemanager ~= nil then
        TheWorld.components.yotc_raceprizemanager:RegisterRacer(ghost_racer, inst)
    end
	ghost_racer.components.yotc_racecompetitor:SetRaceStartPoint(inst)
	ghost_racer.components.yotc_racestats:AddRandomPointSpread(math.max(num_stat_points, TUNING.RACE_STATS.BAD_STAT_SPREAD))
    ghost_racer.components.yotc_racestats:SaveCurrentStatsAsBaseline()

	SpawnPrefab("shadow_puff").Transform:SetPosition(ghost_racer.Transform:GetWorldPosition())
end

local function SpawnGhostRacers(inst, race_data)
	if race_data ~= nil and race_data.num_racers == 1 then
		local racer = next(race_data.racers)
		local num_stats = (racer ~= nil and racer.components.yotc_racestats ~= nil) and racer.components.yotc_racestats:GetNumStatPoints() or 0

		SpawnGhostRacer(inst, math.floor(num_stats * 0.75) + math.random(-3, 0))
		SpawnGhostRacer(inst, math.random(math.floor(num_stats * 0.75), math.floor(num_stats * 0.9)) - 1)
		SpawnGhostRacer(inst, math.random(math.floor(num_stats * 0.8) , math.floor(num_stats * 1.1)))
	end
end

local function OnStartRace(inst)
	inst.AnimState:PlayAnimation("use")
	inst.AnimState:PushAnimation("idle_active")

	inst.SpawnGhostRacers(inst, TheWorld.components.yotc_raceprizemanager ~= nil and TheWorld.components.yotc_raceprizemanager:GetRaceById(inst) or nil)

	inst:DoTaskInTime(GONG_HIT_DELAY, OnGongHit)
end

local function OnEndRace(inst)
	inst.AnimState:PlayAnimation("reset")
	inst.AnimState:PushAnimation("idle")
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function OnHit(inst)
	if not inst:HasTag("burnt") and not inst.AnimState:IsCurrentAnimation("place") and not inst.AnimState:IsCurrentAnimation("use") then
		inst.AnimState:PlayAnimation("hit")
		if TheWorld.components.yotc_raceprizemanager and TheWorld.components.yotc_raceprizemanager:IsRaceUnderway(inst) then
			inst.AnimState:PushAnimation("idle_active", false)
		else
			inst.AnimState:PushAnimation("idle", false)
		end
	end
end

local function onburnt(inst)
	DefaultBurntStructureFn(inst)

	if inst.components.yotc_racestart ~= nil then
		inst:RemoveComponent("yotc_racestart")
	end

	inst.AnimState:PlayAnimation("burnt")

	inst._rug:PushEvent("onburntup")
end

local function MakeRug(inst)
	local rug = SpawnPrefab("yotc_carrat_rug")
	rug.entity:SetParent(inst.entity)

	inst._rug = rug
end

local function OnRaceOver(inst)
	inst.components.yotc_racestart:EndRace()
end

local function OnSave(inst, data)
	if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
		data.burnt = true
	end
end

local function OnLoad(inst, data)
	if data ~= nil then
		if data.burnt then
			inst.components.burnable.onburnt(inst)
		end
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, .4)

	inst.MiniMapEntity:SetIcon("yotc_carrat_race_start.png")

    inst.AnimState:SetBank("yotc_carrat_race_start")
    inst.AnimState:SetBuild("yotc_carrat_race_start")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("structure")

    -- Added by yotc_racestart; in pristine state for optimization
    inst:AddTag("yotc_racestart")

	carratrace_common.AddDeployHelper(inst, {"yotc_carrat_race_deploy_finish", "yotc_carrat_race_deploy_checkpoint"})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

	inst:AddComponent("yotc_racestart")
	inst.components.yotc_racestart.onstartracefn = OnStartRace
	inst.components.yotc_racestart.onendracefn = OnEndRace

	inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(OnHit)

    MakeMediumBurnable(inst, nil, nil, true)
	inst.components.burnable:SetOnBurntFn(onburnt)

    MakeSmallPropagator(inst)

	MakeHauntableWork(inst)

	MakeRug(inst)

	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("yotc_race_over", OnRaceOver)

	inst.racestartstring = "ANNOUNCE_CARRAT_START_RACE"

	inst.SpawnGhostRacers = SpawnGhostRacers

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

--------------------------------------------------------------------------

return Prefab("yotc_carrat_race_start", fn, assets, prefabs),
	MakeDeployableKitItem("yotc_carrat_race_start_item", "yotc_carrat_race_start", "yotc_carrat_racekit_start", "yotc_carrat_racekit_start", "idle", {Asset("ANIM", "anim/yotc_carrat_racekit_start.zip")}, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.LARGE_FUEL}, carratrace_common.deployable_data),
	MakePlacer("yotc_carrat_race_start_item_placer", "yotc_carrat_race_start", "yotc_carrat_race_start", "idle", nil, nil, nil, nil, nil, nil,
	function(inst)
		return carratrace_common.PlacerPostInit_AddCarpetAndPlacerRing(inst, "yotc_carrat_race_deploy_start")
	end)
