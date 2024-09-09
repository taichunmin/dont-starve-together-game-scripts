local Widget = require("widgets/widget")
local Image = require("widgets/image")

local RainDomeOver =  Class(Widget, function(self, owner)
	Widget._ctor(self, "RainDomeOver")

	self.owner = owner

	self:UpdateWhilePaused(false)
	self:SetClickable(false)
	self:SetHAnchor(ANCHOR_MIDDLE)
	self:SetVAnchor(ANCHOR_MIDDLE)
	self:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)

	self.root = self:AddChild(Widget("RainDomeOver_ROOT"))

	self.bg = self.root:AddChild(Image("images/rain_dome_over.xml", "overlay.tex"))
	self.bg:SetSize(1120, 1080)
	self.bg:SetPosition(0, 60)

	self.domes = nil
	self:Hide()

	self.inst:ListenForEvent("underraindomes", function(owner, domes)
		if self.domes == nil then
			self:Show()
			self:StartUpdating()
		end
		self.domes = domes
	end, owner)

	self.inst:ListenForEvent("exitraindome", function()
		if self.domes ~= nil then
			self.domes = nil
			self:StopUpdating()
			self:Hide()
		end
	end, owner)
end)

function RainDomeOver:OnUpdate(dt)
	local intensity = 0
	local x_total, z_total, weight_total = 0, 0, 0
	local x, y, z = self.owner.Transform:GetWorldPosition()
	for i, v in ipairs(self.domes) do
		if v:IsValid() then
			local x1, y1, z1 = v.Transform:GetWorldPosition()
			local r = v.components.raindome:GetActiveRadius()
			local k = distsq(x, z, x1, z1) / (r * r)
			if k < 1 then
				local weight = 1 - math.sqrt(k)
				weight = weight * weight
				x_total = x_total + x1 * weight
				z_total = z_total + z1 * weight
				weight_total = weight_total + weight
				intensity = math.max(intensity, 1 - k)
			end
		end
	end
	if weight_total > 0 then
		x = x_total / weight_total
		z = z_total / weight_total

		--Convert to screen space
		local w, h = TheSim:GetScreenSize()
		x, y = TheSim:GetScreenPos(x, 0, z)
		self.root:SetPosition((x / w - .5) * RESOLUTION_X, (y / h - .5) * RESOLUTION_Y)

		local scale = Remap(TheCamera.distance, 15, 50, 1, 0)
		scale = .75 + 1.25 * scale * scale
		self.root:SetScale(scale, scale)

		self.bg:SetFadeAlpha(Remap(math.min(intensity, .5), 0, .5, 0, 1))
	else
		self.bg:SetFadeAlpha(0)
	end
end

return RainDomeOver
