local assets =
{
    Asset("ANIM", "anim/shadowrift_portal.zip"),
    Asset("MINIMAP_IMAGE", "shadowrift_portal"),
    Asset("MINIMAP_IMAGE", "shadowrift_portal_max"),

    Asset("MINIMAP_IMAGE", "shadowrift_portal1"),
    Asset("MINIMAP_IMAGE", "shadowrift_portal2"),
    Asset("MINIMAP_IMAGE", "shadowrift_portal3"),
    Asset("MINIMAP_IMAGE", "shadowrift_portal4"),
    Asset("MINIMAP_IMAGE", "shadowrift_portal_max1"),
    Asset("MINIMAP_IMAGE", "shadowrift_portal_max2"),
    Asset("MINIMAP_IMAGE", "shadowrift_portal_max3"),
    Asset("MINIMAP_IMAGE", "shadowrift_portal_max4"),
}

local prefabs =
{
    "shadowrift_portal_fx",
    "fused_shadeling",
    "miasma_cloud",

    "shadowthrall_hands",
    "shadowthrall_wings",
    "shadowthrall_horns",
}

------ Constants ---------------------------------------------------------------

local AMBIENT_SOUND_PATH = "rifts2/shadow_rift/shadowrift_portal_allstage"
local AMBIENT_SOUND_LOOP_NAME = "shadowrift_portal_ambience"
local AMBIENT_SOUND_PARAM_NAME = "stage"
local AMBIENT_SOUND_STAGE_TO_INTENSITY = {0.1, 0.4, 0.7}
local PHYSICS_SIZE_BY_STAGE = {1.2, 2.2, 3.2}

local SHAKE_PARAMS_BY_STAGE = {
    {0.5, .01, .1, 50 },
    {1.0, .03, .2, 100},
    {1.5, .06, .3, 200},
}

local SHADELINGS_BY_STAGE = {1, 2, 3}

--------------------------------------------------------------------------------

local function OnChildSpawned(inst, child)
    child:OnSpawnedBy(inst)
end

local function ConfigureShadelingSpawn(inst, stage)
    stage = stage or inst._stage

    local childspawner = inst.components.childspawner

    if childspawner ~= nil then
        local tuning = TUNING.RIFT_SHADOW1_FUSED_SHADELING_SPAWN_RATE_BY_STAGE[stage]

        childspawner:SetRegenPeriod(tuning.REGEN_TIME)
        childspawner:SetSpawnPeriod(tuning.RELEASE_TIME)
        childspawner:SetMaxChildren(tuning.MAX_CHILDREN)
    end
end

--------------------------------------------------------------------------------

local function SetMaxMinimapStatus(inst)
    inst.MiniMapEntity:SetIcon("shadowrift_portal_max.png")
    inst.icon_max = true
end

local function SpawnStageFx(inst)
    local scale = inst._stage * 0.5

    local fx = SpawnPrefab("statue_transition")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx.Transform:SetScale(scale, scale, scale)

    return fx
end

local function GetStageUpTime(inst)
    return TUNING.RIFT_SHADOW1_STAGEUP_BASE_TIME + TUNING.RIFT_SHADOW1_STAGEUP_RANDOM_TIME * math.random()
end

local function CreateMiasma(inst, initial)
    local miasmamanager = TheWorld.components.miasmamanager
    if miasmamanager then
        local x, y, z = inst.Transform:GetWorldPosition()

        if initial then
            miasmamanager:CreateMiasmaAtPoint(x - TILE_SCALE, 0, z - TILE_SCALE)
            miasmamanager:CreateMiasmaAtPoint(x, 0, z - TILE_SCALE)
            miasmamanager:CreateMiasmaAtPoint(x + TILE_SCALE, 0, z - TILE_SCALE)
            miasmamanager:CreateMiasmaAtPoint(x - TILE_SCALE, 0, z)
            miasmamanager:CreateMiasmaAtPoint(x + TILE_SCALE, 0, z)
            miasmamanager:CreateMiasmaAtPoint(x - TILE_SCALE, 0, z + TILE_SCALE)
            miasmamanager:CreateMiasmaAtPoint(x, 0, z + TILE_SCALE)
            miasmamanager:CreateMiasmaAtPoint(x + TILE_SCALE, 0, z + TILE_SCALE)
        else
            local theta = math.random() * PI2
            local ox, oz = TILE_SCALE * math.cos(theta), TILE_SCALE * math.sin(theta)

            miasmamanager:CreateMiasmaAtPoint(x + ox, 0, z + oz)
        end
    end
end

