local GenericWaitingPopup = require "screens/redux/genericwaitingpopup"

local NetworkLoginPopup = Class(GenericWaitingPopup, function(self, onLogin, onCancel, hideOfflineButton)
	GenericWaitingPopup._ctor(self, "NetworkLoginPopup", STRINGS.UI.NOTIFICATION.LOGIN, self:_BuildButtons(hideOfflineButton))
	self.onLogin_cb = onLogin
	self.onCancel_cb = onCancel
	self.inventory_step = INVENTORY_PROGRESS.IDLE
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
	local isLoggingIn = account_manager:IsWaitingForResponse()
	local isDownloadingInventory, inventory_progress = TheInventory:IsDownloadingInventory()

	if not isLoggingIn then
		if isDownloadingInventory then
			if IsConsole() then
				if inventory_progress == INVENTORY_PROGRESS.CHECK_SHOP and self.inventory_step ~= INVENTORY_PROGRESS.CHECK_SHOP then
					self.dialog.title:SetString(STRINGS.UI.NOTIFICATION.CHECK_SHOP)
					self.inventory_step = INVENTORY_PROGRESS.CHECK_SHOP
				elseif inventory_progress == INVENTORY_PROGRESS.CHECK_EVENT and self.inventory_step ~= INVENTORY_PROGRESS.CHECK_EVENT then
					self.dialog.title:SetString(STRINGS.UI.NOTIFICATION.CHECK_SHOP)
					self.inventory_step = INVENTORY_PROGRESS.CHECK_EVENT
				elseif inventory_progress == INVENTORY_PROGRESS.CHECK_DAILY_GIFT and self.inventory_step ~= INVENTORY_PROGRESS.CHECK_DAILY_GIFT then
					self.dialog.title:SetString(STRINGS.UI.NOTIFICATION.CHECK_DAILY_GIFT)
					self.inventory_step = INVENTORY_PROGRESS.CHECK_DAILY_GIFT
				elseif inventory_progress == INVENTORY_PROGRESS.CHECK_COOKBOOK and self.inventory_step ~= INVENTORY_PROGRESS.CHECK_COOKBOOK then
					self.dialog.title:SetString(STRINGS.UI.NOTIFICATION.CHECK_COOKBOOK)
					self.inventory_step = INVENTORY_PROGRESS.CHECK_COOKBOOK
				elseif inventory_progress == INVENTORY_PROGRESS.CHECK_INVENTORY and self.inventory_step ~= INVENTORY_PROGRESS.CHECK_INVENTORY then
					self.dialog.title:SetString(STRINGS.UI.NOTIFICATION.CHECK_INVENTORY)
					self.inventory_step = INVENTORY_PROGRESS.CHECK_INVENTORY
				end
			end
		else
			self:OnLogin()
		end
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
