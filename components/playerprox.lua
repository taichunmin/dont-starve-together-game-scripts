--[[
    PlayerProx component can run in four possible ways
    - Any player within distance, all players outside distance (PlayerProx.AnyPlayer)
    - a specific player within and outside distance (PlayerProx.SpecificPlayer)
    - as soon as a player comes within range, start tracking that one for going out of distance and then relinquish tracking (PlayerProx.LockOnPlayer)
    - as soon as a player comes within range, start tracking that player and keep tracking that player (PlayerProx.LockAndKeepPlayer)
--]]

local function AllPlayers(inst, self)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, self.near, self.alivemode)

    local closeplayers = {}
    for i, player in ipairs(players) do
        closeplayers[player] = true
        if self.closeplayers[player] then
            self.closeplayers[player] = nil
        else
            if self.onnear ~= nil then
                self.onnear(inst, player)
            end
        end
    end

    local farsq = self.far * self.far
    for player in pairs(self.closeplayers) do
        if player:IsValid() then
            if (self.alivemode == nil or self.alivemode ~= IsEntityDeadOrGhost(player)) and
            player.entity:IsVisible() and
            player:GetDistanceSqToPoint(x, y, z) < farsq then
                closeplayers[player] = true
            else
                if self.onfar ~= nil then
                    self.onfar(inst, player)
                end
            end
        end
    end

    self.closeplayers = closeplayers
    self.isclose = not IsTableEmpty(self.closeplayers)
end

local function AnyPlayer(inst, self)
    local x, y, z = inst.Transform:GetWorldPosition()
    if not self.isclose then
        local player = FindClosestPlayerInRange(x, y, z, self.near, self.alivemode)
        if player ~= nil then
            self.isclose = true
            if self.onnear ~= nil then
                self.onnear(inst, player)
            end
        end
    elseif not IsAnyPlayerInRange(x, y, z, self.far, self.alivemode) then
        self.isclose = false
        if self.onfar ~= nil then
            self.onfar(inst)
        end
    end
end

local function SpecificPlayer(inst, self)
    if not self.isclose then
        if self.target:IsNear(inst, self.near) then
            self.isclose = true
            if self.onnear ~= nil then
                self.onnear(inst, self.target)
            end
        end
    elseif not self.target:IsNear(inst, self.far) then
        self.isclose = false
        if self.onfar ~= nil then
            self.onfar(inst)
        end
    end
end

local function LockOnPlayer(inst, self)
    if not self.isclose then
        local x, y, z = inst.Transform:GetWorldPosition()
        local player = FindClosestPlayerInRange(x, y, z, self.near, self.alivemode)
        if player ~= nil then
            self.isclose = true
            self:SetTarget(player)
            if self.onnear ~= nil then
                self.onnear(inst, player)
            end
        end
    elseif not self.target:IsNear(inst, self.far) then
        self.isclose = false
        self:SetTarget(nil)
        if self.onfar ~= nil then
            self.onfar(inst)
        end
    end
end

local function LockAndKeepPlayer(inst, self)
    if not self.isclose then
        local x, y, z = inst.Transform:GetWorldPosition()
        local player = FindClosestPlayerInRange(x, y, z, self.near, self.alivemode)
        if player ~= nil then
            self.isclose = true
            self:SetTargetMode(SpecificPlayer, player, true)
            if self.onnear ~= nil then
                self.onnear(inst, player)
            end
        end
    else
        -- we should never get here
        assert(false)
    end
end

local function OnTargetLeft(self)
    self:Stop()
    self.target = nil
    if self.initialtargetmode == LockAndKeepPlayer or
        self.initialtargetmode == LockOnPlayer then
        self:SetTargetMode(self.initialtargetmode)
    end
    if self.losttargetfn ~= nil then
        self.losttargetfn()
    end
end

local PlayerProx = Class(function(self, inst, targetmode, target)
    self.inst = inst
    self.near = 2
    self.far = 3
    self.isclose = false
    self.period = 10 * FRAMES
    self.onnear = nil
    self.onfar = nil
    self.task = nil
    self.target = nil
    self.losttargetfn = nil
    self.alivemode = nil
    self._ontargetleft = function() OnTargetLeft(self) end
    self.closeplayers = {}

    self:SetTargetMode(targetmode or AnyPlayer, target)
end)

PlayerProx.AliveModes =
{
    AliveOnly =         true,
    DeadOnly =          false,
    DeadOrAlive =       nil,
}

PlayerProx.TargetModes =
{
    AllPlayers =        AllPlayers,
    AnyPlayer =         AnyPlayer,
    SpecificPlayer =    SpecificPlayer,
    LockOnPlayer =      LockOnPlayer,
    LockAndKeepPlayer = LockAndKeepPlayer,
}

function PlayerProx:GetDebugString()
    return self.isclose and "NEAR" or "FAR"
end

function PlayerProx:SetOnPlayerNear(fn)
    self.onnear = fn
end

function PlayerProx:SetOnPlayerFar(fn)
    self.onfar = fn
end

function PlayerProx:IsPlayerClose()
    return self.isclose
end

function PlayerProx:SetDist(near, far)
    self.near = near
    self.far = far
end

function PlayerProx:SetLostTargetFn(func)
    self.losttargetfn = func
end

function PlayerProx:SetPlayerAliveMode(alivemode)
    self.alivemode = alivemode
end

function PlayerProx:Schedule(new_period)
	if new_period ~= nil then
		self.period = new_period
	end
    self:Stop()
    self.task = self.inst:DoPeriodicTask(self.period, self.targetmode, nil, self)
end

function PlayerProx:ForceUpdate()
    if self.task ~= nil and self.targetmode ~= nil then
        self.targetmode(self.inst, self)
    end
end

function PlayerProx:Stop()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function PlayerProx:OnEntityWake()
    self:Schedule()
    self:ForceUpdate()
end

function PlayerProx:OnEntitySleep()
    self:ForceUpdate()
    self:Stop()
end

PlayerProx.OnRemoveEntity = PlayerProx.Stop
PlayerProx.OnRemoveFromEntity = PlayerProx.Stop

function PlayerProx:SetTargetMode(mode, target, override)
    if not override then
        self.originaltargetmode = mode
    end
    self.targetmode = mode
    self:SetTarget(target)
    assert(self.targetmode ~= SpecificPlayer or self.target ~= nil)
    self:Schedule()
end

function PlayerProx:SetTarget(target)
    --listen for playerexited instead of ms_playerleft because
    --this component may be used for client side prefabs
    if self.target ~= nil then
        self.inst:RemoveEventCallback("onremove", self._ontargetleft, self.target)
    end
    self.target = target
    if target ~= nil then
        self.inst:ListenForEvent("onremove", self._ontargetleft, target)
    end
end

return PlayerProx
