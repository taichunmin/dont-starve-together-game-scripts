local assets =
{
	Asset("ANIM", "anim/sharkboi_icespike.zip"),
	Asset("ANIM", "anim/sharkboi_iceplow_fx.zip"),
}

local prefabs_spike =
{
	"ice",
}

local prefabs_tunnel =
{
	"sharkboi_icespike",
}

SetSharedLootTable("sharkboi_icespike", {
	{ "ice", 1.0 },
	{ "ice", 0.75 },
})

SetSharedLootTable("sharkboi_icespike_low", {
	{ "ice", 0.25 },
})

--------------------------------------------------------------------------

local RADIUS = 0.8
local RADIUS_LARGE = 1.4
local NUM_VARIATIONS = 3

local function GetNextVariation(pool)
	local rnd = math.max(1, math.random(NUM_VARIATIONS) - 1)
	local v = pool[rnd]
	for i = rnd, NUM_VARIATIONS - 1 do
		pool[i] = pool[i + 1]
	end
	pool[NUM_VARIATIONS] = v
	return v
end

local function GenerateVariationsPool()
	local pool = {}
	for i = 1, NUM_VARIATIONS do
		pool[i] = i
	end

	--shuffle
	for i = 1, NUM_VARIATIONS - 1 do
		local rnd = math.random(i, NUM_VARIATIONS)
		if rnd ~= i then
			local v = pool[i]
			pool[i] = pool[rnd]
			pool[rnd] = v
		end
	end

	pool.GetNext = GetNextVariation
	return pool
end

--------------------------------------------------------------------------

local DAMAGE_RADIUS_PADDING = 0.5

local function SpikeLaunch(inst, launcher, basespeed, startheight, startradius)
	local x0, y0, z0 = launcher.Transform:GetWorldPosition()
	local x1, y1, z1 = inst.Transform:GetWorldPosition()
	local dx, dz = x1 - x0, z1 - z0
	local dsq = dx * dx + dz * dz
	local angle
	if dsq > 0 then
		local dist = math.sqrt(dsq)
		angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
	else
		angle = TWOPI * math.random()
	end
	local sina, cosa = math.sin(angle), math.cos(angle)
	local speed = basespeed + math.random()
	inst.Physics:Teleport(x0 + startradius * cosa, startheight, z0 + startradius * sina)
	inst.Physics:SetVel(cosa * speed, speed * 5 + math.random() * 2, sina * speed)
end

local COLLAPSIBLE_WORK_ACTIONS =
{
	CHOP = true,
	DIG = true,
	HAMMER = true,
	MINE = true,
}
local COLLAPSIBLE_TAGS = { "frozen" --[[ for "ice" ]], "player", "pickable", "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
	table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "flying", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }
local TOSSITEM_MUST_TAGS = { "_inventoryitem" }
local TOSSITEM_CANT_TAGS = { "locomotor", "INLIMBO" }

