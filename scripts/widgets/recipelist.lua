local Widget = require "widgets/widget"

local TEMPLATES = require "widgets/templates"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Spinner = require "widgets/spinner"

require "stringutil"
require "skinstradeutils"

local DEBUG_MODE = BRANCH == "dev"

local COUNTER_HEIGHT = -135
local MAX_LINES = 5
local TOP_Y = 225
local LINE_HEIGHT = 28
local LEFT_COLUMN = -90
local RIGHT_COLUMN = 90
local TEXT_WIDTH = 215

local DAYS_TEXT_POSITION = 35
local DAYS_TEXT_NO_ICON_POSITION = 22

local FONT = BUTTONFONT
local FONTSIZE = 20

local spinner_lean_images = {
	arrow_left_normal = "crafting_inventory_arrow_l_idle.tex",
	arrow_left_over = "crafting_inventory_arrow_l_hl.tex",
	arrow_left_disabled = "arrow_left_disabled.tex",
	arrow_left_down = "crafting_inventory_arrow_l_idle.tex",
	arrow_right_normal = "crafting_inventory_arrow_r_idle.tex",
	arrow_right_over = "crafting_inventory_arrow_r_hl.tex",
	arrow_right_disabled = "arrow_right_disabled.tex",
	arrow_right_down = "crafting_inventory_arrow_r_idle.tex",
	bg_middle = "blank.tex",
	bg_middle_focus = "blank.tex",
	bg_middle_changing = "blank.tex",
	bg_end = "blank.tex",
	bg_end_focus = "blank.tex",
	bg_end_changing = "blank.tex",
}


-- A widget that displays a list of recipes. Used by the Trade Inn to display the weekly specials.
local RecipeList = Class(Widget, function(self, clickFn)
	Widget._ctor(self, "RecipeList")

	self.root = self:AddChild(Widget("specials_container"))
	self.root:SetPosition(-15, -40)

	self.clickFn = clickFn

	self:DoInit()
end)

function RecipeList:DoInit()
	self.days_remaining = self.root:AddChild(Widget("days-remaining-container"))
	self.days_remaining:SetPosition(0, COUNTER_HEIGHT, 0)

	self.days_remaining.days_text = self.days_remaining:AddChild(Text(BUTTONFONT, 24, STRINGS.UI.TRADESCREEN.DAYS_REMAINING, WHITE))
    self.days_remaining.days_text:SetPosition(DAYS_TEXT_POSITION, 0, 0)

    self.days_remaining.tag = self.days_remaining:AddChild(Image("images/tradescreen.xml", "number_tag.tex"))
    self.days_remaining.tag:SetScale(.24)
    self.days_remaining.tag:SetPosition(-35, 5, 0)

    self.days_remaining.days = self.days_remaining:AddChild(Text(NEWFONT_OUTLINE, 24, "12", RED))
    self.days_remaining.days:SetPosition(-35, 2, 0)

    self.recipes_spinner = self.root:AddChild(Spinner( {}, TEXT_WIDTH, nil, {font=BUTTONFONT, size=24}, nil, nil, spinner_lean_images, true, 200, 50))
    self.recipes_spinner:SetOnChangedFn(function()
											local selectedRecipe = self.data[self.recipes_spinner:GetSelectedIndex()]
											self:DisplayData(selectedRecipe)
											if selectedRecipe ~= nil then
	    										if self.clickFn then
	    											self.clickFn(selectedRecipe or {})
	    										end
	    									end
	    								end)
	self.recipes_spinner:SetPosition(15, TOP_Y + 10, 0)
	self.recipes_spinner:Layout()

	self.specials_root = self.root:AddChild(Widget("specials-container"))
	self.specials = {}
    for i=1,MAX_LINES do
    	self.specials[i] = self.specials_root:AddChild(TEMPLATES.ItemImageText("body", "body_default1", .4, FONT, FONTSIZE, "", BLACK, TEXT_WIDTH))
    	self.specials[i]:SetPosition(0, TOP_Y - i*LINE_HEIGHT, 0)

    	self.specials[i]:Hide()
    end
end

