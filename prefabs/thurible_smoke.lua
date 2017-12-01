local ANIM_HAND_TEXTURE = "fx/animhand.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "thurible_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "thurible_scaleenvelope_smoke"
local COLOUR_ENVELOPE_NAME_HAND = "thurible_colourenvelope_hand"
local SCALE_ENVELOPE_NAME_HAND = "thurible_scaleenvelope_hand"

local assets =
{
    Asset("IMAGE", ANIM_HAND_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function OnEntityWake(inst)
    if not inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/thurible_LP", "loop")
    end
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE,
        {
            { 0,    IntColour(12, 12, 12, 64) },
            { .2,   IntColour(10, 10, 10, 240) },
            { .7,   IntColour(9, 9, 9, 256) },
            { 1,    IntColour(6, 6, 6, 0) },
        }
    )

    local smoke_max_scale = .3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,    { smoke_max_scale * .2, smoke_max_scale * .2 } },
            { .40,  { smoke_max_scale * .7, smoke_max_scale * .7 } },
            { .60,  { smoke_max_scale * .8, smoke_max_scale * .8 } },
            { .75,  { smoke_max_scale * .7, smoke_max_scale * .7 } },
            { 1,    { smoke_max_scale, smoke_max_scale } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_HAND,
        {
            { 0,    IntColour(12, 12, 12, 64) },
            { .2,   IntColour(10, 10, 10, 256) },
            { .75,  IntColour(9, 9, 9, 256) },
            { 1,    IntColour(6, 6, 6, 0) },
        }
    )

    local hand_max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_HAND,
        {
            { 0,    { hand_max_scale * .3, hand_max_scale * .3 } },
            { .2,   { hand_max_scale * .7, hand_max_scale * .7 } },
            { 1,    { hand_max_scale, hand_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local SMOKE_MAX_LIFETIME = 1.1
local HAND_MAX_LIFETIME = 1.7

local function emit_smoke_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), .06 + .02 * UnitRand(), .01 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py + .35, pz,   -- position
        vx, vy, vz,         -- velocity
        math.random() * 360,--* 2 * PI, -- angle
        UnitRand() * 2,     -- angle velocity
        0, 0                -- uv offset
    )
end

local function emit_hand_fn(effect, sphere_emitter)
    local vx, vy, vz = 0, .07 + .01 * UnitRand(), 0
    local px, py, pz = sphere_emitter()
    local uv_offset = math.random(0, 3) * .25

    effect:AddRotatingParticleUV(
        1,
        HAND_MAX_LIFETIME,  -- lifetime
        px, py + .65, pz,   -- position
        vx, vy, vz,         -- velocity
        0,                  --* 2 * PI, -- angle
        UnitRand() * 1,     -- angle velocity
        uv_offset, 0        -- uv offset
    )
end

local function InitParticles(inst)
    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    --SMOKE
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER) --REVEAL_SHADER --particle_add
    effect:SetMaxNumParticles(0, 32)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 1, 1)
    effect:SetSortOrder(0, 0)
    --effect:SetSortOffset(0, 1)

    --HAND
    effect:SetRenderResources(1, ANIM_HAND_TEXTURE, REVEAL_SHADER) --REVEAL_SHADER --particle_add
    effect:SetMaxNumParticles(1, 32)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, HAND_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_HAND)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_HAND)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    effect:SetSortOrder(1, 0)
    --effect:SetSortOffset(1, 1)
    --effect:SetDragCoefficient(1, 50)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local smoke_desired_pps = 10
    local smoke_particles_per_tick = smoke_desired_pps * tick_time
    local smoke_num_particles_to_emit = -5 --start delay

    local hand_desired_pps = .3
    local hand_particles_per_tick = hand_desired_pps * tick_time
    local hand_num_particles_to_emit = -1 ---50 --start delay

    local sphere_emitter = CreateSphereEmitter(.05)

    EmitterManager:AddEmitter(inst, nil, function()
        --SMOKE
        while smoke_num_particles_to_emit > 1 do
            emit_smoke_fn(effect, sphere_emitter)
            smoke_num_particles_to_emit = smoke_num_particles_to_emit - 1
        end
        smoke_num_particles_to_emit = smoke_num_particles_to_emit + smoke_particles_per_tick

        --HAND
        while hand_num_particles_to_emit > 1 do
            emit_hand_fn(effect, sphere_emitter)
            hand_num_particles_to_emit = hand_num_particles_to_emit - 1
        end
        hand_num_particles_to_emit = hand_num_particles_to_emit + hand_particles_per_tick
    end)
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    InitParticles(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep

    return inst
end

return Prefab("thurible_smoke", fn, assets)
