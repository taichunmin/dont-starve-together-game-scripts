local modcompatability = require"modcompatability"

function ModInfoname(name)
	local prettyname = KnownModIndex:GetModFancyName(name)
	if prettyname == name then
		return name
	else
		return name.." ("..prettyname..")"
	end
end


ReleaseID = {
	IDs = {},
	Current = nil,
	}

function AddModReleaseID( name )
	ReleaseID.IDs[name] = name
	ReleaseID.Current = name
end

CurrentRelease = {}
CurrentRelease.GreaterOrEqualTo = function(rhs)
	return (rhs ~= nil) and (ReleaseID.IDs[rhs] ~= nil) or false
end

CurrentRelease.PrintID = function()
	print ("Current Release ID: " .. ((ReleaseID.Current ~= nil) and ("ReleaseID."..ReleaseID.Current) or ".."))
end


-- This isn't for modders to use: see environment version added in InsertPostInitFunctions
function GetModConfigData(optionname, modname, get_local_config)
	assert(modname, "modname must be supplied manually if calling GetModConfigData from outside of modmain or modworldgenmain. Use ModIndex:GetModActualName(fancyname) function [fancyname is name string from modinfo].")
	local force_local_options = false
	if get_local_config ~= nil then force_local_options = get_local_config end
	local config, temp_options = KnownModIndex:GetModConfigurationOptions_Internal(modname, force_local_options)
	if config and type(config) == "table" then
		if temp_options then
			return config[optionname]
		else
			for i,v in pairs(config) do
				if v.name == optionname then
					if v.saved ~= nil then
						return v.saved 
					else 
						return v.default
					end
				end
			end
		end
	end
	return nil
end

local function DoesCharacterExistInGendersTable(charactername)
    for gender,characters in pairs(CHARACTER_GENDERS) do
        if table.contains(characters, charactername) then
            return true
        end
    end
    return false
end

local function AddModCharacter(name, gender)
    table.insert(MODCHARACTERLIST, name)
    if not DoesCharacterExistInGendersTable(name) then
		if gender == nil then
			print( "Warning: Mod Character " .. name .. " does not currently specify a gender. Please update the call to AddModCharacter to include a gender. \"FEMALE\", \"MALE\", \"ROBOT\", or \"NEUTRAL\", or \"PLURAL\" " )
			gender = "NEUTRAL"
		end
		gender = gender:upper()
		if not CHARACTER_GENDERS[gender] then
			CHARACTER_GENDERS[gender] = {}
		end
		table.insert( CHARACTER_GENDERS[gender], name )
	else
		print( "Warning: Mod Character " .. name .. " already exists in the CHARACTER_GENDERS table. It was either added previously, or added twice. You only need to call AddModCharacter now." )
	end
end

local function RemoveDefaultCharacter(name)
	if table.contains(DST_CHARACTERLIST, name) then
		if not table.contains(MODCHARACTEREXCEPTIONS_DST, name) then
			table.insert(MODCHARACTEREXCEPTIONS_DST, name)
		else
			print ("Warning: Character " .. name .. " has already been removed")
		end
	else
		print ("Warning: Character " .. name .. " is not a default character")
	end
end

-- Will assert if the modder has EnableModDebugPrint turned on, otherwise just print a warning for normal users.
function moderror(message, level)
    local modname = (global('env') and env.modname) or ModManager.currentlyloadingmod or "unknown mod"
    local message = string.format("MOD ERROR: %s: %s", ModInfoname(modname), tostring(message))
    if KnownModIndex:IsModErrorEnabled() then
        level = level or 1
        if level ~= 0 then
            level = level + 1
        end
        return error(message, level)
    else
        print(message)
        return
    end
end

function modassert(test, message)
    if not test then
        return moderror(message)
    else
        return test
    end
end

function modprint(...)
    if KnownModIndex:IsModErrorEnabled() then
        print(...)
    end
end

local function getfenvminfield(level, fieldname)
    level = level + 1 -- increase level due to this function call
    -- tail call doesn't have full debug info, its func is nil
    -- use rawget to circumvent strict.lua's checks of _G that we might hit
    while debug.getinfo(level) ~= nil and (debug.getinfo(level).func == nil or rawget(getfenv(level), fieldname) == nil) do
        level = level + 1
    end
    assert(debug.getinfo(level) ~= nil, "Field " .. tostring(fieldname) .. " not found in callstack's functions' environments")
    return getfenv(level)[fieldname]
