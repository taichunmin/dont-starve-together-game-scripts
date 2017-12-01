local TALK_TO_OWNER_DISTANCE = 15

local function OnAxePossessedByPlayer(inst, player)
    inst.components.sentientaxe:SetOwner(player)
end

local function OnAxeRejectedOwner(inst, owner)
    inst.components.sentientaxe:Say(STRINGS.LUCY.other_owner)
end

local function OnAxeRejectedOtherAxe(inst, other)
    inst.components.sentientaxe:Say(STRINGS.LUCY.on_woodie_pickedup_other)
    if other.components.sentientaxe.say_task ~= nil then
        other.components.sentientaxe.say_task:Cancel()
        other.components.sentientaxe.say_task = nil
    end
end

local SentientAxe = Class(function(self, inst)
    self.inst = inst
    self.owner = nil
    self.convo_task = nil
    self.say_task = nil
    self.warnlevel = 0
    self.waslow = false

    self._onfinishedwork = function(owner, data) self:OnFinishedWork(data.target, data.action) end
    self._onbeavernessdelta = function(owner, data) self:OnBeavernessDelta(data.oldpercent, data.newpercent) end
    self._onstartbeaver = function() self:OnBecomeBeaver() end
    self._onstopbeaver = function() self:OnBecomeHuman() end

    inst:ListenForEvent("axepossessedbyplayer", OnAxePossessedByPlayer)
    inst:ListenForEvent("axerejectedowner", OnAxeRejectedOwner)
    inst:ListenForEvent("axerejectedotheraxe", OnAxeRejectedOtherAxe)
end)

local function toground(inst)
    inst.components.sentientaxe:Say(STRINGS.LUCY.on_dropped, nil, 2 * FRAMES)
end

local function onequipped(inst, data)
    local self = inst.components.sentientaxe
    if self.owner ~= nil and self.owner == data.owner then
        self:Say(STRINGS.LUCY.on_pickedup)
    end
end

function SentientAxe:SetOwner(owner)
    if self.owner ~= owner then
        if self.say_task ~= nil then
            self.say_task:Cancel()
            self.say_task = nil
        end
        if self.convo_task ~= nil then
            self.convo_task:Cancel()
            self.convo_task = nil
        end
        if self.owner ~= nil then
            self.inst:RemoveEventCallback("ondropped", toground)
            self.inst:RemoveEventCallback("equipped", onequipped)
            self.inst:RemoveEventCallback("finishedwork", self._onfinishedwork, self.owner)
            self.inst:RemoveEventCallback("beavernessdelta", self._onbeavernessdelta, self.owner)
            self.inst:RemoveEventCallback("startbeaver", self._onstartbeaver, self.owner)
            self.inst:RemoveEventCallback("stopbeaver", self._onstopbeaver, self.owner)
        end
        self.owner = owner
        self.warnlevel = 0
        self.waslow = false
        if owner ~= nil then
            self.inst:ListenForEvent("ondropped", toground)
            self.inst:ListenForEvent("equipped", onequipped)
            self.inst:ListenForEvent("finishedwork", self._onfinishedwork, owner)
            self.inst:ListenForEvent("beavernessdelta", self._onbeavernessdelta, owner)
            self.inst:ListenForEvent("startbeaver", self._onstartbeaver, owner)
            self.inst:ListenForEvent("stopbeaver", self._onstopbeaver, owner)
            if self.inst.components.equippable:IsEquipped() then
                self:Say(STRINGS.LUCY.on_pickedup)
            end
            self:ScheduleConversation()
        end
    end
end

function SentientAxe:OnFinishedWork(target, action)
    if self.owner ~= nil and
        action == ACTIONS.CHOP and
        self.inst.components.equippable:IsEquipped() and
        self.owner.components.beaverness ~= nil and
        self.owner.components.beaverness:GetPercent() > .7 then
        self:Say(STRINGS.LUCY.on_chopped)
    end
end

