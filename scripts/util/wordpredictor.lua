
local HARD_DELIM = " "

local WordPredictor = Class(function(self, text_edit)
	self.prediction = nil

	self.text = ""

	self.dictionaries = {}
end)

function WordPredictor:AddDictionary(dictionary)
	dictionary.postfix = dictionary.postfix or ""
	dictionary.GetDisplayString = dictionary.GetDisplayString or function(word) return dictionary.delim .. word .. dictionary.postfix end
	table.insert(self.dictionaries, dictionary)
end

local function FindEndCursorPos(text, cursor_pos)
	-- Find the first instance of a <"> or the end of the text in order to have more expected word replacement
	local endquote = text:find("\"", cursor_pos)
	if endquote ~= nil then
		return endquote - 1
	end

	return #text
end

local function _find_prediction_start(dictionaries, text, cursor_pos)
	local prediction = nil

	cursor_pos = FindEndCursorPos(text, cursor_pos)
	local pos = cursor_pos
	while (pos > 0) do
		for _, dic in ipairs(dictionaries) do
			local pos_char = text:sub(pos - (#dic.delim-1), pos)

			if pos_char == nil or #pos_char ~= #dic.delim or pos_char:sub(-1) == HARD_DELIM then
				break
			end

			local num_chars_for_prediction = dic.num_chars or 2

			if pos_char == dic.delim then
				if cursor_pos - pos >= num_chars_for_prediction then
					local pre_pos_char = (dic.skip_pre_delim_check or pos == 1) and HARD_DELIM or text:sub(pos-#dic.delim, pos-#dic.delim)
					if pre_pos_char == HARD_DELIM or pre_pos_char == dic.delim or not string.match(pre_pos_char, "[a-zA-Z0-9]") then -- Note: the character range checking is here so I don't have to write crazy pairing of ':' to determin if the current one is the end of another word
						local search_text = text:sub(pos + 1, cursor_pos)
						local matches = {}
						for _, word in ipairs(dic.words) do
							local index = word:find(search_text, 1, true)
							if index ~= nil then
								table.insert(matches, {i = index, word = word})
							end
						end
						if dic.postfix == "" and #matches == 1 then
							-- if we only have one match and its the full text of the word then then remove it so pressing enter doesnt have to happen twice during chat
							-- this check is only needed if there is no post fix, otherwise typing the post fix will dismiss the prediction
							if matches[1].word == search_text then
								matches = {}
							end
						end
						if #matches > 0 then
							prediction = {}
							prediction.start_pos = pos
							prediction.matches = matches
							prediction.dictionary = dic
						end
					end
				end
				if prediction ~= nil then
					break
				end
			end
		end
		if prediction ~= nil then
			break
		end
		pos = pos - 1
	end

	if prediction ~= nil then
		local matches = prediction.matches
		table.sort(matches, function(a, b) return (a.i == b.i and a.word < b.word) or a.i < b.i end)

		prediction.matches = {}
		for _, v in ipairs(matches) do
			table.insert(prediction.matches, v.word)
		end

		local str = ""
		for _, v in ipairs(prediction.matches) do str = str .. ", " .. v end
	end
	return prediction
end

function WordPredictor:RefreshPredictions(text, cursor_pos)
	self.cursor_pos = cursor_pos
	self.text = text

	self.prediction = _find_prediction_start(self.dictionaries, text, cursor_pos)
end

function WordPredictor:Apply(prediction_index)
	local new_text = nil
	local new_cursor_pos = nil
	if self.prediction ~= nil then
		local new_word = self.prediction.matches[math.clamp(prediction_index or 1, 1, #self.prediction.matches)]

		new_text = self.text:sub(1, self.prediction.start_pos) .. new_word .. self.prediction.dictionary.postfix
		new_cursor_pos = #new_text

		local endpos = FindEndCursorPos(self.text, self.cursor_pos)
		local remainder_text = self.text:sub(endpos + 1, #self.text) or ""
		local remainder_strip_pos = remainder_text:find("[^a-zA-Z0-9]") or (#remainder_text + 1)
		if self.prediction.dictionary.postfix ~= "" and remainder_text:sub(remainder_strip_pos, remainder_strip_pos + (#self.prediction.dictionary.postfix-1)) == self.prediction.dictionary.postfix then
			remainder_strip_pos = remainder_strip_pos + #self.prediction.dictionary.postfix
		end

		new_text = new_text .. remainder_text:sub(remainder_strip_pos)
	end

	self:Clear()
	return new_text, new_cursor_pos
end

function WordPredictor:Clear()
	self.prediction = nil
	self.cursor_pos = nil
	self.text = nil
end

function WordPredictor:GetDisplayInfo(prediction_index)
	local text = ""
	if self.prediction ~= nil and prediction_index >= 1 and prediction_index <= #self.prediction.matches then
		text = self.prediction.dictionary.GetDisplayString(self.prediction.matches[prediction_index])
	end
	return text
end

return WordPredictor
