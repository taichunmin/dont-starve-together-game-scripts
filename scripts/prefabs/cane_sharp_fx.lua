local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME = "cane_sharp_colourenvelope"
local SCALE_ENVELOPE_NAME = "cane_sharp_scaleenvelope"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
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
            { 0,    IntColour(75, 0, 130, 160) },
            { .19,  IntColour(75, 0, 130, 160) },
            { .35,  IntColour(75, 0, 130, 80) },
            { .51,  IntColour(75, 0, 130, 60) },
            { .75,  IntColour(75, 0, 130, 40) },
            { 1,    IntColour(75, 0, 130, 0) },
        }
    )

    local glow_max_scale = .21
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { glow_max_scale * 0.7, glow_max_scale * 0.7 } },
            { .55,  { glow_max_scale * 1.2, glow_max_scale * 1.2 } },
            { 1,    { glow_max_scale * 1.3, glow_max_scale * 1.3 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local GLOW_MAX_LIFETIME = 2.1

local function emit_glow_fn(effect, emitter_fn)
    local vx, vy, vz = .005 * UnitRand(), 0, .005 * UnitRand()
    local lifetime = GLOW_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = emitter_fn()

    effect:AddRotatingParticle(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,-- angle
        UnitRand()          -- angle velocity
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

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, GLOW_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
	effect:SetSortOffset(0, -1)
    effect:SetKillOnEntityDeath(0, true)
    effect:SetFollowEmitter(0, true)

    -----------------------------------------------------


    local tick_time = TheSim:GetTickTime()

    local glow_desired_pps = 3
    local glow_particles_per_tick = glow_desired_pps * tick_time
    local glow_num_particles_to_emit = 0

    local sphere_emitter = CreateSphereEmitter(.05)

    EmitterManager:AddEmitter(inst, nil, function()

        while glow_num_particles_to_emit > 1 do
            emit_glow_fn(effect, sphere_emitter)
            glow_num_particles_to_emit = glow_num_particles_to_emit - 1
        end
        glow_num_particles_to_emit = glow_num_particles_to_emit + glow_particles_per_tick * math.random() * 3

    end)

    return inst
end

return Prefab("cane_sharp_fx", fn, assets)