function RecipeList:SetData(recipes)
	self.data = recipes or {}


	local options = {}
	for k,v in pairs(recipes) do
		local str = STRINGS.UI.TRADESCREEN.RECIPE_TITLE
		str = str:gsub("<rarity>", v.Restrictions[1].Rarity)
		table.insert(options, {text=str} )
	end
	if #recipes == 0 then
		table.insert(options, {text=STRINGS.UI.TRADESCREEN.NO_RECIPES} )
	end
	self.recipes_spinner:SetOptions( options )

	self.recipes_spinner:SetSelectedIndex(1) --we've got new data, go back to the start of the list
	self.recipes_spinner:Changed()
end

function RecipeList:GetRecipeName()
	local selectedRecipe = self.data[self.recipes_spinner:GetSelectedIndex()]
	return selectedRecipe.RecipeName
end

function RecipeList:GetRecipeIndex()
	return self.recipes_spinner:GetSelectedIndex()
end


local function are_restrictions_same( res_data, res )
	if res_data == nil then
		return false
	end

	local type_matches = res_data.item_type == res.ItemType
	local rarity_matches = res_data.rarity == res.Rarity
	local tags_match = #res_data.tags == #res.Tags
	if tags_match then
		--same size, now check the contents
		for i=1,#res.Tags do
			if res_data.tags[i] ~= res.Tags[i] then
				tags_match = false
			end
		end
	end

	return type_matches and rarity_matches and tags_match
end

-- Combine identical recipe ingredients into one line
local function coalesce_recipes(recipe_data)
	local res_data = {}
	local last_idx = 0
	for _,restriction in pairs(recipe_data.Restrictions) do
		if are_restrictions_same( res_data[last_idx], restriction ) then
			res_data[last_idx].number = res_data[last_idx].number + 1

			-- Store the index in the recipe so we can find the corresponding line on the display later
			restriction.coalesced_index = last_idx
		else
			local data = {}
			data.item_type = restriction.ItemType
			data.rarity = restriction.Rarity
			data.tags = restriction.Tags
			data.number = 1

			data.type = "empty"
			if #data.tags > 0 then
				data.type = GetTypeFromTag(data.tags[1])
			end

			table.insert( res_data, data )
			last_idx = last_idx + 1

			-- Store the index in the recipe so we can find the corresponding line on the display later
			restriction.coalesced_index = last_idx
		end
	end

	return res_data

end

function RecipeList:DisplayData(recipe_data)
	if recipe_data ~= nil then
		--print( "DisplayData for", recipe_data.RecipeName )

		self.num_needed = {} -- this stores the number of items needed to match each recipe line

		--Coalesce recipe restrictions
		local res_data = coalesce_recipes(recipe_data)

		-- local vars for getting the max string width so we can center the ingredients list
		local temp = Text(FONT, FONTSIZE, "")
		local maxwidth = 0

		--Display coalesced recipe data/restrictions
		for i=1,MAX_LINES do
			local coalesce_res = res_data[i]
			if coalesce_res ~= nil then
				local str, show_icon = self:BuildString(coalesce_res)

				self.specials[i].text:SetString(str)

				temp:SetString(str)
				local w,h = temp:GetRegionSize()
				if w > maxwidth then
					maxwidth = w
				end

				if show_icon then
					self.specials[i].icon:SetItem(coalesce_res.type or "", coalesce_res.item_type, nil, nil)
				else
					self.specials[i].icon:ClearFrame()
				end

				-- set rarity for frames that are empty or contain default icons
				self.specials[i].icon:SetItemRarity(coalesce_res.rarity)

				self.specials[i]:Show()
			else
				self.specials[i]:Hide()
			end
		end

		-- center the ingredients list
		self.specials_root:SetPosition(-.5*(maxwidth - 30), 0, 0)

		temp:Kill()

		local num_days = math.floor( recipe_data.TimeLeft / (60*60*24) )
		self.days_remaining.days:SetString(""..num_days)

		self.days_remaining.days:Show()
		self.days_remaining.tag:Show()
		self.days_remaining.days_text:SetPosition(DAYS_TEXT_POSITION, 0, 0)

		if num_days == 0 then
			self.days_remaining.days:Hide()
			self.days_remaining.tag:Hide()
			self.days_remaining.days_text:SetPosition(DAYS_TEXT_NO_ICON_POSITION, 0, 0)
			local num_hours = math.floor( recipe_data.TimeLeft / (60*60) )
			if num_hours > 6 then
				self.days_remaining.days_text:SetString(STRINGS.UI.TRADESCREEN.LESS_THAN_DAY)
			else
				self.days_remaining.days_text:SetString(STRINGS.UI.TRADESCREEN.ENDING_SOON)
			end
		elseif num_days == 1 then
			self.days_remaining.days_text:SetString(STRINGS.UI.TRADESCREEN.DAY_REMAINING)
		else
			self.days_remaining.days_text:SetString(STRINGS.UI.TRADESCREEN.DAYS_REMAINING)
		end
	else
		self.days_remaining.days:Hide()
		self.days_remaining.tag:Hide()
		self.days_remaining.days_text:SetString("")
	end
