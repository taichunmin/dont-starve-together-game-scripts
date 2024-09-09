local Incinerator = Class(function(self, inst)
    self.inst = inst

   self.onincineratefn = nil
   self.shouldincinerateitemfn = nil
end)

function Incinerator:SetOnIncinerateFn(fn)
    self.onincineratefn = fn
end

function Incinerator:SetShouldIncinerateItemFn(fn)
    self.shouldincinerateitemfn = fn
end

Incinerator.OnPreDestroyItemCallbackFn = function(inst, item) -- NOTES(JBK): Mods can access this.
    local doer = inst.components.incinerator and inst.components.incinerator.incinerate_doer or nil

    if item.incineratesound ~= nil then
        inst.SoundEmitter:PlaySound(FunctionOrValue(item.incineratesound, item, doer))
    elseif item.components.health ~= nil and item.components.health.murdersound ~= nil then
        inst.SoundEmitter:PlaySound(FunctionOrValue(item.components.health.murdersound, item, doer))
    elseif item.components.murderable ~= nil and item.components.murderable.murdersound ~= nil then
        inst.SoundEmitter:PlaySound(FunctionOrValue(item.components.murderable.murdersound, item, doer))
    end

    item:PushEvent("onincinerated", {incinerator = inst, doer = doer,})

    if doer ~= nil then
        if item.components.health ~= nil or item.components.murderable ~= nil then
            local stacksize = item.components.stackable ~= nil and item.components.stackable:StackSize() or 1
            doer:PushEvent("murdered", {victim = item, stackmult = stacksize, incinerated = true,}) -- NOTES(JBK): Incinerating something alive.
            if item.components.combat ~= nil then
                doer:PushEvent("killed", {victim = item, stackmult = stacksize, incinerated = true,})
            end
        end
    end
end

function Incinerator:Incinerate(doer)
    if self.inst.components.container ~= nil then
        self.incinerate_doer = doer

        self.inst.components.container:DestroyContentsConditionally(self.shouldincinerateitemfn, self.OnPreDestroyItemCallbackFn)

        if self.onincineratefn ~= nil then
            self.onincineratefn(self.inst)
        end
        self.incinerate_doer = nil

        return true
    end

    return false
end

function Incinerator:ShouldIncinerateItem(item)
    if self.shouldincinerateitemfn ~= nil then
        return self.shouldincinerateitemfn(self.inst, item)
    end

    return true
end

return Incinerator