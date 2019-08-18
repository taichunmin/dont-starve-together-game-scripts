local Widget = require "widgets/widget"
local SanityBadge = require "widgets/sanitybadge"
local HealthBadge = require "widgets/healthbadge"
local HungerBadge = require "widgets/hungerbadge"
local BeaverBadge = require "widgets/beaverbadge"
local MoistureMeter = require "widgets/moisturemeter"
local BoatMeter = require "widgets/boatmeter"
local ResurrectButton = require "widgets/resurrectbutton"
local UIAnim = require "widgets/uianim"

local function OnSetPlayerMode(inst, self)
    self.modetask = nil

    if self.onhealthdelta == nil then
        self.onhealthdelta = function(owner, data) self:HealthDelta(data) end
        self.inst:ListenForEvent("healthdelta", self.onhealthdelta, self.owner)
        self:SetHealthPercent(self.owner.replica.health:GetPercent())
    end

    if self.onhungerdelta == nil then
        self.onhungerdelta = function(owner, data) self:HungerDelta(data) end
        self.inst:ListenForEvent("hungerdelta", self.onhungerdelta, self.owner)
        self:SetHungerPercent(self.owner.replica.hunger:GetPercent())
    end

    if self.onsanitydelta == nil then
        self.onsanitydelta = function(owner, data) self:SanityDelta(data) end
        self.inst:ListenForEvent("sanitydelta", self.onsanitydelta, self.owner)
        self:SetSanityPercent(self.owner.replica.sanity:GetPercent())
    end

    if self.onmoisturedelta == nil then
        self.onmoisturedelta = function(owner, data) self:MoistureDelta(data) end
        self.inst:ListenForEvent("moisturedelta", self.onmoisturedelta, self.owner)
        self:SetMoisturePercent(self.owner:GetMoisture())
    end

    if self.ongotonplatform == nil then
        local my_platform = self.owner:GetCurrentPlatform()
        if my_platform ~= nil and my_platform.components.healthsyncer ~= nil then
            self.boatmeter:Enable(my_platform)
        end

        self.ongotonplatform = function(owner, platform) if platform.components.healthsyncer ~= nil then self.boatmeter:Enable(platform) end end
        self.inst:ListenForEvent("got_on_platform", self.ongotonplatform, self.owner)

        self.ongotoffplatform = function(owner, platform) self.boatmeter:Disable(platform) end
        self.inst:ListenForEvent("got_off_platform", self.ongotoffplatform, self.owner)
    end

    if self.beaverness ~= nil and self.onbeavernessdelta == nil then
        self.onbeavernessdelta = function(owner, data) self:BeavernessDelta(data) end
        self.inst:ListenForEvent("beavernessdelta", self.onbeavernessdelta, self.owner)
        self:SetBeavernessPercent(self.owner:GetBeaverness())
    end
end

local function OnSetGhostMode(inst, self)
    self.modetask = nil

    if self.onhealthdelta ~= nil then
        self.inst:RemoveEventCallback("healthdelta", self.onhealthdelta, self.owner)
        self.onhealthdelta = nil
    end

    if self.onhungerdelta ~= nil then
        self.inst:RemoveEventCallback("hungerdelta", self.onhungerdelta, self.owner)
        self.onhungerdelta = nil
    end

    if self.onsanitydelta ~= nil then
        self.inst:RemoveEventCallback("sanitydelta", self.onsanitydelta, self.owner)
        self.onsanitydelta = nil
    end

    if self.onmoisturedelta ~= nil then
        self.inst:RemoveEventCallback("moisturedelta", self.onmoisturedelta, self.owner)
        self.onmoisturedelta = nil
    end

    if self.ongotonplatform ~= nil then

        self.inst:RemoveEventCallback("got_on_platform", self.ongotonplatform, self.owner)
        self.ongotonplatform = nil        

        self.inst:RemoveEventCallback("got_off_platform", self.ongotoffplatform, self.owner)
        self.ongotoffplatform = nil
        
    end       

    if self.onbeavernessdelta ~= nil then
        self.inst:RemoveEventCallback("beavernessdelta", self.onbeavernessdelta, self.owner)
        self.onbeavernessdelta = nil
    end
end

local function UpdateRezButton(inst, self, enable)
    self.rezbuttontask = nil
    if enable then
        self:EnableResurrect(true)
    else
        local was_button_visible = self.isghostmode and self.resurrectbutton:IsVisible()
        self:EnableResurrect(false)
        if was_button_visible and not self.resurrectbutton:IsVisible() then
            self.resurrectbuttonfx:GetAnimState():PlayAnimation("break")
            self.resurrectbuttonfx:Show()
            if self.resurrectbuttonfx:IsVisible() then
                TheFocalPoint.SoundEmitter:PlaySound(self.heart.effigybreaksound)
            end
        end
    end
end

