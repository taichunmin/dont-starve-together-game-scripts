
local assets =
{
    Asset("ANIM", "anim/carrat_basic.zip"),
    Asset("ANIM", "anim/carrat_build.zip"),
    Asset("INV_IMAGE", "carrat"),
}

local planted_assets =
{
    Asset("ANIM", "anim/carrat_basic.zip"),
    Asset("ANIM", "anim/carrat_build.zip"),
}

local prefabs =
{
    "carrot",
    "wormwood_lunar_transformation_finish",
}

local carratsounds =
{
    idle = "turnoftides/creatures/together/carrat/idle",
    hit = "turnoftides/creatures/together/carrat/hit",
    sleep = "turnoftides/creatures/together/carrat/sleep",
    death = "turnoftides/creatures/together/carrat/death",
    emerge = "turnoftides/creatures/together/carrat/emerge",
    submerge = "turnoftides/creatures/together/carrat/submerge",
    eat = "turnoftides/creatures/together/carrat/eat",
    stunned = "turnoftides/creatures/together/carrat/stunned",
	reaction = "turnoftides/creatures/together/carrat/reaction",

	step = "dontstarve/creatures/mandrake/footstep",
}

local brain = require("brains/wormwood_carratbrain")

local function finish_transformed_life(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local carrot = SpawnPrefab("carrot")
    carrot.Transform:SetPosition(ix, iy, iz)

    inst.components.lootdropper:FlingItem(carrot)
    inst.components.inventory:DropEverything(true)

    local fx = SpawnPrefab("wormwood_lunar_transformation_finish")
    fx.Transform:SetPosition(ix, iy, iz)

    inst:Remove()
end

local function OnTimerDone(inst, data)
    if data.name == "finish_transformed_life" then
        finish_transformed_life(inst)
    end
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        if data.attacker.components.petleash and data.attacker.components.petleash:IsPet(inst) then
            local timer = inst.components.timer
            if timer and timer:TimerExists("finish_transformed_life") then
                timer:StopTimer("finish_transformed_life")
				finish_transformed_life(inst)
            end
        end
    end
end

local function Sleeper_SleepTest(inst)
    return false
end

local function Sleeper_WakeTest(inst)
    return true
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.DynamicShadow:SetSize(1, .75)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("carrat")
    inst.AnimState:SetBuild("carrat_build")
    inst.AnimState:PlayAnimation("idle1")

    inst.AnimState:SetScale(.8, .8)
    inst.AnimState:SetSymbolMultColour("carrat_eye", 0.7, 1, 0.7, 1)
    inst.AnimState:SetSymbolLightOverride("carrat_eye", 0.2)

    inst:AddTag("animal")
    inst:AddTag("catfood")
    inst:AddTag("cattoy")
    inst:AddTag("prey")
    inst:AddTag("smallcreature")
    inst:AddTag("stunnedbybomb")
    inst:AddTag("lunar_aligned")
    inst:AddTag("NOBLOCK")
    inst:AddTag("notraptrigger")
    inst:AddTag("wormwood_pet")
    inst:AddTag("noauradamage")
    inst:AddTag("soulless")

    inst:SetPrefabNameOverride("carrat")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = carratsounds -- sounds must be assigned before the stategraph


    local locomotor = inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    locomotor.walkspeed = TUNING.CARRAT.WALK_SPEED
    locomotor.runspeed = TUNING.CARRAT.RUN_SPEED

    inst:SetStateGraph("SGwormwood_carrat")
    inst:SetBrain(brain)

    local health = inst:AddComponent("health")
    health:SetMaxHealth(TUNING.CARRAT.HEALTH)
    health.murdersound = inst.sounds.death

    inst:AddComponent("lootdropper")

    local combat = inst:AddComponent("combat")
    combat.hiteffectsymbol = "carrat_body"
    inst:ListenForEvent("attacked", OnAttacked)

    -- Mostly copying MakeSmallBurnableCharacter, EXCEPT for the symbol following,
    -- because it looks bad paired with the burning of the planted prefab.
    local burnable = inst:AddComponent("burnable")
    burnable:SetFXLevel(2)
    burnable:SetBurnTime(10)
    burnable.canlight = false
    burnable:AddBurnFX("fire", Vector3(0, 0, 0))

    local propagator = MakeSmallPropagator(inst)
    propagator.acceptsheat = false

    local inventory = inst:AddComponent("inventory")
    inventory.maxslots = 1

    MakeTinyFreezableCharacter(inst, "carrat_body")

    inst:AddComponent("inspectable")
    local sleeper = inst:AddComponent("sleeper")
    sleeper:SetSleepTest(Sleeper_SleepTest)
    sleeper:SetWakeTest(Sleeper_WakeTest)

    local timer = inst:AddComponent("timer")
	timer:StartTimer("finish_transformed_life", TUNING.WORMWOOD_PET_CARRAT_LIFETIME)
    inst:ListenForEvent("timerdone", OnTimerDone)

    MakeHauntablePanic(inst)

    local follower = inst:AddComponent("follower")
    follower:KeepLeaderOnAttacked()
    follower.keepdeadleader = true
    follower.keepleaderduringminigame = true

    inst.no_spawn_fx = true
    inst.RemoveWormwoodPet = finish_transformed_life

    return inst
end

return Prefab("wormwood_carrat", fn, assets, prefabs)
