local MakeTorchFire = require("prefabs/torchfire_common")

local SMOKE_TEXTURE = "fx/smoke.tex"
local TEXTURE = "fx/torchfire.tex"

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "firesmokecolourenvelope"
local SCALE_ENVELOPE_NAME_SMOKE = "firesmokescaleenvelope"
local COLOUR_ENVELOPE_NAME = "firecolourenvelope"
local SCALE_ENVELOPE_NAME = "firescaleenvelope"

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
        COLOUR_ENVELOPE_NAME_SMOKE,
        {
            { 0,    IntColour(35, 32, 30, 0) },
            { .3,   IntColour(35, 32, 30, 100) },
            { .55,  IntColour(30, 30, 30, 28) },
            { 1,    IntColour(30, 30, 30, 0) },
        }
    )

    local smoke_max_scale = 1.25
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,    { smoke_max_scale * .4, smoke_max_scale * .4} },
            { .50,  { smoke_max_scale * .6, smoke_max_scale * .6} },
            { .65,  { smoke_max_scale * .9, smoke_max_scale * .9} },
            { 1,    { smoke_max_scale, smoke_max_scale} },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(187, 111, 60, 128) },
            { .49,  IntColour(187, 111, 60, 128) },
            { .5,   IntColour(255, 255, 0, 128) },
            { .51,  IntColour(255, 30, 56, 128) },
            { .75,  IntColour(255, 30, 56, 128) },
            { 1,    IntColour(255, 7, 28, 0) },
        }
    )

    local max_scale = 3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { max_scale * .5, max_scale } },
            { 1,    { max_scale * .5 * .5, max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local FIRE_MAX_LIFETIME = .3
local SMOKE_MAX_LIFETIME = .7

local function emit_smoke_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), .05, .01 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        uv_offset, 0        -- uv offset
    )
end

local function emit_fire_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()
    local lifetime = FIRE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        1,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        uv_offset, 0        -- uv offset
    )
end

--------------------------------------------------------------------------

local function common_postinit(inst)
    --Dedicated server does not need to spawn local particle fx


    if TheNet:IsDedicated() then        
        return
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    -----------------------------------------------------

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    --SMOKE
    effect:SetRenderResources(0, SMOKE_TEXTURE, SHADER)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 1)
    effect:SetRadius(0, 2) --only needed on a single emitter

    --FIRE
    effect:SetRenderResources(1, TEXTURE, SHADER)
    effect:SetMaxNumParticles(1, 64)
    effect:SetMaxLifetime(1, FIRE_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, .25, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 2)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local smoke_desired_pps = 80
    local smoke_particles_per_tick = smoke_desired_pps * tick_time
    local smoke_num_particles_to_emit = -50 --start delay

    local fire_desired_pps = 40
    local fire_particles_per_tick = fire_desired_pps * tick_time
    local fire_num_particles_to_emit = 1

    local sphere_emitter = CreateSphereEmitter(.05)

    EmitterManager:AddEmitter(inst, nil, function()
        --SMOKE
        while smoke_num_particles_to_emit > 1 do
            emit_smoke_fn(effect, sphere_emitter)
            smoke_num_particles_to_emit = smoke_num_particles_to_emit - 1
        end
        smoke_num_particles_to_emit = smoke_num_particles_to_emit + smoke_particles_per_tick

        --FIRE
        while fire_num_particles_to_emit > 1 do
            emit_fire_fn(effect, sphere_emitter)
            fire_num_particles_to_emit = fire_num_particles_to_emit - 1
        end
        fire_num_particles_to_emit = fire_num_particles_to_emit + fire_particles_per_tick
    end)
end

local function master_postinit(inst)
    inst.fx_offset = -110
end

return MakeTorchFire("torchfire", assets, nil, common_postinit, master_postinit)
