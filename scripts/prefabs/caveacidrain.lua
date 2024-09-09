local TEXTURE = "fx/rain.tex"

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "acidraincolourenvelope"
local SCALE_ENVELOPE_NAME = "acidrainscaleenvelope"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}

local prefabs =
{
    "acidraindrop",
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0, IntColour(102, 102, 0, 200) },
            { 1, IntColour(102, 102, 0, 200) },
        }
    )

    local max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { .5, max_scale } },
            { 1, { .5, max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local MAX_LIFETIME = 1
local MIN_LIFETIME = 1

--------------------------------------------------------------------------

local function GetPooledFx(prefab, pool)
	local fx = table.remove(pool.ents)
	if fx ~= nil then
		fx:ReturnToScene()
		fx:RestartFx()
	else
		fx = SpawnPrefab(prefab)
		fx.pool = pool
	end
	return fx
end

local function ClearPoolEnts(ents)
	for i = 1, #ents do
		ents[i]:Remove()
		ents[i] = nil
	end
end

local function SpawnRaindropAtXZ(inst, x, z, fastforward)
	local raindrop = GetPooledFx("acidraindrop", inst.acidraindrop_pool)
	raindrop.Transform:SetPosition(x, 0, z)
	if fastforward ~= nil then
		raindrop.AnimState:FastForward(fastforward)
	end
end

local function OnRemoveEntity(inst)
	ClearPoolEnts(inst.acidraindrop_pool.ents)
	inst.acidraindrop_pool.valid = false
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()

    if InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)
    effect:SetRenderResources(0, TEXTURE, SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetMaxNumParticles(0, 4800)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    effect:SetSortOrder(0, 3)
    effect:SetDragCoefficient(0, .2)
    effect:EnableDepthTest(0, true)

    -----------------------------------------------------

	inst.acidraindrop_pool = { valid = true, ents = {} }

    local rng = math.random
    local tick_time = TheSim:GetTickTime()

    local desired_particles_per_second = 0--1000
    local desired_splashes_per_second = 0--100

    inst.particles_per_tick = desired_particles_per_second * tick_time
    inst.splashes_per_tick = desired_splashes_per_second * tick_time

    inst.num_particles_to_emit = inst.particles_per_tick
    inst.num_splashes_to_emit = 0

    local bx, by, bz = 0, 20, 0
    local emitter_shape = CreateBoxEmitter(bx, by, bz, bx + 20, by, bz + 20)

    local angle = 0
    local dx = math.cos(angle * DEGREES)
    effect:SetAcceleration(0, dx, -9.80, 1 )

    local map = TheWorld.Map

	local function emit_fn(x, z, left_sx, right_sx, bottom_sy)
        local vy = -1 + UnitRand() * -2
        local vz = 0
        local vx = dx
        local lifetime = MIN_LIFETIME + (MAX_LIFETIME - MIN_LIFETIME) * UnitRand()
        local px, py, pz = emitter_shape()
		local px1 = x + px
		local pz1 = z + pz

		if not IsUnderRainDomeAtXZ(px1, pz1) and map:CanPointHaveAcidRain(px1, 0, pz1) then
			if bottom_sy ~= nil then
				local psx, psy = TheSim:GetScreenPos(px1, 0, pz1)
				if psy < bottom_sy and psx > left_sx and psx < right_sx then
					return --skip
				end
			end
			effect:AddRotatingParticle(
				0,                  -- the only emitter
				lifetime,           -- lifetime
				px, py, pz,         -- position
				vx, vy, vz,         -- velocity
				angle, 0            -- angle, angular_velocity
			)
		end
    end

    local acidraindrop_offset = CreateDiscEmitter(20)

	local last_domes = nil
	local last_domes_ticks = 0

    local function updateFunc(fastforward)
		local x, y, z = inst.Transform:GetWorldPosition()

		if inst.num_particles_to_emit > 0 then
			local left_sx, right_sx, bottom_sy
			local under_domes = GetRainDomesAtXZ(x, z)
			if #under_domes > 0 then
				left_sx, bottom_sy = TheSim:GetScreenPos(x, 0, z)
				left_sx, right_sx = math.huge, -math.huge
				local right_vec = TheCamera:GetRightVec()
				for i, v in ipairs(under_domes) do
					local r = 16--v.components.raindome.radius
					local rvx = right_vec.x * r
					local rvz = right_vec.z * r
					local x1, y1, z1 = v.Transform:GetWorldPosition()
					local x2 = TheSim:GetScreenPos(x1 + rvx, 0, z1 + rvz)
					right_sx = math.max(right_sx, x2)
					x2 = TheSim:GetScreenPos(x1 - rvx, 0, z1 - rvz)
					left_sx = math.min(left_sx, x2)
				end
			end

			while inst.num_particles_to_emit > 0 do
				emit_fn(x, z, left_sx, right_sx, bottom_sy)
				inst.num_particles_to_emit = inst.num_particles_to_emit - 1
			end
		end

        while inst.num_splashes_to_emit > 0 do
            local dx, dz = acidraindrop_offset()

			local x1 = x + dx
			local z1 = z + dz
			local domes = GetRainDomesAtXZ(x1, z1)
			if #domes > 0 then
				last_domes = domes
				last_domes_ticks = 30
			elseif map:IsPassableAtPoint(x1, 0, z1) and map:CanPointHaveAcidRain(x1, 0, z1) then
                SpawnRaindropAtXZ(inst, x1, z1, fastforward)
			end

			--Extra raindrop for domes
			if last_domes ~= nil then
				for i = #last_domes, 1, -1 do
					local dome = last_domes[i]
					local r = dome.components.raindome ~= nil and dome.components.raindome.radius or 0
					if r > 0 and dome:IsValid() then
						local theta = math.random() * PI2
						for i = 1, 2 do
							if i > 1 then
								theta = theta + PI * (.5 + math.random())
							end
							local x2, y2, z2 = dome.Transform:GetWorldPosition()
							x1 = x2 + math.cos(theta) * r
							z1 = z2 - math.sin(theta) * r
							if map:IsPassableAtPoint(x1, 0, z1) and not IsUnderRainDomeAtXZ(x1, z1) and map:CanPointHaveAcidRain(x1, 0, z1) then
                                SpawnRaindropAtXZ(inst, x1, z1, fastforward)
							end
						end
					elseif #last_domes > 1 then
						table.remove(last_domes, i)
					else
						last_domes = nil
						last_domes_ticks = 0
					end
				end
				if last_domes_ticks > 1 then
					last_domes_ticks = last_domes_ticks - 1
				else
					last_domes = nil
					last_domes_ticks = 0
				end
			end

            inst.num_splashes_to_emit = inst.num_splashes_to_emit - 1
        end

        inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick

		if inst.splashes_per_tick > 0 then
			inst.num_splashes_to_emit = inst.num_splashes_to_emit + inst.splashes_per_tick
		else
			ClearPoolEnts(inst.acidraindrop_pool.ents)
		end
    end

    EmitterManager:AddEmitter(inst, nil, updateFunc)

    function inst:PostInit()
        local dt = 1 / 30
        local t = MAX_LIFETIME
        while t > 0 do
            t = t - dt
            updateFunc(t)
            effect:FastForward(0, dt)
        end
    end

	inst.OnRemoveEntity = OnRemoveEntity

    return inst
end

return Prefab("caveacidrain", fn, assets, prefabs)
