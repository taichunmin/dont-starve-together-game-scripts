require "class"
require "bufferedaction"
require "debugtools"
require 'util'
require 'vecutil'
require ("components/embarker")

local function DefaultRangeCheck(doer, target)
    if target == nil then
        return
    end
    local target_x, target_y, target_z = target.Transform:GetWorldPosition()
    local doer_x, doer_y, doer_z = doer.Transform:GetWorldPosition()
    local dst = distsq(target_x, target_z, doer_x, doer_z)
    return dst <= 16
end

local function CheckFishingOceanRange(doer, dest)
	local doer_pos = doer:GetPosition()
	local target_pos = Vector3(dest:GetPoint())
	local dir = target_pos - doer_pos

	local test_pt = doer_pos + dir:GetNormalized() * (doer:GetPhysicsRadius(0) + 0.25)

    if TheWorld.Map:IsVisualGroundAtPoint(test_pt.x, 0, test_pt.z) or TheWorld.Map:GetPlatformAtPoint(test_pt.x, test_pt.z) ~= nil then
		return false
	else
        return true
	end
end
local function CheckRowRange(doer, dest)
	local doer_pos = doer:GetPosition()
	local target_pos = Vector3(dest:GetPoint())
	local dir = target_pos - doer_pos

	local test_pt = doer_pos + dir:GetNormalized() * (doer:GetPhysicsRadius(0) + 0.25)

    if TheWorld.Map:GetPlatformAtPoint(test_pt.x, test_pt.z) ~= nil then
		return false
	else
        return true
	end
end

local function CheckIsOnPlatform(doer, dest)
    return doer:GetCurrentPlatform() ~= nil
end

local function CheckOceanFishingCastRange(doer, dest)
	local doer_pos = doer:GetPosition()
	local target_pos = Vector3(dest:GetPoint())
	local dir = target_pos - doer_pos

	local test_pt = doer_pos + dir:GetNormalized() * (doer:GetPhysicsRadius(0) + 0.25)

    if TheWorld.Map:IsVisualGroundAtPoint(test_pt.x, 0, test_pt.z) or TheWorld.Map:GetPlatformAtPoint(test_pt.x, test_pt.z) ~= nil then
		return false
	else
        return true
	end
end

local function CheckTileWithinRange(doer, dest)
	local doer_pos = doer:GetPosition()
	local target_pos = Vector3(dest:GetPoint())

    local tile_x, tile_y, tile_z = TheWorld.Map:GetTileCenterPoint(target_pos.x, 0, target_pos.z)
    local dist = TILE_SCALE * 0.5
    if math.abs(tile_x - doer_pos.x) <= dist and math.abs(tile_z - doer_pos.z) <= dist then
        return true
    end
end

local function ShowPourWaterTilePlacer(right_mouse_action)
    if right_mouse_action ~= nil then

        if right_mouse_action.target ~= nil and right_mouse_action.target:HasTag("farm_plant") then
            local x, y, z = right_mouse_action.target.Transform:GetWorldPosition()
            return TheWorld.Map:IsFarmableSoilAtPoint(x, y, z)
        else
            -- If there is no target while hovering farm turf the POUR_WATER_GROUNDTILE point action will have taken priority anyway
            return false
        end
    end
end

local function ExtraPickupRange(doer, dest)
	if dest ~= nil then
		local target_x, target_y, target_z = dest:GetPoint()

		local is_on_water = TheWorld.Map:IsOceanTileAtPoint(target_x, 0, target_z) and not TheWorld.Map:IsPassableAtPoint(target_x, 0, target_z)
		if is_on_water then
			return 0.75
		end
	end
    return 0
end

local function ExtraDeployDist(doer, dest, bufferedaction)
	if dest ~= nil then
		local target_x, target_y, target_z = dest:GetPoint()

		local is_on_water = TheWorld.Map:IsOceanTileAtPoint(target_x, 0, target_z) and not TheWorld.Map:IsPassableAtPoint(target_x, 0, target_z)
		if is_on_water then
			return ((bufferedaction ~= nil and bufferedaction.invobject ~= nil and bufferedaction.invobject:HasTag("usedeployspacingasoffset") and bufferedaction.invobject.replica.inventoryitem ~= nil and bufferedaction.invobject.replica.inventoryitem:DeploySpacingRadius()) or 0) + 1.0
		end
	end
    return 0
end

local function ExtraDropDist(doer, dest, bufferedaction)
    if dest ~= nil then
        local target_x, target_y, target_z = dest:GetPoint()

        local is_on_water = TheWorld.Map:IsOceanTileAtPoint(target_x, 0, target_z) and not TheWorld.Map:IsPassableAtPoint(target_x, 0, target_z)
        if is_on_water then
            return 1.75
        end
    end
    return 0
end

local function ExtraPourWaterDist(doer, dest, bufferedaction)
    return 1.5
end

global("CLIENT_REQUESTED_ACTION")
CLIENT_REQUESTED_ACTION = nil

function SetClientRequestedAction(actioncode, mod_name)
    if mod_name then
        CLIENT_REQUESTED_ACTION = MOD_ACTIONS_BY_ACTION_CODE[mod_name] and MOD_ACTIONS_BY_ACTION_CODE[mod_name][actioncode]
    else
        CLIENT_REQUESTED_ACTION = ACTIONS_BY_ACTION_CODE[actioncode]
    end
end

function ClearClientRequestedAction()
    CLIENT_REQUESTED_ACTION = nil
end

--Positional parameters have been deprecated, pass in a table instead.
Action = Class(function(self, data, instant, rmb, distance, ghost_valid, ghost_exclusive, canforce, rangecheckfn)
    if data == nil then
        data = {}
    end
    if type(data) ~= "table" then
        --#TODO: get rid of the positional parameters all together, this warning here is for mods that may be using the old interface.
        print("WARNING: Positional Action parameters are deprecated. Please pass action a table instead.")
        print(string.format("Action defined at %s", debugstack_oneline(4)))
        local priority = data
        data = {priority=priority, instant=instant, rmb=rmb, ghost_valid=ghost_valid, ghost_exclusive=ghost_exclusive, canforce=canforce, rangecheckfn=rangecheckfn}
    end

    self.priority = data.priority or 0
    self.fn = function() return false end
    self.strfn = nil
    self.instant = data.instant or false
    self.rmb = data.rmb or nil -- note! This actually only does something for tools, everything tests 'right' in componentactions
    self.distance = data.distance or nil
    self.mindistance = data.mindistance or nil
    self.ghost_exclusive = data.ghost_exclusive or false
    self.ghost_valid = self.ghost_exclusive or data.ghost_valid or false -- If it's ghost-exclusive, then it must be ghost-valid
    self.mount_valid = data.mount_valid or false
    self.encumbered_valid = data.encumbered_valid or false
    self.canforce = data.canforce or nil
    self.rangecheckfn = self.canforce ~= nil and data.rangecheckfn or nil
    self.mod_name = nil
	self.silent_fail = data.silent_fail or nil

    --new params, only supported by passing via data field
    self.paused_valid = data.paused_valid or false
    self.actionmeter = data.actionmeter or nil
    self.customarrivecheck = data.customarrivecheck
    self.is_relative_to_platform = data.is_relative_to_platform
    self.disable_platform_hopping = data.disable_platform_hopping
    self.skip_locomotor_facing = data.skip_locomotor_facing
    self.do_not_locomote = data.do_not_locomote
    self.extra_arrive_dist = data.extra_arrive_dist
    self.tile_placer = data.tile_placer
    self.show_tile_placer_fn = data.show_tile_placer_fn
	self.theme_music = data.theme_music
	self.theme_music_fn = data.theme_music_fn -- client side function
    self.pre_action_cb = data.pre_action_cb -- runs and client and server
    self.invalid_hold_action = data.invalid_hold_action
end)

-- NOTE: High priority is intended to be a shortcut flag for actions that we expect to always dominate if they are available.
-- We also expect that no two HIGH_ACTION_PRIORITY actions overlap with each other.
local HIGH_ACTION_PRIORITY = 10

ACTIONS =
{
    REPAIR = Action({ mount_valid=true, encumbered_valid=true }),
    READ = Action({ mount_valid=true }),
    DROP = Action({ priority=-1, mount_valid=true, encumbered_valid=true, is_relative_to_platform=true, extra_arrive_dist=ExtraDropDist }),
    TRAVEL = Action(),
    CHOP = Action(),
    ATTACK = Action({priority=2, canforce=true, mount_valid=true }), -- No custom range check, attack already handles that
    EAT = Action({ mount_valid=true }),
    PICK = Action({ canforce=true, rangecheckfn=DefaultRangeCheck, extra_arrive_dist=ExtraPickupRange, mount_valid = true }),
    PICKUP = Action({ priority=1, extra_arrive_dist=ExtraPickupRange, mount_valid=true }),
    MINE = Action(),
    DIG = Action({ rmb=true }),
    GIVE = Action({ mount_valid=true, canforce=true, rangecheckfn=DefaultRangeCheck }),
    GIVETOPLAYER = Action({ priority=3, canforce=true, rangecheckfn=DefaultRangeCheck }),
    GIVEALLTOPLAYER = Action({ priority=3, canforce=true, rangecheckfn=DefaultRangeCheck }),
    FEEDPLAYER = Action({ priority=3, rmb=true, canforce=true, rangecheckfn=DefaultRangeCheck }),
    DECORATEVASE = Action(),
    COOK = Action({ priority=1, mount_valid=true }),
    FILL = Action(),
    FILL_OCEAN = Action({ is_relative_to_platform=true, extra_arrive_dist=ExtraDropDist }),
    DRY = Action(),
    ADDFUEL = Action({ mount_valid=true, paused_valid=true }),
    ADDWETFUEL = Action({ mount_valid=true, paused_valid=true }),
    LIGHT = Action({ priority=-4 }),
    EXTINGUISH = Action({ priority=0 }),
    LOOKAT = Action({ priority=-3, instant=true, ghost_valid=true, mount_valid=true, encumbered_valid=true }),
    TALKTO = Action({ priority=3, instant=true, mount_valid=true, encumbered_valid=true }),
    WALKTO = Action({ priority=-4, ghost_valid=true, mount_valid=true, encumbered_valid=true, invalid_hold_action=true }),
    INTERACT_WITH = Action({ distance=1.5, mount_valid=true }),
    BAIT = Action(),
    CHECKTRAP = Action({ priority=2, mount_valid=true }),
    BUILD = Action({ mount_valid=true }),
    PLANT = Action(),
    HARVEST = Action(),
    GOHOME = Action(),
    SLEEPIN = Action(),
    CHANGEIN = Action({ priority=-1 }),
    HITCHUP = Action({ priority=-1 }),
    MARK = Action({ distance=2, priority=-1 }),
    UNHITCH = Action({ distance=2, priority=-1 }),
    HITCH = Action({ priority=-1 }),
    EQUIP = Action({ priority=0,instant=true, mount_valid=true, encumbered_valid=true, paused_valid=true }),
    UNEQUIP = Action({ priority=-2,instant=true, mount_valid=true, encumbered_valid=true, paused_valid=true }),
    --OPEN_SHOP = Action(),
    SHAVE = Action({ mount_valid=true }),
    STORE = Action(),
    RUMMAGE = Action({ priority=-1, mount_valid=true }),
    DEPLOY = Action({distance=1.1, extra_arrive_dist=ExtraDeployDist }),
    DEPLOY_TILEARRIVE = Action({customarrivecheck=CheckTileWithinRange, theme_music = "farming"}), -- Note: If this is used for non-farming in the future, this would need to be swapped to theme_music_fn
    PLAY = Action({ mount_valid=true }),
    CREATE = Action(),
    JOIN = Action(),
    NET = Action({ priority=3, canforce=true, rangecheckfn=DefaultRangeCheck }),
    CATCH = Action({ priority=3, distance=math.huge, mount_valid=true }),
    FISH_OCEAN = Action({rmb=true, customarrivecheck=CheckFishingOceanRange, is_relative_to_platform = true, disable_platform_hopping=true}),
    FISH = Action(),
    REEL = Action({ instant=true }),
    OCEAN_FISHING_POND = Action(),
    OCEAN_FISHING_CAST = Action({priority=3, rmb=true, customarrivecheck=CheckOceanFishingCastRange, is_relative_to_platform=true, disable_platform_hopping=true}),
    OCEAN_FISHING_REEL = Action({priority=5, rmb=true, do_not_locomote=true, silent_fail = true }),
    OCEAN_FISHING_STOP = Action({instant=true}),
    OCEAN_FISHING_CATCH = Action({priority=6, instant=true}),
    CHANGE_TACKLE = Action({priority=3, rmb=true, instant=true, mount_valid=true}), -- this is now a generic "put item into the container of the equipped hand item"
    POLLINATE = Action(),
    FERTILIZE = Action({priority=1, mount_valid=true }),
    SMOTHER = Action({ priority=1, mount_valid=true }),
    MANUALEXTINGUISH = Action({ priority=1 }),
    LAYEGG = Action(),
    HAMMER = Action({ priority=3 }),
    TERRAFORM = Action({ tile_placer="gridplacer" }),
    JUMPIN = Action({ ghost_valid=true, encumbered_valid=true }),
    TELEPORT = Action({ rmb=true, distance=2 }),
    RESETMINE = Action({ priority=3 }),
    ACTIVATE = Action({ priority=2 }),
    OPEN_CRAFTING = Action({priority=2, distance = TUNING.RESEARCH_MACHINE_DIST - 1}),
    MURDER = Action({ priority=1, mount_valid=true }),
    HEAL = Action({ mount_valid=true }),
    INVESTIGATE = Action(),
    UNLOCK = Action(),
    USEKLAUSSACKKEY = Action(),
    TEACH = Action({ mount_valid=true }),
    TURNON = Action({ priority=2 }),
    TURNOFF = Action({ priority=2 }),
    SEW = Action({ mount_valid=true }),
    STEAL = Action(),
    USEITEM = Action({ priority=1, instant=true }),
    USEITEMON = Action({ distance=2, priority=1 }),
    STOPUSINGITEM = Action({ priority=1 }),
    TAKEITEM = Action(),
    MAKEBALLOON = Action({ mount_valid=true }),
    CASTSPELL = Action({ priority=-1, rmb=true, distance=20, mount_valid=true }),
	CAST_POCKETWATCH = Action({ priority=-1, rmb=true, mount_valid=true }), -- to actually use the mounted action, the pocket watch will need the pocketwatch_mountedcast tag
    BLINK = Action({ priority=HIGH_ACTION_PRIORITY, rmb=true, distance=36, mount_valid=true }),
    COMBINESTACK = Action({ mount_valid=true, extra_arrive_dist=ExtraPickupRange }),
    TOGGLE_DEPLOY_MODE = Action({ priority=HIGH_ACTION_PRIORITY, instant=true }),
    SUMMONGUARDIAN = Action({ rmb=false, distance=5 }),
    HAUNT = Action({ rmb=false, mindistance=2, ghost_valid=true, ghost_exclusive=true, canforce=true, rangecheckfn=DefaultRangeCheck }),
    UNPIN = Action(),
    STEALMOLEBAIT = Action({ rmb=false, distance=.75 }),
    MAKEMOLEHILL = Action({ priority=4, rmb=false, distance=0 }),
    MOLEPEEK = Action({ rmb=false, distance=1 }),
    FEED = Action({ rmb=true, mount_valid=true }),
    UPGRADE = Action({ rmb=true }),
    HAIRBALL = Action({ rmb=false, distance=3 }),
    CATPLAYGROUND = Action({ rmb=false, distance=1 }),
    CATPLAYAIR = Action({ rmb=false, distance=2 }),
    FAN = Action({ rmb=true, mount_valid=true }),
    DRAW = Action(),
    BUNDLE = Action({ rmb=true, priority=2 }),
    BUNDLESTORE = Action({ instant=true }),
    WRAPBUNDLE = Action({ instant=true }),
    UNWRAP = Action({ rmb=true, priority=2 }),
	BREAK = Action({ rmb=true, priority=2 }),
    CONSTRUCT = Action({ distance=2.5 }),
    STOPCONSTRUCTION = Action({ instant=true, distance=2 }),
    APPLYCONSTRUCTION = Action({ instant=true, distance=2 }),
    STARTCHANNELING = Action({ distance=2.1 }),
    STOPCHANNELING = Action({ instant=true, distance=2.1 }),
	APPLYPRESERVATIVE = Action(),
    COMPARE_WEIGHABLE = Action({ encumbered_valid=true, priority=HIGH_ACTION_PRIORITY }),
	WEIGH_ITEM = Action(),
	START_CARRAT_RACE = Action({ rmb = true }),
    CASTSUMMON = Action({ rmb=true, mount_valid=true }),
    CASTUNSUMMON = Action({ mount_valid=true, distance=math.huge }),
	COMMUNEWITHSUMMONED = Action({ rmb=true, mount_valid=true }),
    TELLSTORY = Action({ rmb=true, distance=3 }),

    TOSS = Action({priority=1, rmb=true, distance=8, mount_valid=true }),
    NUZZLE = Action(),
    WRITE = Action(),
    ATTUNE = Action(),
    REMOTERESURRECT = Action({ rmb=false, ghost_valid=true, ghost_exclusive=true }),
    REVIVE_CORPSE = Action({ rmb=false, actionmeter=true }),
    MIGRATE = Action({ rmb=false, encumbered_valid=true, ghost_valid=true }),
    MOUNT = Action({ priority=1, rmb=true, encumbered_valid=true }),
    DISMOUNT = Action({ priority=1, instant=true, rmb=true, mount_valid=true, encumbered_valid=true }),
    SADDLE = Action({ priority=1 }),
    UNSADDLE = Action({ priority=3, rmb=false }),
    BRUSH = Action({ priority=3, rmb=false }),
    ABANDON = Action({ rmb=true }),
    PET = Action(),
    DISMANTLE = Action({ rmb=true }),
    TACKLE = Action({ rmb=true, distance=math.huge }),
	GIVE_TACKLESKETCH = Action(),
	REMOVE_FROM_TROPHYSCALE = Action(),
	CYCLE = Action({ rmb=true, priority=2 }),

    CASTAOE = Action({ priority=HIGH_ACTION_PRIORITY, rmb=true, distance=8 }),

	HALLOWEENMOONMUTATE = Action({ priority=-1 }),

	WINTERSFEAST_FEAST = Action({ priority=1 }),

    BEGIN_QUEST = Action(),
    ABANDON_QUEST = Action(),

    SING = Action({ rmb=true, mount_valid=true }),
    SING_FAIL = Action({ rmb=true, mount_valid=true }),

    --Quagmire
    TILL = Action({ distance=0.5, theme_music = "farming" }),
    PLANTSOIL = Action({ theme_music = "farming" }),
    INSTALL = Action(),
    TAPTREE = Action({priority=1, rmb=true}),
    SLAUGHTER = Action({ canforce=true, rangecheckfn=DefaultRangeCheck }),
    REPLATE = Action(),
    SALT = Action(),

    BATHBOMB = Action(),

    COMMENT = Action({distance = 4}),
    WATER_TOSS = Action({ priority=3, rmb=true, customarrivecheck=CheckOceanFishingCastRange, is_relative_to_platform=true, disable_platform_hopping=true}),

    -- boats
    RAISE_SAIL = Action({ distance=1.25 }),
    LOWER_SAIL = Action({ distance=1.25 }),
    LOWER_SAIL_BOOST = Action({ distance=1.25 }),
    LOWER_SAIL_FAIL = Action({ distance=1.25, do_not_locomote=true }),
    RAISE_ANCHOR = Action({ distance=2.5 }),
    LOWER_ANCHOR = Action({ distance=2.5 }),
    EXTEND_PLANK = Action({ distance=2.5 }),
    RETRACT_PLANK = Action({ distance=2.5 }),
    ABANDON_SHIP = Action({ distance=2.5, priority=4 }),
    MOUNT_PLANK = Action({ distance=0.5 }),
    DISMOUNT_PLANK = Action({ distance=2.5 }),
    REPAIR_LEAK = Action({ distance=2.5 }),
    STEER_BOAT = Action({ distance=0.1 }),
    SET_HEADING = Action({distance=9999, do_not_locomote=true}),
    STOP_STEERING_BOAT = Action({instant=true}),
    CAST_NET = Action({ priority=HIGH_ACTION_PRIORITY, rmb=true, distance=12, mount_valid=true, disable_platform_hopping=true }),
    ROW_FAIL = Action({customarrivecheck=function() return true end, disable_platform_hopping=true, skip_locomotor_facing=true, invalid_hold_action = true}),
    ROW = Action({priority=3, customarrivecheck=CheckRowRange, is_relative_to_platform=true, disable_platform_hopping=true, invalid_hold_action = true}),
    ROW_CONTROLLER = Action({priority=3, is_relative_to_platform=true, disable_platform_hopping=true, do_not_locomote=true, invalid_hold_action = true}),
    BOARDPLATFORM = Action({ customarrivecheck=CheckIsOnPlatform }),
    OCEAN_TOSS = Action({priority=3, rmb=true, customarrivecheck=CheckOceanFishingCastRange, is_relative_to_platform=true, disable_platform_hopping=true}),
    UNPATCH = Action({ distance=0.5 }),
    POUR_WATER = Action({rmb=true, tile_placer="gridplacer", show_tile_placer_fn=ShowPourWaterTilePlacer, extra_arrive_dist=ExtraPourWaterDist }),
    POUR_WATER_GROUNDTILE = Action({rmb=true, customarrivecheck=CheckTileWithinRange, tile_placer="gridplacer", theme_music = "farming" }),
    PLANTREGISTRY_RESEARCH_FAIL = Action({ priority = -1 }),
    PLANTREGISTRY_RESEARCH = Action({ priority = HIGH_ACTION_PRIORITY }),
    ASSESSPLANTHAPPINESS = Action({ priority = 1 }),
    ATTACKPLANT = Action(),
    PLANTWEED = Action(),
    ADDCOMPOSTABLE = Action(),
    WAX = Action({ encumbered_valid = true, }),
    APPRAISE = Action(),
    UNLOAD_WINCH = Action({rmb=true, priority=3}),
    USE_HEAVY_OBSTACLE = Action({encumbered_valid=true, rmb=true, priority=1}),
    ADVANCE_TREE_GROWTH = Action(),

    CARNIVAL_HOST_SUMMON = Action(),

    -- YOTB
    YOTB_SEW = Action({ priority=1, mount_valid=true }),
    YOTB_STARTCONTEST = Action(),
    YOTB_UNLOCKSKIN = Action(),

	CARNIVALGAME_FEED = Action({ mount_valid=true }),

	-- YOT_Catcoon
    RETURN_FOLLOWER = Action(),
    HIDEANSEEK_FIND = Action({ rmb=true, priority=1, mount_valid=true }),

    -- WEBBER
    MUTATE_SPIDER = Action({priority = 2}),
    HERD_FOLLOWERS = Action({ mount_valid=true }),
    REPEL = Action({ mount_valid=true }),
    BEDAZZLE = Action(),

    -- WANDA
    DISMANTLE_POCKETWATCH = Action({ mount_valid=true }),

    -- WOLFGANG
    LIFT_DUMBBELL = Action({ priority = 2, mount_valid=false }), -- Higher than TOSS

    STOP_LIFT_DUMBBELL = Action({ priority = 2, mount_valid=false, instant = true }),
    ENTER_GYM = Action({ mount_valid=false, invalid_hold_action = true }),    
    UNLOAD_GYM = Action({ mount_valid=false}),

    -- Minigame actions:
    LEAVE_GYM = Action({ mount_valid=false, instant = true }),
    LIFT_GYM_SUCCEED_PERFECT = Action({ do_not_locomote=true, disable_platform_hopping=true, skip_locomotor_facing=true, invalid_hold_action = true }),
    LIFT_GYM_SUCCEED = Action({ do_not_locomote=true, disable_platform_hopping=true, skip_locomotor_facing=true, invalid_hold_action = true }),
    LIFT_GYM_FAIL = Action({ do_not_locomote=true, disable_platform_hopping=true, skip_locomotor_facing=true, invalid_hold_action = true }),

    -- WX78
    APPLYMODULE = Action({ mount_valid=true }),
    APPLYMODULE_FAIL = Action({ mount_valid=true }),
    REMOVEMODULES = Action({ mount_valid=true }),
    REMOVEMODULES_FAIL = Action({ mount_valid=true }),
    CHARGE_FROM = Action({ mount_valid=false }),
}

