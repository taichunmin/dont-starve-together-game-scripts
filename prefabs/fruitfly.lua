local brain = require("brains/fruitflybrain")
local friendlybrain = require("brains/friendlyfruitflybrain")

local sounds = {
    flap = "farming/creatures/lord_fruitfly/LP",
    hurt = "farming/creatures/lord_fruitfly/hit",
    attack = "farming/creatures/lord_fruitfly/attack",
    die = "farming/creatures/lord_fruitfly/die",
    die_ground = "farming/creatures/lord_fruitfly/hit",
    sleep = "farming/creatures/lord_fruitfly/sleep",
    buzz = "farming/creatures/lord_fruitfly/hit",
    spin = "farming/creatures/lord_fruitfly/spin",
    plant_attack = "farming/creatures/lord_fruitfly/plant_attack"
}

local minionsounds = {
    flap = "farming/creatures/minion_fruitfly/LP",
    hurt = "farming/creatures/minion_fruitfly/hit",
    attack = "farming/creatures/minion_fruitfly/attack",
    die = "farming/creatures/minion_fruitfly/die",
    die_ground = "farming/creatures/minion_fruitfly/hit",
    sleep = "farming/creatures/minion_fruitfly/sleep",
    buzz = "farming/creatures/minion_fruitfly/hit",
    spin = "farming/creatures/minion_fruitfly/spin",
    plant_attack = "farming/creatures/minion_fruitfly/plant_attack"
}

local friendlysounds = {
    flap = "farming/creatures/fruitfly/LP",
    hurt = "farming/creatures/fruitfly/hit",
    die = "farming/creatures/fruitfly/die",
    die_ground = "farming/creatures/fruitfly/die",
    sleep = "farming/creatures/fruitfly/sleep",
    buzz = "farming/creatures/fruitfly/hit",
}

local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
require "prefabs/veggies"
local function pickseed()
    local season = TheWorld.state.season
    local weights = {}
    local season_mod = TUNING.SEED_WEIGHT_SEASON_MOD

    for k, v in pairs(VEGGIES) do
        weights[k] = v.seed_weight * ((PLANT_DEFS[k] and PLANT_DEFS[k].good_seasons[season]) and season_mod or 1)
    end

    return weighted_random_choice(weights).."_seeds"
end

SetSharedLootTable("lordfruitfly",
{
    {'plantmeat',             1.00},
})

local function common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.Transform:SetFourFaced()

    MakeGhostPhysics(inst, 1, 0.5)

    inst.AnimState:SetBank("fruitfly")

    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("insect")
    inst:AddTag("small")

    return inst
end

local function common_server(inst)
    inst:AddComponent("inspectable")

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 6
    inst.components.locomotor.pathcaps = {allowocean = true}

    MakeMediumFreezableCharacter(inst, "fruit2")
    MakeMediumBurnableCharacter(inst, "fruit2")

    MakeHauntablePanic(inst)

    return inst
end

local function OnLoad(inst, data)
    if data then
        inst.hascausedhavoc = data.hascausedhavoc
    end
end

local function OnSave(inst)
    local data = {}
    data.hascausedhavoc = inst.hascausedhavoc
    return data
end

local function LordLootSetupFunction(lootdropper)
    lootdropper.chanceloot = nil
    if not TheSim:FindFirstEntityWithTag("friendlyfruitfly") then
        lootdropper:AddChanceLoot("fruitflyfruit", 1.0)
    else
        for i = 1, 4 do
            lootdropper:AddChanceLoot(pickseed(), 1.0)
            lootdropper:AddChanceLoot(pickseed(), 0.25)
        end
    end
end

local function KeepTargetFn(inst, target)
    local p1x, p1y, p1z = inst.components.knownlocations:GetLocation("home"):Get()
    local p2x, p2y, p2z = target.Transform:GetWorldPosition()
    local maxdist = TUNING.LORDFRUITFLY_DEAGGRO_DIST
    return inst.components.combat:CanTarget(target) and distsq(p1x, p1z, p2x, p2z) < maxdist * maxdist
end

local RETARGET_MUSTTAGS = { "player" }
local RETARGET_CANTTAGS = { "playerghost" }
local function RetargetFn(inst)
    return not inst.planttarget and not inst.soiltarget and
        FindEntity(inst, TUNING.LORDFRUITFLY_TARGETRANGE, function(guy) return inst.components.combat:CanTarget(guy) end, RETARGET_MUSTTAGS, RETARGET_CANTTAGS) or nil
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker == nil then
        return
    end
    inst.planttarget = nil
    inst.soiltarget = nil
    inst.components.combat:SetTarget(attacker)
end

local function OnDead()
    TheWorld:PushEvent("ms_lordfruitflykilled")
end

