local Bloomer = Class(function(self, inst)
    self.inst = inst
    self.bloomstack = {}
    self.children = {}

    self._onremovesource = function(source) self:PopBloom(source) end
end)

function Bloomer:OnRemoveFromEntity()
    for i, v in ipairs(self.bloomstack) do
        if type(v.source) == "table" then
            self.inst:RemoveEventCallback("onremove", self._onremovesource, v.source)
        end
    end
    for k, v in pairs(self.children) do
        self.inst:RemoveEventCallback("onremove", v, k)
    end
end

function Bloomer:AttachChild(child)
    if self.children[child] == nil then
        self.children[child] = function(child)
            self.children[child] = nil
        end
        self.inst:ListenForEvent("onremove", self.children[child], child)
        local fx = self:GetCurrentFX()
        if fx ~= nil then
            child.AnimState:SetBloomEffectHandle(fx)
        else
            child.AnimState:ClearBloomEffectHandle()
        end
    end
end

function Bloomer:DetachChild(child)
    if self.children[child] ~= nil then
        self.inst:RemoveEventCallback("onremove", self.children[child], child)
        self.children[child] = nil
    end
end

function Bloomer:GetCurrentFX()
    return #self.bloomstack > 0 and self.bloomstack[#self.bloomstack].fx or nil
end

function Bloomer:OnSetBloomEffectHandle(fx)
    self.inst.AnimState:SetBloomEffectHandle(fx)
    for k, v in pairs(self.children) do
        k.AnimState:SetBloomEffectHandle(fx)
    end
end

function Bloomer:OnClearBloomEffectHandle()
    self.inst.AnimState:ClearBloomEffectHandle()
    for k, v in pairs(self.children) do
        k.AnimState:ClearBloomEffectHandle()
    end
end

function Bloomer:PushBloom(source, fx, priority)
    if source ~= nil and fx ~= nil then
        local oldfx = self:GetCurrentFX()
        local bloom = nil

        priority = priority or 0

        for i, v in ipairs(self.bloomstack) do
            if v.source == source then
                bloom = v
                bloom.fx = fx
                bloom.priority = priority
                table.remove(self.bloomstack, i)
                break
            end
        end

        if bloom == nil then
            bloom = { source = source, fx = fx, priority = priority }
            if type(source) == "table" then
                self.inst:ListenForEvent("onremove", self._onremovesource, source)
            end
        end

        for i, v in ipairs(self.bloomstack) do
            if v.priority > priority then
                table.insert(self.bloomstack, i, bloom)
                local newfx = self:GetCurrentFX()
                if newfx ~= oldfx then
                    self:OnSetBloomEffectHandle(newfx)
                end
                return
            end
        end

        table.insert(self.bloomstack, bloom)
        if fx ~= oldfx then
            self:OnSetBloomEffectHandle(fx)
        end
    end
end

function Bloomer:PopBloom(source)
    if source ~= nil then
        for i, v in ipairs(self.bloomstack) do
            if v.source == source then
                if type(source) == "table" then
                    self.inst:RemoveEventCallback("onremove", self._onremovesource, source)
                end
                local oldfx = self:GetCurrentFX()
                table.remove(self.bloomstack, i)
                local newfx = self:GetCurrentFX()
                if newfx == nil then
                    self:OnClearBloomEffectHandle()
                elseif newfx ~= oldfx then
                    self:OnSetBloomEffectHandle(newfx)
                end
                return
            end
        end
    end
end

function Bloomer:GetDebugString()
    local str = ""
    for i = #self.bloomstack, 1, -1 do
        local bloom = self.bloomstack[i]
        str = str..string.format("\n\t[%d] %s: %s", bloom.priority, tostring(bloom.source), bloom.fx)
    end
    return str
end

return Bloomer