end

function RecipeList:BuildString(data)
	local show_icon = true
 	local str = ""
	if data.item_type ~= "" then
		str = STRINGS.UI.TRADESCREEN.RECIPE_INGREDIENT_ITEM
		str = string.gsub(str, "<item>",  GetSkinName(data.item_type))
 		local colour = GetColourFromColourTag(ITEM_COLOURS[data.item_type])
		str = string.gsub(str, "<colour>", STRINGS.UI.COLOUR[colour] .. " ")
		show_icon = true
	elseif #data.tags > 0 then
		str = STRINGS.UI.TRADESCREEN.RECIPE_INGREDIENT_TAGS
		local tags = ""
		for k,v in pairs(data.tags) do
    		local type = GetTypeFromTag(v)
    		if type ~= nil then
				tags = tags .. STRINGS.UI.TRADESCREEN[string.upper(type)] .. " "
			else
				if COLOURS_TAGS[tag] then
					tags = GetColourFromColourTag(tag) .. " "
				end
			end
		end
		str = string.gsub(str, "<tags>", tags)
		show_icon = true
	else
		str = STRINGS.UI.TRADESCREEN.RECIPE_INGREDIENT_RARITY
		show_icon = false
	end

	str = string.gsub(str, "<number>", data.number and ""..data.number or "")
	str = string.gsub(str, "<plural>", data.number > 1 and "s" or "" )
	str = string.gsub(str, "<rarity>", STRINGS.UI.RARITY[data.rarity])

	return str, show_icon
end


-- Grey out recipe ingredients that have been selected already
function RecipeList:UpdateSelectedIngredients(selected_items)
	local recipe_data = self.data[self.recipes_spinner:GetSelectedIndex()]

	for i = 1, #self.specials do
		self.specials[i]:SetChecked(false)
	end

	if #selected_items <= 0 then
		return
	end

	-- Figure out which recipe lines are satisfied (in the un-coalesced recipe)
	local satisfied_restrictions = GetSatisfiedRestrictions(recipe_data, selected_items)

	local function already_satisfied(display_index) -- helper function, determines whether a coalesced line is satisfied or not
		for k,v in pairs(recipe_data.Restrictions) do
			if v.coalesced_index == display_index and
				not satisfied_restrictions[k] then
				return false
			end
		end

		return true
	end

	-- Change the displayed lines if they are satisfied
	for k,v in pairs(self.specials) do
		if already_satisfied(k) then
			self.specials[k]:SetChecked(true)
		end
	end
end

function RecipeList:OnControl(control, down)
	if RecipeList._base.OnControl(self, control, down) then return true end

	if down then
		if control == CONTROL_PREVVALUE then
			self.recipes_spinner:Prev()
			return true
		elseif control == CONTROL_NEXTVALUE then
			self.recipes_spinner:Next()
			return true
		end
	end
end

function RecipeList:SetHintStrings(prev, next)
	self.prev_hint = prev
	self.next_hint = next
end


function RecipeList:GetHelpText()
	local controller_id = TheInput:GetControllerID()

	local t = {}
	if self.prev_hint and self.next_hint then
		if self.recipes_spinner.leftimage.enabled and self.recipes_spinner.rightimage.enabled then
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PREVVALUE, false, false) .. "/"
							.. TheInput:GetLocalizedControl(controller_id, CONTROL_NEXTVALUE, false, false) .." "
							.. self.prev_hint .. "/" .. self.next_hint)
		elseif self.recipes_spinner.leftimage.enabled then
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_PREVVALUE, false, false) .. " " .. self.prev_hint)
		else
			table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_NEXTVALUE, false, false) .. " " .. self.next_hint)
		end
	end

	return table.concat(t, "  ")

end

return RecipeList