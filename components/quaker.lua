--------------------------------------------------------------------------
--[[ Quaker class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local SourceModifierList = require("util/sourcemodifierlist")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local QUAKESTATE = {
    WAITING = 0,
    WARNING = 1,
    QUAKING = 2,
}

local DENSITYRADIUS = 5 -- the minimum radius that can contain 3 debris (allows for some clumping)

local SMASHABLE_TAGS = { "smashable", "quakedebris", "_combat" }
local NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost", "irreplaceable" }

local HEAVY_WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
}
local HEAVY_SMASHABLE_TAGS = { "smashable", "quakedebris", "_combat", "_inventoryitem", "NPC_workable" }
for k, v in pairs(HEAVY_WORK_ACTIONS) do
    table.insert(HEAVY_SMASHABLE_TAGS, k.."_workable")
end
local HEAVY_NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost", "irreplaceable", "caveindebris" }

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

-- Public

self.inst = inst

-- Private
local _world = TheWorld
local _ismastersim = _world.ismastersim
local _state = nil
local _debrispersecond = 1 -- how much junk falls
local _mammalsremaining = 0
local _task = nil
local _frequencymultiplier = TUNING.QUAKE_FREQUENCY_MULTIPLIER
local _pausesources = SourceModifierList(inst, false, SourceModifierList.boolean)

local _quakedata = nil -- populated through configuration

local _debris =
{
    { weight = 1, loot = { "rocks" } },
}

local _tagdebris =
{
}

local _activeplayers = {}
local _scheduleddrops = {}
local _originalplayers = {}

-- Network Variables
local _quakesoundintensity = net_tinybyte(inst.GUID, "quaker._quakesoundintensity", "quakesoundintensitydirty")
local _miniquakesoundintensity = net_bool(inst.GUID, "quaker._miniquakesoundintensity", "miniquakesoundintensitydirty")

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

-- debris methods
local UpdateShadowSize = _ismastersim and function(shadow, height)
    local scaleFactor = Lerp(.5, 1.5, height / 35)
    shadow.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)
end or nil

