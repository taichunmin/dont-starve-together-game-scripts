local function on_prize_count(self, prize_count)
    if prize_count > 0 then
        self.inst:AddTag("bearded")
    else
        self.inst:RemoveTag("bearded")
    end
end

local Shaveable = Class(function(self, inst)
    self.inst = inst

    --self.prize_prefab = nil
    --self.prize_count = nil
    --self.can_shave_test = nil
    --self.on_shaved = nil
end,
nil,
{
    prize_count = on_prize_count,
})

function Shaveable:OnRemoveFromEntity()
    self.inst:RemoveTag("bearded")
end

function Shaveable:SetPrize(prize_prefab, prize_count)
    self.prize_prefab = prize_prefab
    self.prize_count = prize_count
end

function Shaveable:CanShave(shaver, shaving_implement)
    if self.can_shave_test == nil then
        return true, nil
    end

    return self.can_shave_test(self.inst, shaver, shaving_implement)
end

function Shaveable:Shave(shaver, shaving_implement)
    local can_shave, reason = self:CanShave(shaver, shaving_implement)
    if not can_shave then
        return can_shave, reason
    end

    if self.prize_prefab ~= nil and self.prize_count ~= nil then
        local position = self.inst:GetPosition()

        for k = 1, self.prize_count do
            local prize = SpawnPrefab(self.prize_prefab)
            if prize.components.inventoryitem ~= nil then
                prize.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
            end
            if shaver ~= nil and shaver.components.inventory ~= nil then
                shaver.components.inventory:GiveItem(prize, nil, position)
            else
                LaunchAt(prize, self.inst, nil, 1, 1)
            end
        end
    end

    if self.on_shaved ~= nil then
        self.on_shaved(self.inst, shaver, shaving_implement)
    end

    return true
end

function Shaveable:OnSave()
    return {
        prize_count = self.prize_count
    }
end

function Shaveable:OnLoad(data)
    self.prize_count = data.prize_count
end

function Shaveable:GetDebugString()
    return string.format("%d "..tostring(self.prize_prefab), self.prize_count)
end

return Shaveable
