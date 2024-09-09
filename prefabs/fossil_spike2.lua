local assets =
{
    Asset("ANIM", "anim/fossil_spike2.zip"),
}

local prefabs =
{
    "erode_ash",
    "fossilspike2_base",
}

local NUM_VARIATIONS = 7
local PHYSICS_RADIUS = .2
local DAMAGE_RADIUS_PADDING = .5
local SHADOW_SIZE = { 1.2, .75 }

local function KeepTargetFn()
    return false
end

local function SpikeLaunch(inst, launcher, basespeed, startheight, startradius)
    local x0, y0, z0 = launcher.Transform:GetWorldPosition()
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local dx, dz = x1 - x0, z1 - z0
    local dsq = dx * dx + dz * dz
    local angle
    if dsq > 0 then
        local dist = math.sqrt(dsq)
        angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
    else
        angle = TWOPI * math.random()
    end
    local sina, cosa = math.sin(angle), math.cos(angle)
    local speed = basespeed + math.random()
    inst.Physics:Teleport(x0 + startradius * cosa, startheight, z0 + startradius * sina)
    inst.Physics:SetVel(cosa * speed, speed * 5 + math.random() * 2, sina * speed)
end

local COLLAPSIBLE_WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
}
local COLLAPSIBLE_TAGS = { "_combat", "pickable", "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
    table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "stalker", --[["flying", "ghost",]] "shadow", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }
local TOSSITEM_MUST_TAGS = { "_inventoryitem" }
local TOSSITEM_CANT_TAGS = { "locomotor", "INLIMBO" }

