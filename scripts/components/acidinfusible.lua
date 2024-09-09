local SOURCE_LIST_KEY = "acidinfusion"

local function on_initialize(inst) -- NOTES(JBK): LoadPostPass without regard to save data.
    local self = inst.components.acidinfusible
    if self then
        self:OnInfusedDirty(TheWorld.state.isacidraining, self.inst.components.rainimmunity ~= nil)
        self._initialize_task = nil
    end
end

local function on_is_acid_raining(self, isacidraining)
    self:OnInfusedDirty(isacidraining, self.inst.components.rainimmunity ~= nil)
end

local function on_rain_immunity_added(inst)
    local self = inst.components.acidinfusible
    if self then
        self:OnInfusedDirty(TheWorld.state.isacidraining, true)
    end
end

local function on_rain_immunity_removed(inst)
    local self = inst.components.acidinfusible
    if self then
        self:OnInfusedDirty(TheWorld.state.isacidraining, false)
    end
end

local AcidInfusible = Class(function(self, inst)
    self.inst = inst

    self.infused = false
    self.userainimmunity = true
    self.fxlevel = 1

    --self.damagemult = nil
    --self.damagetakenmult = nil
    --self.speedmult = nil

    --self.on_infuse_fn = nil
    --self.on_uninfuse_fn = nil

    self:WatchWorldState("isacidraining", on_is_acid_raining)

    self.inst:ListenForEvent("gainrainimmunity", on_rain_immunity_added)
    self.inst:ListenForEvent("loserainimmunity", on_rain_immunity_removed)

    self._initialize_task = self.inst:DoTaskInTime(0, on_initialize)
end)

--------------------------------------------------------------------------
function AcidInfusible:OnRemoveFromEntity()
    self:StopWatchingWorldState("isacidraining", on_is_acid_raining)
    self.inst:RemoveEventCallback("gainrainimmunity", on_rain_immunity_added)
    self.inst:RemoveEventCallback("loserainimmunity", on_rain_immunity_removed)
    if self._initialize_task then
        self._initialize_task:Cancel()
        self._initialize_task = nil
    end
end

--------------------------------------------------------------------------
function AcidInfusible:SetDamageMultiplier(n)
    self.damagemult = n

    if self.infused and self.inst.components.combat ~= nil then
        self.inst.components.combat.externaldamagemultipliers:RemoveModifier(self.inst, SOURCE_LIST_KEY)
        if self.damagemult then
            self.inst.components.combat.externaldamagemultipliers:SetModifier(self.inst, self.damagemult, SOURCE_LIST_KEY)
        end
    end
end

function AcidInfusible:SetDamageTakenMultiplier(n)
    self.damagetakenmult = n

    if self.infused and self.inst.components.combat ~= nil then
        self.inst.components.combat.externaldamagetakenmultipliers:RemoveModifier(self.inst, SOURCE_LIST_KEY)
        if self.damagetakenmult then
            self.inst.components.combat.externaldamagetakenmultipliers:SetModifier(self.inst, self.damagetakenmult, SOURCE_LIST_KEY)
        end
    end
end

function AcidInfusible:SetSpeedMultiplier(n)
    self.speedmult = n

    if self.infused and self.inst.components.locomotor ~= nil then
        self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, SOURCE_LIST_KEY)

        if self.speedmult then
            self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, SOURCE_LIST_KEY, self.speedmult)
        end
    end
end

local CLEARED_VALUES = {
    DAMAGE = nil,
    DAMAGE_TAKEN = nil,
    SPEED = nil,
}
function AcidInfusible:SetMultipliers(tuning)
    tuning = tuning or CLEARED_VALUES
    self:SetDamageMultiplier(tuning.DAMAGE)
    self:SetDamageTakenMultiplier(tuning.DAMAGE_TAKEN)
    self:SetSpeedMultiplier(tuning.SPEED)
end

function AcidInfusible:SetOnInfuseFn(fn)
    self.on_infuse_fn = fn
end

function AcidInfusible:SetOnUninfuseFn(fn)
    self.on_uninfuse_fn = fn
end

function AcidInfusible:SetUseRainImmunity(userainimmunity)
    if userainimmunity ~= self.userainimmunity then
        self.userainimmunity = userainimmunity
        self:OnInfusedDirty(TheWorld.state.isacidraining, self.inst.components.rainimmunity ~= nil)
    end
end

function AcidInfusible:SetFXLevel(level)
    self.fxlevel = level
end

--------------------------------------------------------------------------

function AcidInfusible:IsInfused()
    return self.infused
end

--------------------------------------------------------------------------

function AcidInfusible:OnInfuse()
    if self.speedmult ~= nil and self.inst.components.locomotor ~= nil then
        self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, SOURCE_LIST_KEY, self.speedmult)
    end

    if self.inst.components.combat ~= nil then
        if self.damagemult ~= nil then
            self.inst.components.combat.externaldamagemultipliers:SetModifier(self.inst, self.damagemult, SOURCE_LIST_KEY)
        end

        if self.damagetakenmult ~= nil then
            self.inst.components.combat.externaldamagetakenmultipliers:SetModifier(self.inst, self.damagetakenmult, SOURCE_LIST_KEY)
        end
    end

    if self.fxlevel ~= nil then
        self:SpawnFX()
    end

    if self.on_infuse_fn ~= nil then
        self.on_infuse_fn(self.inst)
    end
end

function AcidInfusible:OnUninfuse()
    if self.inst.components.locomotor ~= nil then
        self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, SOURCE_LIST_KEY)
    end

    if self.inst.components.combat ~= nil then
        self.inst.components.combat.externaldamagemultipliers:RemoveModifier(self.inst, SOURCE_LIST_KEY)
        self.inst.components.combat.externaldamagetakenmultipliers:RemoveModifier(self.inst, SOURCE_LIST_KEY)
    end

    self:KillFX()

    if self.on_uninfuse_fn ~= nil then
        self.on_uninfuse_fn(self.inst)
    end
end

function AcidInfusible:OnInfusedDirty(acidraining, hasrainimmunity)
    local infused = acidraining and not (self.userainimmunity and hasrainimmunity)
    if infused and not self.infused then
        self:OnInfuse()
        self.infused = true
    elseif not infused and self.infused then
        self:OnUninfuse()
        self.infused = false
    end
end

--------------------------------------------------------------------------

function AcidInfusible:SpawnFX()
    self:KillFX()

    self._fx = self.inst:SpawnChild("acidsmoke_fx")

    if self._fx ~= nil then
        self._fx:SetLevel(self.fxlevel)
    end
end

function AcidInfusible:KillFX()
    if self._fx ~= nil then
        if self._fx:IsValid() then
            local time = self._fx.AnimState:GetCurrentAnimationLength() - self._fx.AnimState:GetCurrentAnimationTime() + FRAMES
            self._fx:DoTaskInTime(time, self._fx.Remove)
        end
        self._fx = nil
    end
end

--------------------------------------------------------------------------

function AcidInfusible:GetDebugString()
    return "INFUSED: "..(self.infused and "true" or "false")
end

--------------------------------------------------------------------------

return AcidInfusible
