-- This is a text completion object that has two modes:
--  luacompletion: look at previous input and complete the likely lua code
--  suggestion: take prebuilt prefixes and suggest prebuilt words
--
require "util"
local Text = require "widgets/text"

local function _CountOccurrences(str, delimiter)
    local _, num_delimiters = str:gsub(delimiter, '')
    return num_delimiters
end

local TextCompleter = Class(function(self, suggest_text_widgets, input_textedit, history_storage, is_completing_lua)
    self.suggest_text_widgets = suggest_text_widgets
    self.console_edit = input_textedit
    self.is_completing_lua = is_completing_lua

    self:ClearState()

    self.suggesting = false
    self.highlight_idx = nil
    self.suggest_replace = ""

    self.history_idx = nil
    -- Owner is expected to insert into history. We just browse it.
    self.history = history_storage

    self.console_edit.validrawkeys[KEY_TAB] = true
    self.console_edit.validrawkeys[KEY_UP] = true
    self.console_edit.validrawkeys[KEY_DOWN] = true
end)

-- static
-- A helper to create the most obvious set of widgets. You may want them
-- customized more than this.
function TextCompleter.CreateDefaultSuggestionWidgets(widget_root, suggestion_label_height, max_suggestions)
    local suggest_text_widgets = {}
    for i = 1, max_suggestions do
        local w = widget_root:AddChild(Text(DEFAULTFONT, 27, ""))
        w:SetPosition(290, 32*i + 18, 0)
        w:SetHAlign(ANCHOR_RIGHT)
        w:SetRegionSize(300, suggestion_label_height)
        table.insert(suggest_text_widgets, w)
    end
    return suggest_text_widgets
end

function TextCompleter:DebugDraw_AddSection(dbui, panel)
    dbui.Text("TextCompleter.DebugDraw_AddSection")

    dbui.SetNextTreeNodeOpen(true, dbui.constant.SetCond.Appearing)
    if dbui.CollapsingHeader("Lua Completion") then
        dbui.Value("is_completing_lua", self.is_completing_lua)
        -- If not completing lua, don't bother.
        if self.is_completing_lua then
            dbui.Text("luacompletePrefix: ".. tostring(self.luacompletePrefix))
            dbui.Text("luacompleteObjName: ".. self.luacompleteObjName)
            dbui.Text("luacompleteObj: ".. tostring(self.luacompleteObj))
            dbui.Value("luacompleteOffset", self.luacompleteOffset)
        end
    end

    dbui.SetNextTreeNodeOpen(true, dbui.constant.SetCond.Appearing)
    if dbui.CollapsingHeader("Word Suggestion") then
        dbui.Value("suggesting", self.suggesting)
        dbui.Value("history_idx", self.history_idx or -1)
        dbui.SetNextTreeNodeOpen(true)
        panel:AppendTable(dbui, self.suggestion_prefixes or {}, "suggestion_prefixes")
        dbui.SetNextTreeNodeOpen(true)
        panel:AppendTable(dbui, self.suggestion_words or {}, "suggestion_words")
    end
end

function TextCompleter:SetSuggestionData(suggestion_data)
    -- An array of words that can trigger suggestions. We will start suggestion
    -- after any of these inputs.
    self.suggestion_prefixes = suggestion_data.prefixes

    -- An array of words to suggest.
    self.suggestion_words = suggestion_data.words

    -- An array of acceptable delimiters. Matched delimiters surround suggested
    -- words.
    self.suggestion_delimiters = suggestion_data.delimiters

    -- Forbid "magic" characters as delimiters to prevent interpreting
    -- delimiters as magic. (Which can cause lua asserts for '[' or incorrect
    -- results for '*'.)
    local magic = "().%+-*?[^$"
    for i,delimiter in ipairs(self.suggestion_delimiters) do
        assert( nil == magic:find(delimiter, nil, true) )
    end
end

function TextCompleter:ClearState()
    self.luacompletePrefix = nil
    self.luacompleteObjName = ""
    self.luacompleteObj = nil
    self.luacompleteOffset = -1
    self:_ClearSuggestionState()
end

function TextCompleter:_ClearSuggestionState()
    self.suggesting = false
    self.highlight_idx = nil
    for _,w in ipairs(self.suggest_text_widgets) do
        w:SetString("")
    end
end

function TextCompleter:PerformCompletion()
    if self.suggesting then
        -- Only do suggesting if currently suggesting -- it relies on previous
        -- state.
        return self:_SuggestComplete()
    elseif self.is_completing_lua then
        -- Always do lua if enabled -- it rebuilds its state.
        return self:_LuaComplete()
    end
end

