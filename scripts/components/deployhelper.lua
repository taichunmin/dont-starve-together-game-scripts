local DEPLOY_HELPERS = {}

--global
function TriggerDeployHelpers(x, y, z, range, recipe, placerinst)
    range = range * range
    for helper in pairs(DEPLOY_HELPERS) do
        if ((not helper.keyfilters and not helper.recipefilters)
                or (helper.recipefilters and recipe and helper.recipefilters[recipe.name])
                or (helper.keyfilters and placerinst.deployhelper_key and helper.keyfilters[placerinst.deployhelper_key]))
                and helper.inst:GetDistanceSqToPoint(x, y, z) < range then
            helper:StartHelper((recipe and recipe.name) or placerinst.deployhelper_key, placerinst)
        end
    end
end

local DeployHelper = Class(function(self, inst)
    self.inst = inst

    --self.recipefilters = nil
    --self.keyfilters = nil
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
    if self.recipefilters then
        self.recipefilters[recipename] = true
    else
        self.recipefilters = { [recipename] = true }
    end
end

function DeployHelper:AddKeyFilter(key)
    if self.keyfilters then
        self.keyfilters[key] = true
    else
        self.keyfilters = { [key] = true }
    end
end

function DeployHelper:StartHelper(recipename, placerinst)
    if self.delay then
        self.delay = 2
    elseif not self.inst:IsAsleep() then
        self.delay = 2
		self.inst:StartWallUpdatingComponent(self)
        if self.onenablehelper then
            self.onenablehelper(self.inst, true, recipename, placerinst)
        end
	end

	if self.onstarthelper then
		self.onstarthelper(self.inst, recipename, placerinst)
	end
end

function DeployHelper:StopHelper()
    if self.delay then
        self.delay = nil
		self.inst:StopWallUpdatingComponent(self)
        if self.onenablehelper then
            self.onenablehelper(self.inst, false)
        end
    end
end

function DeployHelper:OnWallUpdate()
    if self.delay > 1 then
        self.delay = self.delay - 1
    else
        self:StopHelper()
    end
end

return DeployHelper