end

local function initprint(...)
    if KnownModIndex:IsModInitPrintEnabled() then
        local modname = getfenvminfield(3, "modname")
        print(ModInfoname(modname), ...)
    end
end

-- Based on @no_signal's AddWidgetPostInit :)
local function DoAddClassPostConstruct(classdef, postfn)
	local constructor = classdef._ctor
	classdef._ctor = function (self, ...)
		constructor(self, ...)
		postfn(self, ...)
	end
	local mt = getmetatable(classdef)
	mt.__call = function(class_tbl, ...)
        local obj = {}
        setmetatable(obj, classdef)
        if classdef._ctor then
            classdef._ctor(obj, ...)
        end
        return obj
    end
end

local function AddClassPostConstruct(package, postfn)
	local classdef = require(package)
	assert(type(classdef) == "table", "Class file path '"..package.."' doesn't seem to return a valid class.")
	DoAddClassPostConstruct(classdef, postfn)
end

local function AddGlobalClassPostConstruct(package, classname, postfn)
	require(package)
	local classdef = rawget(_G, classname)
	if classdef == nil then
		classdef = require(package)
	end

	assert(type(classdef) == "table", "Class '"..classname.."' wasn't loaded to global from '"..package.."'.")
	DoAddClassPostConstruct(classdef, postfn)
end

