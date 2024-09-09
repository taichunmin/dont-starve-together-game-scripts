
local function onenabled(self, enabled)
    if enabled then
        self.inst:AddTag("vase")
    else
        self.inst:RemoveTag("vase")
    end
end


local Vase = Class(function(self, inst)
    self.inst = inst
    self.deleteitemonaccept = true
    self.enabled = true
end,
nil,
{
    enabled = onenabled,
})

function Vase:OnRemoveFromEntity()
    self.inst:RemoveTag("vase")
end

function Vase:Enable()
    self.enabled = true
end

function Vase:Disable()
    self.enabled = false
end

function Vase:Decorate(giver, item)
	if item == nil or not self.enabled then
		return false
	end

	if item.components.stackable and item.components.stackable:IsStack() then
		item = item.components.stackable:Get()
    else
        item.components.inventoryitem:RemoveFromOwner(true)
    end

    if self.deleteitemonaccept then
        item:Remove()
    end

    if self.ondecorate ~= nil then
        self.ondecorate(self.inst, giver, item)
    end

    return true
end

function Vase:GetDebugString()
    return "enabled: "..tostring(self.enabled)
end

return Vase
