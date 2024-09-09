local PopupDialogScreen = require "screens/redux/popupdialog"
local WorldGenScreen = require "screens/worldgenscreen"
local HealthWarningPopup = require "screens/healthwarningpopup"
local Stats = require("stats")

local DebugNodes = CAN_USE_DBUI and require("dbui_no_package/debug_nodes") or nil
local DebugConsole = CAN_USE_DBUI and require("dbui_no_package/debug_console") or nil

require "scheduler"
--require "skinsutils"

local DEBUG_MODE = BRANCH == "dev"

SimTearingDown = false
SimShuttingDown = false
PerformingRestart = false

function SavePersistentString(name, data, encode, callback)
    if TheFrontEnd then
        TheFrontEnd:ShowSavingIndicator()
        local function cb()
            TheFrontEnd:HideSavingIndicator()
            if callback then
                callback()
            end
        end
        TheSim:SetPersistentString(name, data, encode or false, cb)
    else
        TheSim:SetPersistentString(name, data, encode or false, callback)
    end
end

function ErasePersistentString(name, callback)
    if TheFrontEnd then
        TheFrontEnd:ShowSavingIndicator()
        local function cb()
            TheFrontEnd:HideSavingIndicator()
            if callback then
                callback()
            end
        end
        TheSim:ErasePersistentString(name, cb)
    else
        TheSim:ErasePersistentString(name, callback)
    end
end

function Print( msg_verbosity, ... )
    if msg_verbosity <= VERBOSITY_LEVEL then
        print( ... )
    end
end

function SecondsToTimeString( total_seconds )
    local minutes = math.floor(total_seconds / 60)
    local seconds = math.floor(total_seconds - minutes*60)

    if minutes > 0 then
        return string.format("%d:%02d", minutes, seconds)
    elseif seconds > 9 then
        return string.format("%02d", seconds)
    else
        return string.format("%d", seconds)
    end
end

---PREFABS AND ENTITY INSTANTIATION

function ShouldIgnoreResolve( filename, assettype )
    if assettype == "INV_IMAGE" then
        return true
    end
    if assettype == "MINIMAP_IMAGE" then
        return true
    end
    if filename:find(".dyn") and assettype == "PKGREF" then
        return true
    end

    if TheNet:IsDedicated() then
        if assettype == "SOUNDPACKAGE" then
            return true
        end
        if assettype == "SOUND" then
            return true
        end
        if filename:find(".ogv") then
            return true
        end
        if filename:find(".fev") and assettype == "PKGREF" then
            return true
        end
        if filename:find("fsb") then
            return true
        end
	end
    return false
end


local modprefabinitfns = {}

function RegisterPrefabsImpl(prefab, resolve_fn)
    --print ("Register " .. tostring(prefab))
    -- allow mod-relative asset paths

    for i,asset in ipairs(prefab.assets) do
        if not ShouldIgnoreResolve(asset.file, asset.type) then
       		resolve_fn(prefab, asset)
        end
    end

    modprefabinitfns[prefab.name] = ModManager:GetPostInitFns("PrefabPostInit", prefab.name)
    Prefabs[prefab.name] = prefab

    TheSim:RegisterPrefab(prefab.name, prefab.assets, prefab.deps)
end

local function RegisterPrefabsResolveAssets(prefab, asset)
	--print(" - - RegisterPrefabsResolveAssets: " .. asset.file, debugstack())
    local resolvedpath = resolvefilepath(asset.file, prefab.force_path_search, prefab.search_asset_first_path)
    assert(resolvedpath, "Could not find "..asset.file.." required by "..prefab.name)
    TheSim:OnAssetPathResolve(asset.file, resolvedpath)
    asset.file = resolvedpath
end

local function VerifyPrefabAssetExistsAsync(prefab, asset)
	-- this is being done to prime the HDD's file cache and ensure all the assets exist before going into game
	--TheSim:VerifyFileExistsAsync(asset.file)
	TheSim:AddBatchVerifyFileExists(asset.file)
end

function RegisterPrefabs(...)
    for i, prefab in ipairs({...}) do
		RegisterPrefabsImpl(prefab, RegisterPrefabsResolveAssets)
	end
end

function RegisterSinglePrefab(prefab)
	RegisterPrefabsImpl(prefab, RegisterPrefabsResolveAssets)
end

PREFABDEFINITIONS = {}

function LoadPrefabFile( filename, async_batch_validation, search_asset_first_path )
    --not is used as cast to boolean
    --this check ensures that both values are not defined, while still allowing both to be undefined.
    assert(not async_batch_validation or not search_asset_first_path, "search_asset_first_path and async_batch_validation cannot both be defined")
    --print("Loading prefab file "..filename)
    local fn, r = loadfile(filename)
    assert(fn, "Could not load file ".. filename)
    if type(fn) == "string" then
        local error_msg = "Error loading file "..filename.."\n"..fn
        if DEBUG_MODE then
            -- Common error in development when working in a branch (we don't
            -- submit updateprefab changes in branches).
            print(error_msg)
            known_assert(false, "DEV_FAILED_TO_LOAD_PREFAB")
        end
        assert(false, error_msg)
    end
    assert( type(fn) == "function", "Prefab file doesn't return a callable chunk: "..filename)
    local ret = {fn()}

    if ret then
        for i,val in ipairs(ret) do
            if type(val)=="table" and val.is_a and val:is_a(Prefab) then
                val.search_asset_first_path = search_asset_first_path
				if async_batch_validation then
					RegisterPrefabsImpl(val, VerifyPrefabAssetExistsAsync)
				else
					RegisterSinglePrefab(val)
	            end
                PREFABDEFINITIONS[val.name] = val
            end
        end
    end

    return ret
end


local MOD_FRONTEND_PREFABS = {}
function ModUnloadFrontEndAssets(modname)
    if modname == nil then
        TheSim:UnloadPrefabs(MOD_FRONTEND_PREFABS)
        TheSim:UnregisterPrefabs(MOD_FRONTEND_PREFABS)
        MOD_FRONTEND_PREFABS = {}
    else
        local prefab = {table.removearrayvalue(MOD_FRONTEND_PREFABS, "MODFRONTEND_"..modname)}
        if not IsTableEmpty(prefab) then
            TheSim:UnloadPrefabs(prefab)
            TheSim:UnregisterPrefabs(prefab)
        end
    end
end

function ModReloadFrontEndAssets(assets, modname)
    assert(KnownModIndex:DoesModExistAnyVersion(modname), "modname "..modname.." must refer to a valid mod!")
    if assets then
        ModUnloadFrontEndAssets(modname)

        assets = shallowcopy(assets) --make a copy so that changes to the table in the mod code don't do anything funky

        for i, v in ipairs(assets) do
            local modroot = MODS_ROOT..modname.."/"
            resolvefilepath_soft(v.file, nil, modroot)
        end
        local prefab = Prefab("MODFRONTEND_"..modname, nil, assets, nil)
        table.insert(MOD_FRONTEND_PREFABS, prefab.name)
        RegisterSinglePrefab(prefab)
        TheSim:LoadPrefabs({prefab.name})
    end
end

local MOD_PRELOAD_PREFABS = {}
function ModUnloadPreloadAssets(modname)
    if modname == nil then
        TheSim:UnloadPrefabs(MOD_PRELOAD_PREFABS)
        TheSim:UnregisterPrefabs(MOD_PRELOAD_PREFABS)
        MOD_PRELOAD_PREFABS = {}
    else
        local prefab = {table.removearrayvalue(MOD_PRELOAD_PREFABS, "MODPRELOAD_"..modname)}
        if not IsTableEmpty(prefab) then
            TheSim:UnloadPrefabs(prefab)
            TheSim:UnregisterPrefabs(prefab)
        end
    end
end

function ModPreloadAssets(assets, modname)
    assert(KnownModIndex:DoesModExistAnyVersion(modname), "modname "..modname.." must refer to a valid mod!")
    if assets then
        ModUnloadPreloadAssets(modname)

        assets = shallowcopy(assets) --make a copy so that changes to the table in the mod code don't do anything funky

        for i, v in ipairs(assets) do
            local modroot = MODS_ROOT..modname.."/"
            resolvefilepath_soft(v.file, nil, modroot)
        end
        local prefab = Prefab("MODPRELOAD_"..modname, nil, assets, nil)
        table.insert(MOD_PRELOAD_PREFABS, prefab.name)
        RegisterSinglePrefab(prefab)
        TheSim:LoadPrefabs({prefab.name})
    end
end

function RegisterAchievements(achievements)
    for i, achievement in ipairs(achievements) do
        --print ("Registering achievement:", achievement.name, achievement.id.steam, achievement.id.psn)
        TheGameService:RegisterAchievement(achievement.name, achievement.id.steam, achievement.id.psn)
    end
end

function LoadAchievements( filename )
    --print("Loading achievement file "..filename)
    local fn, r = loadfile(filename)
    assert(fn, "Could not load file ".. filename)
    if type(fn) == "string" then
        assert(false, "Error loading file "..filename.."\n"..fn)
    end
    assert( type(fn) == "function", "Achievements file doesn't return a callable chunk: "..filename)
    local ret = {fn()}

    if ret then
        for i,val in ipairs(ret) do
            if type(val)=="table" then --and val.is_a and val:is_a(Achievements)then
                RegisterAchievements(val)
            end
        end
    end

    return ret
end

function AwardFrontendAchievement( name )
    if IsConsole() then
	    TheGameService:AwardAchievement(name, nil)
    end
end

function AwardPlayerAchievement( name, player )
	if IsConsole() then
        if player ~= nil and player:HasTag("player") then
		    TheGameService:AwardAchievement(name, tostring(player.userid))
	    else
		    print( "AwardPlayerAchievement Error:", name, "to", tostring(player) )
	    end
    end
