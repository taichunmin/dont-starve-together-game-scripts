
require "behaviours/faceentity"
require "behaviours/wander"
require "behaviours/approach"
require "behaviours/leash"

local CarnivalHostBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local GIVE_PLAZAKIT_DIST = 15
local GIVE_PLAZAKIT_GIVE_DIST = 4
local MAX_LEASH_DIST = 20
local INNER_LEASH_DIST = 15
local MAX_WANDER_DIST = 15

local function GetFaceTargetFn(inst)
    return inst.components.prototyper ~= nil
        and next(inst.components.prototyper.doers)
        or nil
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.prototyper ~= nil and inst.components.prototyper.doers[target] ~= nil
end

local function GetHomePos(inst)
    return inst.components.knownlocations:GetLocation("home")
end

local function GetWanderLines(inst)
	return STRINGS.CARNIVAL_HOST_ANNOUNCE_GENERIC[math.random(#STRINGS.CARNIVAL_HOST_ANNOUNCE_GENERIC)]
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
	if minigame then
		local lines = minigame._minigame_score > 0 and STRINGS.CARNIVAL_HOST_GAME_END_CHEER or STRINGS.CARNIVAL_HOST_GAME_END_BORED
		inst.components.talker:Say(lines[math.random(#lines)])

		for i = 1, math.ceil(minigame._minigame_score / 5) do
			inst:DoTaskInTime(i * 0.2 + math.random() * 0.1, DoTossReward)
		end
	end
end

local function GetWatchingMinigameLines(inst)
	local minigame = inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator:GetMinigame()
	if minigame ~= nil then
		local lines = (minigame.components.minigame:IsExciting() or minigame.components.minigame:GetIsIntro())and STRINGS.CARNIVAL_HOST_GAME_CHEER or STRINGS.CARNIVAL_HOST_GAME_BORED
		return lines[math.random(#lines)]
	end
end

local function GetMinigameOutroGameLines(inst)
	local minigame = inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator:GetMinigame() or nil
	local lines = (minigame ~= nil and minigame._minigame_score > 0) and STRINGS.CARNIVAL_HOST_GAME_END_CHEER
					or STRINGS.CARNIVAL_HOST_GAME_END_BORED
	return lines[math.random(#lines)]
end

function CarnivalHostBrain:OnStart()
	local watch_game = WhileNode( function() return WatchingMinigame(self.inst) end, "Watching Game",
        PriorityNode({
			IfNode(function() return WatchingMinigame(self.inst).components.minigame.gametype == "carnivalgame" end, "Is Carnival Game",
				PriorityNode({
					IfNode(function() return IsWatchingMinigameOutro(self.inst) end, "Is Outro",
						SequenceNode({
							ActionNode(function() OnEndOfGame(self.inst) end, "TossRward"),
							FaceEntity(self.inst, WatchingMinigame, WatchingMinigame ),
							})),
					ChattyNode(self.inst, GetWatchingMinigameLines,
						PriorityNode({
							RunAway(self.inst, "minigame_participator", 5, 7),
							Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist),
							FaceEntity(self.inst, WatchingMinigame, WatchingMinigame ),
						}, 0.1), 5, 10),

				}, 0.1)
			),
			PriorityNode({
				IfNode(function() return IsWatchingMinigameIntro(self.inst) end, "Is Intro",
					PriorityNode({
						Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist),
						RunAway(self.inst, "minigame_participator", 5, 7),
						FaceEntity(self.inst, WatchingMinigame, IsWatchingMinigameIntro),
					}, 0.1)),
				ChattyNode(self.inst, "CARNIVAL_HOST_OTHERGAME_TALK",
					PriorityNode({
						RunAway(self.inst, "minigame_participator", 5, 7),
						Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist),
						FaceEntity(self.inst, WatchingMinigame, WatchingMinigame ),
					}, 0.1), 5, 10),
			}, 0.1),
        }, 0.1)
	)




    local root = PriorityNode(
    {
		WhileNode(function() return not self.inst.sg:HasStateTag("flight") end, "not flyaway",
			PriorityNode({
				watch_game,
				FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn), -- prototyper activated
				WhileNode(function() return not self.inst.hassold_plaza or not self.inst.hasbeento_plaza end, "no plaza",
					ChattyNode(self.inst, "CARNIVAL_HOST_ANNOUNCE_CARNIVAL",
						Wander(self.inst, GetHomePos, MAX_WANDER_DIST), 5, 10)),
				ChattyNode(self.inst, GetWanderLines,
					Wander(self.inst, GetHomePos, MAX_WANDER_DIST), 15, 30),
		}, .25))
    }, .25)

    self.bt = BT(self.inst, root)
end

return CarnivalHostBrain
