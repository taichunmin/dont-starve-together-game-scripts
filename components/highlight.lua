local easing = require("easing")

local Highlight = Class(function(self, inst)
    self.inst = inst
    --[[
    self.highlit = nil
    self.base_add_colour_red = 0
    self.base_add_colour_green = 0
    self.base_add_colour_blue = 0
    self.highlight_add_colour_red = 0
    self.highlight_add_colour_green = 0
    self.highlight_add_colour_blue = 0
    --]]
end)

function Highlight:SetAddColour(col)
    self.base_add_colour_red = col.x
    self.base_add_colour_green = col.y
    self.base_add_colour_blue = col.z

    if not self.flashing then
        self:ApplyColour()
    end
end

function Highlight:Flash(toadd, timein, timeout)
    self.flashadd = toadd
    self.flashtimein = timein
    self.flashtimeout = timeout
    self.t = 0
    self.flashing = true
    self.goingin = true

    self.inst:StartUpdatingComponent(self)
end

function Highlight:OnUpdate(dt)
    if not self.inst:IsValid() then
        if self.highlit then
            self.inst:StopUpdatingComponent(self)
            self.flashing = false
            self.flash_val = nil
        else
            self.inst:RemoveComponent("highlight")
        end
        return
    end

    if self.flashing then
        self.t = self.t + dt

        if self.goingin then
            if self.t > self.flashtimein then
                self.goingin = false
                self.t = 0
            else
                self.flash_val = easing.outCubic(self.t, 0, self.flashadd, self.flashtimein)
            end
        end

        if not self.goingin then
            if self.t > self.flashtimeout then
                self.flashing = false
            else
                self.flash_val = easing.outCubic(self.t, self.flashadd, 0, self.flashtimeout)
            end
        end
    end

    if self.flashing then
        self:ApplyColour()
    elseif self.highlit then
        self.inst:StopUpdatingComponent(self)
        self.flash_val = nil
        self:ApplyColour()
    else
        self.inst:RemoveComponent("highlight")
    end
end

function Highlight:ApplyColour()
    if self.inst.AnimState ~= nil then
        local r = (self.highlight_add_colour_red or 0) + (self.base_add_colour_red or 0) + (self.flash_val or 0)
        local g = (self.highlight_add_colour_green or 0) + (self.base_add_colour_green or 0) + (self.flash_val or 0)
        local b = (self.highlight_add_colour_blue or 0) + (self.base_add_colour_blue or 0) + (self.flash_val or 0)
        self.inst.AnimState:SetHighlightColour(r, g, b, 0)
        if self.inst.highlightchildren ~= nil then
            for i, v in ipairs(self.inst.highlightchildren) do
                v.AnimState:SetHighlightColour(r, g, b, 0)
            end
        end
    end
end

function Highlight:Highlight(r, g, b)
    self.highlit = true

    if self.inst:IsValid() and self.inst:HasTag("player") or CanEntitySeeTarget(ThePlayer, self.inst) then
        self.highlight_add_colour_red = r or .2
        self.highlight_add_colour_green = g or .2
        self.highlight_add_colour_blue = b or .2
    else
        self.highlight_add_colour_red = nil
        self.highlight_add_colour_green = nil
        self.highlight_add_colour_blue = nil
    end

    if not self.flashing then
        self:ApplyColour()
    end
end

function Highlight:UnHighlight()
    self.highlit = nil
    --self.highlight_add_colour_red = nil
    --self.highlight_add_colour_green = nil
    --self.highlight_add_colour_blue = nil

    if not self.flashing then
        self.inst:RemoveComponent("highlight")
    end
end

function Highlight:OnRemoveFromEntity()
    if self.inst:IsValid() and self.inst.AnimState ~= nil then
        self.inst.AnimState:SetHighlightColour()
        if self.inst.highlightchildren ~= nil then
            for i, v in ipairs(self.inst.highlightchildren) do
                v.AnimState:SetHighlightColour()
            end
        end
    end
end

return Highlight
