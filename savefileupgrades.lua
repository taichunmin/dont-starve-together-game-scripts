
local t = nil
t = {
    utilities = {
        UpgradeUserPresetFromV1toV2 = function(preset, custompresets)
            if preset.version ~= nil and preset.version >= 2 then
                return preset
            end
            print(string.format("Upgrading user preset data for '%s' from v1 to v2", preset.data))

            local newid = preset.data
            local newname = preset.text
            local newdesc = preset.desc
            local location = preset.location
            local basepreset = preset.basepreset
            local overrides = preset.overrides

            local Levels = require"map/levels"

            local ret = nil
            if Levels.GetTypeForLevelID(basepreset) == LEVELTYPE.UNKNOWN then
                print(string.format("WARNING: custom preset %s has a non-standard preset for its base (%s). Attempting to recursively upgrade...", newid, basepreset))
                if basepreset ~= newid then
                    for i,custompreset in ipairs(custompresets) do
                        if basepreset == custompreset.id then
                            print("  ...whew! Found an upgraded base to use. Using that.")
                            ret = deepcopy(custompreset)
                            break
                        elseif basepreset == custompreset.data then
                            print("  ...ack. The base preset isn't upgraded either. Trying to uppgrade that...")
                            -- note, this performs the upgrade in place in the custompresets table to prevent infinite recursion ~gjans
                            custompresets[i] = t.utilities.UpgradeUserPresetFromV1toV2(custompreset, custompresets)
                            ret = deepcopy(custompresets[i])
                            break
                        end
                    end
                end

                if ret == nil then
                    print("  ...Could not find a valid base for the preset. Using defaults.")
                    ret = Levels.GetDefaultLevelData(LEVELTYPE.SURVIVAL)
                end
            else
                ret = Levels.GetDataForLevelID(basepreset)
            end

            ret.id = newid
            ret.name = newname
            ret.desc = newdesc
            if ret.location ~= location then
                print(string.format("WARNING: Upgrading preset %s to v2, but there was a location mismatch: '%s' in %s, and '%s' in %s.", newid, tostring(ret.location), basepreset, tostring(location), newid))
            end
            ret.location = location or "forest"

            for i,override in ipairs(overrides) do
                ret.overrides[override[1]] = override[2]
            end

            return ret
        end,
        UpgradeUserPresetFromV2toV3 = function(preset, custompresets)
            if preset.version == nil or preset.version ~= 2 then
                return preset
            end

            print(string.format("Upgrading user preset data for '%s' from v2 to v3 (A New Reign Part 1).", tostring(preset.id)))

            if preset.location == "forest" then
				if preset.ordered_story_setpieces == nil then
					preset.ordered_story_setpieces = {}
				end
				preset.ordered_story_setpieces = ArrayUnion(preset.ordered_story_setpieces, {"Sculptures_1"})
				
				if preset.random_set_pieces == nil then
					preset.random_set_pieces = {}
				end
				preset.random_set_pieces = ArrayUnion(preset.random_set_pieces, {"Sculptures_2", "Sculptures_3", "Sculptures_4", "Sculptures_5"})
			end

			preset.version = 3

            return preset
        end,
        UpgradeUserPresetFromV3toV4 = function(preset, custompresets)
            if preset.version == nil or preset.version ~= 3 then
                return preset
            end

            print(string.format("Upgrading user preset data for '%s' from v2 to v3 (Return of Them: Turn of Tides).", tostring(preset.id)))
			if preset.location == "forest" and preset.overrides.has_ocean ~= true then
				preset.overrides.has_ocean = true
				preset.overrides.keep_disconnected_tiles = true
				preset.overrides.no_wormholes_to_disconnected_tiles = true
				preset.overrides.no_joining_islands = true
				print("  New ocean enabled")
			end

			preset.version = 4
			dumptable(preset, 1, 1)
		end,
        UpgradeSavedLevelFromV1toV2 = function(level, master_world)
            if level.version ~= nil and level.version >= 2 then
                return level
            end

            local basepreset = "SURVIVAL_TOGETHER"
            local newid = nil
            local newname = nil
            local newdesc = nil
            local location = nil
            local overrides = nil
            local tweak = nil
            if level.presetdata ~= nil then
                basepreset = level.presetdata.basepreset or level.presetdata.data
                print(string.format("Upgrading saved level data for '%s' from v1 to v2", tostring(basepreset)))

                newid = level.presetdata.data
                newname = level.presetdata.text
                newdesc = level.presetdata.desc
                location = level.presetdata.location
                overrides = level.presetdata.overrides
                tweak = level.tweak
            else
                print(string.format("Upgrading invalid save level data to v2"))
            end

            local Levels = require"map/levels"
            local Customise = require"map/customise"

            local ret = Levels.GetDataForLevelID(basepreset)
            if ret == nil then
                ret = Levels.GetDefaultLevelData(LEVELTYPE.SURVIVAL, location)
            end

            ret.id = newid or ret.id
            ret.name = newname or ret.name
            ret.desc = newdesc or ret.desc
            if location ~= nil and ret.location ~= location then
                print(string.format("WARNING: Upgrading preset %s to v2, but there was a location mismatch: '%s' in %s, and '%s' in %s.", tostring(newid), tostring(ret.location), basepreset, tostring(location), tostring(newid)))
            end
            ret.location = location or ret.location or "forest"

            local options = Customise.GetOptionsWithLocationDefaults(ret.location, master_world)
            for i, option in ipairs(options) do
                ret.overrides[option.name] = option.default
            end

            if overrides ~= nil then
                for i,override in ipairs(overrides) do
                    ret.overrides[override[1]] = override[2]
                end
            end

            if tweak ~= nil then
                for group,tweaks in pairs(tweak) do
                    for name,value in pairs(tweaks) do
                        ret.overrides[name] = value
                    end
                end
            end

            return ret
        end,
        UpgradeSavedLevelFromV2toV3 = function(level, master_world)
            if level.version ~= 2 then
                return level
            end
            
            print(string.format("Upgrading saved level data for '%s' from v2 to v3 (A New Reign Part 1).", tostring(level.id)))

            if level.location == "forest" then
				if level.ordered_story_setpieces == nil then
					level.ordered_story_setpieces = {}
				end
				level.ordered_story_setpieces = ArrayUnion(level.ordered_story_setpieces, {"Sculptures_1"})
				
				if level.random_set_pieces == nil then
					level.random_set_pieces = {}
				end
				level.random_set_pieces = ArrayUnion(level.random_set_pieces, {"Sculptures_2", "Sculptures_3", "Sculptures_4", "Sculptures_5"})
			end

			level.version = 3
            return level        
        end,
        UpgradeSavedLevelFromV3toV4 = function(level, master_world)
            if level.version ~= 3 then
                return level
            end

			if level.location == "forest" and level.overrides.has_ocean ~= true then
	            print(string.format("Upgrading saved level data for '%s' from v3 to v4 (Return of Them: Turn of Tides).", tostring(level.id)))
				level.overrides.has_ocean = true
				level.overrides.keep_disconnected_tiles = true
				level.overrides.no_wormholes_to_disconnected_tiles = true
				level.overrides.no_joining_islands = true
			end

			level.version = 4
			return level
        end,
        UpgradeWorldgenoverrideFromV1toV2 = function(wgo)
            local validfields = {
                overrides = true,
                preset = true,
                override_enabled = true,
            }
            local needsupgrade = false
            for k,v in pairs(wgo) do
                if validfields[k] == nil then
                    needsupgrade = true
                    break
                end
            end

            if not needsupgrade then
                return wgo
            end

            print("Worldgenoverride needs upgrading from v1 to v2!")

            local ret = {}

            ret.preset = wgo.actualpreset or wgo.preset
            ret.overrides = deepcopy(wgo.overrides or {})
            ret.override_enabled = wgo.override_enabled

            if wgo.presetdata and wgo.presetdata.overrides then
                for i,override in ipairs(wgo.presetdata.overrides) do
                    ret.overrides[override[1]] = override[2]
                end
            end
            wgo.presetdata = nil

            -- We'll just assume that all nested tables contain override data.
            for _,t in pairs(wgo) do
                if type(t) == "table" then
                    for tweak,value in pairs(t) do
                        ret.overrides[tweak] = value
                    end
                end
            end

            print("  Your file will be loaded correctly. However,")
            print("  to ensure it will load correctly in the future,")
            print("  please edit your worldgenoverride.lua to use this format:")
            print("\n\n"..DataDumper(ret).."\n")

            return ret
        end,
    },

-- These functions will be applied in order, starting with the one whose
-- version is higher than the current version in the save file. Version numbers
-- are declared explicitly to prevent the values from getting out of sync
-- somehow.
    upgrades =
    {
        {
            version = 1,
            fn = function(savedata)
                if savedata == nil then
                    return
                end

                --Convert pre-RoG summer to RoG autumn
                print("Converting summer to autumn:")

                if savedata.world_network ~= nil and savedata.world_network.persistdata ~= nil then
                    local seasons = savedata.world_network.persistdata.seasons
                    if seasons ~= nil then
                        print(" -> Updating seasons component")
                        if seasons.season == "summer" then
                            seasons.season = "autumn"
                        end
                        if seasons.preendlessmode then
                            seasons.premode = true
                            seasons.preendlessmode = nil
                        end
                        if seasons.lengths ~= nil then
                            seasons.lengths.autumn = seasons.lengths.summer
                            seasons.lengths.summer = 0
                            seasons.lengths.spring = 0
                        end
                        if seasons.segs ~= nil then
                            seasons.segs.autumn = seasons.segs.summer
                            seasons.segs.summer = { day = 11, dusk = 1, night = 4 }
                            seasons.segs.spring = { day = 5, dusk = 8, night = 3 }
                        end
                    end
                    local weather = savedata.world_network.persistdata.weather
                    if weather ~= nil then
                        print(" -> Updating weather component")
                        if weather.season == "summer" then
                            weather.season = "autumn"
                        end
                    end
                end

                if savedata.map ~= nil and savedata.map.persistdata ~= nil then
                    local worldstate = savedata.map.persistdata.worldstate
                    if worldstate ~= nil then
                        print(" -> Updating worldstate component")
                        worldstate.autumnlength = worldstate.summerlength
                        worldstate.summerlength = 0
                        worldstate.springlength = 0
                        if worldstate.season == "summer" then
                            worldstate.season = "autumn"
                        end
                        worldstate.isautumn = worldstate.issummer
                        worldstate.issummer = false
                        worldstate.isspring = false
                    end

                    local monsters={
                        { "bearger", "never" },
                        { "goosemoose", "never" },
                        { "dragonfly", "never" },
                        { "deciduousmonster", "never" }
                    }
                    local misc={
                        { "frograin", "never" },
                        { "wildfires", "never" }
                    }
                    local original={
                        level_id=2,
                        preset="SURVIVAL_TOGETHER_CLASSIC",
                        tweak={
                            unprepared={
                                cactus="never"
                            },
                            misc={
                                spring="noseason",
                                world_size="large",
                                wildfires="never",
                                summer="noseason",
                                frograin="never",
                                start_setpeice="DefaultStart",
                                season_start="autumn",
                                start_node="Clearing"
                            },
                            animals={
                                moles="never",
                                lightninggoat="never",
                                buzzard="never",
                                catcoon="never"
                            },
                            monsters={
                                bearger="never",
                                deciduousmonster="never",
                                dragonfly="never",
                                goosemoose="never"
                            },
                            resources={
                                rock_ice="never"
                            }
                        }
                    }

                    local overrides = savedata.map.topology and savedata.map.topology.overrides
                    if overrides ~= nil then
                        print("Merging overrides with Vanilla versions")

                        if overrides.monsters then
                            overrides.monsters = MergeKeyValueList(monsters, overrides.monsters)
                        else
                            overrides.monsters = monsters
                        end

                        if overrides.misc then
                            overrides.misc = MergeKeyValueList(misc, overrides.misc)
                        else
                            overrides.misc = misc
                        end

                        if overrides.original then
                            overrides.original = MergeMapsDeep(original, overrides.original)
                        else
                            overrides.original = original
                        end
                        
                    else
                        print("No overrides found, supplying Vanilla versions")
                        savedata.map.topology.overrides = {
                            monsters,
                            misc,
                            original
                        }
                    end
                end

            end,
        },
        {
            version = 2,
            fn = function(savedata)
                if savedata == nil then
                    return
                end

                --print("One-time disabling of prefab swap management.")
                --savedata.map.topology.overrides.prefabswaps = nil
                --savedata.map.topology.overrides.original.prefabswaps = "default"
                --if savedata.map.persistdata ~= nil and savedata.map.persistdata.prefabswapmanager ~= nil then
                    --savedata.map.persistdata.prefabswapmanager.changes = {}
                --end
            end,
        },
        {
            version = 3,
            fn = function(savedata)
                if savedata == nil then
                    return
                end

                print("Checking for default prefab swaps and disabling if necessary.")
                if savedata.map.topology.overrides.prefabswaps == nil
                    or savedata.map.topology.overrides.prefabswaps == "default" then -- Default is now zero swaps.
                    if savedata.map.persistdata ~= nil and savedata.map.persistdata.prefabswapmanager ~= nil then
                        savedata.map.persistdata.prefabswapmanager.changes = {}
                    end
                end
            end,
        },
        {
            version = 4, -- ANR:A Little Fixer Upper
            fn = function(savedata)
                if savedata == nil then
                    return
                end
				if savedata.map ~= nil and savedata.map.prefab == "forest" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitforestmap_anr == nil then
						savedata.map.persistdata.retrofitforestmap_anr = {}
					end
					savedata.map.persistdata.retrofitforestmap_anr.retrofit_part1 = true
				end
            end,
        },
        {
            version = 4.1, -- ANR:Warts and All
            fn = function(savedata)
                if savedata == nil then
                    return
                end
				if savedata.map ~= nil and savedata.map.prefab == "cave" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitcavemap_anr == nil then
						savedata.map.persistdata.retrofitcavemap_anr = {}
					end
					savedata.map.persistdata.retrofitcavemap_anr.retrofit_warts = true
				end
            end,
        },
        {
            version = 4.2, -- ANR:Arts and Crafts
            fn = function(savedata)
                if savedata == nil then
                    return
                end
				if savedata.map ~= nil and savedata.map.prefab == "cave" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitcavemap_anr == nil then
						savedata.map.persistdata.retrofitcavemap_anr = {}
					end
					savedata.map.persistdata.retrofitcavemap_anr.retrofit_artsandcrafts = true
					
				elseif savedata.map ~= nil and savedata.map.prefab == "forest" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitforestmap_anr == nil then
						savedata.map.persistdata.retrofitforestmap_anr = {}
					end
					savedata.map.persistdata.retrofitforestmap_anr.retrofit_artsandcrafts = true
				end
            end,
        },
        {
            version = 4.3, -- ANR:Arts and Crafts 2
            fn = function(savedata)
                if savedata == nil then
                    return
                end
                if savedata.map ~= nil and savedata.map.prefab == "forest" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitforestmap_anr == nil then
                        savedata.map.persistdata.retrofitforestmap_anr = {}
                    end
                    savedata.map.persistdata.retrofitforestmap_anr.retrofit_artsandcrafts2 = true
                end
            end,
        },
        {
            version = 4.4, -- ANR: Cute Fuzzy Animals
            fn = function(savedata)
                if savedata == nil then
                    return
                end
                if savedata.map ~= nil and savedata.map.prefab == "forest" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitforestmap_anr == nil then
                        savedata.map.persistdata.retrofitforestmap_anr = {}
                    end
                    savedata.map.persistdata.retrofitforestmap_anr.retrofit_cutefuzzyanimals = true
                end
            end,
        },
        
        {
            version = 4.5, -- ANR: Cute Herd Mentality
            fn = function(savedata)
                if savedata == nil then
                    return
                end
                if savedata.map ~= nil and savedata.map.prefab == "forest" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitforestmap_anr == nil then
                        savedata.map.persistdata.retrofitforestmap_anr = {}
                    end
                    savedata.map.persistdata.retrofitforestmap_anr.retrofit_herdmentality = true
                end
            end,
        },
        
        {
            version = 4.6, -- ANR: Against the Grain
            fn = function(savedata)
                if savedata == nil then
                    return
                end
                if savedata.map ~= nil and savedata.map.prefab == "forest" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitforestmap_anr == nil then
                        savedata.map.persistdata.retrofitforestmap_anr = {}
                    end
                    savedata.map.persistdata.retrofitforestmap_anr.retrofit_againstthegrain = true
                end
            end,
        },

        {
            version = 4.71, -- ANR: Heart of the Ruins
            fn = function(savedata)
                if savedata == nil then
                    return
                end
				if savedata.map ~= nil and savedata.map.prefab == "cave" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitcavemap_anr == nil then
						savedata.map.persistdata.retrofitcavemap_anr = {}
					end

					savedata.map.persistdata.retrofitcavemap_anr.retrofit_heartoftheruins = true
				end
            end,
        },
 
        {
            version = 4.72, -- ANR: Heart of the Ruins - fix for ruinsrespawners
            fn = function(savedata)
                if savedata == nil then
                    return
                end
				if savedata.map ~= nil and savedata.map.prefab == "cave" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitcavemap_anr == nil then
						savedata.map.persistdata.retrofitcavemap_anr = {}
					end

					savedata.map.persistdata.retrofitcavemap_anr.retrofit_heartoftheruins_respawnerfix = true
				end
            end,
        },
 
        {
            version = 4.73, -- ANR: Heart of the Ruins - altars
            fn = function(savedata)
                if savedata == nil then
                    return
                end
				if savedata.map ~= nil and savedata.map.prefab == "cave" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitcavemap_anr == nil then
						savedata.map.persistdata.retrofitcavemap_anr = {}
					end

					savedata.map.persistdata.retrofitcavemap_anr.retrofit_heartoftheruins_altars = true
				end
            end,
        },

        {
            version = 4.731, -- ANR: Penguin Ice
            fn = function(savedata)
                if savedata == nil then
                    return
                end
                if savedata.map ~= nil and savedata.map.prefab == "forest" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitforestmap_anr == nil then
                        savedata.map.persistdata.retrofitforestmap_anr = {}
                    end
                    savedata.map.persistdata.retrofitforestmap_anr.retrofit_penguinice = true
                end
            end,
        },

        {
            version = 4.74, -- ANR: Heart of the Ruins - cave holes
            fn = function(savedata)
                if savedata == nil then
                    return
                end
				if savedata.map ~= nil and savedata.map.prefab == "cave" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitcavemap_anr == nil then
						savedata.map.persistdata.retrofitcavemap_anr = {}
					end

					savedata.map.persistdata.retrofitcavemap_anr.retrofit_heartoftheruins_caveholes = true
				end
            end,
        },

        {
            version = 4.751, -- ANR: Heart of the Ruins - atrium fixup for gate position and world node
            fn = function(savedata)
                if savedata == nil then
                    return
                end
				if savedata.map ~= nil and savedata.map.prefab == "cave" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitcavemap_anr == nil then
						savedata.map.persistdata.retrofitcavemap_anr = {}
					end

					savedata.map.persistdata.retrofitcavemap_anr.retrofit_heartoftheruins_oldatriumfixup = true
				end
            end,
        },

        {
            version = 4.76, -- ANR: Heart of the Ruins - respawners for chessjunk and statues
            fn = function(savedata)
                if savedata == nil then
                    return
                end
				if savedata.map ~= nil and savedata.map.prefab == "cave" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitcavemap_anr == nil then
						savedata.map.persistdata.retrofitcavemap_anr = {}
					end

					savedata.map.persistdata.retrofitcavemap_anr.retrofit_heartoftheruins_statuechessrespawners = true
				end
            end,
        },

        {
            version = 4.77, -- ANR: sacred_chest
            fn = function(savedata)
                if savedata == nil then
                    return
                end
				if savedata.map ~= nil and savedata.map.prefab == "cave" and savedata.map.persistdata ~= nil then
                    if savedata.map.persistdata.retrofitcavemap_anr == nil then
						savedata.map.persistdata.retrofitcavemap_anr = {}
					end

					savedata.map.persistdata.retrofitcavemap_anr.retrofit_sacred_chest = true
				end
            end,
        },

        {
            version = 5.00, -- RoT: Turn of Tides
            fn = function(savedata)
                if savedata == nil then
                    return
                end

                if savedata.map ~= nil and savedata.map.prefab == "forest" and savedata.map.persistdata ~= nil then
					if not savedata.map.has_ocean then
						savedata.map.has_ocean = true

						if savedata.map.persistdata.retrofitforestmap_anr == nil then
							savedata.map.persistdata.retrofitforestmap_anr = {}
						end
						savedata.map.persistdata.retrofitforestmap_anr.retrofit_turnoftides = true
						savedata.retrofit_oceantiles = true -- since we have a large number of tiles to convert to the ocean, it needs to be done before the map is finalized
					end
                end
             end,
        },

        {
            version = 5.01, -- RoT: Turn of Tides - adds the ocean and island to the nav grid for pathfinding
            fn = function(savedata)
                if savedata ~= nil and savedata.map ~= nil and savedata.map.prefab == "forest" and savedata.map.persistdata ~= nil then
					if savedata.map.persistdata.retrofitforestmap_anr == nil then
						savedata.map.persistdata.retrofitforestmap_anr = {}
					end
					savedata.map.persistdata.retrofitforestmap_anr.retrofit_turnoftides_betaupdate1 = true
                end
             end,
        },

        {
            version = 5.02, -- RoT: Turn of Tides - repopulate the seastacks to something slightly more interesting
            fn = function(savedata)
                if savedata ~= nil and savedata.map ~= nil and savedata.map.prefab == "forest" and savedata.map.persistdata ~= nil then
					if savedata.map.persistdata.retrofitforestmap_anr == nil then
						savedata.map.persistdata.retrofitforestmap_anr = {}
					end
					savedata.map.persistdata.retrofitforestmap_anr.retrofit_turnoftides_seastacks = true
                end
             end,
        },

		

    },
}

local highestversion = -1
for i,upgrade in ipairs(t.upgrades) do
    assert(upgrade.version > highestversion, string.format("Save file upgrades being applied in wrong order! %s followed %s!",upgrade.version, highestversion))
    highestversion = upgrade.version
end

t.VERSION = highestversion

return t
