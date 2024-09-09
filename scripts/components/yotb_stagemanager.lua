local YOTB_StageManager = Class(function(self, inst)
    self.inst = inst
    self.stages = {}

    self.contest_enabled = false
    self.contest_active = false
    self.save_contest = false

    --"yotb_onstagebuilt", {throne = inst}
    self.inst:ListenForEvent("yotb_onstagebuilt", function(inst, data)
    	if data and data.stage then
			self:OnStageBuilt(data.stage)
    	end
	end)
    self.inst:ListenForEvent("yotb_onabortcontest", function(inst, data)
    	self.contest_active = false
    	self.active_stage = nil
	end)

    self.inst:ListenForEvent("yotb_oncontestfinshed", function(inst, data)
    	self:OnContestEnded()
	end)
	self.inst:WatchWorldState("cycles", function() self:OnNewDay() end)
end)

local function conteststarted(stage)
	local manager = TheWorld.components.yotb_stagemanager
	manager:OnContestBegun(stage)
end

local function contestfinished(stage)
	local manager = TheWorld.components.yotb_stagemanager
	manager:OnContestEnded(stage)
end

local function stageremoved(stage)
	local manager = TheWorld.components.yotb_stagemanager
	manager:OnStageDestroyed(stage)
end

local function contestcheckpoint(stage)
	local manager = TheWorld.components.yotb_stagemanager
	manager:OnContestCheckPoint(stage)
end

function YOTB_StageManager:OnNewDay()
	if not self.contest_active and not self.contest_enabled then
		self:EnableContest()
	end
end

function YOTB_StageManager:OnStageBuilt(stage)
	table.insert(self.stages, stage)

	self.inst:ListenForEvent("conteststarted", conteststarted, stage)
	self.inst:ListenForEvent("contestcheckpoint", contestcheckpoint, stage)
--	self.inst:ListenForEvent("contestfinished", contestfinished, stage)
	self.inst:ListenForEvent("onremove", stageremoved, stage)

	if self.contest_enabled then
		stage.components.yotb_stager:EnableContest()
	end
end

function YOTB_StageManager:OnStageDestroyed(stage)

	self.inst:RemoveEventCallback("conteststarted", conteststarted, stage)
	self.inst:RemoveEventCallback("contestcheckpoint", contestcheckpoint, stage)
--	self.inst:RemoveEventCallback("contestfinished", contestfinished, stage)
	self.inst:RemoveEventCallback("onremove", stageremoved, stage)

	for i,v in ipairs(self.stages) do
		if v == stage then
			table.remove(self.stages, i)
			break
		end
	end
end

function YOTB_StageManager:OnContestCheckPoint(stage)
	self.save_contest = true
end

function YOTB_StageManager:IsContestActive()
	return self.contest_active
end

function YOTB_StageManager:IsContestEnabled()
	return self.contest_enabled
end

function YOTB_StageManager:SetContestEnabled(setting)
	self.contest_enabled = setting
end

function YOTB_StageManager:EnableContest()

	if self.contest_active then
		print ("TRYING TO ENABLE CONTEST WHILE A CONTEST IS ALREADY ACTIVE. NOT ALLOWED")
		return
	end

	self.contest_enabled = true
	for i,v in ipairs(self.stages) do
		if v:IsValid() then
			v.components.yotb_stager:EnableContest()
		end
	end

	self.inst:PushEvent("yotb_contestenabled")
end

function YOTB_StageManager:OnContestBegun(active_stage)
	self.active_stage = active_stage
	--self.contest_enabled = false
	self.contest_active = true

	for i,v in ipairs(self.stages) do
		if v ~= active_stage and v:IsValid() then
			v.components.yotb_stager:DisableContest()
		end
	end

	--self.contest_timer = self.inst:DoTaskInTime(TUNING.TOTAL_DAY_TIME, function() self:EnableContest() end)
	self.inst:PushEvent("yotb_conteststarted")
end

function YOTB_StageManager:OnContestEnded()
	self.contest_active = false
	self.save_contest = false
	self.active_stage = nil

	self.inst:PushEvent("yotb_contestfinished")
end

function YOTB_StageManager:GetActiveStage()
	return self.active_stage
end


function YOTB_StageManager:OnSave()
	local data = {}
	local ents = {}

	data.contest_enabled = self.enabletask ~= nil or self.contest_enabled
	data.contest_active = self.contest_active and self.save_contest

	if #self.stages > 0 then
		data.stages = {}

		for i,v in ipairs(self.stages) do
			table.insert(ents, v.GUID)
			table.insert(data.stages, v.GUID)
		end
	end

	return data, ents
end

function YOTB_StageManager:LoadPostPass(newents, savedata)

	if savedata.stages then
		self.stages = {}
		for i,v in ipairs(savedata.stages) do
			self:OnStageBuilt(newents[v].entity)
		end
	end

	self.contest_enabled = savedata.contest_enabled
	self.contest_active = savedata.contest_active

	if self.contest_enabled and not self.contest_active then
		self:EnableContest()
	end
end

return YOTB_StageManager