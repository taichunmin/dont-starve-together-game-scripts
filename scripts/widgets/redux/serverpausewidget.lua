local Widget = require "widgets/widget"
local Text = require "widgets/text"

local ServerPauseWidget = Class(Widget, function(self)
    Widget._ctor(self, "ServerPauseWidget")

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_TOP)

    self.root = self:AddChild(Widget("Root"))

    self.text = self.root:AddChild(Text(UIFONT, 60))
    self.text:SetPosition(0, -45)
end)

function ServerPauseWidget:UpdateText(source)
    self:Show()
    if source == "autopause" then
        self.text:SetString(STRINGS.UI.PAUSEMENU.AUTOPAUSE_TEXT)
    elseif source == "[Host]" then
        self.text:SetString(STRINGS.UI.PAUSEMENU.HOSTPAUSED_TEXT)
    elseif source == TheNet:GetLocalUserName() then
        self.text:SetString(STRINGS.UI.PAUSEMENU.SELFPAUSED_TEXT)
    elseif source ~= nil then
        self.text:SetString(subfmt(STRINGS.UI.PAUSEMENU.PLAYERPAUSED_TEXT, {player = source}))
    else
        self.text:SetString("")
        self:Hide()
    end
end

function ServerPauseWidget:SetOffset(x, y)
    self.root:SetPosition(x, y)
end

return ServerPauseWidget