local function RememberKnownLocation(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.components.knownlocations:RememberLocation("home", Vector3(x, 20, z), true)
end

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

local function NumFruitFliesToSpawn(inst)
    local numFruitFlies = TUNING.LORDFRUITFLY_FRUITFLY_AMOUNT
    local numFollowers = inst.components.leader:CountFollowers()

    local num = math.min(numFollowers+numFruitFlies/2, numFruitFlies) -- only spawn half the fruit flies per buzz
    num = (math.log(num)/0.4)+1 -- 0.4 is approx log(1.5)
    num = RoundToNearest(num, 1)

    return num - numFollowers
end

local function IsTargetedByOther(inst, self, target)
    if inst ~= self and (target == inst.planttarget or target == inst.soiltarget) then
        return true
    end
    for follower in pairs(inst.components.leader.followers) do
        if follower ~= self and (target == follower.planttarget or target == follower.soiltarget) then
            return true
        end
    end
    return false
end

local assets =
{
    Asset("ANIM", "anim/fruitfly.zip"),
    Asset("ANIM", "anim/fruitfly_evil.zip"),
}

local prefabs =
{
    "fruitflyfruit",
    "fruitfly",
}

local function fn()
    local inst = common()

    inst.DynamicShadow:SetSize(1 * 2, 0.375 * 2)

    inst.sounds = sounds

    inst.AnimState:SetBuild("fruitfly_evil")
    inst.AnimState:PlayAnimation("idle")

    inst.Transform:SetScale(2, 2, 2)

    inst:AddTag("lordfruitfly")
    inst:AddTag("fruitfly")
    inst:AddTag("hostile")
    inst:AddTag("epic")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetStateGraph("SGfruitfly")
    inst:SetBrain(brain)

    common_server(inst)

    inst:AddComponent("leader")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "fruit2"
    inst.components.combat:SetAttackPeriod(TUNING.LORDFRUITFLY_ATTACK_PERIOD)
    inst.components.combat:SetDefaultDamage(TUNING.LORDFRUITFLY_DAMAGE)
    inst.components.combat:SetRange(TUNING.LORDFRUITFLY_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.LORDFRUITFLY_HEALTH)

    inst:AddComponent("knownlocations")
    inst:DoTaskInTime(0, RememberKnownLocation)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("lordfruitfly")
    inst.components.lootdropper:SetLootSetupFn(LordLootSetupFunction)
    LordLootSetupFunction(inst.components.lootdropper)

    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL

    --divide by scale for accurate walkspeed
    inst.components.locomotor.walkspeed = TUNING.LORDFRUITFLY_WALKSPEED/2

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDead)

    inst.NumFruitFliesToSpawn = NumFruitFliesToSpawn
    inst.IsTargetedByOther = IsTargetedByOther

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    return inst
end

local function CanTargetAndAttack(inst)
    return inst.components.follower.leader == nil and inst.hascausedhavoc
end

local function ShouldKeepTarget(inst, target)
    return inst:CanTargetAndAttack() and inst:IsNear(target, TUNING.FRUITFLY_DEAGGRO_DIST) or false
end

local function MiniRetargetFn(inst)
    return inst:CanTargetAndAttack() and FindEntity(inst, TUNING.FRUITFLY_TARGETRANGE, function(guy) return inst.components.combat:CanTarget(guy) end, RETARGET_MUSTTAGS, RETARGET_CANTTAGS) or nil
end

local function MiniOnAttacked(inst, data)
    if inst:CanTargetAndAttack() then
        OnAttacked(inst, data)
    end
end

local function LootSetupFunction(lootdropper)
    lootdropper.chanceloot = nil
    lootdropper:AddChanceLoot("seeds", 0.1)
end

local miniassets =
{
    Asset("ANIM", "anim/fruitfly.zip"),
    Asset("ANIM", "anim/fruitfly_evil_minion.zip"),
}

local function minifn()
    local inst = common()

    inst.DynamicShadow:SetSize(1 * 0.5, 0.375 * 0.5)

    inst.sounds = minionsounds

    inst.AnimState:SetBuild("fruitfly_evil_minion")
    inst.AnimState:PlayAnimation("idle")

    inst.Transform:SetScale(0.5, 0.5, 0.5)

    inst:AddTag("fruitfly")
    inst:AddTag("hostile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    common_server(inst)

    inst:AddComponent("follower")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "fruit2"
    inst.components.combat.battlecryenabled = false
    inst.components.combat:SetAttackPeriod(TUNING.FRUITFLY_ATTACK_PERIOD)
    inst.components.combat:SetDefaultDamage(TUNING.FRUITFLY_DAMAGE)
    inst.components.combat:SetRange(TUNING.FRUITFLY_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(3, MiniRetargetFn)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.FRUITFLY_HEALTH)

    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(LootSetupFunction)
    LootSetupFunction(inst.components.lootdropper)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_TINY

    --divide by scale for accurate walkspeed
    inst.components.locomotor.walkspeed = TUNING.FRUITFLY_WALKSPEED/0.5

    inst:SetBrain(brain)
    inst:SetStateGraph("SGfruitfly")

    inst:ListenForEvent("attacked", MiniOnAttacked)

    inst.CanTargetAndAttack = CanTargetAndAttack

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    return inst
end

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local function FriendlyShouldWakeUp(inst)
    return DefaultWakeTest(inst)
        or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function FriendlyShouldSleep(inst)
    return DefaultSleepTest(inst)
        and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE)
