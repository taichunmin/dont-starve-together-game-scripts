local Widget = require "widgets/widget"

local Text = Class(Widget, function(self, font, size, text, colour)
    Widget._ctor(self, "Text")

    self.inst.entity:AddTextWidget()

    self.inst.TextWidget:SetFont(font)
    self.font = font

	self:SetSize(size)

    self:SetColour(colour or { 1, 1, 1, 1 })

    if text ~= nil then
        self:SetString(text)
    end
end)

function Text:__tostring()
    return string.format("%s - %s", self.name, self.string or "")
end

function Text:DebugDraw_AddSection(dbui, panel)
    Text._base.DebugDraw_AddSection(self, dbui, panel)
    local DebugPickers = require("dbui_no_package/debug_pickers")

    dbui.Spacing()
    dbui.Text("Text")
    dbui.Indent() do
        local changed, text = dbui.InputText("string", self:GetString())
        if changed then
            self:SetString(text)
        end

        local region_x,region_y = self.inst.TextWidget:GetRegionSize()
        changed, region_x,region_y = dbui.DragFloat3("region size", region_x,region_y, 100, 1, 1000, "%.f")
        if changed then
            self:SetRegionSize(region_x,region_y)
        end

        local colour = DebugPickers.Colour(dbui, "colour", self.colour)
        if colour then
            self:SetColour(colour)
        end

        local face, size = DebugPickers.Font(dbui, "", self.font, self.size)
        if face then
            self:SetFont(face)
            self:SetSize(size)
        end
    end
    dbui.Unindent()
end

function Text:SetColour(r, g, b, a)
    self.colour = type(r) == "number" and { r, g, b, a } or r
    self.inst.TextWidget:SetColour(unpack(self.colour))
end

function Text:GetColour()
    return { unpack(self.colour) }
end

function Text:SetHorizontalSqueeze(squeeze)
    self.inst.TextWidget:SetHorizontalSqueeze(squeeze)
end

function Text:SetFadeAlpha(a, skipChildren)
    if not self.can_fade_alpha then return end

    self.inst.TextWidget:SetColour(self.colour[1], self.colour[2], self.colour[3], self.colour[4] * a)
    Widget.SetFadeAlpha( self, a, skipChildren )
end

function Text:SetAlpha(a)
    self.inst.TextWidget:SetColour(1,1,1, a)
end

function Text:UpdateAlpha(a)
    self.colour[4] = a
    self.inst.TextWidget:SetColour(unpack(self.colour))
end

function Text:SetFont(font)
    self.inst.TextWidget:SetFont(font)
    self.font = font
end

function Text:SetSize(sz)
	if LOC then
		sz = sz * LOC.GetTextScale()
	end
    self.inst.TextWidget:SetSize(sz)
    self.size = sz
end

function Text:GetSize()
    return self.size
end

function Text:SetRegionSize(w,h)
    self.inst.TextWidget:SetRegionSize(w,h)
end

function Text:GetRegionSize()
    return self.inst.TextWidget:GetRegionSize()
end

function Text:ResetRegionSize()
    return self.inst.TextWidget:ResetRegionSize()
end

function Text:SetString(str)
    self.string = str
    self.inst.TextWidget:SetString(str or "")
end

function Text:GetString()
    return self.inst.TextWidget:GetString() or ""
end

--WARNING: This is not optimized!
-- Recommend to use only in FE menu screens.
-- Causes infinite loop when used with SetRegionSize!
--
-- maxwidth [optional]: max region width, only works when autosizing
-- maxchars [optional]: max chars from original string
-- ellipses [optional]: defaults to "..."
--
-- Works best specifying BOTH maxwidth AND maxchars!
--
-- How to pick non-arbitrary maxchars:
--  1) Call with only maxwidth, and a super long string of dots:
--     e.g. wdgt:SetTruncatedString(".............................", 30)
--  2) Find out how many dots were actually kept:
--     e.g. print(wdgt:GetString():len())
--  3) Use that number as an estimate for maxchars, or round up
--     a little just in case dots aren't the smallest character
function Text:SetTruncatedString(str, maxwidth, maxchars, ellipses)
	local str_fits = true
    str = str ~= nil and str:match("^[^\n\v\f\r]*") or ""
    if #str > 0 then
        if type(ellipses) ~= "string" then
            ellipses = ellipses and "..." or ""
        end
        if maxchars ~= nil and str:utf8len() > maxchars then
            str = str:utf8sub(1, maxchars)
            self.inst.TextWidget:SetString(str..ellipses)
			str_fits = false
        else
            self.inst.TextWidget:SetString(str)
        end
        if maxwidth ~= nil then
            while self.inst.TextWidget:GetRegionSize() > maxwidth do
                str = str:utf8sub(1, -2)
                self.inst.TextWidget:SetString(str..ellipses)
				str_fits = false
            end
        end
    else
        self.inst.TextWidget:SetString("")
    end
	return str_fits
