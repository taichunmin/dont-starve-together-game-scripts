local assets =
{
	Asset("ANIM", "anim/daywalker_build.zip"),
	Asset("ANIM", "anim/daywalker_buried.zip"),
	Asset("ANIM", "anim/daywalker_phase2.zip"),
	Asset("ANIM", "anim/daywalker_phase3.zip"),
	Asset("ANIM", "anim/daywalker_defeat.zip"),
	Asset("ANIM", "anim/scrapball.zip"),
}

local buriedfx_assets =
{
	Asset("ANIM", "anim/daywalker_buried.zip"),
}

local prefabs =
{
	"daywalker2_buried_fx",
	"daywalker2_swipe_fx",
	"daywalker2_object_break_fx",
	"daywalker2_spike_break_fx",
	"daywalker2_spike_loot_fx",
	"daywalker2_cannon_break_fx",
	"daywalker2_armor1_break_fx",
	"daywalker2_armor2_break_fx",
	"daywalker2_cloth_break_fx",
	"junkball_fx",
	"junk_break_fx",
	"alterguardian_laser",
	"alterguardian_laserempty",
	"alterguardian_laserhit",
	"scrap_monoclehat",
	"wagpunk_bits",
	"gears",
    "wagpunkhat_blueprint",
    "armorwagpunk_blueprint",
    "chestupgrade_stacksize_blueprint",
    "wagpunkbits_kit_blueprint",
    "wagpunkbits_kit",
}

local brain = require("brains/daywalker2brain")

SetSharedLootTable("daywalker2",
{
	{ "gears",				0.5 },

	{ "wagpunk_bits",		1 },
	{ "wagpunk_bits",		1 },
	{ "wagpunk_bits",		1 },
	{ "wagpunk_bits",		1 },
	{ "wagpunk_bits",		0.5 },

	{ "scrap_monoclehat",	1 },
})

local MASS = 1000

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
	--remove nightmare fx
	inst.AnimState:OverrideSymbol("ww_eye_R", "daywalker_build", "ww_eye_R_scar")
	--init swappable scrap equips
	inst.AnimState:OverrideSymbol("swap_eye_R", "daywalker_phase3", "swap_eye_R")

	inst:AddComponent("updatelooper")

	inst.isupdating = false
	inst.stalking = nil
	inst.lastfacing = nil
	inst.lastdir1 = nil

	return inst
end

local function OnStalkingDirty(inst)
	inst.head.stalking = inst._stalking:value() --available to clients
	if inst.head.stalking then
		if not inst.head.isupdating then
			inst.head.isupdating = true
			inst.head.components.updatelooper:AddPostUpdateFn(UpdateHead)
		end
		inst.head.Transform:SetEightFaced()
	elseif inst.head.isupdating then
		inst.head.isupdating = false
		inst.head.lastfacing = nil
		inst.head.lastdir1 = nil
		inst.head.components.updatelooper:RemovePostUpdateFn(UpdateHead)
		inst.head.Transform:SetRotation(0)
		inst.head.Transform:SetFourFaced()
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
	elseif inst.head then
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

local function SetStalking(inst, stalking)
	if stalking and not (inst.hostile and stalking.isplayer) then
		stalking = nil
	end
	if stalking ~= inst._stalking:value() then
		if inst._stalking:value() then
			inst:RemoveEventCallback("onremove", inst._onremovestalking, inst._stalking:value())
		end
		inst._stalking:set(stalking)
		if stalking then
			inst:ListenForEvent("onremove", inst._onremovestalking, stalking)
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

local SWING_ITEMS = { "object" }
local TACKLE_ITEMS = { "spike" }
local CANNON_ITEMS = { "cannon" }
local _temp = {}

local function GetNextItem(inst)
	local junk = inst.components.entitytracker:GetEntity("junk")
	if junk and (
		not (inst.canswing or inst.cantackle or inst.cancannon) or
		(	inst.canmultiwield and
			not (inst.canswing and inst.cantackle and (inst.cancannon or not junk.hascannon)) and
			not inst.components.timer:TimerExists("multiwield")
		))
	then
		--Has no equip, or can multiwield and isn't fully equipped yet
		local n = 0
		if not inst.canswing then
			for i = 1, #SWING_ITEMS do
				n = n + 1
				_temp[n] = SWING_ITEMS[i]
			end
		end
		if not inst.cantackle then
			for i = 1, #TACKLE_ITEMS do
				n = n + 1
				_temp[n] = TACKLE_ITEMS[i]
			end
		end
		if not inst.cancannon and junk.hascannon then
			for i = 1, #CANNON_ITEMS do
				n = n + 1
				_temp[n] = CANNON_ITEMS[i]
			end
		end
		if inst.lastequip and n > 1 then
			for i = 1, n do
				if _temp[i] == inst.lastequip then
					_temp[i] = _temp[n]
					n = n - 1
					break
				end
			end
		end
		return junk, _temp[math.random(n)]
	end
	return junk
