

--local SPARKLE_TEXTURE = "fx/sparkle.tex"
--local SPARKLE_TEXTURE = "fx/animsmoke.tex"
local SPARKLE_TEXTURE = "fx/pocketwatch.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "cane_victorian_colourenvelope"
local SCALE_ENVELOPE_NAME = "cane_victorian_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()

	EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(10, 10, 10, 100) },
            { .1,   IntColour(10, 10, 10, 200) },
            { .4,   IntColour(10, 10, 10, 180) },
            { .5,   IntColour(10, 10, 10, 200) },
            { .9,   IntColour(10, 10, 10, 100) },
            { 1,    IntColour(10, 10, 10, 0) },
        }
    )


    local sparkle_max_scale = .5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
            { .25,   { sparkle_max_scale, sparkle_max_scale } },
            { .6,   { sparkle_max_scale, sparkle_max_scale } },
            { 1,    { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.75

local function emit_sparkle_fn(effect, sphere_emitter)
    local vx, vy, vz = .005 * UnitRand(), 0.05 + .004 * UnitRand(), .005 * UnitRand()
    local lifetime = MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()

	local image_index = math.random(0, 4)
	local is_gear = image_index == 4
    local u_offset =  image_index * 1/5
    local ang_vel = is_gear and ((math.random() < 0.5 and 11 or -11) + UnitRand() * 2) or (UnitRand() * 5)
    local angle = math.random() < 0.5 and 180 or 0
    local v_offset = 0

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        u_offset, v_offset        -- uv offset
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

    --SPARKLE
    effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, 1/5, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetSortOffset(0, 1)
	effect:SetDragCoefficient(0, .03)
    --effect:SetSortOffset(0, 2)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local sparkle_desired_pps_low = 2
    local sparkle_desired_pps_high = 6
    local low_per_tick = sparkle_desired_pps_low * tick_time
    local high_per_tick = sparkle_desired_pps_high * tick_time
    local num_to_emit = 0

    local sphere_emitter = CreateSphereEmitter(.15)
    inst.last_pos = inst:GetPosition()

    EmitterManager:AddEmitter(inst, nil, function()
		local owner = inst.entity:GetParent()
		if owner == nil or not (owner:HasTag("attack") or owner.AnimState:IsCurrentAnimation("pocketwatch_atk_pre") or owner.AnimState:IsCurrentAnimation("pocketwatch_atk_pre_2") or owner.AnimState:IsCurrentAnimation("pocketwatch_atk")) then
			local dist_moved = inst:GetPosition() - inst.last_pos
			local move = dist_moved:Length()
			move = math.clamp(move*6, 0, 1)

			local low_pps = owner.age_state == "old" and 3
							or owner.age_state == "normal" and 2
							or 1

			local high_pps = owner.age_state == "old" and 6
							or owner.age_state == "normal" and 3
							or 1

			local per_tick = Lerp(low_pps * tick_time, high_pps * tick_time, move)

			inst.last_pos = inst:GetPosition()

			num_to_emit = num_to_emit + per_tick * math.random() * 2
			while num_to_emit > 1 do
				emit_sparkle_fn(effect, sphere_emitter)
				num_to_emit = num_to_emit - 1
			end
		end
    end)

    return inst
end

return Prefab("pocketwatch_weapon_fx", fn, assets)
