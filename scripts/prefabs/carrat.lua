--------------------------------------------------------------------
-- Assets                                                         --
--------------------------------------------------------------------
local assets =
{
    Asset("ANIM", "anim/carrat_basic.zip"),
    Asset("ANIM", "anim/carrat_yotc.zip"),
    Asset("ANIM", "anim/carrat_build.zip"),
	Asset("ANIM", "anim/yotc_carrat_colour_swaps.zip"),
    Asset("ANIM", "anim/carrat_exhausted_yotc.zip"),
    Asset("ANIM", "anim/carrat_traits_yotc.zip"),
    Asset("ANIM", "anim/redpouch_yotc.zip"),
    Asset("INV_IMAGE", "carrat"),
}

local planted_assets =
{
    Asset("ANIM", "anim/carrat_basic.zip"),
    Asset("ANIM", "anim/carrat_build.zip"),
	Asset("ANIM", "anim/yotc_carrat_colour_swaps.zip"),
}

local prefabs =
{
    "carrat_planted",
    "carrot_seeds",
    "plantmeat",
    "plantmeat_cooked",
    "redpouch_yotc",
}

local planted_prefabs =
{
    "carrat",
}

local carratsounds =
{
    idle = "turnoftides/creatures/together/carrat/idle",
    hit = "turnoftides/creatures/together/carrat/hit",
    sleep = "turnoftides/creatures/together/carrat/sleep",
    death = "turnoftides/creatures/together/carrat/death",
    emerge = "turnoftides/creatures/together/carrat/emerge",
    submerge = "turnoftides/creatures/together/carrat/submerge",
    eat = "turnoftides/creatures/together/carrat/eat",
    stunned = "turnoftides/creatures/together/carrat/stunned",
	reaction = "turnoftides/creatures/together/carrat/reaction",

	step = "dontstarve/creatures/mandrake/footstep",
}

SetSharedLootTable("carrat",
{
    {"plantmeat",       1.00},
    {"carrot_seeds",    0.33},
})

local brain = require("brains/carratbrain")

--------------------------------------------------------------------
-- Common functions                                               --
--------------------------------------------------------------------

local available_colors = -- Used to get a random color on eating unknown veggie seeds
{
	-- "black", -- Black color swap exists but is never used as the color is reserved for shadow racers
	"blue",
	"brown",
	"green",
	"pink",
	"purple",
	"white",
	"yellow",

	"NEUTRAL",
}

for _,v in ipairs(available_colors) do
	if v ~= "NEUTRAL" then
		table.insert(assets, Asset("INV_IMAGE", "carrat_"..v))
	end
end