local function DoDamage(inst)
	inst.dmgtask = nil

	local radius = inst.islarge:value() and RADIUS_LARGE or RADIUS
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, 0, z, radius + DAMAGE_RADIUS_PADDING, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)
	for i, v in ipairs(ents) do
		if v ~= inst and not (inst.targets and inst.targets[v]) and v:IsValid() then
			if v.prefab == "ice" then
				v:Remove()
			elseif v:HasTag("player") then
				--NOTE: inst.targets will prevent multiple knockbacks, but
				--      CreatePhysicsPush should still keep them in bounds
				v:PushEvent("knockback", { knocker = inst, radius = radius, strengthmult = 0.3, forcelanded = not inst.islarge:value() })
			else
				local isworkable = false
				if v.components.workable then
					local work_action = v.components.workable:GetWorkAction()
					--V2C: nil action for NPC_workable (e.g. campfires)
					--     allow digging spawners (e.g. rabbithole)
					isworkable = (
						(work_action == nil and v:HasTag("NPC_workable")) or
						(v.components.workable:CanBeWorked() and work_action and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
					)
				end
				if isworkable then
					v.components.workable:Destroy(inst)
					if v:IsValid() and v:HasTag("stump") then
						v:Remove()
					end
				elseif v.components.pickable and v.components.pickable:CanBePicked() and not v:HasTag("intense") then
					v.components.pickable:Pick(inst)
				end
			end
			if inst.targets then
				inst.targets[v] = true
			end
		end
	end

	--Tossing we don't care about repeat targets
	local totoss = TheSim:FindEntities(x, 0, z, radius + DAMAGE_RADIUS_PADDING, TOSSITEM_MUST_TAGS, TOSSITEM_CANT_TAGS)
	for i, v in ipairs(totoss) do
		if v.prefab == "ice" then
			v:Remove()
		else
			if v.components.mine then
				v.components.mine:Deactivate()
			end
			if not v.components.inventoryitem.nobounce and v.Physics and v.Physics:IsActive() then
				SpikeLaunch(v, inst, .8 + radius, radius * .4, radius + v:GetPhysicsRadius(0))
			end
		end
	end
end

local function RefreshWorkLevel(inst, workleft)
	if inst.islarge:value() then
		if workleft <= TUNING.SHARKBOI_ICE_LARGE_MINE / 3 then
			inst.AnimState:PlayAnimation("spike4_low")
			return true
		elseif workleft <= TUNING.SHARKBOI_ICE_LARGE_MINE * 2 / 3 then
			inst.AnimState:PlayAnimation("spike4_med")
			return true
		end
	elseif workleft <= TUNING.SHARKBOI_ICE_MINE / 2 then
		inst.AnimState:PlayAnimation("spike"..tostring(inst.variation).."_low")
		return true
	end
end

local function OnWork(inst, worker, workleft)
	if workleft <= 0 then
		if worker and (worker:HasTag("groundspike") or worker:HasTag("shark")) then
			inst.components.lootdropper:SetChanceLootTable("sharkboi_icespike_low")
			inst.SoundEmitter:PlaySound("meta3/sharkboi/ice_spike_break")
		else
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/iceboulder_smash")
		end
		local pos = inst:GetPosition()
		inst.components.lootdropper:DropLoot(pos)

		inst.persists = false
		inst.Physics:SetActive(false)
		inst:AddTag("FX")
		inst:AddTag("NOCLICK")
		inst.AnimState:SetBuild("sharkboi_iceplow_fx")
		local variation = math.random(2)
		inst.AnimState:SetBankAndPlayAnimation("sharkboi_iceplow_fx", "iceplow"..tostring(variation).."_pre")
		inst.AnimState:PushAnimation("iceplow"..tostring(variation).."_pst", false)
		if math.random() < 0.5 then
			inst.AnimState:SetScale(-1, 1)
		end
		inst:ListenForEvent("animqueueover", inst.Remove)
	else
		RefreshWorkLevel(inst, workleft)
	end
end

local function MakeWorkable(inst)
	inst.workabletask = nil

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(inst.islarge:value() and TUNING.SHARKBOI_ICE_LARGE_MINE or TUNING.SHARKBOI_ICE_MINE)
	inst.components.workable:SetOnWorkCallback(OnWork)
end

local function CreatePhysicsPush(parent)
	local inst = CreateEntity()

	inst:AddTag("CLASSIFIED")
	--[[Non-networked entity]]
	inst.entity:SetCanSleep(TheWorld.ismastersim)
	inst.persists = false

	inst.entity:AddTransform()

	inst.entity:AddPhysics()
	inst.Physics:SetMass(999999)
	inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
	inst.Physics:ClearCollisionMask()
	inst.Physics:CollidesWith(COLLISION.ITEMS)
	inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.GIANTS)
	inst.Physics:CollidesWith(COLLISION.WORLD)
	inst.Physics:SetCapsule(parent.islarge:value() and RADIUS_LARGE or RADIUS, 2)

	inst:DoTaskInTime(0, inst.Remove)

	inst.Transform:SetPosition(parent.Transform:GetWorldPosition())

	return inst
end

