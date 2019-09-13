local function OnEat(inst, data)
    inst.components.wereeater:EatMosterFood(data)
end

local WereEater = Class(function(self, inst)
    self.inst = inst
    self.duration = TUNING.TOTAL_DAY_TIME / 2
    self.monster_count = 0
    self.forget_task = nil
    self.forcetransformfn = nil

    inst:ListenForEvent("oneat", OnEat)
end)

function WereEater:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("oneat", OnEat)
end

function WereEater:SetForceTransformFn(fn)
    self.forcetransformfn = fn
end

function WereEater:ResetFoodMemory()
    self.monster_count = 0
    if self.forget_task ~= nil then
        self.forget_task:Cancel()
        self.forget_task = nil
    end
end

function WereEater:ForceTransformToWere(mode)
    if self.forcetransformfn ~= nil then
        self.forcetransformfn(self.inst, mode)
    end
end

local function OnMonsterCooldown(inst, self)
    local old = self.monster_count
    if old > 1 then
        self.monster_count = old - 1
        self.forget_task = self.inst:DoTaskInTime(self.duration, OnMonsterCooldown, self)
    else
        self.monster_count = 0
        self.forget_task = nil
    end
    self.inst:PushEvent("wereeaterchanged", {
        old = old,
        new = self.monster_count,
        istransforming = false,
    })
end

function WereEater:EatMosterFood(data)
    if self.inst:HasTag("wereplayer") then
        -- This means we're already transformed
        return
    end

    local forcetransform = data.food:HasTag("wereitem")
    local shouldtransform = forcetransform
    if data.food:HasTag("monstermeat") then
        local old = self.monster_count
        self.monster_count = old + 1
        if self.monster_count >= 2 then
            shouldtransform = true
        end
        if self.forget_task ~= nil then
            self.forget_task:Cancel()
        end
        self.forget_task = self.inst:DoTaskInTime(self.duration, OnMonsterCooldown, self)

        self.inst:PushEvent("wereeaterchanged", {
            old = old,
            new = self.monster_count,
            istransforming = shouldtransform,
        })
    end

    if shouldtransform then
        self:ForceTransformToWere(forcetransform and data.food.were_mode or nil)
    end
end

function WereEater:OnSave()
    return self.monster_count > 0
        and self.forget_task ~= nil
        and {
            monster_count = self.monster_count,
            task_left = GetTaskRemaining(self.forget_task),
        }
        or nil
end

function WereEater:OnLoad(data)
    if data.monster_count ~= nil then
        self.monster_count = math.max(0, data.monster_count)
        if self.forget_task ~= nil then
            self.forget_task:Cancel()
        end
        self.forget_task = self.monster_count > 0 and self.inst:DoTaskInTime(data.task_left or self.duration, OnMonsterCooldown, self) or nil
    end
end

function WereEater:GetDebugString()
    return string.format("monster_count: %d/4 (%.2f/%.2f)", self.monster_count, self.forget_task ~= nil and GetTaskRemaining(self.forget_task) or 0, self.duration)
end

return WereEater