local StatusDisplays = Class(Widget, function(self, owner)
    Widget._ctor(self, "Status")
    self.owner = owner

    self.beaverness = nil
    self.onbeavernessdelta = nil

    self.brain = self:AddChild(SanityBadge(owner))
    self.brain:SetPosition(0, -40, 0)
    self.onsanitydelta = nil

    self.stomach = self:AddChild(HungerBadge(owner))
    self.stomach:SetPosition(-40, 20, 0)
    self.onhungerdelta = nil

    self.heart = self:AddChild(HealthBadge(owner))
    self.heart:SetPosition(40, 20, 0)
    self.heart.effigybreaksound = "dontstarve/creatures/together/lavae/egg_deathcrack"
    self.onhealthdelta = nil
    self.healthpenalty = 0

    self.moisturemeter = self:AddChild(MoistureMeter(owner))
    self.moisturemeter:SetPosition(0, -115, 0)
    self.onmoisturedelta = nil

    self.boatmeter = self:AddChild(BoatMeter(owner))
    self.boatmeter:SetPosition(-80, -40, 0)
    self.ongotonplatform = nil
    self.ongotoffplatform = nil

    self.resurrectbutton = self:AddChild(ResurrectButton(owner))
    self.resurrectbutton:SetScale(.75, .75, .75)
    self.resurrectbutton:SetTooltip(STRINGS.UI.HUD.ACTIVATE_RESURRECTION)

    self.resurrectbuttonfx = self:AddChild(UIAnim())
    self.resurrectbuttonfx:SetScale(.75, .75, .75)
    self.resurrectbuttonfx:GetAnimState():SetBank("effigy_break")
    self.resurrectbuttonfx:GetAnimState():SetBuild("effigy_button")
    self.resurrectbuttonfx:Hide()
    self.resurrectbuttonfx.inst:ListenForEvent("animover", function(inst) inst.widget:Hide() end)

    --NOTE: Can't rely on order of getting and losing attunement,
    --      especially in the same frame when switching effigies.

    --Delay button updates so it doesn't draw focus from entity anims/fx
    --Also helps flatten messages from the same frame to its final value
    local rezbuttondelay = 15 * FRAMES

    self.inst:ListenForEvent("gotnewattunement", function(owner, data)
        --can safely assume we are attuned if we just "got" an attunement
        if data.proxy:IsAttunableType("remoteresurrector") then
            if self.rezbuttontask ~= nil then
                self.rezbuttontask:Cancel()
            end
            self.rezbuttontask = not self.heart.effigy and self.inst:DoTaskInTime(rezbuttondelay, UpdateRezButton, self, true) or nil
        end
    end, owner)

    self.inst:ListenForEvent("attunementlost", function(owner, data)
        --cannot assume that we are no longer attuned
        --to a type when we lose a single attunement!
        if data.proxy:IsAttunableType("remoteresurrector") and
            not (owner.components.attuner ~= nil and owner.components.attuner:HasAttunement("remoteresurrector")) then
            if self.rezbuttontask ~= nil then
                self.rezbuttontask:Cancel()
            end
            self.rezbuttontask = self.heart.effigy and self.inst:DoTaskInTime(rezbuttondelay, UpdateRezButton, self, false) or nil
        end
    end, owner)

    self.rezbuttontask = nil
    self.modetask = nil
    self.isghostmode = true --force the initial SetGhostMode call to be dirty
    self:SetGhostMode(false)

    if owner:HasTag("beaverness") then
        self:AddBeaverness()
	    self.boatmeter:SetPosition(-80, -113, 0)
    end

	self.brain:MoveToFront() -- hack so the sanity mode change fx are on top of everything
end)

function StatusDisplays:ShowStatusNumbers()
    self.brain.num:Show()
    self.stomach.num:Show()
    self.heart.num:Show()
    self.moisturemeter.num:Show()
    self.boatmeter.num:Show()
    if self.beaverness ~= nil then
        self.beaverness.num:Show()
    end
end

function StatusDisplays:HideStatusNumbers()
    self.brain.num:Hide()
    self.stomach.num:Hide()
    self.heart.num:Hide()
    self.moisturemeter.num:Hide()
    self.boatmeter.num:Hide()
    if self.beaverness ~= nil then
        self.beaverness.num:Hide()
    end
end

function StatusDisplays:AddBeaverness()
    if self.beaverness == nil then
        self.beaverness = self:AddChild(BeaverBadge(self.owner))
        self.beaverness:SetPosition(-80, -40, 0)

        if self.isghostmode then
            self.beaverness:Hide()
        elseif self.modetask == nil and self.onbeavernessdelta == nil then
            self.onbeavernessdelta = function(owner, data) self:BeavernessDelta(data) end
            self.inst:ListenForEvent("beavernessdelta", self.onbeavernessdelta, self.owner)
            self:SetBeavernessPercent(self.owner:GetBeaverness())
        end
    end
end

function StatusDisplays:Layout()

end

