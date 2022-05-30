local _src_pos = nil

local function onstacksize(self, stacksize)
    self.inst.replica.stackable:SetStackSize(stacksize)
    if self.inst.replica.inventoryitem ~= nil then
        self.inst.replica.inventoryitem:SetPickupPos(_src_pos)
    end
end

local function onmaxsize(self, maxsize)
    self.inst.replica.stackable:SetMaxSize(maxsize)
end

local Stackable = Class(function(self, inst)
    self.inst = inst

    self.stacksize = 1 -- Its a stack of one (ie the first item)
    self.maxsize = TUNING.STACK_SIZE_MEDITEM
end,
nil,
{
    stacksize = onstacksize,
    maxsize = onmaxsize,
})

function Stackable:IsStack()
    return self.stacksize > 1
end

function Stackable:StackSize()
    return self.stacksize
end

function Stackable:IsFull()
    return self.stacksize >= self.maxsize
end

function Stackable:OnSave()
    if self.stacksize ~= 1 then
        return {stack = self.stacksize}
    end
end

function Stackable:OnLoad(data)
    self.stacksize = data.stack or self.stacksize
    self.inst:PushEvent("stacksizechange", {stacksize = self.stacksize, oldstacksize=1})
end

function Stackable:SetOnDeStack(fn)
    self.ondestack = fn
end

function Stackable:SetStackSize(sz)
    local old_size = self.stacksize
    self.stacksize = sz
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
            self.ondestack(instance)
        end

        if instance.components.perishable ~= nil then
            instance.components.perishable.perishremainingtime = self.inst.components.perishable.perishremainingtime
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
        self.stacksize = newsize
        _src_pos = nil
        self.inst:PushEvent("stacksizechange", {stacksize = self.stacksize, oldstacksize=oldsize, src_pos = source_pos})
    end
    return ret
end

return Stackable