local Stats = require("stats")

local function onbuilder(self, builder)
	self.inst.replica.constructionsite:SetBuilder(builder)
end

local function onenabled(self, enabled)
	self.inst.replica.constructionsite:SetEnabled(enabled)
end

local EMPTY_TABLE = {}

local ConstructionSite = Class(function(self, inst)
    self.inst = inst
    self.materials = {}
    self.builder = nil
    self.constructionprefab = nil
    self.onstartconstructionfn = nil
    self.onstopconstructionfn = nil
    self.onconstructedfn = nil

	self.enabled = true

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("constructionsite")
end,
nil,
{
    builder = onbuilder,
	enabled = onenabled,
})

function ConstructionSite:ForceStopConstruction()
	if self.builder ~= nil and
		self.builder.components.constructionbuilder ~= nil and
		self.builder.components.constructionbuilder.constructionsite == self.inst then
		--
		self.builder.components.constructionbuilder:StopConstruction()
	end
end

ConstructionSite.OnRemoveFromEntity = ConstructionSite.ForceStopConstruction

function ConstructionSite:Enable()
	self.enabled = true
end

function ConstructionSite:Disable()
	self:ForceStopConstruction()
	self.enabled = false
end

function ConstructionSite:IsEnabled()
	return self.enabled
end

function ConstructionSite:SetConstructionPrefab(prefab)
    self.constructionprefab = prefab
end

function ConstructionSite:SetOnStartConstructionFn(fn)
    self.onstartconstructionfn = fn
end

function ConstructionSite:SetOnStopConstructionFn(fn)
    self.onstopconstructionfn = fn
end

function ConstructionSite:SetOnConstructedFn(fn)
    self.onconstructedfn = fn
end

function ConstructionSite:OnStartConstruction(doer)
    self.builder = doer
    if self.onstartconstructionfn ~= nil then
        self.onstartconstructionfn(self.inst, doer)
    end
end

function ConstructionSite:OnStopConstruction(doer)
    self.builder = nil
    if self.onstopconstructionfn ~= nil then
        self.onstopconstructionfn(self.inst, doer)
    end
end

function ConstructionSite:OnConstruct(doer, items)
	local stats = {
		prefab = self.inst.prefab,
		target = tostring(self.inst.GUID),
		recipe_items = {}
	}

    local x, y, z = self.inst.Transform:GetWorldPosition()
    for i, v in ipairs(items) do
        local remainder = self:AddMaterial(v.prefab, v.components.stackable ~= nil and v.components.stackable:StackSize() or 1)
		table.insert(stats.recipe_items, {prefab = v.prefab, count = (v.components.stackable ~= nil and v.components.stackable:StackSize() or 1) - remainder})
        if remainder > 0 then
            if v.components.stackable ~= nil then
                v.components.stackable:SetStackSize(math.min(remainder, v.components.stackable.maxsize))
            end
            -- NOTES(JBK): Stopping the dropping mechanic for overfilling a construction and instead return excess to the builder if it exists and is a player for QoL.
            if self.builder ~= nil and self.builder.components.inventory ~= nil and self.builder:HasTag("player") then
                self.builder.components.inventory:GiveItem(v)
            else
                v.components.inventoryitem:RemoveFromOwner(true)
                v.components.inventoryitem:DoDropPhysics(x, y, z, true)
            end
        else
            v:Remove()
        end
    end
    self.builder = nil

	stats.victory = self:IsComplete()
	Stats.PushMetricsEvent("constructionsite", doer, stats)

    if self.onconstructedfn ~= nil then
        self.onconstructedfn(self.inst, doer)
    end
end

function ConstructionSite:HasBuilder()
    return self.builder ~= nil
end

function ConstructionSite:IsBuilder(guy)
    return guy ~= nil and self.builder == guy
end

function ConstructionSite:AddMaterial(prefab, num)
    --Return remainder
    local material = self.materials[prefab]
    if material == nil then
        for i, v in ipairs(CONSTRUCTION_PLANS[self.inst.prefab] or EMPTY_TABLE) do
            if v.type == prefab then
                local delta = math.min(num, v.amount)
                self.materials[prefab] = { amount = delta, slot = i }
                self.inst.replica.constructionsite:SetSlotCount(i, delta)
                return num - delta
            end
        end
    elseif material.slot ~= nil then
        local delta = math.min(num, math.max(0, (((CONSTRUCTION_PLANS[self.inst.prefab] or EMPTY_TABLE)[material.slot] or EMPTY_TABLE).amount or 0) - material.amount))
        material.amount = material.amount + delta
        self.inst.replica.constructionsite:SetSlotCount(material.slot, material.amount)
        return num - delta
    end
    return num
end

function ConstructionSite:RemoveMaterial(prefab, num)
	--Return amount removed
	local material = self.materials[prefab]
	if material ~= nil then
		num = math.min(num or 1, material.amount)
		material.amount = material.amount - num
		if material.slot ~= nil then
			self.inst.replica.constructionsite:SetSlotCount(material.slot, material.amount)
		end
		if material.amount <= 0 then
			self.materials[prefab] = nil
		end
		return num
	end
	return 0
end

function ConstructionSite:DropAllMaterials(drop_pos)
	local x, y, z
	if drop_pos ~= nil then
		x, y, z = drop_pos:Get()
	else
		x, y, z = self.inst.Transform:GetWorldPosition()
	end
	for k, v in pairs(self.materials) do
		local num = self:RemoveMaterial(k, v.amount)
		while num > 0 do
			local loot = SpawnPrefab(k)
			if loot.components.stackable ~= nil then
				loot.components.stackable:SetStackSize(math.min(num, loot.components.stackable.maxsize))
				num = num - loot.components.stackable:StackSize()
			else
				num = num - 1
			end
			if loot.components.inventoryitem ~= nil then
				loot.components.inventoryitem:DoDropPhysics(x, y, z, true)
			else
				loot.Transform:SetPosition(x, y, z)
			end
		end
	end
end

function ConstructionSite:GetMaterialCount(prefab)
    return (self.materials[prefab] or EMPTY_TABLE).amount or 0
end

function ConstructionSite:GetSlotCount(slot)
    return self:GetMaterialCount(((CONSTRUCTION_PLANS[self.inst.prefab] or EMPTY_TABLE)[slot] or EMPTY_TABLE).type)
end

function ConstructionSite:IsComplete()
    for i, v in ipairs(CONSTRUCTION_PLANS[self.inst.prefab] or {}) do
        if self.inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
            return false
        end
    end
	return true
end

function ConstructionSite:OnSave()
    if next(self.materials) ~= nil then
        local materials = {}
        for k, v in pairs(self.materials) do
            materials[k] = v.amount
        end
        return { materials = materials }
    end
end

function ConstructionSite:OnLoad(data)
    if data.materials ~= nil then
        for i, v in ipairs(CONSTRUCTION_PLANS[self.inst.prefab] or EMPTY_TABLE) do
            local amount = data.materials[v.type]
            if amount ~= nil then
                self.materials[v.type] = { amount = amount, slot = i }
                self.inst.replica.constructionsite:SetSlotCount(i, amount)
            end
        end
        for k, v in pairs(data.materials) do
            if self.materials[k] == nil then
                self.materials[k] = { amount = v }
            end
        end
    end
end

function ConstructionSite:GetDebugString()
    local str = "builder: "..tostring(self.builder)
    for i, v in ipairs(CONSTRUCTION_PLANS[self.inst.prefab] or EMPTY_TABLE) do
        str = str..string.format("\n %s [%i/%i]", v.type, self:GetSlotCount(i), v.amount)
    end
    return str
end

return ConstructionSite