end

function NotifyPlayerProgress( name, value, player )
	if IsConsole() then
        if player ~= nil and player:HasTag("player") then
		    TheGameService:NotifyProgress(name, value, tostring(player.userid))
	    else
		    print( "NotifyPlayerProgress Error:", name, "to", tostring(player) )
	    end
    end
end

function NotifyPlayerPresence( name, level, days, player )
	if IsConsole() then
        if player ~= nil and player:HasTag("player") then
		    TheGameService:NotifyPresence(name, level, days, tostring(player.userid))
	    else
		    TheGameService:NotifyPresence(name, level, days, nil)
	    end
    end
end


function AwardRadialAchievement( name, pos, radius )
	if IsConsole() then
        local players = FindPlayersInRange( pos.x, pos.y, pos.z, radius, true )
        for k,player in pairs(players) do
		    AwardPlayerAchievement(name, player)
	    end
    end
end



function SpawnPrefabFromSim(name)
    name = string.sub(name, string.find(name, "[^/]*$"))
    name = string.lower(name)

    local prefab = Prefabs[name]
    if prefab == nil then
        print( "Can't find prefab " .. tostring(name) )
        return -1
    end

    if prefab then
        local inst = prefab.fn(TheSim)

        if inst ~= nil then

            inst:SetPrefabName(inst.prefab or name)

            local modfns = modprefabinitfns[inst.prefab or name]
            if modfns ~= nil then
                for k,mod in pairs(modfns) do
                    mod(inst)
                end
            end
            if inst.prefab ~= name then
                modfns = modprefabinitfns[name]
                if modfns ~= nil then
                    for k,mod in pairs(modfns) do
                        mod(inst)
                    end
                end
            end

            for k,prefabpostinitany in pairs(ModManager:GetPostInitFns("PrefabPostInitAny")) do
                prefabpostinitany(inst)
            end

            if TheWorld then
                TheWorld:PushEvent("entity_spawned", inst)
            end

            return inst.entity:GetGUID()
        else
            print( "Failed to spawn", name )
            return -1
        end
    end
end

function PrefabExists(name)
    return Prefabs[name] ~= nil
end

function SpawnPrefab(name, skin, skin_id, creator)
    name = string.sub(name, string.find(name, "[^/]*$"))
    if skin and not IsItemId(skin) then
        print("Unknown skin", skin)
		skin = nil
    end
    local guid = TheSim:SpawnPrefab(name, skin, skin_id, creator)
    return Ents[guid]
end

function ReplacePrefab(original_inst, name, skin, skin_id, creator)
    local x,y,z = original_inst.Transform:GetWorldPosition()

    local replacement_inst = SpawnPrefab(name, skin, skin_id, creator)
    replacement_inst.Transform:SetPosition(x,y,z)

    original_inst:Remove()

    return replacement_inst
end

local function ResolveSaveRecordPosition(data)
	if data.puid ~= nil then
		local walkableplatformmanager = TheWorld.components.walkableplatformmanager
		if walkableplatformmanager ~= nil then
			local platform = walkableplatformmanager:GetPlatformWithUID(data.puid)
			if platform ~= nil then
				local x, y, z = platform.entity:LocalToWorldSpace(data.rx or 0, data.ry or 0, data.rz or 0)
				return x, y, z, platform
			end
		end
	end
	return data.x or 0, data.y or 0, data.z or 0
end

function SpawnSaveRecord(saved, newents)
    --print(string.format("~~~~~~~~~~~~~~~~~~~~~SpawnSaveRecord [%s, %s, %s]", tostring(saved.id), tostring(saved.prefab), tostring(saved.data)))
    local inst = SpawnPrefab(saved.prefab, saved.skinname, saved.skin_id)

    if inst then
		if saved.alt_skin_ids then
			inst.alt_skin_ids = saved.alt_skin_ids
		end

		local x, y, z, platform = ResolveSaveRecordPosition(saved)
		inst.Transform:SetPosition(x, y, z)
        if not inst.entity:IsValid() then
            --print(string.format("SpawnSaveRecord [%s, %s] FAILED - entity invalid", tostring(saved.id), saved.prefab))
            return nil
		elseif saved.is_snapshot_save_record then
			--V2C: We won't properly attach to platforms when restoring snapshot save records.
			--     ie. inst:GetCurrentPlatform() will likely return nil
			--     Workaround for passing our platform over to the GetSaveRecord()
			inst._snapshot_platform = platform
		end

        if newents then
            --this is kind of weird, but we can't use non-saved ids because they might collide
            if saved.id  then
                newents[saved.id] = {entity=inst, data=saved.data}
            else
                newents[inst] = {entity=inst, data=saved.data}
            end
        end

        -- Attach scenario. This is a special component that's added based on save data, not prefab setup.
        if saved.scenario or (saved.data and saved.data.scenariorunner) then
            if inst.components.scenariorunner == nil then
                inst:AddComponent("scenariorunner")
            end
            if saved.scenario then
                inst.components.scenariorunner:SetScript(saved.scenario)
            end
        end
        inst:SetPersistData(saved.data, newents)

    else
        print(string.format("SpawnSaveRecord [%s, %s] FAILED", tostring(saved.id), saved.prefab))
    end

    return inst
end

function CreateEntity(name)
    local ent = TheSim:CreateEntity()
    local guid = ent:GetGUID()
    local scr = EntityScript(ent)
    if name ~= nil then
        scr.name = name
    end
    Ents[guid] = scr
    NumEnts = NumEnts + 1
    return scr
end

local debug_entity = nil
local debug_table = nil

function OnRemoveEntity(entityguid)

    PhysicsCollisionCallbacks[entityguid] = nil

    local ent = Ents[entityguid]
    if ent then

        if debug_entity == ent then
            debug_entity = nil
        end

        BrainManager:OnRemoveEntity(ent)
        SGManager:OnRemoveEntity(ent)

        ent:KillTasks()
        NumEnts = NumEnts - 1
        Ents[entityguid] = nil

        if UpdatingEnts[entityguid] then
            UpdatingEnts[entityguid] = nil
            num_updating_ents = num_updating_ents - 1
        end

        if StaticUpdatingEnts[entityguid] then
            StaticUpdatingEnts[entityguid] = nil
        end

        if WallUpdatingEnts[entityguid] then
            WallUpdatingEnts[entityguid] = nil
        end
    end
end

function RemoveEntity(guid)
    local inst = Ents[guid]
    if inst then
        --certain things(like seamless player swapping) need to delay the despawning on a local client until they have ran their own code.
        if inst.delayclientdespawn then
            inst.delayclientdespawn_attempted = true
            return
        end
        inst:Remove()
    end
end

function PushEntityEvent(guid, event, data)
    local inst = Ents[guid]
    if inst then
        inst:PushEvent(event, data)
    end
end

function GetEntityDisplayName(guid)
    local inst = Ents[guid]
    return inst ~= nil and inst:GetDisplayName() or ""
end

------TIME FUNCTIONS

function GetTickTime()
    return TheSim:GetTickTime()
end

local ticktime = GetTickTime()
function GetTime()
    return TheSim:GetTick()*ticktime
end

function GetStaticTime()
    return TheSim:GetStaticTick()*ticktime
end

function GetTick()
    return TheSim:GetTick()
end

function GetStaticTick()
    return TheSim:GetStaticTick()
end

function GetTimeReal()
    return TheSim:GetRealTime()
end

function GetTimeRealSeconds()
    return TheSim:GetRealTime() / 1000
end

---SCRIPTING
local Scripts = {}

function LoadScript(filename)
    if not Scripts[filename] then
        local scriptfn = loadfile("scripts/" .. filename)
        assert(type(scriptfn) == "function", scriptfn)
        Scripts[filename] = scriptfn()
    end
    return Scripts[filename]
end

function RunScript(filename)
    local fn = LoadScript(filename)
    if fn then
        fn()
    end
end

function GetEntityString(guid)
    local ent = Ents[guid]

    if ent then
        return ent:GetDebugString()
    end

    return ""
end

function GetExtendedDebugString()
    if debug_entity and debug_entity.brain then
        return debug_entity:GetBrainString()
    elseif SOUNDDEBUG_ENABLED then
        return GetSoundDebugString(), 24
    elseif WORLDSTATEDEBUG_ENABLED then
        return TheWorld and TheWorld.components.worldstate and TheWorld.components.worldstate:Dump()
    end

    if TheFrontEnd and TheFrontEnd:GetActiveScreen() then
        return "Current screen:" .. TheFrontEnd:GetActiveScreen().name
    end
    return ""
end

function GetDebugString()

    local str = {}
    table.insert(str, tostring(scheduler))

    if debug_entity then
        table.insert(str, "\n-------DEBUG-ENTITY-----------------------\n")
        table.insert(str, debug_entity.GetDebugString and debug_entity:GetDebugString() or "<no debug string>")
    end

    return table.concat(str)
end

function GetDebugEntity()
    return debug_entity
end

function SetDebugEntity(inst)
    if debug_entity ~= nil and debug_entity:IsValid() then
        debug_entity.entity:SetSelected(false)
    end
    if inst ~= nil and inst:IsValid() then
        debug_entity = inst
        inst.entity:SetSelected(true)
    else
        debug_entity = nil
    end
end

function GetDebugTable()
    return debug_table
end

function SetDebugTable(tbl)
    debug_table = tbl
end

