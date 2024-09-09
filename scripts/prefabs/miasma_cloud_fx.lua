local ANIM_SMOKE_TEXTURE = "fx/miasma.tex"
local SMOKE_SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "miasma_cloud_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "miasma_cloud_scaleenvelope_smoke"


local EMBER_TEXTURE = "fx/snow.tex"
local EMBER_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_EMBER = "miasma_cloud_colourenvelope_ember"
local SCALE_ENVELOPE_NAME_EMBER = "miasma_cloud_scaleenvelope_ember"

local prefabs =
{
    "miasmadebuff",
    "miasma_cloud_fx",
}

local assets_fx =
{
	Asset("IMAGE", ANIM_SMOKE_TEXTURE),
	Asset("IMAGE", EMBER_TEXTURE),
	Asset("SHADER", SMOKE_SHADER),
	Asset("SHADER", EMBER_SHADER),
}


local SMOKE_SIZE = 0.8
local SMOKE_MAX_LIFETIME = 5.0
local FIRE_DECAY_MULTIPLIER = 0.25 -- If a fire is nearby this is how much is multiplied for lifetimes.
local EMBER_MAX_LIFETIME = 1.5 -- Max smoke lifetime when on fire.


--No physics padding for miasma cloud to take effect
local MIASMA_SPACING_RADIUS = SQRT2 * TUNING.MIASMA_SPACING * TILE_SCALE / 2
local MIASMA_PARTICLE_RADIUS = MIASMA_SPACING_RADIUS / 2
-- Small overlap is good to make sure players are always in a fog when all squares are in one.
local MIASMA_RADIUS = math.ceil(MIASMA_SPACING_RADIUS)
local SMOKE_RADIUS = MIASMA_RADIUS - SMOKE_SIZE * 1.3-- 1.3 is scale factor for texture size and is constant to the smoke cloud.


local _MiasmaCloudCount = 0 -- Tracking amount of miasma_cloud entities for miasmawatcher; server side.
local function GetMiasmaCloudCount(world)
    return _MiasmaCloudCount
end

local _MiasmaCloudEntities = nil -- Tracking the entities themselves for TheCamera; client side.
local function OnRemove_Client(inst)
    _MiasmaCloudEntities[inst] = nil
end
local _OldHeading = nil
local _OldHeading_cos = nil
local _OldHeading_sin = nil
local function OnCameraUpdate_Client(dt)
    local heading = TheCamera:GetHeading()
    if heading ~= _OldHeading then
        _OldHeading = heading
        _OldHeading_cos = math.cos(_OldHeading * DEGREES)
        _OldHeading_sin = math.sin(_OldHeading * DEGREES)
        local ox, oz = _OldHeading_cos * MIASMA_PARTICLE_RADIUS, _OldHeading_sin * MIASMA_PARTICLE_RADIUS
        for miasmacloud, _ in pairs(_MiasmaCloudEntities) do
            miasmacloud._front_cloud_fx.Transform:SetPosition(ox, 0, oz)
            miasmacloud._back_cloud_fx.Transform:SetPosition(-ox, 0, -oz)
        end
    end
end
local function OnCameraUpdate_Targeted_Client(miasmacloud)
    local heading = TheCamera:GetHeading()
    if heading ~= _OldHeading then
        _OldHeading = heading
        _OldHeading_cos = math.cos(_OldHeading * DEGREES)
        _OldHeading_sin = math.sin(_OldHeading * DEGREES)
    end
    local ox, oz = _OldHeading_cos * MIASMA_PARTICLE_RADIUS, _OldHeading_sin * MIASMA_PARTICLE_RADIUS
    miasmacloud._front_cloud_fx.Transform:SetPosition(ox, 0, oz)
    miasmacloud._back_cloud_fx.Transform:SetPosition(-ox, 0, -oz)
end

