--local TIMEOUT = 20

local function OnPlayerExited(self, player)
    for i, v in ipairs(self.offScreenPlayers) do
        if v == player then
            self.inst.HUD:RemoveTargetIndicator(v)
            table.remove(self.offScreenPlayers, i)
            break
        end
    end
end

local PlayerTargetIndicator = Class(function(self, inst)
    self.inst = inst

    self.max_range = TUNING.MAX_INDICATOR_RANGE * 1.5
    self.offScreenPlayers = {}
    self.onScreenPlayersLastTick = {}
    -- self.recentTargetRemoved = {}
    self.onplayerexited = function(world, player)
        OnPlayerExited(self, player)
    end

    inst:ListenForEvent("playerexited", self.onplayerexited, TheWorld)
    inst:StartUpdatingComponent(self)
end)

function PlayerTargetIndicator:OnRemoveFromEntity()
    if self.offScreenPlayers ~= nil then
        self.inst:RemoveEventCallback("playerexited", self.onplayerexited, TheWorld)
        for i, v in ipairs(self.offScreenPlayers) do
            self.inst.HUD:RemoveTargetIndicator(v)
        end
        self.offScreenPlayers = nil
    end
end

PlayerTargetIndicator.OnRemoveEntity = PlayerTargetIndicator.OnRemoveFromEntity

function PlayerTargetIndicator:ShouldShowIndicator(target)
    -- local recentlyRemoved = false
    -- for i, v in ipairs(self.recentTargetRemoved) do
    --     if v and v.target and v.target == target and v.time < GetTime() then
    --         recentlyRemoved = true
    --         table.remove(self.recentTargetRemoved, i)
    --         break
    --     end
    -- end

    return not self:ShouldRemoveIndicator(target)
        and (--[[recentlyRemoved or]] table.contains(self.onScreenPlayersLastTick, target))
end

function PlayerTargetIndicator:ShouldRemoveIndicator(target)
    return target:HasTag("noplayerindicator") or
            target:HasTag("hiding") or
            not target:IsNear(self.inst, self.max_range) or
            target.entity:FrustumCheck() or
            not CanEntitySeeTarget(self.inst, target)
end

-- local function TimeoutHasExpired(time)
--     return ((GetTime() - time) > TIMEOUT)
-- end

function PlayerTargetIndicator:OnUpdate()
    local checked = {}

    --Check which indicators' players have moved within view or too far
    for i, v in ipairs(self.offScreenPlayers) do
        checked[v] = true

        while self:ShouldRemoveIndicator(v) do
            self.inst.HUD:RemoveTargetIndicator(v)
            table.remove(self.offScreenPlayers, i)
            v = self.offScreenPlayers[i]
            if v == nil then
                break
            end
            checked[v] = true
        end
    end

    --Check which players have moved outside of view
    for i, v in ipairs(AllPlayers) do
        if not (checked[v] or v == self.inst) and self:ShouldShowIndicator(v) then
            self.inst.HUD:AddTargetIndicator(v)
            table.insert(self.offScreenPlayers, v)
        end
    end

    --Check if targets that have been removed have been gone for a while (i.e. grace period is expired) -- Not working currently (might not be worth it...)
    -- for i, v in ipairs(self.recentTargetRemoved) do
    --     while TimeoutHasExpired(v.time) do
    --         table.remove(self.recentTargetRemoved, i)
    --         v = self.recentTargetRemoved[i]
    --         if v == nil then
    --             break
    --         end
    --     end
    -- end

    --Make a list of the players who are on screen so we can know who left the screen next update
    self.onScreenPlayersLastTick = {}
    for i, v in ipairs(AllPlayers) do
        if v ~= self.inst and v.entity:FrustumCheck() then
            table.insert(self.onScreenPlayersLastTick, v)
        end
    end
end

return PlayerTargetIndicator