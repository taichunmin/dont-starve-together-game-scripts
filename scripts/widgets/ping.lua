local Widget = require "widgets/widget"
local Text = require "widgets/text"

-------------------------------------------------------------------------------------------------------

local ping = "Ping: "

local Ping = Class(Widget, function(self, owner)
    self.owner = owner

    Widget._ctor(self, "Ping")

    self.text = self:AddChild(Text(NUMBERFONT, 30))
    self.text:SetString(ping.."0")
    self.text:SetRegionSize( 300, 50 )
    self.text:SetPosition( 70, -30, 0 )
    self.lastPingVal = nil

    self:StartUpdating()
end)

function Ping:OnUpdate()
    local pingVal = TheNet:GetAveragePing()--self.owner)
    if pingVal < 0 then pingVal = 0 end
    if pingVal ~= self.lastPingVal then
        self.text:SetString(ping..pingVal)
        self.lastPingVal = pingVal
        if self.lastPingVal <= 100 then
            self.text:SetColour(59/255, 242/255, 99/255, 255/255)
        elseif self.lastPingVal <= 300 then
            self.text:SetColour(222/255, 222/255, 99/255, 255/255)
        else
            self.text:SetColour(242/255, 99/255, 99/255, 255/255)
        end
    end
end

return Ping