local WateryProtection = Class(function(self, inst)
    self.inst = inst

    self.witherprotectiontime = 0
    self.temperaturereduction = 0
    self.addcoldness = 0
    self.addwetness = 0
    self.extinguish = true
    self.extinguishheatpercent = 0
	--self.protection_dist = nil

    self.ignoretags = { "FX", "DECOR", "INLIMBO", "burnt" }
end)

function WateryProtection:AddIgnoreTag(tag)
    if not table.contains(self.ignoretags, tag) then
        table.insert(self.ignoretags, tag)
    end
end

function WateryProtection:SpreadProtectionAtPoint(x, y, z, dist, noextinguish)
    local ents = TheSim:FindEntities(x, y, z, dist or self.protection_dist or 4, nil, self.ignoretags)
    for i, v in ipairs(ents) do
        if v.components.burnable ~= nil then
            if self.witherprotectiontime > 0 and v.components.witherable ~= nil then
                v.components.witherable:Protect(self.witherprotectiontime)
            end
            if not noextinguish and self.extinguish then
                if v.components.burnable:IsBurning() or v.components.burnable:IsSmoldering() then
                    v.components.burnable:Extinguish(true, self.extinguishheatpercent)
                end
            end
        end
        if self.addcoldness > 0 and v.components.freezable ~= nil then
            v.components.freezable:AddColdness(self.addcoldness)
        end
        if self.temperaturereduction > 0 and v.components.temperature ~= nil then
            v.components.temperature:SetTemperature(v.components.temperature:GetCurrent() - self.temperaturereduction)
        end
        if self.addwetness > 0 and v.components.moisture ~= nil then
            local waterproofness = v.components.inventory and math.min(v.components.inventory:GetWaterproofness(),1) or 0
            v.components.moisture:DoDelta(self.addwetness * (1 - waterproofness))
        end
    end

	if self.addwetness and TheWorld.components.farming_manager ~= nil then
		TheWorld.components.farming_manager:AddSoilMoistureAtPoint(x, y, z, self.addwetness)
	end

	if self.onspreadprotectionfn ~= nil then
		self.onspreadprotectionfn(self.inst, x, y, z)
	end
end

function WateryProtection:SpreadProtection(inst, dist, noextinguish)
    local x, y, z = inst.Transform:GetWorldPosition()
    self:SpreadProtectionAtPoint(x, y, z, dist, noextinguish)
end

return WateryProtection
