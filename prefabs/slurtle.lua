local assets =
{
    Asset("ANIM", "anim/slurtle.zip"),
    Asset("ANIM", "anim/slurtle_snaily.zip"),
    Asset("SOUND", "sound/slurtle.fsb"),
}

local prefabs =
{
    "slurtleslime",
    "slurtle_shellpieces",
    "slurtlehat",
    "armorsnurtleshell",
    "explode_small",
}

SetSharedLootTable('slurtle',
{
    {'slurtleslime',  1.0},
    {'slurtleslime',  1.0},
    {'slurtlehat',    0.1},
})

SetSharedLootTable('snurtle',
{
    {'slurtleslime',      1.0},
    {'slurtleslime',      1.0},
    {'armorsnurtleshell', 0.75},
})

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40
local SPAWN_SLIME_VALUE = 6

local slurtle_brain = require "brains/slurtlebrain"
local snurtle_brain = require "brains/slurtlesnailbrain"

local function KeepTarget(inst, target)
    if not target:IsValid() then
        return false
    end
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil and target:GetDistanceSqToPoint(homePos) < MAX_CHASEAWAY_DIST * MAX_CHASEAWAY_DIST
end

local function IsSlurtle(dude)
    return dude:HasTag("slurtle")
end

local function Slurtle_OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, IsSlurtle, MAX_TARGET_SHARES)
end

local function Snurtle_OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, IsSlurtle, MAX_TARGET_SHARES)
end

local function OnIgniteFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/rattle", "rattle")
    inst.persists = false
end

local function OnExtinguishFn(inst)
    inst.SoundEmitter:KillSound("rattle")
    inst.persists = true
end

local function OnExplodeFn(inst)
    inst.SoundEmitter:KillSound("rattle")
    SpawnPrefab("explode_small_slurtle").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function OnEatElement(inst, food)
    local value = food.components.edible.hungervalue
    inst.stomach = inst.stomach + value
    if inst.stomach >= SPAWN_SLIME_VALUE then
        local stacksize = 0
        while inst.stomach >= SPAWN_SLIME_VALUE do
            inst.stomach = inst.stomach - SPAWN_SLIME_VALUE
            stacksize = stacksize + 1
        end
        local slime = SpawnPrefab("slurtleslime")
        slime.Transform:SetPosition(inst.Transform:GetWorldPosition())
        slime.components.stackable:SetStackSize(stacksize or 1)
    end
end

local function OnNotChanceLoot(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/slurtle/shatter")
end

local function OnInit(inst)
    inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
end

local function CustomOnHaunt(inst)
    inst.components.periodicspawner:TrySpawn()
    return true
end

local function commonfn(bank, build, tag)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, 1.5)

    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 50, .5)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)

    inst:AddTag("cavedweller")
    inst:AddTag("animal")
    inst:AddTag("explosive")

    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:SetStateGraph("SGslurtle")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.ELEMENTAL }, { FOODTYPE.ELEMENTAL })
    inst.components.eater:SetOnEatFn(OnEatElement)

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:DoTaskInTime(0, OnInit)

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("slurtleslime")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()

    inst:AddComponent("thief")

    inst:AddComponent("inventory")

    inst:AddComponent("explosive")
    inst.components.explosive.explosiverange = 3
    inst.components.explosive.lightonexplode = false

    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)

    inst:ListenForEvent("ifnotchanceloot", OnNotChanceLoot)

    MakeMediumFreezableCharacter(inst, "shell")
    MakeMediumBurnableCharacter(inst, "shell")
    inst.components.burnable:SetOnIgniteFn(OnIgniteFn)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguishFn)

    MakeHauntablePanic(inst)
    AddHauntableCustomReaction(inst, CustomOnHaunt, true, false, true)

    inst.lastmeal = 0
    inst.stomach = 0

    return inst
end

local function makeslurtle()
    local inst = commonfn("slurtle", "slurtle", "slurtle")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "shell"
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst:AddComponent("health")

    inst:SetBrain(slurtle_brain)

    inst.components.lootdropper:SetChanceLootTable('slurtle')
    inst.components.lootdropper:AddIfNotChanceLoot("slurtle_shellpieces")

    inst.components.locomotor.walkspeed = TUNING.SLURTLE_WALK_SPEED
    inst.components.explosive.explosivedamage = TUNING.SLURTLE_EXPLODE_DAMAGE
    inst.components.health:SetMaxHealth(TUNING.SLURTLE_HEALTH)
    inst.components.combat:SetRange(TUNING.SLURTLE_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.SLURTLE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SLURTLE_ATTACK_PERIOD)

    inst:ListenForEvent("attacked", Slurtle_OnAttacked)

    return inst
end

local function makesnurtle()
    local inst = commonfn("snurtle", "slurtle_snaily", "snurtle")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "shell"
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst:AddComponent("health")

    inst:SetBrain(snurtle_brain)

    inst.components.lootdropper:SetChanceLootTable('snurtle')
    inst.components.lootdropper:AddIfNotChanceLoot("slurtle_shellpieces")

    inst.components.locomotor.walkspeed = TUNING.SNURTLE_WALK_SPEED
    inst.components.explosive.explosivedamage = TUNING.SNURTLE_EXPLODE_DAMAGE
    inst.components.health:SetMaxHealth(TUNING.SNURTLE_HEALTH)

    inst:ListenForEvent("attacked", Snurtle_OnAttacked)

    return inst
end

return Prefab("slurtle", makeslurtle, assets, prefabs),
    Prefab("snurtle", makesnurtle, assets, prefabs)
