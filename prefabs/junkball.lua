local easing = require("easing")

local assets =
{
	Asset("ANIM", "anim/scrapball.zip"),
}

local prefabs =
{
	"junkball_fall_fx",
}

local prefabs_fall =
{
	"junk_pile",
	"splash_green_large",
}

--------------------------------------------------------------------------

local function SetShadowScale(inst, scale)
	scale = inst.scale * scale
	inst.AnimState:SetScale(scale, math.abs(scale))
end

local function CreateShadow(scale)
	local inst = CreateEntity()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("scrapball")
	inst.AnimState:SetBuild("scrapball")
	inst.AnimState:PlayAnimation("shadow"..tostring(math.random(3)))
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst.scale = math.random() < 0.5 and -scale or scale
	inst.AnimState:SetScale(inst.scale, scale)

	inst.Transform:SetRotation(math.random() * 360)

	inst.SetShadowScale = SetShadowScale

	return inst
end

--------------------------------------------------------------------------

local MIN_DIST = 4
local MAX_DIST = 20
local DEFAULT_DIST = 12
local UP_DIST_PCT = 0.4 --what part of the distance do we cover on the way up
local FALL_DIST_PCT = 1 - UP_DIST_PCT

--client/server (excluding dedicated server)
local function UpdateFade(inst, dt)
	local frame = inst.AnimState:GetCurrentAnimationFrame()
	local len = inst.AnimState:GetCurrentAnimationNumFrames()
	local half = math.floor(len / 2)
	if frame > half then
		if frame >= len then
			inst.AnimState:OverrideMultColour(1, 1, 1, 0)
			inst.components.updatelooper:RemoveOnUpdateFn(UpdateFade)
		else
			local alpha = easing.outQuad(frame - half, 1, -1, len - half)
			inst.AnimState:OverrideMultColour(1, 1, 1, alpha)
		end
	end

	if inst.shadow then
		local fadeoutlen = len * 0.75
		if frame >= fadeoutlen then
			inst.shadow:Remove()
			inst.shadow = nil
		elseif frame >= 1 then
			local scale = easing.linear(frame, 1, -0.5, len)
			inst.shadow:SetShadowScale(scale)

			local alpha = easing.inQuad(frame - 1, 1, -1, fadeoutlen - 1)
			inst.shadow.AnimState:SetMultColour(1, 1, 1, alpha)
		else
			inst.shadow:SetShadowScale(1)
			inst.shadow.AnimState:SetMultColour(1, 1, 1, 0.5)
		end
	end
end

--server only
local function UpdatePos(inst, dt)
	if inst:IsAsleep() then
		return
	end
	dt = dt * TheSim:GetTimeScale()
	inst.x = inst.x + inst.speedx * dt
	inst.z = inst.z + inst.speedz * dt
	inst.Transform:SetPosition(inst.x, 0, inst.z)
end

local function SetupJunkTossAttack(inst, attacker, offset, target, targetpos)
	inst.attacker = attacker
	inst.target = target
	inst.targetpos = targetpos
	inst.dir = attacker.Transform:GetRotation() * DEGREES
	inst.pileupchance = 0.25

	--Start in front of the attacker to line up with character animation
	local cos_dir = math.cos(inst.dir)
	local sin_dir = math.sin(inst.dir)
	local x, y, z = attacker.Transform:GetWorldPosition()
	local xa, za = x, z
	if offset then
		x = x + offset * cos_dir
		z = z - offset * sin_dir
	end

	--Last minute tracking
	if target and target:IsValid() then
		if targetpos then
			targetpos.x, targetpos.y, targetpos.z = target.Transform:GetWorldPosition()
		else
			targetpos = target:GetPosition()
			inst.targetpos = targetpos
		end
	end

	--Calculate target distance depending on whether it's in front or behind us
	inst.dist = DEFAULT_DIST
	if targetpos then
		local dx = targetpos.x - xa
		local dz = targetpos.z - za
		if dx ~= 0 and dz ~= 0 then
			local dir1 = math.atan2(-dz, dx)
			local diff = DiffAngleRad(inst.dir, dir1) --rel to attacker w/o offset
			local distfromoffset = math.sqrt(distsq(x, z, targetpos.x, targetpos.z))
			inst.dist = math.clamp(distfromoffset * math.cos(diff), MIN_DIST, MAX_DIST)
			diff = diff * RADIANS
			if diff > 60 then
				inst.dist = easing.inQuad(diff - 60, inst.dist, DEFAULT_DIST, 120)
			end
		else
			inst.dist = MIN_DIST
		end
	end

	--Cached values to optimize wallupdate
	local speed = inst.dist * UP_DIST_PCT / inst.AnimState:GetCurrentAnimationLength()
	inst.speedx = speed * cos_dir
	inst.speedz = -speed * sin_dir
	inst.x, inst.z = x, z
	inst.Transform:SetPosition(x, 0, z)
	inst.components.updatelooper:AddOnWallUpdateFn(UpdatePos)
