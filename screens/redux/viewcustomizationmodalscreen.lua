local Screen = require "widgets/screen"
local Text = require "widgets/text"
local HeaderTabs = require "widgets/redux/headertabs"
local Widget = require "widgets/widget"
local SettingsList = require "widgets/redux/worldsettings/settingslist"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local TEMPLATES = require "widgets/redux/templates"


local Customize = require "map/customize"
local Levels = require "map/levels"

local dialog_size_x = 720
local dialog_size_y = 555

local width_scale = 275/256
local height_scale = 45/64

local function OnClickTab(self, level)
    self.multileveltabs:SelectButton(level)
    self:SelectMultilevel(self.multileveltabs.selected_index)
    if TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
        self:OnFocusMove(MOVE_DOWN, true)
    end
end

local ViewCustomizationModalScreen = Class(Screen, function(self, leveldata)
    Screen._ctor(self, "ViewCustomizationModalScreen")

    self.currentmultilevel = 1

    --V2C: assert comment is here just as a reminder
    --assert(leveldata ~= nil)

    self.black = self:AddChild(TEMPLATES.BackgroundTint())
    self.root = self:AddChild(TEMPLATES.ScreenRoot())

    local buttons = nil

    if TheInput:ControllerAttached() then
        -- Button is awkward to navigate to, so rely on CONTROL_CANCEL instead.
        buttons = {}
    else
        buttons = {
            {
                text = STRINGS.UI.SERVERLISTINGSCREEN.OK,
                cb = function() self:Cancel() end,
            },
        }
    end

    self.dialog_bg = self.root:AddChild(TEMPLATES.PlainBackground())
    local dialog_width = dialog_size_x + 72
    local dialog_height = dialog_size_y + 4
    self.dialog_bg:SetScissor(-dialog_width/2, -dialog_height/2, dialog_width, dialog_height)

    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(dialog_size_x, dialog_size_y, nil, buttons))
    self.dialog.top:Hide() -- top crown would be behind our tabs.
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.dialog:SetBackgroundTint(r,g,b,0.6) -- need high opacity because there's lots of text behind

    self.optionspanel = self.dialog:InsertWidget(Widget("optionspanel"))

    self.leveldata = deepcopy(leveldata)

    local levelversion = table.typecheckedgetfield(self.leveldata, "number", 1, "version")
    if levelversion and levelversion >= 2 then
        self.settings_widget = self.optionspanel:AddChild(SettingsList(self, LEVELCATEGORY.SETTINGS))
        self.settings_widget:SetPosition(0, -30)
        self.settings_widget:Hide()
        self.worldgen_widget = self.optionspanel:AddChild(SettingsList(self, LEVELCATEGORY.WORLDGEN))
        self.worldgen_widget:Hide()
        self.worldgen_widget:SetPosition(0, -30)

        local tab_tint_width = 795
        local tab_tint_height = 60

        self.tab_tint_bg = self.optionspanel:AddChild(TEMPLATES.PlainBackground())
        self.tab_tint_bg:SetScissor(-tab_tint_width/2, -tab_tint_height/2, tab_tint_width, tab_tint_height)
        self.tab_tint_bg:SetPosition(0, 255)

        self.tab_tint = self.optionspanel:AddChild(Image("images/global.xml", "square.tex"))
        self.tab_tint:SetTint(r, g, b, 0.2)
        self.tab_tint:SetSize(tab_tint_width, tab_tint_height)
        self.tab_tint:SetPosition(0, 255)

        local button_data = {
            {text = STRINGS.UI.CUSTOMIZATIONSCREEN.TAB_TITLE_WORLDSETTINGS, levelcategory = LEVELCATEGORY.SETTINGS, get_widget_fn = function() return self.settings_widget end},
            {text = STRINGS.UI.CUSTOMIZATIONSCREEN.TAB_TITLE_WORLDGENERATION, levelcategory = LEVELCATEGORY.WORLDGEN, get_widget_fn = function() return self.worldgen_widget end},
        }

        local function MakeTab(data, index)
            local tab = ImageButton("images/frontend_redux.xml", "list_tabs_normal.tex", nil, nil, nil, "list_tabs_selected.tex", nil, {0,4})

            tab:SetText(data.text)
            tab:SetTextSize(22)
            tab:SetNormalScale(width_scale, height_scale)
            tab.scale_on_focus = false
            tab:UseFocusOverlay("list_tabs_hover.tex")
            tab:SetFont(CHATFONT)
            tab:SetDisabledFont(CHATFONT)
            tab:SetTextColour(UICOLOURS.GOLD_CLICKABLE)
            tab:SetTextFocusColour(UICOLOURS.GOLD_FOCUS)
            tab:SetTextDisabledColour(UICOLOURS.GOLD_UNIMPORTANT)
            tab:SetTextSelectedColour(UICOLOURS.BLACK)

            tab:SetOnClick(function()
                self.last_selected:Unselect()
                self.last_selected = tab
                tab:Select()
                tab:MoveToFront()

                self.activesettingswidget:Hide()
                self.activesettingswidget = data.get_widget_fn()
                self.activesettingswidget:Show()
                self.activelevelcategory = data.levelcategory
                self:Refresh()
            end)

            return tab
        end

        self.tabs = {}
        for i = 1, #button_data do
            table.insert(self.tabs, self.optionspanel:AddChild(MakeTab(button_data[i], i)))
            self.tabs[#self.tabs]:MoveToBack()
        end
        self.tab_tint:MoveToBack()
        self.tab_tint_bg:MoveToBack()
        self:_PositionTabs(self.tabs, 230*width_scale, 243)

        self.last_selected = self.tabs[1]
        self.last_selected:Select()
        self.last_selected:MoveToFront()

        self.activesettingswidget = button_data[1].get_widget_fn()
        self.activesettingswidget:Show()
        self.activelevelcategory = button_data[1].levelcategory

        self.focus_forward = function() return self.last_selected end

        -- Top border of the scroll list.
        self.customizations_horizontal_line = self.optionspanel:AddChild(Image("images/global_redux.xml", "item_divider.tex"))
        self.customizations_horizontal_line:SetPosition(0,245-(64*height_scale)/2)
        self.customizations_horizontal_line:SetSize(795, 5)

        local tabs = {}
        for i=1,2 do
            if self:IsLevelEnabled(i) then
                assert(i > #tabs, "tab clicking will be broken. need to handle first item missing.")
                local locationid = string.upper(table.typecheckedgetfield(self.leveldata, "string", i, "location") or "")
                local locationname = STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME[locationid] or STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME.UNKNOWN
                table.insert(tabs, {
                        text = locationname,
                        cb = function() OnClickTab(self, i) end,
                    })
            end
        end
        self.multileveltabs = self.dialog:AddChild(HeaderTabs(tabs))
        self.multileveltabs:SetPosition(0,dialog_size_y/2+25)
        self.multileveltabs:MoveToBack()
        self.multileveltabs.tabs = self.multileveltabs.menu.items

        self:Refresh()

        self:DoFocusHookups()
    else
        self.missingtitle = self.optionspanel:AddChild(Text(BUTTONFONT, 50, STRINGS.UI.SERVERLISTINGSCREEN.MISSINGDATATITLE))
        self.missingtitle:SetColour(UICOLOURS.GOLD_SELECTED)
        self.missingtitle:SetPosition(0, 110)

        self.missingbody = self.optionspanel:AddChild(Text(NEWFONT, 28, STRINGS.UI.SERVERLISTINGSCREEN.MISSINGDATABODY))
        self.missingbody:SetRegionSize(450, 250)
        self.missingbody:SetVAlign(ANCHOR_TOP)
        self.missingbody:SetColour(UICOLOURS.GOLD_UNIMPORTANT)
        self.missingbody:SetPosition(0, -50)
        self.missingbody:EnableWordWrap(true)
    end
end)

function ViewCustomizationModalScreen:_PositionTabs(tabs, w, y)
	local offset = #self.tabs / 2
	for i = 1, #self.tabs do
		local x = (i - offset - 0.5) * w
		tabs[i]:SetPosition(x, y)
	end
end

function ViewCustomizationModalScreen:IsEditable()
    return false
end

function ViewCustomizationModalScreen:GetOptions()
    local location = table.typecheckedgetfield(self.leveldata, "string", self.currentmultilevel, "location")

    if self.activelevelcategory == LEVELCATEGORY.SETTINGS then
        return Customize.GetWorldSettingsOptionsWithLocationDefaults(location, self.currentmultilevel == 1)
    elseif self.activelevelcategory == LEVELCATEGORY.WORLDGEN then
        return Customize.GetWorldGenOptionsWithLocationDefaults(location, self.currentmultilevel == 1)
    end
end

function ViewCustomizationModalScreen:SetTweak() end --dummyfn for settingslist

function ViewCustomizationModalScreen:SelectMultilevel(level)
    self.currentmultilevel = level
    self:Refresh()
end

function ViewCustomizationModalScreen:IsLevelEnabled(level)
    return table.typecheckedgetfield(self.leveldata, "table", level)
end

function ViewCustomizationModalScreen:Refresh()
    self.multileveltabs:SetFocusChangeDir(MOVE_DOWN, self.last_selected)
    self.last_selected:SetFocusChangeDir(MOVE_UP, self.multileveltabs)
    self.last_selected:SetFocusChangeDir(MOVE_DOWN, self.activesettingswidget)
    self.activesettingswidget:SetFocusChangeDir(MOVE_UP, self.last_selected)
    self.activesettingswidget:SetFocusChangeDir(MOVE_DOWN, self.dialog)
    self.dialog:SetFocusChangeDir(MOVE_UP, self.activesettingswidget)

    local presetdata = Levels.GetDataForLevelID(self.leveldata[self.currentmultilevel].id)
    if presetdata == nil then
        presetdata = Levels.GetDataForLocation(self.leveldata[self.currentmultilevel].location)
    end
    if presetdata ~= nil then
        self.activesettingswidget:SetPresetValues(presetdata.overrides)
    end

    self.default_focus = self.last_selected

    self.activesettingswidget:RefreshOptionItems()
    if not self.activesettingswidget.scroll_list then
        self.activesettingswidget:MakeScrollList()
    end
end

function ViewCustomizationModalScreen:GetValueForOption(option)
    return table.typecheckedgetfield(self.leveldata, nil, self.currentmultilevel, "overrides", option)
        or Customize.GetLocationDefaultForOption(table.typecheckedgetfield(self.leveldata, "string", self.currentmultilevel, "location"), option)
end

function ViewCustomizationModalScreen:Cancel()
    TheFrontEnd:PopScreen()
end

function ViewCustomizationModalScreen:DoFocusHookups()
    for i, v in ipairs(self.tabs) do
        if self.tabs[i - 1] then
            v:SetFocusChangeDir(MOVE_LEFT, self.tabs[i - 1])
        end
        if self.tabs[i + 1] then
            v:SetFocusChangeDir(MOVE_RIGHT, self.tabs[i + 1])
        end
    end
end

function ViewCustomizationModalScreen:OnControl(control, down)
    if ViewCustomizationModalScreen._base.OnControl(self, control, down) then return true end
    if down then return end

    if control == CONTROL_CANCEL then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        self:Cancel()
        return true
    elseif control == CONTROL_OPEN_CRAFTING then
        OnClickTab(self, self.multileveltabs.selected_index + 1)
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    elseif control == CONTROL_OPEN_INVENTORY then
        OnClickTab(self, self.multileveltabs.selected_index - 1)
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        return true
    end
end

function ViewCustomizationModalScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    return table.concat(t, "  ")
end

return ViewCustomizationModalScreen
