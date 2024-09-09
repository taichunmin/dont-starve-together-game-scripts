--------------------------------------------------------------------------
--[[ Kramped class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Kramped should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local SPAWN_DIST = 30

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _activeplayers = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function GetSpawnPoint(pt)
    if not TheWorld.Map:IsAboveGroundAtPoint(pt:Get()) then
        pt = FindNearbyLand(pt, 1) or pt
    end
    local offset = FindWalkableOffset(pt, math.random() * TWOPI, SPAWN_DIST, 12, true, true, NoHoles)
    if offset ~= nil then
        offset.x = offset.x + pt.x
        offset.z = offset.z + pt.z
        return offset
    end
end

local function MakeAKrampusForPlayer(player)
    local pt = player:GetPosition()
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt ~= nil then
        local kramp = SpawnPrefab("krampus")
        kramp.Physics:Teleport(spawn_pt:Get())
        kramp:FacePoint(pt)
        kramp.spawnedforplayer = player
        kramp:ListenForEvent("onremove", function() kramp.spawnedforplayer = nil end, player)
        return kramp
    end
end

local function OnNaughtyAction(how_naughty, playerdata)
    if playerdata.threshold == nil then
        playerdata.threshold = TUNING.KRAMPUS_THRESHOLD + math.random(TUNING.KRAMPUS_THRESHOLD_VARIANCE)
    end

    playerdata.actions = playerdata.actions + (how_naughty or 1)
    playerdata.timetodecay = TUNING.KRAMPUS_NAUGHTINESS_DECAY_PERIOD

    if playerdata.actions >= playerdata.threshold and playerdata.threshold > 0 then
        playerdata.threshold = TUNING.KRAMPUS_THRESHOLD + math.random(TUNING.KRAMPUS_THRESHOLD_VARIANCE)
        playerdata.actions = 0

        if TUNING.KRAMPUS_INCREASE_RAMP < 1 then -- KAJ 21-3-14:math.random can't be called with < 1. I am assuming that setting "never" in the tuning means to never spawn
            return
        end

        local num_krampii =
            (TheWorld.state.cycles > TUNING.KRAMPUS_INCREASE_LVL2 and 2 + math.random(TUNING.KRAMPUS_INCREASE_RAMP)) or
            (TheWorld.state.cycles > TUNING.KRAMPUS_INCREASE_LVL1 and 1 + math.random(TUNING.KRAMPUS_INCREASE_RAMP)) or
            1

        for i = 1, num_krampii do
            MakeAKrampusForPlayer(playerdata.player)
        end
    else
        self:DoWarningSound(playerdata.player)
    end
end

local function OnKilledOther(player, data)
    if data ~= nil and data.victim ~= nil and data.victim.prefab ~= nil then
        local naughtiness = NAUGHTY_VALUE[data.victim.prefab]
        if naughtiness ~= nil then
            local playerdata = _activeplayers[player]
            if not (data.victim.prefab == "pigman" and
                    data.victim.components.werebeast ~= nil and
                    data.victim.components.werebeast:IsInWereState()) then
                local naughty_val = FunctionOrValue(naughtiness, player, data)
                OnNaughtyAction(naughty_val * (data.stackmult or 1), playerdata)
            end
        end
    end
end

local function GetDebugStringForPlayer(playerdata)
    local playerString = string.format("Player %s - ", tostring(playerdata.player))
    if playerdata.actions and playerdata.threshold and playerdata.timetodecay then
        return playerString..string.format("Actions: %d / %d, decay in %2.2f", playerdata.actions, playerdata.threshold, playerdata.timetodecay)
    else
        return playerString.."Actions: 0"
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerJoined(src, player)
    if _activeplayers[player] ~= nil then
        return
    end
    _activeplayers[player] =
    {
        player = player,
        actions = 0,
        threshold = nil,
        timetodecay = TUNING.KRAMPUS_NAUGHTINESS_DECAY_PERIOD,
    }
    if TUNING.KRAMPUS_THRESHOLD ~= -1 then
        self.inst:ListenForEvent("killed", OnKilledOther, player)
    end
end

local function OnPlayerLeft(src, player)
    if _activeplayers[player] == nil then
        return
    end
    _activeplayers[player] = nil
    self.inst:RemoveEventCallback("killed", OnKilledOther, player)
end

local function OnForceNaughtiness(src, data)
    if data.player ~= nil then
        local playerdata = _activeplayers[data.player]
        if playerdata ~= nil then
            --Reset existing naughtiness
            playerdata.threshold = TUNING.KRAMPUS_THRESHOLD ~= -1 and (TUNING.KRAMPUS_THRESHOLD + math.random(TUNING.KRAMPUS_THRESHOLD_VARIANCE)) or nil
            playerdata.actions = 0
        end

        for i = 1, data.numspawns or 0 do
            local kramp = MakeAKrampusForPlayer(data.player)
            if kramp ~= nil and kramp.components.combat ~= nil then
                kramp.components.combat:SetTarget(data.player)
            end
        end
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

for i, v in ipairs(AllPlayers) do
    OnPlayerJoined(self, v)
end

inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)
inst:ListenForEvent("ms_forcenaughtiness", OnForceNaughtiness, TheWorld)

self.inst:StartUpdatingComponent(self)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

local function _DoWarningSound(player)
    local playerdata = _activeplayers[player]
    if playerdata ~= nil then
        local score = (playerdata.threshold or 0) - playerdata.actions
        if score < 20 then
            SpawnPrefab("krampuswarning_lvl"..
                ((score < 5 and "3") or
                (score < 15 and "2") or
                                "1")
            ).Transform:SetPosition(player.Transform:GetWorldPosition())
        end
    end
end

function self:DoWarningSound(player)
    player:DoTaskInTime(1 + math.random() * 2, _DoWarningSound)
end

function self:OnUpdate(dt)
    for _,playerdata in pairs(_activeplayers) do
        if playerdata.actions > 0 then
            playerdata.timetodecay = playerdata.timetodecay - dt

            if playerdata.timetodecay < 0 then
                playerdata.timetodecay = TUNING.KRAMPUS_NAUGHTINESS_DECAY_PERIOD
                playerdata.actions = playerdata.actions - 1
            end
        end
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local result = ""

    for player,playerdata in pairs(_activeplayers) do
        local str = GetDebugStringForPlayer(playerdata)
        if result ~= "" then
            result = result.."\n"
        end
        result = result..str
    end
    return result
end

end)
