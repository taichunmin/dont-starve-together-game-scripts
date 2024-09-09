local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "nightsword_cotl_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "nightsword_cotl_scaleenvelope_smoke"

local COLOUR_ENVELOPE_NAME_EMBER = "nightsword_cotl_colourenvelope_ember"
local SCALE_ENVELOPE_NAME_EMBER = "nightsword_cotl_scaleenvelope_ember"


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
    -- SMOKE
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE,
        {
            { 0,    IntColour(10, 10, 10, 0) },
            { .1,   IntColour(10, 10, 10, 175) },
            { .52,  IntColour(10, 10, 10, 90) },
            { 1,    IntColour(10, 10, 10, 0) },
        }
    )
    local smoke_max_scale = 0.15
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,    { smoke_max_scale, smoke_max_scale } },
            { 1,    { smoke_max_scale * .5, smoke_max_scale * .5 } },
        }
    )

    -- EMBER
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_EMBER,
        {
            { 0,    IntColour(10, 10, 10, 0) },
            { .1,   IntColour(10, 10, 10, 175) },
            { .52,  IntColour(10, 10, 10, 90) },
            { 1,    IntColour(10, 10, 10, 0) },
        }
    )
    local ember_max_scale = 0.3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_EMBER,
        {
            { 0,    { ember_max_scale, ember_max_scale } },
            { 1,    { ember_max_scale * .5, ember_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local SMOKE_MAX_LIFETIME = 0.8
local SMOKE_FOV = 70.0 -- Half angle.

local function emit_smoke_fn(effect, px, py, pz, angle, percent)
    local lifetime = SMOKE_MAX_LIFETIME * (.8 + math.random() * .2) - 0.2 * percent
    local dx = -math.cos(angle)
    local dz = -math.sin(angle)
    px = px + dx * percent
    pz = pz + dz * percent
    local vx = dx * 0.2 * (percent * 0.5 + 0.5)
    local vz = dz * 0.2 * (percent * 0.5 + 0.5)

    effect:AddRotatingParticle(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, 0, vz,          -- velocity
        math.random() * 360,-- angle
        0                   -- angle velocity
    )
end

--------------------------------------------------------------------------

local EMBER_MAX_LIFETIME = 0.6

local function emit_ember_fn(effect, px, py, pz, angle, percent)
    local lifetime = EMBER_MAX_LIFETIME * (.7 + math.random() * .3)
    px = px + 0.2 * UnitRand()
    py = py + 0.2 * UnitRand()
    pz = pz + 0.2 * UnitRand()

    effect:AddRotatingParticle(
        1,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        0, 0, 0,            -- velocity
        math.random() * 360,-- angle
        UnitRand()          -- angle velocity
    )
end

--------------------------------------------------------------------------

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
    effect:SetMaxNumParticles(0, 45)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 0)
    effect:SetRadius(0, 3) --only needed on a single emitter
    effect:SetDragCoefficient(0, .1)

    -- EMBER
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(1, 5)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, EMBER_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_EMBER)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_EMBER)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetDragCoefficient(1, .1)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local burst_state = 0

    local sphere_emitter = CreateSphereEmitter(.2)

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if parent ~= nil then
            local mount = parent.components.rider ~= nil and parent.components.rider:GetMount() or nil
            if mount == nil then
                local attack_playing = parent.AnimState:IsCurrentAnimation("atk")
                local anim_time = parent.AnimState:GetCurrentAnimationTime()

                if attack_playing then
                    if anim_time > .13 and burst_state == 0 then
                        burst_state = 1
                    end
                else
                    burst_state = 0 --wait for atk anim
                end

                if burst_state == 1 then
                    burst_state = 2 --wait for new atk
                    local num_to_emit_smoke = 15
                    local num_to_emit_ember = 3

                    local fdir = parent.AnimState:GetCurrentFacing()
                    
                    local adjust_vec = nil
                    local smoke_angle = nil
                    if fdir == 0 then
                        smoke_angle = 270
                    elseif fdir == 1 then
                        smoke_angle = 0
                        adjust_vec = TheCamera:GetRightVec() * 0.75 - TheCamera:GetDownVec() * 2.9
                    elseif fdir == 2 then
                        smoke_angle = 90
                    elseif fdir == 3 then
                        smoke_angle = 180
                        adjust_vec = TheCamera:GetDownVec() * 0.75
                    end

                    if smoke_angle ~= nil then
                        local px, py, pz = sphere_emitter()
                        if adjust_vec ~= nil then
                            px = px + adjust_vec.x
                            py = py + adjust_vec.y
                            pz = pz + adjust_vec.z
                        end
                        py = py + 0.4
                        local total_smoke = num_to_emit_smoke
                        smoke_angle = smoke_angle + TheCamera:GetHeadingTarget()
                        while num_to_emit_smoke > 0 do
                            local percent = num_to_emit_smoke / total_smoke
                            local particle_angle = (smoke_angle + (2 * percent - 1) * SMOKE_FOV) * DEGREES
                            emit_smoke_fn(effect, px, py, pz, particle_angle, percent)
                            num_to_emit_smoke = num_to_emit_smoke - 1
                        end
                        while num_to_emit_ember > 0 do
                            emit_ember_fn(effect, px, py, pz)
                            num_to_emit_ember = num_to_emit_ember - 1
                        end
                    else
                        print("Error: Unexpected facing angle for nightsword_cotl_fx.", fdir)
                    end
                end
            end
        end
    end)

    return inst
end

return Prefab("nightsword_cotl_fx", fn, assets)
