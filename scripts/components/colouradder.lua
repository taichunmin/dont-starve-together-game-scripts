local ColourAdder = Class(function(self, inst)
    self.inst = inst
    self.colourstack = {}
    self.children = {}
    self.colour = { 0, 0, 0, 0 }

    self._onremovesource = function(source) self:PopColour(source) end
end)

function ColourAdder:OnRemoveFromEntity()
    for k, v in pairs(self.colourstack) do
		if EntityScript.is_instance(k) then
            self.inst:RemoveEventCallback("onremove", self._onremovesource, k)
        end
    end
    for k, v in pairs(self.children) do
        self.inst:RemoveEventCallback("onremove", v, k)
		if k.components.colouradder ~= nil then
			k.components.colouradder:PopColour(self.inst)
		end
    end
end

function ColourAdder:AttachChild(child)
    if self.children[child] == nil then
        self.children[child] = function(child)
            self.children[child] = nil
        end
        self.inst:ListenForEvent("onremove", self.children[child], child)
		local r, g, b, a = self:GetCurrentColour()
		if child.components.colouradder ~= nil then
			child.components.colouradder:PushColour(self.inst, r, g, b, a)
		elseif child.components.colouraddersync ~= nil then
			child.components.colouraddersync:SyncColour(r, g, b, a)
		else
			child.AnimState:SetAddColour(r, g, b, a)
		end
    end
end

function ColourAdder:DetachChild(child)
    if self.children[child] ~= nil then
        self.inst:RemoveEventCallback("onremove", self.children[child], child)
        self.children[child] = nil
		if child.components.colouradder ~= nil then
			child.components.colouradder:PopColour(self.inst)
		end
    end
end

function ColourAdder:GetCurrentColour()
    return unpack(self.colour)
end

function ColourAdder:CalculateCurrentColour()
    local r, g, b, a = 0, 0, 0, 0
    for k, v in pairs(self.colourstack) do
        r = r + v[1]
        g = g + v[2]
        b = b + v[3]
        a = a + v[4]
    end
    return math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1), math.clamp(a, 0, 1)
end

function ColourAdder:OnSetColour(r, g, b, a)
    self.colour[1], self.colour[2], self.colour[3], self.colour[4] = r, g, b, a
	if self.inst.components.colouraddersync ~= nil then
		self.inst.components.colouraddersync:SyncColour(r, g, b, a)
	else
		self.inst.AnimState:SetAddColour(r, g, b, a)
	end
    for k, v in pairs(self.children) do
		if k.components.colouradder ~= nil then
			k.components.colouradder:PushColour(self.inst, r, g, b, a)
		elseif k.components.colouraddersync ~= nil then
			k.components.colouraddersync:SyncColour(r, g, b, a)
		else
			k.AnimState:SetAddColour(r, g, b, a)
		end
    end
end

function ColourAdder:PushColour(source, r, g, b, a)
    if source ~= nil and r ~= nil and g ~= nil and b ~= nil and a ~= nil then
		if r == 0 and g == 0 and b == 0 and a == 0 then
			self:PopColour(source)
			return
		end
        local colour = self.colourstack[source]
        if colour == nil then
            self.colourstack[source] = { r, g, b, a }
			if EntityScript.is_instance(source) then
                self.inst:ListenForEvent("onremove", self._onremovesource, source)
            end
        elseif r ~= colour[1] or g ~= colour[2] or b ~= colour[3] or a ~= colour[4] then
            colour[1], colour[2], colour[3], colour[4] = r, g, b, a
        else
            return
        end

        r, g, b, a = self:CalculateCurrentColour()
        if r ~= self.colour[1] or g ~= self.colour[2] or b ~= self.colour[3] or a ~= self.colour[4] then
            self:OnSetColour(r, g, b, a)
        end
    end
end

function ColourAdder:PopColour(source)
    if source ~= nil and self.colourstack[source] ~= nil then
		if EntityScript.is_instance(source) then
            self.inst:RemoveEventCallback("onremove", self._onremovesource, source)
        end
        self.colourstack[source] = nil
        local r, g, b, a = self:CalculateCurrentColour()
        if r ~= self.colour[1] or g ~= self.colour[2] or b ~= self.colour[3] or a ~= self.colour[4] then
            self:OnSetColour(r, g, b, a)
        end
    end
end

function ColourAdder:GetDebugString()
    local str = string.format("Current Colour: (%.2f, %.2f, %.2f, %.2f)", self.colour[1], self.colour[2], self.colour[3], self.colour[4])
    for k, v in pairs(self.colourstack) do
        str = str..string.format("\n\t%s: (%.2f, %.2f, %.2f, %.2f)", tostring(k), v[1], v[2], v[3], v[4])
    end
    return str
end

return ColourAdder
