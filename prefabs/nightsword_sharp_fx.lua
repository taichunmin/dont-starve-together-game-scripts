local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local EMBER_TEXTURE = "fx/snow.tex"
local SPARK_TEXTURE = "fx/sparkle.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "nightsword_sharp_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "nightsword_sharp_scaleenvelope_smoke"
local COLOUR_ENVELOPE_NAME_EMBER = "nightsword_sharp_colourenvelope_ember"
local SCALE_ENVELOPE_NAME_EMBER = "nightsword_sharp_scaleenvelope_ember"
local COLOUR_ENVELOPE_NAME_SPARK = "nightsword_sharp_colourenvelope_spark"
local SCALE_ENVELOPE_NAME_SPARK = "nightsword_sharp_scaleenvelope_spark"


local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),
    Asset("IMAGE", SPARK_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE,
        {
            { 0,    IntColour(10, 10, 10, 0) },
            { .3,   IntColour(10, 10, 10, 175) },
            { .52,  IntColour(10, 10, 10, 90) },
            { 1,    IntColour(10, 10, 10, 0) },
        }
    )

    local smoke_max_scale = 0.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,    { smoke_max_scale * .5, smoke_max_scale * .5 } },
            { 1,    { smoke_max_scale, smoke_max_scale } },
        }
    )


    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SPARK,
        {
            { 0,    IntColour(255, 255, 255, 25) },
            { .1,   IntColour(255, 255, 255, 255) },
            { .6,   IntColour(128, 128, 128, 255) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local spark_max_scale = .55
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SPARK,
        {
            { 0,    { spark_max_scale, spark_max_scale } },
            { 1,    { spark_max_scale * 0.2, spark_max_scale * 0.2 } },
        }
    )



    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_EMBER,
        {
            { 0,    IntColour(255, 255, 255, 25) },
            { .2,   IntColour(255, 255, 255, 255) },
            { .6,   IntColour(128, 128, 128, 255) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )

    local ember_max_scale = .55
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_EMBER,
        {
            { 0,    { ember_max_scale, ember_max_scale } },
            { 1,    { ember_max_scale * 0.2, ember_max_scale * 0.2 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local SMOKE_MAX_LIFETIME = 1.1
local SPARK_MAX_LIFETIME = .3
local EMBER_MAX_LIFETIME = .6

local function emit_smoke_fn(effect, sphere_emitter, adjust_vec)
    local vx, vy, vz = .12 * UnitRand(), -.015 + .02 * UnitRand(), .12 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = sphere_emitter()
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddRotatingParticle(
        0,
        lifetime,           -- lifetime
        px, py + .5, pz,    -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 2      -- angle velocity
    )
end

local function emit_spark_fn(effect, sphere_emitter, adjust_vec)
    local vx, vy, vz = .05 * UnitRand(), .05 * UnitRand(), .05 * UnitRand()
    local lifetime = SPARK_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        1,
        lifetime,           -- lifetime
        px, py + .4, pz,    -- position
        vx, vy, vz,         -- velocity
        uv_offset, 0        -- uv offset
    )
end

local function emit_ember_fn(effect, sphere_emitter, adjust_vec)
    local vx, vy, vz = .17 * UnitRand(), .17 * UnitRand(), .17 * UnitRand()
    local lifetime = EMBER_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddParticle(
        2,
        lifetime,           -- lifetime
        px, py + .4, pz,    -- position
        vx, vy, vz         -- velocity
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
    effect:InitEmitters(3)

    --SMOKE
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 32)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    --effect:EnableBloomPass(0, true)
    --effect:SetUVFrameSize(0, .25, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 0)
    effect:SetRadius(0, 3) --only needed on a single emitter
    effect:SetDragCoefficient(0, .1)

    --Sparkle
    effect:SetRenderResources(1, SPARK_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 64)
    effect:SetMaxLifetime(1, SPARK_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SPARK)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SPARK)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetDragCoefficient(1, .11)

    --EMBER
    effect:SetRenderResources(2, EMBER_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(2, 128)
    effect:SetMaxLifetime(2, EMBER_MAX_LIFETIME)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_EMBER)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_EMBER)
    effect:SetBlendMode(2, BLENDMODE.Additive)
    effect:EnableBloomPass(2, true)
    effect:SetSortOrder(2, 0)
    effect:SetSortOffset(2, 0)
    effect:SetDragCoefficient(2, .11)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local burst_state = 0

    local smoke_sphere_emitter = CreateSphereEmitter(.3)
    local spark_sphere_emitter = CreateSphereEmitter(.03)
    local ember_sphere_emitter = CreateSphereEmitter(.1)

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if parent ~= nil then
            local mount = parent.components.rider ~= nil and parent.components.rider:GetMount() or nil
            if mount == nil then
                local attack_playing = parent.AnimState:IsCurrentAnimation("atk")
                local anim_time = parent.AnimState:GetCurrentAnimationTime()

                if attack_playing then
                    if anim_time > 0.13 and burst_state == 0 then
                        burst_state = 1 --do burst
                    end
                else
                    burst_state = 0 --wait for atk anim
                end

                if burst_state == 1 then
                    burst_state = 2 --wait for new atk
                    local num_to_emit_smoke = 10
                    local num_to_emit_spark = 20
                    local num_to_emit_ember = 60

                    local adjust_vec = nil
                    if parent.AnimState:GetCurrentFacing() == 1 then
                        --Do custom positioning
                        adjust_vec = TheCamera:GetRightVec() * 0.75 - TheCamera:GetDownVec() * 2.6
                    end

                    while num_to_emit_smoke > 1 do
                        emit_smoke_fn(effect, smoke_sphere_emitter, adjust_vec)
                        num_to_emit_smoke = num_to_emit_smoke - 1
                    end

                    while num_to_emit_spark > 1 do
                        emit_spark_fn(effect, spark_sphere_emitter, adjust_vec)
                        num_to_emit_spark = num_to_emit_spark - 1
                    end

                    while num_to_emit_ember > 1 do
                        emit_ember_fn(effect, ember_sphere_emitter, adjust_vec)
                        num_to_emit_ember = num_to_emit_ember - 1
                    end
                end
            end
        end
    end)

    return inst
end

return Prefab("nightsword_sharp_fx", fn, assets)
