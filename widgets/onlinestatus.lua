local Widget = require "widgets/widget"
local Text = require "widgets/text"

-------------------------------------------------------------------------------------------------------
local DEBUG_MODE = BRANCH == "dev"

local OnlineStatus = Class(Widget, function(self, show_borrowed_info )
    Widget._ctor(self, "OnlineStatus")

	self.show_borrowed_info = show_borrowed_info

    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.text = self.fixed_root:AddChild(Text(NEWFONT_OUTLINE, 20))
    self.text:SetPosition(378, 345)
    self.text:SetHAlign(ANCHOR_RIGHT)
    self.text:SetRegionSize(300,40)

    self.debug_connections = self.fixed_root:AddChild(Text(NEWFONT_OUTLINE, 20, nil, UICOLOURS.GREY))
    self.debug_connections:SetPosition(90, 345)

    self:StartUpdating()
end)

function OnlineStatus:OnUpdate()
	if self.show_borrowed_info and TheSim:IsBorrowed() then
		self.text:SetString(STRINGS.UI.MAINSCREEN.FAMILY_SHARED)
        self.text:SetColour(80/255, 143/255, 244/255, 255/255)
        self.text:Show()
    end

    -- If you're offline I guess it doesn't matter that you're borrowed?
    if TheFrontEnd:GetIsOfflineMode() or not TheSim:IsLoggedOn() then
        self.text:SetString(STRINGS.UI.MAINSCREEN.OFFLINE)
        self.text:SetColour(242/255, 99/255, 99/255, 255/255)
        self.text:Show()
    end

    if DEBUG_MODE then
        self.debug_connections:SetString(string.format("%s %s",
                TheNet:IsOnlineMode() and "Connected" or "Offline",
                TheNet:GetIsServer() and "as Host" or ""
            ))
    end
end

return OnlineStatus
