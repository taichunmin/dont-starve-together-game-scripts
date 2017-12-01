local UIAnim = require "widgets/uianim"

--see mindcontroller.lua for constants
local MAX_LEVEL = 135
local IN_TIME = MAX_LEVEL * FRAMES
local OFFSET_LEVEL = 1 / MAX_LEVEL

local MindControlOver = Class(UIAnim, function(self, owner)
    self.owner = owner
    UIAnim._ctor(self)

    self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    self:GetAnimState():SetBank("mind_control_overlay")
    self:GetAnimState():SetBuild("mind_control_overlay")
    self:GetAnimState():PlayAnimation("empty")
    self:Hide()

    self.level = 0
    self.targetlevel = 0
    self.task = nil

    if owner ~= nil then
        self.inst:ListenForEvent("mindcontrollevel", function(owner, level) self:PushLevel(level) end, owner)
    end
end)

local function PopLevel(inst, self, delay)
    if delay > 0 then
        self.task = inst:DoTaskInTime(0, PopLevel, self, delay - 1)
    else
        self.task = nil
        self:PushLevel(0)
    end
end

function MindControlOver:PushLevel(level)
    level = math.clamp(level, 0, 1)

    if self.level ~= level then
        self.targetlevel = level

        if level >= 1 then
            self.level = 1
            self:GetAnimState():PlayAnimation("loop", true)
            self:Show()
            self:StopUpdating()
        elseif level > 0 then
            self.level = level
            self:GetAnimState():SetPercent("in", math.min(1, level + OFFSET_LEVEL))
            self:Show()
            self:StopUpdating()
        elseif self.level >= 1 then
            self.level = 0
            self:GetAnimState():PlayAnimation("out")
            self:StartUpdating()
        else
            self:StartUpdating()
        end
    elseif self.targetlevel ~= level then
        self.targetlevel = level
        self:StopUpdating()
    end

    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    if self.targetlevel > 0 then
        self.task = self.inst:DoTaskInTime(0, PopLevel, self, 1)
    end
end

function MindControlOver:OnUpdate(dt)
    if self.targetlevel > 0 then
        --wot! bad state
        self:StopUpdating()
    elseif self.level > 0 then
        local dlevel = dt / IN_TIME
        if self.level > dlevel then
            self.level = self.level - dlevel
            self:GetAnimState():SetPercent("in", self.level)
        else
            self.level = 0
            self:GetAnimState():PlayAnimation("empty")
            self:Hide()
            self:StopUpdating()
        end
    elseif self:GetAnimState():AnimDone() then
        self:GetAnimState():PlayAnimation("empty")
        self:Hide()
        self:StopUpdating()
    end
end

return MindControlOver
