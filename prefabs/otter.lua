local assets =
{
    Asset("ANIM", "anim/otter_basic.zip"),
    Asset("ANIM", "anim/otter_basic_water.zip"),
    Asset("ANIM", "anim/otter_build.zip"),
}

local prefabs =
{
    "boatpatch_kelp",
}

local brain = require("brains/otterbrain")

SetSharedLootTable("otter",
{
    { "meat",            1.00 },
    { "smallmeat",       1.00 },
    { "messagebottle",   0.05 },
})

-- Non-component methods
local function TossFish(inst, item)
    if not item:HasTag("oceanfishable_creature") then
        return false
    end

    local item_loots = (item.fish_def and item.fish_def.loot) or nil
    if not item_loots then
        return false
    end

    local ix, iy, iz = item.Transform:GetWorldPosition()
    local owner = item
    for _, loot_prefab in pairs(item_loots) do
        local loot = SpawnPrefab(loot_prefab)
        loot.Transform:SetPosition(ix, iy, iz)
        Launch2(loot, inst, 2, 0, 2, 0)
    end
    owner:Remove()

    inst.components.timer:StartTimer("fished_recently", 5)

    return true
end

-- Amphibious Creature Functions
local function EnterWater(inst)
    inst.hop_distance = inst.components.locomotor.hop_distance
    inst.components.locomotor.hop_distance = TUNING.OTTER_WATER_HOP_DISTANCE
    inst.DynamicShadow:Enable(false)
end

local function ExitWater(inst)
    inst.components.locomotor.hop_distance = inst.hop_distance or TUNING.DEFAULT_LOCOMOTOR_HOP_DISTANCE
    inst.hop_distance = nil
    inst.DynamicShadow:Enable(true)
end

-- Combat Functions
local RETARGET_CANT_TAGS = {"FX", "INLIMBO", "NOCLICK", "notarget", "playerghost", "wall"}
local RETARGET_ONEOF_TAGS = {"bird", "cookiecutter", "squid"}
local function Retarget(inst)
    return FindEntity(
        inst,
        0.75 * TUNING.OTTER_KEEPTARGET_DISTANCE,
        function(target)
            return inst.components.combat:CanTarget(target)
        end,
        nil,
        RETARGET_CANT_TAGS,
        RETARGET_ONEOF_TAGS
    )
end

local function KeepTarget(inst, target)
    return inst:IsNear(target, TUNING.OTTER_KEEPTARGET_DISTANCE)
end

-- Sleep Functions
local function ShouldSleep(inst)
    -- TODO @stevenm stubbing this in in case we want optional behaviour
    return DefaultSleepTest(inst)
end

local function ShouldWakeUp(inst)
    -- TODO @stevenm stubbing this in in case we want optional behaviour
    return DefaultWakeTest(inst)
end

-- Thief
local function OnStoleItem(inst, victim_object, item)
end

-- Event Listeners
local function on_new_target(inst, data)
    -- TODO @stevenm stubbing this in in case we want optional behaviour
end

local function is_ally_a_valid_otter(ally)
    return not (ally.components.health ~= nil and ally.components.health:IsDead())
        and (ally:HasTag("otter"))
end

local function on_attacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(
        data.attacker,
        TUNING.OTTER_SHARETARGET_DISTANCE,
        is_ally_a_valid_otter,
        1)
end

