local Widget = require "widgets/widget"
local Image = require "widgets/image"


require "constants"


local OPPOSITEALIGN = {
    [ANCHOR_LEFT] = ANCHOR_RIGHT,
    [ANCHOR_RIGHT] = ANCHOR_LEFT,
    [ANCHOR_MIDDLE] = ANCHOR_MIDDLE,
    [ANCHOR_BOTTOM] = ANCHOR_TOP,
    [ANCHOR_TOP] = ANCHOR_BOTTOM,
}

local function SetupSubElement(self, element, atlas, tex, halign, valign, resizew, resizeh, offsetX, offsetY)
	if atlas and tex then
		element:SetTexture(atlas, tex)
	end

    element:SetHRegPoint(OPPOSITEALIGN[halign])
    element:SetVRegPoint(OPPOSITEALIGN[valign])

    element.offsetX = offsetX or 0
    element.offsetY = offsetY or 0

    element.halign = halign
    element.valign = valign

    if resizew ~= nil then
        element.resizew = resizew
    else
        element.resizew = halign == ANCHOR_MIDDLE
    end
    if resizeh ~= nil then
        element.resizeh = resizeh
    else
        element.resizeh = valign == ANCHOR_MIDDLE
    end
    return element
end

local function CreateSubElement(self, atlas, tex, halign, valign, resizew, resizeh, offsetX, offsetY)
    if tex == nil then
        return
    end
    local element = self:AddChild(Image())
    SetupSubElement(self, element, atlas, tex, halign, valign, resizew, resizeh, offsetX, offsetY)
    return element
end

local NineSlice = Class(Widget, function(self, atlas, top_left, top_center, top_right,
                                                        mid_left, mid_center, mid_right,
                                                        bottom_left, bottom_center, bottom_right)
    Widget._ctor(self, "NineSlice")

    top_left = top_left or "topleft.tex"
    top_center = top_center or "top.tex"
    top_right = top_right or "topright.tex"
    mid_left = mid_left or "left.tex"
    mid_center = mid_center or "center.tex"
    mid_right = mid_right or "right.tex"
    bottom_left = bottom_left or "bottomleft.tex"
    bottom_center = bottom_center or "bottom.tex"
    bottom_right = bottom_right or "bottomright.tex"

    self.atlas = atlas

    -- The mid_center element is treated as the actual "widget" for sizing and alignment, the other
    -- elements are "stuck on" to it.
    if mid_center ~= nil then
        self.mid_center = self:AddChild(Image(atlas, mid_center))
    else
        self.mid_center = self:AddChild(Widget())
    end

    self.elements = {
        CreateSubElement(self, atlas, top_left, ANCHOR_LEFT, ANCHOR_TOP),
        CreateSubElement(self, atlas, top_center, ANCHOR_MIDDLE, ANCHOR_TOP),
        CreateSubElement(self, atlas, top_right, ANCHOR_RIGHT, ANCHOR_TOP),

        CreateSubElement(self, atlas, mid_left, ANCHOR_LEFT, ANCHOR_MIDDLE),
        CreateSubElement(self, atlas, mid_right, ANCHOR_RIGHT, ANCHOR_MIDDLE),

        CreateSubElement(self, atlas, bottom_left, ANCHOR_LEFT, ANCHOR_BOTTOM),
        CreateSubElement(self, atlas, bottom_center, ANCHOR_MIDDLE, ANCHOR_BOTTOM),
        CreateSubElement(self, atlas, bottom_right, ANCHOR_RIGHT, ANCHOR_BOTTOM),
    }

    if self.mid_center ~= nil then
        self:SetSize(self.mid_center:GetSize())
    else
        self:SetSize(100,100)
    end
end)

function NineSlice:DebugDraw_AddSection(dbui, panel)
    NineSlice._base.DebugDraw_AddSection(self, dbui, panel)

    dbui.Spacing()
    dbui.Text("NineSlice")
    dbui.Indent() do
        local w, h = self:GetSize()
        local changed
        changed,w,h = dbui.DragFloat3("size", w, h, 0,1,50,900)
        if changed then
            self:SetSize(w,h)
        end
    end
    dbui.Unindent()
end

local function ResizeSubElement(element, w, h)
    if element == nil then
        return
    end

    local origw, origh = element:GetSize()
    element:SetSize(element.resizew and w or origw, element.resizeh and h or origh)
end

local function RepositionSubElement(element, w, h)
    if element == nil then
        return
    end
    local xpos = 0
    local ypos = 0
    if element.halign == ANCHOR_LEFT then
        xpos = -w/2 + (element.offsetX or 0)
    elseif element.halign == ANCHOR_MIDDLE then
        xpos = element.offsetX or 0
    elseif element.halign == ANCHOR_RIGHT then
        xpos = w/2 + (element.offsetX or 0)
    end
    if element.valign == ANCHOR_BOTTOM then
        ypos = -h/2 + (element.offsetY or 0)
    elseif element.valign == ANCHOR_MIDDLE then
        ypos = element.offsetY or 0
    elseif element.valign == ANCHOR_TOP then
        ypos = h/2 + (element.offsetY or 0)
    end
    element:SetPosition(xpos, ypos, 0)
end

function RescaleSubElement(element, w, h)
	if element == nil then
        return
    end

    --local origw, origh = element:GetSize()
    element:SetScale(not element.resizew and w or 1, not element.resizeh and h or 1)
end

function NineSlice:SetScale(w,h)
	--self.mid_center:SetSize(w, h)
    for i,element in ipairs(self.elements) do
        RescaleSubElement(element, w, h)
        --RepositionSubElement(element, w, h)
    end
end

function NineSlice:SetSize(w, h)
    self.mid_center:SetSize(w, h)
    for i,element in ipairs(self.elements) do
        ResizeSubElement(element, w, h)
        RepositionSubElement(element, w, h)
    end
end

function NineSlice:GetSize()
	return self.mid_center:GetSize()
end

function NineSlice:AddCrown(image, hanchor, vanchor, offsetX, offsetY)
	local crown = CreateSubElement(self, self.atlas, image, hanchor, vanchor, false, false, offsetX, offsetY)
    table.insert(self.elements, crown)
    return crown
end

function NineSlice:AddTail(image, hanchor, vanchor, offsetX, offsetY)
	self.tail = CreateSubElement(self, self.atlas, image, hanchor, vanchor, false, false, offsetX, offsetY)
    table.insert(self.elements, self.tail)
    return self.tail
end

function NineSlice:UpdateTail(hanchor, vanchor, offsetX, offsetY)
	SetupSubElement(self, self.tail, nil, nil, hanchor, vanchor, false, false, offsetX, offsetY)
	RepositionSubElement(self.tail, self.mid_center:GetSize())
end

function NineSlice:SetTint(r, g, b, a)
	self.mid_center:SetTint(r, g, b, a)
    for i,element in ipairs(self.elements) do
		element:SetTint(r, g, b, a)
	end
end

return NineSlice
