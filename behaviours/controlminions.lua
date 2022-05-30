ControlMinions = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "ControlMinions")
    self.inst = inst
    self.ms = inst.components.minionspawner
    self.radius = nil
    self.minionrange = 3.5
end)

function ControlMinions:GetClosestMinion(item, minions)
    local x, y, z = item.Transform:GetWorldPosition()

    local closest = nil
    local closest_dist_sq = self.minionrange * self.minionrange

    for k, v in pairs(minions) do
        if v ~= item then
            local dist_sq = v:GetDistanceSqToPoint(x, y, z)
            if dist_sq < closest_dist_sq then
                closest = v
                closest_dist_sq = dist_sq
            end
        end
    end

    return closest
end

local NO_TAGS =
{
    "FX",
    "NOCLICK",
    "DECOR",
    "INLIMBO",
    "irreplaceable",
    "heavy",
    "lureplant",
    "eyeplant",
    "notarget",
    "noattack",
    "flight",
    "invisible",
    "catchable",
    "fire",
    "eyeplant_immune",
}

local ACT_TAGS =
{
    "_inventoryitem",
    "pickable",
    "donecooking",
    "readyforharvest",
    "dried",
}

function ControlMinions:Visit()
    if self.status == READY then
        if self.ms.numminions > 0 then
            self.status = RUNNING
        else
            self.status = FAILED
        end
    end

    if self.status == RUNNING then
        local x, y, z = self.inst.Transform:GetWorldPosition()

        --Get the distance you need to look for things within.
        if self.radius == nil then
            if self.ms.minionpositions ~= nil then
                local x1, y1, z1 = self.ms.minionpositions[#self.ms.minionpositions]:Get()
                local rad = math.sqrt(distsq(x, z, x1, z1))
                self.radius = rad + (rad * 0.1)
            else
                self.status = FAILED
                return
            end
        end

        --find all entities within required radius
        local ents = TheSim:FindEntities(x, y, z, self.radius, nil, NO_TAGS, ACT_TAGS)
        if #ents > 0 then
            for i, v in pairs(ents) do
                if v:IsValid() and v:IsOnValidGround() and v:GetTimeAlive() > 1 then
                    local mn = self:GetClosestMinion(v, self.ms.minions)
                    if mn ~= nil and not mn.sg:HasStateTag("busy") then
                        local action = nil
                        if (v.components.crop ~= nil and v.components.crop:IsReadyForHarvest()) or
                            (v.components.stewer ~= nil and v.components.stewer:IsDone()) or
                            (v.components.dryer ~= nil and v.components.dryer:IsDone()) then
                            --Harvest!
                            action = ACTIONS.HARVEST
                        elseif v.components.pickable ~= nil and
                                v.components.pickable:CanBePicked() and
                                v.components.pickable.caninteractwith then
                            --Pick!
                            action = ACTIONS.PICK
                        elseif v.components.inventoryitem ~= nil and
                                v.components.inventoryitem.cangoincontainer and
                                (v.components.inventoryitem.canbepickedup or v.components.inventoryitem.canbepickedupalive) then
                            --Pick up!
                            action = ACTIONS.PICKUP
                        end
                        if action ~= nil then
                            local ba = BufferedAction(mn, v, action)
                            ba.distance = 4
                            mn:PushBufferedAction(ba)
                            ba = mn:GetBufferedAction()
                            if ba ~= nil and ba.target ~= nil and ba.target:IsValid() then
                                mn:ForceFacePoint(ba.target.Transform:GetWorldPosition())
                            end
                        end
                    end
                end
            end
            self.status = SUCCESS
        else
            self.status = FAILED
        end
    end
end
