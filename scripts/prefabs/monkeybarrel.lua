require("worldsettingsutil")
require "prefabutil"
local RuinsRespawner = require "prefabs/ruinsrespawner"

local assets =
{
    Asset("ANIM", "anim/monkey_barrel.zip"),
    Asset("SOUND", "sound/monkey.fsb"),
    Asset("SCRIPT", "scripts/prefabs/ruinsrespawner.lua"),
}

local prefabs =
{
    "monkey",
    "poop",
    "cave_banana",
    "collapse_small",
    "monkeybarrel_ruinsrespawner_inst",
}

SetSharedLootTable('monkey_barrel',
{
    {'poop',        1.0},
    {'poop',        1.0},
    {'cave_banana', 1.0},
    {'cave_banana', 1.0},
    {'trinket_4',   .01},
    {'trinket_13',   .01},
})

local function shake(inst)
    inst.AnimState:PlayAnimation(math.random() > .5 and "move1" or "move2")
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/monkey/barrel_rattle")
end

local function enqueueShake(inst)
    if inst.shake ~= nil then
        inst.shake:Cancel()
    end
    inst.shake = inst:DoPeriodicTask(GetRandomWithVariance(10, 3), shake)
end

local function onhammered(inst)
    if inst.shake ~= nil then
        inst.shake:Cancel()
        inst.shake = nil
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren(worker)
    end
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", false)

    enqueueShake(inst)
end

local function pushsafetospawn(inst)
    inst.task = nil
    inst:PushEvent("safetospawn")
end

local function ReturnChildren(inst)
    for _, child in pairs(inst.components.childspawner.childrenoutside) do
        if child.components.homeseeker ~= nil then
            child.components.homeseeker:GoHome()
        end
        child:PushEvent("gohome")
    end

    if not inst.task then
        inst.task = inst:DoTaskInTime(math.random(60, 120), pushsafetospawn)
    end
end

local function OnIgniteFn(inst)
    inst.AnimState:PlayAnimation("shake", true)

    if inst.shake ~= nil then
        inst.shake:Cancel()
        inst.shake = nil
    end

    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
    end
end

local function ongohome(inst, child)
    if child.components.inventory ~= nil then
        child.components.inventory:DropEverything(false, false)
    end
end

local function onsafetospawn(inst)
    if TheWorld.state.isacidraining then
        -- Acid rain isn't safe, but we don't have a nice way to track if it's ongoing.
        -- So just check when we try to go safe, and restart the waiting task if we have to.
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end

        inst.task = inst:DoTaskInTime(math.random(60, 120), pushsafetospawn)
    elseif inst.components.childspawner ~= nil then
        inst.components.childspawner:StartSpawning()
    end
end

local function onacidrainresponse(inst)
    -- recheck if it's acid raining, in case it decided to stop in the meantime.
    if TheWorld.state.isacidraining then
        inst:PushEvent("monkeydanger")
    end
end

local TARGET_MUST_TAGS = { "_combat" }
local TARGET_CANT_TAGS = { "playerghost", "INLIMBO" }
local TARGET_ONEOF_TAGS = { "character", "monster" }
local function OnHaunt(inst)
    if inst.components.childspawner == nil or
        not inst.components.childspawner:CanSpawn() or
        math.random() > TUNING.HAUNT_CHANCE_HALF then
        return false
    end

    local target =
        FindEntity(inst,
            25,
            nil,
            TARGET_MUST_TAGS,
            TARGET_CANT_TAGS,
            TARGET_ONEOF_TAGS
        )

    if target ~= nil then
        onhit(inst, target)
        return true
    end

    return false
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.MONKEYBARREL_SPAWN_PERIOD, TUNING.MONKEYBARREL_REGEN_PERIOD)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("monkeybarrel.png")

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("barrel")
    inst.AnimState:SetBuild("monkey_barrel")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("cavedweller")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    local childspawner = inst:AddComponent("childspawner")
    childspawner:SetRegenPeriod(TUNING.MONKEYBARREL_REGEN_PERIOD)
    childspawner:SetSpawnPeriod(TUNING.MONKEYBARREL_SPAWN_PERIOD)
    if TUNING.MONKEYBARREL_CHILDREN.max == 0 then
        childspawner:SetMaxChildren(0)
    else
        childspawner:SetMaxChildren(math.random(TUNING.MONKEYBARREL_CHILDREN.min, TUNING.MONKEYBARREL_CHILDREN.max))
    end

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.MONKEYBARREL_SPAWN_PERIOD, TUNING.MONKEYBARREL_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.MONKEYBARREL_REGEN_PERIOD, TUNING.MONKEYBARREL_ENABLED)
    if not TUNING.MONKEYBARREL_ENABLED then
        childspawner.childreninside = 0
    end

    childspawner:StartRegen()
    childspawner.childname = "monkey"
    childspawner:StartSpawning()
    childspawner.ongohome = ongohome
    childspawner:SetSpawnedFn(shake)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('monkey_barrel')

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(4)
    workable:SetOnFinishCallback(onhammered)
    workable:SetOnWorkCallback(onhit)

    local function ondanger()
        if inst.components.childspawner ~= nil then
            inst.components.childspawner:StopSpawning()
            ReturnChildren(inst)
        end
    end

    --Monkeys all return on a quake start
    inst:ListenForEvent("warnquake", ondanger, TheWorld.net)

    --Monkeys all return on danger
    inst:ListenForEvent("monkeydanger", ondanger)

    -- Monkeys all return when acid rain starts
    inst:WatchWorldState("isacidraining", function()
        inst:DoTaskInTime(3 + 7 * math.random(), onacidrainresponse)
    end)

    inst:ListenForEvent("safetospawn", onsafetospawn)

    inst:AddComponent("inspectable")

    MakeLargeBurnable(inst)
	MakeLargePropagator(inst)
    inst:ListenForEvent("onignite", OnIgniteFn)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    enqueueShake(inst)

    inst.OnPreLoad = OnPreLoad

    return inst
end

local function onruinsrespawn(inst, respawner)
	if not respawner:IsAsleep() then
		inst.AnimState:PlayAnimation("spawn")
		inst.AnimState:PushAnimation("idle", false)

		local fx = SpawnPrefab("small_puff")
		fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
		fx.Transform:SetScale(1.5, 1.5, 1.5)
	end
end

return Prefab("monkeybarrel", fn, assets, prefabs),
    RuinsRespawner.Inst("monkeybarrel", onruinsrespawn), RuinsRespawner.WorldGen("monkeybarrel", onruinsrespawn)
