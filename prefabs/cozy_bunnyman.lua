local assets =
{
    Asset("ANIM", "anim/manrabbit_basic.zip"),
    Asset("ANIM", "anim/manrabbit_actions.zip"),
    Asset("ANIM", "anim/manrabbit_attacks.zip"),
    Asset("ANIM", "anim/manrabbit_build.zip"),
    Asset("ANIM", "anim/manrabbit_boat_jump.zip"),

    Asset("ANIM", "anim/manrabbit_beard_build.zip"),
    Asset("ANIM", "anim/manrabbit_beard_basic.zip"),
    Asset("ANIM", "anim/manrabbit_beard_actions.zip"),
    Asset("SOUND", "sound/bunnyman.fsb"),
}

local prefabs =
{
    "meat",
    "monstermeat",
    "manrabbit_tail",
    "beardhair",
    "carrot",
    "hareball",
    "carrot_spinner",
}

local beardlordloot = { "beardhair", "beardhair", "monstermeat" }

local brain = require("brains/cozy_bunnymanbrain")

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local function ontalk(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/idle_med")
end

local function CalcSanityAura(inst, observer)
    return inst.components.follower ~= nil
        and inst.components.follower:GetLeader() == observer
        and TUNING.SANITYAURA_SMALL
        or 0
end

local function ShouldAcceptItem(inst, item)
    return
        (   --accept tokens!
            item:HasTag("yotr_token")
        ) or
       
        (   --accept food, but not too many carrots for loyalty!
            inst.components.eater:CanEat(item)
        )
end

local function AbleToAcceptItem(inst, item, giver)
    if inst.components.health and inst.components.health:IsDead() then
        return false, "DEAD"
    elseif inst.components.sleeper and inst.components.sleeper:IsAsleep() then
        return false, "SLEEPING"
    elseif (inst.sg and inst.sg:HasStateTag("busy"))
            or inst.components.minigame_spectator
            or inst.components.minigame_participator
            or inst.components.knownlocations:GetLocation("pillowfightlocation")
            or inst.components.entitytracker:GetEntity("arena") then
        return false, "BUSY"
    end

    local shrine = inst.components.entitytracker:GetEntity("shrine")
    if shrine and shrine.gameinprogress then
        return false, "BUSY"
    else
        return true
    end
end

local function GetNextArena(inst)
    if not TheWorld.yotr_fightrings then
        return nil
    end

    local chosen_arena = next(TheWorld.yotr_fightrings)
    if not chosen_arena then
        return nil
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local dsq_to_chosen = chosen_arena:GetDistanceSqToPoint(ix, iy, iz)
    for arena in pairs(TheWorld.yotr_fightrings) do
        if arena ~= chosen_arena then
            local dsq_to_arena = arena:GetDistanceSqToPoint(ix, iy, iz)
            if dsq_to_arena < dsq_to_chosen then
                chosen_arena = arena
                dsq_to_chosen = dsq_to_arena
            end
        end
    end

    return chosen_arena
end

local ARENA_MUST = {"yotr_arena"}
local REJECT_ITEM_DATA = {text=STRINGS.COZY_RABBIT_REJECTTOKEN}
local REJECT_NOARENA_DATA = {text=STRINGS.COZY_RABBIT_NOARENA}
local CHEER_TOKEN_DATA = {text=STRINGS.COZY_RABBIT_GETTOKEN}
local function OnGetItemFromPlayer(inst, giver, item)

    --I collect tokens
    if item:HasTag("yotr_token") then
        inst.SoundEmitter:PlaySound("yotr_2023/common/challenge_bunnyman")

        if inst.components.entitytracker:GetEntity("arena") then
            giver.components.inventory:GiveItem(item)
            inst:PushEvent("reject", REJECT_ITEM_DATA)
        else
            local chosen_arena = GetNextArena(inst)

            if chosen_arena then
                inst:PushEvent("gotyotrtoken", CHEER_TOKEN_DATA)
                inst.needspillow = true
                inst.components.entitytracker:TrackEntity("arena", chosen_arena)
                -- should reserve the arena
            else
                giver.components.inventory:GiveItem(item)
                inst:PushEvent("reject", REJECT_NOARENA_DATA)
            end
        end
    end

    --I eat food, but not carrots, carrots are for games
    if item.prefab == "carrot" then
        inst:PushEvent("cheer", {text=STRINGS.COZY_RABBIT_YAY})
    elseif item.components.edible then
        inst:PushBufferedAction(BufferedAction(inst, item, ACTIONS.EAT))
        inst.sg:GoToState("eat")
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function update_bunny_timers(bunny)
    if bunny.components.timer:TimerExists("dangertime") then
        bunny.components.timer:SetTimeLeft("dangertime",5)
    else
        bunny.components.timer:StartTimer("dangertime",5)
    end
    if not bunny.components.timer:TimerExists("shouldhide") then
        bunny.components.timer:StartTimer("shouldhide",1+math.random()*2)
    end
end

local BUNNYMAN_MUST = {"cozy_bunnyman"}
local function OnAttacked(inst, data)
    -- Don't freak out at all if we're getting hit by a pillow,
    -- or while we're in a minigame.
    if inst.components.minigame_participator
            or (data and data.weapon and data.weapon:HasTag("pillow")) then
        return
    end

    inst:finishgame()

    update_bunny_timers(inst)

    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 15, BUNNYMAN_MUST)
    for _, ent in ipairs(ents)do
        if ent ~= inst and not ent.components.sleeper:IsAsleep() and not ent.sg:HasStateTag("hide") then
            ent:DoTaskInTime(math.random()+0.3, update_bunny_timers)
        end
    end
