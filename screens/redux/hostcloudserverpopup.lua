local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Text = require "widgets/text"

local phases =
{
    STRINGS.UI.FESTIVALEVENTSCREEN.HOST_DETERMININGREGION,      -- eReadyToRequestServer,
    STRINGS.UI.FESTIVALEVENTSCREEN.HOST_REQUESTINGSERVER,       -- eWaitingForServer,
    STRINGS.UI.FESTIVALEVENTSCREEN.HOST_CONNECTINGTOSERVER,     -- eServerReady,
}

local HostCloudServerPopup = Class(GenericWaitingPopup, function(self, name, description, password, claninfo)
    GenericWaitingPopup._ctor(self, "HostCloudServerPopup", " ")--dummy string so it adds a title widget

    local title = self.dialog.title.parent:AddChild(Text(self.dialog.title.font, self.dialog.title.size, nil, self.dialog.title.colour))
    title:SetPosition(self.dialog.title:GetPosition())
    title:SetHAlign(ANCHOR_MIDDLE)

    local wid = self.dialog.title:GetRegionSize()
    self.dialog.title:Kill()
    self.dialog.title = title

    --V2C: Don't make it a localizable formatted string as we
    --     want exactly this format for truncating long names
    title:SetTruncatedString(STRINGS.UI.FESTIVALEVENTSCREEN.HOST.." - "..name, wid, 53, true)

    self.status_msg = self.dialog:AddChild(Text(CHATFONT, 28, phases[1]))
    self.status_msg:SetRegionSize(530, 28)
    self.status_msg:SetPosition(0, 50)

    --V2C: admin flag is ignored for cloud servers
    local sessionid = "" -- If we want to load a previous session then we need to fill this out
    TheNet:StartCloudServerRequestProcess(sessionid, name, description, LOC.GetLocaleCode(), password, claninfo.id, claninfo.only, claninfo.admin, GetFestivalEventInfo().GAME_MODE)
end)

function HostCloudServerPopup:OnUpdate(dt)
    HostCloudServerPopup._base.OnUpdate(self, dt)

    local cloudServerRequestState = TheNet:GetCloudServerRequestState()
    if cloudServerRequestState == 4 then -- eServerFailed
        self:OnError()
    elseif cloudServerRequestState == 5 then -- eNoServersAvailable
        self:OnError(STRINGS.UI.FESTIVALEVENTSCREEN.HOST_NO_SERVERS_BODY)
    elseif cloudServerRequestState == 6 then -- ePingsFailed
        self:OnError(STRINGS.UI.FESTIVALEVENTSCREEN.HOST_PINGS_FAILED_BODY)
    else
        self.status_msg:SetString(phases[cloudServerRequestState] or "")
    end
end

function HostCloudServerPopup:OnError(body)
    self:Disable()
    self:StopUpdating()

    --push screen b4 popping so parent screen doesn't regain focus momentarily
    TheFrontEnd:PushScreen(PopupDialogScreen(
        STRINGS.UI.FESTIVALEVENTSCREEN.HOST_FAILED,
        body or STRINGS.UI.FESTIVALEVENTSCREEN.HOST_FAILED_BODY,
        { { text = STRINGS.UI.POPUPDIALOG.OK, cb = function() TheFrontEnd:PopScreen() end } }
    ))
    TheFrontEnd:PopScreen(self)
end

function HostCloudServerPopup:OnCancel()
    TheNet:CancelCloudServerRequest()
    TheNet:JoinServerResponse( true ) -- cancel join
    TheNet:Disconnect(false)
    HostCloudServerPopup._base.OnCancel(self)
end

return HostCloudServerPopup