end

local function SetupJunkTossFromPile(inst, x, z, x1, z1)
	if x == x1 and z == z1 then
		inst.dir = math.random() * PI2
		inst.dist = MIN_DIST
	else
		local dx = x1 - x
		local dz = z1 - z
		inst.dir = math.atan2(-dz, dx)
		inst.dist = math.clamp(math.sqrt(dx * dx + dz * dz), MIN_DIST, MAX_DIST)
	end
	inst.pileupchance = 0.75

	--Cached values to optimize wallupdate
	local speed = inst.dist * UP_DIST_PCT / inst.AnimState:GetCurrentAnimationLength()
	inst.speedx = speed * math.cos(inst.dir)
	inst.speedz = -speed * math.sin(inst.dir)
	inst.x, inst.z = x, z
	inst.Transform:SetPosition(x, 0, z)
	inst.components.updatelooper:AddOnWallUpdateFn(UpdatePos)
end

local function DoSound(inst)
	inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/pile_throw_land")
end

local function DoJunkFall(inst, x, z, x1, z1, formpile, targets)
	SpawnPrefab("junkball_fall_fx"):SetupJunkFall(inst.attacker, x, z, x1, z1, formpile, inst.pileupchance, targets)
end

local function SortByDistance(a, b)
	return a.dsq < b.dsq
end