function OnEntitySleep(guid)
    local inst = Ents[guid]
    if inst then
        inst:PushEvent("entitysleep")

        if inst.OnEntitySleep then
            inst:OnEntitySleep()
        end

        inst:StopBrain()

        if inst.sg then
            SGManager:Hibernate(inst.sg)
        end

        if inst.emitter then
            EmitterManager:Hibernate(inst.emitter)
        end

        for k,v in pairs(inst.components) do

            if v.OnEntitySleep then
                v:OnEntitySleep()
            end
        end

    end
end

function OnEntityWake(guid)
    local inst = Ents[guid]
    if inst then
        inst:PushEvent("entitywake")

        if inst.OnEntityWake then
            inst:OnEntityWake()
        end

        --V2C: Note that if this needs to work properly for networked
        --     entities on clients, then should use the slower check
        --     :HasTag("INLIMBO").  But there should be no networked
        --     entities on clients that can go to sleep.
        if not inst:IsInLimbo() then
            inst:RestartBrain()
            if inst.sg then
                SGManager:Wake(inst.sg)
            end
        end

        if inst.emitter then
            EmitterManager:Wake(inst.emitter)
        end

        for k,v in pairs(inst.components) do
            if v.OnEntityWake then
                v:OnEntityWake()
            end
        end
    end
end

function OnPhysicsWake(guid)
    local inst = Ents[guid]
    if inst then
        if inst.OnPhysicsWake then
            inst:OnPhysicsWake()
        end

        for k, v in pairs(inst.components) do
            if v.OnPhysicsWake then
                v:OnPhysicsWake()
            end
        end
    end
end

function OnPhysicsSleep(guid)
    local inst = Ents[guid]
    if inst then
        if inst.OnPhysicsSleep then
            inst:OnPhysicsSleep()
        end

        for k,v in pairs(inst.components) do
            if v.OnPhysicsSleep then
                v:OnPhysicsSleep()
            end
        end
    end
end

local Paused = false
local Autopaused = false
local GameAutopaused = false

function OnServerPauseDirty(pause, autopause, gameautopause, source)
    --autopause means we are paused but we don't act like it,
    --this would be for stuff like autpausing from the map being open.

    --gameautopause means we are paused, but we really don't act like it, like not even acknowledge it at all.
    --this only occurs when a non dedicated server has all players in the lobby.
    --gameautopause has no information text, at the top of the screen, and doesn't push the sound mix that deafens the game.

    local WasPaused = Paused or Autopaused or GameAutopaused
    local IsPaused = pause or autopause or gameautopause

    local WasNormalPaused = (Paused or Autopaused) and not GameAutopaused
    local IsNormalPaused = (pause or autopause) and not gameautopause

    if WasPaused and not IsPaused then
        print("Server Unpaused")
    elseif not Paused and pause then
        print("Server Paused")
    elseif (autopause or gameautopause) and not pause then
        print("Server Autopaused")
    end

    Paused = pause
    Autopaused = autopause
    GameAutopaused = gameautopause

    if not WasNormalPaused and IsNormalPaused then
        TheMixer:PushMix("serverpause")
    elseif not IsNormalPaused then
        TheMixer:DeleteMix("serverpause")
    end

    if ThePlayer and ThePlayer.HUD then
        ThePlayer.HUD:SetServerPaused(pause)
    end

    if TheFrontEnd then
        TheFrontEnd:SetServerPauseText(pause and source or autopause and "autopause" or nil)
    end

    if TheWorld then
        TheWorld:PushEvent("serverpauseddirty", {pause = pause, autopause = autopause, gameautopause = gameautopause, source = source})
    end
end

function ReplicateEntity(guid)
    local inst = Ents[guid]

    local _ThePlayer
    if inst.isseamlessswaptarget then
        _ThePlayer = ThePlayer
        ThePlayer = inst
    end

    inst:ReplicateEntity()

    if _ThePlayer then
        ThePlayer = _ThePlayer
    end
end

function DisableLoadingProtection(guid)
    local player = Ents[guid]
    if player then
        player:DisableLoadingProtection()
    end
end

------------------------------

function PlayNIS(nisname, lines)
    local nis = require ("nis/"..nisname)
    local inst = CreateEntity()

    inst:AddComponent("nis")
    inst.components.nis:SetName(nisname)
    inst.components.nis:SetInit(nis.init)
    inst.components.nis:SetScript(nis.script)
    inst.components.nis:SetCancel(nis.cancel)
    inst.entity:CallPrefabConstructionComplete()
    inst.components.nis:Play(lines)
    return inst
end

local paused = false
local simpaused = false
local default_time_scale = 1

function IsPaused()
    return paused
end

function IsSimPaused()
    return simpaused
end

global("PlayerPauseCheck")  -- function not defined when this file included

function SetDefaultTimeScale(scale)
    default_time_scale = scale
    if not paused then
        TheSim:SetTimeScale(default_time_scale)
    end
end

---------------------------------------------------------------------
--V2C: We don't use this in DST
function SetSimPause(val)
    simpaused = val
end

function SetServerPaused(pause)
    -- Ignore if an imgui window is open & has focus
    if CAN_USE_DBUI then
		if TheFrontEnd:IsImGuiWindowFocused() then
	        return
		end
    end

    if pause == nil then pause = not TheNet:IsServerPaused(true) end
    TheNet:SetServerPaused(pause)
end

local autopausecount = 0
function SetAutopaused(autopause)
    autopausecount = autopausecount + (autopause and 1 or -1)
	if DEBUG_MODE and autopausecount < 0 or autopausecount > 5 then
		print("ERROR: autopausecount is invalid:", autopausecount)
		assert(false)
	end
    DoAutopause()
end

local craftingautopause = false
function SetCraftingAutopaused(autopause)
    craftingautopause = autopause
    DoAutopause()
end

local consoleautopausecount = 0
function SetConsoleAutopaused(autopause)
    consoleautopausecount = consoleautopausecount + (autopause and 1 or -1)
    DoAutopause()
end

function DoAutopause()
    TheNet:SetAutopaused(
        ((autopausecount > 0 and Profile:GetAutopauseEnabled())
         or (craftingautopause and Profile:GetCraftingAutopauseEnabled())
         or (consoleautopausecount > 0 and Profile:GetConsoleAutopauseEnabled())
		) and not TheFrontEnd:IsControlsDisabled()
    )
end

---------------------------------------------------------------------
--V2C: DST sim pauses via network checks, and will notify LUA here
function OnSimPaused()
    --Probably shouldn't do anything here, since sim is now paused
    --and most likely anything triggered here won't actually work.
end

function OnSimUnpaused()
    if TheWorld ~= nil then
        TheWorld:PushEvent("ms_simunpaused")
    end
end
---------------------------------------------------------------------

function SetPause(val,reason)
    if val ~= paused then
        if val then
            paused = true
            TheMixer:PushMix("pause")
        else
            paused = false
            TheMixer:PopMix("pause")
        end
    end
    if PlayerPauseCheck then   -- probably don't need this check
        PlayerPauseCheck(val, reason)  -- must be done after SetTimeScale
    end
end

--- EXTERNALLY SET GAME SETTINGS ---
Settings = {}
function SetInstanceParameters(settings)
    if settings ~= "" then
        --print("SetInstanceParameters:",settings)
        Settings = json.decode(settings)
    end
end

Purchases = {}
function SetPurchases(purchases)
    if purchases ~= "" then
        Purchases = json.decode(purchases)
    end
end


local function UpdateWorldGenOverride(overrides, cb, slot, shard)
    local Levels = require("map/levels")
    local filename = "../worldgenoverride.lua"

    local function SetPersistentString(str)
        if shard ~= nil then
            TheSim:SetPersistentStringInClusterSlot(slot, shard, filename, str, false, cb)
        else
            TheSim:SetPersistentString(filename, str, false, cb)
        end
    end

    local function GenerateWorldGenOverride(savedata)
        local out = {}
        table.insert(out, "return {")
        table.insert(out, "\toverride_enabled = true,")

        local worldgen_preset = savedata.worldgen_preset or savedata.preset
        if worldgen_preset and Levels.GetDataForWorldGenID(worldgen_preset) then
            table.insert(out, string.format("\tworldgen_preset = %q,", worldgen_preset))
        end

        local settings_preset = savedata.settings_preset or savedata.preset
        if settings_preset and Levels.GetDataForWorldGenID(settings_preset) then
            table.insert(out, string.format("\tsettings_preset = %q,", settings_preset))
        end

        table.insert(out, "\toverrides = {")
        for name, value in orderedPairs(savedata.overrides) do
            if not name:match('^[_%a][_%w]*$') then
                name = string.format("[%q]", name)
            end
            if type(value) == "string" then
                value = string.format("%q", value)
            else
                value = tostring(value)
            end
            table.insert(out, string.format("\t\t%s = %s,", name, value))
        end
        table.insert(out, "\t},")
        table.insert(out, "}")

        SetPersistentString(table.concat(out, "\n"))
    end

    local function onload(load_success, str)
        if load_success == true then
            local success, savedata = RunInSandboxSafe(str)
            if success and savedata then
                local savefileupgrades = require("savefileupgrades")
                savedata = savefileupgrades.utilities.UpgradeWorldgenoverrideFromV1toV2(savedata)
                if savedata.override_enabled then
                    local worldgen_preset = savedata.worldgen_preset or savedata.preset
                    local worldgen_presetdata = {overrides = {}}
                    if worldgen_preset then
                        worldgen_presetdata = Levels.GetDataForWorldGenID(worldgen_preset) or worldgen_presetdata
                    end

                    local settings_preset = savedata.settings_preset or savedata.preset
                    local settings_presetdata = {overrides = {}}
                    if settings_preset then
                        settings_presetdata = Levels.GetDataForSettingsID(settings_preset) or settings_presetdata
                    end

                    local location = worldgen_presetdata.location or "forest"

                    local Customize = require("map/customize")
                    local defaultoptions = Customize.GetOptionsWithLocationDefaults(location, true)

                    savedata.overrides = savedata.overrides or {}

                    for override_name, override_option in pairs(overrides) do
                        local current_option = (worldgen_presetdata.overrides[override_name] or settings_presetdata.overrides[override_name]) or defaultoptions[override_name] or Customize.GetDefaultForOption(override_name)
                        if current_option and override_option ~= current_option and Customize.IsCustomizeOption(override_name) then
                            savedata.overrides[override_name] = override_option
                        else
                            savedata.overrides[override_name] = nil
                        end
                    end

                    return GenerateWorldGenOverride(savedata)
                end
            end
        end

        if cb then
            cb()
        end
    end

    if shard ~= nil then
        TheSim:GetPersistentStringInClusterSlot(slot, shard, filename, onload)
    else
        TheSim:GetPersistentString(filename, onload)
    end
