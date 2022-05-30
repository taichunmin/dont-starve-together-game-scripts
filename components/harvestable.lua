local function onproduce(self, produce)
    if self.enabled and produce > 0 then
        self.inst:AddTag("harvestable")
    else
        self.inst:RemoveTag("harvestable")
    end
end

local function onenabled(self, enabled)
    if enabled and self.produce > 0 then
        self.inst:AddTag("harvestable")
    else
        self.inst:RemoveTag("harvestable")
    end
end

local Harvestable = Class(function(self, inst)
    self.inst = inst
    self.produce = 0
    self.growtime = nil
    self.product = nil
    self.ongrowfn = nil
    self.maxproduce = 1

    self.enabled = true

    --self.can_harvest_fn = nil
end,
nil,
{
    produce = onproduce,
    enabled = onenabled,
})

function Harvestable:OnRemoveFromEntity()
    self.inst:RemoveTag("harvestable")
end

function Harvestable:SetUp(product, max, time, onharvest, ongrow)
    self:SetProduct(product, max)
    self:SetGrowTime(time)
    self:SetOnGrowFn(ongrow)
    self:SetOnHarvestFn(onharvest)
    self:StartGrowing()
end

function Harvestable:SetOnGrowFn(fn)
    self.ongrowfn = fn
end

function Harvestable:SetOnHarvestFn(fn)
    self.onharvestfn = fn
end

function Harvestable:SetProduct(product, max)
    self.product = product
    self.maxproduce = max or 1
    self.produce = 0
end

function Harvestable:SetGrowTime(time)
    self.growtime = time
end

function Harvestable:CanBeHarvested()
    return self.enabled and self.produce > 0
end

function Harvestable:SetCanHarvestFn(fn)
    self.can_harvest_fn = fn
end

function Harvestable:Disable()
    self:PauseGrowing()
    self.enabled = false
end

function Harvestable:Enable()
    self:StartGrowing()
    self.enabled = true
end

function Harvestable:OnSave()
    local data = {}
    local time = GetTime()
    if self.targettime and self.targettime > time then
        data.time = self.targettime - time
    end
    data.pausetime = self.pausetime
    data.produce = self.produce
    return data
end

function Harvestable:OnLoad(data)
    --print(self.inst, "Harvestable:OnLoad")
    self.produce = data.produce
    self.pausetime = data.pausetime
    if data.time then
        self:StartGrowing(data.time)
    end
end


function Harvestable:GetDebugString()
    local str = string.format("%d "..tostring(self.product).." grown", self.produce)
    if self.targettime then
        str = str.." ("..tostring(self.targettime - GetTime())..")"
    elseif self.pausetime then
        str = str.." (paused: "..tostring(self.pausetime)..")"
    end
    return str
end

function Harvestable:Grow()
    if self.produce < self.maxproduce then
        self.produce = self.produce + 1
        if self.ongrowfn then
            self.ongrowfn(self.inst, self.produce)
        end
        if self.produce < self.maxproduce then
            self:StartGrowing()
        else
            self:StopGrowing()
        end

		return true
    end

	return false
end

function Harvestable:StartGrowing(time)
    self:StopGrowing()
    local growtime = time or self.pausetime or self.growtime
    self.pausetime = nil
    if growtime then
        self.task = self.inst:DoTaskInTime(growtime, function() self:Grow() end, "grow")
        self.targettime = GetTime() + growtime
    end
end

function Harvestable:PauseGrowing()
    if self.task then
        self.task:Cancel()
        self.task = nil
        local time = GetTime()
        if self.targettime and self.targettime > time then
            self.pausetime = self.targettime - time
        end
        self.targettime = nil
    end
end

function Harvestable:StopGrowing()
    if self.task then
        self.task:Cancel()
        self.task = nil
        self.targettime = nil
    end
end

function Harvestable:Harvest(picker)
    if self:CanBeHarvested() then
        if self.can_harvest_fn ~= nil then
            local can_harvest, fail_reason = self.can_harvest_fn(self.inst, picker)
            if not can_harvest then
                return false, fail_reason
            end
        end

        local produce = self.produce
        self.produce = 0

        local pos = self.inst:GetPosition()

        if self.onharvestfn ~= nil then
            self.onharvestfn(self.inst, picker, produce)
        end

		if self.product ~= nil then
			if picker ~= nil and picker.components.inventory ~= nil then
				picker:PushEvent("harvestsomething", { object = self.inst })
			end

			for i = 1, produce, 1 do
				local loot = SpawnPrefab(self.product)
				if loot ~= nil then
					if loot.components.inventoryitem ~= nil then
						loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
					end
					if picker ~= nil and picker.components.inventory ~= nil then
						picker.components.inventory:GiveItem(loot, nil, pos)
					else
						LaunchAt(loot, self.inst, nil, 1, 1)
					end
				end
			end
        end
        self:StartGrowing()
        return true
    end
end

return Harvestable