ACTIONS_BY_ACTION_CODE = {}

ACTION_IDS = {}
for k, v in orderedPairs(ACTIONS) do
    v.str = STRINGS.ACTIONS[k] or "ACTION"
    v.id = k
    table.insert(ACTION_IDS, k)
    v.code = #ACTION_IDS
    ACTIONS_BY_ACTION_CODE[v.code] = v
end

MOD_ACTIONS_BY_ACTION_CODE = {}

ACTION_MOD_IDS = {} --This will be filled in when mods add actions via AddAction in modutil.lua

----set up the action functions!

ACTIONS.APPRAISE.fn = function(act)
    local obj = act.invobject
    local target = act.target
    local canappraise, reason = obj.components.appraisable:CanAppraise(target)
    if canappraise then
        obj.components.appraisable:Appraise(target)
        return true
    elseif reason == "NOTNOW" then
        return false, "NOTNOW"
    end
end

ACTIONS.EAT.fn = function(act)
    local obj = act.target or act.invobject
    if obj ~= nil then
        if obj.components.edible ~= nil and act.doer.components.eater ~= nil then
            return act.doer.components.eater:Eat(obj, act.doer)
        elseif obj.components.soul ~= nil and act.doer.components.souleater ~= nil then
            return act.doer.components.souleater:EatSoul(obj)
        elseif act.doer.components.oceanfishable ~= nil and obj.components.oceanfishable ~= nil then
            return act.doer.components.oceanfishable:SetRod(obj.components.oceanfishable:GetRod())
        end
    end
end

ACTIONS.STEAL.fn = function(act)
    local owner = act.target.components.inventoryitem ~= nil and act.target.components.inventoryitem.owner or nil
    if owner ~= nil then
        return act.doer.components.thief:StealItem(owner, act.target, act.attack == true)
    elseif act.target.components.dryer ~= nil then
        return act.target.components.dryer:DropItem()
    end
end

ACTIONS.MAKEBALLOON.fn = function(act)
    if act.doer ~= nil and
        act.invobject ~= nil and
        act.invobject.components.balloonmaker ~= nil and
        act.doer:HasTag("balloonomancer") then
        if act.doer.components.sanity ~= nil then
            if act.doer.components.sanity.current < TUNING.SANITY_TINY then
                return false
            end
            act.doer.components.sanity:DoDelta(-TUNING.SANITY_TINY)
        end
        --Spawn it to either side of doer's current facing with some variance
        local x, y, z = act.doer.Transform:GetWorldPosition()
        local angle = act.doer.Transform:GetRotation()
        local angle_offset = GetRandomMinMax(-10, 10)
        angle_offset = angle_offset + (angle_offset < 0 and -65 or 65)
        angle = (angle + angle_offset) * DEGREES
        act.invobject.components.balloonmaker:MakeBalloon(
            x + .5 * math.cos(angle),
            0,
            z - .5 * math.sin(angle)
        )
        return true
    end
end

ACTIONS.EQUIP.fn = function(act)
    if act.doer.components.inventory ~= nil then
        return act.doer.components.inventory:Equip(act.invobject)
    end
end

ACTIONS.UNEQUIP.strfn = function(act)
    return (act.invobject ~= nil and
            act.invobject:HasTag("heavy") or
            GetGameModeProperty("non_item_equips") or
            act.doer.replica.inventory:GetNumSlots() <= 0)
        and "HEAVY"
        or nil
end

ACTIONS.UNEQUIP.fn = function(act)
    if act.invobject ~= nil and act.doer.components.inventory ~= nil then
        if act.invobject.components.inventoryitem.cangoincontainer and not GetGameModeProperty("non_item_equips") then
            act.doer.components.inventory:GiveItem(act.invobject)
        else
            act.doer.components.inventory:DropItem(act.invobject, true, true)
        end
        return true
    end
end

ACTIONS.PICKUP.strfn = function(act)
    return act.target ~= nil
        and act.target:HasTag("heavy")
        and "HEAVY"
        or nil
end

ACTIONS.PICKUP.fn = function(act)
    if act.doer.components.inventory ~= nil and
        act.target ~= nil and
        act.target.components.inventoryitem ~= nil and
        (act.target.components.inventoryitem.canbepickedup or
        (act.target.components.inventoryitem.canbepickedupalive and not act.doer:HasTag("player"))) and
        not (act.target:IsInLimbo() or
            (act.target.components.burnable ~= nil and act.target.components.burnable:IsBurning()) or
            (act.target.components.projectile ~= nil and act.target.components.projectile:IsThrown())) then

        if act.doer.components.itemtyperestrictions ~= nil and not act.doer.components.itemtyperestrictions:IsAllowed(act.target) then
            return false, "restriction"
        elseif act.target.components.container ~= nil and act.target.components.container:IsOpenedByOthers(act.doer) then
            return false, "INUSE"
        elseif (act.target.components.yotc_racecompetitor ~= nil and act.target.components.entitytracker ~= nil) then
            local trainer = act.target.components.entitytracker:GetEntity("yotc_trainer")
            if trainer ~= nil and trainer ~= act.doer then
                return false, "NOTMINE_YOTC"
            end
		elseif act.doer.components.inventory.noheavylifting and act.target:HasTag("heavy") then
			return false, "NO_HEAVY_LIFTING"
        end

        if (act.target:HasTag("spider") and act.doer:HasTag("spiderwhisperer")) and 
           (act.target.components.follower.leader ~= nil and act.target.components.follower.leader ~= act.doer) then
            return false, "NOTMINE_SPIDER"
        end

        if act.target.components.inventory ~= nil and act.target:HasTag("drop_inventory_onpickup") then
            act.target.components.inventory:TransferInventory(act.doer)
        end

        act.doer:PushEvent("onpickupitem", { item = act.target })

        if act.target.components.equippable ~= nil and not act.target.components.equippable:IsRestricted(act.doer) then
            local equip = act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
            if equip ~= nil and not act.target.components.inventoryitem.cangoincontainer then
                --special case for trying to carry two backpacks
                if equip.components.inventoryitem ~= nil and equip.components.inventoryitem.cangoincontainer then
                    --act.doer.components.inventory:SelectActiveItemFromEquipSlot(act.target.components.equippable.equipslot)
                    act.doer.components.inventory:GiveItem(act.doer.components.inventory:Unequip(act.target.components.equippable.equipslot))
                else
                    act.doer.components.inventory:DropItem(equip)
                end
                act.doer.components.inventory:Equip(act.target)
                return true
            elseif act.doer:HasTag("player") then
                if equip == nil or act.doer.components.inventory:GetNumSlots() <= 0 then
                    act.doer.components.inventory:Equip(act.target)
                    return true
                elseif GetGameModeProperty("non_item_equips") then
                    act.doer.components.inventory:DropItem(equip)
                    act.doer.components.inventory:Equip(act.target)
                    return true
                end
            end
        end

        act.doer.components.inventory:GiveItem(act.target, nil, act.target:GetPosition())
        return true
    end
end

ACTIONS.REPAIR.strfn = function(act)
	return act.target ~= nil
			and (act.target:HasTag("repairable_moon_altar") and "SOCKET")
			or nil
end

ACTIONS.REPAIR.fn = function(act)
    if act.target ~= nil and act.target.components.repairable ~= nil then
        local material
        if act.doer ~= nil and
            act.doer.components.inventory ~= nil and
            act.doer.components.inventory:IsHeavyLifting() and
            not (act.doer.components.rider ~= nil and
                act.doer.components.rider:IsRiding()) then
            material = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        else
            material = act.invobject
        end
        if material ~= nil and material.components.repairer ~= nil then
            return act.target.components.repairable:Repair(act.doer, material)
        end
    end
end

ACTIONS.SEW.strfn = function(act)
    return act.invobject ~= nil
        and (act.invobject:HasTag("tape") and "PATCH")
        or nil
end

ACTIONS.SEW.fn = function(act)
    if act.target ~= nil and
        act.invobject ~= nil and
        act.target.components.fueled ~= nil and
        act.invobject.components.sewing ~= nil then
        return act.invobject.components.sewing:DoSewing(act.target, act.doer)
    end
end

ACTIONS.RUMMAGE.fn = function(act)
    local targ = act.target or act.invobject

    if targ ~= nil and targ.components.container ~= nil then
        if targ.components.container:IsOpenedBy(act.doer) then
            targ.components.container:Close(act.doer)
            act.doer:PushEvent("closecontainer", { container = targ })
            return true
        elseif targ:HasTag("mastercookware") and not act.doer:HasTag("masterchef") then
            return false, "NOTMASTERCHEF"
        --elseif targ:HasTag("professionalcookware") and not act.doer:HasTag("professionalchef") then
            --return false, "NOTPROCHEF"
        elseif not targ.components.container:IsOpenedBy(act.doer) and not targ.components.container:CanOpen() then
            return false, "INUSE"
        elseif targ.components.container.canbeopened then
            local owner = targ.components.inventoryitem ~= nil and targ.components.inventoryitem:GetGrandOwner() or nil
            if owner ~= nil and (targ.components.quagmire_stewer ~= nil or targ.components.container.droponopen) then
                if owner == act.doer then
                    owner.components.inventory:DropItem(targ, true, true)
                elseif owner.components.container ~= nil and owner.components.container:IsOpenedBy(act.doer) then
                    owner.components.container:DropItem(targ)
                else
                    --Silent fail, should not reach here
                    return true
                end
            end
            --Silent fail for opening containers in the dark
            if CanEntitySeeTarget(act.doer, targ) then
                act.doer:PushEvent("opencontainer", { container = targ })
                targ.components.container:Open(act.doer)
            end
            return true
        end
    end
end

ACTIONS.RUMMAGE.strfn = function(act)
    local targ = act.target or act.invobject
    return targ ~= nil
        and (   targ.replica.container ~= nil and
                targ.replica.container:IsOpenedBy(act.doer) and
                "CLOSE" or
                (act.target ~= nil and act.target:HasTag("decoratable") and "DECORATE")
            )
        or nil
end

ACTIONS.DROP.fn = function(act)
    return act.doer.components.inventory ~= nil
        and act.doer.components.inventory:DropItem(
                act.invobject,
                act.options.wholestack and
                not (act.invobject ~= nil and
                    act.invobject.components.stackable ~= nil and
                    act.invobject.components.stackable.forcedropsingle),
                (act.invobject.components.inventoryitem ~= nil
                    and act.invobject.components.inventoryitem.droprandomdir)
                or false,
                act:GetActionPoint())
        or nil
end

ACTIONS.DROP.strfn = function(act)
    if act.invobject ~= nil and not act.invobject:HasActionComponent("deployable") then
        return (act.invobject:HasTag("trap") and "SETTRAP")
            or (act.invobject:HasTag("mine") and "SETMINE")
            or (act.invobject:HasTag("soul") and "FREESOUL")
            or (act.invobject.prefab == "pumpkin_lantern" and "PLACELANTERN")
            or (act.invobject.GetDropActionString ~= nil and act.invobject:GetDropActionString(act:GetActionPoint()))
            or nil
    end
end

ACTIONS.LOOKAT.fn = function(act)
    local targ = act.target or act.invobject

    if targ ~= nil then
		if targ.components.inspectable ~= nil then
			local desc, text_filter_context, original_author = targ.components.inspectable:GetDescription(act.doer)
			if desc ~= nil then
				if act.doer.components.playercontroller == nil or
					not act.doer.components.playercontroller.directwalking then
					act.doer.components.locomotor:Stop()
				end
				if act.doer.components.talker ~= nil then
					act.doer.components.talker:Say(desc, nil, targ.components.inspectable.noanim, nil, nil, nil, text_filter_context, original_author)
				end
				return true
			end
		end
    end
end

ACTIONS.READ.fn = function(act)
    local targ = act.target or act.invobject
    if targ ~= nil and act.doer ~= nil then
		if targ.components.book ~= nil and act.doer.components.reader ~= nil then
	        return act.doer.components.reader:Read(targ)
		elseif targ.components.simplebook ~= nil then
			targ.components.simplebook:Read(act.doer)
			return true
		end
	end
end

ACTIONS.ROW_FAIL.fn = function(act)
    local oar = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    if oar == nil then return false end

    --Can't rely on return false to trigger action fail string because returning
    --false skips the finite uses callback and the oar won't lose durability
    local fail_string_id = oar.components.oar:RowFail(act.doer)
    local fail_str = GetActionFailString(act.doer, "ROW_FAIL", fail_string_id)
    act.doer.components.talker:Say(fail_str)
    act.doer:PushEvent("working",{}) -- it's not actually doing work, but it can fall out of your hand when wet.
    return true
end

local function row(act)
    local oar = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    if oar == nil then 
        return false 
    end

    local pos = act:GetActionPoint()
    if pos == nil then
        pos = act.target:GetPosition()
    end
    oar.components.oar:Row(act.doer, pos)
    act.doer:PushEvent("working",{}) -- it's not actually doing work, but it can fall out of your hand when wet.
    return true
end

ACTIONS.ROW.fn = function(act)
    return row(act)
end

ACTIONS.ROW_CONTROLLER.fn = function(act)
    return row(act)
end

ACTIONS.BOARDPLATFORM.fn = function(act)
	return true
end

ACTIONS.OCEAN_FISHING_POND.fn = function(act)
	return false, "WRONGGEAR"
end

ACTIONS.OCEAN_FISHING_CAST.fn = function(act)
    local rod = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local pos = act:GetActionPoint()
    if pos == nil then
        pos = act.target:GetPosition()
    end

    return (rod ~= nil and rod.components.oceanfishingrod ~= nil) and rod.components.oceanfishingrod:Cast(act.doer, pos) or nil
end