end

local function NamePillow(item, inst)
	if item.components.named ~= nil and item.components.named.name == nil then
		item.components.named:SetName(subfmt(STRINGS.UI.OBJECTOWNERSHIP, {object = item.name, owner = inst.name}))
    end
end

local function OnItemDropped(inst, data)
    if data.item and data.item:HasTag("bodypillow") then

        inst.components.homeseeker:SetHome(data.item)
        inst.components.entitytracker:TrackEntity("floorpillow", data.item)
        data.item:RemoveComponent("inventoryitem")

        NamePillow(data.item, inst)
    end
end

local function OnGetItem(inst,data)
    if data.item and data.item:HasTag("bodypillow") then
        inst.needspillow = nil
        if data.item == inst.components.entitytracker:GetEntity("floorpillow") then
            inst.components.inventory:Equip(data.item)
            inst.components.entitytracker:ForgetEntity("floorpillow")
        end
    end
end

-----------------------------------------------------------------------------------
local function CozyBunnymanSleepTestFn(inst)
    local shrine = inst.components.entitytracker:GetEntity("shrine")

    return (not shrine or not shrine.gameinprogress)
        and TheWorld.state["isday"]
        and not (inst.components.combat and inst.components.combat.target)
        and not (inst.components.burnable and inst.components.burnable:IsBurning())
        and not (inst.components.freezable and inst.components.freezable:IsFrozen())
        and not (inst.components.minigame_participator or inst.components.minigame_spectator)
        and not inst.sg:HasStateTag("busy")
end

local function CozyBunnymanWakeTestFn(inst)
    local should_wake = not TheWorld.state["isday"]
        or (inst.components.combat and inst.components.combat.target)
        or (inst.components.burnable and inst.components.burnable:IsBurning())
        or (inst.components.health and inst.components.health.takingfiredamage)
        or (inst.components.freezable and inst.components.freezable:IsFrozen())
        or (inst.components.minigame_participator or inst.components.minigame_spectator)

    if not should_wake then
        local pillowspot = inst.components.knownlocations:GetLocation("pillowSpot")
        return (pillowspot and inst:GetDistanceSqToPoint(pillowspot) > 2.5) or false
    else
        return true
    end
end

-----------------------------------------------------------------------------------

local RETARGET_MUST_TAGS = { "_combat", "_health" } -- see entityreplica.lua
local RETARGET_ONEOF_TAGS = { "monster", "player", "pirate"}
local MINIGAME_RETARGET_ONEOF_TAGS = { "character" }
local function NormalRetargetFn(inst)
    if inst:IsInLimbo() then
        return nil
    end

    local minigame_participator = inst.components.minigame_participator
    if not minigame_participator then
        if TheWorld.state.isday then
            -- Make non-minigame-participants fail to choose new targets during the day,
            -- so they can enjoy their sleepover.
            return nil
        end
    elseif minigame_participator.minigame and minigame_participator.minigame.components.minigame:GetIsOutro() then
        return nil
    end

    return FindEntity(
                inst,
                TUNING.PIG_TARGET_DIST,
                (minigame_participator and inst._minigame_retarget_test)
                    or inst._normal_retarget_test,
                RETARGET_MUST_TAGS,
                nil,
                (minigame_participator and MINIGAME_RETARGET_ONEOF_TAGS)
                    or RETARGET_ONEOF_TAGS
            )
        or nil
end

local function NormalKeepTargetFn(inst, target)
    if inst.components.minigame_participator then
        local target_minigame = (target.components.minigame_participator
            and target.components.minigame_participator.minigame)
            or nil
        return target_minigame
            and (not target_minigame.IsCompeting or target_minigame:IsCompeting(target))
    else
        return not TheWorld.state.isday
            and not (target.sg ~= nil and target.sg:HasStateTag("hiding"))
            and inst.components.combat:CanTarget(target)
    end
end

