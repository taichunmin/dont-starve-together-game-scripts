local LOOK_FOR_ATRIUM_PILLARS_RANGE = 50
local ATRIUM_PILLAR_MUSTTAGS = {"pillar_atrium"}

local CAMERA_FOCUS_ID = "charlie_cutscene"
local CAMERA_FOCUS_DIST_MIN = 12
local CAMERA_FOCUS_DIST_MAX = 25

local CAMERA_PAN_GAIN = 4
local CAMERA_HEADING_GAIN  = 1.2
local CAMERA_DISTANCE_GAIN = 0.7

local CAMERA_FINAL_DISTANCE = 25

local REPAIR_GATE_ANIM_LENGTH = 114 * FRAMES

local CHARLIE_SPAWN_DELAY = 2
local CHARLIE_START_CAST_DELAY = 3
local CHARLIE_CAST_TIME = REPAIR_GATE_ANIM_LENGTH + 0.5 + (20 * FRAMES)

local START_REPAIRING_GATE_DELAY = CHARLIE_START_CAST_DELAY + (80 * FRAMES)
local REPAIR_GATE_DELAY = START_REPAIRING_GATE_DELAY + REPAIR_GATE_ANIM_LENGTH

local START_TWEENING_DELAY = REPAIR_GATE_ANIM_LENGTH * 0.95
local TWEEN_TO_BLACK_TIME = REPAIR_GATE_ANIM_LENGTH - START_TWEENING_DELAY
local REVERT_COLOUR_TIME = 3.5


--=========================================================================--
----                     START CLIENT SIDE FUNCTIONS                     ----
--=========================================================================--

local function CharlieCam_UpdateFn(dt, params, parent, dist_sq)
    ------ Start Default Focal Point Update Function -------

    local tpos = params.target:GetPosition()
    local ppos = parent:GetPosition()

    local range = params.maxrange - params.minrange
    local offs = tpos - ppos
    if dist_sq > params.minrange * params.minrange then
        offs = offs * (range ~= 0 and ((params.maxrange - math.sqrt(dist_sq)) / range))
    end

    offs.y = offs.y + 1
    TheCamera:SetOffset(offs)

    ------ End Default Focal Point Update Function -------

    local self = params.source.components.charliecutscene

    -- +2 because this needs to run before TheFocalPoint forgets this source.
    if dist_sq + 2 <= (params.maxrange * params.maxrange) then
        if TheCamera:IsControllable() then
            self:ClientLockCamera()
        end
    else
        if not TheCamera:IsControllable() then
           self:ClientUnlockCamera()
        end
    end
end

local camera_settings = {UpdateFn = CharlieCam_UpdateFn}

local function OnIsCameraLockedDirty(inst)
    if TheNet:IsDedicated() then return end

    local self = inst.components.charliecutscene

    if self._iscameralocked:value() then
        TheFocalPoint.components.focalpoint:StartFocusSource(inst, CAMERA_FOCUS_ID, nil, CAMERA_FOCUS_DIST_MIN, CAMERA_FOCUS_DIST_MAX, 5, camera_settings)
    else
        TheFocalPoint.components.focalpoint:StopFocusSource(inst, CAMERA_FOCUS_ID)

        self:ClientUnlockCamera(inst)
    end
end

--=========================================================================--
----                      END CLIENT SIDE FUNCTIONS                      ----
--=========================================================================--

local function RoundPillarAngle(value)
    local _start = value > 0 and 45 or -315
    local _end   = value > 0 and 315 or -45

    for target = _start, _end, 90 do
        local difference = math.diff(value, target)
        if difference < 5 then
            return target
        end
    end

    return value
end

local function _IsRightAngle(a, b)
    return math.abs(a - b) == 90
end

local function FindPillarsDirections(a, b, c)
    local _a, _b, _c = a.angle, b.angle, c.angle

    if _IsRightAngle(_a, _b) and _IsRightAngle(_a, _c) then
        return {back = a.pillar, side = {b.pillar, c.pillar}}
    elseif _IsRightAngle(_b, _a) and _IsRightAngle(_b, _c) then
        return {back = b.pillar, side = {a.pillar, c.pillar}}
    else
        return {back = c.pillar, side = {a.pillar, b.pillar}}
    end
end

local function InternalCollectAtriumPillarsData(gate_pos)
    local x, y, z = gate_pos:Get()

    local ents = TheSim:FindEntities(x, y, z, LOOK_FOR_ATRIUM_PILLARS_RANGE, ATRIUM_PILLAR_MUSTTAGS)

    local data = {}

    for _, pillar in ipairs(ents) do
        local angle = RoundPillarAngle(pillar:GetAngleToPoint(x, 0, z))

        table.insert(data, {pillar = pillar, angle = angle})
    end

    return FindPillarsDirections(unpack(data))
