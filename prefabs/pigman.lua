local assets =
{
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
    Asset("ANIM", "anim/ds_pig_attacks.zip"),
    Asset("ANIM", "anim/ds_pig_boat_jump.zip"),
    Asset("ANIM", "anim/pig_build.zip"),
    Asset("ANIM", "anim/pigspotted_build.zip"),
    Asset("ANIM", "anim/pig_guard_build.zip"),
    Asset("ANIM", "anim/pigman_yotb.zip"),
    Asset("ANIM", "anim/werepig_build.zip"),
    Asset("ANIM", "anim/werepig_basic.zip"),
    Asset("ANIM", "anim/werepig_actions.zip"),
    Asset("ANIM", "anim/pig_token.zip"),
    Asset("SOUND", "sound/pig.fsb"),
    Asset("ANIM", "anim/merm_actions.zip"),
}

local PIG_TOKEN_PREFAB = "pig_token"

local prefabs =
{
    "meat",
    "monstermeat",
    "poop",
    "tophat",
    "strawhat",
    "pigskin",
    PIG_TOKEN_PREFAB,
}

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local function GetPigToken(inst)
	local token = next(inst.components.inventory:GetItemByName(PIG_TOKEN_PREFAB, 1))
	return token
end

local function ontalk(inst, script)
    inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
end

local function CalcSanityAura(inst, observer)
    return (inst.prefab == "moonpig" and -TUNING.SANITYAURA_LARGE)
        or (inst.components.werebeast ~= nil and inst.components.werebeast:IsInWereState() and -TUNING.SANITYAURA_LARGE)
        or (inst.components.follower ~= nil and inst.components.follower.leader == observer and TUNING.SANITYAURA_SMALL)
        or 0
end

local function ShouldAcceptItem(inst, item)
    if item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        return true
    elseif inst.components.eater:CanEat(item) then
        local foodtype = item.components.edible.foodtype
        if foodtype == FOODTYPE.MEAT or foodtype == FOODTYPE.HORRIBLE then
            return inst.components.follower.leader == nil or inst.components.follower:GetLoyaltyPercent() <= TUNING.PIG_FULL_LOYALTY_PERCENT
        elseif foodtype == FOODTYPE.VEGGIE or foodtype == FOODTYPE.RAW then
            local last_eat_time = inst.components.eater:TimeSinceLastEating()
            return (last_eat_time == nil or
                    last_eat_time >= TUNING.PIG_MIN_POOP_PERIOD)
                and (inst.components.inventory == nil or
                    not inst.components.inventory:Has(item.prefab, 1))
        end
        return true
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    --I eat food
    if item.components.edible ~= nil then
        --meat makes us friends (unless I'm a guard)
        if (    item.components.edible.foodtype == FOODTYPE.MEAT or
                item.components.edible.foodtype == FOODTYPE.HORRIBLE
            ) and
            item.components.inventoryitem ~= nil and
            (   --make sure it didn't drop due to pockets full
                item.components.inventoryitem:GetGrandOwner() == inst or
                --could be merged into a stack
                (   not item:IsValid() and
                    inst.components.inventory:FindItem(function(obj)
                        return obj.prefab == item.prefab
                            and obj.components.stackable ~= nil
                            and obj.components.stackable:IsStack()
                    end) ~= nil)
            ) then
            if inst.components.combat:TargetIs(giver) then
                inst.components.combat:SetTarget(nil)
            elseif giver.components.leader ~= nil and not (inst:HasTag("guard") or giver:HasTag("monster") or giver:HasTag("merm")) then

				if giver.components.minigame_participator == nil then
	                giver:PushEvent("makefriend")
	                giver.components.leader:AddFollower(inst)
				end
                inst.components.follower:AddLoyaltyTime(item.components.edible:GetHunger() * TUNING.PIG_LOYALTY_PER_HUNGER)
                inst.components.follower.maxfollowtime =
                    giver:HasTag("polite")
                    and TUNING.PIG_LOYALTY_MAXTIME + TUNING.PIG_LOYALTY_POLITENESS_MAXTIME_BONUS
                    or TUNING.PIG_LOYALTY_MAXTIME
            end
        end
        if inst.components.sleeper:IsAsleep() then
            inst.components.sleeper:WakeUp()
        end
    end

    --I wear hats
    if item.components.equippable ~= nil and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if current ~= nil then
            inst.components.inventory:DropItem(current)
        end
        inst.components.inventory:Equip(item)
        inst.AnimState:Show("hat")
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function OnEat(inst, food)
    if food.components.edible ~= nil then
        if food.components.edible.foodtype == FOODTYPE.VEGGIE then
            SpawnPrefab("poop").Transform:SetPosition(inst.Transform:GetWorldPosition())
        elseif food.components.edible.foodtype == FOODTYPE.MEAT and
            inst.components.werebeast ~= nil and
            not inst.components.werebeast:IsInWereState() and
            food.components.edible:GetHealth(inst) < 0 then
            inst.components.werebeast:TriggerDelta(1)
        end
    end
end

local SUGGESTTARGET_MUST_TAGS = { "_combat", "_health", "pig" }
local SUGGESTTARGET_CANT_TAGS = { "werepig", "guard", "INLIMBO" }

local function OnAttackedByDecidRoot(inst, attacker)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SpringCombatMod(SHARE_TARGET_DIST) * .5, SUGGESTTARGET_MUST_TAGS, SUGGESTTARGET_CANT_TAGS)
    local num_helpers = 0
    for i, v in ipairs(ents) do
        if v ~= inst and not v.components.health:IsDead() then
            v:PushEvent("suggest_tree_target", { tree = attacker })
            num_helpers = num_helpers + 1
            if num_helpers >= MAX_TARGET_SHARES then
                break
            end
        end
    end
