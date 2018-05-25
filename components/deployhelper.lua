local DEPLOY_HELPERS = {}

--global
function TriggerDeployHelpers(x, y, z, range)
    range = range * range
    for k, v in pairs(DEPLOY_HELPERS) do
        if k.inst:GetDistanceSqToPoint(x, y, z) < range then
            k:StartHelper()
        end
    end
end

local DeployHelper = Class(function(self, inst)
    self.inst = inst

    --self.delay = nil
    self.onenablehelper = nil
end)

function DeployHelper:OnEntitySleep()
    DEPLOY_HELPERS[self] = nil
    self:StopHelper()
end

function DeployHelper:OnEntityWake()
    DEPLOY_HELPERS[self] = true
end

DeployHelper.OnRemoveEntity = DeployHelper.OnEntitySleep
DeployHelper.OnRemoveFromEntity = DeployHelper.OnEntitySleep

function DeployHelper:StartHelper()
    if self.delay ~= nil then
        self.delay = 2
    elseif not self.inst:IsAsleep() then
        self.delay = 2
        self.inst:StartUpdatingComponent(self)
        if self.onenablehelper ~= nil then
            self.onenablehelper(self.inst, true)
        end
    end
end

function DeployHelper:StopHelper()
    if self.delay ~= nil then
        self.delay = nil
        self.inst:StopUpdatingComponent(self)
        if self.onenablehelper ~= nil then
            self.onenablehelper(self.inst, false)
        end
    end
end

function DeployHelper:OnUpdate()
    if self.delay > 1 then
        self.delay = self.delay - 1
    else
        self:StopHelper()
    end
end

return DeployHelper
