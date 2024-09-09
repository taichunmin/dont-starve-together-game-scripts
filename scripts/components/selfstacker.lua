--Accessed by the item-stacking gnome.

local SelfStacker = Class(function(self, inst)
    self.inst = inst

    self.searchradius = 20
    --self.stackpartner = nil
    --self.ignoremovingfast = nil

    -- NOTES(JBK): Recommended to explicitly add tag to prefab pristine state.
    self.inst:AddTag("selfstacker")
end)

function SelfStacker:SetIgnoreMovingFast(ignorespeedcheck)
    self.ignoremovingfast = ignorespeedcheck == true or nil
end

function SelfStacker:CanSelfStack()
	-- Not in a trap, not burning, not in inventory, can be stacked, not moving fast.
	return (self.inst.components.bait == nil or self.inst.components.bait:IsFree()) and
    (self.inst.components.burnable == nil or not self.inst.components.burnable:IsBurning()) and
	(self.inst.components.stackable and not self.inst.components.stackable:IsFull()) and
	(self.inst.components.inventoryitem and not self.inst.components.inventoryitem:IsHeld()) and
	(self.ignoremovingfast or Vector3(self.inst.Physics:GetVelocity()):LengthSq() < 1) and not
	self.stackpartner
end

function SelfStacker:OnRemoveEntity()
    if self.stacktask ~= nil then
        self.stacktask:Cancel()
        self.stacktask = nil
    end
    self.inst:RemoveTag("selfstacker")
end

local SELFSTACKER_MUST_TAGS = {"selfstacker"}
function SelfStacker:FindItemToStackWith()
	self.stackpartner = FindEntity(self.inst, self.searchradius, function(item) return item.prefab == self.inst.prefab and item.skinname == self.inst.skinname and item.components.selfstacker:CanSelfStack() end, SELFSTACKER_MUST_TAGS)
	if self.stackpartner then
		self.stackpartner.components.selfstacker.stackpartner = self.inst
	end

	return self.stackpartner
end

function SelfStacker:DoStack()
    if self.stacktask ~= nil then
        self.stacktask:Cancel()
        self.stacktask = nil
    end
	if self:FindItemToStackWith() then
		local num = self.inst.components.stackable:RoomLeft()
		local to_combine = self.stackpartner.components.stackable:Get(num)
		self.inst.components.stackable:Put(to_combine)
	end
end

function SelfStacker:OnEntityWake()
	self.stackpartner = nil
	if self:CanSelfStack() then
        if self.stacktask ~= nil then
            self.stacktask:Cancel()
            self.stacktask = nil
        end
		self.stacktask = self.inst:DoTaskInTime(math.random() * .1, function() self:DoStack() end)
	end
end

return SelfStacker