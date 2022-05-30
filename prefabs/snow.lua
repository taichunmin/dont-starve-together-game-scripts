local TEXTURE = "fx/snow.tex"
local WINTER_TEXTURE_OLD = "fx/wintersnow.tex"
local WINTER_TEXTURE = "fx/wintersnow_cane.tex"

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "snowcolourenvelope"
local SCALE_ENVELOPE_NAME = "snowscaleenvelope"
local WINTER_SCALE_ENVELOPE_NAME = "wintersnowscaleenvelope"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("IMAGE", WINTER_TEXTURE_OLD),
    Asset("IMAGE", WINTER_TEXTURE),
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
            { 0, IntColour(255, 255, 255, 200) },
            { 0.9, IntColour(255, 255, 255, 200) },
            { 1, IntColour(255, 255, 255, 0) },
        }
   )

    local max_scale = .3
    EnvelopeManager:AddVector2Envelope(
        WINTER_SCALE_ENVELOPE_NAME,
        {
            { 0, { max_scale, max_scale } },
            { 1, { max_scale, max_scale } },
        }
    )

    max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { max_scale, max_scale } },
            { 1, { max_scale, max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local MAX_LIFETIME = 7.5
local MIN_LIFETIME = 4.5

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()

    if InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    -----------------------------------------------------

    local rng = math.random
    local tick_time = TheSim:GetTickTime()

    local desired_particles_per_second = 0--300
    inst.particles_per_tick = desired_particles_per_second * tick_time

    inst.num_particles_to_emit = inst.particles_per_tick

    local bx, by, bz = 0, 20, 0
    local emitter_shape = CreateBoxEmitter(bx, by, bz, bx + 20, by, bz + 20)

    local use_uv_offset = false
    local particle_mult = 1

    local function emit_fn()
        local vx, vy, vz = 0, 0, 0
        local lifetime = MIN_LIFETIME + (MAX_LIFETIME - MIN_LIFETIME) * UnitRand()
        local px, py, pz = emitter_shape()

        if use_uv_offset then

            local angle = math.random() * 360
            local uv_offset = math.random(0, 7) * .125
            local ang_vel = UnitRand() * 4.0
            effect:AddRotatingParticleUV(
                0,
                lifetime,           -- lifetime
                px, py, pz,         -- position
                vx, vy, vz,         -- velocity
                angle, ang_vel,     -- angle, angular_velocity
                uv_offset, 0        -- uv offset
            )
        else
            effect:AddParticle(
                0,
                lifetime,           -- lifetime
                px, py, pz,         -- position
                vx, vy, vz          -- velocity
            )
        end
    end

    local init_effect = true
    local function update_fn()
        if init_effect then
            init_effect = nil
            if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                effect:SetRenderResources(0, WINTER_TEXTURE, SHADER)
                effect:SetScaleEnvelope(0, WINTER_SCALE_ENVELOPE_NAME)
                effect:SetUVFrameSize(0, .125, 1)
                effect:SetRotationStatus(0, true)
                use_uv_offset = true
                particle_mult = 2
                effect:SetAcceleration(0, -1, -9.80, 1)
                effect:SetDragCoefficient(0, .85)
            else
                effect:SetRenderResources(0, TEXTURE, SHADER)
                effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
                effect:SetAcceleration(0, -1, -9.80, 1)
                effect:SetDragCoefficient(0, .8)
            end
            effect:SetMaxNumParticles(0, 4800)
            effect:SetMaxLifetime(0, MAX_LIFETIME)
            effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
            effect:SetBlendMode(0, BLENDMODE.Premultiplied)
            effect:SetSortOrder(0, 3)
            effect:EnableDepthTest(0, true)
        end

        while inst.num_particles_to_emit > 1 do
            emit_fn()
            inst.num_particles_to_emit = inst.num_particles_to_emit - 1
        end
        inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick * particle_mult
    end

    EmitterManager:AddEmitter(inst, nil, update_fn)

    function inst:PostInit()
        local dt = 1 / 30
        local t = MAX_LIFETIME
        while t > 0 do
            t = t - dt
            update_fn()
            effect:FastForward(0, dt)
        end
    end

    return inst
end

return Prefab("snow", fn, assets)
