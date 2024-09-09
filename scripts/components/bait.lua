local function OnRemove(inst)
    if inst.components.bait.trap ~= nil then
        inst.components.bait.trap:RemoveBait()
    end
end

local function OnEaten(inst, data)
    if inst.components.bait.trap ~= nil then
        inst.components.bait.trap:BaitTaken(data.eater)
    end
end

local function OnStolen(inst, data)
    if inst.components.bait.trap ~= nil then
        inst.components.bait.trap:BaitTaken(data.thief)
    elseif data.thief.components.inventory ~= nil then
        data.thief.components.inventory:GiveItem(inst)
    end
end

local Bait = Class(function(self, inst)
    self.inst = inst
    self.trap = nil

    inst:ListenForEvent("onremove", OnRemove)
    inst:ListenForEvent("onpickup", OnRemove)
    inst:ListenForEvent("oneaten", OnEaten)
    inst:ListenForEvent("onstolen", OnStolen)
end)

function Bait:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("onremove", OnRemove)
    self.inst:RemoveEventCallback("onpickup", OnRemove)
    self.inst:RemoveEventCallback("oneaten", OnEaten)
    self.inst:RemoveEventCallback("onstolen", OnStolen)
end

function Bait:GetDebugString()
    return "Trap:"..tostring(self.trap)
end

function Bait:IsFree()
    return self.trap == nil
end

return Bait
