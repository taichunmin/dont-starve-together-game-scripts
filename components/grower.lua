local function onfertile(self)
    self.inst:RemoveTag("infertile")
    self.inst:RemoveTag("fertile")
    self.inst:RemoveTag("fullfertile")
    if self.isempty then
        if self.cycles_left <= 0 then
            self.inst:AddTag("infertile")
        elseif self.cycles_left < self.max_cycles_left then
            self.inst:AddTag("fertile")
        else
            self.inst:AddTag("fullfertile")
        end
    end
end

local Grower = Class(function(self, inst)
    self.inst = inst
    self.crops = {}
    self.level = 1
    self.croppoints = {}
    self.growrate = 1
    self.cycles_left = 1
    self.max_cycles_left = 6
    self.isempty = true

    self.inst:AddTag("grower")
end,
nil,
{
    isempty = onfertile,
    cycles_left = onfertile,
    max_cycles_left = onfertile,
})

function Grower:OnRemoveFromEntity()
    self.inst:RemoveTag("infertile")
    self.inst:RemoveTag("fertile")
    self.inst:RemoveTag("fullfertile")
end

function Grower:IsEmpty()
    return self.isempty
end

function Grower:IsFullFertile()
    return self.cycles_left >= self.max_cycles_left
end

function Grower:GetFertilePercent()
    return self.cycles_left / self.max_cycles_left
end

function Grower:IsFertile()
    return self.cycles_left > 0
end

function Grower:OnSave()
    local data = {crops = {}}

    for k, v in pairs(self.crops) do
        local save_record = k:GetSaveRecord()
        table.insert(data.crops, save_record)
    end
    data.cycles_left = self.cycles_left
    return data
end

function Grower:Fertilize(obj, doer)
    local was_fertile = self:IsFertile()

    if obj.components.fertilizer ~= nil then
        if doer ~= nil and
            doer.SoundEmitter ~= nil and
            obj.components.fertilizer.fertilize_sound ~= nil then
            doer.SoundEmitter:PlaySound(obj.components.fertilizer.fertilize_sound)
        end
        self.cycles_left = self.cycles_left + obj.components.fertilizer.soil_cycles
    end

    if self.setfertility ~= nil then
        self.setfertility(self.inst, self:GetFertilePercent())
    end

	return true
end

function Grower:OnLoad(data, newents)
    if data.crops ~= nil then
        for k, v in pairs(data.crops) do
            self.isempty = false
            self.inst:AddTag("NOCLICK")
            local child = SpawnSaveRecord(v, newents)
            if child ~= nil then
                child.components.crop.grower = self.inst
                child.Transform:SetPosition(v.x or 0, v.y or 0, v.z or 0)
                child.persists = false
                self.crops[child] = true
                child.components.crop:Resume()
            end
        end
    end

    self.cycles_left = data.cycles_left or self.cycles_left

    if self.setfertility ~= nil then
        self.setfertility(self.inst, self:GetFertilePercent())
    end
end

function Grower:PlantItem(item, doer)
    if item.components.plantable == nil then
        return false
    end

    self:Reset()

    local prefab = nil
    if item.components.plantable.product and type(item.components.plantable.product) == "function" then
        prefab = item.components.plantable.product(item)
    else
        prefab = item.components.plantable.product or item.prefab
    end

    self.inst:AddTag("NOCLICK")

    local pos = self.inst:GetPosition()

    for i, v in ipairs(self.croppoints) do
        local plant1 = SpawnPrefab("plant_normal")
        plant1.persists = false
        plant1.components.crop:StartGrowing(prefab, item.components.plantable.growtime * self.growrate, self.inst)
        plant1.Transform:SetPosition(pos.x + v.x, pos.y + v.y, pos.z + v.z)

        self.crops[plant1] = true
    end

    self.isempty = false

    if self.onplantfn ~= nil then
        self.onplantfn(item)
    end
    item:Remove()

    TheWorld:PushEvent("itemplanted", { doer = doer, pos = pos }) --this event is pushed in other places too

    return true
end

function Grower:RemoveCrop(crop)
    crop:Remove()
    self.crops[crop] = nil

    for k, v in pairs(self.crops) do
        return
    end

    self.isempty = true
    self.inst:RemoveTag("NOCLICK")
    self.cycles_left = self.cycles_left - 1
    if self.cycles_left < 0 then
        self.cycles_left = 0
    end

    if self.setfertility ~= nil then
        self.setfertility(self.inst, self:GetFertilePercent())
    end
end

function Grower:GetDebugString()
    return "Cycles left" .. tostring(self.cycles_left) .. " / " .. tostring(self.max_cycles_left)
end

function Grower:Reset(reason)
    self.isempty = true
    for k,v in pairs(self.crops) do
        if reason and reason == "fire" then
            local burntproduct = nil
            if k and k.components.crop and k.components.crop.matured and k.components.crop.product_prefab then
                local temp = SpawnPrefab(k.components.crop.product_prefab)
                if temp.components.cookable and temp.components.cookable.product then
                    burntproduct = SpawnPrefab(temp.components.cookable.product)
                else
                    burntproduct = SpawnPrefab("ash")
                end
                temp:Remove()
            else
                burntproduct = SpawnPrefab("seeds_cooked")
            end
            burntproduct.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
            self.inst:ListenForEvent("onpickup", function(it, data)
                self.inst:RemoveTag("NOCLICK")
            end, burntproduct)
            self.inst:ListenForEvent("onremove", function(it, data)
                self.inst:RemoveTag("NOCLICK")
            end, burntproduct)
        else
            self.inst:RemoveTag("NOCLICK")
        end
        k:Remove()
    end
    self.crops = {}
end

return Grower
