
require "constants"
require "translator"


local USE_LONGEST_LOCS = false

local LOC_ROOT_DIR = ""
local EULE_FILENAME = "eula_english.txt"
if PLATFORM == "XBONE" then
	LOC_ROOT_DIR = "data/scripts/languages/"
	EULE_FILENAME = "eula_english_x.txt"
else
	LOC_ROOT_DIR = "scripts/languages/"
	EULE_FILENAME = "eula_english_p.txt"
end

LanguageTranslator:UseLongestLocs(USE_LONGEST_LOCS)

local localizations = 
{
    {id = LANGUAGE.FRENCH,          alt_id = nil,                   strings = "french.po",         code = "fr",    scale = 1.0, in_menu = true},
    {id = LANGUAGE.SPANISH,         alt_id = LANGUAGE.SPANISH_LA,   strings = "spanish.po",        code = "es",    scale = 1.0, in_menu = true},
    --{id = LANGUAGE.SPANISH_LA,      alt_id = nil,                   strings = "spanish_mex.po",    code = "mex",   scale = 1.0, in_menu = false},
    {id = LANGUAGE.GERMAN,          alt_id = nil,                   strings = "german.po",         code = "de",    scale = 1.0, in_menu = true},
    {id = LANGUAGE.ITALIAN,         alt_id = nil,                   strings = "italian.po",        code = "it",    scale = 1.0, in_menu = true},  
    {id = LANGUAGE.PORTUGUESE_BR,   alt_id = LANGUAGE.PORTUGUESE,   strings = "portuguese_br.po",  code = "pt",    scale = 1.0, in_menu = true},
    {id = LANGUAGE.POLISH,          alt_id = nil,                   strings = "polish.po",         code = "pl",    scale = 1.0, in_menu = true},
    {id = LANGUAGE.RUSSIAN,         alt_id = nil,                   strings = "russian.po",        code = "ru",    scale = 0.8, in_menu = true}, -- Russian strings are very long (often the longest), and the characters in the font are big. Bad combination.
    {id = LANGUAGE.KOREAN,          alt_id = nil,                   strings = "korean.po",         code = "ko",    scale = 0.85, in_menu = true},
    {id = LANGUAGE.CHINESE_S,       alt_id = LANGUAGE.CHINESE_T,    strings = "chinese_s.po",      code = "zh",    scale = 0.85, in_menu = true},
    {id = LANGUAGE.CHINESE_S_RAIL,  alt_id = nil,                   strings = "chinese_r.po",      code = "zhr",  scale = 0.85, in_menu = false},
    --{id = LANGUAGE.JAPANESE,      alt_id = nil,                   strings = "japanese.po",     code = "ja",    scale = 0.85, in_menu = true},
    --{id = LANGUAGE.CHINESE_T,     alt_id = nil,                   strings = "chinese_t.po",    code = "zh",    scale = 0.85, in_menu = true},  
}

function GetLocalizationOptions()
    local lang_options = {}
    table.insert(lang_options, LANGUAGE.ENGLISH)
    for _, loc in pairs(localizations) do
        if loc.in_menu then
            table.insert(lang_options, loc.id)
        end
    end
    return lang_options
end

function GetLocaleByCode(lang_code)
    if lang_code == nil then
        return nil
    end

    local locale = nil
    for _, loc in pairs(localizations) do
        if lang_code == loc.code then
            locale = loc
        end
    end
    return locale
end

function GetLocale(lang_id)
    if lang_id == nil then
        return nil
    end

    local locale = nil
    for _, loc in pairs(localizations) do
        if lang_id == loc.id or lang_id == loc.alt_id then
            locale = loc
        end
    end
    return locale
end

local function GetCurrentLocale()
    local locale = nil
    if TheNet:IsDedicated() then
        --for dedicated servers get the language from the cluster info.
        locale = GetLocaleByCode( TheNet:GetDefaultServerLanguage() )
    else
        if IsRail() then
            local lang_id = LANGUAGE.CHINESE_S_RAIL
            locale = GetLocale(lang_id)
		elseif IsConsole() then
            local lang_id = Profile:GetLanguageID()
            locale = GetLocale(lang_id)
        end
    end

    return locale
end

local CurrentLocale = GetCurrentLocale()

function GetLocaleCode()
    if CurrentLocale then
        return CurrentLocale.code
    else
        return "en"
    end
end

function GetLanguage()
    if CurrentLocale then
        return CurrentLocale.id
    else
        return LANGUAGE.ENGLISH
    end
end

function GetEulaFilename()
    local eula_file = LOC_ROOT_DIR .. EULE_FILENAME
    return eula_file
end

function SwapLanguage(lang_id)
    local locale = GetLocale(lang_id)
    if nil ~= locale then
        LanguageTranslator:LoadPOFile(LOC_ROOT_DIR .. locale.strings, locale.code)    
    end
    TranslateStringTable( STRINGS )
end

function GetTextScale()
    if nil == CurrentLocale then
        return 1.0
    else
        return CurrentLocale.scale
    end
end

function RefreshServerLocale()
    if TheNet:IsDedicated() then
        CurrentLocale = GetCurrentLocale()
        if CurrentLocale ~= nil then
            SwapLanguage(CurrentLocale.id)
        else
            print( "We currently don't support switching the language back to english." )
        end
    else
        print("You probably shouldn't be calling this on clients...")
    end
end



if USE_LONGEST_LOCS then
    for _, loc in pairs(localizations) do
        LanguageTranslator:LoadPOFile(LOC_ROOT_DIR .. loc.strings, loc.code)    
    end
else
    if nil ~= CurrentLocale then
        LanguageTranslator:LoadPOFile(LOC_ROOT_DIR .. CurrentLocale.strings, CurrentLocale.code)    
    end
end