local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local IngredientUI = require "widgets/ingredientui"
local Spinner = require "widgets/spinner"

require "widgets/widgetutil"
require "skinsutils"
local TechTree = require "techtree"

local TEASER_SCALE_TEXT = 1
local TEASER_SCALE_BTN = 1.5
local TEASER_TEXT_WIDTH = 64 * 3 + 24
local TEASER_BTN_WIDTH = TEASER_TEXT_WIDTH / TEASER_SCALE_BTN
local TEXT_WIDTH = 64 * 3 + 30

local testNewTag = false

local recipe_desc_fontSize = PLATFORM ~= "WIN32_RAIL" and 33 or 30

local RecipePopup = Class(Widget, function(self, horizontal)
    Widget._ctor(self, "Recipe Popup")

    self.smallfonts = JapaneseOnPS4()
    self.horizontal = horizontal
    self:BuildNoSpinner(horizontal)
end)

local function GetHintTextForRecipe(player, recipe)
    local validmachines = {}
    local adjusted_level = deepcopy(recipe.level)

    -- Adjust recipe's level for bonus so that the hint gives the right message
	local tech_bonus = player.replica.builder:GetTechBonuses()
	for k, v in pairs(adjusted_level) do
		adjusted_level[k] = math.max(0, v - (tech_bonus[k] or 0))
	end

    for k, v in pairs(TUNING.PROTOTYPER_TREES) do
        local canbuild = CanPrototypeRecipe(adjusted_level, v)
        if canbuild then
            table.insert(validmachines, {TREE = tostring(k), SCORE = 0})
        end
    end

    if #validmachines > 0 then
        if #validmachines == 1 then
            --There's only once machine is valid. Return that one.
            return validmachines[1].TREE
        end

        --There's more than one machine that gives the valid tech level! We have to find the "lowest" one (taking bonus into account).
        for k,v in pairs(validmachines) do
            for rk,rv in pairs(adjusted_level) do
                local prototyper_level = TUNING.PROTOTYPER_TREES[v.TREE][rk]
                if prototyper_level and (rv > 0 or prototyper_level > 0) then
                    if rv == prototyper_level then
                        --recipe level matches, add 1 to the score
                        v.SCORE = v.SCORE + 1
                    elseif rv < prototyper_level then
                        --recipe level is less than prototyper level, remove 1 per level the prototyper overshot the recipe
                        v.SCORE = v.SCORE - (prototyper_level - rv)
                    end
                end
            end
        end

        table.sort(validmachines, function(a,b) return (a.SCORE) > (b.SCORE) end)

        return validmachines[1].TREE
    end

    return "CANTRESEARCH"
end