end

local function IsPig(dude)
    return dude:HasTag("pig")
end

local function IsWerePig(dude)
    return dude:HasTag("werepig")
end

local function IsNonWerePig(dude)
    return dude:HasTag("pig") and not dude:HasTag("werepig")
end

local function IsGuardPig(dude)
    return dude:HasTag("guard") and dude:HasTag("pig")
end

local function OnAttacked(inst, data)
    --print(inst, "OnAttacked")
    local attacker = data.attacker
    inst:ClearBufferedAction()

	if attacker ~= nil then
		if attacker.prefab == "deciduous_root" and attacker.owner ~= nil then
			OnAttackedByDecidRoot(inst, attacker.owner)
		elseif attacker.prefab ~= "deciduous_root" and not attacker:HasTag("pigelite") then
			inst.components.combat:SetTarget(attacker)

			if inst:HasTag("werepig") then
				inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, IsWerePig, MAX_TARGET_SHARES)
			elseif inst:HasTag("guard") then
				inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, attacker:HasTag("pig") and IsGuardPig or IsPig, MAX_TARGET_SHARES)
			elseif not (attacker:HasTag("pig") and attacker:HasTag("guard")) then
				inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, IsNonWerePig, MAX_TARGET_SHARES)
			end
		end
	end
end

local function OnNewTarget(inst, data)
    if inst:HasTag("werepig") then
        inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST, IsWerePig, MAX_TARGET_SHARES)
    end
end

local builds = { "pig_build", "pigspotted_build" }
local guardbuilds = { "pig_guard_build" }
local RETARGET_MUST_TAGS = { "_combat" }