local function on_attack_other(inst, data)
    -- TODO @stevenm evaluate if this actually plays nicely (and if we'll actually otter in pairs)
    inst.components.combat:ShareTarget(
        data.target,
        TUNING.OTTER_SHARETARGET_DISTANCE,
        is_ally_a_valid_otter,
        1)
end

local function on_item_get(inst, data)
    local picked_up_item = (data and data.item)
    if not picked_up_item then return end

    local timer = inst.components.timer
    if not timer:TimerExists("dump_loot_at_home") then
        timer:StartTimer("dump_loot_at_home", 10)
    else
        timer:SetTimeLeft("dump_loot_at_home", 10)
    end
end

--
local function PostInitialize(inst)
    -- Have a fallback if this gets spawned in a way other than a spawner
    if not inst.components.knownlocations:GetLocation("home") then
        inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
    end
end

--
local PATHING_CAPABILITIES = {allowocean = true}
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, 0.4)

    inst.DynamicShadow:SetSize(4.0, 2.5)

    inst.Transform:SetSixFaced()

    inst:AddTag("hostile")
    inst:AddTag("likewateroffducksback")
    inst:AddTag("monster")
    inst:AddTag("scarytooceanprey")
    inst:AddTag("otter")

    inst.AnimState:SetBank("otter_basics")
    inst.AnimState:SetBuild("otter_build")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.TossFish = TossFish

    --
    local amphibiouscreature = inst:AddComponent("amphibiouscreature")
    amphibiouscreature:SetBanks("otter_basics", "otter_basics_water")
    amphibiouscreature:SetEnterWaterFn(EnterWater)
    amphibiouscreature:SetExitWaterFn(ExitWater)

    --
    local combat = inst:AddComponent("combat")
    combat:SetDefaultDamage(TUNING.OTTER_DAMAGE)
    combat:SetAttackPeriod(TUNING.OTTER_ATTACK_PERIOD)
    combat:SetRetargetFunction(3, Retarget)
    combat:SetKeepTargetFunction(KeepTarget)
    combat:SetHurtSound("meta4/otter/vo_hit_f0")
    combat:SetRange(TUNING.OTTER_ATTACK_RANGE)

    --
    local eater = inst:AddComponent("eater")
    eater:SetDiet({FOODTYPE.MEAT}, {FOODTYPE.MEAT})
    eater:SetCanEatHorrible()
    eater:SetStrongStomach(true)

    --
    local embarker = inst:AddComponent("embarker")
    embarker.embark_speed = TUNING.OTTER_RUNSPEED

    --
    local health = inst:AddComponent("health")
    health:SetMaxHealth(TUNING.OTTER_HEALTH)

    --
    inst:AddComponent("inspectable")

    --
    local inventory = inst:AddComponent("inventory")
    inventory.maxslots = TUNING.OTTER_MAX_INVENTORY_ITEMS -- To make it easier to avoid getting stuck trying to pick stuff up.

    --
    inst:AddComponent("knownlocations")

    --
    local locomotor = inst:AddComponent("locomotor")
    locomotor.runspeed = TUNING.OTTER_RUNSPEED
    locomotor.walkspeed = TUNING.OTTER_WALKSPEED
    locomotor.skipHoldWhenFarFromHome = true -- TODO @stevenm see how this works if they're going to deviate from their homes a lot
    locomotor:SetAllowPlatformHopping(true)
    locomotor.pathcaps = PATHING_CAPABILITIES

    --
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetChanceLootTable("otter")

    --
    local sleeper = inst:AddComponent("sleeper")
    sleeper:SetResistance(3) -- TODO @stevenm should sleep be a good way of dealing with these...?
    sleeper.testperiod = GetRandomWithVariance(6, 2)
    sleeper:SetSleepTest(ShouldSleep)
    sleeper:SetWakeTest(ShouldWakeUp)

    --
    local thief = inst:AddComponent("thief")
    thief:SetOnStolenFn(OnStoleItem)

    --
    local timer = inst:AddComponent("timer")
    timer:StartTimer("fished_recently", 5)

    --
    --inst:AddComponent("sanityaura").aura = -TUNING.SANITYAURA_MED

    --
    MakeHauntablePanic(inst)

    --
    MakeMediumFreezableCharacter(inst)

    --
    MakeMediumBurnableCharacter(inst)

    --
    inst:ListenForEvent("newcombattarget", on_new_target)
    inst:ListenForEvent("attacked", on_attacked)
    inst:ListenForEvent("onattackother", on_attack_other)
    inst:ListenForEvent("gotnewitem", on_item_get)

    --
    inst:SetBrain(brain)
    inst:SetStateGraph("SGotter")

    --
    inst:DoTaskInTime(0, PostInitialize)

    --
    return inst
end

return Prefab("otter", fn, assets, prefabs)