local GetDebris = _ismastersim and function(node_data)
    local debris_table = nil
    if node_data == nil or node_data.tags == nil then
        debris_table = _debris
    else
        debris_table = {}

        -- We support empty tables to produce no debris,
        -- so we can't just test for an empty table later.
        local tag_found = false
        for _, tag in ipairs(node_data.tags) do
            local tag_table = _tagdebris[tag]
            if tag_table ~= nil then
                tag_found = true
                ConcatArrays(debris_table, tag_table)
            end
        end

        if not tag_found then
            debris_table = _debris
        end
    end

    local weighttotal = 0
    for i,v in ipairs(debris_table) do
        weighttotal = weighttotal + v.weight
    end
    local val = math.random() * weighttotal
    local droptable = nil
    for i,v in ipairs(debris_table) do
        if val < v.weight then
            droptable = deepcopy(v.loot) -- we will be modifying this
            break
        else
            val = val-v.weight
        end
    end

    local todrop = nil
    if droptable ~= nil then
        while todrop == nil and #droptable > 0 do
            local index = math.random(1,#droptable)
            todrop = droptable[index]
            if todrop == "mole" or todrop == "rabbit" or todrop == "carrat" then
                -- if it's a small creature, count it, or remove it from the table and try again
                if _mammalsremaining == 0 then
                    table.remove(droptable, index)
                    todrop = nil
                end
            end
        end
    end

    return todrop
end or nil

--[[local PlayFallingSound = _ismastersim and function(debris, volume)
    volume = volume or 1
    local sound = debris.SoundEmitter
    if sound then
        local tile, tileinfo = debris:GetCurrentTileType()
        if tile and tileinfo then
            local x, y, z = debris.Transform:GetWorldPosition()
            local size_affix = "_small"
            --gjans: This doesn't play on the client! Not sure why...
            --sound:PlaySound(tileinfo.walksound .. size_affix, nil, volume)
        end
    end
end or nil]]

local _BreakDebris = _ismastersim and function(debris)
    local x, y, z = debris.Transform:GetWorldPosition()
    SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(x, 0, z)
    debris:Remove()
end or nil

local QUAKEDEBRIS_CANT_TAGS = { "quakedebris" }
local QUAKEDEBRIS_ONEOF_TAGS = { "INLIMBO" }

local _GroundDetectionUpdate = _ismastersim and function(debris, override_density)
    local x, y, z = debris.Transform:GetWorldPosition()
    if y <= .2 then
        if not debris:IsOnValidGround() then
            debris:PushEvent("detachchild")
            debris:Remove()
        elseif _world.Map:IsPointNearHole(Vector3(x, 0, z)) then
            if debris.prefab == "mole" or debris.prefab == "rabbit" or debris.prefab == "carrat" then
                debris:PushEvent("detachchild")
                debris:Remove()
            else
                _BreakDebris(debris)
            end
        else
            --PlayFallingSound(debris)

            -- break stuff we land on
            -- NOTE: re-check validity as we iterate, since we're invalidating stuff as we go
            local softbounce = false
            if debris:HasTag("heavy") then
                local ents = TheSim:FindEntities(x, 0, z, 2, nil, HEAVY_NON_SMASHABLE_TAGS, HEAVY_SMASHABLE_TAGS)
                for i, v in ipairs(ents) do
                    if v ~= debris and v:IsValid() and not v:IsInLimbo() then
                        softbounce = true
                        --NOTE: "smashable" excluded for now
                        if v:HasTag("quakedebris") then
                            local vx, vy, vz = v.Transform:GetWorldPosition()
                            SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(vx, 0, vz)
                            v:Remove()
                        elseif v.components.workable ~= nil then
                            if v.sg == nil or not v.sg:HasStateTag("busy") then
                                local work_action = v.components.workable:GetWorkAction()
                                --V2C: nil action for NPC_workable (e.g. campfires)
                                if (    (work_action == nil and v:HasTag("NPC_workable")) or
                                        (work_action ~= nil and HEAVY_WORK_ACTIONS[work_action.id]) ) and
                                    (work_action ~= ACTIONS.DIG
                                    or (v.components.spawner == nil and
                                        v.components.childspawner == nil)) then
                                    v.components.workable:Destroy(debris)
                                end
                            end
                        elseif v.components.combat ~= nil then
                            v.components.combat:GetAttacked(debris, 30, nil)
                        elseif v.components.inventoryitem ~= nil then
                            if v.components.mine ~= nil then
                                v.components.mine:Deactivate()
                            end
                            Launch(v, debris, TUNING.LAUNCH_SPEED_SMALL)
                        end
                    end
                end
            else
                local ents = TheSim:FindEntities(x, 0, z, 2, nil, NON_SMASHABLE_TAGS, SMASHABLE_TAGS)
                for i, v in ipairs(ents) do
                    if v ~= debris and v:IsValid() and not v:IsInLimbo() then
                        softbounce = true
                        --NOTE: "smashable" excluded for now
                        if v:HasTag("quakedebris") then
                            local vx, vy, vz = v.Transform:GetWorldPosition()
                            SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(vx, 0, vz)
                            v:Remove()
                        elseif v.components.combat ~= nil and not (v:HasTag("epic") or v:HasTag("wall")) then
                            v.components.combat:GetAttacked(debris, 20, nil)
                        end
                    end
                end
            end

            debris.Physics:SetDamping(.9)

            if softbounce then
                local speed = 3.2 + math.random()
                local angle = math.random() * 2 * PI
                debris.Physics:SetMotorVel(0, 0, 0)
                debris.Physics:SetVel(
                    speed * math.cos(angle),
                    speed * 2.3,
                    speed * math.sin(angle)
                )
            end

            debris.shadow:Remove()
            debris.shadow = nil

            debris.updatetask:Cancel()
            debris.updatetask = nil

            local density = override_density or DENSITYRADIUS
            if density <= 0 or
                debris.prefab == "mole" or
                debris.prefab == "rabbit" or
                debris.prefab == "carrat" or
                not (math.random() < .75 or
                    --NOTE: There will always be at least one found within DENSITYRADIUS, ourself!
                    #TheSim:FindEntities(x, 0, y, density, nil, QUAKEDEBRIS_CANT_TAGS, QUAKEDEBRIS_ONEOF_TAGS) > 1
                ) then
                --keep it
                debris.persists = true
                debris.entity:SetCanSleep(true)
                if debris._restorepickup then
                    debris._restorepickup = nil
                    if debris.components.inventoryitem ~= nil then
                        debris.components.inventoryitem.canbepickedup = true
                    end
                end
                debris:PushEvent("stopfalling")
            elseif debris:GetTimeAlive() < 1.5 then
                --should be our first bounce
                debris:DoTaskInTime(softbounce and .4 or .6, _BreakDebris)
            else
                --we missed detecting our first bounce, so break immediately this time
                _BreakDebris(debris)
            end
        end
    elseif debris:GetTimeAlive() < 3 then
        if y < 2 then
            debris.Physics:SetMotorVel(0, 0, 0)
        end
        UpdateShadowSize(debris.shadow, y)
    elseif debris:IsInLimbo() then
        --failsafe, but maybe we got trapped or picked up somehow, so keep it
        debris.persists = true
        debris.entity:SetCanSleep(true)
        debris.shadow:Remove()
        debris.shadow = nil
        debris.updatetask:Cancel()
        debris.updatetask = nil
        if debris._restorepickup then
            debris._restorepickup = nil
            if debris.components.inventoryitem ~= nil then
                debris.components.inventoryitem.canbepickedup = true
            end
        end
        debris:PushEvent("stopfalling")
    elseif debris.prefab == "mole" or debris.prefab == "rabbit" or debris.prefab == "carrat" then
        --failsafe
        debris:PushEvent("detachchild")
        debris:Remove()
    else
        --failsafe
        _BreakDebris(debris)
    end
end or nil

-- /debris methods

local OnRemoveDebris = _ismastersim and function(debris)
    debris.shadow:Remove()
end or nil

local SpawnDebris = _ismastersim and function(spawn_point, override_prefab, override_density)
    local node_index = _world.Map:GetNodeIdAtPoint(spawn_point:Get())

    local prefab = override_prefab or GetDebris(_world.topology.nodes[node_index])
    if prefab ~= nil then
        local debris = SpawnPrefab(prefab)
        if debris ~= nil then
            debris.entity:SetCanSleep(false)
            debris.persists = false

            if (prefab == "rabbit" or prefab == "mole" or prefab == "carrat") and debris.sg ~= nil then
                _mammalsremaining = _mammalsremaining - 1
                debris.sg:GoToState("fall")
            end
            if debris.components.inventoryitem ~= nil and debris.components.inventoryitem.canbepickedup then
                debris.components.inventoryitem.canbepickedup = false
                debris._restorepickup = true
            end
            if math.random() < .5 then
                debris.Transform:SetRotation(180)
            end
            debris.Physics:Teleport(spawn_point.x, 35, spawn_point.z)

            debris.shadow = SpawnPrefab("warningshadow")
            debris.shadow:ListenForEvent("onremove", OnRemoveDebris, debris)
            debris.shadow.Transform:SetPosition(spawn_point.x, 0, spawn_point.z)
            UpdateShadowSize(debris.shadow, 35)

            debris.updatetask = debris:DoPeriodicTask(FRAMES, _GroundDetectionUpdate, nil, override_density)
            debris:PushEvent("startfalling")
        end
        return debris
    end
end or nil

local GetTimeForNextDebris = _ismastersim and function()
    return 1 / _debrispersecond
end or nil

local GetSpawnPoint = _ismastersim and function(pt, rad, minrad)
    local theta = math.random() * 2 * PI
    local radius = math.random() * (rad or TUNING.FROG_RAIN_SPAWN_RADIUS)

    minrad = minrad ~= nil and minrad > 0 and minrad * minrad or nil

    local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
        local x = pt.x + offset.x
        local z = pt.z + offset.z
        return _world.Map:IsAboveGroundAtPoint(x, 0, z)
            and (minrad == nil or offset.x * offset.x + offset.z * offset.z >= minrad)
            and not _world.Map:IsPointNearHole(Vector3(x, 0, z))
    end)

    return result_offset ~= nil and pt + result_offset or nil
