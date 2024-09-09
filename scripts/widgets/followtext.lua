local Widget = require "widgets/widget"
local Text = require "widgets/text"

local FollowText = Class(Widget, function(self, font, size, text)
    Widget._ctor(self, "followtext")

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)
    self.text = self:AddChild(Text(font, size, text))
    self.offset = Vector3(0, 0, 0)
    self.screen_offset = Vector3(0, 0, 0)

    self:StartUpdating()
end)

--This would normally be achieved via an owner argument in the constructor
--but we'll not change the constructor in case MODs are using this widget.
function FollowText:SetHUD(hud)
    if not self.hashud then
        self.hashud = true
        self.text:SetScale(TheFrontEnd:GetHUDScale())
        --listen for events (these are not commonly triggered)
        --better than polling update, because GetHUDScale() isn't super cheap
        self.text.inst:ListenForEvent("continuefrompause", function() self.text:SetScale(TheFrontEnd:GetHUDScale()) end, hud)
        self.text.inst:ListenForEvent("refreshhudsize", function(hud, scale) self.text:SetScale(scale) end, hud)
    end
end

function FollowText:SetTarget(target)
    self.target = target
    self:OnUpdate()
end

function FollowText:SetOffset(offset)
    self.offset = offset
    self:OnUpdate()
end

function FollowText:SetScreenOffset(x,y)
    self.screen_offset.x = x
    self.screen_offset.y = y
    self:OnUpdate()
end

function FollowText:GetScreenOffset()
    return self.screen_offset.x, self.screen_offset.y
end

function FollowText:OnUpdate(dt)
    if self.target ~= nil and self.target:IsValid() then
        if not self.hashud then
            --legacy support for MODs
            self.text:SetScale(TheFrontEnd:GetHUDScale())
        end
        local x, y
        if self.target.AnimState ~= nil then
            x, y = TheSim:GetScreenPos(self.target.AnimState:GetSymbolPosition(self.symbol or "", self.offset.x, self.offset.y, self.offset.z))
        else
            x, y = TheSim:GetScreenPos(self.target.Transform:GetWorldPosition())
        end
        self:SetPosition(x + self.screen_offset.x, y + self.screen_offset.y, 0)
    end
end

return FollowText
