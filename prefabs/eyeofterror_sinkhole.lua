local assets =
{
    Asset("ANIM", "anim/antlion_sinkhole.zip"),
}

local prefabs =
{
    "sinkhole_spawn_fx_1",
    "sinkhole_spawn_fx_2",
    "sinkhole_spawn_fx_3",
    "mining_ice_fx",
    "mining_fx",
    "mining_moonglass_fx",
}

local NUM_CRACKING_STAGES = 1
local COLLAPSE_STAGE_DURATION = 1
local OBJECT_SCALE = 0.6

local NUM_FX = 7
local FX_THETA_DELTA = (2*PI) / NUM_FX
local FX_RADIUS = 1.6
local function SpawnFx(inst, scale, pos)
    local theta = math.random() * PI * 2

    pos = pos or inst:GetPosition()

    -- Spawn an fx at the middle of the sinkhole.
    SpawnPrefab("sinkhole_spawn_fx_"..math.random(3)).Transform:SetPosition(pos:Get())

    -- Spawn an fx around the edges of the sinkhole circle.
    for i = 1, NUM_FX do
        local dust = SpawnPrefab("sinkhole_spawn_fx_"..math.random(3))

        dust.Transform:SetPosition(
            pos.x + math.cos(theta) * FX_RADIUS * (1 + math.random() * .1),
            0,
            pos.z - math.sin(theta) * FX_RADIUS * (1 + math.random() * .1)
        )

        local s = scale + math.random() * .2
        local x_scale = (i % 2 == 0 and -s) or s
        dust.Transform:SetScale(x_scale, s, s)

        theta = theta + FX_THETA_DELTA
    end

    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 2 })
end

local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "repair" then
        if not inst:IsAsleep() then
            SpawnFx(inst, OBJECT_SCALE / 2)
        end

        inst.components.unevenground:Disable()
        inst.persists = false
        ErodeAway(inst)
    end
end

local function SmallLaunch(inst, launcher, basespeed)
    local hp = inst:GetPosition()
    local pt = launcher:GetPosition()
    local vel = (hp - pt):GetNormalized()
    local speed = basespeed * .5 + math.random()
    local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
    inst.Physics:Teleport(hp.x, .1, hp.z)
    inst.Physics:SetVel(math.cos(angle) * speed, 3 * speed + math.random(), math.sin(angle) * speed)
end

local COLLAPSIBLE_WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
}
local COLLAPSIBLE_TAGS = { "pickable", "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
    table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "flying", "bird", "ghost", "locomotor", "FX", "NOCLICK", "DECOR", "INLIMBO" }

local TOSS_MUST_TAGS = { "_inventoryitem" }
local TOSS_CANT_TAGS = { "locomotor", "INLIMBO" }

local function DoCollapse(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, COLLAPSE_STAGE_DURATION, .03, .15, inst, TUNING.EYEOFTERROR_CHOMP_SINKHOLERADIUS*6)

    inst.components.unevenground:Enable()

    local pos = inst:GetPosition()
    SpawnFx(inst, OBJECT_SCALE, pos)

    local ents = TheSim:FindEntities(
        pos.x, 0, pos.z,
        TUNING.EYEOFTERROR_CHOMP_SINKHOLERADIUS + 1, nil,
        NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS
    )

    for _, collapsible_entity in ipairs(ents) do
        local isworkable = false

        if collapsible_entity.components.workable ~= nil then
            local work_action = collapsible_entity.components.workable:GetWorkAction()
            --V2C: nil action for NPC_workable (e.g. campfires)
            --     allow digging spawners (e.g. rabbithole)
            isworkable = (
                (work_action == nil and collapsible_entity:HasTag("NPC_workable")) or
                (collapsible_entity.components.workable:CanBeWorked() and work_action ~= nil and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
            )
        end

        -- Work the object a little if it can be worked,
        -- and pick stuff that can be picked.
        if isworkable then
            if collapsible_entity.components.workable:GetWorkAction() == ACTIONS.MINE then
                local mine_fx = (collapsible_entity:HasTag("frozen") and "mining_ice_fx")
                    or (collapsible_entity:HasTag("moonglass") and "mining_moonglass_fx")
                    or "mining_fx"
                SpawnPrefab(mine_fx).Transform:SetPosition(collapsible_entity.Transform:GetWorldPosition())
            end

            collapsible_entity.components.workable:WorkedBy(inst, 1)
            if collapsible_entity:IsValid() and collapsible_entity:HasTag("stump") then
                collapsible_entity:Remove()
            end
        elseif collapsible_entity.components.pickable ~= nil
                and collapsible_entity.components.pickable:CanBePicked()
                and not collapsible_entity:HasTag("intense") then

            local num = collapsible_entity.components.pickable.numtoharvest or 1
            local product = collapsible_entity.components.pickable.product

            collapsible_entity.components.pickable:Pick(inst) -- only calling this to trigger callbacks on the object

            if product ~= nil and num > 0 then
                local ce_x, ce_y, ce_z = collapsible_entity.Transform:GetWorldPosition()
                for i = 1, num do
                    SpawnPrefab(product).Transform:SetPosition(ce_x, 0, ce_z)
                end
            end
        end
    end

    local totoss = TheSim:FindEntities(pos.x, 0, pos.z, TUNING.EYEOFTERROR_CHOMP_SINKHOLERADIUS, TOSS_MUST_TAGS, TOSS_CANT_TAGS)
    for _, tossible_entity in ipairs(totoss) do
        if tossible_entity.components.mine ~= nil then
            tossible_entity.components.mine:Deactivate()
        end
        if not tossible_entity.components.inventoryitem.nobounce
                and (tossible_entity.Physics ~= nil and tossible_entity.Physics:IsActive()) then
            SmallLaunch(tossible_entity, inst, 1.5)
        end
    end

    inst.components.timer:StartTimer("repair", 20)
end

-------------------------------------------------------------------------------

local function OnSave(inst, data)
    data.collapsed = inst.components.timer:TimerExists("repair")
end

local function OnLoad(inst, data)
    if data ~= nil and data.collapsed then
        inst.components.unevenground:Enable()
    end
end

local function OnLoadPostPass(inst, newents, data)
    if not data.collapsed then
        inst:Remove()
    end
end

-------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sinkhole")
    inst.AnimState:SetBuild("antlion_sinkhole")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)
    inst.AnimState:SetScale(OBJECT_SCALE, OBJECT_SCALE, OBJECT_SCALE)

    inst.Transform:SetEightFaced()

    inst:AddTag("antlion_sinkhole")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("NOCLICK")

    inst:SetDeployExtraSpacing(4)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("timer")

    inst:AddComponent("unevenground")
    inst.components.unevenground.radius = TUNING.EYEOFTERROR_CHOMP_SINKHOLERADIUS

    inst:ListenForEvent("docollapse", DoCollapse)
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("eyeofterror_sinkhole", fn, assets, prefabs)
