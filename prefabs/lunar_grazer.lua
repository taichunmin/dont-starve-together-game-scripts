local assets =
{
	Asset("ANIM", "anim/lunar_grazer.zip"),
}

local prefabs =
{
	"lunar_goop_cloud_fx",
	"lunar_goop_trail_fx",
	"lunar_grazer_core_fx",
	"lunar_grazer_debris",
}

local brain = require("brains/lunar_grazer_brain")

--------------------------------------------------------------------------

local NUM_TRAIL_VARIATIONS = 7
local TRAIL_POOL = {}
local TRACKED_ENTS = {}

local function RecycleTrail(inst, fx)
	if next(TRACKED_ENTS) ~= nil then
		fx:RemoveFromScene()
		table.insert(TRAIL_POOL, fx)
	else
		fx:Remove()
	end
	if inst.last_trail == fx then
		inst.last_trail = nil
	end
end

local function SpawnTrail(inst, scale, duration, pos)
	local variation = table.remove(inst.trails, math.random(3))
	table.insert(inst.trails, variation)

	local fx
	if #TRAIL_POOL > 0 then
		fx = table.remove(TRAIL_POOL)
		fx:ReturnToScene()
	else
		fx = SpawnPrefab("lunar_goop_trail_fx")
		fx.onfinished = inst._ontrailfinished
	end
	if pos ~= nil then
		fx.Transform:SetPosition(pos.x, 0, pos.z)
	else
		local x, y, z = inst.Transform:GetWorldPosition()
		fx.Transform:SetPosition(x, 0, z)
	end
	fx:SetVariation(variation, scale, duration)

	inst.last_trail = fx
end

local function StartTracking(inst)
	TRACKED_ENTS[inst] = true
end

local function StopTracking(inst)
	TRACKED_ENTS[inst] = nil
	if next(TRACKED_ENTS) == nil then
		for i = 1, #TRAIL_POOL do
			TRAIL_POOL[i]:Remove()
			TRAIL_POOL[i] = nil
		end
	end
end

--------------------------------------------------------------------------

local NUM_DEBRIS = 6

local function HideDebris(inst)
	if inst.debrisshown then
		inst.debrisshown = false
		inst.debrisscattered = false
		for i, v in ipairs(inst.debris) do
			v:RemoveFromScene()
			v.entity:SetParent(inst.entity)
			v.Transform:SetPosition(0, 0, 0)
		end
	end
end

local function ShowDebris(inst)
	if not inst.debrisshown then
		inst.debrisshown = true
		if inst.debris ~= nil then
			for i, v in ipairs(inst.debris) do
				v.entity:SetParent(nil)
				v:ReturnToScene()
			end
		else
			inst.debris = {}
			for i = 1, NUM_DEBRIS do
				table.insert(inst.debris, SpawnPrefab("lunar_grazer_debris"))
			end
		end
	end
end

local function ScatterDebris(inst)
	if not inst.debrisscattered and inst.debrisshown then
		inst.debrisscattered = true
		local x, y, z = inst.Transform:GetWorldPosition()
		local theta0 = math.random() * TWOPI
		local delta = TWOPI / #inst.debris
		for i, v in ipairs(inst.debris) do
			local r = 1 + math.random() * 2
			local theta = theta0 + (i + math.random() * 0.5) * delta
			v.Physics:Stop()
			v.Physics:Teleport(x + math.cos(theta) * r, 0, z - math.sin(theta) * r)
		end
	end
end

local function TossDebris(inst)
	if inst.debrisshown then
		inst.debrisscattered = true
		local x, y, z = inst.Transform:GetWorldPosition()
		local theta0 = math.random() * TWOPI
		local delta = TWOPI / #inst.debris
		local radius = 1
		for i, v in ipairs(inst.debris) do
			local theta = theta0 + (i + math.random() * 0.5) * delta
			local cos_theta = math.cos(theta)
			local sin_theta = math.sin(theta)
			local speed = 2 + math.random() * 2
			v.Physics:Teleport(x + cos_theta * radius, 1, z - sin_theta * radius)
			v.Physics:SetVel(speed * cos_theta, 2 + math.random() * 2, -speed * sin_theta)
			v.AnimState:PlayAnimation("rock_float_0"..tostring(v.variation))
		end
	end
end

