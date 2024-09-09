--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local TEXTURE = "fx/petal.tex"
local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "cane_rose_colourenvelope"
local SCALE_ENVELOPE_NAME = "cane_rose_scaleenvelope"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}

--------------------------------------------------------------------------
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
            { 0, IntColour(255, 255, 255, 255) },
            { 0.5, IntColour(255, 255, 255, 255) },
            { 1, IntColour(255, 255, 255, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME..2,
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



    InitEnvelope = nil
    IntColour = nil
end
--------------------------------------------------------------------------
local MAX_LIFETIME = 2.0

local function emit_rose_fn(effect, i, spark_sphere_emitter)
    local lifetime = MAX_LIFETIME * (.5 + UnitRand() * .5)
    local px, py, pz = spark_sphere_emitter()
    local vx, vy, vz = px * 0.3, -0.1 + py * 0.25, pz * 0.3

    local angle = math.random() * 360
    local uv_offset = math.random(0, 7) / 8
    local ang_vel = (UnitRand() - 1) * 5

    effect:AddRotatingParticleUV(
        i,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
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
    effect:InitEmitters(6)

    local num_emitters = 2
    for i=0,num_emitters do
        effect:SetRenderResources(i, TEXTURE, SHADER)
        effect:SetRotationStatus(i, true)
        effect:SetUVFrameSize(i, 1/8, 1)
        effect:SetMaxNumParticles(i, 200)
        effect:SetMaxLifetime(i, MAX_LIFETIME)
        effect:SetColourEnvelope(i, COLOUR_ENVELOPE_NAME..i)
        effect:SetScaleEnvelope(i, SCALE_ENVELOPE_NAME)
        effect:SetBlendMode(i, BLENDMODE.Premultiplied)
        effect:EnableBloomPass(i, true)
        effect:SetSortOrder(i, 0)
        effect:SetSortOffset(i, 0)
        effect:SetGroundPhysics(i, true)

        effect:SetAcceleration(i, 0, -0.2, 0)
        effect:SetDragCoefficient(i, .1)
    end





    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local sparkle_desired_pps_low = 0
    local sparkle_desired_pps_high = 15
    local low_per_tick = sparkle_desired_pps_low * tick_time
    local high_per_tick = sparkle_desired_pps_high * tick_time
    local num_to_emit = 0

    local sphere_emitter = CreateSphereEmitter(.25)
    inst.last_pos = inst:GetPosition()

    EmitterManager:AddEmitter(inst, nil, function()
        local dist_moved = inst:GetPosition() - inst.last_pos
        local move = dist_moved:Length()
        move = math.clamp((move - 0.2) * 10, 0, 1)

        local per_tick = Lerp(low_per_tick, high_per_tick, move)

        inst.last_pos = inst:GetPosition()

        for i = 0, num_emitters do
            local num_to_emit = per_tick
            while num_to_emit > 0 do
                emit_rose_fn(effect, i, sphere_emitter)
                num_to_emit = num_to_emit - 1
            end
        end
    end)

    return inst
end

return Prefab("cane_rose_fx", fn, assets)
