local AOEWeapon_Base = Class(function(self, inst)
    self.inst = inst
    self.damage = 10

    --self.onprehitfn = nil
    --self.onhitfn = nil
    --self.onmissfn = nil

    --self.canpick = nil
    --self.stimuli = nil
    --self.tags = nil
    --self.notags = nil
    --self.combinedtags = nil
    --self.workactions = nil

    -- We save a Combine call if we just assign the tags manually here.
    self.tags = {"_combat", "pickable", "NPC_workable"}
    self:SetWorkActions(ACTIONS.CHOP, ACTIONS.HAMMER, ACTIONS.MINE, ACTIONS.DIG)

    self:SetNoTags("FX", "DECOR", "INLIMBO")
end)

function AOEWeapon_Base:SetDamage(dmg)
    self.damage = dmg
end

function AOEWeapon_Base:SetStimuli(stimuli)
    self.stimuli = stimuli
end

function AOEWeapon_Base:SetWorkActions(...)
    self.workactions = {}
    for _, work_type in ipairs({...}) do
        self.workactions[work_type] = true
    end

    self:_CombineTags()
end

function AOEWeapon_Base:SetTags(...)
    self.tags = {...}

    self:_CombineTags()
end

function AOEWeapon_Base:_CombineTags()
    local toskip = {}
    self.combinedtags = {}

    if self.tags then
        for _, tag in ipairs(self.tags) do
            if not toskip[tag] then
                toskip[tag] = true
                table.insert(self.combinedtags, tag)
            end
        end
    end

    if self.workactions then
        for work_type in pairs(self.workactions) do
            local work_tag = work_type.id.."_workable"
            if not toskip[work_tag] then
                toskip[work_tag] = true
                table.insert(self.combinedtags, work_tag)
            end
        end
    end
end

function AOEWeapon_Base:SetNoTags(...)
    self.notags = { ... }
end

function AOEWeapon_Base:SetOnPreHitFn(fn)
    self.onprehitfn = fn
end

function AOEWeapon_Base:SetOnHitFn(fn)
    self.onhitfn = fn
end

function AOEWeapon_Base:SetOnMissFn(fn)
    self.onmissfn = fn
end

function AOEWeapon_Base:OnHit(doer, target)
    if self.onprehitfn ~= nil then
        self.onprehitfn(self.inst, doer, target)
    end

    local targetisworkable = false
    if target.components.workable then
        local work_action = target.components.workable:GetWorkAction()

        --V2C: nil action for NPC_workable (e.g. campfires)
        targetisworkable =
            (   not work_action and target:HasTag("NPC_workable")    ) or
            (   target.components.workable:CanBeWorked() and
                self.workactions[work_action] and
                (   work_action ~= ACTIONS.DIG or
                    (   target.components.spawner == nil and target.components.childspawner == nil  )
                )
            )
    end

    local did_hit = false
    if targetisworkable then
        target.components.workable:Destroy(doer)
        if target:IsValid() and target:HasTag("stump") then
            target:Remove()
        end

        did_hit = true
    elseif self.canpick and target.components.pickable and target.components.pickable:CanBePicked()
            and not target:HasTag("intense") then
		target.components.pickable:Pick(self.inst) --don't pass doer or they'll pocket the loot

        did_hit = true
    elseif doer.components.combat:CanTarget(target) and not doer.components.combat:IsAlly(target) then
        doer.components.combat:DoAttack(target, nil, nil, self.stimuli)

        did_hit = true
    end

    if did_hit then
        if self.onhitfn then
            self.onhitfn(self.inst, doer, target)
        end
    else
        if self.onmissfn then
            self.onmissfn(self.inst, doer, target)
        end
    end
end

local function TestGround(x, z)
    return TheWorld.Map:IsPassableAtPoint(x, 0, z)
        and not TheWorld.Map:IsGroundTargetBlocked(Vector3(x, 0, z))
end

function AOEWeapon_Base:OnToss(doer, target, sourceposition, basespeed, startradius)
    if target.components.mine ~= nil then
        target.components.mine:Deactivate()
    end

    if target.Physics and not target.components.inventoryitem.nobounce and target.Physics:IsActive() then
        startradius = math.max(startradius or 0, doer:GetPhysicsRadius(0) + target:GetPhysicsRadius(0))

        local x0, y0, z0
        if sourceposition then
            x0, y0, z0 = sourceposition:Get()
        else
            x0, y0, z0 = doer.Transform:GetWorldPosition()
        end
        local x1, y1, z1 = target.Transform:GetWorldPosition()

        local dx, dz = x1 - x0, z1 - z0
        local dsq = dx * dx + dz * dz
        local dist = math.sqrt(dsq)
        local angle = (dsq > 0 and math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES)
            or TWOPI * math.random()
        local sina, cosa = math.sin(angle), math.cos(angle)

        --V2C: test against edge of the world
        local testradius = startradius + .2
        if not TestGround(x0 + testradius * cosa, z0 + testradius * sina) then
            local initial_angle = angle
            local testdir = math.random() < 0.5
            for delta = 30, 180, 30 do
                angle = initial_angle + (testdir and delta or -delta)
                sina, cosa = math.sin(angle), math.cos(angle)
                if TestGround(x0 + testradius * cosa, z0 + testradius * sina) then
                    break
                end
                angle = initial_angle + (testdir and -delta or delta)
                sina, cosa = math.sin(angle), math.cos(angle)
                if TestGround(x0 + testradius * cosa, z0 + testradius * sina) then
                    break
                end
            end
        end

        local speed = (basespeed or 1) + math.random()
        target.Physics:Teleport(x0 + startradius * cosa, .1, z0 + startradius * sina)
        target.Physics:SetVel(cosa * speed, speed * 5 + math.random() * 2, sina * speed)
    end
end

return AOEWeapon_Base
