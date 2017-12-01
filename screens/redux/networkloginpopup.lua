local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"

local NetworkLoginPopup = Class(GenericWaitingPopup, function(self, onLogin, onCancel, hideOfflineButton)
	GenericWaitingPopup._ctor(self, "NetworkLoginPopup", STRINGS.UI.NOTIFICATION.LOGIN, self:_BuildButtons(hideOfflineButton))
	self.onLogin_cb = onLogin
	self.onCancel_cb = onCancel
end)

function NetworkLoginPopup:_BuildButtons(hideOfflineButton)
    local buttons = {}
    if hideOfflineButton == nil or not hideOfflineButton then
        table.insert(buttons, {
                text=STRINGS.UI.MAINSCREEN.PLAYOFFLINE,
                cb = function() 
                    self:OnLogin(true)
                end
            })
    end
    return buttons
end

function NetworkLoginPopup:OnUpdate( dt )
	local account_manager = TheFrontEnd:GetAccountManager()
	local isWaiting = account_manager:IsWaitingForResponse() 
	local isDownloadingInventory = TheInventory:IsDownloadingInventory()
	
	if not isWaiting and not isDownloadingInventory then
	    self:OnLogin()
	end

    self._base.OnUpdate(self, dt)
end

function NetworkLoginPopup:OnLogin(forceOffline)
	if forceOffline or not self.logged then
		self.logged = true
	    self:Disable()
	    self:StopUpdating()
	    if forceOffline then TheFrontEnd:GetAccountManager():CancelLogin() end
	    self.onLogin_cb(forceOffline)
	end
end

function NetworkLoginPopup:OnCancel()
    -- Ignore base implementation and do it all ourself.
    self:Disable()
	TheFrontEnd:GetAccountManager():CancelLogin()
	TheFrontEnd:PopScreen()
	self.onCancel_cb()
end

return NetworkLoginPopup