local function Initialize(inst)
    inst:SpawnStageFx()

    inst:ConfigureShadelingSpawn()
    inst:CreateMiasma(true) -- Initial seed placement.

    inst.components.groundpounder.initialRadius = PHYSICS_SIZE_BY_STAGE[inst._stage]

    inst.components.groundpounder:GroundPound()
    inst.components.groundpounder:GroundPound() -- For pushing items and digging stumps, it's probably not the best thing to do.

    inst.SoundEmitter:PlaySound("rifts2/shadow_rift/groundcrack_expand")

    local duration, speed, scale, max_dist = unpack(SHAKE_PARAMS_BY_STAGE[inst._stage])
    ShakeAllCameras(CAMERASHAKE.FULL, duration, speed, scale, inst, max_dist)
end

local function TryStageUp(inst)
    if inst._closing then return end

    if inst._stage < TUNING.RIFT_SHADOW1_MAXSTAGE then
        local next_stage = inst._stage + 1
        inst._stage = next_stage

        if inst._fx then
            inst._fx:PlayStage(next_stage)
        end

        inst:SpawnStageFx()

        inst:ConfigureShadelingSpawn(next_stage)

        inst.components.groundpounder.initialRadius = PHYSICS_SIZE_BY_STAGE[next_stage]
        inst.components.groundpounder:GroundPound()

        inst.Physics:SetCylinder(PHYSICS_SIZE_BY_STAGE[next_stage], 6)

        local duration, speed, scale, max_dist = unpack(SHAKE_PARAMS_BY_STAGE[next_stage])
        ShakeAllCameras(CAMERASHAKE.FULL, duration, speed, scale, inst, max_dist)

        inst.AnimState:PlayAnimation("stage_"..next_stage.."_pre")
        inst.AnimState:PushAnimation("stage_"..next_stage.."_loop", true)

        inst.SoundEmitter:SetParameter(AMBIENT_SOUND_LOOP_NAME, AMBIENT_SOUND_PARAM_NAME, AMBIENT_SOUND_STAGE_TO_INTENSITY[next_stage])
        inst.SoundEmitter:PlaySound("rifts2/shadow_rift/groundcrack_expand")

        if next_stage < TUNING.RIFT_SHADOW1_MAXSTAGE then
            if not inst.components.timer:TimerExists("trynextstage") then
                inst.components.timer:StartTimer("trynextstage", GetStageUpTime())
            end
        else
            inst.components.timer:StopTimer("trynextstage")
        end

        if next_stage == TUNING.RIFT_SHADOW1_MAXSTAGE then
            inst:SetMaxMinimapStatus()
            TheWorld:PushEvent("ms_shadowrift_maxsize", inst)
        end
    else
        inst.AnimState:PlayAnimation("stage_"..inst._stage.."_loop", true)
    end
end

local function ClosePortal(inst)
    inst._closing = true

    if inst:IsAsleep() then
        inst:Remove()
    else
        inst.AnimState:PlayAnimation("disappear")
        inst.SoundEmitter:PlaySound("rifts/portal/portal_disappear")

        if inst._fx then
            inst._fx:Disappear()
        end

        local time = inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime() + FRAMES
        inst.components.timer:StartTimer("be_removed", time)
    end
end

--------------------------------------------------------------------------------

local function OnTimerDone(inst, data)
    if data.name == "seedmiasma" then
        inst:CreateMiasma()
    elseif data.name == "trynextstage" then
        inst:TryStageUp()
    elseif data.name == "be_removed" then
        inst:Remove()
    elseif data.name == "close" then
        ClosePortal(inst)
    elseif data.name == "initialize" then
        Initialize(inst)
    end
end

local function OnPortalRemoved(inst)
    -- Remove the miasma here?
end

--------------------------------------------------------------------------------

local function CreateParticleFx(inst)
    local fx = SpawnPrefab("shadowrift_portal_fx")
    inst:AddChild(fx)

    return fx
end

local function ParticlePlayStage(inst, stage, load)
    if load then
        inst.AnimState:PlayAnimation("particle_"..stage.."_loop", true)
    else
        inst.AnimState:PlayAnimation("particle_"..stage.."_pre")
        inst.AnimState:PushAnimation("particle_"..stage.."_loop", true)
    end
end

local function ParticleDisappear(inst)
    inst.AnimState:PlayAnimation("particle_disappear")
end

--------------------------------------------------------------------------------

local function OnPortalSleep(inst)
    inst.SoundEmitter:KillSound(AMBIENT_SOUND_LOOP_NAME)

    if inst._fx then
        inst._fx:Remove()
        inst._fx = nil
        inst.highlightchildren = nil
    end
end

