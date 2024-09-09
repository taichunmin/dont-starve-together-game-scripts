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
					if v.saved_server ~= nil and not get_local_config then
						return v.saved_server

					elseif v.saved_client ~= nil and get_local_config then
						return v.saved_client

					elseif v.saved ~= nil then
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

local function AddModCharacter(name, gender, modes)
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

	MODCHARACTERMODES[name] = modes
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

local function InsertPostInitFunctions(env, isworldgen, isfrontend)

    env.modassert = modassert
    env.moderror = moderror

	env.postinitfns = {}
	env.postinitdata = {}

	if isfrontend then
		env.ReloadFrontEndAssets = function()
			initprint("ReloadFrontEndAssets")
			if env.FrontEndAssets then
				ModReloadFrontEndAssets(env.FrontEndAssets, env.modname)
			end
		end
	end

	-- Used to preload assets before they get loaded regularly; use mainly for modifying loading screen tip icons
	-- Assets is a table list defined the same as in any prefab file and uses .tex and .xml file data
	--[[ e.g.
		Assets = {
			Asset( "IMAGE", "<path to .tex file relative to the mod's folder>" ),
			Asset( "ATLAS", "<path to .xml file relative to the mod's folder>" ),
		}]]
	if not isworldgen then
		env.ReloadPreloadAssets = function()
			initprint("ReloadPreloadAssets")
			if env.PreloadAssets then
				ModPreloadAssets(env.PreloadAssets, env.modname)
			end
		end
	end

	local Customize = require("map/customize")
	env.AddCustomizeGroup = function(category, name, text, desc, atlas, order)
		initprint("AddCustomizeGroup", category, name)
		Customize.AddCustomizeGroup(env.modname, category, name, text, desc, atlas, order)
	end

	env.RemoveCustomizeGroup = function(category, name)
		initprint("RemoveCustomizeGroup", category, name)
		Customize.RemoveCustomizeGroup(env.modname, category, name)
	end

	env.AddCustomizeItem = function(category, group, name, itemsettings)
		initprint("AddCustomizeItem", category, group, name)
		Customize.AddCustomizeItem(env.modname, category, group, name, itemsettings)
	end

	env.RemoveCustomizeItem = function(category, name)
		initprint("RemoveCustomizeItem", category, name)
		Customize.RemoveCustomizeItem(env.modname, category, name)
	end

	env.GetCustomizeDescription = function(description)
		initprint("GetCustomizeDescription", description)
		return Customize.GetDescription(description)
	end

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
		AddModLocation(env.modname, arg1)
	end
	env.AddLevel = function(arg1, arg2, ...)
		initprint("AddLevel", arg1, arg2.id)

		arg2 = modcompatability.UpgradeModLevelFromV1toV2(env.modname, arg2)

		AddModLevel(env.modname, arg1, arg2)
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

	local TileManager = require("tilemanager")
	env.RegisterTileRange = function(range_name, range_start, range_end)
		initprint("RegisterTileRange", range_name)
		mod_protect_TileManager = false
		TileManager.RegisterTileRange(range_name, range_start, range_end)
		mod_protect_TileManager = true
	end

	env.AddTile = function(tile_name, tile_range, tile_data, ground_tile_def, minimap_tile_def, turf_def)
		initprint("AddTile", tile_name)
		mod_protect_TileManager = false
		TileManager.AddTile(
			tile_name,
			tile_range,
			tile_data,
			ground_tile_def,
			minimap_tile_def,
			turf_def
		)
		mod_protect_TileManager = true
	end

	env.ChangeTileRenderOrder = function(tile_id, target_tile_id, moveafter)
		initprint("ChangeTileRenderOrder", tile_id)
		mod_protect_TileManager = false
		TileManager.ChangeTileRenderOrder(tile_id, target_tile_id, moveafter)
		mod_protect_TileManager = true
	end

	env.SetTileProperty = function(tile_id, propertyname, value)
		initprint("SetTileProperty", tile_id)
		mod_protect_TileManager = false
		TileManager.SetTileProperty(tile_id, propertyname, value)
		mod_protect_TileManager = true
	end

	env.ChangeMiniMapTileRenderOrder = function(tile_id, target_tile_id, moveafter)
		initprint("ChangeMiniMapTileRenderOrder", tile_id)
		mod_protect_TileManager = false
		TileManager.ChangeMiniMapTileRenderOrder(tile_id, target_tile_id, moveafter)
		mod_protect_TileManager = true
	end

	env.SetMiniMapTileProperty = function(tile_id, propertyname, value)
		initprint("SetMiniMapTileProperty", tile_id)
		mod_protect_TileManager = false
		TileManager.SetMiniMapTileProperty(tile_id, propertyname, value)
		mod_protect_TileManager = true
	end

	env.AddFalloffTexture = function(falloff_id, falloff_def)
		initprint("AddFalloffTexture", falloff_id)
		mod_protect_TileManager = false
		TileManager.AddFalloffTexture(falloff_id, falloff_def)
		mod_protect_TileManager = true
	end

	env.ChangeFalloffRenderOrder = function(falloff_id, falloff_id_id, moveafter)
		initprint("ChangeFalloffRenderOrder", falloff_id)
		mod_protect_TileManager = false
		TileManager.ChangeFalloffRenderOrder(falloff_id, falloff_id_id, moveafter)
		mod_protect_TileManager = true
	end

	env.SetFalloffProperty = function(falloff_id, propertyname, value)
		initprint("SetFalloffProperty", falloff_id)
		mod_protect_TileManager = false
		TileManager.SetFalloffProperty(falloff_id, propertyname, value)
		mod_protect_TileManager = true
	end

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
		action.code = #ACTION_MOD_IDS[action.mod_name]
		if MOD_ACTIONS_BY_ACTION_CODE[action.mod_name] == nil then
			MOD_ACTIONS_BY_ACTION_CODE[action.mod_name] = {}
		end
		MOD_ACTIONS_BY_ACTION_CODE[action.mod_name][action.code] = action

		STRINGS.ACTIONS[action.id] = action.str

		return ACTIONS[action.id]
	end

	env.AddComponentAction = function(actiontype, component, fn)
		-- just past this along to the global function
		AddComponentAction(actiontype, component, fn, env.modname)
	end

	env.AddPopup = function(id)
		local popup
		if type(id) == "table" and id.is_a and id:is_a(PopupManagerWidget) then
			popup = id
		else
			popup = PopupManagerWidget()
			popup.id = id
		end
		popup.mod_name = env.modname

		initprint("AddPopup", popup.id)
		POPUPS[popup.id] = popup

		--put it's mapping into a different IDS table, one for each mod
		if MOD_POPUP_IDS[popup.mod_name] == nil then
			MOD_POPUP_IDS[popup.mod_name] = {}
		end
		table.insert(MOD_POPUP_IDS[popup.mod_name], popup.id)
		popup.code = #MOD_POPUP_IDS[popup.mod_name]

		if MOD_POPUPS_BY_POPUP_CODE[popup.mod_name] == nil then
			MOD_POPUPS_BY_POPUP_CODE[popup.mod_name] = {}
		end
		MOD_POPUPS_BY_POPUP_CODE[popup.mod_name][popup.code] = popup

		return POPUPS[popup.id]
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

	env.postinitfns.ModShadersInit = {}
	env.AddModShadersInit = function( fn )
		initprint("AddModShadersInit")
		table.insert(env.postinitfns.ModShadersInit, fn)
	end

	env.postinitfns.ModShadersSortAndEnable = {}
	env.AddModShadersSortAndEnable = function( fn )
		initprint("AddModShadersSortAndEnable")
		table.insert(env.postinitfns.ModShadersSortAndEnable, fn)
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

	env.postinitfns.RecipePostInitAny = {}
	env.AddRecipePostInitAny = function(fn)
		initprint("AddRecipePostInitAny")
		require("recipe")
		table.insert(env.postinitfns.RecipePostInitAny, fn)
		--run for all existing recipes
		for k, v in pairs(AllRecipes) do
			fn(v)
		end
	end

	env.postinitfns.RecipePostInit = {}
	env.AddRecipePostInit = function(recipename, fn)
		initprint("AddRecipePostInit")
		require("recipe")
		if env.postinitfns.RecipePostInit[recipename] == nil then
			env.postinitfns.RecipePostInit[recipename] = {}
		end
		table.insert(env.postinitfns.RecipePostInit[recipename], fn)
		if AllRecipes[recipename] then
			fn(AllRecipes[recipename])
		end
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
		AddCookerRecipe(cooker, recipe, true) -- please do not try to bypass the true value. It will not work and result in server log spam and cause a worse cookbook experience for the mod users.
		if env.cookerrecipes[cooker] == nil then
	        env.cookerrecipes[cooker] = {}
	    end
	    if recipe.name then
	        table.insert(env.cookerrecipes[cooker], recipe.name)
	    end
	end

	env.AddModCharacter = function(name, gender, modes)
		initprint("AddModCharacter", name, gender, modes)
		AddModCharacter(name, gender, modes)
	end

	env.RemoveDefaultCharacter = function (name)
		initprint("RemoveDefaultCharacter", name)
		RemoveDefaultCharacter(name)
	end

	-- data: see PROTOTYPER_DEFS in recipes.lua for examples
	env.AddPrototyperDef = function(prototyper_prefab, data)
		initprint("AddPrototyperDef", prototyper_prefab)
		require("recipe")
		if prototyper_prefab ~= nil then
			PROTOTYPER_DEFS[prototyper_prefab] = data
		end
	end

	env.AddRecipeFilter = function(filter_def, index)
		-- filter_def.name: This is the filter's id and will need the string added to STRINGS.UI.CRAFTING_FILTERS[name]
		-- filter_def.atlas: atlas for the icon,  can be a string or function
		-- filter_def.image: icon to show in the crafting menu, can be a string or function
		-- filter_def.image_size: (optional) custom image sizing 
		-- filter_def.custom_pos: (optional) This will not be added to the grid of filters
		-- filter_def.recipes: !This is not supported! Create the filter and then pass in the filter to AddRecipe2() or AddRecipeToFilter()

		if filter_def == nil or filter_def.name == nil then
			initprint("Error: AddRecipeFilter called with bad data.")
			return
		end

		filter_def.name = string.upper(filter_def.name)

		local name = filter_def.name

		if filter_def.atlas == nil then
			initprint("Error: AddRecipeFilter "..name.." requires 'atlas'.")
			return
		end
		if filter_def.image == nil then
			initprint("Error: AddRecipeFilter "..name.." requires 'image'.")
			return
		end

		initprint("AddRecipeFilter", name)

		filter_def.recipes = {}
		filter_def.default_sort_values = {}

		if index ~= nil then
			table.insert(CRAFTING_FILTER_DEFS, index, filter_def)
		else
			table.insert(CRAFTING_FILTER_DEFS, filter_def)
		end
		CRAFTING_FILTERS[name] = filter_def
	end

	env.AddRecipeToFilter = function(recipe_name, filter_name)
		initprint("AddRecipeToFilter", recipe_name, filter_name)
		local filter = CRAFTING_FILTERS[filter_name]
		if filter ~= nil and filter.default_sort_values[recipe_name] == nil then
			table.insert(filter.recipes, recipe_name)
			filter.default_sort_values[recipe_name] = #filter.recipes
		end
	end

	env.RemoveRecipeFromFilter = function(recipe_name, filter_name)
		initprint("RemoveRecipeFromFilter", recipe_name, filter_name)
		local filter = CRAFTING_FILTERS[filter_name]
		if filter ~= nil and filter.default_sort_values[recipe_name] ~= nil then
			table.removearrayvalue(filter.recipes, recipe_name)
			filter.default_sort_values = table.invert(filter.recipes)
		end
	end

	-- filters = {"TOOLS", "LIGHT"}
	env.AddRecipe2 = function(name, ingredients, tech, config, filters)
		initprint("AddRecipe2", name)
		require("recipe")
		mod_protect_Recipe = false
		local rec = Recipe2(name, ingredients, tech, config)

		if not rec.is_deconstruction_recipe then
			if config ~= nil and config.nounlock then
				env.AddRecipeToFilter(name, CRAFTING_FILTERS.CRAFTING_STATION.name)
			else
				env.AddRecipeToFilter(name, CRAFTING_FILTERS.MODS.name)
			end

			if filters ~= nil then
				for _, filter_name in ipairs(filters) do
					env.AddRecipeToFilter(name, filter_name)
				end
			end
		end


		mod_protect_Recipe = true
		rec:SetModRPCID()
		return rec
	end

	env.AddCharacterRecipe = function(name, ingredients, tech, config, extra_filters)
		initprint("AddCharacterRecipe", name)
		require("recipe")
		mod_protect_Recipe = false

		local rec = Recipe2(name, ingredients, tech, config)

		if config ~= nil and (config.builder_tag ~= nil or config.builder_skill ~= nil) then
			env.AddRecipeToFilter(name, CRAFTING_FILTERS.CHARACTER.name)
		else
			initprint("Warning: AddCharacterRecipe called for recipe "..name.." without a builder_tag or builder_skill. This recipe will be added to the mods filter instead of the character filter.")
			env.AddRecipeToFilter(name, CRAFTING_FILTERS.MODS.name)
		end

		if extra_filters ~= nil then
			for _, filter_name in ipairs(extra_filters) do
				env.AddRecipeToFilter(name, filter_name)
			end
		end


		mod_protect_Recipe = true
		rec:SetModRPCID()
		return rec
	end

	env.AddDeconstructRecipe = function(name, return_ingredients)
		initprint("AddDeconstructRecipe", name)
		require("recipe")
		mod_protect_Recipe = false
		local rec = DeconstructRecipe(name, return_ingredients)
		mod_protect_Recipe = true
		rec:SetModRPCID()
		return rec
	end

	env.AddRecipe = function(arg1, ...)
		print("Warning: function AddRecipe in modmain is deprecated, please use AddRecipe2. Recipe name:", arg1)
		initprint("AddRecipe", arg1)
		require("recipe")
		mod_protect_Recipe = false
		local rec = Recipe(arg1, ...)

		-- unfortunately recipes added using the old system will not support the crafting_station filter as the prototyper is not able to retrofit into a crafting station
		--if rec.nounlock and rec.tab ~= nil and rec.tab.crafting_station then
		--	env.AddRecipeToFilter(name, CRAFTING_FILTERS.CRAFTING_STATION.name)
		--end


		if rec.builder_tag ~= nil or rec.builder_skill ~= nil then
			env.AddRecipeToFilter(arg1, CRAFTING_FILTERS.CHARACTER.name)
		elseif not rec.is_deconstruction_recipe then
			env.AddRecipeToFilter(arg1, CRAFTING_FILTERS.MODS.name)
		end

		mod_protect_Recipe = true
		rec:SetModRPCID()
		return rec
	end

	env.Recipe = function(...)
		print("Warning: function Recipe in modmain is deprecated, please use AddRecipe")
		return env.AddRecipe(...)
	end

    env.AddRecipeTab = function( rec_str, rec_sort, rec_atlas, rec_icon, rec_owner_tag, rec_crafting_station )
		print("Warning: function AddRecipeTab in modmain is deprecated.")
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

	env.RemoveRemapSoundEvent = function(name) -- Convenience wrapper.
		initprint("RemoveRemapSoundEvent", name)
		TheSim:RemapSoundEvent(name) -- Other second parameter values may be nil / the first parameter.
	end

	env.AddReplicableComponent = function(name)
		initprint("AddReplicableComponent", name)
		AddReplicableComponent(name)
	end

	env.AddModRPCHandler = function( namespace, name, fn )
		initprint( "AddModRPCHandler", namespace, name )
		AddModRPCHandler( namespace, name, fn )
	end

	env.AddClientModRPCHandler = function( namespace, name, fn )
		initprint( "AddClientModRPCHandler", namespace, name )
		AddClientModRPCHandler( namespace, name, fn )
	end

	env.AddShardModRPCHandler = function( namespace, name, fn )
		initprint( "AddShardModRPCHandler", namespace, name )
		AddShardModRPCHandler( namespace, name, fn )
	end

	env.GetModRPCHandler = function( namespace, name )
		initprint( "GetModRPCHandler", namespace, name )
		return GetModRPCHandler( namespace, name )
	end

	env.GetClientModRPCHandler = function( namespace, name )
		initprint( "GetClientModRPCHandler", namespace, name )
		return GetClientModRPCHandler( namespace, name )
	end

	env.GetShardModRPCHandler = function( namespace, name )
		initprint( "GetShardModRPCHandler", namespace, name )
		return GetShardModRPCHandler( namespace, name )
	end

	env.SendModRPCToServer = function( id_table, ... )
		initprint( "SendModRPCToServer", id_table.namespace, id_table.id )
		SendModRPCToServer( id_table, ... )
	end

	env.SendModRPCToClient = function( id_table, ... )
		initprint( "SendModRPCToClient", id_table.namespace, id_table.id )
		SendModRPCToClient( id_table, ... )
	end

	env.SendModRPCToShard = function( id_table, ... )
		initprint( "SendModRPCToShard", id_table.namespace, id_table.id )
		SendModRPCToShard( id_table, ... )
	end

	env.MOD_RPC = MOD_RPC --legacy, mods should use GetModRPC below
	env.CLIENT_MOD_RPC = CLIENT_MOD_RPC --legacy, mods should use GetClientModRPC below
	env.SHARD_MOD_RPC = SHARD_MOD_RPC --legacy, mods should use GetShardModRPC below

	env.GetModRPC = function( namespace, name )
		initprint( "GetModRPC", namespace, name )
		return GetModRPC( namespace, name )
	end
	env.GetClientModRPC = function( namespace, name )
		initprint( "GetClientModRPC", namespace, name )
		return GetClientModRPC( namespace, name )
	end
	env.GetShardModRPC = function( namespace, name )
		initprint( "GetModRPC", namespace, name )
		return GetShardModRPC( namespace, name )
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

	env.RegisterInventoryItemAtlas = function(atlas, prefabname) -- for this to work properly (without having to spawn an item), you should be using the prefab name for the inventory image name
		initprint("RegisterInventoryItemAtlas", atlas, prefabname)
		RegisterInventoryItemAtlas(atlas, prefabname)
	end

	env.RegisterScrapbookIconAtlas = function(atlas, tex)
		initprint("RegisterScrapbookIconAtlas", atlas, tex)
		RegisterScrapbookIconAtlas(atlas, tex)
	end

	env.RegisterSkilltreeBGForCharacter = function(atlas, charactername)
		initprint("AddSkilltreeBGForCharacter", atlas, charactername)
		RegisterSkilltreeBGAtlas(atlas, charactername.."_background.tex")
	end

	env.RegisterSkilltreeIconsAtlas = function(atlas, tex)
		initprint("RegisterSkilltreeIconsAtlas", atlas, tex)
		RegisterSkilltreeIconsAtlas(atlas, tex)
	end

	-- For modding loading tips
	env.AddLoadingTip = function(stringtable, id, tipstring, controltipdata)
		if stringtable == nil or id == nil or tipstring == nil then
			return
		end

		-- Note: Tip needs a unique identifier string to load properly
		stringtable[id] = tipstring

		if controltipdata == nil then
			return
		end

		LOADING_SCREEN_CONTROL_TIP_KEYS[id] = controltipdata
	end

	env.RemoveLoadingTip = function(stringtable, id)
		if stringtable == nil or id == nil then
			return
		end

		stringtable[id] = nil
		LOADING_SCREEN_CONTROL_TIP_KEYS[id] = nil
	end

	-- Loading tip weights when playing the game for the first time (LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_START),
	-- or after a certain amount of time (LOADING_SCREEN_TIP_CATEGORY_WEIGHTS_END), based on the weights table to be modified.
	-- For play time in between, weights are interpolated from the difference between start and end category weights.
	env.SetLoadingTipCategoryWeights = function(weighttable, weightdata)
		for key, weight in pairs(weightdata) do
			weighttable[key] = weight
		end
	end

	env.SetLoadingTipCategoryIcon = function(category, categoryatlas, categoryicon)
		LOADING_SCREEN_TIP_ICONS[category] = { atlas = categoryatlas, icon = categoryicon }
	end
end

return {
	InsertPostInitFunctions = InsertPostInitFunctions,
}
