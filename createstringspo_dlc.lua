--
-- Revised version by WrathOf using msgctxt field for po/t file
-- msgctxt is set to the "path" in the table structure which is guaranteed unique
-- versus the string values (msgid) which are not.
--
-- Expanded to support v1 and v2 format in event user needs help converting a
-- strings.lua based translation. Must use a mod to load the translated strings.lua
-- file into a seperate environment and then pass the alternate strings table to
-- CreateStringsPOT along with the actual global strings table for use as a lookup table.
--

-- prefer loading scripts from DLC directory, only afterwards get from base
package.path = "..\\DLC0001\\scripts\\?.lua;..\\DLC0002\\scripts\\?.lua;?.lua"

-- In case strings.lua queries this (tgus needs to be before the require)
function IsDLCEnabled(val)
	if val == REIGN_OF_GIANTS then
		return true
	end
end

require "strings"
require "io"

local REIGN_OF_GIANTS = 1

local path = "STRINGS"

--Used by v1
local msgids = {}

--Used by translated string functions
local STRINGS_LOOKUP = {}


--
-- Version 1 msgid based, original
--

local function PrintStringTableV1( base, tbl, file )

	for k,v in pairs(tbl) do
		local path = base.."."..k
		if type(v) == "table" then
			PrintStringTableV1(path, v, file)
		else
			local str = string.gsub(v, "\n", "\\n")
			str = string.gsub(str, "\r", "\\r")
			str = string.gsub(str, "\"", "\\\"")

			if msgids[str] then
				print("duplicate msgid found: "..str.." (skipping...)")
			else
				msgids[str] = true

				file:write("#. "..path)
				file:write("\n")
				file:write("#: "..path)
				file:write("\n")
				file:write("msgid \""..str.."\"")
				file:write("\n")
				file:write("msgstr \"\"")
				file:write("\n\n")
			end
		end
	end
end

function PrintTranslatedStringTableV1( base_dta, tbl_dta, lkp_var, file )

	for k,v in pairs(tbl_dta) do
		local path = base_dta.."."..k
		if type(v) == "table" then
			PrintTranslatedStringTableV1(path, v, lkp_var, file)
		else

			local idstr = LookupIdValue(lkp_var, path)
			if idstr then
				idstr = string.gsub(idstr, "\n", "\\n")
				idstr = string.gsub(idstr, "\r", "\\r")
				idstr = string.gsub(idstr, "\"", "\\\"")
			else
				idstr = ""
			end

			local str = v
			str = string.gsub(str, "\n", "\\n")
			str = string.gsub(str, "\r", "\\r")
			str = string.gsub(str, "\"", "\\\"")

			if idstr ~= "" and msgids[idstr] then
				print("duplicate msgid found: "..idstr.." (skipping...)")
			else
				msgids[idstr] = true

				file:write("#. "..path)
				file:write("\n")
				file:write("#: "..path)
				file:write("\n")
				file:write("msgid \""..idstr.."\"")
				file:write("\n")
				file:write("msgstr \""..str.."\"")
				file:write("\n\n")
			end
		end
	end
end


local function IsValidString( str )
	for i = 1, #str do
    	local a = string.byte( str, i, i)
    	if a < 32 or a > 127 then
    		return false
    	end
    end
    return true
end


--
-- Version 2 msgctxt based
--

--Recursive function to process table structure
local function PrintStringTableV2( base, tbl, file )

	for k,v in pairs(tbl) do
		local path = base.."."..k
		if type(v) == "table" then
			PrintStringTableV2(path, v, file)
		else
			local str = string.gsub(v, "\n", "\\n")
			str = string.gsub(str, "\r", "\\r")
			str = string.gsub(str, "\"", "\\\"")
			if IsValidString( str ) then

				file:write("#. "..path)
				file:write("\n")
				file:write("msgctxt \""..path.."\"")
				file:write("\n")
				file:write("msgid \""..str.."\"")
				file:write("\n")
				file:write("msgstr \"\"")
				file:write("\n\n")
			end

		end
	end
end

local function PrintTranslatedStringTableV2( base, tbl_dta, lkp_var, file )
	for k,v in pairs(tbl_dta) do
		local path = base.."."..k
		if type(v) == "table" then
			PrintTranslatedStringTableV2(path, v, lkp_var, file)
		else

			local idstr = LookupIdValue(lkp_var, path)
			if idstr then
				idstr = string.gsub(idstr, "\n", "\\n")
				idstr = string.gsub(idstr, "\r", "\\r")
				idstr = string.gsub(idstr, "\"", "\\\"")
			else
				idstr = ""
			end

			local str = v
			str = string.gsub(str, "\n", "\\n")
			str = string.gsub(str, "\r", "\\r")
			str = string.gsub(str, "\"", "\\\"")

			if idstr ~= "" then
				file:write("#. "..path)
				file:write("\n")
				file:write("msgctxt \""..path.."\"")
				file:write("\n")
				file:write("msgid \""..idstr.."\"")
				file:write("\n")
				file:write("msgstr \""..str.."\"")
				file:write("\n\n")
			end
		end
	end
