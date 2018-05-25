--Here is where you can select a language file to override the default english strings
--The game currently only supports ASCII (sadly), so not all languages can be supported at this time.

require "translator"

--Uncomment this for french!
--LanguageTranslator:LoadPOFile("scripts/languages/french.po", "fr")

if PLATFORM == "WIN32_RAIL" then
	LanguageTranslator:LoadPOFile("scripts/languages/simplifiedchinese.po", "cn")
end

function GetLocaleCode()
    return "en"
end