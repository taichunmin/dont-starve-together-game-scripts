local assets =
{
    Asset("ANIM", "anim/player_basic.zip"),
    Asset("ANIM", "anim/player_actions.zip"),
    Asset("ANIM", "anim/player_actions_eat.zip"),
    Asset("ANIM", "anim/player_actions_item.zip"),
    Asset("ANIM", "anim/player_actions_fishing.zip"),
    Asset("ANIM", "anim/player_actions_fishing_ocean.zip"),
    Asset("ANIM", "anim/player_actions_fishing_ocean_new.zip"),
    Asset("ANIM", "anim/player_actions_pocket_scale.zip"),
    Asset("ANIM", "anim/wilson_fx.zip"),
    Asset("ANIM", "anim/player_frozen.zip"),
    Asset("ANIM", "anim/player_shock.zip"),
    Asset("ANIM", "anim/player_wrap_bundle.zip"),
    Asset("SOUND", "sound/sfx.fsb"),
    Asset("SOUND", "sound/wilson.fsb"),
    Asset("ANIM", "anim/player_hermitcrab_idle.zip"),
    Asset("ANIM", "anim/player_hermitcrab_walk.zip"),
    Asset("ANIM", "anim/player_hermitcrab_look.zip"),

    Asset("ANIM", "anim/hermitcrab_build.zip"),
}

local prefabs =
{
    "hermitcrab_marker",
    "hermit_bundle",
    "beebox_hermit",
    "meatrack_hermit",
    "hermit_pearl",
    "hermit_bundle_shells",
    "moon_fissure_plugged",
	"winter_ornament_boss_hermithouse",
	"winter_ornament_boss_pearl",
}

local SHOP_LEVELS =
{
    "HERMITCRABSHOP_L1",
    "HERMITCRABSHOP_L2",
    "HERMITCRABSHOP_L3",
    "HERMITCRABSHOP_L4",
    "HERMITCRABSHOP_L4",
}

local TASKS = {
    FIX_HOUSE_1 = 1,
    FIX_HOUSE_2 = 2,
    FIX_HOUSE_3 = 3,
    PLANT_FLOWERS = 4,
    REMOVE_JUNK = 5,
    PLANT_BERRIES = 6,
    FILL_MEATRACKS = 7,
    GIVE_HEAVY_FISH = 8,
    REMOVE_LUREPLANT = 9,
    GIVE_UMBRELLA = 10,
    GIVE_PUFFY_VEST =11,
    GIVE_FLOWER_SALAD = 12,

    GIVE_BIG_WINTER = 14,
    GIVE_BIG_SUMMER =15,
    GIVE_BIG_SPRING = 16,
    GIVE_BIG_AUTUM = 17,

    MAKE_CHAIR = 18,
}

local MEET_PLAYERS_RANGE_SQ = 20*20
local MEET_PLAYERS_FREQUENCY = 1.5

local function displaynamefn(inst)

    return inst:HasTag("highfriendlevel") and STRINGS.NAMES.HERMITCRAB_NAME or STRINGS.NAMES.HERMITCRAB
end

local function dotalkingtimers(inst)
    if inst.components.timer:TimerExists("speak_time") then
        inst.components.timer:SetTimeLeft("speak_time",TUNING.HERMITCRAB.SPEAKTIME)
    else
        inst.components.timer:StartTimer("speak_time",TUNING.HERMITCRAB.SPEAKTIME)
    end

    if inst.components.timer:TimerExists("complain_time") then
        local time = inst.components.timer:GetTimeLeft("complain_time")
        inst.components.timer:SetTimeLeft("complain_time", time + 10)
    else
        inst.components.timer:StartTimer("complain_time",10 + (math.random()*30))
    end
end

local function settextcolor(inst)
    local gfl = inst.getgeneralfriendlevel(inst)
    if gfl == "HIGH" then
        inst.components.talker.colour = Vector3(194/255, 149/255, 216/255)
    elseif gfl == "MED" then
        inst.components.talker.colour = Vector3(228/255, 163/255, 212/255)
    else
        inst.components.talker.colour = Vector3(241/255, 198/255, 211/255)
    end
end

local function ontalk(inst, script)
    if inst.components.friendlevels.level > 0 then
        settextcolor(inst)
    end
    inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/talk")
end

local function iscoat(item)
    return item.components.insulator and
           item.components.insulator:GetInsulation() >= TUNING.INSULATION_SMALL and
           item.components.insulator:GetType() == SEASONS.WINTER and
           item.components.equippable and
           item.components.equippable.equipslot == EQUIPSLOTS.BODY
end

local function item_is_umbrella(item)
    return item:HasTag("umbrella")
end

local function is_flowersalad(inst)
    return (inst.food_basename or inst.prefab) == "flowersalad"
end

local function ShouldAcceptItem(inst, item)
    -- Accept our pearl, and all ocean fish.
    if item.prefab == "hermit_cracked_pearl" or item:HasTag("oceanfish") then
        return true
    end

    -- Accept flower salad if we haven't had one recently.
    if is_flowersalad(item) and not inst.components.timer:TimerExists("salad") then
        return true
    end

    -- Accept if we're given an umbrella, when it's raining, and we don't already have one.
    if TheWorld.state.israining and item:HasTag("umbrella") then
        local handequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if (inst.components.inventory:FindItem(item_is_umbrella) == nil) and (not handequipped or not handequipped:HasTag("umbrella")) then
            return true
        end
    end

    -- Accept if we're given a coat, when it's showing, and we don't already have one.
    if TheWorld.state.issnowing and iscoat(item) then
        local bodyequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        if (inst.components.inventory:FindItem(iscoat) == nil) and (not bodyequipped or not iscoat(bodyequipped)) then
            return true
        end
    end

    return false
end

local function OnRefuseItem(inst, giver, item)
    if is_flowersalad(item) and inst.components.timer:TimerExists("salad") then
        inst.components.npc_talker:Chatter("HERMITCRAB_REFUSE_SALAD", nil)
    end

    if iscoat(item) then
        local bodyequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        local coat = inst.components.inventory:FindItem(function(testitem) return iscoat(testitem) end) or (bodyequipped and  iscoat(bodyequipped) and bodyequipped )

        if coat then
            inst.components.npc_talker:Chatter("HERMITCRAB_REFUSE_COAT_HASONE", 1)
        elseif not TheWorld.state.issnowing then
            inst.components.npc_talker:Chatter("HERMITCRAB_REFUSE_COAT", 1)
        end
    end

    if item:HasTag("umbrella") then
        local handequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local umbrella = inst.components.inventory:FindItem(function(testitem) return testitem:HasTag("umbrella") end) or (handequipped and  handequipped:HasTag("umbrella") and handequipped )

        if umbrella then
            inst.components.npc_talker:Chatter("HERMITCRAB_REFUSE_UMBRELLA_HASONE", 1)
        elseif not TheWorld.state.israining then
            inst.components.npc_talker:Chatter("HERMITCRAB_REFUSE_UMBRELLA", 1)
        end
    end
    if item.components.insulator and item.components.insulator:GetInsulation() >= TUNING.INSULATION_LARGE and item.components.insulator:GetType() == SEASONS.WINTER and item.components.equippable.equipslot == EQUIPSLOTS.BODY and not TheWorld.state.issnowing then
        inst.components.npc_talker:Chatter("HERMITCRAB_REFUSE_VEST", 1)
    end
    inst.sg:GoToState("refuse")
