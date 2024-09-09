--------------------------------------------------------------------------
--[[ crabkingspawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "CrabkingSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:LoadPostPass(newents, data)
    if not TheSim:FindFirstEntityWithTag("crabking_spawner") then
        if data.crabkingx and data.crabkingz then
            local spawner = SpawnPrefab("crabking_spawner")
            spawner.Transform:SetPosition(data.crabkingx, 0, data.crabkingz)
            spawner.components.childspawner.childreninside = 0
            if data.timetorespawn ~= nil then
                spawner.components.worldsettingstimer:StartTimer("regen_crabking", data.timetorespawn)
            end
        end
    end
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