local function SetVariation(inst, variation)
	variation = math.clamp(variation, 1, NUM_VARIATIONS + 1)
	if inst.variation ~= variation then
		if variation > NUM_VARIATIONS then
			if not inst.islarge:value() then
				inst.islarge:set(true)
				inst.Physics:SetCapsule(RADIUS_LARGE, 2)
				if inst.components.workable then
					local workdone = TUNING.SHARKBOI_ICE_MINE - inst.components.workable:GetWorkLeft()
					local workleft = math.clamp(TUNING.SHARKBOI_ICE_LARGE_MINE - workdone, 1, TUNING.SHARKBOI_ICE_LARGE_MINE)
					inst.components.workable:SetWorkLeft(workleft)
				end
			end
		elseif inst.islarge:value() then
			inst.islarge:set(false)
			inst.Physics:SetCapsule(RADIUS, 2)
			if inst.components.workable then
				local workdone = TUNING.SHARKBOI_ICE_LARGE_MINE - inst.components.workable:GetWorkLeft()
				local workleft = math.clamp(TUNING.SHARKBOI_ICE_MINE - workdone, 1, TUNING.SHARKBOI_ICE_MINE)
				inst.components.workable:SetWorkLeft(workleft)
			end
		end

		if inst.AnimState:IsCurrentAnimation("spike"..tostring(inst.variation).."_pre") then
			local t = inst.AnimState:GetCurrentAnimationTime()
			inst.AnimState:PlayAnimation("spike"..tostring(variation).."_pre")
			inst.AnimState:SetTime(t)
			inst.AnimState:PushAnimation("spike"..tostring(variation), false)
		elseif not (inst.components.workable and RefreshWorkLevel(inst, inst.components.workable:GetWorkLeft())) then
			inst.AnimState:PlayAnimation("spike"..tostring(variation))
		end
		inst.variation = variation
	end
end

local function OnSave(inst, data)
	data.variation = inst.variation ~= 1 and inst.variation or nil
	if inst.dmgtask then
		data.dodmg = true
	elseif inst.components.workable then
		local totalwork = inst.islarge:value() and TUNING.SHARKBOI_ICE_LARGE_MINE or TUNING.SHARKBOI_ICE_MINE
		local workdone = totalwork - inst.components.workable:GetWorkLeft()
		if workdone > 0 then
			data.worked = workdone
		end
	end
end

local function OnLoad(inst, data)
	if not (data and data.dodmg) then
		if inst.dmgtask then
			inst.dmgtask:Cancel()
			inst.dmgtask = nil
		end
		if inst.workabletask then
			inst.workabletask:Cancel()
			MakeWorkable(inst)
			inst.AnimState:PlayAnimation("spike"..tostring(inst.variation))
		end
	end
	inst:SetVariation(data and data.variation or 1)
	if data and data.worked and inst.components.workable then
		local totalwork = inst.islarge:value() and TUNING.SHARKBOI_ICE_LARGE_MINE or TUNING.SHARKBOI_ICE_MINE
		local workleft = totalwork - data.worked
		if workleft > 0 and workleft < totalwork then
			inst.components.workable:SetWorkLeft(workleft)
			RefreshWorkLevel(inst, workleft)
		end
	end
end

local function spikefn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddPhysics()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.Transform:SetSixFaced()

	inst.AnimState:SetBank("sharkboi_icespike")
	inst.AnimState:SetBuild("sharkboi_icespike")
	inst.AnimState:PlayAnimation("spike1_pre")

	MakeObstaclePhysics(inst, RADIUS, 2)
	inst:DoTaskInTime(0, CreatePhysicsPush)

	inst:AddTag("groundspike")
	inst:AddTag("frozen")

	inst.islarge = net_bool(inst.GUID, "sharkboi_icespike.islarge")

	inst.scrapbook_inspectonseen = true

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.scrapbook_anim = "spike1"
	inst.scrapbook_workable = ACTIONS.MINE

	inst.variation = 1
	inst.AnimState:PushAnimation("spike1", false)

	inst.dmgtask = inst:DoTaskInTime(0, DoDamage)
	inst.workabletask = inst:DoTaskInTime(3 * FRAMES, MakeWorkable)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable("sharkboi_icespike")

	inst:AddComponent("savedrotation")

	inst.SetVariation = SetVariation
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	return inst
end

--------------------------------------------------------------------------

local SPAWN_PERIOD = 0
local MAX_COUNT = 20
local MAX_ICESPIKE_SFX = 10
local SFX_PERIOD = math.ceil(MAX_COUNT / (MAX_ICESPIKE_SFX / 2 - 1))
local SPACING = RADIUS * 2 + 0.05
local TUNNEL_RADIUS = 3
local MIN_DRIFT = 0.25
local DRIFT_VAR = 0.25
local OUTER_DRIFT_LIMIT = 1.5
local INNER_DRIFT_LIMIT = 0.5

local function EndTask(inst, flip)
	local taskname = flip and "task_L" or "task_R"
	inst[taskname]:Cancel()
	inst[taskname] = nil
	if not (inst.task_R or inst.task_L) then
		inst:Remove()
	end