ACTIONS.OCEAN_FISHING_REEL.strfn = function(act)
    local rod = act.invobject or act.doer.replica.inventory ~= nil and act.doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
	local target = (rod ~= nil and rod:IsValid() and rod.replica.oceanfishingrod ~= nil) and rod.replica.oceanfishingrod:GetTarget() or nil
	return (target ~= nil and target:HasTag("partiallyhooked")) and "SETHOOK"
			or nil
end

ACTIONS.OCEAN_FISHING_REEL.fn = function(act)
    local rod = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if rod ~= nil and rod.components.oceanfishingrod ~= nil then
		return rod.components.oceanfishingrod:Reel()
	end
end

ACTIONS.OCEAN_FISHING_STOP.fn = function(act)
    local rod = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if rod ~= nil and rod.components.oceanfishingrod ~= nil then
        act.doer.sg:GoToState("oceanfishing_stop")
		rod.components.oceanfishingrod:StopFishing("reeledin")
	end

	return true
end

ACTIONS.OCEAN_FISHING_CATCH.fn = function(act)
    local rod = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if rod ~= nil and rod.components.oceanfishingrod ~= nil then
        act.doer.sg:GoToState("oceanfishing_catch")
		rod.components.oceanfishingrod:CatchFish()
	end

	return true
end

ACTIONS.CHANGE_TACKLE.strfn = function(act)
	local item = (act.invobject ~= nil and act.invobject:IsValid()) and act.invobject or nil
    local equipped = (item ~= nil and act.doer.replica.inventory ~= nil) and act.doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
	return (equipped ~= nil and equipped.replica.container ~= nil and equipped.replica.container:IsHolding(item)) and "REMOVE"
			or (item ~= nil and item:HasTag("reloaditem_ammo")) and "AMMO"
			or nil
end

ACTIONS.CHANGE_TACKLE.fn = function(act)
	local equipped = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if act.invobject == nil or equipped == nil or equipped.components.container == nil then
		return false
	end

	if act.invobject.components.inventoryitem:IsHeldBy(equipped) then
		local item = equipped.components.container:RemoveItem(act.invobject, true)

		if item ~= nil then
	        item.prevcontainer = nil
	        item.prevslot = nil

			act.doer.components.inventory:GiveItem(item, nil, equipped:GetPosition())
			return true
		end
	else
		local targetslot = equipped.components.container:GetSpecificSlotForItem(act.invobject)
		if targetslot == nil then
			return false
		end

		local cur_item = equipped.components.container:GetItemInSlot(targetslot)
		if cur_item == nil then
	        local item = act.invobject.components.inventoryitem:RemoveFromOwner(equipped.components.container.acceptsstacks)
			equipped.components.container:GiveItem(item, targetslot, nil, false)
		else
			if equipped.components.container.acceptsstacks and act.invobject.prefab == cur_item.prefab and act.invobject.skinname == cur_item.skinname
				and (cur_item.components.stackable == nil or not cur_item.components.stackable:IsFull()) then -- if full up the stack

		        local item = act.invobject.components.inventoryitem:RemoveFromOwner(equipped.components.container.acceptsstacks)
				if not equipped.components.container:GiveItem(act.invobject, targetslot, nil, false) then
					if item.prevcontainer ~= nil then
						item.prevcontainer.inst.components.container:GiveItem(item, item.prevslot)
					else
						act.doer.components.inventory:GiveItem(item, item.prevslot)
					end
				end
				return true
			elseif (act.invobject.prefab ~= cur_item.prefab and (act.invobject.skinname == nil or act.invobject.skinname ~= cur_item.skinname)) or cur_item.components.perishable then
		        local item = act.invobject.components.inventoryitem:RemoveFromOwner(equipped.components.container.acceptsstacks)
				local old_item = equipped.components.container:RemoveItemBySlot(targetslot)
				if not equipped.components.container:GiveItem(item, targetslot, nil, false) then
					act.doer.components.inventory:GiveItem(item, nil, equipped:GetPosition())
				end
				if old_item ~= nil then
					act.doer.components.inventory:GiveItem(old_item, nil, equipped:GetPosition())
				end
				return true
			end
		end

	end
	return false
end

ACTIONS.TALKTO.fn = function(act)
    local targ = act.target or act.invobject
    if targ and targ.components.talkable then
        act.doer.components.locomotor:Stop()

        if act.target.components.maxwelltalker then
            if not act.target.components.maxwelltalker:IsTalking() then
                act.target:PushEvent("talkedto")
                act.target.task = act.target:StartThread(function() act.target.components.maxwelltalker:DoTalk(act.target) end)
            end
        end
        return true
    end
end

ACTIONS.INTERACT_WITH.strfn = function(act)
    return act.target ~= nil
        and act.target:HasTag("farm_plant") and "FARM_PLANT"
		or nil
end

ACTIONS.INTERACT_WITH.fn = function(act)
	if act.target ~= nil and act.target.components.farmplanttendable ~= nil then
        if act.target.components.farmplanttendable:TendTo(act.doer) then
            if act.doer.components.talker ~= nil then
                act.doer.sg:AddStateTag("idle") -- allow talker state to take over
                act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_TALK_TO_PLANTS"))
            end
			return true
		end
	end
end
ACTIONS.INTERACT_WITH.theme_music_fn = function(act)
    return act.target ~= nil
        and act.target:HasTag("farm_plant") and "farming"
		or nil
end

ACTIONS.ATTACKPLANT.fn = function(act)
    if act.target ~= nil and act.target.components.farmplantstress ~= nil then
        act.target.components.farmplantstress:SetStressed("happiness", true, act.doer)
        if act.target.components.farmplanttendable then
            act.target.components.farmplanttendable:SetTendable(true)
        end
        return true
    end
end

ACTIONS.TELLSTORY.fn = function(act)
    local targ = act.target or act.invobject
	if act.doer.components.storyteller ~= nil then
		return act.doer.components.storyteller:TellStory(act.target or act.invobject)
	end
end

ACTIONS.BAIT.fn = function(act)
    if act.target.components.trap then
        act.target.components.trap:SetBait(act.doer.components.inventory:RemoveItem(act.invobject))
        return true
    end
end

ACTIONS.DEPLOY.fn = function(act)
	local act_pos = act:GetActionPoint()
    if act.invobject ~= nil and act.invobject.components.deployable ~= nil and act.invobject.components.deployable:CanDeploy(act_pos, nil, act.doer, act.rotation) then
        if act.invobject.components.deployable.keep_in_inventory_on_deploy then
            return act.invobject.components.deployable:Deploy(act_pos, act.doer, act.rotation)
        else
            local container = act.doer.components.inventory or act.doer.components.container
            local obj = container ~= nil and container:RemoveItem(act.invobject) or nil
            if obj ~= nil then
                if obj.components.deployable:Deploy(act_pos, act.doer, act.rotation) then
                    return true
                else
                    container:GiveItem(obj)
                end
            end
        end
    end
end

ACTIONS.DEPLOY.strfn = function(act)
    return act.invobject ~= nil
        and (   (act.invobject:HasTag("usedeploystring") and "DEPLOY") or
                (act.invobject:HasTag("groundtile") and "GROUNDTILE") or
                (act.invobject:HasTag("wallbuilder") and "WALL") or
                (act.invobject:HasTag("fencebuilder") and "FENCE") or
                (act.invobject:HasTag("gatebuilder") and "GATE") or
                (act.invobject:HasTag("portableitem") and "PORTABLE") or
                (act.invobject:HasTag("boatbuilder") and "WATER") or
                (act.invobject:HasTag("deploykititem") and "TURRET") or
                (act.invobject:HasTag("eyeturret") and "TURRET") or
                (act.invobject:HasTag("fertilizer") and "FERTILIZE_GROUND")    )
        or nil
end

ACTIONS.DEPLOY.theme_music_fn = function(act)
    return act.invobject ~= nil
        and act.invobject:HasTag("deployedfarmplant") and "farming"
		or nil
end

ACTIONS.DEPLOY_TILEARRIVE.fn = ACTIONS.DEPLOY.fn
ACTIONS.DEPLOY_TILEARRIVE.stroverridefn = function(act)
    return STRINGS.ACTIONS.DEPLOY[ACTIONS.DEPLOY.strfn(act) or "GENERIC"]
end

ACTIONS.TOGGLE_DEPLOY_MODE.strfn = ACTIONS.DEPLOY.strfn

ACTIONS.SUMMONGUARDIAN.fn = function(act)
    if act.doer and act.target and act.target.components.guardian then
        act.target.components.guardian:Call()
    end
end

ACTIONS.CHECKTRAP.fn = function(act)
    if act.target.components.trap then
        act.target.components.trap:Harvest(act.doer)
        return true
    end
end

local function DoToolWork(act, workaction)
    if act.target.components.workable ~= nil and
        act.target.components.workable:CanBeWorked() and
        act.target.components.workable:GetWorkAction() == workaction then
        act.target.components.workable:WorkedBy(
            act.doer,
            (   (   act.invobject ~= nil and
                act.invobject.components.tool ~= nil and
                act.invobject.components.tool:GetEffectiveness(workaction)
            ) or
            (   act.doer ~= nil and
                act.doer.components.worker ~= nil and
                act.doer.components.worker:GetEffectiveness(workaction)
            ) or
            1
            ) *
            (   act.doer.components.workmultiplier ~= nil and
                act.doer.components.workmultiplier:GetMultiplier(workaction) or
                1
        )
        )
        return true
    end
    return false
end

local function ValidToolWork(act, workaction)
    return act.target.components.workable ~= nil and act.target.components.workable:CanBeWorked() and act.target.components.workable:GetWorkAction() == workaction
end

ACTIONS.CHOP.fn = function(act)
    if DoToolWork(act, ACTIONS.CHOP) and
        act.doer ~= nil and
        act.doer.components.spooked ~= nil and
        act.target:IsValid() then
        act.doer.components.spooked:Spook(act.target)
    end
    return true
end

ACTIONS.CHOP.validfn = function(act)
    return ValidToolWork(act, ACTIONS.CHOP)
end

ACTIONS.MINE.fn = function(act)
    DoToolWork(act, ACTIONS.MINE)
    return true
end

ACTIONS.MINE.validfn = function(act)
    return ValidToolWork(act, ACTIONS.MINE)
end

ACTIONS.HAMMER.fn = function(act)
    DoToolWork(act, ACTIONS.HAMMER)
    return true
end

ACTIONS.HAMMER.validfn = function(act)
    return ValidToolWork(act, ACTIONS.HAMMER)
end

ACTIONS.DIG.fn = function(act)
    DoToolWork(act, ACTIONS.DIG)
    return true
end

ACTIONS.DIG.validfn = function(act)
    return ValidToolWork(act, ACTIONS.DIG)
end

ACTIONS.DIG.theme_music_fn = function(act)
    return act.target ~= nil
        and (act.target:HasTag("farm_debris") or act.target:HasTag("farm_plant")) and "farming"
		or nil
end

ACTIONS.FERTILIZE.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.fertilizer ~= nil then
		local applied = false
        if not (act.doer ~= nil and act.doer.components.rider ~= nil and act.doer.components.rider:IsRiding()) then
            if act.target ~= nil then
            if act.target.components.crop ~= nil and not (act.target.components.crop:IsReadyForHarvest() or act.target:HasTag("withered")) then
                    applied = act.target.components.crop:Fertilize(act.invobject, act.doer)
            elseif act.target.components.grower ~= nil and act.target.components.grower:IsEmpty() then
                    applied = act.target.components.grower:Fertilize(act.invobject, act.doer)
            elseif act.target.components.pickable ~= nil and act.target.components.pickable:CanBeFertilized() then
                    applied = act.target.components.pickable:Fertilize(act.invobject, act.doer)
                    TheWorld:PushEvent("CHEVO_fertilized", {target = act.target, doer = act.doer})
            elseif act.target.components.quagmire_fertilizable ~= nil then
                    applied = act.target.components.quagmire_fertilizable:Fertilize(act.invobject, act.doer)
            end
        end
        end
        if not applied and act.doer ~= nil and (act.target == nil or act.doer == act.target) then
			if act.doer.components.fertilizable ~= nil then
				applied = act.doer.components.fertilizable:Fertilize(act.invobject)
				--applied = act.invobject.components.fertilizer:Heal(act.doer)
			end
        end

		if applied then
			act.invobject.components.fertilizer:OnApplied(act.doer, act.target)
    end

		return applied
end
end

ACTIONS.SMOTHER.fn = function(act)
    if act.target.components.burnable and act.target.components.burnable:IsSmoldering() then
        local smotherer = act.invobject or act.doer
        act.target.components.burnable:SmotherSmolder(smotherer)
        return true
    end
end

ACTIONS.MANUALEXTINGUISH.fn = function(act)
    if act.invobject:HasTag("frozen") and act.target.components.burnable and act.target.components.burnable:IsBurning() then
        act.target.components.burnable:Extinguish(true, TUNING.SMOTHERER_EXTINGUISH_HEAT_PERCENT, act.invobject)
        return true
    end
end

ACTIONS.NET.fn = function(act)
    if act.target ~= nil and
        act.target.components.workable ~= nil and
        act.target.components.workable:CanBeWorked() and
        act.target.components.workable:GetWorkAction() == ACTIONS.NET and
        not (act.target.components.health ~= nil and act.target.components.health:IsDead()) then
        act.target.components.workable:WorkedBy(act.doer)
    end
    return true
end

ACTIONS.CATCH.fn = function(act)
    return true
end

ACTIONS.FISH_OCEAN.fn = function(act)
	return false, "TOODEEP"
end

ACTIONS.FISH.fn = function(act)
    local fishingrod = act.invobject.components.fishingrod
    if fishingrod then
        fishingrod:StartFishing(act.target, act.doer)
    end
    return true
end

ACTIONS.REEL.fn = function(act)
    local fishingrod = act.invobject.components.fishingrod
    if fishingrod and fishingrod:IsFishing() then
        if fishingrod:HasHookedFish() then
            fishingrod:Reel()
        elseif fishingrod:FishIsBiting() then
            fishingrod:Hook()
        else
            fishingrod:StopFishing()
        end
    end
    return true
end

ACTIONS.REEL.strfn = function(act)
    local fishingrod = act.invobject.replica.fishingrod
    if fishingrod ~= nil and fishingrod:GetTarget() == act.target then
        if fishingrod:HasHookedFish() then
            return "REEL"
        elseif act.doer:HasTag("nibble") then
            return "HOOK"
        else
            return "CANCEL"
        end
    end
end

ACTIONS.PICK.strfn = function(act)
	return act.target ~= nil and act.target:HasTag("pickable_harvest_str") and "HARVEST"
			or nil
end

ACTIONS.PICK.fn = function(act)
    if act.target ~= nil and act.target.components.pickable ~= nil then
        act.target.components.pickable:Pick(act.doer)
        return true
    end
end

ACTIONS.PICK.validfn = function(act)
    return act.target and act.target.components.pickable and act.target.components.pickable:CanBePicked()
end

ACTIONS.PICK.theme_music_fn = function(act)
    return act.target ~= nil
        and act.target:HasTag("farm_plant") and "farming"
		or nil
end

ACTIONS.ATTACK.fn = function(act)
    if act.doer.sg ~= nil then
        if act.doer.sg:HasStateTag("propattack") then
            --don't do a real attack with prop weapons
            return true
        elseif act.doer.sg:HasStateTag("thrusting") then
            local weapon = act.doer.components.combat:GetWeapon()
            return weapon ~= nil
                and weapon.components.multithruster ~= nil
                and weapon.components.multithruster:StartThrusting(act.doer)
        elseif act.doer.sg:HasStateTag("helmsplitting") then
            local weapon = act.doer.components.combat:GetWeapon()
            return weapon ~= nil
                and weapon.components.helmsplitter ~= nil
                and weapon.components.helmsplitter:StartHelmSplitting(act.doer)
        end
    end
    act.doer.components.combat:DoAttack(act.target)
    return true
end

ACTIONS.ATTACK.strfn = function(act)
    if act.target ~= nil then
        --act.invobject is weapon
        if act.invobject ~= nil then
            if act.invobject:HasTag("propweapon") then
                return "PROP"
            elseif act.doer.replica.combat ~= nil then
                if act.doer.replica.combat:CanExtinguishTarget(act.target, act.invobject) then
                    return "RANGEDSMOTHER"
                elseif act.doer.replica.combat:CanLightTarget(act.target, act.invobject) then
                    return "RANGEDLIGHT"
                elseif act.target:HasTag("whackable") and act.invobject:HasTag("hammer") then
                    return "WHACK"
                end
            end
        end

        if act.target:HasTag("smashable") then
            return "SMASHABLE"
        end
    end
end

ACTIONS.COOK.stroverridefn = function(act)
    --done this way instead of using .strfn and "SPICE" modifier to try and avoid
    --breaking mods due to the way the COOK string is accessed in containers.lua.
    return act.target ~= nil and act.target:HasTag("spicer") and STRINGS.ACTIONS.SPICE or nil
end

ACTIONS.COOK.fn = function(act)
    if act.target.components.cooker ~= nil then
        local cook_pos = act.target:GetPosition()
        local ingredient = act.doer.components.inventory:RemoveItem(act.invobject)

        --V2C: position usually matters for listeners of "killed" event
        ingredient.Transform:SetPosition(cook_pos:Get())

        if not act.target.components.cooker:CanCook(ingredient, act.doer) then
            act.doer.components.inventory:GiveItem(ingredient, nil, cook_pos)
            return false
        end

        if ingredient.components.health ~= nil and ingredient.components.combat ~= nil then
            act.doer:PushEvent("killed", { victim = ingredient })
        end

        local product = act.target.components.cooker:CookItem(ingredient, act.doer)
        if product ~= nil then
            act.doer.components.inventory:GiveItem(product, nil, cook_pos)
            return true
        elseif ingredient:IsValid() then
            act.doer.components.inventory:GiveItem(ingredient, nil, cook_pos)
        end
        return false
    elseif act.target.components.stewer ~= nil then
        if act.target.components.stewer:IsCooking() then
            --Already cooking
            return true
        end
        local container = act.target.components.container
        if container ~= nil and container:IsOpenedByOthers(act.doer) then
            return false, "INUSE"
        elseif not act.target.components.stewer:CanCook() then
            return false
        end
        act.target.components.stewer:StartCooking(act.doer)
        return true
    elseif act.target.components.cookable ~= nil
        and act.invobject ~= nil
        and act.invobject.components.cooker ~= nil then

        local cook_pos = act.target:GetPosition()

        --Intentional use of 3D dist check for birds.
        if act.doer:GetPosition():Dist(cook_pos) > 2 then
            return false, "TOOFAR"
        end

        local owner = act.target.components.inventoryitem:GetGrandOwner()
        local container = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
        local stacked = act.target.components.stackable ~= nil and act.target.components.stackable:IsStack()
        local ingredient = stacked and act.target.components.stackable:Get() or act.target

        if ingredient ~= act.target then
            --V2C: position usually matters for listeners of "killed" event
            ingredient.Transform:SetPosition(cook_pos:Get())
        end

        if not act.invobject.components.cooker:CanCook(ingredient, act.doer) then
            if container ~= nil then
                container:GiveItem(ingredient, nil, cook_pos)
            elseif stacked and ingredient ~= act.target then
                act.target.components.stackable:SetStackSize(act.target.components.stackable:StackSize() + 1)
                ingredient:Remove()
            end
            return false
        end

        if ingredient.components.health ~= nil and ingredient.components.combat ~= nil then
            act.doer:PushEvent("killed", { victim = ingredient })
        end

        local product = act.invobject.components.cooker:CookItem(ingredient, act.doer)
        if product ~= nil then
            if container ~= nil then
                container:GiveItem(product, nil, cook_pos)
            else
                product.Transform:SetPosition(cook_pos:Get())
                if stacked and product.Physics ~= nil then
                    local angle = math.random() * 2 * PI
                    local speed = math.random() * 2
                    product.Physics:SetVel(speed * math.cos(angle), GetRandomWithVariance(8, 4), speed * math.sin(angle))
                end
            end
            return true
        elseif ingredient:IsValid() then
            if container ~= nil then
                container:GiveItem(ingredient, nil, cook_pos)
            elseif stacked and ingredient ~= act.target then
                act.target.components.stackable:SetStackSize(act.target.components.stackable:StackSize() + 1)
                ingredient:Remove()
            end
        end
        return false
    end
