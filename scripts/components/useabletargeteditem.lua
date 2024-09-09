local function oninuse_targeted(self, inuse_targeted)
    if inuse_targeted then
        self.inst:AddTag("inuse_targeted")
    else
        self.inst:RemoveTag("inuse_targeted")
    end
end

local function on_inventory_disableable(self, newval, oldval)
    if newval then
        self.inst:AddTag("useabletargeteditem_inventorydisable")
    else
        self.inst:RemoveTag("useabletargeteditem_inventorydisable")
    end
end

local function ontargetprefab(self, newprefab, oldprefab)
    if oldprefab then
        self.inst:RemoveTag(oldprefab.."_targeter")
    end

    if newprefab then
        self.inst:AddTag(newprefab.."_targeter")
    end
end

local UseableTargetedItem = Class(function(self, inst)
    self.inst = inst

    self.inuse_targeted = false
    self.inventory_disableable = false

    self.useabletargetprefab = nil

    --self.onusefn = nil
    --self.onstopusefn = nil
end,
nil,
{
    inuse_targeted = oninuse_targeted,
    inventory_disableable = on_inventory_disableable,
    useabletargetprefab = ontargetprefab,
})

function UseableTargetedItem:OnRemoveFromEntity()
    if self.inuse_targeted then
        self.inst:RemoveTag("inuse_targeted")
    end

    if self.inventory_disableable then
        self.inst:RemoveTag("useabletargeteditem_inventorydisable")
    end

    if self.useabletargetprefab ~= nil then
        self.inst:RemoveTag(self.useabletargetprefab.."_targeter")
    end
end

function UseableTargetedItem:SetTargetPrefab(prefab_name)
    self.useabletargetprefab = prefab_name
end

function UseableTargetedItem:SetOnUseFn(fn)
    self.onusefn = fn
end

function UseableTargetedItem:SetOnStopUseFn(fn)
    self.onstopusefn = fn
end

function UseableTargetedItem:SetInventoryDisable(value)
    self.inventory_disableable = value
end

function UseableTargetedItem:CanInteract()
    return not self.inuse_targeted
end

function UseableTargetedItem:StartUsingItem(target, doer)
    local usesuccess = nil
    local usefailreason = nil

    if self.onusefn then
        usesuccess, usefailreason = self.onusefn(self.inst, target, doer)
    else
        usesuccess = true
    end

    if usesuccess then
        self.inuse_targeted = true
    end

    return usesuccess, usefailreason
end

function UseableTargetedItem:StopUsingItem()
    self.inuse_targeted = false

    if self.onstopusefn then
        self.onstopusefn(self.inst)
    end
end

return UseableTargetedItem
