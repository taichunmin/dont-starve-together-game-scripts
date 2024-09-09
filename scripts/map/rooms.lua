
require ("map/room_functions")


local rooms = {}
local modrooms = {}

local function GetRoomByName(name)
    for mod,roomset in pairs(modrooms) do
        if roomset[name] ~= nil then
            return roomset[name]
        end
    end

    return rooms[name]
end

function AddRoom(name, data)
    --print("AddRoom "..name)
    assert(GetRoomByName(name) == nil, "Adding a room '"..name.."' failed, it already exists!")
    function data:__tostring()
        return "Room: "..name
    end
    rooms[name] = data
end

function AddModRoom(mod, name, data)
    if GetRoomByName(name) ~= nil then
        moderror(string.format("Tried adding a room called '%s', but it already exists!\n\t\tRoom will not be added. Maybe try using AddRoomPreInit to extend an existing room instead?", name))
        return
    end
    if modrooms[mod] == nil then modrooms[mod] = {} end
    function data:__tostring()
        return "ModRoom: "..name
    end
    modrooms[mod][name] = data
end

-- "Special" rooms
require("map/rooms/test")

require("map/rooms/forest/pigs")
require("map/rooms/forest/merms")
require("map/rooms/forest/chess")
require("map/rooms/forest/spider")
require("map/rooms/forest/walrus")
require("map/rooms/forest/wormhole")
require("map/rooms/forest/beefalo")
require("map/rooms/forest/graveyard")
require("map/rooms/forest/tallbird")
require("map/rooms/forest/bee")
require("map/rooms/forest/mandrake")
require("map/rooms/forest/giants")

require("map/rooms/cave/bats")
require("map/rooms/cave/bluemush")
require("map/rooms/cave/fungusnoise")
require("map/rooms/cave/generic")
require("map/rooms/cave/greenmush")
require("map/rooms/cave/mud")
require("map/rooms/cave/rabbits")
require("map/rooms/cave/redmush")
require("map/rooms/cave/rocky")
require("map/rooms/cave/sinkhole")
require("map/rooms/cave/spillagmites")
require("map/rooms/cave/swamp")
require("map/rooms/cave/toadstoolarena")

require("map/rooms/cave/ruins")

-- ... adventure?
require("map/rooms/forest/blockers")
require("map/rooms/forest/starts")

-- "Background" rooms

require("map/rooms/forest/terrain_dirt")
require("map/rooms/forest/terrain_forest")
require("map/rooms/forest/terrain_grass")
require("map/rooms/forest/terrain_impassable")
require("map/rooms/forest/terrain_marsh")
require("map/rooms/forest/terrain_noise")
require("map/rooms/forest/terrain_rocky")
require("map/rooms/forest/terrain_savanna")
require("map/rooms/forest/terrain_moonisland")
require("map/rooms/forest/terrain_ocean")

require("map/rooms/cave/terrain_mazes")

require("map/rooms/forest/DLCrooms")

------------------------------------------------------------------------------------
-- EXIT ROOM -----------------------------------------------------------------------
------------------------------------------------------------------------------------
AddRoom("Exit", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = WORLD_TILES.FOREST,
					contents =  {
					                countprefabs= {
					                	teleportato_base = 1,
					                    spiderden = function () return 5 + math.random(3) end,
					                    gravestone = function () return 4 + math.random(4) end,
					                    mound = function () return 4 + math.random(4) end
					                }
					            }
					})


------------------------------------------------------------------------------------
-- BLANK ROOM ----------------------------------------------------------------------
------------------------------------------------------------------------------------
AddRoom("Blank", {
					colour={r=1.0,g=1.0,b=1.0,a=0.1},
					value = WORLD_TILES.IMPASSABLE,
                    type = NODE_TYPE.Blank,
					contents =  {
					            }
					})


local function ClearModData(mod)
    if mod ~= nil then
        modrooms[mod] = nil
    else
        modrooms = {}
    end
end

return {
    GetRoomByName = GetRoomByName,
    ClearModData = ClearModData,
}
