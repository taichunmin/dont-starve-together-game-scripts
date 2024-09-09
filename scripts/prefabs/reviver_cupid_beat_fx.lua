local GLOW_TEXTURE = "fx/heartglow.tex"

local SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_HEART = "cupid_beat1_colourenvelope"
local SCALE_ENVELOPE_NAME_HEART = "cupid_beat1_scaleenvelope"

local assets =
{
    Asset("IMAGE", GLOW_TEXTURE),
    Asset("SHADER", SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_HEART,
        {
            { 0,    IntColour(255, 0, 0, 0) },
            { .2,   IntColour(255, 0, 0, 30) },
            { .65,  IntColour(255, 0, 0, 7) },
            { 1,    IntColour(255, 0, 0, 0) },
        }
    )

    local heart_max_scale = 3.7
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_HEART,
        {
            { 0,    { heart_max_scale * .2, heart_max_scale * .2 } },
            { .40,  { heart_max_scale * .7, heart_max_scale * .7 } },
            { .60,  { heart_max_scale * .8, heart_max_scale * .8 } },
            { .75,  { heart_max_scale * .9, heart_max_scale * .9 } },
            { 1,    { heart_max_scale, heart_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local HEART_LIFETIME = 1

local function InitParticles(inst)
    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)
    effect:SetRenderResources(0, GLOW_TEXTURE, SHADER)
    effect:SetMaxNumParticles(0, 4)
    effect:SetMaxLifetime(0, HEART_LIFETIME)
    effect:SetRotationStatus(0, true)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_HEART)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_HEART)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 1, 1)
    effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 1)

    EmitterManager:AddEmitter(inst, nil, function()
        --sync the particle bursting to the start of the
        --animation, and then wait until the next start.
        local parent = inst.entity:GetParent()
        if parent == nil or parent.AnimState == nil or parent.AnimState:GetCurrentAnimationTime() >= .1 then
            inst.wait_for_burst = true
        elseif inst.wait_for_burst then
            inst.wait_for_burst = false
            effect:AddRotatingParticle(
                0,
                HEART_LIFETIME, -- lifetime
                0, 0, 0,        -- position
                0, 0, 0,         -- velocity
                UnitRand() * 3, -- angle
                UnitRand() * .5  -- angular_velocity
            )
        end
    end)
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    InitParticles(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

--------------------------------------------------------------------------

local function OnGlowFXReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.prefab == "reviver" then
        parent.highlightchildren = { inst }
    end
end

local function glowfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bloodpump")
    inst.AnimState:SetBuild("bloodpump")
    inst.AnimState:OverrideSymbol("bloodpump01", "bloodpump", "bloodpumpglow")
    inst.AnimState:Hide("Shadow")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(.3)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnGlowFXReplicated

        return inst
    end

    inst.persists = false

    return inst
end

--------------------------------------------------------------------------

return Prefab("reviver_cupid_beat_fx", fn, assets),
    Prefab("reviver_cupid_glow_fx", glowfn)