local function DoDamage(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, PHYSICS_RADIUS + DAMAGE_RADIUS_PADDING, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() then
            local isworkable = false
            if v.components.workable ~= nil then
                local work_action = v.components.workable:GetWorkAction()
                --V2C: nil action for NPC_workable (e.g. campfires)
                --     allow digging spawners (e.g. rabbithole)
                isworkable = (
                    (work_action == nil and v:HasTag("NPC_workable")) or
                    (v.components.workable:CanBeWorked() and work_action ~= nil and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
                )
            end
            if isworkable then
                v.components.workable:Destroy(inst)
                if v:IsValid() and v:HasTag("stump") then
                    v:Remove()
                end
            elseif v.components.pickable ~= nil
                and v.components.pickable:CanBePicked()
                and not v:HasTag("intense") then
				v.components.pickable:Pick(inst)
            elseif v.components.combat ~= nil
                and v.components.health ~= nil
                and not v.components.health:IsDead() then
                if v.components.locomotor == nil and not inst:HasTag("epic") then
                    v.components.health:Kill()
                elseif inst.components.combat:IsValidTarget(v) then
                    inst.components.combat:DoAttack(v)
                end
            end
        end
    end

    local totoss = TheSim:FindEntities(x, 0, z, PHYSICS_RADIUS + DAMAGE_RADIUS_PADDING, TOSSITEM_MUST_TAGS, TOSSITEM_CANT_TAGS)
    for i, v in ipairs(totoss) do
        if v.components.mine ~= nil then
            v.components.mine:Deactivate()
        end
        if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
            SpikeLaunch(v, inst, .8 + PHYSICS_RADIUS, PHYSICS_RADIUS * .4, PHYSICS_RADIUS + v:GetPhysicsRadius(0))
        end
    end
end

local function OnKill(inst)
    inst:AddTag("NOCLICK")
    ErodeAway(inst, 1)
end

local function KillSpike(inst)
    if inst.killtask ~= nil then
        inst.killtask:Cancel()
        inst.killtask = nil
    end
    if not inst.killed then
        if inst.basefx ~= nil then
            inst.killed = true

            if inst.task ~= nil then
                inst.task:Cancel()
                inst.task = nil
            end

            SpawnPrefab("erode_ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst:DoTaskInTime(.5, OnKill)
        else
            inst:Remove()
        end
    end
end

local function OnImpact(inst)
    inst:RemoveEventCallback("animover", OnImpact)
    inst.AnimState:PlayAnimation("impact")

    if inst.lighttask ~= nil then
        inst.lighttask:Cancel()
        inst.lighttask = nil
    end
    inst.AnimState:SetLightOverride(0)

    if inst.shadowtask ~= nil then
        inst.shadowtask:Cancel()
        inst.shadowtask = nil
    end
    if inst.shadowtask2 ~= nil then
        inst.shadowtask2:Cancel()
        inst.shadowtask2 = nil
    end
    inst.DynamicShadow:Enable(false)

    inst.basefx = SpawnPrefab("fossilspike2_base")
    inst.basefx.entity:SetParent(inst.entity)

    if inst.soundlevel ~= nil then
        inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/stalker/fossil_spike", { level = inst.soundlevel })
    else
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/fossil_spike")
    end

    DoDamage(inst)

    inst.killtask = inst:DoTaskInTime(.35, KillSpike)
end

local SHADOW_DELTA2 = -.2
local function UpdateShadow2(inst)
    if inst.shadowtask ~= nil then
        inst.shadowtask:Cancel()
        inst.shadowtask = nil
    end
    inst.shadowsize = inst.shadowsize + SHADOW_DELTA2
    local k = 1 - inst.shadowsize
    k = 1 - k * k
    if k <= .5 then
        k = .5
        inst.shadowtask2:Cancel()
        inst.shadowtask2 = nil
    end
    inst.DynamicShadow:SetSize(k * SHADOW_SIZE[1], k * SHADOW_SIZE[2])
end

local SHADOW_DELTA = .05
local function UpdateShadow(inst)
    inst.shadowsize = inst.shadowsize + SHADOW_DELTA
    if inst.shadowsize > 0 then
        inst.DynamicShadow:Enable(true)
        if inst.shadowsize >= 1 then
            inst.shadowsize = 1
            inst.shadowtask:Cancel()
            inst.shadowtask = nil
        end
    end
    local k = inst.shadowsize * inst.shadowsize
    inst.DynamicShadow:SetSize(k * SHADOW_SIZE[1], k * SHADOW_SIZE[2])
end

local LIGHT_DELTA = .03
local function UpdateLight(inst)
    inst.lightvalue = inst.lightvalue + LIGHT_DELTA
    if inst.lightvalue >= 1 then
        inst.lightvalue = 1
        inst.lighttask:Cancel()
        inst.lighttask = nil
    end
    inst.AnimState:SetLightOverride(1 - inst.lightvalue * inst.lightvalue)
end

local function StartSpike(inst, variation)
    inst.task = nil

    if variation > 1 then
        inst.AnimState:OverrideSymbol("bone1", "fossil_spike2", "bone"..tostring(variation))
    end

    inst:ListenForEvent("animover", OnImpact)
    inst.AnimState:PlayAnimation("appear")

    inst.shadowsize = 0
    inst.shadowtask = inst:DoPeriodicTask(0, UpdateShadow)
    inst.shadowtask2 = inst:DoPeriodicTask(0, UpdateShadow2, 43 * FRAMES)
    inst.lightvalue = 0
    inst.lighttask = inst:DoPeriodicTask(0, UpdateLight)
end

local function RestartSpike(inst, delay, variation, soundlevel)
    if inst.task ~= nil then
        inst.task:Cancel()
        if variation == nil then
            variation = math.random(NUM_VARIATIONS)
        elseif variation > NUM_VARIATIONS then
            variation = (variation - 1) % NUM_VARIATIONS + 1
        end
        inst.soundlevel = soundlevel
        inst.task = inst:DoTaskInTime(delay or 0, StartSpike, variation)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fossil_spike2")
    inst.AnimState:SetBuild("fossil_spike2")
    inst.AnimState:PlayAnimation("empty")
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetLightOverride(1)

    inst.DynamicShadow:Enable(false)

    inst:AddTag("notarget")
    inst:AddTag("fossilspike")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.FOSSIL_SPIKE_DAMAGE)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst.persists = false

    inst.task = inst:DoTaskInTime(0, StartSpike, math.random(NUM_VARIATIONS))
    inst.RestartSpike = RestartSpike
    inst.KillSpike = KillSpike

    return inst
end

local function basefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fossil_spike2")
    inst.AnimState:SetBuild("fossil_spike2")
    inst.AnimState:PlayAnimation("base_impact")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("fossilspike2", fn, assets, prefabs),
    Prefab("fossilspike2_base", basefn, assets)
