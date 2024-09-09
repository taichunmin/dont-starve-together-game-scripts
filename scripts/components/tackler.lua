local Tackler = Class(function(self, inst)
    self.inst = inst
    self.onstarttacklefn = nil
    --collisions
    self.distance = .5
    self.radius = .75
    self.structure_damage_mult = 2
    self.work_actions = {}
    self.collide_tags = { "_combat" }
    self.no_collide_tags = { "NPC_workable", "DIG_workable", "FX", "NOCLICK", "DECOR", "INLIMBO" }
    if not TheNet:GetPVPEnabled() then
        table.insert(self.no_collide_tags, "player")
    end
    self.oncollidefn = nil
    self.ontramplefn = nil
    --edge
    self.edgedistance = 5
end)

function Tackler:SetOnStartTackleFn(fn)
    self.onstarttacklefn = fn
end

function Tackler:StartTackle()
    return self.onstarttacklefn ~= nil and self.onstarttacklefn(self.inst)
end

function Tackler:SetDistance(distance)
    self.distance = distance
end

function Tackler:SetRadius(radius)
    self.radius = radius
end

function Tackler:SetStructureDamageMultiplier(mult)
    self.structure_damage_mult = mult
end

function Tackler:AddWorkAction(action, amount)
    if self.work_actions[action] == nil then
        self.work_actions[action] = amount or 1
        table.insert(self.collide_tags, action.id.."_workable")
    else
        self.work_actions[action] = amount or 1
    end
end

function Tackler:SetOnCollideFn(fn)
    self.oncollidefn = fn
end

function Tackler:SetOnTrampleFn(fn)
    self.ontramplefn = fn
end

function Tackler:CheckCollision(ignores)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local angle = self.inst.Transform:GetRotation() * DEGREES
    local x1 = x + math.cos(angle) * self.distance
    local z1 = z - math.sin(angle) * self.distance
    local target = nil
    local targetdist = math.huge
    local targetworkable = nil
    local trample = {}
    for i, v in ipairs(TheSim:FindEntities(x1, 0, z1, self.radius + 3, nil, self.no_collide_tags, self.collide_tags)) do
        if ignores == nil or not ignores[v] then
            local x2, y2, z2 = v.Transform:GetWorldPosition()
            local r = v:GetPhysicsRadius(0)
            local d = self.radius + r
            if distsq(x1, z1, x2, z2) < d * d then
                d = math.sqrt(distsq(x, z, x2, z2)) - v:GetPhysicsRadius(0)
                if d < targetdist then
                    if v.components.workable ~= nil and
                        v.components.workable:CanBeWorked() and
                        self.work_actions[v.components.workable:GetWorkAction()] ~= nil and
                        not v:HasTag("smallcreature") then
                        target = v
                        targetdist = d
                        targetworkable = true
                    elseif v.components.combat ~= nil
                        and v.components.health ~= nil
                        and not v.components.health:IsDead()
                        and self.inst.components.combat ~= nil
						and self.inst.components.combat:CanTarget(v)
						and not (self.inst.TargetForceAttackOnly ~= nil and self.inst:TargetForceAttackOnly(v))
					then
                        if v:HasTag("structure") then
                            target = v
                            targetdist = d
                            targetworkable = false
                        else
                            table.insert(trample, { inst = v, dist = d })
                        end
                    end
                end
            end
        end
    end

    if target ~= nil then
        if ignores ~= nil then
            ignores[target] = true
        end
        if self.oncollidefn ~= nil then
            self.oncollidefn(self.inst, target)
        end
        if targetworkable then
            target.components.workable:WorkedBy(self.inst, self.work_actions[target.components.workable:GetWorkAction()])
        else
            self.inst.components.combat.externaldamagemultipliers:SetModifier(self.inst, self.structure_damage_mult, "tackler")
            self.inst.components.combat:DoAttack(target)
            self.inst.components.combat.externaldamagemultipliers:RemoveModifier(self.inst, "tackler")
        end
    end

    for i, v in ipairs(trample) do
        if v.dist < targetdist and
            v.inst:IsValid() and
            v.inst.components.combat ~= nil and
            v.inst.components.health ~= nil and
            not v.inst.components.health:IsDead() and
			self.inst.components.combat:CanTarget(v.inst) and
			not (self.inst.TargetForceAttackOnly ~= nil and self.inst:TargetForceAttackOnly(v.inst))
		then
            if ignores ~= nil then
                ignores[v.inst] = true
            end
            if self.ontramplefn ~= nil then
                self.ontramplefn(self.inst, v.inst)
            end
            self.inst.components.combat:DoAttack(v.inst)
        end
    end

    return target ~= nil
end

function Tackler:SetEdgeDistance(distance)
    self.edgedistance = distance
end

local function NoHoles(pt)
    return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local function _CheckEdge(x, z, dist, rot)
    rot = rot * DEGREES
    x = x + math.cos(rot) * dist
    z = z - math.sin(rot) * dist
    return not TheWorld.Map:IsAboveGroundAtPoint(x, 0, z) or TheWorld.Map:IsGroundTargetBlocked(Vector3(x, 0, z))
end

function Tackler:CheckEdge()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local rot = self.inst.Transform:GetRotation()
    --only return true if it detects edge at all 3 angles
    return _CheckEdge(x, z, self.edgedistance, rot)
        and _CheckEdge(x, z, self.edgedistance, rot + 30)
        and _CheckEdge(x, z, self.edgedistance, rot - 30)
end

return Tackler