end

--Refactored so that we check our next spawnpoint before spawning our previously
--queued spawnpoint.  This way, we know which one is our final spike, and we can
--set it to a large sized variation.
local function DoSpawnSpike(inst, data, variations, targets, flip)
	local rot = inst.Transform:GetRotation()
	local spike, final, shouldsfx
	if data.queued_x then
		spike = SpawnPrefab("sharkboi_icespike")
		spike.Transform:SetPosition(data.queued_x, 0, data.queued_z)
		spike.Transform:SetRotation(rot + (flip and -70 or 70))
		spike.targets = targets

		if data.next_sfx > 0 then
			data.next_sfx = data.next_sfx - 1
		else
			data.next_sfx = SFX_PERIOD
			shouldsfx = true
		end

		data.count = data.count + 1
		if data.count < MAX_COUNT then
			if data.next_drift_change > 1 then
				data.next_drift_change = data.next_drift_change - 1
			else
				local max_drift_dist = flip and INNER_DRIFT_LIMIT or OUTER_DRIFT_LIMIT
				local min_drift_dist = flip and -OUTER_DRIFT_LIMIT or -INNER_DRIFT_LIMIT
				local mid_drift_dist = (min_drift_dist + max_drift_dist) / 2
				local drift_dir
				if flip and data.drift_dist > mid_drift_dist and data.drift < 0 then
					drift_dir = -1 --favour outward a bit
					data.next_drift_change = 1
				elseif not flip and data.drift_dist < mid_drift_dist and data.drift > 0 then
					drift_dir = 1 --favour outward a bit
					data.next_drift_change = 1
				else
					drift_dir =
						(data.drift_dist > max_drift_dist and -1) or
						(data.drift_dist < min_drift_dist and 1) or
						data.drift > 0 and -1 or 1
					data.next_drift_change = math.random(2, 3)
				end
				data.drift = drift_dir * (MIN_DRIFT + math.random() * DRIFT_VAR)
			end
			data.drift_dist = data.drift_dist + data.drift
		else
			final = true
		end
	end

	if not final then
		local x, y, z = inst.Transform:GetWorldPosition()
		local theta = rot * DEGREES
		local dist = data.count * SPACING
		local perptheta = (rot + 90) * DEGREES
		local perpdist = (flip and -TUNNEL_RADIUS or TUNNEL_RADIUS) + data.drift_dist
		x = x + dist * math.cos(theta) + perpdist * math.cos(perptheta)
		z = z - dist * math.sin(theta) - perpdist * math.sin(perptheta)
		if TheWorld.Map:IsPassableAtPoint(x, 0, z) then
			data.queued_x = x
			data.queued_z = z
		else
			final = true
		end
	end

	if spike then
		spike:SetVariation(final and NUM_VARIATIONS + 1--[[large]] or variations:GetNext())
		if final or shouldsfx then
			spike.SoundEmitter:PlaySound("meta3/sharkboi/ice_spike")
		end
	end
	if final then
		EndTask(inst, flip)
	end
end

local function tunnelfn()
	local inst = CreateEntity()

	inst:AddTag("CLASSIFIED")
	--[[Non-networked entity]]
	inst.persists = false

	inst.entity:AddTransform()

	local targets = {}

	inst.task_R = inst:DoPeriodicTask(SPAWN_PERIOD, DoSpawnSpike, 0, {
		count = 0,
		drift_dist = -0.9,
		drift = MIN_DRIFT + (0.7 + 0.3 * math.random()) * DRIFT_VAR,
		next_drift_change = math.random(2, 3),
		next_sfx = 0,
	}, GenerateVariationsPool(), targets)

	inst.task_L = inst:DoPeriodicTask(SPAWN_PERIOD, DoSpawnSpike, 0, {
		count = 0,
		drift_dist = 0.9,
		drift = -MIN_DRIFT - (0.7 + 0.3 * math.random()) * DRIFT_VAR,
		next_drift_change = math.random(2, 3),
		next_sfx = math.floor(SFX_PERIOD / 2),
	}, GenerateVariationsPool(), targets, true)

	return inst
end

--------------------------------------------------------------------------

return Prefab("sharkboi_icespike", spikefn, assets, prefabs_spike),
	Prefab("sharkboi_icetunnel_fx", tunnelfn, nil, prefabs_tunnel)
