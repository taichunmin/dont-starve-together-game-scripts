DAYLIGHT_SEARCH_RANGE = 30 -- depreacted, please use TUNING.DAYLIGHT_SEARCH_RANGE

local function onmatured(self, matured)
    if matured then
        self.inst:AddTag("readyforharvest")
        self.inst:RemoveTag("notreadyforharvest")
    else
        self.inst:RemoveTag("readyforharvest")
        self.inst:AddTag("notreadyforharvest")
    end
end

local Crop = Class(function(self, inst)
    self.inst = inst
    self.product_prefab = nil
    self.growthpercent = 0
    self.rate = 1 / 120
    self.task = nil
    self.matured = false
    self.onmatured = nil
    self.onwithered = nil
    self.onharvest = nil
    self.cantgrowtime = 0
end,
nil,
{
    matured = onmatured,
})

function Crop:OnRemoveFromEntity()
    self.inst:RemoveTag("readyforharvest")
    self.inst:RemoveTag("notreadyforharvest")
end

function Crop:SetOnMatureFn(fn)
    self.onmatured = fn
end

function Crop:SetOnWitheredFn(fn)
    self.onwithered = fn
end

function Crop:SetOnHarvestFn(fn)
    self.onharvest = fn
end

function Crop:OnSave()
    return
    {
        prefab = self.product_prefab,
        percent = self.growthpercent,
        rate = self.rate,
        matured = self.matured,
    }
end

function Crop:OnLoad(data)
    if data ~= nil then
        self.product_prefab = data.prefab or self.product_prefab
        self.growthpercent = math.clamp(data.percent, 0, 1) or self.growthpercent
        self.rate = data.rate or self.rate
        if data.matured ~= nil then
            self.matured = data.matured
        end
    end

    if not self.inst:HasTag("withered") then
        self:DoGrow(0)
        if self.product_prefab ~= nil and self.matured then
            self.inst.AnimState:SetPercent("grow_pst", 1)
            if self.onmatured ~= nil then
                self.onmatured(self.inst)
            end
        end
    end
end

function Crop:LoadPostPass()--newents, data)
    if self.grower == nil then
        self:Resume()
    end
end

function Crop:Fertilize(fertilizer, doer)
    if self.inst.components.burnable ~= nil then
        self.inst.components.burnable:StopSmoldering()
    end

    if not (TheWorld.state.iswinter and TheWorld.state.temperature <= 0) then
        if fertilizer.components.fertilizer ~= nil then
            if doer ~= nil and
                doer.SoundEmitter ~= nil and
                fertilizer.components.fertilizer.fertilize_sound ~= nil then
                doer.SoundEmitter:PlaySound(fertilizer.components.fertilizer.fertilize_sound)
            end
            self.growthpercent = math.clamp(self.growthpercent + fertilizer.components.fertilizer.fertilizervalue * self.rate, 0, 1)
        end
        if self.growthpercent < 1 then
            self.inst.AnimState:SetPercent("grow", self.growthpercent)
        else
            self.inst.AnimState:PlayAnimation("grow_pst")
            self:Mature()
            if self.task ~= nil then
                self.task:Cancel()
                self.task = nil
            end
        end
        return true
    end
end

local DAYLIGHT_SEARCH_RANGE = 30
local CANGROW_TAGS = { "daylight", "lightsource" }
function Crop:GetWorldGrowthRateMultiplier()
    if TheWorld.state.temperature < TUNING.MIN_CROP_GROW_TEMP then
        return 0
    end
    if TheWorld.state.israining and self.inst.components.rainimmunity == nil then
        return 1 + TUNING.CROP_RAIN_BONUS * TheWorld.state.precipitationrate
    end
    if TheWorld.state.isspring then
        return 1 + TUNING.SPRING_GROWTH_MODIFIER / 3
    end
    return 1
end
function Crop:DoGrow(dt, nowither)
    if not self.inst:HasTag("withered") and self.growthpercent < 1 then
        local shouldgrow = nowither or not TheWorld.state.isnight
        if not shouldgrow then
            local x, y, z = self.inst.Transform:GetWorldPosition()
            for i, v in ipairs(TheSim:FindEntities(x, 0, z, TUNING.DAYLIGHT_SEARCH_RANGE, CANGROW_TAGS)) do
                local lightrad = v.Light:GetCalculatedRadius() * .7
                if v:GetDistanceSqToPoint(x, y, z) < lightrad * lightrad then
                    shouldgrow = true
                    break
                end
            end
        end
        if shouldgrow then
            local temp_rate = self:GetWorldGrowthRateMultiplier()
            self.growthpercent = math.clamp(self.growthpercent + dt * self.rate * temp_rate, 0, 1)
            self.cantgrowtime = 0
        else
            self.cantgrowtime = self.cantgrowtime + dt
            if self.cantgrowtime > TUNING.CROP_DARK_WITHER_TIME and self.inst.components.witherable ~= nil then
                self.inst.components.witherable:ForceWither()
                if self.inst:HasTag("withered") then
                    return false
                end
            end
        end

        if self.growthpercent < 1 then
            self.inst.AnimState:SetPercent("grow", self.growthpercent)
        else
            self.inst.AnimState:PlayAnimation("grow_pst")
            self:Mature()
            if self.task ~= nil then
                self.task:Cancel()
                self.task = nil
            end
        end

		return true
    end

	return false
