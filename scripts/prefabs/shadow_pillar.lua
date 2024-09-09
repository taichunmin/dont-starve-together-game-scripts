local assets =
{
	Asset("ANIM", "anim/shadow_pillar.zip"),
}

local assets_base =
{
	Asset("ANIM", "anim/shadow_pillar_fx.zip"),
	Asset("ANIM", "anim/splash_weregoose_fx.zip"),
	Asset("ANIM", "anim/splash_water_drop.zip"),
}

local prefabs =
{
	"sanity_raise",
	"sanity_lower",
	"shadow_pillar_base_fx",
	"ocean_splash_med1",
	"ocean_splash_med2",
}

local prefabs_spell =
{
	"shadow_pillar",
	"shadow_pillar_target",
	"shadow_glob_fx",
}

--------------------------------------------------------------------------

local WARNING_TIME = 2.5

local function CalcTargetDuration(target)
	return target ~= nil and (
			(target:HasTag("epic") and TUNING.SHADOW_PILLAR_DURATION_BOSS) or
			(target:HasTag("player") and TUNING.SHADOW_PILLAR_DURATION_PLAYER)
		) or TUNING.SHADOW_PILLAR_DURATION
end

--------------------------------------------------------------------------
--"shadow_pillar" is a purely visual FX spawned surrounding the target

