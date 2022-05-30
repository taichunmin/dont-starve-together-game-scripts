local function ondried(self)
    if self.product == nil then
        self.inst:RemoveTag("dried")
        self.inst:RemoveTag("drying")
        self.inst:AddTag("candry")
    elseif self.ingredient == nil then
        self.inst:AddTag("dried")
        self.inst:RemoveTag("drying")
        self.inst:RemoveTag("candry")
    else
        self.inst:RemoveTag("dried")
        self.inst:AddTag("drying")
        self.inst:RemoveTag("candry")
    end
end

local Dryer = Class(function(self, inst)
    self.inst = inst

    self.ingredient = nil
    self.product = nil
	self.buildfile = nil
    self.dried_buildfile = nil
	self.foodtype = nil -- assuming that the product will be of the same food type as the ingredient
    self.remainingtime = nil
    self.tasktotime = nil
    self.task = nil

    self.onstartdrying = nil
    self.ondonedrying = nil
    self.onharvest = nil

    self.protectedfromrain = nil
    self.watchingrain = nil
end,
nil,
{
    ingredient = ondried,
    product = ondried,
})

--------------------------------------------------------------------------

local function OnIsRaining(self, israining)
    if israining then
        self:Pause()
    else
        self:Resume()
    end
end

local function StartWatchingRain(self)
    if not self.watchingrain then
        self.watchingrain = true
        self:WatchWorldState("israining", OnIsRaining)
    end
end

local function StopWatchingRain(self)
    if self.watchingrain then
        self.watchingrain = nil
        self:StopWatchingWorldState("israining", OnIsRaining)
    end
end

--------------------------------------------------------------------------

function Dryer:OnRemoveFromEntity()
    if self.task ~= nil then
        self.task:Cancel()
    end
    StopWatchingRain(self)
    self.inst:RemoveTag("dried")
    self.inst:RemoveTag("drying")
    self.inst:RemoveTag("candry")
end

--------------------------------------------------------------------------

function Dryer:SetStartDryingFn(fn)
    self.onstartdrying = fn
end

function Dryer:SetDoneDryingFn(fn)
    self.ondonedrying = fn
end

function Dryer:SetOnHarvestFn(fn)
    self.onharvest = fn
end

--------------------------------------------------------------------------

function Dryer:CanDry(dryable)
    return self.product == nil and dryable ~= nil and dryable.components.dryable ~= nil
end

function Dryer:IsDrying()
    return self.ingredient ~= nil
end

function Dryer:IsDone()
    return self.product ~= nil and self.ingredient == nil
end

function Dryer:GetTimeToDry()
    return self.ingredient ~= nil and (self.tasktotime ~= nil and self.tasktotime - GetTime() or self.remainingtime) or 0
end

function Dryer:GetTimeToSpoil()
    return self.ingredient == nil and (self.tasktotime ~= nil and self.tasktotime - GetTime() or self.remainingtime) or 0
end

function Dryer:IsPaused()
    return self.remainingtime ~= nil
end

--------------------------------------------------------------------------

local function DoSpoil(inst, self)
    self.ingredient = nil
	self.buildfile = nil
    self.dried_buildfile = nil
    self.product = nil
	self.foodtype = nil
    self.remainingtime = nil
    self.tasktotime = nil
    self.task = nil
    StopWatchingRain(self)

    local loot = SpawnPrefab("spoiled_food")
    if loot ~= nil then
        loot.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if loot.components.inventoryitem ~= nil and not self.protectedfromrain then
            loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
        end
    end

    if self.onharvest ~= nil then
        self.onharvest(inst)
    end
end

local function DoDry(inst, self)
    self.ingredient = nil
    self.remainingtime = TUNING.PERISH_PRESERVED
    self.tasktotime = nil
    self.task = nil
    StopWatchingRain(self)

    self:Resume()

    if self.ondonedrying ~= nil then
        self.ondonedrying(inst, self.product, self.dried_buildfile)
    end