end

--isshutdown means players have been cleaned up by OnDespawn()
--and the sim will shutdown after saving
function SaveGame(isshutdown, cb)
    if not TheNet:GetIsServer() then
        print("SaveGame disabled for Clients in Don't Starve Together")
        if cb ~= nil then
            cb(true)
        end
        return
    end

    TheNet:StartWorldSave()

    local save = {}
	local savedata_entities = {}

    --print("Saving...")
    --save the entities
    local nument = 0
    local saved_ents = {}
    local references = {}
    for k, v in pairs(Ents) do
        if v.persists and v.prefab ~= nil and v.Transform ~= nil and v.entity:GetParent() == nil and v:IsValid() then
            local record, new_references = v:GetSaveRecord()
            record.prefab = nil

            if new_references ~= nil then
                references[v.GUID] = v
                for k1, v1 in pairs(new_references) do
                    references[v1] = v
                end
            end

            saved_ents[v.GUID] = record

            if savedata_entities[v.prefab] == nil then
                savedata_entities[v.prefab] = {}
            end
            table.insert(savedata_entities[v.prefab], record)
            nument = nument + 1
        end
    end

    --save out the map
    save.map =
    {
        tiles = "",
        roads = Roads,
    }

    local new_refs = nil
    local ground = TheWorld
    assert(ground ~= nil, "Cant save world without ground entity")
    if ground ~= nil then
        save.map.prefab = ground.worldprefab
        save.map.tiles = ground.Map:GetStringEncode()
        save.map.world_tile_map = GetWorldTileMap()
        save.map.tiledata = ground.Map:GetDataStringEncode()
        save.map.nav = ground.Map:GetNavStringEncode()
        save.map.nodeidtilemap = ground.Map:GetNodeIdTileMapStringEncode()
        save.map.width, save.map.height = ground.Map:GetSize()
        save.map.topology = ground.topology
        save.map.generated = ground.generated
        save.map.persistdata, new_refs = ground:GetPersistData()
        save.meta = ground.meta
        save.map.hideminimap = ground.hideminimap
		save.map.has_ocean = ground.has_ocean

        if new_refs ~= nil then
            for k, v in pairs(new_refs) do
                references[v] = ground
            end
        end

        local world_network = ground.net
        assert(world_network, "Cant save world without world_network entity")
        if world_network ~= nil then
            save.world_network = {}
            save.world_network.persistdata, new_refs = world_network:GetPersistData()

            if new_refs ~= nil then
                for k, v in pairs(new_refs) do
                    references[v] = world_network
                end
            end
        end

        local shard_network = ground.shard -- NOTES(JBK): This data is optional.
        if shard_network ~= nil then
            local persistdata, new_refs = shard_network:GetPersistData()
            if persistdata ~= nil then
                save.shard_network = {}
                save.shard_network.persistdata = persistdata
                if new_refs ~= nil then
                    for k, v in pairs(new_refs) do
                        references[v] = shard_network
                    end
                end
            end
        end
    end

    if not isshutdown and #AllPlayers > 0 then
        save.snapshot = { players = {} }
    end

    for i, player in ipairs(AllPlayers) do
        if player.userid ~= nil and player.userid:len() > 0 then
            if save.snapshot ~= nil then
                table.insert(save.snapshot.players, player.userid)
            end
            SerializeUserSession(player)
        end
    end

    for k, v in pairs(references) do
        if saved_ents[k] ~= nil then
            saved_ents[k].id = k
        else
            print("Missing reference:", v, "->", k, Ents[k])
        end
    end

    save.mods = ModManager:GetModRecords()
    save.super = WasSuUsed()

    assert(save.map, "Map missing from savedata on save")
    assert(save.map.prefab, "Map prefab missing from savedata on save")
    assert(save.map.tiles, "Map tiles missing from savedata on save")
    assert(save.map.width, "Map width missing from savedata on save")
    assert(save.map.height, "Map height missing from savedata on save")
    --assert(save.map.topology, "Map topology missing from savedata on save")
    --assert(save.ents, "Entities missing from savedata on save")
    assert(save.mods, "Mod records missing from savedata on save")

    local PRETTY_PRINT = BRANCH == "dev"

    local patterns
    if BRANCH == "dev" then
        patterns = {"=nan", "=-nan", "=inf", "=-inf"}
    else
        patterns = {"=-1.#IND", "=1.#QNAN", "=1.#INF", "=-1.#INF"}
    end

    local data = {}
    for key,value in pairs(save) do
        data[key] = DataDumper(value, nil, not PRETTY_PRINT)

		for i, corrupt_pattern in ipairs(patterns) do
			local found = string.find(data[key], corrupt_pattern, 1, true)
			if found ~= nil then
				local bad_data = string.sub(data[key], found - 100, found + 50)
				print(bad_data)
				error("Error saving game, corruption detected.")
			end
		end
    end

	-- special handling for the entities table; contents are dumped per entity rather than
	-- dumping the whole entities table at once as is done for the other parts of the save data
	data.ents = {}
	for key, value in pairs(savedata_entities) do
		data.ents[key] = DataDumper(value, nil, not PRETTY_PRINT)

		for i, corrupt_pattern in ipairs(patterns) do
			local found = string.find(data.ents[key], corrupt_pattern, 1, true)
			if found ~= nil then
				local bad_data = string.sub(data.ents[key], found - 100, found + 50)
				print(bad_data)
				error("Error saving game, entity table corruption detected.")
			end
		end
	end


    local function callback()
        if isshutdown or #AllPlayers <= 0 then
            TheNet:TruncateSnapshots(save.meta.session_identifier)
        end
        TheNet:IncrementSnapshot()
        local function onupdateoverrides()
            local function onsaved()
                local function onwritetimefile()
                    TheNet:EndWorldSave()
                    if cb ~= nil then
                        cb()
                    end
                end
                ShardGameIndex:WriteTimeFile(onwritetimefile)
            end
            ShardGameIndex:Save(onsaved)
        end
        local options = ShardGameIndex:GetGenOptions()
        --copy overrides from the world back to the shard index and worldgenoverrides.
        local overrides = deepcopy(save.map.topology.overrides)
        options.overrides = overrides
        UpdateWorldGenOverride(overrides, onupdateoverrides, ShardGameIndex:GetSlot(), ShardGameIndex:GetShard())
    end

    --todo, if we add more values to this, turn this into a function thats called both here and gamelogic.lua@DoGenerateWorld
    local metadata = {}
    if save and save.world_network and save.world_network.persistdata then
        metadata.clock = save.world_network.persistdata.clock
        metadata.seasons = save.world_network.persistdata.seasons
    end
    local metadataStr = DataDumper(metadata, nil, not PRETTY_PRINT)

    SerializeWorldSession(data, save.meta.session_identifier, callback, metadataStr)
end

function ProcessJsonMessage(message)
    --print("ProcessJsonMessage", message)

    local player = ThePlayer

    local command = TrackedAssert("ProcessJsonMessage",  json.decode, message)

    -- Sim commands
    if command.sim ~= nil then
        --print( "command.sim: ", command.sim )
        --print("Sim command", message)
        if command.sim == 'toggle_pause' then
            --TheSim:TogglePause()
            SetPause(not IsPaused())
        elseif command.sim == 'upsell_closed' then
            HandleUpsellClose()
        elseif command.sim == 'quit' then
            if player then
                player:PushEvent("quit", {})
            end
        elseif type(command.sim) == 'table' and command.sim.playerid then
            TheFrontEnd:SendScreenEvent("onsetplayerid", command.sim.playerid)
        end
    end
end

function LoadFonts()
    for k,v in pairs(FONTS) do
        TheSim:LoadFont(v.filename, v.alias, v.disable_color)
    end

    for k,v in pairs(FONTS) do
        if v.fallback and v.fallback ~= "" then
            TheSim:SetupFontFallbacks(v.alias, v.fallback)
        end
        if v.adjustadvance ~= nil then
            TheSim:AdjustFontAdvance(v.alias, v.adjustadvance)
        end
    end
end

function UnloadFonts()
    for k,v in pairs(FONTS) do
        TheSim:UnloadFont(v.alias)
    end
end

local function Check_Mods()
    if MODS_ENABLED then
        --after starting everything up, give the mods additional environment variables
        ModManager:SetPostEnv(ThePlayer)

        --By this point the game should have either a) disabled bad mods, or b) be interactive
        KnownModIndex:EndStartupSequence(nil) -- no callback, this doesn't need to block and we don't need the results
    end
end

