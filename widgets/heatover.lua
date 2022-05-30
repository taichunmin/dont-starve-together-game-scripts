local Widget = require "widgets/widget"
local Image = require "widgets/image"


local HeatOver = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "HeatOver")
	self:SetClickable(false)

	self.img = self:AddChild(Image("images/fx2.xml", "heat_over.tex"))
	self.img:SetEffect( "shaders/overheat.ksh" )
    self.img:SetHAnchor(ANCHOR_MIDDLE)
    self.img:SetVAnchor(ANCHOR_MIDDLE)
    self.img:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.img:SetBlendMode(BLENDMODE.Additive)
    self.img:SetUVScale(1.05, 1.0)

    self:Hide()
    self.laststep = 0

    self.alpha_min = 1.0
    self.alpha_min_target = 1.0
    self.effectTime = 0.0
    self.effectSize = 0.0
    self.effectSize_target = 0.0
    self.effectFrequency = 0.0
    self.effectFrequency_target = 0.0
    self.effectSpeed = 0.0
    --self.effectSpeed_target = 0.0
	self:StartUpdating()

    self.inst:ListenForEvent("temperaturedelta", function() self:OnHeatChange() end, self.owner)
end)

function HeatOver:OnHeatChange()
	local temp = self.owner.components.temperature ~= nil
        and self.owner.components.temperature:GetCurrent()
        or (self.owner.player_classified ~= nil and
            self.owner.player_classified.currenttemperature or TUNING.STARTING_TEMP)

	local num_steps = 4

	local all_up_thresh = {65, 70, 75, 80}

	local heat_sounds =
	{
		"dontstarve_DLC001/common/HUD_hot_level1",
		"dontstarve_DLC001/common/HUD_hot_level2",
		"dontstarve_DLC001/common/HUD_hot_level3",
		"dontstarve_DLC001/common/HUD_hot_level4",
	}
	local heat_sounds_names =
	{
		"HUD_hot_level1",
		"HUD_hot_level2",
		"HUD_hot_level3",
		"HUD_hot_level4",
	}
	--local all_down_thresh = {8, 3, -2, -7}

	local up_thresh = all_up_thresh[self.laststep+1]
	local down_thresh = all_up_thresh[self.laststep]

	local isup = false
	while all_up_thresh[self.laststep+1] ~= nil and
		temp > all_up_thresh[self.laststep+1] and
		self.laststep < num_steps and
		(temp >= 65 or TheWorld.state.issummmer) do

		self.laststep = self.laststep + 1
		isup = true
	end

	if isup then
		 -- Check if the sound is playing so it doesn't get spammed when temp dances back and forth across the threshold
		if not TheFrontEnd:GetSound():PlayingSound(heat_sounds_names[self.laststep]) then
			TheFrontEnd:GetSound():PlaySound(heat_sounds[self.laststep], heat_sounds_names[self.laststep])
		end
	else
		while all_up_thresh[self.laststep] ~= nil and
			temp < all_up_thresh[self.laststep] and
			self.laststep > 0 do

			self.laststep = self.laststep - 1
		end
	end

	if self.laststep == 0 then
		self.alpha_min_target = 1
	else
		local alpha_mins =
		{
			.4, .3, .1, 0
		}
		self.alpha_min_target = alpha_mins[self.laststep]
		local distortion_size =
		{
		    0.01, 0.011, 0.012, 0.013
		    --0.01, 0.01, 0.01, 0.01
		}
		self.effectSize_target = distortion_size[self.laststep]
		local distortion_frequency =
		{
		    10, 13, 17, 20
		}
		self.effectFrequency_target = distortion_frequency[self.laststep]
		local distortion_speed =
		{
		    -- keep this value constant for now as both lerping and stepping it produce ugly artifacts
		    7, 7, 7, 7
		}
		self.effectSpeed = distortion_speed[self.laststep]
		--self.effectSpeed_target = distortion_speed[self.laststep]
		self:StartUpdating()
	end
end

function HeatOver:OnUpdate(dt)
	local lspeed = dt
	self.alpha_min = (1 - lspeed) * self.alpha_min + lspeed *self.alpha_min_target
	self.img:SetAlphaRange(self.alpha_min,1)
	if self.alpha_min >= .99 then
		self:Hide()
		self:StopUpdating()
	else
		self:Show()
	end
	self.effectTime = self.effectTime + dt
	self.effectSize = (1 - lspeed) * self.effectSize + lspeed *self.effectSize_target
	self.effectFrequency = (1 - lspeed) * self.effectFrequency + lspeed *self.effectFrequency_target
	--self.effectSpeed = (1 - lspeed) * self.effectSpeed + lspeed *self.effectSpeed_target
	self.img:SetEffectParams(self.effectTime, self.effectSize, self.effectFrequency, self.effectSpeed)
end

return HeatOver