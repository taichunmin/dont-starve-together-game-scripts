local SHADER_CUTOFF_HEIGHT_HIDE = 20 -- NOTES(JBK): Just a really high number to make the shader fully invisible to hide all art.

local ProjectedEffects = Class(function(self, inst)
    self.inst = inst

    self.alpha = 0
    self.targetalpha = 0
    self.cutoffheight = -0.01 -- NOTES(JBK): Small nudge away from zero to avoid shader fractals.
    self.intensity = -0.15
    self.decaytime = 0.5
    self.constructtime = 0.25
    --self.onconstructcallback = nil
    --self.ondecaycallback = nil
end)

function ProjectedEffects:MakeOpaque()
    self.alpha = 1
    self.targetalpha = 1
    self.inst.AnimState:SetErosionParams(0, self.cutoffheight, self.intensity)
end

function ProjectedEffects:SetDecayTime(duration)
    self.decaytime = math.max(duration, 0.01) -- NOTES(JBK): Positive non-zero time.
end

function ProjectedEffects:SetConstructTime(duration)
    self.constructtime = math.max(duration, 0.01) -- NOTES(JBK): Positive non-zero time.
end

function ProjectedEffects:SetCutoffHeight(cutoffheight)
    if cutoffheight == 0 then
        cutoffheight = -0.01
    end
    self.cutoffheight = cutoffheight
end

function ProjectedEffects:SetIntensity(intensity)
    self.intensity = math.min(intensity, -0.01) -- NOTES(JBK): We must be negative for projector shader to start.
end

function ProjectedEffects:SetOnConstructCallback(callback)
    self.onconstructcallback = callback
end

function ProjectedEffects:SetOnDecayCallback(callback)
    self.ondecaycallback = callback
end

function ProjectedEffects:Construct()
    if self.permanentdecay then
        return
    end

    self.targetalpha = 1
    if self.alpha < self.targetalpha then
        self.inst:StartUpdatingComponent(self)
    end
end

function ProjectedEffects:Decay(permanent)
    self.permanentdecay = permanent
    self.targetalpha = 0
    if self.alpha > self.targetalpha then
        self.inst:StartUpdatingComponent(self)
    end
end

function ProjectedEffects:LockDecay(locked)
    self.lockeddecay = locked
end

function ProjectedEffects:SetPaused(paused)
    self.paused = paused or nil
end

function ProjectedEffects:OnUpdate(dt)
    if self.paused then
        return
    end

    local delta
    if self.alpha > self.targetalpha then
        delta = -dt / self.decaytime
    else
        delta = dt / self.constructtime
    end
    self.alpha = math.clamp(self.alpha + delta, 0, 1)
    self.inst.AnimState:SetErosionParams(1 - self.alpha, self.alpha == 0 and SHADER_CUTOFF_HEIGHT_HIDE or self.cutoffheight, self.intensity)

    if self.alpha == 0 then
        if not self.lockeddecay then
            if self.ondecaycallback ~= nil then
                self.ondecaycallback(self.inst)
            end
            self.inst:StopUpdatingComponent(self)
        end
    elseif self.alpha == 1 then
        if self.onconstructcallback ~= nil then
            self.onconstructcallback(self.inst)
        end
        self.inst:StopUpdatingComponent(self)
    end
end

return ProjectedEffects