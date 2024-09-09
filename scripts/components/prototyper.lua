local TechTree = require("techtree")

local Prototyper = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("prototyper")

    self.trees = TechTree.Create()
    self.on = false
    self.onturnon = nil
    self.onturnoff = nil
    self.doers = {}
    --self.restrictedtag = nil --only entities with this tag can turn on

    self.onremovedoer = function(doer) self:TurnOff(doer) end
end)

function Prototyper:OnRemoveFromEntity()
    self.inst:RemoveTag("prototyper")
    for k, v in pairs(self.doers) do
        self.inst:RemoveEventCallback("onremove", self.onremovedoer, k)
    end
    self.doers = nil
end

function Prototyper:TurnOn(doer)
    if not self.doers[doer] then
        self.doers[doer] = true
        self.inst:ListenForEvent("onremove", self.onremovedoer, doer)
        if not self.on then
            if self.onturnon ~= nil then
                self.onturnon(self.inst)
            end
            self.on = true
        end
    end
end

function Prototyper:TurnOff(doer)
    if self.doers[doer] then
        self.doers[doer] = nil
        self.inst:RemoveEventCallback("onremove", self.onremovedoer, doer)
        if next(self.doers) == nil and self.on then
            if self.onturnoff ~= nil then
                self.onturnoff(self.inst)
            end
            self.on = false
        end
    end
end

function Prototyper:GetTechTrees()
    return deepcopy(self.trees)
end

function Prototyper:Activate(doer, recipe)
    if self.onactivate ~= nil then
        self.onactivate(self.inst, doer, recipe)
    end
end

return Prototyper