end

local normalbrain = require "brains/hermitcrabbrain"

local function OnActivatePrototyper(inst, doer, recipe)
    local gfl = inst.getgeneralfriendlevel(inst)
    inst.components.npc_talker:Chatter("HERMITCRAB_TALK_ONPURCHASE."..gfl, 1)
end

local function EnableShop(inst, shop_level)
    if inst.components.prototyper == nil then
        inst:AddComponent("prototyper")
        inst.components.prototyper.onactivate = OnActivatePrototyper
    end

    inst._shop_level = math.min(shop_level or inst._shop_level or 1, 5)
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES[SHOP_LEVELS[inst._shop_level]]
end

local function GetStatus(inst)
    return nil
end

local function OnSave(inst, data)
    data.shop_level = inst._shop_level
    data.heavyfish = inst.heavyfish
    data.introduced = inst.introduced
    data.pearlgiven = inst.pearlgiven
    if inst.storelevelunlocktask then
        data.storelevelunlocked = true
    end
    data.highfriendlevel = inst:HasTag("highfriendlevel")
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.shop_level ~= nil and data.shop_level > 0 then
            inst._shop_level = data.shop_level
            EnableShop(inst, inst._shop_level)
        end
        if data.heavyfish then
            inst.heavyfish = data.heavyfish
        end
        if data.storelevelunlocked then
            inst.storelevelunlocked(inst)
        end
        if data.introduced then
            inst.introduced = data.introduced
        end
        if data.pearlgiven then
            inst.pearlgiven = data.pearlgiven
        end
        if data.highfriendlevel then
            inst:AddTag("highfriendlevel")
        end
    end
end


local function is_carpentry_blueprint(item)
    return (item.prefab == "blueprint" and item.recipetouse == "carpentry_station")
end

local function generate_comment_data_for_loaded_target(inst, target)
    local general_friend_level = inst:getgeneralfriendlevel()
    local script, distance = nil, nil
    if target:HasTag("uncomfortable_chair") then
        script = {
            Line(STRINGS.HERMITCRAB_INVESTIGATE.MAKE_UNCOMFORTABLE_CHAIR[general_friend_level][1])
        }

        local stored_blueprint = inst.components.inventory:FindItem(is_carpentry_blueprint)
        if stored_blueprint then
            inst.components.entitytracker:TrackEntity("commentitemtotoss", stored_blueprint)
            table.insert(script, Line(STRINGS.HERMITCRAB_INVESTIGATE.GIVE_CARPENTRY_BLUEPRINT[general_friend_level][1]))
        end
        distance = 1.0
    end

    return script, distance
end

local function OnLoadPostPass(inst, new_ents, data)
    local comment_target = inst.components.entitytracker:GetEntity("commenttarget")
    if comment_target and not inst.comment_data then
        local comment_script, comment_distance = generate_comment_data_for_loaded_target(inst, comment_target)
        inst.comment_data = {
            pos = comment_target:GetPosition(),
            speech = comment_script,
            distance = comment_distance
        }
    end

	-- This is only done for retrofitting, it is not normally needed, do not copy/paste this

	if inst._shop_level ~= nil and inst._shop_level >= 5 then
		inst.components.craftingstation:LearnItem("supertacklecontainer", "hermitshop_supertacklecontainer")
	end

	if inst.pearlgiven then
		inst.components.craftingstation:LearnItem("winter_ornament_boss_pearl", "hermitshop_winter_ornament_boss_pearl")
	end

    if inst.components.friendlevels.friendlytasks[TASKS.FIX_HOUSE_3].complete and IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
		inst.components.craftingstation:LearnItem("winter_ornament_boss_hermithouse", "hermitshop_winter_ornament_boss_hermithouse")
	end
end

local function RegisterToBottleManager(inst)
    if TheWorld.components.messagebottlemanager ~= nil then
        TheWorld.components.messagebottlemanager.hermitcrab = inst
    end
end

local function getgeneralfriendlevel(inst)
    local level_number = inst.components.friendlevels.level
    return (level_number > 7 and "HIGH")    -- 8+ for high
        or (level_number > 3 and "MED")     -- 4-7 for med
        or "LOW"
end

-- FRIENDLEVELS content
local function complain(inst)
    local problems = inst.components.friendlevels.friendlytasks
    local potential_complainstrings = {}
    local num_complainstrings = 0
    for _, problem in ipairs(problems) do
        if problem.complain and not problem.complete and ( not problem.complaintest or problem.complaintest(inst) ) then
            table.insert(potential_complainstrings, problem.complainstrings)
            num_complainstrings = num_complainstrings + 1
        end
    end

    if num_complainstrings > 0 then
        local gfl = getgeneralfriendlevel(inst)
        inst.components.npc_talker:Chatter(potential_complainstrings[math.random(num_complainstrings)].."."..gfl, nil)

        if inst.components.timer:TimerExists("speak_time") then
            inst.components.timer:StopTimer("speak_time")
        end
        inst.components.timer:StartTimer("speak_time",TUNING.HERMITCRAB.SPEAKTIME)
    end

    inst.components.timer:StartTimer("complain_time",10 + (math.random()*30))
end

local function rewardcheck(inst)
    if #inst.components.friendlevels.queuedrewards <= 0 then
        return
    end

    local task = nil
    local group = nil
    for _, reward in ipairs(inst.components.friendlevels.queuedrewards) do
        if reward.task ~= "default" then
            if not task then
                task = reward.task
            else
                group = true
                break
            end
        end
    end

    local str
    local gfl = inst.getgeneralfriendlevel(inst)
    if gfl == "HIGH" and not inst.introduced then
        inst.introduced = true
        str = "HERMITCRAB_INTRODUCE"
    elseif group then
        str = "HERMITCRAB_GROUP_REWARD."..gfl
    elseif task then
        local problems = inst.components.friendlevels.friendlytasks
        local problem_for_task = problems[task]

        str = problem_for_task.completestrings.."."..gfl

        if problem_for_task.specifictaskreward then
            inst.components.friendlevels.specifictaskreward = problem_for_task.specifictaskreward
        end
    else
        str = "HERMITCRAB_DEFAULT_REWARD."..gfl
    end

    local gifts = inst.components.friendlevels:DoRewards()
    if #gifts > 0 then
        inst.itemstotoss = inst.itemstotoss or {}

        ConcatArrays(inst.itemstotoss, gifts)

        for _, gift in ipairs(gifts) do
            inst.components.inventory:GiveItem(gift)
        end
    end

    -- overrides the hermit making a comment on a task that's been partially done,
    -- to reward the player for one that is done
    inst.comment_data = nil
    return str
end

local STOP_RUN_DIST = 8

