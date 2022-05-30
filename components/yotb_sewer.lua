local sewing = require("yotb_sewing")

local function oncheckready(inst)
    if inst.components.container ~= nil and
        not inst.components.container:IsOpen() and
        inst.components.container:IsFull() then
        inst:AddTag("readytosew")
    end
end

local function onnotready(inst)
    inst:RemoveTag("readytosew")
end

local YOTB_Sewer = Class(function(self, inst)
    self.inst = inst

    self.done = nil
    self.targettime = nil
    self.task = nil
    self.product = nil
    self.product_spoilage = nil
    self.spoiledproduct = "spoiled_food"
    self.spoiltime = nil

    inst:ListenForEvent("itemget", oncheckready)
    inst:ListenForEvent("onclose", oncheckready)

    inst:ListenForEvent("itemlose", onnotready)
    inst:ListenForEvent("onopen", onnotready)
end)

function YOTB_Sewer:OnRemoveFromEntity()
    self.inst:RemoveTag("readytosew")
end


local function dosew(inst, self)
    self.task = nil
    self.targettime = nil

    if self.ondonesewing ~= nil then
        self.ondonesewing(inst)
    end

    local item = SpawnPrefab(self.product)
    local x,y,z = self.inst.Transform:GetWorldPosition()
    item.Transform:SetPosition(x,y+2,z)

    local speed = math.random() * 4 + 2
    local angle = math.random() * 2 * PI * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))

    -- Is this the networked variable we removed ealier?
    self.done = true
    self.inst.components.container.canbeopened = true
    self.product = nil
end

local function doreject(inst, self)
    self.task = nil
    self.targettime = nil

    if self.ondonesewing ~= nil then
        self.ondonesewing(inst)
    end

    self.inst.components.container:DropEverything()

    self.done = true
    self.inst.components.container.canbeopened = true
end

function YOTB_Sewer:IsDone()
    return self.done
end

function YOTB_Sewer:IsSewing()
    return not self.done and self.targettime ~= nil
end

function YOTB_Sewer:GetTimeToSew()
    return not self.done and self.targettime ~= nil and self.targettime - GetTime() or 0
end

function YOTB_Sewer:CanSew()
    return self.inst.components.container ~= nil and self.inst.components.container:IsFull()
end

function YOTB_Sewer:StartSewing(doer)
    if self.targettime == nil and self.inst.components.container ~= nil then
        self.ingredient_prefabs = {}

        self.done = nil

        if self.onstartsewing ~= nil then
            self.onstartsewing(self.inst)
        end

        for k, v in pairs (self.inst.components.container.slots) do
            table.insert(self.ingredient_prefabs, v.prefab)
        end

        if sewing.IsRecipeValid(self.ingredient_prefabs) then
            local sewing_time = 1
            self.product, sewing_time = sewing.CalculateRecipe(self.ingredient_prefabs)

            self.targettime = GetTime() + sewing_time
            if self.task ~= nil then
                self.task:Cancel()
            end

            self.task = self.inst:DoTaskInTime(sewing_time, dosew, self)
            self.inst.components.container:DestroyContents()
        else
            self.targettime = GetTime() + TUNING.REJECTION_SEWING_TIME
            self.task = self.inst:DoTaskInTime(TUNING.REJECTION_SEWING_TIME, doreject, self)
        end

        self.inst.components.container:Close()
        self.inst.components.container.canbeopened = false
        self.inst:RemoveTag("readytosew")
    end
end

local function StopProductPhysics(prod)
    prod.Physics:Stop()
end

function YOTB_Sewer:StopSewing(reason)
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end

    if self.product ~= nil and reason == "fire" then
        local prod = SpawnPrefab(self.product)
        if prod ~= nil then
            prod.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
            prod:DoTaskInTime(0, StopProductPhysics)
        end
    end

    self.product = nil
    self.targettime = nil
    self.done = nil
end

function YOTB_Sewer:OnSave()
    local remainingtime = self.targettime ~= nil and self.targettime - GetTime() or 0
    return
    {
        done = self.done,
        product = self.product,
        remainingtime = remainingtime > 0 and remainingtime or nil,
        ingredient_prefabs = self.ingredient_prefabs,
    }
end

function YOTB_Sewer:OnLoad(data)
    if data.product ~= nil then
		self.ingredient_prefabs = data.ingredient_prefabs

        self.done = data.done or nil
        self.product = data.product

        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
        end

        self.targettime = nil

        if data.remainingtime ~= nil then
            self.targettime = GetTime() + math.max(0, data.remainingtime)
            if self.done then
                if self.oncontinuedone ~= nil then
                    self.oncontinuedone(self.inst)
                end
            else
                if self.product then
                    self.task = self.inst:DoTaskInTime(data.remainingtime, dosew, self)
                else
                    self.task = self.inst:DoTaskInTime(data.remainingtime, doreject, self)
                end

                if self.oncontinuesewing ~= nil then
                    self.oncontinuesewing(self.inst)
                end
            end
        elseif self.oncontinuedone ~= nil then
            self.oncontinuedone(self.inst)
        end

        if self.inst.components.container ~= nil then
            self.inst.components.container.canbeopened = false
        end
    end
end

--TODO: we should review this
function YOTB_Sewer:GetDebugString()
    local status = (self:IsSewing() and "SEWING")
                or (self:IsDone() and "FULL")
                or "EMPTY"

    return string.format("%s %s timetosew: %.2f",
            self.product or "<none>",
            status,
            self:GetTimeToSew())
end

function YOTB_Sewer:LongUpdate(dt)
    if self:IsSewing() then
        if self.task ~= nil then
            self.task:Cancel()
        end
        if self.targettime - dt > GetTime() then
            self.targettime = self.targettime - dt

            if self.product then
                self.task = self.inst:DoTaskInTime(self.targettime - GetTime(), dosew, self)
            else
                self.task = self.inst:DoTaskInTime(self.targettime - GetTime(), doreject, self)
            end

            dt = 0
        else
            dt = dt - self.targettime + GetTime()
            if self.product then
                dosew(self.inst, self)
            else
                doreject(self.inst, self)
            end
        end
    end
end

return YOTB_Sewer