function StatusDisplays:RemoveBeaverness()
    if self.beaverness ~= nil then
        if self.onbeavernessdelta ~= nil then
            self.inst:RemoveEventCallback("beavernessdelta", self.onbeavernessdelta, self.owner)
            self.onbeavernessdelta = nil
        end

        self:SetBeaverMode(false)
        self.beaverness:Kill()
        self.beaverness = nil
    end
end

function StatusDisplays:SetBeaverMode(beavermode)
    if self.isghostmode or self.beaverness == nil then
        return
    elseif beavermode then
        self.stomach:Hide()
        self.beaverness:SetPosition(-40, 20, 0)
    else
        self.stomach:Show()
        self.beaverness:SetPosition(-80, -40, 0)
    end
end

function StatusDisplays:SetGhostMode(ghostmode)
    if not self.isghostmode == not ghostmode then --force boolean
        return
    elseif ghostmode then
        self.isghostmode = true

        self.heart:Hide()
        self.stomach:Hide()
        self.brain:Hide()
        self.moisturemeter:Hide()
        self.boatmeter:Hide()

        self.heart:StopWarning()
        self.stomach:StopWarning()
        self.brain:StopWarning()

        if self.beaverness ~= nil then
            self.beaverness:Hide()
            self.beaverness:StopWarning()
        end
    else
        self.isghostmode = nil

        self.heart:Show()
        self.stomach:Show()
        self.brain:Show()
        self.moisturemeter:Show()
        self.boatmeter:Show()

        if self.beaverness ~= nil then
            self.beaverness:Show()
        end
    end

    if self.rezbuttontask ~= nil then
        self.rezbuttontask:Cancel()
        self.rezbuttontask = nil
    end
    self:EnableResurrect(self.owner.components.attuner ~= nil and self.owner.components.attuner:HasAttunement("remoteresurrector"))

    if self.modetask ~= nil then
        self.modetask:Cancel()
    end
    self.modetask = self.inst:DoTaskInTime(0, ghostmode and OnSetGhostMode or OnSetPlayerMode, self)
end

function StatusDisplays:SetHealthPercent(pct)
    local health = self.owner.replica.health
    self.healthpenalty = health:GetPenaltyPercent()
    self.heart:SetPercent(pct, health:Max(), self.healthpenalty)

    if pct <= .33 then
        self.heart:StartWarning()
    else
        self.heart:StopWarning()
    end
end

function StatusDisplays:HealthDelta(data)
    local oldpenalty = self.healthpenalty
    self:SetHealthPercent(data.newpercent)

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

function StatusDisplays:SetHungerPercent(pct)
    self.stomach:SetPercent(pct, self.owner.replica.hunger:Max())

    if pct <= 0 then
        self.stomach:StartWarning()
    else
        self.stomach:StopWarning()
    end
end

function StatusDisplays:HungerDelta(data)
    self:SetHungerPercent(data.newpercent)

    if not data.overtime then
        if data.newpercent > data.oldpercent then
            self.stomach:PulseGreen()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/hunger_up")
        elseif data.newpercent < data.oldpercent then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/hunger_down")
            self.stomach:PulseRed()
        end
    end
end

function StatusDisplays:SetSanityPercent(pct)
    self.brain:SetPercent(pct, self.owner.replica.sanity:Max(), self.owner.replica.sanity:GetPenaltyPercent())

    if self.owner.replica.sanity:IsInsane() or self.owner.replica.sanity:IsEnlightened() then
        self.brain:StartWarning()
    else
        self.brain:StopWarning()
    end
end

function StatusDisplays:SanityDelta(data)
    self:SetSanityPercent(data.newpercent)

    if not data.overtime then
        if data.newpercent > data.oldpercent then
            self.brain:PulseGreen()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_up")
        elseif data.newpercent < data.oldpercent then
            self.brain:PulseRed()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_down")
        end
    end
end

function StatusDisplays:SetBeavernessPercent(pct)
    self.beaverness:SetPercent(pct)
end

function StatusDisplays:BeavernessDelta(data)
    self:SetBeavernessPercent(data.newpercent)

    if not data.overtime then
        if data.newpercent > data.oldpercent then
            self.beaverness:PulseGreen()
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
        elseif data.newpercent < data.oldpercent then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
            self.beaverness:PulseRed()
        end
    end
end

function StatusDisplays:SetMoisturePercent(pct)
    self.moisturemeter:SetValue(pct, self.owner:GetMaxMoisture(), self.owner:GetMoistureRateScale())
end

function StatusDisplays:MoistureDelta(data)
    self:SetMoisturePercent(data.new)
end

function StatusDisplays:GetResurrectButton()
    return self.resurrectbutton:IsVisible() and self.resurrectbutton or nil
end

function StatusDisplays:EnableResurrect(enable)
    if enable then
        self.heart:ShowEffigy()
        if self.isghostmode then
            self.resurrectbutton:Show()
        else
            self.resurrectbutton:Hide()
        end
    else
        self.heart:HideEffigy()
        self.resurrectbutton:Hide()
    end
end

return StatusDisplays