end or nil

local DoDropForPlayer = _ismastersim and function(player, reschedulefn)
    local char_pos = Vector3(player.Transform:GetWorldPosition())
    local spawn_point = GetSpawnPoint(char_pos)
    if spawn_point ~= nil then
        player:ShakeCamera(CAMERASHAKE.FULL, 0.7, 0.02, .75)
        SpawnDebris(spawn_point)
    end
    reschedulefn(player)
end or nil

local ScheduleDrop
ScheduleDrop = _ismastersim and function(player)
    if _scheduleddrops[player] ~= nil then
        _scheduleddrops[player]:Cancel()
    end
    _scheduleddrops[player] = player:DoTaskInTime(GetTimeForNextDebris(), DoDropForPlayer, ScheduleDrop)
end or nil

local CancelDropForPlayer = _ismastersim and function(player)
    if _scheduleddrops[player] ~= nil then
        _scheduleddrops[player]:Cancel()
        _scheduleddrops[player] = nil
    end
end or nil

local CancelDrops = _ismastersim and function()
    for i,v in pairs(_scheduleddrops) do
        v:Cancel()
    end
    _scheduleddrops = {}
end or nil

local _DoWarningSpeech = _ismastersim and function(player)
    player.components.talker:Say(GetString(player, "ANNOUNCE_QUAKE"))
