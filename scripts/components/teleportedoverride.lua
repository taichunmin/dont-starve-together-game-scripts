

local TeleportedOverride = Class(function(self, inst)
	self.inst = inst
end)

function TeleportedOverride:GetDestTarget()
	return self.target_fn ~= nil and self.target_fn(self.inst) or nil
end

function TeleportedOverride:SetDestTargetFn(fn)
	self.target_fn = fn
end

function TeleportedOverride:GetDestPosition()
	return self.pos_fn ~= nil and self.pos_fn(self.inst) or nil
end

function TeleportedOverride:SetDestPositionFn(fn)
	self.pos_fn = fn
end


return TeleportedOverride