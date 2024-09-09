local function oncancatch(self)
    if self.canact and next(self.watchlist) ~= nil then
        self.inst:AddTag("cancatch")
    else
        self.inst:RemoveTag("cancatch")
    end
end

local Catcher = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.actiondistance = 12
    self.catchdistance = 2
    self.canact = false
    self.watchlist = {}
end,
nil,
{
    canact = oncancatch,
})

function Catcher:OnRemoveFromEntity()
    self.inst:RemoveTag("cancatch")
end

function Catcher:SetEnabled(enable)
    self.enabled = enable
    if not enable then
        self.canact = false
        if self.inst.sg:HasStateTag("readytocatch") then
            self.inst:PushEvent("cancelcatch")
        end
    end
end

---this is the distance at which the action to catch the projectile appears
function Catcher:SetActionDistance(dist)
    self.actiondistance = dist
end

--this is the distance at which the projectile will be caught, if ready
function Catcher:SetCatchDistance(dist)
    self.catchdistance = dist
end

function Catcher:StartWatching(projectile)
    self.watchlist[projectile] = true
    oncancatch(self)
    self.inst:StartUpdatingComponent(self)
end

function Catcher:StopWatching(projectile)
    self.watchlist[projectile] = nil
    oncancatch(self)
    if next(self.watchlist) == nil then
        self.inst:StopUpdatingComponent(self)
    end
end

function Catcher:CanCatch()
    return next(self.watchlist) ~= nil and self.canact
end

function Catcher:OnUpdate()
    if not self.inst:IsValid() then
        return
    end

    --Use local variable so we don't trigger self.canact setter unneccessarily
    local canact = false

    for k, v in pairs(self.watchlist) do
        if not k:IsValid() or k.components.projectile == nil or not k.components.projectile:IsThrown() then
            self:StopWatching(k)
        elseif not self.enabled then
            --skip
        elseif self.inst.sg:HasStateTag("readytocatch") then
            local distsq = k:GetDistanceSqToInst(self.inst)
            if distsq <= self.catchdistance * self.catchdistance then
                self.inst:PushEvent("catch", { projectile = k })
                k:PushEvent("caught", { catcher = self.inst })
                k.components.projectile:Catch(self.inst)
                self:StopWatching(k)
            elseif not canact and distsq < self.actiondistance * self.actiondistance then
                canact = true
            end
        elseif not canact and k:IsNear(self.inst, self.actiondistance) then
            canact = true
        end
    end

    self.canact = canact
end

return Catcher
