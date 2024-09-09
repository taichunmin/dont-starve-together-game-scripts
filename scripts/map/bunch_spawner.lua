
require "prefabutil"
require "maputil"

local bunches = require "map/bunches"

local bunch = {}
local entities = {}
local WIDTH = 0
local HEIGHT = 0

local function setEntity(prop, x, z)
    if entities[prop] == nil then
        entities[prop] = {}
    end

    local scenario = nil

    --local save_data = {x= (x - WIDTH/2.0)*TILE_SCALE , z= (z - HEIGHT/2.0)*TILE_SCALE}
    local save_data = {x=x , z= z}
    table.insert(entities[prop], save_data)
end

local function exportSpawnersToEntites(add_entity_fn)
	local fn = add_entity_fn or setEntity
    for _, item in ipairs(bunch) do
        fn(item.prefab, item.x, item.z)
    end
end

local function getdiv1tile(x,y,z)
    local fx,fy,fz = x,y,z

    fx = x - ( math.fmod(x,1) )
    fz = z - ( math.fmod(z,1) )

    return fx,fy,fz
end

local function checkIfValidGround(world, x, z, valid_tile_types, water)
    -- 0.25 was added here because maybe the point thigns are measured from is 1 game unit off? Seems to work?
    x = math.floor((WIDTH/2)+0.5 + (x/TILE_SCALE))
    z = math.floor((HEIGHT/2)+0.5 + (z/TILE_SCALE))

	if x > OCEAN_POPULATION_EDGE_DIST and x < (WIDTH - OCEAN_POPULATION_EDGE_DIST)
            and z > OCEAN_POPULATION_EDGE_DIST and z < (HEIGHT - OCEAN_POPULATION_EDGE_DIST) then
		local original_tile_type = world:GetTile(x, z)
		if not TileGroupManager:IsInvalidTile(original_tile_type) then
			if valid_tile_types then
				for _, tiletype in ipairs(valid_tile_types)do
					if original_tile_type == tiletype then
						return true
					end
				end
			end
		end
    end
    return false
end

local function AddTempEnts(data,x,z,prefab)
    table.insert(data, {
        x = x,
        z = z,
        prefab = prefab,
    })

    return data
end

local function findEntsInRange(x,z,range)
    local ents = {}

    local dist = range*range

    for _, item in ipairs(bunch) do
        local xdif = math.abs(x - item.x)
        local zdif = math.abs(z - item.z)
        if (xdif*xdif) + (zdif*zdif) < dist then
            table.insert(ents,item)
        end
    end

    return ents
end

local function checkforblockingitems(x,z)
    local spawnOK = true

    for _, prefab in ipairs(bunches.BunchBlockers) do
        local dist = 16 -- 4*4
        if entities[prefab] then
            for __, ent in ipairs( entities[prefab] ) do
                local xdif = math.abs(x - ent.x)
                local zdif = math.abs(z - ent.z)
                if (xdif*xdif) + (zdif*zdif) < dist then
                    spawnOK = false
                end
            end
        else
            print(">>> BUNCH SPAWN ERROR?",prefab)
        end
    end
    return spawnOK
end

local function placeitemoffgrids(world, x1,z1, data)

    local spot_clear = false
    local x,z = nil,nil
    local tries = 0
    while spot_clear == false and tries < 20 do

        local radiusMax = data.range
        local rad = math.pow(math.random(),0.8)*radiusMax --math.sqrt(math.random())*radiusMax
        local xdiff = math.random()*rad
        local zdiff = math.sqrt( (rad*rad) - (xdiff*xdiff))

        if math.random() > 0.5 then
            xdiff= -xdiff
        end

        if math.random() > 0.5 then
            zdiff= -zdiff
        end
        x = x1+ xdiff
        z = z1+ zdiff

        local ents = findEntsInRange(x,z,data.min_spacing or 1)
        local test = true
        if #ents > 0 then
            test = false
        end
        tries = tries + 1
        spot_clear = test
    end
    if x and z and checkIfValidGround(world, x, z, data.valid_tile_types, data.water) and checkforblockingitems(x,z) then
        local prefab = data.prefab
        if type(prefab) == "function" then
            local spawnerx = math.floor((WIDTH/2)+0.5 + (x/TILE_SCALE))
            local spawnerz = math.floor((HEIGHT/2)+0.5 + (z/TILE_SCALE))
            prefab = prefab(world, spawnerx, spawnerz)
        end
        if prefab ~= nil then
            AddTempEnts(bunch,x,z,prefab)
        end
    end
end

function BunchSpawnerInit(ents, map_width, map_height)
    entities = ents
    WIDTH = map_width
    HEIGHT = map_height
end

function BunchSpawnerRunSingleBatchSpawner(world, spawner_prefab, x, z, add_entity_fn)
    bunch = {}

	local data = bunches.Bunches[spawner_prefab]
	if data ~= nil then
		local number = math.random(data.min, data.max)

		for i=1,number do
			placeitemoffgrids(world, x, z, data)
		end

		exportSpawnersToEntites(add_entity_fn)
	else
		print("Warning: Could not find bunch spawner data for: " .. tostring(spawner_prefab))
	end
end

function BunchSpawnerRun(world, add_entity_fn)

    for spawner_prefab, _ in pairs(bunches.Bunches)do
        if entities[spawner_prefab] then
            for _, ent in ipairs(entities[spawner_prefab]) do
                BunchSpawnerRunSingleBatchSpawner(world, spawner_prefab, ent.x, ent.z, add_entity_fn)
            end
        end
    end

    return entities
end

function IsBunchSpawner(prefab)
	return bunches.Bunches[prefab] ~= nil
end