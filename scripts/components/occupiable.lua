local function onoccupant(self, occupant)
    if occupant ~= nil then
        self.inst:AddTag("occupied")
        if self.occupanttype ~= nil then
            self.inst:RemoveTag(self.occupanttype.."_occupiable")
        end
    else
        self.inst:RemoveTag("occupied")
        if self.occupanttype ~= nil then
            self.inst:AddTag(self.occupanttype.."_occupiable")
        end
    end
end

local function onoccupanttype(self, occupanttype, old_occupanttype)
    if self.occupant == nil then
        if old_occupanttype ~= nil then
            self.inst:RemoveTag(old_occupanttype.."_occupiable")
        end
        if occupanttype ~= nil then
            self.inst:AddTag(occupanttype.."_occupiable")
        end
    end
end

local Occupiable = Class(function(self, inst)
    self.inst = inst
    self.occupant = nil
    self.occupanttype = nil
end,
nil,
{
    occupant = onoccupant,
    occupanttype = onoccupanttype,
})

function Occupiable:OnRemoveFromEntity()
    self.inst:RemoveTag("occupied")
    if self.occupanttype ~= nil then
        self.inst:RemoveTag(self.occupanttype.."_occupiable")
    end
end

function Occupiable:IsOccupied()
    return self.occupant ~= nil
end

function Occupiable:GetOccupant()
    return self.occupant
end

function Occupiable:CanOccupy(occupier)
    return self.occupant == nil and
        self.occupanttype ~= nil and
        occupier:HasTag(self.occupanttype) and
        occupier.components.occupier ~= nil
end

function Occupiable:Occupy(occupier)
    if self.occupant == nil and occupier ~= nil and occupier.components.occupier ~= nil then
        self.occupant = occupier
        self.occupant.persists = true
        self.occupant.components.occupier:SetOwner(self.inst)
        if occupier.components.occupier.onoccupied ~= nil then
            occupier.components.occupier.onoccupied(occupier, self.inst)
        end

        if self.onoccupied ~= nil then
            self.onoccupied(self.inst, occupier)
        end

        self.inst:AddChild(occupier)
        occupier:RemoveFromScene()

        occupier.occupiableonperish = function(occupier)
            self.inst:RemoveEventCallback("onremove", occupier.occupiableonremove, occupier)
            self.inst:RemoveChild(occupier)
            occupier:ReturnToScene()
            if self.onemptied ~= nil then
                self.onemptied(self.inst)
            end
            if self.onperishfn then
                self.onperishfn(self.inst, self.occupant)
            end
            self.occupant = nil
            occupier:Remove()
        end

        occupier.occupiableonremove = function(occupier)
            self.inst:RemoveEventCallback("perished", occupier.occupiableonperish, occupier)
            if self.onemptied ~= nil then
                self.onemptied(self.inst)
            end
            self.occupant = nil
        end

        self.inst:ListenForEvent("perished", occupier.occupiableonperish, occupier)
        self.inst:ListenForEvent("onremove", occupier.occupiableonremove, occupier)

        return true
    end
end

function Occupiable:Harvest()
    if self.occupant ~= nil and self.occupant.components.inventoryitem ~= nil then
        local occupant = self.occupant
        occupant.components.occupier:SetOwner(nil)
        self.occupant = nil
        self.inst:RemoveEventCallback("perished", occupant.occupiableonperish, occupant)
        self.inst:RemoveEventCallback("onremove", occupant.occupiableonremove, occupant)
        self.inst:RemoveChild(occupant)
        if self.onemptied ~= nil then
            self.onemptied(self.inst)
        end
        occupant:ReturnToScene()
        return occupant
    end
end

function Occupiable:OnSave()
    return
    {
        occupant = self.occupant ~= nil and self.occupant:IsValid() and self.occupant:GetSaveRecord() or nil,
    }
end

function Occupiable:OnLoad(data, newents)
    if data.occupant ~= nil then
        local inst = SpawnSaveRecord(data.occupant, newents)
		if inst ~= nil then
			self:Occupy(inst)
		end
    end
end

return Occupiable