local function onenabled(self, enabled)
    if enabled then
        self.inst:AddTag("trader")
        if self.acceptnontradable then
            self.inst:AddTag("alltrader")
        end
    else
        self.inst:RemoveTag("trader")
        if self.acceptnontradable then
            self.inst:RemoveTag("alltrader")
        end
    end
end

local function onacceptnontradable(self, acceptnontradable)
    if self.enabled then
        if acceptnontradable then
            self.inst:AddTag("alltrader")
        else
            self.inst:RemoveTag("alltrader")
        end
    end
end

local Trader = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.deleteitemonaccept = true
    self.acceptnontradable = false
    self.test = nil
    self.abletoaccepttest = nil

    --V2C: Recommended to explicitly add tags to prefab pristine state
    --On construciton, "trader" tag is added by default
    --If acceptnontradable will be true, then "alltrader" tag should also be added
end,
nil,
{
    enabled = onenabled,
    acceptnontradable = onacceptnontradable,
})

function Trader:OnRemoveFromEntity()
    self.inst:RemoveTag("trader")
    self.inst:RemoveTag("alltrader")
end

function Trader:IsTryingToTradeWithMe(inst)
    local act = inst:GetBufferedAction()
    return act ~= nil
        and act.target == self.inst
        and (act.action == ACTIONS.GIVETOPLAYER or
            act.action == ACTIONS.GIVEALLTOPLAYER or
            act.action == ACTIONS.GIVE)
end

function Trader:Enable()
    self.enabled = true
end

function Trader:Disable()
    self.enabled = false
end

--This only comes into play after passing AbleToAccept,
--and does not trigger action fail or reason.
function Trader:SetAcceptTest(fn)
    self.test = fn
end

--This can be used to override AbleToAccept test to
--trigger custom action fail with reason.
function Trader:SetAbleToAcceptTest(fn)
    self.abletoaccepttest = fn
end

-- Able to accept refers to physical ability, i.e. am I in combat, or sleeping, or dead
function Trader:AbleToAccept(item, giver)
    local on_inventory = self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner ~= nil

    if not self.enabled or item == nil then
        return false
    elseif self.abletoaccepttest ~= nil then
        return self.abletoaccepttest(self.inst, item, giver)
    elseif self.inst.components.health ~= nil and self.inst.components.health:IsDead() then
        return false, "DEAD"
    elseif (self.inst.components.sleeper ~= nil and self.inst.components.sleeper:IsAsleep()) and not on_inventory then
        return false, "SLEEPING"
    elseif self.inst.sg ~= nil and self.inst.sg:HasStateTag("busy") and not on_inventory then
        return false, "BUSY"
    end
    return true
end

-- Wants to accept refers to desire, i.e. do I think that object is disgusting. This one triggers
-- the "refuse" callback.
function Trader:WantsToAccept(item, giver)
    return self.enabled and (not self.test or self.test(self.inst, item, giver))
end

function Trader:AcceptGift(giver, item, count)
    if not self:AbleToAccept(item, giver) then
        return false
    end

    if self:WantsToAccept(item, giver) then
        count = count or 1

        if item.components.stackable ~= nil and item.components.stackable.stacksize > count then
            item = item.components.stackable:Get(count)
        else
            item.components.inventoryitem:RemoveFromOwner(true)
        end

        if self.deleteitemonaccept then
            item:Remove()
        elseif self.inst.components.inventory ~= nil then
            item.prevslot = nil
            item.prevcontainer = nil
            self.inst.components.inventory:GiveItem(item, nil, giver ~= nil and giver:GetPosition() or nil)
        end

        if self.onaccept ~= nil then
            self.onaccept(self.inst, giver, item)
        end

        self.inst:PushEvent("trade", { giver = giver, item = item })

        return true
    end

    if self.onrefuse ~= nil then
        self.onrefuse(self.inst, giver, item)
    end
    return false
end

function Trader:GetDebugString()
    return self.enabled and "true" or "false"
end

return Trader
