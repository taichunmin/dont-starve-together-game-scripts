local TIMEOUT = 3

--Keep in sync with worldvoter.lua and shard_worldvoter.lua
local CANNOT_VOTE = 0
local VOTE_PENDING = MAX_VOTE_OPTIONS + 1

local PlayerVoter = Class(function(self, inst)
    self.inst = inst

    self._refreshtask = nil

    if self.ismastersim then
        self.classified = inst.player_classified
    elseif self.classified == nil and inst.player_classified ~= nil then
        self:AttachClassified(inst.player_classified)
    end
end)

--------------------------------------------------------------------------

local function OnVoteChanged(self, sel)
    if self._refreshtask ~= nil then
        self._refreshtask:Cancel()
        self._refreshtask = nil
    end

    self.inst:PushEvent("playervotechanged", {
        selection = sel > CANNOT_VOTE and sel < VOTE_PENDING and sel or nil,
        canvote = sel == VOTE_PENDING,
    })
end

local function Refresh(inst, self)
    self._refreshtask = nil
    OnVoteChanged(self, self.classified ~= nil and self.classified.voteselection:value() or CANNOT_VOTE)
end

--------------------------------------------------------------------------

function PlayerVoter:OnRemoveFromEntity()
    if self._refreshtask ~= nil then
        self._refreshtask:Cancel()
        self._refreshtask = nil
    end
    if self.classified ~= nil then
        if self.ismastersim then
            self.classified = nil
        else
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

PlayerVoter.OnRemoveEntity = PlayerVoter.OnRemoveFromEntity

function PlayerVoter:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.onvoteselectiondirty = function(classified) OnVoteChanged(self, classified.voteselection:value()) end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
    self.inst:ListenForEvent("voteselectiondirty", self.onvoteselectiondirty, classified)
end

function PlayerVoter:DetachClassified()
    self.inst:RemoveEventCallback("voteselectiondirty", self.onvoteselectiondirty, self.classified)
    self.classified = nil
    self.ondetachclassified = nil
    self.onvoteselectiondirty = nil
end

--------------------------------------------------------------------------

function PlayerVoter:SubmitVote(sel)
    if sel > CANNOT_VOTE and
        sel < VOTE_PENDING and
        self.classified ~= nil and
        self.classified.voteselection:value() == VOTE_PENDING then
        --OnVoteChanged already clears any previous refresh tasks
        OnVoteChanged(self, sel)
        self._refreshtask = self.inst:DoTaskInTime(TIMEOUT, Refresh, self)
        TheNet:Vote(sel)
    end
end

function PlayerVoter:SetSelection(sel)
    if self.classified ~= nil and TheWorld.ismastersim then
        self.classified.voteselection:set(sel)
        OnVoteChanged(self, sel)
    end
end

function PlayerVoter:GetSelection()
    return self.classified ~= nil
        and self.classified.voteselection:value() > CANNOT_VOTE
        and self.classified.voteselection:value() < VOTE_PENDING
        and self.classified.voteselection:value()
        or nil
end

function PlayerVoter:HasVoted()
    return self.classified ~= nil
        and self.classified.voteselection:value() > CANNOT_VOTE
        and self.classified.voteselection:value() < VOTE_PENDING
end

function PlayerVoter:CanVote()
    return self.classified ~= nil
        and self.classified.voteselection:value() == VOTE_PENDING
end

function PlayerVoter:SetSquelched(val)
    if self.classified ~= nil and TheWorld.ismastersim then
        self.classified.votesquelched:set(val)
    end
end

function PlayerVoter:IsSquelched()
    return self.classified == nil or self.classified.votesquelched:value()
end

return PlayerVoter