local function OnPortalWake(inst)
    inst.components.childspawner:StartSpawning()

    inst.SoundEmitter:PlaySound(AMBIENT_SOUND_PATH, AMBIENT_SOUND_LOOP_NAME)
    inst.SoundEmitter:SetParameter(AMBIENT_SOUND_LOOP_NAME, AMBIENT_SOUND_PARAM_NAME, AMBIENT_SOUND_STAGE_TO_INTENSITY[inst._stage])

    if not inst._fx then
        inst._fx = CreateParticleFx(inst)
        inst._fx:PlayStage(inst._stage, true)
        inst.highlightchildren = {inst._fx}
    end
end

--------------------------------------------------------------------------------

local function OnPortalSave(inst, data)
    data.stage = inst._stage

    -- We can't just flag with persists = false, because we need to fire the onremove listener to clean up the area.
    data.finished = inst.components.timer:TimerExists("be_removed")
end

local function OnPortalLoad(inst, data)
    if data then
        inst._stage = data.stage or inst._stage
        if inst._stage >= TUNING.RIFT_SHADOW1_MAXSTAGE then
            inst.components.timer:StopTimer("trynextstage")
        end

        inst.Physics:SetCylinder(PHYSICS_SIZE_BY_STAGE[inst._stage], 6)

        inst.components.groundpounder.initialRadius = PHYSICS_SIZE_BY_STAGE[inst._stage]

        if data.finished then
            inst.AnimState:PlayAnimation("disappear")
            inst.components.timer:StartTimer("be_removed", 5)

            if inst._fx then
                inst._fx:Disappear()
            end
        else
            inst.AnimState:PlayAnimation("stage_"..inst._stage.."_loop", true)
            if inst._fx then
                inst._fx:PlayStage(inst._stage, true)
            end
        end
    end
end

local function OnPortalLoadPostPass(inst, newents, data)
    -- If we're loading anything, stop our timer.
    inst.components.timer:StopTimer("initialize")

    inst.SoundEmitter:KillSound(AMBIENT_SOUND_LOOP_NAME)

    if not inst:IsAsleep() then
        inst.SoundEmitter:PlaySound(AMBIENT_SOUND_PATH, AMBIENT_SOUND_LOOP_NAME)
        inst.SoundEmitter:SetParameter(AMBIENT_SOUND_LOOP_NAME, AMBIENT_SOUND_PARAM_NAME, AMBIENT_SOUND_STAGE_TO_INTENSITY[inst._stage])
    end

    if inst._stage == TUNING.RIFT_SHADOW1_MAXSTAGE then
        inst:SetMaxMinimapStatus()
        TheWorld:PushEvent("ms_shadowrift_maxsize", inst)
    end

    inst:ConfigureShadelingSpawn()
end

local function OnPortalLongUpdate(inst, dt)
    if inst._stage + 1 >= TUNING.RIFT_SHADOW1_MAXSTAGE then
        -- Do nothing, the timer cmp will already do one long update.
        return
    end

    local timer = inst.components.timer

    local trynextstage_timeleft = timer:GetTimeLeft("trynextstage")
    
    if trynextstage_timeleft ~= nil then
        local stageup_time = GetStageUpTime()

        -- Try to skip one stage if possible.
        if dt >= stageup_time then
            inst:TryStageUp()

            -- Increases the remaining time, so that the timer's LongUpdate considers this stage skip time.
            timer:SetTimeLeft("trynextstage", trynextstage_timeleft + stageup_time)
        end
    end
end


local function do_marker_minimap_swap(inst)
    inst.marker_index = inst.marker_index == nil and 0 or ((inst.marker_index + 1) % 4)
    
    local max = ""
    if inst.icon_max then
        max = "_max"
    end

    local marker_image = "shadowrift_portal"..max..(inst.marker_index +1)..".png"  --_max

    --inst.MiniMapEntity:SetIcon(marker_image)
    inst.icon.MiniMapEntity:SetIcon(marker_image)
end

local function show_minimap(inst)
    -- Create a global map icon so the minimap icon is visible to other players as well.
    inst.icon = SpawnPrefab("globalmapicon")
    inst.icon:TrackEntity(inst)
    inst.icon.MiniMapEntity:SetPriority(21)

    inst:DoPeriodicTask(TUNING.STORM_SWAP_TIME, do_marker_minimap_swap)
end


--------------------------------------------------------------------------------

