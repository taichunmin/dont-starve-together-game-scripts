local Stats = require("stats")
local easing = require("easing")

local function onsettarget(self, target)
    self.inst.replica.oceanfishingrod:_SetTarget(target)
end

local function onsetlinetension(self, tension)
    self.inst.replica.oceanfishingrod:_SetLineTension(tension)
end

local OceanFishingRod = Class(function(self, inst)
    self.inst = inst

    self.target = nil

	--self.casting_base = TUNING.OCEANFISHING_TACKLE.BASE
	--self.casting_data = deepcopy(TUNING.OCEANFISHING_TACKLE.BASE)
	--self.default_projectile_prefab = nil

	--self.lure_base = TUNING.OCEANFISHING_TACKLE.BASE
	--self.lure_data = TUNING.OCEANFISHING_TACKLE.BASE

	self.gettackledatafn = nil

	self.target_onremove = function(target) if self.target == target then self.target = nil end end

	self.line_dist = nil
	self.line_tension = 0 -- 0 to 1
	self.line_slack = 0 -- 0 to 1

	self.reeling_line_dist = .75
	self.unreel_resistance = 0.1 -- percent of the target's unreel rate to be transfered into self.line_dist

	--self.oncastfn = nil
	--self.ondonefishing = nil
	--self.onhookedsomethingfn = nil
end,
nil,
{
    target = onsettarget,
	line_tension = onsetlinetension,
})

local function TrackFishingStart(self, tackle)
	self.fishing_stats =
	{
		bobber = tackle.bobber ~= nil and tackle.bobber.prefab or "oceanfishingbobber_none",
		lure = tackle.lure ~= nil and tackle.lure.prefab or "emptyhook",
		cast_time = GetTime(),
	}
end

local function TrackFishingHookedSomething(self)
	if self.fishing_stats ~= nil and self.fishing_stats.cast_time ~= nil and self.fishing_stats.wait_time == nil then
		self.fishing_stats.phase = TheWorld.state.phase or "unknown"
		self.fishing_stats.wait_time = GetTime() - self.fishing_stats.cast_time
	end
end

local function TrackFishingDone(self, reason)
	if self.fishing_stats ~= nil and self.fisher ~= nil then
		self.fishing_stats.result = reason or "unknown"
		self.fishing_stats.target = (self.target ~= nil and self.target.components.oceanfishinghook == nil and not self.target:HasTag("projectile")) and self.target.prefab or "none"
		self.fishing_stats.isafish = self.target ~= nil and self.target:HasTag("oceanfish")
		self.fishing_stats.weight = (self.target ~= nil and self.target.components.weighable ~= nil) and self.target.components.weighable:GetWeight() or 0

		TrackFishingHookedSomething(self)
		self.fishing_stats.catch_time = math.max(0, GetTime() - (self.fishing_stats.cast_time + (self.fishing_stats.wait_time or 0)))

		self.fishing_stats.cast_time = nil
		Stats.PushMetricsEvent("fishing", self.fisher, {fishing = self.fishing_stats})
		self.fishing_stats = nil
	end
end

function OceanFishingRod:_LaunchCastingProjectile(source, targetpos, prefab)
	source:ForceFacePoint(targetpos:Get())

	local x, y, z = source.Transform:GetWorldPosition()
    local projectile = SpawnPrefab(prefab)
    projectile.Transform:SetPosition(x, y, z)

	ApplyBobberSkin( projectile.nameoverride, self.inst.skin_build_name, projectile.AnimState, self.inst.GUID )

	local t = math.min(VecUtil_Length(targetpos.x - x,  targetpos.z - z) / (TUNING.OCEAN_FISHING.MAX_CAST_DIST), 1.0)
    projectile.components.complexprojectile:SetHorizontalSpeed(Lerp(8, 16, t))
    projectile.components.complexprojectile:SetGravity(Lerp(-30, -15, t))
    projectile.components.complexprojectile:SetLaunchOffset(Vector3(.75, 4.5, 0))
    projectile.components.complexprojectile:Launch(targetpos, source, self.inst)

	return projectile
end

function OceanFishingRod:_LaunchFishProjectile(projectile, srcpos, targetpos)
    projectile.Transform:SetPosition(srcpos:Get())
	projectile:ForceFacePoint(targetpos:Get())

    projectile.components.complexprojectile:SetHorizontalSpeed(12)
    projectile.components.complexprojectile:SetGravity(-30)
    projectile.components.complexprojectile:SetLaunchOffset(Vector3(0, 0.5, 0))
    projectile.components.complexprojectile:SetTargetOffset(Vector3(0, 0.2, 0))
    projectile.components.complexprojectile:Launch(targetpos, projectile)

	return projectile
