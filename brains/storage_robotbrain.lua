--Used by: storage_robot, winona_storage_robot

require "behaviours/standstill"
local StorageRobotCommon = require "prefabs/storage_robot_common"

---------------------------------------------------------------------------------------------------

-- Table shared by all storage robots.
-- Keeping this for mods / people spawning more of them.
local ignorethese = { --[[ [item] = worker ]] }

local StorageRobotBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function StorageRobotBrain:IgnoreItem(item)
    self:UnignoreItem()

    self._targetitem = item
    self._targetitem_event_onputininventory = function()
        self:UnignoreItem()
    end

    ignorethese[item] = self.inst
    item:ListenForEvent("onputininventory", self._targetitem_event_onputininventory)
end

function StorageRobotBrain:UnignoreItem()
    if self._targetitem then
        ignorethese[self._targetitem] = nil
        if self._targetitem_event_onputininventory ~= nil then
            if self._targetitem:IsValid() then
                self._targetitem:RemoveEventCallback("onputininventory", self._targetitem_event_onputininventory)
            end
            self._targetitem_event_onputininventory = nil
        end
        self._targetitem = nil
    end
end

function StorageRobotBrain:ShouldIgnoreItem(item)
    return ignorethese[item] ~= nil and ignorethese[item] ~= self.inst
end

---------------------------------------------------------------------------------------------------

local function PickUpAction(inst)
	if inst.LOW_BATTERY_GOHOME and
		inst.components.fueled:GetPercent() < TUNING.WINONA_STORAGE_ROBOT_LOW_FUEL_PCT and
		StorageRobotCommon.GetSpawnPoint(inst)
	then
		return
	end

    local activeitem = inst.components.inventory:GetActiveItem()

    if activeitem ~= nil then
        inst.components.inventory:DropItem(activeitem, true, true)
    end

    ----------------

    local item = inst.components.inventory:GetFirstItemInAnySlot()

    if item and (item.components.stackable == nil or item.components.stackable:IsFull()) then
        return
    end

    ----------------

    item = StorageRobotCommon.FindItemToPickupAndStore(inst, item)

    if item == nil then
        return
    end

    inst.brain:IgnoreItem(item)

    return BufferedAction(inst, item, ACTIONS.PICKUP, nil, nil, nil, nil, nil, nil, inst.PICKUP_ARRIVE_DIST)
end

---------------------------------------------------------------------------------------------------

local function StoreItemAction(inst)
	if inst.LOW_BATTERY_GOHOME and
		inst.components.fueled:GetPercent() < TUNING.WINONA_STORAGE_ROBOT_LOW_FUEL_PCT and
		StorageRobotCommon.GetSpawnPoint(inst)
	then
		return
	end

    local item = inst.components.inventory:GetFirstItemInAnySlot() or inst.components.inventory:GetActiveItem() -- This is intentionally backwards to give the bigger stacks first.

    if item == nil then
        return nil
    end

    inst.brain:UnignoreItem()

    local container = StorageRobotCommon.FindContainerWithItem(inst, item)

    return container ~= nil and BufferedAction(inst, container, ACTIONS.STORE, item) or nil
end

---------------------------------------------------------------------------------------------------

local function GoHomeAction(inst)
    local pos = StorageRobotCommon.GetSpawnPoint(inst)

    if pos == nil then
        return
    end

    inst.brain:UnignoreItem()

    local item = inst.components.inventory:GetFirstItemInAnySlot() or inst.components.inventory:GetActiveItem() -- This is intentionally backwards to give the bigger stacks first.

	--V2C: Why are we doing work in a GET action function?
    if item ~= nil then
        inst.components.inventory:DropItem(item, true, true)
    end

	--V2C: Why are we not using Leash?
	--     For now, just adding this min-dist check so we don't get locked in this node forever.
	if inst:GetDistanceSqToPoint(pos) < 0.25 then
		return
	end
    return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pos, nil, 0.2)
end

---------------------------------------------------------------------------------------------------

function StorageRobotBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode( function() return not self.inst.sg:HasAnyStateTag("busy", "broken") end, "NO BRAIN WHEN BUSY OR BROKEN",
            PriorityNode({
                DoAction( self.inst, PickUpAction,     "Pick Up Item",    true ),
                DoAction( self.inst, StoreItemAction,  "Store Item",      true ),
                DoAction( self.inst, GoHomeAction,     "Return to spawn", true ),
				ParallelNode{
					StandStill(self.inst),
					SequenceNode{
						ParallelNodeAny{
							WaitNode(6),
							ConditionWaitNode(function()
								return self.inst.LOW_BATTERY_GOHOME
									and self.inst.components.fueled:GetPercent() < TUNING.WINONA_STORAGE_ROBOT_LOW_FUEL_PCT
							end),
						},
						ActionNode(function()
							self.inst:PushEvent("sleepmode")
						end),
					},
				},
            }, .25)
        ),
    }, .25)

    self.bt = BT(self.inst, root)
end

function StorageRobotBrain:OnInitializationComplete()
    StorageRobotCommon.UpdateSpawnPoint(self.inst, true)
end

return StorageRobotBrain
