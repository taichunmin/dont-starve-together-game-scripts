local GroundPounder = Class(function(self, inst)
    self.inst = inst

    self.numRings = 4
    self.ringDelay = 0.2
    self.initialRadius = 1
    self.radiusStepDistance = 4
	self.ringWidth = 3
    self.pointDensity = .25
    self.damageRings = 2
    self.destructionRings = 3
    self.platformPushingRings = 2
	--self.fxRings = nil --default to numRings
	--self.fxRadiusOffset = 0 --ONLY supported for RingMode
    self.inventoryPushingRings = 0
    self.noTags = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
    self.workefficiency = nil
    self.destroyer = false
    self.burner = false
    self.groundpoundfx = "groundpound_fx"
    self.groundpoundringfx = "groundpoundring_fx"
    self.groundpounddamagemult = 1
    self.groundpoundFn = nil

    self.usePointMode = true --deprecated, but default for mod backward compatibility

	--RingMode changes:
	--  -Entity searches by concentric rings instead of multiple points around each ring.
	--  -Damage range is not limited by combat attack range.
	--  -Cannot hit the same target more than once, even if it's different rings.
end)

function GroundPounder:UseRingMode()
	self.usePointMode = nil
end

function GroundPounder:GetPoints(pt)
    local points = {}
    local radius = self.initialRadius
	local radiusOffset = not self.usePointMode and self.fxRadiusOffset or 0

    for i = 1, self.numRings do
		local r = math.max(0, radius + radiusOffset)
		local numPoints = math.floor(TWOPI * r * self.pointDensity)
		if i == 1 and numPoints <= 4 then
			numPoints = 1
		end

        if not points[i] then
            points[i] = {}
        end

		if numPoints > 1 then
			for p = 1, numPoints do
				local theta = (TWOPI / numPoints) * p
				local x = pt.x + r * math.cos(theta)
				local z = pt.z + r * math.sin(theta)
				local point = Vector3(x, 0, z)

				table.insert(points[i], point)
			end
		else
			table.insert(points[i], Vector3(pt.x, 0, pt.z))
		end

        radius = radius + self.radiusStepDistance
    end

    return points
end

local WALKABLEPLATFORM_TAGS = {"walkableplatform"}

