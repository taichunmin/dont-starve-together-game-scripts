local CircuitNode = Class(function(self, inst)
    self.inst = inst
    self.range = 5
	self.footprint = 0
    --self.onconnectfn = nil
    --self.ondisconnectfn = nil
    --self.nodes = nil
    self.numnodes = 0
    self.connectsacrossplatforms = true
	self.rangeincludesfootprint = false
end)

function CircuitNode:OnRemoveEntity()
    self.ondisconnectfn = nil
    self:Disconnect()
end

CircuitNode.OnRemoveFromEntity = CircuitNode.OnRemoveEntity

function CircuitNode:IsEnabled()
    return self.nodes ~= nil
end

function CircuitNode:IsConnected()
    return self.numnodes > 0
end

function CircuitNode:NumConnectedNodes()
    return self.numnodes
end

function CircuitNode:ConnectTo(tag)
    if self.nodes == nil then
        self.nodes = {}
    end
    if tag ~= nil then
        local x, y, z = self.inst.Transform:GetWorldPosition()

        local my_platform = nil
        if not self.connectsacrossplatforms then
            my_platform = self.inst:GetCurrentPlatform()
        end

        for i, v in ipairs(TheSim:FindEntities(x, y, z, self.range, { tag })) do
            if v ~= self.inst and v.entity:IsVisible() and v.components.circuitnode and v.components.circuitnode:IsEnabled() then
				local skip
				if self.rangeincludesfootprint then
					local range = self.range - v.components.circuitnode.footprint
					skip = v:GetDistanceSqToPoint(x, 0, z) > range * range
				end
				if not skip and (self.connectsacrossplatforms or v:GetCurrentPlatform() == my_platform) then
					self:AddNode(v)
                end
            end
        end
    end
end

function CircuitNode:Disconnect()
    while self.numnodes > 0 do
        self:RemoveNode(next(self.nodes))
    end
    self.nodes = nil
end

function CircuitNode:SetRange(range)
    self.range = range
end

function CircuitNode:SetFootprint(footprint)
	self.footprint = footprint
end

function CircuitNode:SetOnConnectFn(fn)
    self.onconnectfn = fn
end

function CircuitNode:SetOnDisconnectFn(fn)
    self.ondisconnectfn = fn
end

function CircuitNode:AddNode(node)
    if self.nodes ~= nil and not self.nodes[node] then
        self.nodes[node] = true
        self.numnodes = self.numnodes + 1
        if self.onconnectfn ~= nil then
            self.onconnectfn(self.inst, node)
        end
        node.components.circuitnode:AddNode(self.inst)
    end
end

function CircuitNode:RemoveNode(node)
    if self.nodes ~= nil and self.nodes[node] then
        self.nodes[node] = nil
        self.numnodes = self.numnodes - 1
        if self.ondisconnectfn ~= nil then
            self.ondisconnectfn(self.inst, node)
        end
        node.components.circuitnode:RemoveNode(self.inst)
    end
end

function CircuitNode:ForEachNode(fn)
    if self.numnodes > 0 then
        for k, v in pairs(self.nodes) do
            fn(self.inst, k)
        end
    end
end

return CircuitNode
