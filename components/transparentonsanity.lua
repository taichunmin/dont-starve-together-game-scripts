--NOTE: This is a client side component. No server
--      logic should be driven off this component!

local function PushAlpha(self, alpha, most_alpha)
    self.inst.AnimState:OverrideMultColour(alpha, alpha, alpha, alpha)
    if self.inst.SoundEmitter ~= nil then
        self.inst.SoundEmitter:OverrideVolumeMultiplier(alpha / most_alpha)
    end
	if self.onalphachangedfn ~= nil then
		self.onalphachangedfn(self.inst, alpha, most_alpha)
	end
end

local TransparentOnSanity = Class(function(self, inst)
    self.inst = inst
    self.offset = math.random()
    self.osc_speed = .25 + math.random() * 2
    self.osc_amp = .25 --amplitude
    self.alpha = 0
    self.most_alpha = .4
    self.target_alpha = nil

    PushAlpha(self, 0, .4)
    inst:StartUpdatingComponent(self)

    self.inst.AnimState:UsePointFiltering(true)
end)

function TransparentOnSanity:OnUpdate(dt)
    local player = ThePlayer
    if player == nil then
        self.target_alpha = 0
    elseif self.inst.replica.combat ~= nil and self.inst.replica.combat:GetTarget() == player then
        self.target_alpha = self.most_alpha
    else
        self.offset = self.offset + dt
        self.target_alpha =
            (self.calc_percent_fn and self.calc_percent_fn(self.inst, player) or (1 - player.replica.sanity:GetPercent())) *  --insanity factor
            self.most_alpha *                           --max alpha value
            (1 + self.osc_amp * (math.sin(self.offset * self.osc_speed) - 1)) --variance
    end

    if self.alpha ~= self.target_alpha then
        self.alpha = self.alpha > self.target_alpha and
            math.max(self.target_alpha, self.alpha - dt) or
            math.min(self.target_alpha, self.alpha + dt)
        PushAlpha(self, self.alpha, self.most_alpha)
    end
end

function TransparentOnSanity:GetDebugString()
	return "alpha = "..self.alpha
end

return TransparentOnSanity