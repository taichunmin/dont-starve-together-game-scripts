local RuinsRespawner = require "prefabs/ruinsrespawner"

local assets =
{
    Asset("ANIM", "anim/rook.zip"),
    Asset("ANIM", "anim/rook_build.zip"),
    Asset("ANIM", "anim/rook_rhino.zip"),
    Asset("SOUND", "sound/chess.fsb"),
    Asset("MINIMAP_IMAGE", "atrium_key"),
    Asset("SCRIPT", "scripts/prefabs/ruinsrespawner.lua"),
}

local prefabs =
{
    "meat",
    "minotaurhorn",
    "minotaurchestspawner",
    "atrium_key",
    "collapse_small",
    "minotaur_ruinsrespawner_inst",
}

local prefabs_chest =
{
    "minotaurchest",
    "atrium_key",
}

local brain = require "brains/minotaurbrain"

SetSharedLootTable('minotaur',
{
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"meat",        1.00},
    {"minotaurhorn",1.00},
})

local chest_loot = 
{
	{item = {"armorruins", "ruinshat"}, count = 1},
	{item = {"ruins_bat", "orangestaff", "yellowstaff"}, count = 1},
	{item = {"firestaff", "icestaff", "telestaff", "multitool_axe_pickaxe"}, count = 1},
	{item = {"thulecite"}, count = {5, 12}},
	{item = {"thulecite_pieces"}, count = {12, 36}},
	{item = {"redgem", "bluegem", "purplegem"}, count = {3, 5}},
	{item = {"yellowgem", "orangegem", "greengem"}, count = {1, 3}},
	{item = {"nightmarefuel"}, count = {5, 8}},
	{item = {"gears"}, count = {3, 6}},
}

for _,v in ipairs(chest_loot) do
	for _,item in ipairs(v.item) do
        table.insert(prefabs_chest, item)
	end
end

local SLEEP_DIST_FROMHOME_SQ = 20 * 20
local SLEEP_DIST_FROMTHREAT = 40
local MAX_CHASEAWAY_DIST_SQ = 40 * 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function BasicWakeCheck(inst)
    return (inst.components.combat ~= nil and inst.components.combat.target ~= nil)
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning() ~= nil)
        or (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() ~= nil)
        or GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT) ~= nil
end

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil
        and inst:GetDistanceSqToPoint(homePos:Get()) < SLEEP_DIST_FROMHOME_SQ
        and not BasicWakeCheck(inst)
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (homePos ~= nil and
            inst:GetDistanceSqToPoint(homePos:Get()) >= SLEEP_DIST_FROMHOME_SQ)
        or BasicWakeCheck(inst)
end

local function Retarget(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return not (homePos ~= nil and
                inst:GetDistanceSqToPoint(homePos:Get()) >= MAX_CHASEAWAY_DIST_SQ)
        and FindEntity(
            inst,
            TUNING.MINOTAUR_TARGET_DIST,
            function(guy)
                return not (inst.components.follower ~= nil and inst.components.follower.leader == guy)
                       and inst.components.combat:CanTarget(guy)
            end,
            { "_combat" },
            { "chess", "INLIMBO" },
            { "character", "monster" }
        )
        or nil
end

local function KeepTarget(inst, target)
    if inst.sg ~= nil and inst.sg:HasStateTag("running") then
        return true
    end
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil and inst:GetDistanceSqToPoint(homePos:Get()) < MAX_CHASEAWAY_DIST_SQ
end

local function IsChess(dude)
    return dude:HasTag("chess")
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and attacker:HasTag("chess") then
        return
    end
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, IsChess, MAX_TARGET_SHARES)
end

local function OnDeath(inst)
    AwardRadialAchievement("minotaur_killed", inst:GetPosition(), TUNING.ACHIEVEMENT_RADIUS_FOR_GIANT_KILL)
end

local function ClearRecentlyCharged(inst, other)
    inst.recentlycharged[other] = nil
end

local function onothercollide(inst, other)
    if not other:IsValid() or inst.recentlycharged[other] then
        return
    elseif other:HasTag("smashable") and other.components.health ~= nil then
        --other.Physics:SetCollides(false)
        other.components.health:Kill()
    elseif other.components.workable ~= nil
        and other.components.workable:CanBeWorked()
        and other.components.workable.action ~= ACTIONS.NET then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
        if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
            inst.recentlycharged[other] = true
            inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        end
    elseif other.components.health ~= nil and not other.components.health:IsDead() then
        inst.recentlycharged[other] = true
        inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo")
        inst.components.combat:DoAttack(other)
    end
