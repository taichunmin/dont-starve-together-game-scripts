local TEXTURE = "fx/wintersnow_cane.tex"

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "cane_candy_colourenvelope"
local SCALE_ENVELOPE_NAME = "cane_candy_scaleenvelope"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(255, 255, 255, 0) },
            { 0.05,  IntColour(255, 255, 255, 200) },
            { 0.85,  IntColour(255, 255, 255, 200) },
            { 1,    IntColour(255, 255, 255, 0) },
        }
   )

    local max_scale = .4
    local end_scale = .6
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { max_scale, max_scale } },
            { 0.5,  { max_scale, max_scale } },
            { 1,    { end_scale * max_scale, end_scale * max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 4.5

local function emit_fn(effect, emitter_fn)
    local vx, vy, vz = 0.006 * UnitRand(), -0.015 + 0.006 * (UnitRand() - 1), 0.006 * UnitRand()
    local lifetime = MAX_LIFETIME * (.6 + math.random() * .4)
    local px, py, pz = emitter_fn()

    local angle = math.random() * 360
    local uv_offset = math.random(0, 7) * .125
    local ang_vel = UnitRand() * 2

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    --SNOW
    effect:SetRenderResources(0, TEXTURE, SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetGroundPhysics(0, true)
    effect:SetUVFrameSize(0, .125, 1)
    effect:SetMaxNumParticles(0, 512)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    --effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 0)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local desired_pps_low = 3
    local desired_pps_high = 50
    local low_per_tick = desired_pps_low * tick_time
    local high_per_tick = desired_pps_high * tick_time
    local num_to_emit = 0

    local emitter_fn = CreateBoxEmitter( -0.1, -0.3, -0.1, 0.1, 0.2, 0.1 )
    inst.last_pos = inst:GetPosition()

    EmitterManager:AddEmitter(inst, nil, function()
        local dist_moved = inst:GetPosition() - inst.last_pos
        local move = dist_moved:Length()
        move = math.clamp(move*6, 0, 1)

        local per_tick = Lerp(low_per_tick, high_per_tick, move)

        inst.last_pos = inst:GetPosition()

        num_to_emit = num_to_emit + per_tick * math.random() * 3
        while num_to_emit > 1 do
            emit_fn(effect, emitter_fn)
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end

return Prefab("cane_candy_fx", fn, assets)