local function IntColour(r, g, b, a)
	return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
	-- SMOKE
	EnvelopeManager:AddColourEnvelope(
		COLOUR_ENVELOPE_NAME_SMOKE,
		{
			{ 0,	IntColour(255, 255, 255, 0) },
			{ .1,	IntColour(255, 255, 255, 255) },
			{ .9,	IntColour(255, 255, 255, 255) },
			{ 1,	IntColour(255, 255, 255, 0) },
		}
	)

    local smoke_max_scale = SMOKE_SIZE
	EnvelopeManager:AddVector2Envelope(
		SCALE_ENVELOPE_NAME_SMOKE,
		{
			{ 0, { smoke_max_scale, smoke_max_scale } },
			{ 1, { smoke_max_scale * 0.8, smoke_max_scale * 0.8 } },
		}
	)

    -- EMBER
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_EMBER,
        {
            { 0,    IntColour(200, 85, 60, 25) },
            { .2,   IntColour(230, 140, 90, 200) },
            { .3,   IntColour(255, 90, 70, 255) },
            { .6,   IntColour(255, 90, 70, 255) },
            { .9,   IntColour(255, 90, 70, 230) },
            { 1,    IntColour(255, 70, 70, 0) },
        }
    )

    local ember_max_scale = 0.7
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_EMBER,
        {
            {   0, { ember_max_scale, ember_max_scale } },
            { 0.5, { ember_max_scale * 0.8, ember_max_scale * 0.8 } },
            {   1, { ember_max_scale * 0.1, ember_max_scale * 0.1 } },
        }
    )

	InitEnvelope = nil
	IntColour = nil
end

--------------------------------------------------------------------------
local RADIUS_SQ_DENY = 4 * 4
local RADIUS_SQ_ALLOW = 40 * 40

local function emit_ember_fn(effect, ember_sphere_emitter, px, py, pz, vx, vy, vz) -- To be called in emit_smoke_fn!
    local ox, oy, oz = ember_sphere_emitter()
    local ovx, ovy, ovz = .06 * UnitRand(), 0.2 + 0.3 * math.random(), .06 * UnitRand()

    effect:AddParticle(
        1,
        EMBER_MAX_LIFETIME * (math.random() * 0.5 + 0.5), -- lifetime
        px + ox, 0 - oy, pz + oz,   -- position
        vx + ovx, vy + ovy, vz + ovz -- velocity
    )
end

local function emit_smoke_fn(effect, smoke_circle_emitter, ember_sphere_emitter, px, pz, ex, ez, isdiminishing, isfront, _world, _sim)
	local ox, oz = smoke_circle_emitter() -- Offset.
    if isfront then -- Flip circle coordinates to make it a semicircle.
        if ox < 0 then
            ox = -ox
        end
        ox = ox - MIASMA_PARTICLE_RADIUS
    else
        if ox > 0 then
            ox = -ox
        end
        ox = ox + MIASMA_PARTICLE_RADIUS
    end
    if _OldHeading then -- Rotate to face heading.
        -- Keep this in one line to reduce local variable requirements where ox and oz rely on the old values to work.
        ox, oz = ox * _OldHeading_cos - oz * _OldHeading_sin, ox * _OldHeading_sin + oz * _OldHeading_cos
    end
    ex, ez = ex + oz, ez + oz -- World position of particle.

    local dx, dz = px - ex, pz - ez -- Delta from player to particle.
    local dsq = dx * dx + dz * dz
    if dsq > RADIUS_SQ_ALLOW then
        -- Hide ones too far from the player.
        return
    end

    if not _world.Map:IsVisualGroundAtPoint(ex, 0, ez) then
        -- Hide ones over void.
        return
    end

	local vx, vy, vz = .01 * UnitRand(), 0.005 * UnitRand(), .01 * UnitRand()
	local lifetime = SMOKE_MAX_LIFETIME -- Do not vary VFX will make it pop on the engine side and we do not want any pops.
    local oy = 0.5 * (1 + math.random())

    if isdiminishing then
        -- Emit ember particles to help show the effect of fire.
        for i = 1, 8 do
            emit_ember_fn(effect, ember_sphere_emitter, ox, oy, oz, vx, vy, vz)
        end

        if math.random() < 0.75 then
            return
        end

        lifetime = lifetime * FIRE_DECAY_MULTIPLIER
        vy = vy + 0.3
    end

    local uv_offset = math.random(0, 1) * 0.5

	effect:AddRotatingParticleUV(
		0,
		lifetime,           -- lifetime
		ox, oy, oz,         -- position
		vx, vy, vz,         -- velocity
		math.random() * 360,-- angle
		UnitRand() * 0.1,     -- angle velocity
        uv_offset, 0        -- UV
	)
