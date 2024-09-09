local _src_pos = nil

local function onstacksize(self, stacksize)
    self.inst.replica.stackable:SetStackSize(stacksize)
	local inventoryitem = self.inst.replica.inventoryitem
	if inventoryitem ~= nil then
		inventoryitem:SetPickupPos(_src_pos)
    end
end

local function onmaxsize(self, maxsize)
	local _ = rawget(self, "_") --see class.lua for property setters implementation
	if _.originalmaxsize[1] then
		-- Trying to change maxsize while infinite maxsize is toggled on?
		-- -> store maxsize changes in originalmaxsize instead
		-- -> set current maxsize back to infinity
		_.originalmaxsize[1] = maxsize
		_.maxsize[1] = math.huge
	end
    self.inst.replica.stackable:SetMaxSize(maxsize)
end

local Stackable = Class(function(self, inst)
    self.inst = inst

    self.stacksize = 1 -- Its a stack of one (ie the first item)
	makereadonly(self, "originalmaxsize")
    self.maxsize = TUNING.STACK_SIZE_MEDITEM
end,
nil,
{
    stacksize = onstacksize,
    maxsize = onmaxsize,
})

function Stackable:SetIgnoreMaxSize(ignoremaxsize)
	local _ = rawget(self, "_") --see class.lua for property setters implementation
	if ignoremaxsize then
		local old = _.maxsize[1]
		if old ~= math.huge then
			_.originalmaxsize[1] = old
			_.maxsize[1] = math.huge
			self.inst.replica.stackable:SetIgnoreMaxSize(true)
		end
	else
		local original = _.originalmaxsize[1]
		if original then
			_.maxsize[1] = original
			_.originalmaxsize[1] = nil
			self.inst.replica.stackable:SetIgnoreMaxSize(false)
		end
	end
end

function Stackable:IsStack()
    return self.stacksize > 1
end

function Stackable:StackSize()
    return self.stacksize
end

function Stackable:IsFull()
    return self.stacksize >= self.maxsize
end

--oversized stack (possible when maxsize is set to be ignored)
function Stackable:IsOverStacked()
	return self.stacksize > (self.originalmaxsize or self.maxsize)
end

function Stackable:OnSave()
    if self.stacksize ~= 1 then
        return {stack = self.stacksize}
    end
end

function Stackable:OnLoad(data)
	self.stacksize = math.min(data.stack or self.stacksize, MAXUINT)
    self.inst:PushEvent("stacksizechange", {stacksize = self.stacksize, oldstacksize=1})
end

function Stackable:SetOnDeStack(fn)
    self.ondestack = fn
end

function Stackable:SetStackSize(sz)
    local old_size = self.stacksize
	self.stacksize = math.min(sz, MAXUINT)
    self.inst:PushEvent("stacksizechange", {stacksize = sz, oldstacksize=old_size})
end

function Stackable:Get(num)
    local num_to_get = num or 1
    -- If we have more than one item in the stack
    if self.stacksize > num_to_get then
        local instance = SpawnPrefab( self.inst.prefab, self.inst.skinname, self.inst.skin_id, nil )


        self:SetStackSize(self.stacksize - num_to_get)
        instance.components.stackable:SetStackSize(num_to_get)

        if self.ondestack ~= nil then
            self.ondestack(instance, self.inst)
        end

        if instance.components.perishable ~= nil then
            instance.components.perishable.perishremainingtime = self.inst.components.perishable.perishremainingtime
        end

        if instance.components.curseditem ~= nil and self.inst.components.curseditem ~= nil then
            self.inst.components.curseditem:CopyCursedFields(instance.components.curseditem)
            if self.inst:HasTag("applied_curse") then
                instance.skipspeech = true
                instance:AddTag("applied_curse")
            end
        end

        if instance.components.rechargeable ~= nil and self.inst.components.rechargeable ~= nil then
            if not self.inst.components.rechargeable:IsCharged() then
                instance.components.rechargeable:SetChargeTime(self.inst.components.rechargeable:GetChargeTime())
                instance.components.rechargeable:SetCharge(self.inst.components.rechargeable:GetCharge())
            end
        end

        if instance.components.inventoryitem ~= nil and self.inst.components.inventoryitem ~= nil then
            if self.inst.components.inventoryitem.owner then
                instance.components.inventoryitem:OnPutInInventory(self.inst.components.inventoryitem.owner)
            end
            instance.components.inventoryitem:InheritMoisture(self.inst.components.inventoryitem:GetMoisture(), self.inst.components.inventoryitem:IsWet())
        end

        return instance
    end

    return self.inst
end

function Stackable:RoomLeft()
    return self.maxsize - self.stacksize
end

function Stackable:Put(item, source_pos)
    assert(item ~= self, "cant stack on self" )
    local ret
    if item.prefab == self.inst.prefab and item.skinname == self.inst.skinname then

        local num_to_add = item.components.stackable.stacksize
        local newtotal = self.stacksize + num_to_add

        local oldsize = self.stacksize
        local newsize = math.min(self.maxsize, newtotal)
        local numberadded = newsize - oldsize

        if self.inst.components.perishable ~= nil then
            self.inst.components.perishable:Dilute(numberadded, item.components.perishable.perishremainingtime)
        end

        if self.inst.components.inventoryitem ~= nil then
            self.inst.components.inventoryitem:DiluteMoisture(item, numberadded)
        end

        if self.inst.components.edible ~= nil then
            self.inst.components.edible:DiluteChill(item, numberadded)
        end

        if self.inst.components.curseditem ~= nil then
            self.inst.skipspeech = true
        end

        if self.maxsize >= newtotal then
            item:Remove()
        else
            _src_pos = source_pos
            item.components.stackable.stacksize = newtotal - self.maxsize
            _src_pos = nil
            item:PushEvent("stacksizechange", {stacksize = item.components.stackable.stacksize, oldstacksize=num_to_add, src_pos = source_pos })
            ret = item
        end

        _src_pos = source_pos
		self.stacksize = math.min(newsize, MAXUINT)
        _src_pos = nil
        self.inst:PushEvent("stacksizechange", {stacksize = self.stacksize, oldstacksize=oldsize, src_pos = source_pos})
    end
    return ret
end

function Stackable:GetDebugString()
	local str = string.format("%d/%s", self.stacksize, self.maxsize == math.huge and "--" or tostring(self.maxsize))
	if self.originalmaxsize then
		str = str..string.format("(%d)", self.originalmaxsize)
	end
	return str
end

return Stackable