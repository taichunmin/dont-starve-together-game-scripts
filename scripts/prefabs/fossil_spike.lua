local assets =
{
    Asset("ANIM", "anim/fossil_spike.zip"),
}

local prefabs =
{
    "erode_ash",
    "fossilspike_base",
}

local NUM_VARIATIONS = 7
local PHYSICS_RADIUS = .2
local DAMAGE_RADIUS_PADDING = .5

local function KeepTargetFn()
    return false
end

local function ChangeToObstacle(inst)
    inst:RemoveEventCallback("animover", ChangeToObstacle)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Physics:Stop()
    inst.Physics:SetMass(0)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:Teleport(x, 0, z)
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
local NON_COLLAPSIBLE_TAGS = { "stalker", "flying", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }
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

local function OnKill2(inst)
    inst:AddTag("NOCLICK")
    inst.Physics:SetActive(false)
    ErodeAway(inst, 1)
end

local function OnKill(inst)
    SpawnPrefab("erode_ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:DoTaskInTime(.5, OnKill2)
end

local function KillSpike(inst)
    if not inst.killed then
        if inst.basefx ~= nil then
            inst.killed = true

            if inst.task ~= nil then
                inst.task:Cancel()
                inst.task = nil
            end

            inst:RemoveEventCallback("animover", ChangeToObstacle)

            if inst.basefx:IsValid() then
                inst.basefx.AnimState:PlayAnimation("base_pst"..tostring(inst.basefx.variation))
                inst:DoTaskInTime(1, OnKill)
            else
                OnKill(inst)
            end
        else
            inst:Remove()
        end
    end
end

local function StartSpike(inst, duration, variation)
    inst.task = inst:DoTaskInTime(duration, KillSpike)

    if variation > 1 then
        inst.AnimState:OverrideSymbol("bone1", "fossil_spike", "bone"..tostring(variation))
    end

    inst.basefx = SpawnPrefab("fossilspike_base")
    inst.basefx.entity:SetParent(inst.entity)

    inst:ListenForEvent("animover", ChangeToObstacle)
    inst.AnimState:PlayAnimation("fossil_pst")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/fossil_spike")

    DoDamage(inst)
end

local function RestartSpike(inst, delay, duration, variation)
    if inst.task ~= nil then
        inst.task:Cancel()
        if variation == nil then
            variation = math.random(NUM_VARIATIONS)
        elseif variation > NUM_VARIATIONS then
            variation = (variation - 1) % NUM_VARIATIONS + 1
        end
        inst.task = inst:DoTaskInTime(delay or 0, StartSpike, duration, variation)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fossil_spike")
    inst.AnimState:SetBuild("fossil_spike")
    inst.AnimState:PlayAnimation("empty")
    inst.AnimState:SetFinalOffset(1)

    inst.Physics:SetMass(99999)
    inst.Physics:SetCollisionGroup(COLLISION.SMALLOBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:SetCapsule(PHYSICS_RADIUS, 2)

    inst:AddTag("notarget")
    inst:AddTag("groundspike")
    inst:AddTag("fossilspike")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(10)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst.persists = false

    inst.task = inst:DoTaskInTime(0, StartSpike, 5 + math.random(), math.random(NUM_VARIATIONS))
    inst.RestartSpike = RestartSpike
    inst.KillSpike = KillSpike

    return inst
end

local function basefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fossil_spike")
    inst.AnimState:SetBuild("fossil_spike")
    inst.AnimState:PlayAnimation("base_pre1")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.variation = math.random(3)
    if inst.variation > 1 then
        inst.AnimState:PlayAnimation("base_pre"..tostring(inst.variation))
    end

    return inst
end

return Prefab("fossilspike", fn, assets, prefabs),
    Prefab("fossilspike_base", basefn, assets)
