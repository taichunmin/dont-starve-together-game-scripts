local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local ImageButton = require("widgets/imagebutton")

local InspectaclesWidget = require("widgets/redux/inspectacleswidget")

local InspectaclesScreen = Class(Screen, function(self, owner)
    self.owner = owner
    Screen._ctor(self, "InspectaclesScreen")
    self.solution = {}

    local function PopMe()
        self:TryToCloseWithAnimations()
    end

    local inspectaclesparticipant = owner.components.inspectaclesparticipant
    if inspectaclesparticipant == nil then
        owner:DoTaskInTime(0, PopMe)
        return
    end

    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0,0,0,.5)
    black:SetOnClick(PopMe)
    black:SetHelpTextMessage("")

    local root = self:AddChild(Widget("root"))
    root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetVAnchor(ANCHOR_MIDDLE)
    root:SetPosition(0, 0)

    self.game = root:AddChild(InspectaclesWidget(owner, self, inspectaclesparticipant))
    self.default_focus = self.game

    SetAutopaused(true)
end)

function InspectaclesScreen:OnDestroy()
    if self.game then -- NOTES(JBK): Only assigned when SetAutopaused(true) is called.
        SetAutopaused(false)
    end

    -- NOTES(JBK): Transform solution table into a solution number. [IPGVR]
    -- Since this is not really needed for gameplay we will check if solution table is empty as being good otherwise a bad solution was given.
    local solution = next(self.solution) ~= nil and 1 or 0

    POPUPS.INSPECTACLES:Close(self.owner, solution)

    InspectaclesScreen._base.OnDestroy(self)
end

function InspectaclesScreen:OnBecomeInactive()
    InspectaclesScreen._base.OnBecomeInactive(self)
end

function InspectaclesScreen:OnBecomeActive()
    InspectaclesScreen._base.OnBecomeActive(self)
end

function InspectaclesScreen:TryToCloseWithAnimations()
    if self.game then
        self.game:CloseWithAnimations()
    else
        TheFrontEnd:PopScreen()
    end
end

function InspectaclesScreen:OnControl(control, down)
    if InspectaclesScreen._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MENU_BACK or control == CONTROL_CANCEL) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        self:TryToCloseWithAnimations()
        return true
    end

	return false
end

function InspectaclesScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

return InspectaclesScreen
