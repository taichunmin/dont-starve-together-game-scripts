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

--    self.max_range = TUNING.MAX_INDICATOR_RANGE * 1.5
    self.offScreenPlayers = {}
    self.onScreenPlayersLastTick = {}
    -- self.recentTargetRemoved = {}
    self.onplayerexited = function(world, player)
        OnPlayerExited(self, player)
    end

    --inst:ListenForEvent("playerexited", self.onplayerexited, TheWorld)
    inst:ListenForEvent("unregister_hudindicatable", self.onplayerexited, TheWorld)

    inst:StartUpdatingComponent(self)
end)

function PlayerTargetIndicator:OnRemoveFromEntity()
    if self.offScreenPlayers ~= nil then
        --self.inst:RemoveEventCallback("playerexited", self.onplayerexited, TheWorld)
        self.inst:RemoveEventCallback("unregister_hudindicatable", self.onplayerexited, TheWorld)
        for i, v in ipairs(self.offScreenPlayers) do
            self.inst.HUD:RemoveTargetIndicator(v)
        end
        self.offScreenPlayers = nil
    end
end

PlayerTargetIndicator.OnRemoveEntity = PlayerTargetIndicator.OnRemoveFromEntity

function PlayerTargetIndicator:ShouldShowIndicator(target)

    return target.components.hudindicatable:ShouldTrack(self.inst)
        and table.contains(self.onScreenPlayersLastTick, target)
end

function PlayerTargetIndicator:ShouldRemoveIndicator(target)
    return not target.components.hudindicatable:ShouldTrack(self.inst)
end

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
    if TheWorld.components.hudindicatablemanager then
        for i, v in pairs(TheWorld.components.hudindicatablemanager.items) do
            if not (checked[v] or v == self.inst) and self:ShouldShowIndicator(v) then
                self.inst.HUD:AddTargetIndicator(v)
                table.insert(self.offScreenPlayers, v)
            end
        end
        self.onScreenPlayersLastTick = {}
         for i, v in pairs(TheWorld.components.hudindicatablemanager.items) do
            if v ~= self.inst and v.entity:FrustumCheck() then
                table.insert(self.onScreenPlayersLastTick, v)
            end
        end
    end

end

return PlayerTargetIndicator