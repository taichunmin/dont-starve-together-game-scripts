local assets =
{
    Asset("ANIM", "anim/winona_catapult_projectile.zip"),
}

local prefabs =
{
	"trap_vines",
	"crab_king_waterspout",
}

local ELEMENTS = { "shadow", "lunar", "hybrid" }
local ELEMENT_ID = table.invert(ELEMENTS)

local NO_TAGS_PVP = { "INLIMBO", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "notarget", "companion", "shadowminion", "wall" }
local NO_TAGS = { "player" }
for i, v in ipairs(NO_TAGS_PVP) do
    table.insert(NO_TAGS, v)
end
local COMBAT_TAGS = { "_combat" }
local AOE_RANGE_PADDING = 3

local function ResetDamage(inst, attacker)
	attacker.components.combat:SetDefaultDamage(TUNING.WINONA_CATAPULT_DAMAGE)
	attacker.components.planardamage:SetBaseDamage(0)
	attacker.components.damagetypebonus:RemoveBonus("shadow_aligned", inst)
	attacker.components.damagetypebonus:RemoveBonus("lunar_aligned", inst)
end

local function ConfigureElementalDamage(inst, attacker, element, mega)
	if element then
		if mega then
			attacker.components.combat:SetDefaultDamage(0)
			if element == "shadow" then
				attacker.components.planardamage:SetBaseDamage(TUNING.WINONA_CATAPULT_PLANAR_DAMAGE)
			else
				attacker.components.planardamage:SetBaseDamage(TUNING.WINONA_CATAPULT_MEGA_PLANAR_DAMAGE)
			end
		elseif element == "hybrid" then
			attacker.components.combat:SetDefaultDamage(TUNING.WINONA_CATAPULT_HYBRID_NON_PLANAR_DAMAGE)
			attacker.components.planardamage:SetBaseDamage(TUNING.WINONA_CATAPULT_HYBRID_PLANAR_DAMAGE)
		else
			attacker.components.combat:SetDefaultDamage(TUNING.WINONA_CATAPULT_NON_PLANAR_DAMAGE)
			attacker.components.planardamage:SetBaseDamage(TUNING.WINONA_CATAPULT_PLANAR_DAMAGE)
		end

		if element == "lunar" or element == "hybrid" then
			attacker.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WINONA_CATAPULT_DAMAGETYPE_MULT)
		end
		if element == "shadow" or element == "hybrid" then
			attacker.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WINONA_CATAPULT_DAMAGETYPE_MULT)
		end
	end
end

local function DoAOEAttack(inst, x, z, attacker, caster, element, mega)
	if attacker and attacker.components.combat and attacker:IsValid() then
		attacker.components.combat.ignorehitrange = true
		ConfigureElementalDamage(inst, attacker, element, mega)
	else
		attacker = nil
	end
	inst.components.combat.ignorehitrange = true
	ConfigureElementalDamage(inst, inst, element, mega)

	local caster_combat = caster and caster:IsValid() and caster.components.combat or nil

	local hit = false
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, inst.AOE_RADIUS + AOE_RANGE_PADDING, COMBAT_TAGS, TheNet:GetPVPEnabled() and NO_TAGS_PVP or NO_TAGS)) do
		if v:IsValid() and
			v.entity:IsVisible() and
			v:GetDistanceSqToPoint(x, 0, z) < inst.components.combat:CalcHitRangeSq(v) and
			inst.components.combat:CanTarget(v)
		then
			local isally
			if caster_combat then
				isally = caster_combat:IsAlly(v)
			elseif not TheNet:GetPVPEnabled() and
				not (v.components.combat and v.components.combat:HasTarget() and v.components.combat.target:HasTag("player")) and
				(	v:HasTag("companion") or
					(v.components.follower and v.components.follower:GetLeader() and v.components.follower:GetLeader():HasTag("player"))
				)
			then
				isally = true
			end

			if not isally then
				if attacker and not (v.components.combat.target and v.components.combat.target:HasTag("player")) then
					--if target is not targeting a player, then use the catapult as attacker to draw aggro
					attacker.components.combat:DoAttack(v)
				else
					inst.components.combat:DoAttack(v)
				end
				hit = true
			end
		end
	end

	if attacker then
		attacker.components.combat.ignorehitrange = false
		ResetDamage(inst, attacker)
	end
	inst.components.combat.ignorehitrange = false
	--ResetDamage(inst, inst) -- don't need, we're gonna be deleted

	inst.SoundEmitter:PlaySound(
		(element == "shadow" and (mega and "meta4/winona_catapult/shadow_projectile_explode" or "meta4/winona_catapult/shadow_projectile_hit")) or
		(element == "lunar" and (mega and "meta4/winona_catapult/lunar_projectile_explode" or "meta4/winona_catapult/lunar_projectile_hit")) or
		(element == "hybrid" and (mega and "meta4/winona_catapult/lunar_shadow_combo_explode" or "meta4/winona_catapult/lunar_shadow_combo_hit")) or
		"dontstarve/common/together/catapult/rock_hit",
		nil, hit and .5 or nil)
