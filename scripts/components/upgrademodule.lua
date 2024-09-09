local UpgradeModule = Class(function(self, inst)
    self.inst = inst
    self.slots = 1
    self.activated = false

    --self.target = nil
    --self.onactivatedfn = nil
    --self.ondeactivatedfn = nil
    --self.onremovedfromownerfn = nil
end)

function UpgradeModule:SetRequiredSlots(slots)
    self.slots = slots
end

function UpgradeModule:SetTarget(target)
    self.target = target
end

--Should only be called by the upgrademoduleowner component
function UpgradeModule:TryActivate(isloading)
    if not self.activated then
        self.activated = true

        if self.onactivatedfn ~= nil then
            self.onactivatedfn(self.inst, self.target, isloading)
        end
    end
end

--Should only be called by the upgrademoduleowner component
function UpgradeModule:TryDeactivate()
    if self.activated then
        self.activated = false

        if self.ondeactivatedfn ~= nil then
            self.ondeactivatedfn(self.inst, self.target)
        end
    end
end

function UpgradeModule:RemoveFromOwner()
    self:SetTarget(nil)

    if self.onremovedfromownerfn ~= nil then
        self.onremovedfromownerfn(self.inst)
    end
end

return UpgradeModule
