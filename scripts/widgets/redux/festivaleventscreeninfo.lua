local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local TEMPLATES = require "widgets/redux/templates"

local FestivalEventScreenInfo = Class(Widget, function(self, atlas, image, str, url)
	Widget._ctor(self, "FestivalEventScreenInfo")

	local image = self:AddChild(Image(atlas, image))
	image:SetScale(0.7, 0.7)
	image:SetPosition(0, 0)
	image:SetClickable(false)

	if str ~= nil then
		local title = self:AddChild(Text(HEADERFONT, 22, "", UICOLOURS.HIGHLIGHT_GOLD))
		title:SetMultilineTruncatedString(str, 2, 200)
		title:SetPosition(0, -90)
	end

	self.button = self:AddChild(TEMPLATES.StandardButton(function() VisitURL(url) end, STRINGS.UI.MODSSCREEN.MODLINK_MOREINFO))
	self.button:SetScale(0.5, 0.5)
	self.button:SetPosition(0, -130)

	if self.button ~= nil then
		self.focus_forward = self.button
	end
end)

return FestivalEventScreenInfo