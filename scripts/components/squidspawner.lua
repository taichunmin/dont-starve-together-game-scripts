--------------------------------------------------------------------------
--[[ squidspawner class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

assert(TheWorld.ismastersim, "Squidspawner should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _activeplayers = {}
local _worldstate = TheWorld.state

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local SQUID_SPAWN_RADIUS = 6
local SQUID_TIMING = {5, 7}

local SQUID_TAGS = {"squid"}
local FISHABLE_TAGS = {"oceanfish", "oceanfishable"}

local OCEANTRAWLER_TAGS = { "oceantrawler" }
local function GetOceanTrawlerChanceModifier(spawnpoint)
    local oceantrawlers = TheSim:FindEntities(spawnpoint.x, spawnpoint.y, spawnpoint.z, TUNING.SQUID_TEST_RADIUS, OCEANTRAWLER_TAGS)
    for _, trawler in ipairs(oceantrawlers) do
        if trawler.components.oceantrawler then
            return trawler.components.oceantrawler:GetOceanTrawlerSpawnChanceModifier(spawnpoint)
        end
    end
    return 1
end

local function do_squid_spawn_for_herd(herd, spawnpoint)
    local squid = SpawnPrefab("squid")
    squid.Transform:SetPosition(spawnpoint.x, 0, spawnpoint.z)
    squid:PushEvent("spawn")
    herd.components.herd:AddMember(squid)
end

local function testforsquid(forcesquid)
    if not forcesquid and _worldstate.isday then
        return
    end

    local playerlist = shallowcopy(_activeplayers)

    local scrambled = {}
    for _=1,#_activeplayers do
        local idx = math.random(#playerlist)
        table.insert(scrambled,playerlist[idx])
        table.remove(playerlist,idx)
    end

    local moonphase_max = TUNING.SQUID_MAX_NUMBERS[_worldstate.moonphase]
    while scrambled[1] do
        local spawnpoint = scrambled[1]:GetPosition()

        local oceantrawlerchancemodifier = GetOceanTrawlerChanceModifier(spawnpoint)

        local squidcount = #TheSim:FindEntities(spawnpoint.x, spawnpoint.y, spawnpoint.z, TUNING.SQUID_TEST_RADIUS, SQUID_TAGS)
        local fishlist = TheSim:FindEntities(spawnpoint.x, spawnpoint.y, spawnpoint.z, TUNING.SQUID_TEST_RADIUS, FISHABLE_TAGS)
        local fishcount = #fishlist

        local chance = TUNING.SQUID_CHANCE[_worldstate.moonphase] * (oceantrawlerchancemodifier or 1)
        chance = Remap(math.min(fishcount, TUNING.SQUID_MAX_FISH), 0, TUNING.SQUID_MAX_FISH, 0, chance)
        if _worldstate.isnight then
            chance = chance * 2
        end

        local max

        if _worldstate.iswaxingmoon then
            chance = chance / 3
            max = 2
        else
            max = moonphase_max
        end

        if forcesquid or (squidcount < max and math.random() < chance) then
            local herd = SpawnPrefab("squidherd")
            local num = math.random(2, moonphase_max)
            for _=1,num do
                local squidspawnpoint = (fishcount ~= 0 and fishlist[math.random(fishcount)]:GetPosition())
                    or spawnpoint

                herd.Transform:SetPosition(squidspawnpoint.x, squidspawnpoint.y, squidspawnpoint.z)
                local angle = math.random()*TWOPI
                local offset = FindSwimmableOffset(squidspawnpoint,angle,SQUID_SPAWN_RADIUS)
                if offset then
                    herd:DoTaskInTime(
                        GetRandomMinMax(SQUID_TIMING[1], SQUID_TIMING[2]),
                        do_squid_spawn_for_herd,
                        squidspawnpoint + offset
                    )
                end
            end
        end

        -- remove nearby players from list
        local player = scrambled[1]
        table.remove(scrambled,1)

        if #scrambled > 0 then
            for i = #scrambled, 1, -1 do
                if player:GetDistanceSqToInst(scrambled[i]) < 1600 then -- 40*40
                    table.remove(scrambled,i)
                end
            end
        end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerJoined(src, player)
    for _, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)
end

local function OnPlayerLeft(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            table.remove(_activeplayers, i)
            return
        end
    end
end

local function spawntask()
    if _worldstate.isnight or _worldstate.isdusk then
        testforsquid()
        if inst.squidtask then
            inst.squidtask:Cancel()
            inst.squidtask = nil
        end
        inst.squidtask = inst:DoTaskInTime(TUNING.SEG_TIME + (math.random() * TUNING.SEG_TIME), inst.spawntask)
    else
        if inst.squidtask then
            inst.squidtask:Cancel()
            inst.squidtask = nil
        end
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for _, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

inst.spawntask = spawntask
spawntask()

--Register events
inst:WatchWorldState("phase", function() spawntask() end)
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------
function self:Debug_ForceTestForSquid()
    testforsquid(true)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