local function OnAnimOver(inst)
	if inst.x == nil then
		inst:Remove()
		return
	end

	inst.components.updatelooper:RemoveOnWallUpdateFn(UpdatePos)
	inst:Hide()

	--More last minute tracking
	if inst.target and inst.target:IsValid() then
		inst.targetpos.x, inst.targetpos.y, inst.targetpos.z = inst.target.Transform:GetWorldPosition()
	end

	local dir = inst.dir
	local remainingdist = inst.dist * FALL_DIST_PCT
	local dist = remainingdist
	if inst.targetpos then
		local dx = inst.targetpos.x - inst.x
		local dz = inst.targetpos.z - inst.z
		if dx ~= 0 and dz ~= 0 then
			local dir1 = math.atan2(-dz, dx)
			local diff = ReduceAngleRad(dir1 - dir)

			--Allow minor change in direction
			local maxdiff = 45 * DEGREES
			dir = dir + math.clamp(diff, -maxdiff, maxdiff)

			--Recalculate remaining target distance
			diff = math.abs(diff)
			dist = math.clamp(math.sqrt(dx * dx + dz * dz) * math.cos(diff), MIN_DIST * FALL_DIST_PCT, MAX_DIST * FALL_DIST_PCT)
			diff = diff * RADIANS
			if diff > 60 then
				dist = easing.inQuad(diff - 60, dist, DEFAULT_DIST * FALL_DIST_PCT, 120)
			end

			--Allow minor change in distance
			dist = math.clamp(dist, remainingdist - math.min(6, remainingdist * 0.5), remainingdist + math.min(6, inst.dist * 0.3))
		end
	end

	local cos_dir = math.cos(dir)
	local sin_dir = math.sin(dir)
	local offset = dist * 0.35
	local x = inst.x + offset * cos_dir
	local z = inst.z - offset * sin_dir
	dist = dist - offset

	local x1 = x + dist * cos_dir
	local z1 = z - dist * sin_dir
	local pts = { { x = x1, z = z1, dsq = dist * dist, pile = true } }

	local angle = math.random() * PI2
	local num = 5
	local delta = PI2 / num
	for i = 1, num do
		local r = 2.5 + math.random()
		local x2 = x1 + r * math.cos(angle)
		local z2 = z1 - r * math.sin(angle)
		table.insert(pts, { x = x2, z = z2, dsq = distsq(x, z, x2, z2) })
		angle = angle + delta
	end

	table.sort(pts, SortByDistance)

	--shuffle a bit so the fall pattern feels more natural after sorting
	local swaprange = math.floor(#pts / 3)
	local rnd1 = math.random(swaprange)
	local rnd2 = math.random(#pts - swaprange + 1, #pts)
	local swap = pts[rnd1]
	pts[rnd1] = pts[rnd2]
	pts[rnd2] = swap

	local targets = {}
	local delay = 6 * FRAMES
	for i, v in ipairs(pts) do
		inst:DoTaskInTime(delay, DoJunkFall, x, z, v.x, v.z, v.pile, targets)
		delay = delay + (1.5 + math.random()) * FRAMES
	end

	inst.Transform:SetPosition(x1, 0, z1)
	inst:DoTaskInTime((6 + 11) * FRAMES, DoSound)
	inst:DoTaskInTime(math.max(delay, (6 + 11 + 4) * FRAMES), inst.Remove)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("NOCLICK")
	inst:AddTag("FX")
	inst:AddTag("junk")

	inst.AnimState:SetBank("scrapball")
	inst.AnimState:SetBuild("scrapball")
	inst.AnimState:PlayAnimation("scrap_launch")

	inst:AddComponent("updatelooper")

	--Dedicated server does not need to spawn the local fx or fade
	if not TheNet:IsDedicated() then
		inst.shadow = CreateShadow(1.7)
		inst.shadow.entity:SetParent(inst.entity)

		inst.components.updatelooper:AddOnUpdateFn(UpdateFade)
		UpdateFade(inst, 0)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	inst:ListenForEvent("animover", OnAnimOver)

	inst.SetupJunkTossAttack = SetupJunkTossAttack
	inst.SetupJunkTossFromPile = SetupJunkTossFromPile

	return inst
end

--------------------------------------------------------------------------

local COLLAPSIBLE_WORK_ACTIONS =
{
	CHOP = true,
	DIG = true,
	HAMMER = true,
	MINE = true,
}
local COLLAPSIBLE_TAGS = { "_combat", "pickable", "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
	table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end
local NON_COLLAPSIBLE_TAGS = { "FX", --[["NOCLICK",]] "DECOR", "INLIMBO", "junkmob" }
local AOE_RADIUS = 1.5
local PHYSICS_PADDING = 3

local function DoDamage(inst, targets)
	local combat = inst.attacker and inst.attacker:IsValid() and inst.attacker.components.combat or inst.components.combat
	local restoredmg = combat.defaultdamage
	local restorepdp = combat.playerdamagepercent
	combat:SetDefaultDamage(TUNING.JUNK_FALL_DAMAGE)
	combat.playerdamagepercent = nil
	combat.ignorehitrange = true

	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, 0, z, AOE_RADIUS + PHYSICS_PADDING, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)
	for i, v in ipairs(ents) do
		if targets[v] == nil and v ~= inst.attacker and
			v:IsValid() and not v:IsInLimbo() and
			not (v.components.health and v.components.health:IsDead())
		then
			local r = AOE_RADIUS + v:GetPhysicsRadius(0.5)
			local x1, y1, z1 = v.Transform:GetWorldPosition()
			if distsq(x, z, x1, z1) < r * r then
				local isworkable = false
				if v.components.workable then
					local work_action = v.components.workable:GetWorkAction()
					--V2C: nil action for NPC_workable (e.g. campfires)
					isworkable =
						(   work_action == nil and v:HasTag("NPC_workable")    ) or
						(   work_action and
							v.components.workable:CanBeWorked() and
							COLLAPSIBLE_WORK_ACTIONS[work_action.id] and
							(   work_action ~= ACTIONS.DIG or
								not (v.components.spawner or v.components.childspawner)
							)
						)
				end
				if isworkable then
					v.components.workable:Destroy(inst)
					targets[v] = "worked"
					if inst.formpile and v:IsValid() and v:HasTag("stump") then
						v:Remove()
					end
				elseif v.components.pickable and v.components.pickable:CanBePicked() and not v:HasTag("intense") then
					v.components.pickable:Pick(inst)
					targets[v] = "picked"
				elseif combat:CanTarget(v) then
					if v.components.inventory and v.components.inventory:EquipHasTag("junk") then
						combat.externaldamagemultipliers:SetModifier(inst, 0, "junkabsorbed")
						combat:DoAttack(v)
						combat.externaldamagemultipliers:RemoveModifier(inst, "junkabsorbed")
					else
						combat:DoAttack(v)
					end
					targets[v] = "attacked"
				end
			end
		end
	end

	combat.ignorehitrange = false
	combat.playerdamagepercent = restorepdp
	combat:SetDefaultDamage(restoredmg)

	if targets.pile and math.random() < inst.pileupchance and targets.pile:IsValid() and targets.pile.components.workable and targets.pile.components.workable:CanBeWorked() then
		targets.pile.components.workable:WorkedBy(inst, 0)
	end

	local totoss = TheSim:FindEntities(x, 0, z, AOE_RADIUS + PHYSICS_PADDING, { "_inventoryitem" }, { "locomotor", "INLIMBO" })
	for i, v in ipairs(totoss) do
		local rsq = AOE_RADIUS + v:GetPhysicsRadius(.5)
		rsq = rsq * rsq
		local x1, y1, z1 = v.Transform:GetWorldPosition()
		local dx, dz = x1 - x, z1 - z
		local dsq = dx * dx + dz * dz
		if dsq < rsq and y1 < 0.2 then
			if v.components.mine then
				v.components.mine:Deactivate()
			end
			if not v.components.inventoryitem.nobounce and v.Physics and v.Physics:IsActive() then
				local angle
				if dsq > 0 then
					local dist = math.sqrt(dsq)
					angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
				else
					angle = PI2 * math.random()
				end
				local sina, cosa = math.sin(angle), math.cos(angle)
				local speed = 2.25 - dsq / rsq + math.random()
				v.Physics:Teleport(x1, .1, z1)
				v.Physics:SetVel(cosa * speed, speed * 2 + math.random() * 2, sina * speed)
			end
		end
	end
end

--------------------------------------------------------------------------

local FALL_TIME = 0.5

--client/server (excluding dedicated server)
local function UpdateFallFade(inst, dt)
	local frame = inst.AnimState:GetCurrentAnimationFrame()
	local len = inst.AnimState:GetCurrentAnimationNumFrames()
	local landingframe = 15
	local faeoutframe = 19
	if frame >= faeoutframe then
		inst.components.updatelooper:RemoveOnUpdateFn(UpdateFallFade)
		inst.AnimState:OverrideMultColour(1, 1, 1, 1)
		inst.shadow:Remove()
		inst.shadow = nil
	elseif frame >= landingframe then
		inst.AnimState:OverrideMultColour(1, 1, 1, 1)

		local t = frame - landingframe
		local len = faeoutframe - landingframe
		local scale = easing.outQuad(t, 1, 0.2, len)
		local alpha = easing.outQuad(t, 1, -1, len)
		inst.shadow:SetShadowScale(scale)
		inst.shadow.AnimState:SetMultColour(1, 1, 1, alpha)
	else
		if frame >= 10 then
			inst.AnimState:OverrideMultColour(1, 1, 1, 1)
			inst.shadow.AnimState:SetMultColour(1, 1, 1, 1)
		else
			local alpha = easing.inQuad(frame, 0, 1, 6)
			inst.AnimState:OverrideMultColour(1, 1, 1, alpha)
			inst.shadow.AnimState:SetMultColour(1, 1, 1, alpha)
		end

		local scale = easing.linear(frame, 0.5, 0.5, landingframe)
		inst.shadow:SetShadowScale(scale)
	end
end

local JUNK_PILE_TAGS = { "junk_pile", "junk_pile_big", "wall" }

--server only
local function UpdateFallPos(inst, dt)
	if inst:IsAsleep() then
		return
	end
	dt = dt * TheSim:GetTimeScale()
	inst.t = inst.t + dt
	if inst.t < FALL_TIME then
		inst.x = inst.x + inst.speedx * dt
		inst.z = inst.z + inst.speedz * dt
		inst.Transform:SetPosition(inst.x, 0, inst.z)
	else
		inst.Transform:SetPosition(inst.x1, 0, inst.z1)
		inst.components.updatelooper:RemoveOnWallUpdateFn(UpdateFallPos)
		local targets = inst.targets or {}
		DoDamage(inst, targets)

		if TheWorld.Map:IsOceanAtPoint(inst.x1, 0, inst.z1) then
			SpawnPrefab("splash_green_large").Transform:SetPosition(inst.x1, 0, inst.z1)
		elseif inst.formpile then
			local blocked = false
			for i, v in ipairs(TheSim:FindEntities(inst.x1, 0, inst.z1, 5, nil, nil, JUNK_PILE_TAGS)) do
				if v:HasTag("junk_pile_big") then
					blocked = true
					break
				end
				local dsq = v:GetDistanceSqToPoint(inst.x1, 0, inst.z1)
				if v:HasTag("wall") then
					local range = v:GetPhysicsRadius(0) + 1.5
					if dsq < range * range then
						blocked = true
						break
					end
				else--if v:HasTag("junk_pile") then --can assume this is true
					if dsq < 6.25 then
						blocked = true
						break
					end
				end
			end
			if not blocked then
				for k, v in pairs(targets) do
					if v == "worked" then
						if k:IsValid() and k:HasTag("stump") then
							k:Remove()
						end
					elseif v == "attacked" then
						local strengthmult = (k.components.inventory and k.components.inventory:ArmorHasTag("heavyarmor") or k:HasTag("heavybody")) and 0.6 or 1
						k:PushEvent("knockback", { knocker = inst, radius = AOE_RADIUS, strengthmult = strengthmult, forcelanded = true })
					end
				end

				local junk = SpawnPrefab("junk_pile")
				junk.Transform:SetPosition(inst.x1, 0, inst.z1)
				junk.components.workable:SetWorkLeft(1)
				junk:Shake(1, true)
				targets[junk] = "pile"
				targets.pile = junk
			end
		end
	end
end

local function SetupJunkFall(inst, attacker, x, z, x1, z1, formpile, pileupchance, targets)
	inst.attacker = attacker
	inst.formpile = formpile
	inst.pileupchance = pileupchance
	inst.targets = targets

	inst.Transform:SetPosition(x, 0, z)
	inst.t = 0
	inst.x, inst.z = x, z
	inst.x1, inst.z1 = x1, z1
	inst.speedx = (x1 - x) / FALL_TIME
	inst.speedz = (z1 - z) / FALL_TIME
	inst.components.updatelooper:AddOnWallUpdateFn(UpdateFallPos)
end

local function KeepTargetFn()
	return false
end

local function fallfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("NOCLICK")
	inst:AddTag("FX")
	inst:AddTag("junk")

	inst.AnimState:SetBank("scrapball")
	inst.AnimState:SetBuild("scrapball")
	inst.AnimState:PlayAnimation("scrap_fall")

	inst:AddComponent("updatelooper")

	--Dedicated server does not need to spawn the local fx or fade
	if not TheNet:IsDedicated() then
		inst.shadow = CreateShadow(1.3)
		inst.shadow.entity:SetParent(inst.entity)

		inst.components.updatelooper:AddOnUpdateFn(UpdateFallFade)
		UpdateFallFade(inst, 0)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.JUNK_FALL_DAMAGE)
	inst.components.combat:SetRange(AOE_RADIUS)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)

	inst.SetupJunkFall = SetupJunkFall

	return inst
end

--------------------------------------------------------------------------

return Prefab("junkball_fx", fn, assets, prefabs),
	Prefab("junkball_fall_fx", fallfn, assets, prefabs_fall)
