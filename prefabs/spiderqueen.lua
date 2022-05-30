local assets =
{
    Asset("ANIM", "anim/spider_queen_build.zip"),
    Asset("ANIM", "anim/spider_queen.zip"),
    Asset("ANIM", "anim/spider_queen_2.zip"),
    --Asset("ANIM", "anim/spider_queen_3.zip"),
    --Asset("SOUND", "sound/spider.fsb"),
}

local prefabs =
{
    "monstermeat",
    "silk",
    "spiderhat",
    "spidereggsack",
}

local brain = require "brains/spiderqueenbrain"

local loot =
{
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "silk",
    "silk",
    "silk",
    "silk",
    "spidereggsack",
    "spiderhat",
}

local SHARE_TARGET_DIST = 30

local RETARGET_MUST_TAGS = { "character", "_combat" }
local RETARGET_CANT_TAGS = { "spiderwhisperer", "spiderdisguise", "INLIMBO" }
local function Retarget(inst)
    if not inst.components.health:IsDead() and not inst.components.sleeper:IsAsleep() then
        local oldtarget = inst.components.combat.target
        local newtarget = FindEntity(inst, 10,
            function(guy)
                return (not guy:HasTag("monster") or guy:HasTag("player"))
                    and inst.components.combat:CanTarget(guy)
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS
        )

        if newtarget ~= nil and newtarget ~= oldtarget then
            inst.components.combat:SetTarget(newtarget)
        end
    end
end

local function CalcSanityAura(inst, observer)
    return observer:HasTag("spiderwhisperer") and 0 or -TUNING.SANITYAURA_HUGE
end

local function ShareTargetFn(dude)
    return dude.prefab == "spiderqueen" and not dude.components.health:IsDead()
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, ShareTargetFn, 2)
    end
end

local function BabyCount(inst)
    return inst.components.leader.numfollowers
end

local function MakeBaby(inst)
    local angle = (inst.Transform:GetRotation() + 180) * DEGREES
    
    local prefab = "spider"
    if inst.components.combat:HasTarget() and math.random() < 0.45 then
        prefab = math.random() > 0.5 and "spider_warrior" or "spider_healer"
    end

    local spider = inst.components.lootdropper:SpawnLootPrefab(prefab)
    if spider ~= nil then
        local rad = spider:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0) + .25
        local x, y, z = inst.Transform:GetWorldPosition()
        spider.Transform:SetPosition(x + rad * math.cos(angle), 0, z - rad * math.sin(angle))
        spider.sg:GoToState("taunt")
        inst.components.leader:AddFollower(spider)
        if inst.components.combat.target ~= nil then
            spider.components.combat:SetTarget(inst.components.combat.target)
        end
    end
end

local PLAYER_TAGS = { "player" }
local PLAYER_IGNORE_TAGS = { "playerghost" }

local function MaxBabies(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, TUNING.SPIDERQUEEN_NEARBYPLAYERSDIST, PLAYER_TAGS, PLAYER_IGNORE_TAGS)
    return RoundBiasedDown(math.pow(#ents * 20, 1 / 1.4))
end

local function AdditionalBabies(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, TUNING.SPIDERQUEEN_NEARBYPLAYERSDIST, PLAYER_TAGS, PLAYER_IGNORE_TAGS)
    return RoundBiasedUp(#ents * .5)
end

local function OnDead(inst)
    AwardRadialAchievement("spiderqueen_killed", inst:GetPosition(), TUNING.ACHIEVEMENT_RADIUS_FOR_GIANT_KILL)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1000, 1)

    inst.DynamicShadow:SetSize(7, 3)
    inst.Transform:SetFourFaced()

    inst:AddTag("cavedweller")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("epic")
    inst:AddTag("largecreature")
    inst:AddTag("spiderqueen")
    inst:AddTag("spider")

    inst.AnimState:SetBank("spider_queen")
    inst.AnimState:SetBuild("spider_queen_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:SetStateGraph("SGspiderqueen")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    ---------------------
    MakeLargeBurnableCharacter(inst, "body")
    MakeLargeFreezableCharacter(inst, "body")
    inst.components.burnable.flammability = TUNING.SPIDER_FLAMMABILITY

    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SPIDERQUEEN_HEALTH)

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.SPIDERQUEEN_ATTACKRANGE)
    inst.components.combat:SetDefaultDamage(TUNING.SPIDERQUEEN_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDERQUEEN_ATTACKPERIOD)
    inst.components.combat:SetRetargetFunction(3, Retarget)

    ------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetResistance(4)
    ------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = TUNING.SPIDERQUEEN_WALKSPEED

    ------------------

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!

    ------------------

    inst:AddComponent("incrementalproducer")
    inst.components.incrementalproducer.countfn = BabyCount
    inst.components.incrementalproducer.producefn = MakeBaby
    inst.components.incrementalproducer.maxcountfn = MaxBabies
    inst.components.incrementalproducer.incrementfn = AdditionalBabies
    inst.components.incrementalproducer.incrementdelay = TUNING.SPIDERQUEEN_GIVEBIRTHPERIOD

    ------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("leader")

    MakeHauntableGoToState(inst, "poop", TUNING.HAUNT_CHANCE_OCCASIONAL, TUNING.HAUNT_COOLDOWN_MEDIUM, TUNING.HAUNT_CHANCE_LARGE)

    ------------------

    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDead)

    return inst
end

return Prefab("spiderqueen", fn, assets, prefabs)
