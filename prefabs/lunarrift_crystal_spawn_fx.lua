local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "lunarrift_crystal_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "lunarrift_crystal_scaleenvelope_smoke"

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
			{ 0.0,	IntColour(255, 255, 255, 50) },
			{ 0.1,	IntColour(255, 255, 255, 70) },
			{ 0.3,	IntColour(255, 255, 255, 100) },
		}
	)

	local smoke_max_scale = .8
	EnvelopeManager:AddVector2Envelope(
		SCALE_ENVELOPE_NAME_SMOKE,
		{
			{ 0,	{ smoke_max_scale * 0.4, smoke_max_scale * 0.4 } },
			{ 1,	{ smoke_max_scale * 0.7, smoke_max_scale * 0.7 } },
		}
	)

	InitEnvelope = nil
	IntColour = nil
end

--------------------------------------------------------------------------

local SMOKE_MAX_LIFETIME = 0.5

local function emit_smoke_fn(effect, smoke_emitter)
	local vx, vy, vz = 0.02 * UnitRand(), -0.01 - 0.02 * UnitRand(), 0.02 * UnitRand()
	local lifetime = SMOKE_MAX_LIFETIME * (0.9 + 0.1 * math.random())
	local px, pz = smoke_emitter()
    local py = 1.0

	effect:AddRotatingParticle(
		0,
		lifetime,               -- lifetime
		px, py, pz,             -- position
		vx, vy, vz,             -- velocity
		360 * math.random(),    -- angle
		UnitRand()              -- angle velocity
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

	-- SMOKE
	effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
	effect:SetMaxNumParticles(0, 50)
	effect:SetRotationStatus(0, true)
	effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
	effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
	effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
	effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
	effect:SetSortOrder(0, 3)
	effect:SetSortOffset(0, 0)
	effect:SetRadius(0, 3) --only needed on a single emitter
	effect:SetDragCoefficient(0, .1)

	-----------------------------------------------------

	local smoke_emitter = CreateCircleEmitter(1.0)

	local previous_tick = GetTick()
	EmitterManager:AddEmitter(inst, nil, function()
		local t = GetTick()
		local dt = math.floor(t - previous_tick)
		previous_tick = t

		local parent = inst.entity:GetParent()
		if not (parent and parent.IsCloudEnabled and not parent:IsCloudEnabled()) then
			for i = 1, dt do
				emit_smoke_fn(effect, smoke_emitter)
			end
		end
	end)

    inst:DoTaskInTime(0.5, inst.Remove)

	return inst
end

return Prefab("lunarrift_crystal_spawn_fx", fn, assets)
