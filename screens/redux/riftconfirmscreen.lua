local PopupDialogScreen = require("screens/redux/popupdialog")

local RiftConfirmScreen = Class(PopupDialogScreen, function(self, title, text, buttons)
	PopupDialogScreen._ctor(self, title, text, buttons, nil, "big", "dark_wide")

	self.controldown = {}
	self.tick0 = GetStaticTick()

	SetAutopaused(true)
end)

function RiftConfirmScreen:OnDestroy()
	SetAutopaused(false)
	self._base.OnDestroy(self)
end

function RiftConfirmScreen:OnControl(control, down)
	--NOTE: PopupDialogScreen's base, not our own base (which would just be PopupDialogScreen)
	if PopupDialogScreen._base.OnControl(self, control, down) then return true end

	--Only handle control up if the down was also tracked by us.
	--Otherwise, controllers may open this dialog with (B) down,
	--only to have it instantly cancel itself on (B) up.
	if down then
		if GetStaticTick() - self.tick0 > 1 then
			self.controldown[control] = true
		end
		return false
	elseif not self.controldown[control] then
		return true
	else
		self.controldown[control] = nil
		return self.oncontrol_fn(control, down)
	end
end

return RiftConfirmScreen