end


--LookupIdValue (common function)
-- lkp_var = name of variable holding lookup table as string
-- path = dot delimited indexes into the lookup table, first token assumed
--        to be original table var name and substituted with lkp_var
-- returns value stored in lookup table variable if found, otherwise nil
--
local function LookupIdValue(lkp_var, path)
--print(lkp_var, path)

	--capture original tbl var name and remaining indexes
	--OLD_TBL_VAR.LEVEL1.LEVEL2.LEVEL3 --> OLD_TBL_VAR, LEVEL1.LEVEL2.LEVEL3.1
	local sidx, eidx, tblvar, str = string.find(path, "([^%.]*).(.*)")

	--attempt to capture ending numeric index, store and remove if found
	local sidx, eidx, endnum1 = string.find(str, "%.(%d*)$")
	if endnum1 then str = string.sub(str,1,string.len(str)-string.len(endnum1)-1) end

	--attempt to capture second ending numeric index, store and remove if found
	local sidx, eidx, endnum2 = string.find(str, "%.(%d*)$")
	if endnum2 then str = string.sub(str,1,string.len(str)-string.len(endnum2)-1) end

	--replace dots with bracket quote syntax
	--LEVEL1.LEVEL2.LEVEL3 --> LEVEL1"]["LEVEL2"]["LEVEL3
    str = string.gsub(str, "%.", "\"][\"")

	--build eval string for returning value in lookup table using bracket quote syntax
	--'return LKP_TBL_VAR["LEVEL1"]["LEVEL2"]["LEVEL3"]'
	local evalstr = "return "..lkp_var.."[\""..str.."\"]"
	if endnum2 then evalstr = evalstr.."["..endnum2.."]" end
	if endnum1 then evalstr = evalstr.."["..endnum1.."]" end
	local result, val = pcall(function() return loadstring(evalstr)() end)
--print(evalstr,result,val)
	if result and type(val) == "string" then return val else return nil end
end



--
-- Public functions
--

function CreateStringsPOTv1(filename, root, tbl_dta, tbl_lkp)
	filename = filename or "data\\scripts\\languages\\temp_v1.pot"
	root = root or "STRINGS"

	local file = io.open(filename, "w")

	if tbl_lkp then
		STRINGS_LOOKUP = tbl_lkp
		PrintTranslatedStringTableV1( root, tbl_dta, "STRINGS_LOOKUP", file )
	else
		PrintStringTablev1( root, tbl_dta, file )
	end

	file:close()
end

function CreateStringsPOTv2(filename, root, tbl_dta, tbl_lkp)
	filename = filename or "data\\DLC0001\\scripts\\languages\\temp_v2.pot"
	root = root or "STRINGS"

	local file = io.open(filename, "w")

	--Add file format info
	file:write("\"Application: Dont' Starve\\n\"")
	file:write("\n")
	file:write("\"POT Version: 2.0\\n\"")
	file:write("\n")
	file:write("\n")

	if tbl_lkp then
		STRINGS_LOOKUP = tbl_lkp
		PrintTranslatedStringTableV2( root, tbl_dta, "STRINGS_LOOKUP", file )
	else
		PrintStringTableV2( root, tbl_dta, file )
	end

	file:close()
end

-- *** INSTRUCTIONS ***
-- To generate strings for Reign of Giants (DLC):
-- 1. Backup the speech_[character].lua files in DontStarve\data\scripts
-- 2. Copy the speech_[character].lua files in DontStarve\data\DLC0001\scripts and paste them into DontStarve\data\scripts
-- 3. Open strings.lua and find the STRINGS.CHARACTERS table.
--		Add "WATHGRITHR = require "speech_wathgrithr"" and "WEBBER = require "speech_webber"" (without outer quotes) to the table and save the file.
-- 4. Open cmd and navigate to the DontStarve\data\scripts folder
-- 5. Enter "..\..\tools\LUA\lua.exe createstringspo_dlc.lua" (without quotes) into the cmd line and press return
-- 6. Undo your changes to strings.lua and restore the backed up speech files to their previous location in data\scripts

--Only run if this is not the released game version
--if BRANCH == "release" then

	print("Generating PO/T files from strings table....")

	--Create POT file for STRINGS table in original v1 format
	--CreateStringsPOTv1("data\\scripts\\languages\\strings_v1.pot", "STRINGS", STRINGS)

	--Create POT file for STRINGS table in new v2 format
	CreateStringsPOTv2("..\\DLC0001\\scripts\\languages\\strings.pot", "STRINGS", STRINGS)

	--Create english.po file for new translations (or just copy the pot file create above, not sure how from lua)
	--CreateStringsPOTv2("languages\\english.po", "STRINGS", STRINGS)

--end