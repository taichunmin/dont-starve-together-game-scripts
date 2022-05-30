local SEE_DIST = 20

local genericfollowposfn = function(inst) return inst:GetPosition() end

FindFarmPlant = Class(BehaviourNode, function(self, inst, action, wantsstressed, getfollowposfn, validplantfn)
    BehaviourNode._ctor(self, "FindFarmPlant")
    self.inst = inst
    self.wantsstressed = wantsstressed or false
    self.action = action
    self.getfollowposfn = getfollowposfn or genericfollowposfn
    self.validplantfn = validplantfn or nil
end)

local function IsNearFollowPos(self, plant)
    local followpos = self.getfollowposfn(self.inst)
    local plantpos = plant:GetPosition()
    return distsq(followpos.x, followpos.z, plantpos.x, plantpos.z) < SEE_DIST * SEE_DIST
end

function FindFarmPlant:DBString()
    return string.format("Go to farmplant %s", tostring(self.inst.planttarget))
end

function FindFarmPlant:Visit()
    if self.status == READY then
        self:PickTarget()
        if self.inst.planttarget then
			local action = BufferedAction(self.inst, self.inst.planttarget, self.action, nil, nil, nil, 0.1)
			self.inst.components.locomotor:PushAction(action, self.shouldrun)
			self.status = RUNNING
		else
			self.status = FAILED
        end
    end
    if self.status == RUNNING then
        local plant = self.inst.planttarget
        if not plant or not plant:IsValid() or not IsNearFollowPos(self, plant) or
        not (self.validplantfn == nil or self.validplantfn(self.inst, plant)) or not (plant.components.growable == nil or plant.components.growable:GetCurrentStageData().tendable) then
            self.inst.planttarget = nil
            self.status = FAILED
        --we don't need to test for the component, since we won't ever set clostest plant to anything that lacks that component
        elseif plant.components.farmplantstress.stressors.happiness ~= self.wantsstressed then
            self.inst.planttarget = nil
            self.status = SUCCESS
        end
    end
end

local FARMPLANT_MUSTTAGS = { "farmplantstress" }
local FARMPLANT_NOTAGS = { "farm_plant_killjoy" }
function FindFarmPlant:PickTarget()
    self.inst.planttarget = FindEntity(self.inst, SEE_DIST, function(plant)
        if IsNearFollowPos(self, plant) and (self.validplantfn == nil or self.validplantfn(self.inst, plant)) and
        (plant.components.growable == nil or plant.components.growable:GetCurrentStageData().tendable) then
            return plant.components.farmplantstress and plant.components.farmplantstress.stressors.happiness == self.wantsstressed
        end
    end, FARMPLANT_MUSTTAGS, FARMPLANT_NOTAGS)
end
