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
    local receiver = owner ~= nil and (owner.components.inventory or owner.components.container) or nil

    local loot = target.components.lootdropper:GetFullRecipeLoot(AllRecipes[target.prefab])
    target:Remove() -- We remove the target before giving the loot to make more space in the inventory

    for _, prefab in ipairs(loot) do
		if prefab ~= "nightmarefuel" then
			if receiver ~= nil then
		        receiver:GiveItem(SpawnPrefab(prefab), nil, self.inst:GetPosition())
			else
				target.components.lootdropper:SpawnLootPrefab(prefab)
			end
		end
    end

    SpawnPrefab("brokentool").Transform:SetPosition(doer.Transform:GetWorldPosition())
end

return PocketWatch_Dismantler
