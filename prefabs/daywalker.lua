local assets =
{
	Asset("ANIM", "anim/daywalker_build.zip"),
	Asset("ANIM", "anim/daywalker_pillar.zip"),
	Asset("ANIM", "anim/daywalker_imprisoned.zip"),
	Asset("ANIM", "anim/daywalker_phase1.zip"),
	Asset("ANIM", "anim/daywalker_phase2.zip"),
	Asset("ANIM", "anim/daywalker_defeat.zip"),
}

local prefabs =
{
	"shadow_leech",
	"daywalker_sinkhole",
	"daywalker_pillar",

	"nightmarefuel",
	"horrorfuel",
	"armordreadstone_blueprint",
	"dreadstonehat_blueprint",
	"wall_dreadstone_item_blueprint",
	"support_pillar_dreadstone_scaffold_blueprint",
	"chesspiece_daywalker_sketch",
	"winter_ornament_boss_daywalker",
}

local brain = require("brains/daywalkerbrain")

SetSharedLootTable("daywalker",
{
	{ "nightmarefuel",	0.5 },

	{ "horrorfuel",		1 },
	{ "horrorfuel",		1 },
	{ "horrorfuel",		1 },
	{ "horrorfuel",		1 },
	{ "horrorfuel",		0.5 },

	{ "armordreadstone_blueprint",	1 },
	{ "dreadstonehat_blueprint",	1 },
	{ "wall_dreadstone_item_blueprint", 1 },
	{'chesspiece_daywalker_sketch', 1.00},
})
local BONUS_PILLAR_LOOT = { "support_pillar_dreadstone_scaffold_blueprint" }

--------------------------------------------------------------------------

local PILLAR_TAGS = { "daywalker_pillar" }
local PILLAR_NO_TAGS = { "NOCLICK" }

