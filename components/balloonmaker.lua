local BalloonMaker = Class(function(self, inst)
    self.inst = inst
end)

function BalloonMaker:MakeBalloon(x,y,z)
    local balloon = SpawnPrefab("balloon")
    if balloon then
        balloon.Transform:SetPosition(x,y,z)
        --Trying without timer removal first since
        --we have a max cap on balloons in a world
        --if balloon.components.timer ~= nil then
        --    balloon.components.timer:StartTimer("flyoff", TUNING.TOTAL_DAY_TIME)
        --end
    end
end

return BalloonMaker
