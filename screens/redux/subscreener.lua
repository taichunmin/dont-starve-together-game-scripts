local TEMPLATES = require("widgets/redux/templates")

local Subscreener = Class(function(self, owner, menu_ctor, sub_screens)
    self.screen = owner
    self.buttons = {}
    self.titles = {}
    self.sub_screens = sub_screens
    self.menu = menu_ctor(owner, self)
end)

function Subscreener:MenuButton(text, key, tooltip_text, tooltip_widget)
	local btn = TEMPLATES.MenuButton(text, function() self:OnMenuButtonSelected(key) end, tooltip_text, tooltip_widget)
    self.buttons[key] = btn
    self.titles[key] = text
    return btn
end

function Subscreener:WardrobeButton(text, key, tooltip_text, tooltip_widget)
	local btn = TEMPLATES.WardrobeButton(text, function() self:OnMenuButtonSelected(key) end, tooltip_text, tooltip_widget)
    self.buttons[key] = btn
    self.titles[key] = text
    return btn
end

function Subscreener:OnMenuButtonSelected(selection)
    self.menu:UnselectAll()
	self.buttons[selection]:Select()
	
	for _,ss in pairs(self.sub_screens) do
		ss:Hide()
	end
	self.sub_screens[selection]:Show()

    if self.screen.title and self.screen.title.small then
        self.screen.title.small:SetString(self.titles[selection])
    end

    self:_DoFocusHookups(selection)
	self.buttons[selection]:SetFocus()
end

function Subscreener:_DoFocusHookups(selection)
    -- Focus should move to the first item in the menu.
	self.menu.reverse = true

    local current_sub_screen = self.sub_screens[selection]
    self.menu:SetFocusChangeDir(MOVE_RIGHT, current_sub_screen)
    current_sub_screen:SetFocusChangeDir(MOVE_LEFT, self.menu)
end

return Subscreener
