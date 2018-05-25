--------------------------------------------------------------------------
--[[ ChessUnlocks class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "ChessUnlocks should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local CHESS_UNLOCKS =
{
    ["pawn"] = {},
    ["bishop"] = { "trinket_15", "trinket_16" },
    ["rook"] = { "trinket_28", "trinket_29" },
    ["knight"] = { "trinket_30", "trinket_31" },
    ["muse"] = {},
    ["formal"] = {},
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _lockedsketches = {}
local _lockedtrinkets = {}
local _numlockedsketches = 0
local _numlockedtrinkets = 0

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function LockSketch(prefab)
    if not _lockedsketches[prefab] then
        _lockedsketches[prefab] = true
        _numlockedsketches = _numlockedsketches + 1
    end
end

local function UnlockSketch(prefab)
    if _lockedsketches[prefab] then
        _lockedsketches[prefab] = nil
        _numlockedsketches = _numlockedsketches - 1
    end
end

local function LockTrinket(prefab)
    if not _lockedtrinkets[prefab] then
        _lockedtrinkets[prefab] = true
        _numlockedtrinkets = _numlockedtrinkets + 1
    end
end

local function UnlockTrinket(prefab)
    if _lockedtrinkets[prefab] then
        _lockedtrinkets[prefab] = nil
        _numlockedtrinkets = _numlockedtrinkets - 1
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnUnlockChesspiece(inst, chesspiece)
    local trinkets = CHESS_UNLOCKS[chesspiece]
    if trinkets ~= nil then
        UnlockSketch("chesspiece_"..chesspiece.."_sketch")
        for _, trinket in ipairs(trinkets) do
            UnlockTrinket(trinket)
        end
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

for chesspiece, trinkets in pairs(CHESS_UNLOCKS) do
    LockSketch("chesspiece_"..chesspiece.."_sketch")
    for _, trinket in ipairs(trinkets) do
        LockTrinket(trinket)
    end
end

inst:ListenForEvent("ms_unlockchesspiece", OnUnlockChesspiece)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:IsLocked(prefab)
    return _lockedsketches[prefab] or _lockedtrinkets[prefab]
end

function self:GetNumLockedSketches()
    return _numlockedsketches
end

function self:GetNumLockedTrinkets()
    return _numlockedtrinkets
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}
    for chesspiece, _ in pairs(CHESS_UNLOCKS) do
        if not _lockedsketches["chesspiece_"..chesspiece.."_sketch"] then
            table.insert(data, chesspiece)
        end
    end
    return data ~= nil and { unlocks = data } or nil
end

function self:OnLoad(data)
    if data ~= nil and data.unlocks ~= nil then
        for i, v in ipairs(data.unlocks) do
            OnUnlockChesspiece(inst, v)
        end
    end
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
