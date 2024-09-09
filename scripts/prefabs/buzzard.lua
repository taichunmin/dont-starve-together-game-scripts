local assets =
{
    Asset("ANIM", "anim/buzzard_build.zip"),
    --Asset("ANIM", "anim/buzzard_shadow.zip"),
    Asset("ANIM", "anim/buzzard_basic.zip"),
    Asset("SOUND", "sound/buzzard.fsb"),        -- Why was that commented ?
}

local prefabs =
{
    "drumstick",
    "smallmeat",
    "feather_crow",
}

local brain = require("brains/buzzardbrain")

SetSharedLootTable('buzzard',
{
    {'drumstick',             1.00},
    {'smallmeat',             0.33},
    {'feather_crow',          0.33},
})

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
        and inst:IsNear(target, target:HasTag("buzzard") and inst.components.combat:GetAttackRange() + target:GetPhysicsRadius(0) or 7.5)
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local function OnPreLoad(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    if y > 0 then
        inst.Transform:SetPosition(x, 0, z)
    end
end

local function OnEntitySleep(inst)
    inst.components.combat:SetTarget(nil)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(1.25, .75)
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 15, .25)

    inst.AnimState:SetBank("buzzard")
    inst.AnimState:SetBuild("buzzard_build")
    inst.AnimState:PlayAnimation("idle", true)

    ------------------------------------------

    inst:AddTag("buzzard")
    inst:AddTag("animal")
    inst:AddTag("scarytoprey")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ------------------------------------------

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BUZZARD_HEALTH)

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BUZZARD_DAMAGE)
    inst.components.combat:SetRange(TUNING.BUZZARD_ATTACK_RANGE)
    inst.components.combat.hiteffectsymbol = "buzzard_body"
    inst.components.combat:SetAttackPeriod(TUNING.BUZZARD_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/buzzard/hurt")
    ------------------------------------------

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })

    ------------------------------------------

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('buzzard')

    ------------------------------------------

    inst:AddComponent("inspectable")

    ------------------------------------------

    inst:AddComponent("knownlocations")

    ------------------------------------------

    inst:ListenForEvent("attacked", OnAttacked)

    ------------------------------------------

    MakeMediumBurnableCharacter(inst, "buzzard_body")
    MakeMediumFreezableCharacter(inst, "buzzard_body")

    ------------------------------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BUZZARD_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.BUZZARD_RUN_SPEED

    inst:SetStateGraph("SGbuzzard")
    inst:SetBrain(brain)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        local action = BufferedAction(inst, nil, ACTIONS.GOHOME)
        inst.components.locomotor:PushAction(action)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
        return true
    end)

    inst.OnPreLoad = OnPreLoad
    inst.OnEntitySleep = OnEntitySleep

    return inst
end

return Prefab("buzzard", fn, assets, prefabs)
