local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local AccountItemFrame = require "widgets/redux/accountitemframe"


local DefaultSkinSelectionPopup = Class(Screen, function(self, user_profile, character)
    Screen._ctor(self, "DefaultSkinSelectionPopup")

    self.user_profile = user_profile
    self.character = character

    local inv_item_list = GetUniquePotentialCharacterStartingInventoryItems(character, true)

    if inv_item_list[1] == nil then
        print("how did we get here???")
    end

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
    self.proot = self:AddChild(TEMPLATES.ScreenRoot())

    self.buttons = {
        {
            text=STRINGS.UI.HELP.BACK,
            cb = function()
                self:_Cancel()
            end,
            controller_control = CONTROL_CANCEL,
        },
    }
    
    local scroll_height = 250--460
    local content_width = 390
    local item_height = 60

    self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(470,
        scroll_height,
        STRINGS.UI.ITEM_SKIN_DEFAULTS.TITLE,
        self.buttons,
        30,
        "" -- force creation of body to re-use sizing data
    ))

    -- NOTES(JBK): Using this to cache the data for faster consistent lookups.
    self.spinnerdata = {}
    local total_spinners = 0
    for _, item in ipairs(inv_item_list) do
        if PREFAB_SKINS[item] then
            total_spinners = total_spinners + 1
            local data = {}
            self.spinnerdata[total_spinners] = data

            local override_item_image = TUNING.STARTING_ITEM_IMAGE_OVERRIDE[item]
            data.atlas = override_item_image ~= nil and override_item_image.atlas or GetInventoryItemAtlas(item..".tex", true)
            data.image = override_item_image ~= nil and override_item_image.image or (item..".tex")
            data.spinner_options = self:GetSkinOptions(item)
            data.item = item
            data.last_skin = self.user_profile:GetLastUsedSkinForItem(item)
            data.original_skin = data.last_skin
            data.itemname = STRINGS.NAMES[string.upper(item)]
        end
    end


    local NO_OPTIONS = {}
    local function ScrollWidgetsCtor(context, i)
        local item = Widget("item-" .. i)
        item.root = item:AddChild(Widget("root"))
        item.root:SetPosition(-180, 0)

        local row = item.root
        local slot = row:AddChild(Image("images/hud.xml", "inv_slot.tex"))

        local front_img = slot:AddChild(Image("images/global.xml", "square.tex"))
        slot:SetScale(0.85)
        slot:SetPosition(360, 0)

        local width_label = 250
        local width_spinner = 200
        local height = 40
        local spin_spacing = 0 
        local font = HEADERFONT
        local font_size = 24
        local horiz_offset = 100
        local spinner
        spinner = row:AddChild(TEMPLATES.LabelSpinner("n/a", NO_OPTIONS, width_label, width_spinner, height, spin_spacing, font, font_size, horiz_offset,
            function(data)
                if data ~= nil then
                    spinner.front_img:SetTexture(data.xml, data.tex, "default.tex")
                    for _, spinnerdata in ipairs(self.spinnerdata) do
                        if data.item == spinnerdata.item then
                            spinnerdata.last_skin = data.skin_item
                            break
                        end
                    end
                end
            end
        ))
        spinner.front_img = front_img

        spinner.spinner.fgimage:SetPosition( 150, 0 )

        item.spinner = item.root:AddChild(spinner)

        item.focus_forward = item.spinner
        item:SetOnGainFocus(function()
            self.scroll_list:OnWidgetFocus(item)
        end)

        return item
    end
    local function ScrollWidgetApply(context, item, spinnerdata, index)
        if spinnerdata then
            item.spinner.label:SetString(spinnerdata.itemname)
            item.spinner.spinner:SetOptions(spinnerdata.spinner_options)
            if spinnerdata.atlas ~= nil then
                item.spinner.front_img:SetTexture(spinnerdata.atlas, spinnerdata.image)
                item.spinner.front_img:SetScale(0.9)
            end

            for i, option in ipairs(spinnerdata.spinner_options) do
                if option.data.skin_item == spinnerdata.last_skin then
                    item.spinner.spinner:SetSelectedIndex(i)
                    item.spinner.spinner:Changed() --why doesn't SetSelectedIndex call this?!?
                end
            end

            item:Show()
        else
            item:Hide()
        end
    end

    self.scroll_list = self.proot:AddChild(
        TEMPLATES.ScrollingGrid(
            self.spinnerdata,
            {
                context = {},
                widget_width  = content_width + 40,
                widget_height =  item_height,
                num_visible_rows = math.floor(scroll_height/item_height) - 1,
                num_columns      = 1,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn     = ScrollWidgetApply,
                scrollbar_height_offset = -60,
                scrollbar_offset = 20,
            }
        )
    )
    self.scroll_list:SetPosition(0, 30)


    self.oncontrol_fn, self.gethelptext_fn = TEMPLATES.ControllerFunctionsFromButtons(self.buttons)
    if TheInput:ControllerAttached() then
        self.dialog.actions:Hide()
    end

    self.default_focus = self.scroll_list
end)

function DefaultSkinSelectionPopup:GetSkinsList( item )
    --Note(Peter): This could get a speed improvement by passing in self.recipe.name into a c-side inventory check, and then add the PREFAB_SKINS data to c-side
    -- so that we don't have to walk the whole inventory for each prefab for each item_type in PREFAB_SKINS[self.recipe.name]
    local skins_list = {}
    if PREFAB_SKINS[item] then
        for _,item_type in pairs(PREFAB_SKINS[item]) do
            if not PREFAB_SKINS_SHOULD_NOT_SELECT[item_type] then
                local has_item = TheInventory:CheckOwnership(item_type)
                if has_item then
                    local data  = {}
                    data.item = item_type
                    table.insert(skins_list, data)
                end
            end
        end
    end

    return skins_list
end

function DefaultSkinSelectionPopup:GetSkinOptions( item )
    local skin_options = {}

    local override_item_image = TUNING.STARTING_ITEM_IMAGE_OVERRIDE[item]
    local atlas = override_item_image ~= nil and override_item_image.atlas or GetInventoryItemAtlas(item..".tex", true)

    table.insert(skin_options,
    {
        text = STRINGS.UI.CRAFTING.DEFAULT,
        colour = DEFAULT_SKIN_COLOR,
        data = {xml = atlas, tex = item..".tex", item = item},
    })
    
    local skins_list = self:GetSkinsList(item)
    for which = 1, #skins_list do
        local skin_item = skins_list[which].item

        local colour = GetColorForItem(skin_item)
        local text_name = GetSkinName(skin_item)
        local image_name = GetSkinInvIconName(skin_item)

        table.insert(skin_options,
        {
            text = text_name,
            colour = colour,
            data = { xml = GetInventoryItemAtlas(image_name..".tex"), tex = image_name..".tex" or "default.tex", item = item, skin_item = skin_item},
        })
    end

    return skin_options
end



function DefaultSkinSelectionPopup:OnControl(control, down)
    if DefaultSkinSelectionPopup._base.OnControl(self,control, down) then
        return true
    end

    return self.oncontrol_fn(control, down)
end

function DefaultSkinSelectionPopup:GetHelpText()
    return self.gethelptext_fn()
end

function DefaultSkinSelectionPopup:_Cancel()
    for _, data in ipairs(self.spinnerdata) do
        if data.last_skin ~= data.original_skin then
            self.user_profile:SetLastUsedSkinForItem(data.item, data.last_skin)
        end
    end
    TheFrontEnd:PopScreen(self)
end

return DefaultSkinSelectionPopup
