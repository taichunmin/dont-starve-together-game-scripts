local function onaccepts_items(self, new_accepts_items, old_accepts_items)
    if new_accepts_items then
        if not old_accepts_items then
            self.inst:AddTag("compostingbin_accepts_items")
        end
    else
        if old_accepts_items then
            self.inst:RemoveTag("compostingbin_accepts_items")
        end
    end
end

local function ontimerdone(inst, data)
    if data ~= nil then
        if data.name == "composting" then
            local compostingbin = inst.components.compostingbin
            local greens_and_browns = compostingbin.greens + compostingbin.browns

            if compostingbin.greens > 0 and compostingbin.browns > 0 then
                compostingbin.greens = compostingbin.greens - 1
                compostingbin.browns = compostingbin.browns - 1
            else
                if compostingbin.greens > 1 then
                    compostingbin.greens = compostingbin.greens - 2
                elseif compostingbin.browns > 1 then
                    compostingbin.browns = compostingbin.browns - 2
                end
            end

            compostingbin:Refresh(true)

            if compostingbin.finishcyclefn ~= nil then
                compostingbin.finishcyclefn(inst)
            end
        end
    end
end

local function stopcomposting(inst)
    if inst.components.timer:TimerExists("composting") then
        inst.components.timer:StopTimer("composting")
    end

    inst.components.compostingbin.current_composting_time = nil

    if inst.components.compostingbin.onstopcompostingfn ~= nil then
        inst.components.compostingbin.onstopcompostingfn(inst)
    end
end

local CompostingBin = Class(function(self, inst)
    self.inst = inst

    self.max_materials = 6

    self.greens = 0
    self.browns = 0

    self.materials_per_fertilizer = 2

    self.greens_ratio = nil

    self.composting_time_min = 6
    self.composting_time_max = 20

    self.current_composting_time = nil

    self.accepts_items = true

    -- self.calcdurationmultfn = nil
    -- self.calcmaterialvalue = nil

    -- self.onaddcompostable = nil

    -- self.finishcyclefn = nil

    -- self.onstartcompostingfn = nil
    -- self.onstopcompostingfn = nil
    -- self.onrefreshfn = nil

    self.inst:ListenForEvent("timerdone", ontimerdone)
end, nil,
{
    accepts_items = onaccepts_items,
})

function CompostingBin:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("timerdone", ontimerdone)
end

function CompostingBin:GetMaterialTotal()
    return self.greens + self.browns
end

function CompostingBin:IsFull()
    return self:GetMaterialTotal() >= self.max_materials
end

function CompostingBin:Refresh(cycle_completed)
    local greens_and_browns = self.greens + self.browns

    if greens_and_browns < 2 then
        self.onrefreshfn(self.inst, cycle_completed)
        stopcomposting(self.inst)
    else
        self.greens_ratio = self.greens / greens_and_browns

        local processing_time_alpha = math.abs(self.greens_ratio - 0.5) * 2
        local duration_multiplier = (self.calcdurationmultfn ~= nil and self.calcdurationmultfn(self.inst)) or 1

        if self.inst.components.timer:TimerExists("composting") then
            local progress_percentage = self.inst.components.timer:GetTimeLeft("composting") / self.current_composting_time
            self.current_composting_time = Lerp(self.composting_time_min, self.composting_time_max, processing_time_alpha) * duration_multiplier
            local new_time_remaining = progress_percentage * self.current_composting_time

            self.inst.components.timer:SetTimeLeft("composting", new_time_remaining * progress_percentage)
        else
            self.current_composting_time = Lerp(self.composting_time_min, self.composting_time_max, processing_time_alpha) * duration_multiplier
            self.inst.components.timer:StartTimer("composting", self.current_composting_time)

            if self.onstartcompostingfn ~= nil then
                self.onstartcompostingfn(self.inst)
            end
        end

        if self.onrefreshfn ~= nil then
            self.onrefreshfn(self.inst, cycle_completed)
        end
    end
end

function CompostingBin:AddCompostable(item)
    if self.calcmaterialvalue == nil then
        return false
    end

    local materialvalue = self.calcmaterialvalue(self.inst, item)
    if not materialvalue then
        return false
    end

    if self.onaddcompostable ~= nil then
        self.onaddcompostable(self.inst, item)
    end

    if item.components.stackable ~= nil then
        item.components.stackable:Get():Remove()
    else
        item:Remove()
    end

    self:AddMaterials(materialvalue.greens, materialvalue.browns)
    return true
end

function CompostingBin:AddMaterials(greens, browns)
    greens = greens or 0
    browns = browns or 0

    self.greens = self.greens + greens
    self.browns = self.browns + browns

    self:Refresh()
end

function CompostingBin:IsComposting()
    return self.inst.components.timer:TimerExists("composting")
end

function CompostingBin:OnSave()
    if self:IsComposting() or self:GetMaterialTotal() > 0 then
        return { greens = self.greens, browns = self.browns, current_composting_time = self.current_composting_time }
    end
end

function CompostingBin:OnLoad(data)
    self.greens = data.greens or 0
    self.browns = data.browns or 0

    if self.greens ~= 0 or self.browns ~= 0 then
        self.greens_ratio = self.greens / (self.greens + self.browns)
    end

    self.current_composting_time = data.current_composting_time
end

return CompostingBin
