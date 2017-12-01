local Screen = require "widgets/screen"
local MapWidget = require("widgets/mapwidget")
local Widget = require "widgets/widget"
local MapControls = require "widgets/mapcontrols"
local HudCompass = require "widgets/hudcompass"

local MapScreen = Class(Screen, function(self, owner)
    self.owner = owner
    Screen._ctor(self, "MapScreen")
    self.minimap = self:AddChild(MapWidget(self.owner))

    self.bottomright_root = self:AddChild(Widget("br_root"))
    self.bottomright_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.bottomright_root:SetHAnchor(ANCHOR_RIGHT)
    self.bottomright_root:SetVAnchor(ANCHOR_BOTTOM)
    self.bottomright_root:SetMaxPropUpscale(MAX_HUD_SCALE)

    self.bottomright_root = self.bottomright_root:AddChild(Widget("br_scale_root"))
    self.bottomright_root:SetScale(TheFrontEnd:GetHUDScale())
    self.bottomright_root.inst:ListenForEvent("refreshhudsize", function(hud, scale) self.bottomright_root:SetScale(scale) end, owner.HUD.inst)

    if not TheInput:ControllerAttached() then
        self.mapcontrols = self.bottomright_root:AddChild(MapControls())
        self.mapcontrols:SetPosition(-60,70,0)
        self.mapcontrols.pauseBtn:Hide()
    end

    self.hudcompass = self.bottomright_root:AddChild(HudCompass(self.owner, false))
    self.hudcompass:SetPosition(-160,70,0)

    self.repeat_time = 0
end)

function MapScreen:OnBecomeInactive()
    MapScreen._base.OnBecomeInactive(self)

    if TheWorld.minimap.MiniMap:IsVisible() then
        TheWorld.minimap.MiniMap:ToggleVisibility()
    end
    --V2C: Don't set pause in multiplayer, all it does is change the
    --     audio settings, which we don't want to do now
    --SetPause(false)
end

function MapScreen:OnBecomeActive()
    MapScreen._base.OnBecomeActive(self)

    if not TheWorld.minimap.MiniMap:IsVisible() then
        TheWorld.minimap.MiniMap:ToggleVisibility()
    end
    self.minimap:UpdateTexture()
    --V2C: Don't set pause in multiplayer, all it does is change the
    --     audio settings, which we don't want to do now
    --SetPause(true)
end

function MapScreen:OnUpdate(dt)
    local s = -100 -- now per second, not per repeat

    if TheInput:IsControlPressed(CONTROL_MOVE_LEFT) then
        self.minimap:Offset(-s * dt, 0)
    elseif TheInput:IsControlPressed(CONTROL_MOVE_RIGHT)then
        self.minimap:Offset(s * dt, 0)
    end

    if TheInput:IsControlPressed(CONTROL_MOVE_DOWN)then
        self.minimap:Offset(0, -s * dt)
    elseif TheInput:IsControlPressed(CONTROL_MOVE_UP)then
        self.minimap:Offset(0, s * dt)
    end

    if self.repeat_time <= 0 then
        if TheInput:IsControlPressed(CONTROL_MAP_ZOOM_IN ) then
            self.minimap:OnZoomIn()
        elseif TheInput:IsControlPressed(CONTROL_MAP_ZOOM_OUT ) then
            self.minimap:OnZoomOut()
        end

        self.repeat_time = .025
    else
        self.repeat_time = self.repeat_time - dt
    end
end

--[[ EXAMPLE of map coordinate functions
function MapScreen:NearestEntToCursor()
    local closestent = nil
    local closest = nil
    for ent,_ in pairs(someentities) do
        local ex,ey,ez = ent.Transform:GetWorldPosition()
        local entpos = self:MapPosToWidgetPos( Vector3(self.minimap:WorldPosToMapPos(ex,ez,0)) )
        local mousepos = self:ScreenPosToWidgetPos( TheInput:GetScreenPosition() )
        local delta = mousepos - entpos

        local length = delta:Length()
        if length < 30 then
            if closest == nil or length < closest then
                closestent = ent
                closest = length
            end
        end
    end

    if closestent ~= nil then
        local ex,ey,ez = closestent.Transform:GetWorldPosition()
        local entpos = self:MapPosToWidgetPos( Vector3(self.minimap:WorldPosToMapPos(ex,ez,0)) )

        self.hovertext:SetPosition(entpos:Get())
        self.hovertext:Show()
    else
        self.hovertext:Hide()
    end
end
]]

function MapScreen:MapPosToWidgetPos(mappos)
    return Vector3(
        mappos.x * RESOLUTION_X/2,
        mappos.y * RESOLUTION_Y/2,
        0
    )
end

function MapScreen:ScreenPosToWidgetPos(screenpos)
    local w, h = TheSim:GetScreenSize()
    return Vector3(
        screenpos.x / w * RESOLUTION_X - RESOLUTION_X/2,
        screenpos.y / h * RESOLUTION_Y - RESOLUTION_Y/2,
        0
    )
end

function MapScreen:WidgetPosToMapPos(widgetpos)
    return Vector3(
        widgetpos.x / (RESOLUTION_X/2),
        widgetpos.y / (RESOLUTION_Y/2),
        0
    )
end

function MapScreen:OnControl(control, down)
    if MapScreen._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
        TheFrontEnd:PopScreen()
        return true
    end

    if not (down and self.shown) then
        return false
    end

    if control == CONTROL_ROTATE_LEFT and ThePlayer and ThePlayer.components.playercontroller then
        ThePlayer.components.playercontroller:RotLeft()
    elseif control == CONTROL_ROTATE_RIGHT and ThePlayer and ThePlayer.components.playercontroller then
        ThePlayer.components.playercontroller:RotRight()
    elseif control == CONTROL_MAP_ZOOM_IN then
        self.minimap:OnZoomIn()
        self.repeat_time = .025
    elseif control == CONTROL_MAP_ZOOM_OUT then
        self.minimap:OnZoomOut()
        self.repeat_time = .025
    else
        return false
    end
    return true
end

function MapScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_LEFT) .. " " .. STRINGS.UI.HELP.ROTATE_LEFT)
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_RIGHT) .. " " .. STRINGS.UI.HELP.ROTATE_RIGHT)
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MAP_ZOOM_IN) .. " " .. STRINGS.UI.HELP.ZOOM_IN)
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MAP_ZOOM_OUT) .. " " .. STRINGS.UI.HELP.ZOOM_OUT)
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

return MapScreen
