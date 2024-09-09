local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ANIM_SPARK_TEXTURE = "fx/animsponge.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SPARK = "nightsword_wizard_colourenvelope_spark"
local SCALE_ENVELOPE_NAME_SPARK = "nightsword_wizard_scaleenvelope_spark"

local COLOUR_ENVELOPE_NAME_SMOKE = "nightsword_wizard_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "nightsword_wizard_scaleenvelope_smoke"


local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", ANIM_SPARK_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    -- SMOKE
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


    -- SPARK
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SPARK,
        {
            { 0.0, IntColour(100, 100, 100,   0) },
            { 0.2, IntColour( 50,  50,  50, 200) },
            { 1.0, IntColour(  0,   0,   0, 100) },
        }
    )
    local spark_max_scale = 0.6
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SPARK,
        {
            { 0.0, { spark_max_scale, spark_max_scale } },
            { 1.0, { spark_max_scale, spark_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local SMOKE_MAX_LIFETIME = 0.75
local SPARK_MAX_LIFETIME = 1.5

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
        math.random() * 360,-- angle
        UnitRand() * 2      -- angle velocity
    )
end

local function emit_spark_fn(effect, sphere_emitter, adjust_vec)
    local vx, vy, vz = .005 * UnitRand(), 0, .005 * UnitRand()
    local lifetime = SPARK_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddRotatingParticle(
        1,
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
    effect:InitEmitters(2)

    -- SMOKE
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(0, 32)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 0)
    effect:SetRadius(0, 3) --only needed on a single emitter
    effect:SetDragCoefficient(0, .1)

    -- SPARK
    effect:SetRenderResources(1, ANIM_SPARK_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(1, 32)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, SPARK_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SPARK)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SPARK)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:SetUVFrameSize(1, 1, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetDragCoefficient(1, 1)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local burst_state = 0

    local smoke_sphere_emitter = CreateSphereEmitter(.2)
    local spark_sphere_emitter = CreateSphereEmitter(.5)

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
                    local num_to_emit_smoke = 5
                    local num_to_emit_spark = 3

                    local adjust_vec = nil
                    if parent.AnimState:GetCurrentFacing() == 1 then
                        --Do custom positioning
                        adjust_vec = TheCamera:GetRightVec() * 0.75 - TheCamera:GetDownVec() * 2.6
                    end

                    while num_to_emit_smoke > 0 do
                        emit_smoke_fn(effect, smoke_sphere_emitter, adjust_vec)
                        num_to_emit_smoke = num_to_emit_smoke - 1
                    end

                    while num_to_emit_spark > 0 do
                        emit_spark_fn(effect, spark_sphere_emitter, adjust_vec)
                        num_to_emit_spark = num_to_emit_spark - 1
                    end
                end
            end
        end
    end)

    return inst
end

return Prefab("nightsword_wizard_fx", fn, assets)
