    
local loaded_klumps = {}

function LoadAccessibleKlumpFiles()
    --print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ LOADING KLUMP ASSETS from profile")
    --dumptable(Profile.persistdata.klump_ciphers)
    for _,klump_asset in pairs(require("klump_assets")) do
        local klump_key = string.gsub(klump_asset.file, "klump/", "")
        local is_strings = false
        if string.sub(klump_key,1,8) == "strings/" then
            is_strings = true
            klump_key = string.gsub(klump_key, "strings/", "")
        end

        local cipher = Profile:GetKlumpCipher(klump_key)
        if cipher ~= nil then
            if is_strings then
                LoadKlumpString( klump_key, cipher )
            else
                LoadKlumpFile( klump_key, cipher )
            end
        end
    end
end

function LoadKlumpFile( klump_key, cipher )
	if not IsKlumpLoaded( klump_key ) then
        Profile:SaveKlumpCipher( klump_key, cipher )
        TheSim:LoadKlumpFile( klump_key, cipher )
        loaded_klumps[klump_key] = true
    end
end

function LoadKlumpString( klump_key, cipher)
	if not IsKlumpLoaded( klump_key ) then
        Profile:SaveKlumpCipher( klump_key, cipher )
        TheSim:LoadKlumpString( klump_key, cipher )
        loaded_klumps[klump_key] = true
    end
end

function IsKlumpLoaded(klump_key)
    return loaded_klumps[klump_key] ~= nil
end

function ApplyKlumpToStringTable(json_str)
    local json_data = json.decode(json_str)
    local s = _G
    local last_table = nil
    local last_key = nil
    for i in string.gmatch(json_data.ID, "[%w_]+") do
        if i ~= nil then
            last_table = s
            last_key = i
            
            if s[i] == nil then
                last_table[i] = {}
            end
            s = s[i]            
        end
    end
    last_table[last_key] = json_data[GetLocaleCode()]
end