end

local function SetEquip(inst, action, item, uses)
	if action == "swing" then
		if item then
			inst.AnimState:Hide("ARM_NORMAL")
			inst.AnimState:Show("ARM_CARRY")
			inst.canswing = true
			inst.equipswing = item
			inst.numswings = TUNING.DAYWALKER2_ITEM_USES
		else
			inst.AnimState:Hide("ARM_CARRY")
			inst.AnimState:Show("ARM_NORMAL")
			inst.canswing = false
			inst.equipswing = nil
			inst.numswings = nil
		end
	elseif action == "tackle" then
		if item then
			inst.AnimState:ShowSymbol("swap_armupper")
			inst.cantackle = true
			inst.equiptackle = item
			inst.numtackles = TUNING.DAYWALKER2_ITEM_USES
		else
			inst.AnimState:HideSymbol("swap_armupper")
			inst.cantackle = false
			inst.equiptackle = nil
			inst.numtackles = nil
		end
	elseif action == "cannon" then
		if item then
			inst.AnimState:ShowSymbol("swap_armlower")
			inst.cancannon = true
			inst.equipcannon = item
			inst.numcannons = TUNING.DAYWALKER2_ITEM_USES
		else
			inst.AnimState:HideSymbol("swap_armlower")
			inst.cancannon = false
			inst.equipcannon = nil
			inst.numcannons = nil
		end
	end
	if item then
		inst.lastequip = item
	end
	inst.components.combat:SetRange(
		(inst.cancannon and TUNING.DAYWALKER2_CANNON_ATTACK_RANGE) or
		(inst.canswing and TUNING.DAYWALKER2_ATTACK_RANGE) or
		TUNING.DAYWALKER_ATTACK_RANGE
	)
end

local function OnItemUsed(inst, action)
	if action == "swing" then
		if inst.numswings then
			inst.numswings = inst.numswings - 1
			return inst.numswings > 0
		end
	elseif action == "tackle" then
		if inst.numtackles then
			inst.numtackles = inst.numtackles - 1
			return inst.numtackles > 0
		end
	elseif action == "cannon" then
		if inst.numcannons then
			inst.numcannons = inst.numcannons - 1
			return inst.numcannons > 0
		end
	end
	return false
end

local function DropItem(inst, action, nosound, _loot)
	local item, angleoffset
	if action == "swing" then
		item = inst.equipswing
		angleoffset = -(70 + math.random() * 20)
	elseif action == "tackle" then
		item = inst.equiptackle
		angleoffset = 70 + math.random() * 20
	elseif action == "cannon" then
		item = inst.equipcannon
		angleoffset = 70 + math.random() * 20
	end

	inst:SetEquip(action, nil)

	if item then
		local fx = SpawnPrefab("daywalker2_"..item..(_loot and "_loot_fx" or "_break_fx"))
		local rot = inst.Transform:GetRotation() + angleoffset
		fx.Transform:SetRotation(rot)
		local x, y, z = inst.Transform:GetWorldPosition()
		rot = rot * DEGREES
		fx.Transform:SetPosition(x + math.cos(rot) * 2, y, z - math.sin(rot) * 2)

		if not nosound then
			inst.SoundEmitter:PlaySound("dontstarve/wilson/use_break")
		end
	end
end

local function DropItemAsLoot(inst, action, nosound)
	DropItem(inst, action, nosound, true)
end

