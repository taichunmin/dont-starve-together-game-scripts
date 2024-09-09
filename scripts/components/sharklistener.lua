--------------------------------------------------------------------------
--[[ ShadowHandSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--assert(TheWorld.ismastersim, "Sharklistener should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local DIST = 30

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private

local _players = {}
local _sharks = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function processsharks()
    local count = 0
    for shark,i in pairs(_sharks) do
        count = count + 1
    end

    for player,i in pairs(_players) do
        local closest = nil
        for shark,s in pairs(_sharks) do
            if shark:IsValid() then
                local distsq = player:GetDistanceSqToInst(shark)
                if distsq <= DIST*DIST then
                    if shark:IsValid() and not shark:HasTag("walking") then
                        closest = nil
                        break
                    elseif shark:IsValid() then
                        if not closest or distsq < closest then
                            closest = distsq
                        end
                    end
                end
            end
        end

        if closest then
            if player.killtask then
                player.killtask:Cancel()
                player.killtask = nil
            end
            local param = Remap(math.max(10*10,closest), 0, DIST*DIST, 1,0 )
            player._sharksoundparam:set(param)
        else
            player.killtask = player:DoTaskInTime(3,function()
                player._sharksoundparam:set(2)
            end)
        end

    end
end

local function StopTrackingShark(ent)
    self.inst:RemoveEventCallback("onremove", StopTrackingShark, ent)
    if _sharks[ent] ~= nil then
        _sharks[ent] = nil
    end
end

local function StartTrackingShark(inst, data)
    local ent = data.target
    if ent then
        if not _sharks[ent] then
            _sharks[ent] = true
            self.inst:ListenForEvent("onremove", StopTrackingShark, ent)
        end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerJoined(inst, player)
    if _players[player] ~= nil then
        return
    end
    _players[player] = true
end

local function OnPlayerLeft(inst, player)
    if _players[player] == nil then
        return
    end
    _players[player] = nil
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    OnPlayerJoined(inst, v)
end

--Register events
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft)
inst:ListenForEvent("sharkspawned", StartTrackingShark)

inst:DoPeriodicTask(3,processsharks)
--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local count = 0
    for shark,i in pairs(_sharks) do
        count = count + 1
    end
    return count == 1 and "1 shark" or (tostring(count).." sharks")
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)