local function DropDebris(inst)
	if inst.debrisshown then
		inst.debrisscattered = true
		local x, y, z = inst.Transform:GetWorldPosition()
		local theta0 = math.random() * TWOPI
		local delta = TWOPI / #inst.debris
		local radius = 1
		for i, v in ipairs(inst.debris) do
			local theta = theta0 + (i + math.random() * 0.5) * delta
			local cos_theta = math.cos(theta)
			local sin_theta = math.sin(theta)
			local speed = 2 + math.random() * 2
			v.Physics:Teleport(x + cos_theta * radius, 0, z - sin_theta * radius)
			v.Physics:SetVel(speed * cos_theta, 0, -speed * sin_theta)
			v.AnimState:PlayAnimation("rock_float_0"..tostring(v.variation))
		end
	end
end

local function OnRemoveEntity(inst)
	if inst.debrisshown then
		for i, v in ipairs(inst.debris) do
			v:Remove()
		end
	end
	StopTracking(inst)
end

local function OnNewState(inst)
	if not inst.sg:HasStateTag("debris") then
		inst:HideDebris()
	end
end

--------------------------------------------------------------------------

local CLOUD_RADIUS = 2.5
local PHYSICS_PADDING = 3
local SLEEPER_TAGS = { "player", "sleeper" }
local SLEEPER_NO_TAGS = { "playerghost", "epic", "lunar_aligned", "INLIMBO" }

local function OnClearCloudProtection(ent)
	ent._lunargrazercloudprot = nil
end

local function SetCloudProtection(inst, ent, duration)
	if ent:IsValid() then
		if ent._lunargrazercloudprot ~= nil then
			ent._lunargrazercloudprot:Cancel()
		end
		ent._lunargrazercloudprot = ent:DoTaskInTime(duration, OnClearCloudProtection)
	end
end

