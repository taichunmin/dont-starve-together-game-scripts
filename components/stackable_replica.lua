local STACK_SIZES =
{
    TUNING.STACK_SIZE_MEDITEM,
    TUNING.STACK_SIZE_SMALLITEM,
    TUNING.STACK_SIZE_LARGEITEM,
}
local STACK_SIZE_CODES = table.invert(STACK_SIZES)

local Stackable = Class(function(self, inst)
    self.inst = inst

    self._stacksize = net_smallbyte(inst.GUID, "stackable._stacksize", "stacksizedirty")
    self._maxsize = net_tinybyte(inst.GUID, "stackable._maxsize")
end)

function Stackable:SetStackSize(stacksize)
    self._stacksize:set(stacksize - 1)
end

function Stackable:SetMaxSize(maxsize)
    self._maxsize:set(STACK_SIZE_CODES[maxsize] - 1)
end

function Stackable:StackSize()
    return self._stacksize:value() + 1
end

function Stackable:MaxSize()
    return STACK_SIZES[self._maxsize:value() + 1]
end

function Stackable:IsStack()
    return self:StackSize() > 1
end

function Stackable:IsFull()
    return self:StackSize() >= self:MaxSize()
end

return Stackable