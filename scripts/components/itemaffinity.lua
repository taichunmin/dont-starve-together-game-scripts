-- Gives characters a sanity bonus from carrying a specific item in their inventory
-- It does not stack though, only one item bonus will be active at a time, so items have a priority
local ItemAffinity = Class(function(self, inst)
    self.inst = inst
    self.affinities = {}

    self.inst:ListenForEvent("itemget",  function() self:RefreshAffinity() end)
    self.inst:ListenForEvent("itemlose", function() self:RefreshAffinity() end)
    self.inst:ListenForEvent("dropitem", function() self:RefreshAffinity() end)
end)

function ItemAffinity:SortAffinities()
    table.sort(self.affinities, function(a,b) return a.priority > b.priority end)
end

function ItemAffinity:AddAffinity(prefab, tag, sanity_bonus, priority)
    table.insert(self.affinities, {prefab = prefab, tag= tag, sanity_bonus = sanity_bonus, priority = priority})
    self:RefreshAffinity()
end

function ItemAffinity:RemoveAffinity(prefab)

    local remove_index = nil
    for i,v in ipairs(self.affinities) do
        if v.prefab == prefab then
            remove_index = i
            break
        end
    end

    if remove_index then
        table.remove(self.affinities, remove_index)
    end

    self:RefreshAffinity()
end

function ItemAffinity:RefreshAffinity()
    self:SortAffinities()
    self.inst.components.sanity.externalmodifiers:RemoveModifier(self.inst)

    for i,v in ipairs(self.affinities) do
        if v.prefab and self.inst.components.inventory:Has(v.prefab, 1) then
            self.inst.components.sanity.externalmodifiers:SetModifier(self.inst, v.sanity_bonus)
            break
        elseif v.tag and self.inst.components.inventory:HasItemWithTag(v.tag, 1) then
            self.inst.components.sanity.externalmodifiers:SetModifier(self.inst, v.sanity_bonus)
            break
        end
    end
end

return ItemAffinity