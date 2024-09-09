local PocketWatch_Dismantler = Class(function(self, inst)
    self.inst = inst
end)

function PocketWatch_Dismantler:CanDismantle(target, doer)
	if target.components.rechargeable ~= nil and not target.components.rechargeable:IsCharged() then
        return false, "ONCOOLDOWN"
    end
	if not doer:HasTag("clockmaker") then
		return false
	end

    return true
end

function PocketWatch_Dismantler:Dismantle(target, doer)
    local owner = target.components.inventoryitem:GetGrandOwner()
    local receiver = owner ~= nil and not owner:HasTag("pocketdimension_container") and (owner.components.inventory or owner.components.container) or nil
    local pt = receiver ~= nil and self.inst:GetPosition() or doer:GetPosition()

    local loot = target.components.lootdropper:GetFullRecipeLoot(AllRecipes[target.prefab])
    target:Remove() -- We remove the target before giving the loot to make more space in the inventory

    for _, prefab in ipairs(loot) do
		if prefab ~= "nightmarefuel" then
			if receiver ~= nil then
		        receiver:GiveItem(SpawnPrefab(prefab), nil, pt)
			else
				target.components.lootdropper:SpawnLootPrefab(prefab, pt)
			end
		end
    end

    SpawnPrefab("brokentool").Transform:SetPosition(doer.Transform:GetWorldPosition())
end

return PocketWatch_Dismantler