local function InsertPostInitFunctions(env, isworldgen)

    env.modassert = modassert
    env.moderror = moderror

	env.postinitfns = {}
	env.postinitdata = {}

	env.postinitfns.LevelPreInit = {}
	env.AddLevelPreInit = function(levelid, fn)
		initprint("AddLevelPreInit", levelid)
		if env.postinitfns.LevelPreInit[levelid] == nil then
			env.postinitfns.LevelPreInit[levelid] = {}
		end
		table.insert(env.postinitfns.LevelPreInit[levelid], fn)
	end
	env.postinitfns.LevelPreInitAny = {}
	env.AddLevelPreInitAny = function(fn)
		initprint("AddLevelPreInitAny")
		table.insert(env.postinitfns.LevelPreInitAny, fn)
	end
	env.postinitfns.TaskSetPreInit = {}
	env.AddTaskSetPreInit = function(tasksetname, fn)
		initprint("AddTaskSetPreInit", tasksetname)
		if env.postinitfns.TaskSetPreInit[tasksetname] == nil then
			env.postinitfns.TaskSetPreInit[tasksetname] = {}
		end
		table.insert(env.postinitfns.TaskSetPreInit[tasksetname], fn)
	end
	env.postinitfns.TaskSetPreInitAny = {}
	env.AddTaskSetPreInitAny = function(fn)
		initprint("AddTaskSetPreInitAny")
		if env.postinitfns.TaskSetPreInitAny == nil then
			env.postinitfns.TaskSetPreInitAny = {}
		end
		table.insert(env.postinitfns.TaskSetPreInitAny, fn)
	end
	env.postinitfns.TaskPreInit = {}
	env.AddTaskPreInit = function(taskname, fn)
		initprint("AddTaskPreInit", taskname)
		if env.postinitfns.TaskPreInit[taskname] == nil then
			env.postinitfns.TaskPreInit[taskname] = {}
		end
		table.insert(env.postinitfns.TaskPreInit[taskname], fn)
	end
	env.postinitfns.RoomPreInit = {}
	env.AddRoomPreInit = function(roomname, fn)
		initprint("AddRoomPreInit", roomname)
		if env.postinitfns.RoomPreInit[roomname] == nil then
			env.postinitfns.RoomPreInit[roomname] = {}
		end
		table.insert(env.postinitfns.RoomPreInit[roomname], fn)
	end

	env.AddLocation = function(arg1, ...)
		initprint("AddLocation", arg1.location)
		AddModLocation(env.modname, arg1, ...)
	end
	env.AddLevel = function(arg1, arg2, ...)
		initprint("AddLevel", arg1, arg2.id)

		arg2 = modcompatability.UpgradeModLevelFromV1toV2(env.modname, arg2)

		AddModLevel(env.modname, arg1, arg2, ...)
	end
	env.AddTaskSet = function(arg1, ...)
		initprint("AddTaskSet", arg1)
		AddModTaskSet(env.modname, arg1, ...)
	end
	env.AddTask = function(arg1, ...)
		initprint("AddTask", arg1)
		AddModTask(env.modname, arg1, ...)
	end
	env.AddRoom = function(arg1, ...)
		initprint("AddRoom", arg1)
		AddModRoom(env.modname, arg1, ...)
	end
    env.AddStartLocation = function(arg1, ...)
        initprint("AddStartLocation", arg1)
        AddModStartLocation(env.modname, arg1, ...)
    end

	env.AddGameMode = function(game_mode, game_mode_text)
		print("Warning: AddGameMode has been removed.")
		print("Game mode is now described in modinfo.lua with the following code")
		print("game_modes =")
		print("{")
		print("\t{")
		print("\t\tname = \"glutton\",")
		print("\t\tlabel = \"Glutton\",")
		print("\t\tsettings =")
		print("\t\t{")
		print("\t\t\tghost_sanity_drain = true,")
		print("\t\t\tportal_rez = true")
		print("\t\t\t--see other setting options in gamemodes.lua")
		print("\t\t}")
		print("\t}")
		print("}")
	end

	env.GetModConfigData = function( optionname, get_local_config )
		initprint("GetModConfigData", optionname, get_local_config)
		return GetModConfigData(optionname, env.modname, get_local_config)
	end

	env.postinitfns.GamePostInit = {}
	env.AddGamePostInit = function(fn)
		initprint("AddGamePostInit")
		table.insert(env.postinitfns.GamePostInit, fn)
	end

	env.postinitfns.SimPostInit = {}
	env.AddSimPostInit = function(fn)
		initprint("AddSimPostInit")
		table.insert(env.postinitfns.SimPostInit, fn)
	end

	env.AddGlobalClassPostConstruct = function(package, classname, fn)
		initprint("AddGlobalClassPostConstruct", package, classname)
		AddGlobalClassPostConstruct(package, classname, fn)
	end

	env.AddClassPostConstruct = function(package, fn)
		initprint("AddClassPostConstruct", package)
		AddClassPostConstruct(package, fn)
	end

	--env.AddTile = function( tile_name, texture_name, noise_texture, runsound, walksound, snowsound, mudsound, flashpoint_modifier )
	--	AddTile( env.modname, tile_name, texture_name, noise_texture, runsound, walksound, snowsound, mudsound, flashpoint_modifier )
	--end
	
	env.ReleaseID = ReleaseID.IDs
	env.CurrentRelease = CurrentRelease

	------------------------------------------------------------------------------
	-- Everything above this point is available in Worldgen or Main.
	-- Everything below is ONLY available in Main.
	-- This allows us to provide easy access to game-time data without
	-- breaking worldgen.
	------------------------------------------------------------------------------
	if isworldgen then
		return
	end
	------------------------------------------------------------------------------


	env.AddAction = function( id, str, fn )
		local action
        if type(id) == "table" and id.is_a and id:is_a(Action) then
			--backwards compatibility with old AddAction
            action = id
        else
			assert( str ~= nil and type(str) == "string", "Must specify a string for your custom action! Example: \"Perform My Action\"")
			assert( fn ~= nil and type(fn) == "function", "Must specify a fn for your custom action! Example: \"function(act) --[[your action code]] end\"")
			action = Action()
			action.id = id
			action.str = str
			action.fn = fn
		end
		action.mod_name = env.modname

		assert( action.id ~= nil and type(action.id) == "string", "Must specify an ID for your custom action! Example: \"MYACTION\"")			

		initprint("AddAction", action.id)
		ACTIONS[action.id] = action

		--put it's mapping into a different IDS table, one for each mod
		if ACTION_MOD_IDS[action.mod_name] == nil then
			ACTION_MOD_IDS[action.mod_name] = {}
		end
		table.insert(ACTION_MOD_IDS[action.mod_name], action.id)
		ACTIONS[action.id].code = #ACTION_MOD_IDS[action.mod_name]

		STRINGS.ACTIONS[action.id] = action.str
		
		return ACTIONS[action.id]
	end

	env.AddComponentAction = function(actiontype, component, fn)
		-- just past this along to the global function
		AddComponentAction(actiontype, component, fn, env.modname)
	end

	env.postinitdata.MinimapAtlases = {}
	env.AddMinimapAtlas = function( atlaspath )
		initprint("AddMinimapAtlas", atlaspath)
		table.insert(env.postinitdata.MinimapAtlases, atlaspath)
	end

	env.postinitdata.StategraphActionHandler = {}
	env.AddStategraphActionHandler = function(stategraph, handler)
		initprint("AddStategraphActionHandler", stategraph)
		if not env.postinitdata.StategraphActionHandler[stategraph] then
			env.postinitdata.StategraphActionHandler[stategraph] = {}
		end
		table.insert(env.postinitdata.StategraphActionHandler[stategraph], handler)
	end

	env.postinitdata.StategraphState = {}
	env.AddStategraphState = function(stategraph, state)
		initprint("AddStategraphState", stategraph)
		if not env.postinitdata.StategraphState[stategraph] then
			env.postinitdata.StategraphState[stategraph] = {}
		end
		table.insert(env.postinitdata.StategraphState[stategraph], state)
	end

	env.postinitdata.StategraphEvent = {}
	env.AddStategraphEvent = function(stategraph, event)
		initprint("AddStategraphEvent", stategraph)
		if not env.postinitdata.StategraphEvent[stategraph] then
			env.postinitdata.StategraphEvent[stategraph] = {}
		end
		table.insert(env.postinitdata.StategraphEvent[stategraph], event)
	end

	env.postinitfns.StategraphPostInit = {}
	env.AddStategraphPostInit = function(stategraph, fn)
		initprint("AddStategraphPostInit", stategraph)
		if env.postinitfns.StategraphPostInit[stategraph] == nil then
			env.postinitfns.StategraphPostInit[stategraph] = {}
		end
		table.insert(env.postinitfns.StategraphPostInit[stategraph], fn)
	end


	env.postinitfns.ComponentPostInit = {}
	env.AddComponentPostInit = function(component, fn)
		initprint("AddComponentPostInit", component)
		if env.postinitfns.ComponentPostInit[component] == nil then
			env.postinitfns.ComponentPostInit[component] = {}
		end
		table.insert(env.postinitfns.ComponentPostInit[component], fn)
	end

	-- You can use this as a post init for any prefab. If you add a global prefab post init function, it will get called on every prefab that spawns.
	-- This is powerful but also be sure to check that you're dealing with the appropriate type of prefab before doing anything intensive, or else
	-- you might hit some performance issues. The next function down, player post init, is both itself useful and a good example of how you might
	-- want to write your global prefab post init functions.
	env.postinitfns.PrefabPostInitAny = {}
	env.AddPrefabPostInitAny = function(fn)
		initprint("AddPrefabPostInitAny")
		table.insert(env.postinitfns.PrefabPostInitAny, fn)
	end

	-- An illustrative example of how to use a global prefab post init, in this case, we're making a player prefab post init.
	env.AddPlayerPostInit = function(fn)
		env.AddPrefabPostInitAny( function(inst)
			if inst and inst:HasTag("player") then fn(inst) end
		end)
	end

	env.postinitfns.PrefabPostInit = {}
	env.AddPrefabPostInit = function(prefab, fn)
		initprint("AddPrefabPostInit", prefab)
		if env.postinitfns.PrefabPostInit[prefab] == nil then
			env.postinitfns.PrefabPostInit[prefab] = {}
		end
		table.insert(env.postinitfns.PrefabPostInit[prefab], fn)
	end

	-- the non-standard ones

	env.AddBrainPostInit = function(brain, fn)
		initprint("AddBrainPostInit", brain)
		local brainclass = require("brains/"..brain)
		if brainclass.modpostinitfns == nil then
			brainclass.modpostinitfns = {}
		end
		table.insert(brainclass.modpostinitfns, fn)
	end

	env.AddIngredientValues = function(names, tags, cancook, candry)
		require("cooking")
		initprint("AddIngredientValues", table.concat(names, ", "))
		AddIngredientValues(names, tags, cancook, candry)
	end

	env.cookerrecipes = {}
	env.AddCookerRecipe = function(cooker, recipe)
		require("cooking")
		initprint("AddCookerRecipe", cooker, recipe.name)
		AddCookerRecipe(cooker, recipe)
		if env.cookerrecipes[cooker] == nil then
	        env.cookerrecipes[cooker] = {}
	    end
	    if recipe.name then
	        table.insert(env.cookerrecipes[cooker], recipe.name)
	    end
	end

	env.AddModCharacter = function(name, gender)
		initprint("AddModCharacter", name, gender)
		AddModCharacter(name, gender)
	end

	env.RemoveDefaultCharacter = function (name)
		initprint("RemoveDefaultCharacter", name)
		RemoveDefaultCharacter(name)
	end

	env.AddRecipe = function(arg1, ...)
		initprint("AddRecipe", arg1)
		require("recipe")
		mod_protect_Recipe = false
		local rec = Recipe(arg1, ...)
		mod_protect_Recipe = true
		rec:SetModRPCID()
		return rec
	end
	
	env.Recipe = function(...)
		print("Warning: function Recipe in modmain is deprecated, please use AddRecipe")
		return env.AddRecipe(...)
	end
	
    env.AddRecipeTab = function( rec_str, rec_sort, rec_atlas, rec_icon, rec_owner_tag, rec_crafting_station )
		CUSTOM_RECIPETABS[rec_str] = { str = rec_str, sort = rec_sort, icon_atlas = rec_atlas, icon = rec_icon, owner_tag = rec_owner_tag, crafting_station = rec_crafting_station }
		STRINGS.TABS[rec_str] = rec_str
		return CUSTOM_RECIPETABS[rec_str]
    end

	env.Prefab = Prefab

	env.Asset = Asset

	env.Ingredient = Ingredient

	env.LoadPOFile = function(path, lang)
		initprint("LoadPOFile", lang)
		require("translator")
		LanguageTranslator:LoadPOFile(path, lang)
	end

	env.RemapSoundEvent = function(name, new_name)
		initprint("RemapSoundEvent", name, new_name)
		TheSim:RemapSoundEvent(name, new_name)
	end

	env.AddReplicableComponent = function(name)
		initprint("AddReplicableComponent", name)
		AddReplicableComponent(name)
	end

	env.AddModRPCHandler = function( namespace, name, fn )
		initprint( "AddModRPCHandler", namespace, name )
		AddModRPCHandler( namespace, name, fn )
	end

	env.GetModRPCHandler = function( namespace, name )
		initprint( "GetModRPCHandler", namespace, name )
		return GetModRPCHandler( namespace, name )
	end
	
	env.SendModRPCToServer = function( id_table, ... )
		initprint( "SendModRPCToServer", id_table.namespace, id_table.id )
		SendModRPCToServer( id_table, ... )
	end

	env.MOD_RPC = MOD_RPC --legacy, mods should use GetModRPC below

	env.GetModRPC = function( namespace, name )
		initprint( "GetModRPC", namespace, name )
		return GetModRPC( namespace, name )
	end

    env.SetModHUDFocus = function(focusid, hasfocus)
        initprint("SetModHUDFocus", focusid, hasfocus)
        if ThePlayer == nil or ThePlayer.HUD == nil then
            print("WARNING: SetModHUDFocus called when there is no active player HUD")
        else
			ThePlayer.HUD:SetModFocus(env.modname, focusid, hasfocus)
		end
    end

    env.AddUserCommand = function(command_name, data)
        initprint("AddUserCommand", command_name)
        AddModUserCommand(env.modname, command_name, data)
    end

	env.AddVoteCommand = function(command_name, init_options_fn, process_result_fn, vote_timeout )
		initprint("AddVoteCommand", command_name, init_options_fn, process_result_fn, vote_timeout )
		
		if env.vote_commands == nil then
	        env.vote_commands = {}
	    end
		env.vote_commands[command_name] = { InitOptionsFn = init_options_fn, ProcessResultFn = process_result_fn, Timeout = vote_timeout or 15 }
	end
	
	env.ExcludeClothingSymbolForModCharacter = function(name, symbol)
        initprint("ExcludeClothingSymbolForModCharacter", name, symbol)

		if env.clothing_exclude == nil then
	        env.clothing_exclude = {}
	    end
	    if env.clothing_exclude[name] == nil then
			env.clothing_exclude[name] = {}
	    end
	    table.insert( env.clothing_exclude[name], symbol )
    end
    
end

return {
			InsertPostInitFunctions = InsertPostInitFunctions,
		}
