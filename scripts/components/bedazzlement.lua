local Bedazzlement = Class(function(self, inst)
    self.inst = inst
end)

function Bedazzlement:Start()

	if self.inst:HasTag("bedazzled") then
		return
	end

	self.inst:AddTag("bedazzled")
	self.inst.AnimState:ShowSymbol("bedazzled_flare")

	self.inst.AnimState:PlayAnimation(self.inst.anims.bedazzle, false)
	self.inst.AnimState:PushAnimation(self.inst.anims.idle, true)

	self.inst.SoundEmitter:PlaySound("webber2/common/spiderden/bedazzle")

	self.inst.components.growable:StopGrowing()

	self.inst.MiniMapEntity:SetIcon("spiderden_bedazzled.png")

	if self.inst:GetCurrentPlatform() == nil then
		-- Delaying this a frame to fix a loading issue
		self.inst:DoTaskInTime(0, function() 
			self.inst.GroundCreepEntity:SetRadius(TUNING.SPIDERDEN_CREEP_RADIUS_BEDAZZLED)
		end)
    end

	if self.bedazzle_task ~= nil then
		self.bedazzle_task:Cancel()
		self.bedazzle_task = nil
	end

	self.bedazzle_task = self.inst:DoPeriodicTask(TUNING.BEDAZZLEMENT_RATE, function() self:PacifySpiders() end)
end

function Bedazzlement:Stop()
	if not self.inst:HasTag("bedazzled") then
		return
	end

	self.inst.SoundEmitter:PlaySound("webber2/common/spiderden/downgrade")--- hugo

	self.inst:RemoveTag("bedazzled")
	self.inst.AnimState:HideSymbol("bedazzled_flare")

	self.inst.MiniMapEntity:SetIcon("spiderden_" .. tostring(self.inst.data.stage) .. ".png")

	if self.inst:GetCurrentPlatform() == nil then
		self.inst.components.growable:StartGrowing()
        self.inst.GroundCreepEntity:SetRadius(TUNING.SPIDERDEN_CREEP_RADIUS[self.inst.data.stage])
    end

    if self.inst.shaving then
    	self.inst.shaving = nil
    end

	if self.bedazzle_task ~= nil then
		self.bedazzle_task:Cancel()
		self.bedazzle_task = nil
	end
end

function Bedazzlement:PacifySpiders()
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local den_tier = self.inst.components.growable ~= nil and self.inst.components.growable:GetStage() or 1

	if den_tier > 3 then
		den_tier = 3
	end

    local ents = TheSim:FindEntities(x, y, z, TUNING.BEDAZZLEMENT_RADIUS[den_tier], {"spider"}, {"spiderqueen"})

    for k, spider in pairs(ents) do
		spider:AddDebuff("bedazzle_buff", "bedazzle_buff")
    end
end

function Bedazzlement:OnSave()
    local data = {}
    if self.inst:HasTag("bedazzled") then
    	data.bedazzled = true
    end

    return data
end

function Bedazzlement:OnLoad(data)
	if data and data.bedazzled then
		self.inst:DoTaskInTime(0, function() self:Start() end)
	end
end

return Bedazzlement