end

ACTIONS.FILL.fn = function(act)
    local source_object, filled_object = nil, nil

    if act.target == nil then
        filled_object = act.invobject
    else
        if act.target:HasTag("watersource") then
            source_object = act.target
            filled_object = act.invobject
        elseif act.invobject:HasTag("watersource") then
            source_object = act.invobject
            filled_object = act.target
        end
    end

    if filled_object == nil then
        return false
    elseif source_object ~= nil
        and filled_object.components.fillable ~= nil
        and source_object.prefab == filled_object.components.fillable.filledprefab then

        return false
    end

    local groundpt = act:GetActionPoint()
    if groundpt ~= nil then
        local success = filled_object.components.fillable.acceptsoceanwater and TheWorld.Map:IsOceanAtPoint(groundpt.x, 0, groundpt.z)
        if success then
            filled_object.components.fillable:Fill()
            return true
        else
            return false, filled_object.components.fillable.oceanwatererrorreason
        end
    end

    return source_object ~= nil
        and source_object:HasTag("watersource")
        and filled_object.components.fillable:Fill(source_object)
end

ACTIONS.FILL_OCEAN.fn = ACTIONS.FILL.fn
ACTIONS.FILL_OCEAN.stroverridefn = function(act)
    return STRINGS.ACTIONS.FILL
end

ACTIONS.DRY.fn = function(act)
    if act.target.components.dryer then
        if not act.target.components.dryer:CanDry(act.invobject) then
            return false
        end

        local ingredient = act.doer.components.inventory:RemoveItem(act.invobject)
        if not act.target.components.dryer:StartDrying(ingredient) then
            act.doer.components.inventory:GiveItem(ingredient, nil, act.target:GetPosition())
            return false
        else
            TheWorld:PushEvent("CHEVO_starteddrying",{target=act.target,doer=act.doer})
        end
        return true
    end
end

ACTIONS.ADDFUEL.fn = function(act)
    if act.doer.components.inventory then
        local fuel = act.doer.components.inventory:RemoveItem(act.invobject)
        if fuel then
            if act.target.components.fueled and act.target.components.fueled:TakeFuelItem(fuel, act.doer) then
                return true
            else
                --print("False")
                act.doer.components.inventory:GiveItem(fuel)
            end
        end
    end
end
ACTIONS.ADDWETFUEL.fn = ACTIONS.ADDFUEL.fn

ACTIONS.GIVE.strfn = function(act)
    return act.target ~= nil
        and ((act.target:HasTag("gemsocket") and "SOCKET") or
            (act.target:HasTag("moontrader") and "CELESTIAL"))
        or nil
end

ACTIONS.GIVE.stroverridefn = function(act)
    --Quagmire & Winter's Feast action strings
    if act.target ~= nil and act.invobject ~= nil then
		if act.target:HasTag("ghostlyelixirable") and act.invobject:HasTag("ghostlyelixir") then
			return subfmt(STRINGS.ACTIONS.GIVE.APPLY, { item = act.invobject:GetBasicDisplayName() })
		elseif act.target:HasTag("wintersfeasttable") then
			return subfmt(STRINGS.ACTIONS.GIVE.PLACE_ITEM, { item = act.invobject:GetBasicDisplayName() })
        elseif act.target.nameoverride ~= nil and act.invobject:HasTag("quagmire_stewer") then
            return subfmt(STRINGS.ACTIONS.GIVE[string.upper(act.target.nameoverride)], { item = act.invobject:GetBasicDisplayName() })
        elseif act.target:HasTag("quagmire_altar") then
            if act.invobject.prefab == "quagmire_portal_key" then
                return STRINGS.ACTIONS.GIVE.SOCKET
            elseif act.invobject.prefab:sub(1, 14) == "quagmire_food_" then
                local dish = act.invobject.basedish
                if dish == nil then
                    local i = act.invobject.prefab:find("_", 15)
                    if i ~= nil then
                        dish = STRINGS.NAMES[string.upper(act.invobject.prefab:sub(1, i - 1))]
                    end
                end
                local str = dish ~= nil and STRINGS.ACTIONS.GIVE.QUAGMIRE_ALTAR[string.upper(dish)] or nil
                if str ~= nil then
                    return subfmt(str, { food = act.invobject:GetBasicDisplayName() })
                end
            end
            return subfmt(STRINGS.ACTIONS.GIVE.QUAGMIRE_ALTAR.GENERIC, { food = act.invobject:GetBasicDisplayName() })
        end
    end
end

ACTIONS.GIVE.fn = function(act)
    if act.target ~= nil then
		
        if act.target.components.ghostlyelixirable ~= nil and act.invobject.components.ghostlyelixir ~= nil then
            return act.invobject.components.ghostlyelixir:Apply(act.doer, act.target)        
        elseif act.target.components.trader ~= nil then
            local able, reason = act.target.components.trader:AbleToAccept(act.invobject, act.doer)
            if not able then
                return false, reason
            end

            act.target.components.trader:AcceptGift(act.doer, act.invobject)
            return true
        elseif act.target.components.moontrader ~= nil then
            return act.target.components.moontrader:AcceptOffering(act.doer, act.invobject)
        elseif act.target.components.quagmire_cookwaretrader ~= nil then
            return act.target.components.quagmire_cookwaretrader:AcceptCookware(act.doer, act.invobject)
        elseif act.target.components.quagmire_altar ~= nil then
            return act.target.components.quagmire_altar:AcceptFoodTribute(act.doer, act.invobject)
        end
    end
end

ACTIONS.GIVETOPLAYER.fn = function(act)
    if act.target ~= nil and
        act.target.components.trader ~= nil and
        act.target.components.inventory ~= nil and
        (act.target.components.inventory:IsOpenedBy(act.target) or act.target:HasTag("playerghost")) then
        if act.target.components.inventory:CanAcceptCount(act.invobject, 1) <= 0 then
            return false, "FULL"
        end
        local able, reason = act.target.components.trader:AbleToAccept(act.invobject, act.doer)
        if not able then
            return false, reason
        end
        act.target.components.trader:AcceptGift(act.doer, act.invobject, 1)
        return true
    end
end

ACTIONS.GIVEALLTOPLAYER.fn = function(act)
    if act.target ~= nil and
        act.target.components.trader ~= nil and
        act.target.components.inventory ~= nil and
        act.target.components.inventory:IsOpenedBy(act.target) then
        local count = act.target.components.inventory:CanAcceptCount(act.invobject)
        if count <= 0 then
            return false, "FULL"
        end
        local able, reason = act.target.components.trader:AbleToAccept(act.invobject, act.doer)
        if not able then
            return false, reason
        end
        act.target.components.trader:AcceptGift(act.doer, act.invobject, count)
        return true
    end
end

ACTIONS.FEEDPLAYER.fn = function(act)
    if act.target ~= nil and
        act.target:IsValid() and
        act.target.sg:HasStateTag("idle") and
        not (act.target.sg:HasStateTag("busy") or
            act.target.sg:HasStateTag("attacking") or
            act.target.sg:HasStateTag("sleeping") or
            act.target:HasTag("playerghost") or
            act.target:HasTag("wereplayer")) and
        act.target.components.eater ~= nil and
        act.invobject.components.edible ~= nil and
        act.target.components.eater:CanEat(act.invobject) and
        (TheNet:GetPVPEnabled() or
        (act.target:HasTag("strongstomach") and 
            act.invobject:HasTag("monstermeat")) or
        (act.invobject:HasTag("spoiled") and act.target:HasTag("ignoresspoilage") and not 
            (act.invobject:HasTag("badfood") or act.invobject:HasTag("unsafefood"))) or
        not (act.invobject:HasTag("badfood") or
            act.invobject:HasTag("unsafefood") or
            act.invobject:HasTag("spoiled"))) then

        if act.target.components.eater:PrefersToEat(act.invobject) then
            local food = act.invobject.components.inventoryitem:RemoveFromOwner()
            if food ~= nil then
                act.target:AddChild(food)
                food:RemoveFromScene()
                food.components.inventoryitem:HibernateLivingItem()
                food.persists = false
                act.target.sg:GoToState(
                    food.components.edible.foodtype == FOODTYPE.MEAT and "eat" or "quickeat",
                    { feed = food, feeder = act.doer }
                )
                return true
            end
        else
            act.target:PushEvent("wonteatfood", { food = act.invobject })
            return true -- the action still "succeeded", there's just no result on this end
        end
    end
end

ACTIONS.DECORATEVASE.fn = function(act)
    if act.target ~= nil and act.target.components.vase ~= nil and act.target.components.vase.enabled then
        act.target.components.vase:Decorate(act.doer, act.invobject)
        return true
    end
end

ACTIONS.CARNIVALGAME_FEED.fn = function(act)
    if act.invobject ~= nil and act.invobject:IsValid() and act.target ~= nil and act.target:IsValid() and act.target.components.carnivalgamefeedable ~= nil then
		if not act.target.components.carnivalgamefeedable.enabled then
			return false, "TOO_LATE"
		end
        return act.target.components.carnivalgamefeedable:DoFeed(act.invobject, act.doer)
    end
end

ACTIONS.STORE.fn = function(act)
    local target = act.target
    --V2C: For dropping items onto the object rather than construction widget
    if target.components.container == nil and target.components.constructionsite ~= nil then
        local builder = target.components.constructionsite.builder
        target = builder == act.doer and builder.components.constructionbuilder ~= nil and builder.components.constructionbuilder.constructioninst or nil
        if target == nil then
            return false
        end
    end
    --
    if target.components.container ~= nil and act.invobject.components.inventoryitem ~= nil and act.doer.components.inventory ~= nil then
        if target:HasTag("mastercookware") and not act.doer:HasTag("masterchef") then
            return false, "NOTMASTERCHEF"
        --elseif target:HasTag("professionalcookware") and not act.doer:HasTag("professionalchef") then
            --return false, "NOTPROCHEF"
        elseif not target.components.container:IsOpenedBy(act.doer) and not target.components.container:CanOpen() then
            return false, "INUSE"
        end

        local targetslot = nil
        if act.doer.components.constructionbuilderuidata ~= nil and act.doer.components.constructionbuilderuidata:GetContainer() == target then
            targetslot = act.doer.components.constructionbuilderuidata:GetSlotForIngredient(act.invobject.prefab)
            if targetslot == nil or not target.components.container:CanTakeItemInSlot(act.invobject, targetslot) then
                --V2C: construction is a busy state, so we need to force the speech
                act.doer.components.talker:Say(GetActionFailString(act.doer, "CONSTRUCT", "NOTALLOWED"))
                return true
            end
        elseif not target.components.container:CanTakeItemInSlot(act.invobject) then
            if target:HasTag("bundle") then
                --V2C: bundling is a busy state, so we need to force the speech
                act.doer.components.talker:Say(GetActionFailString(act.doer, "STORE", "NOTALLOWED"))
                return true
            end
            return false, "NOTALLOWED"
        end

        local forceopen = target.components.quagmire_stewer ~= nil and target.components.inventoryitem ~= nil
        local forcedrop = forceopen and target.components.inventoryitem:GetGrandOwner() or nil
        if forcedrop ~= nil and forcedrop ~= act.doer then
            --Silent fail, should not reach here
            return true
        end

        local item = act.invobject.components.inventoryitem:RemoveFromOwner(target.components.container.acceptsstacks)
        if item ~= nil then
            if forcedrop ~= nil then
                forcedrop.components.inventory:DropItem(target, true, true)
            end
            if forceopen or target.components.inventoryitem == nil then
                target.components.container:Open(act.doer)
            end

            if not target.components.container:GiveItem(item, targetslot, nil, false) then
                if act.doer.components.playercontroller ~= nil and
                    act.doer.components.playercontroller.isclientcontrollerattached then
                    act.doer.components.inventory:GiveItem(item)
                else
                    act.doer.components.inventory:GiveActiveItem(item)
                end
                if target:HasTag("bundle") then
                    --V2C: bundling is a busy state, so we need to force the speech
                    act.doer.components.talker:Say(GetActionFailString(act.doer, "STORE"))
                    return true
                else
                    return false
                end
            end
            return true
        end
    elseif act.invobject ~= nil and
        act.invobject.components.occupier ~= nil and
        target.components.occupiable ~= nil and
        target.components.occupiable:CanOccupy(act.invobject) then
        return target.components.occupiable:Occupy(act.invobject.components.inventoryitem:RemoveFromOwner())
    end
end

ACTIONS.BUNDLESTORE.strfn = function(act)
    return act.target ~= nil
        and act.doer ~= nil
        and act.doer.components.constructionbuilderuidata ~= nil
        and (act.doer.components.constructionbuilderuidata:GetContainer() == act.target or
            act.doer.components.constructionbuilderuidata:GetTarget() == act.target)
        and "CONSTRUCT"
        or nil
end

ACTIONS.BUNDLESTORE.fn = ACTIONS.STORE.fn

ACTIONS.STORE.strfn = function(act)
    if act.target ~= nil then
        return ((act.target:HasTag("stewer") or act.target:HasTag("quagmire_stewer")) and (act.target:HasTag("spicer") and "SPICE" or "COOK"))
            or (act.target.prefab == "birdcage" and "IMPRISON")
            or (act.target:HasTag("decoratable") and "DECORATE")
            or nil
    end
end

ACTIONS.BUILD.fn = function(act)
    if act.doer.components.builder ~= nil then
        return act.doer.components.builder:DoBuild(act.recipe, act:GetActionPoint(), act.rotation, act.skin)
    end
end

ACTIONS.PLANT.strfn = function(act)
    return act.target ~= nil and act.target:HasTag("winter_treestand") and "PLANTER" or nil
end

ACTIONS.PLANT.fn = function(act)
    if act.doer.components.inventory ~= nil then
        local seed = act.doer.components.inventory:RemoveItem(act.invobject)
        if seed ~= nil then
            if act.target.components.grower ~= nil and act.target.components.grower:PlantItem(seed, act.doer) then
                return true
            elseif act.target:HasTag("winter_treestand")
                and act.target.components.burnable ~= nil
                and not (act.target.components.burnable:IsBurning() or
                        act.target.components.burnable:IsSmoldering()) then
                act.target:PushEvent("plantwintertreeseed", { seed = seed, doer = act.doer })
                return true
            else
                act.doer.components.inventory:GiveItem(seed)
            end
        end
    end
end

ACTIONS.HARVEST.fn = function(act)
    if act.target.components.crop ~= nil then
        local harvested--[[, product]] = act.target.components.crop:Harvest(act.doer)
        return harvested
    elseif act.target.components.harvestable ~= nil then
        return act.target.components.harvestable:Harvest(act.doer)
    elseif act.target.components.stewer ~= nil then
        return act.target.components.stewer:Harvest(act.doer)
    elseif act.target.components.dryer ~= nil then
        return act.target.components.dryer:Harvest(act.doer)
    elseif act.target.components.occupiable ~= nil and act.target.components.occupiable:IsOccupied() then
        local item = act.target.components.occupiable:Harvest(act.doer)
        if item ~= nil then
            act.doer.components.inventory:GiveItem(item)
            return true
        end
	elseif act.target.components.quagmire_tappable ~= nil then
		return act.target.components.quagmire_tappable:Harvest(act.doer)
    end
end

ACTIONS.HARVEST.strfn = function(act)
    if act.target ~= nil and act.target.prefab == "birdcage" then
        return "FREE"
    end
    if act.target ~= nil and act.target.components.crop and act.target:HasTag("withered") then
        return "WITHERED"
    end
end

ACTIONS.LIGHT.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.lighter ~= nil then
        if act.doer ~= nil then
            act.doer:PushEvent("onstartedfire", { target = act.target })
        end
        act.invobject.components.lighter:Light(act.target)
        return true
    end
end

ACTIONS.SLEEPIN.fn = function(act)
    if act.doer ~= nil then
        local bag =
            (act.invobject ~= nil and act.invobject.components.sleepingbag ~= nil and act.invobject) or
            (act.target ~= nil and act.target.components.sleepingbag ~= nil and act.target) or
            nil
        if bag ~= nil then
            bag.components.sleepingbag:DoSleep(act.doer)
            return true
        end
    end
end

ACTIONS.HITCHUP.fn = function(act)
    if act.doer == nil or act.target == nil then
        return false
    end

    local bell = nil
    if act.doer.components.inventory then
        bell = act.doer.components.inventory:FindItem(function(item)
            if item.GetBeefalo and item:GetBeefalo() then
                return true
            end
        end)
    end

    local beefalo = bell and bell:GetBeefalo()
    if not beefalo then
        return false, "NEEDBEEF"
    end

    local inrange = act.target:GetDistanceSqToInst(beefalo) < 400
    if not inrange then
        return false, "NEEDBEEF_CLOSER"
    end

    if beefalo:GetIsInMood() then
        return false, "INMOOD"
    end

    beefalo:PushEvent("hitchto", {doer = act.doer, target = act.target})

    if act.doer.components.talker ~= nil then
        act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_CALL_BEEF"))
        act.doer.comment_data = nil
    end

    return true
end

ACTIONS.UNHITCH.fn = function(act)
    if act.doer ~= nil and
        act.target ~= nil and
        act.target.components.hitcher and
        not act.target:HasTag("hitcher") then
            act.target.components.hitcher:Unhitch()
        return true
    end
end

ACTIONS.HITCH.fn = function(act)
    act.doer.hitchingspot = nil
    if act.target:HasTag("hitcher") then
        act.target.components.hitcher:SetHitched(act.doer)
    end
end

ACTIONS.MARK.strfn = function(act)
    if act.target and act.target.components.markable and act.target.components.markable:HasMarked( act.doer ) then
        return "UNMARK"
    end
end