local function DoCloudTask(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	for i, v in ipairs(TheSim:FindEntities(x, y, z, CLOUD_RADIUS + PHYSICS_PADDING, nil, SLEEPER_NO_TAGS, SLEEPER_TAGS)) do
		if v._lunargrazercloudprot == nil and
			v:IsValid() and v.entity:IsVisible() and
			not (v.components.health ~= nil and v.components.health:IsDead()) and
			not (v.sg ~= nil and v.sg:HasStateTag("waking"))
			then
			local range = v:GetPhysicsRadius(0) + CLOUD_RADIUS
			if v:GetDistanceSqToPoint(x, y, z) < range * range then
				if v.components.grogginess ~= nil then
					if not (v.sg ~= nil and v.sg:HasStateTag("knockout")) then
						v.components.grogginess:AddGrogginess(TUNING.LUNAR_GRAZER_GROGGINESS, TUNING.LUNAR_GRAZER_KNOCKOUTTIME)
						inst:SetCloudProtection(v, .5)
					end
				elseif v.components.sleeper ~= nil then
					if not (v.sg ~= nil and v.sg:HasStateTag("sleeping")) then
						v.components.sleeper:AddSleepiness(TUNING.LUNAR_GRAZER_GROGGINESS, TUNING.LUNAR_GRAZER_KNOCKOUTTIME)
						inst:SetCloudProtection(v, .5)
					end
				end
			end
		end
	end
end

local function StartCloudTask(inst)
	if inst.cloudtask == nil then
		inst.cloudtask = inst:DoPeriodicTask(1, DoCloudTask, math.random())
	end
end

local function StopCloudTask(inst)
	if inst.cloudtask ~= nil then
		inst.cloudtask:Cancel()
		inst.cloudtask = nil
	end
end

local function EnableCloud(inst, enable)
	enable = enable ~= false
	if enable ~= inst._cloudenabled:value() then
		inst._cloudenabled:set(enable)
		if not enable then
			StopCloudTask(inst)
		elseif not inst:IsAsleep() then
			StartCloudTask(inst)
		end
	end
end

local function IsCloudEnabled(inst)
	return inst._cloudenabled:value()
end

--------------------------------------------------------------------------

local function IsTargetSleeping(inst, target)
	if target.components.grogginess ~= nil then
		return target.components.grogginess:IsKnockedOut()
	elseif target.components.sleeper ~= nil then
		return target.components.sleeper:IsAsleep()
	end
	return false
end

local function RetargetFn(inst)
	if inst.sg:HasStateTag("invisible") then
		return
	end

	local target = inst.components.combat.target
	if inst.debrisshown then
		if target ~= nil then
			--Already has target
			return
		end
		--Only players can wake them up
		local player, distsq = inst:GetNearestPlayer(true)
		return distsq ~= nil
			and distsq < TUNING.LUNAR_GRAZER_WAKE_RANGE * TUNING.LUNAR_GRAZER_WAKE_RANGE
			and player
			or nil
	end

	local x, y, z = inst.Transform:GetWorldPosition()
	local inrange, isplayer, asleep
	if target ~= nil then
		local range = TUNING.LUNAR_GRAZER_ATTACK_RANGE + target:GetPhysicsRadius(0)
		inrange = target:GetDistanceSqToPoint(x, y, z) < range * range
		isplayer = target:HasTag("player")
		asleep = inst:IsTargetSleeping(target)
		if inrange and isplayer and asleep then
			--Keep target
			return
		end
	end

	for i, v in ipairs(TheSim:FindEntities(x, y, z, TUNING.LUNAR_GRAZER_AGGRO_RANGE, nil, SLEEPER_NO_TAGS, SLEEPER_TAGS)) do
		if v.entity:IsVisible() and
			not (v.components.health ~= nil and v.components.health:IsDead()) and
			(not asleep or inst:IsTargetSleeping(v)) and
			(	not (isplayer or inrange) and
				v.components.combat ~= nil and
				v.components.combat.target ~= nil and
				v.components.combat.target.prefab == inst.prefab or
				v:HasTag("player")
			)
			then
			return v, true
		end
	end
end

local function KeepTargetFn(inst, target)
	if inst.debrisshown and not target:HasTag("player") or not inst.components.combat:CanTarget(target) or inst.sg:HasStateTag("invisible") then
		return false
	end
	local spawnpoint = inst.components.knownlocations:GetLocation("spawnpoint")
	if spawnpoint ~= nil then
		return target:GetDistanceSqToPoint(spawnpoint) < TUNING.LUNAR_GRAZER_DEAGGRO_RANGE * TUNING.LUNAR_GRAZER_DEAGGRO_RANGE
	end
	return inst:IsNear(target, TUNING.LUNAR_GRAZER_DEAGGRO_RANGE)
end

local function OnAttacked(inst, data)
	if data.attacker ~= nil then
		local target = inst.components.combat.target
		if not (target ~= nil and
			target:HasTag("player") and
			inst:IsNear(target, TUNING.LUNAR_GRAZER_ATTACK_RANGE + target:GetPhysicsRadius(0))) then
			inst.components.combat:SetTarget(data.attacker)
		end
	end
end

--------------------------------------------------------------------------

local function OnEntitySleep(inst)
	if not POPULATING and inst.components.knownlocations:GetLocation("spawnpoint") ~= nil and inst.components.entitytracker:GetEntity("portal") == nil then
		inst:Remove()
		return
	end
	StopTracking(inst)
	StopCloudTask(inst)
end

local function OnEntityWake(inst)
	StartTracking(inst)
	if inst:IsCloudEnabled() then
		StartCloudTask(inst)
	end
end

local function OnSpawnedBy(inst, portal, delay)
	inst.components.knownlocations:RememberLocation("spawnpoint", inst:GetPosition())
	inst.components.entitytracker:TrackEntity("portal", portal)
	inst:ListenForEvent("onremove", inst._onportalremoved, portal)
	inst.sg:GoToState("spawndelay", delay)
end

local function OnSave(inst, data)
	if inst.debrisshown or inst.sg:HasStateTag("invisible") then
		data.debris = true
	end
end

local function OnLoad(inst, data)
	if data ~= nil and data.debris then
		inst.sg:GoToState("dissipated")
	end
end

local function OnLoadPostPass(inst)--, newents, data)
	local portal = inst.components.entitytracker:GetEntity("portal")
	if portal ~= nil then
		inst:ListenForEvent("onremove", inst._onportalremoved, portal)
	elseif inst.components.knownlocations:GetLocation("spawnpoint") ~= nil then
		inst:Remove()
	end
end

