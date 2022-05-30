DoAction = Class(BehaviourNode, function(self, inst, getactionfn, name, run, timeout)
    BehaviourNode._ctor(self, name or "DoAction")
    self.inst = inst
    self.shouldrun = run
    self.action = nil
    self.getactionfn = getactionfn
    self.time = nil
    self.timeout = timeout
end)

function DoAction:OnFail()
    self.pendingstatus = FAILED
end

function DoAction:OnSucceed()
    self.pendingstatus = SUCCESS
end


function DoAction:Visit()

    if self.status == READY then
        local action = self.getactionfn(self.inst)

        if action then
            action:AddFailAction(function() self:OnFail() end)
            action:AddSuccessAction(function() self:OnSucceed() end)
            self.pendingstatus = nil
            self.inst.components.locomotor:PushAction(action, FunctionOrValue(self.shouldrun))
            self.action = action
            self.time = GetTime()
            self.status = RUNNING
        else
            self.status = FAILED
        end
    end

    if self.status == RUNNING then
    	if self.timeout and (GetTime() - self.time > self.timeout) then
    		self.status = FAILED
    		--print("Action timed out, failing")
    	end

        if self.pendingstatus then
            self.status = self.pendingstatus
        elseif not self.action:IsValid() then
            self.status = FAILED
        end
    end

end