end

--------------------------------------------------------------------------

local WORK_RADIUS_PADDING = 0.5
local COLLAPSIBLE_WORK_ACTIONS =
{
	CHOP = true,
	DIG = true,
	HAMMER = true,
	MINE = true,
}
local COLLAPSIBLE_TAGS = { "NPC_workable" }
local COLLAPSIBLE_TAGS_OCEAN = { "kelp", "NPC_workable" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
	local tag = k.."_workable"
	table.insert(COLLAPSIBLE_TAGS, tag)
	table.insert(COLLAPSIBLE_TAGS_OCEAN, tag)
end

local NON_COLLAPSIBLE_TAGS = { "FX", --[["NOCLICK",]] "DECOR", "INLIMBO", --[["structure",]] "wall", "walkableperipheral" }

local function DoAOEWork(inst, x, z, isocean)
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, inst.AOE_RADIUS + WORK_RADIUS_PADDING, nil, NON_COLLAPSIBLE_TAGS, isocean and COLLAPSIBLE_TAGS_OCEAN or COLLAPSIBLE_TAGS)) do
		if v:IsValid() and not v:IsInLimbo() then
			if v.prefab == "bullkelp_plant" then
				--Spawn kelp roots along with kelp is a bullkelp plant is hit
				local x1, y1, z1 = v.Transform:GetWorldPosition()

				local loot = SpawnPrefab("bullkelp_root")
				loot.Transform:SetPosition(x1, 0, z1)

				if v.components.pickable and v.components.pickable:CanBePicked() then
					loot = SpawnPrefab(v.components.pickable.product)
					if loot then
						loot.Transform:SetPosition(x1, 0, z1)
						if loot.components.inventoryitem then
							loot.components.inventoryitem:MakeMoistureAtLeast(TUNING.OCEAN_WETNESS)
						end
						if loot.components.stackable and v.components.pickable.numtoharvest > 1 then
							loot.components.stackable:SetStackSize(v.components.pickable.numtoharvest)
						end
					end
				end

				v:Remove()
			elseif (not v:HasTag("structure") or
					(v.components.childspawner and not v:HasTag("playerowned")) or
					(v:HasTag("statue") and not v:HasTag("sculpture")) or
					v:HasTag("smashable")
				)
			then
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
					if v:IsValid() and v:HasTag("stump") and v.components.workable and v.components.workable:CanBeWorked() then
						v.components.workable:Destroy(inst)
					end
				elseif v.components.pickable and v.components.pickable:CanBePicked() and not v:HasTag("intense") then
					v.components.pickable:Pick(inst)
				end
			end
		end
	end
end

local TOSSITEM_MUST_TAGS = { "_inventoryitem" }
local TOSSITEM_CANT_TAGS = { "locomotor", "INLIMBO" }

local function TossLaunch(obj, x0, z0, basespeed, startheight)
	local x1, y1, z1 = obj.Transform:GetWorldPosition()
	local dx, dz = x1 - x0, z1 - z0
	local dsq = dx * dx + dz * dz
	local angle
	if dsq > 0 then
		local dist = math.sqrt(dsq)
		angle = math.atan2(dz / dist, dx / dist)
		if obj.prefab == "bullkelp_root" then
			--prevent overlap with pickable loot spawned at the same time
			local rnd = math.random() * 40
			angle = angle + (rnd < 20 and 60 + rnd or -(40 + rnd)) * DEGREES
		else
			angle = angle + (math.random() * 20 - 10) * DEGREES
		end
	else
		angle = TWOPI * math.random()
	end
	local speed = basespeed + math.random()
	obj.Physics:Teleport(x1, startheight, z1)
	obj.Physics:SetVel(math.cos(angle) * speed, speed * 5 + math.random() * 2, math.sin(angle) * speed)
