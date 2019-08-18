local BathBombable = Class(function(self, inst)
    self.inst = inst

    self.onbathbombedfn = nil
    self.canbebathbombedfn = nil
end)

function BathBombable:OnRemoveFromEntity()
    self.inst:RemoveTag("bathbombable")
end

function BathBombable:SetOnBathBombedFn(new_fn)
    self.onbathbombedfn = new_fn
end

function BathBombable:OnBathBombed(bathbomb_inst)
    if self.onbathbombedfn ~= nil then
        self.onbathbombedfn(self.inst, bathbomb_inst)
    end
end

function BathBombable:SetCanBeBathBombedFn(new_fn)
    self.canbebathbombedfn = new_fn
end

function BathBombable:SetCanBeBathBombed(can_be_bathbombed)
    if can_be_bathbombed then
        self.inst:AddTag("bathbombable")
    else
        self.inst:RemoveTag("bathbombable")
    end
end

function BathBombable:CanBeBathBombed(bathbomb_inst)
    if self.canbebathbombedfn ~= nil then
        return self.canbebathbombedfn(self.inst, bathbomb_inst)
    else
        return true
    end
end

return BathBombable
