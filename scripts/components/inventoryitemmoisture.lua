--V2C: This component is for extending inventoryitem
--     component, and should not be used on its own.

--note: There is up to an UPDATE_TIME error when an enity sleeps due to the remainging time in the task.
--  There is up to an UPDATE_TIME error when an enity wakes due to the random start time.
--  At this point moisture is not critical enough to factor for these

--V2C: Don't worry about the time error, it doesn't even account
--     for changes in target moisture while we are asleep either

local UPDATE_TIME = 1.0
local SLOW_UPDATE_TIME = 2 --switch to this period when we've reached target moisture

local function onmoisture(self, moisture)
    self._replica:SetMoistureLevel(moisture)
end

local function oniswet(self, iswet)
    self._replica:SetIsWet(iswet)
end
--[[
debug_print_moisture_updates = false
local prev_tick = 0
local moisture_updates = 0
local function debugUpdate()
	local tick = TheSim:GetTick()
	if tick ~= prev_tick then
		local total = 0
		local active = 0
		for _, v in pairs(Ents) do
			if v.components.inventoryitemmoisture ~= nil then
				total = total + 1
			end
			if v.moistureupdatetask ~= nil then
				active = active + 1
			end
		end

		print("Active InventoryItemMoisture: total: " .. total .. "  active: " .. active .. "  updated: " .. moisture_updates)
		prev_tick = tick
		moisture_updates = 0
	end
	moisture_updates = moisture_updates + 1
end
]]
local function DoUpdate(inst)
	local self = inst.components.inventoryitemmoisture
	local dt = self.moistureupdatetask.period
	local nextdt = self:UpdateMoisture(dt) and UPDATE_TIME or SLOW_UPDATE_TIME
	if dt ~= nextdt then
		self.moistureupdatetask:Cancel()
		self.moistureupdatetask = inst:DoPeriodicTask(nextdt, DoUpdate)
	end

--	if debug_print_moisture_updates then
--		debugUpdate()
--	end
end

local InventoryItemMoisture = Class(function(self, inst)
    self.inst = inst

    self.lastUpdate = GetTime()

    self._replica = nil
    --Don't initialize .moisture and .iswet until we have a link to inventoryitem replica
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

	if self.moistureupdatetask then
		self.moistureupdatetask:Cancel()
		self.moistureupdatetask = nil
	end
end

function InventoryItemMoisture:OnEntitySleep()
	if self.moistureupdatetask then
		self.moistureupdatetask:Cancel()
		self.moistureupdatetask = nil
	end

	self._entitysleeptime = GetTime()
end

function InventoryItemMoisture:OnEntityWake()
	local updated
	if self._entitysleeptime then
		local time_slept = GetTime() - self._entitysleeptime
		if time_slept > 0 then
			updated = self:UpdateMoisture(time_slept)
		end
		self._entitysleeptime = nil
	end
	if self.moistureupdatetask == nil then
		self.moistureupdatetask = self.inst:DoPeriodicTask(updated and UPDATE_TIME or SLOW_UPDATE_TIME, DoUpdate, math.random() * UPDATE_TIME)
	end
end

function InventoryItemMoisture:InheritMoisture(moisture, iswet)
	self.moisture = math.clamp(moisture, 0, TUNING.MAX_WETNESS)
    self.iswet = (iswet and moisture > TUNING.MOISTURE_DRY_THRESHOLD) or moisture >= TUNING.MOISTURE_WET_THRESHOLD
end

function InventoryItemMoisture:DiluteMoisture(item, count)
    if self.inst.components.stackable ~= nil and item.components.inventoryitem ~= nil then
        local stacksize = self.inst.components.stackable.stacksize
        self:SetMoisture((stacksize * self.moisture + count * item.components.inventoryitem:GetMoisture()) / (stacksize + count))
    end
end

function InventoryItemMoisture:MakeMoistureAtLeast(min)
	self.moisture = math.max(self.moisture, min)
	self.iswet = self.iswet or min > TUNING.MOISTURE_DRY_THRESHOLD
end

function InventoryItemMoisture:DoDelta(delta)
    self:SetMoisture(self.moisture + delta)
end

function InventoryItemMoisture:SetMoisture(moisture)
	self.moisture = math.clamp(moisture, 0, TUNING.MAX_WETNESS)
    if moisture >= TUNING.MOISTURE_WET_THRESHOLD then
        self.iswet = true
    elseif moisture <= TUNING.MOISTURE_DRY_THRESHOLD then
        self.iswet = false
    end
    --.iswet does not change if we're in betwen both thresholds
end

function InventoryItemMoisture:GetTargetMoisture()
	--If floating in the ocean, use MAX_WETNESS (not OCEAN_WETNESS, that is initial wetness when entering ocean)
	--If there is no owner, use world moisture (account for "rainimmunity")
    --If owner is player, use player moisture
    --Otherwise (most likely a container), keep items dry
    local owner = self.inst.components.inventoryitem.owner
	return (self.inst.components.floater ~= nil and self.inst.components.floater.showing_effect and TUNING.MAX_WETNESS)
		or (owner == nil and (TheWorld.state.israining and self.inst.components.rainimmunity == nil and TheWorld.state.wetness or 0))
        or (owner.components.moisture ~= nil and owner.components.moisture:GetMoisture())
        or 0
end

function InventoryItemMoisture:UpdateMoisture(dt)
    local targetMoisture = self:GetTargetMoisture()
	local target_delta = targetMoisture - self.moisture
    if target_delta > 0 then
        self:SetMoisture(math.min(targetMoisture, self.moisture + 0.5 * dt))
    elseif target_delta < 0 then
        self:SetMoisture(math.max(targetMoisture, self.moisture - dt))
	else
		return false --no change
    end
	return true --changed
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
		self.moisture = math.clamp(data.moisture or 0, 0, TUNING.MAX_WETNESS)
        self.iswet = (data.wet == true)
    end
end

function InventoryItemMoisture:GetDebugString()
    return string.format("moisture: %2.2f target: %2.2f%s", self.moisture, self:GetTargetMoisture(), self.iswet and " WET" or "")
end

return InventoryItemMoisture
