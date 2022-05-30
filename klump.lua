local LOAD_UPFRONT_MODE = false

local loaded_klumps = {}

function LoadAccessibleKlumpFiles(minimal_load)
    --dumptable(Profile.persistdata.klump_ciphers)
    if LOAD_UPFRONT_MODE then
        if QUAGMIRE_USE_KLUMP and (IsFestivalEventActive(FESTIVAL_EVENTS.QUAGMIRE) or IsPreviousFestivalEvent(FESTIVAL_EVENTS.QUAGMIRE)) then
			require("quagmire_event_server/quagmire_food_ids")
			local secrets = event_server_data("quagmire", "klump_secrets")
			for _,name in pairs(QUAGMIRE_FOOD_IDS) do
				LoadKlumpFile("images/quagmire_food_inv_images_"..name..".tex", secrets[name].cipher, true)
				LoadKlumpFile("images/quagmire_food_inv_images_hires_"..name..".tex", secrets[name].cipher, true)
				LoadKlumpFile("anim/dynamic/"..name..".dyn", secrets[name].cipher, true)
				if not minimal_load then
					LoadKlumpString("STRINGS.NAMES."..string.upper(name), secrets[name].cipher, true)
				end
			end
		end
    else
        if IsFestivalEventActive(FESTIVAL_EVENTS.QUAGMIRE) or IsPreviousFestivalEvent(FESTIVAL_EVENTS.QUAGMIRE) then
            print("Klump load on boot started.")
            local load_count = 0
            for _,file in pairs(require("klump_files")) do
                local klump_file = string.gsub(file, "klump/", "")
                local is_strings = false
                if string.sub(klump_file,1,8) == "strings/" then
                    is_strings = true
                    klump_file = string.gsub(klump_file, "strings/", "")
                end

                local cipher = Profile:GetKlumpCipher(klump_file)
                if cipher ~= nil then
                    load_count = load_count + 1
                    if is_strings then
                        LoadKlumpString( klump_file, cipher, true )
                    else
                        LoadKlumpFile( klump_file, cipher, true )
				    end
                end
            end
            print("Klump files loaded: ", load_count)
        end
    end
end

function LoadKlumpFile( klump_file, cipher, suppress_print )
	if not IsKlumpLoaded( klump_file ) then
        if not suppress_print then
            print("LoadKlumpFile", klump_file, cipher)
        end
        Profile:SaveKlumpCipher( klump_file, cipher )
        TheSim:LoadKlumpFile( klump_file, cipher )
        loaded_klumps[klump_file] = true
    end
end

function LoadKlumpString( klump_file, cipher, suppress_print)
	if not IsKlumpLoaded( klump_file ) then
        if not suppress_print then
            print("LoadKlumpString", klump_file, cipher)
        end
        Profile:SaveKlumpCipher( klump_file, cipher )
        TheSim:LoadKlumpString( klump_file, cipher )
        loaded_klumps[klump_file] = true
    end
end

function IsKlumpLoaded(klump_file)
    return loaded_klumps[klump_file] ~= nil
end

function ApplyKlumpToStringTable(string_id, json_str)
    local json_data = json.decode(json_str)
    local s = _G
    local last_table = nil
    local last_key = nil
    for i in string.gmatch(string_id, "[%w_]+") do
        if i ~= nil then
            last_table = s
            last_key = i

            if s[i] == nil then
                last_table[i] = {}
            end
            s = s[i]
        end
    end

    local locale_code = LOC.GetLocaleCode()
    if locale_code == "zhr" then
        locale_code = "zh"
    elseif locale_code == "mex" then
        locale_code = "es"
    end

    if json_data[locale_code] == nil or json_data[locale_code] == "" then
        last_table[last_key] = json_data["en"]
    else
        last_table[last_key] = json_data[locale_code]
    end
end