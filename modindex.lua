require("mods")
require("modutil")

local mod_config_path = "mod_config_data/"

--redirect existing mod dependency solutions into ours
package.preload["moddependencymanager"] = function() end
package.preload["librarymanager"] = function()
	return function(_dependencies)
		local modenv = getfenv(2)
		if not rawget(_G, "TheFrontEnd") or (not _dependencies or not modenv or not modenv.modname or (KnownModIndex.savedata.known_mods[modenv.modname] and
			KnownModIndex.savedata.known_mods[modenv.modname].dependencies)) then return end
		local dependencies = {}
		for i, v in ipairs(_dependencies) do
			table.insert(dependencies, {v})
		end
		KnownModIndex.savedata.known_mods[modenv.modname].dependencies = dependencies
		local mods_tab
		for i, screen in ipairs(TheFrontEnd.screenstack) do
			if screen and screen.mods_tab then
				mods_tab = screen.mods_tab
				break
			end
		end
		if mods_tab then
			local mod_dependencies = KnownModIndex:GetModDependencies(modenv.modname, true)
			if KnownModIndex:DoModsExistAnyVersion(mod_dependencies) then
				mods_tab:EnableModDependencies(mod_dependencies)
			else
				mods_tab:DisplayModDependencies(modenv.modname, mod_dependencies)
				return
			end
		end
	end
end
package.preload["tools/librarymanager"] = package.preload["librarymanager"]
package.preload["libs/librarymanager"] = package.preload["librarymanager"]

-- Note: This is a singleton (created at the bottom of this file) so the class is local
local ModIndex = Class(function(self)
	self.startingup = false
	self.cached_data = {}
	self.savedata =
	{
		known_mods = { },
		known_api_version = 0,
		disable_special_event_warning = false,
	}
	self.forceddirs = {}
	self.mod_dependencies =
	{
		server_dependency_list = {},
		dependency_list = {},
	}
	if IsConsole() then
		self.modsettings = {}
	end
end)

--[[
known_mods = {
	[modname] = {
		enabled = true,
		disabled_bad = true,
		modinfo = {
			version = "1.2",
			api_version = 2,
			failed = false,
		},
	}
}
--]]

function ModIndex:GetModIndexName()
    return BRANCH ~= "dev" and "modindex" or ("modindex_"..BRANCH)
end

function ModIndex:GetModConfigurationPath(modname, client_config)
	if modname then
		return mod_config_path..self:GetModConfigurationName(modname, client_config)
	else
		return mod_config_path
	end
end

function ModIndex:GetModConfigurationName(modname, client_config)
	local name = "modconfiguration_"..modname
	if BRANCH ~= "release" then
		name = name .. "_"..BRANCH
	end
	if self:GetModInfo(modname) and not self:GetModInfo(modname).client_only_mod and client_config then
		name = name .. "_CLIENT"
	end
	return name
end

function ModIndex:BeginStartupSequence(callback)
	self.startingup = true

	if TheNet:IsDedicated() then
		print("ModIndex: Beginning normal load sequence for dedicated server.\n")
		self:DisableAllMods() --We assume the mods will be re-enabled by the modoverrides.lua file
		callback()
	else
		local filename = "boot_"..self:GetModIndexName()
		TheSim:GetPersistentString(filename,
			function(load_success, str)
				if load_success and str == "loading" then
					local modsenabled = self:GetModsToLoad()
					if #modsenabled > 0 then
						self.badload = true
						print("ModIndex: Detected bad load, disabling all mods.")
						self:DisableAllMods()
						self:Save(nil) -- write to disk that all mods were disabled!
					end
					callback()
				else
					print("ModIndex: Beginning normal load sequence.\n")
					SavePersistentString(filename, self.modsettings.disablemods and "loading" or "done", false, callback)
				end
			end)
	end
end

function ModIndex:EndStartupSequence(callback)
	self.startingup = false
	local filename = "boot_"..self:GetModIndexName()
	SavePersistentString(filename, "done", false, callback)
	print("ModIndex: Load sequence finished successfully.")
end

function ModIndex:WasLoadBad()
	return self.badload == true
end

function ModIndex:GetModNames()
	local names = {}
	for name,_ in pairs(self.savedata.known_mods) do
		table.insert(names, name)
	end
	return names
end

function ModIndex:GetServerModNames()
	local names = {}
	for modname,_ in pairs(self.savedata.known_mods) do
		if not self:GetModInfo(modname).client_only_mod then
			table.insert(names, modname)
		end
	end
	return names
end

function ModIndex:GetClientModNames()
	local names = {}
	for modname,_ in pairs(self.savedata.known_mods) do
		if self:GetModInfo(modname).client_only_mod then
			table.insert(names, modname)
		end
	end
	return names
end

function ModIndex:GetClientModNamesTable()
	local names = {}
	for known_modname,_ in pairs(self.savedata.known_mods) do
		if self:GetModInfo(known_modname).client_only_mod then
			table.insert(names, {modname = known_modname})
		end
	end
	return names
end

function ModIndex:GetServerModNamesTable()
	local names = {}
	for known_modname,_ in pairs(self.savedata.known_mods) do
		if not self:GetModInfo(known_modname).client_only_mod then
			table.insert(names, {modname = known_modname})
		end
	end
	return names