local function common_setcolor(inst, color)
	color = color == "RANDOM" and available_colors[math.random(#available_colors)] or color
	color = color ~= "NEUTRAL" and color or nil

	if inst.prefab == "carrat_planted" then
		if color == nil then
			inst.AnimState:ClearOverrideSymbol("carrot_parts")
		else
			inst.AnimState:OverrideSymbol("carrot_parts", "yotc_carrat_colour_swaps", color.."_carrot_parts")
		end
	else
		if color == nil then
			inst.AnimState:ClearOverrideSymbol("carrat_tail")
			inst.AnimState:ClearOverrideSymbol("carrat_ear")
			inst.AnimState:ClearOverrideSymbol("carrot_parts")
		else
			inst.AnimState:OverrideSymbol("carrat_tail", "yotc_carrat_colour_swaps", color.."_carrat_tail")
			inst.AnimState:OverrideSymbol("carrat_ear", "yotc_carrat_colour_swaps", color.."_carrat_ear")
			inst.AnimState:OverrideSymbol("carrot_parts", "yotc_carrat_colour_swaps", color.."_carrot_parts")
		end
	end

	if inst.components.inventoryitem ~= nil then
		inst.components.inventoryitem:ChangeImageName(color ~= nil and ("carrat_"..color) or "carrat")
	end

	inst._color = color
end

local function common_onsave(inst, data)
	if inst._color ~= nil then
		data.color = inst._color
	end
    if inst.beefalo_carrat then
        data.beefalo_carrat = true
    end
    data.is_burrowed = inst._is_burrowed
    data.has_trained = inst._trained_today
end

local function common_onload(inst, data)
    if data ~= nil then
        if data.color ~= nil then
            common_setcolor(inst, data.color)
        end
        if data.is_burrowed then
            inst.sg:GoToState("submerged")
        end
		if IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
            inst.beefalo_carrat = data.beefalo_carrat
            inst._trained_today = data.has_trained
        end
    end

    if inst._spread_stats_task then
        inst._spread_stats_task:Cancel()
        inst._spread_stats_task = nil
    end

    if inst.components.named ~= nil and inst.components.named.name ~= nil then
        inst.components.named:SetName(nil)
    end
end

local function OnMusicStateDirty(inst)
    if inst._musicstate:value() > 0 then
        if inst._musicstate:value() == CARRAT_MUSIC_STATES.RACE then
            if ThePlayer:GetDistanceSqToInst(inst) < 20*20 then
                ThePlayer:PushEvent("playracemusic")
            end
        end
    end
end

local function docarratfailtalk(inst,stat)

    if inst.components.entitytracker:GetEntity("yotc_trainer") then
        local player = inst.components.entitytracker:GetEntity("yotc_trainer")
        if inst:GetDistanceSqToInst(player) < 20*20 then
            if stat == "direction" then
                inst:DoTaskInTime(2,function() player.components.talker:Say(GetString(player, "ANNOUNCE_CARRAT_ERROR_WRONG_WAY")) end)
            elseif stat == "reaction" then
                inst:DoTaskInTime(2,function() player.components.talker:Say(GetString(player, "ANNOUNCE_CARRAT_ERROR_STUNNED")) end)
            elseif stat == "speed" then
                inst:DoTaskInTime(4,function() player.components.talker:Say(GetString(player, "ANNOUNCE_CARRAT_ERROR_WALKING")) end)
            elseif stat == "stamina" then
                inst:DoTaskInTime(2,function() player.components.talker:Say(GetString(player, "ANNOUNCE_CARRAT_ERROR_FELL_ASLEEP")) end)
            end
        end
    end
end

--------------------------------------------------------------------
-- Submerged state                                                --
--------------------------------------------------------------------

local function on_submerged_ignite(inst)
    inst:GoToEmerged()
    inst.sg:GoToState("emerge_fast")
end

local function on_submerged_picked(inst)
    inst:GoToEmerged()
    inst.sg:GoToState("emerge_fast")
end

local function on_submerged_dug_up(inst, digger)
    inst:GoToEmerged()
    inst.sg:GoToState("dug_up")
end

local function on_submerged_haunt_fn(inst, haunter)
    return true
end

local function play_special_submerged_idle(inst)
    inst.AnimState:PlayAnimation("planted_ruffle")
    inst.AnimState:PushAnimation("planted")
end

local function go_to_submerged(inst)
    -- Remove tags & components --
    inst:RemoveTag("animal")
    inst:RemoveTag("canbetrapped")
    inst:RemoveTag("catfood")
    inst:RemoveTag("cattoy")
    inst:RemoveTag("prey")
    inst:RemoveTag("smallcreature")

	if inst.components.yotc_racecompetitor ~= nil then
        local prize = inst.components.yotc_racecompetitor:CollectPrize()
        if prize ~= nil then
            if inst.components.lootdropper ~= nil then
                inst.components.lootdropper:FlingItem(prize, inst:GetPosition())
            else
                prize.Transform:SetPosition(inst.Transform:GetWorldPosition())
			end
		end
        inst:RemoveComponent("yotc_racecompetitor")
	end

    inst:RemoveComponent("locomotor")
    inst:RemoveComponent("cookable")
    inst:RemoveComponent("lootdropper")
    inst:RemoveComponent("combat")
    inst:RemoveComponent("sleeper")
    inst:RemoveComponent("tradable")
    inst:RemoveComponent("freezable")

	inst.components.inventoryitem.canbepickedup = false

    -- Update shared components --
    inst.components.burnable.canlight = true
    inst.components.burnable:SetOnIgniteFn(on_submerged_ignite)
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)
    inst.components.burnable:SetOnBurntFn(DefaultBurntFn)

    inst.components.propagator.acceptsheat = true

    inst.components.hauntable.cooldown = nil
    inst.components.hauntable:SetOnHauntFn(on_submerged_haunt_fn)
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    -- Add burrowed-only components --
    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    inst.components.pickable.onpickedfn = on_submerged_picked
    inst.components.pickable.canbepicked = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(on_submerged_dug_up)
    inst.components.workable:SetWorkLeft(1)

    -- Non-component setup --
    inst:SetPrefabNameOverride("CARROT_PLANTED")
    inst.AnimState:SetRayTestOnBB(true)

    inst._planted_ruffle_task = inst:DoPeriodicTask(
        TUNING.CARRAT.PLANTED_RUFFLE_TIME,
        play_special_submerged_idle,
        math.random(TUNING.CARRAT.PLANTED_RUFFLE_TIME)
    )

    inst:SetBrain(nil)
    inst:StopBrain()

    -- Track if we're burrowed for save/load
    inst._is_burrowed = true
end

local function on_cooked_fn(inst, cooker, chef)
    inst.SoundEmitter:PlaySound(inst.sounds.hit)
end

local function yotc_on_inventory(inst, owner)
    if owner.components.inventoryitem then
        owner = owner.components.inventoryitem:GetGrandOwner()
    end

    if owner ~= nil and owner:HasTag("player") then
        inst.components.entitytracker:TrackEntity("yotc_trainer", owner)
    end

    if inst.components.yotc_racecompetitor ~= nil then
        if owner ~= nil and owner.components.inventory ~= nil then
            local prize = inst.components.yotc_racecompetitor:CollectPrize()
            if prize ~= nil then
                if not owner.components.inventory:IsFull() then
                    owner.components.inventory:GiveItem(prize, nil, inst:GetPosition())
                elseif inst.components.lootdropper ~= nil then
                    inst.components.lootdropper:FlingItem(prize, inst:GetPosition())
                else
                    prize.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
            end
        end

        inst:RemoveComponent("yotc_racecompetitor")
    end

    inst:RemoveTag("noauradamage")

    inst.components.named:SetName(nil)
    inst.beefalo_carrat = nil

    inst.components.inventoryitem.canbepickedup = false
end

local YOTC_RACESTART_MUSTHAVETAGS = {"yotc_racestart"}
local YOTC_RACESTART_CANTHAVETAGS = {"fire", "burnt", "INLIMBO", "race_on"}
local function find_yotc_race_startentity(inst)
    local platform = inst:GetCurrentPlatform()
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local start_points = TheSim:FindEntities(ix, iy, iz, TUNING.YOTC_ADDTORACE_DIST, YOTC_RACESTART_MUSTHAVETAGS, YOTC_RACESTART_CANTHAVETAGS)
    for _, v in ipairs(start_points) do
		if platform == v:GetCurrentPlatform() then
			return v
		end
    end

    return nil
end

local function race_begun(inst)
	if inst.components.yotc_racecompetitor ~= nil and inst.components.yotc_racestats ~= nil then
        inst:RemoveTag("has_no_prize")
        inst.components.inventoryitem.canbepickedup = false

		-- remove character collision so players don't physics push their carrats to the finishline
		inst.Physics:SetCollisionMask(COLLISION.WORLD, COLLISION.OBSTACLES, COLLISION.SMALLOBSTACLES, COLLISION.GIANTS)

		inst.components.yotc_racecompetitor.isforgetful = inst.components.yotc_racestats:GetDirectionModifier() == 0
		inst.components.yotc_racecompetitor.stamina_max = Lerp(TUNING.YOTC_RACER_STAMINA_BAD, TUNING.YOTC_RACER_STAMINA_GOOD, inst.components.yotc_racestats:GetStaminaModifier())
		inst.components.yotc_racecompetitor.exhausted_time = TUNING.YOTC_RACER_STAMINA_EXHAUSTED_TIME
		inst.components.yotc_racecompetitor.exhausted_time_var = TUNING.YOTC_RACER_STAMINA_EXHAUSTED_TIME_VAR
		inst.components.yotc_racecompetitor:RecoverStamina()

		if inst.components.locomotor ~= nil then
			inst.components.locomotor.runspeed = Lerp(TUNING.YOTC_RACER_SPEED_BAD, TUNING.YOTC_RACER_SPEED_GOOD, inst.components.yotc_racestats:GetSpeedModifier()) + math.random() * TUNING.YOTC_RACER_SPEED_VAR
		end

		if inst.components.health == nil or not inst.components.health:IsDead() then
			if inst.components.sleeper ~= nil then
				inst.components.sleeper:WakeUp()
			end

			local reaction_stat = inst.components.yotc_racestats ~= nil and inst.components.yotc_racestats:GetReactionModifier() or 0
			if reaction_stat == 0 then
                docarratfailtalk(inst,"reaction")
				inst.sg:GoToState("race_start_stunned", math.random(TUNING.YOTC_RACER_REACTION_START_STUN_LOOPS_MIN, TUNING.YOTC_RACER_REACTION_START_STUN_LOOPS_MAX))
			else
				local start_delay = Lerp(TUNING.YOTC_RACER_REACTION_START_BAD, TUNING.YOTC_RACER_REACTION_START_GOOD, reaction_stat) + math.random() * Lerp(TUNING.YOTC_RACER_REACTION_START_BAD_VAR, TUNING.YOTC_RACER_REACTION_START_GOOD_VAR, reaction_stat)
				if start_delay > 0 then
					inst.components.yotc_racecompetitor:SetLateStarter(start_delay)
					inst.sg:GoToState("race_start_startle")
				end

			end
		end
	end
end

local function reached_finish_line(inst)
    if inst.components.locomotor ~= nil then
        inst.components.locomotor.runspeed = TUNING.CARRAT.RUN_SPEED
    end

	ChangeToCharacterPhysics(inst)
end

local function full_race_over(inst)
    local racestate = (inst.components.yotc_racecompetitor and inst.components.yotc_racecompetitor.racestate) or nil
    if racestate == "postrace" or racestate == "prerace" or racestate == "raceover" then
        inst.components.inventoryitem.canbepickedup = true
    end
end

local function on_dropped(inst)
    if not IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
        inst.sg:GoToState("stunned")
        return
    end

    local nearby_race_startentity = find_yotc_race_startentity(inst)
    if nearby_race_startentity ~= nil then
		local added_to_race = false
        if TheWorld.components.yotc_raceprizemanager ~= nil then
            local old_racer
			added_to_race, old_racer = TheWorld.components.yotc_raceprizemanager:RegisterRacer(inst, nearby_race_startentity)
            if old_racer ~= nil then
                if old_racer.components.yotc_racecompetitor ~= nil then
                    old_racer.components.yotc_racecompetitor:AbortRace()
                end
            end
        end

		if added_to_race then
			-- Might be dropped on pickup if the player's inventory is full. If it's not added to the inventory,
			-- it will keep its racecompetitor component.
			if inst.components.yotc_racecompetitor == nil then
				inst:AddComponent("yotc_racecompetitor")
				inst.components.yotc_racecompetitor:SetRaceBegunFn(race_begun)
				inst.components.yotc_racecompetitor:SetRaceFinishedFn(reached_finish_line)
				inst.components.yotc_racecompetitor:SetRaceOverFn(full_race_over)
				inst.components.yotc_racecompetitor.stamina_max_var = TUNING.YOTC_RACER_STAMINA_VAR

				-- Even if we were dropped closer to a new start point, if we had our old competitor component,
				-- we probably want to stay attached to our old start point instead of re-assigning it.
				inst.components.yotc_racecompetitor:SetRaceStartPoint(nearby_race_startentity)
			end

			local trainer = (inst.components.entitytracker and inst.components.entitytracker:GetEntity("yotc_trainer")) or nil
			if trainer then
				local new_name = subfmt(STRINGS.NAMES.YOTC_OWNED_CARRAT, { trainer = trainer.name })
				inst.components.named:SetName(new_name)
			end

			inst.sg:GoToState("idle")

			-- Racing rats should not be targeted by Abigail
			inst:AddTag("noauradamage")

			-- NOTE: It's important that these are set after the GoToState, because we may be leaving the stunned state
			inst:AddTag("has_no_prize")
			inst.components.inventoryitem.canbepickedup = true
		end
    elseif inst:HasTag("has_no_prize") or inst:HasTag("has_prize") then
        -- Racing rats should not be targeted by Abigail
        inst:AddTag("noauradamage")

        inst.sg:GoToState("idle")

        -- NOTE: It's important that this is set after the GoToState, because we may be leaving the stunned state
        inst.components.inventoryitem.canbepickedup = (inst:HasTag("has_no_prize") or inst:HasTag("has_prize"))
    else
        inst.components.entitytracker:ForgetEntity("yotc_trainer")
        inst.sg:GoToState("stunned")
    end
end

local function go_to_emerged(inst)
    -- Add tags --
    inst:AddTag("animal")
    inst:AddTag("canbetrapped")
    inst:AddTag("catfood")
    inst:AddTag("cattoy")
    inst:AddTag("prey")
    inst:AddTag("smallcreature")
    inst:AddTag("stunnedbybomb")

    -- Remove unused components --
    inst:RemoveComponent("pickable")
    inst:RemoveComponent("workable")

    -- Update shared components --
    inst.components.burnable.canlight = false
    inst.components.burnable:SetOnIgniteFn(nil)
    inst.components.burnable:SetOnExtinguishFn(nil)
    inst.components.burnable:SetOnBurntFn(nil)

    inst.components.propagator.acceptsheat = false

    MakeHauntablePanic(inst)

    inst.components.perishable:SetPercent(1)

    -- Add components --
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.CARRAT.WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.CARRAT.RUN_SPEED

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("carrat")

    inst:AddComponent("cookable")
    inst.components.cookable.product = "plantmeat_cooked"
    inst.components.cookable:SetOnCookedFn(on_cooked_fn)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "carrat_body"

    inst:AddComponent("sleeper")
    inst:AddComponent("tradable")

    MakeTinyFreezableCharacter(inst, "carrat_body")

    -- Non-component setup --
    inst.AnimState:SetRayTestOnBB(false)
    inst:SetPrefabNameOverride(nil)

    if inst._planted_ruffle_task ~= nil then
        inst._planted_ruffle_task:Cancel()
        inst._planted_ruffle_task = nil
    end

    inst:SetBrain(brain)
    inst:RestartBrain()

    -- Track if we're burrowed for save/load
    inst._is_burrowed = false
end

local function client_get_drop_action_string(inst, drop_pst)
    if drop_pst == nil then
        return nil
    end

    local dx, dy, dz = drop_pst:Get()
    local drop_platform = TheWorld.Map:GetPlatformAtPoint(dx, dy, dz)
    local start_points = TheSim:FindEntities(dx, dy, dz, TUNING.YOTC_ADDTORACE_DIST, YOTC_RACESTART_MUSTHAVETAGS, YOTC_RACESTART_CANTHAVETAGS)
    for _, v in ipairs(start_points) do
		if not TheWorld.Map:IsOceanAtPoint(dx, dy, dz) and drop_platform == v:GetCurrentPlatform() then
			return "YOTC_ENTERRACE"
		end
    end

    return nil
end

local function spread_stats(inst)
    if inst.components.yotc_racestats then
        local points = TUNING.RACE_STATS.BAD_STAT_SPREAD
        if inst.beefalo_carrat then
            points = TUNING.RACE_STATS.WILD_STAT_SPREAD
        end
        inst.components.yotc_racestats:AddRandomPointSpread(points)
        inst.components.yotc_racestats:SaveCurrentStatsAsBaseline()
    end
end

local POINTS_PER_TRAIN = 1
local function _dospeedgym(inst)
    inst.components.yotc_racestats:ModifySpeed(POINTS_PER_TRAIN)

    inst._trained_today = true
end

local function _dodirectiongym(inst)
    inst.components.yotc_racestats:ModifyDirection(POINTS_PER_TRAIN)

    inst._trained_today = true
end

local function _doreactiongym(inst)
    inst.components.yotc_racestats:ModifyReaction(POINTS_PER_TRAIN)

    inst._trained_today = true
end

local function _dostaminagym(inst)
    inst.components.yotc_racestats:ModifyStamina(POINTS_PER_TRAIN)

    inst._trained_today = true
end

local function yotc_drop_prize_on_death(inst, data)
    if inst.components.yotc_racecompetitor ~= nil and inst:HasTag("has_prize") then
        local prize = inst.components.yotc_racecompetitor:CollectPrize()
        if prize ~= nil then
            if inst.components.lootdropper ~= nil then
                inst.components.lootdropper:FlingItem(prize, inst:GetPosition())
            else
                prize.Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
        end
    end
end

local function yotc_nighttime_degrade_test(inst, isnight)
    if isnight then
        -- Racing and post-race are considered part of active racing (because you might get locked from feeding your rat in postrace)
        local is_not_actively_racing = inst.components.yotc_racecompetitor == nil or inst.components.yotc_racecompetitor.racestate == "prerace"
        if is_not_actively_racing and not inst._trained_today then
            if inst.components.yotc_racestats ~= nil then
                local degrade_amount = math.random(POINTS_PER_TRAIN * (TUNING.CARRAT_GYM.TRAINS_PER_DAY - 1))
                inst.components.yotc_racestats:DegradePoints(degrade_amount)
                if inst.gymscale then
                    inst.gymscale.updateratstats(inst.gymscale)
                end
            end
        else
            inst._trained_today = false
        end
    end
end

local function settrapdata(inst)
    local lootdata = {}
    lootdata.colour = inst._color
    local stats = inst.components.yotc_racestats
    if stats then
        lootdata.stats = {speed = stats.speed,stamina = stats.stamina,direction = stats.direction,reaction = stats.reaction}
    end
    return lootdata
end

local function getcarratfromtrap(inst,data)
    if data.colour then
        inst._setcolorfn(inst, data.colour)
    end
    if data.stats then
        if inst.components.yotc_racestats then
            if inst._spread_stats_task then
                inst._spread_stats_task:Cancel()
                inst._spread_stats_task = nil
            end
            inst.components.yotc_racestats.speed = data.stats.speed
            inst.components.yotc_racestats.direction = data.stats.direction
            inst.components.yotc_racestats.reaction = data.stats.reaction
            inst.components.yotc_racestats.stamina = data.stats.stamina
        end
    end
end

local food_colors =
{
    watermelon_seeds = "blue",

    onion_seeds = "brown",
    potato_seeds = "brown",

	asparagus_seeds = "green",
    durian_seeds = "green",

	dragonfruit_seeds = "pink",
	pomegranate_seeds = "pink",
	tomato_seeds = "pink",
	pepper_seeds = "pink",

    eggplant_seeds = "purple",

	garlic_seeds = "white",

	corn_seeds = "yellow",
	pumpkin_seeds = "yellow",

	carrot_seeds = "NEUTRAL",
	seeds = "RANDOM",
}

local function GetColorFromFood(inst, data)
	local food_prefab = data ~= nil and data.food ~= nil and data.food.prefab or nil
	return food_prefab ~= nil and food_colors[food_prefab] or nil
end

local function yotc_oneatfn(inst, data)
	local color = GetColorFromFood(inst, data)
	if color ~= nil then
		common_setcolor(inst, color)
	end
end

local function setbeefalocarratrat(inst)
    inst.beefalo_carrat = true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.DynamicShadow:SetSize(1, .75)
    inst.DynamicShadow:Enable(false)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("carrat")
    inst.AnimState:SetBuild("carrat_build")
    inst.AnimState:PlayAnimation("planted")

    inst:AddTag("animal")
    inst:AddTag("canbetrapped")
    inst:AddTag("catfood")
    inst:AddTag("cattoy")
    inst:AddTag("prey")
    inst:AddTag("smallcreature")
    inst:AddTag("stunnedbybomb")
    inst:AddTag("lunar_aligned")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    if IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
        -- _named (from named component) for pristine state optimization
        inst:AddTag("_named")
        inst.AnimState:AddOverrideBuild("redpouch_yotc")

        inst.GetDropActionString = client_get_drop_action_string
    end

    MakeFeedableSmallLivestockPristine(inst)

    inst._musicstate = net_tinybyte(inst.GUID, "carrat.musicstate", "musicstatedirty")
    inst._musicstate:set(CARRAT_MUSIC_STATES.NONE)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("musicstatedirty", OnMusicStateDirty)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = carratsounds -- sounds must be assigned before the stategraph

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem:SetSinks(true)

	inst._setcolorfn = common_setcolor
    local yotc_carrat = IsSpecialEventActive(SPECIAL_EVENTS.YOTC)
    if yotc_carrat then
		--inst._color = nil

        inst.dospeedgym = _dospeedgym
        inst.dodirectiongym = _dodirectiongym
        inst.doreactiongym = _doreactiongym
        inst.dostaminagym = _dostaminagym

        --Remove these tags so that they can be added properly when replicating components below
        inst:RemoveTag("_named")
        inst:AddComponent("named")

        inst:AddComponent("yotc_racestats")
        inst._spread_stats_task = inst:DoTaskInTime(0, spread_stats)

        inst:AddComponent("entitytracker")

        inst._trained_today = false

        inst:ListenForEvent("death", yotc_drop_prize_on_death)
		inst:ListenForEvent("oneat", yotc_oneatfn)
        inst:ListenForEvent("carrat_error_direction", function() docarratfailtalk(inst,"direction") end)
        inst:ListenForEvent("carrat_error_walking", function() docarratfailtalk(inst,"speed") end)
        inst:ListenForEvent("carrat_error_sleeping", function() docarratfailtalk(inst,"stamina") end)
        inst:WatchWorldState("isnight", yotc_nighttime_degrade_test)
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.CARRAT.WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.CARRAT.RUN_SPEED

    inst:SetStateGraph("SGcarrat")
    inst:SetBrain(brain)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
    inst.components.eater:SetStrongStomach(true)

    inst:AddComponent("cookable")
    inst.components.cookable.product = "plantmeat_cooked"
    inst.components.cookable:SetOnCookedFn(on_cooked_fn)

    inst:AddComponent("homeseeker")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CARRAT.HEALTH)
    inst.components.health.murdersound = inst.sounds.death

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("carrat")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "carrat_body"

    -- Mostly copying MakeSmallBurnableCharacter, EXCEPT for the symbol following,
    -- because it looks bad paired with the burning of the planted prefab.
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable.canlight = false
    inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0))

    MakeSmallPropagator(inst)
    inst.components.propagator.acceptsheat = false

    MakeTinyFreezableCharacter(inst, "carrat_body")

    inst:AddComponent("inspectable")
    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst:AddComponent("tradable")

    MakeHauntablePanic(inst)

    local _on_added_to_inventory = (yotc_carrat and yotc_on_inventory) or nil
    MakeFeedableSmallLivestock(inst, TUNING.CARRAT.PERISH_TIME, _on_added_to_inventory, on_dropped)

    inst.GoToSubmerged = go_to_submerged
    inst.GoToEmerged = go_to_emerged
    inst.setbeefalocarratrat = setbeefalocarratrat
    --inst.getcarratfromtrap = getcarratfromtrap --deprecated
	inst.restoredatafromtrap = getcarratfromtrap
    inst.settrapdata = settrapdata

	inst.OnSave = common_onsave
	inst.OnLoad = common_onload

    return inst