end

local function oncollide(inst, other)
    if not (other ~= nil and other:IsValid() and inst:IsValid())
        or inst.recentlycharged[other]
        or other:HasTag("player")
        or Vector3(inst.Physics:GetVelocity()):LengthSq() < 42 then
        return
    end
    ShakeAllCameras(CAMERASHAKE.SIDE, .5, .05, .1, inst, 40)
    inst:DoTaskInTime(2 * FRAMES, onothercollide, other)
end

local function rememberhome(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("atrium_key.png")
    inst.MiniMapEntity:SetPriority(15)
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)
    inst.MiniMapEntity:SetRestriction("nightmaretracker")

    inst.DynamicShadow:SetSize(5, 3)
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 100, 2.2)
    inst.Physics:SetCylinder(2.2, 4)

    inst.AnimState:SetBank("rook")
    inst.AnimState:SetBuild("rook_rhino")

    inst:AddTag("cavedweller")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("minotaur")
    inst:AddTag("epic")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.recentlycharged = {}
    inst.Physics:SetCollisionCallback(oncollide)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.MINOTAUR_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.MINOTAUR_RUN_SPEED

    inst:SetStateGraph("SGminotaur")

    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "spring"
    inst.components.combat:SetAttackPeriod(TUNING.MINOTAUR_ATTACK_PERIOD)
    inst.components.combat:SetDefaultDamage(TUNING.MINOTAUR_DAMAGE)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetRange(3, 4)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MINOTAUR_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('minotaur')

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("maprevealable")
    inst.components.maprevealable:AddRevealSource(inst, "nightmaretracker")
    inst.components.maprevealable:SetIconPriority(15)

    inst:DoTaskInTime(0, rememberhome)

    MakeMediumBurnableCharacter(inst, "spring")
    MakeMediumFreezableCharacter(inst, "spring")

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)

    return inst
end

--------------------------------------------------------------------------

local function dospawnchest(inst, loading)
    local chest = SpawnPrefab("minotaurchest")
    local x, y, z = inst.Transform:GetWorldPosition()
    chest.Transform:SetPosition(x, 0, z)

    --Set up chest loot
    chest.components.container:GiveItem(SpawnPrefab("atrium_key"))

    local loot_keys = {}
    for i, _ in ipairs(chest_loot) do
        table.insert(loot_keys, i)
    end
    loot_keys = PickSome(math.random(3, 6), loot_keys)

    for _, i in ipairs(loot_keys) do
        local loot = chest_loot[i]
        local item = SpawnPrefab(loot.item[math.random(#loot.item)])
        if item ~= nil then
            if type(loot.count) == "table" and item.components.stackable ~= nil then
                item.components.stackable:SetStackSize(math.random(loot.count[1], loot.count[2]))
            end
            chest.components.container:GiveItem(item)
        end
    end
    --

    if not chest:IsAsleep() then
        chest.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

        local fx = SpawnPrefab("statue_transition_2")
        if fx ~= nil then
            fx.Transform:SetPosition(x, y, z)
            fx.Transform:SetScale(1, 2, 1)
        end

        fx = SpawnPrefab("statue_transition")
        if fx ~= nil then
            fx.Transform:SetPosition(x, y, z)
            fx.Transform:SetScale(1, 1.5, 1)
        end
    end

    if inst.minotaur ~= nil and inst.minotaur:IsValid() and inst.minotaur.sg:HasStateTag("death") then
        inst.minotaur.MiniMapEntity:SetEnabled(false)
        inst.minotaur:RemoveComponent("maprevealable")
    end

    if not loading then
        inst:Remove()
    end
end

local function OnLoadChest(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        dospawnchest(inst, true)
        inst.persists = false
        inst:DoTaskInTime(0, inst.Remove)
    end
end

local function chestfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst.task = inst:DoTaskInTime(3, dospawnchest)

    inst.OnLoad = OnLoadChest

    return inst
end

--------------------------------------------------------------------------

return Prefab("minotaur", fn, assets, prefabs),
    Prefab("minotaurchestspawner", chestfn, nil, prefabs_chest),
    RuinsRespawner.Inst("minotaur"), RuinsRespawner.WorldGen("minotaur")