end

function ModIndex:Save(callback)
    if IsConsole() then
        return
    end

	local newdata = { known_mods = {} }
	newdata.known_api_version = MOD_API_VERSION
	newdata.disable_special_event_warning = self.savedata.disable_special_event_warning

	for name, data in pairs(self.savedata.known_mods) do
		newdata.known_mods[name] = {}
		newdata.known_mods[name].enabled = data.enabled
		newdata.known_mods[name].favorite = data.favorite
		newdata.known_mods[name].temp_enabled = data.temp_enabled
		newdata.known_mods[name].temp_disabled = data.temp_disabled
		newdata.known_mods[name].disabled_bad = data.disabled_bad
		newdata.known_mods[name].disabled_incompatible_with_mode = data.disabled_incompatible_with_mode
		newdata.known_mods[name].seen_api_version = MOD_API_VERSION
		--newdata.known_mods[name].modinfo = data.modinfo --modinfo is no longer saved in the modindex. To remove the clutter from the modindex and to get rid of unreadable modindex files due to mods with invalid modinfo files
		newdata.known_mods[name].temp_config_options = data.temp_config_options
	end

	--print("\n\n---SAVING MOD INDEX---\n\n")
	--dumptable(newdata)
	--print("\n\n---END SAVING MOD INDEX---\n\n")
	local fastmode = true
	local data = DataDumper(newdata, nil, fastmode)
    local insz, outsz = SavePersistentString(self:GetModIndexName(), data, ENCODE_SAVES, callback)
end

local workshop_prefix = "workshop-"
--This function only works if the modindex has been updated
function ResolveModname(modname)
	--try to convert from Workshop id to modname
	if KnownModIndex:DoesModExistAnyVersion(modname) then
		return modname
	else
		--modname wasn't found, try it as a workshop mod
		local workshop_modname = workshop_prefix..modname
		if KnownModIndex:DoesModExistAnyVersion(workshop_modname) then
			return workshop_modname
		end
	end
	return nil
end

function IsWorkshopMod(modname)
	if modname == nil then
		return false
	end
	return modname:sub( 1, workshop_prefix:len() ) == workshop_prefix
end

function GetWorkshopIdNumber(modname)
	return string.sub(modname, workshop_prefix:len() + 1)
end

function ModIndex:GetTempEnabledMods()
	local moddirs = {}
	for name, data in pairs(self.savedata.known_mods) do
		if data.temp_enabled then
			table.insert(moddirs, name)
		end
	end
	return moddirs
end

function ModIndex:GetForceEnabledMods()
	local moddirs = {}
	for name in pairs(self.modsettings.forceenable) do
		if (IsWorkshopMod(name)) then
			table.insert(moddirs, name)
		else
			if tonumber(name) then
				table.insert(moddirs, "workshop-"..name)
			else
				table.insert(moddirs, name)
			end
		end
	end
	return moddirs
end

function ModIndex:GetModsToLoad(usecached)
	local cached = usecached or false

	local ret = {}
	if not cached then
		local moddirs = TheSim:GetModDirectoryNames()
		local mods_to_load = {}
		for i,moddir in ipairs(moddirs) do
			if ((self:IsModEnabled(moddir) or self:IsModForceEnabled(moddir) or self:IsModTempEnabled(moddir) ) and not self:IsModTempDisabled(moddir)) and not mods_to_load[moddir] then
				print("ModIndex:GetModsToLoad inserting moddir, ", moddir)
				mods_to_load[moddir] = true
				table.insert(ret, moddir)
			end
		end
		for i, moddir in ipairs(self:GetTempEnabledMods()) do
			if not table.contains(moddirs, moddir) then
				self.forceddirs[moddir] = true
			end
		end
		for i, moddir in ipairs(self:GetForceEnabledMods()) do
			if not table.contains(moddirs, moddir) then
				self.forceddirs[moddir] = true
			end
		end
		for moddir in pairs(self.forceddirs) do
			if ((self:IsModEnabled(moddir) or self:IsModForceEnabled(moddir) or self:IsModTempEnabled(moddir) ) and not self:IsModTempDisabled(moddir)) and not mods_to_load[moddir] then
				print("ModIndex:GetModsToLoad inserting forcedmoddir, ", moddir)
				mods_to_load[moddir] = true
				table.insert(ret, moddir)
			end
		end
	else
		if self.savedata and self.savedata.known_mods then
			for modname, moddata in pairs(self.savedata.known_mods) do
				if (self:IsModEnabled(modname) or self:IsModForceEnabled(modname) or self:IsModTempEnabled(modname) ) and not self:IsModTempDisabled(modname) then
					print("ModIndex:GetModsToLoad inserting modname, ", modname)
					table.insert(ret, modname)
				end
			end
		end
	end
	for i,modname in ipairs(ret) do
		if self:IsModStandalone(modname) then
			print("\n\n"..ModInfoname(modname).." Loading a standalone mod! No other mods will be loaded.\n")
			return { modname }
		end
	end
	return ret
end

function ModIndex:GetModInfo(modname)
	if self.savedata.known_mods[modname] then
		return self.savedata.known_mods[modname].modinfo or {}
	else
		modprint("unknown mod " .. tostring(modname))
		return nil
	end