end

local function TossItems(inst, x, z, isocean)
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, inst.AOE_RADIUS + WORK_RADIUS_PADDING, TOSSITEM_MUST_TAGS, TOSSITEM_CANT_TAGS)) do
		if v.components.mine then
			v.components.mine:Deactivate()
		end
		if not v.components.inventoryitem.nobounce and v.Physics and v.Physics:IsActive() then
			TossLaunch(v, x, z, 1, 0.4)
			if isocean then
				v.components.inventoryitem:SetLanded(false, true)
			end
		end
	end
end

--------------------------------------------------------------------------

local OCEAN_ONE_OF_TAGS = { "oceanfishable", "wave" }
local OCEAN_NO_TAGS = { "INLIMBO", "noattack", "flight", "invisible" }

local function DoOceanFishing(inst, x, z)
	-- Set y to zero to look for objects floating on the ocean
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, inst.AOE_RADIUS + WORK_RADIUS_PADDING, nil, OCEAN_NO_TAGS, OCEAN_ONE_OF_TAGS)) do
		-- Look for fish in the splash radius, kill and spawn their loot if hit
		if v.components.oceanfishable then
			if v.fish_def and v.fish_def.loot then
				for j, product in ipairs(v.fish_def.loot) do
					local loot = SpawnPrefab(product)
					if loot then
						local x1, y1, z1 = v.Transform:GetWorldPosition()
						loot.Transform:SetPosition(x1, 0, z1)
					end
				end
				v:Remove()
			end
		elseif v.waveactive then
			v:DoSplash()
		end
	end

	SpawnPrefab("crab_king_waterspout").Transform:SetPosition(x, 0, z)
end

--------------------------------------------------------------------------

local TRAP_TAGS = { "trap_vines" }
local DEPLOY_IGNORE_TAGS = { "flower", "_inventoryitem", "projectile", "trap_vines", "NOBLOCK", "locomotor", "character", "invisible", "FX", "INLIMBO", "DECOR" }

local function SpawnTrapRing(inst, x, z, attacker, caster, r, n, theta)
	local delta = TWOPI / n
	local map = TheWorld.Map
	local pt = Vector3(0, 0, 0)
	for i = 1, n do
		pt.x = x + r * math.cos(theta)
		pt.z = z - r * math.sin(theta)
		if map:IsPassableAtPoint(pt.x, 0, pt.z, false, true) and map:IsDeployPointClear(pt, nil, 1, nil, nil, nil, DEPLOY_IGNORE_TAGS) then
			for _, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, 1, TRAP_TAGS)) do
				v:DespawnTrap()
			end
			local trap = SpawnPrefab("trap_vines")
			trap.Transform:SetPosition(pt:Get())
			trap.attacker = attacker
			trap.caster = caster

			if not inst._vinesfxstarted then
				inst._vinesfxstarted = true
				trap:StartSoundLoop()
			end
		end
		theta = theta + delta
	end
end

--attacker is the catapult, caster is the player if available
local function SpawnAOETrap(inst, x, z, attacker, caster)
	local theta = math.random() * TWOPI

	if inst.AOE_LEVEL == 1 then
		SpawnTrapRing(inst, x, z, attacker, caster, 0, 1, theta)
		SpawnTrapRing(inst, x, z, attacker, caster, 1.6, 5, theta)
		SpawnTrapRing(inst, x, z, attacker, caster, 3, 10, theta + TWOPI / 20)
	else
		SpawnTrapRing(inst, x, z, attacker, caster, 1, 3, theta)
		SpawnTrapRing(inst, x, z, attacker, caster, 2.4, 8, theta + TWOPI / 15)
		if inst.AOE_LEVEL >= 2 then
			SpawnTrapRing(inst, x, z, attacker, caster, 3.7, 12, theta + TWOPI / 2)
			if inst.AOE_LEVEL >= 3 then
				SpawnTrapRing(inst, x, z, attacker, caster, 5, 16, theta + TWOPI / 91)
			end
		end
	end