end

local function GetOneSidePillar(data)
    return math.random() > 0.5 and data.side[1] or data.side[2]
end

-----------------------------------------------------------------------------------------------

local function TweenToNormalColour(inst)
    inst.components.colourtweener:StartTween({1, 1, 1, 1}, REVERT_COLOUR_TIME)
end

local function RevertToNormalColour(inst)
    inst:DoTaskInTime(0.2, TweenToNormalColour)
end

local function TweenToBlack(inst)
    inst.components.colourtweener:StartTween({0, 0, 0, 1}, TWEEN_TO_BLACK_TIME, RevertToNormalColour)
end

local function StartRepairingGate(inst)
    inst.AnimState:PlayAnimation("fixing")

    inst.SoundEmitter:PlaySound("rifts2/atrium/fixing", "fixing")

    inst:DoTaskInTime(START_TWEENING_DELAY, TweenToBlack)
end

local function RepairGate(inst)
    return inst.components.charliecutscene:RepairGate()
end

-----------------------------------------------------------------------------------------------

local CharlieCutscene = Class(function(self, inst)
    self.inst = inst

    self.gate_pos = nil
    self.atrium_pillars = nil

    self._iscameralocked = net_bool(     inst.GUID, "charliecutscene._iscameralocked", "iscameralockeddirty")
    self._cameraangle    = net_ushortint(inst.GUID, "charliecutscene._cameraangle")

    self._running = false
    self._gatefixed = false

    self._traderenabled = nil

    if not TheWorld.ismastersim then
        inst:ListenForEvent("iscameralockeddirty", OnIsCameraLockedDirty)

        -- For clients joining during the cutscene!
        inst:DoTaskInTime(0, OnIsCameraLockedDirty)
    end

end)

function CharlieCutscene:ClientLockCamera()
    TheCamera:SetControllable(false)

    TheCamera:SetGains(CAMERA_PAN_GAIN, CAMERA_HEADING_GAIN, CAMERA_DISTANCE_GAIN)

    TheCamera:SetDistance(CAMERA_FINAL_DISTANCE)
    TheCamera:SetHeadingTarget(self._cameraangle:value())
end

function CharlieCutscene:ClientUnlockCamera()
    TheCamera:SetControllable(true)

    -- Note: TheFocalPoint will handle resetting the gain values.
end

-----------------------------------------------------------------------------------------------

if not TheWorld.ismastersim then
    return CharlieCutscene
end

-----------------------------------------------------------------------------------------------

--=========================================================================--
----                       SERVER SIDE FUNCTIONS                         ----
--=========================================================================--

function CharlieCutscene:Start()
    self._running = true

    TheWorld:PushEvent("charliecutscene", true)
    TheWorld:PushEvent("ms_locknightmarephase", "wild")

    self._traderenabled = self.inst.components.trader.enabled
    self.inst.components.trader:Disable()

    self:CollectAtriumPillarsData()

    self:SpawnCharlieWithDelay(CHARLIE_SPAWN_DELAY)
    self:StartRepairingGateWithDelay(START_REPAIRING_GATE_DELAY, REPAIR_GATE_DELAY)

    self._cameraangle:set(self:FindSceneCameraAngle())
    self._iscameralocked:set(true)

    OnIsCameraLockedDirty(self.inst)
end

-- Called by charlie_npc.lua
function CharlieCutscene:Finish()
    self._running = false

    TheWorld:PushEvent("charliecutscene", false)
    TheWorld:PushEvent("ms_locknightmarephase", nil)

    -- Note: trader.enabled is not saved, so this don't need to run on load.
    if self._traderenabled then
        self.inst.components.trader:Enable()
    end

    self._iscameralocked:set(false)
    OnIsCameraLockedDirty(self.inst)

    TheWorld:PushEvent("shadowrift_opened")
end

-----------------------------------------------------------------------------------------------

function CharlieCutscene:CollectAtriumPillarsData()
    if self.gate_pos ~= nil and self.atrium_pillars ~= nil then
        return
    end

    self.gate_pos = self.inst:GetPosition()
    self.atrium_pillars = InternalCollectAtriumPillarsData(self.gate_pos)
end

