local MakeLighterFire = require("prefabs/lighterfire_common")

local ANIMSMOKE_TEXTURE = "fx/animsmoke.tex"
local ANIMSMOKE2_TEXTURE = "fx/animsmoke2.tex"

local SHADER = "shaders/vfx_particle.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME = "lighterfirecolourenvelope_haunteddoll"
local SCALE_ENVELOPE_NAME = "lighterfirescaleenvelope_haunteddoll"

local COLOUR_ENVELOPE_NAME_SMOKE = "lighterfire_haunteddoll_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "lighterfire_haunteddoll_scaleenvelope_smoke"

local assets =
{
    Asset("IMAGE", ANIMSMOKE_TEXTURE),
    Asset("IMAGE", ANIMSMOKE2_TEXTURE),
    Asset("SHADER", SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(122, 30, 255, 255) },
            { .5,   IntColour(122, 20, 255, 255) },
            { .75,  IntColour(122, 10, 255, 255) },
            { 1,    IntColour(200, 5, 255, 255) },
        }
    )

    local max_scale = 0.09
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { max_scale * 0.1, max_scale * 0.1 } },
            { 0.2,  { max_scale * 0.4, max_scale * 0.4 } },
            { 1,    { max_scale * 0.8, max_scale } },
        }
    )

    local g = 8
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE,
        {
            { 0,    IntColour(g, g, g, 60) },
            { .2,   IntColour(g, g, g, 60) },
            { .8,   IntColour(g, g, g, 30) },
            { 1,    IntColour(g, g, g, 10) },
        }
    )

    local smoke_max_scale = 1.9
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,    { smoke_max_scale * .2, smoke_max_scale * .2} },
            { .40,  { smoke_max_scale * .7, smoke_max_scale * .7} },
            { .60,  { smoke_max_scale * .8, smoke_max_scale * .8} },
            { .75,  { smoke_max_scale * .9, smoke_max_scale * .9} },
            { 1,    { smoke_max_scale, smoke_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local MAX_LIFETIME = .5
local SMOKE_MAX_LIFETIME = 1.3

local function emit_fn(effect, sphere_emitter)
    local vx, vy, vz = .005 * UnitRand(), 0, .0005 * UnitRand()
    local lifetime = MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,-- angle
        UnitRand() * 2,     -- angle velocity
        0, 0                -- uv offset
    )
end

local function emit_smoke_fn(effect, sphere_emitter)
    local vx, vy, vz = 1.5 * UnitRand(), 2.0 + .02 * UnitRand(), 1.5 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    --offset the flame particles upwards a bit so they can be used on a torch

    local u_offset = math.random(0, 3) * .25
    local v_offset = math.random(0, 3) * .25

    effect:AddRotatingParticleUV(
        1,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 1,     -- angle velocity
        u_offset, v_offset                -- uv offset
    )
end

local function common_postinit(inst)
    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    effect:SetRenderResources(0, ANIMSMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 64)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 1, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 1)
    effect:SetKillOnEntityDeath(0, true)
    effect:SetFollowEmitter(0, true)

    --SMOKE
    effect:SetRenderResources(1, ANIMSMOKE2_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(1, 64)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 0.25)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetAcceleration(1, 0, -13, 0)
    effect:SetDragCoefficient(1, .95)
    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local particles_per_tick = 20 * tick_time
    local num_particles_to_emit = 1


    local moving_smoke_particles_per_tick = 40 * tick_time
    local idle_smoke_particles_per_tick = 5 * tick_time
    local smoke_num_particles_to_emit = -5 --start delay

    local sphere_emitter = CreateSphereEmitter(.05)

    inst.last_fx_position = inst:GetPosition()

    EmitterManager:AddEmitter(inst, nil, function()
        while num_particles_to_emit > 1 do
            emit_fn(effect, sphere_emitter)
            num_particles_to_emit = num_particles_to_emit - 1
        end
        num_particles_to_emit = num_particles_to_emit + particles_per_tick

        --SMOKE
        while smoke_num_particles_to_emit > 1 do
            emit_smoke_fn(effect, sphere_emitter)
            smoke_num_particles_to_emit = smoke_num_particles_to_emit - 1
        end

        --Movement speed based emission
        local move_mag = (inst:GetPosition() - inst.last_fx_position):LengthSq()
        if move_mag > 0.007 then
            smoke_num_particles_to_emit = smoke_num_particles_to_emit + moving_smoke_particles_per_tick
        else
            smoke_num_particles_to_emit = smoke_num_particles_to_emit + idle_smoke_particles_per_tick
        end
        inst.last_fx_position = inst:GetPosition()
    end)
end

local function master_postinit(inst)
    inst.fx_offset_x = 56
    inst.fx_offset_y = -55
end


return MakeLighterFire("lighterfire_haunteddoll", assets, nil, common_postinit, master_postinit)