end

--------------------------------------------------------------------------

local function CreateAOEBase(anim, scale)
	local inst = CreateEntity()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false) --commented out; follow parent sleep instead
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.AnimState:SetBank("winona_catapult_projectile")
	inst.AnimState:SetBuild("winona_catapult_projectile")
	inst.AnimState:PlayAnimation(anim)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	if scale then
		inst.AnimState:SetScale(scale, scale)
	end

	inst.persists = false

	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

local function OnAOEBaseDirty(inst)
	local fx
	local scale = TUNING.WINONA_CATAPULT_AOE_RADIUS / 2.5
	local aoelevel = inst.aoebase:value()
	if aoelevel >= 4 then
		--mega lunar or hybrid
		aoelevel = aoelevel - 4
		fx = CreateAOEBase("aoe_special", scale * (TUNING.SKILLS.WINONA.CATAPULT_AOE_RADIUS_MULT[aoelevel] or 1))
		if inst.AnimState:IsCurrentAnimation("impact"..(aoelevel ~= 0 and tostring(aoelevel) or "").."_special") then
			fx.AnimState:SetTime(inst.AnimState:GetCurrentAnimationTime())
		end
	else
		local element = ELEMENTS[inst.element:value()]
		fx = CreateAOEBase("aoe_"..(element or "dirt"), scale * (TUNING.SKILLS.WINONA.CATAPULT_AOE_RADIUS_MULT[aoelevel] or 1))
		if inst.AnimState:IsCurrentAnimation("impact"..(aoelevel ~= 0 and tostring(aoelevel) or "")..(element and ("_"..element) or "")) then
			fx.AnimState:SetTime(inst.AnimState:GetCurrentAnimationTime())
		end
	end
	fx.entity:SetParent(inst.entity)
end

local function OnHit(inst, attacker, target)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Physics:Stop()
    inst.Physics:Teleport(x, 0, z)

	local element = ELEMENTS[inst.element:value()]
	if not inst.mega then
		inst.AnimState:PlayAnimation("impact"..(inst.AOE_LEVEL ~= 0 and tostring(inst.AOE_LEVEL) or "")..(element and ("_"..element) or ""))
		inst.aoebase:set_local(0) --force dirty in case level 0
		inst.aoebase:set(inst.AOE_LEVEL)
		--Dedicated server does not need to spawn the local fx
		if not TheNet:IsDedicated() then
			OnAOEBaseDirty(inst)
		end
	elseif element == "shadow" then
		inst.AnimState:PlayAnimation("shadow_absorb")
	else--hybrid or lunar => show the lunar
		inst.AnimState:PlayAnimation("impact"..(inst.AOE_LEVEL ~= 0 and tostring(inst.AOE_LEVEL) or "").."_special")
		inst.aoebase:set(4 + inst.AOE_LEVEL)
		--Dedicated server does not need to spawn the local fx
		if not TheNet:IsDedicated() then
			OnAOEBaseDirty(inst)
		end
	end
    inst:ListenForEvent("animover", inst.Remove)

    inst.hideanim:set(true)
    if inst.animent ~= nil then
        inst.animent:Remove()
        inst.animent = nil
    end

	local isocean = TheWorld.Map:IsOceanAtPoint(x, y, z)
	if inst.mega and (element == "lunar" or element == "hybrid") then
		inst:AddTag("toughworker")
		DoAOEWork(inst, x, z, isocean)
		ShakeAllCameras(CAMERASHAKE.FULL, 0.7, 0.02, 0.4, inst, 15 + inst.AOE_RADIUS)
	end
	if isocean then
		DoOceanFishing(inst, x, z)
	end
	--if not (inst.mega and element == "shadow") then
		DoAOEAttack(inst, x, z, attacker, inst.caster, element, inst.mega)
	--end
	if inst.mega and (element == "shadow" or element == "hybrid") then
		SpawnAOETrap(inst, x, z, attacker, inst.caster)
	end
	if inst.mega and (element == "lunar" or element == "hybrid") or isocean then
		TossItems(inst, x, z, isocean)
	end
