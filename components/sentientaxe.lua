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
    self._onwereeaterchanged = function(owner, data) self:OnWereEaterChanged(data.old, data.new, data.istransforming) end
    self._onstartwereplayer = function() self:OnBecomeWere() end
    self._onstopwereplayer = function() self:OnBecomeHuman() end

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
            self.inst:RemoveEventCallback("wereeaterchanged", self._onwereeaterchanged, self.owner)
            self.inst:RemoveEventCallback("startwereplayer", self._onstartwereplayer, self.owner)
            self.inst:RemoveEventCallback("stopwereplayer", self._onstopwereplayer, self.owner)
        end
        self.owner = owner
        self.warnlevel = 0
        self.waslow = false
        if owner ~= nil then
            self.inst:ListenForEvent("ondropped", toground)
            self.inst:ListenForEvent("equipped", onequipped)
            self.inst:ListenForEvent("finishedwork", self._onfinishedwork, owner)
            self.inst:ListenForEvent("wereeaterchanged", self._onwereeaterchanged, owner)
            self.inst:ListenForEvent("startwereplayer", self._onstartwereplayer, owner)
            self.inst:ListenForEvent("stopwereplayer", self._onstopwereplayer, owner)
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
        self.inst.components.equippable:IsEquipped() then
        self:Say(STRINGS.LUCY.on_chopped)
    end
end

function SentientAxe:OnWereEaterChanged(old, new, istransforming)
    --NOTE: transforming will trigger another speech, so skip this one
    if istransforming or new <= old or not self.inst.components.inventoryitem:IsHeld() then
        return
    elseif new == 1 then
        self:Say(STRINGS.LUCY.beaver_down_early, "dontstarve/characters/woodie/lucy_warn_1")
    elseif new == 2 then
        self:Say(STRINGS.LUCY.beaver_down_late, "dontstarve/characters/woodie/lucy_warn_3")
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

function SentientAxe:OnBecomeWere()
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
                self.owner:HasTag("wereplayer") or
                self.owner:HasTag("playerghost"))
end

function SentientAxe:ScheduleConversation(delay)
    if self.convo_task ~= nil then
        self.convo_task:Cancel()
    end
    self.convo_task = self.inst:DoTaskInTime(delay or (10 + math.random() * 5), OnMakeConvo, self)
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
