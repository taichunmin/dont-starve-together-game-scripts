local function OnEnterDark(inst)
    inst.components.grue:RemoveImmunity("light")
end

local function OnEnterLight(inst)
    inst.components.grue:AddImmunity("light")
end

local function OnNightVision(inst, nightvision)
    if nightvision then
        inst.components.grue:AddImmunity("nightvision")
    else
        inst.components.grue:RemoveImmunity("nightvision")
    end
end

local function OnInvincibleToggle(inst, data)
    if data.invincible then
        inst.components.grue:AddImmunity("invincible")
    else
        inst.components.grue:RemoveImmunity("invincible")
    end
end

local function OnDeath(inst)
    inst.components.grue:Stop()
end

local function OnRespawned(inst)
	local self = inst.components.grue
	if next(self.immunity) == nil then
		self:Start()
	end
end

local function OnInit(inst, self)
    self.inittask = nil
    inst:ListenForEvent("enterdark", OnEnterDark)
    inst:ListenForEvent("enterlight", OnEnterLight)
    inst:ListenForEvent("nightvision", OnNightVision)
    inst:ListenForEvent("invincibletoggle", OnInvincibleToggle)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("ms_respawnedfromghost", OnRespawned)

	if inst:IsInLight() then
		self:AddImmunity("light")
	end
	if inst.components.playervision ~= nil and inst.components.playervision:HasNightVision() then
		self:AddImmunity("nightvision")
	end
	if inst.components.health ~= nil and inst.components.health:IsInvincible() then
		self:AddImmunity("invincible")
	end

	if next(self.immunity) == nil then
		self:Start()
	end
end

local Grue = Class(function(self, inst)
    self.inst = inst

    self.soundevent = nil
    self.warndelay = 1
    --self.resistance = nil
    self.level = nil
    --self.nextHitTime = nil
    --self.nextSoundTime = nil
    self.immunity = {}

    self.nonlethal = TUNING.NONLETHAL_DARKNESS
    self.nonlethal_pct = TUNING.NONLETHAL_PERCENT

    self.inittask = inst:DoTaskInTime(0, OnInit, self)
end)

function Grue:OnRemoveEntity()
	--Prevent items being removed at the same time from triggering loss of
	--immunity and thus restarting updating while we are becoming invalid.
	for k in pairs(self.immunity) do
		self.immunity[k] = nil
	end
end

function Grue:OnRemoveFromEntity()
    self:Stop()
    if self.inittask ~= nil then
        self.inittask:Cancel()
        self.inittask = nil
    else
        self.inst:RemoveEventCallback("enterdark", OnEnterDark)
        self.inst:RemoveEventCallback("enterlight", OnEnterLight)
        self.inst:RemoveEventCallback("nightvision", OnNightVision)
        self.inst:RemoveEventCallback("invincibletoggle", OnInvincibleToggle)
        self.inst:RemoveEventCallback("death", OnDeath)
        self.inst:RemoveEventCallback("ms_respawnedfromghost", OnRespawned)
    end
end

--V2C: Leave CheckForStart() as a public member function for backward mod compatibility
function Grue:CheckForStart()
    return not (self.inst.components.health:IsInvincible() or
                self.inst:IsInLight() or
                self.inst.components.health:IsDead() or
                CanEntitySeeInDark(self.inst))
end

function Grue:Start()
    if self.level == nil and self:CheckForStart() then
        self.level = 0
        self.inst:StartUpdatingComponent(self)
        self.nextHitTime = 5 + math.random() * 5
        self.nextSoundTime = self.nextHitTime * (.4 + math.random() * .4)
    end
end

function Grue:SetSounds(warn, attack)
    self.soundwarn = warn
    self.soundattack = attack
end

function Grue:Stop()
    if self.level ~= nil then
        self.level = nil
        self.inst:StopUpdatingComponent(self)
    end
end

function Grue:SetResistance(resistance)
    self.resistance = resistance
end

function Grue:AddImmunity(source)
	source = source or self
	if not self.immunity[source] then
		self.immunity[source or self] = true
		self:Stop()
	end
end

function Grue:RemoveImmunity(source)
	source = source or self
	if self.immunity[source] then
		self.immunity[source] = nil
		if next(self.immunity) == nil then
			self:Start()
		end
	end
end

--Deprecated; kept around for mod backward compatibility
function Grue:SetSleeping(asleep)
    if asleep then
        self:AddImmunity("sleeping")
    else
        self:RemoveImmunity("sleeping")
    end
end

function Grue:Attack()
    local damage = TUNING.GRUEDAMAGE

    if self.nonlethal then
        local health = self.inst.components.health
        if health then
            local currenthealth = health.currenthealth
            local maxhealth = health.maxhealth

            local damagepercent = (currenthealth - damage) / maxhealth
            if damagepercent <= self.nonlethal_pct then
                local minhealth = maxhealth * self.nonlethal_pct
                damage = math.max(0, currenthealth - minhealth)
            end
        end
    end

    self.inst.components.combat:GetAttacked(nil, damage, nil, "darkness")
end

function Grue:OnUpdate(dt)
    if self.nextHitTime ~= nil and self.nextHitTime > 0 then
        self.nextHitTime = self.nextHitTime - dt
    end

    if self.nextSoundTime ~= nil and self.nextSoundTime > 0 then
        self.nextSoundTime = self.nextSoundTime - dt

        if self.nextSoundTime <= 0 then
            if self.soundwarn ~= nil then
                self.inst.SoundEmitter:PlaySound(self.soundwarn)
            end
            self.inst:DoTaskInTime(self.warndelay, self.inst.PushEvent, "heargrue")
        end
    end

    if self.nextHitTime ~= nil and self.nextHitTime <= 0 then
        self.level = self.level + 1
        self.nextHitTime = 5 + math.random() * 6
        self.nextSoundTime = self.nextHitTime * (.4 + math.random() * .4)

        if self.soundattack ~= nil then
            self.inst.SoundEmitter:PlaySound(self.soundattack)
        end

        if self.level > (self.resistance or 0) then
            self:Attack()
            self.inst.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
            self.inst:PushEvent("attackedbygrue")
        else
            self.inst:PushEvent("resistedgrue")
        end
    end
end

return Grue
