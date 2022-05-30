--V2C: This component is for extending inventoryitem
--     component, and should not be used on its own.

--note: There is up to an UPDATE_TIME error when an enity sleeps due to the remainging time in the task.
--  There is up to an UPDATE_TIME error when an enity wakes due to the random start time.
--  At this point moisture is not critical enough to factor for these

local UPDATE_TIME = 1.0

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
	inst.components.inventoryitemmoisture:UpdateMoisture(UPDATE_TIME)

--	if debug_print_moisture_updates then
--		debugUpdate()
--	end
end

local function StartUpdateTask(inst)
	if inst.moistureupdatetask == nil then
		local update_offset = math.random()*UPDATE_TIME
		inst.moistureupdatetask = inst:DoPeriodicTask(UPDATE_TIME, DoUpdate, update_offset)
	end
end

local function OnSleep(inst)
	if inst.moistureupdatetask ~= nil then
		inst.moistureupdatetask:Cancel()
		inst.moistureupdatetask = nil
	end

	inst._entitysleeptime = GetTime()
end

local function OnWake(inst)
	if inst._entitysleeptime == nil then
		return
	end

	local time_slept = GetTime() - inst._entitysleeptime
	if time_slept > 0 then
		inst.components.inventoryitemmoisture:UpdateMoisture(time_slept)
	end
	StartUpdateTask(inst)
end

local InventoryItemMoisture = Class(function(self, inst)
    self.inst = inst

    self.lastUpdate = GetTime()

    self._replica = nil
    --Don't initialize .moisture and .iswet until we have a link to inventoryitem replica

	inst:ListenForEvent("entitysleep", OnSleep)
    inst:ListenForEvent("entitywake", OnWake)

	StartUpdateTask(inst)
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

	self.inst:RemoveEventCallback("entitysleep", OnSleep)
    self.inst:RemoveEventCallback("entitywake", OnWake)

	if self.inst.moistureupdatetask ~= nil then
		self.inst.moistureupdatetask:Cancel()
		self.inst.moistureupdatetask = nil
	end
end

function InventoryItemMoisture:InheritMoisture(moisture, iswet)
    self.moisture = math.max(0, moisture)
    self.iswet = (iswet and moisture > TUNING.MOISTURE_DRY_THRESHOLD) or moisture >= TUNING.MOISTURE_WET_THRESHOLD
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
    if moisture >= TUNING.MOISTURE_WET_THRESHOLD then
        self.iswet = true
    elseif moisture <= TUNING.MOISTURE_DRY_THRESHOLD then
        self.iswet = false
    end
    --.iswet does not change if we're in betwen both thresholds
end

function InventoryItemMoisture:GetTargetMoisture()
    --If floating in the ocean, use OCEAN_WETNESS
	--If there is no owner, use world moisture
    --If owner is player, use player moisture
    --Otherwise (most likely a container), keep items dry
    local owner = self.inst.components.inventoryitem.owner
    return (self.inst.components.floater ~= nil and self.inst.components.floater.showing_effect and TUNING.OCEAN_WETNESS)
        or (owner == nil and (TheWorld.state.israining and TheWorld.state.wetness or 0))
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
