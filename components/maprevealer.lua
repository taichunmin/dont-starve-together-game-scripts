local MapRevealer = Class(function(self, inst)
    self.inst = inst

    self.revealperiod = 5
    self.task = nil

    --V2C: Recommended to explicitly add tag to prefab pristine state
    --inst:AddTag("maprevealer")
    --Added in Start function

    self:Start()
end)

local function OnRestart(inst, self, delay)
    self.task = nil
    self:Start(delay)
end

local function OnRevealing(inst, self, delay, players)
    local player = table.remove(players)
    while not player:IsValid() do
        if #players <= 0 then
            OnRestart(inst, self, delay)
            return
        end
        player = table.remove(players)
    end

    self:RevealMapToPlayer(player)

    if #players > 0 then
        self.task = inst:DoTaskInTime(delay, OnRevealing, self, delay, players)
    else
        OnRestart(inst, self, delay)
    end
end

local function OnStart(inst, self)
    local numplayers = #AllPlayers
    if numplayers > 0 then
        local players = {}
        for i, v in ipairs(AllPlayers) do
            table.insert(players, v)
        end

        OnRevealing(inst, self, self.revealperiod / numplayers, players)
    else
        OnRestart(inst, self, self.revealperiod)
    end
end

function MapRevealer:Start(delay)
    if self.task == nil then
        self.inst:AddTag("maprevealer")
        self.task = self.inst:DoTaskInTime(delay or math.random() * .5, OnStart, self)
    end
end

function MapRevealer:Stop()
    if self.task ~= nil then
        self.inst:RemoveTag("maprevealer")
        self.task:Cancel()
        self.task = nil
    end
end

function MapRevealer:RevealMapToPlayer(player)
    if player.player_classified ~= nil then
        player.player_classified.MapExplorer:RevealArea(self.inst.Transform:GetWorldPosition())
    end
end

MapRevealer.OnRemoveFromEntity = MapRevealer.Stop

return MapRevealer
