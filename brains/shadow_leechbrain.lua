require("behaviours/leash")
require("behaviours/faceentity")
require("behaviours/wander")

local JUMP_DIST = 6

local Shadow_LeechBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local function GetTarget(inst)
	return inst.components.entitytracker:GetEntity("daywalker")
end

local function GetTargetPos(inst)
	local target = GetTarget(inst)
	return target ~= nil and target:GetPosition() or nil
end

local function KeepTarget(inst, target)
	return target:IsValid()
end

local function ShouldJump(inst)
	local target = GetTarget(inst)
	return inst:IsNear(target, JUMP_DIST)
end

function Shadow_LeechBrain:OnStart()
	local root = PriorityNode(
	{
		WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "<jump guard>",
			PriorityNode({
				WhileNode(function() return ShouldJump(self.inst) end, "Jump",
					ActionNode(function()
						local target = GetTarget(self.inst)
						if target ~= nil then
							self.inst:PushEvent("jump", target)
							target:PushEvent("incoming_jump", self.inst)
						end
					end)),
				Leash(self.inst, GetTargetPos, 0, 0, true),
				FaceEntity(self.inst, GetTarget, KeepTarget),
				Wander(self.inst),
			}, .5)),
	}, .5)

	self.bt = BT(self.inst, root)
end

return Shadow_LeechBrain