local JUNK_COLLIDE_RADIUS = 5.7 --3.6(junk radius) + 2(aoe radius) + padding!
local JUNK_COLLIDE_RSQ = JUNK_COLLIDE_RADIUS * JUNK_COLLIDE_RADIUS
local function TestTackle(inst, target, range)
	local x, y, z = inst.Transform:GetWorldPosition()
	local x1, y1, z1 = target.Transform:GetWorldPosition()
	local a_dx = x1 - x
	local a_dz = z1 - z
	local a_sq = a_dx * a_dx + a_dz * a_dz

	if range then
		if a_sq >= range * range then
			return false --OOR
		elseif not inst.canavoidjunk then
			--no need to avoid colliding with junk
			--(except for combo; range is nil; always avoid junk then)
			return true
		end
	end

	range = 1 + 2 + target:GetPhysicsRadius(0)
	if a_sq < range * range then
		--in range to hit target, doesn't matter if we also collide
		return true
	end

	local junk = inst.components.entitytracker:GetEntity("junk")
	if junk == nil then
		--no junk to avoid
		return true
	end

	local x2, y2, z2 = junk.Transform:GetWorldPosition()
	local b_sq = distsq(x1, z1, x2, z2)
	if b_sq < JUNK_COLLIDE_RSQ then
		--target too close to junk, we'll collide b4 reaching target
		return false
	end

	local c_dx = x2 - x
	local c_dz = z2 - z
	if c_dx == 0 and c_dz == 0 then
		--target is inside junk, unlikely, but more as sanity check
		return false
	end
	local a_dir = math.atan2(-a_dz, a_dx)
	local c_dir = math.atan2(-c_dz, c_dx)
	if DiffAngleRad(a_dir, c_dir) >= PI / 2 then
		--target at more than 90degree from junk
		return true
	end

	local c_sq = c_dx * c_dx + c_dz * c_dz
	if c_sq < JUNK_COLLIDE_RSQ then
		--daywalker is too close to junk, will collide immediately
		return false
	end

	local a = math.sqrt(a_sq)
	local c = math.sqrt(c_sq)
	local B = math.acos((a_sq - b_sq + c_sq) / (2 * a * c))
	local theta = math.asin(JUNK_COLLIDE_RADIUS / c)
	--won't collide if angle to target is greater than angle to tangent
	return B >= theta
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
			inst.canmultiwield = false
			inst.candoublerummage = false
			inst.canavoidjunk = true
		end,
	},
	--
	[1] = {
		hp = 0.75,
		fn = function(inst)
			inst.canmultiwield = true
			inst.candoublerummage = false
			inst.canavoidjunk = true
		end,
	},
	[2] = {
		hp = 0.5,
		fn = function(inst)
			inst.canmultiwield = true
			inst.candoublerummage = true
			inst.canavoidjunk = true
		end,
	},
}

local function CheckHealthPhase(inst)
	local healthpct = inst.components.health:GetPercent()
	for i = #PHASES, 1, -1 do
		local v = PHASES[i]
		if healthpct <= v.hp then
			v.fn(inst)
			return
		end
	end
	PHASES[0].fn(inst)
end

--------------------------------------------------------------------------

local function UpdatePlayerTargets(inst)
	local toadd = {}
	local toremove = {}
	local x, y, z
	local range
	local junk = inst.components.entitytracker:GetEntity("junk")
	if junk then
		x, y, z = junk.Transform:GetWorldPosition()
		range = TUNING.DAYWALKER2_DEAGGRO_DIST_FROM_JUNK
	else
		x, y, z = inst.Transform:GetWorldPosition()
		range = TUNING.DAYWALKER_DEAGGRO_DIST
	end

	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		toremove[k] = true
	end
	for i, v in ipairs(FindPlayersInRange(x, y, z, range, true)) do
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
	local inrange = target and inst:IsNear(target, inst.components.combat:GetAttackRange() + target:GetPhysicsRadius(0))

	if target and target.isplayer then
		local newplayer = inst.components.grouptargeter:TryGetNewTarget()
		return newplayer
			and newplayer:IsNear(inst, inrange and inst.components.combat:GetAttackRange() + newplayer:GetPhysicsRadius(0) or TUNING.DAYWALKER_KEEP_AGGRO_DIST)
			and newplayer
			or nil,
			true
	end

	local nearplayers = {}
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		if inst:IsNear(k, inrange and inst.components.combat:GetAttackRange() + k:GetPhysicsRadius(0) or TUNING.DAYWALKER_AGGRO_DIST) then
			table.insert(nearplayers, k)
		end
	end
	return #nearplayers > 0 and nearplayers[math.random(#nearplayers)] or nil, true
end

local function KeepTargetFn(inst, target)
	if inst.defeated or not inst.components.combat:CanTarget(target) then
		return false
	end
	local junk = inst.components.entitytracker:GetEntity("junk")
	if junk then
		return target:IsNear(junk, TUNING.DAYWALKER2_DEAGGRO_DIST_FROM_JUNK)
	end
	return target:IsNear(inst, TUNING.DAYWALKER_DEAGGRO_DIST)
end

local function OnAttacked(inst, data)
	if data.attacker then
		local target = inst.components.combat.target
		local targetinrange
		if target and target.isplayer then
			targetinrange = target:IsNear(inst, inst.components.combat:GetAttackRange() + target:GetPhysicsRadius(0))
			if targetinrange then
				--keep player target if they're in range
				return
			end
		end

		if inst.components.rooted or inst.components.stuckdetection:IsStuck() then
			if data.attacker:IsNear(inst, inst.components.combat:GetAttackRange() + data.attacker:GetPhysicsRadius(0)) then
				--switch to attacker if they're in range
				inst.components.combat:SetTarget(data.attacker)
				return
			elseif targetinrange == nil and target then
				targetinrange = target:IsNear(inst, inst.components.combat:GetAttackRange() + target:GetPhysicsRadius(0))
			end
			if targetinrange then
				--keep current target if they're in range
				return
			end
			--neither target in range, default to just switching targets
		end

		inst.components.combat:SetTarget(data.attacker)
	end
