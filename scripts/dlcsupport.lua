MAIN_GAME = 0
REIGN_OF_GIANTS = 1

DONT_STARVE_TOGETHER_APPID = 322330
DONT_STARVE_APPID = 219740

NO_DLC_TABLE = {REIGN_OF_GIANTS=false}
ALL_DLC_TABLE = {REIGN_OF_GIANTS=true}
MENU_DLC_LIST = {}
DLC_LIST = {REIGN_OF_GIANTS}

RegisteredDLC = {}
ActiveDLC = {}

-----------------------  locals ------------------------------------------

local function AddPrefab(prefabName)
   for i,v in pairs(PREFABFILES) do
      if v==prefabName then
         return
      end
   end
   PREFABFILES[#PREFABFILES+1] = prefabName
end


local function GetDLCPrefabFiles(filename)
    print("Load "..filename)
    local fn, r = loadfile(filename)
    assert(fn, "Could not load file ".. filename)
    if type(fn) == "string" then
        assert(false, "Error loading file "..filename.."\n"..fn)
    end
    assert( type(fn) == "function", "Prefab file doesn't return a callable chunk: "..filename)
    local ret = fn()
    return ret
end


local function RegisterPrefabs(index)
    local dlcPrefabFilename = string.format("scripts/DLC%03d_prefab_files",index)
    local dlcprefabfiles = GetDLCPrefabFiles(dlcPrefabFilename)
    for i,v in pairs(dlcprefabfiles) do
        AddPrefab(v)
    end
end

-- Load the base prefablist and merge in all additional prefabs for the DLCs
local function ReloadPrefabList()
    for i,v in pairs(RegisteredDLC) do
            RegisterPrefabs(i)
    end
end


-----------------------  globals ------------------------------------------

function RegisterAllDLC()
    for i=1,10 do
        local filename = string.format("scripts/DLC%04d",i)
        local fn, r = loadfile(filename)
        if (type(fn) == "function") then
             local ret = fn()
             RegisteredDLC[i] = ret
        else
             RegisteredDLC[i] = nil
        end
    end
    ReloadPrefabList()
end

function RegisterDLC( index )
    for i=1,10 do
         RegisteredDLC[i] = nil
    end
    local filename = string.format("scripts/DLC%04d",index)
    local fn, r = loadfile(filename)
    if (type(fn) == "function") then
         local ret = fn()
         RegisteredDLC[index] = ret
    else
         RegisteredDLC[index] = nil
    end
    ReloadPrefabList()
end

-- This one is somewhat important, it can be used to load prefabs that are not referenced by any prefab and thus not loaded
function InitAllDLC()
    for i,v in pairs(RegisteredDLC) do
        if v.Setup then
            v.Setup()
        end
    end
end
function InitDLC(index)
    if RegisteredDLC[index].Setup then
        RegisteredDLC[index].Setup()
    end
end

function GetActiveCharacterList()
    return JoinArrays(DST_CHARACTERLIST, MODCHARACTERLIST)
end

function GetSelectableCharacterList()
    -- NOTES(JBK): Players are not allowed to pick SEAMLESSSWAP_CHARACTERLIST and must be done through in game methods.
    return ExceptionArrays(JoinArrays(DST_CHARACTERLIST, MODCHARACTERLIST), SEAMLESSSWAP_CHARACTERLIST)
end

function GetFEVisibleCharacterList()
    local all = {}    
    for i,character in ipairs(DST_CHARACTERLIST) do
        local add_char = true
        if character == "wonkey" and TheGenericKV:GetKV("wonkey_played") ~= "played" then --only show wonkey if we've played him
            add_char = false
        end
        if add_char then
            table.insert( all, character )
        end
    end
    return all 
end

function DisableDLC(index)
    TheSim:SetDLCEnabled(index,false)
end

function EnableExclusiveDLC(index)
	DisableAllDLC()
	EnableDLC(index)
end

function EnableDLC(index)
    TheSim:SetDLCEnabled(index,true)
end

function IsDLCEnabled(index)
    return TheSim:IsDLCEnabled(index)
end

function IsDLCInstalled(index)
    return TheSim:IsDLCInstalled(index)
end

function EnableAllDLC()
    for i,v in pairs(DLC_LIST) do
        EnableDLC(v)
    end
end

function DisableAllDLC()
    for i,v in pairs(DLC_LIST) do
        DisableDLC(v)
    end
end

function EnableAllMenuDLC()
    DisableAllDLC()
    for i,v in pairs(MENU_DLC_LIST) do
        EnableDLC(v)
    end
end

