local prefabs =
{
    "moon_altar_link_fx",

    "moonpulse_fx",
    "moonpulse2_fx",
}

local spawner_prefabs =
{
    "moonpulse",
}

local DIST_FOR_MAX_COVERAGE = 40

local GLOW_INTENSITY_GAIN = 1.75
local GLOW_INTENSITY_DROP = 0.32

local WISP_SPAWN_FREQ_MIN = 0.04
local WISP_SPAWN_FREQ_MAX = 0.07
local WISP_SPAWN_OFFSET_MIN = 4
local WISP_SPAWN_OFFSET_VARIANCE = 32

local function SpawnWisp(inst)
    if ThePlayer ~= nil and ThePlayer:IsValid() then
        local x, _, z = ThePlayer.Transform:GetWorldPosition()
        local theta = math.random() * TWOPI
        local offset = WISP_SPAWN_OFFSET_MIN + math.random() * WISP_SPAWN_OFFSET_VARIANCE
        SpawnPrefab("moon_altar_link_fx").Transform:SetPosition(x + math.cos(theta) * offset, 0, z + math.sin(theta) * offset)

        inst.num_spawn_wisps = inst.num_spawn_wisps - 1
        if inst.num_spawn_wisps > 0 then
            inst:DoTaskInTime(WISP_SPAWN_FREQ_MIN + math.random() * WISP_SPAWN_FREQ_MAX, SpawnWisp)
        end
    end
end

local function PlayScreenFlash(inst)
    if not inst.fading_out then
        TheWorld:PushEvent("screenflash", .5)
    end
end

local function SmallWaveFX(inst)
    if ThePlayer ~= nil and ThePlayer:IsValid() then
        ThePlayer:ShakeCamera(CAMERASHAKE.SIDE, 0.74, 0.025, 0.28)
    end

    local x, _, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("moonpulse_fx").Transform:SetPosition(x, 0, z)

    inst.num_spawn_wisps = 8
    SpawnWisp(inst)

    TheFocalPoint.SoundEmitter:PlaySound("grotto/common/moon_alter/link/wave1")
end

local function BigWaveFX(inst)
    if ThePlayer ~= nil and ThePlayer:IsValid() then
        ThePlayer:ShakeCamera(CAMERASHAKE.SIDE, 4*FRAMES, 0.012, 4)
    end

    inst:DoTaskInTime(3*FRAMES, function(inst)
        if ThePlayer ~= nil and ThePlayer:IsValid() then
            ThePlayer:ShakeCamera(CAMERASHAKE.SIDE, 2.18, 0.025, 0.65)
        end
    end)

    local x, _, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("moonpulse2_fx").Transform:SetPosition(x, 0, z)

    inst.num_spawn_wisps = 17
    SpawnWisp(inst)

    TheFocalPoint.SoundEmitter:PlaySound("grotto/common/moon_alter/link/wave2")
end

local STAGES =
{
    {
        WAVE_SPEED_MULTIPLIER = 0.7,
        HOLD = 0.85,
        ENTER_FN = function(inst)
            inst:DoTaskInTime(0.18, SmallWaveFX)
        end,
    },
    {
        WAVE_SPEED_MULTIPLIER = 0.7,
        HOLD = 1.15,
        ENTER_FN = function(inst)
            inst:DoTaskInTime(0.18, SmallWaveFX)
        end,
    },
    {
        WAVE_SPEED_MULTIPLIER = 0.39,
        HOLD = 1.7,
        ENTER_FN = function(inst)
            inst:DoTaskInTime(0.18, BigWaveFX)
        end,
    },
}

local function incrementStage(inst)
    inst.wave_progress = 0

    inst.stage = inst.stage + 1

    if inst.stage > #STAGES then
        inst.fading_out = true
    else
        if STAGES[inst.stage].ENTER_FN ~= nil then
            STAGES[inst.stage].ENTER_FN(inst)
        end
    end
end

