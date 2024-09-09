local function onworkable(self)
    local repairable = self.inst.components.repairable
    if repairable then
        repairable:SetWorkRepairable(self.maxwork ~= nil and self.workleft < self.maxwork and self.workable)
    end

    if self.action ~= nil then
        if self.workleft > 0 and self.workable then
            self.inst:AddTag(self.action.id.."_workable")
        else
            self.inst:RemoveTag(self.action.id.."_workable")
        end
    end
end

local function onaction(self, action, old_action)
    if self.workleft > 0 and self.workable then
        if old_action ~= nil then
            self.inst:RemoveTag(old_action.id.."_workable")
        end
        if action ~= nil then
            self.inst:AddTag(action.id.."_workable")
        end
    end
end

local Workable = Class(function(self, inst)
    self.inst = inst
    self.onwork = nil
    self.onfinish = nil
    self.workleft = 10
    self.maxwork = -1
    self.action = ACTIONS.CHOP
    self.savestate = false
    self.workable = true
	--self.tough = false
	--self.workmultiplierfn = nil
	--self.shouldrecoilfn = nil
end,
nil,
{
    workleft = onworkable,
    maxwork = onworkable,
    action = onaction,
    workable = onworkable,
})

function Workable:OnRemoveFromEntity()
    self.inst:RemoveTag("workrepairable")
    if self.action ~= nil then
        self.inst:RemoveTag(self.action.id.."_workable")
    end
end

function Workable:GetDebugString()
    return "workleft: "..tostring(self.workleft)
        .." maxwork: "..tostring(self.maxwork)
        .." workable: "..tostring(self.workable)
end

function Workable:SetRequiresToughWork(tough)
	self.tough = tough
end

function Workable:SetWorkAction(act)
    self.action = act
end

function Workable:GetWorkAction()
    return self.action
end

function Workable:Destroy(destroyer)
    if self:CanBeWorked() then
        self:WorkedBy(destroyer, self.workleft)
    end
end

function Workable:SetWorkable(able)
    self.workable = able
end

function Workable:SetWorkLeft(work)
    self.workable = true
    self.workleft = self.maxwork > 0 and math.clamp(work or 10, 1, self.maxwork) or math.max(1, work or 10)
end

function Workable:GetWorkLeft()
    return self.workable and self.workleft or 0
end

function Workable:CanBeWorked()
    return self.workable and self.workleft > 0
end

function Workable:SetOnLoadFn(fn)
    if type(fn) == "function" then
        self.onloadfn = fn
    end
end

function Workable:SetMaxWork(work)
    self.maxwork = math.max(1, work or 10)
end

function Workable:OnSave()
    return self.savestate
        and {
                maxwork = self.maxwork,
                workleft = self.workleft,
            }
        or {}
end

function Workable:OnLoad(data)
    self.workleft = data.workleft or self.workleft
    self.maxwork = data.maxwork or self.maxwork
    if self.onloadfn ~= nil then
        self.onloadfn(self.inst, data)
    end
end

function Workable:WorkedBy(worker, numworks)
	local tool = worker.components.inventory ~= nil and worker.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
	local recoil
	recoil, numworks = self:ShouldRecoil(worker, tool, numworks)
	self:WorkedBy_Internal(worker, numworks)
end

function Workable:WorkedBy_Internal(worker, numworks)
    numworks = numworks or 1
	if self.workmultiplierfn ~= nil then
		numworks = numworks * (self.workmultiplierfn(self.inst, worker, numworks) or 1)
	end
	if numworks > 0 then
		if self.workleft <= 1 then -- if there is less that one full work remaining, then just finish it. This is to handle the case where objects are set to only one work and not planned to handled something like 0.5 numworks
			self.workleft = 0
		else
			self.workleft = self.workleft - numworks
			if self.workleft < 0.01 then -- NOTES(JBK): Floating points are possible with work efficiency modifiers so cut out the epsilon.
				self.workleft = 0
			end
		end
	end
    self.lastworktime = GetTime()

    worker:PushEvent("working", { target = self.inst })
    self.inst:PushEvent("worked", { worker = worker, workleft = self.workleft })

    if self.onwork ~= nil then
        self.onwork(self.inst, worker, self.workleft, numworks)
    end

    if self.workleft <= 0 then
        local isplant =
            self.inst:HasTag("plant") and
            not self.inst:HasTag("burnt") and
            not (self.inst.components.diseaseable ~= nil and self.inst.components.diseaseable:IsDiseased())
        local pos = isplant and self.inst:GetPosition() or nil

        if self.onfinish ~= nil then
            self.onfinish(self.inst, worker)
        end
        self.inst:PushEvent("workfinished", { worker = worker })
        worker:PushEvent("finishedwork", { target = self.inst, action = self.action })
        if isplant then
            TheWorld:PushEvent("plantkilled", { doer = worker, pos = pos, workaction = self.action }) --this event is pushed in other places too
        end
    end
end

function Workable:SetOnWorkCallback(fn)
    self.onwork = fn
end

function Workable:SetOnFinishCallback(fn)
    self.onfinish = fn
end

function Workable:SetWorkMultiplierFn(fn)
	self.workmultiplierfn = fn
end

function Workable:SetShouldRecoilFn(fn)
	self.shouldrecoilfn = fn
end

function Workable:ShouldRecoil(worker, tool, numworks)
	if self.shouldrecoilfn ~= nil then
		local recoil, remainingworks = self.shouldrecoilfn(self.inst, worker, tool, numworks)
		if recoil ~= nil then
			if recoil then
				return true, remainingworks or 0
			end
			return false, remainingworks or numworks
		end
	end
	if self.tough and
		not (worker ~= nil and worker:HasTag("toughworker")) and
		not (tool ~= nil and tool.components.tool ~= nil and tool.components.tool:CanDoToughWork())
		then
		return true, 0
	end	
	return false, numworks
end

return Workable