end

function ModIndex:UpdateModInfo()
	modprint("Updating all mod info.")

	local modnames = TheSim:GetModDirectoryNames()

	for modname,moddata in pairs(self.savedata.known_mods) do
		if not table.contains(modnames, modname) and not self.forceddirs[modname] then
			if moddata.temp_enabled then
				if not self.savedata.known_mods[modname] then
					self.savedata.known_mods[modname] = {}
				end
				self.savedata.known_mods[modname].modinfo = self:LoadModInfo(modname, self.savedata.known_mods[modname].modinfo)
			else
				self.savedata.known_mods[modname] = nil
			end
		end
	end

	for i,modname in ipairs(modnames) do
		if not self.savedata.known_mods[modname] then
			self.savedata.known_mods[modname] = {}
		end
		self.savedata.known_mods[modname].modinfo = self:LoadModInfo(modname, self.savedata.known_mods[modname].modinfo)
	end

	for modname in pairs(self.forceddirs) do
		if not self.savedata.known_mods[modname] then
			self.savedata.known_mods[modname] = {}
		end
		self.savedata.known_mods[modname].modinfo = self:LoadModInfo(modname, self.savedata.known_mods[modname].modinfo)
	end
end

function ModIndex:UpdateSingleModInfo(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].modinfo = self:LoadModInfo(modname, self.savedata.known_mods[modname].modinfo)
end

function ModIndex:LoadModOverides(shardGameIndex)
	if TheNet:GetIsClient() then
		return {}
	end

    local overrides = {}
    local filename = "../modoverrides.lua"

    local function onload(load_success, str)
        if load_success == true then
            local fn, message = loadstring(str)
            if fn ~= nil then
                local env = {}
                local success, r = RunInEnvironment(fn, env)
				if success and type(r) == "table" then
					print("SUCCESS: Loaded modoverrides.lua")
                    overrides = r
                else
                    print("ERROR: Failed to run code from modoverrides.lua")
                end
            else
                print("ERROR: Failed to load modoverrides.lua")
            end
        end
    end

	--ShardGameIndex isn't loaded yet, load a temp one for this test...
	shardGameIndex = shardGameIndex or ShardGameIndex
	if not shardGameIndex then
		require("shardindex")
		shardGameIndex = ShardIndex()
		shardGameIndex:Load()
	end
    if not TheNet:IsDedicated() and shardGameIndex:IsValid() and not shardGameIndex:GetServerData().use_legacy_session_path then
        TheSim:GetPersistentStringInClusterSlot(shardGameIndex:GetSlot(), "Master", filename, onload)
    else
        TheSim:GetPersistentString(filename, onload)
    end

    return overrides
end


function ModIndex:TryLoadMod(modname)
	if self.savedata.known_mods[modname] then return true end
	if kleifileexists(MODS_ROOT..modname.."/modinfo.lua") then
		self.forceddirs[modname] = true
		self:UpdateSingleModInfo(modname)
		return true
	end
	return false
end

function ModIndex:ApplyEnabledOverrides(mod_overrides) --Note(Peter): This function is now coupled with the format written by ShardSaveIndex:SetSlotEnabledServerMods
	if mod_overrides == nil then
		print("Warning: modoverrides.lua is empty, or is failing to return a table.")
	else
		--Enable mods that are being forced on in the modoverrides.lua file
		--print("ModIndex:ApplyEnabledOverrides for mods" )
		for modname,env in pairs(mod_overrides) do
			if modname == "client_mods_disabled" then
				self:DisableClientMods( env ) --env is a bool in this case
			else
				if env.enabled ~= nil then
					if not self:TryLoadMod(modname) then
						self:TryLoadMod(workshop_prefix..modname)
					end
					local actual_modname = ResolveModname(modname)
					if actual_modname ~= nil then
						if env.enabled then
							print( "modoverrides.lua enabling " .. actual_modname )
							self:Enable(actual_modname)
						else
							self:Disable(actual_modname)
						end
					end
				end
			end
		end
	end
end

function ModIndex:ApplyConfigOptionOverrides(mod_overrides)
	--print("ModIndex:ApplyConfigOptionOverrides for mods" )
	for modname,env in pairs(mod_overrides) do
		if modname == "client_mods_disabled" then
			--Do nothing here for this entry
		else
			if env.configuration_options ~= nil then
				local actual_modname = ResolveModname(modname)
				if actual_modname ~= nil then
					print( "applying configuration_options from modoverrides.lua to mod " .. actual_modname )

					local force_local_options = true
					local config_options = self:GetModConfigurationOptions_Internal(actual_modname,force_local_options)

					if config_options and type(config_options) == "table" then
						for option,override in pairs(env.configuration_options) do
							for _,config_option in pairs(config_options) do
			  					if config_option.name == option then
			  						print( "Overriding mod " .. actual_modname .. "'s option " .. option .. " with value " .. tostring(override) )
			  						config_option.saved = override
			  					end
							end
						end
					end
				end
			end
		end
	end
end

local function FindEnabledMod(self, v)
    if self:IsModEnabledAny(v.workshop) then
        return v.workshop
    end
    for modname, isfancy in ipairs(v) do
        if modname ~= "workshop" then
            modname = not isfancy and modname or self:GetModActualName(modname)
            if self:IsModEnabledAny(modname) then
                return modname
            end
        end
    end