--Deprecated
function GroundPounder:DestroyPoints(points, breakobjects, dodamage, pushplatforms, pushinventoryitems, spawnfx)
    local getEnts = breakobjects or dodamage or pushinventoryitems
    local map = TheWorld.Map
    if dodamage then
        self.inst.components.combat:EnableAreaDamage(false)
    end
    local ents_hit = {}
    local platforms_hit = {}
    for k, v in pairs(points) do
        if getEnts then
            local ents = TheSim:FindEntities(v.x, v.y, v.z, self.ringWidth, nil, self.noTags)
            if #ents > 0 then
                if breakobjects then
                    for i, v2 in ipairs(ents) do
                        if v2 ~= self.inst and v2:IsValid() then
                            -- Don't net any insects when we do work
                            if (self.destroyer or self.workefficiency ~= nil) and
                                v2.components.workable ~= nil and
                                v2.components.workable:CanBeWorked() and
                                v2.components.workable.action ~= ACTIONS.NET
                            then
                                if self.workefficiency ~= nil then
                                    v2.components.workable:WorkedBy(self.inst, self.workefficiency)
                                else
                                    v2.components.workable:Destroy(self.inst)
                                end
                            end
                            if v2:IsValid() and --might've changed after work?
                                not v2:IsInLimbo() and --might've changed after work?
                                self.burner and
                                v2.components.fueled == nil and
                                v2.components.burnable ~= nil and
                                not v2.components.burnable:IsBurning() and
                                not v2:HasTag("burnt") then
                                v2.components.burnable:Ignite()
                            end
                        end
                    end
                end
                if dodamage then
                    for i, v2 in ipairs(ents) do
                        if v2 ~= self.inst and 
                            not ents_hit[v2] and
                            v2:IsValid() and
                            v2.components.health ~= nil and
                            not v2.components.health:IsDead() and
                            self.inst.components.combat:CanTarget(v2) then
                            ents_hit[v2] = true
                            self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
                        end
                    end
                end
                if pushinventoryitems then
                    for _, object in ipairs(ents) do
                        local inventoryitem = object.components.inventoryitem
                        if inventoryitem then
                            Launch(object, self.inst)
                            inventoryitem:SetLanded(false, true)
                        end
                    end
                end
            end
        end

        if pushplatforms then
            local platform_ents = TheSim:FindEntities(v.x, v.y, v.z, self.ringWidth + TUNING.MAX_WALKABLE_PLATFORM_RADIUS, WALKABLEPLATFORM_TAGS, self.noTags)
            for i, p_ent in ipairs(platform_ents) do
                if p_ent ~= self.inst
                        and not platforms_hit[p_ent]
                        and p_ent:IsValid()
                        and p_ent.Transform
                        and p_ent.components.boatphysics then
                    local v2x, v2y, v2z = p_ent.Transform:GetWorldPosition()
                    local mx, mz = v2x - v.x, v2z - v.z
                    if mx ~= 0 or mz ~= 0 then
                        platforms_hit[p_ent] = true
                        local normalx, normalz = VecUtil_Normalize(mx, mz)
                        p_ent.components.boatphysics:ApplyForce(normalx, normalz, 3)
                    end
                end
            end
        end

		if spawnfx and map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
            SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
        end
    end
    if dodamage then
        self.inst.components.combat:EnableAreaDamage(true)
    end
end

function GroundPounder:DestroyRing(pt, radius, points, breakobjects, dodamage, pushplatforms, pushinventoryitems, spawnfx, ents_hit, platforms_hit)
	local getEnts = breakobjects or dodamage or pushinventoryitems
	local map = TheWorld.Map
	if dodamage then
		self.inst.components.combat:EnableAreaDamage(false)
		self.inst.components.combat.ignorehitrange = true
	end
	ents_hit = ents_hit or {}
	platforms_hit = platforms_hit or {}

	if getEnts then
		local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, radius + self.ringWidth, nil, self.noTags)
		if #ents > 0 then
			local i0
			local min_range_sq = math.max(0, radius - self.ringWidth)
			min_range_sq = min_range_sq * min_range_sq
			for i, v2 in ipairs(ents) do
				if v2:GetDistanceSqToPoint(pt) >= min_range_sq then
					i0 = i
					break
				end
			end
			if i0 ~= nil then
				if breakobjects then
					for i = i0, #ents do
						local v2 = ents[i]
						if v2 ~= self.inst and v2:IsValid() then
							-- Don't net any insects when we do work
							if (self.destroyer or self.workefficiency ~= nil) and
								v2.components.workable ~= nil and
								v2.components.workable:CanBeWorked() and
								v2.components.workable.action ~= ACTIONS.NET
							then
								if self.workefficiency ~= nil then
									v2.components.workable:WorkedBy(self.inst, self.workefficiency)
								else
									v2.components.workable:Destroy(self.inst)
								end
							end
							if v2:IsValid() and --might've changed after work?
								not v2:IsInLimbo() and --might've changed after work?
								self.burner and
								v2.components.fueled == nil and
								v2.components.burnable ~= nil and
								not v2.components.burnable:IsBurning() and
								not v2:HasTag("burnt") then
								v2.components.burnable:Ignite()
							end
						end
					end
				end
				if dodamage then
					for i = i0, #ents do
						local v2 = ents[i]
						if v2 ~= self.inst and 
							not ents_hit[v2] and
							v2:IsValid() and
							v2.components.health ~= nil and
							not v2.components.health:IsDead() and
							self.inst.components.combat:CanTarget(v2) then
							ents_hit[v2] = true
							self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
						end
					end
				end
				if pushinventoryitems then
					for i = i0, #ents do
						local object = ents[i]
						local inventoryitem = object.components.inventoryitem
						if inventoryitem then
							Launch(object, self.inst)
							inventoryitem:SetLanded(false, true)
						end
					end
				end
			end
		end
	end

	if pushplatforms then
		local platform_radius = self.ringWidth + TUNING.MAX_WALKABLE_PLATFORM_RADIUS
		local platform_ents = TheSim:FindEntities(pt.x, pt.y, pt.z, radius + platform_radius, WALKABLEPLATFORM_TAGS, self.noTags)
		local i0
		local min_range_sq = math.max(0, radius - platform_radius)
		min_range_sq = min_range_sq * min_range_sq
		for i, v2 in ipairs(platform_ents) do
			if v2:GetDistanceSqToPoint(pt) >= min_range_sq then
				i0 = i
				break
			end
		end
		if i0 ~= nil then
			for i = i0, #platform_ents do
				local p_ent = platform_ents[i]
				if p_ent ~= self.inst
						and not platforms_hit[p_ent]
						and p_ent:IsValid()
						and p_ent.Transform
						and p_ent.components.boatphysics then
					local v2x, v2y, v2z = p_ent.Transform:GetWorldPosition()
					local mx, mz = v2x - pt.x, v2z - pt.z
					if mx ~= 0 or mz ~= 0 then
						platforms_hit[p_ent] = true
						local normalx, normalz = VecUtil_Normalize(mx, mz)
						p_ent.components.boatphysics:ApplyForce(normalx, normalz, 3)
					end
				end
			end
		end
	end

	if spawnfx then
		for i, v in ipairs(points) do
			if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
				SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
			end
		end
	end

	if dodamage then
		self.inst.components.combat:EnableAreaDamage(true)
		self.inst.components.combat.ignorehitrange = false
	end