local function CountPillars(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local pillars = TheSim:FindEntities(x, y, z, 6.1, PILLAR_TAGS--[[, PILLAR_NO_TAGS]])
	local resonating, idle = 0, 0
	for i, v in ipairs(pillars) do
		if v:GetPrisoner() == inst then
			if v:IsResonating() then
				resonating = resonating + 1
			else
				idle = idle + 1
			end
		end
	end
	return resonating, idle
end

local function OnPillarRemoved(inst, pillar)
	local pos = inst.components.knownlocations:GetLocation("prison")
	if pos ~= nil then
		local pillars = TheSim:FindEntities(pos.x, pos.y, pos.z, 6.1, PILLAR_TAGS, PILLAR_NO_TAGS)
		for i, v in ipairs(pillars) do
			if v.components.entitytracker ~= nil and
				(	v.components.entitytracker:GetEntity("freed") == inst or
					v.components.entitytracker:GetEntity("prisoner") == inst
				) then
				--Still has a pillar
				return
			end
		end
		--Our pillars got destroyed
		inst.components.knownlocations:ForgetLocation("prison")
	end
end

--------------------------------------------------------------------------

local MASS = 1000

--For clients
local function OnFacingModelDirty(inst)
	local numfacings = inst._facingmodel:value()
	if numfacings == 4 then
		inst.eye.Transform:SetFourFaced()
	elseif numfacings == 6 then
		inst.eye.Transform:SetSixFaced()
	elseif numfacings == 0 then
		inst.eye.Transform:SetNoFaced()
	end
end

local function SwitchToFacingModel(inst, numfacings)
	if numfacings == 0 then
		inst.Transform:SetNoFaced()
		if inst.eye ~= nil then
			inst.eye.Transform:SetNoFaced()
		end
	elseif numfacings == 4 then
		inst.Transform:SetFourFaced()
		if inst.eye ~= nil then
			inst.eye.Transform:SetFourFaced()
		end
	elseif numfacings == 6 then
		inst.Transform:SetSixFaced()
		if inst.eye ~= nil then
			inst.eye.Transform:SetSixFaced()
		end
	else--unsupported
		--assert(false)
		return
	end
	inst._facingmodel:set(numfacings)
end

--------------------------------------------------------------------------

local function CreateShackleNeckBand()
	local inst = CreateEntity()

	--inst:AddTag("FX")
	inst:AddTag("decor")
	inst:AddTag("NOCLICK")
	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.AnimState:SetBank("daywalker")
	inst.AnimState:SetBuild("daywalker_pillar")
	inst.AnimState:PlayAnimation("shackle_neck_band_loop", true)

	return inst
end

local function CreateChainBodyLink()
	local inst = CreateEntity()

	--inst:AddTag("FX")
	inst:AddTag("decor")
	inst:AddTag("NOCLICK")
	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.AnimState:SetBank("daywalker")
	inst.AnimState:SetBuild("daywalker_pillar")
	inst.AnimState:PlayAnimation("chain_body_link_loop", true)
	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

	return inst
end

local function SpawnChains(inst)
	if inst.chains == nil then
		inst.neckchain = CreateShackleNeckBand()
		inst.neckchain.entity:SetParent(inst.entity)
		inst.neckchain.Follower:FollowSymbol(inst.GUID, "shackle_neck_band_follow", nil, nil, nil, true)
		inst.chains = {}
		for i = 1, 12 do
			local link = CreateChainBodyLink()
			link.entity:SetParent(inst.entity)
			link.Follower:FollowSymbol(inst.GUID, "chain_body_link_follow_"..tostring(i), nil, nil, nil, true)
			table.insert(inst.chains, link)
		end
	end
end

local function RemoveChains(inst)
	if inst.neckchain ~= nil then
		inst.neckchain:Remove()
		inst.neckchain = nil
	end
	if inst.chains ~= nil then
		for i, v in ipairs(inst.chains) do
			v:Remove()
		end
		inst.chains = nil
	end
end

local function OnChainSleepTask(inst)
	inst._chainsleeptask = nil
	RemoveChains(inst)
end

local function OnChainsDirty(inst)
	if inst._enablechains:value() then
		if not (TheWorld.ismastersim and inst:IsAsleep()) then
			SpawnChains(inst)
		end
	else
		RemoveChains(inst)
		if inst._chainsleeptask ~= nil then
			inst._chainsleeptask:Cancel()
			inst._chainsleeptask = nil
		end
	end
end

local function EnableChains(inst, enable)
	enable = enable ~= false
	if enable ~= inst._enablechains:value() then
		inst._enablechains:set(enable)

		--Dedicated server does not need to spawn the local fx
		if not TheNet:IsDedicated() then
			OnChainsDirty(inst)
		end
	end
end

--------------------------------------------------------------------------

local ATTACH_POS =
{
	"left",
	"right",
	"top",
}

local function HasLeechAttached(inst)
	for i, v in ipairs(ATTACH_POS) do
		if inst.components.entitytracker:GetEntity(v) ~= nil then
			return true
		end
	end
	return false
end

local function HasLeechTracked(inst)
	return next(inst._leeches) ~= nil
end

local function StartTrackingLeech(inst, leech)
	if inst._leeches[leech] == nil then
		inst._leeches[leech] = true
		inst:ListenForEvent("onremove", inst._onremoveleech, leech)
		inst:MakeHarassed()
		if not inst.sg:HasStateTag("canattach") and inst.sg:HasState("tired") then
			inst.sg:GoToState("tired")
		end
	end
end

local function SetLeechAttached(inst, leech, attachpos)
	leech.components.entitytracker:TrackEntity("daywalker", inst)
	leech.Follower:FollowSymbol(inst.GUID, "shadowleech_"..attachpos, nil, nil, nil, true)
	leech.sg:GoToState("attached")
end

local function AttachLeech(inst, leech, noreact)
	if inst.chained or inst.defeated then
		return false
	end
	local attachpos = {}
	for i, v in ipairs(ATTACH_POS) do
		local ent = inst.components.entitytracker:GetEntity(v)
		if ent == nil then
			table.insert(attachpos, v)
		elseif ent == leech then
			return false
		end
	end
	attachpos = attachpos[math.random(#attachpos)]
	inst.components.entitytracker:TrackEntity(attachpos, leech)
	if inst._incoming_jumps[leech.GUID] ~= nil then
		inst._incoming_jumps[leech.GUID]:Cancel()
		inst._incoming_jumps[leech.GUID] = nil
	end
	SetLeechAttached(inst, leech, attachpos)
	inst:MakeHarassed()
	if not noreact then
		inst:PushEvent("leechattached", { leech = leech, attachpos = attachpos })
	end
	return true
end

local function ClearTask(inst, tbl, key)
	tbl[key] = nil
end

local function DetachLeech(inst, attachpos, speedmult, randomdir)
	local todetach
	if type(attachpos) == "string" then
		if inst._busy_attach_pos[attachpos] ~= nil then
			return false
		end
		todetach = inst.components.entitytracker:GetEntity(attachpos)
		if todetach == nil then
			return false
		end
	elseif attachpos ~= nil then
		for i, v in ipairs(attachpos) do
			if inst._busy_attach_pos[v] == nil then
				todetach = inst.components.entitytracker:GetEntity(v)
				if todetach ~= nil then
					attachpos = v
					break
				end
			end
		end
		if todetach == nil then
			return false
		end
	else
		todetach = {}
		for i, v in ipairs(ATTACH_POS) do
			if inst._busy_attach_pos[v] == nil then
				local ent = inst.components.entitytracker:GetEntity(v)
				if ent ~= nil then
					table.insert(todetach, { v, ent })
				end
			end
		end
		if #todetach <= 1 then
			return false
		end
		attachpos, todetach = unpack(todetach[math.random(#todetach)])
	end

	--prevent reusing this attachpos for 2 seconds
	if inst._busy_attach_pos[attachpos] ~= nil then
		inst._busy_attach_pos[attachpos]:Cancel()
	end
	inst._busy_attach_pos[attachpos] = inst:DoTaskInTime(2, ClearTask, inst._busy_attach_pos, attachpos)

	inst.components.entitytracker:ForgetEntity(attachpos)

	--[[todetach.Follower:StopFollowing()
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot = randomdir and math.random() * 360 or inst.Transform:GetRotation() + math.random() * 10 - 5
	todetach.Transform:SetRotation(rot + 180) --flung backwards
	rot = rot * DEGREES
	speedmult = speedmult or 1
	todetach.Physics:Teleport(x + math.cos(rot) * speedmult, y, z - math.sin(rot) * speedmult)
	todetach.sg:GoToState("flung", speedmult)]]
	--V2C: moved to shadow_leech.OnFlungFrom
	todetach:OnFlungFrom(inst, speedmult, randomdir)
	return true
end

local function OnAttachmentInterrupted(inst, leech)
	--Used by shadow_leech stategraph in case of leaving "attached" state unexpectedly
	for i, v in ipairs(ATTACH_POS) do
		if inst.components.entitytracker:GetEntity(v) == leech then
			inst.components.entitytracker:ForgetEntity(v)
			return
		end
	end
end

local function OnIncomingJump(inst, leech)
	if inst._incoming_jumps[leech.GUID] ~= nil then
		inst._incoming_jumps[leech.GUID]:Cancel()
	end
	inst._incoming_jumps[leech.GUID] = inst:DoTaskInTime(0.7, ClearTask, inst._incoming_jumps, leech.GUID)
end

local function SpawnLeeches(inst)
	local pos = inst:GetPosition()
	local theta = math.random() * TWOPI
	for i = 1, 3 do
		local x, z = pos.x, pos.z
		local leech = SpawnPrefab("shadow_leech")
		for r = 4, 2, -1 do
			local offset = FindWalkableOffset(pos, theta, r + math.random() * 0.5, 4, false, true)
			if offset ~= nil then
				x = x + offset.x
				z = z + offset.z
				break
			end
		end
		leech.Transform:SetPosition(x, 0, z)
		leech:OnSpawnFor(inst, 0.4 + i * 0.3 + math.random() * 0.2)
		theta = theta + TWOPI / 3
	end
end

--------------------------------------------------------------------------

local function CreateEyeFlame()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	if not TheWorld.ismastersim then
		inst.entity:SetCanSleep(false)
	end
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("daywalker")
	inst.AnimState:SetBuild("daywalker_build")
	inst.AnimState:PlayAnimation("flame_loop", true)
	inst.AnimState:SetLightOverride(1)

	return inst
end

--------------------------------------------------------------------------

local BLINDSPOT = 15

local function UpdateHead(inst)
	if inst.stalking == nil then
		return
	elseif not inst.stalking:IsValid() then
		inst.stalking = nil
		inst.lastfacing = nil
		inst.lastdir1 = nil
		inst.Transform:SetRotation(0)
		inst.Transform:SetFourFaced()
		inst.eye.Transform:SetFourFaced()
		return
	end

	local parent = inst.entity:GetParent()
	parent.AnimState:MakeFacingDirty()
	local dir1 = parent:GetAngleToPoint(inst.stalking.Transform:GetWorldPosition())
	local camdir = TheCamera:GetHeading()
	local facing = parent.AnimState:GetCurrentFacing()

	dir1 = ReduceAngle(dir1 + camdir)

	if facing == FACING_UP then
		if dir1 > -135 and dir1 < 135 then
			local diff = ReduceAngle(dir1 - 2)
			if math.abs(diff) < BLINDSPOT and facing == inst.lastfacing then
				dir1 = inst.lastdir1
			else
				dir1 = diff > 0 and 135 or -135
			end
		end
	elseif facing == FACING_DOWN then
		if dir1 < -45 or dir1 > 90 then
			local diff = ReduceAngle(dir1 + 178)
			if math.abs(diff) < BLINDSPOT and facing == inst.lastfacing then
				dir1 = inst.lastdir1
			else
				dir1 = diff < 0 and 90 or -45
			end
		end
	elseif facing == FACING_LEFT then
		if dir1 < -45 or dir1 > 135 then
			local diff = ReduceAngle(dir1 + 160)
			if math.abs(diff) < BLINDSPOT and facing == inst.lastfacing then
				dir1 = inst.lastdir1
			else
				dir1 = diff < 0 and 135 or -45
			end
		end
	elseif facing == FACING_RIGHT then
		if dir1 < -135 or dir1 > 45 then
			local diff = ReduceAngle(dir1 - 160)
			if math.abs(diff) < BLINDSPOT and facing == inst.lastfacing then
				dir1 = inst.lastdir1
			else
				dir1 = diff < 0 and 45 or -135
			end
		end
	end

	inst.lastfacing = facing
	inst.lastdir1 = dir1

	inst.Transform:SetRotation(dir1 - camdir - parent.Transform:GetRotation())
	inst.AnimState:MakeFacingDirty()
	local facing1 = inst.AnimState:GetCurrentFacing()
	if facing1 == FACING_UPRIGHT or facing1 == FACING_UPLEFT then
		if facing == FACING_UP then
			inst.AnimState:Hide("side_ear")
			inst.AnimState:Show("back_ear")
		else
			inst.AnimState:Hide("back_ear")
			inst.AnimState:Show("side_ear")
		end
	end
end

local function CreateHead()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	if not TheWorld.ismastersim then
		inst.entity:SetCanSleep(false)
	end
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("daywalker")
	inst.AnimState:SetBuild("daywalker_build")
	inst.AnimState:PlayAnimation("head", true)

	inst:AddComponent("updatelooper")

	inst.isupdating = false
	inst.stalking = nil
	inst.lastfacing = nil
	inst.lastdir1 = nil

	inst.eye = CreateEyeFlame()
	inst.eye.entity:SetParent(inst.entity)
	inst.eye.Follower:FollowSymbol(inst.GUID, "follow_eye", nil, nil, nil, true)

	return inst
end

local function OnStalkingDirty(inst)
	inst.head.stalking = inst._stalking:value() --available to clients
	if inst.head.stalking ~= nil then
		if not inst.head.isupdating then
			inst.head.isupdating = true
			inst.head.components.updatelooper:AddPostUpdateFn(UpdateHead)
		end
		inst.head.Transform:SetEightFaced()
		inst.head.eye.Transform:SetEightFaced()
	elseif inst.head.isupdating then
		inst.head.isupdating = false
		inst.head.lastfacing = nil
		inst.head.lastdir1 = nil
		inst.head.components.updatelooper:RemovePostUpdateFn(UpdateHead)
		inst.head.Transform:SetRotation(0)
		inst.head.Transform:SetFourFaced()
		inst.head.eye.Transform:SetFourFaced()
	end
end

local function OnHeadTrackingDirty(inst)
	if inst._headtracking:value() then
		if inst.head == nil then
			inst.head = CreateHead()
			inst.head.entity:SetParent(inst.entity)
			inst.head.Follower:FollowSymbol(inst.GUID, "HEAD_follow", nil, nil, nil, true, true)
			inst.highlightchildren = { inst.head }
			inst.head:ListenForEvent("stalkingdirty", OnStalkingDirty, inst)
			OnStalkingDirty(inst)
		end
	elseif inst.head ~= nil then
		inst.head:Remove()
		inst.head = nil
		inst.highlightchildren = nil
	end
end

local function SetHeadTracking(inst, track)
	track = track ~= false
	if inst._headtracking:value() ~= track then
		inst._headtracking:set(track)

		--Dedicated server does not need to spawn the local fx
		if not TheNet:IsDedicated() then
			OnHeadTrackingDirty(inst)
		end
	end
end

local function OnStalkingNewState(inst)
	if inst.sg:HasStateTag("stalking") then
		inst.components.health:StartRegen(TUNING.DAYWALKER_COMBAT_STALKING_HEALTH_REGEN, TUNING.DAYWALKER_COMBAT_HEALTH_REGEN_PERIOD, false)
	else
		inst.components.health:StopRegen()
	end
end

local function SetStalking(inst, stalking)
	if stalking ~= nil and not (inst.hostile and stalking:HasTag("player")) then
		stalking = nil
	end
	if stalking ~= inst._stalking:value() then
		if inst._stalking:value() ~= nil then
			inst:RemoveEventCallback("onremove", inst._onremovestalking, inst._stalking:value())
			if stalking == nil then
				inst:RemoveEventCallback("newstate", OnStalkingNewState)
				if inst.engaged then
					inst.components.health:StopRegen()
				end
			end
		elseif stalking ~= nil then
			inst:ListenForEvent("newstate", OnStalkingNewState)
		end
		inst._stalking:set(stalking)
		if stalking then
			inst:ListenForEvent("onremove", inst._onremovestalking, stalking)
			if not inst.nostalkcd then
				inst.components.timer:StopTimer("stalk_cd")
				inst.components.timer:StartTimer("stalk_cd", TUNING.DAYWALKER_STALK_CD)
			end
		end
	end
end

local function GetStalking(inst)
	return inst._stalking:value()
end

local function IsStalking(inst)
	return inst._stalking:value() ~= nil
end

--------------------------------------------------------------------------

local DESPAWN_TIME = 60 * 4

--#V2C: kinda silly, but this was just to have it so PHASES[0] exists, but
--      will also be excluded from ipairs and #PHASES...
local PHASES =
{
	[0] = {
		hp = 1,
		fn = function(inst)
			inst.canfatigue = false
			inst.nostalkcd = true
			inst.canstalk = true
			inst.canslam = false
			inst.canwakeuphit = false
			inst.components.timer:StopTimer("stalk_cd")
			inst:ResetFatigue()
		end,
	},
	--
	[1] = {
		hp = 0.999,
		fn = function(inst)
			if inst.hostile then
				inst.canfatigue = true
				inst.nostalkcd = true
				inst.canstalk = false
				inst.canslam = false
				inst.canwakeuphit = false
			end
		end,
	},
	[2] = {
		hp = 0.8,
		fn = function(inst)
			if inst.hostile then
				inst.canfatigue = true
				inst.nostalkcd = false
				inst.canstalk = true
				inst.canslam = false
				inst.canwakeuphit = false
			end
		end,
	},
	[3] = {
		hp = 0.5,
		fn = function(inst)
			if inst.hostile then
				inst.canfatigue = true
				inst.nostalkcd = true
				inst.canstalk = true
				inst.canslam = true
				inst.canwakeuphit = false
				inst.components.timer:StopTimer("stalk_cd")
			end
		end,
	},
	[4] = {
		hp = 0.3,
		fn = function(inst)
			if inst.hostile then
				inst.canfatigue = true
				inst.nostalkcd = false
				inst.canstalk = true
				inst.canslam = true
				inst.canwakeuphit = true
			end
		end,
	},
}

--------------------------------------------------------------------------

local function UpdatePlayerTargets(inst)
	local toadd = {}
	local toremove = {}
	local x, y, z = inst.Transform:GetWorldPosition()

	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		toremove[k] = true
	end
	for i, v in ipairs(FindPlayersInRange(x, y, z, TUNING.DAYWALKER_DEAGGRO_DIST, true)) do
		if toremove[v] then
			toremove[v] = nil
		else
			table.insert(toadd, v)
		end
	end

	for k in pairs(toremove) do
		inst.components.grouptargeter:RemoveTarget(k)
	end
	for i, v in ipairs(toadd) do
		inst.components.grouptargeter:AddTarget(v)
	end
end

local function RetargetFn(inst)
	UpdatePlayerTargets(inst)

	local target = inst.components.combat.target
	local inrange = target ~= nil and inst:IsNear(target, TUNING.DAYWALKER_ATTACK_RANGE + target:GetPhysicsRadius(0))

	if target ~= nil and target:HasTag("player") then
		local newplayer = inst.components.grouptargeter:TryGetNewTarget()
		return newplayer ~= nil
			and newplayer:IsNear(inst, inrange and TUNING.DAYWALKER_ATTACK_RANGE + newplayer:GetPhysicsRadius(0) or TUNING.DAYWALKER_KEEP_AGGRO_DIST)
			and newplayer
			or nil,
			true
	end

	local nearplayers = {}
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		if inst:IsNear(k, inrange and TUNING.DAYWALKER_ATTACK_RANGE + k:GetPhysicsRadius(0) or TUNING.DAYWALKER_AGGRO_DIST) then
			table.insert(nearplayers, k)
		end
	end
	return #nearplayers > 0 and nearplayers[math.random(#nearplayers)] or nil, true
end

local function KeepTargetFn(inst, target)
	return not inst.defeated
		and inst.components.combat:CanTarget(target)
		and target:IsNear(inst, TUNING.DAYWALKER_DEAGGRO_DIST)
end

local function OnAttacked(inst, data)
	if data.attacker ~= nil then
		local target = inst.components.combat.target
		if not (target ~= nil and
			target:HasTag("player") and
			target:IsNear(inst, TUNING.DAYWALKER_ATTACK_RANGE + target:GetPhysicsRadius(0))) then
			inst.components.combat:SetTarget(data.attacker)
		end
	end
end

local function OnNewTarget(inst, data)
	if data.target ~= nil then
		inst:SetEngaged(true)
		if inst.canstalk and inst:IsStalking() then
			inst:SetStalking(data.target)
		end
	end
end

local function SetEngaged(inst, engaged)
	if inst.engaged ~= engaged and (engaged ~= nil) == inst.hostile then
		inst.engaged = engaged
		if engaged then
			inst.components.health:StopRegen()
			inst:StartAttackCooldown()
			if not inst.components.timer:TimerExists("roar_cd") then
				inst:PushEvent("roar", { target = inst.components.combat.target })
			end
		else
			inst:SetStalking(nil)
			if engaged == false then
				inst.components.health:StartRegen(TUNING.DAYWALKER_HEALTH_REGEN, 1)
			else--if engaged == nil then
				inst.components.health:StopRegen()
			end
			inst.components.combat:ResetCooldown()
			inst.components.combat:DropTarget()
		end
	end
end

local function StartAttackCooldown(inst)
	inst.components.combat:SetAttackPeriod(GetRandomMinMax(TUNING.DAYWALKER_ATTACK_PERIOD.min, TUNING.DAYWALKER_ATTACK_PERIOD.max))
	inst.components.combat:RestartCooldown()
end

local function OnMinHealth(inst)
	if not POPULATING then
		inst:MakeDefeated()
	end
end

local function OnDespawnTimer(inst, data)
	if data ~= nil and data.name == "despawn" then
		if inst:IsAsleep() then
			inst:Remove()
		else
			inst.components.talker:IgnoreAll("despawn")
			inst.components.despawnfader:FadeOut()
			inst.DynamicShadow:Enable(false)
		end
	end
end

--------------------------------------------------------------------------

local function RegenFatigue(inst)
	inst.fatigue = inst.fatigue - TUNING.DAYWALKER_FATIGUE_REGEN
	if inst.fatigue <= 0 then
		inst.fatigue = 0
		inst._fatiguetask:Cancel()
		inst._fatiguetask = nil
	end
end

local function DeltaFatigue(inst, fatigue)
	if inst.canfatigue then
		inst.fatigue = math.max(0, inst.fatigue + fatigue)
		if inst._fatiguetask ~= nil then
			inst._fatiguetask:Cancel()
		end
		inst._fatiguetask = inst.fatigue > 0 and inst:DoPeriodicTask(TUNING.DAYWALKER_FATIGUE_REGEN_PERIOD, RegenFatigue, fatigue >= 0 and TUNING.DAYWALKER_FATIGUE_REGEN_START_PERIOD or nil) or nil
	end
end

local function ResetFatigue(inst)
	inst.fatigue = 0
	if inst._fatiguetask ~= nil then
		inst._fatiguetask:Cancel()
		inst._fatiguetask = nil
	end
end

local function IsFatigued(inst)
	return inst.fatigue >= TUNING.DAYWALKER_FATIGUE_TIRED
end

--------------------------------------------------------------------------

local function MakeChained(inst)
	if not (inst.chained or inst.defeated) then
		inst.chained = true
		inst.hostile = false
		inst.sg:GoToState("transition")
		inst:RemoveEventCallback("attacked", OnAttacked)
		inst:RemoveEventCallback("newcombattarget", OnNewTarget)
		inst:RemoveEventCallback("minhealth", OnMinHealth)
		inst.components.timer:StopTimer("despawn")
		inst.components.combat:DropTarget()
		inst.components.combat:SetRetargetFunction(nil)
		inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_STRUGGLE_DAMAGE)
		inst.components.talker:ShutUp()
		inst.components.locomotor:Stop()
		inst.components.health:SetCurrentHealth(inst.components.health.minhealth)
		inst.components.health:SetInvincible(true)
		inst.components.sanityaura.aura = -TUNING.SANITYAURA_LARGE
		inst:RemoveTag("hostile")
		inst:AddTag("notarget")
		inst:AddTag("noteleport")
		inst.AnimState:OverrideSymbol("chain_set", "daywalker_pillar", "chain_set")
		inst.AnimState:OverrideSymbol("chain_set_break", "daywalker_pillar", "chain_set_break")
		inst:SwitchToFacingModel(0) --inst.Transform:SetNoFaced()
		inst.SoundEmitter:PlaySound("daywalker/pillar/chain_idle", "chainloop")
		ChangeToObstaclePhysics(inst)
		EnableChains(inst, true)
		PHASES[0].fn(inst)
		inst:SetBrain(nil)
		inst:SetHeadTracking(false)
		inst:SetStalking(nil)
		inst:SetEngaged(nil)
		inst:SetStateGraph("SGdaywalker_imprisoned")

		local x, y, z = inst.Transform:GetWorldPosition()
		inst.components.knownlocations:RememberLocation("prison", Vector3(x, 0, z), false)
	end
end

local function MakeUnchained(inst)
	if inst.chained then
		inst.chained = nil
		inst.sg:GoToState("transition")
		inst:ListenForEvent("attacked", OnAttacked)
		inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_STRUGGLE_DAMAGE)
		inst.components.talker:ShutUp()
		inst.components.health:SetInvincible(false)
		inst.components.sanityaura.aura = -TUNING.SANITYAURA_SUPERHUGE
		inst:RemoveTag("notarget")
		inst:RemoveTag("noteleport")
		--inst:AddTag("hostile")
		inst.AnimState:ClearAllOverrideSymbols()
		inst:SwitchToFacingModel(4) --inst.Transform:SetFourFaced()
		inst.SoundEmitter:KillSound("chainloop")
		ChangeToGiantCharacterPhysics(inst, MASS)
		EnableChains(inst, false)
		inst:SetStateGraph("SGdaywalker")
		inst.sg:GoToState("tired")
	end
end

local function MakeHarassed(inst)
	if not (inst.chained or inst.defeated) and inst.hostile then
		inst.hostile = false
		inst:RemoveEventCallback("newcombattarget", OnNewTarget)
		inst:RemoveEventCallback("minhealth", OnMinHealth)
		inst.components.timer:StopTimer("despawn")
		inst.components.combat:DropTarget()
		inst.components.combat:SetRetargetFunction(nil)
		inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_STRUGGLE_DAMAGE)
		inst.components.sanityaura.aura = -TUNING.SANITYAURA_SUPERHUGE
		inst:RemoveTag("hostile")
		inst:SetBrain(nil)
		inst:SetHeadTracking(false)
		inst:SetStalking(nil)
		inst:SetEngaged(nil)
	end
end

local function MakeHostile(inst)
	if not (inst.chained or inst.defeated or inst.hostile) then
		inst.hostile = true
		inst:ListenForEvent("newcombattarget", OnNewTarget)
		inst:ListenForEvent("minhealth", OnMinHealth)
		inst.components.timer:StopTimer("despawn")
		inst.components.combat:SetRetargetFunction(3, RetargetFn)
		inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_DAMAGE)
		inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
		inst:AddTag("hostile")
		if not inst.components.health:IsHurt() then
			PHASES[0].fn(inst)
		end
		inst:SetBrain(brain)
		if inst.brain == nil and not inst:IsAsleep() then
			inst:RestartBrain()
		end
		inst:SetEngaged(inst.components.combat:HasTarget())
	end
end

local function MakeDefeated(inst)
	if not (inst.chained or inst.defated) and inst.hostile then
		inst.defeated = true
		inst.hostile = false
		inst:RemoveEventCallback("attacked", OnAttacked)
		inst:RemoveEventCallback("newcombattarget", OnNewTarget)
		inst:RemoveEventCallback("minhealth", OnMinHealth)
		inst:ListenForEvent("timerdone", OnDespawnTimer)
		if not inst.components.timer:TimerExists("despawn") then
			inst.components.timer:StartTimer("despawn", DESPAWN_TIME, not inst.looted)
		end
		inst.components.combat:DropTarget()
		inst.components.combat:SetRetargetFunction(nil)
		inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
		inst:RemoveTag("hostile")
		inst:SetBrain(nil)
		inst:SetHeadTracking(false)
		inst:SetStalking(nil)
		inst:SetEngaged(nil)
	end
end

--------------------------------------------------------------------------

local function GetStatus(inst)
	return inst.chained and "IMPRISONED" or nil
end

local function OnSave(inst, data)
	data.hostile = inst.hostile or nil
	data.looted = inst.looted or nil
end

local function OnLoad(inst, data)
	local healthpct = inst.components.health:GetPercent()
	for i = #PHASES, 1, -1 do
		local v = PHASES[i]
		if healthpct <= v.hp then
			v.fn(inst)
			break
		end
	end

	if inst.components.timer:TimerExists("despawn") then
		inst:MakeDefeated()
		if data ~= nil and data.looted then
			inst.looted = true
			inst.sg:GoToState("defeat_idle_pre")
		else
			inst.components.timer:PauseTimer("despawn")
			inst.components.timer:SetTimeLeft("despawn", DESPAWN_TIME)
			inst.sg:GoToState("defeat")
		end
	end
end

local function OnLoadPostPass(inst, ents, data)
	local harassed = false
	for i, v in ipairs(ATTACH_POS) do
		local ent = inst.components.entitytracker:GetEntity(v)
		if ent ~= nil then
			SetLeechAttached(inst, ent, v)
			harassed = true
		end
	end
	if not inst.chained then
		if harassed then
			inst:MakeHarassed()
			inst.sg:GoToState("struggle_idle")
		elseif not (data ~= nil and data.hostile or inst.defeated) then
			inst:MakeHarassed()
			inst.sg:GoToState("tired")
		end
	end
end

local function OnEntitySleep(inst)
	if inst.chains ~= nil and inst._chainsleeptask == nil then
		inst._chainsleeptask = inst:DoTaskInTime(1, OnChainSleepTask)
	end
	if inst.looted then
		if inst._despawntask == nil then
			inst._despawntask = inst:DoTaskInTime(1, inst.Remove)
		end
	elseif inst.hostile then
		inst:SetEngaged(false)
	end
end

local function OnEntityWake(inst)
	if inst._chainsleeptask ~= nil then
		inst._chainsleeptask:Cancel()
		inst._chainsleeptask = nil
	elseif inst._enablechains:value() and not TheNet:IsDedicated() then
		SpawnChains(inst)
	end
	if inst._despawntask ~= nil then
		inst._despawntask:Cancel()
		inst._despawntask = nil
	end
end

local function OnTalk(inst)
	if not inst.sg:HasStateTag("notalksound") then
		inst.SoundEmitter:PlaySound("daywalker/voice/speak_short")
	end
end

local function teleport_override_fn(inst)
	if not inst.hostile then
		--Stay within prison; or, backup is just don't go too far
		local pos = inst.components.knownlocations:GetLocation("prison") or inst:GetPosition()
		local offset = FindWalkableOffset(pos, TWOPI * math.random(), 4, 8, true, false)
		return offset ~= nil and pos + offset or pos
	end

	--Go back to prison if it is still there, otherwise anywhere (return nil for default behvaiour)
	local pos = inst.components.knownlocations:GetLocation("prison")
	if pos ~= nil then
		local offset = FindWalkableOffset(pos, TWOPI * math.random(), 4, 8, true, false)
		return offset ~= nil and pos + offset or pos
	end
end

--------------------------------------------------------------------------

local function PushMusic(inst)
	if ThePlayer == nil or not inst:HasTag("hostile") then
		inst._playingmusic = false
	elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
		inst._playingmusic = true
		ThePlayer:PushEvent("triggeredevent", { name = "daywalker" })
	elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
		inst._playingmusic = false
	end
end

--------------------------------------------------------------------------

local function LootSetupFn(lootdropper)
	lootdropper:SetLoot(lootdropper.inst.components.knownlocations:GetLocation("prison") == nil and BONUS_PILLAR_LOOT or nil)
	lootdropper:SetChanceLootTable("daywalker")
end

--------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

	inst.Transform:SetFourFaced()
	--inst.Transform:SetSixFaced() --V2C: TwoFaced has a built in rot offset hack for stationary objects
	MakeGiantCharacterPhysics(inst, MASS, 1.3)

	inst:AddTag("epic")
	inst:AddTag("noepicmusic")
	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("scarytoprey")
	inst:AddTag("largecreature")
	inst:AddTag("shadow_aligned")

	inst.AnimState:SetBank("daywalker")
	inst.AnimState:SetBuild("daywalker_build")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:Hide("ARM_CARRY")
	inst.AnimState:SetSymbolLightOverride("ww_armlower_red", .6)
	inst.AnimState:SetSymbolLightOverride("flake", .6)
	inst.scrapbook_anim = "scrapbook"

	inst.DynamicShadow:SetSize(3.5, 1.5)

	local talker = inst:AddComponent("talker")
	talker.fontsize = 40
	talker.font = TALKINGFONT
	talker.colour = Vector3(238 / 255, 69 / 255, 105 / 255)
	talker.offset = Vector3(0, -400, 0)
	talker.symbol = "ww_hunch"
	talker.name_colour = Vector3(159/256, 72/256, 93/256)
	talker.chaticon = "npcchatflair_daywalker"
	talker:MakeChatter()

	inst._enablechains = net_bool(inst.GUID, "daywalker._enablechains", "chainsdirty")
	inst._facingmodel = net_tinybyte(inst.GUID, "daywalker._facingmodel", "facingmodeldirty")
	inst._headtracking = net_bool(inst.GUID, "daywalker._headtracking", "headtrackingdirty")
	inst._stalking = net_entity(inst.GUID, "daywalker._stalking", "stalkingdirty")

	inst:AddComponent("despawnfader")

	inst.entity:SetPristine()

	--Dedicated server does not need to trigger music
	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst._playingmusic = false
		inst:DoPeriodicTask(1, PushMusic, 0)

		inst.eye = CreateEyeFlame()
		inst.eye.entity:SetParent(inst.entity)
		inst.eye.Follower:FollowSymbol(inst.GUID, "follow_eye", nil, nil, nil, true)
	end

	if not TheWorld.ismastersim then
		inst:ListenForEvent("chainsdirty", OnChainsDirty)
		inst:ListenForEvent("facingmodeldirty", OnFacingModelDirty)
		inst:ListenForEvent("headtrackingdirty", OnHeadTrackingDirty)

		return inst
	end

	inst.footstep = "daywalker/action/step"

	inst.components.talker.ontalk = OnTalk

	inst:AddComponent("entitytracker")

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.DAYWALKER_WALKSPEED
	inst.components.locomotor.runspeed = TUNING.DAYWALKER_RUNSPEED

	inst:AddComponent("health")
	inst.components.health:SetMinHealth(1)
	inst.components.health:SetMaxHealth(TUNING.DAYWALKER_HEALTH)
	--inst.components.health.nofadeout = true

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_DAMAGE)
	inst.components.combat:SetAttackPeriod(TUNING.DAYWALKER_ATTACK_PERIOD.min)
	inst.components.combat.playerdamagepercent = .5
	inst.components.combat:SetRange(TUNING.DAYWALKER_ATTACK_RANGE)
	inst.components.combat:SetRetargetFunction(3, RetargetFn)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	inst.components.combat.hiteffectsymbol = "ww_body"
	inst.components.combat.battlecryenabled = false
	inst.components.combat.forcefacing = false

	inst:AddComponent("healthtrigger")
	for i, v in pairs(PHASES) do
		inst.components.healthtrigger:AddTrigger(v.hp, v.fn)
	end

	inst:AddComponent("knownlocations")
	inst:AddComponent("grouptargeter")
	inst:AddComponent("timer")
	inst:AddComponent("explosiveresist")

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE

	inst:AddComponent("epicscare")
	inst.components.epicscare:SetRange(TUNING.DAYWALKER_EPICSCARE_RANGE)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLootSetupFn(LootSetupFn)
	inst.components.lootdropper.min_speed = 1
	inst.components.lootdropper.max_speed = 3
	inst.components.lootdropper.y_speed = 14
	inst.components.lootdropper.y_speed_variance = 4
	inst.components.lootdropper.spawn_loot_inside_prefab = true

	inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)

	inst.hit_recovery = TUNING.DAYWALKER_HIT_RECOVERY

	inst._busy_attach_pos = {}
	inst._incoming_jumps = {}
	inst._leeches = {}
	inst._onremoveleech = function(leech) inst._leeches[leech] = nil end

	inst:ListenForEvent("incoming_jump", OnIncomingJump)
	inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("newcombattarget", OnNewTarget)
	inst:ListenForEvent("minhealth", OnMinHealth)
	inst:ListenForEvent("pillarremoved", OnPillarRemoved)

	inst.chained = false
	inst.hostile = true
	inst.engaged = nil
	inst.defeated = false
	inst.looted = false
	inst.fatigue = 0
	inst._fatiguetask = nil

	--ability unlocks
	inst.canfatigue = false
	inst.nostalkcd = true
	inst.canstalk = true
	inst.canslam = false
	inst.canwakeuphit = false

	inst._onremovestalking = function(stalking) inst._stalking:set(nil) end

	inst.SwitchToFacingModel = SwitchToFacingModel
	inst.MakeChained = MakeChained
	inst.MakeUnchained = MakeUnchained
	inst.MakeHarassed = MakeHarassed
	inst.MakeHostile = MakeHostile
	inst.MakeDefeated = MakeDefeated
	inst.SetEngaged = SetEngaged
	inst.StartAttackCooldown = StartAttackCooldown
	inst.SetHeadTracking = SetHeadTracking
	inst.SetStalking = SetStalking
	inst.GetStalking = GetStalking
	inst.IsStalking = IsStalking
	inst.DeltaFatigue = DeltaFatigue
	inst.ResetFatigue = ResetFatigue
	inst.IsFatigued = IsFatigued
	inst.CountPillars = CountPillars
	inst.HasLeechAttached = HasLeechAttached
	inst.HasLeechTracked = HasLeechTracked
	inst.AttachLeech = AttachLeech
	inst.DetachLeech = DetachLeech
	inst.OnAttachmentInterrupted = OnAttachmentInterrupted
	inst.StartTrackingLeech = StartTrackingLeech
	inst.SpawnLeeches = SpawnLeeches
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnLoadPostPass = OnLoadPostPass
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

	inst:SetStateGraph("SGdaywalker")
	inst:SetBrain(brain)
	inst:SetEngaged(false)

	return inst
end

return Prefab("daywalker", fn, assets, prefabs)
