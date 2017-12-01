local assets =
{
    Asset("ANIM", "anim/hound_basic.zip"),
    Asset("ANIM", "anim/hound.zip"),
    Asset("ANIM", "anim/hound_red.zip"),
    Asset("ANIM", "anim/hound_ice.zip"),
    Asset("SOUND", "sound/hound.fsb"),
}

local prefabs =
{
    "houndstooth",
    "monstermeat",
    "redgem",
    "bluegem",
}

local gargoyles = 
{
    "gargoyle_houndatk",
    "gargoyle_hounddeath",
}
local moonprefabs = {}
for i, v in ipairs(gargoyles) do
    table.insert(moonprefabs, v)
end
for i, v in ipairs(prefabs) do
    table.insert(moonprefabs, v)
end

local brain = require("brains/houndbrain")
local moonbrain = require("brains/moonbeastbrain")

SetSharedLootTable( 'hound',
{
    {'monstermeat', 1.000},
    {'houndstooth',  0.125},
})

SetSharedLootTable( 'hound_fire',
{
    {'monstermeat', 1.0},
    {'houndstooth', 1.0},
    {'houndfire',   1.0},
    {'houndfire',   1.0},
    {'houndfire',   1.0},
    {'redgem',      0.2},
})

SetSharedLootTable( 'hound_cold',
{
    {'monstermeat', 1.0},
    {'houndstooth', 1.0},
    {'houndstooth', 1.0},
    {'bluegem',     0.2},
})

local WAKE_TO_FOLLOW_DISTANCE = 8
local SLEEP_NEAR_HOME_DISTANCE = 10
local SHARE_TARGET_DIST = 30
local HOME_TELEPORT_DIST = 30

local NO_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or (inst.components.follower and inst.components.follower.leader and not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE))
end

local function ShouldSleep(inst)
    return inst:HasTag("pet_hound")
        and not TheWorld.state.isday
        and not (inst.components.combat and inst.components.combat.target)
        and not (inst.components.burnable and inst.components.burnable:IsBurning())
        and (not inst.components.homeseeker or inst:IsNear(inst.components.homeseeker.home, SLEEP_NEAR_HOME_DISTANCE))
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function retargetfn(inst)
    return FindEntity(
            inst,
            inst:HasTag("pet_hound") and TUNING.HOUND_FOLLOWER_TARGET_DIST or TUNING.HOUND_TARGET_DIST,
            function(guy)
                return inst.components.combat:CanTarget(guy)
            end,
            nil,
            { "wall", "houndmound", "hound", "houndfriend" }
        )
end

local function KeepTarget(inst, target)
    return inst.components.combat:CanTarget(target) and (not inst:HasTag("pet_hound") or inst:IsNear(target, TUNING.HOUND_FOLLOWER_TARGET_KEEP))
end

local function IsNearMoonBase(inst, dist)
    local moonbase = inst.components.entitytracker:GetEntity("moonbase")
    return moonbase == nil or inst:IsNear(moonbase, dist)
end

local function moon_retargetfn(inst)
    return IsNearMoonBase(inst, TUNING.MOONHOUND_AGGRO_DIST)
        and FindEntity(
                inst,
                TUNING.HOUND_FOLLOWER_TARGET_DIST,
                function(guy)
                    return inst.components.combat:CanTarget(guy)
                end,
                nil,
                { "wall", "houndmound", "hound", "houndfriend", "moonbeast" }
            )
        or nil
end

local function moon_keeptargetfn(inst, target)
    return IsNearMoonBase(inst, TUNING.MOONHOUND_RETURN_DIST)
        and inst.components.combat:CanTarget(target)
        and inst:IsNear(target, TUNING.HOUND_FOLLOWER_TARGET_KEEP)
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("hound") or dude:HasTag("houndfriend") and not dude.components.health:IsDead() end, 5)
end

local function OnAttackOther(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST, function(dude) return dude:HasTag("hound") or dude:HasTag("houndfriend") and not dude.components.health:IsDead() end, 5)
end

local function GetReturnPos(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local rad = 2
    local angle = math.random() * 2 * PI
    return x + rad * math.cos(angle), y, z - rad * math.sin(angle)
end

local function DoReturn(inst)
    --print("DoReturn", inst)
    if inst.components.homeseeker ~= nil and inst.components.homeseeker:HasHome() then
        if inst:HasTag("pet_hound") then
            if inst.components.homeseeker.home:IsAsleep() and not inst:IsNear(inst.components.homeseeker.home, HOME_TELEPORT_DIST) then
                inst.Physics:Teleport(GetReturnPos(inst.components.homeseeker.home))
            end
        elseif inst.components.homeseeker.home.components.childspawner ~= nil then
            inst.components.homeseeker.home.components.childspawner:GoHome(inst)
        end
    end
end

local function OnEntitySleep(inst)
    --print("OnEntitySleep", inst)
    if not TheWorld.state.isday then
        DoReturn(inst)
    end
end

local function OnStopDay(inst)
    --print("OnStopDay", inst)
    if inst:IsAsleep() then
        DoReturn(inst)
    end
end

local function OnSpawnedFromHaunt(inst)
    if inst.components.hauntable ~= nil then
        inst.components.hauntable:Panic()
    end
end

local function OnSave(inst, data)
    data.ispet = inst:HasTag("pet_hound") or nil
    --print("OnSave", inst, data.ispet)
end

local function OnLoad(inst, data)
    --print("OnLoad", inst, data.ispet)
    if data ~= nil and data.ispet then
        inst:AddTag("pet_hound")
        if inst.sg ~= nil then
            inst.sg:GoToState("idle")
        end
    end
end

local function fncommon(build, morphlist, custombrain, tag)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)

    inst.DynamicShadow:SetSize(2.5, 1.5)
    inst.Transform:SetFourFaced()

    inst:AddTag("scarytoprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("hound")
    inst:AddTag("canbestartled")

    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.AnimState:SetBank("hound")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("spawnfader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.HOUND_SPEED
    inst:SetStateGraph("SGhound")

    inst:SetBrain(custombrain or brain)

    inst:AddComponent("follower")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    inst.components.eater:SetCanEatHorrible()

    inst.components.eater.strongstomach = true -- can eat monster meat!

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.HOUND_HEALTH)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.HOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.HOUND_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound("dontstarve/creatures/hound/hurt")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('hound')

    inst:AddComponent("inspectable")

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    if morphlist ~= nil then
        MakeHauntableChangePrefab(inst, morphlist)
        inst:ListenForEvent("spawnedfromhaunt", OnSpawnedFromHaunt)
    else
        MakeHauntablePanic(inst)
    end

    inst:WatchWorldState("stopday", OnStopDay)
    inst.OnEntitySleep = OnEntitySleep

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)

    return inst
