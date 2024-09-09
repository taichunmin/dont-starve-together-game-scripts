
local Widget = require "widgets/widget"
local SkillTreeWidget = require "widgets/redux/skilltreewidget"

local SkillTreePanel = Class(Widget, function(self, parent_screen)
    Widget._ctor(self, "SkillTreePanel")

    self.root = self:AddChild(Widget("ROOT"))

    self.root:SetPosition(0, -15)

	--TheCookbook:ClearFilters()

	self.book = self.root:AddChild(SkillTreeWidget(self))

    self.focus_forward = self.book
end)

return SkillTreePanel
