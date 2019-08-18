local AreaAware = Class(function(self, inst)
    self.inst = inst
    self.current_area = -1
    self.current_area_data = nil
    self.lastpt = Vector3(-9999,0,-9999)
	self.updatedistsq = 16 --4*4

    self.inst:StartUpdatingComponent(self)

	self._ForceUpdate = function() self:UpdatePosition(self.inst.Transform:GetWorldPosition()) end
    self.inst:ListenForEvent("done_embark_movement", self._ForceUpdate)                
	
end)

function AreaAware:OnRemoveFromEntity()
    self:StopUpdating()
    self.inst:RemoveEventCallback("done_embark_movement", self._ForceUpdate)
end

function AreaAware:UpdatePosition(x, y, z)
    self.lastpt.x, self.lastpt.z = x, z
    if not TheWorld.Map:IsVisualGroundAtPoint(x, 0, z) then
		if self.current_area_data ~= nil then
			self.current_area = -1
			self.current_area_data = nil 
            self.inst:PushEvent("changearea", self:GetCurrentArea())
		end
        return
    end

	for i = #TheWorld.topology.nodes, 1, -1 do -- iterating backwards only because retrofitted worlds don't properly fix up the topology mesh
		local node = TheWorld.topology.nodes[i]
        if node.type ~= NODE_TYPE.Blank and node.type ~= NODE_TYPE.Blocker and TheSim:WorldPointInPoly(x, z, node.poly) then
			if self.current_area ~= i then
				self.current_area = i
				self.current_area_data = {
					id = TheWorld.topology.ids[i],
					type = node.type,
					center = node.cent,
					poly = node.poly,
					tags = node.tags,
				}
				self.inst:PushEvent("changearea", self:GetCurrentArea())
			end
			return
        end
    end
end

function AreaAware:OnUpdate(dt)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    if distsq(x, z, self.lastpt.x, self.lastpt.z) > self.updatedistsq then
        self:UpdatePosition(x, 0, z)
    end
end

function AreaAware:SetUpdateDist(dist)
	self.updatedistsq = dist*dist
end

function AreaAware:GetCurrentArea()
    return self.current_area_data
end

function AreaAware:CurrentlyInTag(tag)
    return self.current_area_data and self.current_area_data.tags and table.contains(self.current_area_data.tags, tag)
end

function AreaAware:GetDebugString()
    local node = TheWorld.topology.nodes[self.current_area]
    if node then
        local s = string.format("%s: %s [%d]",tostring(TheWorld.topology.ids[self.current_area]), table.reverselookup(NODE_TYPE, node.type), self.current_area)
        if node.tags then
            s = string.format("%s, {%s}", s, table.concat(node.tags, ", "))
        else
            s = string.format("%s, No tags.", s)
        end
        return s
    else

        return "No current node."
    end
end

function AreaAware:StartCheckingPosition(checkinterval)
    self.checkpositiontask = self.inst:DoPeriodicTask(checkinterval or self.checkinterval, function() self:UpdatePosition() end)
end

return AreaAware