function RecipePopup:BuildWithSpinner(horizontal)
    self:KillAllChildren()

    local hud_atlas = GetGameModeProperty("hud_atlas") or resolvefilepath(HUD_ATLAS)

    self.bg = self:AddChild(Image())
    local img = horizontal and "craftingsubmenu_fullvertical.tex" or "craftingsubmenu_fullhorizontal.tex"

    local y_offset = 0
    if horizontal then
        y_offset = -55
        self.bg:SetPosition(240,-15,0)
    else
        self.bg:SetPosition(210,16,0)
    end
    self.bg:SetTexture(hud_atlas, img)
    self.bg:SetScale(1, 1.25, 1)

    --

    self.contents = self:AddChild(Widget("contents"))
    self.contents:SetPosition(-75,0 + y_offset,0)

    self.lines = self.contents:AddChild(Widget("separators"))

    if self.smallfonts then
        self.name = self.contents:AddChild(Text(UIFONT, 40 * 0.8))
        self.desc = self.contents:AddChild(Text(BODYTEXTFONT, 33 * 0.8))
        self.desc:SetPosition(320, 20, 0)
    else
        self.name = self.contents:AddChild(Text(UIFONT, 40))
        self.desc = self.contents:AddChild(Text(BODYTEXTFONT, recipe_desc_fontSize))
        self.desc:SetPosition(320, 25, 0)
    end
    self.name:SetPosition(320, 172, 0)
    self.name:SetHAlign(ANCHOR_MIDDLE)

    -- create the background first so it displays under the lines
    self.spinner_bg = self.lines:AddChild(Image("images/hud.xml", "crafting_submenu_texture.tex"))
    self.spinner_bg:SetScale(1, 1.32, 1)
    self.spinner_bg:SetPosition(317, -68)

    self.lines.line_under_desc = self.lines:AddChild(Image("images/ui.xml", "line_horizontal_white.tex"))
    self.lines.line_under_desc:SetPosition(320, -15)
    self.lines.line_under_desc:SetTint(unpack(BROWN))

    self.ing = {}

    self.button = self.contents:AddChild(ImageButton())
    self.button:SetWhileDown(function()
        if self.recipe_held then
            DoRecipeClick(self.owner, self.recipe, self.skins_spinner.GetItem())
        end
    end)
    self.button:SetOnDown(function()
        if self.last_recipe_click and (GetStaticTime() - self.last_recipe_click) < 1 then
            self.recipe_held = true
            self.last_recipe_click = nil
        end
    end)
    self.button:SetOnClick(function()
        self.last_recipe_click = GetStaticTime()
        if not self.recipe_held then
            if not DoRecipeClick(self.owner, self.recipe, self.skins_spinner.GetItem()) then
                self.owner.HUD.controls.craftingmenu:Close()
            end
        end
        self.recipe_held = false
        Profile:SetRecipeTimestamp(self.recipe.name, self.timestamp)
        Profile:SetLastUsedSkinForItem(self.recipe.name, self.skins_spinner.GetItem())
    end)
    self.button:SetPosition(320, -155, 0)
    self.button:SetScale(.7,.7,.7)
    self.button.image:SetScale(.45, .7)

    self.skins_spinner = self.contents:AddChild(self:MakeSpinner())
    self.skins_spinner:SetPosition(307, -100)

    if horizontal and TheInput:ControllerAttached() then
        -- Put symbols showing the controls for the spinner next to the spinner buttons
        self.skins_spinner.spinner:AddControllerHints()
    end

    self.lines.line_under_spinner = self.lines:AddChild(Image("images/ui.xml", "line_horizontal_white.tex"))
    self.lines.line_under_spinner:SetPosition(320, -120)
    self.lines.line_under_spinner:SetTint(unpack(BROWN))

    self.amulet = self.contents:AddChild(Image( resolvefilepath(GetInventoryItemAtlas("greenamulet.tex")), "greenamulet.tex"))
    self.amulet:SetPosition(415, -155, 0)
    self.amulet:SetTooltip(STRINGS.GREENAMULET_TOOLTIP)

    self.teaser = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.teaser:SetPosition(320, -150, 0)
    self.teaser:Hide()
end

