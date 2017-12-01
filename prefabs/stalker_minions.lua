local brain = require("brains/stalker_minionbrain")

--only specify one or the other (or none): movestarttime, movestoptime
local MINIONS =
{
    {
        name = "stalker_minion1",
        bank = "stalker_minion",
        build = "stalker_minion",
        emergeimmunetime = 38 * FRAMES,
        emergeshadowtime = 81 * FRAMES,
        movestoptime = 6 * FRAMES,
        movespeed = 3,
    },
    {
        name = "stalker_minion2",
        bank = "stalker_minion_2",
        build = "stalker_minion_2",
        emergeimmunetime = 40 * FRAMES,
        emergeshadowtime = 49 * FRAMES,
        movestarttime = 16 * FRAMES,
        movespeed = 1.5,
    },
}

--------------------------------------------------------------------------

local function KeepTargetFn()
    return false
end

local function OnDeath(inst)
    local stalker = inst.components.entitytracker:GetEntity("stalker")
    if stalker ~= nil then
        stalker:PushEvent("miniondeath", { minion = inst })
    end
end

local function OnSpawnedBy(inst, stalker)
    local old = inst.components.entitytracker:GetEntity("stalker")
    if old ~= stalker then
        if old ~= nil then
            inst.components.entitytracker:ForgetEntity("stalker")
            inst:RemoveEventCallback("death", inst._onstalkerdeath, old)
        end
        inst.components.entitytracker:TrackEntity("stalker", stalker)
        inst:ListenForEvent("death", inst._onstalkerdeath, stalker)
        inst:ForceFacePoint(stalker.Transform:GetWorldPosition())
        inst.sg:GoToState("emerge")
    end
end

local function OnLoadPostPass(inst)
    local stalker = inst.components.entitytracker:GetEntity("stalker")
    if stalker ~= nil then
        inst:ForceFacePoint(stalker.Transform:GetWorldPosition())
        if stalker.components.health:IsDead() then
            inst.components.entitytracker:ForgetEntity("stalker")
            inst.stalkerdead = true
        else
            inst:ListenForEvent("death", inst._onstalkerdeath, stalker)
        end
    end
end

local function OnDecay(inst)
    inst.sleeptask = nil
    if not inst.components.health:IsDead() then
        local stalker = inst.components.entitytracker:GetEntity("stalker")
        if stalker ~= nil and not stalker.components.health:IsDead() then
            stalker:PushEvent("miniondeath", { minion = inst })
            if stalker:IsAsleep() and
                stalker:IsNearAtrium() and
                stalker:IsNearAtrium(inst) then
                stalker.components.health:DoDelta(TUNING.STALKER_FEAST_HEALING)
            end
        end
    end
    inst:Remove()
end

local function OnEntitySleep(inst)
    if inst.sleeptask == nil then
        inst.sleeptask = inst:DoTaskInTime(10, OnDecay)
    end
end

local function OnEntityWake(inst)
    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
        inst.sleeptask = nil
    end
end

local function OnTimerDone(inst, data)
    if data.name == "selfdestruct" and not inst.components.health:IsDead() then
        local stalker = inst.components.entitytracker:GetEntity("stalker")
        if stalker ~= nil and stalker.sg:HasStateTag("feasting") and stalker:IsNear(inst, 3) then
            inst.components.timer:StartTimer("selfdestruct", GetRandomWithVariance(5, 1))
        elseif inst:IsAsleep() then
            if stalker ~= nil then
                stalker:PushEvent("miniondeath", { minion = inst })
            end
            inst:Remove()
        else
            inst.components.health:Kill()
        end
    end
end

--------------------------------------------------------------------------

local function ClearRecentlyCharged(inst, other)
    inst.recentlycharged[other] = nil
end