end

--Deprecated
local function OnDestroyPoints(inst, self, points, breakobjects, dodamage, pushplatforms, pushinventoryitems, spawnfx)
	self:DestroyPoints(points, breakobjects, dodamage, pushplatforms, pushinventoryitems, spawnfx)
end

local function OnDestroyRing(inst, self, pt, radius, points, breakobjects, dodamage, pushplatforms, pushinventoryitems, spawnfx, ents_hit, platforms_hit)
	self:DestroyRing(pt, radius, points, breakobjects, dodamage, pushplatforms, pushinventoryitems, spawnfx, ents_hit, platforms_hit)
end

function GroundPounder:GroundPound(pt, ents_hit)
    pt = pt or self.inst:GetPosition()

	local fx = SpawnPrefab(self.groundpoundringfx)
	fx.Transform:SetPosition(pt.x, 0, pt.z)

	--auto-scaling hitbox radius if it's the default fx
	if not self.usePointMode and self.groundpoundringfx == "groundpoundring_fx" then
		local hitrings = math.min(self.numRings, math.max(self.damageRings, self.destructionRings))
		local hitradius = self.initialRadius + self.radiusStepDistance * math.max(0, hitrings - 1) + self.ringWidth
		local fxscale = math.sqrt(hitradius / 12) --art radius is 12; sqrt coz of transform scale bug
		fx.Transform:SetScale(fxscale, fxscale, fxscale)
		if hitrings <= 2 and fx.FastForward ~= nil then
			fx:FastForward()
		end
	end

    local points = self:GetPoints(pt)
    local delay = 0
	local radius = self.initialRadius
	local platforms_hit = {}
	if ents_hit == nil then
		ents_hit = {}
	end
    for i = 1, self.numRings do
		if self.usePointMode then
			--Deprecated
			self.inst:DoTaskInTime(
				delay, OnDestroyPoints,
				self, points[i],
				i <= self.destructionRings,
				i <= self.damageRings,
				i <= self.platformPushingRings,
				i <= self.inventoryPushingRings,
				i <= (self.fxRings or self.numRings)
			)
		else
			self.inst:DoTaskInTime(
				delay, OnDestroyRing,
				self, pt, radius, points[i],
				i <= self.destructionRings,
				i <= self.damageRings,
				i <= self.platformPushingRings,
				i <= self.inventoryPushingRings,
				i <= (self.fxRings or self.numRings),
				ents_hit,
				platforms_hit
			)
		end
		radius = radius + self.radiusStepDistance
        delay = delay + self.ringDelay
    end

    if self.groundpoundFn then
        self.groundpoundFn(self.inst)
    end
