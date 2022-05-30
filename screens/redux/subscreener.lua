local TEMPLATES = require("widgets/redux/templates")

require("util")

local Subscreener = Class(function(self, owner, menu_ctor, sub_screens)
    self.screen = owner
    self.buttons = {}
    self.titles = {}
    self.sub_screens = sub_screens
    self.menu = menu_ctor(owner, self)
    self.active_key = nil

    self.ordered_keys = self:_CreatedOrderedKeyList()
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

function Subscreener:WardrobeButtonMinimal(key)
	local btn = TEMPLATES.WardrobeButtonMinimal(function() self:OnMenuButtonSelected(key) end)

    self.buttons[key] = btn
    return btn
end

-- Interop with a custom Menu container. Must include an additional
-- item in each element of menu_items: key. Matches the value passed to
-- OnMenuButtonSelected.
function Subscreener:MenuContainer(menu_ctor, menu_items)
    -- Notify the container.
    self:SetPostMenuSelectionAction(function(selection)
        self.menu_container:SelectButton(self:_FindOrderedKeyIndex(selection))
    end)

    -- Stomp callbacks with our own that notifies the container.
    for i,item in ipairs(menu_items) do
        assert(item.cb == nil, "Don't use cb with MenuContainer. It will be ignored.")
        local key = menu_items[i].key
        item.cb = function() self:OnMenuButtonSelected(key) end
    end

    self.menu_container = menu_ctor(menu_items)
    local menu = self.menu_container.menu

    -- Hook up buttons to our subscreens.
    for i,w in ipairs(menu.items) do
        local key = menu_items[i].key
        self.buttons[key] = w
        self.titles[key] = menu_items[i].text
    end

    -- User needs to AddChild the menu_container.
    return self.menu_container
end

function Subscreener:SetPostMenuSelectionAction(fn)
    self.post_menu_selection_fn = fn
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
    -- Anything may be triggering selection, so only change focus if it would
    -- go somewhere visible.
    if self.buttons[selection]:IsVisible() then
        self.buttons[selection]:SetFocus()
    end

    self.active_key = selection

    if self.post_menu_selection_fn then
        self.post_menu_selection_fn(selection)
    end
end

function Subscreener:GetActiveSubscreenFn()
    return function()
        return self.sub_screens[self.active_key]
    end
end

function Subscreener:_DoFocusHookups(selection)
    -- Focus should move to the first item in the menu.
	self.menu.reverse = true

    local to_menu,to_subscreen = MOVE_LEFT, MOVE_RIGHT
    if self.menu.horizontal then
        to_menu,to_subscreen = MOVE_UP, MOVE_DOWN
    end

    local current_sub_screen = self.sub_screens[selection]
    self.menu:SetFocusChangeDir(to_subscreen, current_sub_screen)
    current_sub_screen:SetFocusChangeDir(to_menu, self.menu_container or self.menu)
end

function Subscreener:_CreatedOrderedKeyList()
    local btn_indexes = {}
    for i,btn in ipairs(self.menu.items) do
        btn_indexes[btn] = i
    end
    local ordered_keys = table.getkeys(self.buttons)
    table.sort(ordered_keys, function(a,b)
        local btn_a = self.buttons[a]
        local btn_b = self.buttons[b]
        return btn_indexes[btn_a] < btn_indexes[btn_b]
    end)
    return ordered_keys
end

function Subscreener:_FindOrderedKeyIndex(current_key)
    for i,key in ipairs(self.ordered_keys) do
        if current_key == key then
            return i
        end
    end
    return nil
end

-- Use this to emulate next/prev:
--      subscreener:OnMenuButtonSelected(subscreener:GetKeyRelativeToCurrent(1))
function Subscreener:GetKeyRelativeToCurrent(increment)
    local current_index = self:_FindOrderedKeyIndex(self.active_key)
    return circular_index(self.ordered_keys, current_index + increment)
end

return Subscreener