local function portalfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, PHYSICS_SIZE_BY_STAGE[1])
    inst.Physics:SetCylinder(PHYSICS_SIZE_BY_STAGE[1], 6)

    inst.MiniMapEntity:SetIcon("shadowrift_portal.png")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)
    inst.MiniMapEntity:SetPriority(22)

    local animstate = inst.AnimState
    animstate:SetBank ("shadowrift_portal")
    animstate:SetBuild("shadowrift_portal")
    animstate:PlayAnimation("stage_1_pre")
    animstate:PushAnimation("stage_1_loop", true)
    animstate:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)
    animstate:SetLayer(LAYER_BACKGROUND)
    animstate:SetSortOrder(2)

	inst:SetDeploySmartRadius(3.5)

    inst.AnimState:SetSymbolLightOverride("fx_beam",   1)
    inst.AnimState:SetSymbolLightOverride("fx_spiral", 1)
    inst.AnimState:SetLightOverride(0.5)

    inst:AddTag("birdblocker")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("notarget")
    inst:AddTag("scarytoprey")
    inst:AddTag("shadowrift_portal")

    inst.entity:SetPristine()

    inst._fx = CreateParticleFx(inst)
    inst.highlightchildren = {inst._fx}    
    inst.highlightoverride = {0.15, 0, 0}

    inst.scrapbook_anim = "scrapbook" -- "stage_3_loop"
    inst.scrapbook_nodamage = true
    inst.scrapbook_specialinfo = "SHADOWRIFTPORTAL"

    if not TheWorld.ismastersim then
        return inst
    end

    inst._stage = 1

    inst:AddComponent("inspectable")

    local combat = inst:AddComponent("combat")
    combat:SetDefaultDamage(TUNING.RIFT_SHADOW1_GROUNDPOUND_DAMAGE)
    combat.playerdamagepercent = 0.5

    local groundpounder = inst:AddComponent("groundpounder")
    table.insert(groundpounder.noTags, "shadow_aligned")
	groundpounder:UseRingMode()
    groundpounder.radiusStepDistance = 1.5
    groundpounder.inventoryPushingRings = 2
    groundpounder.numRings = 2
    groundpounder.destroyer = true

    local timer = inst:AddComponent("timer")
    timer:StartTimer("initialize", 0)
    timer:StartTimer("close", TUNING.RIFT_SHADOW1_CLOSE_TIME)
    timer:StartTimer("trynextstage", GetStageUpTime())
    timer:StartTimer("seedmiasma", TUNING.TOTAL_DAY_TIME * 0.25)

    -------------------

    local childspawner = inst:AddComponent("childspawner")
    childspawner.childname = "fused_shadeling"
    childspawner:SetSpawnedFn(OnChildSpawned)

    --
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("onremove",  OnPortalRemoved)

    --
    inst.OnEntitySleep = OnPortalSleep
    inst.OnEntityWake = OnPortalWake
    inst.OnSave = OnPortalSave
    inst.OnLoad = OnPortalLoad
    inst.OnLoadPostPass = OnPortalLoadPostPass
    inst.OnLongUpdate = OnPortalLongUpdate

    inst.TryStageUp = TryStageUp
    inst.CreateMiasma = CreateMiasma
    inst.ConfigureShadelingSpawn = ConfigureShadelingSpawn

    inst.SpawnStageFx = SpawnStageFx
    inst.SetMaxMinimapStatus = SetMaxMinimapStatus

    inst:DoTaskInTime(0, show_minimap)

    return inst
end

local function portalfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    local animstate = inst.AnimState
    animstate:SetBank("shadowrift_portal")
    animstate:SetBuild("shadowrift_portal")
    animstate:PlayAnimation("particle_1_pre")
    animstate:PushAnimation("particle_1_loop", true)

    inst.AnimState:SetLightOverride(1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.PlayStage = ParticlePlayStage
    inst.Disappear = ParticleDisappear

    return inst
end

--------------------------------------------------------------------------------

local rift_portal_defs = require("prefabs/rift_portal_defs")
local RIFTPORTAL_FNS = rift_portal_defs.RIFTPORTAL_FNS
local RIFTPORTAL_CONST = rift_portal_defs.RIFTPORTAL_CONST
rift_portal_defs = nil

RIFTPORTAL_FNS.CreateRiftPortalDefinition("shadowrift_portal", {
    CustomAllowTest = function(_map, x, y, z)
        local id, index = _map:GetTopologyIDAtPoint(x, y, z)
        local r = (
            id:find("BigBatCave") or id:find("RockyLand") or id:find("SpillagmiteCaverns") or id:find("LichenLand") or
            id:find("BlueForest") or id:find("RedForest") or id:find("GreenForest")
        ) and true or false
        return r
    end,
    Affinity = RIFTPORTAL_CONST.AFFINITY.SHADOW,
})

--------------------------------------------------------------------------------

return
        Prefab("shadowrift_portal",    portalfn,   assets, prefabs),
        Prefab("shadowrift_portal_fx", portalfxfn, assets, prefabs)
