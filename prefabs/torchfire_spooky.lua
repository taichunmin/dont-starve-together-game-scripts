local MakeTorchFire = require("prefabs/torchfire_common")

local SMOKE_TEXTURE = "fx/smoke.tex"

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "torch_spooky_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "torch_spooky_scaleenvelope_smoke"

local assets =
{
    Asset("IMAGE", SMOKE_TEXTURE),
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
            { 0,    IntColour(30, 22, 15, 0) },
            { .3,   IntColour(20, 18, 15, 100) },
            { .52,  IntColour(15, 15, 15, 20) },
            { 1,    IntColour(15, 15, 15, 0) },
        }
    )

    local smoke_max_scale = 2.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,    { smoke_max_scale * .4, smoke_max_scale * .4 } },
            { .50,  { smoke_max_scale * .6, smoke_max_scale * .6 } },
            { .65,  { smoke_max_scale * .9, smoke_max_scale * .9 } },
            { 1,    { smoke_max_scale, smoke_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local SMOKE_MAX_LIFETIME = 1.1
local FIRE_MAX_LIFETIME = .9

local function emit_smoke_fn(effect, sphere_emitter)
    --SMOKE
    local vx, vy, vz = .01 * UnitRand(), .08 + .02 * UnitRand(), .01 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()
    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,           -- lifetime
        px, py + .2, pz,    -- position
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
    effect:InitEmitters(1)

    --SMOKE
    effect:SetRenderResources(0, SMOKE_TEXTURE, SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 1)
    effect:SetRadius(0, 3) --only needed on a single emitter

    -----------------------------------------------------
    local tick_time = TheSim:GetTickTime()

    local smoke_desired_pps = 80
    local smoke_particles_per_tick = smoke_desired_pps * tick_time
    local smoke_num_particles_to_emit = -50 --start delay

    local sphere_emitter = CreateSphereEmitter(.05)

    EmitterManager:AddEmitter(inst, nil, function()
        --SMOKE
        while smoke_num_particles_to_emit > 1 do
            emit_smoke_fn(effect, sphere_emitter)
            smoke_num_particles_to_emit = smoke_num_particles_to_emit - 1
        end
        smoke_num_particles_to_emit = smoke_num_particles_to_emit + smoke_particles_per_tick
    end)
end

local function master_postinit(inst)
    inst.fx_offset = -125
end

return MakeTorchFire("torchfire_spooky", assets, nil, common_postinit, master_postinit)
