local Playbill_Lecturn = Class(function(self, inst)
    self.inst = inst

    --self.playbill_item = nil
    --self.stage = nil
    --self.onstageset = nil

    self.inst:AddTag("playbill_lecturn")
end)

function Playbill_Lecturn:OnRemoveEntity()
    self.inst:RemoveTag("playbill_lecturn")
end
Playbill_Lecturn.OnRemoveFromEntity = Playbill_Lecturn.OnRemoveEntity

function Playbill_Lecturn:SetStage(stage)
    self.stage = stage
    if self.onstageset ~= nil then
        self.onstageset(self.inst, stage)
    end
end

function Playbill_Lecturn:ChangeAct(next_act)
    if self.playbill_item then
        self.playbill_item.components.playbill:SetCurrentAct(next_act)
        self:UpdateText()
    end
end

function Playbill_Lecturn:UpdateText()
    if self.playbill_item then
        local pb = self.playbill_item.components.playbill
        local script = pb.scripts[pb.current_act] 
        local text = script.playbill.."\nCast:"
        for _, cast_member in ipairs(script.cast) do
            text=text .."\n"..pb.costumes[cast_member].name
        end
        self.inst.components.writeable:SetText(text)
        self.inst:PushEvent("text_changed")  
    end
        
end

function Playbill_Lecturn:SwapPlayBill(playbill, doer)
    if doer then
        playbill.components.playbill:SetCurrentAct(playbill.components.playbill.starting_act)
        doer.components.inventory:RemoveItem(playbill)
    end

    playbill.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
    playbill:RemoveFromScene()

    if self.playbill_item then
        self.playbill_item:ReturnToScene()
        self.inst.components.lootdropper:FlingItem(self.playbill_item)
    end

    self.playbill_item = playbill

    if self.stage then
        local play_data =
        {
            costumes    =   self.playbill_item.components.playbill.costumes,
            scripts     =   self.playbill_item.components.playbill.scripts,
            current_act =   self.playbill_item.components.playbill.current_act,
        }
        self.stage.components.stageactingprop:AddPlay(play_data)

        self.inst.AnimState:PlayAnimation("switch")
        self.inst.AnimState:PushAnimation("idle")
    end

    self:UpdateText()
end

function Playbill_Lecturn:OnSave()
    local refs = {}
    local data = {}
    if self.playbill_item then
        data.playbill_item_id = self.playbill_item.GUID
        table.insert(refs, self.playbill_item.GUID)
    end
    return data, refs
end

local function loadplaybill_postpass(inst, self, playbill)
    -- NOTE: self.stage needs to be loaded at this point
    self:SwapPlayBill(playbill)
end

function Playbill_Lecturn:LoadPostPass(newents, data)
    if data.playbill_item_id then
        local playbill_data = newents[data.playbill_item_id]
        if playbill_data then
            self.inst:DoTaskInTime(0, loadplaybill_postpass, self, playbill_data.entity)
        end
    end
end

return Playbill_Lecturn