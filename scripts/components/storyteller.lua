
local function on_done_talking(inst)
	local self = inst.components.storyteller
	if self ~= nil then
		self:OnDone()
	end
end

local function on_story_tick(inst)
	local self = inst.components.storyteller
	if self ~= nil then
		self:OnStoryTick()
	end
end

local StoryTeller = Class(function(self, inst)
    self.inst = inst

	--self.storytotellfn = nil

	self.storytelling_dist = 10
	self.storytelling_ticktime = 2.5

	self.inst:AddTag("storyteller")

	self.storyprop_onremove = function(prop)
		self:AbortStory()
	end
end)

function StoryTeller:OnRemoveFromEntity()
	self.inst:RemoveTag("storyteller")
end

function StoryTeller:SetStoryToTellFn(fn)
    self.storytotellfn = fn
end

function StoryTeller:SetOnStoryBeginFn(fn)
	self.onstorybeginfn = fn
end

function StoryTeller:SetOnStoryOverFn(fn)
	self.onstoryoverfn = fn
end

function StoryTeller:IsTellingStory()
	return self.story ~= nil
end

function StoryTeller:AbortStory(reason)
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

function StoryTeller:OnDone()
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

function StoryTeller:OnStoryTick()
	self.story.ontickfn(self.inst, self.story)
end

function StoryTeller:TellStory(storyprop)
	if self.storytotellfn ~= nil and storyprop ~= nil then
		local story = self.storytotellfn(self.inst, storyprop)
		if story == nil or type(story) == "string" then
			return false, story
		end

		self.story = story
		self.story.prop = storyprop

		local lines = {}
		for i, v in ipairs(story.lines) do
			if type(v) == "table" then
				table.insert(lines, { message = v.line, noanim = true, duration = tonumber(v.duration) })
			else
				table.insert(lines, { message = v, noanim = true })
			end
		end

		self.inst.components.talker:Say(lines, nil, true, true)

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

return StoryTeller