end


local function SetupParticles(inst)
	if InitEnvelope ~= nil then
		InitEnvelope()
	end

	local effect = inst.entity:AddVFXEffect()
	effect:InitEmitters(2)

	-- SMOKE
	effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, SMOKE_SHADER)
	effect:SetMaxNumParticles(0, 50)
	effect:SetRotationStatus(0, true)
	effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
	effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
	effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetUVFrameSize(0, 0.5, 1)
	effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
	effect:SetSortOrder(0, 0)
	effect:SetSortOffset(0, 0)
	effect:SetRadius(0, SMOKE_RADIUS) --only needed on a single emitter
	effect:SetDragCoefficient(0, .1)

    -- EMBER
    effect:SetRenderResources(1, EMBER_TEXTURE, EMBER_SHADER)
    effect:SetMaxNumParticles(1, 128)
    effect:SetMaxLifetime(1, EMBER_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_EMBER)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_EMBER)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
	effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetDragCoefficient(1, 0.07)

	-----------------------------------------------------
    -- Local cache for when FX are emitted.
    local _world = TheWorld
    local _sim = TheSim

    local smoke_circle_emitter = CreateCircleEmitter(SMOKE_RADIUS)
    local ember_sphere_emitter = CreateSphereEmitter(SMOKE_SIZE)

    local particles_per_tick = 2 * TheSim:GetTickTime() -- Half intensity with particle placement folding.
    local num_to_emit = 0
    EmitterManager:AddEmitter(inst, nil, function()
        local _player = ThePlayer
        if _player then
            local parent = inst.entity:GetParent()
            if parent and (parent.IsCloudEnabled == nil or parent:IsCloudEnabled()) then
                local px, _, pz = _player.Transform:GetWorldPosition()
                local ex, _, ez = parent.Transform:GetWorldPosition()
                local isdiminishing = parent._diminishing:value()
                local isfront = inst._frontsemicircle

                num_to_emit = num_to_emit + particles_per_tick
                while num_to_emit > 1 do
                    emit_smoke_fn(effect, smoke_circle_emitter, ember_sphere_emitter, px, pz, ex, ez, isdiminishing, isfront, _world, _sim)
                    num_to_emit = num_to_emit - 1
                end
            end
        end
    end)
end

--------------------------------------------------------------------------

--NOTE: twice as long to exit miasma for smooth transition from one cloud to another
local PERIOD = .5

local NO_TAGS = { "playerghost", "ghost", "shadow", "shadowminion", "noauradamage", "FX", "INLIMBO", "notarget", "noattack", "flight", "invisible" }

local function ClearWatcherTable(inst, tbl)
	for k in pairs(tbl) do
		tbl[k] = nil
		if k:IsValid() and k.components.miasmawatcher ~= nil then
			k.components.miasmawatcher:RemoveMiasmaSource(inst)
		end
	end
end

local FIRE_MUST_TAGS = {"fire",}
local FIRE_RADIUS = MIASMA_RADIUS + 1 -- Small fudge factor.
local function OnUpdate(inst)
	local temp = inst.watchers_toremove
	inst.watchers_toremove = inst.watchers_exiting
	inst.watchers_exiting = inst.watchers
	inst.watchers = temp

	local x, y, z = inst.Transform:GetWorldPosition()
	for i, v in ipairs(TheSim:FindEntities(x, y, z, MIASMA_RADIUS, nil, NO_TAGS)) do
		if v.entity:IsVisible() then
			if v.components.miasmawatcher ~= nil then
				inst.watchers[v] = true
				if inst.watchers_toremove[v] then
					inst.watchers_toremove[v] = nil
				elseif inst.watchers_exiting[v] then
					inst.watchers_exiting[v] = nil
				else
					v.components.miasmawatcher:AddMiasmaSource(inst)
				end
			end
		end
	end

    local miasmamanager = TheWorld.components.miasmamanager
    local nearestfire = TheSim:FindEntities(x, y, z, FIRE_RADIUS, FIRE_MUST_TAGS)[1]
    if nearestfire then
        if miasmamanager and miasmamanager:GetMiasmaAtPoint(x, y, z) then
            miasmamanager:SetMiasmaDiminishingAtPoint(x, y, z, true)
        elseif inst._miasma_kill_task == nil then
            -- Fake diminishing an unmanaged miasma cloud.
            inst._miasma_kill_task = inst:DoTaskInTime(TUNING.MIASMA_DIMINISH_INTERVAL_SECONDS * TUNING.MIASMA_MAXSTRENGTH, inst.Remove)
        end
        inst._diminishing:set(true)
    else
        if miasmamanager and miasmamanager:GetMiasmaAtPoint(x, y, z) then
            miasmamanager:SetMiasmaDiminishingAtPoint(x, y, z, false)
        elseif inst._miasma_kill_task ~= nil then
            -- Stop fake diminishing an unmanaged miasma cloud.
            inst._miasma_kill_task:Cancel()
            inst._miasma_kill_task = nil
        end
        inst._diminishing:set(false)
    end

	inst:ClearWatcherTable(inst.watchers_toremove)
