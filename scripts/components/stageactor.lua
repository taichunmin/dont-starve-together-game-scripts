
local function on_done_talking(inst)
	local self = inst.components.stageactor
	if self ~= nil then
		self:OnDone()
	end
end

local function on_story_tick(inst)
	local self = inst.components.stageactor
	if self ~= nil then
		self:OnStoryTick()
	end
end

local StageActor = Class(function(self, inst)
    self.inst = inst

	self.storytelling_dist = 10
	self.storytelling_ticktime = 2.5

    --self.stage = nil

	self.inst:AddTag("stageactor")

	self.storyprop_onremove = function(prop)
		self:AbortStory()
	end
end)

function StageActor:OnRemoveFromEntity()
    self.inst:RemoveTag("stageactor")
end

function StageActor:performedplay(story_id)
	if not self.previous_acts then
		self.previous_acts	= {}
	end
	table.insert(self.previous_acts,story_id)
end

function StageActor:performplay()
    local monologues = deepcopy(STRINGS.STAGEACTOR["GENERIC"])
    local player_monologues = STRINGS.STAGEACTOR[string.upper(self.inst.prefab)] or nil

    if player_monologues then
        for i,set in pairs(player_monologues)do
            monologues[i] = set
        end
    end

    local count = 0
    for i,set in pairs(monologues)do
        count = count +1
    end
    if self.previous_acts then
        if #self.previous_acts >= count then
            self.previous_acts = nil
        else
            for i,set in ipairs(self.previous_acts) do
                monologues[set] = nil
            end
        end
    end

    if monologues ~= nil then
        local story_id = GetRandomKey(monologues)
        self:performedplay(story_id)
        return { style = "CAMPFIRE", id = story_id, lines = monologues[story_id].lines }
    end
end

function StageActor:SetOnStoryBeginFn(fn)
	self.onstorybeginfn = fn
end

function StageActor:SetOnStoryOverFn(fn)
	self.onstoryoverfn = fn
end

function StageActor:IsTellingStory()
	return self.story ~= nil
end

function StageActor:AbortStory(reason)
	if self.inst.components.talker ~= nil then
		if reason then
			self.inst.components.talker:Say(reason)
		else
			self.inst.components.talker:ShutUp()
		end
	else
		self:OnDone()
	end
end

function StageActor:OnDone()
	self.inst:RemoveEventCallback("donetalking", on_done_talking)

	if self.onstoryticktask ~= nil then
		self.onstoryticktask:Cancel()
		self.onstoryticktask = nil
	end

	if self.onstoryoverfn ~= nil then
		self.onstoryoverfn(self.inst, self.story)
	end

	self.story = nil
end

function StageActor:OnStoryTick()
	self.story.ontickfn(self.inst, self.story)
end

local STAGE_LISTENER_ONEOF = { "stage", "stagelistener" }
function StageActor:TellStory(storyprop, story)
	if storyprop ~= nil then
		local story = story or self:performplay()

		if story == nil or type(story) == "string" then
			return false, story
		end

		self.story = story
		self.story.prop = storyprop

		local lines = {}

		for i, v in ipairs(story.lines) do
			if type(v) == "table" then
				table.insert(lines, { message = GetLine(self.inst, v.line), noanim = true, duration = tonumber(v.duration) })
			else
				table.insert(lines, { message = GetLine(self.inst, v), noanim = true })
			end
		end

		local function onfinishedfn(inst, data)
		    local x,y,z = self.inst.Transform:GetWorldPosition()
	        local ents = TheSim:FindEntities(x,y,z, 10, nil, nil, STAGE_LISTENER_ONEOF)
	        for i, ent in ipairs(ents)do
	            ent:PushEvent("play_performed")
	        end
    	end

		self.inst.components.talker:Say(lines, nil, true, nil, nil, nil, nil, nil, onfinishedfn) -- GetSpecialCharacterString(self.inst) or 

		if self.story.ontickfn then
			self.onstoryticktask = self.inst:DoPeriodicTask(self.story.ticktime or self.storytelling_ticktime, on_story_tick)
		end
		self.inst:ListenForEvent("donetalking", on_done_talking)
		self.inst:ListenForEvent("onremove", self.storyprop_onremove, storyprop)

		if self.onstorybeginfn ~= nil then
			self.onstorybeginfn(self.inst, self.story)
		end

		return true
	end

	return false
end

function StageActor:SetStage(stage)
    self.stage = stage
end

function StageActor:GetStage(stage)
    return self.stage
end

function StageActor:OnSave()
	local data = {
		previous_acts = self.previous_acts
	}	
	return data
end

function StageActor:OnLoad(data)
	if data then
		if data.previous_acts then
			self.previous_acts = data.previous_acts
		end
    end
end

return StageActor