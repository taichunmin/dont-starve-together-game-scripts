local brain = require("brains/berniebigbrain")

local assets =
{
    Asset("ANIM", "anim/bernie_big.zip"),
    Asset("ANIM", "anim/bernie_build.zip"),
	Asset("MINIMAP_IMAGE", "bernie"),
}

local prefabs =
{
    "bernie_inactive",
}

local TARGET_DIST = 12
local TAUNT_DIST = 16
local TAUNT_PERIOD = 2

local function goinactive(inst)
    local skin_name = nil
    if inst:GetSkinName() ~= nil then
        skin_name = string.gsub(inst:GetSkinName(), "_big", "")
    end
    local inactive = SpawnPrefab("bernie_inactive", skin_name, inst.skin_id, nil)
    if inactive ~= nil then
        --Transform health % into fuel.
        inactive.components.fueled:SetPercent(inst.components.health:GetPercent())
        inactive.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inactive.Transform:SetRotation(inst.Transform:GetRotation())
        inactive.components.timer:StartTimer("transform_cd", TUNING.BERNIE_BIG_COOLDOWN)
        inst:Remove()
        return inactive
    end
end

local function IsTauntable(inst, target)
    return not (target.components.health ~= nil and target.components.health:IsDead())
        and target.components.combat ~= nil
        and not target.components.combat:TargetIs(inst)
        and target.components.combat:CanTarget(inst)
        and (   target:HasTag("shadowcreature") or
                (   target.components.combat:HasTarget() and
                    (   target.components.combat.target:HasTag("player") or
                        (target.components.combat.target:HasTag("companion") and target.components.combat.target.prefab ~= inst.prefab)
                    )
                )
            )
end

local function IsTargetable(inst, target)
    return not (target.components.health ~= nil and target.components.health:IsDead())
        and target.components.combat ~= nil
        and target.components.combat:CanTarget(inst)
        and (   target.components.combat:TargetIs(inst) or
                target:HasTag("shadowcreature") or
                (   target.components.combat:HasTarget() and
                    (   target.components.combat.target:HasTag("player") or
                        target.components.combat.target:HasTag("companion")
                    )
                )
            )
end

local TAUNT_MUST_TAGS = { "_combat", "locomotor" }
local TAUNT_CANT_TAGS = { "INLIMBO", "player", "companion", "epic", "notaunt" }
local function TauntCreatures(inst)
    if not inst.components.health:IsDead() then
        local x, y, z = inst.Transform:GetWorldPosition()
        for i, v in ipairs(TheSim:FindEntities(x, y, z, TAUNT_DIST, TAUNT_MUST_TAGS, TAUNT_CANT_TAGS)) do
            if IsTauntable(inst, v) then
                v.components.combat:SetTarget(inst)
            end
        end
    end
end

local function OnLoad(inst)
    inst._taunttask:Cancel()
    inst._taunttask = inst:DoPeriodicTask(TAUNT_PERIOD, TauntCreatures, math.random() * TAUNT_PERIOD)
    inst.sg:GoToState("idle")
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "player", "companion" }
local RETARGET_ONEOF_TAGS = { "locomotor", "epic" }

local function RetargetFn(inst)
    if inst.components.combat:HasTarget() then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, TARGET_DIST, RETARGET_MUST_TAGS, RETARGET_CANT_TAGS, RETARGET_ONEOF_TAGS)) do
        if IsTargetable(inst, v) then
            return v
        end
    end
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target) and inst:IsNear(target, TARGET_DIST)
end

local function OnAttacked(inst, data)
    local attacker = data ~= nil and data.attacker or nil
    if attacker ~= nil and not PreventTargetingOnAttacked(inst, attacker, TheNet:GetPVPEnabled() and "bernieowner" or "player") then
        local target = inst.components.combat.target
        if not (target ~= nil and target:IsValid() and inst:IsNear(target, TUNING.BERNIE_BIG_ATTACK_RANGE + target:GetPhysicsRadius(0))) then
            inst.components.combat:SetTarget(attacker)
        end
    end
end

local function OnSleepTask(inst)
    inst._sleeptask = nil
    inst:GoInactive()
end

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask = inst:DoTaskInTime(.5, OnSleepTask)
    end
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 500, .65)
    inst.DynamicShadow:SetSize(2.75, 1.3)

    inst.Transform:SetScale(.7, .7, .7)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("bernie_big")
    inst.AnimState:SetBuild("bernie_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.MiniMapEntity:SetIcon("bernie.png")

    inst:AddTag("largecreature")
    inst:AddTag("companion")
    inst:AddTag("soulless")
    inst:AddTag("crazy")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BERNIE_BIG_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BERNIE_BIG_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.BERNIE_BIG_RUN_SPEED

    -- Enable boat hopping
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BERNIE_BIG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BERNIE_BIG_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.BERNIE_BIG_ATTACK_RANGE, TUNING.BERNIE_BIG_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.battlecryinterval = 16
    inst.components.combat.hiteffectsymbol = "body"

    inst:AddComponent("timer")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.hit_recovery = TUNING.BERNIE_BIG_HIT_RECOVERY

    inst:SetStateGraph("SGberniebig")
    inst:SetBrain(brain)

    inst._taunttask = inst:DoPeriodicTask(TAUNT_PERIOD, TauntCreatures, 0)
    inst.OnLoad = OnLoad
    inst.GoInactive = goinactive
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab("bernie_big", fn, assets, prefabs)
