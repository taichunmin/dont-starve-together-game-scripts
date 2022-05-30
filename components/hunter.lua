--------------------------------------------------------------------------
--[[ Hunter class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Hunter should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local SourceModifierList = require("util/sourcemodifierlist")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local HUNT_UPDATE = 2

local MIN_TRACKS = 6
local MAX_TRACKS = 12

local _dirt_prefab = "dirtpile"
local _track_prefab = "animal_track"
local _beast_prefab_summer = "koalefant_summer"
local _beast_prefab_winter = "koalefant_winter"
local _beast_prefab_spring = "lightninggoat"
local _alternate_beasts = { "warg", "spat" }
local _ambush_prefab = "bat"

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

-- Private
local _activeplayers = {}
local _activehunts = {}
local _wargshrines = SourceModifierList(inst, false, SourceModifierList.boolean)

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local OnUpdateHunt
local ResetHunt

local function GetMaxHunts()
    return #_activeplayers
end

local function RemoveDirt(hunt)
    assert(hunt)
    --print("Hunter:RemoveDirt")
    if hunt.lastdirt ~= nil then
        --print("   removing old dirt")
        inst:RemoveEventCallback("onremove", hunt.lastdirt._ondirtremove, hunt.lastdirt)
        hunt.lastdirt:Remove()
        hunt.lastdirt = nil
    --else
        --print("   nothing to remove")
    end
end

local function StopHunt(hunt)
    assert(hunt)
    --print("Hunter:StopHunt")

    RemoveDirt(hunt)

    if hunt.hunttask ~= nil then
        --print("   stopping")
        hunt.hunttask:Cancel()
        hunt.hunttask = nil
    --else
        --print("   nothing to stop")
    end
end

local function BeginHunt(hunt)
    assert(hunt)
    --print("Hunter:BeginHunt")
    hunt.hunttask = inst:DoPeriodicTask(HUNT_UPDATE, OnUpdateHunt, nil, hunt)
    --print(hunt.hunttask ~= nil and "The Hunt Begins!" or "The Hunt ... failed to begin.")
end

local function StopCooldown(hunt)
    assert(hunt)
    --print("Hunter:StopCooldown")
    if hunt.cooldowntask ~= nil then
        --print("    stopping")
        hunt.cooldowntask:Cancel()
        hunt.cooldowntask = nil
        hunt.cooldowntime = nil
    --else
        --print("    nothing to stop")
    end
end

local function OnCooldownEnd(inst, hunt)
    assert(hunt)
    --print("Hunter:OnCooldownEnd")

    StopCooldown(hunt) -- clean up references
    StopHunt(hunt)

    BeginHunt(hunt)
end

local function RemoveHunt(hunt)
    StopHunt(hunt)
    for i,v in ipairs(_activehunts) do
        if v == hunt then
            table.remove(_activehunts, i)
            return
        end
    end
    assert(false)
end

local function StartCooldown(inst, hunt, cooldown)
    assert(hunt)
    cooldown = cooldown or TUNING.HUNT_COOLDOWN + TUNING.HUNT_COOLDOWNDEVIATION * (math.random() * 2 - 1)
    --print("Hunter:StartCooldown", cooldown)

    StopHunt(hunt)
    StopCooldown(hunt)

    if #_activehunts > GetMaxHunts() then
        RemoveHunt(hunt)
        return
    end

    if cooldown and cooldown > 0 then
        --print("The Hunt begins in", cooldown)
        hunt.activeplayer = nil
        hunt.lastdirt = nil
        hunt.lastdirttime = nil

        hunt.cooldowntask = inst:DoTaskInTime(cooldown, OnCooldownEnd, hunt)
        hunt.cooldowntime = GetTime() + cooldown
    end
end

local function StartHunt()
    --print("Hunter:StartHunt")
    -- Given the way hunt is used, it should really be its own class now
    local newhunt =
    {
        lastdirt = nil,
        direction = nil,
        activeplayer = nil,
    }
    table.insert(_activehunts, newhunt)
    inst:DoTaskInTime(0, StartCooldown, newhunt, TUNING.HUNT_COOLDOWN + TUNING.HUNT_COOLDOWNDEVIATION * (math.random() * 2 - 1))
    return newhunt
end

local function GetSpawnPoint(pt, radius, hunt)
    --print("Hunter:GetSpawnPoint", tostring(pt), radius)

    local angle = hunt.direction
    if angle then
        local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
        local spawn_point = pt + offset
        --print(string.format("Hunter:GetSpawnPoint RESULT %s, %2.2f", tostring(spawn_point), angle/DEGREES))
        return spawn_point
    end
end

local function SpawnDirt(pt,hunt)
    assert(hunt)
    --print("Hunter:SpawnDirt")

    local spawn_pt = GetSpawnPoint(pt, TUNING.HUNT_SPAWN_DIST, hunt)
    if spawn_pt ~= nil then
        local spawned = SpawnPrefab(_dirt_prefab)
        if spawned ~= nil then
            spawned.Transform:SetPosition(spawn_pt:Get())
            hunt.lastdirt = spawned
            hunt.lastdirttime = GetTime()

			if hunt.ambush_track_num ~= nil and hunt.ambush_track_num == hunt.trackspawned then
				local day = TheWorld.state.cycles
				local num_bats = math.min(3 + math.floor(day/35), 6)
				for i = 1, num_bats do
					spawned:DoTaskInTime(0.2 * i + math.random() * 0.3, function()
						local bat = SpawnPrefab(_ambush_prefab)
						local pos = FindNearbyLand(spawned:GetPosition(), 2)
						bat.Transform:SetPosition(pos:Get())
						bat:PushEvent("fly_back")
					end)
				end
				hunt.ambush_track_num = nil
			end

            spawned._ondirtremove = function()
                hunt.lastdirt = nil
                ResetHunt(hunt)
            end
            inst:ListenForEvent("onremove", spawned._ondirtremove, spawned)

            return true
        end
    end
    --print("Hunter:SpawnDirt FAILED")
    return false
end

local function GetRunAngle(pt, angle, radius)
    local offset, result_angle = FindWalkableOffset(pt, angle, radius, 14, true)
    return result_angle
end

local function GetNextSpawnAngle(pt, direction, radius)
    --print("Hunter:GetNextSpawnAngle", tostring(pt), radius)

    local base_angle = direction or math.random() * 2 * PI
    local deviation = math.random(-TUNING.TRACK_ANGLE_DEVIATION, TUNING.TRACK_ANGLE_DEVIATION)*DEGREES

    local start_angle = base_angle + deviation
    --print(string.format("   original: %2.2f, deviation: %2.2f, starting angle: %2.2f", base_angle/DEGREES, deviation/DEGREES, start_angle/DEGREES))

    --[[local angle =]] return GetRunAngle(pt, start_angle, radius)
    --print(string.format("Hunter:GetSpawnPoint RESULT %s", tostring(angle and angle/DEGREES)))
    --return angle
end

local function StartDirt(hunt,position)
    assert(hunt)

    --print("Hunter:StartDirt")

    RemoveDirt(hunt)

    local pt = position --Vector3(player.Transform:GetWorldPosition())

    hunt.numtrackstospawn = math.random(MIN_TRACKS, MAX_TRACKS)

    if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
		hunt.ambush_track_num = math.random(math.floor(hunt.numtrackstospawn/2), hunt.numtrackstospawn-1)
	end

    hunt.trackspawned = 0
    hunt.direction = GetNextSpawnAngle(pt, nil, TUNING.HUNT_SPAWN_DIST)
    if hunt.direction ~= nil then
        --print(string.format("   first angle: %2.2f", hunt.direction/DEGREES))

        --print("    numtrackstospawn", hunt.numtrackstospawn)

        -- it's ok if this spawn fails, because we'll keep trying every HUNT_UPDATE
        local spawnRelativeTo =  pt
        if SpawnDirt(spawnRelativeTo, hunt) then
            --print("Suspicious dirt placed for player ")
        end
    --else
        --print("Failed to find suitable dirt placement point")
    end
end

-- are we too close to the last dirtpile of a hunt?
local function IsNearHunt(player)
    for i,hunt in ipairs(_activehunts) do
        if hunt.lastdirt ~= nil and player:IsNear(hunt.lastdirt, TUNING.MIN_JOINED_HUNT_DISTANCE) then
            return true
        end
    end
    return false
end

local function IsEligible(player)
	local area = player.components.areaaware
	return TheWorld.Map:IsVisualGroundAtPoint(player.Transform:GetWorldPosition())
			and area:GetCurrentArea() ~= nil
			and not area:CurrentlyInTag("nohunt")
			and not area:CurrentlyInTag("moonhunt")
end

-- something went unrecoverably wrong, try again after a brief pause
ResetHunt = function(hunt, washedaway)
    assert(hunt)
    --print("Hunter:ResetHunt - The Hunt was a dismal failure, please stand by...")
    if hunt.activeplayer ~= nil then
        hunt.activeplayer:PushEvent("huntlosttrail", { washedaway = washedaway })
    end

    StartCooldown(inst, hunt, TUNING.HUNT_RESET_TIME)
end

-- Don't be tricked by the name. This is not called every frame
OnUpdateHunt = function(inst, hunt)
    assert(hunt)

    --print("Hunter:OnUpdateHunt")

    if hunt.lastdirttime ~= nil then
        if hunt.trackspawned >= 1 then
            local wet = TheWorld.state.wetness > 15 or TheWorld.state.israining

            local lastdirttime = GetTime() - hunt.lastdirttime
            local maxtime = wet and 0.75*TUNING.SEG_TIME or 1.25*TUNING.SEG_TIME
            if lastdirttime > maxtime then

                -- check if the player is currently active in any other hunts
                local playerIsInOtherHunt = false
                for i,v in ipairs(_activehunts) do
                    if v ~= hunt and v.activeplayer and hunt.activeplayer then
                        if v.activeplayer == hunt.activeplayer then
                            playerIsInOtherHunt = true
                        end
                    end
                end

                -- if the player is still active in another hunt then end this one quietly
                if playerIsInOtherHunt then
                    StartCooldown(inst, hunt)
                else
                    ResetHunt(hunt, wet) --Wash the tracks away but only if the player has seen at least 1 track
                end

                return
            end
        end
    end

    if hunt.lastdirt == nil then
        -- pick a player that is available, meaning, not being the active participant in a hunt
        local huntingPlayers = {}
        for i,v in ipairs(_activehunts) do
            if v.activeplayer then
                huntingPlayers[v.activeplayer] = true
            end
        end

        local eligiblePlayers = {}
        for i,v in ipairs(_activeplayers) do
            if not huntingPlayers[v] and not IsNearHunt(v) and IsEligible(v) then
                table.insert(eligiblePlayers, v)
            end
        end
        if #eligiblePlayers == 0 then
            -- Maybe next time?
            return
        end
        local player = eligiblePlayers[math.random(1,#eligiblePlayers)]
        --print("Start hunt for player",player)
        local position = player:GetPosition()
        StartDirt(hunt, position)
    else
        -- if no player near enough, then give up this hunt and start a new one
        local x, y, z = hunt.lastdirt.Transform:GetWorldPosition()

        if not IsAnyPlayerInRange(x, y, z, TUNING.MAX_DIRT_DISTANCE) then
            -- try again rather soon
            StartCooldown(inst, hunt, .1)
        end
    end
end

local function GetAlternateBeastChance()
    local day = TheWorld.state.cycles
    local chance = Lerp(TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MIN, TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MAX, day/100)
    return math.clamp(chance, TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MIN, TUNING.HUNT_ALTERNATE_BEAST_CHANCE_MAX)
end

local function SpawnHuntedBeast(hunt, pt)
    assert(hunt)
    --print("Hunter:SpawnHuntedBeast")

    local spawn_pt = GetSpawnPoint(pt, TUNING.HUNT_SPAWN_DIST, hunt)
    if spawn_pt ~= nil then
		local spawn_x, spawn_y, spawn_z = spawn_pt:Get()
        local huntedbeast = SpawnPrefab(
            (self:IsWargShrineActive() and "claywarg") or
            (math.random() <= GetAlternateBeastChance() and GetRandomItem(_alternate_beasts)) or
            (TheWorld.state.iswinter and _beast_prefab_winter) or
			(TheWorld.state.isspring and TheWorld.state.israining and TheWorld.Map:FindVisualNodeAtPoint(spawn_x, spawn_y, spawn_z, "sandstorm") and _beast_prefab_spring) or
            _beast_prefab_summer
        )

        if huntedbeast ~= nil then
            --print("Kill the Beast!")
            huntedbeast.Physics:Teleport(spawn_x, spawn_y, spawn_z)

            huntedbeast:PushEvent("spawnedforhunt")
            return true
        end
    end
    --print("Hunter:SpawnHuntedBeast FAILED")
    return false
end

local function SpawnTrack(spawn_pt, hunt)
    --print("Hunter:SpawnTrack")

    if spawn_pt then
        local next_angle = GetNextSpawnAngle(spawn_pt, hunt.direction, TUNING.HUNT_SPAWN_DIST)
        if next_angle ~= nil then
            local spawned = SpawnPrefab(_track_prefab)
            if spawned ~= nil then
                spawned.Transform:SetPosition(spawn_pt:Get())

                hunt.direction = next_angle

                --print(string.format("   next angle: %2.2f", hunt.direction/DEGREES))
                spawned.Transform:SetRotation(hunt.direction/DEGREES - 90)

                hunt.trackspawned = hunt.trackspawned + 1
                --print(string.format("   spawned %u/%u", hunt.trackspawned, hunt.numtrackstospawn))
                return true
            end
        end
    end
    --print("Hunter:SpawnTrack FAILED")
    return false
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function KickOffHunt()
    -- schedule start of a new hunt
    if #_activehunts < GetMaxHunts() then
        StartHunt()
    end
end

local function OnPlayerJoined(src, player)
    for i,v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)
    -- one hunt per player.
    KickOffHunt()
end

local function OnPlayerLeft(src, player)
    for i,v in ipairs(_activeplayers) do
        if v == player then
            table.remove(_activeplayers, i)
            return
        end
    end
end

local function OnWargShrineActivated(src, shrine)
    _wargshrines:SetModifier(shrine, true)
end

local function OnWargShrineDeactivated(src, shrine)
    _wargshrines:RemoveModifier(shrine)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

for i, v in ipairs(AllPlayers) do
    OnPlayerJoined(self, v)
end

inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)
inst:ListenForEvent("wargshrineactivated", OnWargShrineActivated, TheWorld)
inst:ListenForEvent("wargshrinedeactivated", OnWargShrineDeactivated, TheWorld)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

-- if anything fails during this step, it's basically unrecoverable, since we only have this one chance
-- to spawn whatever we need to spawn.  if that fails, we need to restart the whole process from the beginning
-- and hope we end up in a better place
function self:OnDirtInvestigated(pt, doer)
    assert(doer)

    --print("Hunter:OnDirtInvestigated (by "..tostring(doer)..")")

    local hunt = nil
    -- find the hunt this pile belongs to
    for i,v in ipairs(_activehunts) do
        if v.lastdirt ~= nil and v.lastdirt:GetPosition() == pt then
            hunt = v
            inst:RemoveEventCallback("onremove", v.lastdirt._ondirtremove, v.lastdirt)
            break
        end
    end

    if hunt == nil then
        -- we should probably do something intelligent here.
        --print("yikes, no matching hunt found for investigated dirtpile")
        return
    end

    hunt.activeplayer = doer

    if hunt.numtrackstospawn ~= nil and hunt.numtrackstospawn > 0 then
        if SpawnTrack(pt, hunt) then
            --print("    ", hunt.trackspawned, hunt.numtrackstospawn)
            if hunt.trackspawned < hunt.numtrackstospawn then
                if SpawnDirt(pt, hunt) then
                    --print("...good job, you found a track!")
                else
                    --print("SpawnDirt FAILED! RESETTING")
                    ResetHunt(hunt)
                end
            elseif hunt.trackspawned == hunt.numtrackstospawn then
                if SpawnHuntedBeast(hunt,pt) then
                    --print("...you found the last track, now find the beast!")
                    hunt.activeplayer:PushEvent("huntbeastnearby")
                    StartCooldown(inst, hunt)
                else
                    --print("SpawnHuntedBeast FAILED! RESETTING")
                    ResetHunt(hunt)
                end
            end
        else
            --print("SpawnTrack FAILED! RESETTING")
            ResetHunt(hunt)
        end
    end
end

function self:IsWargShrineActive()
    return _wargshrines:Get() and IsSpecialEventActive(SPECIAL_EVENTS.YOTV)
end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:LongUpdate(dt)
    for i,hunt in ipairs(_activehunts) do
        if hunt.cooldowntask ~= nil and hunt.cooldowntime ~= nil then
            hunt.cooldowntask:Cancel()
            hunt.cooldowntask = nil
            hunt.cooldowntime = hunt.cooldowntime - dt
            hunt.cooldowntask = inst:DoTaskInTime(hunt.cooldowntime - GetTime(), OnCooldownEnd, hunt)
        end
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local str = ""
    for i, hunt in ipairs(_activehunts) do
        str = str.." Cooldown: ".. (hunt.cooldowntime and string.format("%2.2f", math.max(1, hunt.cooldowntime - GetTime())) or "-")
		if hunt.trackspawned ~= nil then
			str = str .. " Track # " .. tostring(hunt.trackspawned) .. "/" .. tostring(hunt.numtrackstospawn) .. (hunt.ambush_track_num ~= nil and (" ambush at " .. tostring(hunt.ambush_track_num)) or "")
		end
        if not hunt.lastdirt then
            str = str.." No last dirt."
            --str = str.." Distance: ".. (playerdata.distance and string.format("%2.2f", playerdata.distance) or "-")
            --str = str.."/"..tostring(TUNING.MIN_HUNT_DISTANCE)
        else
            str = str.." Dirt"
            --str = str.." Distance: ".. (playerdata.distance and string.format("%2.2f", playerdata.distance) or "-")
            --str = str.."/"..tostring(TUNING.MAX_DIRT_DISTANCE)
        end
    end
    return str
end

end)