ACTIONS.MARK.fn = function(act)
    local can, fail = nil, nil

    if act.target.components.markable then
        can, fail = act.target.components.markable:Mark(act.doer)
    end
    if not can and act.target.components.markable_proxy then
        can, fail = act.target.components.markable_proxy:Mark(act.doer)
    end

    if can then
        if act.doer.yotb_post_to_mark then
            act.doer.yotb_post_to_mark = nil
        end
        return true
    else
        if fail == "not_participant" then
            return false, "NOT_PARTICIPANT"
        end
        return false, "ALREADY_MARKED"
    end
end

ACTIONS.CHANGEIN.strfn = function(act)
    return act.target ~= nil and act.target:HasTag("dressable") and "DRESSUP" or nil
end

ACTIONS.CHANGEIN.fn = function(act)
    if act.doer ~= nil and
        act.target ~= nil and
        act.target.components.wardrobe ~= nil or act.target.components.groomer ~= nil then

        local component = nil
        if act.target.components.wardrobe then
            component = act.target.components.wardrobe
        end
        if act.target.components.groomer then
            component = act.target.components.groomer
        end

        local success, reason = component:CanBeginChanging(act.doer)
        if not success then
            return false, reason
        end

        --Silent fail for opening wardrobe in the dark
        if CanEntitySeeTarget(act.doer, act.target) then
            component:BeginChanging(act.doer)
        end
        return true
    end
end

ACTIONS.SHAVE.strfn = function(act)
    return (act.target == nil or act.target == act.doer)
        and TheInput:ControllerAttached()
        and "SELF"
        or nil
end

ACTIONS.SHAVE.fn = function(act)
    if act.invobject ~= nil then
        local shavee = act.target or act.doer
        if shavee ~= nil and act.invobject.components.shaver ~= nil then
            if shavee.components.beard ~= nil then
                return shavee.components.beard:Shave(act.doer, act.invobject)
            elseif shavee.components.shaveable ~= nil then
                return shavee.components.shaveable:Shave(act.doer, act.invobject)
            end
        end
    end
end

ACTIONS.PLAY.fn = function(act)
    if act.invobject and act.invobject.components.instrument then
        return act.invobject.components.instrument:Play(act.doer)
    end
end

ACTIONS.POLLINATE.fn = function(act)
    if act.doer.components.pollinator ~= nil then
        if act.target ~= nil then
            return act.doer.components.pollinator:Pollinate(act.target)
        else
            return act.doer.components.pollinator:CreateFlower()
        end
    end
end

ACTIONS.TERRAFORM.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.terraformer ~= nil then
        return act.invobject.components.terraformer:Terraform(act:GetActionPoint(), act.doer)
    end
end

ACTIONS.EXTINGUISH.fn = function(act)
    if act.target.components.burnable ~= nil and act.target.components.burnable:IsBurning() then
        if act.target.components.fueled ~= nil and not act.target.components.fueled:IsEmpty() then
            act.target.components.fueled:ChangeSection(-1)
        else
            act.target.components.burnable:Extinguish()
        end
        return true
    elseif act.target.components.fueled ~= nil and act.target.components.fueled.canbespecialextinguished and not act.target.components.fueled:IsEmpty() then
        act.target.components.fueled:ChangeSection(-1)
    end
end

ACTIONS.LAYEGG.fn = function(act)
    if act.target.components.pickable ~= nil and not act.target.components.pickable.canbepicked then
        return act.target.components.pickable:Regen()
    end
end

ACTIONS.INVESTIGATE.fn = function(act)
    local investigatePos = act.doer.components.knownlocations ~= nil and act.doer.components.knownlocations:GetLocation("investigate") or nil
    if investigatePos ~= nil then
        act.doer.components.knownlocations:RememberLocation("investigate", nil)
        --try to get a nearby target
        if act.doer.components.combat ~= nil then
            act.doer.components.combat:TryRetarget()
        end
        return true
    end
end

ACTIONS.COMMENT.fn = function(act)
    if act.doer.components.talker ~= nil and act.doer.comment_data then
        act.doer.components.talker:Say(act.doer.comment_data.speech)
        act.doer.comment_data = nil
    end
end

ACTIONS.GOHOME.fn = function(act)
    --this is gross. make it better later.
    if act.doer.force_onwenthome_message then
        act.doer:PushEvent("onwenthome")
    end
    if act.target ~= nil then
        if act.target.components.spawner ~= nil then
            return act.target.components.spawner:GoHome(act.doer)
        elseif act.target.components.childspawner ~= nil then
            return act.target.components.childspawner:GoHome(act.doer)
        elseif act.target.components.hideout ~= nil then
            return act.target.components.hideout:GoHome(act.doer)
        end
        act.target:PushEvent("onwenthome", { doer = act.doer })
        act.doer:Remove()
        return true
    elseif act.pos ~= nil then
        act.doer:Remove()
        return true
    end
end

ACTIONS.JUMPIN.strfn = function(act)
    return act.doer ~= nil and act.doer:HasTag("playerghost") and "HAUNT" or nil
end

ACTIONS.JUMPIN.fn = function(act)
    if act.doer ~= nil and
        act.doer.sg ~= nil and
        act.doer.sg.currentstate.name == "jumpin_pre" then
        if act.target ~= nil and
            act.target.components.teleporter ~= nil and
            act.target.components.teleporter:IsActive() then
            act.doer.sg:GoToState("jumpin", { teleporter = act.target })
            return true
        end
        act.doer.sg:GoToState("idle")
    end
end

ACTIONS.TELEPORT.strfn = function(act)
    return act.target ~= nil and "TOWNPORTAL" or nil
end

ACTIONS.TELEPORT.fn = function(act)
    if act.doer ~= nil and act.doer.sg ~= nil then
        local teleporter
        if act.invobject ~= nil then
            if act.doer.sg.currentstate.name == "dolongaction" then
                teleporter = act.invobject
            end
        elseif act.target ~= nil
            and act.doer.sg.currentstate.name == "give" then
            teleporter = act.target
        end
        if teleporter ~= nil and teleporter:HasTag("teleporter") then
            act.doer.sg:GoToState("entertownportal", { teleporter = teleporter })
            return true
        end
    end
end

ACTIONS.RESETMINE.fn = function(act)
    if act.target.components.mine ~= nil then
        act.target.components.mine:Reset()
        return true
    end
end

ACTIONS.ACTIVATE.fn = function(act)
    if act.target.components.activatable ~= nil and (act.target.components.burnable == nil or not (act.target.components.burnable:IsSmoldering() or act.target.components.burnable:IsBurning())) and act.target.components.activatable:CanActivate(act.doer) then
        local success, msg = act.target.components.activatable:DoActivate(act.doer)
        return (success ~= false), msg -- note: for legacy reasons, nil will be true
    end
end

ACTIONS.ACTIVATE.strfn = function(act)
    if act.target.GetActivateVerb ~= nil then
        return act.target:GetActivateVerb(act.doer)
    end
end

ACTIONS.ACTIVATE.stroverridefn = function(act)
    if act.target.OverrideActivateVerb ~= nil then
        return act.target:OverrideActivateVerb(act.doer)
    end
end


ACTIONS.OPEN_CRAFTING.strfn = function(act)
	local target = act.target
	if target ~= nil and PROTOTYPER_DEFS[target.prefab] ~= nil then
		return PROTOTYPER_DEFS[target.prefab].action_str
	end
end

ACTIONS.OPEN_CRAFTING.fn = function(act)
	if act.doer.components.builder ~= nil then
		return act.doer.components.builder:UsePrototyper(act.target)
	end
	return false;
end

ACTIONS.CAST_POCKETWATCH.strfn = function(act)
    if act.invobject ~= nil then
        return FunctionOrValue(act.invobject.GetActionVerb_CAST_POCKETWATCH, act.invobject, act.doer, act.target)
    end
end

ACTIONS.CAST_POCKETWATCH.fn = function(act)
    local caster = act.doer
    if act.invobject ~= nil and caster ~= nil and caster:HasTag("pocketwatchcaster") then
		return act.invobject.components.pocketwatch:CastSpell(caster, act.target, act:GetActionPoint())
	end
end

ACTIONS.HAUNT.fn = function(act)
    if act.target ~= nil and
        act.target:IsValid() and
        not act.target:IsInLimbo() and
        act.target.components.hauntable ~= nil and
        not (act.target.components.inventoryitem ~= nil and act.target.components.inventoryitem:IsHeld()) and
        not (act.target:HasTag("haunted") or act.target:HasTag("catchable")) then
        act.doer:PushEvent("haunt", { target = act.target })
        act.target.components.hauntable:DoHaunt(act.doer)
        return true
    end
end

ACTIONS.MURDER.fn = function(act)
    local murdered = act.invobject or act.target
    if murdered ~= nil and (murdered.components.health ~= nil or murdered.components.murderable ~= nil) then
        local x, y, z = act.doer.Transform:GetWorldPosition()
        murdered.components.inventoryitem:RemoveFromOwner(true)
        murdered.Transform:SetPosition(x, y, z)

        if murdered.components.health ~= nil and murdered.components.health.murdersound ~= nil then
            act.doer.SoundEmitter:PlaySound(FunctionOrValue(murdered.components.health.murdersound, murdered, act.doer))
        elseif murdered.components.murderable ~= nil and murdered.components.murderable.murdersound ~= nil then
            act.doer.SoundEmitter:PlaySound(FunctionOrValue(murdered.components.murderable.murdersound, murdered, act.doer))
        end

        local stacksize = murdered.components.stackable ~= nil and murdered.components.stackable:StackSize() or 1
        if murdered.components.lootdropper ~= nil then
            murdered.causeofdeath = act.doer
            local pos = Vector3(x, y, z)
            for i = 1, stacksize do
                local loots = murdered.components.lootdropper:GenerateLoot()
                for k, v in pairs(loots) do
                    local loot = SpawnPrefab(v)
                    if loot ~= nil then
                        act.doer.components.inventory:GiveItem(loot, nil, pos)
                    end
                end
            end
        end

        if murdered.components.inventory and murdered:HasTag("drop_inventory_onmurder") then
            murdered.components.inventory:TransferInventory(act.doer)
        end

        act.doer:PushEvent("murdered", { victim = murdered, stackmult = stacksize })
        act.doer:PushEvent("killed", { victim = murdered, stackmult = stacksize })
        murdered:Remove()

        return true
    end
end

ACTIONS.HEAL.strfn = function(act)
    return (act.target == nil or act.target == act.doer)
        and TheInput:ControllerAttached()
        and "SELF"
        or nil
end

ACTIONS.HEAL.fn = function(act)
    local target = act.target or act.doer
    if target ~= nil and act.invobject ~= nil and target.components.health ~= nil and not (target.components.health:IsDead() or target:HasTag("playerghost")) then
        if act.invobject.components.healer ~= nil then
            return act.invobject.components.healer:Heal(target)
        elseif act.invobject.components.maxhealer ~= nil then
            return act.invobject.components.maxhealer:Heal(target)
        end
    end
end

ACTIONS.UNLOCK.fn = function(act)
    if act.target.components.lock ~= nil then
        if act.target.components.lock:IsLocked() then
            act.target.components.lock:Unlock(act.invobject, act.doer)
        --else
            --act.target.components.lock:Lock(act.doer)
        end
        return true
    end
end

ACTIONS.USEKLAUSSACKKEY.fn = function(act)
    if act.target.components.klaussacklock ~= nil then
        local able, reason = act.target.components.klaussacklock:UseKey(act.invobject, act.doer)
        if not able then
            return false, reason
        end
        return true
    end
end

ACTIONS.TEACH.strfn = function(act)
	return act.invobject ~= nil and act.invobject.components.mapspotrevealer ~= nil and "READ" or nil
end

ACTIONS.TEACH.fn = function(act)
    if act.invobject ~= nil then
        local target = act.target or act.doer
        if act.invobject.components.teacher ~= nil then
            return act.invobject.components.teacher:Teach(target)
        elseif act.invobject.components.maprecorder ~= nil then
            local success, reason = act.invobject.components.maprecorder:TeachMap(target)
            if success or reason == "BLANK" then
                return true
            end
            return success, reason
		elseif act.invobject.components.mapspotrevealer ~= nil then
			local success, reason = act.invobject.components.mapspotrevealer:RevealMap(act.doer)
			return success, reason
        end
    end
end

ACTIONS.TURNON.fn = function(act)
    local tar = act.target or act.invobject
    if tar and tar.components.machine and not tar.components.machine:IsOn() then
        tar.components.machine:TurnOn(tar)
        return true
    end
end

ACTIONS.TURNOFF.strfn = function(act)
    local tar = act.target
    return tar ~= nil and tar:HasTag("hasemergencymode") and "EMERGENCY" or nil
end

ACTIONS.TURNOFF.fn = function(act)
    local tar = act.target or act.invobject
    if tar and tar.components.machine and tar.components.machine:IsOn() then
        tar.components.machine:TurnOff(tar)
        return true
    end
end

ACTIONS.USEITEM.fn = function(act)
    if act.invobject ~= nil and
        act.invobject.components.useableitem ~= nil and
        act.invobject.components.useableitem:CanInteract() and
        act.doer.components.inventory ~= nil and
        act.doer.components.inventory:IsOpenedBy(act.doer) then
        return act.invobject.components.useableitem:StartUsingItem()
    end
end

ACTIONS.USEITEMON.strfn = function(act)
    return (act.invobject ~= nil and string.upper(act.invobject.prefab))
            or "GENERIC"
end

ACTIONS.USEITEMON.fn = function(act)
    if act.invobject ~= nil and act.target ~= nil
            and act.invobject.components.useabletargeteditem ~= nil
            and act.invobject.components.useabletargeteditem:CanInteract() then
        local success, reason = act.invobject.components.useabletargeteditem:StartUsingItem(act.target, act.doer)
        if success then
            return true
        else
            return success, reason
        end
    end
end

ACTIONS.STOPUSINGITEM.strfn = function(act)
    return (act.invobject ~= nil and string.upper(act.invobject.prefab))
            or "GENERIC"
end

ACTIONS.STOPUSINGITEM.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.useabletargeteditem ~= nil then
        act.invobject.components.useabletargeteditem:StopUsingItem()
        return true
    end
end

ACTIONS.TAKEITEM.fn = function(act)
    --Use this for taking a specific item as opposed to having an item be generated as it is in Pick/ Harvest
    if act.target ~= nil and act.target.components.shelf ~= nil and act.target.components.shelf.cantakeitem then
        act.target.components.shelf:TakeItem(act.doer)
        return true
    end
end

ACTIONS.TAKEITEM.strfn = function(act)
    return act.target.prefab == "birdcage" and "BIRDCAGE" or "GENERIC"
end

ACTIONS.TAKEITEM.stroverridefn = function(act)
	if act.target.prefab == "table_winters_feast" then
		return STRINGS.ACTIONS.TAKEITEM.GENERIC
	end

    local item = act.target.takeitem ~= nil and act.target.takeitem:value() or nil
    return item ~= nil and subfmt(STRINGS.ACTIONS.TAKEITEM.ITEM, { item = item:GetBasicDisplayName() }) or nil
end

ACTIONS.CASTSPELL.strfn = function(act)
    return act.invobject ~= nil and act.invobject.spelltype or nil
end

ACTIONS.CASTSPELL.fn = function(act)
    --For use with magical staffs
    local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	local act_pos = act:GetActionPoint()
    if staff and staff.components.spellcaster and staff.components.spellcaster:CanCast(act.doer, act.target, act_pos) then
        staff.components.spellcaster:CastSpell(act.target, act_pos)
        return true
    end
end

ACTIONS.BLINK.strfn = function(act)
    return act.invobject == nil and act.doer ~= nil and act.doer:HasTag("soulstealer") and "SOUL" or nil
end

ACTIONS.BLINK.fn = function(act)
	local act_pos = act:GetActionPoint()
    if act.invobject ~= nil then
        if act.invobject.components.blinkstaff ~= nil then
            return act.invobject.components.blinkstaff:Blink(act_pos, act.doer)
        end
    elseif act.doer ~= nil
        and act.doer.sg ~= nil
        and act.doer.sg.currentstate.name == "portal_jumpin_pre"
        and act_pos ~= nil
        and act.doer.components.inventory ~= nil
        and act.doer.components.inventory:Has("wortox_soul", 1) then
        act.doer.components.inventory:ConsumeByName("wortox_soul", 1)
        act.doer.sg:GoToState("portal_jumpin", act_pos)
        return true
    end
end

ACTIONS.CASTSUMMON.fn = function(act)
	if act.invobject ~= nil and act.invobject.components.summoningitem and act.doer ~= nil and act.doer.components.ghostlybond ~= nil then
		return act.doer.components.ghostlybond:Summon( act.invobject.components.summoningitem.inst )
	end
end

ACTIONS.CASTUNSUMMON.fn = function(act)
	if act.invobject ~= nil and act.invobject.components.summoningitem and act.doer ~= nil and act.doer.components.ghostlybond ~= nil then
		return act.doer.components.ghostlybond:Recall(false)
	end
end

ACTIONS.COMMUNEWITHSUMMONED.strfn = function(act)
    return act.doer:HasTag("has_aggressive_follower") and "MAKE_DEFENSIVE" or "MAKE_AGGRESSIVE"
end

ACTIONS.COMMUNEWITHSUMMONED.fn = function(act)
	if act.invobject ~= nil and act.invobject.components.summoningitem and act.doer ~= nil and act.doer.components.ghostlybond ~= nil then
		return act.doer.components.ghostlybond:ChangeBehaviour()
	end
end

ACTIONS.COMBINESTACK.fn = function(act)
    local target = act.target
    local invobj = act.invobject
    if invobj and target and invobj.prefab == target.prefab and invobj.skinname == target.skinname and target.components.stackable and not target.components.stackable:IsFull() then
        target.components.stackable:Put(invobj)
        return true
    end
end

ACTIONS.TRAVEL.fn = function(act)
    if act.target and act.target.travel_action_fn then
        act.target.travel_action_fn(act.doer)
        return true
    end
end

ACTIONS.UNPIN.fn = function(act)
    if act.doer ~= act.target and act.target.components.pinnable and act.target.components.pinnable:IsStuck() then
        act.target:PushEvent("unpinned")
        return true
    end
end

ACTIONS.STEALMOLEBAIT.fn = function(act)
    if act.doer ~= nil and act.target ~= nil and act.doer.prefab == "mole" then
        act.target.selectedasmoletarget = nil
        act.target:PushEvent("onstolen", { thief = act.doer })
        return true
    end
end

ACTIONS.MAKEMOLEHILL.fn = function(act)
    if act.doer then
        if act.doer.prefab == "mole" then
        local molehill = SpawnPrefab("molehill")
        molehill.Transform:SetPosition(act.doer.Transform:GetWorldPosition())
        molehill:AdoptChild(act.doer)
        act.doer.needs_home_time = nil
        return true
        elseif act.doer.prefab == "molebat" then
            local molebathill = SpawnPrefab("molebathill")
            molebathill.Transform:SetPosition(act.doer.Transform:GetWorldPosition())
            molebathill:AdoptChild(act.doer)
            return true
    end
