--------------------------------------------------------------------------
--[[ squidspawner class definition ]]
--------------------------------------------------------------------------
local FISH_DATA = require("prefabs/oceanfishdef")

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
local _map = TheWorld.Map

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local SQUID_SPAWN_RADIUS = 6
local SQUID_TIMING = {5, 7}

local SQUID_TAGS = {"squid"}
local FISHABLE_TAGS = {"oceanfish", "oceanfishable"}
local function testforsquid(comp, forcesquid)

    if not TheWorld.state.isday then
        local playerlist = {}
        for i,player in pairs(_activeplayers)do
            table.insert(playerlist,player)
        end

        local scrambled = {}
        for i=1,#_activeplayers do
            local idx = math.random(1,#playerlist)
            table.insert(scrambled,playerlist[idx])
            table.remove(playerlist,idx)
        end

        while scrambled[1] do
            local spawnpoint = Vector3(scrambled[1].Transform:GetWorldPosition())

        --    local tile_at_spawnpoint = TheWorld.Map:GetTileAtPoint(spawnpoint:Get())
        --    if tile_at_spawnpoint == GROUND.OCEAN_SWELL or tile_at_spawnpoint == GROUND.OCEAN_ROUGH then

            local squidcount = #TheSim:FindEntities(spawnpoint.x, spawnpoint.y, spawnpoint.z, TUNING.SQUID_TEST_RADIUS, SQUID_TAGS)
            local fishlist = TheSim:FindEntities(spawnpoint.x, spawnpoint.y, spawnpoint.z, TUNING.SQUID_TEST_RADIUS, FISHABLE_TAGS)
            local fishcount = #fishlist

            local chance = TUNING.SQUID_CHANCE[TheWorld.state.moonphase]
            chance = Remap(math.min(fishcount,TUNING.SQUID_MAX_FISH), 0, TUNING.SQUID_MAX_FISH, 0, chance)
            if TheWorld.state.isnight then
                chance = chance * 2
            end

            local max = TUNING.SQUID_MAX_NUMBERS[TheWorld.state.moonphase]

            if TheWorld.state.iswaxingmoon then
                chance = chance / 3
                max = 2
            end

            if (squidcount < max and  math.random() < chance ) or forcesquid then
                local herd = SpawnPrefab("squidherd")
                local num = math.random(2,TUNING.SQUID_MAX_NUMBERS[TheWorld.state.moonphase])
                for i=1,num do

                    local squidspawnpoint = Vector3(fishlist[math.random(1,#fishlist)].Transform:GetWorldPosition())

                    herd.Transform:SetPosition(squidspawnpoint.x, squidspawnpoint.y, squidspawnpoint.z)
                    local angle = math.random()* 2 * PI
                    local offset = FindSwimmableOffset(squidspawnpoint,angle,SQUID_SPAWN_RADIUS)
                    if offset then
                        comp.inst:DoTaskInTime(GetRandomMinMax(SQUID_TIMING[1], SQUID_TIMING[2]),function()
                            local squid = SpawnPrefab("squid")
                            squid.Transform:SetPosition(squidspawnpoint.x+offset.x,0,squidspawnpoint.z+offset.z)
                            squid:PushEvent("spawn")
                            herd.components.herd:AddMember(squid)
                        end)
                    end
                end
            end

            -- remove nearby players from list
            local player = scrambled[1]
            table.remove(scrambled,1)

            if #scrambled > 0 then
                for i = #scrambled, 1, -1 do
                    if player:GetDistanceSqToInst(scrambled[i]) < 40 * 40 then
                        table.remove(scrambled,i)
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------
--[[
local function OnTargetSleep(target)
    inst:DoTaskInTime(0, AutoRemoveTarget, target)
end
]]
local function OnPlayerJoined(src, player)
    for i, v in ipairs(_activeplayers) do
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

local function onschoolspawned(src,data)
    testforsquid(self,data.spawnpoint)
end

local function spawntask()
    if TheWorld.state.isnight or TheWorld.state.isdusk then
        testforsquid(self)
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
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

--Register events
--inst:ListenForEvent("moonphasechanged",moonphasechanged, TheWorld)
--inst:ListenForEvent("phasechanged",phasechanged, TheWorld)
--inst:ListenForEvent("schoolspawned",onschoolspawned, TheWorld)
inst.spawntask = spawntask
spawntask()

inst:WatchWorldState("phase", function() spawntask() end)
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)


--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    return
    {
    --    maxbirds = _maxschools,
    --    minspawndelay = _minspawndelay,
    --    maxspawndelay = _maxspawndelay,
    --    lastsquidattack = _lastsquidattack
    }
end

function self:OnLoad(data)
   -- _maxschools = data.maxbirds or TUNING.SCHOOL_SPAWN_MAX
   -- _minspawndelay = data.minspawndelay or TUNING.SCHOOL_SPAWN_DELAY.min
   -- _maxspawndelay = data.maxspawndelay or TUNING.SCHOOL_SPAWN_DELAY.max
   -- _lastsquidattack = data.lastsquidattack or GetTime()
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------
--[[
function self:GetDebugString()
    local numschools = 0
    for k, v in pairs(_schools) do
        numschools = numschools + 1
    end
    return string.format("schools:%d/%d", numschools, _maxschools)
end
]]

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
