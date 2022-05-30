FaceEntity = Class(BehaviourNode, function(self, inst, getfn, keepfn, timeout, customalert)
    BehaviourNode._ctor(self, "FaceEntity")
    self.inst = inst
    self.getfn = getfn
    self.keepfn = keepfn
    self.timeout = timeout
    self.starttime = 0
    self.target = nil
    self.customalert = customalert
end)

function FaceEntity:HasLocomotor()
    return self.inst.components.locomotor ~= nil
end

function FaceEntity:Visit()
    if self.status == READY then
        self.target = self.getfn(self.inst)

        if self.target ~= nil then
            self.status = RUNNING

            if self:HasLocomotor() then
                self.inst.components.locomotor:Stop()
            end

            self.starttime = GetTime()
        else
            self.status = FAILED
        end
    end

    if self.status == RUNNING then
        --uhhhh....
        if self.inst.sg:HasStateTag("idle") and not self.inst.sg:HasStateTag("alert") and self.inst.sg.sg.states.alert then
            if self.customalert and self.inst.sg.currentstate.name ~= self.customalert then
                self.inst.sg:GoToState(self.customalert)
            elseif self.inst.sg.currentstate.name ~= "alert" then
                self.inst.sg:GoToState("alert")
            end
        end

        if self.timeout ~= nil and GetTime() - self.starttime > self.timeout then
            self.status = SUCCESS
            return
        end

        if not (self.target ~= nil and self.target:IsValid() and self.keepfn(self.inst, self.target)) then
            self.status = FAILED
        elseif self.inst.sg:HasStateTag("canrotate") then
            self.inst:FacePoint(self.target.Transform:GetWorldPosition())
        end

        self:Sleep(.5)
    end
end