end
end

ACTIONS.MOLEPEEK.fn = function(act)
    if act.doer and act.doer.prefab == "mole" then
        act.doer:PushEvent("peek")
        return true
    end
end

ACTIONS.FEED.fn = function(act)
    
    if act.target.components.trader then
        local abletoaccept, reason = act.target.components.trader:AbleToAccept(act.invobject,act.doer)
        if abletoaccept then
            act.target.components.trader:AcceptGift(act.doer, act.invobject, 1)
            return true
        else
            return false, reason
        end

    elseif act.doer ~= nil and act.target ~= nil and act.target.components.eater ~= nil and act.target.components.eater:CanEat(act.invobject) then
        act.target.components.eater:Eat(act.invobject, act.doer)
        local murdered =
            act.target:IsValid() and
            act.target.components.health ~= nil and
            act.target.components.health:IsDead() and
            act.target or nil

        if murdered ~= nil then
            murdered.causeofdeath = act.doer

            local owner = murdered.components.inventoryitem ~= nil and murdered.components.inventoryitem.owner or nil
            if owner ~= nil then
                --In inventory or container:
                --Slightly different from MURDER action since victim ate and died
                --in place, so there should be no looting animation, and the loot
                --should always replace the victim's old slot.
                local grandowner = murdered.components.inventoryitem:GetGrandOwner()
                local x, y, z = grandowner.Transform:GetWorldPosition()
                murdered.components.inventoryitem:RemoveFromOwner(true)
                murdered.Transform:SetPosition(x, y, z)

                if murdered.components.health.murdersound ~= nil and grandowner.SoundEmitter then
                    grandowner.SoundEmitter:PlaySound(FunctionOrValue(murdered.components.health.murdersound, murdered, act.doer))
                end

                if murdered.components.lootdropper ~= nil then
                    local container = owner.components.inventory or owner.components.container
                    if container ~= nil then
                        local stacksize = murdered.components.stackable ~= nil and murdered.components.stackable:StackSize() or 1
                        for i = 1, stacksize do
                            local loots = murdered.components.lootdropper:GenerateLoot()
                            for k, v in pairs(loots) do
                                local loot = SpawnPrefab(v)
                                if loot ~= nil then
                                    container:GiveItem(loot, murdered.prevslot)
                                end
                            end
                        end
                    end
                end
            end

            act.doer:PushEvent("killed", { victim = murdered })

            if owner ~= nil then
                murdered:Remove()
            end
        end
        return true
    end

--[[    local murdered = act.invobject or act.target
    if murdered ~= nil and murdered.components.health ~= nil then
        local x, y, z = act.doer.Transform:GetWorldPosition()
        murdered.components.inventoryitem:RemoveFromOwner(true)
        murdered.Transform:SetPosition(x, y, z)

        if murdered.components.health.murdersound ~= nil and grandowner.SoundEmitter then
            grandowner.SoundEmitter:PlaySound(FunctionOrValue(murdered.components.health.murdersound, murdered, act.doer))
        end

        if murdered.components.lootdropper ~= nil then
            murdered.causeofdeath = act.doer
            local pos = Vector3(x, y, z)
            local stacksize = murdered.components.stackable ~= nil and murdered.components.stackable:StackSize() or 1
            for i = 1, stacksize do
                local loots = murdered.components.lootdropper:GenerateLoot()
                for k, v in pairs(loots) do
                    local loot = SpawnPrefab(v)
                    if loot ~= nil then
                        act.doer.components.inventory:GiveItem(loot, nil, pos)
                    end
                end
            end
        end

        act.doer:PushEvent("killed", { victim = murdered })
        murdered:Remove()

        return true
    end]]
end

ACTIONS.HAIRBALL.fn = function(act)
    if act.doer and act.doer.prefab == "catcoon" then
        return true
    end
end

ACTIONS.CATPLAYGROUND.fn = function(act)
    if act.doer then
        if act.target then
			if act.target.components.cattoy ~= nil then
				act.target.components.cattoy:Play(act.doer, false)
			elseif act.target.components.poppable ~= nil then
				act.target.components.poppable:Pop()
            elseif act.doer.components.combat ~= nil and math.random() < TUNING.CATCOON_ATTACK_CONNECT_CHANCE and act.target.components.health and act.target.components.health.maxhealth <= TUNING.PENGUIN_HEALTH -- Only bother attacking if it's a penguin or weaker
				and act.target.components.combat and act.target.components.combat:CanBeAttacked(act.doer)
				and not (act.doer.components.follower and act.doer.components.follower:IsLeaderSame(act.target))
				and not act.target:HasTag("player") then

                act.doer.components.combat:DoAttack(act.target, nil, nil, nil, 2) --2*25 dmg
            elseif act.doer.components.inventory ~= nil and act.target.components.inventoryitem and act.target.components.inventoryitem.canbepickedup and math.random() < TUNING.CATCOON_PICKUP_ITEM_CHANCE then
			    if act.target.components.bait ~= nil then
					act.target:PushEvent("onstolen", { thief = act.doer })
				elseif act.doer.components.inventory ~= nil then
					act.doer.components.inventory:GiveItem(act.target)
				else
					act.target:Remove()
				end
			elseif act.target.components.activatable ~= nil and act.target.components.activatable:CanActivate(act.doer) and math.random() < TUNING.CATCOON_ACTIVATE_CONNECT_CHANCE then
				act.target.components.activatable:DoActivate(act.doer)
            end
        end
        return true
    end
end

ACTIONS.CATPLAYAIR.fn = function(act)
    if act.doer and act.target then
		if act.target.components.cattoy ~= nil then
			act.target.components.cattoy:Play(act.doer, true)
		elseif act.target.components.poppable ~= nil then
			act.target.components.poppable:Pop()
        elseif act.doer.components.combat ~= nil and act.target and math.random() < TUNING.CATCOON_ATTACK_CONNECT_CHANCE
			and act.target.components.health and act.target.components.health.maxhealth <= TUNING.PENGUIN_HEALTH -- Only bother attacking if it's a penguin or weaker
			and act.target.components.combat and act.target.components.combat:CanBeAttacked(act.doer)
			and not (act.doer.components.follower and act.doer.components.follower:IsLeaderSame(act.target)) then

            act.doer.components.combat:DoAttack(act.target, nil, nil, nil, 2) --2*25 dmg
		elseif act.target.components.activatable ~= nil and act.target.components.activatable:CanActivate(act.doer) and math.random() < TUNING.CATCOON_ACTIVATE_CONNECT_CHANCE then
			local ret, msg = act.target.components.activatable:DoActivate(act.doer)
        end
        act.doer.last_play_air_time = GetTime()
        return true
    end
end

ACTIONS.FAN.fn = function(act)
    if act.invobject ~= nil and act.invobject.components.fan ~= nil then
        return act.invobject.components.fan:Fan(act.target or act.doer)
    end
end

ACTIONS.TOSS.fn = function(act)
    if act.invobject and act.doer then
        if act.invobject.components.complexprojectile and act.doer.components.inventory and (act.invobject.components.equippable == nil or not act.invobject.components.equippable:IsRestricted(act.doer)) then
            local projectile = act.doer.components.inventory:DropItem(act.invobject, false)
            if projectile then
                local pos = nil
                if act.target then
                    pos = act.target:GetPosition()
                    projectile.components.complexprojectile.targetoffset = {x=0,y=1.5,z=0}
                else
                    pos = act:GetActionPoint()
                end
                projectile.components.complexprojectile:Launch(pos, act.doer)
                return true
            end
        end
    end
end

ACTIONS.WATER_TOSS.fn = ACTIONS.TOSS.fn

ACTIONS.UPGRADE.fn = function(act)
    if act.invobject and act.target and 
        act.invobject.components.upgrader and
        act.invobject.components.upgrader:CanUpgrade(act.target, act.doer) and
        act.target.components.upgradeable then

        local can_upgrade, reason = act.target.components.upgradeable:CanUpgrade()
        if can_upgrade then
            return act.target.components.upgradeable:Upgrade(act.invobject, act.doer)
        end

        return false, reason
    end
end

ACTIONS.UPGRADE.strfn = function(act)
    return (act.target ~= nil and act.target:HasTag(UPGRADETYPES.WATERPLANT.."_upgradeable") and "WATERPLANT")
            or nil
end

ACTIONS.NUZZLE.fn = function(act)
    if act.target then
        --print(string.format("%s loves %s!", act.doer.prefab, act.target.prefab))
        return true
    end
end

ACTIONS.WRITE.fn = function(act)
    if act.doer ~= nil and
        act.target ~= nil and
        act.target.components.writeable ~= nil and
        not act.target.components.writeable:IsWritten() then

        if act.target.components.writeable:IsBeingWritten() then
            return false, "INUSE"
        end

        --Silent fail for writing in the dark
        if CanEntitySeeTarget(act.doer, act.target) then
            act.target.components.writeable:BeginWriting(act.doer)
        end
        return true
    end
end

ACTIONS.ATTUNE.fn = function(act)
    if act.doer ~= nil and
        act.target ~= nil and
        act.target.components.attunable ~= nil then
        return act.target.components.attunable:LinkToPlayer(act.doer)
    end
end

ACTIONS.MIGRATE.fn = function(act)
    --fail reasons: "NODESTINATION"
    return act.doer ~= nil
        and act.target ~= nil
        and act.target.components.worldmigrator ~= nil
        and act.target.components.worldmigrator:Activate(act.doer)
end

ACTIONS.REMOTERESURRECT.fn = function(act)
    if act.doer ~= nil and act.doer.components.attuner ~= nil and act.doer:HasTag("playerghost") then
        local target = act.doer.components.attuner:GetAttunedTarget("remoteresurrector")
        if target ~= nil then
            act.doer:PushEvent("respawnfromghost", { source = target })
            return true
        end
    end
end

ACTIONS.REVIVE_CORPSE.fn = function(act)
    if act.doer ~= nil and act.target ~= nil and act.target.components.revivablecorpse ~= nil then
        --Silent fail
        if act.target.components.revivablecorpse:CanBeRevivedBy(act.doer) then
            act.target.components.revivablecorpse:Revive(act.doer)
        end
        return true
    end
end

ACTIONS.MOUNT.fn = function(act)
    if act.target.components.combat ~= nil and act.target.components.combat:HasTarget()
            and (act.target.components.rideable == nil
                or act.target.components.rideable.saddle == nil
                or not act.target.components.rideable.saddle:HasTag("combatmount")) then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.rideable == nil
        or not act.target.components.rideable.canride
        or (act.target.components.health ~= nil and
            act.target.components.health:IsDead())
        or (act.target.components.freezable and
            act.target.components.freezable:IsFrozen())
        or (act.target.components.hitchable ~= nil and
            act.target.components.hitchable:GetHitch() ~= nil)
        or (act.target.hitchingspot ~= nil) then
        return false
    elseif act.target.components.rideable:IsBeingRidden() then
        return false, "INUSE"
    elseif act.target:HasTag("dogrider_only") and act.doer:HasTag("dogrider") and act.target._playerlink ~= act.doer then
        return false
    end

    act.doer.components.rider:Mount(act.target)
    return true
end

ACTIONS.DISMOUNT.fn = function(act)
    if act.doer == act.target and act.doer.components.rider ~= nil and act.doer.components.rider:IsRiding() then
        act.doer.components.rider:Dismount()
        return true
    end
end

ACTIONS.SADDLE.fn = function(act)
    if act.target.components.combat ~= nil and act.target.components.combat:HasTarget() then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.rideable ~= nil then
        --V2C: currently, rideable component implies saddleable always
        act.doer:PushEvent("saddle", { target = act.target })
        act.doer.components.inventory:RemoveItem(act.invobject)
        act.target.components.rideable:SetSaddle(act.doer, act.invobject)
        return true
    end
end

ACTIONS.UNSADDLE.fn = function(act)
    if act.target.components.combat ~= nil and act.target.components.combat:HasTarget() then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.rideable ~= nil then
        --V2C: currently, rideable component implies saddleable always
        act.doer:PushEvent("saddle", { target = act.target })
        act.target.components.rideable:SetSaddle(act.doer, nil)
        return true
    end
end

ACTIONS.BRUSH.fn = function(act)
    if act.target.components.combat ~= nil and act.target.components.combat:HasTarget() then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.brushable ~= nil then
        act.target.components.brushable:Brush(act.doer, act.invobject)
        return true
    end
end

local CRITTER_MUST_TAGS = { "critterlab" }
ACTIONS.ABANDON.fn = function(act)
    if act.doer.components.petleash ~= nil and act.target.components.crittertraits ~= nil then
        if not (act.doer.components.builder ~= nil and act.doer.components.builder.accessible_tech_trees.ORPHANAGE > 0) then
            --we could've been in range but the pet was out of range
            local x, y, z = act.doer.Transform:GetWorldPosition()
            if #TheSim:FindEntities(x, y, z, 10, CRITTER_MUST_TAGS) <= 0 then
                return false
            end
        end
        act.doer.components.petleash:DespawnPet(act.target)
        return true

	elseif act.target.components.follower ~= nil and act.target.components.follower:GetLeader() == act.doer then
		act.target.components.follower:StopFollowing()
		return true
   end
end

ACTIONS.PET.fn = function(act)
    if act.target ~= nil then
		if act.doer.components.petleash ~= nil and act.target.components.crittertraits ~= nil then
			if act.target.components.crittertraits then
				act.target.components.crittertraits:OnPet(act.doer)
			end
		end

		if act.target.components.kitcoon ~= nil then
			act.target:PushEvent("on_petted", {doer = act.doer})
		end
        return true
    end
end

ACTIONS.RETURN_FOLLOWER.fn = function(act)
    if act.target ~= nil and act.target.components.follower ~= nil and act.target.components.follower:GetLeader() == act.doer and act.doer:HasTag("near_kitcoonden") then
		local x, y, z = act.target.Transform:GetWorldPosition()
		local den = TheSim:FindEntities(x, y, z, TUNING.KITCOON_NEAR_DEN_DIST, {"kitcoonden"})[1]
		if den ~= nil then
			den.components.kitcoonden:AddKitcoon(act.target, act.doer)
	        return true
		else
			return false
		end
    end
end

ACTIONS.HIDEANSEEK_FIND.fn = function(act)
    local targ = act.target or act.invobject
	
    if targ ~= nil then
		if targ.components.hideandseekhidingspot ~= nil then
			targ.components.hideandseekhidingspot:SearchHidingSpot(act.doer)
			return true
		end
    end
end

require("components/drawingtool")
ACTIONS.DRAW.stroverridefn = function(act)
    local item = FindEntityToDraw(act.target, act.invobject)
return item ~= nil
        and subfmt(STRINGS.ACTIONS.DRAWITEM, { item = item.drawnameoverride or item:GetBasicDisplayName() })
        or nil
end

ACTIONS.DRAW.fn = function(act)
    if act.invobject ~= nil and
        act.target ~= nil and
        act.invobject.components.drawingtool ~= nil and
        act.target.components.drawable ~= nil and
        act.target.components.drawable:CanDraw() then
        local image, src, atlas, bgimage, bgatlas = act.invobject.components.drawingtool:GetImageToDraw(act.target)
        if image == nil then
            return false, "NOIMAGE"
        end
        act.invobject.components.drawingtool:Draw(act.target, image, src, atlas, bgimage, bgatlas)
        return true
    end
end

ACTIONS.STARTCHANNELING.strfn = function(act)
    return act.target:HasTag("pump") and "PUMP" or nil
end

ACTIONS.STARTCHANNELING.fn = function(act)
    return act.target ~= nil and act.target.components.channelable:StartChanneling(act.doer)
end

ACTIONS.STOPCHANNELING.fn = function(act)
    if act.target ~= nil then
        act.target.components.channelable:StopChanneling(true)
    end
    return true
end

ACTIONS.BUNDLE.fn = function(act)
    local target = act.invobject or act.target
    if target ~= nil and
        act.doer ~= nil and
        act.doer.components.bundler ~= nil and
        act.doer.components.bundler:CanStartBundling() then
        --Silent fail for bundling in the dark
        if CanEntitySeeTarget(act.doer, act.doer) then
            return act.doer.components.bundler:StartBundling(target)
        end
        return true
    end
end

ACTIONS.WRAPBUNDLE.fn = function(act)
    if act.doer ~= nil and
        act.doer.components.bundler ~= nil and
        act.doer.components.bundler:IsBundling(act.target) then
        if act.target.components.container ~= nil and not act.target.components.container:IsEmpty() then
            return act.doer.components.bundler:FinishBundling()
        elseif act.doer.components.talker ~= nil then
            act.doer.components.talker:Say(GetActionFailString(act.doer, "WRAPBUNDLE", "EMPTY"))
        end
        return true
    end
end

ACTIONS.UNWRAP.fn = function(act)
    local target = act.target or act.invobject
    if target ~= nil and
        target.components.unwrappable ~= nil and
        target.components.unwrappable.canbeunwrapped then
        target.components.unwrappable:Unwrap(act.doer)
        return true
    end
end

ACTIONS.BREAK.strfn = function(act)
    local target = act.target or act.invobject
    return target ~= nil and target:HasTag("pickapart") and "PICKAPART" or nil
end

ACTIONS.CONSTRUCT.stroverridefn = function(act)
    if act.invobject ~= nil then
        if act.invobject.constructionname ~= nil and not act.target:HasTag("constructionsite") then
            local name = STRINGS.NAMES[string.upper(act.invobject.constructionname)]
            return name ~= nil and subfmt(STRINGS.ACTIONS.CONSTRUCT.GENERIC_FMT, { name = name }) or nil
        end
    elseif act.target ~= nil and act.target.constructionname ~= nil then
        local name = STRINGS.NAMES[string.upper(act.target.constructionname)]
        return name ~= nil and subfmt(STRINGS.ACTIONS.CONSTRUCT.GENERIC_FMT, { name = name }) or nil
    end
end

ACTIONS.CONSTRUCT.strfn = function(act)
    return act.invobject ~= nil and act.target:HasTag("constructionsite") and "STORE" or nil
end