end

function Dryer:StartDrying(dryable)
    if not self:CanDry(dryable) then
        return false
    end

    self.ingredient = dryable.prefab
	self.buildfile = dryable.components.dryable:GetBuildFile()
    self.dried_buildfile = dryable.components.dryable:GetDriedBuildFile()
    self.ingredientperish = dryable.components.perishable:GetPercent()
	self.foodtype = dryable.components.edible ~= nil and dryable.components.edible.foodtype or nil
    self.product = dryable.components.dryable:GetProduct()
    self.remainingtime = dryable.components.dryable:GetDryTime()
    self.tasktotime = nil
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    StopWatchingRain(self)

    if self.ingredient == nil or self.product == nil or self.remainingtime == nil then
        self.ingredient = nil
		self.buildfile = nil
        self.dried_buildfile = nil
        self.product = nil
		self.foodtype = nil
        self.remainingtime = nil
        return false
    end

    dryable:Remove()

    if not TheWorld.state.israining or self.protectedfromrain then
        self:Resume()
    end
    if not self.protectedfromrain then
        StartWatchingRain(self)
    end

    if self.onstartdrying ~= nil then
        self.onstartdrying(self.inst, self.ingredient, self.buildfile)
    end
    return true
end

function Dryer:StopDrying(reason)
    if self.product == nil then
        return
    end

    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    StopWatchingRain(self)

    if reason == "fire" then
        local loot = SpawnPrefab(self.product)
        if loot ~= nil then
            loot.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
        end

        self.ingredient = nil
		self.buildfile = nil
        self.dried_buildfile = nil
        self.product = nil
		self.foodtype = nil
        self.remainingtime = nil
        self.tasktotime = nil
    elseif self.ingredient ~= nil then
        DoDry(self.inst, self)
    else
        DoSpoil(self.inst, self)
    end
end

function Dryer:Pause()
    if self.tasktotime ~= nil then
        self.remainingtime = math.max(0, self.tasktotime - GetTime())
        self.tasktotime = nil
        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
        end
    end
end

function Dryer:Resume()
    if self.remainingtime ~= nil then
        if self.task ~= nil then
            self.task:Cancel()
        end
        self.task = self.inst:DoTaskInTime(self.remainingtime, self.ingredient ~= nil and DoDry or DoSpoil, self)
        self.tasktotime = GetTime() + self.remainingtime
        self.remainingtime = nil
    end
end

function Dryer:DropItem()
	if self.ingredient == nil and self.product == nil then
		return
	end

    local loot = SpawnPrefab(self.ingredient or self.product)
    if loot ~= nil then
		LaunchAt(loot, self.inst, nil, .25, 1)
        if loot.components.perishable ~= nil then
			if self.ingredient ~= nil then
				--print (self.ingredientperish, self:GetTimeToDry(), loot.components.dryable:GetDryTime(), (self:GetTimeToDry() / loot.components.dryable:GetDryTime()), self.ingredientperish * (self:GetTimeToDry() / loot.components.dryable:GetDryTime()))
				loot.components.perishable:SetPercent(self.ingredientperish * (self:GetTimeToDry() / loot.components.dryable:GetDryTime()))
	        else
	            loot.components.perishable:SetPercent(self:GetTimeToSpoil() / TUNING.PERISH_PRESERVED)
	        end
            loot.components.perishable:StartPerishing()
        end
        if loot.components.inventoryitem ~= nil and not self.protectedfromrain then
            loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
        end
    end

    self.ingredient = nil
	self.buildfile = nil
    self.dried_buildfile = nil
    self.product = nil
	self.foodtype = nil
    self.remainingtime = nil
    self.tasktotime = nil
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    StopWatchingRain(self)

    if self.onharvest ~= nil then
        self.onharvest(self.inst)
    end
    return true
end

