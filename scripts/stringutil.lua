local function getmodifiedstring(topic_tab, modifier)
	if type(modifier) == "table" then
		local ret = topic_tab
		for i,v in ipairs(modifier) do
			if ret == nil then
				return nil
			end
			ret = ret[v]
		end
		return ret
	elseif modifier ~= nil then
        local ret = topic_tab[modifier]
        return (type(ret) == "table" and #ret > 0 and ret[math.random(#ret)])
                or ret
                or topic_tab.GENERIC
                or (#topic_tab > 0 and topic_tab[math.random(#topic_tab)])
                or nil
    else
		return topic_tab.GENERIC
                or (#topic_tab > 0 and topic_tab[math.random(#topic_tab)])
                or nil
	end
end

local function getcharacterstring(tab, item, modifier)

    if tab == nil then
        return
    end

    local topic_tab = tab[item]
    if topic_tab == nil then
        return
    elseif type(topic_tab) == "string" then
        return topic_tab
    elseif type(topic_tab) ~= "table" then
        return
    end

	if type(modifier) == "table" then
		for i,v in ipairs(modifier) do
			v = string.upper(v)
		end
	else
		modifier = modifier ~= nil and string.upper(modifier) or nil
	end

	return getmodifiedstring(topic_tab, modifier)
end

function GetGenderStrings(charactername)
    for gender,characters in pairs(CHARACTER_GENDERS) do
        if table.contains(characters, charactername) then
            return gender
        end
    end
    return "DEFAULT"
end

---------------------------------------------------------
--"Oooh" string stuff


local Oooh_endings = { "h", "oh", "ohh" }
local Oooh_punc = { ".", "?", "!" }

local function ooohstart(isstart)
    local str = isstart and "O" or "o"
    local l = math.random(2, 4)
    for i = 2, l do
        str = str..(math.random() > 0.3 and "o" or "O")
    end
    return str
end

local function ooohspace()
    local c = math.random()
    local str =
        (c <= .1 and "! ") or
        (c <= .2 and ". ") or
        (c <= .3 and "? ") or
        (c <= .4 and ", ") or
        " "
    return str, c <= .3
end

local function ooohend()
    return Oooh_endings[math.random(#Oooh_endings)]
end

local function ooohpunc()
    return Oooh_punc[math.random(#Oooh_punc)]
end


local function CraftOooh() -- Ghost speech!
    local isstart = true
    local length = math.random(6)
    local str = ""
    for i = 1, length do
        str = str..ooohstart(isstart)..ooohend()
        if i ~= length then
            local space
            space, isstart = ooohspace()
            str = str..space
        end
    end
    return str..ooohpunc()
end


function CraftGiberish()

    local function midstr(locstr)
        locstr = locstr .. STRINGS.GIBERISH_PRE[math.random(1,#STRINGS.GIBERISH_PRE)]
        return locstr
    end

    local function endstr(locstr)
        locstr = locstr .. STRINGS.GIBERISH_PST[math.random(1,#STRINGS.GIBERISH_PST)]
        return locstr
    end

    local str = ""
    local loop = 4    
    while loop > 0 do
        str = midstr(str)
        if math.random() <0.3 then
            str = endstr(str)
        end

        if math.random() <0.3 then
            loop = 0
        end
        loop = loop -1
        if loop > 0 and math.random() < 0.8 then
            str = str .. " "
        end        
    end
    
    if math.random() < 0.2 then
        return str .. "!"
    end
    return str .. "."
end

function CraftMonkeySpeech()
    --getcharacterstring(STRINGS.CHARACTERS.WONKEY.DESCRIBE, stringtype, modifier) or CraftMonkeyString()

    if not ThePlayer or ThePlayer:HasTag("wonkey") then
        return nil
    else
        local function midstr(locstr)
            locstr = locstr .. STRINGS.MONKEY_SPEECH_PRE[math.random(1,#STRINGS.MONKEY_SPEECH_PRE)]
            return locstr
        end

        local function endstr(locstr)
            locstr = locstr .. STRINGS.MONKEY_SPEECH_PST[math.random(1,#STRINGS.MONKEY_SPEECH_PST)]
            return locstr
        end

        local str = ""
        local loop = 4    
        while loop > 0 do
            str = midstr(str)
            if math.random() <0.3 then
                str = endstr(str)
            end

            if math.random() <0.3 then
                loop = 0
            end
            loop = loop -1
            if loop > 0 and math.random() < 0.8 then
                str = str .. " "
            end        
        end
        
        if math.random() < 0.2 then
            return str .. "!"
        end
        return str .. "."
    end
end



--V2C: Left this here as a global util function so mods or other characters can use it easily.
function Umlautify(string)
    if not Profile:IsWathgrithrFontEnabled() then
        return string
    end

    local ret = ""
    local last = false
    for i = 1, #string do
        local c = string:sub(i,i)
        if not last and (c == "o" or c == "O") then
            ret = ret .. ((c == "o" and "ö") or (c == "O" and "Ö") or c)
            last = true
        else
            ret = ret .. c
            last = false
        end
    end
    return ret
end

---------------------------------------------------------

local wilton_sayings =
{
    "Ehhhhhhhhhhhhhh.",
    "Eeeeeeeeeeeer.",
    "Rattle.",
    "click click click click",
    "Hissss!",
    "Aaaaaaaaa.",
    "mooooooooooooaaaaan.",
    "...",
}

function GetSpecialCharacterString(character)
    if character == nil then
        return nil
    end

    character = string.lower(character)

    return (character == "mime" and "")
        or (character == "ghost" and CraftOooh())
        or (character == "wonkey" and CraftMonkeySpeech())
        or (character == "wilton" and wilton_sayings[math.random(#wilton_sayings)])
        or nil
end

--V2C: Deprecated, set talker.mod_str_fn in character prefab definitions instead
--     Kept for backward compatibility with mods
function GetSpecialCharacterPostProcess(character, string)
    return string
end

-- When calling GetString, must pass actual instance of entity if it might be used when ghost
-- Otherwise, handing inst.prefab directly to the function call is okay
function ProcessString(inst)

    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)

    local specialcharacter =
    type(inst) == "table"
    and ((inst:HasTag("mime") and "mime") or
    (inst:HasTag("playerghost") and "ghost"))
    or character

    return GetSpecialCharacterString(specialcharacter)
    or nil
end

-- When calling GetString, must pass actual instance of entity if it might be used when ghost
-- Otherwise, handing inst.prefab directly to the function call is okay
function GetString(inst, stringtype, modifier, nil_missing)
    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)


    if type(inst) ~= "string" and inst.components.talker and inst.components.talker.speechproxy then
        character = inst.components.talker.speechproxy
    end

    character = character ~= nil and string.upper(character) or nil
    stringtype = stringtype ~= nil and string.upper(stringtype) or nil
	if type(modifier) == "table" then
		for i,v in ipairs(modifier) do
			v = string.upper(v)
		end
	else
		modifier = modifier ~= nil and string.upper(modifier) or nil
	end

    local specialcharacter =
        type(inst) == "table"
        and ((inst:HasTag("mime") and "mime") or
        (inst:HasTag("playerghost") and "ghost"))
        or character


	return GetSpecialCharacterString(specialcharacter)
        or getcharacterstring(STRINGS.CHARACTERS[character], stringtype, modifier)
        or getcharacterstring(STRINGS.CHARACTERS.GENERIC, stringtype, modifier)
		or (not nil_missing and ("UNKNOWN STRING: "..(character or "").." "..(stringtype or "").." "..(modifier or "")))
		or nil
end

function GetLine(inst, line, modifier, nil_missing)
    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)


    if type(inst) ~= "string" and inst.components.talker and inst.components.talker.speechproxy then
        character = inst.components.talker.speechproxy
    end

    character = character ~= nil and string.upper(character) or nil
    line = line ~= nil and string.upper(line) or nil
    if type(modifier) == "table" then
        for i,v in ipairs(modifier) do
            v = string.upper(v)
        end
    else
        modifier = modifier ~= nil and string.upper(modifier) or nil
    end

    local specialcharacter =
        type(inst) == "table"
        and ((inst:HasTag("mime") and "mime") or
        (inst:HasTag("playerghost") and "ghost"))
        or character

    return GetSpecialCharacterString(specialcharacter)
        or line
end

function GetActionString(action, modifier)
    return getcharacterstring(STRINGS.ACTIONS, action, modifier) or "ACTION"
end

-- NOTES(JBK): Wraps up edge cases that add to the description.
-- This should not be called directly but is open for mods to hook to add onto.
-- This function is responsible for initializing the return string if it is nil.
function GetDescription_AddSpecialCases(ret, charactertable, inst, item, modifier)
    local post = {}

    -- NOTES(JBK): Encapsulate getcharacterstring to only use the first return value!
    if type(inst) == "table" then
        if item.components.shadowlevel ~= nil and inst:HasTag("shadowmagic") then
            table.insert(post, (getcharacterstring(charactertable, "ANNOUNCE_SHADOWLEVEL_ITEM", modifier)))
        end

        if inst.components.foodmemory ~= nil and inst.components.foodmemory:GetMemoryCount(item.prefab) > 0 then
            table.insert(post, (getcharacterstring(charactertable, "ANNOUNCE_FOODMEMORY", modifier)))
        end
    end

    if item.components.repairable ~= nil and not item.components.repairable.noannounce and item.components.repairable:NeedsRepairs() then
        table.insert(post, (getcharacterstring(charactertable, "ANNOUNCE_CANFIX", modifier)))
    end

    if #post > 0 then
        ret = (ret or "") .. table.concat(post, "")
    end

    return ret
end
-- When calling GetDescription, must pass actual instance of entity if it might be used when ghost
-- Otherwise, handing inst.prefab directly to the function call is okay
function GetDescription(inst, item, modifier)
    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)

    if type(inst) ~= "string" and inst.components.talker and inst.components.talker.speechproxy then
        character = inst.components.talker.speechproxy
    end

    character = character ~= nil and string.upper(character) or nil
    local itemname = item.nameoverride or item.components.inspectable.nameoverride or item.prefab or nil
    itemname = itemname ~= nil and string.upper(itemname) or nil
	if type(modifier) == "table" then
		for i,v in ipairs(modifier) do
			v = string.upper(v)
		end
	else
		modifier = modifier ~= nil and string.upper(modifier) or nil
	end

    local specialcharacter =
        type(inst) == "table"
        and ((inst:HasTag("mime") and "mime") or
            (inst:HasTag("playerghost") and "ghost"))
        or character

    local ret = GetSpecialCharacterString(specialcharacter)
    if ret ~= nil then
        return ret
    end

    if character ~= nil and STRINGS.CHARACTERS[character] ~= nil then
        ret = getcharacterstring(STRINGS.CHARACTERS[character].DESCRIBE, itemname, modifier)
        ret = GetDescription_AddSpecialCases(ret, STRINGS.CHARACTERS[character], inst, item, modifier)
        if ret ~= nil then
            return ret
        end
    end

    ret = getcharacterstring(STRINGS.CHARACTERS.GENERIC.DESCRIBE, itemname, modifier)

    if item ~= nil then
        ret = GetDescription_AddSpecialCases(ret, STRINGS.CHARACTERS.GENERIC, inst, item, modifier)
        if ret ~= nil then
            return ret
        end
    end

    return ret or STRINGS.CHARACTERS.GENERIC.DESCRIBE_GENERIC
end

function GetCharacterDescription(herocharacter)
    if herocharacter == "woodie" then
        if TheNet:GetCountryCode() == "CA" then
            herocharacter = herocharacter.."_canada"
        elseif TheNet:GetCountryCode() == "US" then
            herocharacter = herocharacter.."_us"
        end
    end
    if TheNet:GetServerGameMode() == "lavaarena" then
		return STRINGS.LAVAARENA_CHARACTER_DESCRIPTIONS[herocharacter]
	elseif TheNet:GetServerGameMode() == "quagmire" then
		return STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS[herocharacter]
	end
    return STRINGS.CHARACTER_DESCRIPTIONS[herocharacter]
end

-- When calling GetActionFailString, must pass actual instance of entity if it might be used when ghost
-- Otherwise, handing inst.prefab directly to the function call is okay
function GetActionFailString(inst, action, reason)
    local character =
        type(inst) == "string"
        and inst
        or (inst ~= nil and inst.prefab or nil)

    local specialcharacter =
        type(inst) == "table"
        and ((inst:HasTag("playerghost") and "ghost") or
            (inst:HasTag("mime") and "mime"))
        or character

    local ret = GetSpecialCharacterString(specialcharacter)
    if ret ~= nil then
        return ret
    end

    character = string.upper(character)

    return (STRINGS.CHARACTERS[character] ~= nil and getcharacterstring(STRINGS.CHARACTERS[character].ACTIONFAIL, action, reason))
        or getcharacterstring(STRINGS.CHARACTERS.GENERIC.ACTIONFAIL, action, reason)
        or STRINGS.CHARACTERS.GENERIC.ACTIONFAIL_GENERIC
end

function FirstToUpper(str)
    return str:gsub("^%l", string.upper)
end

function TrimString( s )
   return string.match( s, "^()%s*$" ) and "" or string.match( s, "^%s*(.*%S)" )
end

-- usage:
-- subfmt("this is my {adjective} string, read it {number} times!", {adjective="cool", number="five"})
-- => "this is my cool string, read it five times"
function subfmt(s, tab)
  return (s:gsub('(%b{})', function(w) return tab[w:sub(2, -2)] or w end))
end

function str_seconds(time)
	time = math.floor(time)
	local seconds = 0
	local minutes = 0
	local hours = 0


	seconds = time % 60
	time = (time - seconds) / 60
	if time > 0  then
		minutes = time % 60
		time = (time - minutes) / 60
	end
	if time > 0  then
		hours = time
	end

	local seconds_str = seconds<10 and tostring("0"..seconds) or tostring(seconds)
	local minutes_str = (hours > 0 and minutes<10) and tostring("0"..minutes) or tostring(minutes)

	if hours > 0 then
		return subfmt(STRINGS.UI.TIME_FORMAT.HHMMSS, {hours=hours, minutes=minutes_str, seconds=seconds_str})
	else
		return subfmt(STRINGS.UI.TIME_FORMAT.MMSS, {minutes=minutes_str or 0, seconds=seconds_str})
	end

end

function str_date(os_time)
	local os_date = os.date("*t", os_time)

	return subfmt(STRINGS.UI.DATE_FORMAT.MDY, {month = STRINGS.UI.DATE.MONTH_ABBR[os_date.month], day = tostring(os_date.day), year = tostring(os_date.year)})
end

function str_play_time(time)
	local minutes = 0
	local hours = 0
	local days = 0

	time = math.floor(time / 60) -- drop the seconds, we dont want to display them
	if time > 0  then
		minutes = time % 60
		time = math.floor((time - minutes) / 60)
	end
	if time > 0  then
		hours = time % 24
		time = math.floor((time - hours) / 24)
	end
	if time > 0  then
		days = time
	end

	if days > 0 then
		return subfmt(STRINGS.UI.DAYS_FORMAT.DHM, {days=days, hours=hours, minutes=minutes})
	elseif hours > 0 then
		return subfmt(STRINGS.UI.DAYS_FORMAT.HM, {hours=hours, minutes=minutes})
	else
		return subfmt(STRINGS.UI.DAYS_FORMAT.M, {minutes=minutes or 1})
	end
end

--Damerau–Levenshtein distance with limit
function DamLevDist( a, b, limit )
    local a_len = a:len()
    local b_len = b:len()

    --early out optimization, if the lengths are more than "limit" difference then we can return
    if math.abs( a_len - b_len ) > limit then
        return math.abs( a_len - b_len )
    end

    --Note(Peter): does this work with unicode?
    a = { string.byte( a, 1, a_len ) }
    b = { string.byte( b, 1, b_len ) }

    local d = {} --2d array, 0-based, indexed as [i * num_columns + j]
    local num_columns = b_len + 1

    local id = function( i, j )
        return i * num_columns + j
    end

    --Initialize insertion and deletion costs
    for i = 0, a_len do
        d[ id(i,0) ] = i
    end
    for j = 0, b_len do
        d[ id(0,j) ] = j
    end


    for i = 1, a_len do
        local low = limit --Used to early out when we get to the limit

        for j = 1, b_len do
            local cost = a[i] ~= b[j] and 1 or 0

            local current = math.min(
                d[ id(i-1, j  ) ] + 1,    --Deletion
                d[ id(i,   j-1) ] + 1,    --Insertion
                d[ id(i-1, j-1) ] + cost  --Cost of substitution, could be 0 if they are the same
            )
            d[ id(i,j) ] = current

            --Check if we can transpose
            if i > 1 and j > 1 and a[ i ] == b[ j-1 ] and a[ i-1 ] == b[ j ] then
                d[ id(i,j) ] = math.min( current, d[ id(i-2, j-2) ] + cost ) -- Cost of transposition
            end

            if current < low then
                low = current
            end
        end

        if low > limit then
            return low
        end
    end

    return d[ id(a_len,b_len) ]
end

--once again, left so you can see what string_search_subwords is doing
local search_subwords = function( search, str, sub_len, limit )
    local str_len = string.len(str)

    for i=1,str_len - sub_len + 1 do
        local sub = str:sub( i, i + sub_len - 1 )

        local dist = DamLevDist( search, sub, limit )
        if dist <= limit then
            return true
        end
    end

    return false
end

function do_search_subwords(...)
    return string_search_subwords(...)
end