local function NormalRetargetFn(inst)
    if inst:HasTag("NPC_contestant") then
        return nil
    end

	local exclude_tags = { "playerghost", "INLIMBO" , "NPC_contestant" }
	if inst.components.follower.leader ~= nil then
		table.insert(exclude_tags, "abigail")
	end
	if inst.components.minigame_spectator ~= nil then
		table.insert(exclude_tags, "player") -- prevent spectators from auto-targeting webber
	end

    local oneof_tags = {"monster"}
    if not inst:HasTag("merm") then
        table.insert(oneof_tags, "merm")
    end

    return not inst:IsInLimbo()
        and FindEntity(
                inst,
                TUNING.PIG_TARGET_DIST,
                function(guy)
                    return guy:IsInLight() and inst.components.combat:CanTarget(guy)
                end,
                RETARGET_MUST_TAGS, -- see entityreplica.lua
                exclude_tags,
                oneof_tags
            )
        or nil
end

local function NormalKeepTargetFn(inst, target)
    --give up on dead guys, or guys in the dark, or werepigs
    return inst.components.combat:CanTarget(target) and target:IsInLight()
        and not (target.sg ~= nil and target.sg:HasStateTag("transform"))
end

local CAMPFIRE_TAGS = { "campfire", "fire" }
local function NormalShouldSleep(inst)
    return DefaultSleepTest(inst)
        and (inst.components.follower == nil or inst.components.follower.leader == nil
            or (FindEntity(inst, 6, nil, CAMPFIRE_TAGS) ~= nil and inst:IsInLight()))
end

local normalbrain = require "brains/pigbrain"

local function SuggestTreeTarget(inst, data)
    local ba = inst:GetBufferedAction()
    if data ~= nil and data.tree ~= nil and (ba == nil or ba.action ~= ACTIONS.CHOP) then
        inst.tree_target = data.tree
    end
end

local function OnItemGet(inst, data)
	if data.item ~= nil and data.item.prefab == PIG_TOKEN_PREFAB then
        inst.AnimState:OverrideSymbol("pig_belt", "pig_token", "pig_belt")
		--inst.AnimState:Show("belt")
	end
end

local function OnItemLose(inst, data)
	if not inst.components.inventory:Has(PIG_TOKEN_PREFAB, 1) then
		inst.AnimState:ClearOverrideSymbol("pig_belt")
		--inst.AnimState:Hide("belt")
	end
end

local function SetupPigToken(inst)
	if not inst._pigtokeninitialized then
		inst._pigtokeninitialized = true
		if math.random() <= (IsSpecialEventActive(SPECIAL_EVENTS.YOTP) and TUNING.PIG_TOKEN_CHANCE_YOTP or TUNING.PIG_TOKEN_CHANCE) then
			inst.components.inventory:GiveItem(SpawnPrefab(PIG_TOKEN_PREFAB))
		end
	end
end

local function ReplacePigToken(inst)
	if inst._pigtokeninitialized then
		local item = GetPigToken(inst)
		local should_get_item = math.random() <= (IsSpecialEventActive(SPECIAL_EVENTS.YOTP) and TUNING.PIG_TOKEN_CHANCE_YOTP or TUNING.PIG_TOKEN_CHANCE)
		if item ~= nil and not should_get_item then
			inst.components.inventory:RemoveItem(item, true)
			item:Remove()
		elseif item == nil and should_get_item then
			inst.components.inventory:GiveItem(SpawnPrefab(PIG_TOKEN_PREFAB))
		end
	end
end

