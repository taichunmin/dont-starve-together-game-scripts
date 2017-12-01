local TEXTURE = "levels/textures/ds_fog1.tex"

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "mistcolourenvelope"
local SCALE_ENVELOPE_NAME = "mistscaleenvelope"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}

local function InitEnvelopes()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    { 1, 1, 1, 0 } },
            { .1,  { 1, 1, 1, .12 } },
            { .75, { 1, 1, 1, .12 } },
            { 1,    { 1, 1, 1, 0 } },
        }
    )

    local max_scale = 10
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { 6, 6 } },
            { 1,    { max_scale, max_scale } },
        }
    )

    InitEnvelopes = nil
end

local MAX_LIFETIME = 31
local GROUND_HEIGHT = .4
local EMITTER_RADIUS = 25

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    if TheNet:GetIsClient() then
        inst.entity:AddClientSleepable()
    end
    inst.persists = false

    inst.entity:AddTransform()

    -----------------------------------------------------

    if InitEnvelopes ~= nil then
        InitEnvelopes()
    end

    local config =
    {
        texture = TEXTURE,
        shader = SHADER,
        max_num_particles = MAX_LIFETIME + 1,
        max_lifetime = MAX_LIFETIME,
        SV =
        {
            { x = -1, y = 0, z = 1 },
            { x = 1, y = 0, z = 1 },
        },
        sort_order = 3,
        colour_envelope_name = COLOUR_ENVELOPE_NAME,
        scale_envelope_name = SCALE_ENVELOPE_NAME
    }

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)
    effect:SetRenderResources(0, config.texture, config.shader)
    effect:SetMaxNumParticles(0, config.max_num_particles)
    effect:SetMaxLifetime(0, config.max_lifetime)
    effect:SetSpawnVectors(0,
        config.SV[1].x, config.SV[1].y, config.SV[1].z,
        config.SV[2].x, config.SV[2].y, config.SV[2].z
    )
    effect:SetSortOrder(0, config.sort_order)
    effect:SetColourEnvelope(0, config.colour_envelope_name)
    effect:SetScaleEnvelope(0, config.scale_envelope_name)
    effect:SetRadius(0, EMITTER_RADIUS)

    -----------------------------------------------------

    inst:AddComponent("emitter")
    inst.components.emitter.config = config
    inst.components.emitter.max_lifetime = MAX_LIFETIME
    inst.components.emitter.ground_height = GROUND_HEIGHT
    inst.components.emitter.particles_per_tick = 1

    return inst
end

return Prefab("mist", fn, assets)