local function Update(inst)
    if inst.stage <= #STAGES then
        local stage_data = STAGES[inst.stage]

        inst.glow_intensity = math.min(1, inst.glow_intensity + GLOW_INTENSITY_GAIN * FRAMES)

        if inst.hold_time == nil or inst.hold_time <= 0 then
            inst.wave_progress = inst.wave_progress + FRAMES * stage_data.WAVE_SPEED_MULTIPLIER

            if inst.wave_progress >= 1 then
                inst.wave_progress = 1

                if stage_data.HOLD ~= nil and stage_data.HOLD > 0 then
                    inst.hold_time = stage_data.HOLD
                else
                    incrementStage(inst)
                end
            end
        else
            inst.hold_time = inst.hold_time - FRAMES

            if inst.hold_time <= 0 then
                inst.hold_time = nil
                incrementStage(inst)
            end
        end
    else
        inst.glow_intensity = inst.glow_intensity - GLOW_INTENSITY_DROP * FRAMES

        if inst.glow_intensity <= 0 then
            inst:Remove()
        end
    end

    if ThePlayer ~= nil and ThePlayer:IsValid() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local px, py, pz = ThePlayer.Transform:GetWorldPosition()

        local dx, dz = px - x, pz - z

        local theta = VecUtil_GetAngleInRads(dx, dz)
        local dist = VecUtil_Length(dx, dz)

        local normalized_range_coefficient = math.clamp(dist / DIST_FOR_MAX_COVERAGE, 0, 1)
        local angle_to_player = theta - (PI / 4) - (((TheCamera.heading - 45) / 360) * TWOPI)
        PostProcessor:SetMoonPulseParams(angle_to_player, dist, inst.glow_intensity, inst.wave_progress)
        PostProcessor:SetMoonPulseGradingParams(angle_to_player, dist, inst.glow_intensity, inst.wave_progress)
    end
end

local function StartPostFX(inst)
    inst.stage = 1

    if STAGES[inst.stage].ENTER_FN ~= nil then
        STAGES[inst.stage].ENTER_FN(inst)
    end

    PostProcessor:EnablePostProcessEffect(PostProcessorEffects.MoonPulse, true)
    PostProcessor:EnablePostProcessEffect(PostProcessorEffects.MoonPulseGrading, true)

    -- Angle and distance to player params don't matter here since the effect is nullified; this is
    -- just to prevent the post process effect from flashing brightly the frame this object spawns
    PostProcessor:SetMoonPulseParams(0, 0, 0, 0)
    PostProcessor:SetMoonPulseGradingParams(0, 0, 0, 0)

    inst:DoPeriodicTask(FRAMES, Update)
end

local function onremove(inst)
    PostProcessor:EnablePostProcessEffect(PostProcessorEffects.MoonPulse, false)
    PostProcessor:EnablePostProcessEffect(PostProcessorEffects.MoonPulseGrading, false)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst.entity:SetCanSleep(false)

    if not TheNet:IsDedicated() then
        inst:AddTag("NOCLICK")
        inst:AddTag("NOBLOCK")

        StartPostFX(inst)

        inst:ListenForEvent("onremove", onremove)

        inst.persists = false

        -- inst.fading_out = nil
        -- inst.num_spawn_wisps = nil
        -- inst.stage = nil
        -- inst.hold_time = nil
        inst.wave_progress = 0
        inst.glow_intensity = 0

        inst:DoPeriodicTask(7*FRAMES, PlayScreenFlash, 0.28)
    else
        inst:DoTaskInTime(0, inst.Remove)
    end

    return inst
end

local function spawner_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetCanSleep(false)

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, function()
            local pulse = SpawnPrefab("moonpulse")
            if pulse ~= nil then
                local x, _, z = inst.Transform:GetWorldPosition()
                pulse.Transform:SetPosition(x, 0, z)
            end
        end)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

return Prefab("moonpulse", fn, nil, prefabs),
    Prefab("moonpulse_spawner", spawner_fn, nil, spawner_prefabs)
