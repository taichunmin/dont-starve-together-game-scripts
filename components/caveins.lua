--------------------------------------------------------------------------
--[[ CaveIns class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "CaveIns should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local BOULDERS =
{
    "cavein_boulder",
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _ismastershard = TheWorld.ismastershard

local _targets = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function DoTargetDebris(inst, x, z, player, spread, remaining)
    if player ~= nil and player:IsValid() then
        local x1, y1, z1 = player.Transform:GetWorldPosition()
        local dx, dz = x1 - x, z1 - z
        local len = dx * dx + dz * dz
        if len <= 16 then
            x, z = x1, z1
        else
            len = math.sqrt(len)
            x = x + dx * 4 / len
            z = z + dz * 4 / len
            spread = math.max(0, spread - .4)
        end
    end
    local theta = math.random() * TWOPI
    SpawnPrefab("cavein_debris").Transform:SetPosition(x + spread * math.cos(theta), 0, z + spread * math.sin(theta))
    if remaining > 1 then
        inst:DoTaskInTime(.4 + math.random() * .2, DoTargetDebris, x, z, player, math.min(1, spread + .5), remaining - 1)
    end
end

local function DoTargetWarning(targetinfo)
    ShakeAllCameras(CAMERASHAKE.SIDE, 1.5, .04, .05, targetinfo.pos, 6)
    DoTargetDebris(inst, targetinfo.pos.x, targetinfo.pos.z, targetinfo.player, .2, math.random(3, 4))
    if targetinfo.player ~= nil and not targetinfo.warned then
        targetinfo.warned = true
        targetinfo.player.components.talker:Say(GetString(targetinfo.player, "ANNOUNCE_CAVEIN"))
    end
    targetinfo.warncd = TUNING.ANTLION_SINKHOLE.WARNING_DELAY * .8
end

local function GetDebrisFn()
    return "cavein_boulder", 0
end

local function DoTargetAttack(inst, pos, player)
    TheWorld:PushEvent("ms_miniquake", {
        rad = 4,
        minrad = 1.5,
        num = 30,
        duration = 3.5,
        pos = pos,
        target = player,
        debrisfn = GetDebrisFn,
    })
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local OnSinkholesUpdate = not _ismastershard and function(inst, data)
    local old = _targets
    _targets = {}
    if #data.targets > 0 then
        local players = {}
        for i, v in ipairs(AllPlayers) do
            players[smallhash(v.userid)] = v
        end
        for i, v in ipairs(data.targets) do
            local player = players[v.userhash]
            local oldtarget = old[v.userhash]
            if player ~= nil then
                if v.attack then
                    DoTargetAttack(inst, player:GetPosition(), player)
                else
                    if oldtarget ~= nil then
                        _targets[v.userhash] = oldtarget
                        oldtarget.player = player
                        oldtarget.pos.x, oldtarget.pos.y, oldtarget.pos.z = player.Transform:GetWorldPosition()
                    else
                        _targets[v.userhash] =
                        {
                            player = player,
                            pos = player:GetPosition(),
                        }
                    end
                    if v.warn and not (oldtarget ~= nil and oldtarget.warncd ~= nil) then
                        DoTargetWarning(_targets[v.userhash])
                    end
                end
            elseif oldtarget ~= nil then
                if v.attack then
                    DoTargetAttack(inst, oldtarget.pos)
                else
                    _targets[v.userhash] = oldtarget
                    oldtarget.player = nil
                    if v.warn and not (oldtarget ~= nil and oldtarget.warncd ~= nil) then
                        DoTargetWarning(oldtarget)
                    end
                end
            end
        end
    end

    if next(_targets) ~= nil then
        inst:StartUpdatingComponent(self)
    else
        inst:StopUpdatingComponent(self)
    end
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
if not _ismastershard then
    inst:ListenForEvent("secondary_sinkholesupdate", OnSinkholesUpdate)
end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
    for k, v in pairs(_targets) do
        if v.player ~= nil then
            if v.player:IsValid() then
                v.pos.x, v.pos.y, v.pos.z = v.player.Transform:GetWorldPosition()
            else
                v.player = nil
            end
        end
        v.warncd = v.warncd ~= nil and v.warncd > dt and v.warncd - dt or nil
    end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    if next(_targets) ~= nil then
        local data = {}
        for k, v in pairs(_targets) do
            table.insert(data, {
                x = v.pos.x,
                z = v.pos.z,
            })
        end
        return { targets = data }
    end
end

function self:OnLoad(data)
    if data.targets ~= nil then
        for i, v in ipairs(data.targets) do
            if v.x ~= nil and v.z ~= nil then
                inst:DoTaskInTime(0, DoTargetAttack, Vector3(v.x, 0, v.z))
            end
        end
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local s
    for k, v in pairs(_targets) do
        s = (s ~= nil and (s.."\n") or "")..string.format("  [%s] @(%.2f,%.2f)", tostring(v.player), v.pos.x, v.pos.z)
    end
    return s
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
