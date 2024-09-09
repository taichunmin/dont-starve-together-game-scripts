--------------------------------------------------------------------------
--[[ Wildfires class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Wildfires should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _activeplayers = {}
local _scheduledtasks = {}
local _issummer = false
local _isday = true
local _iswet = false
local _ishot = TUNING.STARTING_TEMP > TUNING.WILDFIRE_THRESHOLD
local _chance = TUNING.WILDFIRE_CHANCE
local _radius = 25
local _updating = false
local _excludetags = { "wildfireprotected", "fire", "burnt", "player", "companion", "NOCLICK", "INLIMBO" } -- things that don't start fires

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function ShouldActivateWildfires()
    return _issummer and _isday and _ishot and not _iswet and _chance > 0
end

local YES_TAGS_SHADECANOPY = {"shadecanopy"}
local YES_TAGS_SHADECANOPY_SMALL = {"shadecanopysmall"}
local function checkforcanopyshade(obj)
    local x,y,z = obj.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE, YES_TAGS_SHADECANOPY)
    if #ents > 0 then
        return true
    end
    ents = TheSim:FindEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE_SMALL, YES_TAGS_SHADECANOPY_SMALL)
    if #ents > 0 then
        return true
    end
end

local function CheckValidWildfireStarter(obj)
    local x, y, z = obj.Transform:GetWorldPosition()
    if not obj:IsValid() or
        obj:HasTag("fireimmune") or
        checkforcanopyshade(obj) or
        (obj.components.witherable ~= nil and obj.components.witherable:IsProtected()) or
        GetTemperatureAtXZ(x, z) <= TUNING.WILDFIRE_THRESHOLD
    then
        return false --Invalid, immune, or temporarily protected
    elseif obj.components.pickable ~= nil then
        if obj.components.pickable:IsWildfireStarter() then
            --Wild plants
            return true
        end
    elseif obj.components.crop == nil and obj.components.growable == nil then
        --Non-plant
        return true
    end
    --Farm crop or tree
    return (obj.components.crop ~= nil and obj.components.witherable:IsWithered())
        or (obj.components.workable ~= nil and obj.components.workable:GetWorkAction() == ACTIONS.CHOP)
end

local function LightFireForPlayer(player, rescheduleFn)
    _scheduledtasks[player] = nil

    if math.random() <= _chance and
        not (_world.components.sandstorms ~= nil and
            _world.components.sandstorms:IsInSandstorm(player)) then
        local x, y, z = player.Transform:GetWorldPosition()
        local firestarters = TheSim:FindEntities(x, y, z, _radius, nil, _excludetags)
        if #firestarters > 0 then
            local highprio = {}
            local lowprio = {}
            for i, v in ipairs(firestarters) do
                if v.components.burnable ~= nil then
                    table.insert(v:HasTag("wildfirepriority") and highprio or lowprio, v)
                end
            end
            firestarters = #highprio > 0 and highprio or lowprio
            while #firestarters > 0 do
                local i = math.random(#firestarters)
                if CheckValidWildfireStarter(firestarters[i]) then
                    firestarters[i].components.burnable:StartWildfire()
                    break
                else
                    table.remove(firestarters, i)
                end
            end
        end
    end

    rescheduleFn(player)
end

local function ScheduleSpawn(player)
    if _scheduledtasks[player] == nil then
        _scheduledtasks[player] = player:DoTaskInTime(TUNING.WILDFIRE_RETRY_TIME, LightFireForPlayer, ScheduleSpawn)
    end
end

local function CancelSpawn(player)
    if _scheduledtasks[player] ~= nil then
        _scheduledtasks[player]:Cancel()
        _scheduledtasks[player] = nil
    end
end

local function ToggleUpdate()
    if ShouldActivateWildfires() then
        if not _updating then
            _updating = true
            for i, v in ipairs(_activeplayers) do
                ScheduleSpawn(v)
            end
        end
    elseif _updating then
        _updating = false
        for i, v in ipairs(_activeplayers) do
            CancelSpawn(v)
        end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnSeasonTick(inst, data)
    _issummer = data.season == SEASONS.SUMMER
    ToggleUpdate()
end

local function OnWeatherTick(inst, data)
    _iswet = data.wetness > 0 or data.snowlevel > 0
    ToggleUpdate()
end

local function OnTemperatureTick(inst, temperature)
    _ishot = temperature > TUNING.WILDFIRE_THRESHOLD
    ToggleUpdate()
end

local function OnPhaseChanged(inst, phase)
    _isday = phase == "day"
    ToggleUpdate()
end

local function ForceWildfireForPlayer(inst, player)
    if ShouldActivateWildfires() then
        CancelSpawn(player)
        LightFireForPlayer(player, ScheduleSpawn)
    end
end

local function OnPlayerJoined(inst, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)
    if _updating then
        ScheduleSpawn(player)
    end
end

local function OnPlayerLeft(inst, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            CancelSpawn(player)
            table.remove(_activeplayers, i)
            return
        end
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

--Register events
inst:ListenForEvent("weathertick", OnWeatherTick)
inst:ListenForEvent("seasontick", OnSeasonTick)
inst:ListenForEvent("temperaturetick", OnTemperatureTick)
inst:ListenForEvent("phasechanged", OnPhaseChanged)
inst:ListenForEvent("ms_lightwildfireforplayer", ForceWildfireForPlayer)
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft)

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return _updating and "Active" or "Inactive"
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
