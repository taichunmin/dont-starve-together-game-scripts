local OvalPortrait = require "widgets/redux/ovalportrait"
local TEMPLATES = require "widgets/redux/templates"
local Widget = require "widgets/widget"


-- A character selection grid with a portrait for the focused character.
-- Positioned relative to the portrait.
local CharacterSelect = Class(Widget, function(self, owner, character_widget_ctor, character_widget_size, character_description_getter_fn, default_character, cbPortraitHighlighted, cbPortraitSelected, additionalCharacters, scrollbar_offset, custom_character_details_widget)
    self.owner = owner
	Widget._ctor(self, "CharacterSelect")

	self.OnPortraitHighlighted = cbPortraitHighlighted
	self.OnPortraitSelected = cbPortraitSelected

    self.characters = self:_BuildCharactersList(additionalCharacters or {})

    self.grid_columns = 5
    self.character_grid = self:AddChild(self:_BuildCharacterGrid(self.characters, character_widget_ctor, character_widget_size, scrollbar_offset))
    -- Layout is relative to oval portrait since it usually anchors the grid to
    -- the right side of the screen. Portrait is where next grid object would
    -- go plus a bit more because portrait is larger than grid items.
    local w,h = self.character_grid:GetScrollRegionSize()
    self.character_grid:SetPosition(w * -0.8, h * -0.2)

    self.selectedportrait = self:AddChild(custom_character_details_widget ~= nil and custom_character_details_widget(default_character) or OvalPortrait(default_character, character_description_getter_fn))

    self.focus_forward = self.character_grid
end)

function CharacterSelect:_BuildCharactersList(additionalCharacters)
    local active_characters = ExceptionArrays(GetActiveCharacterList(), MODCHARACTEREXCEPTIONS_DST)

    local characters = {}
    for _,hero in ipairs(active_characters) do
        if TheNet:IsOnlineMode() or not IsRestrictedCharacter( hero ) then
            table.insert(characters, hero)
        end
    end

	for _,hero in ipairs(additionalCharacters) do
		table.insert(characters, hero)
    end
    return characters
end

function CharacterSelect:_BuildCharacterGrid(characters, character_widget_ctor, character_widget_size, scrollbar_offset)
    local function ScrollWidgetsCtor(context, index)
        local w = Widget("CharacterSelect-cell-".. index)
        local function OnPortraitFocused(is_enabled)
            if is_enabled and w.face.herocharacter then
                self.selectedportrait:SetPortrait(w.face.herocharacter)
                if self.OnPortraitHighlighted ~= nil then
                    self.OnPortraitHighlighted(w.face.herocharacter)
                end
                self.character_grid:OnWidgetFocus(w)
            end
        end
        local function OnPortraitClicked()
            if w.face.herocharacter then
                self.OnPortraitSelected(w.face.herocharacter)
            end
        end
        -- Using a valid character to silence load errors.
        w.face = w:AddChild(character_widget_ctor("wilson", OnPortraitFocused, OnPortraitClicked))
        w.focus_forward = w.face
        return w
    end
    local function ScrollWidgetApply(context, widget, data, index)
        if data then
            if widget.data ~= data then
                widget.data = data
                widget.face:SetCharacter(data)
                widget.face:Show()
            end
        else
            widget.face:Hide()
        end
    end

    local grid = TEMPLATES.ScrollingGrid(
        characters,
        {
            context = {},
            widget_width  = character_widget_size*0.85,
            widget_height = character_widget_size,
            num_visible_rows = 4,
            num_columns      = self.grid_columns,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ScrollWidgetApply,
            scrollbar_offset = scrollbar_offset
        })

    return grid
end

function CharacterSelect:_GetGrid()
    return self.character_grid.list_root.grid
end

function CharacterSelect:GetCharacter()
	return self.selectedportrait.currentcharacter
end

function CharacterSelect:RefocusCharacter(last_character)
	if last_character == self.selectedportrait.currentcharacter then
		return
	end

    local grid = self:_GetGrid()
    local slot_c,slot_r = grid:FindItemSlot(
        function(a)
            return a.face.herocharacter == last_character
        end)

    if slot_c and slot_r then
        local hero_slot = grid:GetItemInSlot(slot_c,slot_r)
        if hero_slot then
            hero_slot:SetFocus()
        end
    end
end

function CharacterSelect:RefreshInventory()
    local grid = self:_GetGrid()
    for c = 1, grid.cols do
        for r = 1, grid.rows do
            local item = grid:GetItemInSlot(c,r)
            if item and item.face.RefreshInventory then
                item.face:RefreshInventory()
            end
        end
    end
end

return CharacterSelect
