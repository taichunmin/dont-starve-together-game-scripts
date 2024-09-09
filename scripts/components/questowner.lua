local function onquesting(self, questing)
    if questing then
        self.inst:AddTag("questing")
    else
        self.inst:RemoveTag("questing")
    end
end
local function onquestcomplete(self, questcomplete)
    if questcomplete then
        self.inst:AddTag("questcomplete")
    else
        self.inst:RemoveTag("questcomplete")
    end
end

local QuestOwner = Class(function(self, inst)
    self.inst = inst
    self.on_begin_quest = nil
    self.on_abandon_quest = nil
    self.questing = false
	self.questcomplete = false

    --self.CanBeginFn = nil
    --self.CanAbandonFn = nil
end,
nil,
{
    questing = onquesting,
	questcomplete = onquestcomplete,
})

function QuestOwner:SetOnBeginQuest(on_begin_quest)
    self.on_begin_quest = on_begin_quest
end

function QuestOwner:SetOnAbandonQuest(on_abandon_quest)
    self.on_abandon_quest = on_abandon_quest
end

function QuestOwner:SetOnCompleteQuest(on_complete_quest)
    self.on_complete_quest = on_complete_quest
end

function QuestOwner:OnRemoveFromEntity()
    self.inst:RemoveTag("questing")
    self.inst:RemoveTag("questcomplete")
end

function QuestOwner:CanBeginQuest(doer)
    return self.CanBeginFn == nil or self.CanBeginFn(self.inst, doer)
end

function QuestOwner:BeginQuest(doer)
    local begin_message = nil
	self.questcomplete = false
    if self.on_begin_quest ~= nil then
        self.questing, begin_message = self.on_begin_quest(self.inst, doer)
    end
    return self.questing, begin_message
end

function QuestOwner:CanAbandonQuest(doer)
    return self.CanAbandonFn == nil or self.CanAbandonFn(self.inst, doer)
end

function QuestOwner:AbandonQuest(doer)
	if self.questing then
		if self.on_abandon_quest ~= nil then
			local quest_abandoned, abandon_message = self.on_abandon_quest(self.inst, doer)
			if quest_abandoned then
				self.questing = false
			end
			return quest_abandoned, abandon_message
		else
			self.questing = false
			return true
		end
	end
    return nil
end

function QuestOwner:CompleteQuest()
	self.questing = false
	self.questcomplete = true
    if self.on_complete_quest ~= nil then
        self.on_complete_quest(self.inst)
    end
end

function QuestOwner:OnSave()
    local data =
    {
        questing = self.questing,
        questcomplete = self.questcomplete,
    }

    return data
end

function QuestOwner:OnLoad(data)
    if data ~= nil then
        self.questing = data.questing or false
        self.questcomplete = data.questcomplete or false
    end
end

return QuestOwner
