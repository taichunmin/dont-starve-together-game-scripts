local FireFX = Class(function(self, inst)
    self.inst = inst

    self.level = nil
    self.playingsound = nil
    self.playingsoundintensity = nil
    self.percent = 1
    self.levels = {}
    self.playignitesound = true
    self.bigignitesoundthresh = 3
    self.usedayparamforsound = false
    self.current_radius = 1
    self.lightsound = nil
    self.extinguishsound = nil
    --self.extinguishsoundtest = nil

    inst:StartUpdatingComponent(self) 
end)

function FireFX:OnUpdate(dt)
    local time = GetTime() * 30
    --local flicker = (math.sin(time) + math.sin(time + 2) + math.sin(time + .7777)) * .5
    --Convert flicker from [-1 , 1] -> [0, 1]
    --flicker = (1 + flicker) * .5
    --local rad = self.current_radius + flicker * .05
    self.inst.Light:SetRadius(self.current_radius + .025 + (math.sin(time) + math.sin(time + 2) + math.sin(time + .7777)) * .0125)

    if self.usedayparamforsound and self.isday ~= TheWorld.state.isday then
        self.isday = TheWorld.state.isday
        self.inst.SoundEmitter:SetParameter("fire", "daytime", self.isday and 1 or 2)
    end
end

function FireFX:UpdateRadius()
    local highval_r = self.levels[self.level].radius
    local lowval_r = self.level > 1 and self.levels[self.level - 1].radius or 0

    self.current_radius = self.percent * (highval_r - lowval_r) + lowval_r

    self.inst.Light:SetRadius(self.current_radius)
end

function FireFX:SetPercentInLevel(percent)
    self.percent = percent
    self:UpdateRadius()

    local lowval_i = self.levels[math.max(1, self.level - 1)].intensity
    local highval_i = self.levels[self.level].intensity

    self.inst.Light:SetIntensity(percent * (highval_i - lowval_i) + lowval_i)
end

function FireFX:SetLevel(lev, immediate)
    if lev > 0 and lev ~= self.level then
        if self.playignitesound and (self.level == nil or lev > self.level) then
            self.inst.SoundEmitter:PlaySound(self.lightsound or (lev >= self.bigignitesoundthresh and "dontstarve/common/fireBurstLarge" or "dontstarve/common/fireBurstSmall"))
        end

        if self.level ~= nil then
            immediate = true
        end

        self.level = math.min(lev, #self.levels)
        local params = self.levels[self.level]
        if immediate or params.pre == nil then
            self.inst.AnimState:PlayAnimation(params.anim, true)
        else
            self.inst.AnimState:PlayAnimation(params.pre)
            self.inst.AnimState:PushAnimation(params.anim, true)
        end

        self.current_radius = params.radius
        self.inst.Light:Enable(true)
        self.inst.Light:SetIntensity(params.intensity)
        self.inst.Light:SetRadius(params.radius)
        self.inst.Light:SetFalloff(params.falloff)
        self.inst.Light:SetColour(unpack(params.colour))

        if self.playingsound ~= params.sound then
            if self.playingsound ~= nil then
                self.inst.SoundEmitter:KillSound("fire")
            end
            self.playingsound = params.sound
            self.playingsoundintensity = nil
            if params.sound ~= nil and not self.inst:IsAsleep() then
                self.inst.SoundEmitter:PlaySound(params.sound, "fire")
            end
        end

        if self.playingsoundintensity ~= params.soundintensity and params.sound ~= nil then
            self.playingsoundintensity = params.soundintensity
            if params.soundintensity ~= nil and self.inst.SoundEmitter:PlayingSound("fire") then
                self.inst.SoundEmitter:SetParameter("fire", "intensity", params.soundintensity)
            end
        end
    end
end

--- Kill the fx.
-- Returns true if there's a 'going out' animation and the owning entity shouldn't be removed instantly
function FireFX:Extinguish()
    if self.playingsound ~= nil then
        self.inst.SoundEmitter:KillSound("fire")
        self.playingsound = nil
        self.playingsoundintensity = nil
    end

    if self.extinguishsoundtest == nil or self.extinguishsoundtest() then
        self.inst.SoundEmitter:PlaySound(self.extinguishsound or "dontstarve/common/fireOut")
        if self.levels[self.level] ~= nil and self.levels[self.level].pst ~= nil then
            self.inst.AnimState:PlayAnimation(self.levels[self.level].pst)
            return true
        end
    end
end

function FireFX:OnEntitySleep()
    self.inst.SoundEmitter:KillSound("fire")
end

function FireFX:OnEntityWake()
    if self.playingsound ~= nil and not self.inst.SoundEmitter:PlayingSound("fire") then
        self.inst.SoundEmitter:PlaySound(self.playingsound, "fire")
        if self.playingsoundintensity ~= nil then
            self.inst.SoundEmitter:SetParameter("fire", "intensity", self.playingsoundintensity)
        end
    end
end

return FireFX