function CharlieCutscene:FindSceneCameraAngle()
    local pillar_pos = self.atrium_pillars.back:GetPosition()

    local angle = math.atan2(self.gate_pos.z - pillar_pos.z, pillar_pos.x - self.gate_pos.x) / DEGREES + 180

    angle = RoundPillarAngle(angle)

    -- DiogoW: This is ugly, I know...
    local offset = ((angle == 45 or angle == 225) and -90) or 90

    return (angle + offset) % 360
end

-----------------------------------------------------------------------------------------------

function CharlieCutscene:StartRepairingGateWithDelay(delay, delay_to_fix)
    self.inst:DoTaskInTime(delay,        StartRepairingGate)
    self.inst:DoTaskInTime(delay_to_fix, RepairGate        )
end

function CharlieCutscene:RepairGate()
    self._gatefixed = true
    self.inst.AnimState:SetBuild("atrium_gate_build")
    self.inst.AnimState:PlayAnimation("fixed")
    self.inst.SoundEmitter:KillSound("fixing")

    ShakeAllCameras(CAMERASHAKE.SIDE, 1, .07, .4, self.inst, 30)

    self.inst.SoundEmitter:PlaySound("rifts2/atrium/fixed")

    local active = self.inst.components.pickable.caninteractwith or self.inst.components.worldsettingstimer:ActiveTimerExists("destabilizedelay")
    self.inst.MiniMapEntity:SetIcon(active and "atrium_gate_fixed_active.png" or "atrium_gate_fixed.png")

    local cooldown = self.inst.components.worldsettingstimer:ActiveTimerExists("cooldown")
    self.inst.AnimState:PushAnimation(cooldown and "cooldown" or "idle", cooldown)
end

-----------------------------------------------------------------------------------------------

function CharlieCutscene:FindCharlieSpawnPoint()
    local pillar = GetOneSidePillar(self.atrium_pillars)

    if pillar ~= nil then
        local pillar_pos = pillar:GetPosition()
        local spawn_pos = (pillar_pos * 0.4) + (self.gate_pos * 0.6)

        -- Moving the spawn point slightly ahead of the atrium gate.
        local angle = self._cameraangle:value() / RADIANS
        local mult = 3

        local offset = Vector3(math.cos(angle), 0, math.sin(angle)):Normalize() * mult

        return spawn_pos + offset
    end
end

function CharlieCutscene:SpawnCharlieWithDelay(delay)
    self.inst:DoTaskInTime(delay, function(inst)
        self.charlie = SpawnPrefab("charlie_npc")
        
        self.charlie.atrium = inst
        
        local spawn_pos = self:FindCharlieSpawnPoint()
        
        self.charlie.Transform:SetPosition(spawn_pos:Get())
        self.charlie:ForceFacePoint(self.gate_pos:Get())

        self.charlie:StartCastingWithDelay(CHARLIE_START_CAST_DELAY, CHARLIE_CAST_TIME)
    end)
end

-----------------------------------------------------------------------------------------------

function CharlieCutscene:FindCharlieHandSpawnPoint()
    self:CollectAtriumPillarsData()

    local back, side1, side2 = self.atrium_pillars.back:GetPosition(), self.atrium_pillars.side[1]:GetPosition(), self.atrium_pillars.side[2]:GetPosition()

    -- Find the inverse point of the back pillar.
    local pos = side1 + side2 - back

    return pos
end

function CharlieCutscene:SpawnCharlieHand()
    self.hand = SpawnPrefab("charlie_hand")

    self.inst.components.entitytracker:TrackEntity("charlie_hand", self.hand)
    self.hand.components.entitytracker:TrackEntity("atrium", self.inst)

    local spawn_pos = self:FindCharlieHandSpawnPoint()

    self.hand:Initialize(spawn_pos)
end

-----------------------------------------------------------------------------------------------

function CharlieCutscene:IsGateRepaired()
    return self._gatefixed
end

function CharlieCutscene:OnSave()
    if self._running then
        return {
            running = true
        }
    elseif self._gatefixed then
        return {
            gatefixed = true
        }
    end
end

function CharlieCutscene:OnLoad(data)
    if data ~= nil then
        if data.running then
            -- Just skip the cutscene!
            self:Finish()

            self._running = false
        end

        if data.running or data.gatefixed then
            self._gatefixed = true
            self.inst.AnimState:SetBuild("atrium_gate_build")

            local active = self.inst.components.pickable.caninteractwith or self.inst.components.worldsettingstimer:ActiveTimerExists("destabilizedelay")
            self.inst.MiniMapEntity:SetIcon(active and "atrium_gate_fixed_active.png" or "atrium_gate_fixed.png")
        end
    end
end

-----------------------------------------------------------------------------------------------

return CharlieCutscene