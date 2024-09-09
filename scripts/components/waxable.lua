local function onwaxfn(self, waxfn)
    if waxfn then
        self.inst:AddTag("waxable")
    else
        self.inst:RemoveTag("waxable")
    end
end

local function OnNeedsSprayFn(self, needs_spray)
    if needs_spray then
        self.inst:AddTag("needswaxspray")
    else
        self.inst:RemoveTag("needswaxspray")
    end
end

local Waxable = Class(function(self, inst)
    self.inst = inst

    self.needs_spray = false

    self.inst:AddTag("waxable")
end, nil,
{
    waxfn = onwaxfn,
    needs_spray = OnNeedsSprayFn,
})

function Waxable:SetWaxfn(fn)
    self.waxfn = fn
end

function Waxable:SetNeedsSpray(val)
    self.needs_spray = val ~= false
end

function Waxable:NeedsSpray()
    return self.needs_spray
end

function Waxable:Wax(doer, waxitem)
    if self:NeedsSpray() and waxitem.components.wax ~= nil and not waxitem.components.wax:GetIsSpray() then
        return false
    end

    if self.waxfn then
        local result, reason = self.waxfn(self.inst, doer, waxitem)

        if result then
            if waxitem.components.finiteuses ~= nil then
                waxitem.components.finiteuses:Use()
    
            elseif waxitem.components.stackable ~= nil then
                waxitem.components.stackable:Get():Remove()
    
            else
                waxitem:Remove()
            end
        end

        return result, reason
    end

    return false
end

function Waxable:OnRemoveFromEntity()
    self.inst:RemoveTag("waxable")
    self.inst:RemoveTag("needswaxspray")
end

return Waxable