end

local function KeepTargetFn(inst)
    return false
end

local function CreateProjectileAnim()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("winona_catapult_projectile")
    inst.AnimState:SetBuild("winona_catapult_projectile")
	inst.AnimState:PlayAnimation("air_rock", true)

    return inst
end

local function OnHideAnimDirty(inst)
    if inst.hideanim:value() and inst.animent ~= nil then
        inst.animent:Remove()
        inst.animent = nil
    end
end

--------------------------------------------------------------------------

local function OnElementDirty(inst)
	if inst.animent then
		local element = ELEMENTS[inst.element:value()]
		inst.animent.AnimState:PlayAnimation("air_"..(element or "rock"), true)
		if element == "lunar" then
			inst.animent.AnimState:SetSymbolBloom("white_parts")
			inst.animent.AnimState:SetSymbolLightOverride("white_parts", 0.1)
		elseif element == "shadow" then
			inst.animent.AnimState:SetSymbolLightOverride("red_parts", 1)
		elseif element == "hybrid" then
			inst.animent.AnimState:SetSymbolBloom("white_parts")
			inst.animent.AnimState:SetSymbolLightOverride("white_parts", 0.1)
			inst.animent.AnimState:SetSymbolLightOverride("red_parts", 1)
		end
	end
end

local function SetElementalRock(inst, element, mega)
	inst.mega = mega or false
	local elem = ELEMENT_ID[element] or 0
	if elem ~= inst.element:value() then
		inst.element:set(elem)
		OnElementDirty(inst)
	end
end

local function SetAoeRadius(inst, radius, level)
	inst.AOE_RADIUS = radius or TUNING.WINONA_CATAPULT_AOE_RADIUS
	inst.AOE_LEVEL = level or 0
	inst.components.combat:SetRange(inst.AOE_RADIUS)
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("winona_catapult_projectile")
    inst.AnimState:SetBuild("winona_catapult_projectile")
    inst.AnimState:PlayAnimation("empty")
	inst.AnimState:SetSymbolLightOverride("red_parts", 1)
	inst.AnimState:SetSymbolLightOverride("white_parts_fx", 0.1)
	inst.AnimState:SetSymbolLightOverride("white_parts", 0.1)
	inst.AnimState:SetSymbolBloom("white_parts")

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
	inst.Physics:SetRestitution(0)
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetSphere(.4)

    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")

    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.hideanim = net_bool(inst.GUID, "winona_catapult_projectile.hideanim", "hideanimdirty")
	inst.element = net_tinybyte(inst.GUID, "winona_catapult_projectile.element", "elementdirty")
	inst.aoebase = net_tinybyte(inst.GUID, "winona_catapult_projectile.aoebase")

    --Dedicated server does not need to spawn the local animation
    if not TheNet:IsDedicated() then
        inst.animent = CreateProjectileAnim()
        inst.animent.entity:SetParent(inst.entity)

        if not TheWorld.ismastersim then
            inst:ListenForEvent("hideanimdirty", OnHideAnimDirty)
			inst:ListenForEvent("elementdirty", OnElementDirty)
        end
    end

    inst:SetPrefabNameOverride("winona_catapult") --for death announce

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.AOE_RADIUS = TUNING.WINONA_CATAPULT_AOE_RADIUS
	inst.AOE_LEVEL = 0
	inst.mega = false

    local complexprojectile = inst:AddComponent("complexprojectile")
    complexprojectile:SetGravity(-100)
    complexprojectile:SetLaunchOffset(Vector3(1.25, 3, 0))
    complexprojectile:SetHorizontalSpeedForDistance(TUNING.WINONA_CATAPULT_MAX_RANGE, 35)
    complexprojectile:SetOnHit(OnHit)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.WINONA_CATAPULT_DAMAGE)
	inst.components.combat:SetRange(inst.AOE_RADIUS)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

	inst:AddComponent("planardamage")
	inst:AddComponent("damagetypebonus")

	inst.SetElementalRock = SetElementalRock
	inst.SetAoeRadius = SetAoeRadius

    inst.persists = false

    return inst
end

return Prefab("winona_catapult_projectile", fn, assets, prefabs)
