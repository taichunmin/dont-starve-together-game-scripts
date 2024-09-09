local function OnIsSprayFn(self, is_spray)
    if is_spray then
        self.inst:AddTag("waxspray")
    else
        self.inst:RemoveTag("waxspray")
    end
end

local Wax = Class(function(self, inst)
    self.inst = inst

    self.is_spray = false
end,
nil,
{
    is_spray = OnIsSprayFn,
})

function Wax:SetIsSpray()
    self.is_spray = true
end

function Wax:GetIsSpray()
    return self.is_spray
end

return Wax
