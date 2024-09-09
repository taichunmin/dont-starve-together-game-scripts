local BOAT_SPEED_MUSIC_THRESHOLD = 0.2

local function TestBoatMusic(inst)
    local self = inst.components.walkableplatformplayer
    if self then
        local boatpos = self.platform:GetPosition()
        local boatspeed = (boatpos - self.boatpos):LengthSq()
        if boatspeed >= BOAT_SPEED_MUSIC_THRESHOLD and (not self.boatspeed or self.boatspeed < BOAT_SPEED_MUSIC_THRESHOLD) then
            self.inst:PushEvent("playboatmusic")
        end
        self.boatspeed = boatspeed
        self.boatpos = boatpos
    end
end

local function BoatCam_ActiveFn(params, parent, best_dist_sq)
	local state = params.updater.state
    local tpos = params.target:GetPosition()
	state.last_platform_x, state.last_platform_z = tpos.x, tpos.z

	local pan_gain, heading_gain, distance_gain = TheCamera:GetGains()
	TheCamera:SetGains(1.5, heading_gain, distance_gain)
end

local function BoatCam_UpdateFn(dt, params, parent, best_dist_sq)
    local tpos = params.target:GetPosition()

	local state = params.updater.state
    local platform_x, platform_y, platform_z = tpos:Get()

    local velocity_x = dt == 0 and 0 or ((platform_x - state.last_platform_x) / dt)
	local velocity_z = dt == 0 and 0 or ((platform_z - state.last_platform_z) / dt)
    local velocity_normalized_x, velocity_normalized_z = 0, 0
    local velocity = 0
    local min_velocity = 0.4
    local velocity_sq = velocity_x * velocity_x + velocity_z * velocity_z

    if velocity_sq >= min_velocity * min_velocity then
        velocity = math.sqrt(velocity_sq)
        velocity_normalized_x = velocity_x / velocity
        velocity_normalized_z = velocity_z / velocity
        velocity = math.max(velocity - min_velocity, 0)
    end

    local look_ahead_max_dist = 5
    local look_ahead_max_velocity = 3
    local look_ahead_percentage = math.min(math.max(velocity / look_ahead_max_velocity, 0), 1)
    local look_ahead_amount = look_ahead_max_dist * look_ahead_percentage

    --Average target_camera_offset to get rid of some of the noise.
    state.target_camera_offset.x = (state.target_camera_offset.x + velocity_normalized_x * look_ahead_amount) / 2
    state.target_camera_offset.z = (state.target_camera_offset.z + velocity_normalized_z * look_ahead_amount) / 2

    state.last_platform_x, state.last_platform_z = platform_x, platform_z

    local camera_offset_lerp_speed = 0.25
    state.camera_offset.x, state.camera_offset.z = VecUtil_Lerp(state.camera_offset.x, state.camera_offset.z, state.target_camera_offset.x, state.target_camera_offset.z, dt * camera_offset_lerp_speed)

    TheCamera:SetOffset(state.camera_offset + (tpos - parent:GetPosition()))

    local pan_gain, heading_gain, distance_gain = TheCamera:GetGains()
    local pan_lerp_speed = 0.75
    pan_gain = Lerp(pan_gain, state.target_pan_gain, dt * pan_lerp_speed)

    TheCamera:SetGains(pan_gain, heading_gain, distance_gain)
end

local function EnableBoatCamera(inst, enabled)
    local self = inst.components.walkableplatformplayer
    if self then
        self.boat_camera_enabled = enabled
        if self.platform then
            if enabled then
                self:StartBoatCamera()
                self:StartBoatCameraZooms()
            else
                self:StopBoatCamera()
                self:StopBoatCameraZooms()
            end
        end
    end
end

local function EnableMovementPrediction(inst, enabled)
    local self = inst.components.walkableplatformplayer
    if self then
        self.movement_prediction_enabled = enabled
        if self.platform then
            if enabled then
                self.platform:AddPlatformFollower(self.inst)
                self.platform.components.walkableplatform:SpawnPlayerCollision()
            else
                self.platform.components.walkableplatform:DespawnPlayerCollision()
            end
        end
    end
end

--Boat camera zoom config variables.
local ZOOM_STEP = 0.25
local ZOOM_TARGET = 5
local ZOOM_TIME = 4

local NUM_ZOOMS = ZOOM_TARGET / ZOOM_STEP
local ZOOM_TASK_PERIOD = ZOOM_TIME / NUM_ZOOMS

local function player_zoom(inst, self)
    if inst and inst:IsValid() and self.player_zooms <= NUM_ZOOMS then
        inst:PushEvent("zoomcamera", {zoomout = self.player_zoomout, zoom = ZOOM_STEP})
        self.player_zooms = self.player_zooms + 1
    else
        self.player_zoom_task:Cancel()
        self.player_zoom_task = nil
    end
end

local function OnDoPlatformCameraZoomDirty(self, doplatformcamerazoom)
    self.player_zoomout = doplatformcamerazoom
    self.player_zooms = NUM_ZOOMS - self.player_zooms
    if not self.player_zoom_task then
        self.player_zoom_task = self.inst:DoPeriodicTask(ZOOM_TASK_PERIOD, player_zoom, nil, self)
    end
end

local function DoStartBoatCamera(inst)
    local self = inst.components.walkableplatformplayer
    if self and self.platform and not TheNet:IsDedicated() and self.inst == ThePlayer and self.boat_camera_enabled then
        self:StartBoatCamera()
    end
