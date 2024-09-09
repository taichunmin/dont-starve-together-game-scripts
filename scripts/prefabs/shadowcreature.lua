local prefabs =
{
    "nightmarefuel",
    "shadow_teleport_out",
    "shadow_teleport_in",
}

local brain = require("brains/shadowcreaturebrain")

local function NotifyBrainOfTarget(inst, target)
    if inst.brain ~= nil and inst.brain.SetTarget ~= nil then
        inst.brain:SetTarget(target)
    end
end

local function retargetfn(inst)
    local maxrangesq = TUNING.SHADOWCREATURE_TARGET_DIST * TUNING.SHADOWCREATURE_TARGET_DIST
    local rangesq, rangesq1, rangesq2 = maxrangesq, math.huge, math.huge
    local target1, target2 = nil, nil
    for i, v in ipairs(AllPlayers) do
        if v.components.sanity:IsCrazy() and not v:HasTag("playerghost") then
            local distsq = v:GetDistanceSqToInst(inst)
            if distsq < rangesq then
                if inst.components.shadowsubmissive:TargetHasDominance(v) then
                    if distsq < rangesq1 and inst.components.combat:CanTarget(v) then
                        target1 = v
                        rangesq1 = distsq
                        rangesq = math.max(rangesq1, rangesq2)
                    end
                elseif distsq < rangesq2 and inst.components.combat:CanTarget(v) then
                    target2 = v
                    rangesq2 = distsq
                    rangesq = math.max(rangesq1, rangesq2)
                end
            end
        end
    end

	local forcechange = inst.forceretarget
	inst.forceretarget = nil

    if target1 ~= nil and rangesq1 <= math.max(rangesq2, maxrangesq * .25) then
        --Targets with shadow dominance have higher priority within half targeting range
        --Force target switch if current target does not have shadow dominance
        return target1, not inst.components.shadowsubmissive:TargetHasDominance(inst.components.combat.target)
    end
	return target2, forcechange
end

--V2C: called from SG instead of combat component
local function keeptargetfn(inst, target)
	if inst.sg.mem.forcedespawn then
		return true
	elseif target.components.sanity == nil then
		--not player; could be bernie or other creature
		if inst.wantstodespawn then
			--don't deaggro, so you can actually see the despawn
			inst.sg.mem.forcedespawn = true
		end
		return true
	elseif target.components.sanity:IsCrazy() then
		inst._deaggrotime = nil
		return true
	end

	--start deaggro timer when target is becomes sane
	local t = GetTime()
	if inst._deaggrotime == nil then
		inst._deaggrotime = t
		return true
	end

	--V2C: NOTE: -combat cmp sets lastwasattackedbytargettime when retargeting also
	--           -so it may use the longer delay sometimes even when not attacked
	--           -this is fine XD
	--
	--Deaggro if target has been sane for 2.5s, hasn't hit us in 6s, and hasn't tried to attack us for 5s
	if inst._deaggrotime + 2.5 >= t or
		inst.components.combat.lastwasattackedbytargettime + 6 >= t or
		(	target.components.combat and
			target.components.combat:IsRecentTarget(inst) and
			(target.components.combat.laststartattacktime or 0) + 5 >= t
		)
	then
		return true
	elseif inst.wantstodespawn then
		--don't deaggro, so you can actually see the despawn
		inst.sg.mem.forcedespawn = true
		return true
	end
	return false
end

local function onkilledbyother(inst, attacker)
    if attacker ~= nil and attacker.components.sanity ~= nil then
        attacker.components.sanity:DoDelta(inst.sanityreward or TUNING.SANITY_SMALL)
    end
end

SetSharedLootTable("shadow_creature",
{
    { "nightmarefuel",  1.0 },
    { "nightmarefuel",  0.5 },
})

local function CalcSanityAura(inst, observer)
    return inst.components.combat:HasTarget()
        and observer.components.sanity:IsCrazy()
        and -TUNING.SANITYAURA_LARGE
        or 0
end

local function ShareTargetFn(dude)
    return dude:HasTag("shadowcreature") and not dude.components.health:IsDead()
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, ShareTargetFn, 1)
end

local function OnNewCombatTarget(inst, data)
    NotifyBrainOfTarget(inst, data.target)

	--Reset deaggro delay when we change targets
	inst._deaggrotime = nil
end

local function OnDeath(inst, data)
    if data ~= nil and data.afflicter ~= nil and data.afflicter:HasTag("crazy") then
        --max one nightmarefuel if killed by a crazy NPC (e.g. Bernie)
        inst.components.lootdropper:SetLoot({ "nightmarefuel" })
        inst.components.lootdropper:SetChanceLootTable(nil)
    end
end


local function ExchangeWithOceanTerror(inst)
    if inst.components.combat.target then
        local target = inst.components.combat.target
        local x,y,z = target.Transform:GetWorldPosition()
        if not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
            local sx,sy,sz = inst.Transform:GetWorldPosition()
            local radius = 0
            local theta = inst:GetAngleToPoint(Vector3(x,y,z)) * DEGREES
            while TheWorld.Map:IsVisualGroundAtPoint(sx,sy,sz) and radius < 30 do
                radius = radius + 2
                local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                sx = sx + offset.x
                sy = sy + offset.y
                sz = sz + offset.z
            end

            if radius >= 30 then
                return nil
            else
                local shadow = SpawnPrefab("oceanhorror")
                shadow.components.health:SetPercent(inst.components.health:GetPercent())
                shadow.Transform:SetPosition(sx,sy,sz)
                shadow.sg:GoToState("appear")
                shadow.components.combat:SetTarget(target)
                TheWorld:PushEvent("ms_exchangeshadowcreature", {ent = inst, exchangedent = shadow})
                local fx = SpawnPrefab("shadow_teleport_in")
                fx.Transform:SetPosition(sx,sy,sz)
            end
        end
    end
