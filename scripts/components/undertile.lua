--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ UnderTile class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

assert(TheWorld.ismastersim, "UnderTile should not exist on client")

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------

local _world = TheWorld
local _map = _world.Map

local _underneath_tiles

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function InitializeDataGrid(src, data)
    if _underneath_tiles ~= nil then return end
    _underneath_tiles = DataGrid(data.width, data.height)
end
inst:ListenForEvent("worldmapsetsize", InitializeDataGrid, _world)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:GetTileUnderneath(x, y)
    return _underneath_tiles:GetDataAtPoint(x, y)
end

function self:SetTileUnderneath(x, y, tile)
    _underneath_tiles:SetDataAtPoint(x, y, tile)
end

function self:ClearTileUnderneath(x, y)
    _underneath_tiles:SetDataAtPoint(x, y, nil)
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}

    data.underneath_tiles = _underneath_tiles:Save()

    return ZipAndEncodeSaveData(data)
end

function self:OnLoad(data)
    data = DecodeAndUnzipSaveData(data)
    if data == nil then return end

    local tile_id_conversion_map = TheWorld.tile_id_conversion_map

    _underneath_tiles:Load(data.underneath_tiles)
    for k, v in pairs(_underneath_tiles.grid) do
        _underneath_tiles.grid[k] = tile_id_conversion_map[v] or v
    end
end
 
end)