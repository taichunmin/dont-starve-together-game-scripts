local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local function OnEffigyDeactivated(inst)
    if inst.AnimState:IsCurrentAnimation("effigy_deactivate") then
        inst.widget:Hide()
    end
end

local OldAgeBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, "status_oldage", owner, { .8, .8, .8, 1 }, nil, nil, nil, true)

	self.rate_time = 0
	self.warning_precent = 0.1

	self.health_precent = 1

    self.year_hand = self.underNumber:AddChild(UIAnim())
    self.year_hand:GetAnimState():SetBank("status_oldage")
    self.year_hand:GetAnimState():SetBuild("status_oldage")
	self.year_hand:GetAnimState():PlayAnimation("year")
    self.year_hand:GetAnimState():AnimateWhilePaused(false)

    self.days_hand = self.underNumber:AddChild(UIAnim())
    self.days_hand:GetAnimState():SetBank("status_oldage")
    self.days_hand:GetAnimState():SetBuild("status_oldage")
	self.days_hand:GetAnimState():PlayAnimation("day")
    self.days_hand:GetAnimState():AnimateWhilePaused(false)

    self.effigyanim = self.underNumber:AddChild(UIAnim())
    self.effigyanim:GetAnimState():SetBank("status_health")
    self.effigyanim:GetAnimState():SetBuild("status_health")
    self.effigyanim:GetAnimState():PlayAnimation("effigy_deactivate")
    self.effigyanim:Hide()
    self.effigyanim:SetClickable(false)
    self.effigyanim:GetAnimState():AnimateWhilePaused(false)
    self.effigyanim.inst:ListenForEvent("animover", OnEffigyDeactivated)
    self.effigy = false
    self.effigybreaksound = nil

    self.corrosives = {}
    self._onremovecorrosive = function(debuff)
        self.corrosives[debuff] = nil
    end
    self.inst:ListenForEvent("startcorrosivedebuff", function(owner, debuff)
        if self.corrosives[debuff] == nil then
            self.corrosives[debuff] = true
            self.inst:ListenForEvent("onremove", self._onremovecorrosive, debuff)
        end
    end, owner)

    self.inst:ListenForEvent("serverpauseddirty", function()
        if TheNet:IsServerPaused() then
            TheFrontEnd:GetSound():KillSound("pulse_loop")
        else
            if self.playing_pulse_loop == "up" then
                TheFrontEnd:GetSound():PlaySound("wanda2/characters/wanda/up_health_LP", "pulse_loop")
            elseif self.playing_pulse_loop == "down" then
                TheFrontEnd:GetSound():PlaySound("wanda2/characters/wanda/down_health_LP", "pulse_loop")
            end
        end
    end, TheWorld)

    self.inst:ListenForEvent("isacidsizzling", function(owner, isacidsizzling)
        if isacidsizzling == nil then
            isacidsizzling = owner:IsAcidSizzling()
        end
        if isacidsizzling then
            if self.acidsizzling == nil then
                self.acidsizzling = self.underNumber:AddChild(UIAnim())
                self.acidsizzling:GetAnimState():SetBank("inventory_fx_acidsizzle")
                self.acidsizzling:GetAnimState():SetBuild("inventory_fx_acidsizzle")
                self.acidsizzling:GetAnimState():PlayAnimation("idle", true)
                self.acidsizzling:GetAnimState():SetMultColour(.65, .62, .17, 0.8)
                self.acidsizzling:GetAnimState():SetTime(math.random())
                self.acidsizzling:SetScale(.2)
                self.acidsizzling:GetAnimState():AnimateWhilePaused(false)
                self.acidsizzling:SetClickable(false)
            end
        else
            if self.acidsizzling ~= nil then
                self.acidsizzling:Kill()
                self.acidsizzling = nil
            end
        end
    end, owner)

    self.hots = {}
    self._onremovehots = function(debuff)
        self.hots[debuff] = nil
    end
    self:StartUpdating()
    self.healthpenalty = 0
end)


function OldAgeBadge:ShowEffigy()
    if not self.effigy then
        self.effigy = true
        self.effigyanim:GetAnimState():PlayAnimation("effigy_activate")
        self.effigyanim:GetAnimState():PushAnimation("effigy_idle", false)
        self.effigyanim:Show()
    end
end

local function PlayEffigyBreakSound(inst, self)
    inst.task = nil
    if self:IsVisible() and inst.AnimState:IsCurrentAnimation("effigy_deactivate") then
        --Don't use FE sound since it's not a 2D sfx
        TheFocalPoint.SoundEmitter:PlaySound(self.effigybreaksound)
    end
end

