local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local AccountItemFrame = require "widgets/redux/accountitemframe"


local DefaultSkinSelectionPopup = Class(Screen, function(self, user_profile, character)
    Screen._ctor(self, "DefaultSkinSelectionPopup")

    self.user_profile = user_profile
    self.character = character

    local inv_item_list = (TUNING.GAMEMODE_STARTING_ITEMS[TheNet:GetServerGameMode()] or TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT)[string.upper(character)]

    if inv_item_list == nil or #inv_item_list == 0 then
        print("how did we get here???")
    end

    local inv_items, item_count = {}, {}
    for _, v in ipairs(inv_item_list) do
        if item_count[v] == nil then
            item_count[v] = 1
            table.insert(inv_items, v)
        else
            item_count[v] = item_count[v] + 1
        end
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
    self.dialog = self.proot:AddChild(TEMPLATES.CurlyWindow(470,
            250,
            STRINGS.UI.ITEM_SKIN_DEFAULTS.TITLE,
            self.buttons,
            30,
            "" -- force creation of body to re-use sizing data
        ))


    local spacing = 60

    self.spinners = {}
    local i = 1
    for _, item in ipairs(inv_items) do
        if PREFAB_SKINS[item] then
            local row = self.proot:AddChild(Widget("starting_slot_widget"))
            row:SetPosition(-180, 150 - i * spacing)

            local slot = row:AddChild(Image("images/hud.xml", "inv_slot.tex"))

            local override_item_image = TUNING.STARTING_ITEM_IMAGE_OVERRIDE[item]
            local atlas = override_item_image ~= nil and override_item_image.atlas or GetInventoryItemAtlas(item..".tex", true)
            local front_img = nil
            if atlas ~= nil then
                local image = override_item_image ~= nil and override_item_image.image or (item..".tex")
                front_img = slot:AddChild(Image(atlas, image))
                front_img:SetScale(0.9)
            end
            slot:SetScale(0.85)
            slot:SetPosition(360, 0)

            local spinner_options = self:GetSkinOptions( item )
            local width_label = 250
            local width_spinner = 200
            local height = 40
            local spin_spacing = 0 
            local font = HEADERFONT
            local font_size = 24
            local horiz_offset = 100
            local spinner = row:AddChild(TEMPLATES.LabelSpinner(STRINGS.NAMES[string.upper(item)], spinner_options, width_label, width_spinner, height, spin_spacing, font, font_size, horiz_offset,
                function(data)
                    if data ~= nil then
                        front_img:SetTexture(data.xml, data.tex, "default.tex")
                    end
                end
            ))

            local last_skin = self.user_profile:GetLastUsedSkinForItem(item)
            for i, option in ipairs(spinner_options) do
                if option.data.skin_item == last_skin then
                    spinner.spinner:SetSelectedIndex(i)
                    spinner.spinner:Changed() --why doesn't SetSelectedIndex call this?!?
                end
            end

            spinner.spinner.fgimage:SetPosition( 150, 0 )
            
            table.insert( self.spinners, spinner )

            i = i + 1
        end
    end

    self.oncontrol_fn, self.gethelptext_fn = TEMPLATES.ControllerFunctionsFromButtons(self.buttons)
    if TheInput:ControllerAttached() then
        self.dialog.actions:Hide()
    end

    if #self.spinners > 1 then
        self.spinners[1]:SetFocusChangeDir(MOVE_DOWN, self.spinners[2])
        self.spinners[#self.spinners]:SetFocusChangeDir(MOVE_UP, self.spinners[#self.spinners-1])
    end
    for i = 2, #self.spinners - 1 do
        self.spinners[i]:SetFocusChangeDir(MOVE_UP, self.spinners[i-1])
        self.spinners[i]:SetFocusChangeDir(MOVE_DOWN, self.spinners[i+1])
    end

    self.default_focus = self.spinners[1]
end)

function DefaultSkinSelectionPopup:GetSkinsList( item )
    --Note(Peter): This could get a speed improvement by passing in self.recipe.name into a c-side inventory check, and then add the PREFAB_SKINS data to c-side
    -- so that we don't have to walk the whole inventory for each prefab for each item_type in PREFAB_SKINS[self.recipe.name]
    local skins_list = {}
    if PREFAB_SKINS[item] then
        for _,item_type in pairs(PREFAB_SKINS[item]) do
            local has_item = TheInventory:CheckOwnership(item_type)
            if has_item then
                local data  = {}
                data.item = item_type
                table.insert(skins_list, data)
            end
        end
    end

    return skins_list
end

--TheNet:IsOnlineMode()
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
    for _,spinner in pairs(self.spinners) do
        local data = spinner.spinner:GetSelectedData()
        self.user_profile:SetLastUsedSkinForItem(data.item, data.skin_item)
    end

    TheFrontEnd:PopScreen(self)
end

return DefaultSkinSelectionPopup
