local assets =
{
    Asset("ANIM", "anim/ds_spider_basic.zip"),
    Asset("ANIM", "anim/spider_build.zip"),
    Asset("ANIM", "anim/ds_spider_boat_jump.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local warrior_assets =
{
    Asset("ANIM", "anim/ds_spider_basic.zip"),
    Asset("ANIM", "anim/ds_spider_warrior.zip"),
    Asset("ANIM", "anim/spider_warrior_build.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local hiderassets =
{
    Asset("ANIM", "anim/ds_spider_basic.zip"),
    Asset("ANIM", "anim/ds_spider_caves.zip"),
    Asset("ANIM", "anim/ds_spider_caves_boat_jump.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local spitterassets =
{
    Asset("ANIM", "anim/ds_spider_basic.zip"),
    Asset("ANIM", "anim/ds_spider2_caves.zip"),
    Asset("ANIM", "anim/ds_spider2_caves_boat_jump.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local dropperassets =
{
    Asset("ANIM", "anim/ds_spider_basic.zip"),
    Asset("ANIM", "anim/ds_spider_warrior.zip"),
    Asset("ANIM", "anim/spider_white.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local moon_assets =
{
    Asset("ANIM", "anim/ds_spider_basic.zip"),
    Asset("ANIM", "anim/ds_spider_moon.zip"),
    Asset("ANIM", "anim/ds_spider_moon_boat_jump.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local healer_assets = 
{
    Asset("ANIM", "anim/ds_spider_cannon.zip"),
    Asset("ANIM", "anim/spider_wolf_build.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local water_assets =
{
    Asset("ANIM", "anim/spider_water.zip"),
    Asset("ANIM", "anim/spider_water_water.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local prefabs =
{
    "spidergland",
    "monstermeat",
    "silk",
    "spider_web_spit",
    "spider_web_spit_acidinfused",
    "moonspider_spike",
    
    "spider_mutate_fx",
    "spider_heal_fx",
    "spider_heal_target_fx",
    "spider_heal_ground_fx"
}

local brain = require "brains/spiderbrain"

local function ShouldAcceptItem(inst, item, giver)
    if inst.components.health ~= nil and inst.components.health:IsDead() then
        return false, "DEAD"
    end

    if inst.components.inventoryitem:IsHeld() and not inst.components.eater:CanEat(item) then
        return false, "SPIDERNOHAT"
    end

    return
        (giver:HasTag("spiderwhisperer") and inst.components.eater:CanEat(item)) or
        (item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD)
end

local SPIDER_TAGS = { "spider" }
local SPIDER_IGNORE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local function GetOtherSpiders(inst, radius, tags)
    tags = tags or SPIDER_TAGS
    local x, y, z = inst.Transform:GetWorldPosition()
    
    local spiders = TheSim:FindEntities(x, y, z, radius, nil, SPIDER_IGNORE_TAGS, tags)
    local valid_spiders = {}

    for _, spider in ipairs(spiders) do
        if spider:IsValid() and not spider.components.health:IsDead() and not spider:HasTag("playerghost") then
            table.insert(valid_spiders, spider)
        end
    end

    return valid_spiders
end

local function OnGetItemFromPlayer(inst, giver, item)

    if inst.components.eater:CanEat(item) then
        inst.components.eater:Eat(item)

        if inst.components.inventoryitem.owner ~= nil then
            inst.sg:GoToState("idle")
        else
            inst.sg:GoToState("eat", true)
        end

        local playedfriendsfx = false
        if inst.components.combat.target == giver then
            inst.components.combat:SetTarget(nil)
        elseif giver.components.leader ~= nil and
            inst.components.follower ~= nil then
            
            if giver.components.minigame_participator == nil then
                giver:PushEvent("makefriend")
                giver.components.leader:AddFollower(inst)
                playedfriendsfx = true
            end
        end

        if giver.components.leader ~= nil then
            local spiders = GetOtherSpiders(inst, 15) --note: also returns the calling instance of the spider in the list
            local maxSpiders = TUNING.SPIDER_FOLLOWER_COUNT

            for i, v in ipairs(spiders) do
                if v ~= inst then
                    if maxSpiders <= 0 then
                        break
                    end

                    local effectdone = true

                    if v.components.combat.target == giver then
                        v.components.combat:SetTarget(nil)
                    elseif giver.components.leader ~= nil and
                        v.components.follower ~= nil and
                        v.components.follower.leader == nil then
                        if not playedfriendsfx then
                            giver:PushEvent("makefriend")
                            playedfriendsfx = true
                        end
                        giver.components.leader:AddFollower(v)
                    else
                        effectdone = false
                    end

                    if effectdone then
                        maxSpiders = maxSpiders - 1
    
                        if v.components.sleeper:IsAsleep() then
                            v.components.sleeper:WakeUp()
                        end
                    end
                end
            end
        end
    -- I also wear hats
    elseif item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if current ~= nil then
            inst.components.inventory:DropItem(current)
        end
        inst.components.inventory:Equip(item)
        inst.AnimState:Show("hat")
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("taunt")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function HasFriendlyLeader(inst, target)
    local leader = inst.components.follower.leader
    local target_leader = (target.components.follower ~= nil) and target.components.follower.leader or nil
    
    if leader ~= nil and target_leader ~= nil then

        if target_leader.components.inventoryitem then
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
    
    elseif target_leader ~= nil and target_leader.components.inventoryitem then
        -- Don't attack webber's chester
        target_leader = target_leader.components.inventoryitem:GetGrandOwner()
        return target_leader ~= nil and target_leader:HasTag("spiderwhisperer")
    end

    return false
end


local TARGET_MUST_TAGS = { "_combat", "character" }
local TARGET_CANT_TAGS = { "spiderwhisperer", "spiderdisguise", "INLIMBO" }
local function FindTarget(inst, radius)
    if not inst.no_targeting then
        return FindEntity(
            inst,
            SpringCombatMod(radius),
            function(guy)
                return (not inst.bedazzled and (not guy:HasTag("monster") or guy:HasTag("player")))
                    and inst.components.combat:CanTarget(guy)
                    and not (inst.components.follower ~= nil and inst.components.follower.leader == guy)
                    and not HasFriendlyLeader(inst, guy)
                    and not (inst.components.follower.leader ~= nil and inst.components.follower.leader:HasTag("player") 
                        and guy:HasTag("player") and not TheNet:GetPVPEnabled())
            end,
            TARGET_MUST_TAGS,
            TARGET_CANT_TAGS
        )
    end
end

local function NormalRetarget(inst)
    return FindTarget(inst, inst.components.knownlocations:GetLocation("investigate") ~= nil and TUNING.SPIDER_INVESTIGATETARGET_DIST or TUNING.SPIDER_TARGET_DIST)
end

local function WarriorRetarget(inst)
    return FindTarget(inst, TUNING.SPIDER_WARRIOR_TARGET_DIST)
end

local function keeptargetfn(inst, target)
   return target ~= nil
        and target.components.combat ~= nil
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and not (inst.components.follower ~= nil and
                (inst.components.follower.leader == target or inst.components.follower:IsLeaderSame(target)))
end

local function BasicWakeCheck(inst)
    return inst.components.combat:HasTarget()
        or (inst.components.homeseeker ~= nil and inst.components.homeseeker:HasHome())
        or inst.components.burnable:IsBurning()
        or inst.components.freezable:IsFrozen()
        or inst.components.health.takingfiredamage
        or inst.components.follower:GetLeader() ~= nil
        or inst.summoned
end

local function ShouldSleep(inst)
    return TheWorld.state.iscaveday and not BasicWakeCheck(inst)
end

local function ShouldWake(inst)
    return not TheWorld.state.iscaveday
        or BasicWakeCheck(inst)
        or (inst:HasTag("spider_warrior") and
            FindTarget(inst, TUNING.SPIDER_WARRIOR_WAKE_RADIUS) ~= nil)
end

local function DoReturn(inst)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    if home ~= nil and
        home.components.childspawner ~= nil and
        not (inst.components.follower ~= nil and
            inst.components.follower.leader ~= nil) then
        home.components.childspawner:GoHome(inst)
    end
end

local function OnIsCaveDay(inst, iscaveday)
    if not iscaveday then
        inst.components.sleeper:WakeUp()
    elseif inst:IsAsleep() then
        DoReturn(inst)
    end
end

local function OnEntitySleep(inst)
    if TheWorld.state.iscaveday then
        DoReturn(inst)
    end
end


local SPIDERDEN_TAGS = {"spiderden"}
local function SummonFriends(inst, attacker)
    local radius = (inst.prefab == "spider" or inst.prefab == "spider_warrior") and 
                    SpringCombatMod(TUNING.SPIDER_SUMMON_WARRIORS_RADIUS) or
                    TUNING.SPIDER_SUMMON_WARRIORS_RADIUS

    local den = GetClosestInstWithTag(SPIDERDEN_TAGS, inst, radius)

    if den ~= nil and den.components.combat ~= nil and den.components.combat.onhitfn ~= nil then
        den.components.combat.onhitfn(den, attacker)
    end
end

local function OnAttacked(inst, data)
    if inst.no_targeting then
        return
    end

    inst.defensive = false
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
        local should_share = dude:HasTag("spider")
            and not dude.components.health:IsDead()
            and dude.components.follower ~= nil
            and dude.components.follower.leader == inst.components.follower.leader

        if should_share and dude.defensive and not dude.no_targeting then
            dude.defensive = false
        end

        return should_share
    end, 10)
end

local function SetHappyFace(inst, is_happy)
    if is_happy then
        inst.AnimState:OverrideSymbol("face", inst.build, "happy_face")    
    else
        inst.AnimState:ClearOverrideSymbol("face")
    end
end

local function OnStartLeashing(inst, data)
    inst:SetHappyFace(true)
    inst.components.inventoryitem.canbepickedup = true

    if inst.recipe then
        local leader = inst.components.follower.leader
        if leader.components.builder and not leader.components.builder:KnowsRecipe(inst.recipe) and leader.components.builder:CanLearn(inst.recipe) then
            leader.components.builder:UnlockRecipe(inst.recipe)
        end
    end
end

local function OnStopLeashing(inst, data)
    inst.defensive = false
    inst.no_targeting = false
    inst.components.inventoryitem.canbepickedup = false

    if not inst.bedazzled then
        inst:SetHappyFace(false)
    end
end

local function OnTrapped(inst, data)
    inst.components.inventory:DropEverything()
end

local function OnEat(inst, data)
    if data.food.components.spidermutator and data.food.components.spidermutator:CanMutate(inst) then
        data.food.components.spidermutator:Mutate(inst)
    end
end

local function OnDropped(inst, data)
    if ShouldWake(inst) then
        inst.sg:GoToState("idle")
    elseif ShouldSleep(inst) then
        inst.sg:GoToState("sleep")
    end
end

local function OnGoToSleep(inst)
    inst.components.inventoryitem.canbepickedup = true
end

local function OnWakeUp(inst)
    if inst.components.follower.leader == nil then
        inst.components.inventoryitem.canbepickedup = false
    end
end

local function CalcSanityAura(inst, observer)
    if observer:HasTag("spiderwhisperer") or inst.bedazzled or 
    (inst.components.follower.leader ~= nil and inst.components.follower.leader:HasTag("spiderwhisperer")) then
        return 0
    end
    
    return inst.components.sanityaura.aura
end

local function HalloweenMoonMutate(inst, new_inst)
    local leader = inst ~= nil and inst.components.follower ~= nil
        and new_inst ~= nil and new_inst.components.follower ~= nil
        and inst.components.follower:GetLeader()
        or nil

    if leader ~= nil then
        new_inst.components.follower:SetLeader(leader)
    end
end

-- Used by the Spitter
local function MakeWeapon(inst)
    if inst.components.inventory ~= nil then
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        
        MakeInventoryPhysics(weapon)
        
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(TUNING.SPIDER_SPITTER_DAMAGE_RANGED)
        weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange + 4)
        weapon.components.weapon:SetProjectile("spider_web_spit")
        
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)

        weapon.projectiledelay = 2.5 * FRAMES
        
        weapon:AddComponent("equippable")
        weapon:AddTag("nosteal")
        inst.weapon = weapon
        inst.components.inventory:Equip(inst.weapon)
        inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
    end
end

-- Used by the moon spider
local variations = {1, 2, 3, 4, 5}
local function DoSpikeAttack(inst, pt)
    local x, y, z = pt:Get()
    local inital_r = 1

    x = GetRandomWithVariance(x, inital_r)
    z = GetRandomWithVariance(z, inital_r)

    shuffleArray(variations)

    local num = math.random(2, 4)
    local dtheta = TWOPI / num

    for i = 1, num do
        local r = 1.1 + math.random() * 1.75
        local theta = i * dtheta + math.random() * dtheta * 0.8 + dtheta * 0.2
        local x1 = x + r * math.cos(theta)
        local z1 = z + r * math.sin(theta)

        if TheWorld.Map:IsVisualGroundAtPoint(x1, 0, z1) and not TheWorld.Map:IsPointNearHole(Vector3(x1, 0, z1)) then
            local spike = SpawnPrefab("moonspider_spike")
            spike.Transform:SetPosition(x1, 0, z1)
            spike:SetOwner(inst)
            if variations[i + 1] ~= 1 then
                spike.AnimState:OverrideSymbol("spike01", "spider_spike", "spike0"..tostring(variations[i + 1]))
            end
        end
    end
end

local function SpawnHealFx(inst, fx_prefab, scale)
    local x,y,z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab(fx_prefab)
    fx.Transform:SetNoFaced()
    fx.Transform:SetPosition(x,y,z)

    scale = scale or 1
    fx.Transform:SetScale(scale, scale, scale)
end

local function DoHeal(inst)
    local scale = 1.35
    SpawnHealFx(inst, "spider_heal_ground_fx", scale)
    SpawnHealFx(inst, "spider_heal_fx", scale)

    local other_spiders = GetOtherSpiders(inst, TUNING.SPIDER_HEALING_RADIUS, {"spider", "spiderwhisperer", "spiderqueen"})
    local leader = inst.components.follower.leader

    for i, spider in ipairs(other_spiders) do
        local target = inst.components.combat.target

        -- Don't heal the spider if it's targetting us, our leader or our leader's other followers
        local targetting_us = target ~= nil and 
                             (target == inst or (leader ~= nil and 
                             (target == leader or leader.components.leader:IsFollower(target))))

        -- Don't heal the spider if we're targetting it, or our leader is targetting it or our leader's other followers
        local targetted_by_us = inst.components.combat.target == spider or (leader ~= nil and
                                (leader.components.combat:TargetIs(spider) or
                                leader.components.leader:IsTargetedByFollowers(spider)))

        if not (targetting_us or targetted_by_us) then
            local heal_amount = spider:HasTag("spiderwhisperer") and TUNING.HEALING_MEDSMALL or TUNING.SPIDER_HEALING_AMOUNT
            spider.components.health:DoDelta(heal_amount, false, inst.prefab)
            SpawnHealFx(spider, "spider_heal_target_fx")
        end
    end

    inst.healtime = GetTime()
end

local function OnPickup(inst)
    inst:PushEvent("detachchild")
    if inst.components.homeseeker then
        inst.components.homeseeker:SetHome(nil)
        inst:RemoveComponent("homeseeker")
    end
end

local function Spitter_OnAcidInfuse(inst)
    if inst.weapon == nil then
        return
    end

    inst.weapon.components.weapon:SetProjectile("spider_web_spit_acidinfused")
end

local function Spitter_OnAcidUninfuse(inst)
    if inst.weapon == nil then
        return
    end

    inst.weapon.components.weapon:SetProjectile("spider_web_spit")
end

local function SoundPath(inst, event)
    local creature = "spider"
    if inst:HasTag("spider_healer") then
        return "webber1/creatures/spider_cannonfodder/" .. event
    elseif inst:HasTag("spider_moon") then
        return "turnoftides/creatures/together/spider_moon/" .. event
    elseif inst:HasTag("spider_warrior") then
        creature = "spiderwarrior"
    elseif inst:HasTag("spider_hider") or inst:HasTag("spider_spitter") then
        creature = "cavespider"
    else
        creature = "spider"
    end
    return "dontstarve/creatures/" .. creature .. "/" .. event
end

local DIET = { FOODTYPE.MEAT }
local BASE_PATHCAPS = { ignorecreep = true }
local function create_common(bank, build, tag, common_init, extra_data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)

    inst.DynamicShadow:SetSize(1.5, .5)
    inst.Transform:SetFourFaced()

    inst:AddTag("cavedweller")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("canbetrapped")
    inst:AddTag("smallcreature")
    inst:AddTag("spider")
    inst:AddTag("drop_inventory_onpickup")
    inst:AddTag("drop_inventory_onmurder")
    
    inst.scrapbook_deps = {"silk","spidergland","monstermeat"}


    if tag ~= nil then
        inst:AddTag(tag)
    end

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")

    MakeFeedableSmallLivestockPristine(inst)
    
    if common_init ~= nil then
        common_init(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ----------
    inst.OnEntitySleep = OnEntitySleep

    -- locomotor must be constructed before the stategraph!
    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = (extra_data and extra_data.pathcaps) or BASE_PATHCAPS
    -- boat hopping setup
    inst.components.locomotor:SetAllowPlatformHopping(true)
    
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:SetStateGraph((extra_data and extra_data.sg) or "SGspider")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("monstermeat", 1)
    inst.components.lootdropper:AddRandomLoot("silk", .5)
    inst.components.lootdropper:AddRandomLoot("spidergland", .5)
    inst.components.lootdropper:AddRandomHauntedLoot("spidergland", 1)
    inst.components.lootdropper.numrandomloot = 1

    ---------------------
    MakeMediumBurnableCharacter(inst, "body")
    MakeMediumFreezableCharacter(inst, "body")
    inst.components.burnable.flammability = TUNING.SPIDER_FLAMMABILITY
    ---------------------

    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetKeepTargetFunction(keeptargetfn)
    inst.components.combat:SetOnHit(SummonFriends)

    inst:AddComponent("follower")
    --inst.components.follower.maxfollowtime = TUNING.TOTAL_DAY_TIME

    ------------------

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetResistance(2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    ------------------

    inst:AddComponent("knownlocations")

    ------------------

    inst:AddComponent("eater")
    inst.components.eater:SetDiet(DIET, DIET)
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!
    inst.components.eater:SetCanEatRawMeat(true)

    ------------------

    inst:AddComponent("inspectable")

    ------------------

    inst:AddComponent("inventory")
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader:SetAbleToAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false

    ------------------

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem:SetSinks(true)

    --------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------

    inst:AddComponent("acidinfusible")
    inst.components.acidinfusible:SetFXLevel(1)
    inst.components.acidinfusible:SetMultipliers(TUNING.ACID_INFUSION_MULT.STRONGER)

    ------------------
    
    MakeFeedableSmallLivestock(inst, TUNING.SPIDER_PERISH_TIME)
    MakeHauntablePanic(inst)

    inst:SetBrain((extra_data and extra_data.brain) or brain)

    inst:ListenForEvent("attacked", OnAttacked)
    
    inst:ListenForEvent("startleashing", OnStartLeashing)
    inst:ListenForEvent("stopleashing", OnStopLeashing)
    
    inst:ListenForEvent("ontrapped", OnTrapped)
    inst:ListenForEvent("oneat", OnEat)

    inst:ListenForEvent("ondropped", OnDropped)

    inst:ListenForEvent("gotosleep", OnGoToSleep)
    inst:ListenForEvent("onwakeup", OnWakeUp)

    inst:ListenForEvent("onpickup", OnPickup)

    inst:WatchWorldState("iscaveday", OnIsCaveDay)
    OnIsCaveDay(inst, TheWorld.state.iscaveday)
    
    inst.SoundPath = SoundPath

    inst.incineratesound = SoundPath(inst, "die")

    inst.build = build
    inst.SetHappyFace = (extra_data and extra_data.SetHappyFaceFn) or SetHappyFace

    return inst
end

local function create_spider()
    local inst = create_common("spider", "spider_build")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.health:SetMaxHealth(TUNING.SPIDER_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, NormalRetarget)

    inst.components.locomotor.walkspeed = TUNING.SPIDER_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.SPIDER_RUN_SPEED

    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL

    inst:AddComponent("halloweenmoonmutable")
    inst.components.halloweenmoonmutable:SetPrefabMutated("spider_moon")
    inst.components.halloweenmoonmutable:SetOnMutateFn(HalloweenMoonMutate)

    return inst
end

local function create_warrior()
    local inst = create_common("spider", "spider_warrior_build", "spider_warrior")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.health:SetMaxHealth(TUNING.SPIDER_WARRIOR_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_WARRIOR_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_WARRIOR_ATTACK_PERIOD + math.random() * 2)
    inst.components.combat:SetRange(TUNING.SPIDER_WARRIOR_ATTACK_RANGE, TUNING.SPIDER_WARRIOR_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(2, WarriorRetarget)

    inst.components.locomotor.walkspeed = TUNING.SPIDER_WARRIOR_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.SPIDER_WARRIOR_RUN_SPEED

    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("halloweenmoonmutable")
    inst.components.halloweenmoonmutable:SetPrefabMutated("spider_moon")
    inst.components.halloweenmoonmutable:SetOnMutateFn(HalloweenMoonMutate)

    inst.recipe = "mutator_warrior"

    return inst
end

local function create_hider()
    local inst = create_common("spider_hider", "DS_spider_caves", "spider_hider")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.health:SetMaxHealth(TUNING.SPIDER_HIDER_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_HIDER_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_HIDER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, WarriorRetarget)

    inst.components.locomotor.walkspeed = TUNING.SPIDER_HIDER_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.SPIDER_HIDER_RUN_SPEED

    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("halloweenmoonmutable")
    inst.components.halloweenmoonmutable:SetPrefabMutated("spider_moon")
    inst.components.halloweenmoonmutable:SetOnMutateFn(HalloweenMoonMutate)

    inst.recipe = "mutator_hider"

    return inst
end

local function create_spitter()
    local inst = create_common("spider_spitter", "DS_spider2_caves", "spider_spitter")

    inst.scrapbook_deps = {"silk","spidergland","monstermeat"}

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.acidinfusible:SetOnInfuseFn(Spitter_OnAcidInfuse)
    inst.components.acidinfusible:SetOnUninfuseFn(Spitter_OnAcidUninfuse)

    inst.components.health:SetMaxHealth(TUNING.SPIDER_SPITTER_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_SPITTER_DAMAGE_MELEE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_SPITTER_ATTACK_PERIOD + math.random() * 2)
    inst.components.combat:SetRange(TUNING.SPIDER_SPITTER_ATTACK_RANGE, TUNING.SPIDER_SPITTER_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(2, WarriorRetarget)

    inst.components.locomotor.walkspeed = TUNING.SPIDER_SPITTER_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.SPIDER_SPITTER_RUN_SPEED

    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
    MakeWeapon(inst)

    inst:AddComponent("halloweenmoonmutable")
    inst.components.halloweenmoonmutable:SetPrefabMutated("spider_moon")
    inst.components.halloweenmoonmutable:SetOnMutateFn(HalloweenMoonMutate)

    inst.recipe = "mutator_spitter"

    return inst
end

local function create_dropper()
    local inst = create_common("spider", "spider_white", "spider_warrior")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.health:SetMaxHealth(TUNING.SPIDER_WARRIOR_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_WARRIOR_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_WARRIOR_ATTACK_PERIOD + math.random() * 2)
    inst.components.combat:SetRange(TUNING.SPIDER_WARRIOR_ATTACK_RANGE, TUNING.SPIDER_WARRIOR_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(2, WarriorRetarget)

    inst.components.locomotor.walkspeed = TUNING.SPIDER_WARRIOR_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.SPIDER_WARRIOR_RUN_SPEED

    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("halloweenmoonmutable")
    inst.components.halloweenmoonmutable:SetPrefabMutated("spider_moon")
    inst.components.halloweenmoonmutable:SetOnMutateFn(HalloweenMoonMutate)

    inst.recipe = "mutator_dropper"

    return inst
end

local function spider_moon_common_init(inst)
    inst.Transform:SetScale(1.25, 1.25, 1.25)
    inst:AddTag("lunar_aligned")
end

local function create_moon()
    local inst = create_common("spider_moon", "ds_spider_moon", "spider_moon", spider_moon_common_init)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.DoSpikeAttack = DoSpikeAttack

    inst.components.health:SetMaxHealth(TUNING.SPIDER_MOON_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_MOON_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_MOON_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.SPIDER_WARRIOR_ATTACK_RANGE, TUNING.SPIDER_WARRIOR_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(1, WarriorRetarget)

    inst.components.locomotor.walkspeed = TUNING.SPIDER_HIDER_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.SPIDER_HIDER_RUN_SPEED

    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst.recipe = "mutator_moon"

    return inst
end

local function create_healer()
    local inst = create_common("spider", "spider_wolf_build", "spider_healer")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.health:SetMaxHealth(TUNING.SPIDER_HEALER_HEALTH)

    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_HEALER_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, NormalRetarget)

    inst.components.locomotor.walkspeed = TUNING.SPIDER_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.SPIDER_RUN_SPEED

    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL

    inst:AddComponent("halloweenmoonmutable")
    inst.components.halloweenmoonmutable:SetPrefabMutated("spider_moon")
    inst.components.halloweenmoonmutable:SetOnMutateFn(HalloweenMoonMutate)

    inst.DoHeal = DoHeal

    inst.recipe = "mutator_healer"

    return inst
end

------ Water Strider --------------------------------------------------------------------------------
local function WaterSpider_SetHappyFace(inst, is_happy)
    if is_happy then
        inst.AnimState:OverrideSymbol("waterforest_eyes", inst.build, "happy_face")
        inst.AnimState:OverrideSymbol("fangs", inst.build, "happy_fangs")
    else
        inst.AnimState:ClearOverrideSymbol("fangs")
        inst.AnimState:ClearOverrideSymbol("waterforest_eyes")
    end
end

-- Custom SG and brain for amphibious creature support.
local SPIDER_WATER_EXTRADATA =
{
    sg = "SGspider_water",
    brain = require "brains/spider_waterbrain",
    pathcaps = { ignorecreep = true, allowocean = true },
    SetHappyFaceFn = WaterSpider_SetHappyFace,
}

local function OnEnterWater(inst)
    inst.hop_distance = inst.components.locomotor.hop_distance
    inst.components.locomotor.hop_distance = 4

    inst.AnimState:SetBuild("spider_water_water")
end

local function OnExitWater(inst)
    if inst.hop_distance then
        inst.components.locomotor.hop_distance = inst.hop_distance
    end

    inst.AnimState:SetBuild("spider_water")
end

local function WaterRetarget(inst)
    -- If we're chasing a fish, go to a lower target distance so they're not as aggressive.
    local dist = (inst._fishtarget ~= nil and inst._fishtarget:IsValid() and TUNING.SPIDER_WATER_FISH_TARGET_DIST)
        or inst.components.knownlocations:GetLocation("investigate") ~= nil and TUNING.SPIDER_INVESTIGATETARGET_DIST
        or TUNING.SPIDER_TARGET_DIST

    return FindTarget(inst, dist)
end

local function create_water()
    local inst = create_common("spider_water", "spider_water", "spider_water", nil, SPIDER_WATER_EXTRADATA)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("amphibiouscreature")
    inst.components.amphibiouscreature:SetBanks("spider_water", "spider_water_water")
    inst.components.amphibiouscreature:SetEnterWaterFn(OnEnterWater)
    inst.components.amphibiouscreature:SetExitWaterFn(OnExitWater)
    ------------------

    inst:AddComponent("timer")
    ------------------

    inst.components.combat:SetDefaultDamage(TUNING.SPIDER_WATER_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_WATER_ATTACK_PERIOD + math.random() * 2)
    inst.components.combat:SetRange(TUNING.SPIDER_WATER_HIT_RANGE)
    inst.components.combat:SetRetargetFunction(2, WaterRetarget)
    ------------------

    inst.components.locomotor.walkspeed = TUNING.SPIDER_WATER_WALKSPEED
    inst.components.locomotor.runspeed = TUNING.SPIDER_WATER_RUNSPEED
    ------------------

    inst.components.embarker.embark_speed = inst.components.locomotor.runspeed
    ------------------

    inst.components.inventoryitem:SetSinks(false)
    ------------------

    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
    ------------------

    inst.components.health:SetMaxHealth(TUNING.SPIDER_WATER_HEALTH)
    ------------------

    inst.recipe = "mutator_water"

    return inst
end
-----------------------------------------------------------------------------------------------------

return Prefab("spider", create_spider, assets, prefabs),
       Prefab("spider_warrior", create_warrior, warrior_assets, prefabs),
       Prefab("spider_hider", create_hider, hiderassets, prefabs),
       Prefab("spider_spitter", create_spitter, spitterassets, prefabs),
       Prefab("spider_dropper", create_dropper, dropperassets, prefabs),
       Prefab("spider_moon", create_moon, moon_assets, prefabs),
       Prefab("spider_healer", create_healer, healer_assets, prefabs),
       Prefab("spider_water", create_water, water_assets, prefabs)
