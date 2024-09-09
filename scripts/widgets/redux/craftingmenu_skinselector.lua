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

local spinner_font = {font=UIFONT, size=26}

local SCALE = 0.85

local FORCE_NEWTAG = false

local SkinSelector = Class(Widget, function(self, recipe, owner, skin_name)
    Widget._ctor(self, "Crafting Menu Skins Selector")

	self.recipe = recipe
	self.owner = owner

    self.skins_list = self:GetSkinsList()
    self.skins_options = self:GetSkinOptions()

	self:SetScale(SCALE)

    local spinner_width = 220
    local spinner_height = 110

    self.spinner_bg = self:AddChild(Image("images/crafting_menu.xml", "skins_backing.tex"))
    self.spinner_bg:SetPosition(0, -spinner_height/2)
	self.spinner_bg:SetTint(1, 1, 1, 0.7)

	self.line_top = self:AddChild(Image("images/ui.xml", "line_horizontal_white.tex"))
	self.line_top:SetPosition(0, 0)
	self.line_top:SetTint(unpack(BROWN))

	self.line_bottom = self:AddChild(Image("images/ui.xml", "line_horizontal_white.tex"))
	self.line_bottom:SetPosition(0, -spinner_height)
	self.line_bottom:SetTint(unpack(BROWN))

    self.spinner = self:AddChild(Spinner( {}, spinner_width, nil, spinner_font, nil, nil, textures, true, 250, nil))
    self.spinner.auto_shrink_text = true
    self.spinner:SetPosition(0, -spinner_height/2, 0)
	if recipe.fxover ~= nil then
		if self.spinner.fxover == nil then
			self.spinner.fxover = self.spinner.fgimage:AddChild(UIAnim())
			self.spinner.fxover:SetClickable(false)
			self.spinner.fxover:GetAnimState():AnimateWhilePaused(false)
			self.spinner.fxover:SetScale(.25)
		end
		self.spinner.fxover:GetAnimState():SetBank(recipe.fxover.bank)
		self.spinner.fxover:GetAnimState():SetBuild(recipe.fxover.build)
		self.spinner.fxover:GetAnimState():PlayAnimation(recipe.fxover.anim, true)
	elseif self.spinner.fxover ~= nil then
		self.spinner.fxover:Kill()
		self.spinner.fxover = nil
	end
    self.spinner.fgimage:SetPosition(0, 0)
	self.spinner.fgimage:SetScale(1.2)
    self.spinner.text:SetPosition(0, -35)
	self.spinner.text:Hide()
    self.spinner.background:ScaleToSize(spinner_width + 2, spinner_height)
    self.spinner.background:SetPosition(0, 6)
	self.spinner:AddControllerHints(CONTROL_INVENTORY_USEONSCENE, CONTROL_INVENTORY_USEONSELF, true)

	self.spinner:SetOnChangedFn(function()
		local which = self.spinner:GetSelectedIndex()
        if which > 1 then
            if self.skins_options[which].new_indicator or FORCE_NEWTAG then
				self.new_tag:Show()
            else
				self.new_tag:Hide()
            end
        else
            self.new_tag:Hide()
        end
		if self.spinner.fxover ~= nil then
			self.spinner.fxover:GetAnimState():SetTime(0)
		end
	end)

    if #self.skins_options == 1 then
		self.spinner.fgimage:SetPosition(0, 0)
		self.spinner.fgimage:SetScale(1.2)
		self.spinner.text:Hide()
	else
		self.spinner.fgimage:SetPosition(0, 15)
		self.spinner.fgimage:SetScale(1)
		self.spinner.text:Show()
	end

    self.new_tag = self:AddChild(Image("images/ui.xml", "new_label.tex"))
    self.new_tag:SetScale(.7)
    self.new_tag:SetPosition(-55, -20)
    self.new_tag:Hide()

    self.focus_forward = self.spinner

	self.spinner:SetWrapEnabled(#self.skins_options > 1)
	self.spinner:SetOptions(self.skins_options)

	self.spinner:SetSelectedIndex(skin_name == nil and 1 or self:GetIndexForSkin(skin_name) or 1)

	self.widget_height = spinner_height * SCALE
end)

function SkinSelector:RefreshControllers(controller_mode)
	self.spinner:RefreshControllers(controller_mode)
end

function SkinSelector:GetItem()
    local which = self.spinner:GetSelectedIndex()
    if which > 1 then
        local name = self.skins_list[which - 1].item
        return name
    else
        return nil --self.recipe.name
    end
end

function SkinSelector:GetIndexForSkin(skin)
    for i=1, #self.skins_list do
        if self.skins_list[i].item == skin then
            return i + 1
        end
    end

    return 1
end

function SkinSelector:SelectSkin(skin_name)
	self.spinner:SetSelectedIndex(skin_name == nil and 1 or self:GetIndexForSkin(skin_name) or 1)
end

function SkinSelector:GetSkinsList()
    if not self.timestamp then self.timestamp = -10000 end

    --Note(Peter): This could get a speed improvement by passing in self.recipe.name into a c-side inventory check, and then add the PREFAB_SKINS data to c-side
    -- so that we don't have to walk the whole inventory for each prefab for each item_type in PREFAB_SKINS[self.recipe.name]
    local skins_list = {}
    if self.recipe and PREFAB_SKINS[self.recipe.product] then
        for _,item_type in pairs(PREFAB_SKINS[self.recipe.product]) do
            if not PREFAB_SKINS_SHOULD_NOT_SELECT[item_type] then
                local has_item, modified_time = TheInventory:CheckOwnershipGetLatest(item_type)
                if has_item then
                    local data  = {}
                    data.type = type
                    data.item = item_type
                    data.timestamp = modified_time
                    table.insert(skins_list, data)

                    if data.timestamp > self.timestamp then
                        self.timestamp = data.timestamp
                    end
                end
            end
        end
    end

    return skins_list
end

function SkinSelector:GetSkinOptions()
    local skin_options = {}

	local non_skin_image = self.recipe.imagefn ~= nil and self.recipe.imagefn() or self.recipe.image or (self.recipe.product..".tex")
    table.insert(skin_options,
    {
        text = STRINGS.UI.CRAFTING.DEFAULT,
        data = nil,
        colour = DEFAULT_SKIN_COLOR,
        new_indicator = false,
        image = {self.recipe:GetAtlas(), non_skin_image, "default.tex"},
    })

    local recipe_timestamp = Profile:GetRecipeTimestamp(self.recipe.product)
    --print(self.recipe.product, "Recipe timestamp is ", recipe_timestamp)
    if self.skins_list ~= nil and self.recipe.chooseskin == nil and (TheInventory:HasSupportForOfflineSkins() or TheNet:IsOnlineMode()) then
        for which = 1, #self.skins_list do
            local item = self.skins_list[which].item

            local colour = GetColorForItem(item)
            local text_name = GetSkinName(item)
            local image_name = GetSkinInvIconName(item)..".tex"
            local new_indicator = not self.skins_list[which].timestamp or (self.skins_list[which].timestamp > recipe_timestamp)

            table.insert(skin_options,
            {
                text = text_name,
                data = nil,
                colour = colour,
                --new_indicator = new_indicator, -- disabling the new indicator, for now, because it never really quite worked right...
                image = {GetInventoryItemAtlas(image_name), image_name or "default.tex", "default.tex"},
            })
        end
    end

    return skin_options
end


function SkinSelector:OnControl(control, down)
	if self.spinner:OnControl(control, down) then
		return true
	end


end


return SkinSelector