end

function OceanFishingRod:SetDefaults(default_projectile_prefab, default_casting_tuning, default_lure_tuning, default_lure_setup)
	self.default_projectile_prefab = default_projectile_prefab
	self.projectile_prefab = default_projectile_prefab
	self.casting_base = default_casting_tuning
	self.casting_data = deepcopy(default_casting_tuning)
	self.lure_base = default_lure_tuning
	self.lure_data = default_lure_tuning
	self.default_lure_setup = default_lure_setup
	self.lure_setup = default_lure_setup

	self:UpdateClientMaxCastDistance()
end

function OceanFishingRod:GetLureData()
	return self.lure_data
end

function OceanFishingRod:GetLureFunctions()
	return self.lure_setup.fns
end

function OceanFishingRod:UpdateClientMaxCastDistance()
	if self.inst.replica.oceanfishingrod ~= nil then
		local tackle = self.gettackledatafn ~= nil and self.gettackledatafn(self.inst) or {}
		local bobber_data = (tackle.bobber ~= nil and tackle.bobber.components.oceanfishingtackle ~= nil) and tackle.bobber.components.oceanfishingtackle.casting_data or nil
		local lure_data = (tackle.lure ~= nil and tackle.lure.components.oceanfishingtackle ~= nil) and tackle.lure.components.oceanfishingtackle.lure_data or nil

		self.inst.replica.oceanfishingrod:SetClientMaxCastDistance(math.max(0, self.casting_base.dist_max + (bobber_data ~= nil and bobber_data.dist_max or 0) + (lure_data ~= nil and lure_data.dist_max or 0)))
	end
end

function OceanFishingRod:_CacheTackleData(bobber, lure)
	local bobber_data = (bobber ~= nil and bobber.components.oceanfishingtackle ~= nil) and bobber.components.oceanfishingtackle.casting_data or nil
	local lure_data = (lure ~= nil and lure.components.oceanfishingtackle ~= nil) and lure.components.oceanfishingtackle.lure_data or nil

	for k, _ in pairs(self.casting_base) do
		self.casting_data[k] = math.max(0, self.casting_base[k] + (bobber_data ~= nil and bobber_data[k] or 0) + (lure_data ~= nil and lure_data[k] or 0))
	end

	self.projectile_prefab = (bobber ~= nil and bobber.components.oceanfishingtackle) and bobber.components.oceanfishingtackle.projectile_prefab or self.default_projectile_prefab

	self.lure_data = lure_data or self.lure_base
	self.lure_setup = (lure ~= nil and lure.components.oceanfishingtackle) and lure.components.oceanfishingtackle.lure_setup or self.default_lure_setup
end

function OceanFishingRod:_CalcCastDest(src_pos, dest_pos)
	local cast_vect = dest_pos - src_pos
	local cast_dist = math.min(cast_vect:Length(), self.casting_data.dist_max)

	local cast_dist_accuracy = math.random() * (self.casting_data.dist_max_accuracy - self.casting_data.dist_min_accuracy) + self.casting_data.dist_min_accuracy
	cast_dist = math.max(2, cast_dist * cast_dist_accuracy)

	local theta = math.random() * 2 - 1
	theta = theta * theta * theta * self.casting_data.max_angle_offset / RADIANS + math.atan2(cast_vect.z, cast_vect.x)
	cast_vect.x = cast_dist * math.cos(theta)
	cast_vect.z = cast_dist * math.sin(theta)

	return src_pos + cast_vect
end

function OceanFishingRod:Cast(fisher, targetpos)
	local tackle = self.gettackledatafn(self.inst)
	self:_CacheTackleData(tackle.bobber, tackle.lure)

	TrackFishingStart(self, tackle)

	targetpos = self:_CalcCastDest(self.inst:GetPosition(), targetpos)
    self.fisher = fisher
	self:SetTarget(self:_LaunchCastingProjectile(fisher, targetpos, self.projectile_prefab))
	if self.target ~= nil and self.lure_setup ~= nil and self.lure_setup.build ~= nil and self.lure_setup.symbol ~= nil then
		self.target.AnimState:OverrideSymbol("lure", self.lure_setup.build, self.lure_setup.symbol)
	end

    self.inst:StartUpdatingComponent(self)

	if self.oncastfn ~= nil then
		self.oncastfn(self.inst, fisher, self.target)
	end

	return self.target ~= nil
end

function OceanFishingRod:GetTensionRating()
	return self.line_tension
end

function OceanFishingRod:IsLineTensionHigh()
	return self.line_tension > TUNING.OCEAN_FISHING.LINE_TENSION_HIGH
end

