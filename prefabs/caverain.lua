local TEXTURE = "fx/rain.tex"

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "raincolourenvelope"
local SCALE_ENVELOPE_NAME = "rainscaleenvelope"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}

local prefabs =
{
    "raindrop",
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
            { 1, IntColour(255, 255, 255, 200) },
        }
    )

    local max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { .5, max_scale } },
            { 1, { .5, max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local MAX_LIFETIME = 1
local MIN_LIFETIME = 1

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
    effect:SetRotationStatus(0, true)
    effect:SetMaxNumParticles(0, 4800)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    effect:SetSortOrder(0, 3)
    effect:SetDragCoefficient(0, .2)
    effect:EnableDepthTest(0, true)

    -----------------------------------------------------

    local rng = math.random
    local tick_time = TheSim:GetTickTime()

    local desired_particles_per_second = 0--1000
    local desired_splashes_per_second = 0--100

    inst.particles_per_tick = desired_particles_per_second * tick_time
    inst.splashes_per_tick = desired_splashes_per_second * tick_time

    inst.num_particles_to_emit = inst.particles_per_tick
    inst.num_splashes_to_emit = 0

    local bx, by, bz = 0, 20, 0
    local emitter_shape = CreateBoxEmitter(bx, by, bz, bx + 20, by, bz + 20)

    local angle = 0
    local dx = math.cos(angle * DEGREES)
    effect:SetAcceleration(0, dx, -9.80, 1 )

    local function emit_fn()
        local vy = -1 + UnitRand() * -2
        local vz = 0
        local vx = dx

        local lifetime = MIN_LIFETIME + (MAX_LIFETIME - MIN_LIFETIME) * UnitRand()
        local px, py, pz = emitter_shape()

        effect:AddRotatingParticle(
            0,                  -- the only emitter
            lifetime,           -- lifetime
            px, py, pz,         -- position
            vx, vy, vz,         -- velocity
            angle, 0            -- angle, angular_velocity
        )
    end

    local raindrop_offset = CreateDiscEmitter(20)

    local map = TheWorld.Map

    local function updateFunc(fastforward)
        while inst.num_particles_to_emit > 0 do
            emit_fn()
            inst.num_particles_to_emit = inst.num_particles_to_emit - 1
        end

        while inst.num_splashes_to_emit > 0 do
            local x, y, z = inst.Transform:GetWorldPosition()
            local dx, dz = raindrop_offset()

            x = x + dx
            z = z + dz

            if map:IsPassableAtPoint(x, y, z) then
                local raindrop = SpawnPrefab("raindrop")
                raindrop.Transform:SetPosition(x, y, z)

                if fastforward then
                    raindrop.AnimState:FastForward(fastforward)
                end
            end
            inst.num_splashes_to_emit = inst.num_splashes_to_emit - 1
        end

        inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick
        inst.num_splashes_to_emit = inst.num_splashes_to_emit + inst.splashes_per_tick
    end

    EmitterManager:AddEmitter(inst, nil, updateFunc)

    function inst:PostInit()
        local dt = 1 / 30
        local t = MAX_LIFETIME
        while t > 0 do
            t = t - dt
            updateFunc(t)
            effect:FastForward(0, dt)
        end
    end

    return inst
end

return Prefab("caverain", fn, assets, prefabs)
