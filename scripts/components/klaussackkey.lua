local KlausSackKey = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("klaussackkey")

    --self.truekey = false --default nil
end)

function KlausSackKey:OnRemoveFromEntity()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    self.inst:RemoveTag("klaussackkey")
end

local function RestoreKey(inst, self)
    self.task = nil
    TheWorld:PushEvent("ms_restoreklaussackkey", inst)
end

function KlausSackKey:SetTrueKey(truekey)
    if truekey then
        if not self.truekey then
            self.truekey = true
            if not POPULATING then
                if self.task ~= nil then
                    self.task:Cancel()
                end
                RestoreKey(self.inst, self)
            elseif self.task == nil then
                self.task = self.inst:DoTaskInTime(0, RestoreKey, self)
            end
        end
    elseif self.truekey then
        self.truekey = nil
        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
        end
    end
end

return KlausSackKey
