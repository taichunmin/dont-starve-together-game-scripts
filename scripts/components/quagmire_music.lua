--------------------------------------------------------------------------
--[[ QuagmireMusic class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MUSIC =
{
    "dontstarve/quagmire/music/cook_1",
    "dontstarve/quagmire/music/cook_2",
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _soundemitter = nil
local _activatedplayer = nil --cached for activation/deactivation only, NOT for logic use
local _levelplaying = nil

--Network
local _netvars =
{
    level = net_tinybyte(inst.GUID, "lavaarenamusic._netvars.level", "leveldirty"),
    won = net_event(inst.GUID, "lavaarenamusic._netvars.won")
}

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnLevelDirty(inst)
    if _netvars.level:value() ~= _levelplaying then
        _soundemitter:KillSound("bgm")
        local sound = MUSIC[_netvars.level:value()]
        if sound ~= nil then
            _soundemitter:PlaySound(sound, "bgm")
        end
    end
end

local function OnWon(inst)
    _soundemitter:PlaySound("dontstarve/quagmire/music/gorge_win")
end

local function OnPlayerDeactivated(src, player)
    if player == _activatedplayer then
        _activatedplayer = nil
        _soundemitter:KillSound("bgm")
        _soundemitter = nil
        _levelplaying = nil
        inst:RemoveEventCallback("leveldirty", OnLevelDirty)
        inst:RemoveEventCallback("lavaarenamusic._netvars.won", OnWon)
    end
end

local function OnPlayerActivated(src, player)
    if _activatedplayer ~= player then
        if _activatedplayer ~= nil then
            OnPlayerDeactivated(src, _activatedplayer)
        end
        _activatedplayer = player
        _soundemitter = TheFocalPoint.SoundEmitter
        inst:ListenForEvent("leveldirty", OnLevelDirty)
        inst:ListenForEvent("lavaarenamusic._netvars.won", OnWon)
        OnLevelDirty(inst)
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize network variables
_netvars.level:set(1)

--Register events
inst:ListenForEvent("playeractivated", OnPlayerActivated, _world)
inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated, _world)

if _world.ismastersim then
    event_server_data("quagmire", "components/quagmire_music").master_postinit(self, inst, _netvars)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