function TextCompleter:OnRawKey(key, down)
    if down then return end

    if key == KEY_TAB then
        self:PerformCompletion()
    elseif key == KEY_UP then
        if self.suggesting then
            self:_DeltaSuggest(1)
        else
            local len = #self.history
            if len > 0 then
                if self.history_idx ~= nil then
                    self.history_idx = math.max( 1, self.history_idx - 1 )
                else
                    self.history_idx = len
                end
                self.console_edit:SetString( self.history[ self.history_idx ] )
            end
        end
        return true
    elseif key == KEY_DOWN then
        if self.suggesting then
            self:_DeltaSuggest(-1)
        else
            local len = #self.history
            if len > 0 then
                if self.history_idx ~= nil then
                    if self.history_idx == len then
                        self.console_edit:SetString( "" )
                    else
                        self.history_idx = math.min( len, self.history_idx + 1 )
                        self.console_edit:SetString( self.history[ self.history_idx ] )
                    end
                end
            end
        end
        return true
    end

    self:ClearState()
    return false
end

function TextCompleter:_DeltaSuggest(direction)
    local num_widgets = #self.suggest_text_widgets
    -- Circular increment: Lots of +- 1 due to lua 1-indexed arrays
    local new_idx = (self.highlight_idx + direction + num_widgets - 1) % (num_widgets) + 1
    self:_Highlight(new_idx)
end

