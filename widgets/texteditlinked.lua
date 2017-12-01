local Widget = require "widgets/widget"
local TextEdit = require "widgets/textedit"

local TextEditLinked = Class(TextEdit, function(self, font, size, text, colour)
    TextEdit._ctor(self, font, size, text, colour)
end)

function TextEditLinked:SetNextTextEdit(next_te)
	self.next_text_edit = next_te
end

function TextEditLinked:SetLastTextEdit(last_te)
	self.last_text_edit = last_te
end

function TextEditLinked:OnTextInput(text)
	--print("TextEditLinked:OnTextInput(text)", text)
    if self.limit then
        local str = self:GetString()
        if string.len(str) >= self.limit then
			if self.next_text_edit == nil then
				return false
			else
				--if box is full and character added, move to next box (set cursor to start)
				self:SetEditing(false)
                self.next_text_edit:SetEditing(true)
				return self.next_text_edit:OnTextInput(text)
			end
        end
    end

	return TextEditLinked._base.OnTextInput(self, text)
end

function TextEditLinked:OnRawKey(key, down)
	--if box is empty and backpack is pressed, move to last box (set cursor to end by doing getstring setstring)
	if down and self.editing then
		if key == KEY_BACKSPACE then
			local str = self:GetString()
			if string.len(str) == 0 and self.last_text_edit ~= nil then
				--if box is empty and backpack is pressed, move to last box and set cursor
				self:SetEditing(false)
				self.last_text_edit:SetEditing(true)
				self.last_text_edit:SetString(self.last_text_edit:GetString()) --HACK to set the cursor to the end
				return self.last_text_edit:OnRawKey(key, down)
			end
		elseif key == KEY_TAB then
			if self.next_text_edit then
				self.next_text_edit:SetEditing(true)
			end
        elseif TheInput:IsPasteKey(key) then
			local clipboard = TheSim:GetClipboardData()
			if self.OnLargePaste ~= nil and #clipboard > self.limit then
				self:OnLargePaste()
				if self.OnTextInputted ~= nil then
					self.OnTextInputted()
				end
				return true
			else
                self.pasting = true
                if self.next_text_edit ~= nil then
                    self.next_text_edit.pasting = true
                end
				for i=1,#clipboard do
					local char = clipboard:sub(i,i)
                    local success, overflow = self:OnTextInput(char)
					if not success and self.next_text_edit ~= nil then
						success, overflow = self.next_text_edit:OnTextInput(char)
					end
                    if overflow then
                        break
                    end
                end
                self.pasting = false
                if self.next_text_edit ~= nil then
                    self.next_text_edit.pasting = false
                end
				if self.OnTextInputted ~= nil then
					self.OnTextInputted()
				end
				return true
			end
		end
	end

    return TextEditLinked._base.OnRawKey(self, key, down)
end

return TextEditLinked