local function SetNormalPig(inst)
    inst:RemoveTag("werepig")
    inst:RemoveTag("guard")
    inst:SetBrain(normalbrain)
    inst:SetStateGraph("SGpig")
    inst.AnimState:SetBuild(inst.build)

    inst.components.sleeper:SetResistance(2)

    inst.components.combat:SetDefaultDamage(TUNING.PIG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.PIG_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
    inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED

    inst.components.sleeper:SetSleepTest(NormalShouldSleep)
    inst.components.sleeper:SetWakeTest(DefaultWakeTest)

    inst.components.lootdropper:SetLoot({})
    inst.components.lootdropper:AddRandomLoot("meat", 3)
    inst.components.lootdropper:AddRandomLoot("pigskin", 1)
    inst.components.lootdropper.numrandomloot = 1

    inst.components.health:SetMaxHealth(TUNING.PIG_HEALTH)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    inst.components.combat:SetTarget(nil)
    inst:ListenForEvent("suggest_tree_target", SuggestTreeTarget)

    inst.components.trader:Enable()
    inst.components.talker:StopIgnoringAll("becamewerepig")
end

local KING_TAGS = { "king" }
local RETARGET_GUARD_MUST_TAGS = { "character" }
local RETARGET_GUARD_CANT_TAGS = { "guard", "INLIMBO" }
local RETARGET_GUARD_PLAYER_MUST_TAGS = { "player" }
local RETARGET_GUARD_LIMBO_CANT_TAGS = { "INLIMBO" }

local function GuardRetargetFn(inst)
    --defend the king, then the torch, then myself
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    local defendDist = SpringCombatMod(TUNING.PIG_GUARD_DEFEND_DIST)
    local defenseTarget =
        FindEntity(inst, defendDist, nil, KING_TAGS) or
        (home ~= nil and inst:IsNear(home, defendDist) and home) or
        inst

    if not defenseTarget.happy then
        local invader = FindEntity(defenseTarget, SpringCombatMod(TUNING.PIG_GUARD_TARGET_DIST), nil, RETARGET_GUARD_MUST_TAGS, RETARGET_GUARD_CANT_TAGS)
        if invader ~= nil and
            not (defenseTarget.components.trader ~= nil and defenseTarget.components.trader:IsTryingToTradeWithMe(invader)) and
            not (inst.components.trader ~= nil and inst.components.trader:IsTryingToTradeWithMe(invader)) then
            return invader
        end

        if not TheWorld.state.isday and home ~= nil and home.components.burnable ~= nil and home.components.burnable:IsBurning() then
            local lightThief = FindEntity(
                home,
                home.components.burnable:GetLargestLightRadius(),
                function(guy)
                    return guy:IsInLight()
                        and not (defenseTarget.components.trader ~= nil and defenseTarget.components.trader:IsTryingToTradeWithMe(guy))
                        and not (inst.components.trader ~= nil and inst.components.trader:IsTryingToTradeWithMe(guy))
                end,
                RETARGET_GUARD_PLAYER_MUST_TAGS
            )
            if lightThief ~= nil then
                return lightThief
            end
        end
    end

    local oneof_tags = {"monster"}
    if not inst:HasTag("merm") then
        table.insert(oneof_tags, "merm")
    end

    return FindEntity(defenseTarget, defendDist, nil, {}, RETARGET_GUARD_LIMBO_CANT_TAGS, oneof_tags)
end

local function GuardKeepTargetFn(inst, target)
    if not inst.components.combat:CanTarget(target) or
        (target.sg ~= nil and target.sg:HasStateTag("transform")) or
        (target:HasTag("guard") and target:HasTag("pig")) then
        return false
    end

    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    if home == nil then
        return true
    end

    local defendDist = not TheWorld.state.isday
                    and home.components.burnable ~= nil
                    and home.components.burnable:IsBurning()
                    and home.components.burnable:GetLargestLightRadius()
                    or SpringCombatMod(TUNING.PIG_GUARD_DEFEND_DIST)
    return target:IsNear(home, defendDist) and inst:IsNear(home, defendDist)
end

local function GuardShouldSleep(inst)
    return false
end

local function GuardShouldWake(inst)
    return true
end

local guardbrain = require "brains/pigguardbrain"

local function SetGuardPig(inst)
    inst:RemoveTag("werepig")
    inst:AddTag("guard")
    inst:SetBrain(guardbrain)
    inst:SetStateGraph("SGpig")
    inst.AnimState:SetBuild(inst.build)

    inst.components.sleeper:SetResistance(3)

    inst.components.health:SetMaxHealth(TUNING.PIG_GUARD_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.PIG_GUARD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.PIG_GUARD_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(GuardKeepTargetFn)
    inst.components.combat:SetRetargetFunction(1, GuardRetargetFn)
    inst.components.combat:SetTarget(nil)
    inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED

    inst.components.sleeper:SetSleepTest(GuardShouldSleep)
    inst.components.sleeper:SetWakeTest(GuardShouldWake)

    inst.components.lootdropper:SetLoot({})
    inst.components.lootdropper:AddRandomLoot("meat", 3)
    inst.components.lootdropper:AddRandomLoot("pigskin", 1)
    inst.components.lootdropper.numrandomloot = 1

    inst.components.trader:Enable()
    inst.components.talker:StopIgnoringAll("becamewerepig")
    inst.components.follower:SetLeader(nil)
end

local RETARGET_MUST_TAGS = { "_combat" }
local WEREPIG_RETARGET_CANT_TAGS = { "werepig", "alwaysblock", "wereplayer" }
local function WerepigRetargetFn(inst)
    return FindEntity(
        inst,
        SpringCombatMod(TUNING.PIG_TARGET_DIST),
        function(guy)
            return inst.components.combat:CanTarget(guy)
                and not (guy.sg ~= nil and guy.sg:HasStateTag("transform"))
        end,
        RETARGET_MUST_TAGS, --See entityreplica.lua (re: "_combat" tag)
        WEREPIG_RETARGET_CANT_TAGS
    )
end

local function WerepigKeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
           and not target:HasTag("werepig")
           and not target:HasTag("wereplayer")
           and not (target.sg ~= nil and target.sg:HasStateTag("transform"))
end

local function IsNearMoonBase(inst, dist)
    local moonbase = inst.components.entitytracker:GetEntity("moonbase")
    return moonbase == nil or inst:IsNear(moonbase, dist)
end

local MOONPIG_RETARGET_CANT_TAGS = { "werepig", "alwaysblock", "wereplayer", "moonbeast" }
local function MoonpigRetargetFn(inst)
    return IsNearMoonBase(inst, TUNING.MOONPIG_AGGRO_DIST)
        and FindEntity(
                inst,
                TUNING.PIG_TARGET_DIST,
                function(guy)
                    return inst.components.combat:CanTarget(guy)
                        and not (guy.sg ~= nil and guy.sg:HasStateTag("transform"))
                end,
                RETARGET_MUST_TAGS, --See entityreplica.lua (re: "_combat" tag)
                MOONPIG_RETARGET_CANT_TAGS
            )
        or nil
end

local function MoonpigKeepTargetFn(inst, target)
    return IsNearMoonBase(inst, TUNING.MOONPIG_RETURN_DIST)
        and not target:HasTag("moonbeast")
        and WerepigKeepTargetFn(inst, target)
end

local function WerepigSleepTest(inst)
    return false
end

local function WerepigWakeTest(inst)
    return true
end

local werepigbrain = require "brains/werepigbrain"

local function SetWerePig(inst)
    inst:AddTag("werepig")
    inst:RemoveTag("guard")
    inst:SetBrain(werepigbrain)
    inst:SetStateGraph("SGwerepig")
    inst.AnimState:SetBuild("werepig_build")

    inst.components.sleeper:SetResistance(3)

    inst.components.combat:SetDefaultDamage(TUNING.WEREPIG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WEREPIG_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.WEREPIG_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.WEREPIG_WALK_SPEED

    inst.components.sleeper:SetSleepTest(WerepigSleepTest)
    inst.components.sleeper:SetWakeTest(WerepigWakeTest)

    inst.components.lootdropper:SetLoot({ "meat", "meat", "pigskin" })
    inst.components.lootdropper.numrandomloot = 0

    inst.components.health:SetMaxHealth(TUNING.WEREPIG_HEALTH)
    inst.components.combat:SetTarget(nil)
    inst.components.combat:SetRetargetFunction(3, WerepigRetargetFn)
    inst.components.combat:SetKeepTargetFunction(WerepigKeepTargetFn)

    inst.components.trader:Disable()
    inst.components.follower:SetLeader(nil)
    inst.components.talker:IgnoreAll("becamewerepig")
end

local function GetStatus(inst)
    return (inst:HasTag("werepig") and "WEREPIG")
        or (inst:HasTag("guard") and "GUARD")
        or (inst.components.follower.leader ~= nil and "FOLLOWER")
        or nil
end

local function displaynamefn(inst)
    return inst.name
end

local function OnSave(inst, data)
    data.build = inst.build
	data._pigtokeninitialized = inst._pigtokeninitialized
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst.build = data.build or builds[1]
        if not inst.components.werebeast:IsInWereState() then
            inst.AnimState:SetBuild(inst.build)
        end
		inst._pigtokeninitialized = data._pigtokeninitialized
    end
end

local function CustomOnHaunt(inst)
    if not inst:HasTag("werepig") and math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
        local remainingtime = TUNING.TOTAL_DAY_TIME * (1 - TheWorld.state.time)
        local mintime = TUNING.SEG_TIME
        inst.components.werebeast:SetWere(math.max(mintime, remainingtime) + math.random() * TUNING.SEG_TIME)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE
    end
end

local function common(moonbeast)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst:AddTag("character")
    inst:AddTag("pig")
    inst:AddTag("scarytoprey")
    inst.AnimState:SetBank("pigman")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:Hide("hat")

    if IsSpecialEventActive(SPECIAL_EVENTS.YOTB) then
        inst.AnimState:AddOverrideBuild("pigman_yotb")
    end

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")

    if moonbeast then
        inst:AddTag("werepig")
        inst:AddTag("moonbeast")
        inst:AddTag("hostile")
        inst.AnimState:SetBuild("werepig_build")
        --Since we override prefab name, we will need to use the higher
        --priority displaynamefn to return us back plain old .name LOL!
        inst:SetPrefabNameOverride("pigman")
        inst.displaynamefn = displaynamefn

        inst:AddComponent("spawnfader")
    else
        --trader (from trader component) added to pristine state for optimization
        inst:AddTag("trader")

        inst:AddComponent("talker")
        inst.components.talker.fontsize = 35
        inst.components.talker.font = TALKINGFONT
        --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
        inst.components.talker.offset = Vector3(0, -400, 0)
        inst.components.talker:MakeChatter()
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    if not moonbeast then
        inst.components.talker.ontalk = ontalk

		inst._pig_token_prefab = PIG_TOKEN_PREFAB
		inst:ListenForEvent("onvacatehome", ReplacePigToken)
		inst:ListenForEvent("itemget", OnItemGet)
		inst:ListenForEvent("itemlose", OnItemLose)
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED --5
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED --3

    inst:AddComponent("bloomer")

    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetCanEatRaw()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!
    inst.components.eater:SetOnEatFn(OnEat)
    ------------------------------------------
    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"

    MakeMediumBurnableCharacter(inst, "pig_torso")

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.PIGNAMES
    inst.components.named:PickNewName()

    ------------------------------------------
    MakeHauntablePanic(inst)

    if not moonbeast then
        inst:AddComponent("werebeast")
        inst.components.werebeast:SetOnWereFn(SetWerePig)
        inst.components.werebeast:SetTriggerLimit(4)

        AddHauntableCustomReaction(inst, CustomOnHaunt, true, nil, true)
    end

    ------------------------------------------
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.PIG_LOYALTY_MAXTIME
    ------------------------------------------

    inst:AddComponent("inventory")

    ------------------------------------------

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("knownlocations")

    ------------------------------------------

    if not moonbeast then
        inst:AddComponent("trader")
        inst.components.trader:SetAcceptTest(ShouldAcceptItem)
        inst.components.trader.onaccept = OnGetItemFromPlayer
        inst.components.trader.onrefuse = OnRefuseItem
        inst.components.trader.deleteitemonaccept = false
    end

    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------------------------------

    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true

    ------------------------------------------
    MakeMediumFreezableCharacter(inst, "pig_torso")

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    ------------------------------------------

    if not moonbeast then
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
    end

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    return inst
end

local function normal()
    local inst = common(false)

    if not TheWorld.ismastersim then
        return inst
    end

    -- boat hopping setup
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst.build = builds[math.random(#builds)]
    inst.AnimState:SetBuild(inst.build)
    inst.components.werebeast:SetOnNormalFn(SetNormalPig)
    SetNormalPig(inst)

	inst:DoTaskInTime(0, SetupPigToken)
    return inst
end

local function guard()
    local inst = common(false)

    if not TheWorld.ismastersim then
        return inst
    end

    -- boat hopping setup
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst.build = guardbuilds[math.random(#guardbuilds)]
    inst.AnimState:SetBuild(inst.build)
    inst.components.werebeast:SetOnNormalFn(SetGuardPig)
    SetGuardPig(inst)
    return inst
end

local gargoyles =
{
    "gargoyle_werepigatk",
    "gargoyle_werepigdeath",
    "gargoyle_werepighowl",
}
local moonpigprefabs = {}
for i, v in ipairs(gargoyles) do
    table.insert(moonpigprefabs, v)
end
for i, v in ipairs(prefabs) do
    table.insert(moonpigprefabs, v)
end

local moonbeastbrain = require "brains/moonbeastbrain"

local function OnMoonPetrify(inst)
    if not inst.components.health:IsDead() and (not inst.sg:HasStateTag("busy") or inst:IsAsleep()) then
        local x, y, z = inst.Transform:GetWorldPosition()
        local rot = inst.Transform:GetRotation()
        local name = inst.components.named.name
        inst:Remove()
        local gargoyle = SpawnPrefab(gargoyles[math.random(#gargoyles)])
        gargoyle.components.named:SetName(name)
        gargoyle.Transform:SetPosition(x, y, z)
        gargoyle.Transform:SetRotation(rot)
        gargoyle:Petrify()
    end
end

local function OnMoonTransformed(inst, data)
    inst.components.named:SetName(data.old.components.named.name)
    inst.sg:GoToState("howl")
end

local function moon()
    local inst = common(true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("entitytracker")

    inst:SetBrain(moonbeastbrain)
    inst:SetStateGraph("SGmoonpig")

    inst.components.sleeper:SetResistance(3)
    inst.components.freezable:SetDefaultWearOffTime(TUNING.MOONPIG_FREEZE_WEAR_OFF_TIME)

    inst.components.combat:SetDefaultDamage(TUNING.WEREPIG_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WEREPIG_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.WEREPIG_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.WEREPIG_WALK_SPEED

    inst.components.sleeper:SetSleepTest(WerepigSleepTest)
    inst.components.sleeper:SetWakeTest(WerepigWakeTest)

    inst.components.lootdropper:SetLoot({ "meat", "meat", "pigskin" })
    inst.components.lootdropper.numrandomloot = 0

    inst.components.health:SetMaxHealth(TUNING.WEREPIG_HEALTH)
    inst.components.combat:SetTarget(nil)
    inst.components.combat:SetRetargetFunction(3, MoonpigRetargetFn)
    inst.components.combat:SetKeepTargetFunction(MoonpigKeepTargetFn)

    inst:ListenForEvent("moonpetrify", OnMoonPetrify)
    inst:ListenForEvent("moontransformed", OnMoonTransformed)

    return inst
end

return Prefab("pigman", normal, assets, prefabs),
    Prefab("pigguard", guard, assets, prefabs),
    Prefab("moonpig", moon, assets, moonpigprefabs)
