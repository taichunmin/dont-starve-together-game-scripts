local function CheckForMorph(inst)
    inst.components.amorphous:CheckForMorph()
end

local function CheckForMorphIfClosed(inst)
    if not (inst.components.container ~= nil and inst.components.container:IsOpen()) then
        inst.components.amorphous:CheckForMorph()
    end
end

local Amorphous = Class(function(self, inst)
    self.inst = inst
    self.forms = {}
    self.currentform = nil
    inst:ListenForEvent("onclose", CheckForMorph)
    if not POPULATING then
        self:LoadPostPass()
    end
end)

function Amorphous:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("onclose", CheckForMorph)
    self.inst:RemoveEventCallback("itemget", CheckForMorphIfClosed)
    self.inst:RemoveEventCallback("itemlose", CheckForMorphIfClosed)
end

function Amorphous:OnSave()
    return self.currentform ~= nil
        and self.currentform ~= self.forms[#self.forms]
        and {
            form = self.currentform.name,
        }
        or nil
end

function Amorphous:OnLoad(data)
    if data ~= nil and data.form ~= nil then
        local form = self:FindForm(data.form)
        if form ~= nil then
            self:MorphToForm(form, true)
        else
            print("Could not find amorphous form "..data.form)
        end
    end
end

function Amorphous:LoadPostPass()
    self.inst:ListenForEvent("itemget", CheckForMorphIfClosed)
    self.inst:ListenForEvent("itemlose", CheckForMorphIfClosed)
    if POPULATING then
        self:CheckForMorph()
    end
end

function Amorphous:GetCurrentForm()
    return self.currentform ~= nil and self.currentform.name or nil
end

function Amorphous:AddForm(form)
    table.insert(self.forms, form)
end

function Amorphous:FindForm(name)
    for i, v in ipairs(self.forms) do
        if v.name == name then
            return v
        end
    end
end

function Amorphous:MorphToForm(form, instant)
    if self.currentform ~= form then
        if self.currentform ~= nil and self.currentform.exitformfn ~= nil then
            self.currentform.exitformfn(self.inst, instant)
        end
        self.currentform = form
        if form.enterformfn ~= nil then
            form.enterformfn(self.inst, instant)
        end
    end
end

function Amorphous:CheckForMorph()
    local numforms = #self.forms
    if numforms <= 0 or
        (self.inst.components.container ~= nil and self.inst.components.container:IsOpen()) or
        (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
        return
    end

    if numforms > 1 and self.inst.components.container ~= nil then
        for i = 1, numforms - 1 do
            local form = self.forms[i]
            local foundtags = true
            for i1, tag in ipairs(form.itemtags) do
                if self.inst.components.container:FindItem(function(item) return item:HasTag(tag) end) == nil then
                    foundtags = false
                    break
                end
            end
            if foundtags then
                self:MorphToForm(form, false)
                return
            end
        end
    end

    self:MorphToForm(self.forms[numforms], false)
end

return Amorphous