ACTIONS.CONSTRUCT.fn = function(act)
    local target = act.target
    if target == nil or act.doer == nil or act.doer.components.constructionbuilder == nil then
        return false
    elseif act.doer.components.constructionbuilder:IsConstructingAny() then
        --Silent fail, in case of controller mashing buttons, since we continue to
        --return the construction action after it's initiated once, to prevent the
        --action prompts from flickering.
        return true
    elseif act.doer.components.constructionbuilder:CanStartConstruction() then
        --Silent fail for construction in the dark
        if not CanEntitySeeTarget(act.doer, target) then
            return true
        end

        -- DANY: open sound here.
        if act.doer == ThePlayer then
            act.doer.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
        end

        local item = act.invobject
        local success, reason
        if item ~= nil and item.components.constructionplans ~= nil and target.components.constructionsite == nil then
            target, reason = item.components.constructionplans:StartConstruction(target)
            if target == nil then
                return false, reason
            end
            item:Remove()
            item = nil
        end
        success, reason = act.doer.components.constructionbuilder:StartConstruction(target)
        if not success then
            return false, reason
        end
        --Try to store whatever was on our mouse pointer
        if item ~= nil and item.components.inventoryitem ~= nil and act.doer.components.inventory ~= nil then
            local container = act.doer.components.constructionbuilder.constructioninst
            container = container ~= nil and container.components.container or nil
            if container ~= nil and container:IsOpenedBy(act.doer) then
                local slot
                for i, v in ipairs(CONSTRUCTION_PLANS[target.prefab] or {}) do
                    if v.type == item.prefab then
                        slot = i
                        break
                    end
                end
                if slot ~= nil and container:CanTakeItemInSlot(item, slot) then
                    item = item.components.inventoryitem:RemoveFromOwner(container.acceptsstacks)
                    if item ~= nil and not container:GiveItem(item, slot, nil, false) then
                        if act.doer.components.playercontroller ~= nil and
                            act.doer.components.playercontroller.isclientcontrollerattached then
                            act.doer.components.inventory:GiveItem(item)
                        else
                            act.doer.components.inventory:GiveActiveItem(item)
                        end
                    end
                elseif act.doer.components.talker ~= nil then
                    act.doer.components.talker:Say(GetActionFailString(act.doer, "CONSTRUCT", "NOTALLOWED"))
                end
            end
        end
        return true
    end
end

ACTIONS.STOPCONSTRUCTION.stroverridefn = function(act)
    if act.invobject == nil and act.target ~= nil and act.target.constructionname ~= nil then
        local name = STRINGS.NAMES[string.upper(act.target.constructionname)]
        return name ~= nil and subfmt(STRINGS.ACTIONS.STOPCONSTRUCTION.GENERIC_FMT, { name = name }) or nil
    end
end

ACTIONS.STOPCONSTRUCTION.fn = function(act)
    if act.doer ~= nil and act.doer.components.constructionbuilder ~= nil then
        act.doer.components.constructionbuilder:StopConstruction()

        -- DANY: close sound here.
        if act.doer == ThePlayer then
            act.doer.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
        end

    end
    return true
end

ACTIONS.APPLYCONSTRUCTION.fn = function(act)
    if act.doer ~= nil and
        act.doer.components.constructionbuilder ~= nil and
        act.doer.components.constructionbuilder:IsConstructing(act.target) then
        if act.target.components.container ~= nil and not act.target.components.container:IsEmpty() then
            return act.doer.components.constructionbuilder:FinishConstruction()
        elseif act.doer.components.talker ~= nil then
            act.doer.components.talker:Say(GetActionFailString(act.doer, "CONSTRUCT", "EMPTY"))
        end
        return true
    end
end

ACTIONS.CASTAOE.strfn = function(act)
    return act.invobject ~= nil and string.upper(act.invobject.prefab) or nil
end

ACTIONS.CASTAOE.fn = function(act)
	local act_pos = act:GetActionPoint()
    if act.invobject ~= nil and act.invobject.components.aoespell ~= nil and act.invobject.components.aoespell:CanCast(act.doer, act_pos) then
        act.invobject.components.aoespell:CastSpell(act.doer, act_pos)
        return true
    end
end

ACTIONS.DISMANTLE.fn = function(act)
    if act.target ~= nil and
        act.target.components.portablestructure ~= nil and
        not (act.target.components.burnable ~= nil and act.target.components.burnable:IsBurning()) then

        if act.target.components.container ~= nil then
            if act.target.components.container:IsOpen() then
                return false, "INUSE"
            elseif not act.target.components.container:IsEmpty() or (act.target.components.stewer ~= nil and act.target.components.stewer:IsDone()) then
                return false, "NOTEMPTY"
            elseif not act.target.components.container.canbeopened then
                return false, "COOKING"
            end
        elseif act.target.components.sleepingbag and act.target.components.sleepingbag:InUse() then
            return false, "INUSE"
        end

        if act.target.candismantle and not act.target:candismantle() then
            return false
        end

        act.target.components.portablestructure:Dismantle(act.doer)
        return true
    end
end

ACTIONS.TACKLE.fn = function(act)
    return act.doer ~= nil
        and act.doer.components.tackler ~= nil
        and act.doer.components.tackler:StartTackle()
end

ACTIONS.HALLOWEENMOONMUTATE.fn = function(act)
	if act.invobject ~= nil and act.invobject.components.halloweenpotionmoon ~= nil then
		if act.target == nil
			or (not act.target:HasTag("flying") and not TheWorld.Map:IsPassableAtPoint(act.target.Transform:GetWorldPosition()))
			or (act.target.components.burnable ~= nil and (act.target.components.burnable:IsBurning() or act.target.components.burnable:IsSmoldering()))
			or (act.target.components.freezable ~= nil and act.target.components.freezable:IsFrozen()) then

			return false
		else
			act.invobject.components.halloweenpotionmoon:Use(act.doer, act.target)
			return true
		end
	end
end

ACTIONS.APPLYPRESERVATIVE.strfn = function(act)
	return act.invobject ~= nil and act.invobject.prefab == "saltrock" and "SALT" or nil
end

ACTIONS.APPLYPRESERVATIVE.fn = function(act)
	if act.target ~= nil and act.invobject ~= nil and act.invobject.components.preservative ~= nil
		    and act.target.components.health == nil
		    and (act.target:HasTag("fresh") or act.target:HasTag("stale") or act.target:HasTag("spoiled"))
		    and act.target:HasTag("cookable")
		    and not act.target:HasTag("deployable") then

		act.target.components.perishable:SetPercent(act.target.components.perishable:GetPercent() + (
			    act.invobject.components.preservative.divide_effect_by_stack_size and
                act.target.components.stackable and
                act.invobject.components.preservative.percent_increase / act.target.components.stackable.stacksize or
                act.invobject.components.preservative.percent_increase
			)
        )

		local used_preservative = act.doer.components.inventory:RemoveItem(act.invobject)
        if used_preservative ~= nil then
            used_preservative:Remove()
            return true
        else
			return false
        end
	else
		return false
	end
end

ACTIONS.COMPARE_WEIGHABLE.fn = function(act)
    local weighable = nil

    local equipped = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if equipped ~= nil and equipped:HasTag("heavy") then
        weighable = equipped
    else
        weighable = act.invobject
    end

	if act.target ~= nil and weighable ~= nil and
		act.target.components.trophyscale ~= nil and
		act.target.components.trophyscale.accepts_items and
		not act.target:HasTag("fire") and
		not act.target:HasTag("burnt") then

		return act.target.components.trophyscale:Compare(weighable, act.doer)
	end
	return false
end

ACTIONS.WEIGH_ITEM.fn = function(act)
	if act.target ~= nil and act.invobject ~= nil then
		local weigher = act.target.components.itemweigher and act.target
						or act.invobject.components.itemweigher and act.invobject
						or nil
		local weighable = weigher ~= act.target and act.target or act.invobject

		if weigher and weighable and
			not weigher:HasTag("fire") and
			not weigher:HasTag("burnt") then

			return weigher.components.itemweigher:DoWeighIn(weighable, act.doer)
		end
	end
	return false
end

ACTIONS.START_CARRAT_RACE.fn = function(act)
	if act.target ~= nil and act.target.components.yotc_racestart ~= nil and act.target.components.yotc_racestart:CanInteract() and
		not (act.target:HasTag("fire") or act.target:HasTag("burnt")) then

        local race_data = TheWorld.components.yotc_raceprizemanager ~= nil and TheWorld.components.yotc_raceprizemanager:GetRaceById(act.target) or nil
        if not race_data or (race_data.num_racers == nil or race_data.num_racers == 0) then
            return false, "NO_RACERS"
        end
		act.target.components.yotc_racestart:StartRace()
        if act.doer and act.target.racestartstring then
            act.doer:DoTaskInTime(2,function() if act.target:HasTag("race_on") then act.doer.components.talker:Say(GetString(act.doer, act.target.racestartstring)) end end)
        end
		return true
	end
end

ACTIONS.TILL.fn = function(act)
    if act.invobject ~= nil then
		if act.invobject.components.farmtiller ~= nil then
			return act.invobject.components.farmtiller:Till(act:GetActionPoint(), act.doer)
		elseif act.invobject.components.quagmire_tiller ~= nil then --Quagmire
        return act.invobject.components.quagmire_tiller:Till(act:GetActionPoint(), act.doer)
    end
end
end

ACTIONS.PLANTSOIL.fn = function(act)
    if act.invobject ~= nil and
        act.doer.components.inventory ~= nil and
        act.target ~= nil and act.target:HasTag("soil") then
        local seed = act.doer.components.inventory:RemoveItem(act.invobject)
        if seed ~= nil then
            if seed.components.quagmire_plantable ~= nil then
				if seed.components.quagmire_plantable:Plant(act.target, act.doer) then
                return true
            end
			elseif seed.components.farmplantable ~= nil then
				if seed.components.farmplantable:Plant(act.target, act.doer) then
					return true
				end
            end
            act.doer.components.inventory:GiveItem(seed)
        end
    end
end

ACTIONS.INSTALL.fn = function(act)
    if act.invobject ~= nil and act.target ~= nil then
        if act.invobject.components.quagmire_installable ~= nil and
            act.invobject.components.quagmire_installable.installprefab ~= nil and
            act.target.components.quagmire_installations ~= nil and
            act.target.components.quagmire_installations:IsEnabled() then
            local part = SpawnPrefab(act.invobject.components.quagmire_installable.installprefab)
            if part ~= nil then
                act.invobject:Remove()
                act.target.components.quagmire_installations:Install(part)
                return true
            end
        elseif act.invobject.components.quagmire_saltextractor ~= nil
            and act.target.components.quagmire_saltpond ~= nil
            and act.invobject.components.quagmire_saltextractor:DoInstall(act.target) then
            act.invobject:Remove()
            return true
        end
    end
end

ACTIONS.TAPTREE.fn = function(act)
    if act.target ~= nil and  act.target.components.quagmire_tappable ~= nil then
        if act.target.components.quagmire_tappable:IsTapped() then
            act.target.components.quagmire_tappable:UninstallTap(act.doer)
            return true
        elseif act.invobject ~= nil and act.invobject.components.quagmire_tapper ~= nil then
            act.target.components.quagmire_tappable:InstallTap(act.doer, act.invobject)
            return true
        end
    end
end

ACTIONS.TAPTREE.strfn = function(act)
    return not act.target:HasTag("tappable") and "UNTAP" or nil
end

ACTIONS.SLAUGHTER.stroverridefn = function(act)
    return act.invobject ~= nil
        and act.invobject.GetSlaughterActionString ~= nil
        and act.invobject:GetSlaughterActionString(act.target)
        or nil
end

ACTIONS.SLAUGHTER.fn = function(act)
    if act.invobject.components.quagmire_slaughtertool ~= nil and act.invobject:IsValid() and act.doer:IsValid() then
        if act.target == nil then
            return false, "TOOFAR"
        elseif not (act.target:IsValid() and act.target:HasTag("canbeslaughtered")) then
            return false
        elseif not (act.target:IsInLimbo() or act.doer:IsNear(act.target, 2)) then
            return false, "TOOFAR"
        elseif act.target.components.health ~= nil and not act.target.components.health:IsDead() then
            act.invobject.components.quagmire_slaughtertool:Slaughter(act.doer, act.target)
            return true
        end
    end
end

ACTIONS.REPLATE.stroverridefn = function(act)
    --Quagmire action strings
    local replatable_inst = (act.target ~= nil and act.target:HasTag("quagmire_replatable") and act.target) or (act.invobject ~= nil and act.invobject:HasTag("quagmire_replatable") and act.invobject) or nil
    if replatable_inst ~= nil then
        local i = replatable_inst.prefab:find("_", 15)
        if i ~= nil then
            local dish = STRINGS.NAMES[string.upper(replatable_inst.prefab:sub(1, i - 1))]
            return dish ~= nil and subfmt(STRINGS.ACTIONS.REPLATE.FMT, { dish = dish }) or nil
        end
    end
end

ACTIONS.BATHBOMB.fn = function(act)
    local bathbombable = (act.target ~= nil and act.target.components.bathbombable) or nil
    local bathbomb = (act.invobject ~= nil and act.invobject.components.bathbomb) or nil

	if bathbomb ~= nil and bathbombable ~= nil and bathbombable.can_be_bathbombed then
	    bathbombable:OnBathBombed(act.invobject, act.doer)
		act.doer.components.inventory:RemoveItem(act.invobject):Remove()
		return true
        end
    end

ACTIONS.RAISE_SAIL.fn = function(act)     -- this name is backwards. "raising" in this case means making a full sail
	if act.target ~= nil and act.target.components.mast ~= nil then
		act.target.components.mast:UnfurlSail()
		return true
	end
end

ACTIONS.RAISE_SAIL.stroverridefn = function(act)
    return STRINGS.ACTIONS.RAISE_SAIL
end

ACTIONS.LOWER_SAIL.fn = function(act) -- this name is backwards. "lowering" in this case means wrapping the sail up
    return true
end

ACTIONS.LOWER_SAIL.stroverridefn = function(act)
    return STRINGS.ACTIONS.LOWER_SAIL
end

ACTIONS.LOWER_SAIL_BOOST.fn = function(act)
	if act.target ~= nil and act.target.components.mast ~= nil and act.target.components.mast.is_sail_raised then
        
        local strength = act.doer.components.expertsailor ~= nil and act.doer.components.expertsailor:GetLowerSailStrength() or TUNING.DEFAULT_SAIL_BOOST_STRENGTH

        act.target.components.mast:AddSailFurler(act.doer, strength)

		act.doer:PushEvent("on_lower_sail_boost")
		return true
	end
end

local function GetLowerSailStr(act)
    local doer = act.doer

    local str_idx = 1

    if doer:HasTag("switchtoho") then
        str_idx = 2
    end

    return STRINGS.ACTIONS.LOWER_SAIL_BOOST[str_idx]
end

ACTIONS.LOWER_SAIL_BOOST.stroverridefn = function(act)
    return GetLowerSailStr(act)
end

ACTIONS.LOWER_SAIL_FAIL.fn = function(act)
    return true
end

ACTIONS.LOWER_SAIL_FAIL.stroverridefn = function(act)
    return GetLowerSailStr(act)
end


ACTIONS.RAISE_ANCHOR.fn = function(act)
    return act.target.components.anchor:AddAnchorRaiser(act.doer)
end

ACTIONS.LOWER_ANCHOR.fn = function(act)
    return act.target.components.anchor:StartLoweringAnchor()
end

ACTIONS.MOUNT_PLANK.fn = function(act)
    return act.target.components.walkingplank:MountPlank(act.doer)
end

ACTIONS.DISMOUNT_PLANK.fn = function(act)
    act.target.components.walkingplank:DismountPlank(act.doer)
    return true
end

ACTIONS.ABANDON_SHIP.fn = function(act)
    return act.target.components.walkingplank:AbandonShip(act.doer)
end

ACTIONS.EXTEND_PLANK.fn = function(act)
    act.target.components.walkingplank:Extend()
    return true
end

ACTIONS.RETRACT_PLANK.fn = function(act)
    act.target.components.walkingplank:Retract()
    return true
end

ACTIONS.REPAIR_LEAK.fn = function(act)
    if act.invobject ~= nil and act.target ~= nil and act.target.components.boatleak ~= nil and act.target:HasTag("boat_leak") then
	    return act.target.components.boatleak:Repair(act.doer, act.invobject)
	end
end

ACTIONS.STEER_BOAT.fn = function(act)
	if act.target ~= nil
		and (act.target.components.steeringwheel ~= nil and act.target.components.steeringwheel.sailor == nil)
		and (act.target.components.burnable ~= nil and not act.target.components.burnable:IsBurning())
		and act.doer.components.steeringwheeluser ~= nil then

		act.doer.components.steeringwheeluser:SetSteeringWheel(act.target)
		return true
	end
end

ACTIONS.SET_HEADING.fn = function(act)
	if act.doer.components.steeringwheeluser ~= nil then
		local act_pos = act:GetActionPoint()
	    act.doer.components.steeringwheeluser:Steer(act_pos.x, act_pos.z)
	end
    return true
end

ACTIONS.STOP_STEERING_BOAT.fn = function(act)
	if act.doer.components.steeringwheeluser ~= nil then
	    act.doer.components.steeringwheeluser:SetSteeringWheel(nil)
	end
    return true
end

ACTIONS.CAST_NET.fn = function(act)
    if act.invobject and act.invobject.components.fishingnet then
		local act_pos = act:GetActionPoint()
        if act_pos == nil then
            local pos_x, pos_y, pos_z = act.target.Transform:GetWorldPosition()
            act.invobject.components.fishingnet:CastNet(pos_x, pos_z, act.doer)
        else
            act.invobject.components.fishingnet:CastNet(act_pos.x, act_pos.z, act.doer)
        end
        return true
    end
    return false
end

ACTIONS.GIVE_TACKLESKETCH.fn = function(act)
	if act.invobject and act.target and
		act.target.components.craftingstation ~= nil and
		not act.target:HasTag("burnt") and
		not (act.target.components.burnable and act.target.components.burnable:IsBurning()) then

		if act.target.components.craftingstation:KnowsItem(act.invobject:GetSpecificSketchPrefab()) then
			return false, "DUPLICATE"
		else
			act.invobject.components.tacklesketch:Teach(act.target)
			return true
		end
	end
	return false
end

ACTIONS.REMOVE_FROM_TROPHYSCALE.fn = function(act)
	if not act.target:HasTag("burnt") and
		not act.target:HasTag("fire") and
		act.target.components.trophyscale ~= nil and
		act.target:HasTag("trophycanbetaken") then

		if act.target.components.trophyscale.takeitemtestfn ~= nil then
			local testresult, reason = act.target.components.trophyscale.takeitemtestfn(act.target, act.doer)

			if not testresult then
				return testresult, reason
			else
				return act.target.components.trophyscale:TakeItem(act.doer)
			end
		else
			return act.target.components.trophyscale:TakeItem(act.doer)
		end
	end
end

ACTIONS.CYCLE.strfn = function(act)
    return (act.target ~= nil and act.target:HasTag("singingshell") and "TUNE")
        or nil
end

ACTIONS.CYCLE.fn = function(act)
	local tar = act.target
	if tar.components.cyclable ~= nil then
		if tar.components.cyclable.cancycle then
			tar.components.cyclable:Cycle(act.doer)
			return true
		else
			return false
		end
	end
end

ACTIONS.OCEAN_TOSS.fn = function(act)
    if act.invobject and act.doer then
        if act.invobject.components.oceanthrowable and act.doer.components.inventory then
            local projectile = act.doer.components.inventory:DropItem(act.invobject, false)
            if projectile then
                projectile.components.oceanthrowable:AddProjectile()
                local pos = nil
                if act.target then
                    pos = act.target:GetPosition()
                    projectile.components.complexprojectile.targetoffset = {x=0,y=1.5,z=0}
                else
                    pos = act:GetActionPoint()
                end
                projectile.components.complexprojectile:Launch(pos, act.doer)
                return true
            end
        end
    end
