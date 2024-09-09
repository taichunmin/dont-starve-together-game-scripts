local prefabs =
{
    "nightmarefuel",
}

local brain = require( "brains/nightmarecreaturebrain")

local function retargetfn(inst)
    local maxrangesq = TUNING.SHADOWCREATURE_TARGET_DIST * TUNING.SHADOWCREATURE_TARGET_DIST
    local rangesq, rangesq1, rangesq2 = maxrangesq, math.huge, math.huge
    local target1, target2 = nil, nil
    for i, v in ipairs(AllPlayers) do
        if --[[v.components.sanity:IsCrazy() and]] not v:HasTag("playerghost") then
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

    if target1 ~= nil and rangesq1 <= math.max(rangesq2, maxrangesq * .25) then
        --Targets with shadow dominance have higher priority within half targeting range
        --Force target switch if current target does not have shadow dominance
        return target1, not inst.components.shadowsubmissive:TargetHasDominance(inst.components.combat.target)
    end
    return target2
end

SetSharedLootTable('nightmare_creature',
{
    {'nightmarefuel', 1.0},
    {'nightmarefuel', 0.5},
})

local function CanShareTargetWith(dude)
    return dude:HasTag("nightmarecreature") and not dude.components.health:IsDead()
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, 30, CanShareTargetWith, 1)
    end
end

local function OnDeath(inst, data)
    if data ~= nil and data.afflicter ~= nil and data.afflicter:HasTag("crazy") and inst.components.lootdropper.loot == nil then
        --max one nightmarefuel if killed by a crazy NPC (e.g. Bernie)
        inst.components.lootdropper:SetLoot({ "nightmarefuel" })
        inst.components.lootdropper:SetChanceLootTable(nil)
    end
end

local function ScheduleCleanup(inst)
    inst:DoTaskInTime(math.random() * TUNING.NIGHTMARE_SEGS.DAWN * TUNING.SEG_TIME, function()
        inst.components.lootdropper:SetLoot({})
        inst.components.lootdropper:SetChanceLootTable(nil)
        inst.components.health:Kill()
    end)
end

local function OnNightmareDawn(inst, dawn)
    if dawn then
        ScheduleCleanup(inst)
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
    local bank = data.bank
    local build = data.build

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

        inst.Transform:SetFourFaced()

        MakeCharacterPhysics(inst, 10, 1.5)
        RemovePhysicsColliders(inst)
        inst.Physics:SetCollisionGroup(COLLISION.SANITY)
        inst.Physics:CollidesWith(COLLISION.SANITY)

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle_loop")
        inst.AnimState:SetMultColour(1, 1, 1, 0.5)

        inst:AddTag("nightmarecreature")
        inst:AddTag("gestaltnoloot")
        inst:AddTag("monster")
        inst:AddTag("hostile")
        inst:AddTag("shadow")
        inst:AddTag("notraptrigger")
        inst:AddTag("shadow_aligned")

		--shadowsubmissive (from shadowsubmissive component) added to pristine state for optimization
		inst:AddTag("shadowsubmissive")

		inst.HostileToPlayerTest = CLIENT_ShadowSubmissive_HostileToPlayerTest

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	    inst.components.locomotor:SetTriggersCreep(false)
        inst.components.locomotor.pathcaps = { ignorecreep = true }
        inst.components.locomotor.walkspeed = data.speed
        inst.sounds = sounds

        inst:SetStateGraph("SGshadowcreature")
        inst:SetBrain(brain)

        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aura = -TUNING.SANITYAURA_LARGE

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(data.health)

        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(data.damage)
        inst.components.combat:SetAttackPeriod(data.attackperiod)
        inst.components.combat:SetRetargetFunction(3, retargetfn)

        inst:AddComponent("shadowsubmissive")

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable('nightmare_creature')

        inst:ListenForEvent("attacked", OnAttacked)
        inst:ListenForEvent("death", OnDeath)

        inst:WatchWorldState("isnightmaredawn", OnNightmareDawn)

        inst:AddComponent("knownlocations")

        return inst
    end

    return Prefab(data.name, fn, assets, prefabs)
end

local data =
{
    {
        name = "crawlingnightmare",
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
        name = "nightmarebeak",
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