local function OnDestroyOther(inst, other)
    if other:IsValid() and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked() and
        other.components.workable.action ~= ACTIONS.DIG and
        other.components.workable.action ~= ACTIONS.NET and
        not inst.recentlycharged[other] then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
        if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
            inst.recentlycharged[other] = true
            inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        end
    end
end

local function OnCollide(inst, other)
    if other ~= nil and
        other:IsValid() and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked() and
        other.components.workable.action ~= ACTIONS.DIG and
        other.components.workable.action ~= ACTIONS.NET and
        not inst.recentlycharged[other] then
        inst:DoTaskInTime(2 * FRAMES, OnDestroyOther, other)
    end
end

--------------------------------------------------------------------------

local function nostalkerordebrisdmg(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    return afflicter ~= nil and (afflicter:HasTag("stalker") or afflicter:HasTag("quakedebris"))
end

--------------------------------------------------------------------------

local function MakeMinion(name, data, prefabs)
    local assets = data ~= nil and {
        Asset("ANIM", "anim/stalker_shadow_build.zip"),
        Asset("ANIM", "anim/"..data.build..".zip"),
    } or nil

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        MakeCharacterPhysics(inst, 50, .3)

        inst.DynamicShadow:SetSize(1.5, 1)

        inst.Transform:SetSixFaced()

        local params = data
        if params == nil then
            params = MINIONS[math.random(#MINIONS)]
            inst:SetPrefabName(params.name)
        end

        inst.AnimState:SetBank(params.bank)
        inst.AnimState:SetBuild(params.build)
        inst.AnimState:OverrideSymbol("fx_flames", "stalker_shadow_build", "fx_flames")
        inst.AnimState:OverrideSymbol("shield_minion", "stalker_shadow_build", "shield_minion")
        inst.AnimState:OverrideSymbol("fx_dark_minion", "stalker_shadow_build", "fx_dark_minion")
        inst.AnimState:PlayAnimation("idle", true)

        inst:AddTag("monster")
        inst:AddTag("hostile")
        inst:AddTag("stalkerminion")
        inst:AddTag("fossil")

        inst:SetPrefabNameOverride("stalker_minion")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.recentlycharged = {}
        inst.Physics:SetCollisionCallback(OnCollide)

        inst:AddComponent("inspectable")

        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

        inst:AddComponent("locomotor")
        inst.components.locomotor.walkspeed = params.movespeed

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(1)
        inst.components.health.nofadeout = true
        inst.components.health.redirect = nostalkerordebrisdmg

        inst:AddComponent("combat")
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

        inst:AddComponent("entitytracker")

        inst:AddComponent("timer")
        inst.components.timer:StartTimer("selfdestruct", GetRandomWithVariance(TUNING.STALKER_MINIONS_LIFESPAN, TUNING.STALKER_MINIONS_LIFESPAN_VARIANCE))
        inst:ListenForEvent("timerdone", OnTimerDone)

        inst.emergeimmunetime = params.emergeimmunetime
        inst.emergeshadowtime = params.emergeshadowtime
        inst.movestarttime = params.movestarttime
        inst.movestoptime = params.movestoptime

        inst:SetStateGraph("SGstalker_minion")
        inst:SetBrain(brain)

        inst.OnSpawnedBy = OnSpawnedBy
        inst.OnLoadPostPass = OnLoadPostPass
        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake

        inst._onstalkerdeath = function(stalker)
            inst:RemoveEventCallback("death", inst._onstalkerdeath, stalker)
            if inst.components.entitytracker:GetEntity("stalker") == stalker then
                inst.components.entitytracker:ForgetEntity("stalker")
                inst.stalkerdead = true
            end
        end

        inst:ListenForEvent("death", OnDeath)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local ret = {}
local prefs = {}
for i, v in ipairs(MINIONS) do
    table.insert(prefs, v.name)
    table.insert(ret, MakeMinion(v.name, v))
end
table.insert(ret, MakeMinion("stalker_minion", nil, prefs))
prefs = nil

return unpack(ret)
