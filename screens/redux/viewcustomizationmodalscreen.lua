local Screen = require "widgets/screen"
local Text = require "widgets/text"
local HeaderTabs = require "widgets/redux/headertabs"
local Widget = require "widgets/widget"
local WorldCustomizationList = require "widgets/redux/worldcustomizationlist"
local TEMPLATES = require "widgets/redux/templates"


local Customise = require "map/customise"
local Levels = require "map/levels"

local dialog_size_x = 830
local dialog_size_y = 424 -- ServerCreationScreen uses 555 but has other widgets


local function OnClickTab(self, level)
    self.multileveltabs:SelectButton(level)
    self:SelectMultilevel(self.multileveltabs.selected_index)
    if TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
        self:OnFocusMove(MOVE_DOWN, true)
    end
end

local ViewCustomizationModalScreen = Class(Screen, function(self, leveldata)
    Widget._ctor(self, "ViewCustomizationModalScreen")

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
    self.dialog = self.root:AddChild(TEMPLATES.RectangleWindow(dialog_size_x, dialog_size_y, nil, buttons))
    self.dialog.top:Hide() -- top crown would be behind our tabs.
    local r,g,b = unpack(UICOLOURS.BROWN_DARK)
    self.dialog:SetBackgroundTint(r,g,b,0.9) -- need high opacity because there's lots of text behind

    self.optionspanel = self.dialog:InsertWidget(Widget("optionspanel"))

    self.leveldata = deepcopy(leveldata)

    if self.leveldata ~= nil and self.leveldata[1] and self.leveldata[1].version ~= nil and self.leveldata[1].version >= 2 then
        local tabs = {}
        for i=1,2 do
            if self:IsLevelEnabled(i) then
                assert(i > #tabs, "tab clicking will be broken. need to handle first item missing.")
                local locationid = string.upper(self.leveldata[i].location)
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

function ViewCustomizationModalScreen:SelectMultilevel(level)
    self.currentmultilevel = level
    self:Refresh()
end

function ViewCustomizationModalScreen:IsLevelEnabled(level)
    return self.leveldata[level] ~= nil
end

function ViewCustomizationModalScreen:Refresh()
    local location = self.leveldata[self.currentmultilevel].location
    local options = Customise.GetOptionsWithLocationDefaults(location, self.currentmultilevel == 1)

    if self.customizationlist ~= nil then
        self.customizationlist:Kill()
    end

    self.customizationlist = self.optionspanel:AddChild(WorldCustomizationList(location, options, nil))
    self.customizationlist:SetScale(.85)
    self.customizationlist:SetEditable(false)

    self.multileveltabs:SetFocusChangeDir(MOVE_DOWN, self.customizationlist)
    self.customizationlist:SetFocusChangeDir(MOVE_UP, self.multileveltabs)
    self.customizationlist:SetFocusChangeDir(MOVE_DOWN, self.dialog)
    self.dialog:SetFocusChangeDir(MOVE_UP, self.customizationlist)

    local presetdata = Levels.GetDataForLevelID(self.leveldata[self.currentmultilevel].id)
    if presetdata == nil then
        print("Couldn't get data for "..tostring(self.leveldata[self.currentmultilevel].id))
        presetdata = Levels.GetDataForLocation(self.leveldata[self.currentmultilevel].location)
    end
    if presetdata ~= nil then
        self.customizationlist:SetPresetValues(presetdata.overrides)
    end

    local title = self.leveldata[self.currentmultilevel].name
    --if next(self.leveldata[self.currentmultilevel].tweak) ~= nil then
        ----title = title.." "..STRINGS.UI.CUSTOMIZATIONSCREEN.CUSTOM
    --end
    self.customizationlist:SetTitle(title)

    self.default_focus = self.customizationlist

    for i,v in ipairs(options) do
        self.customizationlist:SetValueForOption(v.name, self:GetValueForOption(self.currentmultilevel, v.name))
    end
end

function ViewCustomizationModalScreen:GetValueForOption(level, option)
    return self.leveldata[level].overrides[option]
        or Customise.GetLocationDefaultForOption(self.leveldata[level].location, option)
end

function ViewCustomizationModalScreen:Cancel()
    TheFrontEnd:PopScreen()
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