local function CheckControllers()
    local isConnected = TheInput:ControllerConnected()
    local sawPopup = Profile:SawControllerPopup()

	if IsSteamDeck() and not TheNet:IsDedicated() then
		TheInputProxy:EnableInputDevice(1, true)
        Check_Mods()
    elseif RUN_GLOBAL_INIT and isConnected and not (sawPopup or TheNet:IsDedicated()) then

        -- store previous controller enabled state so we can revert to it, then enable all controllers
        local controllers = {}
        local numControllers = TheInputProxy:GetInputDeviceCount()
        for i = 1, (numControllers - 1) do
            local enabled = TheInputProxy:IsInputDeviceEnabled(i)
            table.insert(controllers, enabled)
        end

        -- enable all controllers so they can be used in the popup if desired
        TheInput:EnableAllControllers()

        local function enableControllers()
            -- set all connected controllers as enabled in the player profile
            for i = 1, (numControllers - 1) do
                if TheInputProxy:IsInputDeviceConnected(i) then
                    local guid, data, enabled = TheInputProxy:SaveControls(i)
                    if not(nil == guid) and not(nil == data) then
                        Profile:SetControls(guid, data, enabled)
                    end
                end
            end

            Profile:ShowedControllerPopup()
            TheFrontEnd:PopScreen() -- pop after updating settings otherwise this dialog might show again!
            Profile:Save()
            scheduler:ExecuteInTime(0.05, function() Check_Mods() end)
        end

        local function disableControllers()
            TheInput:DisableAllControllers()
            Profile:ShowedControllerPopup()
            TheFrontEnd:PopScreen() -- pop after updating settings otherwise this dialog might show again!
            Profile:Save()
            scheduler:ExecuteInTime(0.05, function() Check_Mods() end)
        end

        local function revertControllers()
            -- restore controller enabled/disabled to previous state
            for i = 1, (numControllers - 1) do
                TheInputProxy:EnableInputDevice(i, controllers[i])
            end

            Profile:ShowedControllerPopup()
            TheFrontEnd:PopScreen() -- pop after updating settings otherwise this dialog might show again!
            Profile:Save()
            scheduler:ExecuteInTime(0.05, function() Check_Mods() end)
        end

        local popup = PopupDialogScreen(STRINGS.UI.MAINSCREEN.CONTROLLER_DETECTED_HEADER, STRINGS.UI.MAINSCREEN.CONTROLLER_DETECTED_BODY,
            {
                {text=STRINGS.UI.MAINSCREEN.ENABLECONTROLLER, cb = enableControllers},
                {text=STRINGS.UI.MAINSCREEN.DISABLECONTROLLER, cb = disableControllers}
            },
            nil,
            "big"
        )
        if TheInput:ControllerAttached() then
            TheFrontEnd:StopTrackingMouse(true)
        end
        TheFrontEnd:PushScreen(popup)
    else
        if TheInput:ControllerAttached() then
            TheFrontEnd:StopTrackingMouse(true)
        end
        Check_Mods()
    end
end

function Start()
    if SOUNDDEBUG_ENABLED then
        require("debugsounds")
    end

    ---The screen manager
    TheFrontEnd = FrontEnd()
    require("gamelogic")

    known_assert(TheSim:CanWriteConfigurationDirectory(), "CONFIG_DIR_WRITE_PERMISSION")
    known_assert(TheSim:CanReadConfigurationDirectory(), "CONFIG_DIR_READ_PERMISSION")
    known_assert(TheSim:HasValidLogFile(), "CONFIG_DIR_CLIENT_LOG_PERMISSION")
    known_assert(TheSim:HasEnoughFreeDiskSpace(), "CONFIG_DIR_DISK_SPACE")

    --load the user's custom commands into the game
    TheSim:GetPersistentString("../customcommands.lua",
        function(load_success, str)
            if load_success then
                local fn = loadstring(str)
                known_assert(fn ~= nil, "CUSTOM_COMMANDS_ERROR")
                xpcall(fn, debug.traceback)
            end
        end)

    CheckControllers()

	if IsRail() and RUN_GLOBAL_INIT then
		TheFrontEnd:Fade(FADE_IN, SCREEN_FADE_TIME)
		TheFrontEnd:PushScreen( HealthWarningPopup() )
	end
end

--------------------------

exiting_game = false

-- Gets called ONCE when the sim first gets created. Does not get called on subsequent sim recreations!
function GlobalInit()
    TheSim:LoadPrefabs({ "global" })
    TheSim:LoadPrefabs(SPECIAL_EVENT_GLOBAL_PREFABS)
    TheSim:LoadPrefabs(FESTIVAL_EVENT_GLOBAL_PREFABS)
    LoadFonts()
    if PLATFORM == "PS4" then
        PreloadSounds()
    end
    TheSim:SendHardwareStats()
    FirstStartupForNetworking = true
end

function DoLoadingPortal(cb)
	local values = {}
    local screen = TheFrontEnd:GetActiveScreen()
	values.join_screen = screen ~= nil and screen.name or "other"
	values.special_event = screen ~= nil and screen.event_id or nil
	Stats.PushMetricsEvent("joinfromscreen", TheNet:GetUserID(), values)

	--No portal anymore, just fade to "white". Maybe we want to swipe fade to the loading screen?
	TheFrontEnd:Fade(FADE_OUT, SCREEN_FADE_TIME, cb, nil, nil, "white")
end

-- This is for joining a game: once we're done downloading the map, we load it and simreset
function LoadMapFile(map_name)
    local function do_load_file()
        DisableAllDLC()
        StartNextInstance({ reset_action = RESET_ACTION.LOAD_FILE, save_name = map_name })
    end

    if InGamePlay() then
        -- Must be a synchronous load if we're in any game play state (including lobby screen)
        do_load_file()
    else
        DoLoadingPortal(do_load_file)
    end
end

function JapaneseOnPS4()
    if PLATFORM=="PS4" and APP_REGION == "SCEJ" then
        return true
    end
    return false
end

function StartNextInstance(in_params)
    local match_results =
    {
        mvp_cards = TheWorld ~= nil and TheWorld.GetMvpAwards ~= nil and TheWorld:GetMvpAwards() or TheFrontEnd.match_results.mvp_cards,
        wxp_data = TheWorld ~= nil and TheWorld.GetAwardedWxp ~= nil and TheWorld:GetAwardedWxp() or TheFrontEnd.match_results.wxp_data,
        player_stats = TheWorld ~= nil and TheWorld.GetPlayerStatistics ~= nil and TheWorld:GetPlayerStatistics() or TheFrontEnd.match_results.player_stats,
        outcome = TheWorld ~= nil and TheWorld.GetMatchOutcome ~= nil and TheWorld:GetMatchOutcome() or TheFrontEnd.match_results.outcome,
    }

    if TheNet:GetIsServer() then
        NotifyLoadingState(LoadingStates.Loading, match_results)
    end

    local params = in_params or {}
    params.last_reset_action = Settings.reset_action
    params.match_results = match_results
    params.load_screen_image = global_loading_widget.image_random
    params.loading_screen_keys = BuildListOfSelectedItems(Profile, "loading")

    SimReset(params)
end

function ForceAssetReset()
    Settings.current_asset_set = "FORCERESET"
    Settings.current_world_asset = nil
    Settings.current_world_specialevent = nil
    Settings.current_world_extraevents = nil
end

function SimReset(instanceparameters)
    SimTearingDown = true

    if instanceparameters == nil then
        instanceparameters = {}
    end
    instanceparameters.last_asset_set = Settings.current_asset_set
    instanceparameters.last_world_asset = Settings.current_world_asset
    instanceparameters.last_world_specialevent = Settings.current_world_specialevent
    instanceparameters.last_world_extraevents = Settings.current_world_extraevents
    instanceparameters.loaded_characters = Settings.loaded_characters
    instanceparameters.loaded_mods = ModManager:GetUnloadPrefabsData()
    if Settings.current_asset_set == "BACKEND" then
        instanceparameters.memoizedFilePaths = GetMemoizedFilePaths()
        instanceparameters.chatHistory = ChatHistory:GetChatHistory()
    end

    local params = json.encode(instanceparameters)
    TheSim:SetInstanceParameters(params)
    TheSim:Reset()
end

function RequestShutdown()
    if exiting_game then
        return
    end
    exiting_game = true

    if not TheNet:GetServerIsDedicated() then
        TheFrontEnd:PushScreen(
            PopupDialogScreen(STRINGS.UI.QUITTINGTITLE, STRINGS.UI.QUITTING, {})
        )
    end

    if TheNet:GetIsHosting() then
        TheSystemService:StopDedicatedServers(not IsDynamicCloudShutdown)
    end

    Shutdown()
end

function DoWorldOverseerShutdown()
    if TheWorld ~= nil and TheWorld.ismastershard and TheWorld.components.worldoverseer ~= nil then
        TheWorld.components.worldoverseer:QuitAll()
    end
end

function Shutdown()
    DoWorldOverseerShutdown()

    SimShuttingDown = true

    Print(VERBOSITY.DEBUG, 'Ending the sim now!')

    --V2C: Assets will be unloaded when the C++ subsystems are deconstructed
    --UnloadFonts()

    -- warning, we don't want to run much code here. We're in a strange mix of loaded assets and mapped paths
    -- as a bonus, the fonts are unloaded, so no asserting...
    --TheSim:UnloadAllPrefabs()
    --ModManager:UnloadPrefabs()

    TheSim:Quit()
end

