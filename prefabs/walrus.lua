local assets =
{
    Asset("ANIM", "anim/walrus_actions.zip"),
    Asset("ANIM", "anim/walrus_attacks.zip"),
    Asset("ANIM", "anim/walrus_basic.zip"),
    Asset("ANIM", "anim/walrus_build.zip"),
    Asset("ANIM", "anim/walrus_baby_build.zip"),
    Asset("SOUND", "sound/mctusky.fsb"),
}

local prefabs =
{
    "meat",
    "blowdart_walrus", -- creature weapon
    "blowdart_pipe", -- player loot
    "walrushat",
    "walrus_tusk",
}

local brain = require "brains/walrusbrain"

SetSharedLootTable( 'walrus',
{
    {'meat',            1.00},
    {'blowdart_pipe',   1.00},
    {'walrushat',       0.25},
    {'walrus_tusk',     0.50},
})

SetSharedLootTable( 'walrus_wee_loot',
{
    {'meat',            1.0},
})

local function ShareTargetFn(dude)
    return dude:HasTag("walrus") and not dude.components.health:IsDead()
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, ShareTargetFn, 5)
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "hound", "walrus" }
local RETARGET_ONEOF_TAGS = { "animal", "character", "monster" }
local function Retarget(inst)
    return FindEntity(inst, TUNING.WALRUS_TARGET_DIST, function(guy)
        return inst.components.combat:CanTarget(guy)
    end,
    RETARGET_MUST_TAGS,
    RETARGET_CANT_TAGS,
    RETARGET_ONEOF_TAGS
    )
end

local function KeepTarget(inst, target)
    return inst:IsNear(target, TUNING.WALRUS_LOSETARGET_DIST)
end

local function DoReturn(inst)
    --print("DoReturn", inst)
    if inst.components.homeseeker and inst.components.homeseeker.home then
        inst.components.homeseeker.home:PushEvent("onwenthome", {doer = inst})
        inst:Remove()
    end
end

local function OnStopDay(inst)
    --print("OnStopDay", inst)
    if inst:IsAsleep() then
        DoReturn(inst)
    end
end

local function OnEntitySleep(inst)
    --print("OnEntitySleep", inst)
    if not TheWorld.state.isday then
        DoReturn(inst)
    end
end

local function ShouldSleep(inst)
    return not (inst.components.homeseeker and inst.components.homeseeker:HasHome()) and DefaultSleepTest(inst)
end

local function EquipBlowdart(inst)
    if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local blowdart = CreateEntity()
        --[[Non-networked entity]]
        blowdart.entity:AddTransform()
        blowdart:AddComponent("weapon")
        blowdart:AddTag("sharp")
        blowdart.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        blowdart.components.weapon:SetRange(inst.components.combat.attackrange)
        blowdart.components.weapon:SetProjectile("blowdart_walrus")
        blowdart:AddComponent("inventoryitem")
        blowdart.persists = false
        blowdart.components.inventoryitem:SetOnDroppedFn(inst.Remove)
        blowdart:AddComponent("equippable")

        inst.components.inventory:Equip(blowdart)
    end
end

local function create_common(build, scale, tag)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(2.5, 1.5)
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(scale, scale, scale)

    inst.AnimState:SetBank("walrus")
    inst.AnimState:SetBuild(build)
    --inst.AnimState:Hide("hat")

    inst:AddTag("character")
    inst:AddTag("walrus")
    inst:AddTag("houndfriend")
    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 4
    inst.components.locomotor.walkspeed = 2

    inst:SetStateGraph("SGwalrus")
    inst.soundgroup = "mctusk"

    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetSleepTest(ShouldSleep)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetRange(TUNING.WALRUS_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.WALRUS_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WALRUS_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WALRUS_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('walrus')

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    MakeMediumBurnableCharacter(inst, "pig_torso")
    MakeMediumFreezableCharacter(inst, "pig_torso")

    MakeHauntablePanic(inst)

    inst:AddComponent("leader")

    inst:ListenForEvent("attacked", OnAttacked)

    inst:WatchWorldState("stopday", OnStopDay)

    inst.OnEntitySleep = OnEntitySleep

    inst:DoTaskInTime(1, EquipBlowdart)

    return inst
end

local function create_normal()
    return create_common("walrus_build", 1.5)
end

local function create_little()
    local inst = create_common("walrus_baby_build", 1, "taunt_attack")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.soundgroup = "wee_mctusk"

    inst.components.lootdropper:SetChanceLootTable('walrus_wee_loot')

    inst:AddComponent("follower")

    inst.components.locomotor.runspeed = 5
    inst.components.locomotor.walkspeed = 3

    inst.components.health:SetMaxHealth(TUNING.LITTLE_WALRUS_HEALTH)

    inst.components.combat:SetRange(TUNING.LITTLE_WALRUS_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.LITTLE_WALRUS_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.LITTLE_WALRUS_ATTACK_PERIOD)

    return inst
end

return Prefab("walrus", create_normal, assets, prefabs),
    Prefab("little_walrus", create_little, assets)