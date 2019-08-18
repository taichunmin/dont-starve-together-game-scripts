--V2C: This component is for extending inventoryitem
--     component, and should not be used on its own.

local UpdateBuckets = nil
local UpdateTask = nil
local CurrentBucket = nil

local function DoUpdate()
    for i, v in ipairs(UpdateBuckets[CurrentBucket]) do
        v:UpdateMoisture()
    end
    CurrentBucket = CurrentBucket < #UpdateBuckets and CurrentBucket + 1 or 1
end

local function RegisterUpdate(self)
    if UpdateBuckets == nil then
        assert(UpdateTask == nil)
        UpdateTask = TheWorld:DoPeriodicTask(FRAMES, DoUpdate)
        self._bucket = { self }
        UpdateBuckets = { self._bucket }
        CurrentBucket = 1
        return
    end
    for i, v in ipairs(UpdateBuckets) do
        if #v < 50 then
            self._bucket = v
            table.insert(v, self)
            return
        end
    end
    self._bucket = { self }
    table.insert(UpdateBuckets, 1, self._bucket)
    CurrentBucket = CurrentBucket + 1
end

local function UnregisterUpdate(self)
    if self._bucket == nil then
        --Guard against bad code out there that is removing an entity multiple times
        return
    end
    for i, v in ipairs(self._bucket) do
        if v == self then
            table.remove(self._bucket, i)
            if #self._bucket <= 0 then
                for i2, v2 in ipairs(UpdateBuckets) do
                    if v2 == self._bucket then
                        table.remove(UpdateBuckets, i2)
                        if #UpdateBuckets <= 0 then
                            UpdateTask:Cancel()
                            UpdateTask = nil
                            UpdateBuckets = nil
                            CurrentBucket = nil
                        elseif CurrentBucket > i2 then
                            CurrentBucket = CurrentBucket - 1
                        elseif CurrentBucket > #UpdateBuckets then
                            CurrentBucket = 1
                        end
                        break
                    end
                end
            end
            self._bucket = nil
            return
        end
    end
end

local function onmoisture(self, moisture)
    self._replica:SetMoistureLevel(moisture)
end

local function oniswet(self, iswet)
    self._replica:SetIsWet(iswet)
end

local InventoryItemMoisture = Class(function(self, inst)
    self.inst = inst

    self.dryingSpeed = 1
    self.dryingResistance = 1

    self.wetnessSpeed = .5
    self.wetnessResistance = 1

    self.wetnessThreshold = TUNING.MOISTURE_WET_THRESHOLD
    self.drynessThreshold = TUNING.MOISTURE_DRY_THRESHOLD

    self.lastUpdate = GetTime()

    self._replica = nil
    --Don't initialize .moisture and .iswet until we have a link to inventoryitem replica

    RegisterUpdate(self)
end,
nil,
{
    moisture = onmoisture,
    iswet = oniswet,
})

--Used internally by inventoryitem component
function InventoryItemMoisture:AttachReplica(replica)
    self._replica = replica
    self.moisture = 0
    self.iswet = false
end

function InventoryItemMoisture:OnRemoveFromEntity()
    self.moisture = 0
    self.iswet = false
    UnregisterUpdate(self)
end

function InventoryItemMoisture:OnRemoveEntity()
    UnregisterUpdate(self)
end

function InventoryItemMoisture:InheritMoisture(moisture, iswet)
    self.moisture = math.max(0, moisture)
    self.iswet = (iswet and moisture > self.drynessThreshold) or moisture >= self.wetnessThreshold
end

function InventoryItemMoisture:DiluteMoisture(item, count)
    if self.inst.components.stackable ~= nil and item.components.inventoryitem ~= nil then
        local stacksize = self.inst.components.stackable.stacksize
        self:SetMoisture((stacksize * self.moisture + count * item.components.inventoryitem:GetMoisture()) / (stacksize + count))
    end
end

function InventoryItemMoisture:DoDelta(delta)
    self:SetMoisture(self.moisture + delta)
end

function InventoryItemMoisture:SetMoisture(moisture)
    self.moisture = math.max(0, moisture)
    if moisture >= self.wetnessThreshold then
        self.iswet = true
    elseif moisture <= self.drynessThreshold then
        self.iswet = false
    end
    --.iswet does not change if we're in betwen both thresholds
end

function InventoryItemMoisture:GetTargetMoisture()
    --If there is no owner, use world moisture
    --If owner is player, use player moisture
    --Otherwise (most likely a container), keep items dry
    local owner = self.inst.components.inventoryitem.owner
    return (self.inst.components.floater ~= nil and self.inst.components.floater:IsFloating() and TUNING.OCEAN.WETNESS)
        or (owner == nil and (TheWorld.state.israining and TheWorld.state.wetness or 0))
        or (owner.components.moisture ~= nil and owner.components.moisture:GetMoisture())
        or 0
end

function InventoryItemMoisture:UpdateMoisture()
    local t = GetTime()
    local dt = t - self.lastUpdate
    self.lastUpdate = t
    if dt <= 0 then
        return
    end

    local targetMoisture = self:GetTargetMoisture()
    if targetMoisture > self.moisture then
        self:SetMoisture(math.min(targetMoisture, self.moisture + self.wetnessSpeed * self.wetnessResistance * dt))
    elseif targetMoisture < self.moisture then
        self:SetMoisture(math.max(targetMoisture, self.moisture - self.dryingSpeed * self.dryingResistance * dt))
    end
end

function InventoryItemMoisture:OnSave()
    local data =
    {
        moisture = self.moisture > 0 and self.moisture or nil,
        wet = self.iswet or nil,
    }
    return next(data) ~= nil and data or nil
end

function InventoryItemMoisture:OnLoad(data)
    if data ~= nil then
        self.moisture = math.max(0, data.moisture or 0)
        self.iswet = (data.wet == true)
    end
end

function InventoryItemMoisture:GetDebugString()
    return string.format("moisture: %2.2f target: %2.2f%s", self.moisture, self:GetTargetMoisture(), self.iswet and " WET" or "")
end

return InventoryItemMoisture