function OldAgeBadge:HideEffigy()
    if self.effigy then
        self.effigy = false
        self.effigyanim:GetAnimState():PlayAnimation("effigy_deactivate")
        if self.effigyanim.inst.task ~= nil then
            self.effigyanim.inst.task:Cancel()
        end
        self.effigyanim.inst.task = self.effigyanim.inst:DoTaskInTime(7 * FRAMES, PlayEffigyBreakSound, self)
    end
end

function OldAgeBadge:SetPercent(val, max, penaltypercent)
	local age_precent = 1 - val
	local age = TUNING.WANDA_MIN_YEARS_OLD + age_precent * (TUNING.WANDA_MAX_YEARS_OLD - TUNING.WANDA_MIN_YEARS_OLD)
	
	self.health_precent = val

	self.num:SetString(tostring(math.floor(age + 0.5)))

	local badge_max = TUNING.WANDA_MAX_YEARS_OLD - TUNING.WANDA_MIN_YEARS_OLD

    self.year_hand:SetRotation( Lerp(0, 360, age_precent) )
end

function OldAgeBadge:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

	local player_classified = self.owner.player_classified
	if player_classified == nil then
		return
	end

	local year_percent = player_classified.oldager_yearpercent:value()

	-- client prediction for the oldager component
	if not TheWorld.ismastersim then
		local dps_rate = player_classified:GetOldagerRate()

		year_percent = year_percent + (1/40 + dps_rate*0.9) * dt
		if dps_rate == 0 then
			year_percent = math.min(1, year_percent) -- if we are going at the normal rate, then wait for the game to say we have aged a year before progressing
		end 
		player_classified.oldager_yearpercent:set_local(year_percent)
	end

    self.days_hand:SetRotation( Lerp(0, 360, year_percent) )
end

function OldAgeBadge:PulseColor(r, g, b, a)
    self.pulse:GetAnimState():SetMultColour(r, g, b, a)
    self.pulse:GetAnimState():PlayAnimation("on")
    self.pulse:GetAnimState():PushAnimation("on_loop", true)
end

function OldAgeBadge:PulseGreen()
    self:PulseColor(0, 1, 0, 1)
end

function OldAgeBadge:PulseRed()
    self:PulseColor(1, 0, 0, 1)
end

function OldAgeBadge:PulseOff()
    self.pulse:GetAnimState():SetMultColour(1, 0, 0, 1)
    self.pulse:GetAnimState():PlayAnimation("off")
    self.pulse:GetAnimState():PushAnimation("idle")
    TheFrontEnd:GetSound():KillSound("pulse_loop")
    self.playing_pulse_loop = nil
    self.pulsing = nil
end

function OldAgeBadge:Pulse(color)
    local frontend_sound = TheFrontEnd:GetSound()
    
    if color == "green" then
        self:PulseGreen()
        frontend_sound:KillSound("pulse_loop")
        frontend_sound:PlaySound("wanda2/characters/wanda/up_health_LP", "pulse_loop")
        self.playing_pulse_loop = "up"
        frontend_sound:PlaySound("dontstarve/HUD/health_up")
    else
        self:PulseRed()
        frontend_sound:KillSound("pulse_loop")
        self.playing_pulse_loop = "down"
		frontend_sound:PlaySound("wanda2/characters/wanda/down_health_LP", "pulse_loop")

		local volume = self.owner.player_classified:GetOldagerRate() > 0 and 1
					or self.health_precent <= TUNING.WANDA_AGE_THRESHOLD_OLD and 1 
					or self.health_precent < TUNING.WANDA_AGE_THRESHOLD_YOUNG and 0.65
					or 0.4
        frontend_sound:PlaySound("dontstarve/HUD/health_down", nil, volume)
    end

    self.pulsing = color
end

function OldAgeBadge:HealthDelta(data)
    
    local oldpenalty = self.healthpenalty
    local health = self.owner.replica.health
    self.healthpenalty = health:GetPenaltyPercent()

    self:SetPercent(data.newpercent, health:Max(), self.healthpenalty)

    local should_pulse = nil

    if oldpenalty > self.healthpenalty or data.newpercent > data.oldpercent then
        should_pulse = "green"
    elseif oldpenalty < self.healthpenalty or data.newpercent < data.oldpercent then
        should_pulse = "red"
    end

    if should_pulse then
        if self.pulsing ~= nil then
            if should_pulse == self.pulsing then
                if self.turnofftask ~= nil then
                    self.turnofftask:Cancel()
                    self.turnofftask = nil
                end
            else
                if self.turnofftask ~= nil then
                    self.turnofftask:Cancel()
                    self.turnofftask = nil
                end

                self:Pulse(should_pulse)
            end
        else
            self:Pulse(should_pulse)
        end

        self.turnofftask = self.inst:DoTaskInTime(0.25, function() self:PulseOff() end)
    else
        if self.turnofftask ~= nil then
            self.turnofftask:Cancel()
            self.turnofftask = nil
        end
        self:PulseOff()
    end
end

return OldAgeBadge