end

local function fndefault()
    local inst = fncommon("hound", { "firehound", "icehound" })

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumFreezableCharacter(inst, "hound_body")
    MakeMediumBurnableCharacter(inst, "hound_body")
    return inst
end

local function PlayFireExplosionSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/firehound_explo")
end

local function fnfire()
    local inst = fncommon("hound_red", { "hound", "icehound" })

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumFreezableCharacter(inst, "hound_body")
    inst.components.freezable:SetResistance(4) --because fire

    inst.components.combat:SetDefaultDamage(TUNING.FIREHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.FIREHOUND_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.FIREHOUND_SPEED
    inst.components.health:SetMaxHealth(TUNING.FIREHOUND_HEALTH)
    inst.components.lootdropper:SetChanceLootTable('hound_fire')

    inst:ListenForEvent("death", PlayFireExplosionSound)

    return inst
end

local function DoIceExplosion(inst)
    if inst.components.freezable == nil then
        MakeMediumFreezableCharacter(inst, "hound_body")
    end
    inst.components.freezable:SpawnShatterFX()
    inst:RemoveComponent("freezable")
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 4, { "freezable" }, NO_TAGS)
    for i, v in pairs(ents) do
        if v.components.freezable ~= nil then
            v.components.freezable:AddColdness(2)
        end
    end

    inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/icehound_explo")
end

local function fncold()
    local inst = fncommon("hound_ice", { "firehound", "hound" })

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumBurnableCharacter(inst, "hound_body")

    inst.components.combat:SetDefaultDamage(TUNING.ICEHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ICEHOUND_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.ICEHOUND_SPEED
    inst.components.health:SetMaxHealth(TUNING.ICEHOUND_HEALTH)
    inst.components.lootdropper:SetChanceLootTable('hound_cold')

    inst:ListenForEvent("death", DoIceExplosion)

    return inst
end

local function OnMoonPetrify(inst)
    if not inst.components.health:IsDead() and (not inst.sg:HasStateTag("busy") or inst:IsAsleep()) then
        local x, y, z = inst.Transform:GetWorldPosition()
        local rot = inst.Transform:GetRotation()
        inst:Remove()
        local gargoyle = SpawnPrefab(gargoyles[math.random(#gargoyles)])
        gargoyle.Transform:SetPosition(x, y, z)
        gargoyle.Transform:SetRotation(rot)
        gargoyle:Petrify()
    end
end

local function OnMoonTransformed(inst, data)
    if data.old.prefab ~= "hound" then
        SpawnPrefab("small_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    inst.sg:GoToState("taunt")
end

local function fnmoon()
    local inst = fncommon("hound", nil, moonbrain, "moonbeast")

    inst:SetPrefabNameOverride("hound")

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumFreezableCharacter(inst, "hound_body")
    MakeMediumBurnableCharacter(inst, "hound_body")

    inst.components.freezable:SetDefaultWearOffTime(TUNING.MOONHOUND_FREEZE_WEAR_OFF_TIME)

    inst.components.combat:SetDefaultDamage(TUNING.MOONHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.MOONHOUND_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, moon_retargetfn)
    inst.components.combat:SetKeepTargetFunction(moon_keeptargetfn)
    inst.components.locomotor.runspeed = TUNING.MOONHOUND_SPEED
    inst.components.health:SetMaxHealth(TUNING.MOONHOUND_HEALTH)

    inst:AddComponent("entitytracker")

    inst:ListenForEvent("moonpetrify", OnMoonPetrify)
    inst:ListenForEvent("moontransformed", OnMoonTransformed)

    return inst
end

local function fnfiredrop()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeLargeBurnable(inst, 6 + math.random() * 6)
    MakeLargePropagator(inst)

    --Remove the default handlers that toggle persists flag
    inst.components.burnable:SetOnIgniteFn(nil)
    inst.components.burnable:SetOnExtinguishFn(inst.Remove)
    inst.components.burnable:Ignite()

    return inst
end

return Prefab("hound", fndefault, assets, prefabs),
        Prefab("firehound", fnfire, assets, prefabs),
        Prefab("icehound", fncold, assets, prefabs),
        Prefab("moonhound", fnmoon, assets, moonprefabs),
        --fx
        Prefab("houndfire", fnfiredrop, assets, prefabs)
