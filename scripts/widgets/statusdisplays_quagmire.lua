local Widget = require "widgets/widget"
local Badge = require "widgets/badge"
local HealthBadge = require "widgets/healthbadge"
local UIAnim = require "widgets/uianim"


local StatusDisplays = Class(Widget, function(self, owner)
    Widget._ctor(self, "Status")
    self.owner = owner

    self.modetask = nil
    self.isghostmode = false
    self.craft_hide = false
    self.visiblemode = false --force the initial UpdateMode call to be dirty
end)

function StatusDisplays:SetGhostMode(ghostmode)
end

function StatusDisplays:ToggleCrafting(hide)
end

function StatusDisplays:ShowStatusNumbers()
end

function StatusDisplays:HideStatusNumbers()
end

function StatusDisplays:GetResurrectButton()
    return nil
end

return StatusDisplays