function Dryer:Harvest(harvester)
    if not self:IsDone() or harvester == nil or harvester.components.inventory == nil then
        return false
    end

    local loot = SpawnPrefab(self.product)
    if loot ~= nil then
        if loot.components.perishable ~= nil then
            loot.components.perishable:SetPercent(self:GetTimeToSpoil() / TUNING.PERISH_PRESERVED)
            loot.components.perishable:StartPerishing()
        end
        if loot.components.inventoryitem ~= nil and not self.protectedfromrain then
            loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
        end
        harvester.components.inventory:GiveItem(loot, nil, self.inst:GetPosition())
    end

    self.ingredient = nil
	self.buildfile = nil
    self.dried_buildfile = nil
    self.product = nil
	self.foodtype = nil
    self.remainingtime = nil
    self.tasktotime = nil
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    StopWatchingRain(self)

    if self.onharvest ~= nil then
        self.onharvest(self.inst)
    end
    return true
end

--------------------------------------------------------------------------
-- Update

function Dryer:LongUpdate(dt)
    if self.product == nil then
        return
    end

    self:Pause()

    if self.remainingtime > dt then
        self.remainingtime = self.remainingtime - dt
    elseif self.ingredient ~= nil then
        dt = dt - self.remainingtime
        if TUNING.PERISH_PRESERVED > dt then
            DoDry(self.inst, self)
            self:Pause()
            self.remainingtime = math.max(0, self.remainingtime - dt)
        else
            DoSpoil(self.inst, self)
        end
    else
        DoSpoil(self.inst, self)
    end

    if self:IsDrying() then
        if not TheWorld.state.israining or self.protectedfromrain then
            self:Resume()
        end
        if not self.protectedfromrain then
            StartWatchingRain(self)
        end
    else
        self:Resume()
    end
end

--------------------------------------------------------------------------
-- Save/Load

function Dryer:OnSave()
    if self.product ~= nil then
        local remainingtime = (self.tasktotime ~= nil and self.tasktotime - GetTime() or self.remainingtime) or 0
        return
        {
            ingredient = self.ingredient,
			buildfile = self.buildfile,
            dried_buildfile = self.dried_buildfile,
            ingredientperish = self.ingredientperish,
            product = self.product,
			foodtype = self.foodtype,
            remainingtime = remainingtime > 0 and remainingtime or nil,
        }
    end
end

function Dryer:OnLoad(data)
    if data.product ~= nil then
        self.ingredient = data.ingredient
        self.ingredientperish = data.ingredientperish or 100 -- for old save files, assume 100%
		self.buildfile = data.buildfile
        self.dried_buildfile = data.dried_buildfile
        self.product = data.product
		self.foodtype = data.foodtype or FOODTYPE.GENERIC
        self.remainingtime = data.remainingtime or 0
        self.tasktotime = nil
        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
        end
        StopWatchingRain(self)

        if self:IsDrying() then
            if not TheWorld.state.israining or self.protectedfromrain then
                self:Resume()
            end
            if not self.protectedfromrain then
                StartWatchingRain(self)
            end
            if self.onstartdrying ~= nil then
                self.onstartdrying(self.inst, self.ingredient, self.buildfile)
            end
        else
            self:Resume()
            if self.ondonedrying ~= nil then
                self.ondonedrying(self.inst, self.product, self.dried_buildfile)
            end
        end
    end
end

--------------------------------------------------------------------------
-- Debug

function Dryer:GetDebugString()
    return ((self:IsDrying() and "DRYING ") or
            (self:IsDone() and "DRIED ") or
            "EMPTY ")
        ..(self.product or "<none>")
		.." "..(self.foodtype or "none")
        ..(self:IsPaused() and " PAUSED" or "")
        ..string.format(" drytime: %2.2f spoiltime: %2.2f", self:GetTimeToDry(), self:GetTimeToSpoil())
end

--------------------------------------------------------------------------

return Dryer