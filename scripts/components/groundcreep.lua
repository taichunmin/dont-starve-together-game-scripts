--------------------------------------------------------------------------
--[[ GroundCreep class definition ]]
--[[
    This exists solely to make serializing the ground creep from the map sane,
    as opposed to insane special case code that lives god knows where
--]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerActivated()
    inst.GroundCreep:FastForward()
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

inst:ListenForEvent("playeractivated", OnPlayerActivated)

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

if inst.ismastersim then function self:OnSave()
    return inst.GroundCreep:GetAsString()
end end

if inst.ismastersim then function self:OnLoad(data)
    inst.GroundCreep:SetFromString(data)
end end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)