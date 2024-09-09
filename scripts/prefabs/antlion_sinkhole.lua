require("stategraphs/commonstates")

local assets =
{
    Asset("ANIM", "anim/antlion_sinkhole.zip"),
    Asset("MINIMAP_IMAGE", "sinkhole"),
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

local NUM_CRACKING_STAGES = 3
local COLLAPSE_STAGE_DURATION = 1

local function UpdateOverrideSymbols(inst, state)
    if state == NUM_CRACKING_STAGES then
        inst.AnimState:ClearOverrideSymbol("cracks1")
        if inst.components.unevenground ~= nil then
            inst.components.unevenground:Enable()
        end
    else
        inst.AnimState:OverrideSymbol("cracks1", "antlion_sinkhole", "cracks_pre"..tostring(state))
        if inst.components.unevenground ~= nil then
            inst.components.unevenground:Disable()
        end
    end
end

local function SpawnFx(inst, stage, scale)
    local theta = math.random() * TWOPI
    local num = 7
    local radius = 1.6
    local dtheta = TWOPI / num
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("sinkhole_spawn_fx_"..math.random(3)).Transform:SetPosition(x, y, z)
    for i = 1, num do
        local dust = SpawnPrefab("sinkhole_spawn_fx_"..math.random(3))
        dust.Transform:SetPosition(x + math.cos(theta) * radius * (1 + math.random() * .1), 0, z - math.sin(theta) * radius * (1 + math.random() * .1))
        local s = scale + math.random() * .2
        dust.Transform:SetScale(i % 2 == 0 and -s or s, s, s)
        theta = theta + dtheta
    end
    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = math.pow(stage / NUM_CRACKING_STAGES, 2) })
end

-- c_sel():PushEvent("timerdone", {name = "nextrepair"})
local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "nextrepair" then
        inst.remainingrepairs = inst.remainingrepairs - 1
        if inst.remainingrepairs <= 0 then
            inst.components.unevenground:Disable()
            inst.persists = false
            ErodeAway(inst)
        else
            UpdateOverrideSymbols(inst, inst.remainingrepairs)
            inst.components.timer:StartTimer("nextrepair", TUNING.ANTLION_SINKHOLE.REPAIR_TIME[inst.remainingrepairs] + (math.random() * TUNING.ANTLION_SINKHOLE.REPAIR_TIME_VARIANCE))
        end

        if not inst:IsAsleep() then
            SpawnFx(inst, inst.remainingrepairs, .45)
        end
    end
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
local NON_COLLAPSIBLE_TAGS = { "flying", "bird", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }
local NON_COLLAPSIBLE_TAGS_FIRST = { "flying", "bird", "ghost", "locomotor", "FX", "NOCLICK", "DECOR", "INLIMBO" }

local function SmallLaunch(inst, launcher, basespeed)
    local hp = inst:GetPosition()
    local pt = launcher:GetPosition()
    local vel = (hp - pt):GetNormalized()
    local speed = basespeed * .5 + math.random()
    local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
    inst.Physics:Teleport(hp.x, .1, hp.z)
    inst.Physics:SetVel(math.cos(angle) * speed, 3 * speed + math.random(), math.sin(angle) * speed)
end

local TOSS_MUST_TAGS = { "_inventoryitem" }
local TOSS_CANT_TAGS = { "locomotor", "INLIMBO" }

local function start_repairs(inst, repairdata)
    inst.remainingrepairs = (repairdata and repairdata.num_stages) or NUM_CRACKING_STAGES

    local repairtime = (repairdata and repairdata.time) or TUNING.ANTLION_SINKHOLE.REPAIR_TIME[NUM_CRACKING_STAGES] + (math.random() * TUNING.ANTLION_SINKHOLE.REPAIR_TIME_VARIANCE)
    inst.components.timer:StartTimer("nextrepair", repairtime)
end

