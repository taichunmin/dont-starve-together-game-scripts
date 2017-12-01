local Widget = require "widgets/widget"
local Image = require "widgets/image"

local Tab = Class(Widget, function(self, tabgroup, name, atlas, icon_atlas, icon, imnorm, imselected, imhighlight, imalthighlight, imoverlay, selectfn, deselectfn, collapsed)
    Widget._ctor(self, "Tab")
    self.group = tabgroup
    self.atlas = atlas
    self.icon_atlas = icon_atlas
    self.selectfn = selectfn
    self.deselectfn = deselectfn
    self.collapsed = collapsed
    self.imnormal = imnorm
    self.imselected = imselected
    self.imhighlight = imhighlight
    self.imalthighlight = imalthighlight
    self.basescale = .5
    self.selected = false
    self.highlighted = false
    self:SetTooltip(name)
    self:SetScale(self.basescale,self.basescale,self.basescale)

    self.bg = self:AddChild(Image(atlas, imnorm))
    local w, h = self.bg:GetSize()

    self.bg:SetPosition(w/2,0,0)
    self.icon = self:AddChild(Image(icon_atlas, icon))
    self.icon:SetClickable(false)
    self.icon:SetPosition(w/2,0,0)

    self.overlay = self:AddChild(Image(atlas, imoverlay))
    self.overlay:SetPosition(w/2,0,0)
    self.overlay:Hide()
    self.overlay:SetClickable(false)
end)

function Tab:OnControl(control, down)
    if Tab._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_ACCEPT then
        if self.selected then
            self:Deselect()
        else
            self:Select()
        end

        self.group:OnTabsChanged()
        return true
    end
end

function Tab:Overlay()
    if not self.overlayshow then
        self.overlayshow = true
        self.overlay:Show()
        local delay = self.group.onoverlay ~= nil and self.group.onoverlay() or nil

        local applychange = function()
            self:ScaleTo(2 * self.basescale, self.selected and 1.25 * self.basescale or self.basescale, .25)
            self.overlay:Show()
        end

        if delay ~= nil then
            scheduler:ExecuteInTime(delay, applychange)
        else
            applychange()
        end
    end
end

function Tab:HideOverlay()
    self.overlayshow = false
    self.overlay:Hide()
end

function Tab:Highlight(num, instant, alt)
    local change_scale = self.highlightnum == nil or self.highlightnum < num
    local change_texture = not self.selected and (not alt == not self.highlighted or not alt ~= not self.alternatehighlighted)

    self.alternatehighlighted = alt
    self.highlighted = not alt
    self.highlightnum = num

    if change_texture or change_scale then
        local delay = not instant and self.group.onhighlight ~= nil and self.group.onhighlight() or nil

        local applychange = function()
            if change_texture then
                self.bg:SetTexture(self.atlas, alt and self.imalthighlight or self.imhighlight)
            end

            if change_scale and not instant then
                self:ScaleTo(2 * self.basescale, self.selected and 1.25 * self.basescale or self.basescale, .25)
            end
        end

        if delay ~= nil then
            scheduler:ExecuteInTime(delay, applychange)
        else
            applychange()
        end
    end
end

function Tab:AlternateHighlight(num, instant)
    self:Highlight(num, instant, true)
end

function Tab:UnHighlight(instant)
    if not self.selected then
        self.bg:SetTexture(self.atlas, self.imnormal)
    end

    if not instant and (self.highlighted or self.alternatehighlighted) then
        self:ScaleTo(.75 * self.basescale, self.selected and 1.25 * self.basescale or self.basescale, .33)
    end

    self.highlighted = false
    self.alternatehighlighted = false
    self.highlightnum = nil
end

function Tab:Deselect()
    if self.selected then
        self:ScaleTo(1.25 * self.basescale, self.basescale, .125)

        if self.deselectfn ~= nil then
            self.deselectfn(self)
        end

        self.bg:SetTexture(self.atlas,
            (self.highlighted and self.imhighlight) or
            (self.alternatehighlighted and self.imalthighlight) or
            self.imnormal
        )
        self.selected = false
    end
end

function Tab:Select()
    if not self.selected then
        self:ScaleTo(self.basescale, 1.25 * self.basescale, .25)
        self.group:DeselectAll()

        if self.selectfn ~= nil then
            self.selectfn(self)
        end

        self.bg:SetTexture(self.atlas, self.imselected)
        self.selected = true
    end
end

return Tab
