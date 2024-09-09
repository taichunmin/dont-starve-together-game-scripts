local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"

local LaunchingServerPopup = Class(GenericWaitingPopup, function(self, serverinfo, successCallback, errorCallback)
    GenericWaitingPopup._ctor(self, "LaunchingServerPopup", STRINGS.UI.NOTIFICATION.LAUNCHING_SERVER, nil, IsConsole())

    self.serverinfo = serverinfo
    self.successCallback = successCallback
    self.errorCallback = errorCallback
    self.launchtime = GetStaticTime()
	self.errorStartingServers = false
end)

function LaunchingServerPopup:OnUpdate( dt )
    self._base.OnUpdate(self, dt)

    local status = TheNet:GetChildProcessStatus()
	local hasError = TheNet:GetChildProcessError() or self.errorStartingServers
    -- 0 : not starting, not existing
    -- 1 : process is starting
    -- 2 : worldgen
    -- 3 : ready to accept connection
    --print("STATUS IS ", status);

	if hasError then
        if self.worldgenscreen and TheFrontEnd:GetActiveScreen() == self.worldgenscreen then
            TheFrontEnd:PopScreen()
        end

        if TheFrontEnd:GetActiveScreen() == self then
            TheFrontEnd:PopScreen()
        end

		self.errorCallback()

	elseif status == 0 or status == 1 then
        -- keep waiting
	elseif status == 2 then
        self.dialog.title:SetString(STRINGS.UI.NOTIFICATION.SERVER_WORLDGEN)
        --if self.worldgenscreen == nil then
            --self.worldgenscreen = TheFrontEnd:PushScreen(WorldGenScreen())
        --end
    elseif status == 3 then
        --if self.worldgenscreen and TheFrontEnd:GetActiveScreen() == self.worldgenscreen then
            --TheFrontEnd:PopScreen()
        --end
        if TheFrontEnd:GetActiveScreen() == self then
            TheFrontEnd:PopScreen()
        end
        self.successCallback(self.serverinfo)
    end

end

function LaunchingServerPopup:OnCancel()
    -- Ignore base implementation and do it all ourself.
    self:Disable()

    TheSystemService:StopDedicatedServers()
    TheFrontEnd:PopScreen()
end

function LaunchingServerPopup:SetErrorStartingServers()
    self.errorStartingServers = true
end

return LaunchingServerPopup
