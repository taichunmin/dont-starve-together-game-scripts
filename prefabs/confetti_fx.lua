local BEEFALO_SHAPE_TRIS = {
	{{x=-0.18,y=-0.27},{x=-0.10,y=0.71},{x=0.06,y=-0.20}},
	{{x=-0.18,y=-0.27},{x=-0.43,y=0.65},{x=-0.10,y=0.71}},
	{{x=0.22,y=0.71},{x=-0.10,y=0.71},{x=0.20,y=1.00}},
	{{x=-0.10,y=0.71},{x=0.22,y=0.71},{x=0.06,y=-0.20}},
	{{x=-0.53,y=-0.10},{x=-0.18,y=-0.27},{x=-0.45,y=-0.25}},
	{{x=-0.43,y=0.65},{x=-0.53,y=-0.10},{x=-0.63,y=0.28}},
	{{x=-0.18,y=-0.27},{x=-0.53,y=-0.10},{x=-0.43,y=0.65}},
	{{x=-0.12,y=-0.32},{x=-0.18,y=-0.27},{x=0.06,y=-0.20}},
	{{x=-0.18,y=-0.27},{x=-0.12,y=-0.32},{x=-0.19,y=-0.37}},
	{{x=-0.18,y=-0.27},{x=-0.28,y=-0.33},{x=-0.45,y=-0.25}},
	{{x=-0.28,y=-0.33},{x=-0.18,y=-0.27},{x=-0.19,y=-0.37}},
	{{x=1.00,y=-0.58},{x=0.90,y=-1.00},{x=0.89,y=-1.00}},
	{{x=0.73,y=-0.43},{x=1.00,y=-0.58},{x=0.89,y=-1.00}},
	{{x=-1.00,y=-0.57},{x=-0.66,y=-0.44},{x=-0.86,y=-1.00}},
	{{x=-0.66,y=-0.44},{x=-1.00,y=-0.57},{x=-1.00,y=-0.53}},
	{{x=0.22,y=0.71},{x=0.23,y=-0.26},{x=0.06,y=-0.20}},
	{{x=0.58,y=0.53},{x=0.23,y=-0.26},{x=0.22,y=0.71}},
	{{x=0.67,y=0.31},{x=0.23,y=-0.26},{x=0.58,y=0.53}},
	{{x=-0.67,y=-0.32},{x=-0.70,y=-0.11},{x=-0.53,y=-0.10}},
	{{x=-0.66,y=-0.44},{x=-0.67,y=-0.32},{x=-0.45,y=-0.25}},
	{{x=-0.67,y=-0.32},{x=-0.53,y=-0.10},{x=-0.45,y=-0.25}},
	{{x=-0.67,y=-0.32},{x=-0.66,y=-0.44},{x=-1.00,y=-0.53}},
	{{x=-0.70,y=-0.11},{x=-0.67,y=-0.32},{x=-1.00,y=-0.53}},
	{{x=0.42,y=-0.26},{x=0.56,y=-0.14},{x=0.73,y=-0.43}},
	{{x=0.56,y=-0.14},{x=0.65,y=-0.10},{x=0.73,y=-0.43}},
	{{x=0.56,y=-0.14},{x=0.67,y=0.31},{x=0.69,y=0.08}},
	{{x=0.23,y=-0.26},{x=0.56,y=-0.14},{x=0.42,y=-0.26}},
	{{x=0.67,y=0.31},{x=0.56,y=-0.14},{x=0.23,y=-0.26}},
	{{x=1.00,y=-0.52},{x=1.00,y=-0.58},{x=0.73,y=-0.43}},
	{{x=0.65,y=-0.10},{x=1.00,y=-0.52},{x=0.73,y=-0.43}},
	{{x=0.23,y=-0.26},{x=0.29,y=-0.36},{x=0.06,y=-0.20}}
}

local TEXTURE = "fx/confetti.tex"
local SPARK_TEXTURE = "fx/sparkle.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "confetti_colourenvelope"
local SCALE_ENVELOPE_NAME = "confetti_scaleenvelope"