end

--------------------------------------------------------------------
-- Separate planted prefab for world gen                          --
--------------------------------------------------------------------

local function spawn_carrat_from_planted()
    local carrat = SpawnPrefab("carrat")
    if IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
        if carrat._spread_stats_task then
            carrat._spread_stats_task:Cancel()
            carrat._spread_stats_task = nil
        end

        if carrat.components.yotc_racestats then
            carrat.components.yotc_racestats.speed = 1
            carrat.components.yotc_racestats.direction = 1
            carrat.components.yotc_racestats.reaction = 1
            carrat.components.yotc_racestats.stamina = 1

            if TUNING.RACE_STATS.WILD_STAT_SPREAD > 4 then
                carrat.components.yotc_racestats:AddRandomPointSpread(TUNING.RACE_STATS.WILD_STAT_SPREAD - 4)
            end

            carrat.components.yotc_racestats:SaveCurrentStatsAsBaseline()
        end
    end
    return carrat
end

local function on_planted_prefab_picked(inst)
    local carrat = spawn_carrat_from_planted()
    carrat.Transform:SetPosition(inst.Transform:GetWorldPosition())

	if inst._color ~= nil then
		carrat._setcolorfn(carrat, inst._color)
	end
end

local function on_planted_prefab_ignite(inst, source, doer)
    local carrat = spawn_carrat_from_planted()
    carrat.Transform:SetPosition(inst.Transform:GetWorldPosition())
    carrat.components.burnable:Ignite(nil, source, doer)

	if inst._color ~= nil then
		carrat._setcolorfn(carrat, inst._color)
	end

    -- Not sure why, but this needs to be delayed a frame or else the propagator will
    -- continue to try to update. Probably because it'd be stopped and started in the same frame otherwise.
    inst:DoTaskInTime(0, function(ignited_inst) ignited_inst:Remove() end)