function RecipePopup:BuildNoSpinner(horizontal)
    self:KillAllChildren()

    self.skins_spinner = nil

    local hud_atlas = GetGameModeProperty("hud_atlas") or resolvefilepath(HUD_ATLAS)

    self.bg = self:AddChild(Image())
    local img = horizontal and "craftingsubmenu_fullvertical.tex" or "craftingsubmenu_fullhorizontal.tex"

    if horizontal then
        self.bg:SetPosition(240,40,0)
    else
        self.bg:SetPosition(210,16,0)
    end
    self.bg:SetTexture(hud_atlas, img)

    if horizontal then
        self.bg.light_box = self.bg:AddChild(Image(hud_atlas, "craftingsubmenu_litehorizontal.tex"))
        self.bg.light_box:SetPosition(0, -50)
    else
        self.bg.light_box = self.bg:AddChild(Image(hud_atlas, "craftingsubmenu_litevertical.tex"))
        self.bg.light_box:SetPosition(30, -22)
    end

    --

    self.contents = self:AddChild(Widget(""))
    self.contents:SetPosition(-75,0,0)

    if self.smallfonts then
        self.name = self.contents:AddChild(Text(UIFONT, 40 * 0.8))
        self.desc = self.contents:AddChild(Text(BODYTEXTFONT, 33 * 0.8))
        self.desc:SetPosition(320, -10, 0)
    else
        self.name = self.contents:AddChild(Text(UIFONT, 40))
        self.desc = self.contents:AddChild(Text(BODYTEXTFONT, recipe_desc_fontSize))
        self.desc:SetPosition(320, -5, 0)
    end
    self.name:SetPosition(320, 142, 0)
    self.name:SetHAlign(ANCHOR_MIDDLE)

    self.ing = {}

    self.button = self.contents:AddChild(ImageButton())
    self.button:SetScale(.7,.7,.7)
    self.button.image:SetScale(.45, .7)
    self.button:SetWhileDown(function()
        if self.recipe_held then
            DoRecipeClick(self.owner, self.recipe)
        end
    end)
    self.button:SetOnDown(function()
        if self.last_recipe_click and (GetStaticTime() - self.last_recipe_click) < 1 then
            self.recipe_held = true
            self.last_recipe_click = nil
        end
    end)
    self.button:SetOnClick(function()
        self.last_recipe_click = GetStaticTime()
        if not self.recipe_held then
            if not DoRecipeClick(self.owner, self.recipe) then
                self.owner.HUD.controls.craftingmenu:Close()
            end
        end
        self.recipe_held = false
    end)

    self.amulet = self.contents:AddChild(Image( resolvefilepath(GetInventoryItemAtlas("greenamulet.tex")), "greenamulet.tex"))
    self.amulet:SetPosition(415, -105, 0)
    self.amulet:SetTooltip(STRINGS.GREENAMULET_TOOLTIP)

    self.teaser = self.contents:AddChild(Text(BODYTEXTFONT, 28))
    self.teaser:SetPosition(320, -100, 0)
    self.teaser:Hide()
end