function DisplayError(error)

    SetPause(true,"DisplayError")
    if global_error_widget ~= nil then
        return nil
    end

    print (error) -- Failsafe since sometimes the error screen is no shown

    local modnames = ModManager:GetEnabledModNames()

    if #modnames > 0 then
        local modnamesstr = ""
        for k,modname in ipairs(modnames) do
            modnamesstr = modnamesstr.."\""..KnownModIndex:GetModFancyName(modname).."\" "
        end

        local buttons = nil
        if IsNotConsole() then
            buttons = {
                {text=STRINGS.UI.MAINSCREEN.SCRIPTERRORQUIT, cb = function() TheSim:ForceAbort() end},
                {text=STRINGS.UI.MAINSCREEN.MODQUIT, cb = function()
                                                            KnownModIndex:DisableAllMods()
                                                            ForceAssetReset()
                                                            KnownModIndex:Save(function()
                                                                TheSim:ResetError()
                                                                SimReset()
                                                            end)
                                                        end},
                {text=STRINGS.UI.MAINSCREEN.MODFORUMS, nopop=true, cb = function() VisitURL("http://forums.kleientertainment.com/forum/79-dont-starve-together-beta-mods-and-tools/") end }
            }

            -- Add reload save button if we're on dev
            if BRANCH == "dev" then
                table.insert(buttons, 1, {text=STRINGS.UI.MAINSCREEN.SCRIPTERRORRESTART, cb = function()
                                                                                                TheSim:ResetError()
                                                                                                c_reset()
                                                                                            end})
            end
        end
        SetGlobalErrorWidget(
                STRINGS.UI.MAINSCREEN.MODFAILTITLE,
                error,
                buttons,
                ANCHOR_LEFT,
                STRINGS.UI.MAINSCREEN.SCRIPTERRORMODWARNING..modnamesstr,
                20
                )
    else
        local buttons = nil

        -- If we know what happened, display a better message for the user
        local known_error = known_error_key ~= nil and ERRORS[known_error_key] or nil
        if known_error ~= nil then
            error = known_error.message
        end

        if IsNotConsole() then
            buttons = {
                {text=STRINGS.UI.MAINSCREEN.SCRIPTERRORQUIT, cb = function() TheSim:ForceAbort() end},
            }

            -- Add reload save button if we're on dev
            if BRANCH == "dev" then
                table.insert(buttons, 1, {text=STRINGS.UI.MAINSCREEN.SCRIPTERRORRESTART, cb = function()
                                                                                                TheSim:ResetError()
                                                                                                c_reset()
                                                                                            end})
                if not Profile:GetThreadedRenderEnabled() then
                    table.insert(buttons, 1, {text=STRINGS.UI.MAINSCREEN.SCRIPTERROR_DEBUG, cb = function()
                        if not TheFrontEnd:FindOpenDebugPanel(DebugNodes.DebugConsole) then
                            DebugNodes.ShowDebugPanel(DebugNodes.DebugConsole, false)
                        end
                    end})
                end
            end

            if known_error_key == nil or ERRORS[known_error_key] == nil then
                table.insert(buttons, {text=STRINGS.UI.MAINSCREEN.ISSUE, nopop=true, cb = function() VisitURL("http://forums.kleientertainment.com/klei-bug-tracker/dont-starve-together/") end })
            elseif known_error.url ~= nil then
                table.insert(buttons, {text=STRINGS.UI.MAINSCREEN.GETHELP, nopop=true, cb = function() VisitURL(known_error.url) end })
            end
        end

        SetGlobalErrorWidget(
                STRINGS.UI.MAINSCREEN.MODFAILTITLE,
                error,
                buttons,
                known_error ~= nil and ANCHOR_MIDDLE or ANCHOR_LEFT,
                nil,
                known_error ~= nil and 30 or 20
                )
    end
end

function SetPauseFromCode(pause)
    if pause then
        if inGamePlay and not IsPaused() then
            local PauseScreen = require "screens/redux/pausescreen"
            TheFrontEnd:PushScreen(PauseScreen())
        end
    end
end

function InGamePlay()
    return inGamePlay
end

function IsMigrating()
    --Right now the only way to really tell if we are migrating is if we are neither in FE or in gameplay, which results in no screen...
    --      e.g. if there is no active screen, or just a connecting to game popup
    --THIS SHOULD BE IMPROVED YARK YARK YARK
    --V2C: Who dat? ----------^
    local screen = TheFrontEnd:GetActiveScreen()
    return screen == nil or (screen.name == "ConnectingToGamePopup" and TheFrontEnd:GetScreenStackSize() <= 1)
end

--DoRestart helper
local function postsavefn()
    TheNet:Disconnect(true)
    EnableAllMenuDLC()

    if TheNet:GetIsHosting() then
        TheSystemService:StopDedicatedServers(not IsDynamicCloudShutdown)
    end

    StartNextInstance()
    inGamePlay = false
    PerformingRestart = false
end

--DoRestart helper
local function savefn()
    if TheWorld == nil then
        postsavefn()
    elseif TheWorld.ismastersim then
        DoWorldOverseerShutdown()

        for i, v in ipairs(AllPlayers) do
            v:OnDespawn()
        end
        TheSystemService:EnableStorage(true)
        ShardGameIndex:SaveCurrent(postsavefn, true)
    else
        SerializeUserSession(ThePlayer)
        postsavefn()
    end
end

function DoRestart(save)
    print("DoRestart:", save)

	Settings.match_results = {}

    if not PerformingRestart then
        PerformingRestart = true
        ShowLoading()
        TheFrontEnd:Fade(FADE_OUT, 1, save and savefn or postsavefn)
    end
end

IsDynamicCloudShutdown = false

--these are currently unused, they will be used on Steam Dynamic Cloud Syncing is eventually enabled.
function OnDynamicCloudSyncReload()
    TheNet:SendWorldRollbackRequestToServer(0)
end

function OnDynamicCloudSyncDelete()
    IsDynamicCloudShutdown = true
    DoRestart(false)
end

local screen_fade_time = .25

function OnPlayerLeave(player_guid, expected)
    if TheWorld.ismastersim and player_guid ~= nil then
        local player = Ents[player_guid]
        if player ~= nil then
            --V2C: #spawn #despawn
            --     This was where we used to announce player left.
            --     Now we announce it when you actually disconnect
            --     but not during a shard migration disconnection.
            --TheNet:Announce(string.format(STRINGS.UI.NOTIFICATION.LEFTGAME, player:GetDisplayName()), player.entity, true, "leave_game")

            --Save must happen when the player is actually removed
            --This is currently handled in playerspawner listening to ms_playerdespawn
            TheWorld:PushEvent("ms_playerdisconnected", {player=player, wasExpected=expected})
            TheWorld:PushEvent("ms_playerdespawn", player)
        end
    end
end

-- Receive a message that does not disconnect the user
function OnPushPopupDialog( message )
    local title = STRINGS.UI.POPUPDIALOG.TITLE[message] or STRINGS.UI.POPUPDIALOG.TITLE.DEFAULT
    message = STRINGS.UI.POPUPDIALOG.BODY[message] or STRINGS.UI.POPUPDIALOG.BODY.DEFAULT

    local function doclose( )
        TheFrontEnd:PopScreen( )
    end

    TheFrontEnd:PushScreen( PopupDialogScreen(title, message, { {text=STRINGS.UI.POPUPDIALOG.OK, cb = function() doclose( ) end}  }) )
    local screen = TheFrontEnd:GetActiveScreen()
    if screen then
        screen:Enable()
    end
end

function OnDemoTimeout()
	print("Demo timed out")
	if not IsMigrating() then
		TheSystemService:StopDedicatedServers(not IsDynamicCloudShutdown)
	end
	if ThePlayer ~= nil then
		SerializeUserSession(ThePlayer)
	end
	local should_reset = true
	should_reset = should_reset and (InGamePlay() or IsMigrating())

	DoRestart(should_reset)
end