end

local function IsWhiteSpace(charcode)
    -- 32: space
    --  9: \t
    return charcode == 32 or charcode == 9
end

local function IsNewLine(charcode)
    -- 10: \n
    -- 11: \v
    -- 12: \f
    -- 13: \r
    return charcode >= 10 and charcode <= 13
end

-- maxwidth can be a single number or an array of numbers if maxwidth is different per line
function Text:SetMultilineTruncatedString_Impl(str, maxlines, maxwidth, maxcharsperline, ellipses)
	local str_fits = true
    if str == nil or #str <= 0 then
        self.inst.TextWidget:SetString("")
        return str_fits
    end
    local tempmaxwidth = type(maxwidth) == "table" and maxwidth[1] or maxwidth
    if maxlines <= 1 then
        str_fits = self:SetTruncatedString(str, tempmaxwidth, maxcharsperline, ellipses) -- returns true if the string was truncated
    else
        self:SetTruncatedString(str, tempmaxwidth, maxcharsperline, false)
        local line = self:GetString()
        if #line < #str then
            if IsNewLine(str:byte(#line + 1)) then
                str = str:sub(#line + 2)
            elseif not IsWhiteSpace(str:byte(#line + 1)) then
                local found_white = false
                for i = #line, 1, -1 do
                    if IsWhiteSpace(line:byte(i)) then
                        line = line:sub(1, i)
                        found_white = true
                        break
                    end
                end
                str = str:sub(#line + 1)

                if not found_white then
                    --Testing for finding areas where we've had to split on
                    --print("Warning: ".. line .. " was split on non-whitespace.")
                end
            else
                str = str:sub(#line + 2)
                while #str > 0 and IsWhiteSpace(str:byte(1)) do
                    str = str:sub(2)
                end
            end
            if #str > 0 then
                if type(maxwidth) == "table" then
                    if #maxwidth > 2 then
                        tempmaxwidth = {}
                        for i = 2, #maxwidth do
                            table.insert(tempmaxwidth, maxwidth[i])
                        end
                    elseif #maxwidth == 2 then
                        tempmaxwidth = maxwidth[2]
                    end
                end
                str_fits = self:SetMultilineTruncatedString_Impl(str, maxlines - 1, tempmaxwidth, maxcharsperline, ellipses)
                self.inst.TextWidget:SetString(line.."\n"..(self.inst.TextWidget:GetString() or ""))
            end
        end
    end

	return str_fits
end

function Text:UpdateOriginalSize()
	self.original_size = self.size
end

function Text:SetMultilineTruncatedString(str, maxlines, maxwidth, maxcharsperline, ellipses, shrink_to_fit, min_shrink_font_size)
    if str == nil or #str <= 0 then
        self.inst.TextWidget:SetString("")
        return
    end

	if shrink_to_fit then
		--ensure that we reset the size back to the original size when we get new text
		if self.original_size ~= nil then
			self:SetSize( self.original_size )
		else
			self.original_size = self:GetSize()
		end
	end

	local str_fits = self:SetMultilineTruncatedString_Impl(str, maxlines, maxwidth, maxcharsperline, ellipses)
	while not str_fits and shrink_to_fit and LOC.GetShouldTextFit() and self:GetSize() > (min_shrink_font_size or 16) do -- the 16 is a semi reasonable "smallest" size that is okay. This is to stop stackoverflow from infinite recursion due to bad string data.
		local new_size = self:GetSize() - 1 --drop size to fit a whole word
		local shrinked_maxlines = math.floor(maxlines * self.original_size / new_size)  -- num lines that fit in original size

		self:SetSize( new_size )
		str_fits = self:SetMultilineTruncatedString_Impl(str, shrinked_maxlines, maxwidth, maxcharsperline, ellipses)
	end
end

function Text:SetAutoSizingString(str, max_width, allow_scaling_up)
-- Note: Use SetMultilineTruncatedString instead of this
    self:SetString(str)
	self.inst.TextWidget:ResetRegionSize()

	self.target_font_size = self:GetSize()
	local w = self:GetRegionSize()

	local scale = allow_scaling_up and (max_width / w) or math.min(1, max_width / w)
	if scale ~= 1 then
		self:SetSize(self.target_font_size * scale)
	end
end
function Text:RemoveAutoSizing()
	self:SetSize(self.target_font_size)
	self.target_font_size = nil
end

function Text:SetVAlign(anchor)
    self.inst.TextWidget:SetVAnchor(anchor)
end

function Text:SetHAlign(anchor)
    self.inst.TextWidget:SetHAnchor(anchor)
end

function Text:EnableWordWrap(enable)
    self.inst.TextWidget:EnableWordWrap(enable)
end

function Text:EnableWhitespaceWrap(enable)
    self.inst.TextWidget:EnableWhitespaceWrap(enable)
end

return Text
