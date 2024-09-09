local ATTACH_DIST_SQ = 1
local CLOSE_DIST_SQ = 64
local SCREEN_DIST_SQ = PLAYER_CAMERA_SEE_DISTANCE_SQ

local CORPSE_TRACK_NAME = "corpse"

local function CalcNewPosition(inst, radius, angle)
    local anglediff = math.random() * (PI*.45)

    if math.random() > 0.5 then
        anglediff = -anglediff
    end

    local theta = angle + anglediff
    local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))

    return inst:GetPosition() + offset
end

local function MoveToPointAction(inst)
    local pos = nil
    local target = inst.components.entitytracker:GetEntity(CORPSE_TRACK_NAME)

    if target ~= nil and target:IsValid() then
        local dist = inst:GetDistanceSqToInst(target)

        if dist <= ATTACH_DIST_SQ then
			inst.Transform:SetPosition(target.Transform:GetWorldPosition())
			inst.sg:GoToState("infest_corpse")

        elseif dist <= CLOSE_DIST_SQ then
            pos = target:GetPosition()

        else
            local x, y, z = target.Transform:GetWorldPosition()

            local angle = inst:GetAngleToPoint(x, y, z) * DEGREES
            local radius = math.min((math.random()*8) + 8, math.sqrt(dist)*.75)

            pos = CalcNewPosition(inst, radius, angle)
        end
    end

    -- Move around freely.
    if not pos then
        local x, y, z = inst.Transform:GetWorldPosition()
        local inview = IsAnyPlayerInRangeSq(x, y, z, SCREEN_DIST_SQ)

        if not inview then
            inst:Remove()
            return
        else
            -- Go out of sight and then dissapear.
            if not inst.randomdirection then
                inst.randomdirection = math.random()*TWOPI
            end

            local angle = inst.randomdirection
            local radius = (math.random()*8) + 8

            pos = CalcNewPosition(inst, radius, angle)
        end

    end

    if pos and inst:IsValid() then
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pos, nil, .2)
    end
end

local CorpseGestaltBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function CorpseGestaltBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.sg:HasStateTag("idle") end, "CanMove",
            DoAction(self.inst, MoveToPointAction, "Move", true )
        ),
    }, .25)

    self.bt = BT(self.inst, root)
end

return CorpseGestaltBrain