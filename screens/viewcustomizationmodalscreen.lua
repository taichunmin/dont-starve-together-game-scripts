local Screen = require "widgets/screen"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local CustomizationList = require "widgets/customizationlist"
local TEMPLATES = require "widgets/templates"

local Customize = require "map/customize"
local Levels = require "map/levels"

local function OnClickTab(self, level)
    self:SelectMultilevel(level)
    if TheInput:ControllerAttached() and not TheFrontEnd.tracking_mouse then
        self:OnFocusMove(MOVE_DOWN, true)
    end
end

local ViewCustomizationModalScreen = Class(Screen, function(self, leveldata)
    Widget._ctor(self, "ViewCustomizationModalScreen")

    self.currentmultilevel = 1

    --V2C: assert comment is here just as a reminder
    --assert(leveldata ~= nil)

    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,.75)

    self.root = self:AddChild(Widget("root"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.clickroot = self:AddChild(Widget("clickroot"))
    self.clickroot:SetVAnchor(ANCHOR_MIDDLE)
    self.clickroot:SetHAnchor(ANCHOR_MIDDLE)
    self.clickroot:SetPosition(0,0,0)
    self.clickroot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --menu buttons
    self.optionspanel = self.clickroot:AddChild(Widget("optionspanel"))
    self.optionspanel:SetPosition(0,20,0)

    self.optionspanelbg = self.root:AddChild(TEMPLATES.CurlyWindow(40, 365, 1, 1, 67, -41))
    self.optionspanelbg.fill = self.root:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.optionspanelbg.fill:SetScale(.64, -.493)
    self.optionspanelbg.fill:SetPosition(9, -15)
    self.optionspanelbg:SetPosition(0,0,0)

    if not TheInput:ControllerAttached() then
        self.button = self.optionspanel:AddChild(ImageButton())
        self.button:SetText(STRINGS.UI.SERVERLISTINGSCREEN.OK)
        self.button:SetOnClick(function() self:Cancel() end)
        self.button:SetPosition(0,-257)
    end

    self.leveldata = deepcopy(leveldata)

    if self.leveldata ~= nil and self.leveldata[1] and self.leveldata[1].version ~= nil and self.leveldata[1].version >= 2 then

        self.multileveltabs = self.optionspanel:AddChild(Widget("multileveltabs"))
        self.multileveltabs:SetPosition(9, 180, 0)

        self.multileveltabs.tabs =
        {
            self.multileveltabs:AddChild(TEMPLATES.TabButton(-123, 0, "", function() OnClickTab(self, 1) end, "small")),
            self.multileveltabs:AddChild(TEMPLATES.TabButton(123, 0, "", function() OnClickTab(self, 2) end, "small")),
        }

        for i, v in ipairs(self.multileveltabs.tabs) do
            if self:IsLevelEnabled(i) then

                local locationid = string.upper(self.leveldata[i].location)
                local locationname = STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME[locationid] or STRINGS.UI.SANDBOXMENU.LOCATIONTABNAME.UNKNOWN

                v:SetText(locationname)
            else
                v:Disable()
                v:Hide()
            end
            v.image:SetScale(1.135, 1)
        end

        self:HookupFocusMoves()
        self:UpdateMultilevelUI()

        self:Refresh()
    else
        self.missingtitle = self.optionspanel:AddChild(Text(BUTTONFONT, 50, STRINGS.UI.SERVERLISTINGSCREEN.MISSINGDATATITLE))
        self.missingtitle:SetColour(0,0,0,1)
        self.missingtitle:SetPosition(0, 110)

        self.missingbody = self.optionspanel:AddChild(Text(NEWFONT, 28, STRINGS.UI.SERVERLISTINGSCREEN.MISSINGDATABODY))
        self.missingbody:SetRegionSize(450, 250)
        self.missingbody:SetVAlign(ANCHOR_TOP)
        self.missingbody:SetColour(0,0,0,1)
        self.missingbody:SetPosition(0, -50)
        self.missingbody:EnableWordWrap(true)
    end
end)

function ViewCustomizationModalScreen:SelectMultilevel(level)
    self.currentmultilevel = level
    self:Refresh()
    self:UpdateMultilevelUI()
end

function ViewCustomizationModalScreen:IsLevelEnabled(level)
    return self.leveldata[level] ~= nil
end

function ViewCustomizationModalScreen:UpdateMultilevelUI()
    for i,tab in ipairs(self.multileveltabs.tabs) do
        if i == self.currentmultilevel or not self:IsLevelEnabled(i) then
            tab:Disable()
        else
            tab:Enable()
        end
    end
end

function ViewCustomizationModalScreen:Refresh()
    local location = self.leveldata[self.currentmultilevel].location
    local options = Customize.GetOptionsWithLocationDefaults(location, self.currentmultilevel == 1)

    if self.customizationlist ~= nil then
        self.customizationlist:Kill()
    end

    self.customizationlist = self.optionspanel:AddChild(CustomizationList(location, options, nil))
    self.customizationlist:SetPosition(-3, -40, 0)
    self.customizationlist:SetScale(.85)
    self.customizationlist:SetEditable(false)

    local function toleveltab()
        return self.multileveltabs.tabs[self.currentmultilevel < #self.multileveltabs.tabs and self.currentmultilevel + 1 or self.currentmultilevel - 1]
    end
    self.customizationlist:SetFocusChangeDir(MOVE_UP, toleveltab)

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
        or Customize.GetLocationDefaultForOption(self.leveldata[level].location, option)
end

function ViewCustomizationModalScreen:Cancel()
    TheFrontEnd:PopScreen()
end

function ViewCustomizationModalScreen:OnControl(control, down)
    if ViewCustomizationModalScreen._base.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        self:Cancel()
        return true
    end
end

function ViewCustomizationModalScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    return table.concat(t, "  ")
end

function ViewCustomizationModalScreen:HookupFocusMoves()
    local function tocustomizationlist()
        return self.customizationlist
    end

    for i, v in ipairs(self.multileveltabs.tabs) do
        v:SetFocusChangeDir(MOVE_DOWN, tocustomizationlist)
        if i < #self.multileveltabs.tabs then
            v:SetFocusChangeDir(MOVE_RIGHT, self.multileveltabs.tabs[i + 1])
        end
        if i > 1 then
            v:SetFocusChangeDir(MOVE_LEFT, self.multileveltabs.tabs[i - 1])
        end
    end
end

return ViewCustomizationModalScreen