end

ACTIONS.WINTERSFEAST_FEAST.fn = function(act)
	return true
	-- Logic is handled from stategraph; action is never actually performed
end

ACTIONS.BEGIN_QUEST.fn = function(act)
    if act.target.components.questowner ~= nil and act.target.components.questowner:CanBeginQuest(act.doer) then
        local success, message = act.target.components.questowner:BeginQuest(act.doer)
        return (success ~= false), message
    end
end

ACTIONS.ABANDON_QUEST.fn = function(act)
    if act.target.components.questowner ~= nil and act.target.components.questowner:CanAbandonQuest(act.doer) then
        local success, message = act.target.components.questowner:AbandonQuest(act.doer)
        return (success ~= false), message
    end
end

ACTIONS.SING.fn = function(act)
    local singinginspiration = act.doer.components.singinginspiration
    if act.invobject and singinginspiration ~= nil then

        local songdata = act.invobject.songdata
        if songdata ~= nil then

            if singinginspiration:IsSongActive(songdata) then --we need this test incase the client asks to do this action due to lag.
                return true
            end

            if singinginspiration:CanAddSong(songdata) then
                act.invobject.components.singable:Sing(act.doer)
            end
        end

        return true
    end

    return false
end

ACTIONS.SING_FAIL.fn = function(act)
    return true
end

ACTIONS.SING_FAIL.stroverridefn = function(act)
    return STRINGS.ACTIONS.SING
end

ACTIONS.REPLATE.fn = function(act)
    if act.target ~= nil and act.invobject ~= nil then
        local replater = act.target.components.quagmire_replater or act.invobject.components.quagmire_replater
        local replatable = act.target.components.quagmire_replatable or act.invobject.components.quagmire_replatable
        if replater ~= nil and replatable ~= nil and replater ~= replatable then
            if replater.basedish ~= replatable.basedish then
                return false, "MISMATCH"
            elseif replater.dishtype == replatable.dishtype then
                return false, "SAMEDISH"
            end

            local dishtype = replater.dishtype
            local owner = replatable.inst.components.inventoryitem:GetGrandOwner()
            if owner ~= nil then
                local inventory = owner.components.inventory or owner.components.container
                local replater_owner = replater.inst.components.inventoryitem.owner
                if replater_owner == nil then
                    --new plate on the ground
                    inventory:DropItem(replatable.inst, true, false, replater.inst:GetPosition())
                    replater.inst:Remove()
                    replatable:Replate(dishtype, nil, act.doer)
                elseif replatable.inst == act.invobject then
                    --new plate in inventory
                    --spawn new entity so UI animates on clients
                    local replater_container = replater_owner.components.inventory or replater_owner.components.container
                    local replater_slot = replater_container:GetItemSlot(replater.inst)
                    local prefab = replatable.inst.prefab
                    local perish = replatable.inst.components.perishable ~= nil and replatable.inst.components.perishable:GetPercent() or nil
                    local salted = replatable.inst:HasTag("quagmire_salted")
                    replatable.inst:Remove()
                    replater.inst:Remove()
                    local newitem = SpawnPrefab(prefab)
                    if perish ~= nil then
                        newitem.components.perishable:SetPercent(perish)
                    end
                    if salted then
                        newitem.components.quagmire_saltable:Salt(0, true)
                    end
                    newitem.components.quagmire_replatable:Replate(dishtype, true, act.doer)
                    replater_container:GiveItem(newitem, replater_slot, replater_owner:GetPosition())
                else
                    --food plate in inventory
                    --spawn new entity so UI animates on clients
                    local slot = inventory:GetItemSlot(replatable.inst)
                    local prefab = replatable.inst.prefab
                    local perish = replatable.inst.components.perishable ~= nil and replatable.inst.components.perishable:GetPercent() or nil
                    local salted = replatable.inst:HasTag("quagmire_salted")
                    replatable.inst:Remove()
                    replater.inst:Remove()
                    local newitem = SpawnPrefab(prefab)
                    if perish ~= nil then
                        newitem.components.perishable:SetPercent(perish)
                    end
                    if salted then
                        newitem.components.quagmire_saltable:Salt(0, true)
                    end
                    newitem.components.quagmire_replatable:Replate(dishtype, true, act.doer)
                    inventory:GiveItem(newitem, slot, owner:GetPosition())
                end
            else
                --food plate on the ground
                replater.inst:Remove()
                replatable:Replate(dishtype)
            end
            return true
        end
    end
end

ACTIONS.SALT.fn = function(act)
    if act.target ~= nil and act.target.components.quagmire_saltable ~= nil then
        if act.invobject.components.stackable ~= nil then
            act.invobject.components.stackable:Get():Remove()
        else
            act.invobject:Remove()
        end

        local owner = act.target.components.inventoryitem:GetGrandOwner()
        if owner ~= nil then
            --food plate in inventory
            --spawn new entity so UI animates on clients
            local inventory = owner.components.inventory or owner.components.container
            local slot = inventory:GetItemSlot(act.target)
            local prefab = act.target.prefab
            local perish = act.target.components.perishable ~= nil and act.target.components.perishable:GetPercent() or nil
            local replated = act.target.components.quagmire_replatable ~= nil and act.target.components.quagmire_replatable.dishtype or nil
            act.target:Remove()
            local newitem = SpawnPrefab(prefab)
            if perish ~= nil then
                newitem.components.perishable:SetPercent(perish)
            end
            if replated ~= nil then
                newitem.components.quagmire_replatable:Replate(replated, true)
            end
            newitem.components.quagmire_saltable:Salt(1, true)
            inventory:GiveItem(newitem, slot, owner:GetPosition())
        else
            --food plate on the ground
            act.target.components.quagmire_saltable:Salt(1)
        end
        return true
    end
end

ACTIONS.UNPATCH.fn = function(act)
    if act.target ~= nil and act.target.components.boatleak ~= nil then

        if act.target.components.lootdropper then
            local build = act.target.AnimState:GetBuild()

            local prefab = "boatpatch"
            if build == "boat_repair_tape_build" then
                prefab = "sewing_tape"
            end
            local patch = SpawnPrefab(prefab)

            if patch.components.repairer and patch.components.repairer.healthrepairvalue then
                local boat = act.target:GetCurrentPlatform()
                if boat.components.health ~= nil then
                    boat.components.health:DoDelta(-patch.components.repairer.healthrepairvalue)
                end
            end

            act.target.components.lootdropper:FlingItem(patch)

            act.target.components.boatleak:SetState("small_leak")
        end
        return true
    end
end

ACTIONS.POUR_WATER.fn = function(act)
    if act.invobject ~= nil and act.invobject:IsValid() then
        if act.invobject.components.finiteuses ~= nil and act.invobject.components.finiteuses:GetUses() <= 0 then
			return false, (act.invobject:HasTag("wateringcan") and "OUT_OF_WATER" or nil)
        end

        if act.target ~= nil and act.target:IsValid() then
			act.invobject.components.wateryprotection:SpreadProtection(act.target)
        else
			act.invobject.components.wateryprotection:SpreadProtectionAtPoint(act:GetActionPoint():Get())
        end

        return true
    end
end

ACTIONS.POUR_WATER.strfn = function(act)
    return (act.target:HasTag("fire") or act.target:HasTag("smolder")) and "EXTINGUISH" or nil
end

ACTIONS.POUR_WATER_GROUNDTILE.fn = ACTIONS.POUR_WATER.fn
ACTIONS.POUR_WATER_GROUNDTILE.stroverridefn = function(act)
    return STRINGS.ACTIONS.POUR_WATER.GENERIC
end

ACTIONS.PLANTREGISTRY_RESEARCH_FAIL.fn = function(act)
    local targ = act.target or act.invobject

    if targ and targ:HasTag("fertilizerresearchable") then
        return false, "FERTILIZER"
    end

    return false
end

ACTIONS.PLANTREGISTRY_RESEARCH.fn = function(act)
    local targ = act.target or act.invobject

    if targ ~= nil then
        if targ.components.plantresearchable then
            if targ.components.plantresearchable:IsRandomSeed() then
                if act.doer.components.talker then
                    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_PLANT_RANDOMSEED"), nil, targ.components.inspectable.noanim)
                end
            else
                targ.components.plantresearchable:LearnPlant(act.doer)

                if act.doer.components.talker then
                    act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_PLANT_RESEARCHED"), nil, targ.components.inspectable.noanim)
                end
            end
        elseif targ.components.fertilizerresearchable then
            targ.components.fertilizerresearchable:LearnFertilizer(act.doer)

            if act.doer.components.talker then
                act.doer.components.talker:Say(GetString(act.doer, "ANNOUNCE_FERTILIZER_RESEARCHED"), nil, targ.components.inspectable.noanim)
        end
        end
        return true
    end
end

ACTIONS.ASSESSPLANTHAPPINESS.stroverridefn = function(act)
    local targ = act.target or act.invobject
    if targ then
        local plant = targ:GetDisplayName()
        return plant ~= nil and subfmt(STRINGS.ACTIONS.ASSESSPLANTHAPPINESS.GENERIC_FMT, { plant = plant }) or nil
    end
end

ACTIONS.ASSESSPLANTHAPPINESS.fn = function(act)
    local targ = act.target or act.invobject

    if targ ~= nil then
        local desc
        if targ.components.farmplantstress then
            desc = targ.components.farmplantstress:GetStressDescription(act.doer)
        else
            desc = GetString(act.doer, "DESCRIBE_PLANTHAPPY")
        end
        if desc and act.doer.components.talker then
            act.doer.components.talker:Say(desc, nil, targ.components.inspectable.noanim)
        end
        return true
    end
end

local WEIGHTED_SEED_TABLE = require("prefabs/weed_defs").weighted_seed_table
ACTIONS.PLANTWEED.fn = function(act)
    local targ = act.target or act.invobject

    if targ and targ:HasTag("soil") then
        local x, y, z = targ.Transform:GetWorldPosition()
        local new_weed = SpawnPrefab(weighted_random_choice(WEIGHTED_SEED_TABLE))
        new_weed.Transform:SetPosition(x, y, z)

        if new_weed.SoundEmitter ~= nil then
            new_weed.SoundEmitter:PlaySound("dontstarve/common/plant")
        end

        new_weed:PushEvent("on_planted", {in_soil = true, doer = act.doer})

        targ:Remove()
        return true
    end
end

ACTIONS.ADDCOMPOSTABLE.fn = function(act)
    if act.target ~= nil and act.target.components.compostingbin ~= nil then
        return act.target.components.compostingbin:AddCompostable(act.invobject)
    end
end


ACTIONS.WAX.fn = function(act)
    if act.target.components.waxable then
        return act.target.components.waxable:Wax(act.doer, act.invobject)
    end
end

ACTIONS.UNLOAD_WINCH.fn = function(act)
    if act.target.components.winch ~= nil and act.target.components.winch.unloadfn ~= nil then
        return act.target.components.winch.unloadfn(act.target)
    end
end

ACTIONS.USE_HEAVY_OBSTACLE.strfn = function(act)
	return act.target.use_heavy_obstacle_string_key
end

ACTIONS.USE_HEAVY_OBSTACLE.fn = function(act)
    local heavy_item = act.doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

    if heavy_item == nil or not act.target:HasTag("can_use_heavy")
        or (act.target.use_heavy_obstacle_action_filter ~= nil and not act.target.use_heavy_obstacle_action_filter(act.target, act.doer, heavy_item)) then

        return false
    end
    
    if heavy_item ~= nil and act.target ~= nil and act.target.components.heavyobstacleusetarget ~= nil then
        return act.target.components.heavyobstacleusetarget:UseHeavyObstacle(act.doer, heavy_item)
    end
end

ACTIONS.YOTB_SEW.fn = function(act)
    if act.target:HasTag("sewingmachine") then
        if act.target.components.yotb_sewer:IsSewing() then
            --Already sewing
            return true
        end

        local container = act.target.components.container
        if container ~= nil and container:IsOpen() and not container:IsOpenedBy(act.doer) then
            return false, "INUSE"
        elseif not act.target.components.yotb_sewer:CanSew() then
            return false
        end

        act.target.components.yotb_sewer:StartSewing(act.doer)
        return true
    end
end

ACTIONS.YOTB_STARTCONTEST.fn = function(act)
    if not TheWorld.components.yotb_stagemanager then
        return false, "DOESNTWORK"
    elseif TheWorld.components.yotb_stagemanager:IsContestActive() then
        return false, "ALREADYACTIVE"
    end

    act.target.components.yotb_stager:StartContest(act.doer)
    return true
end

ACTIONS.YOTB_UNLOCKSKIN.fn = function(act)
    if act.invobject and act.invobject.components.yotb_skinunlocker and
       act.doer and act.doer.YOTB_unlockskinset ~= nil and act.doer.YOTB_issetunlocked ~= nil then

        local skin = act.invobject.components.yotb_skinunlocker:GetSkin()

        if act.invobject.makedoll then
            act.invobject:makedoll(act.invobject,act.doer)
        end

        if act.doer:YOTB_issetunlocked(skin) then
            act.invobject:Remove()
            return false, "ALREADYKNOWN"
        else
            act.doer:YOTB_unlockskinset(skin)
            act.invobject:Remove()
            return true
        end
    end 
end

ACTIONS.MUTATE_SPIDER.fn = function(act)
    if act.invobject.components.spidermutator:CanMutate(act.target) then
        act.invobject.components.spidermutator:Mutate(act.target, false, act.doer)
        return true
    else
        return false, "SAMETYPE"
    end
end

ACTIONS.HERD_FOLLOWERS.fn = function (act)
    local can_herd, reason = act.invobject.components.followerherder:CanHerd(act.doer)
    if not can_herd then
        return false, reason
    end

    act.invobject.components.followerherder:Herd(act.doer)
    return true
end

ACTIONS.BEDAZZLE.fn = function (act)
    local can_bedazzle, reason = act.invobject.components.bedazzler:CanBedazzle(act.target)
    if not can_bedazzle then
        return false, reason
    end

    act.invobject.components.bedazzler:Bedazzle(act.target)
    return true
end

ACTIONS.REPEL.fn = function(act)
    if act.invobject.components.repellent then
        act.invobject.components.repellent:Repel(act.doer)
        return true
    end

    return false
end

ACTIONS.ADVANCE_TREE_GROWTH.fn = function(act)
    if act.target ~= nil and act.invobject.components.treegrowthsolution then
        return act.invobject.components.treegrowthsolution:GrowTarget(act.target)
    end

    return false
end

ACTIONS.DISMANTLE_POCKETWATCH.fn = function(act)
    local can_dismantle, reason = act.invobject.components.pocketwatch_dismantler:CanDismantle(act.target, act.doer)
    if can_dismantle then
        act.invobject.components.pocketwatch_dismantler:Dismantle(act.target, act.doer)
    end

    return can_dismantle, reason
end



ACTIONS.STOP_LIFT_DUMBBELL.fn = function(act)
    act.doer:PushEvent("stopliftingdumbbell")
end

ACTIONS.LIFT_DUMBBELL.fn = function(act)
    if act.doer ~= nil and act.invobject ~= nil then
        
        local dumbbell = act.invobject
        local lifter = act.doer.components.dumbbelllifter

        if lifter~= nil and dumbbell ~= nil then
            local can_lift, reason = lifter:CanLift(dumbbell)
            if not can_lift then
                return false, reason
            end
            
            lifter:StartLifting(dumbbell)
            return true
        end
    end

    return false
end

ACTIONS.ENTER_GYM.fn = function(act)
    if act.doer ~= nil and act.target ~= nil and act.target.components.mightygym then
        local gym = act.target.components.mightygym
        local can_workout, reason = gym:CanWorkout(act.doer)
        if can_workout then
            gym:CharacterEnterGym(act.doer)
            return true
		end
        return false, reason
    end
    return false
end

ACTIONS.LIFT_GYM_FAIL.pre_action_cb = function(act)
    if act.doer and act.doer.bell  then
        act.doer.bell:ding("fail")
    end

    if not TheNet:IsDedicated() then 
        act.doer:PushEvent("lift_gym",{result = "fail"})
    end
end

ACTIONS.LIFT_GYM_FAIL.fn = function(act)
    return true
end

ACTIONS.LIFT_GYM_SUCCEED_PERFECT.pre_action_cb = function(act)
    if act.doer and act.doer.bell  then
        act.doer.bell:ding("perfect")
    end
end

ACTIONS.LIFT_GYM_SUCCEED_PERFECT.fn = function(act)
    return true
end

ACTIONS.LIFT_GYM_SUCCEED.pre_action_cb = function(act)
    if act.doer and act.doer.bell  then
        act.doer.bell:ding("succeed")
    end
end

ACTIONS.LIFT_GYM_SUCCEED.fn = function(act)
    return true
end

ACTIONS.LEAVE_GYM.fn = function(act)
    local gym = act.doer.components.strongman.gym
	if gym ~= nil then
		gym.components.mightygym:CharacterExitGym(act.doer)
		return true
	end
end

ACTIONS.UNLOAD_GYM.fn = function(act)
    if act.target then
        act.target.components.mightygym:UnloadWeight()
        return true
    end
end

ACTIONS.APPLYMODULE.fn = function(act)
    if (act.invobject ~= nil and act.invobject.components.upgrademodule ~= nil)
            and (act.doer ~= nil and act.doer.components.upgrademoduleowner ~= nil) then

        local can_upgrade, reason = act.doer.components.upgrademoduleowner:CanUpgrade(act.invobject)

        if can_upgrade then
            local individual_module = act.invobject.components.inventoryitem:RemoveFromOwner()
            act.doer.components.upgrademoduleowner:PushModule(individual_module)
            return true
        else
            return false, reason
        end
    end

    return false
end

ACTIONS.APPLYMODULE_FAIL.fn = function(act)
    return true
end

ACTIONS.APPLYMODULE_FAIL.stroverridefn = function(act)
    return STRINGS.ACTIONS.APPLYMODULE
end

ACTIONS.REMOVEMODULES.fn = function(act)
    if (act.invobject ~= nil and act.invobject.components.upgrademoduleremover ~= nil)
            and (act.doer ~= nil and act.doer.components.upgrademoduleowner ~= nil) then
        if act.doer.components.upgrademoduleowner:NumModules() > 0 then
            
            local energy_cost = act.doer.components.upgrademoduleowner:PopOneModule()
            if energy_cost ~= 0 then
                act.doer.components.upgrademoduleowner:AddCharge(-energy_cost)
            end

            return true
        else
            return false, "NO_MODULES"
        end
    end

    return false
end

ACTIONS.REMOVEMODULES_FAIL.fn = function(act)
    return true
end

ACTIONS.REMOVEMODULES_FAIL.stroverridefn = function(act)
    return STRINGS.ACTIONS.REMOVEMODULES
end

ACTIONS.CHARGE_FROM.fn = function(act)
    if (act.target ~= nil and act.target.components.battery ~= nil) and
            (act.doer ~= nil and act.doer.components.batteryuser ~= nil) then
        return act.doer.components.batteryuser:ChargeFrom(act.target)
    else
        return false
    end
end
