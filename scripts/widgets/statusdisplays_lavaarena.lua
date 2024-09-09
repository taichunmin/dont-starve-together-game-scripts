local Widget = require "widgets/widget"
local Badge = require "widgets/badge"
local HealthBadge = require "widgets/healthbadge"
local UIAnim = require "widgets/uianim"

local function OnSetVisibleMode(inst, self)
    self.modetask = nil

    if self.onhealthdelta == nil then
        self.onhealthdelta = function(owner, data) self:HealthDelta(data) end
        inst:ListenForEvent("healthdelta", self.onhealthdelta, self.owner)
        self.healthmax = self:SetHealthPercent(self.owner.replica.health:GetPercent())
        self.queuedhealthmax = self.healthmax

        self.onpethealthdirty = function() self:RefreshPetHealth() end
        inst:ListenForEvent("clientpethealthdirty", self.onpethealthdirty, self.owner)
        inst:ListenForEvent("clientpethealthsymboldirty", self.onpethealthdirty, self.owner)
        inst:ListenForEvent("clientpetmaxhealthdirty", self.onpethealthdirty, self.owner)
        inst:ListenForEvent("clientpethealthstatusdirty", self.onpethealthdirty, self.owner)
        if self.owner.components.pethealthbar ~= nil and self.owner.components.pethealthbar:GetSymbol() ~= 0 then
            self:RefreshPetHealth()
        end
    end
end

local function OnSetHiddenMode(inst, self)
    self.modetask = nil

    if self.onhealthdelta ~= nil then
        self.inst:RemoveEventCallback("healthdelta", self.onhealthdelta, self.owner)
        self.onhealthdelta = nil
    end

    self:StopUpdating()
end

local StatusDisplays = Class(Widget, function(self, owner)
    Widget._ctor(self, "Status")
    self:UpdateWhilePaused(false)
    self.owner = owner

    self:SetPosition(-115 + 16, 59)

    self.heart = self:AddChild(HealthBadge(owner, "lavaarena_health"))
    self.heart.topperanim:Hide()
    self.heart.anim:GetAnimState():Show("frame")
    self.heart.anim:SetScale(.61)
    self.heart.pulse:SetScale(1.375)
    self.heart.pulse:SetPosition(2, -1)
    self.heart.warning:SetScale(1.375)
    self.heart.warning:SetPosition(2, -1)

    self.onhealthdelta = nil
    self.healthpenalty = 0
    self.healthmax = 0
    self.queuedhealthmax = 0

    self.modetask = nil
    self.isghostmode = false
    self.craft_hide = false
    self.visiblemode = false --force the initial UpdateMode call to be dirty
    self:UpdateMode()
end)

function StatusDisplays:AddPet()
    self.pet_heart = self:AddChild(Badge("lavaarena_pethealth", self.owner))
    self.pet_heart.anim:GetAnimState():Show("frame")
    self.pet_heart:SetPosition(35, 70)
    self.pet_heart.anim:SetScale(.8)
    self.pet_heart:MoveToBack()

    self.pet_heart._arrowdir = 0

    self.pet_heart.arrow = self.pet_heart.underNumber:AddChild(UIAnim())
    self.pet_heart.arrow:GetAnimState():SetBank("sanity_arrow")
    self.pet_heart.arrow:GetAnimState():SetBuild("sanity_arrow")
    self.pet_heart.arrow:GetAnimState():PlayAnimation("neutral")
    self.pet_heart.arrow:GetAnimState():AnimateWhilePaused(false)
    self.pet_heart.arrow:SetScale(0.75)
end

function StatusDisplays:UpdateMode()
    if self.visiblemode == not (self.isghostmode or self.craft_hide) then
        return
    end

    self.visiblemode = not self.visiblemode

    if self.visiblemode then
        self.heart:Show()
        if self.pet_heart ~= nil then
            self.pet_heart:Show()
        end
    else
        self.heart:Hide()
        if self.pet_heart ~= nil then
            self.pet_heart:Hide()
        end
    end

    if self.modetask ~= nil then
        self.modetask:Cancel()
    end
    self.modetask = self.inst:DoTaskInTime(0, self.visiblemode and OnSetVisibleMode or OnSetHiddenMode, self)
