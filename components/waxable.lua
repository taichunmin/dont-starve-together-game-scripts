local function onwaxfn(self, waxfn)
    if waxfn then
        self.inst:AddTag("waxable")
    else
        self.inst:RemoveTag("waxable")
    end
end

local Waxable = Class(function(self, inst)
    self.inst = inst

    self.inst:AddTag("waxable")
end, nil,
{
    waxfn = onwaxfn,
})

function Waxable:SetWaxfn(fn)
    self.waxfn = fn
end

function Waxable:Wax(doer, waxitem)
    if self.waxfn then
        local result = self.waxfn(self.inst, doer, waxitem)
        if waxitem.components.finiteuses ~= nil then
            waxitem.components.finiteuses:Use()
        elseif waxitem.components.stackable ~= nil then
            waxitem.components.stackable:Get():Remove()
        else
            waxitem:Remove()
        end
        return result
    end
    return false
end

return Waxable