local COLOUR_ENVELOPE_NAME_SPARK = "confetti_colourenvelope_spark"
local SCALE_ENVELOPE_NAME_SPARK = "confetti_scaleenvelope_spark"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("IMAGE", SPARK_TEXTURE),
    Asset("SHADER", SHADER),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local envs = {}

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME..0,
        {
            { 0, IntColour(255, 0, 0, 255) },
            { 0.5, IntColour(255, 0, 0, 255) },
            { 1, IntColour(255, 0, 0, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME..1,
        {
            { 0, IntColour(0, 200, 0, 255) },
            { 0.5, IntColour(0, 200, 0, 255) },
            { 1, IntColour(0, 200, 0, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME..2,
        {
            { 0, IntColour(21, 85, 203, 255) },
            { 0.5, IntColour(21, 85, 203, 255) },
            { 1, IntColour(21, 85, 203, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME..3,
        {
            { 0, IntColour(255, 255, 255, 255) },
            { 0.5, IntColour(255, 255, 255, 255) },
            { 1, IntColour(255, 255, 255, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME..4,
        {
            { 0, IntColour(233, 224, 44, 255) },
            { 0.5, IntColour(233, 224, 44, 255) },
            { 1, IntColour(233, 224, 44, 0) },
        }
    )


    local envs = {}

    local max_scale = .7
    local end_scale = .4
    local t = 0
    local step = .2
    while t + step < 1 do
        local s = Lerp( max_scale, end_scale, Clamp(2*t - 0.5, 0, 1) )
        table.insert(envs, { t, { s * 0.25, s } })
        t = t + step

        local s = Lerp( max_scale, end_scale, Clamp(2*t - 0.5, 0, 1))
        table.insert(envs, { t, { s, s * 0.2 } })
        t = t + step
    end
    table.insert(envs, { 1, { max_scale, max_scale * 0.6 } })

    EnvelopeManager:AddVector2Envelope( SCALE_ENVELOPE_NAME, envs )


    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SPARK,
        {
            { 0,    IntColour(255, 255, 255, 25) },
            { .05,   IntColour(255, 255, 255, 255) },
            { .8,   IntColour(128, 128, 128, 255) },
            { 1,    IntColour(0, 0, 0, 0) },
        }
    )
    local spark_max_scale = 2.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SPARK,
        {
            { 0,    { spark_max_scale, spark_max_scale } },
            { 1,    { spark_max_scale * 0.4, spark_max_scale * 0.4 } },
        }
    )


    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 2.7

local function emit_confetti_fn(effect, i, ep, camera_right, camera_up)
    local lifetime = MAX_LIFETIME * (.5 + UnitRand() * .5)
    local px, py, pz = ep(camera_right, camera_up)
    local vx, vy, vz = px * 0.75, py * 0.75, pz * 0.75
    vy = vy + 1 --apply upward force to all confetti
    py = py + 1 --confetti spawns at origin + 2

    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = (UnitRand() - 1) * 5

    effect:AddRotatingParticleUV(
        i,
        lifetime,           -- lifetime
        0, 3, 0,         -- position
        vx, vy, vz,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
    )
end

local SPARK_MAX_LIFETIME = .2
local function emit_spark_fn(effect, spark_sphere_emitter)
    local vx, vy, vz = .05 * UnitRand(), .05 * UnitRand(), .05 * UnitRand()
    local lifetime = SPARK_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = spark_sphere_emitter()
    py = py + 3.4

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        5,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        uv_offset, 0        -- uv offset
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

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
    effect:InitEmitters(6)

    local num_emitters = 4
    for i=0,num_emitters do
        effect:SetRenderResources(i, TEXTURE, SHADER)
        effect:SetRotationStatus(i, true)
        effect:SetUVFrameSize(i, .25, 1)
        effect:SetMaxNumParticles(i, 200)
        effect:SetMaxLifetime(i, MAX_LIFETIME)
        effect:SetColourEnvelope(i, COLOUR_ENVELOPE_NAME..i)
        effect:SetScaleEnvelope(i, SCALE_ENVELOPE_NAME)
        effect:SetBlendMode(i, BLENDMODE.Premultiplied)
        effect:EnableBloomPass(i, true)
        effect:SetSortOrder(i, 0)
        effect:SetSortOffset(i, 0)
        effect:SetGroundPhysics(i, true)

        effect:SetAcceleration(i, 0, -0.8, 0)
        effect:SetDragCoefficient(i, .1)
    end

    --Sparkle
    effect:SetRenderResources(5, SPARK_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(5, 20)
    effect:SetMaxLifetime(5, SPARK_MAX_LIFETIME)
    effect:SetColourEnvelope(5, COLOUR_ENVELOPE_NAME_SPARK)
    effect:SetScaleEnvelope(5, SCALE_ENVELOPE_NAME_SPARK)
    effect:SetBlendMode(5, BLENDMODE.Additive)
    effect:EnableBloomPass(5, true)
    effect:SetUVFrameSize(5, 0.25, 1)
    effect:SetSortOrder(5, 0)
    effect:SetSortOffset(5, 1)
    effect:SetDragCoefficient(5, .11)


    local ep = Create2DTriEmitter(BEEFALO_SHAPE_TRIS, 0.5)

    local spark_sphere_emitter = CreateSphereEmitter(.03)

    inst:DoTaskInTime(0, function()
        local c_down = TheCamera:GetPitchDownVec():Normalize()
        local c_right = TheCamera:GetRightVec():Normalize()

        local c_up = c_down:Cross(c_right):Normalize()

        for i = 0,num_emitters do
            local num_to_emit = math.random(150, 200)
            while num_to_emit > 0 do
                emit_confetti_fn(effect, i, ep, c_right, c_up)
                num_to_emit = num_to_emit - 1
            end
        end

        local num_to_emit_spark = 3
        while num_to_emit_spark > 0 do
            emit_spark_fn(effect, spark_sphere_emitter)
            num_to_emit_spark = num_to_emit_spark - 1
        end

        inst:Remove()
    end)

    inst.SoundEmitter:PlaySound("yotb_2021/common/fireworks")

    return inst
end

return Prefab("confetti_fx", fn, assets)

--[[
    c_spawn("confetti_fx")
]]