function OceanFishingRod:IsLineTensionGood()
	return self.line_tension > TUNING.OCEAN_FISHING.LINE_TENSION_GOOD and self.line_tension <= TUNING.OCEAN_FISHING.LINE_TENSION_HIGH
end

function OceanFishingRod:IsLineTensionLow()
	return self.line_tension <= TUNING.OCEAN_FISHING.LINE_TENSION_GOOD
end

function OceanFishingRod:UpdateTensionRating()
	if self.target ~= nil and self.line_dist ~= nil then
		local fishing_dir = self.target:GetPosition() - self.inst:GetPosition()
		local max_tension_rating = 1
		if self.target.components.locomotor ~= nil then
			-- don't have high tension if target is moving toward the fisher
            local target_rot = self.target.Transform:GetRotation() * DEGREES
            local target_forward_x, target_forward_z = math.cos(target_rot), -math.sin(target_rot)
			if VecUtil_Dot(target_forward_x, target_forward_z, fishing_dir.x, fishing_dir.z) <= 0 then
				max_tension_rating = TUNING.OCEAN_FISHING.LINE_TENSION_HIGH
			end
		end
		local target_dist = fishing_dir:Length()

		local max_offset = 3
		local tension_offset = target_dist - self.line_dist
		self.line_tension = tension_offset > 0 and math.min(max_tension_rating, (1 + 1/max_offset) - (1 + 1/max_offset)/(tension_offset + 1)) or 0
		self.line_slack = tension_offset < 0 and math.min(1, (1 + 1/max_offset) - (1 + 1/max_offset)/(1 - tension_offset)) or 0
	else
		self.line_tension = 0
		self.line_slack = 0
	end
end

function OceanFishingRod:Reel()
	if self.target ~= nil and self.target.components.oceanfishable ~= nil and self.fisher and self.fisher:IsValid() then
		local dir = self.fisher:GetPosition() - self.target:GetPosition()
		local len = dir:Length()

		self.target.components.oceanfishable:OnReelingIn(self.fisher)

		local was_high_tension = self:IsLineTensionHigh()
		if self.line_dist ~= nil then
			local reel_in_dist = self.target.components.locomotor ~= nil and (self.reeling_line_dist * (1 - self.line_tension)) or self.reeling_line_dist
			self.line_dist = math.max(0, self.line_dist - reel_in_dist)
			self:UpdateTensionRating()
		end

		local target = self.target
		local snapped = self.line_tension >= TUNING.OCEAN_FISHING.REELING_SNAP_TENSION and was_high_tension
		if snapped then
			self:StopFishing("linesnapped", true)
		end

		if target ~= nil then
			target.components.oceanfishable:OnReelingInPst(self.fisher)
		end

		return not snapped
	end

	return false
end

function OceanFishingRod:SetTarget(new_target)
	if self.target ~= new_target then
		local prev_target = self.target
		self.target = new_target
		self.line_dist = nil
		self.line_tension = 0
		self.line_slack = 0
		if prev_target ~= nil then
			self.inst:RemoveEventCallback("onremove", self.target_onremove, prev_target)
			if prev_target.components.oceanfishable ~= nil then
				if new_target ~= nil then
					if self.target ~= nil and self.target.components.oceanfishinghook == nil and not self.target:HasTag("projectile") then
						TrackFishingHookedSomething(self)
					end
					prev_target.components.oceanfishable:WasEatenByA(new_target) -- this will call prev_target:Remove()
				else
					prev_target.components.oceanfishable:SetRod(nil)
				end
			end
		end
		if self.target ~= nil then
			if not self.target:HasTag("projectile") then
				self.line_dist = (self.target:GetPosition() - self.inst:GetPosition()):Length()
			end
			self:UpdateTensionRating()

			self.inst:ListenForEvent("onremove", self.target_onremove, self.target)

			if self.onnewtargetfn ~= nil then
				self.onnewtargetfn(self.inst, new_target)
			end

			if self.target.components.oceanfishable ~= nil then
				self.target.components.oceanfishable:SetRod(self.inst)
			end

			if self.fisher ~= nil then
				self.fisher:PushEvent("newfishingtarget", {prev = prev_target, target = new_target})
			end
		end
	end
end