function TextCompleter:_SuggestComplete()
    assert(self.suggest_text_widgets[self.highlight_idx] ~= nil)
    local str = self.console_edit:GetString()

    -- Replace partially typed suggestion with completed suggestion.
    local first = string.lower(str):rfind_plain(self.suggest_replace)
    if first ~= nil then
        local idx = first - 1
        str = str:sub(1, idx)
        str = str .. self.suggest_text_widgets[self.highlight_idx]:GetString()
    end

    -- Closing code assumes we cannot have multiple unclosed delimiters (so we
    -- don't need to deal with nesting) because we won't trigger suggestions if
    -- there are multiple open delimiters because we treat all delimiters as
    -- interchangeable.

    -- Close delimiters and parens, get us ready to submit text.
    for i,delimiter in ipairs(self.suggestion_delimiters) do
        local num_delimiters = _CountOccurrences(str, delimiter)
        if (num_delimiters % 2 > 0) then
            str = str .. delimiter
        end
    end

    if self.is_completing_lua then
        local remaining_parens = _CountOccurrences(str, "%(") - _CountOccurrences(str, "%)")
        str = str .. string.rep(")", remaining_parens)
    end

    self:ClearState()

    self.console_edit:SetString(str)

    return true
end

-- Should be called from owner's OnRawKey.
function TextCompleter:UpdateSuggestions(down, key)
    if key == KEY_ENTER or key == KEY_TAB or key == KEY_UP or key == KEY_DOWN then return end
    if down then
        -- We don't care about previous state -- we're rebuilding it every
        -- update. Don't mess with lua state since we might not be suggesting.
        self:_ClearSuggestionState()

        -- Simplify input
        local primary_delimiter = self.suggestion_delimiters[1]
        local str_test = self.console_edit:GetString()
        str_test = string.lower(str_test) -- lowercase for comparison
        if self.is_completing_lua then
            str_test = string.gsub(str_test, "%(", "") --remove parens for comparison
        end
        for i,delimiter in ipairs(self.suggestion_delimiters) do
            if i ~= 1 then
                str_test = string.gsub(str_test, delimiter, primary_delimiter)
            end
        end

        local num_delimiters = _CountOccurrences(str_test, primary_delimiter)
        if (num_delimiters % 2 == 0) then -- even # of delimiters, no input to complete.
            return
        end

        -- Strip matched delimiters.
        local remove_earlier_delim_regex = string.format(".*%s(.*%s)", primary_delimiter, primary_delimiter)
        str_test = str_test:gsub(remove_earlier_delim_regex, "%1")

        for _,prefix in ipairs(self.suggestion_prefixes) do
            prefix = prefix .. primary_delimiter
            local start, fin = str_test:find(prefix)
            if start ~= nil and fin ~= nil then
                -- make sure there's text to work from and doesn't have a closing delimiters/parens
                if str_test:len() > fin
                    and str_test:find(primary_delimiter, fin + 1) == nil
                    and (self.is_completing_lua or str_test:find(")", fin + 1, true) == nil)
                    then
                    local partial_match = str_test:sub(fin+1)
                    self:_ShowSuggestions(partial_match, prefix)
                    break
                end
            end
        end
    end
end

function TextCompleter:_ShowSuggestions(partial_match, prefix)
    -- Gather and organize.
    local suggestions = {}
    for _,word in ipairs(self.suggestion_words) do
        local first,last = word:find(partial_match, nil, true)
        if first then
            table.insert(suggestions, {
                    position = first,
                    suggestion = word
                })
        end
    end
    table.sort(suggestions, function(a, b)
            -- The combination of these two results in preferring shorter
            -- matches ('spe' will match 'spear' before 'spear_blueprint').
            if a.position == b.position then
                -- Compare words for lexical sort: groups related items.
                return a.suggestion < b.suggestion
            else
                -- Compare the position of the matches: earlier occurrence is
                -- more relevant ('ha' matches 'hambat' before
                -- 'bishop_charge').
                return a.position < b.position
            end
        end)

    -- Offer any found results as suggestions.
    self.suggesting = #suggestions > 0
    if self.suggesting then
        self.suggest_replace = partial_match
    end

    -- Put top matches into display widgets.
    local max_suggestions = #self.suggest_text_widgets
    local num_suggestions = math.min(#suggestions, max_suggestions)
    for i=1,num_suggestions do
        local word = suggestions[i].suggestion
        if i == 1 then
            self:_Highlight(i)
        end
        self.suggest_text_widgets[i]:SetString(word)
    end
end

function TextCompleter:_Highlight(key)
    for i,w in ipairs(self.suggest_text_widgets) do
        if i ~= key then
            w:SetColour(1, 1, 1, 1)
        end
    end

    self.highlight_idx = key
    self.suggest_text_widgets[key]:SetColour(1, 1, 0, 1)
end

-- Check if the beginning of str matches prefix. Analogous to python's
-- startswith().
function string.starts(str,prefix)
    return string.sub(str, 1, string.len(prefix))==prefix
end

-- For lua autocompletion to be improved, you really need to start knowing
-- about the language that's being autocompleted and the string must be
-- tokenized and fed into a lexer.
--
-- For instance, what should you autocomplete here:
--        print(TheSim:Get<tab>
--
-- Given understanding of the language, we know that the object to get is TheSim and
-- it's the metatable from that to autocomplete from. However, you need to know that
-- "print(" is not part of that object.
--
-- Conversely, if I have "SomeFunction().GetTheSim():Get<tab>" then I need to include
-- "SomeFunction()." as opposed to stripping it off. Again, we're back to understanding
-- the language.
--
-- Something that might work is to cheat by starting from the last token, then iterating
-- backwards evaluating pcalls until you don't get an error or you reach the front of the
-- string.
function TextCompleter:_LuaComplete()
    local str = self.console_edit:GetString()

    -- Ensure that changes to input make us restart completion (instead of
    -- resuming from our previous completion sequence).
    if self.luacompleteInput ~= str then
        self:ClearState()
    end

    if self.luacompletePrefix == nil and self.luacompleteObj == nil then
        local luacomplete_obj_name = nil
        local luacomplete_prefix = str
        self.luacompleteInput = str

        local rev_str = string.reverse( str )
        local idx = string.find( rev_str, ".", 1, true )
        if idx == nil then
            idx = string.find( rev_str, ":", 1, true )
        end
        if idx ~= nil then
            luacomplete_obj_name = string.sub( str, 1, string.len( str ) - idx )
            luacomplete_prefix = string.sub( str, string.len( str ) - idx + 2, string.len( str ) - 1 )
        end

        self.luacompletePrefix = luacomplete_prefix

        if luacomplete_obj_name ~= nil then
            -- Lunar instances are userdata we can't iterate for suggestions.
            -- Find the matching class definition (i.e.,
            -- cNetworkLuaProxy::className) that is a table of members.
            for capture in luacomplete_obj_name:gmatch("The(.*)") do
                for name,obj in pairs(_G) do
                    if type(obj) == 'table'
                        and name ~= luacomplete_obj_name
                        and name:find(capture, nil, true)
                        then
                        luacomplete_obj_name = name
                        break
                    end
                end
            end

            -- Execute some lua code to give us a known variable
            -- (__KLEI_AUTOCOMPLETE) pointing to our object.
            local status, r = pcall( loadstring( "__KLEI_AUTOCOMPLETE=" .. luacomplete_obj_name ) )
            if status then
                self.luacompleteObjName = string.sub( str, 1, string.len( str ) - idx + 1 ) -- must include that last character!
                self.luacompleteObj = getmetatable( __KLEI_AUTOCOMPLETE )
                if self.luacompleteObj == nil or IsTableEmpty(self.luacompleteObj) then
                    self.luacompleteObj = __KLEI_AUTOCOMPLETE
                end
            end
        end
    end

    local luacomplete_obj = self.luacompleteObj or _G

    local function find_next_completion(offset)
        local counter = 0
        for k, v in pairs( luacomplete_obj ) do
            if string.starts( k, self.luacompletePrefix ) then
                if offset == -1 or offset < counter then
                    self.luacompleteInput = self.luacompleteObjName .. k
                    if type(v) == 'function' then
                        self.luacompleteInput = self.luacompleteInput .. '('
                    end
                    self.console_edit:SetString(self.luacompleteInput)
                    return counter
                end
                counter = counter + 1
            end
        end
        return -1
    end

    self.luacompleteOffset = find_next_completion(self.luacompleteOffset)
    if self.luacompleteOffset < 0 then
        -- Restart from beginning.
        self.luacompleteOffset = find_next_completion(-1)
    end

    return self.luacompleteOffset >= 0
end

return TextCompleter
