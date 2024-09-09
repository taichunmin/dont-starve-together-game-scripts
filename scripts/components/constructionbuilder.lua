--V2C: constructionbuilderuidata client-side component must exist
--     so that we don't have to add a constructionbuilder_replica

local function onconstructioninst(self, constructioninst)
    self.inst.components.constructionbuilderuidata:SetContainer(constructioninst)
end

local function onconstructionsite(self, constructionsite)
    self.inst.components.constructionbuilderuidata:SetTarget(constructionsite)
end

local ConstructionBuilder = Class(function(self, inst)
    self.inst = inst
    self.constructioninst = nil
    self.constructionsite = nil
    self._onremoveconstructionsite = function(target)
        if target == self.constructionsite then
            self:StopConstruction()
        end
    end
end,
nil,
{
    constructioninst = onconstructioninst,
    constructionsite = onconstructionsite,
})

function ConstructionBuilder:CanStartConstruction()
    return self.inst.sg.currentstate.name == "construct"
        and self.constructioninst == nil
        and self.constructionsite == nil
end

function ConstructionBuilder:IsConstructing(constructioninst)
    return self.constructioninst == constructioninst and self:IsConstructingAny()
end

function ConstructionBuilder:IsConstructingAny()
    return self.constructioninst ~= nil and self.inst.sg.currentstate.name == "constructing"
end

function ConstructionBuilder:StartConstruction(target)
    if target ~= nil and
        target.components.constructionsite ~= nil and
		target.components.constructionsite.constructionprefab ~= nil and
		target.components.constructionsite:IsEnabled() then
        self:StopConstruction()

        if target.components.constructionsite:HasBuilder() then
            return false, "INUSE"
        end

        if target:HasTag("burnt") then
            return false, "BURNT"
        end

        self.constructionsite = target
        self.constructioninst = SpawnPrefab(target.components.constructionsite.constructionprefab)
        if self.constructioninst ~= nil then
            if self.constructioninst.components.container ~= nil then
                self.constructioninst.components.container:Open(self.inst)
                if self.constructioninst.components.container:IsOpenedBy(self.inst) then
                    self.constructioninst.entity:SetParent(self.inst.entity)
                    self.constructioninst.persists = false
                    target.components.constructionsite:OnStartConstruction(self.inst)
                    self.inst:ListenForEvent("onremove", self._onremoveconstructionsite, target)
                    self.inst.sg.statemem.constructing = true
                    self.inst.sg:GoToState("constructing")
                    return true
                end
            end
            self.constructioninst:Remove()
            self.constructioninst = nil
        end
        self.constructionsite = nil
    end
    return false
end

function ConstructionBuilder:StopConstruction()
    if self.constructioninst ~= nil then
        if self.constructioninst.components.container ~= nil then
            if self.inst.components.inventory ~= nil then
                local pos = self.constructioninst:GetPosition()
                for i = 1, self.constructioninst.components.container:GetNumSlots() do
                    local item = self.constructioninst.components.container:RemoveItemBySlot(i)
                    if item ~= nil then
                        item.prevcontainer = nil
                        item.prevslot = nil
                        self.inst.components.inventory:GiveItem(item, nil, pos)
                    end
                end
            else
                self.constructioninst.components.container:DropEverything()
            end
        end
        self.constructioninst:Remove()
        self.constructioninst = nil
    end
    if self.constructionsite ~= nil then
        self.inst:RemoveEventCallback("onremove", self._onremoveconstructionsite, self.constructionsite)
        if self.constructionsite.components.constructionsite ~= nil then
            self.constructionsite.components.constructionsite:OnStopConstruction(self.inst)
        end
        self.constructionsite = nil
    end
    self.inst:PushEvent("stopconstruction")
end

function ConstructionBuilder:FinishConstruction()
    if
        self.constructioninst ~= nil and
        self.constructioninst.components.container ~= nil and
        not self.constructioninst.components.container:IsEmpty() and
        self.constructionsite ~= nil and
        self.constructionsite.components.constructionsite ~= nil and
		self.constructionsite.components.constructionsite:IsEnabled() and
        self.inst.sg.currentstate.name == "constructing"
    then
		self.constructioninst.components.container:Close()
		self.inst.sg.statemem.constructing = true
		self.inst.sg:GoToState("construct_pst")
		return true
    end
end

function ConstructionBuilder:OnFinishConstruction()
    if self.constructioninst ~= nil and
        self.constructioninst.components.container ~= nil and
        not self.constructioninst.components.container:IsEmpty() and
        self.constructionsite ~= nil and
		self.constructionsite.components.constructionsite ~= nil and
		self.constructionsite.components.constructionsite:IsEnabled() then
        local items = {}
        for i = 1, self.constructioninst.components.container:GetNumSlots() do
            local item = self.constructioninst.components.container:GetItemInSlot(i)
            if item ~= nil then
                table.insert(items, item)
            end
        end
        self.inst:RemoveEventCallback("onremove", self._onremoveconstructionsite, self.constructionsite)
        self.constructionsite.components.constructionsite:OnConstruct(self.inst, items)
        self.constructioninst:Remove()
        self.constructioninst = nil
        self.constructionsite = nil
    end
end

function ConstructionBuilder:OnSave()
    return self.constructioninst ~= nil
        and self.constructioninst.components.container ~= nil
        and not self.constructioninst.components.container:IsEmpty()
        and {
            constructing = self.constructioninst:GetSaveRecord()
        } or nil
end

function ConstructionBuilder:OnLoad(data)
    if data.constructing ~= nil then
        local currentconstructing = self.constructioninst
        local currenttarget = self.constructionsite

        self.constructionsite = nil
        self.constructioninst = SpawnSaveRecord(data.constructing)
        if self.constructioninst ~= nil then
            self.constructioninst.entity:SetParent(self.inst.entity)
            self.constructioninst.persists = false
        end

        if currentconstructing ~= nil or currenttarget ~= nil then
            self:StopConstruction()
            self.constructioninst = currentconstructing
            self.constructionsite = currenttarget
        end
    end
end

ConstructionBuilder.OnRemoveFromEntity = ConstructionBuilder.StopConstruction
ConstructionBuilder.OnRemoveEntity = ConstructionBuilder.StopConstruction

return ConstructionBuilder