end

local function BuildModPriorityList(self, v, is_workshop)
    local workshop = v.workshop
	local mods = {}
    for modname, isfancy in pairs(v) do
        if modname ~= "workshop" then
            modname = not isfancy and modname or self:GetModActualName(modname)
            if self:DoesModExistAnyVersion(modname) then
                table.insert(mods, modname)
            end
        end
	end
	if workshop then
		--prioritize workshop mods if the mod is_workshop, otherwise its the last resort
		table.insert(mods, is_workshop and 1 or #mods+1, workshop)
	end
	return mods
end

local print_atlas_warning = true
function ModIndex:LoadModInfo(modname, prev_info)
	modprint(string.format("Updating mod info for '%s'", modname))

	local info = self:InitializeModInfo(modname)
	if info.failed then
		modprint("  But there was an error loading it.")
		self:DisableBecauseBad(modname)
	else
		-- we've already "dealt" with this in the past; if the user
		-- chooses to enable it, then try loading it!
	end

	self.savedata.known_mods[modname].modinfo = info
	for i,v in pairs(self.savedata.known_mods[modname].modinfo) do
		-- print(i,v)
	end

	info.version = TrimString(info.version or "")
	info.version = string.lower(info.version)
	info.version_compatible = type(info.version_compatible) == "string" and info.version_compatible or info.version
	info.version_compatible = TrimString( info.version_compatible )
	info.version_compatible = string.lower(info.version_compatible)

	if prev_info ~= nil and prev_info.version == info.version then return prev_info end

	if info.icon_atlas ~= nil and info.icon ~= nil and info.icon_atlas ~= "" and info.icon ~= "" then
		local atlaspath = MODS_ROOT..modname.."/"..info.icon_atlas
		local iconpath = string.gsub(atlaspath, "/[^/]*$", "") .. "/"..info.icon
		if softresolvefilepath(atlaspath) and softresolvefilepath(iconpath) then
			info.icon_atlas = atlaspath
			info.iconpath = iconpath
		else
			-- This prevents malformed icon paths from crashing the game.
			if print_atlas_warning then
				print(string.format("WARNING: icon paths for mod %s are not valid. Got icon_atlas=\"%s\" and icon=\"%s\".\nPlease ensure that these point to valid files in your mod folder, or else comment out those lines from your modinfo.lua.", ModInfoname(modname), info.icon_atlas, info.icon))
				print_atlas_warning = false
			end
			info.icon_atlas = nil
			info.iconpath = nil
			info.icon = nil
		end
	else
		info.icon_atlas = nil
		info.iconpath = nil
		info.icon = nil
	end

	--Add game modes
	if info.game_modes then
		for _,mode in pairs(info.game_modes) do
			local gm = AddGameMode(mode.name, mode.label)
			gm.description = mode.description or ""
			if mode.settings then
				for option,value in pairs(mode.settings) do
					gm[option] = value
				end
			end
		end
	end

    if info.mod_dependencies and not info.client_only_mod then --todo(Zachary): support client mods in the future
		local dependencies = {}
		self.savedata.known_mods[modname].dependencies = dependencies
        for i, v in ipairs(info.mod_dependencies) do
            --if a mod is already enabled, use that version.
            local enabledmod = FindEnabledMod(self, v)
            if enabledmod then
                table.insert(dependencies, {enabledmod})
            else
                local mods = BuildModPriorityList(self, v, IsWorkshopMod(modname))
                if #mods == 0 then
                    modprint("no valid dependent mod found for mod "..modname)
					self:DisableBecauseBad(modname)
				end
				table.insert(dependencies, mods)
            end
        end
	end

	return info
end

function ModIndex:InitializeModInfo(modname)
	local env = {
		folder_name = modname,
		locale = LOC.GetLocaleCode(),
		ChooseTranslationTable = function(tbl)
			local locale = LOC.GetLocaleCode()
			return tbl[locale] or tbl[1]
		end,
	}
	local fn = kleiloadlua(MODS_ROOT..modname.."/modinfo.lua")
	local modinfo_message = ""
	if type(fn) == "string" then
		print("Error loading mod: "..ModInfoname(modname).."!\n "..fn.."\n")
		--table.insert( self.failedmods, {name=modname,error=fn} )
		env.failed = true
	elseif not fn then
		modinfo_message = modinfo_message.."No modinfo.lua, using defaults... "
	else
		local status, r = RunInEnvironment(fn,env)

		--if api_version_dst exists, we want to promote it to be the actual api_version of this mod.
		if env.api_version_dst ~= nil then
			env.api_version = env.api_version_dst
		end

		if status == false then
			print("Error loading mod: "..ModInfoname(modname).."!\n "..r.."\n")
			env.failed = true
		elseif env.api_version == nil or env.api_version < MOD_API_VERSION then
			modinfo_message = modinfo_message.."Old API! (mod: "..tostring(env.api_version).." game: "..MOD_API_VERSION..") "
		elseif env.api_version > MOD_API_VERSION then
			local old = "api_version for "..modname.." is in the future, please set to the current version. (api_version is version "..env.api_version..", game is version "..MOD_API_VERSION..".)"
			print("Error loading mod: "..ModInfoname(modname).."!\n "..old.."\n")
			env.failed = true
		else
			local checkinfo = { "name", "description", "author", "version", "api_version", "dont_starve_compatible", "reign_of_giants_compatible", "configuration_options", "dst_compatible" }
			local missing = {}

			for i,v in ipairs(checkinfo) do
				if env[v] == nil then
					if v == "dont_starve_compatible" then
						-- Print a warning but let the mod load
						--print("WARNING loading modinfo.lua: "..modname.." does not specify if it is compatible with the base game. It may not work properly.")
					elseif v == "reign_of_giants_compatible" then
						-- Print a warning but let the mod load
						--print("WARNING loading modinfo.lua: "..modname.." does not specify if it is compatible with Reign of Giants. It may not work properly.")
					elseif v == "dst_compatible" then
						-- Print a warning but let the mod load
						print("WARNING loading modinfo.lua: "..modname.." does not specify if it is compatible with Don't Starve Together. It may not work properly.")
					elseif v == "configuration_options" then
						-- Do nothing. It's perfectly fine not to have config options!
					else
						table.insert(missing, v)
					end
				end
			end

			if #missing > 0 then
				local e = "Error loading modinfo.lua. These fields are required: " .. table.concat(missing, ", ")
				print (e)
				--table.insert( self.failedmods, {name=modname,error=e} )

				env.failed = true
			else
				-- everything loaded okay!
			end
		end
	end

	env.modinfo_message = modinfo_message

	-- If modinfo hasn't been updated to specify compatibility yet, set it to true for both modes and set a flag
	if env.dont_starve_compatible == nil then
		env.dont_starve_compatible = true
		env.dont_starve_compatibility_specified = false
	end
	if env.reign_of_giants_compatible == nil then
		env.reign_of_giants_compatible = true
		env.reign_of_giants_compatibility_specified = false
	end
	if env.dst_compatible == nil then
		env.dst_compatible = true
		env.dst_compatibility_specified = false
	end

	if env.client_only_mod and env.all_clients_require_mod then
		print("WARNING loading modinfo.lua: "..modname.." specifies client_only_mod and all_clients_require_mod. These flags are mutually exclusive.")
	end

	return env
end

function ModIndex:GetModActualName(fancyname)
	for i,v in pairs(self.savedata.known_mods) do
		if v and v.modinfo and v.modinfo.name then
			if v.modinfo.name == fancyname then
				return i
			end
		end
	end
end

function ModIndex:GetModFancyName(modname)
	local knownmod = self.savedata.known_mods[modname]
	if knownmod and knownmod.modinfo and knownmod.modinfo.name then
		return knownmod.modinfo.name
	else
		return modname
	end
end

function ModIndex:Load(callback)

	self:UpdateModSettings()

    local filename = self:GetModIndexName()
    TheSim:GetPersistentString(filename,
        function(load_success, str)
        	if load_success == true then
				local success, savedata = RunInSandboxSafe(str)
				if success and string.len(str) > 0 and savedata ~= nil then
					self.savedata = savedata
					print ("loaded "..filename)
					--print("\n\n---LOADING MOD INDEX---\n\n")
					--dumptable(self.savedata)
					--print("\n\n---END LOADING MOD INDEX---\n\n")


					--print("\n\n---LOADING MOD INFOS---\n\n")
					self:UpdateModInfo()
					--dumptable(self.savedata)
					--print("\n\n---END LOADING MOD INFOS---\n\n")
				else
					print ("Could not load "..filename)
					if string.len(str) > 0 then
						print("File str is ["..str.."]")
					end
				end
			else
				print ("Could not load "..filename)
			end

			callback()
        end)
end

function ModIndex:IsModCompatibleWithMode(modname, dlcmode)
	local known_mod = self.savedata.known_mods[modname]
	if known_mod and known_mod.modinfo then
		return known_mod.modinfo.dst_compatible
	end
	return false
end

function ModIndex:HasModConfigurationOptions(modname)
	local modinfo = self:GetModInfo(modname)
	if modinfo and modinfo.configuration_options and type(modinfo.configuration_options) == "table" and #modinfo.configuration_options > 0 then
		return true
	end
	return false
end

function ModIndex:UpdateConfigurationOptions(config_options, savedata, client_config)
	for i,v in pairs(savedata) do
		for j,k in pairs(config_options) do
			if v.name == k.name and v.saved ~= nil then
				if client_config then
					k.saved_client = v.saved
				else
					k.saved_server = v.saved
				end

				k.saved = v.saved -- don't know if this is still needed, but keeping it.
			end
		end
	end
end

-- Just returns the table itself, and a bool specifying if it's a temp or regular table
-- In the frontend this function is not reliable without actually loading the mods from disk again due to the periodic updater.
function ModIndex:GetModConfigurationOptions_Internal(modname,force_local_options)
	local known_mod = self.savedata.known_mods[modname]
	if known_mod then
		if known_mod.temp_enabled and not force_local_options then
			return known_mod.temp_config_options, true
		elseif not ModManager.worldgen and ((TheNet:GetIsServer() and not TheNet:IsDedicated()) and not force_local_options) then
			return known_mod.temp_config_options, false
		else
			return known_mod.modinfo.configuration_options, false
		end
	end
end

function ModIndex:SetConfigurationOption(modname, option_name, value)
	local known_mod = self.savedata.known_mods[modname]
	if known_mod and known_mod.modinfo and known_mod.modinfo.configuration_options then
		for _,option in pairs(known_mod.modinfo.configuration_options) do
			if option.name == option_name then
				option.saved = value
			end
		end
	end
end

-- Loads the actual file from disk
function ModIndex:LoadModConfigurationOptions(modname, client_config)
	local known_mod = self.savedata.known_mods[modname]
	if known_mod == nil then
		print("Error: mod isn't known", modname )
		return nil
	end

	-- Try to find saved config settings first
	local filename = self:GetModConfigurationPath(modname, client_config)
	TheSim:GetPersistentString(filename,
        function(load_success, str)
        	if load_success == true then
				local success, savedata = RunInSandboxSafe(str)
				if success and string.len(str) > 0 then
					-- Carry over saved data from old versions when possible
					if self:HasModConfigurationOptions(modname) then
						self:UpdateConfigurationOptions(known_mod.modinfo.configuration_options, savedata, client_config)
					else
						if known_mod.modinfo ~= nil then
							known_mod.modinfo.configuration_options = savedata
						else
							print("Error: modinfo was not available for mod ", modname) --something went wrong, likely due to workshop update during FE loading, load modinfo now to try to recover
							self:UpdateSingleModInfo(modname)
							known_mod.modinfo.configuration_options = savedata
						end
					end
					print ("loaded "..filename)
				else
					print ("Could not load "..filename)
				end
			else
				print ("Could not load "..filename)
			end

			-- callback()
        end)

	if known_mod and known_mod.modinfo and known_mod.modinfo.configuration_options then
		return known_mod.modinfo.configuration_options
	end
	return nil
end

function ModIndex:SaveHostConfiguration(modname)
	local known_mod = self.savedata.known_mods[modname]
	if known_mod then
		if known_mod.modinfo then
			if known_mod.modinfo.configuration_options then
				self:SaveConfigurationOptions(function() end, modname, known_mod.modinfo.configuration_options, false)
			end
		end
	end
end

function ModIndex:SaveConfigurationOptions(callback, modname, configdata, client_config)
	if IsConsole() or not configdata then
        return
    end
    --print("### SaveConfigurationOptions ", modname)
    --write to existing table
    for _,v in pairs(configdata) do
		self:SetConfigurationOption(modname, v.name, v.saved)
	end

    -- Save it to disk
    local name = self:GetModConfigurationPath(modname, client_config)
	local data = DataDumper(configdata, nil, false)

	local cb = function()
		callback()
		-- And reload it to make sure there's parity after it's been saved
		self:LoadModConfigurationOptions(modname, client_config)
	end

    local insz, outsz = SavePersistentString(name, data, ENCODE_SAVES, cb)
end

function ModIndex:IsModEnabled(modname)
	local known_mod = self.savedata.known_mods[modname]
	return known_mod and known_mod.enabled
end

function ModIndex:IsModTempEnabled(modname)
	local known_mod = self.savedata.known_mods[modname]
	return known_mod and known_mod.temp_enabled
end

function ModIndex:IsModTempDisabled(modname)
	local known_mod = self.savedata.known_mods[modname]
	return known_mod and known_mod.temp_disabled
end

function ModIndex:IsModForceEnabled(modname)
	if self.modsettings.forceenable[modname] ~= nil then
		return self.modsettings.forceenable[modname]
	else
		--try to fall back and find the mod without the workshop prefix (sometimes users force enable a mod by just the workshop id)
		if string.sub( modname, 0, string.len(workshop_prefix) ) == workshop_prefix then
			local alt_name = string.sub( modname, string.len(workshop_prefix) + 1 )
			return self.modsettings.forceenable[alt_name]
		end
	end
	return false
end

function ModIndex:IsModEnabledAny(modname)
	return modname and
		((self:IsModEnabled(modname) or
		self:IsModForceEnabled(modname) or
		self:IsModTempEnabled(modname)) and
		not self:IsModTempDisabled(modname))
end

function ModIndex:SetDisableSpecialEventModWarning()
	self.savedata.disable_special_event_warning = true
end

function ModIndex:GetIsSpecialEventModWarningDisabled()
	return self.savedata.disable_special_event_warning
end

function ModIndex:IsModStandalone(modname)
	local known_mod = self.savedata.known_mods[modname]
	return known_mod and known_mod.modinfo and known_mod.modinfo.standalone == true
end

function ModIndex:IsModInitPrintEnabled()
	return self.modsettings.initdebugprint
end

function ModIndex:IsModErrorEnabled()
	return self.modsettings.moderror
end

function ModIndex:IsLocalModWarningEnabled()
	return self.modsettings.localmodwarning
end

function ModIndex:Disable(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].enabled = false
end

function ModIndex:DisableAllMods()
	for k,v in pairs(self.savedata.known_mods) do
		self:Disable(k)
	end
end

function ModIndex:ClearTempModFlags(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].temp_enabled = false
	self.savedata.known_mods[modname].temp_disabled = false
	self.savedata.known_mods[modname].temp_config_options = nil

end

function ModIndex:ClearAllTempModFlags()
	--print( "ModIndex:ClearAllTempModFlags" )

	local function internal_clear_all_temp_mod_flags()
		for k,v in pairs(self.savedata.known_mods) do
			self:ClearTempModFlags(k)
		end
		self:Save(nil)
	end
	if self.savedata == nil then
		self:Load( internal_clear_all_temp_mod_flags )
	else
		internal_clear_all_temp_mod_flags()
	end
end

function ModIndex:SetTempModConfigData( temp_mods_config_data )
	print( "ModIndex:SetTempModConfigData" )
	for modname,config_data in pairs(temp_mods_config_data) do
		if self.savedata.known_mods[modname] ~= nil then
			print( "Setting temp mod config for mod ", modname )
			self.savedata.known_mods[modname].temp_config_options = config_data
		else
			assert(false, "Temp mod is missing from known mods")
		end
	end
end

function ModIndex:DisableBecauseBad(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].disabled_bad = true
	self.savedata.known_mods[modname].enabled = false
end

function ModIndex:DisableBecauseIncompatibleWithMode(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].disabled_incompatible_with_mode = true
	self.savedata.known_mods[modname].enabled = false
end

function ModIndex:Enable(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end

	if not self.savedata.known_mods[modname].enabled then
		self.savedata.disable_special_event_warning = false
	end

	self.savedata.known_mods[modname].enabled = true
	self.savedata.known_mods[modname].disabled_bad = false
	self.savedata.known_mods[modname].disabled_incompatible_with_mode = false
end

function ModIndex:TempEnable(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].temp_enabled = true
	self.savedata.known_mods[modname].disabled_bad = false
	self.savedata.known_mods[modname].disabled_incompatible_with_mode = false
end

function ModIndex:TempDisable(modname)
	if not self.savedata.known_mods[modname] then
		self.savedata.known_mods[modname] = {}
	end
	self.savedata.known_mods[modname].temp_disabled = true
end

function ModIndex:IsModNewlyBad(modname)
	local known_mod = self.savedata.known_mods[modname]
	if known_mod and known_mod.modinfo.failed then
		-- After a mod is disabled it can no longer fail;
		-- in addition, the index is saved when a mod fails.
		-- So we just have to check if the mod failed in the index
		-- and that indicates what happened last time.
		return true
	end
	return false
end

function ModIndex:KnownAPIVersion(modname)
	local known_mod = self.savedata.known_mods[modname]
	if not known_mod or not known_mod.modinfo then
		return -2 -- If we've never seen the mod before, we assume it's REALLY old
	elseif not known_mod.modinfo.api_version then
		return -1 -- If we've seen it but it has no info, it's just "Old"
	else
		return known_mod.modinfo.api_version
	end
end

function ModIndex:IsModNew(modname)
	return not self.savedata.known_mods[modname] or not self.savedata.known_mods[modname].modinfo
end

function ModIndex:IsModKnownBad(modname)
	return self.savedata.known_mods[modname] and self.savedata.known_mods[modname].disabled_bad
end

-- When the user changes settings it messes directly with the index data, so make a backup
function ModIndex:CacheSaveData()
	self.cached_data = {}
	self.cached_data.savedata = deepcopy(self.savedata)
	self.cached_data.modsettings = deepcopy(self.modsettings)
	return self.cached_data
end

-- If the user cancels their mod changes, restore the index to how it was prior the changes.
function ModIndex:RestoreCachedSaveData(ext_data)
	if ext_data then
		self.savedata = ext_data.savedata
		self.modsettings = ext_data.modsettings
	elseif self.cached_data then
		self.savedata = self.cached_data.savedata
		self.modsettings = self.cached_data.modsettings
	end
end

function ModIndex:UpdateModSettings()

	self.modsettings = {
		forceenable = {},
		disablemods = true,
		localmodwarning = true
	}

	local function ForceEnableMod(modname)
		print("WARNING: Force-enabling mod '"..modname.."' from modsettings.lua! If you are not developing a mod, please use the in-game menu instead.")
		self.modsettings.forceenable[modname] = true
	end
	local function EnableModDebugPrint()
		self.modsettings.initdebugprint = true
	end
	local function EnableModError()
		self.modsettings.moderror = true
	end
	local function DisableModDisabling()
		self.modsettings.disablemods = false
	end
	local function DisableLocalModWarning()
		self.modsettings.localmodwarning = false
	end

	local env = {
		ForceEnableMod = ForceEnableMod,
		EnableModDebugPrint = EnableModDebugPrint,
		EnableModError = EnableModError,
		DisableModDisabling = DisableModDisabling,
		DisableLocalModWarning = DisableLocalModWarning,
	}

	local filename = MODS_ROOT.."modsettings.lua"
	local fn = kleiloadlua( filename )
	if fn == nil then
		print("could not load modsettings: "..filename)
		print("Warning: You may want to try reinstalling the game if you need access to forcing mods on.")
	else
		if type(fn)=="string" then
			error("Error loading modsettings:\n"..fn)
		end
		setfenv(fn, env)
		fn()
	end
end

local function IsModAlreadyDepended(deps, new_deps)
	for i, mod in ipairs(new_deps) do
		if deps[mod] then
			return true
		end
	end
	return false
end

function ModIndex:GetModDependencies(modname, recursive, rec_deps)
	if not rec_deps then
		self:UpdateModInfo()
	end
	local dependencies = self.savedata.known_mods[modname] and self.savedata.known_mods[modname].dependencies
	if not dependencies then
		return {}
	end
	local deps = rec_deps or {}
	local new_deps = {}
	--add our modname to the deps to prevent circular dependency loops
	deps[modname] = true
	for i, mods_dep in ipairs(dependencies) do
		if not IsModAlreadyDepended(deps, mods_dep) then
			deps[mods_dep[1]] = true
			new_deps[mods_dep[1]] = true
		end
	end
	if recursive then
		for _modname, _ in pairs(new_deps) do
			self:GetModDependencies(_modname, recursive, deps)
		end
	end
	--rec_deps will be nil when called externally
	if not rec_deps then
		deps[modname] = nil
		return table.getkeys(deps)
	end
end

function ModIndex:GetModDependents(modname, recursive, rec_deps)
	local deps = rec_deps or {}
	local new_deps = {}
	--add our modname to the deps to prevent circular dependency loops
	deps[modname] = true
	for _modname, modslist in pairs(self.mod_dependencies.dependency_list) do
		if not deps[_modname] then
			for _, _modnamedep in ipairs(modslist) do
				if modname == _modnamedep then
					deps[_modname] = true
					new_deps[_modname] = true
				end
			end
		end
	end
	if recursive then
		for _modname, _ in pairs(new_deps) do
			self:GetModDependents(_modname, recursive, deps)
		end
	end

	--rec_deps will be nil when called externally
	if not rec_deps then
		deps[modname] = nil
		return table.getkeys(deps)
	end
end

function ModIndex:IsModDependedOn(modname)
	return (self.mod_dependencies.server_dependency_list[modname] or 0) > 0
end

function ModIndex:SetDependencyList(modname, modslist, nosubscribe)
	self.mod_dependencies.dependency_list[modname] = modslist
	for i, mod in ipairs(modslist) do
		self:AddModDependency(mod, nosubscribe)
	end
end

function ModIndex:AddModDependency(modname, nosubscribe)
	if IsWorkshopMod(modname) and not KnownModIndex:DoesModExistAnyVersion(modname) then
		if nosubscribe then return end
		TheSim:SubscribeToMod(modname)
	end
	self.mod_dependencies.server_dependency_list[modname] = (self.mod_dependencies.server_dependency_list[modname] or 0) + 1
end

function ModIndex:ClearModDependencies(modname)
    if modname == nil then
        self.mod_dependencies.server_dependency_list = {}
        self.mod_dependencies.dependency_list = {}
    else
        for i, v in ipairs(self.mod_dependencies.dependency_list[modname] or {}) do
            self.mod_dependencies.server_dependency_list[v] = (self.mod_dependencies.server_dependency_list[v] or 0) - 1
        end
        self.mod_dependencies.dependency_list[modname] = nil
    end
end

function ModIndex:GetModDependenciesEnabled()
	for k, v in pairs(self.mod_dependencies.server_dependency_list) do
		if (v or 0) > 0 and not self:IsModEnabled(k) then
			return false
		end
	end
	return true
end

function ModIndex:DoesModExistAnyVersion( modname )
	local modinfo = self:GetModInfo(modname)
	if modinfo ~= nil then
		return true
	else
		return false
	end
end

function ModIndex:DoModsExistAnyVersion(modlist)
    for i, v in ipairs(modlist) do
        if not self:DoesModExistAnyVersion(v) then
            return false
        end
    end
    return true
end

function ModIndex:DoesModExist( modname, server_version, server_version_compatible )
	self:UpdateSingleModInfo(modname)
	if server_version_compatible == nil then
		--no compatible flag, so we want to do an exact version check
		local modinfo = self:GetModInfo(modname)
		if modinfo ~= nil then
			return server_version == modinfo.version
		end
		print("Mod "..modname.." v:"..server_version.." doesn't exist in mod dir ")
		return false
	else
		local modinfo = self:GetModInfo(modname)
		if modinfo ~= nil then
			if server_version >= modinfo.version then
				--server is ahead or equal version, check if client is compatible with server
				return modinfo.version >= server_version_compatible
			else
				--client is ahead, check if server is compatible with client
				return server_version >= modinfo.version_compatible
			end
		end
		print("Mod "..modname.." v:"..server_version.." vc:"..server_version_compatible.." doesn't exist in mod dir ")
		return false
	end
end

function ModIndex:GetEnabledModTags()
	local tags = {}
	for name,data in pairs(self.savedata.known_mods) do
		if data.enabled then
			local modinfo = self:GetModInfo(name)
			if modinfo ~= nil and modinfo.server_filter_tags ~= nil then
				for i,tag in pairs(modinfo.server_filter_tags) do
					table.insert(tags, tag)
				end
			end
		end
	end
	return tags
end


function ModIndex:DisableClientMods( disabled ) --to be called from the server/host when loading mod overrides. Note, this is not saved out to the mod index file on the clients, it's applied through the server listing temp disabling individual client mods when connecting
	self.client_mods_disabled = disabled
end

function ModIndex:AreClientModsDisabled()
	return self.client_mods_disabled
end

KnownModIndex = ModIndex()
