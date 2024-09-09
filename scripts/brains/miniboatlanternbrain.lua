require "behaviours/wander"

local WANDER_TIMES = {minwalktime=1, randwalktime=0.25, minwaittime=0.0, randwaittime=0.0}

local function getdirectionFn(inst)
	local r = math.random() * 2 - 1
	return (inst.Transform:GetRotation() + r*r*r * 40) * DEGREES
end

local function ShouldMove(inst)
	return TheWorld.Map:IsOceanAtPoint(inst.Transform:GetWorldPosition()) and inst.components.fueled ~= nil and not inst.components.fueled:IsEmpty()
end

local MiniBoatLanternBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MiniBoatLanternBrain:OnStart()
    local root = PriorityNode(
    {
		WhileNode(function() return ShouldMove(self.inst) end, "ShouldMove",
            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, TUNING.MINIBOATLANTERN_WANDER_DIST, WANDER_TIMES, getdirectionFn)),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

function MiniBoatLanternBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end

return MiniBoatLanternBrain