local function giveupstring()
    return "RABBIT_GIVEUP", math.random(#STRINGS["RABBIT_GIVEUP"])
end

local function battlecry(combatcmp, target)
    return "RABBIT_BATTLECRY", math.random(#STRINGS["RABBIT_BATTLECRY"])
end

local function LootSetupFunction(lootdropper)
    lootdropper:AddRandomLoot("carrot", 3)
    lootdropper:AddRandomLoot("meat", 3)
    lootdropper:AddRandomLoot("manrabbit_tail", 2)
    lootdropper.numrandomloot = 1
end

----------------------------------------------------
local function onremove_cleanup_floor_pillow(inst)
    local pillow = inst.components.entitytracker:GetEntity("floorpillow")
	if pillow ~= nil then
		if pillow.components.inventoryitem == nil then
			pillow:AddComponent("inventoryitem")
		end
		if pillow.components.named ~= nil then
			pillow.components.named:SetName(nil)
		end
    end
end

local function connecttofloorpillow(inst)
    local pillow = inst.components.entitytracker:GetEntity("floorpillow")
    if pillow then
        if not pillow.components.inventoryitem:IsHeld() then
            inst.components.homeseeker:SetHome(pillow)
            pillow:RemoveComponent("inventoryitem")
            NamePillow(pillow, inst)
        end
    end
    inst:ListenForEvent("onremove", onremove_cleanup_floor_pillow)

    if inst.components.entitytracker:GetEntity("arena") then
        if pillow and not pillow.components.inventoryitem then
            inst.needspillow = true
        end
    end
end

----------------------------------------------------
local function OnSetupPrizes(inst, prize_data)
    if not prize_data or not prize_data.count or prize_data.count < 1 then
        return
    end

    local prize_type = prize_data.type or "goldnugget"

    local prize_pouch = SpawnPrefab("redpouch_yotr")
    local prize_items = {}
    for _ = 1, prize_data.count do
        table.insert(prize_items, SpawnPrefab(prize_type))
    end

    prize_pouch.components.unwrappable:WrapItems(prize_items)
    for _, prize_item in ipairs(prize_items) do
        prize_item:Remove()
    end

    inst.components.inventory:GiveItem(prize_pouch)
    local fightprize_info = {}
    fightprize_info.prize = prize_pouch
    fightprize_info.winner = prize_data.winner
    table.insert(inst.fightprizes, fightprize_info)
end

local function OnPillowFightArrivedAtArena(inst, position)
    if inst.components.knownlocations then
        inst.components.knownlocations:RememberLocation("pillowfightlocation", position)
    end

    if inst.components.locomotor then
        inst.components.locomotor:GoToPoint(position, nil, true)
    end
end

local function OnPillowFightStarted(inst, arena)
    inst.components.knownlocations:ForgetLocation("pillowfightlocation")

    local start_position = inst:GetPositionAdjacentTo(arena, 2.0)
    inst.components.knownlocations:RememberLocation("yotr_fightring_fightstartpos", start_position)

    -- Clean up any pillow_attack_cooldown timers still ticking down from random swings
    inst.components.timer:StopTimer("pillow_attack_cooldown")
end

local function OnOutOfPillowFight(inst)
    inst.sg.mem.is_holding_overhead = nil
end

local function pillowfight_gohome(inst)
    inst.components.knownlocations:ForgetLocation("yotr_fightring_fightstartpos")
    inst._return_to_pillow_spot = true

    inst.return_home_task = nil
end

local function OnPillowFightDeactivated(inst)
    -- Add an extra forget here so we can conveniently use this event to also
    -- send home a rabbit if it's bumped out of the waiting circle.
    inst.components.knownlocations:ForgetLocation("pillowfightlocation")

    inst.components.entitytracker:ForgetEntity("arena")

    inst.components.combat:DropTarget()

    inst.return_home_task = inst:DoTaskInTime(math.random(1, 10)*FRAMES, pillowfight_gohome)
end

----------------------------------------------------
local BUNNYMAN_MUST = {"cozy_bunnyman"}
local function ontimerdone(inst, data)
    if data.name == "shouldhide" then
        inst.shouldhide = true
    elseif data.name == "yotr_waitforplayertoeat" then
        if inst.carrotgamestatus == "prizedelivered" then
            inst.sayspoilsport = true
        end
    end
end


local function finishgame(inst)

    local shrine = inst.components.entitytracker:GetEntity("shrine")
    if shrine then
       shrine.gameinprogress = nil
       shrine:SetShrineWinner(nil)

        for i, ent in ipairs(shrine:getrabbits())do
            ent.gamehost = nil    
            ent.carrotgamestatus = nil
            ent.gooptoeat = nil
        end
    end
end

local function WantsToGoBackToPillowSpot(inst)
    return inst._return_to_pillow_spot or (inst.return_home_task ~= nil)
end

-----------------------------------------------------------------------------------
local function OnSave(inst, data)
    data.return_to_pillow_spot = inst._return_to_pillow_spot
end

local function OnLoad(inst, data)
    if data then
        inst._return_to_pillow_spot = data.return_to_pillow_spot
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("manrabbit_build")
    inst.AnimState:AddOverrideBuild("manrabbit_actions")

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(1.25, 1.25, 1.25)

    inst:AddTag("character")
    inst:AddTag("pig")
    inst:AddTag("manrabbit")
    inst:AddTag("scarytoprey")
    inst:AddTag("cozy_bunnyman")

    inst.AnimState:SetBank("manrabbit")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:Hide("hat")
    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Hide("HAIR_HAT")

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 24
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -500, 0)
    inst.components.talker:MakeChatter()

    inst:WatchWorldState("isfullmoon", function(inst, isfullmoon)
        if isfullmoon then
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        else
            inst.AnimState:ClearBloomEffectHandle()
        end
    end)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.fightprizes = {}

    inst._minigame_retarget_test = function(guy)
        if guy.components.minigame_participator and inst.components.combat:CanTarget(guy) then
            local my_minigame = inst.components.minigame_participator:GetMinigame()
            return (not my_minigame or not my_minigame.IsCompeting or my_minigame:IsCompeting(guy))
                    and my_minigame == guy.components.minigame_participator:GetMinigame()
        else
            return false
        end
    end
    inst._normal_retarget_test = function(guy)
        return inst.components.combat:CanTarget(guy)
            and (guy:HasTag("monster")
                or guy:HasTag("wonkey")
                or guy:HasTag("pirate"))
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    inst.components.talker.ontalk = ontalk

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED * 2.2 -- account for them being stopped for part of their anim
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED * 1.9 -- account for them being stopped for part of their anim

    -- boat hopping setup
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:AddComponent("bloomer")

    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })
    inst.components.eater:SetCanEatRaw()

    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "manrabbit_torso"
    inst.components.combat.panic_thresh = TUNING.BUNNYMAN_PANIC_THRESH
    inst.components.combat.externaldamagetakenmultipliers:SetModifier(inst, 0.01, "cozy_bunnyman_cheat")

    inst.components.combat.GetBattleCryString = battlecry
    inst.components.combat.GetGiveUpString = giveupstring

    MakeMediumBurnableCharacter(inst, "manrabbit_torso")

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.BUNNYMANNAMES
    inst.components.named:PickNewName()

    ------------------------------------------
    inst:AddComponent("health")
    inst.components.health:StartRegen(TUNING.BUNNYMAN_HEALTH_REGEN_AMOUNT, TUNING.BUNNYMAN_HEALTH_REGEN_PERIOD)

    ------------------------------------------

    inst:AddComponent("inventory")

    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(LootSetupFunction)

    ------------------------------------------
    inst:AddComponent("knownlocations")

    ------------------------------------------
    inst:AddComponent("homeseeker")
    inst.components.homeseeker.removecomponent = false

    ------------------------------------------
    inst:AddComponent("entitytracker")

    ------------------------------------------
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false

    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------------------------------

    inst:AddComponent("sleeper")
    inst.components.sleeper.sleeptestfn = CozyBunnymanSleepTestFn
    inst.components.sleeper.waketestfn = CozyBunnymanWakeTestFn

    ------------------------------------------
    MakeMediumFreezableCharacter(inst, "pig_torso")

    ------------------------------------------
    inst:AddComponent("inspectable")

    ------------------------------------------
    inst:AddComponent("timer")

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("dropitem", OnItemDropped)
    inst:ListenForEvent("timerdone", ontimerdone)
    inst:ListenForEvent("itemget", OnGetItem)
    inst:ListenForEvent("setupprizes", OnSetupPrizes)
    inst:ListenForEvent("pillowfight_arrivedatarena", OnPillowFightArrivedAtArena)
    inst:ListenForEvent("pillowfight_startgame", OnPillowFightStarted)
    inst:ListenForEvent("pillowfight_ringout", OnOutOfPillowFight)
    inst:ListenForEvent("pillowfight_deactivated", OnPillowFightDeactivated)
    inst:ListenForEvent("pillowfight_ended", OnOutOfPillowFight)

    inst.OnAttacked = OnAttacked
    inst.finishgame = finishgame
    inst.WantsToGoBackToPillowSpot = WantsToGoBackToPillowSpot

    inst.components.combat:SetDefaultDamage(TUNING.BUNNYMAN_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BUNNYMAN_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)

    inst.components.locomotor.runspeed = TUNING.BUNNYMAN_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.BUNNYMAN_WALK_SPEED

    inst.components.health:SetMaxHealth(TUNING.BUNNYMAN_HEALTH)

    MakeHauntablePanic(inst)

    inst:DoTaskInTime(0,connecttofloorpillow)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGcozy_bunnyman")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("cozy_bunnyman", fn, assets, prefabs)
