local STACK_SIZES =
{
    TUNING.STACK_SIZE_MEDITEM,
    TUNING.STACK_SIZE_SMALLITEM,
    TUNING.STACK_SIZE_LARGEITEM,
    TUNING.STACK_SIZE_TINYITEM,
}
local STACK_SIZE_CODES = table.invert(STACK_SIZES)

local function OnStackSizeDirty(inst)
	local self = inst.replica.stackable
	if not self then
		return --stackable removed?
	end

	self:ClearPreviewStackSize()

	--instead of inventoryitem_classified listening for "stacksizedirty" as well
	--forward a new event to guarantee order
	inst:PushEvent("inventoryitem_stacksizedirty")
end

local Stackable = Class(function(self, inst)
    self.inst = inst

    self._stacksize = net_smallbyte(inst.GUID, "stackable._stacksize", "stacksizedirty")
	self._stacksizeupper = net_smallbyte(inst.GUID, "stackable._stacksizeupper", "stacksizedirty")
	self._ignoremaxsize = net_bool(inst.GUID, "stackable._ignoremaxsize")
    self._maxsize = net_tinybyte(inst.GUID, "stackable._maxsize")

    if not TheWorld.ismastersim then
		--self._previewstacksize = nil
		--self._previewtimeouttask = nil
		inst:ListenForEvent("stacksizedirty", OnStackSizeDirty)
    end
end)

--V2C: OnRemoveFromEntity not supported
--[[function Stackable:OnRemoveFromEntity()
	if not TheWorld.ismastersim then
		self.inst:RemoveEventCallback("stacksizedirty", OnStackSizeDirty)
		self:ClearPreviewStackSize()
	end
end]]

function Stackable:SetStackSize(stacksize)
	stacksize = stacksize - 1
	if stacksize <= 63 then
		self._stacksizeupper:set(0)
		self._stacksize:set(stacksize)
	elseif stacksize >= 4095 then
		if self._stacksizeupper:value() ~= 63 then
			self._stacksizeupper:set(63)
		else
			self._stacksize:set_local(63) --force sync to trigger UI events even when capped
		end
		self._stacksize:set(63)
	else
		local upper = math.floor(stacksize / 64)
		self._stacksizeupper:set(upper)
		self._stacksize:set(stacksize - upper * 64)
	end
end

local function OnPreviewTimeout(inst, self)
	self._previewtimeouttask = nil
	self._previewstacksize = nil
end

function Stackable:SetPreviewStackSize(stacksize, context, timeout)
	if not TheWorld.ismastersim then
		if self._previewstacksize then
			self._previewstacksize[context] = stacksize
		else
			self._previewstacksize = { [context] = stacksize }
		end

		if self._previewtimeouttask then
			self._previewtimeouttask:Cancel()
		end
		self._previewtimeouttask = self.inst:DoStaticTaskInTime(timeout or 2, OnPreviewTimeout, self)
	end
end

function Stackable:ClearPreviewStackSize()
	if self._previewtimeouttask then
		self._previewtimeouttask:Cancel()
		self._previewtimeouttask = nil
	end
	self._previewstacksize = nil
end

function Stackable:GetPreviewStackSize()
	return self._previewstacksize and self._previewstacksize[self.inst.stackable_preview_context] or nil
end

function Stackable:SetMaxSize(maxsize)
    self._maxsize:set(STACK_SIZE_CODES[maxsize] - 1)
end

function Stackable:SetIgnoreMaxSize(ignoremaxsize)
	self._ignoremaxsize:set(ignoremaxsize)
end

function Stackable:StackSize()
	return self:GetPreviewStackSize() or (self._stacksizeupper:value() * 64 + self._stacksize:value() + 1)
end

function Stackable:MaxSize()
	return self._ignoremaxsize:value() and math.huge or STACK_SIZES[self._maxsize:value() + 1]
end

function Stackable:OriginalMaxSize()
	return STACK_SIZES[self._maxsize:value() + 1]
end

function Stackable:IsStack()
	return self:StackSize() > 1
end

function Stackable:IsFull()
	return self:StackSize() >= self:MaxSize()
end

function Stackable:IsOverStacked()
	return self:StackSize() > self:OriginalMaxSize()
end

return Stackable