end

function Crop:GetDebugString()
    return (self.inst:HasTag("withered") and "WITHERED")
        or (self.matured and string.format("[%s] DONE", tostring(self.product_prefab)))
        or string.format("[%s] %.2f%% (done in %.2f) darkwither: %.2f", tostring(self.product_prefab), self.growthpercent, (1 - self.growthpercent) / self.rate, TUNING.CROP_DARK_WITHER_TIME - self.cantgrowtime)
end

local function _DoGrow(inst, self, dt)
    self:DoGrow(dt)
end

function Crop:Resume()
    if not (self.matured or self.inst:HasTag("withered")) then
        self.inst.AnimState:SetPercent("grow", self.growthpercent)
        local dt = 2
        if self.task ~= nil then
            self.task:Cancel()
        end
        self.task = self.inst:DoPeriodicTask(dt, _DoGrow, nil, self, dt)
    end
end

function Crop:StartGrowing(prod, grow_time, grower, percent)
    self.product_prefab = prod
    self.rate = 1 / grow_time
    self.growthpercent = math.clamp(percent or 0, 0, 1)
    self.inst.AnimState:SetPercent("grow", self.growthpercent)
    self.grower = grower

    local dt = 2
    if self.task ~= nil then
        self.task:Cancel()
    end
    self.task = self.inst:DoPeriodicTask(dt, _DoGrow, nil, self, dt)
end

function Crop:Harvest(harvester)
    if self.matured or self.inst:HasTag("withered") then
        local product = nil
        if self.grower ~= nil and
            (self.grower.components.burnable ~= nil and self.grower.components.burnable:IsBurning()) or
            (self.inst.components.burnable ~= nil and self.inst.components.burnable:IsBurning()) then
            local temp = SpawnPrefab(self.product_prefab)
            product = SpawnPrefab(temp.components.cookable ~= nil and temp.components.cookable.product or "seeds_cooked")
            temp:Remove()
        else
            product = SpawnPrefab(self.product_prefab)
        end

        if self.onharvest ~= nil then
            self.onharvest(self.inst, product, harvester)
        end

        if product ~= nil then
            if product.components.inventoryitem ~= nil then
				product.components.inventoryitem:InheritWorldWetnessAtTarget(self.inst)
            end

            if harvester ~= nil then
                harvester.components.inventory:GiveItem(product, nil, self.inst:GetPosition())
            else
                -- just drop the thing (happens if you haunt the fully grown crop)
                product.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
            end
            ProfileStatsAdd("grown_"..product.prefab)
        end

        self.matured = false
        self.growthpercent = 0
        self.product_prefab = nil

        if self.grower ~= nil and self.grower:IsValid() and self.grower.components.grower ~= nil then
            self.grower.components.grower:RemoveCrop(self.inst)
            self.grower = nil
        else
            self.inst:Remove()
        end

        return true, product
    end
end

function Crop:Mature()
    if self.product_prefab ~= nil and not (self.matured or self.inst:HasTag("withered")) then
        self.matured = true
        if self.onmatured ~= nil then
            self.onmatured(self.inst)
        end
    end
end

function Crop:MakeWithered()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    self.matured = false
    self.product_prefab = "cutgrass"
    self.growthpercent = 0
    self.rate = 0
    self.inst.AnimState:PlayAnimation("picked")
    if self.inst.components.burnable == nil then
        MakeMediumBurnable(self.inst)
        MakeSmallPropagator(self.inst)
    end
	if self.inst.components.halloweenmoonmutable ~= nil then
		self.inst:RemoveComponent("halloweenmoonmutable")
	end
    if self.onwithered ~= nil then
        self.onwithered(self.inst)
    end
end

function Crop:IsReadyForHarvest()
    return self.matured
end

function Crop:LongUpdate(dt)
    self:DoGrow(dt)
end

return Crop