--------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("notraptrigger")
	inst:AddTag("lunar_aligned")

	MakeCharacterPhysics(inst, 10, .5)

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("lunar_grazer")
	inst.AnimState:SetBuild("lunar_grazer")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetMultColour(1, 1, 1, .4)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:UsePointFiltering(true)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetSymbolAddColour("moon_rocks", 0, 0, 0, 1)
	inst.scrapbook_anim = "scrapbook"

	inst._cloudenabled = net_bool(inst.GUID, "lunar_grazer._cloudenabled")
	inst._cloudenabled:set(true)
	inst.IsCloudEnabled = IsCloudEnabled

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.cloud = SpawnPrefab("lunar_goop_cloud_fx")
	inst.cloud.entity:SetParent(inst.entity)

	inst.core = SpawnPrefab("lunar_grazer_core_fx")
	inst.core.entity:SetParent(inst.entity)
	inst.core.Follower:FollowSymbol(inst.GUID, "rock_cycle_follow", nil, nil, nil, true)

	inst:AddComponent("inspectable")

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.LUNAR_GRAZER_HEALTH)
	inst.components.health:SetMinHealth(1)
	inst.components.health.nofadeout = true

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.LUNAR_GRAZER_DAMAGE)
	inst.components.combat:SetRange(TUNING.LUNAR_GRAZER_ATTACK_RANGE, TUNING.LUNAR_GRAZER_HIT_RANGE)
	inst.components.combat:SetAttackPeriod(TUNING.LUNAR_GRAZER_ATTACK_PERIOD)
	inst.components.combat:SetRetargetFunction(3, RetargetFn)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	inst.components.combat.hiteffectsymbol = "blob_body"
	inst:ListenForEvent("attacked", OnAttacked)

	inst:AddComponent("planarentity")
	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.LUNAR_GRAZER_PLANAR_DAMAGE)

	inst:AddComponent("damagetyperesist")
	inst.components.damagetyperesist:AddResist("explosive", inst, 99999, "weaktoexplosives")

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.LUNAR_GRAZER_WALKSPEED
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.softstop = true
	inst.components.locomotor.pathcaps = { ignorecreep = true }

	inst:AddComponent("knownlocations")
	inst:AddComponent("entitytracker")

	inst.debris = nil
	inst.debrisshown = false
	inst.debrisscattered = false
	inst.HideDebris = HideDebris
	inst.ShowDebris = ShowDebris
	inst.ScatterDebris = ScatterDebris
	inst.TossDebris = TossDebris
	inst.DropDebris = DropDebris
	inst.OnRemoveEntity = OnRemoveEntity
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
	inst.SetCloudProtection = SetCloudProtection
	inst.EnableCloud = EnableCloud
	inst.IsTargetSleeping = IsTargetSleeping
	inst.OnSpawnedBy = OnSpawnedBy
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnLoadPostPass = OnLoadPostPass

	inst._onportalremoved = function(portal)
		if inst:IsAsleep() then
			inst:Remove()
		else
			inst:PushEvent("lunar_grazer_despawn", { force = true })
		end
	end

	inst.trails = {}
	for i = 1, NUM_TRAIL_VARIATIONS do
		inst.trails[i] = i
	end
	--shuffle veriations
	for i = 1, NUM_TRAIL_VARIATIONS do
		local rnd = math.random(i, NUM_TRAIL_VARIATIONS)
		local v = inst.trails[i]
		inst.trails[i] = inst.trails[rnd]
		inst.trails[rnd] = v
	end
	inst.SpawnTrail = SpawnTrail
	inst._ontrailfinished = function(fx) RecycleTrail(inst, fx) end

	inst:ListenForEvent("newstate", OnNewState)

	inst:SetStateGraph("SGlunar_grazer")
	inst:SetBrain(brain)

	return inst
end

--------------------------------------------------------------------------

local function corefn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("lunar_grazer")
	inst.AnimState:SetBuild("lunar_grazer")
	inst.AnimState:PlayAnimation("rock_cycle", true)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	return inst
end

--------------------------------------------------------------------------

local function debrisfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("lunar_grazer")
	inst.AnimState:SetBuild("lunar_grazer")
	inst.AnimState:PlayAnimation("rock_01")
	inst.AnimState:SetSymbolMultColour("rock_blob", 1, 1, 1, 0.4)
	inst.AnimState:SetSymbolLightOverride("rock_blob", 0.1)
	inst.AnimState:SetSymbolBloom("rock_blob")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.variation = math.random(5)
	if inst.variation ~= 1 then
		inst.AnimState:PlayAnimation("rock_0"..tostring(inst.variation))
	end

	inst.persists = false

	return inst
end

--------------------------------------------------------------------------

return Prefab("lunar_grazer", fn, assets, prefabs),
	Prefab("lunar_grazer_core_fx", corefn, assets),
	Prefab("lunar_grazer_debris", debrisfn, assets)