function RecipePopup:Refresh()
    local owner = self.owner
    if owner == nil then
        return false
    end

    local recipe = self.recipe
    local builder = owner.replica.builder
    local inventory = owner.replica.inventory

    local knows = builder:KnowsRecipe(recipe)
    local buffered = builder:IsBuildBuffered(recipe.name)
    local can_build = buffered or builder:HasIngredients(recipe)
    local tech_level = builder:GetTechTrees()
    local should_hint = not knows and ShouldHintRecipe(recipe.level, tech_level) and not CanPrototypeRecipe(recipe.level, tech_level)

    self.skins_list = self:GetSkinsList()

    self.skins_options = self:GetSkinOptions() -- In offline mode, this will return the default option and nothing else

    if #self.skins_options == 1 then
        -- No skins available, so use the original version of this popup
        if self.skins_spinner ~= nil then
            self:BuildNoSpinner(self.horizontal)
        end
    else
        --Skins are available, use the spinner version of this popup
        if self.skins_spinner == nil then
            self:BuildWithSpinner(self.horizontal)
        end

        self.skins_spinner.spinner:SetOptions(self.skins_options)
        local last_skin = Profile:GetLastUsedSkinForItem(recipe.name)
        if last_skin then
            self.skins_spinner.spinner:SetSelectedIndex(self:GetIndexForSkin(last_skin) or 1)
        end
    end

    self.name:SetTruncatedString(STRINGS.NAMES[string.upper(self.recipe.name)] or STRINGS.NAMES[string.upper(self.recipe.product)], TEXT_WIDTH+38, nil, false)
    self.desc:SetMultilineTruncatedString(STRINGS.RECIPE_DESC[string.upper(self.recipe.description or self.recipe.product)], 2, TEXT_WIDTH, self.smallfonts and 40 or 33, true)

    for i, v in ipairs(self.ing) do
        v:Kill()
    end

    self.ing = {}

    local num =
        (recipe.ingredients ~= nil and #recipe.ingredients or 0) +
        (recipe.character_ingredients ~= nil and #recipe.character_ingredients or 0) +
        (recipe.tech_ingredients ~= nil and #recipe.tech_ingredients or 0)
    local w = 64
    local div = 10
    local half_div = div * .5
    local offset = 315 --center
    if num > 1 then
        offset = offset - (w *.5 + half_div) * (num - 1)
    end

    local hint_tech_ingredient = nil

    for i, v in ipairs(recipe.tech_ingredients) do
        if v.type:sub(-9) == "_material" then
            local has, level = builder:HasTechIngredient(v)
            local ing = self.contents:AddChild(IngredientUI(v:GetAtlas(), v:GetImage(), nil, nil, has, STRINGS.NAMES[string.upper(v.type)], owner, v.type))
            if GetGameModeProperty("icons_use_cc") then
                ing.ing:SetEffect("shaders/ui_cc.ksh")
            end
            if num > 1 and #self.ing > 0 then
                offset = offset + half_div
            end
            ing:SetPosition(Vector3(offset, self.skins_spinner ~= nil and 110 or 80, 0))
            offset = offset + w + half_div
            table.insert(self.ing, ing)
            if not has and hint_tech_ingredient == nil then
                hint_tech_ingredient = v.type:sub(1, -10):upper()
            end
        end
    end

    for i, v in ipairs(recipe.ingredients) do
        local has, num_found = inventory:Has(v.type, math.max(1, RoundBiasedUp(v.amount * builder:IngredientMod())), true)
        local ing = self.contents:AddChild(IngredientUI(v:GetAtlas(), v:GetImage(), v.amount ~= 0 and v.amount or nil, num_found, has, STRINGS.NAMES[string.upper(v.type)], owner, v.type))
        if GetGameModeProperty("icons_use_cc") then
            ing.ing:SetEffect("shaders/ui_cc.ksh")
        end
        if num > 1 and #self.ing > 0 then
            offset = offset + half_div
        end
        ing:SetPosition(Vector3(offset, self.skins_spinner ~= nil and 110 or 80, 0))
        offset = offset + w + half_div
        table.insert(self.ing, ing)
    end

    for i, v in ipairs(recipe.character_ingredients) do
        --#BDOIG - does this need to listen for deltas and change while menu is open?
        --V2C: yes, but the entire craft tabs does. (will be added there)
        local has, amount = builder:HasCharacterIngredient(v)

		if v.type == CHARACTER_INGREDIENT.HEALTH and owner:HasTag("health_as_oldage") then
			v = Ingredient(CHARACTER_INGREDIENT.OLDAGE, math.ceil(v.amount * TUNING.OLDAGE_HEALTH_SCALE))
		end
        local ing = self.contents:AddChild(IngredientUI(v:GetAtlas(), v:GetImage(), v.amount, amount, has, STRINGS.NAMES[string.upper(v.type)], owner, v.type))
        if GetGameModeProperty("icons_use_cc") then
            ing.ing:SetEffect("shaders/ui_cc.ksh")
        end
        if num > 1 and #self.ing > 0 then
            offset = offset + half_div
        end
        ing:SetPosition(Vector3(offset, self.skins_spinner ~= nil and 110 or 80, 0))
        offset = offset + w + half_div
        table.insert(self.ing, ing)
    end

    local equippedBody = inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    local showamulet = equippedBody and equippedBody.prefab == "greenamulet"

    if should_hint or hint_tech_ingredient ~= nil then
        self.button:Hide()

        local str
        if should_hint then
            local hint_text =
			{
                ["SCIENCEMACHINE"] = "NEEDSCIENCEMACHINE",
                ["ALCHEMYMACHINE"] = "NEEDALCHEMYENGINE",
                ["SHADOWMANIPULATOR"] = "NEEDSHADOWMANIPULATOR",
                ["PRESTIHATITATOR"] = "NEEDPRESTIHATITATOR",
                ["CANTRESEARCH"] = "CANTRESEARCH",
                ["ANCIENTALTAR_HIGH"] = "NEEDSANCIENT_FOUR",
                ["SPIDERCRAFT"] = "NEEDSSPIDERFRIENDSHIP",
                ["ROBOTMODULECRAFT"] = "NEEDSCREATURESCANNING",
            }
            local prototyper_tree = GetHintTextForRecipe(owner, recipe)
            str = STRINGS.UI.CRAFTING[hint_text[prototyper_tree] or ("NEEDS"..prototyper_tree)]
        else
            str = STRINGS.UI.CRAFTING.NEEDSTECH[hint_tech_ingredient]
        end
        self.teaser:SetScale(TEASER_SCALE_TEXT)
        self.teaser:SetMultilineTruncatedString(str, 3, TEASER_TEXT_WIDTH, 38, true)
        self.teaser:Show()
        showamulet = false
    elseif TheNet:IsServerPaused() then
        self.button:Hide()

        self.teaser:SetScale(TEASER_SCALE_TEXT)
        self.teaser:SetMultilineTruncatedString(STRINGS.UI.CRAFTING.GAMEPAUSED, 3, TEASER_TEXT_WIDTH, 38, true)
        self.teaser:Show()
    else
        self.teaser:Hide()

        local buttonstr =
            (not (knows or recipe.nounlock) and STRINGS.UI.CRAFTING.PROTOTYPE) or
            (buffered and STRINGS.UI.CRAFTING.PLACE) or
			(recipe.actionstr ~= nil and STRINGS.UI.CRAFTING.RECIPEACTION[recipe.actionstr]) or
            STRINGS.UI.CRAFTING.TABACTION[recipe.tab.str] or
            STRINGS.UI.CRAFTING.BUILD

        if TheInput:ControllerAttached() then
            self.button:Hide()
            self.teaser:Show()

            if can_build then
                self.teaser:SetScale(TEASER_SCALE_BTN)
                self.teaser:SetTruncatedString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_ACCEPT).." "..buttonstr, TEASER_BTN_WIDTH, 26, true)
            else
                self.teaser:SetScale(TEASER_SCALE_TEXT)
                self.teaser:SetMultilineTruncatedString((STRINGS.UI.CRAFTING.TABNEEDSTUFF or {})[recipe.tab.str] or STRINGS.UI.CRAFTING.NEEDSTUFF, 3, TEASER_TEXT_WIDTH, 38, true)
            end
        else
            self.button:Show()
            if self.skins_spinner ~= nil then
                self.button:SetPosition(320, -155, 0)
            else
                self.button:SetPosition(320, -105, 0)
            end
            self.button:SetScale(1,1,1)

            self.button:SetText(buttonstr)
            if can_build then
                self.button:Enable()
            else
                self.button:Disable()
            end
        end
    end

    if showamulet then
        self.amulet:Show()
    else
        self.amulet:Hide()
    end

    -- update new tags
    if self.skins_spinner then
        self.skins_spinner.spinner:Changed()
    end
end

function RecipePopup:SetRecipe(recipe, owner)
    self.recipe = recipe
    self.owner = owner
    self:Refresh()
end

function RecipePopup:GetSkinAtIndex(idx)
    return idx == 1 and self.recipe.name or self.skins_list[idx - 1].item
end

function RecipePopup:GetIndexForSkin(skin)
    for i=1, #self.skins_list do
        if self.skins_list[i].item == skin then
            return i + 1
        end
    end

    return 1
end

function RecipePopup:GetSkinsList()
    if not self.timestamp then self.timestamp = -10000 end

    --Note(Peter): This could get a speed improvement by passing in self.recipe.name into a c-side inventory check, and then add the PREFAB_SKINS data to c-side
    -- so that we don't have to walk the whole inventory for each prefab for each item_type in PREFAB_SKINS[self.recipe.name]
    self.skins_list = {}
    if self.recipe and PREFAB_SKINS[self.recipe.product] then
        for _,item_type in pairs(PREFAB_SKINS[self.recipe.product]) do
            local has_item, modified_time = TheInventory:CheckOwnershipGetLatest(item_type)
            if has_item then
                local data  = {}
                data.type = type
                data.item = item_type
                data.timestamp = modified_time
                table.insert(self.skins_list, data)

                if data.timestamp > self.timestamp then
                    self.timestamp = data.timestamp
                end
            end
        end
    end

    return self.skins_list
end

function RecipePopup:GetSkinOptions()
    local skin_options = {}

    table.insert(skin_options,
    {
        text = STRINGS.UI.CRAFTING.DEFAULT,
        data = nil,
        colour = DEFAULT_SKIN_COLOR,
        new_indicator = false,
        image = {GetInventoryItemAtlas(self.recipe.product..".tex"), self.recipe.product..".tex", "default.tex"},
    })

    local recipe_timestamp = Profile:GetRecipeTimestamp(self.recipe.product)
    --print(self.recipe.product, "Recipe timestamp is ", recipe_timestamp)
    if self.skins_list ~= nil and self.recipe.chooseskin == nil and TheNet:IsOnlineMode() then
        for which = 1, #self.skins_list do
            local item = self.skins_list[which].item

            local colour = GetColorForItem(item)
            local text_name = GetSkinName(item)
            local image_name = GetSkinInvIconName(item)
            local new_indicator = not self.skins_list[which].timestamp or (self.skins_list[which].timestamp > recipe_timestamp)

            table.insert(skin_options,
            {
                text = text_name,
                data = nil,
                colour = colour,
                new_indicator = new_indicator,
                image = {GetInventoryItemAtlas(image_name..".tex"), image_name..".tex" or "default.tex", "default.tex"},
            })
        end

    else
        self.spinner_empty = true
    end

    return skin_options
end

function RecipePopup:MakeSpinner()
    local spinner_group = Widget("spinner group")

    local textures = {
        arrow_left_normal = "crafting_inventory_arrow_l_idle.tex",
        arrow_left_over = "crafting_inventory_arrow_l_hl.tex",
        arrow_left_disabled = "arrow_left_disabled.tex",
        arrow_left_down = "crafting_inventory_arrow_l_hl.tex",
        arrow_right_normal = "crafting_inventory_arrow_r_idle.tex",
        arrow_right_over = "crafting_inventory_arrow_r_hl.tex",
        arrow_right_disabled = "arrow_right_disabled.tex",
        arrow_right_down = "crafting_inventory_arrow_r_hl.tex",
        bg_middle = "blank.tex",
        bg_middle_focus = "blank.tex", --"box_2.tex",
        bg_middle_changing = "blank.tex",
        bg_end = "blank.tex",
        bg_end_focus = "blank.tex",
        bg_end_changing = "blank.tex",
    }

    local spinner_width = 220
    local spinner_height = 68

    --local bg = spinner_group:AddChild(Image("images/ui.xml", "single_option_bg.tex"))
    --bg:SetSize(220, 30)
    --bg:SetPosition(10, 4, 0)

    spinner_group.spinner = spinner_group:AddChild(Spinner( {}, spinner_width, nil, {font=UIFONT, size=28}, nil, nil, textures, true, 200, nil))
    spinner_group.spinner:SetPosition(10, 46, 0)
    spinner_group.spinner.text:SetPosition(0, -44)
    spinner_group.spinner.fgimage:SetScale(.9)
    spinner_group.spinner.fgimage:SetPosition(0, 6)
    spinner_group.spinner.background:ScaleToSize(spinner_width + 2, spinner_height)
    spinner_group.spinner.background:SetPosition(0, 6)

    spinner_group.new_tag = spinner_group:AddChild(Image("images/ui.xml", "new_label.tex"))
    spinner_group.new_tag:SetScale(.8)
    spinner_group.new_tag:SetPosition(-45, 60)
    --spinner_group.new_tag:SetPosition(60, 60)

    spinner_group.spinner:SetOnChangedFn(function()
                                                    local which = spinner_group.spinner:GetSelectedIndex()
                                                    if which > 1 then
                                                      if self.skins_options[which].new_indicator or testNewTag then
                                                        spinner_group.new_tag:Show()
                                                      else
                                                        spinner_group.new_tag:Hide()
                                                      end
                                                    else
                                                        spinner_group.new_tag:Hide()
                                                    end
                                        end)

    spinner_group.GetItem =
        function()
            local which = spinner_group.spinner:GetSelectedIndex()
            if which > 1 then
                local name = self.skins_list[which - 1].item
                return name
            else
                return self.recipe.name
            end
        end

    spinner_group.OnControl = function(self, control, down) spinner_group.spinner:OnControl(control, down) end

    spinner_group.focus_forward = spinner_group.spinner

    return spinner_group

end

function RecipePopup:OnControl(control, down)
    if RecipePopup._base.OnControl(self, control, down) then return true end

    -- This function gets called by craftslot when left or right d-pad buttons are pushed. Pass those through to the
    -- spinner.
    if self.skins_spinner ~= nil and TheInput:ControllerAttached() then
        self.skins_spinner:OnControl(control, down)
    end
end

return RecipePopup
