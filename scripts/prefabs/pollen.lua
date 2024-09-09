local TEXTURE = "fx/snow.tex"

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "pollencolourenvelope"
local SCALE_ENVELOPE_NAME = "pollenscaleenvelope"

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
        {   { 0,    IntColour(255, 255, 0, 0) },
            { .5,   IntColour(255, 255, 0, 127) },
            { 1,    IntColour(255, 255, 0, 0) },
        }
    )

    local min_scale = .8
    local max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { min_scale, min_scale } },
            { .5,   { max_scale, max_scale } },
            { 1,    { min_scale, min_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local MAX_LIFETIME = 60
local MIN_LIFETIME = 30

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
    effect:SetRenderResources(0, TEXTURE, SHADER)
    effect:SetMaxNumParticles(0, 1000)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    effect:SetSortOrder(0, 3)
    --effect:SetLayer(0, LAYER_BACKGROUND)
    effect:SetAcceleration(0, 0, .0001, 0)
    effect:SetDragCoefficient(0, .0001)
    effect:EnableDepthTest(0, false)

    -----------------------------------------------------

    local rng = math.random
    local tick_time = TheSim:GetTickTime()

    local desired_particles_per_second = 0--300
    inst.particles_per_tick = desired_particles_per_second * tick_time

    inst.num_particles_to_emit = inst.particles_per_tick

    local halfheight = 2
    local emitter_shape = CreateBoxEmitter(0, 0, 0, 40, halfheight, 40)

    local map = TheWorld.Map
    local worldstate = TheWorld.state

    local function emit_fn()
        local x, y, z = inst.Transform:GetWorldPosition()
        local px, py, pz = emitter_shape()
        py = py + halfheight -- otherwise the particles appear under the ground
        x = x + px
        z = z + pz

        -- don't spawn particles over water
        if not TileGroupManager:IsImpassableTile(map:GetTileAtPoint(x, y, z)) then
            local vx = .03 * (math.random() - .5)
            local vy = 0
            local vz = .03 * (math.random() - .5)
            if worldstate.isday and GetTemperatureAtXZ(x, z) > TUNING.WILDFIRE_THRESHOLD then
                vx = vx * .1
                vy = .01
                vz = vz * .1
            end

            local lifetime = MIN_LIFETIME + (MAX_LIFETIME - MIN_LIFETIME) * UnitRand()

            effect:AddParticle(
                0,
                lifetime,           -- lifetime
                px, py, pz,         -- position
                vx, vy, vz          -- velocity
           )
        end
    end

    local function updateFunc()
        while inst.num_particles_to_emit > 1 do
            emit_fn()
            inst.num_particles_to_emit = inst.num_particles_to_emit - 1
        end
        inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick

        -- vary the acceleration with time in a circular pattern
        -- together with the random initial velocities this should give a variety of motion
        inst.time = inst.time + tick_time
        inst.interval = inst.interval + 1
        if 10 < inst.interval then
            inst.interval = 0
            if worldstate.isday and GetLocalTemperature(inst) > TUNING.WILDFIRE_THRESHOLD then
                local sin_val = .01 * math.sin(inst.time * .8)
                effect:SetAcceleration(0, 0, sin_val, 0)
            else
                local t = inst.time / 3
                local sin_val = .006 * math.sin(t)
                local cos_val = .006 * math.cos(t)
                effect:SetAcceleration(0, sin_val, .05 * sin_val, cos_val)
            end
        end
    end

    inst.time = 0
    inst.interval = 0

    EmitterManager:AddEmitter(inst, nil, updateFunc)

    function inst:PostInit()
        local dt = 1 / 30
        local t = MAX_LIFETIME
        while t > 0 do
            t = t - dt
            updateFunc()
            effect:FastForward(0, dt)
        end
    end

    return inst
end

return Prefab("pollen", fn, assets)
