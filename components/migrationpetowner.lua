local MigrationPetOwner = Class(function(self, inst)
    -- A lightweight component to easily pass through a prefab
    -- capable of migrating alongside an inventory item.

    self.inst = inst

    --self.get_pet_fn = nil
end)

function MigrationPetOwner:SetPetFn(petfn)
    self.get_pet_fn = petfn
end

function MigrationPetOwner:GetPet()
    return (self.get_pet_fn ~= nil and self.get_pet_fn(self.inst))
            or nil
end

return MigrationPetOwner
