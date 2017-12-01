--------------------------------------------------------------------------
-- Initialize should be called once only during world initializtion
-- after MODs have finished loading and modifying GLOBAL.EQUIPSLOTS

local EQUIPSLOT_NAMES, EQUIPSLOT_IDS
local function InitializeSlots()
    assert(EQUIPSLOT_NAMES == nil and EQUIPSLOT_IDS == nil, "Equip slots already initialized")

    EQUIPSLOT_NAMES = {}
    for k, v in pairs(EQUIPSLOTS) do
        table.insert(EQUIPSLOT_NAMES, v)
    end

    assert(#EQUIPSLOT_NAMES <= 63, "Too many equip slots!")

    EQUIPSLOT_IDS = table.invert(EQUIPSLOT_NAMES)
end

--------------------------------------------------------------------------
-- These are meant for networking, and can be used in prefab or
-- component logic. They are not valid when modmain is loading.

local function EquipSlotToID(eslot)
    return EQUIPSLOT_IDS[eslot]
end

local function EquipSlotFromID(eslotid)
    return EQUIPSLOT_NAMES[eslotid]
end

local function GetCount()
    return #EQUIPSLOT_NAMES
end

--------------------------------------------------------------------------
return
{
    --Internal use
    Initialize = InitializeSlots,

    --Valid only after initialization
    ToID = EquipSlotToID,
    FromID = EquipSlotFromID,
    Count = GetCount,
}