local function onTaskComplete(inst, defaulttask)
    if not inst.giverewardstask then
        inst.giverewardstask = inst:DoPeriodicTask(0.5, function()
            if inst.sg:HasStateTag("ishome") then
                return
            end

            local player = FindClosestPlayerToInst(inst, STOP_RUN_DIST, true)
            if not player then
                return
            end

            local str = rewardcheck(inst)
            if str then
                inst.components.timer:StartTimer("speak_time",TUNING.HERMITCRAB.SPEAKTIME)

                if inst.components.timer:TimerExists("complain_time") then
                    local time = inst.components.timer:GetTimeLeft("complain_time")
                    inst.components.timer:SetTimeLeft("complain_time", time + 10)
                else
                    inst.components.timer:StartTimer("complain_time",10 + (math.random()*30))
                end
                local sound = (not defaulttask
                    and "hookline_2/characters/hermit/friendship_music/"..inst.components.friendlevels.level)
                    or nil
                inst.components.npc_talker:Chatter(str, nil, nil, nil, nil, sound)
            end

            if inst.giverewardstask then
                inst.giverewardstask:Cancel()
                inst.giverewardstask = nil
            end
        end)
    end

    if inst.getgeneralfriendlevel(inst) == "HIGH" and not inst:HasTag("highfriendlevel")  then
        inst:AddTag("highfriendlevel")
        if inst.components.homeseeker and inst.components.homeseeker.home then
            inst.components.homeseeker.home:AddTag("highfriendlevel")
        end
    end
end


local function storelevelunlocked(inst)
    if not inst.storelevelunlocktask then
        inst.storelevelunlocktask = inst:DoPeriodicTask(2.0, function()
            if not inst.sg:HasStateTag("ishome") and not inst.giverewardstask and not inst.components.timer:TimerExists("speak_time") then
                local player = FindClosestPlayerToInst(inst, STOP_RUN_DIST, true)
                if player then

                    inst.components.timer:StartTimer("speak_time",TUNING.HERMITCRAB.SPEAKTIME)
                    if inst.components.timer:TimerExists("complain_time") then
                        local time = inst.components.timer:GetTimeLeft("complain_time")
                        inst.components.timer:SetTimeLeft("complain_time", time + 10)
                    else
                        inst.components.timer:StartTimer("complain_time",10 + (math.random()*30))
                    end
                    inst.components.npc_talker:Chatter("HERMITCRAB_STORE_UNLOCK_"..inst._shop_level, nil)

                    if inst.storelevelunlocktask then
                        inst.storelevelunlocktask:Cancel()
                        inst.storelevelunlocktask = nil
                    end
                end
            end
        end)
    end
end

local function extrarewardcheck(inst, gifts)
    if inst.extrareward then
        for i,gift in ipairs(inst.extrareward) do
            table.insert(gifts,SpawnPrefab(gift))
        end
        inst.extrareward = nil
    end
    return gifts
end

local function createbundle(inst,gifts)
    local final = {}
    if #gifts >0 then
        local pouch = SpawnPrefab("hermit_bundle")
        local prize_items = {}
        for _, p in ipairs(gifts) do
            table.insert(prize_items, SpawnPrefab(p))
        end
        pouch.components.unwrappable:WrapItems(prize_items)
		for i, v in ipairs(prize_items) do
			v:Remove()
		end
        table.insert(final,pouch)
    end
    final = extrarewardcheck(inst, final)


    if inst.components.friendlevels.level >= 10 and not inst.pearlgiven and inst.components.friendlevels.friendlytasks[TASKS.FIX_HOUSE_3].complete then
        if inst.components.friendlevels.friendlytasks[TASKS.FIX_HOUSE_3].complete then
            inst.pearlgiven = true
            table.insert(final,SpawnPrefab("hermit_pearl"))
            inst:DoTaskInTime(0,function()
                inst.components.npc_talker:Chatter("HERMITCRAB_GIVE_PEARL")
            end)
        else
            inst:DoTaskInTime(0,function()
                inst.components.npc_talker:Chatter("HERMITCRAB_WANT_HOUSE")
            end)
        end
    end

    return final
end

local hermit_bundle_shell_loots =
{
    singingshell_octave5 = 2,
    singingshell_octave4 = 2,
    singingshell_octave3 = 1,
}

local seasonal_lure =
{
    oceanfishinglure_hermit_rain = 1,
    oceanfishinglure_hermit_snow = 1,
    oceanfishinglure_hermit_drowsy = 1,
    oceanfishinglure_hermit_heavy = 1,
}

local function addhoneyrewards(inst,gifts)
    if inst.components.friendlevels.friendlytasks[TASKS.PLANT_FLOWERS].complete then
        table.insert(gifts,"honey")
    end
end

local function addtaskrewards(inst, gifts, task_id)
	if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
		if task_id == TASKS.FIX_HOUSE_3 then
			table.insert(gifts, "winter_ornament_boss_hermithouse")
		end
	end
end

local function defaultfriendrewards(inst, target, task_id)
	local gifts = {}
	for i=1,3 do
		table.insert(gifts, weighted_random_choice(hermit_bundle_shell_loots))
	end
	addhoneyrewards(inst, gifts)
	return createbundle(inst, gifts)
end

local function friendlevel_1_reward(inst, target, task_id)
    EnableShop(inst, 1)
    storelevelunlocked(inst)

    local gifts = {}
	addtaskrewards(inst, gifts, task_id)
    return createbundle(inst, gifts)
end

local function friendlevel_2_reward(inst, target, task_id)
    local gifts = {}
    table.insert(gifts, weighted_random_choice(seasonal_lure))
    addhoneyrewards(inst, gifts)
	addtaskrewards(inst, gifts, task_id)
    return createbundle(inst, gifts)
end

local function friendlevel_3_reward(inst, target, task_id)
    EnableShop(inst, 2)
    storelevelunlocked(inst)

    local gifts = {}
	addtaskrewards(inst, gifts, task_id)
    return createbundle(inst, gifts)
end

local function friendlevel_4_reward(inst, target, task_id)
    local gifts = {}
    for i=1,3 do
        table.insert(gifts, weighted_random_choice(hermit_bundle_shell_loots))
    end
    table.insert(gifts, weighted_random_choice(seasonal_lure))
    addhoneyrewards(inst, gifts)
	addtaskrewards(inst, gifts, task_id)
    return createbundle(inst, gifts)
end

local function friendlevel_5_reward(inst, target, task_id)
    local gifts = {}
    for i=1,3 do
        table.insert(gifts, weighted_random_choice(hermit_bundle_shell_loots))
    end
    table.insert(gifts, weighted_random_choice(seasonal_lure))
    addhoneyrewards(inst, gifts)
	addtaskrewards(inst, gifts, task_id)
    return createbundle(inst, gifts)
end

local function friendlevel_6_reward(inst, target, task_id)
    EnableShop(inst,3)
    storelevelunlocked(inst)

    local gifts = {}
	addtaskrewards(inst, gifts, task_id)
    return createbundle(inst, gifts)
end

local function friendlevel_7_reward(inst, target, task_id)
    local gifts = {}
    for i=1,3 do
        table.insert(gifts, weighted_random_choice(hermit_bundle_shell_loots))
    end
    table.insert(gifts, weighted_random_choice(seasonal_lure))
    addhoneyrewards(inst, gifts)
	addtaskrewards(inst, gifts, task_id)
    return createbundle(inst, gifts)
end

local function friendlevel_8_reward(inst, target, task_id)
    EnableShop(inst,4)
    storelevelunlocked(inst)

    local gifts = {}
	addtaskrewards(inst, gifts, task_id)
    return createbundle(inst, gifts)
end