end

local function FriendlyShouldKeepTarget()
    return false
end

local function OnStopFollowing(inst)
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
    if inst.components.follower.leader:HasTag("fruitflyfruit") then
        inst:AddTag("companion")
    end
end

local friendlyassets =
{
    Asset("ANIM", "anim/fruitfly.zip"),
    Asset("ANIM", "anim/fruitfly_good.zip"),
}

local function friendlyfn()
    local inst = common()

    inst.DynamicShadow:SetSize(1 * 0.75, 0.375 * 0.75)

    inst.sounds = friendlysounds

    inst.AnimState:SetBuild("fruitfly_good")
    inst.AnimState:PlayAnimation("idle")

    inst.Transform:SetScale(0.75, 0.75, 0.75)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("friendlyfruitfly.png")
    inst.MiniMapEntity:SetPriority(5)

    inst:AddTag("friendlyfruitfly")
    inst:AddTag("cattoyairborne")

    MakeInventoryFloatable(inst, "med")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    common_server(inst)

    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "fruit2"
    inst.components.combat:SetKeepTargetFunction(FriendlyShouldKeepTarget)

    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(FriendlyShouldSleep)
    inst.components.sleeper:SetWakeTest(FriendlyShouldWakeUp)

    inst:AddComponent("lootdropper")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY

    inst:SetBrain(friendlybrain)
    inst:SetStateGraph("SGfruitfly")

    return inst
end

local fruitassets =
{
    Asset("ANIM", "anim/fruitflyfruit.zip"),
    Asset("INV_IMAGE", "fruitflyfruit_dead"),
}

local fruitprefabs =
{
    "friendlyfruitfly",
}

local function OnLoseChild(inst, child)
    if not inst:HasTag("fruitflyfruit") then
        return
    end

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst:AddTag("show_spoilage")
    inst.components.inventoryitem:ChangeImageName("fruitflyfruit_dead")
    inst.AnimState:PlayAnimation("idle_dead")
    inst:RemoveTag("fruitflyfruit")

    --V2C: I think this is trying to refresh the inventory tile
    --     because show_spoilage doesn't refresh automatically.
    --     Plz document hacks like this in the future -_ -""
    if inst.components.inventoryitem:IsHeld() then
        local owner = inst.components.inventoryitem.owner
        inst.components.inventoryitem:RemoveFromOwner(true)
        if owner.components.container ~= nil then
            owner.components.container.ignoresound = true
            owner.components.container:GiveItem(inst)
            owner.components.container.ignoresound = false
        elseif owner.components.inventory ~= nil then
            owner.components.inventory.ignoresound = true
            owner.components.inventory:GiveItem(inst)
            owner.components.inventory.ignoresound = false
        end
    end

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
end

local function getstatus(inst)
    return not inst:HasTag("fruitflyfruit") and "DEAD" or nil
end

local function OnPreLoad(inst, data)
    if data ~= nil and data.deadchild then
        OnLoseChild(inst)
    end
end

local function OnSave(inst, data)
    data.deadchild = not inst:HasTag("fruitflyfruit") or nil
end

local function SpawnFriendlyFruitFly(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local offset = FindWalkableOffset(Vector3(x, y, z), math.random() * 2 * PI, 35, 12, true)
    local fruitfly = SpawnPrefab("friendlyfruitfly")
    if fruitfly ~= nil then
        fruitfly.Physics:Teleport(offset ~= nil and offset.x + x or x, 0, offset ~= nil and offset.z + z or z)
        fruitfly:FacePoint(x, y, z)
        return fruitfly
    end
end

local function OnInit(inst)
    if inst:HasTag("fruitflyfruit") then
        --Rebind Friendly Fruit Fly
        local fruitfly = TheSim:FindFirstEntityWithTag("friendlyfruitfly") or SpawnFriendlyFruitFly(inst)
        if fruitfly ~= nil and
            fruitfly.components.health ~= nil and
            not fruitfly.components.health:IsDead() and
            fruitfly.components.follower.leader ~= inst then
                fruitfly.components.follower:SetLeader(inst)
        end
    end
end

local function fruitfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("fruitflyfruit")
    inst.AnimState:SetBuild("fruitflyfruit")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("fruitflyfruit")
    inst:AddTag("nonpotatable")
    inst:AddTag("irreplaceable")

    MakeInventoryFloatable(inst, "med", nil, 0.7)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("leader")
    inst.components.leader.onremovefollower = OnLoseChild
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
    inst:AddComponent("inventoryitem")


    MakeHauntableLaunch(inst)

    inst.OnPreLoad = OnPreLoad
    inst.OnSave = OnSave

    inst:DoTaskInTime(0, OnInit)

    return inst
end

return Prefab("lordfruitfly", fn, assets, prefabs),
    Prefab("fruitfly", minifn, miniassets),
    Prefab("friendlyfruitfly", friendlyfn, friendlyassets),
    Prefab("fruitflyfruit", fruitfn, fruitassets, fruitprefabs)