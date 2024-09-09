local assets_despawn_fx =
{
	Asset("ANIM", "anim/statue_ruins_fx.zip"),
}

local prefabs =
{
    "shadow_despawn",
	"shadow_glob_fx",
    "statue_transition_2",
    "nightmarefuel",
	"ocean_splash_med1",
	"ocean_splash_med2",
	"ocean_splash_small1",
	"ocean_splash_small2",
}

local brain = require("brains/shadowwaxwellbrain")

local function SaveSpawnPoint(inst, dont_overwrite)
	if not dont_overwrite or
		(	inst.components.knownlocations:GetLocation("spawn") == nil and
			inst.components.knownlocations:GetLocation("spawnplatform") == nil
		) then
		local x, y, z = inst.Transform:GetWorldPosition()
		local platform = TheWorld.Map:GetPlatformAtPoint(x, z)
		if platform ~= nil then
			x, y, z = platform.entity:WorldToLocalSpace(x, 0, z)
			inst.components.knownlocations:ForgetLocation("spawn")
			inst.components.knownlocations:RememberLocation("spawnplatform", Vector3(x, 0, z))
			inst.components.entitytracker:TrackEntity("spawnplatform", platform)
		else
			inst.components.entitytracker:ForgetEntity("spawnplatform")
			inst.components.knownlocations:ForgetLocation("spawnplatform")
			inst.components.knownlocations:RememberLocation("spawn", Vector3(x, 0, z))
		end
	end
end

local function GetSpawnPoint(inst)
	local pt = inst.components.knownlocations:GetLocation("spawn")
	if pt ~= nil then
		return pt
	end
	pt = inst.components.knownlocations:GetLocation("spawnplatform")
	if pt ~= nil then
		local platform = inst.components.entitytracker:GetEntity("spawnplatform")
		if platform ~= nil then
			local x, y, z = platform.entity:LocalToWorldSpace(pt:Get())
			return Vector3(x, 0, z)
		end
	end
end

local function MakeSpawnPointTracker(inst)
	inst:AddComponent("knownlocations")
	inst:AddComponent("entitytracker")
	inst.SaveSpawnPoint = SaveSpawnPoint
	inst.GetSpawnPoint = GetSpawnPoint
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        if data.attacker.components.petleash ~= nil and
            data.attacker.components.petleash:IsPet(inst) then
			if inst.despawnpetloot then
				if inst.components.lootdropper == nil then
					inst:AddComponent("lootdropper")
				end
				inst.components.lootdropper:SpawnLootPrefab("nightmarefuel", inst:GetPosition())
			end
            data.attacker.components.petleash:DespawnPet(inst)
        elseif data.attacker.components.combat ~= nil then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end
end

local function DoRemove(inst)
	if inst.components.inventory ~= nil then
		inst.components.inventory:DropEverything(true)
	end
	inst:Remove()
end

local function OnSeekOblivion(inst)
	if inst:IsAsleep() then
		DoRemove(inst)
		return
	end
	inst.components.timer:StopTimer("obliviate")
	if inst.components.health == nil then
		inst.sg:GoToState("quickdespawn")
	elseif inst.components.health:IsInvincible() then
		--reschedule
		inst.components.timer:StartTimer("obliviate", .5)
	else
		inst:StopBrain()
		inst:SetBrain(nil)
		inst.components.health:Kill()
	end
end

local function OnTimerDone(inst, data)
    if data and data.name == "obliviate" then
        OnSeekOblivion(inst)
    end
end

local function OnEntitySleep(inst)
	if inst._obliviatetask == nil then
		inst._obliviatetask = inst:DoTaskInTime(TUNING.SHADOWWAXWELL_MINION_IDLE_DESPAWN_TIME, DoRemove)
	end
end

local function OnEntityWake(inst)
	if inst._obliviatetask ~= nil then
		inst._obliviatetask:Cancel()
		inst._obliviatetask = nil
	end
end

local function MakeOblivionSeeker(inst, duration)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("obliviate", duration)
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
end