-- Receive a disconnect notification
function OnNetworkDisconnect( message, should_reset, force_immediate_reset, details, miscdata)
    -- The client has requested we immediately close this connection
    if force_immediate_reset == true then
        DoRestart(true)
        return
    end

    if not IsMigrating() then
        TheSystemService:StopDedicatedServers(not IsDynamicCloudShutdown)
    end

    local accounts_link = nil
	local help_button = nil
    local play_offline = nil
    if message == "E_BANNED" then
        if (IsRail() or TheNet:IsNetOverlayEnabled()) then
            accounts_link = {text=STRINGS.UI.NETWORKDISCONNECT.ACCOUNTS, cb = function() TheFrontEnd:GetAccountManager():VisitAccountPage() end}
        end
        play_offline = {text=STRINGS.UI.MAINSCREEN.PLAYOFFLINE, cb = function()
            TheFrontEnd:PopScreen()
            if miscdata then
                miscdata()
            end
        end}
    end

	if details ~= nil then
		if accounts_link == nil then
			accounts_link = details.help_button
		else
			help_button = details.help_button
		end
	end

    if play_offline ~= nil then
        if accounts_link == nil then
            accounts_link = play_offline
            play_offline = nil
        elseif help_button == nil then
            help_button = play_offline
            play_offline = nil
        end
    end

    local title = STRINGS.UI.NETWORKDISCONNECT.TITLE[message] or STRINGS.UI.NETWORKDISCONNECT.TITLE.DEFAULT
    message = STRINGS.UI.NETWORKDISCONNECT.BODY[message] or STRINGS.UI.NETWORKDISCONNECT.BODY.DEFAULT

    local screen = TheFrontEnd:GetActiveScreen()
    if screen then
		if screen.name == "ConnectingToGamePopup" then
			TheFrontEnd:PopScreen()
		elseif screen.name == "QuickJoinScreen" then
		    TheNet:JoinServerResponse( true ) -- cancel join
            TheNet:Disconnect(false)
			screen:TryNextServer(title, message)
			return
		elseif screen.name == "HostCloudServerPopup" then
		    TheNet:JoinServerResponse( true ) -- cancel join
            TheNet:Disconnect(false)
            screen:OnError(message)
			return
		end
    end

    --If we plan to serialize a user session, we should do it now.  It will be too late later.
    if ThePlayer ~= nil then
        SerializeUserSession(ThePlayer)
    end

    --Don't need to reset if we're in FE already
    --NOTE: due to migration, we can be in neither gameplay nor FE
    --      INVALID_CLIENT_TOKEN is a special case; we want to
    --      boot the user back to the main menu even if they're in the FE
    should_reset = should_reset and (InGamePlay() or IsMigrating() or message == "INVALID_CLIENT_TOKEN")
    local function doquit( should_reset )
        if should_reset == true then
            DoRestart(false) --don't save again
        else
            TheNet:Disconnect(false)
            TheFrontEnd:PopScreen()
            -- Make sure we try to enable the screen behind this
            local screen = TheFrontEnd:GetActiveScreen()
            if screen then
                screen:Enable()
            end
        end
    end

    if TheFrontEnd:GetFadeLevel() > 0 then --we're already fading
        if TheFrontEnd.fadedir == false then
            local cb = TheFrontEnd.fadecb
            TheFrontEnd.fadecb = function()
                if cb then cb() end
                TheFrontEnd:PushScreen( PopupDialogScreen(title, message, { {text=STRINGS.UI.NETWORKDISCONNECT.OK, cb = function() doquit( should_reset ) end}, accounts_link, help_button, play_offline }) )
                local screen = TheFrontEnd:GetActiveScreen()
                if screen then
                    screen:Enable()
                end
                TheFrontEnd:Fade(FADE_IN, screen_fade_time)
            end
        else
            TheFrontEnd:PushScreen( PopupDialogScreen(title, message, { {text=STRINGS.UI.NETWORKDISCONNECT.OK, cb = function() doquit( should_reset ) end}, accounts_link, help_button, play_offline }) )
            local screen = TheFrontEnd:GetActiveScreen()
            if screen then
                screen:Enable()
            end
            TheFrontEnd:Fade(FADE_IN, screen_fade_time)
        end
    else
        -- TheFrontEnd:Fade(FADE_OUT, screen_fade_time, function()
            TheFrontEnd:PushScreen( PopupDialogScreen(title, message, { {text=STRINGS.UI.NETWORKDISCONNECT.OK, cb = function() doquit( should_reset ) end}, accounts_link, help_button, play_offline }) )
            local screen = TheFrontEnd:GetActiveScreen()
            if screen then
                screen:Enable()
            end
            -- TheFrontEnd:Fade(FADE_IN, screen_fade_time)
        -- end)
    end
    return true
end

OnAccountEventListeners = {}

function RegisterOnAccountEventListener( listener )
    table.insert( OnAccountEventListeners, listener )
end

function RemoveOnAccountEventListener( listener_to_remove )
    local index = 1
    for k,listener in pairs(OnAccountEventListeners) do
        if listener == listener_to_remove then
            table.remove( OnAccountEventListeners, index )
            break
        end
        index = index + 1
    end
end

function OnAccountEvent( success, event_code, custom_message )
    for k,listener in pairs(OnAccountEventListeners) do
        if listener ~= nil then
            listener:OnAccountEvent( success, event_code, custom_message )
        end
    end
end

function TintBackground( bg )
    --if IsDLCEnabled(REIGN_OF_GIANTS) then
    --    bg:SetTint(unpack(BGCOLOURS.PURPLE))
    --else
        -- bg:SetTint(unpack(BGCOLOURS.GREY))
        bg:SetTint(unpack(BGCOLOURS.FULL))
    --end
end

-- NOTES(JBK): Keeping this for PC Steam/RAIL only for now.
local platforms_supporting_audio_focus = {
    ["WIN32_STEAM"] = true,
    ["WIN32_RAIL"] = true,
    ["LINUX_STEAM"] = true,
    ["OSX_STEAM"] = true,
}

-- Global for saving game on Android focus lost event
function OnFocusLost()
    --check that we are in gameplay, not main menu
    if PLATFORM == "ANDROID" and inGamePlay then
        SetPause(true)
        ShardGameIndex:SaveCurrent()
    end
    if platforms_supporting_audio_focus[PLATFORM] and Profile:GetMuteOnFocusLost() then
        TheMixer:SetLevel("master", 0)
    end
end

function OnFocusGained()
    --check that we are in gameplay, not main menu
    if PLATFORM == "ANDROID" and inGamePlay then
        SetPause(false)
    end
    if platforms_supporting_audio_focus[PLATFORM] and Profile:GetMuteOnFocusLost() then
        TheMixer:SetLevel("master", 1)
    end
end

local function OnUserPickedCharacter(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet)
    local function doSpawn()
        TheFrontEnd:PopScreen()

        local starting_skins = {}
        --get the starting inventory skins and send those along to the spawn request
        local inv_item_list = GetUniquePotentialCharacterStartingInventoryItems(char, true)

        for _, item in ipairs(inv_item_list) do
            if PREFAB_SKINS[item] then
                local skin_name = Profile:GetLastUsedSkinForItem(item)
                starting_skins[item] = skin_name
            end
        end
        local selection = TheSkillTree:GetPlayerSkillSelection(char)
        local has_selection = false
        for _, v in ipairs(selection) do
            if v ~= 0 then
                has_selection = true
                break
            end
        end
        if not has_selection then
            selection = nil
        end

        TheNet:SendSpawnRequestToServer(char, skin_base, clothing_body, clothing_hand, clothing_legs, clothing_feet, starting_skins, selection)
    end

    TheFrontEnd:Fade(FADE_OUT, 1, doSpawn, nil, nil, "white")
end

function ResumeRequestLoadComplete(success)
    --If successful then don't do anything, game will automatically
    --activate and fade in once the user's player is downloaded
    if not success then
        TheNet:DeleteUserSession(TheNet:GetUserID())
        local LobbyScreen = require "screens/redux/lobbyscreen"
        TheFrontEnd:PushScreen(LobbyScreen(Profile, OnUserPickedCharacter, false))
        TheFrontEnd:Fade(FADE_IN, 1, nil, nil, nil, "white")
        TheWorld:PushEvent("entercharacterselect")
--[[
	else
		local session_file = TheNet:GetLocalClientUserSessionFile()
        if session_file then
            print("Loading Local Client Session Data from:", session_file)

            TheNet:DeserializeUserSession(session_file, function(success, str)
                if success and str ~= nil and #str > 0 then
                    local playerdata = ParseUserSessionData(str)
                    if playerdata ~= nil and playerdata.crafting_menu ~= nil then
                        TheCraftingMenuProfile:DeserializeLocalClientSessionData(playerdata.crafting_menu)
                    end
                end
            end)
        end
]]
    end
end

--data is raw string data from save file
function ParseUserSessionData(data)
    local success, playerdata = RunInSandboxSafe(data)
    if success and playerdata ~= nil then
        --print(playerdata, playerdata.prefab)
        --Here we can do some validation on data and/or prefab if we want
        --e.g. Resuming a mod character without the mod loaded?
        return playerdata, playerdata.prefab
    end
    return nil, ""
end

--data is lua table
function ResumeExistingUserSession(data, guid)
    if TheNet:GetIsServer() then
        local player = Ents[guid]
        if player ~= nil then
            player:SetPersistData( data.data or {} )
            player:EnableLoadingProtection()

            -- Spawn the player to last known location
			local x, y, z, platform = ResolveSaveRecordPosition(data)
			TheWorld.components.playerspawner:SpawnAtLocation(TheWorld, player, x, y, z, true)
			if platform ~= nil then
				player.components.walkableplatformplayer:TestForPlatform()
			end

            return player.player_classified ~= nil and player.player_classified.entity or nil
        end
    end
end

function RestoreSnapshotUserSession(sessionid, userid)
    local file = TheNet:GetUserSessionFile(sessionid, userid)
    if file ~= nil then
        print("Restoring user: "..file)
        TheNet:DeserializeUserSession(file, function(success, str)
            if success and str ~= nil and #str > 0 then
                local playerdata, prefab = ParseUserSessionData(str)
                if playerdata ~= nil and GetTableSize(playerdata) > 0 and prefab ~= nil and prefab ~= "" then
                    local player = SpawnPrefab(prefab)
                    if player ~= nil then
                        player.userid = userid
						player.is_snapshot_user_session = true
                        player:SetPersistData(playerdata.data or {})
						local x, y, z, platform = ResolveSaveRecordPosition(playerdata)
						player.Physics:Teleport(x, y, z)
						if platform ~= nil then
							player.components.walkableplatformplayer:TestForPlatform()
							--V2C: TestForPlatform does NOT do what you think it does in this context...
							--     player:GetCurrentPlatform() returns unexpected nil
							--     Might consider refactoring in the future.
							--     But for now:
							player._snapshot_platform = platform
                        end
						--if playerdata.crafting_menu ~= nil then
						--	TheCraftingMenuProfile:DeserializeLocalClientSessionData(playerdata.crafting_menu)
						--end

                        return player.player_classified ~= nil and player.player_classified.entity or nil
                    end
                end
            end
        end)
    end
end

-- Execute arbitrary lua
function ExecuteConsoleCommand(fnstr, guid, x, z)
    local saved_ThePlayer
    if guid ~= nil then
        saved_ThePlayer = ThePlayer
        ThePlayer = guid ~= nil and Ents[guid] or nil
    end
    TheInput.overridepos = x ~= nil and z ~= nil and Vector3(x, 0, z) or nil

    local status, r = pcall(loadstring(fnstr))
    if not status then
        nolineprint(r)
    end

    if guid ~= nil then
        ThePlayer = saved_ThePlayer
    end
    TheInput.overridepos = nil
