local brain = require "brains/koalefantbrain"

local assets =
{
    Asset("ANIM", "anim/koalefant_basic.zip"),
    Asset("ANIM", "anim/koalefant_actions.zip"),
    --Asset("ANIM", "anim/koalefant_build.zip"),
    Asset("ANIM", "anim/koalefant_summer_build.zip"),
    Asset("ANIM", "anim/koalefant_winter_build.zip"),
    Asset("SOUND", "sound/koalefant.fsb"),
}

local prefabs =
{
    "meat",
    "poop",
    "trunk_summer",
    "trunk_winter",
}

local loot_summer = {"meat","meat","meat","meat","meat","meat","meat","meat","trunk_summer"}
local loot_winter = {"meat","meat","meat","meat","meat","meat","meat","meat","trunk_winter"}
local loot_fire = {"meat","meat","meat","meat","meat","meat","meat","meat","trunk"}
--V2C: "trunk" is a dummy loot prefab that should be converted to "trunk_cooked"

function SimulateKoalefantDrops(inst) -- Intentionally global.
    -- NOTES(JBK): This simulates a koalefant being spawned and slain followed up with meats eaten at random.
    -- 'inst' must have lootdropper already.
    -- Dependencies of "meat", "trunk_winter", "trunk_summer" are expected in the prefabs table for any prefab using this.
    for i = 1, 2 do
        local loot = SpawnPrefab("meat")
        inst.components.lootdropper:FlingItem(loot)
    end
    if math.random() < 0.5 then
        local loot = SpawnPrefab(TheWorld.state.iswinter and "trunk_winter" or "trunk_summer")
        inst.components.lootdropper:FlingItem(loot)
    end
end

local WAKE_TO_RUN_DISTANCE = 10
local SLEEP_NEAR_ENEMY_DISTANCE = 14

local function ShouldWakeUp(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    return DefaultWakeTest(inst) or IsAnyPlayerInRange(x, y, z, WAKE_TO_RUN_DISTANCE)
end

local function ShouldSleep(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    return DefaultSleepTest(inst) and not IsAnyPlayerInRange(x, y, z, SLEEP_NEAR_ENEMY_DISTANCE)
end

local function KeepTarget(inst, target)
    return inst:IsNear(target, TUNING.KOALEFANT_CHASE_DIST)
end

local function ShareTargetFn(dude)
    return dude:HasTag("koalefant") and not dude:HasTag("player") and not dude.components.health:IsDead()
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, ShareTargetFn, 5)
end

local function lootsetfn(lootdropper)
    if lootdropper.inst.components.burnable ~= nil and lootdropper.inst.components.burnable:IsBurning() or lootdropper.inst:HasTag("burnt") then
        lootdropper:SetLoot(loot_fire)
    end
end

local function create_base(build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .75)

    inst.DynamicShadow:SetSize(4.5, 2)
    inst.Transform:SetSixFaced()

    inst:AddTag("koalefant")
    inst:AddTag("animal")
    inst:AddTag("largecreature")

    --saltlicker (from saltlicker component) added to pristine state for optimization
    inst:AddTag("saltlicker")

    inst.AnimState:SetBank("koalefant")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- Let the lootdropper take care of adding these dependencies correctly.
    inst.scrapbook_deps = {}

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "beefalo_body"
    inst.components.combat:SetDefaultDamage(TUNING.KOALEFANT_DAMAGE)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.KOALEFANT_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(lootsetfn)

    inst:AddComponent("inspectable")

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()

    inst:AddComponent("timer")
    inst:AddComponent("saltlicker")
    inst.components.saltlicker:SetUp(TUNING.SALTLICK_KOALEFANT_USES)

    MakeLargeBurnableCharacter(inst, "beefalo_body")
    MakeLargeFreezableCharacter(inst, "beefalo_body")

    MakeHauntablePanic(inst)

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 1.5
    inst.components.locomotor.runspeed = 7

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGkoalefant")
    return inst
end

local function create_summer()
    local inst = create_base("koalefant_summer_build")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.lootdropper:SetLoot(loot_summer)

    return inst
end

local function create_winter()
    local inst = create_base("koalefant_winter_build")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.lootdropper:SetLoot(loot_winter)

    return inst
end

return Prefab("koalefant_summer", create_summer, assets, prefabs),
    Prefab("koalefant_winter", create_winter, assets, prefabs)
