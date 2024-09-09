local function on_winch_ready(self)
	if self.winch_ready then
		if not self.inst:HasTag("winch_ready") then
			self.inst:AddTag("winch_ready")
		end
	else
		if self.inst:HasTag("winch_ready") then
			self.inst:RemoveTag("winch_ready")
		end
	end
end

local Winch = Class(function(self, inst)
	self.inst = inst

	-- self.onfullyloweredfn = nil
	-- self.onfullyraisedfn = nil
	-- self.onstartloweringfn = nil
	-- self.onstartraisingfn = nil

	-- self.unloadfn = nil

	self.winch_ready = true

    self.line_length = 0
	self.is_raising = false
	self.is_static = true

	self.raising_speed = 1
	self.lowering_speed = .5
end,
nil,
{
	winch_ready = on_winch_ready,
})

function Winch:OnRemoveFromEntity()
    self.inst:RemoveTag("winch_ready")
end


-- function Winch:OnSave()
--     local data =
--     {
-- 		line_length = self.line_length,
-- 		is_raising = self.is_raising,
--     }

-- 	return data
-- end
function Winch:OnSave()
    local data =
    {
		line_length = self.line_length,
		is_raising = self.is_raising,
		is_static = self.is_static,
		winch_ready = self.winch_ready,

		raising_speed = self.raising_speed,
		lowering_speed = self.lowering_speed,
    }

	return data
end

-- function Winch:OnLoad(data)
-- 	if data ~= nil then
-- 		if data.line_length then
-- 			self.line_length = data.line_length

-- 			if self.line_length > 0 then
-- 				self.winch_ready = false

-- 				if data.is_raising then
-- 					self.is_raising = true
-- 					self:StartRaising()
-- 				else
-- 					self.is_raising = false
-- 				end
-- 			else
-- 				self.winch_ready = true
-- 			end
-- 		end
-- 	end
-- end
function Winch:OnLoad(data)
	if data ~= nil then
		self.line_length = data.line_length
		self.is_raising = data.is_raising
		self.is_static = data.is_static
		self.winch_ready = data.winch_ready

		self.raising_speed = data.raising_speed
		self.lowering_speed = data.lowering_speed
	end
end

function Winch:SetLoweringSpeedMultiplier(mult)
	self.lowering_speed = mult
end

function Winch:SetRaisingSpeedMultiplier(mult)
	self.raising_speed = mult
end

function Winch:SetOnFullyLoweredFn(fn)
	self.onfullyloweredfn = fn
end

function Winch:SetOnFullyRaisedFn(fn)
	self.onfullyraisedfn = fn
end

function Winch:SetOnStartRaisingFn(fn)
	self.onstartraisingfn = fn
end

function Winch:SetOnStartLoweringFn(fn)
	self.onstartloweringfn = fn
end

function Winch:SetOverrideGetCurrentDepthFn(fn)
	self.overridegetcurrentdepthfn = fn
end

function Winch:SetUnloadFn(fn)
	self.unloadfn = fn
end

function Winch:GetCurrentDepth()
	if self.overridegetcurrentdepthfn ~= nil then
		return self.overridegetcurrentdepthfn(self.inst) or 0
	else
		local tile = TheWorld.Map:GetTileAtPoint(self.inst.Transform:GetWorldPosition())
		if tile then
			local depthcategory = GetTileInfo(tile).ocean_depth
			return depthcategory and TUNING.ANCHOR_DEPTH_TIMES[depthcategory] or 0
		end
	end

	return 0
end

function Winch:StartRaising(loading_in)
	self:StartDepthTesting(true)

	if self.onstartraisingfn ~= nil then
		self.onstartraisingfn(self.inst)
	end

	self.inst:PushEvent("start_raising_winch", loading_in)
end

function Winch:StartLowering(loading_in)
	self:StartDepthTesting(false)

	if self.onstartloweringfn ~= nil then
		self.onstartloweringfn(self.inst)
	end

	self.inst:PushEvent("start_lowering_winch", loading_in)
	return true
end

function Winch:FullyRaised()
	self.line_length = 0

	self:StopDepthTesting()

	if self.onfullyraisedfn ~= nil then
		self.onfullyraisedfn(self.inst)
	end

	self.inst:PushEvent("winch_fully_raised")
end

function Winch:FullyLowered()
	self.line_length = self:GetCurrentDepth()
	self:StopDepthTesting()

	if self.onfullyloweredfn ~= nil then
		self.onfullyloweredfn(self.inst)
	end

	self.inst:PushEvent("winch_fully_lowered")
end

function Winch:StartDepthTesting(is_raising)
	self.is_static = false
	self.is_raising = is_raising
	self.inst:StartUpdatingComponent(self)
end

function Winch:StopDepthTesting()
	self.is_static = true
	self.is_raising = false
	self.inst:StopUpdatingComponent(self)
end

function Winch:OnUpdate(dt)
	local depth = self:GetCurrentDepth()

	if self.is_raising then
		self.line_length = self.line_length - (dt*self.raising_speed)
		if self.line_length <= 0 then
			self.line_length = 0
			self:FullyRaised()
		end
	else
		self.line_length = self.line_length + (dt*self.lowering_speed)
		if self.line_length >= depth then
			self.line_length = depth
			self:FullyLowered()
		end
	end
end

-- function Winch:GetDebugString()
-- 	return string.format("line_length: %s", self.line_length ~= nil and tostring(self.line_length) or "nil")
-- end

return Winch
