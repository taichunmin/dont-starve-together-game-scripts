local PetLeash = Class(function(self, inst)
    self.inst = inst

    self.petprefab = nil
    self.pets = {}
    self.maxpets = 1
    self.numpets = 0
    self.maxpetsperprefab = nil
    self.numpetsperprefab = nil

    self.onspawnfn = nil
    self.ondespawnfn = nil
    self.onpetremoved = nil

    self._onremovepet = function(pet)
        if self.pets[pet] ~= nil then
            self.pets[pet] = nil

            if self:IsPetAPrefabLimitedOne(pet.prefab) then
                self.numpetsperprefab[pet.prefab] = self.numpetsperprefab[pet.prefab] - 1
            else
                self.numpets = self.numpets - 1
            end
            if self.onpetremoved ~= nil then
                self.onpetremoved(self.inst, pet)
            end
        end
    end
end)

function PetLeash:SetPetPrefab(prefab)
    self.petprefab = prefab
end

function PetLeash:SetOnSpawnFn(fn)
    self.onspawnfn = fn
end

function PetLeash:SetOnDespawnFn(fn)
    self.ondespawnfn = fn
end

function PetLeash:SetOnRemovedFn(fn)
    self.onpetremoved = fn
end

function PetLeash:SetMaxPets(num)
    self.maxpets = num
end

function PetLeash:GetMaxPets()
    return self.maxpets
end

function PetLeash:GetNumPets()
    return self.numpets
end

function PetLeash:IsFull()
    return self.numpets >= self.maxpets
end

function PetLeash:IsPetAPrefabLimitedOne(prefab)
    if self.maxpetsperprefab == nil then
        return false
    end

    return self.maxpetsperprefab[prefab] ~= nil
end

function PetLeash:SetMaxPetsForPrefab(prefab, maxpets)
    self.maxpetsperprefab = self.maxpetsperprefab or {}
    self.maxpetsperprefab[prefab] = maxpets

    self.numpetsperprefab = self.numpetsperprefab or {}
    self.numpetsperprefab[prefab] = self.numpetsperprefab[prefab] or 0
end

function PetLeash:GetMaxPetsForPrefab(prefab)
    if self.maxpetsperprefab == nil then
        return 0
    end

    return self.maxpetsperprefab[prefab] or 0
end

function PetLeash:GetNumPetsForPrefab(prefab)
    if self.numpetsperprefab == nil then
        return 0
    end

    return self.numpetsperprefab and self.numpetsperprefab[prefab] or 0
end

function PetLeash:GetPetsWithPrefab(prefab)
    if self:GetNumPetsForPrefab(prefab) == 0 then
        return nil
    end

    local pets = {}
    for k, v in pairs(self.pets) do
        if v.prefab == prefab then
            table.insert(pets, v)
        end
    end

    return pets
end

function PetLeash:IsFullForPrefab(prefab)
    return self:GetNumPetsForPrefab(prefab) >= self:GetMaxPetsForPrefab(prefab)
end

function PetLeash:HasPetWithTag(tag)
    for k, v in pairs(self.pets) do
        if v:HasTag(tag) then
            return true
        end
    end
    return false
end

function PetLeash:GetPets()
    return self.pets
end

function PetLeash:IsPet(pet)
    return self.pets[pet] ~= nil
end

local function LinkPet(self, pet)
    self.pets[pet] = pet
    if self:IsPetAPrefabLimitedOne(pet.prefab) then
        self.numpetsperprefab[pet.prefab] = self.numpetsperprefab[pet.prefab] + 1
    else
        self.numpets = self.numpets + 1
    end
    self.inst:ListenForEvent("onremove", self._onremovepet, pet)
    pet.persists = false

    if self.inst.components.leader ~= nil then
        self.inst.components.leader:AddFollower(pet)
    end
end

function PetLeash:SpawnPetAt(x, y, z, prefaboverride, skin)
    local prefab = prefaboverride or self.petprefab
    if prefab == nil then
        return nil
    end
    if self:IsPetAPrefabLimitedOne(prefab) then
        if self:IsFullForPrefab(prefab) then
            return nil
        end
    else
        if self:IsFull() then
            return nil
        end
    end

    local pet = SpawnPrefab(prefab, skin, nil, self.inst.userid)
    if pet ~= nil then
        LinkPet(self, pet)

        if pet.Physics ~= nil then
            pet.Physics:Teleport(x, y, z)
        elseif pet.Transform ~= nil then
            pet.Transform:SetPosition(x, y, z)
        end

        if self.onspawnfn ~= nil then
            self.onspawnfn(self.inst, pet)
        end
    end

    return pet
end

function PetLeash:DespawnPet(pet)
    if self.pets[pet] ~= nil then
        if self.ondespawnfn ~= nil then
            self.ondespawnfn(self.inst, pet)
        else
            pet:Remove()
        end
    end
end

function PetLeash:DespawnAllPets()
    local toremove = {}
    for k, v in pairs(self.pets) do
        table.insert(toremove, v)
    end
    for i, v in ipairs(toremove) do
        self:DespawnPet(v)
    end
end

function PetLeash:OnSave()
    if next(self.pets) ~= nil then
        local data = {}
        for k, v in pairs(self.pets) do
			v.temp_save_platform_pos = true
            local saved--[[, refs]] = v:GetSaveRecord()
			v.temp_save_platform_pos = nil
            table.insert(data, saved)
        end
        return { pets = data }
    end
end

function PetLeash:OnLoad(data)
    if data ~= nil and data.pets ~= nil then
        for i, v in ipairs(data.pets) do
			v.is_snapshot_save_record = self.inst.is_snapshot_user_session
            local pet = SpawnSaveRecord(v)
			v.is_snapshot_save_record = nil
            if pet ~= nil then
                LinkPet(self, pet)

                if self.onspawnfn ~= nil then
                    self.onspawnfn(self.inst, pet)
                end
            end
        end
        if self.inst.migrationpets ~= nil then
            for k, v in pairs(self.pets) do
                table.insert(self.inst.migrationpets, v)
            end
        end
    end
end

function PetLeash:OnRemoveFromEntity()
    for k, v in pairs(self.pets) do
        self.inst:RemoveEventCallback("onremove", self._onremovepet, v)
    end
end

PetLeash.OnRemoveEntity = PetLeash.DespawnAllPets

function PetLeash:TransferComponent(newinst)
    local newcomponent = newinst.components.petleash

end

return PetLeash
