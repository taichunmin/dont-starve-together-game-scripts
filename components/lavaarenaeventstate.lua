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

--Network
local _netvars =
{
    victorystate = net_tinybyte(inst.GUID, "lavaarenaeventstate._netvars.victorystate", "victorystatedirty"),
}

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

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
