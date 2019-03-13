local DEPLOY_HELPERS = {}

--global
function TriggerDeployHelpers(x, y, z, range, recipe, placerinst)
    range = range * range
    for k, v in pairs(DEPLOY_HELPERS) do
        if (k.recipefilters == nil or (recipe ~= nil and k.recipefilters[recipe.name])) and k.inst:GetDistanceSqToPoint(x, y, z) < range then
            k:StartHelper(recipe ~= nil and recipe.name or nil, placerinst)
        end
    end
end

local DeployHelper = Class(function(self, inst)
    self.inst = inst

    --self.recipefilters = nil
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

function DeployHelper:AddRecipeFilter(recipename)
    if self.recipefilters ~= nil then
        self.recipefilters[recipename] = true
    else
        self.recipefilters = { [recipename] = true }
    end
end

function DeployHelper:StartHelper(recipename, placerinst)
    if self.delay ~= nil then
        self.delay = 2
    elseif not self.inst:IsAsleep() then
        self.delay = 2
        self.inst:StartUpdatingComponent(self)
        if self.onenablehelper ~= nil then
            self.onenablehelper(self.inst, true, recipename, placerinst)
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