end or nil

local SetNextQuake = nil -- forward declare this...
local EndQuake = nil -- forward declare this...

local ClearTask = _ismastersim and function()
    if _state == QUAKESTATE.QUAKING or _state == QUAKESTATE.WARNING then
        EndQuake(inst, false)
    end

    if _task ~= nil then
        _task:Cancel()
        _task = nil
    end

    _state = nil
end or nil

local UpdateTask = _ismastersim and function(time, callback, data)
    if _task ~= nil then
        _task:Cancel()
        _task = nil
    end
    _task = inst:DoTaskInTime(time, callback, data)
end or nil

-- was forward declared
EndQuake = _ismastersim and function(inst, continue)
    CancelDrops()

    _quakesoundintensity:set(0)
    inst:PushEvent("endquake")

    if continue then
        SetNextQuake(_quakedata)
    end

    for i, op in ipairs(_originalplayers) do
	    for j, ap in ipairs(_activeplayers) do
			if op == ap and not op:HasTag("playerghost") then
				AwardPlayerAchievement("survive_earthquake", op)
				break
			end
		end
	end
end or nil

local StartQuake = _ismastersim and function(inst, data, overridetime)
    _quakesoundintensity:set(2)

    _debrispersecond = FunctionOrValue(data.debrispersecond)
    _mammalsremaining = FunctionOrValue(data.mammals)

	_originalplayers = {}
    for i, v in ipairs(_activeplayers) do
        ScheduleDrop(v)

        table.insert(_originalplayers, v)
    end

    inst:PushEvent("startquake")

    local quaketime = overridetime or FunctionOrValue(data.quaketime)
    UpdateTask(quaketime, EndQuake, true)
    _state = QUAKESTATE.QUAKING
end or nil

local DoWarnQuake = _ismastersim and function()
    for i, v in ipairs(_activeplayers) do
        v:DoTaskInTime(math.random() * 2, _DoWarningSpeech)
    end
    inst:PushEvent("warnquake")
end or nil

local WarnQuake = _ismastersim and function(inst, data, overridetime)
    if _pausesources:Get() then
        SetNextQuake(_quakedata)
        return
    end

    inst:DoTaskInTime(1, DoWarnQuake)
    _quakesoundintensity:set(1)

    local warntime = overridetime or FunctionOrValue(data.warningtime)
    ShakeAllCameras(CAMERASHAKE.FULL, warntime + 3, .02, .2, nil, 40)
    UpdateTask(warntime, StartQuake, data)
    _state = QUAKESTATE.WARNING