end

local function StartAllWatchers(inst)
	if inst.task == nil then
		inst.task = inst:DoPeriodicTask(PERIOD, OnUpdate, math.random() * .5)
	end
end

local function StopAllWatchers(inst)
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil

		inst:ClearWatcherTable(inst.watchers)
		inst:ClearWatcherTable(inst.watchers_exiting)
		inst:ClearWatcherTable(inst.watchers_toremove)
	end
end

local function OnRemoveEntity(inst)
    inst:StopAllWatchers()
    _MiasmaCloudCount = _MiasmaCloudCount - 1
    if _MiasmaCloudCount == 0 then
        TheWorld:PushEvent("miasmacloudexists", false)
    end
end

local function OnEntityWake(inst)
    inst:StartAllWatchers()
end

local function OnEntitySleep(inst)
    inst:StopAllWatchers()
end

local function AttachParticles(inst)
    local front = SpawnPrefab("miasma_cloud_fx")
    front.entity:SetParent(inst.entity)
    front.Transform:SetPosition(MIASMA_PARTICLE_RADIUS, 0, 0)
    front._frontsemicircle = true

    local back = SpawnPrefab("miasma_cloud_fx")
    back.entity:SetParent(inst.entity)
    back.Transform:SetPosition(-MIASMA_PARTICLE_RADIUS, 0, 0)

    inst._front_cloud_fx = front
    inst._back_cloud_fx = back
end

--------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("miasma")

    inst._diminishing = net_bool(inst.GUID, "miasma_cloud._diminishing", "diminishingdirty")

	--Dedicated server does not need to spawn local particle fx
	if not TheNet:IsDedicated() then
		AttachParticles(inst)
        if _MiasmaCloudEntities == nil then
            -- Initialize.
            _MiasmaCloudEntities = {}
            if TheCamera then
                TheCamera:AddListener("MiasmaClouds", OnCameraUpdate_Client)
            end
        end
        if TheCamera then
            OnCameraUpdate_Targeted_Client(inst)
        end
        _MiasmaCloudEntities[inst] = true
        inst:ListenForEvent("onremove", OnRemove_Client)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.watchers = {}
	inst.watchers_exiting = {}
	inst.watchers_toremove = {}

	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep
    inst.OnRemoveEntity = OnRemoveEntity
    inst.ClearWatcherTable = ClearWatcherTable
    inst.StartAllWatchers = StartAllWatchers
    inst.StopAllWatchers = StopAllWatchers

    _MiasmaCloudCount = _MiasmaCloudCount + 1
    if _MiasmaCloudCount == 1 then
        TheWorld:PushEvent("miasmacloudexists", true)
    end
    if TheWorld.GetMiasmaCloudCount == nil then -- Do not overwrite.
        TheWorld.GetMiasmaCloudCount = GetMiasmaCloudCount
    end

	return inst
end

--------------------------------------------------------------------------

local function fn_fx()
	local inst = CreateEntity()

    inst.entity:AddTransform()

	inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    SetupParticles(inst)

    return inst
end

return Prefab("miasma_cloud", fn, nil, prefabs),
    Prefab("miasma_cloud_fx", fn_fx, assets_fx)
