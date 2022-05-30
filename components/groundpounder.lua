local GroundPounder = Class(function(self, inst)
    self.inst = inst

    self.numRings = 4
    self.ringDelay = 0.2
    self.initialRadius = 1
    self.radiusStepDistance = 4
    self.pointDensity = .25
    self.damageRings = 2
    self.destructionRings = 3
    self.platformPushingRings = 2
    self.noTags = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
    self.destroyer = false
    self.burner = false
    self.groundpoundfx = "groundpound_fx"
    self.groundpoundringfx = "groundpoundring_fx"
    self.groundpounddamagemult = 1
    self.groundpoundFn = nil
end)

function GroundPounder:GetPoints(pt)
    local points = {}
    local radius = self.initialRadius

    for i = 1, self.numRings do
        local theta = 0
        local circ = 2*PI*radius
        local numPoints = circ * self.pointDensity
        for p = 1, numPoints do

            if not points[i] then
                points[i] = {}
            end

            local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
            local point = pt + offset

            table.insert(points[i], point)

            theta = theta - (2*PI/numPoints)
        end

        radius = radius + self.radiusStepDistance

    end
    return points
end

local WALKABLEPLATFORM_TAGS = {"walkableplatform"}

function GroundPounder:DestroyPoints(points, breakobjects, dodamage, pushplatforms)
    local getEnts = breakobjects or dodamage
    local map = TheWorld.Map
    if dodamage then
        self.inst.components.combat:EnableAreaDamage(false)
    end
    local ents_hit = {}
    local platforms_hit = {}
    for k, v in pairs(points) do
        if getEnts then
            local ents = TheSim:FindEntities(v.x, v.y, v.z, 3, nil, self.noTags)
            if #ents > 0 then
                if breakobjects then
                    for i, v2 in ipairs(ents) do
                        if v2 ~= self.inst and v2:IsValid() then
                            -- Don't net any insects when we do work
                            if self.destroyer and
                                v2.components.workable ~= nil and
                                v2.components.workable:CanBeWorked() and
                                v2.components.workable.action ~= ACTIONS.NET then
                                v2.components.workable:Destroy(self.inst)
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
            end
        end

        if pushplatforms then
            local platform_ents = TheSim:FindEntities(v.x, v.y, v.z, 3 + TUNING.MAX_WALKABLE_PLATFORM_RADIUS, WALKABLEPLATFORM_TAGS, self.noTags)
            for i, p_ent in ipairs(platform_ents) do
                if p_ent ~= self.inst
                    and not platforms_hit[p_ent] 
                    and p_ent:IsValid() 
                    and p_ent.Transform ~= nil 
                    and p_ent.components.boatphysics ~= nil then
                    local v2x, v2y, v2z = p_ent.Transform:GetWorldPosition()
                    local mx, mz = v2x - v.x, v2z - v.z
                    if mx ~= 0 or mz ~= 0 then
                        ents_hit[p_ent] = true
                        local normalx, normalz = VecUtil_Normalize(mx, mz)
                        p_ent.components.boatphysics:ApplyForce(normalx, normalz, 3)
                    end
                end
            end
        end

        if map:IsPassableAtPoint(v:Get()) then
            SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
        end
    end
    if dodamage then
        self.inst.components.combat:EnableAreaDamage(true)
    end
end

local function OnDestroyPoints(inst, self, points, breakobjects, dodamage, pushplatforms)
    self:DestroyPoints(points, breakobjects, dodamage, pushplatforms)
end

function GroundPounder:GroundPound(pt)
    pt = pt or self.inst:GetPosition()
    SpawnPrefab(self.groundpoundringfx).Transform:SetPosition(pt:Get())
    local points = self:GetPoints(pt)
    local delay = 0
    for i = 1, self.numRings do
        self.inst:DoTaskInTime(delay, OnDestroyPoints, self, points[i], i <= self.destructionRings, i <= self.damageRings, i <= self.platformPushingRings)
        delay = delay + self.ringDelay
    end

    if self.groundpoundFn ~= nil then
        self.groundpoundFn(self.inst)
    end
end

function GroundPounder:GroundPound_Offscreen(position)
    self.inst.components.combat:EnableAreaDamage(false)

    local breakobjectsRadius = self.initialRadius + (self.destructionRings - 1) * self.radiusStepDistance
    local dodamageRadius = self.initialRadius + (self.damageRings - 1) * self.radiusStepDistance
    local breakobjectsRadiusSQ = breakobjectsRadius * breakobjectsRadius

    local ents = TheSim:FindEntities(position.x, position.y, position.z, dodamageRadius, nil, self.noTags)
    for i, v in ipairs(ents) do
        if v ~= self.inst and v:IsValid() and not v:IsInLimbo() then
            if v:GetDistanceSqToPoint(position:Get()) < breakobjectsRadiusSQ then
                if self.destroyer and
                    v.components.workable ~= nil and
                    v.components.workable:CanBeWorked() and
                    v.components.workable.action ~= ACTIONS.NET then
                    v.components.workable:Destroy(self.inst)
                end
                if v:IsValid() and
                    not v:IsInLimbo() and
                    self.burner and
                    v.components.fueled == nil and
                    v.components.burnable ~= nil and
                    not v.components.burnable:IsBurning() and
                    not v:HasTag("burnt") then
                    v.components.burnable:Ignite()
                end
            elseif v.components.health ~= nil and
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
            if p_ent ~= self.inst and p_ent:IsValid() and p_ent.Transform ~= nil and p_ent.components.boatphysics ~= nil then
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
    return string.format("num rings: %d, damage rings: %d, destruction rings: %d, pushing rings: %d", self.numRings, self.damageRings, self.destructionRings, self.platformPushingRings)
end

return GroundPounder
