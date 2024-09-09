local TEXTURE = "fx/frostbreath.tex"

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "breathcolourenvelope"
local SCALE_ENVELOPE_NAME = "breathscaleenvelope"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelopes()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {   { 0,    IntColour( 255, 255, 255, 0 ) },
            { .10,  IntColour( 255, 255, 255, 128 ) },
            { .3,   IntColour( 255, 255, 255, 64 ) },
            { 1,    IntColour( 255, 255, 255, 0 ) },
        }
    )

    local min_scale = .4
    local max_scale = 3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { min_scale, min_scale } },
            { 1,    { max_scale, max_scale } },
        }
    )

    InitEnvelopes = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local MAX_LIFETIME = 2.5

local function Emit(inst)
    local vx, vy, vz = 0, .005, 0
    local lifetime = MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = inst.sphere_emitter()
    local angle = UnitRand() * 360
    local angular_velocity = UnitRand() * 5

    inst.VFXEffect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        angle,              -- rotation
        angular_velocity,   -- angular_velocity :P
        0, 0                -- uv offset
    )
end

local function empty_func()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        inst.Emit = empty_func

        return inst
    elseif InitEnvelopes ~= nil then
        InitEnvelopes()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)
    effect:SetRenderResources(0, TEXTURE, SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    effect:SetUVFrameSize(0, 1, 1)

    inst.sphere_emitter = CreateSphereEmitter(.05)
    inst.Emit = Emit

    EmitterManager:AddEmitter(inst, nil, empty_func)

    return inst
end

return Prefab("frostbreath", fn, assets)