end or nil

-- Was forward declared
SetNextQuake = _ismastersim and function(data, overridetime)
    if _frequencymultiplier <= 0 then
        --should not get here yo!
        ClearTask()
        return
    end

    local nexttime = overridetime or FunctionOrValue(data.nextquake) / _frequencymultiplier
    UpdateTask(nexttime, WarnQuake, data)
    _state = QUAKESTATE.WAITING
end or nil

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnQuakeSoundIntensityDirty()
    if _quakesoundintensity:value() > 0 then
        if not _world.SoundEmitter:PlayingSound("earthquake") then
            _world.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "earthquake")
        end
        _world.SoundEmitter:SetParameter("earthquake", "intensity", _quakesoundintensity:value() <= 1 and .8 or 1)
    elseif _world.SoundEmitter:PlayingSound("earthquake") then
        _world.SoundEmitter:KillSound("earthquake")
    end
end

local function OnMiniQuakeSoundIntensityDirty()
    if _miniquakesoundintensity:value() then
        if not _world.SoundEmitter:PlayingSound("miniearthquake") then
            _world.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "miniearthquake")
            _world.SoundEmitter:SetParameter("miniearthquake", "intensity", 1)
        end
    elseif _world.SoundEmitter:PlayingSound("miniearthquake") then
        _world.SoundEmitter:KillSound("miniearthquake")
    end
end

local _OnEndMiniQuake = _ismastersim and function()
    _miniquakesoundintensity:set(false)
end or nil

local _OnMiniQuakeSpawn = _ismastersim and function(inst, pos, rad, minrad, debrisfn)
    local spawn_point = GetSpawnPoint(pos, rad, minrad)
    if spawn_point ~= nil then
        if debrisfn ~= nil then
            local prefab, density = debrisfn()
            if prefab ~= nil then
                SpawnDebris(spawn_point, prefab, density)
            end
        else
            SpawnDebris(spawn_point)
        end
    end
end or nil

local OnMiniQuake = _ismastersim and function(src, data)
    _miniquakesoundintensity:set(true)

    local pos = data.pos or data.target:GetPosition()
    local dt = data.duration / data.num
    for t = 0, data.duration - dt * .5, dt do
        inst:DoTaskInTime(t, _OnMiniQuakeSpawn, pos, data.rad, data.minrad, data.debrisfn)
    end

    ShakeAllCameras(CAMERASHAKE.FULL, data.duration, .02, .5, data.target, 40)

    inst:DoTaskInTime(data.duration, _OnEndMiniQuake)
end or nil

local OnExplosion = _ismastersim and function(src, data)
    if _state == QUAKESTATE.WAITING then
        SetNextQuake(_quakedata, GetTaskRemaining(_task) - data.damage)
    elseif _state == QUAKESTATE.WARNING then
        WarnQuake(inst, _quakedata)
    end
end or nil

-- Immediately start the current or a specified quake
-- If a new quake type is forced, save current quake type and restore it once quake has finished
local OnForceQuake = _ismastersim and function(src, data)
    if _state == QUAKESTATE.QUAKING then return false end
    StartQuake(inst, data or _quakedata)
    return true
end or nil

local OnPlayerJoined = _ismastersim and function(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)
    if _state == QUAKESTATE.QUAKING then
        ScheduleDrop(player)
    end
end or nil