end

local function CLIENT_ShadowSubmissive_HostileToPlayerTest(inst, player)
	if player:HasTag("shadowdominance") then
		return false
	end
	local combat = inst.replica.combat
	if combat ~= nil and combat:GetTarget() == player then
		return true
	end
	local sanity = player.replica.sanity
	if sanity ~= nil and sanity:IsCrazy() then
		return true
	end
	return false
end

local function MakeShadowCreature(data)
    local assets =
    {
        Asset("ANIM", "anim/"..data.build..".zip"),
    }

    local sounds =
    {
        attack = "dontstarve/sanity/creature"..data.num.."/attack",
        attack_grunt = "dontstarve/sanity/creature"..data.num.."/attack_grunt",
        death = "dontstarve/sanity/creature"..data.num.."/die",
        idle = "dontstarve/sanity/creature"..data.num.."/idle",
        taunt = "dontstarve/sanity/creature"..data.num.."/taunt",
        appear = "dontstarve/sanity/creature"..data.num.."/appear",
        disappear = "dontstarve/sanity/creature"..data.num.."/dissappear",
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeCharacterPhysics(inst, 10, 1.5)
        RemovePhysicsColliders(inst)
        inst.Physics:SetCollisionGroup(COLLISION.SANITY)
        inst.Physics:CollidesWith(COLLISION.SANITY)
        --inst.Physics:CollidesWith(COLLISION.WORLD)

        inst.Transform:SetFourFaced()

        inst:AddTag("shadowcreature")
        inst:AddTag("gestaltnoloot")
        inst:AddTag("monster")
        inst:AddTag("hostile")
        inst:AddTag("shadow")
        inst:AddTag("notraptrigger")
        inst:AddTag("shadow_aligned")

		--shadowsubmissive (from shadowsubmissive component) added to pristine state for optimization
		inst:AddTag("shadowsubmissive")

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)
        inst.AnimState:PlayAnimation("idle_loop", true)
        inst.AnimState:SetMultColour(1, 1, 1, .5)

        if not TheNet:IsDedicated() then
            -- this is purely view related
            inst:AddComponent("transparentonsanity")
            inst.components.transparentonsanity:ForceUpdate()
        end

		inst.HostileToPlayerTest = CLIENT_ShadowSubmissive_HostileToPlayerTest

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor.walkspeed = data.speed
	    inst.components.locomotor:SetTriggersCreep(false)
        inst.components.locomotor.pathcaps = { ignorecreep = true }

        inst.sounds = sounds

        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aurafn = CalcSanityAura

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(data.health)
        inst.components.health.nofadeout = true

        inst.sanityreward = data.sanityreward

        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(data.damage)
        inst.components.combat:SetAttackPeriod(data.attackperiod)
        inst.components.combat:SetRetargetFunction(3, retargetfn)
		--inst.components.combat:SetKeepTargetFunction(keeptargetfn)
		inst.ShouldKeepTarget = keeptargetfn --V2C: call from SG instead!
        inst.components.combat.onkilledbyother = onkilledbyother

        inst:AddComponent("shadowsubmissive")

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable('shadow_creature')

        inst:ListenForEvent("attacked", OnAttacked)
        inst:ListenForEvent("newcombattarget", OnNewCombatTarget)
        inst:ListenForEvent("death", OnDeath)

        if data.name == "terrorbeak" then
            inst.followtosea = true
            inst.ExchangeWithOceanTerror = ExchangeWithOceanTerror
        end

		inst:SetStateGraph("SGshadowcreature")
		inst:SetBrain(brain)

        inst.persists = false

        return inst
    end

    return Prefab(data.name, fn, assets, prefabs)
end

local data =
{
    {
        name = "crawlinghorror",
        build = "shadow_insanity1_basic",
        bank = "shadowcreature1",
        num = 1,
        speed = TUNING.CRAWLINGHORROR_SPEED,
        health = TUNING.CRAWLINGHORROR_HEALTH,
        damage = TUNING.CRAWLINGHORROR_DAMAGE,
        attackperiod = TUNING.CRAWLINGHORROR_ATTACK_PERIOD,
        sanityreward = TUNING.SANITY_MED,
    },
    {
        name = "terrorbeak",
        build = "shadow_insanity2_basic",
        bank = "shadowcreature2",
        num = 2,
        speed = TUNING.TERRORBEAK_SPEED,
        health = TUNING.TERRORBEAK_HEALTH,
        damage = TUNING.TERRORBEAK_DAMAGE,
        attackperiod = TUNING.TERRORBEAK_ATTACK_PERIOD,
        sanityreward = TUNING.SANITY_LARGE,
    },
}
local ret = {}
for i, v in ipairs(data) do
    table.insert(ret, MakeShadowCreature(v))
end
return unpack(ret)