local function DropAggro(inst)
	local leader = inst.components.follower:GetLeader()
	if leader ~= nil and
		(	(leader.components.health ~= nil and leader.components.health:IsDead()) or
			(leader.sg ~= nil and leader.sg:HasStateTag("hiding")) or
			not inst:IsNear(leader, TUNING.SHADOWWAXWELL_PROTECTOR_TRANSFER_AGGRO_RANGE) or
			not leader.entity:IsVisible() or
			leader:HasTag("playerghost")
		) then
		--dead, hiding, or too far
		leader = nil
	end
	--nil leader will just drop target
	inst:PushEvent("transfercombattarget", leader)
end

local function OnDancingPlayerData(inst, data)
    if data == nil then
        return
    end

    local player = data.inst
    if player == nil or player ~= inst.components.follower:GetLeader() then
        return
    end

    inst._brain_dancedata = data.dancedata
end

local RETARGET_MUST_TAGS = { "_combat" } -- see entityreplica.lua
local RETARGET_CANT_TAGS = { "playerghost", "INLIMBO" }
local function spearretargetfn(inst)
    --Find things attacking leader
    local leader = inst.components.follower:GetLeader()
    return leader ~= nil
        and FindEntity(
            leader,
            TUNING.SHADOWWAXWELL_TARGET_DIST,
            function(guy)
                return guy ~= inst
                    and (guy.components.combat:TargetIs(leader) or
                        guy.components.combat:TargetIs(inst))
                    and inst.components.combat:CanTarget(guy)
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS
        )
        or nil
end
local function spearkeeptargetfn(inst, target)
    --Is your leader nearby and your target not dead? Stay on it.
    --Match KEEP_WORKING_DIST in brain
    return inst.components.follower:IsNearLeader(14)
        and inst.components.combat:CanTarget(target)
		and target.components.minigame_participator == nil
