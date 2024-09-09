local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "lunar_goop_cloud_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "lunar_goop_cloud_scaleenvelope_smoke"

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
			{ 0,	IntColour(255, 255, 255, 0) },
			{ .1,	IntColour(255, 255, 255, 6) },
			{ .3,	IntColour(255, 255, 255, 12) },
		}
	)

	local smoke_max_scale = .8
	EnvelopeManager:AddVector2Envelope(
		SCALE_ENVELOPE_NAME_SMOKE,
		{
			{ 0,	{ smoke_max_scale * .6, smoke_max_scale * .6 } },
			{ 1,	{ smoke_max_scale, smoke_max_scale } },
		}
	)

	InitEnvelope = nil
	IntColour = nil
end

--------------------------------------------------------------------------

local SMOKE_MAX_LIFETIME = 1.5

local function emit_smoke_fn(effect, sphere_emitter)
	local vx, vy, vz = .02 * UnitRand(), -.01 + .02 * UnitRand(), .02 * UnitRand()
	local lifetime = SMOKE_MAX_LIFETIME * (.9 + math.random() * .1)
	local px, py, pz = sphere_emitter()

	effect:AddRotatingParticle(
		0,
		lifetime,           -- lifetime
		px, py + 1, pz,     -- position
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

	local smoke_sphere_emitter = CreateSphereEmitter(2.5)

	local tick = GetTick()
	EmitterManager:AddEmitter(inst, nil, function()
		local t = GetTick()
		local dt = math.floor(t - tick)
		tick = t

		local parent = inst.entity:GetParent()
		if not (parent ~= nil and parent.IsCloudEnabled ~= nil and not parent:IsCloudEnabled()) then
			for i = 1, dt do
				emit_smoke_fn(effect, smoke_sphere_emitter)
			end
		end
	end)

	return inst
end

return Prefab("lunar_goop_cloud_fx", fn, assets)