end

local function OnNewTarget(inst, data)
	if data.target then
		if not inst.hostile then
			inst.hostile = true
			inst:AddTag("hostile")
			inst.components.combat:SetRetargetFunction(3, RetargetFn)
		end
		inst:SetEngaged(true)
		if inst:IsStalking() then
			inst:SetStalking(data.target)
		end
	end
end

local function SetEngaged(inst, engaged)
	if engaged then
		if not inst.engaged then
			inst.engaged = true
			inst.components.health:StopRegen()
			inst:StartAttackCooldown()
			if not inst.components.timer:TimerExists("roar_cd") then
				inst:PushEvent("roar", { target = inst.components.combat.target })
			end
		end
	elseif inst.engaged then
		inst.engaged = false
		inst:SetStalking(nil)

		if not inst.defeated then
			inst.components.health:StartRegen(TUNING.DAYWALKER_HEALTH_REGEN, 1)
		else
			inst.components.health:StopRegen()
		end
		inst.components.combat:ResetCooldown()
		inst.components.combat:DropTarget()
	end
end

local function StartAttackCooldown(inst)
	inst.components.combat:SetAttackPeriod(GetRandomMinMax(TUNING.DAYWALKER2_ATTACK_PERIOD.min, TUNING.DAYWALKER2_ATTACK_PERIOD.max))
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

local function OnThiefDelayOver(inst)
	inst._thiefdelaytask = nil
	inst._thief = nil
end

local function OnThiefReset(inst)
	if inst._thiefresettask then
		inst._thiefresettask:Cancel()
		inst._thiefresettask = nil
	end
	inst._thieflevel = 0
end