local OnPlayerLeft = _ismastersim and function(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            CancelDropForPlayer(player)
            table.remove(_activeplayers, i)
            return
        end
    end
end or nil

local OnPauseQuakes = _ismastersim and function(src, data)
    if data ~= nil and data.source ~= nil then
        _pausesources:SetModifier(data.source, true, data.reason)
    end
end or nil

local OnUnpauseQuakes = _ismastersim and function(src, data)
    if data ~= nil and data.source ~= nil then
        _pausesources:RemoveModifier(data.source, data.reason)
    end
end or nil

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SetQuakeData(data)
    if not _ismastersim then return end

    _quakedata = data
    if _quakedata ~= nil and _frequencymultiplier > 0 then
        SetNextQuake(_quakedata)
    else
        ClearTask()
    end
end

function self:SetDebris(data)
    if not _ismastersim then return end

    _debris = data
end

function self:SetTagDebris(tile, data)
    if not _ismastersim then return end

    _tagdebris[tile] = data
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register network variable sync events
if not TheNet:IsDedicated() then
    inst:ListenForEvent("quakesoundintensitydirty", OnQuakeSoundIntensityDirty)
    inst:ListenForEvent("miniquakesoundintensitydirty", OnMiniQuakeSoundIntensityDirty)
end

--Register events
if _ismastersim then
    inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, _world)
    inst:ListenForEvent("ms_playerleft", OnPlayerLeft, _world)

    inst:ListenForEvent("ms_miniquake", OnMiniQuake, _world)
    inst:ListenForEvent("ms_forcequake", OnForceQuake, _world)

    inst:ListenForEvent("explosion", OnExplosion, _world)

    inst:ListenForEvent("pausequakes", OnPauseQuakes, _world)
    inst:ListenForEvent("unpausequakes", OnUnpauseQuakes, _world)
end

-- Default configuration
self:SetDebris( {
    { -- common
        weight = 0.75,
        loot = {
            "rocks",
            "flint",
        },
    },
    { -- uncomon
        weight = 0.20,
        loot = {
            "goldnugget",
            "nitre",
            "rabbit",
            "mole",
        },
    },
    { -- rare
        weight = 0.05,
        loot = {
            "redgem",
            "bluegem",
            "marble",
        },
    },
})

local MUTATED_MUSH_DEBRIS =
{
    { -- common
        weight = 0.60,
        loot =
        {
            "rocks",
            "flint",
            "moonglass",
        }
    },
    { -- uncomon
        weight = 0.40,
        loot =
        {
            "rock_avocado_fruit",
            "carrat",
        },
    },
}
self:SetTagDebris( "lunacyarea", MUTATED_MUSH_DEBRIS )

-- If we were to use nil, we would fall through to the default debris table.
self:SetTagDebris( "nocavein", {})

self:SetQuakeData({
    warningtime = 7,
    quaketime = function() return math.random(5, 10) + 5 end,
    debrispersecond = function() return math.random(5, 6) end,
    nextquake = function() return TUNING.TOTAL_DAY_TIME + math.random() * TUNING.TOTAL_DAY_TIME * 2 end,
    mammals = 1,
})

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

if _ismastersim then function self:OnSave()
    return {
        time = GetTaskRemaining(_task),
        state = _state,
        debrispersecond = _debrispersecond,
        mammalsremaining = _mammalsremaining
    }
end end

if _ismastersim then function self:OnLoad(data)
    _debrispersecond = data.debrispersecond or 1
    _mammalsremaining = data.mammalsremaining or 0

    _state = data.state
    if _state == QUAKESTATE.WAITING then
        SetNextQuake(_quakedata, data.time)
    elseif _state == QUAKESTATE.WARNING then
        WarnQuake(inst, _quakedata, data.time)
    elseif _state == QUAKESTATE.QUAKING then
        StartQuake(inst, _quakedata, data.time)
    end
end end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local s = ""
    if _ismastersim then
        s = table.reverselookup(QUAKESTATE, _state)
        s = s .. string.format(" %.2f", GetTaskRemaining(_task))
        if _state == QUAKESTATE.QUAKING then
            s = s .. string.format(" debris/second: %.2f mammals: %d",
                _debrispersecond, _mammalsremaining)
        elseif _state == QUAKESTATE.WARNING then
        elseif _state == QUAKESTATE.WAITING then
        end
    end
    s = s .. " intensity: " .. tostring(
        (_quakesoundintensity:value() == 0 and 0) or
        (_quakesoundintensity:value() == 1 and .8) or
        1
    )
    return s
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
