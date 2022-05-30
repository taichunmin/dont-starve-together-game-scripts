
local Widget = require "widgets/widget"
local CookbookWidget = require "widgets/redux/cookbookwidget"

local CookbookPanel = Class(Widget, function(self, parent_screen)
    Widget._ctor(self, "CookbookPanel")

    self.root = self:AddChild(Widget("ROOT"))

    self.root:SetPosition(0, -15)

	TheCookbook:ClearFilters()

	self.book = self.root:AddChild(CookbookWidget(self))

    self.focus_forward = self.book
end)

return CookbookPanel