local beaverness_thresholds = {
    {
        val = 0.74,
        up_strings = STRINGS.LUCY.beaver_up_waslow,
        needs_low = true, -- this will only trigger if low had been latched to true
        low = false, -- latch low to false
    },
    {
        val = 0.5833,
        down_strings = STRINGS.LUCY.beaver_down_early,
        down_audio = "dontstarve/characters/woodie/lucy_warn_1",
    },
    {
        val = 0.4167,
        down_strings = STRINGS.LUCY.beaver_down_mid,
        down_audio = "dontstarve/characters/woodie/lucy_warn_2",
        low = true, -- latch low to true
    },
    {
        val = .30,
        down_strings = STRINGS.LUCY.beaver_down_late,
        down_audio = "dontstarve/characters/woodie/lucy_warn_3",
    },
}

function SentientAxe:OnBeavernessDelta(old, new)
    if not self.inst.components.inventoryitem:IsHeld() then
        return
    else
        for i,threshold in ipairs(beaverness_thresholds) do

            if threshold.down_strings and old >= threshold.val and new < threshold.val then
                self:Say(threshold.down_strings, threshold.down_audio, FRAMES)
                if threshold.low ~= nil then
                    self.waslow = threshold.low
                end
                break
            end

            if threshold.up_strings and old <= threshold.val and new > threshold.val then
                if not threshold.needs_low or self.waslow then
                    self:Say(threshold.up_strings, threshold.up_audio, FRAMES)
                end
                if threshold.low ~= nil then
                    self.waslow = threshold.low
                end
                break
            end

        end
    end
end

function SentientAxe:OnBecomeHuman()
    if self.owner ~= nil and self.owner:IsNear(self.inst, TALK_TO_OWNER_DISTANCE) then
        self:Say(STRINGS.LUCY.transform_woodie)
    elseif self.say_task ~= nil then
        self.say_task:Cancel()
        self.say_task = nil
    end
end

function SentientAxe:OnBecomeBeaver()
    if self.owner ~= nil and self.owner:IsNear(self.inst, TALK_TO_OWNER_DISTANCE) then
        self:Say(STRINGS.LUCY.transform_beaver, "dontstarve/characters/woodie/lucy_transform")
    elseif self.say_task ~= nil then
        self.say_task:Cancel()
        self.say_task = nil
    end
end

local function OnSay(inst, self, list, sound_override)
    self.say_task = nil
    --Use ShouldMakeConversation check for delayed speech
    if self:ShouldMakeConversation() then
        self:Say(list, sound_override)
    end
end

function SentientAxe:Say(list, sound_override, delay)
    if self.say_task ~= nil then
        self.say_task:Cancel()
        self.say_task = nil
    end
    if delay ~= nil then
        self.say_task = self.inst:DoTaskInTime(delay, OnSay, self, list, sound_override)
        return
    end

    if self.inst.lucy_classified ~= nil then
        self.inst.lucy_classified:Say(list, math.random(#list), sound_override)
    end
    if self.owner ~= nil then
        self:ScheduleConversation(60 + math.random() * 60)
    end
end

local function OnMakeConvo(inst, self)
    self.convo_task = nil
    self:MakeConversation()
end

function SentientAxe:ShouldMakeConversation()
    return self.owner ~= nil
        and not (self.owner.components.health ~= nil and
                self.owner.components.health:IsDead())
        and not (self.owner.sg:HasStateTag("transform") or
                self.owner:HasTag("beaver") or
                self.owner:HasTag("playerghost"))
end

function SentientAxe:ScheduleConversation(delay)
    if self.convo_task ~= nil then
        self.convo_task:Cancel()
    end
    self.convo_task = self.inst:DoTaskInTime(delay or 10 + math.random() * 5, OnMakeConvo, self)
end

function SentientAxe:MakeConversation()
    if self.owner == nil then
        return
    elseif not self:ShouldMakeConversation() then
        self:ScheduleConversation()
        return
    end

    local owner = self.inst.components.inventoryitem.owner
    if owner == nil then
        --on the ground
        if self.owner:IsNear(self.inst, TALK_TO_OWNER_DISTANCE) then
            self:Say(STRINGS.LUCY.on_ground)
        end
    elseif self.inst.components.equippable:IsEquipped() then
        --equipped
        self:Say(STRINGS.LUCY.equipped)
    elseif owner.components.inventoryitem ~= nil and owner.components.inventoryitem.owner == self.owner then
        --in backpack
        self:Say(STRINGS.LUCY.in_container)
    end

    self:ScheduleConversation()
end

return SentientAxe
