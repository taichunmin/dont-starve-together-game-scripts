local MakeTorchFire = require("prefabs/torchfire_common")

local FIRE_TEXTURE = "fx/torchfire.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local SHADER = "shaders/vfx_particle.ksh"
local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "torch_pillar_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "torch_pillar_scaleenvelope_smoke"
local COLOUR_ENVELOPE_NAME = "torch_pillar_colourenvelope"
local SCALE_ENVELOPE_NAME = "torch_pillar_scaleenvelope"

local assets =
{
    Asset("IMAGE", FIRE_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", SHADER),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE,
        {
            { 0,    IntColour(24, 24, 24, 64) },
            { .2,   IntColour(20, 20, 20, 240) },
            { .7,   IntColour(18, 18, 18, 256) },
            { 1,    IntColour(12, 12, 12, 0) },
        }
    )

    local smoke_max_scale = .3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,    { smoke_max_scale * .2, smoke_max_scale * .2 } },
            { .40,  { smoke_max_scale * .7, smoke_max_scale * .7 } },
            { .60,  { smoke_max_scale * .8, smoke_max_scale * .8 } },
            { .75,  { smoke_max_scale * .7, smoke_max_scale * .7 } },
            { 1,    { smoke_max_scale, smoke_max_scale } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(200, 85, 60, 25) },
            { .19,  IntColour(200, 125, 80, 100) },
            { .35,  IntColour(255, 20, 10, 200) },
            { .51,  IntColour(255, 20, 10, 128) },
            { .75,  IntColour(255, 20, 10, 64) },
            { 1,    IntColour(255, 7, 5, 0) },
        }
    )

    local fire_max_scale = 4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { fire_max_scale * .9, fire_max_scale } },
            { 1,    { fire_max_scale * .5, fire_max_scale * .4 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local SMOKE_MAX_LIFETIME = 1.1
local FIRE_MAX_LIFETIME = .25

local function emit_fire_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), 0, .01 * UnitRand()
    local lifetime = FIRE_MAX_LIFETIME * (.9 + UnitRand() * .1)
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

local function emit_smoke_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), .06 + .02 * UnitRand(), .01 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    --offset the flame particles upwards a bit so they can be used on a torch

    effect:AddRotatingParticleUV(
        1,
        lifetime,           -- lifetime
        px, py + .35, pz,   -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* TWOPI, -- angle
        UnitRand() * 2,     -- angle velocity
        0, 0                -- uv offset
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

    --FIRE
    effect:SetRenderResources(0, FIRE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, FIRE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    --SMOKE
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER) --REVEAL_SHADER --particle_add
    effect:SetMaxNumParticles(1, 32)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 1, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 1)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local fire_desired_pps = 40
    local fire_particles_per_tick = fire_desired_pps * tick_time
    local fire_num_particles_to_emit = 0

    local smoke_desired_pps = 10
    local smoke_particles_per_tick = smoke_desired_pps * tick_time
    local smoke_num_particles_to_emit = -5 --start delay

    local sphere_emitter = CreateSphereEmitter(.05)

    EmitterManager:AddEmitter(inst, nil, function()
        --FIRE
        while fire_num_particles_to_emit > 1 do
            emit_fire_fn(effect, sphere_emitter)
            fire_num_particles_to_emit = fire_num_particles_to_emit - 1
        end
        fire_num_particles_to_emit = fire_num_particles_to_emit + fire_particles_per_tick * math.random() * 3

        --SMOKE
        while smoke_num_particles_to_emit > 1 do
            emit_smoke_fn(effect, sphere_emitter)
            smoke_num_particles_to_emit = smoke_num_particles_to_emit - 1
        end
        smoke_num_particles_to_emit = smoke_num_particles_to_emit + smoke_particles_per_tick
    end)
end

local function master_postinit(inst)
    inst.fx_offset = -130
end

return MakeTorchFire("torchfire_pillar", assets, nil, common_postinit, master_postinit)
