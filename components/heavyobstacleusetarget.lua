local function oncan_use_heavy(self)
    if self.can_use_heavy then
        if not self.inst:HasTag("can_use_heavy") then
            self.inst:AddTag("can_use_heavy")
        end
    else
        if self.inst:HasTag("can_use_heavy") then
            self.inst:RemoveTag("can_use_heavy")
        end
    end
end

local HeavyObstacleUseTarget = Class(function(self, inst)
    self.inst = inst
    self.can_use_heavy = true
    -- self.on_use_fn = nil
end,
nil,
{
    can_use_heavy = oncan_use_heavy,
})

function HeavyObstacleUseTarget:UseHeavyObstacle(doer, heavy_obstacle)
    return self.on_use_fn ~= nil and self.on_use_fn(self.inst, doer, heavy_obstacle) or false
end

return HeavyObstacleUseTarget