end

-- Note(DiogoW): I don't think this is working as expected.
--@V2C: this is deprecated and unused. code is probalby just kept around for mods
function GroundPounder:GroundPound_Offscreen(position)
    self.inst.components.combat:EnableAreaDamage(false)

    local breakobjectsRadius = self.initialRadius + (self.destructionRings - 1) * self.radiusStepDistance
    local dodamageRadius = self.initialRadius + (self.damageRings - 1) * self.radiusStepDistance
    local breakobjectsRadiusSQ = breakobjectsRadius * breakobjectsRadius

    local ents = TheSim:FindEntities(position.x, position.y, position.z, dodamageRadius, nil, self.noTags)
    for i, v in ipairs(ents) do
        if v ~= self.inst and v:IsValid() and not v:IsInLimbo() then
            if v:GetDistanceSqToPoint(position:Get()) < breakobjectsRadiusSQ then
                if (self.destroyer or self.workefficiency ~= nil) and
                    v.components.workable and
                    v.components.workable:CanBeWorked() and
                    v.components.workable.action ~= ACTIONS.NET
                then
                    if self.workefficiency ~= nil then
                        v.components.workable:WorkedBy(self.inst, self.workefficiency)
                    else
                        v.components.workable:Destroy(self.inst)
                    end
                end
                if v:IsValid() and
                        not v:IsInLimbo() and
                        self.burner and
                        not v.components.fueled and
                        v.components.burnable and
                        not v.components.burnable:IsBurning() and
                        not v:HasTag("burnt") then
                    v.components.burnable:Ignite()
                end
            elseif v.components.health and
                    not v.components.health:IsDead() and
                    self.inst.components.combat:CanTarget(v) then
                self.inst.components.combat:DoAttack(v, nil, nil, nil, self.groundpounddamagemult)
            end
        end
    end

    if self.platformPushingRings > 0 then
        local platformPushRadius = self.initialRadius + (self.platformPushingRings - 1) * self.radiusStepDistance
        local platformEnts = TheSim:FindEntities(position.x, position.y, position.z, platformPushRadius + TUNING.MAX_WALKABLE_PLATFORM_RADIUS, WALKABLEPLATFORM_TAGS, self.noTags)
        for i, p_ent in ipairs(platform_ents) do
            if p_ent ~= self.inst and p_ent:IsValid() and p_ent.Transform and p_ent.components.boatphysics then
                local v2x, v2y, v2z = p_ent.Transform:GetWorldPosition()
                local mx, mz = v2x - v.x, v2z - v.z
                if mx ~= 0 or mz ~= 0 then
                    local normalx, normalz = VecUtil_Normalize(mx, mz)
                    p_ent.components.boatphysics:ApplyForce(normalx, normalz, 3)
                end
            end
        end
    end

    self.inst.components.combat:EnableAreaDamage(true)
end

function GroundPounder:GetDebugString()
    return string.format("num rings: %d, damage rings: %d, destruction rings: %d, boat pushing rings: %d, inventory pushing rings: %d",
        self.numRings,
        self.damageRings,
        self.destructionRings,
        self.platformPushingRings,
        self.inventoryPushingRings
    )
end

return GroundPounder