end

local WalkablePlatformPlayer = Class(function(self, inst)
    self.inst = inst
    self.boat_camera_enabled = false
    --self.platform = nil

    self.player_zoomed_out = false
    self.player_zooms = NUM_ZOOMS

    self._doplatformcamerazoomdirty = function(platform) OnDoPlatformCameraZoomDirty(self, platform.doplatformcamerazoom:value()) end
    inst:ListenForEvent("enableboatcamera", EnableBoatCamera)
    inst:ListenForEvent("enablemovementprediction", EnableMovementPrediction)
    inst:ListenForEvent("playeractivated", function(inst) inst:DoTaskInTime(0, function() DoStartBoatCamera(inst) end) end)
end)

function WalkablePlatformPlayer:StartBoatMusicTest()
    if not self.test_boat_speed_task then
        self.boatpos = self.platform:GetPosition()
        self.test_boat_speed_task = self.inst:DoPeriodicTask(0.5, TestBoatMusic)
    end
end

function WalkablePlatformPlayer:StopBoatMusicTest()
    if self.test_boat_speed_task then
        self.boatpos = nil
        self.test_boat_speed_task:Cancel()
        self.test_boat_speed_task = nil
    end
end

function WalkablePlatformPlayer:StartBoatCamera()
	local camera_settings =
	{
		state = {
			target_camera_offset = Vector3(0,1.5,0),
			camera_offset = Vector3(0,1.5,0),
			last_platform_x = 0, last_platform_z = 0,
			target_pan_gain = 4,
		},
		UpdateFn = BoatCam_UpdateFn,
		ActiveFn = BoatCam_ActiveFn,
	}

	TheFocalPoint.components.focalpoint:StartFocusSource(self.platform, nil, nil, math.huge, math.huge, -1, camera_settings)
end

function WalkablePlatformPlayer:StopBoatCamera()
    TheFocalPoint.components.focalpoint:StopFocusSource(self.platform)
end

function WalkablePlatformPlayer:StartBoatCameraZooms()
    self.inst:ListenForEvent("doplatformcamerazoomdirty", self._doplatformcamerazoomdirty, self.platform)
    if self.platform.doplatformcamerazoom:value() then
        OnDoPlatformCameraZoomDirty(self, true)
    end
end

function WalkablePlatformPlayer:StopBoatCameraZooms()
    self.inst:RemoveEventCallback("doplatformcamerazoomdirty", self._doplatformcamerazoomdirty, self.platform)
    if self.player_zoomout then
        OnDoPlatformCameraZoomDirty(self, false)
    end
end

function WalkablePlatformPlayer:GetOnPlatform(platform)
    self.platform = platform
    self.inst.Transform:SetIsOnPlatform(true)

    if TheWorld.ismastersim then
        platform.components.walkableplatform:AddPlayerOnPlatform(self.inst)
    end

    if self.movement_prediction_enabled then
        platform.components.walkableplatform:SpawnPlayerCollision()
    end

    if not TheNet:IsDedicated() and self.inst == ThePlayer then
        self.inst:PushEvent("got_on_platform", platform)

        self:StartBoatMusicTest()
        if self.boat_camera_enabled then
            self:StartBoatCameraZooms()
            self:StartBoatCamera()
        end
    end
end

function WalkablePlatformPlayer:GetOffPlatform()
    if not TheNet:IsDedicated() and self.inst == ThePlayer then
        if self.boat_camera_enabled then
            self:StopBoatCamera()
            self:StopBoatCameraZooms()
        end
        self:StopBoatMusicTest()

        self.inst:PushEvent("got_off_platform", self.platform)
    end

    if self.movement_prediction_enabled then
        self.platform.components.walkableplatform:DespawnPlayerCollision()
    end

    if TheWorld.ismastersim then
        self.platform.components.walkableplatform:RemovePlayerOnPlatform(self.inst)
    end

    self.inst.Transform:SetIsOnPlatform(false)
    self.platform = nil
end

function WalkablePlatformPlayer:TestForPlatform()
    if TheWorld.ismastersim then
        local platform = self.inst:GetCurrentPlatform()
        if self.platform ~= platform then
            if self.platform then
                self:GetOffPlatform()
            end
            if platform then
                self:GetOnPlatform(platform)
            end
        end
    elseif self.inst == ThePlayer then
        local x, y, z = self.inst.Transform:GetWorldPosition()
        local platform = TheWorld.Map:GetPlatformAtPoint(x, y, z)
        if self.platform ~= platform then
            if self.platform then
                if self.movement_prediction_enabled then
                    self.platform:RemovePlatformFollower(self.inst)
                end
                self:GetOffPlatform()
            end
            if platform then
                if self.movement_prediction_enabled then
                    platform:AddPlatformFollower(self.inst)
                end
                self:GetOnPlatform(platform)
            end
        end
    end
end

function WalkablePlatformPlayer:OnRemoveEntity()
    if self.platform then
        self.platform:RemovePlatformFollower(self.inst)
        self.platform.components.walkableplatform:RemovePlayerOnPlatform(self.inst)
        self.inst.Transform:SetIsOnPlatform(false)
        self.platform = nil
    end
end

WalkablePlatformPlayer.OnRemoveFromEntity = WalkablePlatformPlayer.OnRemoveEntity

return WalkablePlatformPlayer