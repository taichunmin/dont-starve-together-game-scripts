local function onitem(self, item)
	if item ~= nil then
		self.inst:AddTag("usingmagiciantool")
	else
		self.inst:RemoveTag("usingmagiciantool")
	end
end

local function onequip(self, equip)
	if equip then
		self.inst:AddTag("usingmagiciantool_wasequipped")
	else
		self.inst:RemoveTag("usingmagiciantool_wasequipped")
	end
end

local Magician = Class(function(self, inst)
	self.inst = inst
	self.item = nil
	self.held = nil
	self.equip = nil

	--V2C: Recommended to explicitly add tag to prefab pristine state
	inst:AddTag("magician")
end,
nil,
{
	item = onitem,
	equip = onequip,
})

function Magician:OnRemoveFromEntity()
	self:StopUsing()
	self.inst:RemoveTag("magician")
	self.inst:RemoveTag("usingmagiciantool")
	self.inst:RemoveTag("usingmagiciantool_wasequipped")
end

function Magician:DropToolOnStop()
	self.held = nil
	self.equip = nil
end

function Magician:StartUsingTool(item)
	if self.item ~= nil or item.components.magiciantool == nil then
		return false
	end

	if item.components.inventoryitem ~= nil then
		local owner = item.components.inventoryitem:GetGrandOwner()
		if owner ~= nil then
			local container = owner.components.inventory or owner.components.container 
			if not container:IsOpenedBy(self.inst) then
				return false
			end
			self.held = true
		end
	end

	self.equip = item.components.equippable ~= nil and item.components.equippable:IsEquipped() or nil

	self.item =
		(self.held and item.components.inventoryitem:RemoveFromOwner()) or
		(item.components.stackable ~= nil and item.components.stackable:Get()) or
		item

	self.item.persists = false
	self.item.entity:SetParent(self.inst.entity)
	self.item:RemoveFromScene()
	self.item.Transform:SetPosition(0, 0, 0)

	if self.item.components.magiciantool ~= nil then
		self.item.components.magiciantool:OnStartUsing(self.inst)
	end
	return true
end

function Magician:StopUsing()
	local item = self.item
	if item == nil then
		return false
	end

	local washeld = self.held
	local wasequip = self.equip

	self.item = nil
	self.held = nil
	self.equip = nil

	if item.components.magiciantool ~= nil then
		item.components.magiciantool:OnStopUsing(self.inst)
	end

	item.entity:SetParent(nil)
	item:ReturnToScene()
	item.persists = true

	if washeld and self.inst.components.inventory ~= nil then
		if wasequip and
			item.components.equippable ~= nil and
			self.inst.components.inventory:GetEquippedItem(item.components.equippable.equipslot) == nil then
			self.inst.components.inventory:Equip(item)
		else
			self.inst.components.inventory.silentfull = true
			self.inst.components.inventory:GiveItem(item, nil, self.inst:GetPosition())
			self.inst.components.inventory.silentfull = false
		end
	else
		local x, y, z = self.inst.Transform:GetWorldPosition()
		item.components.inventoryitem:DoDropPhysics(x, y, z, true)
	end

	self.inst:PushEvent("magicianstopped")

	return true
end

function Magician:OnSave()
	if self.item ~= nil then
		return
		{
			item = self.item:GetSaveRecord(),
			held = self.held and not self.equip or nil,
			equip = self.equip or nil,
		}
	end
end

function Magician:OnLoad(data)
	if data ~= nil and data.item ~= nil then
		self.item = SpawnSaveRecord(data.item)
		if self.item ~= nil then
			self.held = data.held or data.equip
			self.equip = data.equip
		end
	end
end

return Magician