function OceanFishingRod:OnUpdate(dt)
    if not self.fisher:IsValid() or self.target == nil then
		self:StopFishing()
    elseif (not self.inst.components.equippable or not self.inst.components.equippable.isequipped)
		or (not self.fisher.sg:HasStateTag("fishing") and not self.fisher.sg:HasStateTag("npc_fishing") and not self.fisher.sg:HasStateTag("catchfish")) then

		local has_fish = self.target.components.oceanfishinghook == nil and not self.target:HasTag("projectile")
		self:StopFishing("interupted", has_fish)
	elseif not self.inst:IsNear(self.target, TUNING.OCEAN_FISHING.MAX_HOOK_DIST) then
		self:StopFishing("toofaraway", true)
	else
		if self.target ~= nil then
			self.fisher:ForceFacePoint(self.target.Transform:GetWorldPosition())
			self:UpdateTensionRating()

			if self.target.components.oceanfishable ~= nil then
				if self.line_tension >= TUNING.OCEAN_FISHING.START_UNREELING_TENSION then
					local line_unreel_rate = self.target.components.oceanfishable ~= nil and self.target.components.oceanfishable:CalcLineUnreelRate(self.inst) or 0
					if line_unreel_rate > 0 then
						self.line_dist = self.line_dist + dt * line_unreel_rate * (1 - self.unreel_resistance)
					end
				elseif self.line_slack >= 1 and self.target.components.oceanfishinghook == nil then
					self:StopFishing("linetooloose")
				end
			end
		end
    end
end

function OceanFishingRod:CalcCatchDest(src_pos, dest_pos, catch_dist)
	local catch_vect = dest_pos - src_pos
	return src_pos + catch_vect:GetNormalized() * (math.min(catch_dist, catch_vect:Length()) + (math.random()*1 + .5))
end

function OceanFishingRod:CatchFish()
    self.inst:StopUpdatingComponent(self)

	if self.target ~= nil and self.target.components.oceanfishable ~= nil then
		TrackFishingDone(self, "success")

		local targetpos = self:CalcCatchDest(self.target:GetPosition(), self.fisher:GetPosition(), self.target.components.oceanfishable.catch_distance)
		local startpos = self.target:GetPosition()
		local fish = self.target.components.oceanfishable:MakeProjectile()
		if fish.components.weighable ~= nil then
			fish.components.weighable:SetPlayerAsOwner(self.fisher)
		end
		self:_LaunchFishProjectile(fish, startpos, targetpos)

		if self.ondonefishing ~= nil then
			self.ondonefishing(self.inst, "success", false, self.fisher, fish)
		end

		self:SetTarget(nil)
	else
		self:StopFishing()
	end
end

function OceanFishingRod:StopFishing(reason, lost_tackle)
    self.inst:StopUpdatingComponent(self)

	if self.ondonefishing ~= nil then
		self.ondonefishing(self.inst, reason, lost_tackle, self.fisher, self.target)
	end
	if self.fisher ~= nil then
		TrackFishingDone(self, reason)
		self.fisher:PushEvent("oceanfishing_stoppedfishing", {reason = reason, rod = self.inst, fisher = self.fisher, target = self.target})
	end
	if self.target ~= nil then
		self.target:PushEvent("oceanfishing_stoppedfishing", {reason = reason, rod = self.inst, fisher = self.fisher, target = self.target})
	end

	self.fisher = nil
	self:SetTarget(nil)
end

function OceanFishingRod:GetExtraStaminaDrain()
	return self.lure_data.stamina_drain or 0
end

function OceanFishingRod:GetDebugString()
    local str = "Target: " .. tostring(self.target) .. string.format(", Tension: %0.3f (%0.2f / %0.2f)", self.line_tension > 0 and self.line_tension or -self.line_slack, self.target ~= nil and (self.inst:GetPosition() - self.target:GetPosition()):Length() or 0,  self.line_dist or 0)

	if self.inst.components.container ~= nil then
		local bobber = self.inst.components.container.slots[1]
		local lure = self.inst.components.container.slots[2]

		local b_data = (bobber ~= nil and bobber.components.oceanfishingtackle ~= nil) and bobber.components.oceanfishingtackle.casting_data or {}
		local l_data = (lure ~= nil and lure.components.oceanfishingtackle ~= nil) and lure.components.oceanfishingtackle.lure_data or {}

		local bobber_str = "  Bobber: " .. (bobber ~= nil and bobber.prefab or "nil")
		local lure_str = "  Lure: " .. (lure ~= nil and lure.prefab or "nil")

		for k, _ in pairs(self.casting_base) do
			bobber_str = bobber_str .. ", " .. tostring(k) .. "=" .. tostring(self.casting_data[k] or 0)
		end

		for k, data in pairs(self.lure_data) do
			if type(data) == "table" then
				for k2, data2 in pairs(data) do
					lure_str = lure_str .. ", " .. tostring(k2) .. "=" .. tostring(data2 or 0)
				end
			else
				lure_str = lure_str .. ", " .. tostring(k) .. "=" .. tostring(data or 0)
			end
		end

		str = str .. "\n" .. bobber_str .. "\n" .. lure_str
	end
    return str
end

return OceanFishingRod