end
--deprecated
local function spearfn(inst)
    inst.components.health:SetMaxHealth(TUNING.SHADOWWAXWELL_LIFE)
    inst.components.health:StartRegen(TUNING.SHADOWWAXWELL_HEALTH_REGEN, TUNING.SHADOWWAXWELL_HEALTH_REGEN_PERIOD)

    inst.components.combat:SetDefaultDamage(TUNING.SHADOWWAXWELL_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SHADOWWAXWELL_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(2, spearretargetfn) --Look for leader's target.
    inst.components.combat:SetKeepTargetFunction(spearkeeptargetfn) --Keep attacking while leader is near.

	inst.despawnpetloot = true

    return inst
end

--[=[local function protectorretargetfn_test(inst, target)
    if inst == target then
        return false
    end

	if target.components.minigame_participator ~= nil then
		return false
	end

    if (target:HasTag("player") and not TheNet:GetPVPEnabled()) or target:HasTag("ghost") then
        return false
    end

    local leader = inst.components.follower.leader
    if leader ~= nil
        and (leader == target
            or (target.components.follower ~= nil and
                target.components.follower.leader == leader)) then
        return false
    end

    if inst.components.combat.target == target then
        print("target is target")
        return true
    end

    local targettarget = target.components.combat.target
    if targettarget ~= nil
        and (targettarget:HasTag("player") or targettarget:HasTag("shadowminion"))
        and inst.components.combat:CanTarget(target) then
        print("target is attacking a friend")
        return true
    end

    local ismonster = target:HasTag("monster")
    if ismonster and not TheNet:GetPVPEnabled() and 
       ((target.components.follower and target.components.follower.leader ~= nil and 
         target.components.follower.leader:HasTag("player")) or target.bedazzled) then
        return false
    end

    if target:HasTag("companion") then
        return false
    end

    return ismonster or target:HasTag("prey")
end]=]

local COMBAT_MUSHAVE_TAGS = { "_combat", "_health" }
local COMBAT_CANTHAVE_TAGS = { "INLIMBO", "companion" }
local COMBAT_MUSTONEOF_TAGS_AGGRESSIVE = { "monster", "prey", "insect", "hostile", "character", "animal" }
local function HasFriendlyLeader(inst, target)
    local leader = inst.components.follower.leader
    if leader ~= nil then
        local target_leader = (target.components.follower ~= nil) and target.components.follower.leader or nil

        if target_leader and target_leader.components.inventoryitem then
            target_leader = target_leader.components.inventoryitem:GetGrandOwner()
            -- Don't attack followers if their follow object has no owner
            if target_leader == nil then
                return true
            end
        end

        local PVP_enabled = TheNet:GetPVPEnabled()

        return leader == target or (target_leader ~= nil
                and (target_leader == leader or (target_leader:HasTag("player")
                and not PVP_enabled))) or
                (target.components.domesticatable and target.components.domesticatable:IsDomesticated()
                and not PVP_enabled) or
                (target.components.saltlicker and target.components.saltlicker.salted
                and not PVP_enabled)
    end

    return false
end
local function protectorretargetfn(inst)
	if inst.sg:HasStateTag("dancing") then
		return nil
	end

	local spawn = inst:GetSpawnPoint()
    if spawn == nil then
        return nil
    end

    local target = nil
    local ents = TheSim:FindEntities(spawn.x, spawn.y, spawn.z, TUNING.SHADOWWAXWELL_PROTECTOR_DEFEND_RADIUS, COMBAT_MUSHAVE_TAGS, COMBAT_CANTHAVE_TAGS, COMBAT_MUSTONEOF_TAGS_AGGRESSIVE)
    for _, ent in ipairs(ents) do
        --if protectorretargetfn_test(inst, ent) then
        if ent ~= inst and ent.entity:IsVisible()
        and inst.components.combat:CanTarget(ent)
        and ent.components.minigame_participator == nil
        and not HasFriendlyLeader(inst, ent) then
            target = ent
            break
        end
    end

    return target
end
local function protectorkeeptargetfn(inst, target)
    -- Maintain the target if it is able to.
    return inst.components.combat:CanTarget(target)
		and not inst.sg:HasStateTag("dancing")
		and target.components.minigame_participator == nil
        and (not target:HasTag("player") or TheNet:GetPVPEnabled())
end
local function protector_updatehealthclamp(inst)
	local cap = math.abs(inst.components.health.maxdamagetakenperhit)
	cap = cap + math.abs(TUNING.SHADOWWAXWELL_PROTECTOR_HEALTH_CLAMP_INCREASE)
	cap = math.min(cap, math.max(1, inst.components.health.maxhealth - 1))
	inst.components.health:SetMaxDamageTakenPerHit(cap)
end
local function protector_onengaged(inst)
	if inst.disengagetask ~= nil then
		inst.disengagetask:Cancel()
		inst.disengagetask = nil
	end
	if inst.engagedtask == nil then
		inst.engagedtask = inst:DoPeriodicTask(TUNING.SHADOWWAXWELL_PROTECTOR_HEALTH_CLAMP_PERIOD, protector_updatehealthclamp, TUNING.SHADOWWAXWELL_PROTECTOR_HEALTH_CLAMP_INITIAL_PERIOD)
	end
end
local function protector_resethealthclamp(inst)
	inst.disengagetask = nil
	if inst.engagedtask ~= nil then
		inst.engagedtask:Cancel()
		inst.engagedtask = nil
	end
	inst.components.health:SetMaxDamageTakenPerHit(TUNING.SHADOWWAXWELL_PROTECTOR_HEALTH_CLAMP_TAKEN)
end
local function protector_ondisengaged(inst)
	if inst.disengagetask == nil then
		inst.disengagetask = inst:DoTaskInTime(TUNING.SHADOWWAXWELL_PROTECTOR_HEALTH_CLAMP_INITIAL_PERIOD, protector_resethealthclamp)
	end
end
local function protector_attacked(inst, data)
	if data ~= nil and data.damage ~= nil and data.damage > 0 then
		inst.components.health:SetMaxDamageTakenPerHit(TUNING.SHADOWWAXWELL_PROTECTOR_HEALTH_CLAMP_TAKEN)
		if inst.engagedtask ~= nil then
			inst.engagedtask:Cancel()
			inst.engagedtask = inst:DoPeriodicTask(TUNING.SHADOWWAXWELL_PROTECTOR_HEALTH_CLAMP_PERIOD, protector_updatehealthclamp, TUNING.SHADOWWAXWELL_PROTECTOR_HEALTH_CLAMP_INITIAL_PERIOD)
		end
	end
end
local function protectorfn(inst)
    inst.components.health:SetMaxHealth(TUNING.SHADOWWAXWELL_PROTECTOR_LIFE)
    inst.components.health:SetMaxDamageTakenPerHit(TUNING.SHADOWWAXWELL_PROTECTOR_HEALTH_CLAMP_TAKEN)

    inst.components.combat:SetDefaultDamage(TUNING.SHADOWWAXWELL_PROTECTOR_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SHADOWWAXWELL_PROTECTOR_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, protectorretargetfn)
    inst.components.combat:SetKeepTargetFunction(protectorkeeptargetfn)

    inst.components.locomotor.runspeed = TUNING.SHADOWWAXWELL_PROTECTOR_SPEED

	inst.components.follower.noleashing = true

	MakeSpawnPointTracker(inst)
	MakeOblivionSeeker(inst, TUNING.SHADOWWAXWELL_PROTECTOR_DURATION + math.random())

	inst:ListenForEvent("newcombattarget", protector_onengaged)
	inst:ListenForEvent("droppedtarget", protector_ondisengaged)
	inst:ListenForEvent("attacked", protector_attacked)
end

local function nokeeptargetfn(inst)
    return false
end

--deprecated
local function noncombatantfn(inst)
    inst.components.combat:SetKeepTargetFunction(nokeeptargetfn)
	inst.despawnpetloot = true
end

local function dancerfn(inst)
	inst.components.combat:SetKeepTargetFunction(nokeeptargetfn)
end

local function workerfn(inst)
    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1

    inst.components.combat:SetKeepTargetFunction(nokeeptargetfn)

	inst.components.follower.noleashing = true

	MakeSpawnPointTracker(inst)
	MakeOblivionSeeker(inst, TUNING.SHADOWWAXWELL_WORKER_DURATION + math.random())
end

local function nodebrisdmg(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    return afflicter ~= nil and afflicter:HasTag("quakedebris")
end

--------------------------------------------------------------------------

local function OnRippleAnimOver(inst)
	if inst.pool.invalid then
		inst:Remove()
	else
		inst:Hide()
		table.insert(inst.pool, inst)
	end
end

local function CreateRipple(pool)
	local inst
	if #pool > 0 then
		inst = table.remove(pool)
		inst:Show()
	else
		inst = CreateEntity()

		inst:AddTag("FX")
		inst:AddTag("NOCLICK")
		--[[Non-networked entity]]
		inst.entity:SetCanSleep(false)
		inst.persists = false

		inst.entity:AddTransform()
		inst.entity:AddAnimState()

		inst.AnimState:SetBank("splash_weregoose_fx")
		inst.AnimState:SetBuild("splash_water_drop")
		inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
		inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

		inst.pool = pool
		inst:ListenForEvent("animover", OnRippleAnimOver)
	end

	inst.AnimState:PlayAnimation(math.random() < .5 and "no_splash" or "no_splash2")
	local scale = .6 + math.random() * .2
	inst.AnimState:SetScale(math.random() < .5 and -scale or scale, scale)

	return inst
end

local function TryRipple(inst, map)
	if not (inst:HasTag("moving") or
			inst.AnimState:IsCurrentAnimation("appear") or
			inst.AnimState:IsCurrentAnimation("disappear") or
			inst.AnimState:IsCurrentAnimation("lunge_pst")
		) then
		local x, y, z = inst.Transform:GetWorldPosition()
		if map:IsOceanAtPoint(x, 0, z) then
			CreateRipple(inst.ripple_pool).Transform:SetPosition(x, 0, z)
		end
	end
end

local function OnRemoveEntity(inst)
	for i, v in ipairs(inst.ripple_pool) do
		v:Remove()
	end
	inst.ripple_pool.invalid = true
end

--------------------------------------------------------------------------

local function MakeMinion(prefab, tool, hat, master_postinit)
    local assets =
    {
        Asset("PKGREF", "anim/waxwell_shadow_mod.zip"), -- Deprecated asset but mods might use it.
        Asset("SOUND", "sound/maxwell.fsb"),

		Asset("ANIM", "anim/waxwell_minion_spawn.zip"),
		Asset("ANIM", "anim/waxwell_minion_appear.zip"),
		Asset("ANIM", "anim/splash_weregoose_fx.zip"),
		Asset("ANIM", "anim/splash_water_drop.zip"),
    }

	local prefabs_override

	local isprotector = prefab == "shadowprotector"
	if isprotector then
		table.insert(assets, Asset("ANIM", "anim/lavaarena_shadow_lunge.zip"))
		table.insert(assets, Asset("ANIM", "anim/waxwell_minion_idle.zip"))

		prefabs_override = shallowcopy(prefabs)
		table.insert(prefabs_override, "shadowstrike_slash_fx")
		table.insert(prefabs_override, "shadowstrike_slash2_fx")
	end

    local onetool = type(tool) == "string"
    if onetool then
        table.insert(assets, Asset("ANIM", "anim/" .. tool .. ".zip"))
    elseif tool ~= nil then -- Assume tool is table for new input syntax.
        for _, toolname in ipairs(tool) do
            table.insert(assets, Asset("ANIM", "anim/" .. toolname .. ".zip"))
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

		inst:SetPhysicsRadiusOverride(.5)
		MakeGhostPhysics(inst, 1, inst.physicsradiusoverride)

        inst.Transform:SetFourFaced(inst)

        inst.AnimState:SetBank("wilson")
        inst.AnimState:SetBuild("waxwell") -- "waxwell_shadow_mod" Deprecated.
        inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
		inst.AnimState:PlayAnimation("minion_spawn")
        inst.AnimState:SetMultColour(0, 0, 0, .5)
        inst.AnimState:UsePointFiltering(true)

		inst.AnimState:AddOverrideBuild("waxwell_minion_spawn")
		inst.AnimState:AddOverrideBuild("waxwell_minion_appear")
		if isprotector then
			inst.AnimState:AddOverrideBuild("lavaarena_shadow_lunge")
		end

        if onetool then
            inst.AnimState:OverrideSymbol("swap_object", tool, tool)
            inst.AnimState:Hide("ARM_normal")
        else
            inst.AnimState:Hide("ARM_carry")
        end

        if hat ~= nil then
            inst.AnimState:OverrideSymbol("swap_hat", hat, "swap_hat")
            inst.AnimState:Hide("HAIR_NOHAT")
            inst.AnimState:Hide("HAIR")
        else
            inst.AnimState:Hide("HAT")
            inst.AnimState:Hide("HAIR_HAT")
        end

        inst:AddTag("scarytoprey")
        inst:AddTag("shadowminion")
        inst:AddTag("NOBLOCK")

        inst:SetPrefabNameOverride("shadowwaxwell")

		--Dedicated server does not need to spawn the local fx
		if not TheNet:IsDedicated() then
			inst.ripple_pool = {}
			inst:DoPeriodicTask(.6, TryRipple, math.random() * .6, TheWorld.Map)
			inst.OnRemoveEntity = OnRemoveEntity
		end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("skinner")
        inst.components.skinner:SetupNonPlayerData()

        inst:AddComponent("locomotor")
        inst.components.locomotor.runspeed = TUNING.SHADOWWAXWELL_SPEED
	    inst.components.locomotor:SetTriggersCreep(false)
        inst.components.locomotor.pathcaps = { ignorecreep = true }
        inst.components.locomotor:SetSlowMultiplier(.6)

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(1)
        inst.components.health.nofadeout = true
        inst.components.health.redirect = nodebrisdmg

        inst:AddComponent("combat")
        inst.components.combat.hiteffectsymbol = "torso"
        inst.components.combat:SetRange(2)

        inst:AddComponent("follower")
        inst.components.follower:KeepLeaderOnAttacked()
        inst.components.follower.keepdeadleader = true
        inst.components.follower.keepleaderduringminigame = true

        inst:SetBrain(brain)
        inst:SetStateGraph("SGshadowwaxwell")

        inst:ListenForEvent("attacked", OnAttacked)
        inst:ListenForEvent("seekoblivion", OnSeekOblivion)
		inst:ListenForEvent("death", DropAggro)
        inst:ListenForEvent("dancingplayerdata", function(world, data) OnDancingPlayerData(inst, data) end, TheWorld)

		inst.DropAggro = DropAggro
		inst.isprotector = isprotector

        if master_postinit ~= nil then
            master_postinit(inst)
        end

        return inst
    end

	return Prefab(prefab, fn, assets, prefabs_override or prefabs)
end

--------------------------------------------------------------------------

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function onbuilt(inst, builder)
    local theta = math.random() * TWOPI
    local pt = builder:GetPosition()
    local radius = math.random(3, 6)
    local offset = FindWalkableOffset(pt, theta, radius, 12, true, true, NoHoles)
    if offset ~= nil then
        pt.x = pt.x + offset.x
        pt.z = pt.z + offset.z
    end
    builder.components.petleash:SpawnPetAt(pt.x, 0, pt.z, inst.pettype)
    inst:Remove()
end

local function MakeBuilder(prefab)
    --These shadows are summoned this way because petleash needs to
    --be the component that summons the pets, not the builder.
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        inst:AddTag("CLASSIFIED")

        --[[Non-networked entity]]
        inst.persists = false

        --Auto-remove if not spawned by builder
        inst:DoTaskInTime(0, inst.Remove)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.pettype = prefab
        inst.OnBuiltFn = onbuilt

        return inst
    end

    return Prefab(prefab.."_builder", fn, nil, { prefab })
end

--------------------------------------------------------------------------
-- We want these FX to sync tightly with anims or entity removal, so don't use fx.lua

local function DoDespawnFxSound(inst)
	inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_despawn")
end

local function despawn_fx_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("statue_ruins_fx")
	inst.AnimState:SetBuild("statue_ruins_fx")
	inst.AnimState:PlayAnimation("transform_nightmare")
	inst.AnimState:SetMultColour(1, 1, 1, .5)
	inst.AnimState:UsePointFiltering(true)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:DoTaskInTime(0, DoDespawnFxSound)

	inst:ListenForEvent("animover", inst.Remove)
	inst.persists = false

	return inst
end

--------------------------------------------------------------------------

return Prefab("shadow_despawn", despawn_fx_fn, assets_despawn_fx),
	MakeMinion("shadowdancer", nil, nil, dancerfn), -- A Little Drama mock shadow clone created by stage play.
    -- Maxwell refresh 2022 created by spells no crafting UI builder.
    MakeMinion("shadowworker", {"swap_axe", "swap_pickaxe", "swap_shovel"}, nil, workerfn),
    MakeMinion("shadowprotector", "swap_nightmaresword_shadow", nil, protectorfn),
    -- DEPRECATED, keep for mods.
    MakeMinion("shadowduelist", "swap_nightmaresword_shadow", nil, spearfn),
    MakeBuilder("shadowduelist"),
    MakeMinion("shadowlumber", "swap_axe", nil, noncombatantfn),
    MakeMinion("shadowminer", "swap_pickaxe", nil, noncombatantfn),
    MakeMinion("shadowdigger", "swap_shovel", nil, noncombatantfn),
    MakeBuilder("shadowlumber"),
    MakeBuilder("shadowminer"),
    MakeBuilder("shadowdigger")
