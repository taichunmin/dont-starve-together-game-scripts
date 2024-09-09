
require "behaviours/standstill"
require "behaviours/chattynode"
require "behaviours/follow"
require "behaviours/runaway"
require "behaviours/faceentity"
require "behaviours/wander"

local MAX_WANDER_DIST = 12

local function HasValidHome(inst)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    return home ~= nil
        and home:IsValid()
        and not (home.components.burnable ~= nil and home.components.burnable:IsBurning())
        and not home:HasTag("burnt")
end

local function GetHomePos(inst)
    return HasValidHome(inst) and inst.components.homeseeker:GetHomePos()
end

local FACE_PLAYER_DISTSQ = 3*3
local function GetFaceTargetFn(inst)
	local player, distsq = inst:GetNearestPlayer(true)
	if distsq ~= nil and distsq <= FACE_PLAYER_DISTSQ and (inst._talktoplayercooldown == nil or inst._talktoplayercooldown < GetTime()) then
		inst._talktoplayercooldown = GetTime() + TUNING.CARNIVAL_CROWKID_TALK_TO_PLAYER_COOLDOWN
		return player
	end
	return nil
end

local function KeepFaceTargetFn(inst, target)
	local player, distsq = inst:GetNearestPlayer(true)
	return player == target and distsq ~= nil and distsq <= FACE_PLAYER_DISTSQ
end

local function IsHomeless(inst)
	inst.ShouldFlyAway = inst.ShouldFlyAway or inst.components.homeseeker == nil
	return inst.ShouldFlyAway
end

local SHOULDFLYAWAY_CANT_TAGS = { "notarget", "INLIMBO" }
local SHOULDFLYAWAY_ONEOF_TAGS = { "hostile" }
local function ShouldFlyAway(inst)
    inst.ShouldFlyAway = inst.ShouldFlyAway
						or (not (inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("flight"))
							and (FindEntity(inst, 8, nil, nil, SHOULDFLYAWAY_CANT_TAGS, SHOULDFLYAWAY_ONEOF_TAGS) ~= nil
								))

	return inst.ShouldFlyAway
end

local function FlyHome(inst)
    return inst.ShouldFlyAway and BufferedAction(inst, nil, ACTIONS.GOHOME) or nil
end