end

LoadingStates =
{
    None = 0,
    Loading = 1,
    Generating = 2,
    DoneGenerating = 3,
    DoneLoading = 4,
}

function NotifyLoadingState(loading_state, match_results)
    if TheNet:GetIsClient() then
        --Let gamelogic know not to handle player deactivation messages
        DeactivateWorld()
        --
        if GetGameModeProperty("hide_worldgen_loading_screen") then
			if loading_state == LoadingStates.Loading then
				TheFrontEnd:Fade(FADE_OUT, TheFrontEnd:GetFadeLevel() < 1 and 1 or 0,
					function()
						TheFrontEnd:PopScreen()
					end)
				if match_results ~= nil then
					TheFrontEnd.match_results = json.decode(match_results)
				end
				ShowLoading()
			elseif loading_state == LoadingStates.Generating or loading_state == LoadingStates.DoneGenerating then
				ShowLoading()
			end
		else
			if loading_state == LoadingStates.Loading then
				ShowLoading()
				TheFrontEnd:Fade(FADE_OUT, 1)
			elseif loading_state == LoadingStates.Generating then
				CreateEntity():DoTaskInTime(0.15, function(inst)
					TheFrontEnd:PopScreen()
					TheFrontEnd:PushScreen(WorldGenScreen(nil, nil, nil))
					inst.entity:Retire()
				end)
			elseif loading_state == LoadingStates.DoneGenerating then
				TheFrontEnd:PopScreen()
			end
		end
    elseif TheNet:GetIsServer() then
        TheNet:NotifyLoadingState(loading_state, json.encode(match_results))
    end
end

function BuildTagsStringCommon(tagsTable)
    -- Vote command tags (controlled by master server only)
    if not TheShard:IsSecondary() and TheNet:GetDefaultVoteEnabled() then
        table.insert(tagsTable, STRINGS.TAGS.VOTE)
    end

    if TheShard:IsMaster() then
        -- Merge secondary shard tags
        for k, v in pairs(Shard_GetConnectedShards()) do
            if v.tags ~= nil then
                for i, tag in ipairs(v.tags:split(",")) do
                    table.insert(tagsTable, tag)
                end
            end
        end
    end

    -- Mods tags
    for i, mod_tag in ipairs(KnownModIndex:GetEnabledModTags()) do
        table.insert(tagsTable, mod_tag)
    end

    -- Beta tag (forced to front of list)
    if BRANCH == "staging" and CURRENT_BETA > 0 then
        table.insert(tagsTable, 1, BETA_INFO[CURRENT_BETA].SERVERTAG)
        table.insert(tagsTable, 1, BETA_INFO[PUBLIC_BETA].SERVERTAG)
    end

    -- Language tag (forced to front of list, don't put anything else at slot 1, or language detection will fail!)
    table.insert(tagsTable, 1, STRINGS.PRETRANSLATED.LANGUAGES[LOC.GetLanguage()] or "")

    -- Concat unique tags
    local tagged = {}
    local tagsString = ""
    for i, v in ipairs(tagsTable) do
        --trim whitespace
        v = v:lower():match("^%s*(.-%S)%s*$") or ""
        if v:len() > 0 and not tagged[v] then
            tagged[v] = true
            tagsString = tagsString:len() > 0 and (tagsString..","..v) or v
        end
    end

    return tagsString
end

function SaveAndShutdown()
    if not TheWorld then
        return
    end
    if TheWorld.ismastersim then
        for i, v in ipairs(AllPlayers) do
            v:OnDespawn()
        end
        TheSystemService:EnableStorage(true)
        ShardGameIndex:SaveCurrent(Shutdown, true)
    end
end

function IsInFrontEnd()
	return Settings.reset_action == nil or Settings.reset_action == RESET_ACTION.LOAD_FRONTEND
end

function CreateRepeatedSoundVolumeReduction(repeat_time, lowered_volume_percent)
    local last_played_time = GetTime()
    local lower_sound_repeat_time = repeat_time
    local reduced_volume_percent = lowered_volume_percent
    return function()
        local current_time = GetTime()

        local sound_volume = 1
        if current_time - last_played_time <= lower_sound_repeat_time then
            sound_volume = reduced_volume_percent
        end

        last_played_time = current_time
        return sound_volume
    end
end

--if fired in the last 0.25 seconds, reduce the volume to 75%
ClickMouseoverSoundReduction = CreateRepeatedSoundVolumeReduction(0.25, 0.75)

local currently_displaying = nil
function DisplayAntiAddictionNotification( notification )
    if notification ~= currently_displaying then
        local Text = require "widgets/text"
        local title = Text(CHATFONT_OUTLINE, 35)
        title:SetString(STRINGS.ANTIADDICTION[notification])
        title:SetPosition(0, -50, 0)
        title:Show()
        title:SetVAnchor(ANCHOR_TOP)
        title:SetHAnchor(ANCHOR_MIDDLE)
        currently_displaying = notification

        CreateEntity():DoTaskInTime(10.5, function(inst)
            title:Kill()
            inst.entity:Retire()
            currently_displaying = nil
        end)
    end
end

--shell commands that are ignored
local RCINIL = function() end
RCITimeout = RCINIL
RCIFileLock = RCINIL
RCIFileUnlock = RCINIL

require("dlcsupport")

function ShowBadHashUI()
    if HashesMessageState ~= "SHOW_WARNING" then
        return
    end
    -- Backend does not want to see errors when a game client is in an unstable state.
    HashesMessageState = "SHOWING_POPUP"
    --TheNet:SetQuietBackendErrorsReason(HashesMessageState) We faked the HashesMessageState prior to this callback.

    SetGlobalErrorWidget(STRINGS.UI.MAINSCREEN.BAD_HASHES_TITLE, STRINGS.UI.MAINSCREEN.BAD_HASHES_BODY, {
        {
            text = STRINGS.UI.MAINSCREEN.BAD_HASHES_PLAY,
            cb = function()
                -- Backend especially does not want to see errors when a player chooses to play anyway with an unstable game state.
                HashesMessageState = "CHOSE_TO_PLAY_ANYWAY"
                TheNet:SetQuietBackendErrorsReason(HashesMessageState)
                global_error_widget:GoAway()
            end
        },{
            text = STRINGS.UI.MAINSCREEN.BAD_HASHES_INSTRUCTIONS,
            cb = function()
                VisitURL("https://support.klei.com/hc/en-us/articles/360029555352-DST-Is-Crashing-DST-Won-t-Start")
            end
        },{
            text = STRINGS.UI.MAINSCREEN.ASKQUIT,
            cb = function()
                RequestShutdown()
            end
        },
    })
end

-- Login flow sync.
local login_button = nil
local function TurnOffLoginButton()
    if login_button then
        login_button:_TurnOff()
    end
end
local function TurnOnLoginButton()
    if login_button then
        login_button:_TurnOn()
    end
end
function HookLoginButtonForDataBundleFileHashes(button)
    login_button = button
end

-- Integrity check callbacks.
function BeginDataBundleFileHashes()
    -- The integrity checker is running things use this to let the game try to be synchronous and wait for its completion before login flow starts.
    IsIntegrityChecking = true
    TurnOffLoginButton()
end

function DataBundleFileHashes(calculatedhashes)
    -- NOTES(JBK): General integrity check in case the platform did not patch the files in data/databundles/*.zip properly.
    -- Generally the game binary always succeeds in patching and sometimes the databundles do not.
    -- This is made in the hope that players will be able to self serve a fix before experiencing issues when loading a game world or inside a game world.
    -- If a player chooses to play anyway we do not want to see errors pop up from malformed backend requests that are harder to debug.
    -- This function is only currently being called for platforms that allow the macro DO_GAMEFILE_INTEGRITY_CHECKS.
    IsIntegrityChecking = nil -- This is the response we are done here.
    TurnOnLoginButton()
    login_button = nil
    local hashesfile = io.open("databundles/hashes.txt", "r")
    if hashesfile == nil then
        -- No hash file to do basic checks with bail out and quiet backend errors.
        HashesMessageState = "MISSING_HASHES"
        TheNet:SetQuietBackendErrorsReason(HashesMessageState)
        return
    end

    for line in hashesfile:lines() do
        local filename, hash = line:match("^(.+) (.-)$")
        if filename and hash then
            hash = hash:gsub("[\r\n]", "") -- Remove any newlines from the over extending pattern above.
            hash = hash:gsub("\\", "/") -- Consistent path delimiters.
            if hash ~= "" then
                local calculatedhash = calculatedhashes[filename]
                if calculatedhash then
                    if calculatedhash ~= hash then
                        print("A bad filehash was detected for:", filename, hash, "got this:", calculatedhash)
                        HashesMessageState = "SHOW_WARNING"
                        TheNet:SetQuietBackendErrorsReason("SHOWING_POPUP") -- Fake the value of HashesMessageState we do not differentiate if the warning is pending to show.
                    end
                elseif HashesMessageState ~= "SHOW_WARNING" then
                    -- We have a hash in hashes.txt that we did not calculate a hash for.
                    -- This can happen if a player extracts a databundle for modding and deletes the zip.
                    -- If this happens it is highly likely the player manually deleted a databundle zip and should know that crashes are from their activities.
                    -- Backend team does not want to get alerted to these crashes.
                    HashesMessageState = "MISSING_DATABUNDLES"
                    TheNet:SetQuietBackendErrorsReason(HashesMessageState)
                end
            end
        end
    end

    io.close(hashesfile)
    hashesfile = nil
end
