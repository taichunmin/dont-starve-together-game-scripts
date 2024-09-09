require "translator"


local USE_LONGEST_LOCS = false
LanguageTranslator:UseLongestLocs(USE_LONGEST_LOCS)

function GetCurrentLocale()
    local locale = nil
    if TheNet:IsDedicated() then
        --for dedicated servers get the language from the cluster info.
        locale = LOC.GetLocaleByCode( TheNet:GetDefaultServerLanguage() )
    else
        if IsRail() then
            local lang_id = LANGUAGE.CHINESE_S_RAIL
            locale =  LOC.GetLocale(lang_id)
		elseif IsConsole() or IsSteam() then
            local lang_id = Profile:GetLanguageID()
            locale =  LOC.GetLocale(lang_id)
        end
    end

    return locale
end

LOC.SetCurrentLocale(GetCurrentLocale())

if USE_LONGEST_LOCS then
	for _, id in pairs(LOC.GetLanguages()) do
		local file = LOC.GetStringFile(id)
		local code = LOC.GetLocaleCode(id)
		if file and code then
			LanguageTranslator:LoadPOFile(file, code)
		end
	end
else
	local currentLocale = LOC.GetLocale()
    if nil ~= currentLocale then
		local file = LOC.GetStringFile(currentLocale.id)
		if file then
			LanguageTranslator:LoadPOFile(file, currentLocale.code)
		end
    end
end