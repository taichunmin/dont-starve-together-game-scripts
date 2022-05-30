--------------------------------------------------------------------------
--[[ SchoolSpawner class definition ]]
--------------------------------------------------------------------------
local FISH_DATA = require("prefabs/oceanfishdef")

return Class(function(self, inst)

assert(TheWorld.ismastersim, "SchoolSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _scheduledtasks = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local GNARWAIL_SPAWN_RADIUS = 10
local GNARWAIL_TIMING = {8, 10} -- min 8, max 10
local GNARWAIL_TAGS = { "gnarwail" }
local function testforgnarwail(comp, spawnpoint)
    local ents = TheSim:FindEntities(spawnpoint.x, spawnpoint.y, spawnpoint.z, TUNING.GNARWAIL_TEST_RADIUS, GNARWAIL_TAGS)
    if #ents < 2 and math.random() < TUNING.GNARWAIL_SPAWN_CHANCE then
        local offset = FindSwimmableOffset(spawnpoint, math.random()*2*PI, GNARWAIL_SPAWN_RADIUS)
        if offset then
            comp.inst:DoTaskInTime(GetRandomMinMax(GNARWAIL_TIMING[1], GNARWAIL_TIMING[2]), function()
                local spawn_x = spawnpoint.x + offset.x
                local spawn_z = spawnpoint.z + offset.z

                -- Make sure a boat didn't roll over our spawn point during the delay
                if TheWorld.Map:GetPlatformAtPoint(spawn_x, spawn_z) == nil then
                    local gnarwail = SpawnPrefab("gnarwail")
                    gnarwail.Transform:SetPosition(spawn_x, 0, spawn_z)
                    gnarwail.sg:GoToState("emerge")
                end
            end)
        end
    end
end

local SHARK_SPAWN_RADIUS = 20
local SHARK_TIMING = {8, 10} -- min 8, max 10
local SHARK_TAGS = { "shark" }
local function testforshark(comp, spawnpoint)
    local ents = TheSim:FindEntities(spawnpoint.x, spawnpoint.y, spawnpoint.z, TUNING.SHARK_TEST_RADIUS, SHARK_TAGS)
    if #ents < 2 and math.random() < TUNING.SHARK_SPAWN_CHANCE then
        local offset = FindSwimmableOffset(spawnpoint, math.random()*2*PI, SHARK_SPAWN_RADIUS)
        if offset then
            comp.inst:DoTaskInTime(GetRandomMinMax(SHARK_TIMING[1], SHARK_TIMING[2]), function()
                local spawn_x = spawnpoint.x + offset.x
                local spawn_z = spawnpoint.z + offset.z

                if TheWorld.Map:GetPlatformAtPoint(spawn_x, spawn_z) == nil then
                    local shark = SpawnPrefab("shark")
                    shark.Transform:SetPosition(spawn_x, 0, spawn_z)

                    -- The shark is spawned in the ocean, but amphibiouscreature defaults to the land state.
                    -- However, "eat_pre" prevents amphibiouscreature from updating properly, so we can just do the transition pre-emptively here,
                    -- since we know it will be correct (our ocean testing is more rigorous than theirs).
                    shark.components.amphibiouscreature:OnEnterOcean()
                    shark.sg:GoToState("eat_pre")

                    local player = FindClosestPlayerInRangeSq(spawn_x, 0, spawn_z, 20*20, true)
                    if player then
                        shark:ForceFacePoint(player.Transform:GetWorldPosition())
                    end
                end
            end)
        end
    end
end

local function SpawnSchoolForPlayer(player, reschedule)
    if self:ShouldSpawnANewSchoolForPlayer(player) then
        local spawnpoint = self:GetSpawnPoint(player:GetPosition())
        if spawnpoint ~= nil then
            self:SpawnSchool(spawnpoint, player)
        end
    end

    _scheduledtasks[player] = nil
    reschedule(player)
end

local function ScheduleSpawn(player)
    if _scheduledtasks[player] == nil then
        _scheduledtasks[player] = player:DoTaskInTime(GetRandomMinMax(TUNING.SCHOOL_SPAWN_DELAY.min, TUNING.SCHOOL_SPAWN_DELAY.max), SpawnSchoolForPlayer, ScheduleSpawn)
    end
end

local function CancelSpawn(player)
    if _scheduledtasks[player] ~= nil then
        _scheduledtasks[player]:Cancel()
        _scheduledtasks[player] = nil
    end
end

local function PickSchool(spawnpoint)
	if FISH_DATA.school[TheWorld.state.season] ~= nil then
		local school_choices = FISH_DATA.school[TheWorld.state.season][TheWorld.Map:GetTileAtPoint(spawnpoint.x,spawnpoint.y,spawnpoint.z)]
		local schooltype = school_choices and weighted_random_choice(school_choices) or nil
		return schooltype ~= nil and FISH_DATA.fish[schooltype] or nil
	end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerJoined(src, player)
	ScheduleSpawn(player)
end

local function OnPlayerLeft(src, player)
    CancelSpawn(player)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    ScheduleSpawn(player)
end

--Register events
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

local FISHSCHOOLSPAWNBLOCKER_TAGS = {"fishschoolspawnblocker"}
local FISHABLE_MUST_TAGS = {"oceanfish", "oceanfishable"}
function self:ShouldSpawnANewSchoolForPlayer(player)
	local pt = player:GetPosition()
	local percent_ocean = TheWorld.Map:CalcPercentOceanTilesAtPoint(pt.x, pt.y, pt.z, 25)

	if percent_ocean > TUNING.SCHOOL_SPAWNER_FISH_OCEAN_PERCENT then
		local num_school_spawn_blockers = #TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.SCHOOL_SPAWNER_FISH_CHECK_RADIUS, FISHSCHOOLSPAWNBLOCKER_TAGS)
		if math.random() < 1 - num_school_spawn_blockers * TUNING.SCHOOL_SPAWNER_BLOCKER_MOD then
			local num_fish = #TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.SCHOOL_SPAWNER_FISH_CHECK_RADIUS, FISHABLE_MUST_TAGS)
			local r = math.random()
			return num_fish == 0 and (r < percent_ocean)
					or num_fish <= TUNING.SCHOOL_SPAWNER_MAX_FISH and (r < (1/(num_fish + 1))*percent_ocean)
					or false
			end
	end

	return false
end

function self:GetSpawnPoint(pt)
    local function TestSpawnPoint(offset)
        return PickSchool(pt + offset) and TheWorld.Map:IsOceanAtPoint((pt + offset):Get())
    end

    local theta = math.random() * 2 * PI
	local resultoffset = FindValidPositionByFan(theta, 5 + math.random() * 4, 8, TestSpawnPoint)
						or FindValidPositionByFan(theta, 10 + math.random() * 4, 12, TestSpawnPoint)
						or FindValidPositionByFan(theta, 15 + math.random() * 4, 16, TestSpawnPoint)
						or nil

    if resultoffset ~= nil then
        return pt + resultoffset
    end
end

local function DoSpawnFish(prefab, pos, rot, herd)
    if herd:IsValid() then
        local fish = SpawnPrefab(prefab)
        fish.Physics:Teleport(pos:Get())
        fish.Transform:SetRotation(rot)
        fish.components.herdmember:Enable(true)
        fish.components.herdmember.herdprefab = herd.prefab
        fish.sg:GoToState("arrive")

    	herd.components.herd:AddMember(fish)
    end
end

function self:SpawnSchool(spawnpoint, target, override_spawn_offset)
    local schooldata = PickSchool(spawnpoint)
    if schooldata == nil then
        return
    end

	local herd = SpawnPrefab("schoolherd_"..schooldata.prefab)
	herd.Transform:SetPosition(spawnpoint:Get())

    local schoolsize = math.random(schooldata.schoolmin, schooldata.schoolmax)
    local rotation = math.random()*360

    local school_rand_angle = math.random()*360
    local school_spawnpoint = spawnpoint + (override_spawn_offset
                                            or FindSwimmableOffset(spawnpoint, school_rand_angle, 20, 12, nil, nil, nil, true)
											or FindSwimmableOffset(spawnpoint, school_rand_angle, 13, 12, nil, nil, nil, true)
											or FindSwimmableOffset(spawnpoint, school_rand_angle, 7, 12, nil, nil, nil, true)
											or Vector3(0,0,0))

    local count = 0
    for i = 1, schoolsize do
        local radius = math.sqrt(math.random())*schooldata.schoolrange
        local angle = math.random()*360

        local offset = FindSwimmableOffset(school_spawnpoint, angle, radius, 12, true, nil, nil, true)
        if offset then
			if count == 0 then
				DoSpawnFish(schooldata.prefab, school_spawnpoint + offset, rotation, herd)
			else
	            self.inst:DoTaskInTime(0.1+math.random()*1,function() DoSpawnFish(schooldata.prefab, school_spawnpoint + offset, rotation, herd) end)
			end
            count = count + 1
        end
    end

	--print("[schools - SpawnSchool] Spawned " .. tostring(count) .. "x " .. tostring(schooldata.prefab) .. " for " .. tostring(target))

    if count > 0 then
		SpawnPrefab("fishschoolspawnblocker").Transform:SetPosition(spawnpoint:Get())

        self.inst:PushEvent("schoolspawned", {spawnpoint = spawnpoint})

        local tile_at_spawnpoint = TheWorld.Map:GetTileAtPoint(spawnpoint:Get())
        if tile_at_spawnpoint == GROUND.OCEAN_SWELL or tile_at_spawnpoint == GROUND.OCEAN_ROUGH then
            testforgnarwail(self, spawnpoint)
            testforshark(self, spawnpoint)
        end
	else
		herd:Remove()
		herd = nil
    end

    return count
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    return
    {
    }
end

function self:OnLoad(data)
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local str = nil
	for k, t in pairs(_scheduledtasks) do

		local pt = k:GetPosition()
		local percent_ocean = TheWorld.Map:CalcPercentOceanTilesAtPoint(pt.x, pt.y, pt.z, 25)
		str = (str == nil and "" or "\n")..tostring(k).." in "..string.format("%.2f", GetTaskRemaining(t)).." ocean = "..string.format("%.2f", percent_ocean).."%"
	end
	return str or "no scheduled tasks"
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