local function OnJunkStolen(inst, thief)
	if not (inst.buried or inst.defated or inst.hostile or inst._thiefdelaytask or inst.sg:HasStateTag("sleeping")) then
		inst._thieflevel = inst._thieflevel + 1
		inst._thiefdelaytask = inst:DoTaskInTime(2, OnThiefDelayOver)
		inst._thief = thief

		if inst._thiefresettask then
			inst._thiefresettask:Cancel()
		end
		inst._thiefresettask = inst:DoTaskInTime(TUNING.TOTAL_DAY_TIME / 2, OnThiefReset)

		if inst._thieflevel > 3 then
			inst.components.combat:SetTarget(thief)
		else
			local strid
			if inst._thieflevel > 2 then
				strid = math.max(3, math.random(#STRINGS.DAYWALKER2_JUNK_WARNING))
			elseif inst._thieflevel > 1 then
				strid = math.random(4, #STRINGS.DAYWALKER2_JUNK_WARNING)
			else
				strid = math.random(2)
			end
			inst.components.talker:Chatter("DAYWALKER2_JUNK_WARNING", strid, nil, nil, CHATPRIORITIES.HIGH)
		end
	end
end

local function ShouldSleep(inst)
	return false
end

local function ShouldWake(inst)
	return true
end

local function AddCombatStatusEffectComponents(inst)
	MakeLargeBurnableCharacter(inst, "ww_cloth")
	MakeLargeFreezableCharacter(inst, "ww_body")
	inst.components.freezable:SetResistance(4)
	inst.components.freezable.diminishingreturns = true

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(4)
	inst.components.sleeper:SetSleepTest(ShouldSleep)
	inst.components.sleeper:SetWakeTest(ShouldWake)
	inst.components.sleeper.diminishingreturns = true
end

local function RemoveCombatStatusEffectComponents(inst)
	if inst.components.freezable.coldness > 0 then
		inst.components.freezable:SpawnShatterFX()
	end
	inst.components.freezable:Reset()
	inst:RemoveComponent("freezable")
	inst:RemoveComponent("burnable")
	inst:RemoveComponent("propagator")
	inst:RemoveComponent("sleeper")
end

--------------------------------------------------------------------------

local function MakeBuried(inst, junk)
	if not (inst.buried or inst.defeated) then
		inst.buried = true
		inst.hostile = false
		OnThiefReset(inst)
		inst.persists = false
		if inst.canswing or inst.cantackle or inst.cancannon then
			if inst.canswing then
				inst:DropItem("swing", true)
			end
			if inst.cantackle then
				if inst.equiptackle == "spike" then
					inst:DropItemAsLoot("tackle", true)
				else
					inst:DropItem("tackle", true)
				end
			end
			if inst.cancannon then
				inst:DropItem("cannon", true)
			end
			--just play it once for all loot
			inst.SoundEmitter:PlaySound("dontstarve/wilson/use_break")
		end
		inst.sg:GoToState("transition")
		inst:RemoveEventCallback("attacked", OnAttacked)
		inst:RemoveEventCallback("newcombattarget", OnNewTarget)
		inst:RemoveEventCallback("minhealth", OnMinHealth)
		inst:RemoveEventCallback("ms_junkstolen", OnJunkStolen)
		inst.components.timer:StopTimer("despawn")
		inst.components.combat:DropTarget()
		inst.components.combat:SetRetargetFunction(nil)
		inst.components.talker:ShutUp()
		inst.components.locomotor:Stop()
		inst.components.health:SetInvincible(true)
		inst.components.sanityaura.aura = -TUNING.SANITYAURA_LARGE
		RemoveCombatStatusEffectComponents(inst)
		inst:RemoveTag("hostile")
		inst:AddTag("notarget")
		inst.AnimState:Hide("junk_top")
		inst.AnimState:Hide("junk_mid")
		inst.AnimState:Hide("junk_back")
		inst.Transform:SetEightFaced()
		inst.Physics:SetActive(false)
		PHASES[0].fn(inst)
		inst:SetBrain(nil)
		inst:SetHeadTracking(false)
		inst:SetStalking(nil)
		inst:SetEngaged(false)

		if inst.junkfx == nil then
			inst.junkfx = {}
			for i, v in ipairs({ "junk_top", "junk_mid", "junk_back" }) do
				local fx = SpawnPrefab("daywalker2_buried_fx")
				fx.entity:SetParent(junk.entity)
				if junk.prefab == "junk_pile_big" and junk.highlightchildren then
					table.insert(junk.highlightchildren, fx)
				end
				fx.AnimState:Show(v)
				if i == 1 then
					fx.AnimState:SetSortWorldOffset(0, 0.1, 0) --top layer mouseover priority
				end
				fx.Follower:FollowSymbol(inst.GUID, "follow_"..v, 0, 0, 0, true)
				table.insert(inst.junkfx, fx)
			end
		end

		inst.components.entitytracker:TrackEntity("junk", junk)
		inst._onremovejunk = function() inst:Remove() end
		inst:ListenForEvent("onremove", inst._onremovejunk, junk)

		inst:SetStateGraph("SGdaywalker2_buried") --after junkfx spawned
	end
end

local function MakeFreed(inst)
	if inst.buried then
		inst.buried = nil
		--OnThiefReset(inst)
		inst.persists = true
		inst.sg:GoToState("transition")
		inst:ListenForEvent("attacked", OnAttacked)
		inst:ListenForEvent("newcombattarget", OnNewTarget)
		inst:ListenForEvent("minhealth", OnMinHealth)
		inst:ListenForEvent("ms_junkstolen", OnJunkStolen)
		AddCombatStatusEffectComponents(inst)
		inst.components.timer:StopTimer("despawn")
		inst.components.talker:ShutUp()
		inst.components.health:SetInvincible(false)
		inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE
		inst:RemoveTag("notarget")
		inst.AnimState:Show("junk_top")
		inst.AnimState:Show("junk_mid")
		inst.AnimState:Show("junk_back")
		inst.Transform:SetFourFaced()
		inst.Physics:SetActive(true)
		inst:SetStateGraph("SGdaywalker2")
		inst.sg:GoToState("emerge")
		CheckHealthPhase(inst)
		inst:SetBrain(brain)
		if inst.brain == nil and not inst:IsAsleep() then
			inst:RestartBrain()
		end

		if inst.junkfx then
			for i, v in ipairs(inst.junkfx) do
				v:Remove()
			end
			inst.junkfx = nil
		end

		if inst._onremovejunk then
			local junk = inst.components.entitytracker:GetEntity("junk")
			inst:RemoveEventCallback("onremove", inst._onremovejunk, junk)
			inst._onremovejunk = nil
		end
	end
end

local function MakeDefeated(inst, force)
	if not (inst.buried or inst.defated) and (inst.hostile or force) then
		inst.defeated = true
		inst.hostile = false
		OnThiefReset(inst)
		inst:RemoveEventCallback("attacked", OnAttacked)
		inst:RemoveEventCallback("newcombattarget", OnNewTarget)
		inst:RemoveEventCallback("minhealth", OnMinHealth)
		inst:RemoveEventCallback("ms_junkstolen", OnJunkStolen)
		inst:ListenForEvent("timerdone", OnDespawnTimer)
		if not inst.components.timer:TimerExists("despawn") then
			inst.components.timer:StartTimer("despawn", DESPAWN_TIME, not inst.looted)
		end
		inst.components.health:StopRegen()
		inst.components.combat:DropTarget()
		inst.components.combat:SetRetargetFunction(nil)
		inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
		RemoveCombatStatusEffectComponents(inst)
		inst:RemoveTag("hostile")
		inst:SetBrain(nil)
		inst:SetHeadTracking(false)
		inst:SetStalking(nil)
		inst:SetEngaged(false)
	end
end

--------------------------------------------------------------------------

local function GetStatus(inst)
	return (inst.buried and "BURIED")
		or (inst.hostile and "HOSTILE")
		or nil
end

local function OnSave(inst, data)
	data.hostile = inst.hostile or nil
	data.looted = inst.looted or nil
	if inst.canswing then
		data.numswings = inst.numswings
		data.equipswing = inst.equipswing
	end
	if inst.cantackle then
		data.numtackles = inst.numtackles
		data.equiptackle = inst.equiptackle
	end
	if inst.cancannon then
		data.numcannons = inst.numcannons
		data.equipcannon = inst.equipcannon
	end
end

local function OnLoad(inst, data)
	CheckHealthPhase(inst)

	if inst.components.timer:TimerExists("despawn") then
		inst:MakeDefeated(true)
		if data and data.looted then
			inst.looted = true
			inst.sg:GoToState("defeat_idle_pre")
		else
			inst.components.timer:PauseTimer("despawn")
			inst.components.timer:SetTimeLeft("despawn", DESPAWN_TIME)
			inst.sg:GoToState("defeat")
		end
	elseif data.hostile then
		inst.hostile = true
		inst:AddTag("hostile")
		inst.components.combat:SetRetargetFunction(3, RetargetFn)
	end

	if inst.hostile or (inst.defeated and not inst.looted) then
		if data.numswings and data.numswings > 0 then
			inst:SetEquip("swing", data.equipswing, data.numswings)
		end
		if data.numtackles and data.numtackles > 0 then
			inst:SetEquip("tackle", data.equiptackle, data.numtackles)
		end
		if data.numcannons and data.numcannons > 0 then
			inst:SetEquip("cannon", data.equipcannon, data.numcannons)
		end
	end
end

local function OnEntitySleep(inst)
	if inst.looted then
		if inst._despawntask == nil then
			inst._despawntask = inst:DoTaskInTime(1, inst.Remove)
		end
	elseif inst.hostile then
		inst:SetEngaged(false)
	end
end

local function OnEntityWake(inst)
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
	if inst.buried then
		return inst:GetPosition()
	end

	local junk = inst.components.entitytracker:GetEntity("junk")
	if inst.defeated then
		--Stay near junkyard; or, backup is just don't go too far
		local pos = (junk or inst):GetPosition()
		local offset = FindWalkableOffset(pos, TWOPI * math.random(), 5, 8, true, false)
		if offset then
			pos.x = pos.x + offset.x
			pos.z = pos.z + offset.z
		elseif junk then
			pos.x, pos.y, pos.z = inst.Transform:GetWorldPosition()
		end
		pos.y = 0
		return pos
	end

	--Go back to junk if it is still there, otherwise anywhere (return nil for default behvaiour)
	if junk and junk:CanBuryDaywalker(inst) then
		return inst:GetPosition()
	end
end

local function OnTeleported(inst)
	if inst.defeated then
		return
	end
	local junk = inst.components.entitytracker:GetEntity("junk")
	if inst.buried then
		if not (junk and junk:TryReleaseDaywalker(inst)) then
			--staff teleport resets invincible flag
			inst.components.health:SetInvincible(true)
		end
	elseif junk then
		junk:TryBuryDaywalker(inst)
	end
end

-- NOTES(JBK): Keep these up to sync with wagstaff_machinery drops. [WPDROPS]
local WAGPUNK_ITEMS = { -- These are prefab names not their blueprints.
    "wagpunkhat",
    "armorwagpunk",
    "chestupgrade_stacksize",
    "wagpunkbits_kit",
}
local function lootsetfn(lootdropper)
    lootdropper:ClearRandomLoot()
    if TheWorld.components.riftspawner and TheWorld.components.riftspawner:GetLunarRiftsEnabled() then
        local needstoknow = nil
        local inst = lootdropper.inst
        for _, player in ipairs(AllPlayers) do
            if player:GetDistanceSqToInst(inst) <= 256 then -- 16 * 16 = 256 = 4 tiles
                local builder = player.components.builder
                for _, recipename in ipairs(WAGPUNK_ITEMS) do
                    if not builder:KnowsRecipe(recipename) then
                        if needstoknow == nil then
                            needstoknow = {}
                        end
                        needstoknow[recipename] = (needstoknow[recipename] or 0) + 1
                    end
                end
            end
        end
        if needstoknow then
            -- Some one needs something make it only potentially drop these.
            for recipename, _ in pairs(needstoknow) do
                lootdropper:AddRandomLoot(recipename .. "_blueprint", 1)
            end
        else
            -- No one needs anything make it random.
            for _, recipename in ipairs(WAGPUNK_ITEMS) do
                lootdropper:AddRandomLoot(recipename .. "_blueprint", 1)
            end
        end
    else
        lootdropper:AddRandomLoot("wagpunkbits_kit", 1)
    end
    lootdropper.numrandomloot = 1
end

--------------------------------------------------------------------------

local function PushMusic(inst)
	if ThePlayer == nil or not inst:HasTag("hostile") then
		inst._playingmusic = false
	elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
		inst._playingmusic = true
		ThePlayer:PushEvent("triggeredevent", { name = "daywalker2" })
	elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
		inst._playingmusic = false
	end
end

--------------------------------------------------------------------------

-- NOTES(DiogoW): @V2C, please keep this updated :)
local scrapbook_data =
{
	scrapbook_anim =			"scrapbook",
	scrapbook_overridebuild =	"daywalker_phase3",
	scrapbook_overridedata =	{	{ "ww_armlower_base", "daywalker_build", "ww_armlower_base_nored" },
									{ "ww_eye_R",         "daywalker_build", "ww_eye_R_scar"          },
								},
	scrapbook_hide =			{ "follow_eye" },
	scrapbook_hidesymbol =		{ "ww_armlower_red" },
	scrapbook_deps =			{ "scraphat" },
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

	inst.Transform:SetFourFaced()
	--inst.Transform:SetSixFaced() --V2C: TwoFaced has a built in rot offset hack for stationary objects
	inst:SetPhysicsRadiusOverride(1.3)
	MakeGiantCharacterPhysics(inst, MASS, inst.physicsradiusoverride)

	inst:AddTag("epic")
	inst:AddTag("noepicmusic")
	inst:AddTag("monster")
	--inst:AddTag("hostile")
	inst:AddTag("scarytoprey")
	inst:AddTag("largecreature")
	inst:AddTag("junkmob")
	--inst:AddTag("lunar_aligned")

	inst.AnimState:SetBank("daywalker")
	inst.AnimState:SetBuild("daywalker_build")
	inst.AnimState:PlayAnimation("idle", true)
	--remove nightmare fx
	inst.AnimState:HideSymbol("ww_armlower_red")
	inst.AnimState:OverrideSymbol("ww_armlower_base", "daywalker_build", "ww_armlower_base_nored")
	inst.AnimState:OverrideSymbol("ww_eye_R", "daywalker_build", "ww_eye_R_scar")
	inst.AnimState:SetSymbolSaturation("fx_smear", 0)
	--init swappable scrap equips
	inst.AnimState:Hide("ARM_CARRY")
	inst.AnimState:HideSymbol("swap_armupper")
	inst.AnimState:HideSymbol("swap_armlower")
	inst.AnimState:OverrideSymbol("scrap_debris", "scrapball", "scrap_debris")
	inst.AnimState:AddOverrideBuild("daywalker_phase3")
	inst.AnimState:AddOverrideBuild("daywalker_buried")

	inst.DynamicShadow:SetSize(3.5, 1.5)

	local talker = inst:AddComponent("talker")
	talker.fontsize = 40
	talker.font = TALKINGFONT
	talker.colour = Vector3(238 / 255, 69 / 255, 105 / 255)
	talker.offset = Vector3(0, -400, 0)
	talker.symbol = "ww_hunch"
    talker.name_colour = Vector3(175/256, 133/256, 64/256)
    talker.chaticon = "npcchatflair_daywalker_scrap"
	talker:MakeChatter()

	inst._headtracking = net_bool(inst.GUID, "daywalker._headtracking", "headtrackingdirty")
	inst._stalking = net_entity(inst.GUID, "daywalker._stalking", "stalkingdirty")

	inst:AddComponent("despawnfader")

	inst.entity:SetPristine()

	--Dedicated server does not need to trigger music
	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst._playingmusic = false
		inst:DoPeriodicTask(1, PushMusic, 0)
	end

	if not TheWorld.ismastersim then
		inst:ListenForEvent("headtrackingdirty", OnHeadTrackingDirty)

		return inst
	end

	shallowcopy(scrapbook_data, inst)

	inst.footstep = "qol1/daywalker_scrappy/step"

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
	inst.components.health:StartRegen(TUNING.DAYWALKER_HEALTH_REGEN, 1)
	--inst.components.health.nofadeout = true

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.DAYWALKER_DAMAGE)
	inst.components.combat:SetAttackPeriod(TUNING.DAYWALKER2_ATTACK_PERIOD.min)
	inst.components.combat.playerdamagepercent = .5
	inst.components.combat.externaldamagetakenmultipliers:SetModifier(inst, TUNING.DAYWALKER2_DAMAGE_TAKEN_MULT, "junkarmor")
	inst.components.combat:SetRange(TUNING.DAYWALKER_ATTACK_RANGE)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	inst.components.combat.hiteffectsymbol = "ww_body"
	inst.components.combat.battlecryenabled = false
	inst.components.combat.forcefacing = false

	inst:AddComponent("stuckdetection")
	inst.components.stuckdetection:SetTimeToStuck(3)

	inst:AddComponent("colouradder")
	inst:AddComponent("bloomer")

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
    inst.components.lootdropper:SetLootSetupFn(lootsetfn)
	inst.components.lootdropper:SetChanceLootTable("daywalker2")
	inst.components.lootdropper.min_speed = 1
	inst.components.lootdropper.max_speed = 3
	inst.components.lootdropper.y_speed = 14
	inst.components.lootdropper.y_speed_variance = 4
	inst.components.lootdropper.spawn_loot_inside_prefab = true

	inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)

	AddCombatStatusEffectComponents(inst)

	inst.hit_recovery = TUNING.DAYWALKER_HIT_RECOVERY

	inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("newcombattarget", OnNewTarget)
	inst:ListenForEvent("minhealth", OnMinHealth)
	inst:ListenForEvent("ms_junkstolen", OnJunkStolen)
	inst:ListenForEvent("teleported", OnTeleported)

	inst.engaged = false
	inst.defeated = false
	inst.looted = false
	inst._trampledelays = {}
	inst._thieflevel = 0
	inst._thief = nil
	inst._thiefdelaytask = nil

	--ability unlocks
	inst.autostalk = true
	inst.canthrow = true
	inst.canswing = false
	inst.cantackle = false
	inst.cancannon = false
	inst.canmultiwield = false
	inst.candoublerummage = false
	inst.canavoidjunk = true

	inst._onremovestalking = function(stalking) inst._stalking:set(nil) end

	inst.MakeBuried = MakeBuried
	inst.MakeFreed = MakeFreed
	inst.MakeDefeated = MakeDefeated
	inst.SetEngaged = SetEngaged
	inst.StartAttackCooldown = StartAttackCooldown
	inst.SetHeadTracking = SetHeadTracking
	inst.SetStalking = SetStalking
	inst.GetStalking = GetStalking
	inst.IsStalking = IsStalking
	inst.GetNextItem = GetNextItem
	inst.SetEquip = SetEquip
	inst.OnItemUsed = OnItemUsed
	inst.DropItem = DropItem
	inst.DropItemAsLoot = DropItemAsLoot
	inst.TestTackle = TestTackle
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

	inst:SetStateGraph("SGdaywalker2")
	inst:SetBrain(brain)
	inst:SetEngaged(false)

	return inst
end

--------------------------------------------------------------------------

local function buriedfx_OnRemoveEntity(inst)
	local parent = inst.entity:GetParent()
	if parent and parent.highlightchildren then
		table.removearrayvalue(parent.highlightchildren, inst)
	end
end

local function buriedfx_OnEntityReplicated(inst)
	local parent = inst.entity:GetParent()
	if parent and parent.prefab == "junk_pile_big" then
		table.insert(parent.highlightchildren, inst)
	end
end

local function buriedfx_fn()
	local inst = CreateEntity()

	--V2C: speecial =) must be the 1st tag added b4 AnimState component
	inst:AddTag("can_offset_sort_pos")

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst.Transform:SetEightFaced()

	inst.AnimState:SetBank("daywalker")
	inst.AnimState:SetBuild("daywalker_buried")
	inst.AnimState:PlayAnimation("buried_hold_full", true)
	inst.AnimState:Hide("junk_top")
	inst.AnimState:Hide("junk_mid")
	inst.AnimState:Hide("junk_back")

	inst:AddTag("FX")

	inst.entity:SetPristine()

	inst.OnRemoveEntity = buriedfx_OnRemoveEntity

	if not TheWorld.ismastersim then
		inst.OnEntityReplicated = buriedfx_OnEntityReplicated

		return inst
	end

	inst.persists = false

	return inst
end

--------------------------------------------------------------------------

return Prefab("daywalker2", fn, assets, prefabs),
	Prefab("daywalker2_buried_fx", buriedfx_fn, buriedfx_assets)