local function GetTalkToPlayerChatterLines(inst)
	local home = (inst:GetTimeAlive() > 5 and inst.components.homeseeker ~= nil) and inst.components.homeseeker.home
	if home then
		local rank = home.components.carnivaldecorranker.rank
		local lines = rank <= 1 and (inst.has_snack and STRINGS.CARNIVAL_CROWKID_DECOR_PLAYER_NONE_SNACK or STRINGS.CARNIVAL_CROWKID_DECOR_PLAYER_NONE)
						or rank == TUNING.CARNIVAL_DECOR_RANK_MAX and (inst.has_snack and STRINGS.CARNIVAL_CROWKID_DECOR_PLAYER_LOTS_SNACK or STRINGS.CARNIVAL_CROWKID_DECOR_PLAYER_LOTS)
						or (inst.has_snack and STRINGS.CARNIVAL_CROWKID_DECOR_PLAYER_SOME_SNACK or STRINGS.CARNIVAL_CROWKID_DECOR_PLAYER_SOME)
		return lines[math.random(#lines)]
	end
end

local function GetAmbientChatterLines(inst)
	local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home
	if home then
		local rank = home.components.carnivaldecorranker ~= nil and home.components.carnivaldecorranker.rank or 0
		local lines = rank <= 1 and (inst.has_snack and STRINGS.CARNIVAL_CROWKID_DECOR_AMBIENT_NONE_SNACK or STRINGS.CARNIVAL_CROWKID_DECOR_AMBIENT_NONE)
						or rank == TUNING.CARNIVAL_DECOR_RANK_MAX and (inst.has_snack and STRINGS.CARNIVAL_CROWKID_DECOR_AMBIENT_LOTS_SNACK or STRINGS.CARNIVAL_CROWKID_DECOR_AMBIENT_LOTS)
						or (inst.has_snack and STRINGS.CARNIVAL_CROWKID_DECOR_AMBIENT_SOME_SNACK or STRINGS.CARNIVAL_CROWKID_DECOR_AMBIENT_SOME)
		return lines[math.random(#lines)]
	end
end

local SEE_DICOR_DIST = 4
local SEE_DICOR_MUST_TAGS = {"inactive", "carnivaldecor" }
--local SEE_DICOR_ONEOF_TAGS = {"carnivalcannon", "carnivallamp", "carnivallamp"}

local function ActivateDecor(inst)
	if inst.components.minigame_spectator ~= nil then
		return
	end

    if inst.next_activate_time == nil then
		inst.next_activate_time = GetTime() + math.random(TUNING.CROWKID_ACTIVATE_DECOR_DELAY_MIN, TUNING.CROWKID_ACTIVATE_DECOR_DELAY_MAX)
		return
	elseif inst.next_activate_time > GetTime() then
		return
	end

	local chain_can_activate_time = GetTime() - TUNING.CROWKID_ACTIVATE_DECOR_CHAIN_DELAY

    local target = (inst._watch_campfire ~= nil and inst._watch_campfire:IsValid() and inst._watch_campfire.components.fueled ~= nil and inst._watch_campfire.components.fueled:GetPercent() <= TUNING.CROWKID_STOKE_FIRE_PRECENT ) and inst._watch_campfire or nil

	target = target or FindEntity(inst,
        SEE_DICOR_DIST,
        function(item)
            return (item._lastchaintime == nil or item._lastchaintime < chain_can_activate_time)
					and item or nil

        end,
        SEE_DICOR_MUST_TAGS
    )

    if target ~= nil then
		inst.next_activate_time = GetTime() + math.random(TUNING.CROWKID_ACTIVATE_DECOR_DELAY_MIN, TUNING.CROWKID_ACTIVATE_DECOR_DELAY_MAX)
		if target == inst._watch_campfire then
		    return BufferedAction(inst, target, ACTIONS.ADDFUEL)
		else
	        return BufferedAction(inst, target, ACTIONS.ACTIVATE)
		end
    end
end

local CAMPFIRE_WANDER_TIMES = { minwaittime = 3 }

local CAMPFIRE_TAGS = {"campfire", "fire"}
local SEE_CAMPFIRE_DIST = 12
local function WatchCampfireFn(inst)
	if not TheWorld.state.isnight then
		inst._watch_campfire = nil
		return false
	end

	if inst._watch_campfire ~= nil then
		if inst._watch_campfire:IsValid() and inst._watch_campfire.components.burnable ~= nil and inst._watch_campfire.components.burnable:IsBurning() then
			return true
		end

		inst._watch_campfire = nil
	end

	local x, y, z = inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(x, y, z, SEE_CAMPFIRE_DIST, CAMPFIRE_TAGS)
	if #targets > 0 then
		inst._watch_campfire = targets[1]
	end

	return inst._watch_campfire ~= nil
end

local function GetCurrentCampfirePos(inst)
    return (inst._watch_campfire ~= nil and inst._watch_campfire:IsValid()) and inst._watch_campfire:GetPosition() or nil
end

local function GetCampfireChatterLines(inst)
	return STRINGS.CARNIVAL_CROWKID_CAMPFIRE[math.random(#STRINGS.CARNIVAL_CROWKID_CAMPFIRE)]
end

--- Minigames
local function WatchingMinigame(inst)
	return inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator:GetMinigame() or nil
end

local function IsWatchingMinigameIntro(inst)
	local minigame = inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator:GetMinigame() or nil
	return minigame ~= nil and minigame.components.minigame:GetIsIntro()
end

local function WatchingMinigame_MinDist(inst)
	return inst.components.minigame_spectator:GetMinigame().components.minigame.watchdist_min
end
local function WatchingMinigame_TargetDist(inst)
	return inst.components.minigame_spectator:GetMinigame().components.minigame.watchdist_target
end
local function WatchingMinigame_MaxDist(inst)
	return inst.components.minigame_spectator:GetMinigame().components.minigame.watchdist_max
end

local function IsWatchingMinigameOutro(inst)
	local minigame = inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator:GetMinigame() or nil
	return minigame ~= nil and minigame.components.minigame:GetIsOutro()
end

local function DoTossReward(inst)
	local minigame = inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator:GetMinigame() or nil
	if minigame ~= nil then
		LaunchAt(SpawnPrefab("carnival_prizeticket"), inst, minigame, 2)
	end
end

local function OnEndOfGame(inst)
	local minigame = inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator:GetMinigame() or nil

	local score = minigame ~= nil and minigame._minigame_score ~= nil and minigame._minigame_score or 0
	inst.components.minigame_spectator._good_ending = score >= (minigame._good_score_value or 6)
	inst:PushEvent("minigame_spectator_start_outro")

	if score >= (minigame._spectator_rewards_score or 16) or (score > 5 and math.random() < 0.25) then 
		inst:DoTaskInTime(0.5 + math.random() * 0.5, DoTossReward)
	end
end


---------------
local CrowKidBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function CrowKidBrain:OnStart()
	local watch_game = WhileNode( function() return WatchingMinigame(self.inst) end, "Watching Game",
        PriorityNode({
			IfNode(function() return WatchingMinigame(self.inst).components.minigame.gametype == "carnivalgame" end, "Is Carnival Game",
				PriorityNode({
					IfNode(function() return IsWatchingMinigameOutro(self.inst) end, "Is Outro",
						SequenceNode({
							ActionNode(function() OnEndOfGame(self.inst) end, "TossRward"),
							FaceEntity(self.inst, WatchingMinigame, WatchingMinigame ),
						}, 0.1)),
					IfNode(function() return IsWatchingMinigameIntro(self.inst) end, "Is Intro",
						PriorityNode({
							ChattyNode(self.inst, "CARNIVAL_CROWKID_GAME_GOTO",
								Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist)),
							RunAway(self.inst, "minigame_participator", 5, 7),
							FaceEntity(self.inst, WatchingMinigame, IsWatchingMinigameIntro),
						}, 0.1)),
					RunAway(self.inst, "minigame_participator", 5, 7),
					Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist),
					FaceEntity(self.inst, WatchingMinigame, WatchingMinigame ),

				}, 0.1)
			),
			PriorityNode({
				IfNode(function() return IsWatchingMinigameIntro(self.inst) end, "Is Intro",
					PriorityNode({
						ChattyNode(self.inst, "CARNIVAL_CROWKID_GAME_GOTO",
							Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist)),
						RunAway(self.inst, "minigame_participator", 5, 7),
						FaceEntity(self.inst, WatchingMinigame, IsWatchingMinigameIntro),
					}, 0.1)),
				RunAway(self.inst, "minigame_participator", 5, 7),
				Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist),
				FaceEntity(self.inst, WatchingMinigame, WatchingMinigame ),
			}, 0.1),
        }, 0.1)
	)



    local root = PriorityNode(
    {
		WhileNode(function() return not self.inst.sg:HasStateTag("flight") end, "not flyaway",
			PriorityNode({
				WhileNode(function() return IsHomeless(self.inst) end, "Go Away",
					DoAction(self.inst, FlyHome)),
				ChattyNode(self.inst, "CARNIVAL_CROWKID_SCARED",
					WhileNode(function() return ShouldFlyAway(self.inst) end, "Go Away",
						DoAction(self.inst, FlyHome))),

				watch_game,

				DoAction(self.inst, ActivateDecor, "ActivateDecor"),

				ChattyNode(self.inst, GetTalkToPlayerChatterLines,
					FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn, 2), 5, 10),

				WhileNode(function() return WatchCampfireFn(self.inst) end, "Campfire",
					ChattyNode(self.inst, GetCampfireChatterLines,
						Wander(self.inst, GetCurrentCampfirePos, TUNING.CARNIVAL_CROWKID_CAMPFIRE_WANDER_DIST, CAMPFIRE_WANDER_TIMES), 10, 20, 10, 10)
				),

				ChattyNode(self.inst, GetAmbientChatterLines,
					Wander(self.inst, GetHomePos, MAX_WANDER_DIST), 20, 20, 5, 10),

				-- fly away if no valid home pos

				StandStill(self.inst),

		}, .25))

    }, .25)

    self.bt = BT(self.inst, root)
end

return CrowKidBrain