local NUM_VARIATIONS = 6
local VARIATIONS_POOL = {}
for i = 1, NUM_VARIATIONS do
	table.insert(VARIATIONS_POOL, math.random(#VARIATIONS_POOL + 1), i)
end
local function GetNextVariation()
	local rnd = math.random()
	--higher chance to pick first entry, no chance to pick last entry
	rnd = math.floor(rnd * rnd * (NUM_VARIATIONS - 1)) + 1
	rnd = table.remove(VARIATIONS_POOL, rnd)
	table.insert(VARIATIONS_POOL, rnd)
	return rnd
end

local LAST_FLIPPED = false
local function GetNextFlipped()
	if math.random() < .65 then
		LAST_FLIPPED = not LAST_FLIPPED
	end
	return LAST_FLIPPED
end

local function DoSplash(inst)
	if TheWorld.Map:IsOceanAtPoint(inst.Transform:GetWorldPosition()) then
		SpawnPrefab("ocean_splash_med"..tostring(math.random(2))).Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

local function DoRaise(inst)
	inst._delayraisetask = nil
	inst.variation = GetNextVariation()
	if GetNextFlipped() then
		inst.flipped = true
		inst.AnimState:SetScale(-1, 1, 1)
	end
	inst.AnimState:PlayAnimation("pre"..tostring(inst.variation))
	--inst.SoundEmitter:PlaySound("maxwell_rework/shadow_pillar/pre")
	inst.AnimState:PushAnimation("idle"..tostring(inst.variation))
	DoSplash(inst)
end

local function DoLower(inst)
	inst.AnimState:PlayAnimation("pst"..tostring(inst.variation))
	inst.SoundEmitter:KillSound("rumble")
	inst:SetTarget(nil)
	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)
	if inst.base ~= nil then
		inst.base:DoTaskInTime(2 * FRAMES, inst.base.KillFX)
	end
	inst:DoTaskInTime(10 * FRAMES, DoSplash)
end

local function Pillar_OnDispell(inst)
	if inst._delayraisetask ~= nil or inst.components.timer:TimerExists("delay") then
		inst:Remove()
	else
		inst.components.timer:StopTimer("lifetime")
		inst.components.timer:StopTimer("warningtime")
		DoLower(inst)
	end
end

local function Pillar_OnTargetRemoved(inst)
	if inst._delayraisetask ~= nil or inst.components.timer:TimerExists("delay") then
		inst:Remove()
	else
		inst.components.timer:StopTimer("warningtime")
		if inst.components.timer:TimerExists("lifetime") then
			inst.components.timer:SetTimeLeft("lifetime", math.random())
		else
			--fallback? shouldn't reach here
			DoLower(inst)
		end
	end
end

local function PreRaise(inst)
	inst._delayraisetask = inst:DoTaskInTime(7 * FRAMES, DoRaise)
	if inst.base == nil then
		inst.base = SpawnPrefab("shadow_pillar_base_fx")
		inst.base.entity:SetParent(inst.entity)
		inst.base.Transform:SetRotation(math.random() * 360)
	end
end

local PILLAR_TAGS = { "shadow_pillar" }
local function Pillar_OnTimerDone(inst, data)
	if data ~= nil then
		if data.name == "delay" then
			inst._delayraisetask = inst:DoTaskInTime(8 * FRAMES, PreRaise)
			inst.SoundEmitter:PlaySound("maxwell_rework/shadow_pillar/pre")
			SpawnPrefab("sanity_raise").Transform:SetPosition(inst.Transform:GetWorldPosition())

			local x, y, z = inst.Transform:GetWorldPosition()
			local overlaps = TheSim:FindEntities(x, 0, z, .9, PILLAR_TAGS)
			for _, v in ipairs(overlaps) do
				if v ~= inst and v.persists then
					Pillar_OnDispell(v)
				end
			end

			local t = CalcTargetDuration(inst.components.entitytracker:GetEntity("target"))
			inst.components.timer:StartTimer("lifetime", t)
			inst.components.timer:StartTimer("warningtime", math.max(0, t - WARNING_TIME))

		elseif data.name == "warningtime" then
			inst.AnimState:PlayAnimation("shake"..tostring(inst.variation), true)
			inst.SoundEmitter:PlaySound("maxwell_rework/shadow_pillar/rumble", "rumble")

		elseif data.name == "lifetime" then
			if inst._delayraisetask ~= nil then
				inst:Remove()
			else
				inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_down")
				SpawnPrefab("sanity_lower").Transform:SetPosition(inst.Transform:GetWorldPosition())
				DoLower(inst)
			end
		end
	end
end

local function Pillar_SetDelay(inst, delay)
	if inst.components.timer:TimerExists("delay") then
		inst.components.timer:StopTimer("delay")
		inst.components.timer:StartTimer("delay", delay)
	end
end

local function Pillar_OnSetTarget(inst, target)
	inst._ondispell = function() Pillar_OnDispell(inst) end
	inst._ontargetdeath = function()
		inst.components.timer:StopTimer("warningtime")
	end
	inst._ontargetremoved = function() Pillar_OnTargetRemoved(inst) end
	inst._reducetime = function(target, dt)
		local t = inst.components.timer:GetTimeLeft("lifetime")
		if t ~= nil then
			t = math.max(0, t - dt)
			inst.components.timer:SetTimeLeft("lifetime", t)
			if t > 0 then
				t = inst.components.timer:GetTimeLeft("warningtime")
				if t ~= nil then
					inst.components.timer:SetTimeLeft("warningtime", math.max(0, t - dt))
				end
			else
				inst.components.timer:StopTimer("warningtime")
			end
		end
	end
	inst:ListenForEvent("dispell_shadow_pillars", inst._ondispell, target)
	inst:ListenForEvent("death", inst._ontargetdeath, target)
	inst:ListenForEvent("onremove", inst._ontargetremoved, target)
	inst:ListenForEvent("remove_shadow_pillars", inst._ontargetremoved, target)
	inst:ListenForEvent("reduce_shadow_pillars_time", inst._reducetime, target)
end

local function Pillar_SetTarget(inst, target, hasplatform)
	local oldtarget = inst.components.entitytracker:GetEntity("target")
	if oldtarget ~= nil then
		if inst._ondispell ~= nil then
			inst:RemoveEventCallback("dispell_shadow_pillars", inst._ondispell, oldtarget)
			inst._ondispell = nil
		end
		if inst._ontargetdeath ~= nil then
			inst:RemoveEventCallback("death", inst._ontargetdeath, oldtarget)
			inst._ontargetdeath = nil
		end
		if inst._ontargetremoved ~= nil then
			inst:RemoveEventCallback("onremove", inst._ontargetremoved, oldtarget)
			inst:RemoveEventCallback("remove_shadow_pillars", inst._ontargetremoved, oldtarget)
			inst._ontargetremoved = nil
		end
		if inst._reducetime ~= nil then
			inst:RemoveEventCallback("reduce_shadow_pillars_time", inst._reducetime, target)
			inst._reducetime = nil
		end
		inst.components.entitytracker:ForgetEntity("target")
	end
	if target ~= nil then
		inst.components.entitytracker:TrackEntity("target", target)
		Pillar_OnSetTarget(inst, target)
		if hasplatform then
			inst:RemoveTag("ignorewalkableplatforms")
		else
			inst:AddTag("ignorewalkableplatforms")
		end
	end
end

local function Pillar_OnSave(inst, data)
	data.variation = inst.variation ~= 1 and inst.variation or nil
	data.flipped = inst.flipped or nil
	data.hasplatform = not inst:HasTag("ignorewalkableplatforms") or nil
end

local function Pillar_OnLoad(inst, data)
	if inst.components.timer:TimerExists("lifetime") then
		inst.components.timer:StopTimer("delay")
		inst.variation = data ~= nil and data.variation or 1
		if data ~= nil and data.flipped then
			inst.flipped = true
			inst.AnimState:SetScale(-1, 1, 1)
		end
		--base pre is 24 * FRAMES
		--pillar pre is 24 * FRAMES
		--pillar pre is delayed 7 * FRAMES
		inst.AnimState:PlayAnimation("idle"..tostring(inst.variation), true)
		local fr = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1
		inst.AnimState:SetFrame(fr)
		if inst.base == nil then
			inst.base = SpawnPrefab("shadow_pillar_base_fx")
			inst.base.entity:SetParent(inst.entity)
			inst.base.Transform:SetRotation(math.random() * 360)
		end
		inst.base.AnimState:PlayAnimation("idle", true)
		inst.base.AnimState:SetFrame(fr + 7)
		if not inst.components.timer:TimerExists("warningtime") then
			local target = inst.components.entitytracker:GetEntity("target")
			if target ~= nil and not (target.components.health ~= nil and target.components.health:IsDead()) then
				inst.components.timer:StartTimer("warningtime", 0)
			end
		end
	elseif not inst.components.timer:TimerExists("delay") then
		--bad save data
		inst.persists = false
		inst:DoTaskInTime(0, inst.Remove)
	end
end

local function Pillar_OnLoadPostPass(inst, ents, data)
	local target = inst.components.entitytracker:GetEntity("target")
	if target ~= nil then
		Pillar_OnSetTarget(inst, target)
	end
	if data ~= nil and data.hasplatform then
		inst:RemoveTag("ignorewalkableplatforms")
	end
end

local function pillar_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	--Not fx, otherwise walkableplatform can't detect
	--inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("shadow_pillar")
	inst:AddTag("ignorewalkableplatforms")
	inst:AddTag("ignorewalkableplatformdrowning")

	inst.AnimState:SetBank("shadow_pillar")
	inst.AnimState:SetBuild("shadow_pillar")
	inst.AnimState:SetSymbolMultColour("shad_spot2", 1, 1, 1, .75)
	inst.AnimState:SetSymbolMultColour("shadow2", 1, 1, 1, .75)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("entitytracker")

	inst:AddComponent("timer")
	inst.components.timer:StartTimer("delay", 0)

	inst:ListenForEvent("timerdone", Pillar_OnTimerDone)
	inst:ListenForEvent("onsink", Pillar_OnDispell)

	inst.SetDelay = Pillar_SetDelay
	inst.SetTarget = Pillar_SetTarget
	inst.OnSave = Pillar_OnSave
	inst.OnLoad = Pillar_OnLoad
	inst.OnLoadPostPass = Pillar_OnLoadPostPass

	return inst
end

--------------------------------------------------------------------------

local function CreateRipples()
	local inst = CreateEntity()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("splash_weregoose_fx")
	inst.AnimState:SetBuild("splash_water_drop")
	inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
	inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

	return inst
end

local function DoRipple(inst, ripples, map, x, z)
	if inst.AnimState:IsCurrentAnimation("idle") and map:GetPlatformAtPoint(x, z) == nil then
		ripples.AnimState:PlayAnimation(math.random() < .5 and "no_splash" or "no_splash2")
	end
end

local function TryRipples(inst)
	local parent = inst.entity:GetParent()
	if parent ~= nil and parent:HasTag("ignorewalkableplatforms") then
		--Now we know we won't ever attach to boats.
		local x, y, z = inst.Transform:GetWorldPosition()
		local map = TheWorld.Map
		--Start ripples task whether we are over boat or not, as long as in water.
		--Check for boat each pulse instead, since we don't move but boats can move over or away from us.
		if map:IsOceanAtPoint(x, y, z, true) then
			local ripples = CreateRipples()
			ripples.entity:SetParent(inst.entity)
			inst:DoPeriodicTask(1, DoRipple, 0, ripples, map, x, z)
		end
	end
end

local function Base_KillFX(inst)
	inst.AnimState:PlayAnimation("pst")
	inst:ListenForEvent("animover", inst.Remove)
end

local function base_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("shadow_pillar_fx")
	inst.AnimState:SetBuild("shadow_pillar_fx")
	inst.AnimState:PlayAnimation("pre")
	inst.AnimState:SetMultColour(1, 1, 1, .6)
	inst.AnimState:UsePointFiltering(true)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst:DoTaskInTime(1, TryRipples)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.AnimState:PushAnimation("idle")

	inst.KillFX = Base_KillFX
	inst.persists = false

	return inst
end

--------------------------------------------------------------------------
--"shadow_pillar_target" is a hidden entity that temporarily forces target's
--physics to behave as if its mass were 0.

local function Target_OnTimerDone(inst, data)
	if data ~= nil then
		if data.name == "delay" then
			local target = inst.components.entitytracker:GetEntity("target")
			if target ~= nil then
				inst.components.timer:StartTimer("lifetime", CalcTargetDuration(target))
			else
				inst:Remove()
			end
		elseif data.name == "lifetime" then
			inst:Remove()
		end
	end
end

local function Target_SetDelay(inst, delay)
	if inst.components.timer:TimerExists("delay") then
		inst.components.timer:StopTimer("delay")
		inst.components.timer:StartTimer("delay", delay)
	end
end

local MOVED_DIST_SQ = .5 * .5
local UPDATE_PERIOD = 1
local MAX_PLAYERS_CAP = 4 --maximum prison break speed at 4+ players
local function Target_Update(inst, x, z, target, attackers)
	--Backup test just in case, for weird boat physics or any forced teleporting
	if target:GetDistanceSqToPoint(x, 0, z) > MOVED_DIST_SQ then
		target:PushEvent("remove_shadow_pillars")
		inst:Remove()
		return
	end

	--Reduce timers based on how many unique player attackers
	local t = inst.components.timer:GetTimeLeft("lifetime")
	if t == nil then
		return
	end
	local count = 0
	local countothers = attackers.other and 1 or 0
	attackers.other = nil
	for k, v in pairs(attackers) do
		attackers[k] = nil
		count = count + 1
	end
	count = math.max(count, countothers)
	if count > 0 then
		--calculate the prison break speed mult first
		local dt = Remap(math.min(count, MAX_PLAYERS_CAP), 1, MAX_PLAYERS_CAP, 0, 1)
		dt = Lerp(TUNING.SHADOW_PILLAR_BREAK_MULT.MIN, TUNING.SHADOW_PILLAR_BREAK_MULT.MAX, dt)
		if dt > 1 then --greater than normal (1x) speed
			dt = UPDATE_PERIOD * (dt - 1) --convert to additional dt to advance timers
			if t < dt then
				target:PushEvent("remove_shadow_pillars")
				inst:Remove()
				return
			end
			inst.components.timer:SetTimeLeft("lifetime", t - dt)
			target:PushEvent("reduce_shadow_pillars_time", dt)
		end
	end
end

local function Target_OnSetTarget(inst, target)
	if target.components.rooted == nil then
		target:AddComponent("rooted")
	end
	target.components.rooted:AddSource(inst)

	local function onremovetarget() inst:Remove() end
	inst:ListenForEvent("onremove", onremovetarget, target)
	inst:ListenForEvent("death", onremovetarget, target)
	inst:ListenForEvent("enterlimbo", onremovetarget, target)
	inst:ListenForEvent("teleported", onremovetarget, target)
	inst:ListenForEvent("dispell_shadow_pillars", onremovetarget, target)

	if target.sg ~= nil then
		inst:ListenForEvent("newstate", function(target)
			if target.sg ~= nil and target.sg:HasStateTag("flight") then
				inst:Remove()
			end
		end, target)
	end

	local attackers = {}
	local function ontargetattacked(target, data)
		local attacker = data ~= nil and data.attacker or nil
		if attacker ~= nil then
			if attacker.components.follower ~= nil then
				attacker = attacker.components.follower:GetLeader() or attacker
			end
			if not attacker:HasTag("player") then
				attacker = nil
			end
		end
		attackers[attacker or "other"] = true
	end
	inst:ListenForEvent("attacked", ontargetattacked, target)
	inst:ListenForEvent("blocked", ontargetattacked, target)

	local x, y, z = inst.Transform:GetWorldPosition()
	inst:DoPeriodicTask(UPDATE_PERIOD, Target_Update, nil, x, z, target, attackers)
end

local function Target_DoShake(inst, radius)
	ShakeAllCameras(CAMERASHAKE.VERTICAL, 1, .025, .075, inst, 12 + radius)
end

local function Target_SetTarget(inst, target, radius, hasplatform)
	if target ~= nil then
		inst.components.entitytracker:TrackEntity("target", target)
		Target_OnSetTarget(inst, target)
		if hasplatform then
			inst:RemoveTag("ignorewalkableplatforms")
		end
		inst:DoTaskInTime(14 * FRAMES, Target_DoShake, radius) --doesn't save/load
	end
end

local function Target_OnSave(inst, data)
	data.hasplatform = not inst:HasTag("ignorewalkableplatforms") or nil
end

local function Target_OnLoad(inst)
	if inst.components.timer:TimerExists("lifetime") then
		inst.components.timer:StopTimer("delay")
	elseif not inst.components.timer:TimerExists("delay") then
		--bad save data
		inst.persists = false
		inst:DoTaskInTime(0, inst.Remove)
	end
end

local function Target_OnLoadPostPass(inst, ents, data)
	local target = inst.components.entitytracker:GetEntity("target")
	if target ~= nil and (inst.components.timer:TimerExists("lifetime") or inst.components.timer:TimerExists("delay")) then
		Target_OnSetTarget(inst, target)
	else
		--bad save data
		inst.persists = false
		inst:DoTaskInTime(0, inst.Remove)
		return
	end
	if data ~= nil and data.hasplatform then
		inst:RemoveTag("ignorewalkableplatforms")
	end
end

local function target_fn()
	local inst = CreateEntity()

	--Not classified, otherwise walkableplatform can't detect
	--inst:AddTag("CLASSIFIED")
	inst:AddTag("ignorewalkableplatforms")
	--[[Non-networked entity]]

	inst.entity:AddTransform()

	inst:AddComponent("entitytracker")

	inst:AddComponent("timer")
	inst.components.timer:StartTimer("delay", 0)

	inst:ListenForEvent("timerdone", Target_OnTimerDone)

	inst.SetDelay = Target_SetDelay
	inst.SetTarget = Target_SetTarget
	inst.OnSave = Target_OnSave
	inst.OnLoad = Target_OnLoad
	inst.OnLoadPostPass = Target_OnLoadPostPass

	return inst
end

--------------------------------------------------------------------------
--"shadow_pillar_spell" is a hidden entity that finds valid targets in an
--area for spawning "shadow_pillar_target" and "shadow_pillar" entities

local TRAIL_TAGS = { "shadowtrail" }
local function TryFX(inst, offsets, map)
	local offs1, offs2, offs3 = unpack(offsets)
	while true do --should we limit number of tries?
		local offset = table.remove(offs1, math.random(#offs1))
		local x, y, z = inst.entity:LocalToWorldSpaceIncParent(offset:Get())
		table.insert(offs3, offset)
		if map:IsPassableAtPoint(x, 0, z, true) and not map:IsGroundTargetBlocked(Vector3(x, 0, z)) then
			if #TheSim:FindEntities(x, 0, z, .7, TRAIL_TAGS) <= 0 then
				local fx = SpawnPrefab("shadow_glob_fx")
				if map:IsOceanAtPoint(x, 0, z, true) then
					local platform = map:GetPlatformAtPoint(x, z)
					if platform ~= nil then
						fx.entity:SetParent(platform.entity)
						x, y, z = platform.entity:WorldToLocalSpace(x, 0, z)
					else
						fx:EnableRipples(true)
					end
				end
				fx.Transform:SetPosition(x, 0, z)
			end
			break
		elseif #offs1 <= 0 then
			if #offs2 > 0 then
				--Swap in page 2 offsets
				offsets[1] = offs2
				offsets[2] = offs1
				offs1 = offs2
				offs2 = offsets[2]
			else
				--Tried all offsets, none valid
				offsets[1] = offs3
				offsets[3] = offs1
				return
			end
		end
	end

	for i = 1, #offs3 do
		table.insert(offs2, offs3[i])
		offs3[i] = nil
	end
	if #offs1 <= 0 then
		offsets[1] = offs2
		offsets[2] = offs1
	end
end

local function StartFX(inst)
	local angle = math.random() * PI2
	local offsets = {}
	for i = 1, 3 do
		local radius = (i - 1) * 1.6
		local count = i > 1 and i * i - 1 or 1
		local delta = PI2 / count
		for j = 1, count do
			angle = angle + delta
			table.insert(offsets, Vector3(math.cos(angle) * radius, 0, -math.sin(angle) * radius))
		end
		angle = angle + delta * .5
	end
	inst:DoPeriodicTask(2 * FRAMES, TryFX, 0, { offsets, {}, {} }, TheWorld.Map)
end

local function IsNearOther(pt, newpillars)
	for i, v in ipairs(newpillars) do
		if distsq(pt.x, pt.z, v.x, v.z) < 1 then
			return true
		end
	end
	return false
end

local function DoPillarsTarget(target, caster, item, newpillars, map, x0, z0)
	--Dispell existing pillars first
	target:PushEvent("dispell_shadow_pillars")

	local padding =
		(target:HasTag("epic") and 1) or
		(target:HasTag("smallcreature") and 0) or
		.75
	local radius = math.max(1, target:GetPhysicsRadius(0) + padding)
	local circ = PI2 * radius
	local num = math.floor(circ / 1.4 + .5)

	local period = 1 / num
	local delays = {}
	for i = 0, num - 1 do
		table.insert(delays, i * period)
	end

	local platform = target:GetCurrentPlatform()
	local flying = not platform and target:HasTag("flying")

	local ent = SpawnPrefab("shadow_pillar_target")
	ent.Transform:SetPosition(x0, 0, z0)
	ent:SetDelay(delays[#delays]) --this just extends lifetime, spell still takes effect right away
	ent:SetTarget(target, radius, platform ~= nil)

	local theta = math.random() * PI2
	local delta = PI2 / num
	for i = 1, num do
		local pt = Vector3(x0 + math.cos(theta) * radius, 0, z0 - math.sin(theta) * radius)
		if not IsNearOther(pt, newpillars) and
			map:IsPassableAtPoint(pt.x, 0, pt.z, true) and
			flying or (map:GetPlatformAtPoint(pt.x, pt.z) == platform) and
			not map:IsGroundTargetBlocked(pt) then
			ent = SpawnPrefab("shadow_pillar")
			ent.Transform:SetPosition(pt:Get())
			ent:SetDelay(table.remove(delays, math.random(#delays)))
			ent:SetTarget(target, platform ~= nil)
			newpillars[ent] = pt
		end
		theta = theta + delta
	end

	if not (target.sg ~= nil and target.sg:HasStateTag("noattack")) then
		target:PushEvent("attacked", { attacker = caster, damage = 0, weapon = item })
	end
end

local AOE_RADIUS = 4
local SPELL_MUST_TAGS = { "locomotor" }
local SPELL_NO_TAGS_PVP = { "INLIMBO", "notarget", "flight", "invisible", "notraptrigger", "projectile" }
local SPELL_NO_TAGS = deepcopy(SPELL_NO_TAGS_PVP)
table.insert(SPELL_NO_TAGS, "player")
local function DoPillars(inst, targets, newpillars)
	local map = TheWorld.Map
	local caster = inst.caster ~= nil and inst.caster:IsValid() and inst.caster or nil
	local castercombat = caster ~= nil and caster.components.combat or nil
	local item = inst.item ~= nil and inst.item:IsValid() and inst.item or nil
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, 0, z, AOE_RADIUS, SPELL_MUST_TAGS, TheNet:GetPVPEnabled() and SPELL_NO_TAGS_PVP or SPELL_NO_TAGS)
	for i, v in ipairs(ents) do
		if v ~= caster and not targets[v] and v.entity:IsVisible() and
			not (v.components.health ~= nil and v.components.health:IsDead()) and
			not (castercombat ~= nil and castercombat:IsAlly(v)) then
			x, y, z = v.Transform:GetWorldPosition()
			if map:IsPassableAtPoint(x, y, z, true) then
				targets[v] = true
				DoPillarsTarget(v, caster, item, newpillars, map, x, z)
			end
		end
	end
end

local function StopTask(inst, task)
	task:Cancel()
	inst.SoundEmitter:KillSound("loop")
end

local function spell_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("CLASSIFIED")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.SoundEmitter:PlaySound("maxwell_rework/shadow_magic/shadow_goop_ground", "loop")
	StartFX(inst)
	local task = inst:DoPeriodicTask(.25, DoPillars, 0, {}, {})
	inst:DoTaskInTime(1.25, StopTask, task)
	inst:DoTaskInTime(1.5, inst.Remove)

	inst.persists = false

	return inst
end

--------------------------------------------------------------------------

return Prefab("shadow_pillar", pillar_fn, assets, prefabs),
	Prefab("shadow_pillar_base_fx", base_fn, assets_base),
	Prefab("shadow_pillar_target", target_fn),
	Prefab("shadow_pillar_spell", spell_fn, nil, prefabs_spell)
