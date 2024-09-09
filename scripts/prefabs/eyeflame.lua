local SHADER1 = "shaders/vfx_particle_reveal.ksh"
local TEXTURE1 = "fx/animsmoke.tex"
local COLOUR_ENVELOPE_NAME1 = "eyeflame_colourenvelope1"
local SCALE_ENVELOPE_NAME1 = "eyeflame_scaleenvelope1"

local SHADER2 = "shaders/vfx_particle_add.ksh"
local TEXTURE2 = "fx/torchfire.tex"
local COLOUR_ENVELOPE_NAME2 = "eyeflame_colourenvelope2"
local SCALE_ENVELOPE_NAME2 = "eyeflame_scaleenvelope2"

local assets =
{
    Asset("IMAGE", TEXTURE1),
    Asset("IMAGE", TEXTURE2),
    Asset("SHADER", SHADER1),
    Asset("SHADER", SHADER2),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME1,
        {
            { 0,    IntColour(200, 85, 60, 5) },
            { .19,  IntColour(200, 125, 80, 51) },
            { .35,  IntColour(255, 20, 10, 51) },
            { .51,  IntColour(255, 20, 10, 51) },
            { .75,  IntColour(255, 20, 10, 51) },
            { 1,    IntColour(255, 7, 5, 0) },
        }
    )

    local fire_max_scale = .1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME1,
        {
            { 0,    { fire_max_scale * .5, fire_max_scale * .5 } },
            { .55,  { fire_max_scale * 1.3, fire_max_scale * 1.3 } },
            { 1,    { fire_max_scale * 1.5, fire_max_scale * 1.5 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME2,
        {
            { 0,    IntColour(187, 111, 60, 128) },
            { .49,  IntColour(187, 111, 60, 128) },
            { .5,   IntColour(255, 255, 0, 128) },
            { .51,  IntColour(255, 30, 56, 128) },
            { .75,  IntColour(255, 30, 56, 128) },
            { 1,    IntColour(255, 7, 28, 0) },
        }
    )

    fire_max_scale = 3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME2,
        {
            { 0,    { fire_max_scale * .5, fire_max_scale } },
            { 1,    { fire_max_scale * .5 * .5, fire_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local FIRE_MAX_LIFETIME1 = .9

local function emit_fire_fn1(effect, sphere_emitter)
    local vx, vy, vz = .005 * UnitRand(), 0, .0005 * UnitRand()
    local lifetime = FIRE_MAX_LIFETIME1 * (.9 + UnitRand() * .1)
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

local FIRE_MAX_LIFETIME2 = .9

local function emit_fire_fn2(effect, sphere_emitter)
    local vx, vy, vz = .009 * UnitRand(), 0, .009 * UnitRand()
    local lifetime = FIRE_MAX_LIFETIME2 * (.9 + UnitRand() * .1)
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.persists = false

    -----------------------------------------------------

    if InitEnvelope ~= nil then
        InitEnvelope()
    end

    -----------------------------------------------------

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    --FIRE
    effect:SetRenderResources(0, TEXTURE1, SHADER1)
    effect:SetMaxNumParticles(0, 32)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, FIRE_MAX_LIFETIME1)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME1)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME1)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 1, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 1)
    effect:SetKillOnEntityDeath(0, true)
    effect:SetFollowEmitter(0, true)

    --FIRE2
    effect:SetRenderResources(1, TEXTURE2, SHADER2)
    effect:SetMaxNumParticles(1, 64)
    effect:SetMaxLifetime(1, FIRE_MAX_LIFETIME2)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME2)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME2)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, .25, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 2)
    effect:SetFollowEmitter(1, true)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local fire_desired_pps = 6
    local fire_particles_per_tick = fire_desired_pps * tick_time
    local fire_num_particles_to_emit = 0

    local fire_desired_pps2 = 6
    local fire_particles_per_tick2 = fire_desired_pps2 * tick_time
    local fire_num_particles_to_emit2 = 1

    local sphere_emitter = CreateSphereEmitter(.05)

    EmitterManager:AddEmitter(inst, nil, function()
        --FIRE
        while fire_num_particles_to_emit > 1 do
            emit_fire_fn1(effect, sphere_emitter)
            fire_num_particles_to_emit = fire_num_particles_to_emit - 1
        end
        fire_num_particles_to_emit = fire_num_particles_to_emit + fire_particles_per_tick * math.random() * 3

        --FIRE2
        while fire_num_particles_to_emit2 > 1 do
            emit_fire_fn2(effect, sphere_emitter)
            fire_num_particles_to_emit2 = fire_num_particles_to_emit2 - 1
        end
        fire_num_particles_to_emit2 = fire_num_particles_to_emit2 + fire_particles_per_tick2
    end)

    return inst
end

return Prefab("eyeflame", fn, assets)
