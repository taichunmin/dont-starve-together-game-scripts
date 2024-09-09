local function OnSymbolDirty(inst)
    inst:PushEvent("clientpethealthsymboldirty", { symbol = inst.components.pethealthbar:GetSymbol() })
end

local function OnStatusDirty(inst)
    inst:PushEvent("clientpethealthstatusdirty")
end

local function OnPulseDirty(inst)
    inst:PushEvent("clientpethealthpulsedirty")
end

local function OnHealthMaxDirty(inst)
    inst:PushEvent("clientpetmaxhealthdirty", { max = inst.components.pethealthbar._maxhealth:value() })
end

local function OnHealthPctDirty(inst)
    inst:PushEvent("clientpethealthdirty", { percent = inst.components.pethealthbar._healthpct:value() })
end

local function OnPetSkinDirty(inst)
    inst:PushEvent("clientpetskindirty")
end

local function OnHealthDelta(inst, data)
    local self = inst.components.pethealthbar
	local prev_health = self._healthpct:value()
	self._healthpct:set(data.newpercent) -- setting then testing against the old value so the persistion in the net_float will work out correctly
    if prev_health ~= self._healthpct:value() then
        self._healthpct:set(data.newpercent)
		if not data.overtime and data.oldpercent ~= nil then
			self._pulse:set_local(0)
			self._pulse:set(data.oldpercent < data.newpercent and 1 or 2)
		end
        OnHealthPctDirty(inst)
    end
end

local function onsetpetskin(self, petskin)
	self._petskin:set(petskin)
end

local PetHealthBar = Class(function(self, inst)
    self.inst = inst
    self.ismastersim = TheWorld.ismastersim

    self._symbol = net_hash(inst.GUID, "pethealthbar._symbol", "pethealthsymboldirty")
    self._status = net_tinybyte(inst.GUID, "pethealthbar._status", "pethealthstatusdirty") -- [0-4] for over time
    self._maxhealth = net_ushortint(inst.GUID, "pethealthbar._maxhealth", "pethealthmaxdirty")
    self._pulse = net_tinybyte(inst.GUID, "pethealthbar._pulse", "pethealthpulsedirty") -- 1 = green, 2 = red -- Note: This is hooked up like a net_event
    self._healthpct = net_float(inst.GUID, "pethealthbar._healthpct", "pethealthpctdirty")
    self._petskin = net_hash(inst.GUID, "pethealthbar._petskin", "pethealthpetskindirty")
    self.petskin_str = ""
    self._healthpct:set(1)

    if self.ismastersim then
        self._onhealthdelta = function(pet, data)
            OnHealthDelta(self.inst, data)
        end

        self.corrosives = {}
        self._onremovecorrosive = function(debuff)
            self.corrosives[debuff] = nil
        end
        self._onstartcorrsivedebuff = function(pet, debuff)
            if self.corrosives[debuff] == nil then
                self.corrosives[debuff] = true
                self.inst:ListenForEvent("onremove", self._onremovecorrosive, debuff)
            end
        end

        self.hots = {}
        self._onremovehots = function(debuff)
            self.hots[debuff] = nil
        end
        self._onstarthealthregen = function(pet, debuff)
            if self.hots[debuff] == nil then
                self.hots[debuff] = true
                self.inst:ListenForEvent("onremove", self._onremovehots, debuff)
            end
        end

        self.small_hots = {}
        self._onremovesmallhots = function(debuff)
            self.small_hots[debuff] = nil
        end
        self._onstartsmallhealthregen = function(pet, debuff)
            if self.small_hots[debuff] == nil then
                self.small_hots[debuff] = true
                self.inst:ListenForEvent("onremove", self._onremovesmallhots, debuff)
            end
        end
    else
        inst:ListenForEvent("pethealthsymboldirty", OnSymbolDirty)
        inst:ListenForEvent("pethealthstatusdirty", OnStatusDirty)
        inst:ListenForEvent("pethealthpulsedirty", OnPulseDirty)
        inst:ListenForEvent("pethealthmaxdirty", OnHealthMaxDirty)
        inst:ListenForEvent("pethealthpctdirty", OnHealthPctDirty)
        inst:ListenForEvent("pethealthpetskindirty", OnPetSkinDirty)
        inst:DoTaskInTime(0, OnHealthPctDirty)
    end
end,
nil,
{
	petskin = onsetpetskin,
})

--------------------------------------------------------------------------
--Common

function PetHealthBar:GetSymbol()
    return self._symbol:value()
end

function PetHealthBar:GetMaxHealth()
    return self._maxhealth:value()
end

function PetHealthBar:GetOverTime()
    -- returns -2 large down, -1 small down, 0 none, 1 small up, 2 large up
    local val = self._status:value()
    return ((val <= 0 or val >= 5) and 0)
        or (val <= 2 and val)
        or val - 5