local function friendlevel_9_reward(inst, target, task_id)
	inst.components.craftingstation:LearnItem("supertacklecontainer", "hermitshop_supertacklecontainer")
    inst._shop_level = 5
    storelevelunlocked(inst)

    local gifts = {}
	addtaskrewards(inst, gifts, task_id)
    return createbundle(inst, gifts)
end

local function friendlevel_10_reward(inst, target, task_id)
	inst.components.craftingstation:LearnItem("winter_ornament_boss_pearl", "hermitshop_winter_ornament_boss_pearl")

    local gifts = {}
	if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
		table.insert(gifts, "winter_ornament_boss_pearl")
	end
	addtaskrewards(inst, gifts, task_id)
    return createbundle(inst, gifts)
end

local ISLAND_RADIUS = 35

local friendlevelrewards = {
    friendlevel_1_reward, --1
    friendlevel_2_reward, --2
    friendlevel_3_reward, --3
    friendlevel_4_reward, --4
    friendlevel_5_reward, --5
    friendlevel_6_reward, --6
    friendlevel_7_reward, --7
    friendlevel_8_reward, --8
    friendlevel_9_reward, --9
    friendlevel_10_reward, --10
}


local FIND_LUREPLANT_TAGS = {"lureplant"}
local FIND_FLOWER_TAGS = {"flower"}
local FIND_PLANT_TAGS = {"bush","plant"}
local FIND_STRUCTURE_TAGS = {"structure"}
local FIND_HEAVY_TAGS = {"underwater_salvageable"}
local FIND_HERMITCRAB_LURE_MARKER_TAGS = {"hermitcrab_lure_marker"}
local FIND_CHAIR_ONEOF_TAGS = {"faced_chair","limited_chair"}
local FIND_CHAIR_CANT_TAGS = {"uncomfortable_chair"}
local FIND_BLUEPRINT_TAGS = {"_inventoryitem"}

local function lureplantcomplainfn(inst)
    local source = inst.CHEVO_marker
    if source then
        local pos = Vector3(source.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, ISLAND_RADIUS, FIND_LUREPLANT_TAGS)
        if #ents > 0 then
            return true
        end
    end
end
local function plantflowerscomplainfn(inst)
    local source = inst.CHEVO_marker
    if source then
        local pos = Vector3(source.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, ISLAND_RADIUS, FIND_FLOWER_TAGS)
        if #ents < 10 then
            return true
        end
    end
end

local function berriescomplainfn(inst)
    local source = inst.CHEVO_marker
    if source then
        local pos = Vector3(source.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, ISLAND_RADIUS, FIND_PLANT_TAGS)
        for i=#ents,1,-1 do
            if not ents[i].components.pickable or ents[i].components.pickable:IsBarren() then
                table.remove(ents,i)
            end
        end
        if #ents < 8 then
            return true
        end
    end
end

local function meatcomplainfn(inst)
    local source = inst.CHEVO_marker
    if source then
        local pos = Vector3(source.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, ISLAND_RADIUS, FIND_STRUCTURE_TAGS)
        for i=#ents,1,-1 do
            if not ents[i].components.dryer or not ents[i].components.dryer.product then
                table.remove(ents,i)
            end
        end
        if #ents <= 0 then
            return true
        end
    end
end

local function umbrellacomplainfn(inst)
    if TheWorld.state.israining then
        return true
    end
end
local function puffycomplainfn(inst)
    if TheWorld.state.issnowing then
        return true
    end
end
local function saladcomplainfn(inst)
   if TheWorld.state.issummer then
        return true
    end
end

local function fishautumfn(inst)
   if TheWorld.state.isautumn then
        return true
    end
end

local function fishspringfn(inst)
    if TheWorld.state.isspring then
        return true
    end
end

local function fishsummerfn(inst)
    if TheWorld.state.issummer then
        return true
    end
end

local function fishwinterfn(inst)
    if TheWorld.state.iswinter then
        return true
    end
end

local function buildchairfn(inst)
    local source = inst.CHEVO_marker
    if source then
        local source_x, source_y, source_z = source.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(source_x, source_y, source_z, ISLAND_RADIUS, nil, FIND_CHAIR_CANT_TAGS, FIND_CHAIR_ONEOF_TAGS)
        if #ents > 0 then
            return true
        end
    end
end

local friendlytasks ={
    [TASKS.FIX_HOUSE_1] =       {completestrings="HERMITCRAB_REWARD.FIX_HOUSE_1"},
    [TASKS.FIX_HOUSE_2] =       {completestrings="HERMITCRAB_REWARD.FIX_HOUSE_2"},
    [TASKS.FIX_HOUSE_3] =       {completestrings="HERMITCRAB_REWARD.FIX_HOUSE_3"},
    [TASKS.PLANT_FLOWERS] =     {completestrings="HERMITCRAB_REWARD.PLANT_FLOWERS",     complain=true, complainstrings="HERMITCRAB_COMPLAIN.PLANT_FLOWERS",      complaintest=plantflowerscomplainfn,   onetime = true},
    [TASKS.REMOVE_JUNK] =       {completestrings="HERMITCRAB_REWARD.REMOVE_JUNK",       complain=true, complainstrings="HERMITCRAB_COMPLAIN.REMOVE_JUNK",     onetime = true},
    [TASKS.PLANT_BERRIES] =     {completestrings="HERMITCRAB_REWARD.PLANT_BERRIES",     complain=true, complainstrings="HERMITCRAB_COMPLAIN.PLANT_BERRIES",      complaintest=berriescomplainfn,        onetime = true},
    [TASKS.FILL_MEATRACKS] =    {completestrings="HERMITCRAB_REWARD.FILL_MEATRACKS",    complain=true, complainstrings="HERMITCRAB_COMPLAIN.FILL_MEATRACKS",     complaintest=meatcomplainfn},
    [TASKS.GIVE_HEAVY_FISH] =   {completestrings="HERMITCRAB_REWARD.GIVE_HEAVY_FISH",   complain=true, complainstrings="HERMITCRAB_COMPLAIN.GIVE_HEAVY_FISH"},
    [TASKS.REMOVE_LUREPLANT] =  {completestrings="HERMITCRAB_REWARD.REMOVE_LUREPLANT",  complain=true, complainstrings="HERMITCRAB_COMPLAIN.REMOVE_LUREPLANT",   complaintest=lureplantcomplainfn},
    [TASKS.GIVE_UMBRELLA] =     {completestrings="HERMITCRAB_REWARD.GIVE_UMBRELLA",     complain=true, complainstrings="HERMITCRAB_COMPLAIN.GIVE_UMBRELLA",      complaintest=umbrellacomplainfn},
    [TASKS.GIVE_PUFFY_VEST] =   {completestrings="HERMITCRAB_REWARD.GIVE_PUFFY_VEST",   complain=true, complainstrings="HERMITCRAB_COMPLAIN.GIVE_PUFFY_VEST",    complaintest=puffycomplainfn},
    [TASKS.GIVE_FLOWER_SALAD] = {completestrings="HERMITCRAB_REWARD.GIVE_FLOWER_SALAD", complain=true, complainstrings="HERMITCRAB_COMPLAIN.GIVE_FLOWER_SALAD",  complaintest=saladcomplainfn},

    [TASKS.GIVE_BIG_WINTER] =   {completestrings="HERMITCRAB_REWARD.GIVE_FISH_WINTER",  complain=true, complainstrings="HERMITCRAB_COMPLAIN.GIVE_FISH_WINTER",  complaintest=fishwinterfn}, -- oceanfish_medium_8
    [TASKS.GIVE_BIG_SUMMER] =   {completestrings="HERMITCRAB_REWARD.GIVE_FISH_SUMMER",  complain=true, complainstrings="HERMITCRAB_COMPLAIN.GIVE_FISH_SUMMER",  complaintest=fishsummerfn}, -- oceanfish_small_8
    [TASKS.GIVE_BIG_SPRING] =   {completestrings="HERMITCRAB_REWARD.GIVE_FISH_SPRING",  complain=true, complainstrings="HERMITCRAB_COMPLAIN.GIVE_FISH_SPRING",  complaintest=fishspringfn}, -- oceanfish_small_7
    [TASKS.GIVE_BIG_AUTUM]  =   {completestrings="HERMITCRAB_REWARD.GIVE_FISH_AUTUM",   complain=true, complainstrings="HERMITCRAB_COMPLAIN.GIVE_FISH_AUTUM",   complaintest=fishautumfn},  -- oceanfish_small_6

    [TASKS.MAKE_CHAIR]      =   {completestrings="HERMITCRAB_REWARD.MAKE_CHAIR",        complain=true, complainstrings="HERMITCRAB_COMPLAIN.MAKE_CHAIR",        complaintest=buildchairfn, onetime = true},
}