end

function StatusDisplays:SetGhostMode(ghostmode)
    self.isghostmode = ghostmode
    self:UpdateMode()
end

function StatusDisplays:ToggleCrafting(hide)
    self.craft_hide = hide
    self:UpdateMode()
end

function StatusDisplays:ShowStatusNumbers()
    self.heart.num:Show()
    if self.pet_heart ~= nil then
        self.pet_heart.num:Show()
    end
end

function StatusDisplays:HideStatusNumbers()
    self.heart.num:Hide()
    if self.pet_heart ~= nil then
        self.pet_heart.num:Hide()
    end
end

function StatusDisplays:GetResurrectButton()
    return nil
end

function StatusDisplays:SetHealthPercent(pct)
    local health = self.owner.replica.health
    local max = health:Max()
    self.healthpenalty = health:GetPenaltyPercent()
    self.heart:SetPercent(pct, max, self.healthpenalty)

    if pct <= .3 then
        self.heart:StartWarning()
    else
        self.heart:StopWarning()
    end

    return max
end

function StatusDisplays:HealthDelta(data)
    local oldpenalty = self.healthpenalty
    local percent = data.newpercent == 0 and 0 or math.max(data.newpercent, 0.001)
    self.queuedhealthmax = self:SetHealthPercent(percent)

    --max health pulses are queued since multiple events fire when swapping equipment
    if self.queuedhealthmax ~= self.healthmax then
        self:StartUpdating()
    else
        self:StopUpdating()
    end

    --health penalty pulse takes priority
    if oldpenalty > self.healthpenalty then
        self.heart:PulseGreen()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
    elseif oldpenalty < self.healthpenalty then
        self.heart:PulseRed()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
    elseif data.overtime then
        --ignore pulse for healthdelta overtime
    elseif data.newpercent > data.oldpercent then
        self.heart:PulseGreen()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
    elseif data.newpercent < data.oldpercent then
        self.heart:PulseRed()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
    end
end

function StatusDisplays:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

    if self.queuedhealthmax > self.healthmax then
        self.heart:PulseGreen()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
    elseif self.queuedhealthmax < self.healthmax then
        self.heart:PulseRed()
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
    end
    self.healthmax = self.queuedhealthmax
    self:StopUpdating()
end

function StatusDisplays:RefreshPetHealth()
    local pethealthbar = self.owner ~= nil and self.owner:IsValid() and self.owner.components.pethealthbar or nil
    if pethealthbar == nil then
        return
    end

    local symbol = pethealthbar:GetSymbol()

    if self.pet_heart == nil then
        self:AddPet()
    end

    if symbol == 0 then
        self.pet_heart:Hide()
    else
        if self.heart:IsVisible() then
            self.pet_heart:Show()
        end
        self.pet_heart.anim:GetAnimState():OverrideSymbol("pet_abigail", "lavaarena_pethealth", symbol)
    end

    local arrowdir = pethealthbar:GetOverTime() or 0
    if self.pet_heart._arrowdir ~= arrowdir then
        self.pet_heart._arrowdir = arrowdir
        self.pet_heart.arrow:GetAnimState():PlayAnimation(
            (arrowdir > 1 and "arrow_loop_increase_most") or
            (arrowdir < 0 and "arrow_loop_decrease_most") or
            "neutral",
            true
        )
    end

    local percent = pethealthbar:GetPercent()
    if percent ~= nil then
		percent = percent == 0 and 0 or math.max(percent, 0.001)
        local health = percent * pethealthbar:GetMaxHealth()
        self.pet_heart.num:SetScale( (health >= 200 and .7) or (health > 100 and 0.85) or 1)
        self.pet_heart:SetPercent(percent, pethealthbar:GetMaxHealth())
    end
end

return StatusDisplays
