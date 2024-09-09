local brain = require("brains/wormwood_fruitdragonbrain")

local assets =
{
    Asset("ANIM", "anim/fruit_dragon.zip"),
    Asset("ANIM", "anim/fruit_dragon_build.zip"),
}

local prefabs =
{
    "dragonfruit",
    "wormwood_lunar_transformation_finish",
}

local MAX_CHASE_DIST = 12

local function KeepTarget(inst, target)
    return inst:IsNear(target, MAX_CHASE_DIST)
end

local function RetargetFn(inst)
    if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        return nil
    end

    return inst.components.combat.target
end

local function Sleeper_SleepTest(inst)
    return false
end

local function Sleeper_WakeTest(inst)
    return true
end

local function finish_transformed_life(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local fruit = SpawnPrefab("dragonfruit")
    fruit.Transform:SetPosition(ix, iy, iz)
    inst.components.lootdropper:FlingItem(fruit)

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
        elseif data.attacker.components.combat then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end
end

local function OnHealthDelta(inst)
    if inst.components.health:IsHurt() then
        inst.components.health:StartRegen(TUNING.WORMWOOD_PET_FRUITDRAGON_HEALTH_REGEN_AMOUNT, TUNING.WORMWOOD_PET_FRUITDRAGON_HEALTH_REGEN_PERIOD)
    else
        inst.components.health:StopRegen()
    end
end

local function OnLoad(inst, data)
    OnHealthDelta(inst)
end

local fruit_dragon_sounds =
{
    idle = "turnoftides/creatures/together/fruit_dragon/idle",
    death = "turnoftides/creatures/together/fruit_dragon/death",
    eat = "turnoftides/creatures/together/fruit_dragon/eat",
    onhit = "turnoftides/creatures/together/fruit_dragon/hit",
    sleep_loop = "turnoftides/creatures/together/fruit_dragon/sleep",
    stretch = "turnoftides/creatures/together/fruit_dragon/stretch",
    --do_ripen = "turnoftides/creatures/together/fruit_dragon/do_ripen",
    do_unripen = "turnoftides/creatures/together/fruit_dragon/stretch",
    attack = "turnoftides/creatures/together/fruit_dragon/attack",
    attack_fire = "turnoftides/creatures/together/fruit_dragon/attack_fire",
    challenge_pre = "turnoftides/creatures/together/fruit_dragon/challenge_pre",
    challenge = "turnoftides/creatures/together/fruit_dragon/challenge",
    challenge_pst = "turnoftides/creatures/together/fruit_dragon/eat",
    challenge_win = "turnoftides/creatures/together/fruit_dragon/eat",
    challenge_lose = "turnoftides/creatures/together/fruit_dragon/eat",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, 0.75)
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.AnimState:SetBank("fruit_dragon")
    inst.AnimState:SetBuild("fruit_dragon_build")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetScale(.8, .8)
    inst.AnimState:SetSymbolMultColour("gecko_eye", 0.7, 1, 0.7, 1)
    inst.AnimState:SetSymbolLightOverride("gecko_eye", 0.2)

    inst:AddTag("smallcreature")
    inst:AddTag("animal")
    inst:AddTag("scarytoprey")
    inst:AddTag("lunar_aligned")
    inst:AddTag("NOBLOCK")
    inst:AddTag("notraptrigger")
    inst:AddTag("wormwood_pet")
    inst:AddTag("noauradamage")
    inst:AddTag("soulless")

    inst:SetPrefabNameOverride("fruitdragon")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = fruit_dragon_sounds

    inst:AddComponent("inspectable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WORMWOOD_PET_FRUITDRAGON_HEALTH)
    inst.components.health.fire_damage_scale = 0
    inst:ListenForEvent("healthdelta", OnHealthDelta)

    inst:AddComponent("combat")
    inst.components.combat:SetHurtSound("turnoftides/creatures/together/fruit_dragon/hit")
    inst.components.combat.hiteffectsymbol = "gecko_torso_middle"
    inst.components.combat:SetAttackPeriod(TUNING.WORMWOOD_PET_FRUITDRAGON_ATTACK_PERIOD)
    inst.components.combat:SetDefaultDamage(TUNING.WORMWOOD_PET_FRUITDRAGON_DAMAGE)
    inst.components.combat:SetRange(TUNING.FRUITDRAGON.ATTACK_RANGE, TUNING.FRUITDRAGON.HIT_RANGE)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("lootdropper")

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(Sleeper_WakeTest)
    inst.components.sleeper:SetSleepTest(Sleeper_SleepTest)

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.WORMWOOD_PET_FRUITDRAGON_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.WORMWOOD_PET_FRUITDRAGON_WALK_SPEED

    MakeSmallFreezableCharacter(inst)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGwormwood_fruitdragon")

    MakeHauntablePanicAndIgnite(inst)

    local timer = inst:AddComponent("timer")
    timer:StartTimer("finish_transformed_life", TUNING.WORMWOOD_PET_FRUITDRAGON_LIFETIME)
    inst:ListenForEvent("timerdone", OnTimerDone)
    
    local follower = inst:AddComponent("follower")
    follower:KeepLeaderOnAttacked()
    follower.keepdeadleader = true
    follower.keepleaderduringminigame = true

    inst.no_spawn_fx = true
    inst.RemoveWormwoodPet = finish_transformed_life
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("wormwood_fruitdragon", fn, assets, prefabs)