local function initfriendlevellisteners(inst)
    -- FIX_HOUSE_1, FIX_HOUSE_2, FIX_HOUSE_3
    inst:ListenForEvent("home_upgraded", function(inst,data)
        if data.house.prefab == "hermithouse_construction2" then
            inst.components.friendlevels:CompleteTask(TASKS.FIX_HOUSE_1, data.doer)
        elseif data.house.prefab == "hermithouse_construction3" then
            inst.components.friendlevels:CompleteTask(TASKS.FIX_HOUSE_2, data.doer)
        else
            inst.components.friendlevels:CompleteTask(TASKS.FIX_HOUSE_3, data.doer)
			if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
				inst.components.craftingstation:LearnItem("winter_ornament_boss_hermithouse", "hermitshop_winter_ornament_boss_hermithouse")
			end
        end
    end)

    --PLANT_FLOWERS
    inst:ListenForEvent("CHEVO_growfrombutterfly", function(world,data)
        local source = inst.CHEVO_marker
        if source and data.target:GetDistanceSqToInst(source) < ISLAND_RADIUS * ISLAND_RADIUS then
            local source_x, source_y, source_z = source.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(source_x, source_y, source_z, ISLAND_RADIUS, FIND_FLOWER_TAGS)

            -- INVESTIGATE
            local gfl = inst.getgeneralfriendlevel(inst)
            if not inst.comment_data then
                inst.comment_data = {
                    pos = data.target:GetPosition(),
                    do_chatter = true,
                    speech = "HERMITCRAB_INVESTIGATE.PLANT_FLOWERS."..gfl,
                    chat_priority = CHATPRIORITIES.HIGH,
                }
            end

            if #ents >= 10 then
                inst.components.friendlevels:CompleteTask(TASKS.PLANT_FLOWERS, data.doer)
            end

        end
    end, TheWorld)

    --MAKE CHAIR
    inst:ListenForEvent("CHEVO_makechair", function(world, data)
        local source = inst.CHEVO_marker
        if not source then return end

        local target = data.target
        local target_x, target_y, target_z = target.Transform:GetWorldPosition()
        local source_x, source_y, source_z = source.Transform:GetWorldPosition()
        if distsq(target_x, target_z, source_x, source_z) >= ISLAND_RADIUS * ISLAND_RADIUS then
            return
        end

        local entitytracker = inst.components.entitytracker

        local doer = data.doer
        local target_is_uncomfortable = target:HasTag("uncomfortable_chair")
        local blueprint_given = false
        local blueprint_on_ground, blueprint_in_limbo = false, false
        local doer_knows_blueprint = (doer == nil or (doer.components.builder ~= nil and doer.components.builder:KnowsRecipe("carpentry_station")))
        if target_is_uncomfortable and not doer_knows_blueprint then
            local blueprint_in_inventory = nil
            local nearby_blueprints = TheSim:FindEntities(source_x, source_y, source_z, ISLAND_RADIUS, FIND_BLUEPRINT_TAGS)
            for _, nearby_blueprint in ipairs(nearby_blueprints) do
                if is_carpentry_blueprint(nearby_blueprint) then
                    -- Track the blueprint separately if it's in our own inventory, as it might be there due to
                    -- a save/load, or some other interruption. If it's the only one, we'll want to toss it out,
                    -- and not try to create a new one. It also shouldn't block giving out the blueprints.
                    if nearby_blueprint.components.inventoryitem:IsHeldBy(inst) then
                        blueprint_in_inventory = nearby_blueprint
                    else
                        if nearby_blueprint:IsInLimbo() then
                            blueprint_in_limbo = true
                        else
                            blueprint_on_ground = true
                        end
                        break
                    end
                end
            end

            if not blueprint_on_ground and not blueprint_in_limbo then
                if not entitytracker:GetEntity("commentitemtotoss") then
                    if blueprint_in_inventory then
                        entitytracker:TrackEntity("commentitemtotoss", blueprint_in_inventory)
                    else
                        local carpentry_blueprint = SpawnPrefab("carpentry_station_blueprint")
                        entitytracker:TrackEntity("commentitemtotoss", carpentry_blueprint)
                        inst.components.inventory:GiveItem(carpentry_blueprint)
                    end
                end

                blueprint_given = true
            end
        end

        -- INVESTIGATE
        if not inst.comment_data then
            entitytracker:TrackEntity("commenttarget", target)

            local general_friend_level = inst:getgeneralfriendlevel()
            local lines = {}
            if target_is_uncomfortable then
                table.insert(lines, Line(STRINGS.HERMITCRAB_INVESTIGATE.MAKE_UNCOMFORTABLE_CHAIR[general_friend_level][1]))
            end

            local additional_lines_table = (blueprint_given and STRINGS.HERMITCRAB_INVESTIGATE.GIVE_CARPENTRY_BLUEPRINT[general_friend_level])
                or (doer_knows_blueprint and STRINGS.HERMITCRAB_INVESTIGATE.ALREADY_KNOWS_CARPENTRY[general_friend_level])
                or (blueprint_on_ground and STRINGS.HERMITCRAB_INVESTIGATE.CARPENTRY_BLUEPRINT_ONGROUND[general_friend_level])
                or (blueprint_in_limbo and STRINGS.HERMITCRAB_INVESTIGATE.CARPENTRY_BLUEPRINT_ININVENTORY[general_friend_level])
                or nil
            if additional_lines_table then
                for _, line in ipairs(additional_lines_table) do
                    table.insert(lines, Line(line))
                end
            end

            inst.comment_data = {
                pos = target:GetPosition(),
                distance = 1.0,
                speech = lines,
            }
        end
    end, TheWorld)

    --FILL_MEATRACKS
    inst:ListenForEvent("CHEVO_starteddrying", function(world,data)
        local source = inst.CHEVO_marker
        if source and data.target:GetDistanceSqToInst(source) < ISLAND_RADIUS * ISLAND_RADIUS then
            local source_x, source_y, source_z = source.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(source_x, source_y, source_z, ISLAND_RADIUS, FIND_STRUCTURE_TAGS)
            local ent_dryer = nil
            for i=#ents,1,-1 do
                ent_dryer = ents[i].components.dryer
                if not ent_dryer or not ent_dryer.product then
                    table.remove(ents,i)
                end
            end

            -- INVESTIGATE
            local gfl = inst.getgeneralfriendlevel(inst)
            if not inst.comment_data then
                inst.comment_data = {
                    pos = data.target:GetPosition(),
                    do_chatter = true,
                    speech = "HERMITCRAB_INVESTIGATE.FILL_MEATRACKS."..gfl,
                    chat_priority = CHATPRIORITIES.HIGH,
                }
            end

            if #ents >= 6 and not inst.driedthings then
                inst.driedthings = 0
                inst.components.friendlevels:CompleteTask(TASKS.FILL_MEATRACKS, data.doer)
            end
        end
    end, TheWorld)

    --PLANT_BERRIES
    inst:ListenForEvent("CHEVO_fertilized", function(world,data)
        local source = inst.CHEVO_marker
        if source and data.target:GetDistanceSqToInst(source) < ISLAND_RADIUS * ISLAND_RADIUS then
            local source_x, source_y, source_z = source.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(source_x, source_y, source_z, ISLAND_RADIUS, FIND_PLANT_TAGS)
            local ent_pickable = nil
            for i=#ents,1,-1 do
                ent_pickable = ents[i].components.pickable
                if not ent_pickable or ent_pickable:IsBarren() then
                    table.remove(ents,i)
                end
            end

            -- INVESTIGATE
            local gfl = inst.getgeneralfriendlevel(inst)
            if not inst.comment_data then
                inst.comment_data = {
                    pos = data.target:GetPosition(),
                    do_chatter = true,
                    speech = "HERMITCRAB_INVESTIGATE.PLANT_BERRIES."..gfl,
                    chat_priority = CHATPRIORITIES.HIGH,
                }
            end

            if #ents >= 8 then
                inst.components.friendlevels:CompleteTask(TASKS.PLANT_BERRIES, data.doer)
            end
        end
    end, TheWorld)

    --REMOVE_JUNK
    local function checkforclearwaters(inst, data)
        local source = inst.CHEVO_marker
        local range = ISLAND_RADIUS + 10
        if source and data.target:GetDistanceSqToInst(source) < range * range then
            local x, y, z = source.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, range, FIND_HEAVY_TAGS)
            if #ents == 0 then
                inst.components.friendlevels:CompleteTask(TASKS.REMOVE_JUNK, data.doer)
            end
        end
    end

    inst:ListenForEvent("CHEVO_heavyobject_winched", function(world,data)
        checkforclearwaters(inst,data)
    end, TheWorld)

    --REMOVE_LUREPLANT
    local function checklureplant(inst,data)
        local source = inst.CHEVO_marker
        local range = ISLAND_RADIUS +10
        if source and source:GetDistanceSqToPoint(data.pt) < range * range then
            local x, y, z = source.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, range, FIND_LUREPLANT_TAGS)
            for i=#ents,1,-1 do
                if ents[i].components.health:IsDead() then
                    table.remove(ents,i)
                end
            end

            -- INVESTIGATE
            local gfl = inst.getgeneralfriendlevel(inst)
            if not inst.comment_data then
                inst.comment_data = {
                    pos = data.target:GetPosition(),
                    do_chatter = true,
                    speech = "HERMITCRAB_INVESTIGATE.REMOVE_LUREPLANT."..gfl,
                    chat_priority = CHATPRIORITIES.HIGH,
                }
            end

            if #ents <= 0 then
                inst.components.friendlevels:CompleteTask(TASKS.REMOVE_LUREPLANT)
            end
        end
    end
    inst:ListenForEvent("CHEVO_lureplantdied", function(world,data)
        if data.target and data.target:HasTag("planted") then
            -- INVESTIGATE
            local gfl = inst.getgeneralfriendlevel(inst)
            if not inst.comment_data then
                inst.comment_data = {
                    pos = data.target:GetPosition(),
                    do_chatter = true,
                    speech = "HERMITCRAB_PLANTED_LUREPLANT_DIED."..gfl,
                    chat_priority = CHATPRIORITIES.LOW,
                }
            end
        else
            checklureplant(inst,data)
        end
    end, TheWorld)

    -- ITEMS
    inst:ListenForEvent("itemget", function(world,data)
        local item = data.item
        if item:HasTag("oceanfish") then

            local str = nil
            local completetask = nil
            local keepitem = false
             -- IN CASE OF PREVIOUS ERROR

            if inst.itemstotoss then
                for _, gift in ipairs(inst.itemstotoss) do
                    inst.components.inventory:DropItem(gift)
                    inst.components.lootdropper:FlingItem(gift)
                end
                inst.itemstotoss = nil
            end

            if item.components.weighable:GetWeightPercent() >= TUNING.HERMITCRAB.HEAVY_FISH_THRESHHOLD then

                local is_special_fish = false

                local dospecialfish = function(task, tacklesketch)
                    is_special_fish = true
                    completetask = task
                    inst.extrareward = inst.extrareward or {}
                    table.insert(inst.extrareward, tacklesketch)
                end

                if item.prefab == "oceanfish_small_6_inv" then
                    dospecialfish(TASKS.GIVE_BIG_AUTUM, "oceanfishinglure_hermit_drowsy_tacklesketch")
                elseif item.prefab == "oceanfish_small_7_inv" then
                    dospecialfish(TASKS.GIVE_BIG_SPRING, "oceanfishinglure_hermit_rain_tacklesketch")
                elseif item.prefab == "oceanfish_small_8_inv" then
                    dospecialfish(TASKS.GIVE_BIG_SUMMER, "oceanfishinglure_hermit_heavy_tacklesketch")
                elseif item.prefab == "oceanfish_medium_8_inv" then
                    dospecialfish(TASKS.GIVE_BIG_WINTER, "oceanfishinglure_hermit_snow_tacklesketch")
                end

                if not is_special_fish then
                    inst.heavyfish = (inst.heavyfish or 0) + 1
                    if inst.heavyfish == 5 then
                        completetask = TASKS.GIVE_HEAVY_FISH
                        inst.heavyfish = nil
                    end
                end

				str = "HERMITCRAB_GETFISH_BIG"
            else
                local weight = item.components.weighable:GetWeight()
                str = subfmt(STRINGS.HERMITCRAB_REFUSE_SMALL_FISH[math.random(#STRINGS.HERMITCRAB_REFUSE_SMALL_FISH)], {weight = string.format("%0.2f", weight)})

                inst.itemstotoss = inst.itemstotoss or {}
                table.insert(inst.itemstotoss, item)

                keepitem = true
            end

            if str then
                inst:PushEvent("use_pocket_scale", {str=str, target=item})
            end

            if completetask then
                inst.delayfriendtask = completetask
            end

            if not keepitem then
                item:Remove()
            end
        elseif item:HasTag("umbrella") and TheWorld.state.israining then
            inst.components.inventory:Equip(item)
            inst.components.friendlevels:CompleteTask(TASKS.GIVE_UMBRELLA)

        elseif iscoat(item) and TheWorld.state.issnowing then
            inst.components.inventory:Equip(item)
            inst.components.friendlevels:CompleteTask(TASKS.GIVE_PUFFY_VEST)
        elseif is_flowersalad(item) then
            inst.components.friendlevels:CompleteTask(TASKS.GIVE_FLOWER_SALAD)
            inst.components.timer:StartTimer("salad", TUNING.TOTAL_DAY_TIME * 10 )
            inst:PushEvent("eat_food")
            item:Remove()
        elseif item.prefab == "hermit_cracked_pearl" then
            inst.components.npc_talker:Chatter("HERMITCRAB_GOT_PEARL")
            item:RemoveTag("irreplaceable")
            item:Remove()
        elseif item.components.edible then
            if inst.driedthings then
                inst.driedthings = inst.driedthings + 1
                if inst.driedthings == 6 then
                    inst.driedthings = nil
                end
            end
            inst:PushEvent("eat_food")
            item:Remove()
        end
    end)

    -- Friend level deltas.
    inst:ListenForEvent("friend_level_changed", function(inst, data)
        local worldmeteorshower = TheWorld.components.worldmeteorshower
        if worldmeteorshower ~= nil then
            local odds = inst.components.friendlevels:GetLevel() / inst.components.friendlevels:GetMaxLevel()
            worldmeteorshower.moonrockshell_chance_additionalodds:SetModifier(inst, odds, "pearl_tasks")
        end
    end)
end
-- END FRIEND LEVELS

local function item_is_oceanfishingrod(item)
    return item.prefab == "oceanfishingrod"
end

local function restocklures(inst)
    local fishingrod = inst.components.inventory:FindItem(item_is_oceanfishingrod)
    if not fishingrod then
        local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        fishingrod = (equipped and equipped.prefab == "oceanfishingrod" and equipped)
    end

    if fishingrod and not fishingrod.components.container:GetItemInSlot(1) then
        fishingrod.components.container:GiveItem(SpawnPrefab("oceanfishingbobber_ball"),1)
    end

    if fishingrod and not fishingrod.components.container:GetItemInSlot(2) then
        local lure_type = (math.random() < 0.5 and "oceanfishinglure_hermit_drowsy")
            or "oceanfishinglure_hermit_heavy"
        fishingrod.components.container:GiveItem(SpawnPrefab(lure_type), 2)
    end
end

local function startfishing(inst)
    local fishingrod = inst.components.inventory:FindItem(item_is_oceanfishingrod)
    if not fishingrod then
        local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        fishingrod = (equipped and equipped.prefab == "oceanfishingrod" and equipped)
    end
    if not fishingrod then
        fishingrod = SpawnPrefab("oceanfishingrod")
        inst.components.inventory:GiveItem(fishingrod)
    end

    if not fishingrod.components.equippable.isequipped then
        inst.components.inventory:Equip(fishingrod)
    end

    if inst.putawayrod then
        inst.putawayrod:Cancel()
        inst.putawayrod = nil
    end
    inst._fishingtimer = function(inst, data)
        if data.name == "fishingtime" then
            inst.sg:GoToState("oceanfishing_stop")
            inst.stopfishing(inst)
        end
    end
    inst:ListenForEvent("timerdone", inst._fishingtimer)

    inst:ListenForEvent("newfishingtarget", function(inst, data)
        if data.target:HasTag("oceanfish") then
            inst.hookfish = true
        end
    end)
end

local function stopfishing(inst)
    inst.hookfish = nil
	if inst._fishingtimer then
		inst:RemoveEventCallback("timerdone", inst._fishingtimer)
		inst._fishingtimer = nil
	end
    if inst.components.timer:TimerExists("fishingtime") then
        inst.components.timer:StopTimer("fishingtime")
    end
    -- remove the fishing rod
    inst.putawayrod = inst:DoTaskInTime(2, function()
        local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item and item.components.oceanfishingrod then
            inst.components.inventory:Unequip(EQUIPSLOTS.HANDS)
        end
    end)
end

local function onplayerdance(inst,player)
    if inst.getgeneralfriendlevel(inst) == "HIGH" and 
            inst:GetDistanceSqToInst(player) < TUNING.HERMITCRAB.DANCE_RANGE * TUNING.HERMITCRAB.DANCE_RANGE then
        inst:PushEvent("dance")
    end
end
local function onmoonvent(inst,doer)
    if math.random() < 0.3 then
        local source = inst.CHEVO_marker
        if source and not inst.comment_data and source:GetDistanceSqToInst(doer) < ISLAND_RADIUS * ISLAND_RADIUS then
            local gfl = inst.getgeneralfriendlevel(inst)

            inst.comment_data = {
                pos = doer:GetPosition(),
                do_chatter = true,
                speech = "HERMITCRAB_MOON_FISSURE_VENT."..gfl,
                chat_priority = CHATPRIORITIES.LOW,
            }
        end
    end
end

local function OnSpringChange(inst)
    -- if task not complete, spawn lure plant at location.
    if not inst.components.friendlevels.friendlytasks[TASKS.REMOVE_LUREPLANT].complete then
        --look for lureplant?
        local source = inst.CHEVO_marker
        if source then
            local source_x, source_y, source_z = source.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(source_x, source_y, source_z, ISLAND_RADIUS, FIND_LUREPLANT_TAGS)
            if #ents <= 0 then
                -- spawnlureplant
                local markerents = TheSim:FindEntities(source_x, source_y, source_z, ISLAND_RADIUS, FIND_HERMITCRAB_LURE_MARKER_TAGS)
                if #markerents > 0 then
                    local marker_x, marker_y, marker_z = markerents[1].Transform:GetWorldPosition()
                    local plant = SpawnPrefab("lureplant")
                    plant.Transform:SetPosition(marker_x, marker_y, marker_z)
                    plant.sg:GoToState("spawn")
                end
            end
        end
    end
end

local function MeetPlayers(inst)
    if TheWorld.components.messagebottlemanager then
        local x, y, z = inst.Transform:GetWorldPosition()

        for i, v in ipairs(FindPlayersInRangeSq(x, y, z, MEET_PLAYERS_RANGE_SQ, true)) do
            TheWorld.components.messagebottlemanager:SetPlayerHasFoundHermit(v)
        end
    end
end

local function StopMeetPlayersTask(inst)
    if inst._meet_players_task then
        inst._meet_players_task:Cancel()
        inst._meet_players_task = nil
    end
end

local function StartMeetPlayersTask(inst)
    StopMeetPlayersTask(inst)
    inst._meet_players_task = inst:DoPeriodicTask(MEET_PLAYERS_FREQUENCY, MeetPlayers)
end

local function retrofitconstuctiontasks(inst, house_prefab)
    if house_prefab == "hermithouse_construction2" then
        inst.components.friendlevels.friendlytasks[TASKS.FIX_HOUSE_1].complete = true
		--print("Retrofitting for Return Of Them: Turn of Tides - completed hermit house 1 friendship task.")
    elseif house_prefab == "hermithouse_construction3" then
        inst.components.friendlevels.friendlytasks[TASKS.FIX_HOUSE_1].complete = true
        inst.components.friendlevels.friendlytasks[TASKS.FIX_HOUSE_2].complete = true
		--print("Retrofitting for Return Of Them: Turn of Tides - completed hermit house 1, 2 friendship tasks.")
    elseif house_prefab == "hermithouse" then
        inst.components.friendlevels.friendlytasks[TASKS.FIX_HOUSE_1].complete = true
        inst.components.friendlevels.friendlytasks[TASKS.FIX_HOUSE_2].complete = true
        inst.components.friendlevels.friendlytasks[TASKS.FIX_HOUSE_3].complete = true
		--print("Retrofitting for Return Of Them: Turn of Tides - completed hermit house 1, 2, 3 friendship tasks.")
    end
end

local function teleport_override_fn(inst)
	local target = (inst.components.homeseeker and inst.components.homeseeker.home)
					or inst.CHEVO_marker
					or inst

    local pt = target:GetPosition()
    local offset = FindWalkableOffset(pt, math.random() * TWOPI, 4, 8, true, false) or
					FindWalkableOffset(pt, math.random() * TWOPI, 8, 8, true, false)
    if offset then
        pt = pt + offset
    end

	return pt
end

local HERMITCRAB_MARKER_TAG = {"hermitcrab_marker"}

local function fn()
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
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("hermitcrab_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")

    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
    inst.AnimState:OverrideSymbol("fx_liquid", "wilson_fx", "fx_liquid")
    inst.AnimState:OverrideSymbol("shadow_hands", "shadow_hands", "shadow_hands")
    inst.AnimState:OverrideSymbol("snap_fx", "player_actions_fishing_ocean_new", "snap_fx")

    --Additional effects symbols for hit_darkness animation

    inst.AnimState:AddOverrideBuild("player_wrap_bundle")
    inst.AnimState:AddOverrideBuild("player_actions_fishing_ocean_new")

    --Sneak these into pristine state for optimization

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")

    inst:AddComponent("talker")
    inst.components.talker.colour = Vector3(252/255, 226/255, 219/255)
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker.name_colour = Vector3(118/256, 89/256, 141/256)
    inst.components.talker.chaticon = "npcchatflair_hermitcrab"
    inst.components.talker:MakeChatter()
    inst.components.talker.lineduration = TUNING.HERMITCRAB.SPEAKTIME - 0.5  -- the subtraction is to create a buffer between text.

    if LOC.GetTextScale() == 1 then
        --Note(Peter): if statement is hack/guess to make the talker not resize for users that are likely to be speaking using the fallback font.
        --Doesn't work for users across multiple languages or if they speak in english despite having a UI set to something else, but it's more likely to be correct, and is safer than modifying the talker
        inst.components.talker.fontsize = 40
    end
    inst.components.talker.font = TALKINGFONT_HERMIT

    inst:AddComponent("npc_talker")
    inst.components.npc_talker.default_chatpriority = CHATPRIORITIES.LOW

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(220)
    end

    inst.displaynamefn = displaynamefn

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_hide = { "ARM_carry", "HAT", "HAIR_HAT", "HEAD_HAT" }
    inst.scrapbook_facing  = FACING_DOWN

    inst.components.talker.ontalk = ontalk

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.HERMITCRAB.RUNSPEED
    inst.components.locomotor.walkspeed = TUNING.HERMITCRAB.WALKSPEED

    inst:AddComponent("bloomer")

    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetCanEatRaw()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!

    ------------------------------------------
    inst:AddComponent("named")

    ------------------------------------------
    MakeHauntablePanic(inst)

    -----------------------StopActionMeter-------------------

    inst:AddComponent("inventory")

    ------------------------------------------

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("friendlevels")
    inst.components.friendlevels:SetDefaultRewards(defaultfriendrewards)
    inst.components.friendlevels:SetLevelRewards(friendlevelrewards)
    inst.components.friendlevels:SetFriendlyTasks(friendlytasks)
    initfriendlevellisteners(inst)
    inst.complain = complain
    inst.rewardcheck = rewardcheck
    inst.getgeneralfriendlevel = getgeneralfriendlevel
    inst.storelevelunlocked = storelevelunlocked

    inst:ListenForEvent("friend_task_complete", onTaskComplete)

    ------------------------------------------

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false

    ------------------------------------------

	inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)

    ------------------------------------------

    inst:AddComponent("entitytracker")

    ------------------------------------------

    inst:AddComponent("timer")

    ------------------------------------------
    MakeMediumFreezableCharacter(inst, "torso")

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    ------------------------------------------

    inst:AddComponent("craftingstation")

    ------------------------------------------

    inst:SetStateGraph("SGhermitcrab")

    ------------------------------------------

    inst:SetBrain(normalbrain)

    inst.startfishing = startfishing
    inst.stopfishing = stopfishing
    inst.restocklures = restocklures
    inst.island_radius = ISLAND_RADIUS
    inst.dotalkingtimers = dotalkingtimers
    inst.iscoat = iscoat
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    inst:WatchWorldState("isspring", OnSpringChange)

    inst:ListenForEvent("enterlimbo",  function()
        inst.components.timer:StopTimer("complain_time")
    end)
    inst:ListenForEvent("exitlimbo",  function()
        if inst.entity:IsAwake() then
            inst.components.timer:StartTimer("complain_time",10 + (math.random()*30))
            inst.components.npc_talker:resetqueue()
        end
    end)

    inst:ListenForEvent("onsatinchair", function(inst)
        inst.components.friendlevels:CompleteTask(TASKS.MAKE_CHAIR)
    end)

    inst.OnEntitySleep = function(inst)
        inst.components.timer:StopTimer("complain_time")

        StopMeetPlayersTask(inst)
    end
    inst.OnEntityWake = function(inst)
        if not inst:HasTag("INLIMBO") then
            inst.components.timer:StartTimer("complain_time",10 + (math.random()*30))
            inst.components.npc_talker:resetqueue()
        end

        StartMeetPlayersTask(inst)
    end

    inst:ListenForEvent("dancingplayer",  function(world,data) onplayerdance(inst,data) end, TheWorld)
    inst:ListenForEvent("moonfissurevent",  function(world,data) onmoonvent(inst,data) end, TheWorld)
    inst:DoTaskInTime(0,function()
        inst.CHEVO_marker = FindEntity(inst, ISLAND_RADIUS, nil, HERMITCRAB_MARKER_TAG)
        if inst.CHEVO_marker then
            inst:ListenForEvent("onremove",  function() inst.CHEVO_marker = nil end, inst.CHEVO_marker)
        end
    end)

    inst:ListenForEvent("clocksegschanged", function(world, data)
        inst.segs = data
    end, TheWorld)

	RegisterToBottleManager(inst)

	inst.retrofitconstuctiontasks = retrofitconstuctiontasks

    return inst
end

local function markerfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst:AddTag("hermitcrab_marker")

    return inst
end

local function markerfishingfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst:AddTag("hermitcrab_marker_fishing")

    return inst
end

local function luremarkerfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst:AddTag("hermitcrab_lure_marker")

    return inst
end

return Prefab("hermitcrab", fn, assets, prefabs),
       Prefab("hermitcrab_marker", markerfn, {}, {}),
       Prefab("hermitcrab_lure_marker", luremarkerfn, {}, {}),
       Prefab("hermitcrab_marker_fishing", markerfishingfn, {}, {})