local function donextcollapse(inst)
    inst.collapsestage = inst.collapsestage + 1

    local isfinalstage = inst.collapsestage >= NUM_CRACKING_STAGES

    if isfinalstage then
        inst.collapsetask:Cancel()
        inst.collapsetask = nil

        inst:RemoveTag("scarytoprey")
        ShakeAllCameras(CAMERASHAKE.FULL, COLLAPSE_STAGE_DURATION, .03, .15, inst, TUNING.ANTLION_SINKHOLE.RADIUS*6)
        start_repairs(inst)
    else
        ShakeAllCameras(CAMERASHAKE.FULL, COLLAPSE_STAGE_DURATION, .015, .15, inst, TUNING.ANTLION_SINKHOLE.RADIUS*4)
    end

    UpdateOverrideSymbols(inst, inst.collapsestage)

    SpawnFx(inst, inst.collapsestage, .8)

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, TUNING.ANTLION_SINKHOLE.RADIUS + 1, nil, inst.collapsestage > 1 and NON_COLLAPSIBLE_TAGS or NON_COLLAPSIBLE_TAGS_FIRST, COLLAPSIBLE_TAGS)
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
                if isfinalstage then
                    v.components.workable:Destroy(inst)
                    if v:IsValid() and v:HasTag("stump") then
                        v:Remove()
                    end
                else
                    if v.components.workable:GetWorkAction() == ACTIONS.MINE then
                        PlayMiningFX(inst, v, true)
                    end
                    v.components.workable:WorkedBy(inst, 1)
                end
            elseif v.components.pickable ~= nil
                and v.components.pickable:CanBePicked()
                and not v:HasTag("intense") then
				v.components.pickable:Pick(inst)
            elseif v.components.combat ~= nil
                and v.components.health ~= nil
                and not v.components.health:IsDead() then
                if isfinalstage and v.components.locomotor == nil then
                    v.components.health:Kill()
                elseif v.components.combat:CanBeAttacked() then
                    v.components.combat:GetAttacked(inst, TUNING.ANTLION_SINKHOLE.DAMAGE)
                end
            end
        end
    end
    local totoss = TheSim:FindEntities(x, 0, z, TUNING.ANTLION_SINKHOLE.RADIUS, TOSS_MUST_TAGS, TOSS_CANT_TAGS)
    for i, v in ipairs(totoss) do
        if v.components.mine ~= nil then
            v.components.mine:Deactivate()
        end
        if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
            SmallLaunch(v, inst, 1.5)
        end
    end
end

local function onstartcollapse(inst)
    inst.collapsestage = 0

    inst:AddTag("scarytoprey")

    inst.collapsetask = inst:DoPeriodicTask(COLLAPSE_STAGE_DURATION, donextcollapse)
    donextcollapse(inst)
end

-------------------------------------------------------------------------------

local function OnSave(inst, data)
    if inst.collapsetask ~= nil then
        data.collapsestage = inst.collapsestage
    else
        data.remainingrepairs = inst.remainingrepairs
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.collapsestage ~= nil then
            inst.collapsestage = data.collapsestage
            UpdateOverrideSymbols(inst, inst.collapsestage)
            inst.collapsetask = inst:DoPeriodicTask(COLLAPSE_STAGE_DURATION, donextcollapse)
        elseif data.remainingrepairs ~= nil then
            inst.remainingrepairs = data.remainingrepairs
            UpdateOverrideSymbols(inst, inst.remainingrepairs)
        end
    end
end

-------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sinkhole")
    inst.AnimState:SetBuild("antlion_sinkhole")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)

    inst.MiniMapEntity:SetIcon("sinkhole.png")

    inst.Transform:SetEightFaced()

    inst:AddTag("antlion_sinkhole")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("NOCLICK")

	inst:SetDeploySmartRadius(3)

    inst.scrapbook_anim = "scrapbook"
    inst.scrapbook_specialinfo = "ANTLIONSINKHOLE"
    inst.scrapbook_inspectonseen = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst:AddComponent("unevenground")
    inst.components.unevenground.radius = TUNING.ANTLION_SINKHOLE.UNEVENGROUND_RADIUS

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("startcollapse", onstartcollapse)
    inst:ListenForEvent("startrepair", start_repairs)

    return inst
end

return Prefab("antlion_sinkhole", fn, assets, prefabs)