end

function PetHealthBar:GetPercent()
    return self._healthpct:value()
end

function PetHealthBar:GetPulse()
	return self._pulse:value()
end

function PetHealthBar:ResetPulse()
	self._pulse:set_local(0)
end

--------------------------------------------------------------------------
--Server only

function PetHealthBar:SetSymbol(symbol)
    if self.ismastersim and self._symbol:value() ~= symbol then
        self._symbol:set(symbol)
        OnSymbolDirty(self.inst)
    end
end

function PetHealthBar:SetMaxHealth(max_health)
    if self.ismastersim and self._maxhealth:value() ~= max_health then
        self._maxhealth:set(max_health)
        OnHealthMaxDirty(self.inst)
    end
end

function PetHealthBar:SetPetSkin(petskin)
    if self.ismastersim and self.petskin_str ~= petskin then
        self.petskin_str = petskin
        if petskin == nil then
            petskin = 0
        end
        self._petskin:set(petskin)
        OnPetSkinDirty(self.inst)
    end
end

local function InitPet(inst, self, pet)
    self.task = nil
    OnHealthDelta(inst, { newpercent = pet.components.health ~= nil and pet.components.health:GetPercent() or 0 })
end

function PetHealthBar:SetPet(pet, symbol, maxhealth)
    if self.ismastersim then
        self:SetSymbol(symbol)
        self:SetMaxHealth(maxhealth)

        if self.pet == pet then
            return
        elseif self.pet ~= nil then
            if self.task ~= nil then
                self.task:Cancel()
            end
            self.inst:RemoveEventCallback("healthdelta", self._onhealthdelta, self.pet)
            self.inst:RemoveEventCallback("startcorrosivedebuff", self._onstartcorrsivedebuff, self.pet)
            self.inst:RemoveEventCallback("starthealthregen", self._onstarthealthregen, self.pet)
            self.inst:RemoveEventCallback("startsmallhealthregen", self._onstartsmallhealthregen, self.pet)

            local k = next(self.corrosives)
            while k ~= nil do
                self.inst:RemoveEventCallback("onremove", self._onremovecorrosive, k)
                self.corrosives[k] = nil
                k = next(self.corrosives)
            end
            k = next(self.hots)
            while k ~= nil do
                self.inst:RemoveEventCallback("onremove", self._onremovehots, k)
                self.hots[k] = nil
                k = next(self.hots)
            end
            k = next(self.small_hots)
            while k ~= nil do
                self.inst:RemoveEventCallback("onremove", self._onremovesmallhots, k)
                self.small_hots[k] = nil
                k = next(self.small_hots)
            end
        end

        self.pet = pet

        self:SetPetSkin( pet.skinname )

        self.inst:ListenForEvent("healthdelta", self._onhealthdelta, pet)
        self.inst:ListenForEvent("startcorrosivedebuff", self._onstartcorrsivedebuff, pet)
        self.inst:ListenForEvent("starthealthregen", self._onstarthealthregen, pet)
        self.inst:ListenForEvent("startsmallhealthregen", self._onstartsmallhealthregen, pet)
        self.task = self.inst:DoTaskInTime(0, InitPet, self, pet)

        self.inst:StartUpdatingComponent(self)
    end
end

function PetHealthBar:OnUpdate(dt)
    local down =
        (self.pet.IsFreezing ~= nil and self.pet:IsFreezing()) or
        (self.pet.IsOverheating ~= nil and self.pet:IsOverheating()) or
        (self.pet.components.hunger ~= nil and self.pet.components.hunger:IsStarving()) or
        (self.pet.components.health ~= nil and self.pet.components.health.takingfiredamage) or
        next(self.corrosives) ~= nil

    -- Show the up-arrow when we're sleeping (but not in a straw roll: that doesn't heal us)
    local up = not down and
        (   next(self.hots) ~= nil or
			next(self.small_hots) ~= nil or
            (self.pet.components.inventory ~= nil and self.pet.components.inventory:EquipHasTag("regen"))
        ) and
        self.pet.components.health ~= nil and self.pet.components.health:IsHurt()

    local status =
        (down and 3) or
        (not up and 0) or
        (next(self.hots) ~= nil and 2) or
        1

    if self._status:value() ~= status then
        self._status:set(status)
        OnStatusDirty(self.inst)
    end
end

function PetHealthBar:GetDebugString()
	if self.pet == nil then
		return "no pet"
	else
		return string.format("%0.2f%% of %d, sym: 0x%08X, stat: %d", self._healthpct:value() * 100, self._maxhealth:value(), self._symbol:value(), self._status:value())
	end
end

return PetHealthBar
