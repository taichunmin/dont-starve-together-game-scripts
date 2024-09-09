local BoatAI = Class(function(self, inst)
    self.inst = inst

    self.inst:StartUpdatingComponent(self)
end)


function BoatAI:OnUpdate(dt)
    local my_position = Vector3(self.inst.Transform:GetWorldPosition())

    local entities = TheSim:FindEntities(my_position.x, my_position.y, my_position.z, 200)

    for i, v in ipairs(entities) do
    	local mast = v.components.mast
    	if v ~= self.inst and mast ~= nil and mast.is_sail_raised then
    		self.inst.components.hull.mast.components.mast:RaiseSail()
    		local target_boat_position = Vector3(v.Transform:GetWorldPosition())
    		local target_move_position = target_boat_position + mast.wind_direction * 10
    		local my_new_wind_dir = (target_move_position - my_position):Normalize()
    		self.inst.components.hull.mast.components.mast.wind_direction = my_new_wind_dir
    	end
    end
end

return BoatAI