end

local function on_planted_prefab_dug_up(inst, digger)
    local carrat = spawn_carrat_from_planted()
    carrat.Transform:SetPosition(inst.Transform:GetWorldPosition())
    carrat.sg:GoToState("dug_up")

	if inst._color ~= nil then
		carrat._setcolorfn(carrat, inst._color)
	end

    inst:Remove()
end

local function planted_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("carrat")
    inst.AnimState:SetBuild("carrat_build")
    inst.AnimState:PlayAnimation("planted")
    inst.AnimState:SetRayTestOnBB(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst._setcolorfn = common_setcolor
	--inst._color = nil -- Carried over to planted carrat in SGcarrat 'submerged' state

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "CARROT_PLANTED"

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    inst.components.pickable.onpickedfn = on_planted_prefab_picked
	inst.components.pickable.remove_when_picked = true
    inst.components.pickable.canbepicked = true

    MakeSmallBurnable(inst)
    inst.components.burnable:SetOnIgniteFn(on_planted_prefab_ignite)
    inst.components.burnable:SetOnBurntFn(nil)

    MakeSmallPropagator(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(on_planted_prefab_dug_up)
    inst.components.workable:SetWorkLeft(1)

    inst:DoPeriodicTask(
        TUNING.CARRAT.PLANTED_RUFFLE_TIME,
        play_special_submerged_idle,
        math.random(TUNING.CARRAT.PLANTED_RUFFLE_TIME)
    )

	inst.OnSave = common_onsave
	inst.OnLoad = common_onload

    return inst
end

return Prefab("carrat", fn, assets, prefabs),
        Prefab("carrat_planted", planted_fn, planted_assets, planted_prefabs)
