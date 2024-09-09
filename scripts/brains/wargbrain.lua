--------------------------------------------------------------------------
-- *** WARNING ***
--  This brain is also used by warglet, which uses SGhound
--------------------------------------------------------------------------

require "behaviours/standstill"
require "behaviours/chaseandattack"
require "behaviours/leash"
require("behaviours/wander")
local BrainCommon = require("brains/braincommon")

local WargBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    --self.reanimatetime = nil
    --self.petrifytime = nil
end)

local function CanSpawnChild(inst)
    return inst:GetTimeAlive() > 5
        and inst:NumHoundsToSpawn() > 0
        and inst.components.combat:HasTarget()
end

local function TryReanimate(self)
    local player, dsq = self.inst:GetNearestPlayer(true)
    if player == nil or dsq >= 25 then
        self.reanimatetime = nil
    elseif self.reanimatetime == nil then
        self.reanimatetime = GetTime() + 3
    elseif self.reanimatetime == true then
        self.inst:PushEvent("reanimate", { target = player })
    elseif self.reanimatetime < GetTime() then
        self.reanimatetime = true
    end
end

--------------------------------------------------------------------------

local SEE_DIST = 30
local CARCASS_TAGS = { "meat_carcass" }
local CARCASS_NO_TAGS = { "fire" }
function WargBrain:SelectCarcass()
	self.carcass = FindEntity(self.inst, SEE_DIST, nil, CARCASS_TAGS, CARCASS_NO_TAGS)
	return self.carcass ~= nil
end

function WargBrain:CheckCarcass()
	return not (self.carcass.components.burnable ~= nil and self.carcass.components.burnable:IsBurning())
		and self.carcass:IsValid()
		and self.carcass:HasTag("meat_carcass")
end

function WargBrain:GetCarcassPos()
	return self:CheckCarcass() and self.carcass:GetPosition() or nil
end

--------------------------------------------------------------------------

function WargBrain:OnStart()
    local isclay = self.inst:HasTag("clay")
	local ismutated = self.inst:HasTag("lunar_aligned")
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.sg:HasStateTag("intro_state") end, "intro",
            StandStill(self.inst)),

        WhileNode(function() return isclay and self.inst.sg:HasStateTag("statue") end, "Statue",
            ActionNode(function() TryReanimate(self) end, "TryReanimate")),

		IfNode(function() return not ismutated end, "NormalPanic",
			BrainCommon.PanicTrigger(self.inst)),

        MinPeriod(self.inst, TUNING.WARG_SUMMONPERIOD, true,
            IfNode(function() return CanSpawnChild(self.inst) end, "needs follower",
                ActionNode(function()
					if not (self.inst.sg:HasStateTag("howling") or self.inst.sg.mem.dohowl) then
						self.inst.sg:HandleEvent("dohowl")
						if self.inst.sg:HasStateTag("howling") or self.inst.sg.mem.dohowl then
							return SUCCESS
						end
                    end
                    return FAILED
                end, "Summon Hound"))),

		--Eat carcass behaviour
		WhileNode(
			function()
				return not ismutated and (
					not self.inst.components.combat:HasTarget() or
					self.inst.components.combat:GetLastAttackedTime() + TUNING.HOUND_FIND_CARCASS_DELAY < GetTime()
				)
			end,
			"not attacked",
			IfNode(function() return self:SelectCarcass() end, "eat carcass",
				PriorityNode({
					FailIfSuccessDecorator(
						Leash(self.inst,
							function() return self:GetCarcassPos() end,
							function() return self.inst.components.combat:GetHitRange() + self.carcass:GetPhysicsRadius(0) - 0.5 end,
							function() return self.inst.components.combat:GetHitRange() + self.carcass:GetPhysicsRadius(0) - 1 end,
							true)),
					IfNode(function() return self:CheckCarcass() and not self.inst.components.combat:InCooldown() end, "chomp",
						ActionNode(function() self.inst.sg:HandleEvent("chomp", { target = self.carcass }) end)),
					FaceEntity(self.inst,
						function() return self.carcass end,
						function() return self:CheckCarcass() end),
				}, .25))),
		--

        ChaseAndAttack(self.inst),

        IfNode(function() return isclay end, "IsClay",
            ParallelNode{
                LoopNode{
                    WaitNode(3),
                    ActionNode(function() self.inst:PushEvent("becomestatue") end),
                },
                StandStill(self.inst),
            }),

		Wander(self.inst),
    }, .25)

    self.bt = BT(self.inst, root)
end

return WargBrain
