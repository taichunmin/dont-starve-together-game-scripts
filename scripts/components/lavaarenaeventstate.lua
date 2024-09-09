--------------------------------------------------------------------------
--[[ LavaarenaEventState class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local VictoryStateEnum =
{
    Playing = 0,
    Victory = 1,
    Defeat = 2,
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim

--Network vars. These are for the client to query, the server should not use this data
local _netvars =
{
    round = net_smallbyte(inst.GUID, "lavaarenaeventstate._netvars.round", "rounddirty"),
    victorystate = net_tinybyte(inst.GUID, "lavaarenaeventstate._netvars.victorystate", "victorystatedirty"),

	progression_json = net_string(inst.GUID, "lavaarenaeventstate._netvars.progression_json", "progressionjsondirty"),
	player_quest_json = {}
}
for i = 1, TheNet:GetServerMaxPlayers() do
	_netvars.player_quest_json[i] = net_string(inst.GUID, "lavaarenaeventstate._netvars.player_quest_json"..i, "playerquestjsondirty_"..i)
end

--------------------------------------------------------------------------
--[[ Public Methods ]]
--------------------------------------------------------------------------

function self:GetServerProgressionJson()
	return _netvars.progression_json:value()
end

function self:GetCurrentRound()
	return math.max(1, _netvars.round:value())
end

function self:GetServerPlayerQuestJson(quest_slot)
	return _netvars.player_quest_json[quest_slot]:value()
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnVictoryStateDirty()
    if _netvars.victorystate:value() > 0 and not TheNet:IsDedicated() and ThePlayer ~= nil and ThePlayer:IsValid() then
        _world:PushEvent("endofmatch", { victory = _netvars.victorystate:value() == VictoryStateEnum.Victory })
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

inst:ListenForEvent("victorystatedirty", OnVictoryStateDirty)
inst:ListenForEvent("playeractivated", OnVictoryStateDirty, _world)

if _world.ismastersim then
    event_server_data("lavaarena", "components/lavaarenaeventstate").master_postinit(self, inst, _netvars, VictoryStateEnum)
end

Lavaarena_CommunityProgression:RegisterForWorld()

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local str = "?" -- string.format("Community Progress: %d, %0.3f", self:GetLevelAndPercent())
    return str
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
