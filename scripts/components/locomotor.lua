local SourceModifierList = require("util/sourcemodifierlist")

local DOZE_OFF_TIME = 2

local PATHFIND_PERIOD = 1
local PATHFIND_MAX_RANGE = 40

local STATUS_CALCULATING = 0
local STATUS_FOUNDPATH = 1
local STATUS_NOPATH = 2

local ARRIVE_STEP = .15

local MOVE_TIMER_STOP_THRESHOLD = .1 --seconds

local INVALID_PLATFORM_ID = "INVALID PLATFORM"

Dest = Class(function(self, inst, pt, buffered_action)
    self.inst = inst
    if pt ~= nil then
        self.pt = pt
    end
    self.buffered_action = buffered_action
end)

function Dest:IsValid()
    return self.inst == nil or self.inst:IsValid()
end

function Dest:__tostring()
    return (self.inst ~= nil and ("Going to Entity: "..tostring(self.inst)))
        or (self.pt ~= nil and ("Going to Point: "..tostring(self.pt)))
        or (self.buffered_action ~= nil and ("Going to buffered action point: "..tostring(self.buffered_action.pos)))
        or "No Dest"
end

function Dest:GetPoint()
    if self.inst ~= nil and self.inst:IsValid() then
        return self.inst.Transform:GetWorldPosition()
    elseif self.pt then
        return self.pt:Get()
    elseif self.buffered_action ~= nil then
        local act_pos = self.buffered_action:GetActionPoint()
        if act_pos ~= nil then
            return act_pos:Get()
        end
    end
    return 0, 0, 0
end

function Dest:GetPlatform()
    if self.inst ~= nil and self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner ~= nil then
        return self.inst.components.inventoryitem.owner:GetCurrentPlatform()
    elseif self.inst ~= nil then
        return self.inst:GetCurrentPlatform()
    elseif self.pt then
        return TheWorld.Map:GetPlatformAtPoint(self.pt:Get())
    elseif self.buffered_action ~= nil then
        local act_pos = self.buffered_action:GetActionPoint()
        if act_pos ~= nil then
            return TheWorld.Map:GetPlatformAtPoint(act_pos:Get())
        end
    end
    return nil
end

local function onrunspeed(self, runspeed)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.runspeed:set(runspeed)
    end
end

local function onexternalspeedmultiplier(self, externalspeedmultiplier)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.externalspeedmultiplier:set(externalspeedmultiplier)
    end
end

local function ServerRunSpeed(self)
    if self.inst.components.rider ~= nil then
        local mount = self.inst.components.rider:IsRiding() and self.inst.components.rider:GetMount() or nil
        if mount ~= nil then
            return mount.components.locomotor.runspeed
        end
    end
    return self.runspeed
end

local function ClientRunSpeed(self)
    local rider = self.inst.replica.rider
    local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
    if mount ~= nil then
        return rider:GetMountRunSpeed()
    end
    if self.inst.player_classified ~= nil then
        if self.predictrunspeed ~= nil and self.inst:HasTag("autopredict") then
            return self.predictrunspeed
        end
        return self.inst.player_classified.runspeed:value()
    end
    return self.runspeed
end

local function ServerFasterOnRoad(self)
    if self.inst.components.rider ~= nil then
        local mount = self.inst.components.rider:IsRiding() and self.inst.components.rider:GetMount() or nil
        if mount ~= nil then
            return mount.components.locomotor.fasteronroad
        end
    end
    return self.fasteronroad
end

local function ClientFasterOnRoad(self)
    local rider = self.inst.replica.rider
    local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
    if mount ~= nil then
        return rider:GetMountFasterOnRoad()
    end
    return self.fasteronroad
end

local function ServerFasterOnCreep(self)
    if self.inst.components.rider ~= nil then
        local mount = self.inst.components.rider:IsRiding() and self.inst.components.rider:GetMount() or nil
        if mount ~= nil then
            return false
        end
    end
    return self.fasteroncreep
end

local function ClientFasterOnCreep(self)
    local rider = self.inst.replica.rider
    local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
    if mount ~= nil then
        return false
    end
    return self.fasteroncreep
end

local function ServerExternalSpeedMutliplier(self)
    return self.externalspeedmultiplier
end

local function ClientExternalSpeedMultiplier(self)
	return (self.inst.player_classified and self.inst.player_classified.externalspeedmultiplier:value() or self.externalspeedmultiplier) * self:GetPredictExternalSpeedMultipler()
end

local function ServerGetSpeedMultiplier(self)
    local mult = self:ExternalSpeedMultiplier()
    if self.inst.components.inventory ~= nil then
        if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then
            local saddle = self.inst.components.rider:GetSaddle()
            if saddle ~= nil and saddle.components.saddler ~= nil then
                mult = mult * saddle.components.saddler:GetBonusSpeedMult()
            end
        elseif self.inst.components.inventory.isopen then
            --NOTE: Check if inventory is open because client GetEquips returns
            --      nothing if inventory is closed.
            --      Don't check visibility though.
			local is_mighty = self.inst.components.mightiness ~= nil and self.inst.components.mightiness:GetState() == "mighty"
            for k, v in pairs(self.inst.components.inventory.equipslots) do
                if v.components.equippable ~= nil then
					local item_speed_mult = v.components.equippable:GetWalkSpeedMult()
                    if is_mighty and item_speed_mult < 1 then
						item_speed_mult = 1
					end

                    mult = mult * item_speed_mult
                end
            end
        end
    end

    return mult * (self:TempGroundSpeedMultiplier() or self.groundspeedmultiplier) * self.throttle
end

local function ClientGetSpeedMultiplier(self)
    local mult = self:ExternalSpeedMultiplier()
    local inventory = self.inst.replica.inventory
    if inventory ~= nil then
        local rider = self.inst.replica.rider
        if rider ~= nil and rider:IsRiding() then
            local saddle = rider:GetSaddle()
            local inventoryitem = saddle ~= nil and saddle.replica.inventoryitem or nil
            if inventoryitem ~= nil then
                mult = mult * inventoryitem:GetWalkSpeedMult()
            end
        else
            --NOTE: GetEquips returns empty if inventory is closed! (Hidden still returns items.)
			local is_mighty = self.inst:HasTag("mightiness_mighty")
            for k, v in pairs(inventory:GetEquips()) do
                local inventoryitem = v.replica.inventoryitem
                if inventoryitem ~= nil then
					local item_speed_mult = inventoryitem:GetWalkSpeedMult()
                    if is_mighty and item_speed_mult < 1 then
						item_speed_mult = 1
					end

                    mult = mult * item_speed_mult
                end
            end
        end
    end

    return mult * (self:TempGroundSpeedMultiplier() or self.groundspeedmultiplier) * self.throttle
end

function ServerIsFasterOnGroundTile(self, ground_tile)
	if self.inst.player_classified == nil or not self.inst.player_classified.isghostmode:value() then
		local rider = self.inst.components.rider
		local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
		if mount ~= nil then
			return mount.components.locomotor ~= nil and mount.components.locomotor.faster_on_tiles[ground_tile]
        else
		    return self.faster_on_tiles[ground_tile] == true
        end
	end

	return false
end

function ClientIsFasterOnGroundTile(self, ground_tile)
	if self.inst.player_classified == nil or not self.inst.player_classified.isghostmode:value() then
		local rider = self.inst.replica.rider
		local mount = rider ~= nil and rider:IsRiding() and rider:GetMount() or nil
		if mount ~= nil then
			return mount:HasTag("turfrunner_"..tostring(ground_tile))
        else
		    return self.inst:HasTag("turfrunner_"..tostring(ground_tile))
        end
	end

	return false
end

local LocoMotor = Class(function(self, inst)
    self.inst = inst
    self.ismastersim = TheWorld.ismastersim

    if self.ismastersim then
        inst:AddTag("locomotor")
        self.RunSpeed = ServerRunSpeed
        self.FasterOnRoad = ServerFasterOnRoad
        self.FasterOnCreep = ServerFasterOnCreep
        self.ExternalSpeedMultiplier = ServerExternalSpeedMutliplier
        self.GetSpeedMultiplier = ServerGetSpeedMultiplier
		self.IsFasterOnGroundTile = ServerIsFasterOnGroundTile
    else
        self.RunSpeed = ClientRunSpeed
        self.FasterOnRoad = ClientFasterOnRoad
        self.FasterOnCreep = ClientFasterOnCreep
        self.ExternalSpeedMultiplier = ClientExternalSpeedMultiplier
        self.GetSpeedMultiplier = ClientGetSpeedMultiplier
		self.IsFasterOnGroundTile = ClientIsFasterOnGroundTile
        removesetter(self, "runspeed")
        removesetter(self, "externalspeedmultiplier")
    end

    self.dest = nil
    self.atdestfn = nil
    self.bufferedaction = nil
    self.arrive_step_dist = ARRIVE_STEP
    self.arrive_dist = ARRIVE_STEP
    self.walkspeed = TUNING.WILSON_WALK_SPEED -- 4
    self.runspeed = TUNING.WILSON_RUN_SPEED -- 6
    self.throttle = 1
    self.lastpos = {}
    self.slowmultiplier = 0.6
    self.fastmultiplier = 1.3
    self.movestarttime = -1
    self.movestoptime = -1
    --self.predictmovestarttime = nil
	--self.no_predict_fastforward = nil --see PlayerController:RepeatHeldAction()

    self.groundspeedmultiplier = 1.0
    self.enablegroundspeedmultiplier = true
    --self.tempgroundspeedmultiplier = nil
    --self.tempgroundspeedmulttime = nil
    --self.tempgroundtile = nil
    self.isrunning = false

    self._externalspeedmultipliers = {}
    self.externalspeedmultiplier = 1

    self.wasoncreep = false
    self.triggerscreep = true
    self.is_prediction_enabled = false
    self.hop_distance = TUNING.DEFAULT_LOCOMOTOR_HOP_DISTANCE
	--self.hop_distance_fn = nil
    self.hopping = false
    self.time_before_next_hop_is_allowed = 0
	--self.hop_delay = nil

    self.faster_on_tiles = {}

    --self.isupdating = nil
    --self.predictrunspeed = nil
	--self.predictexternalspeedmultiplier = nil
	--self.pusheventwithdirection = false --mainly for players, to handle initial move dir, and not have to add "canrotate" to all interruptible states
end,
nil,
{
    runspeed = onrunspeed,
    externalspeedmultiplier = onexternalspeedmultiplier,
})

function LocoMotor:EnableHopDelay(enable)
	if enable == false then
		self.hop_delay = nil
	elseif self.hop_delay == nil then
		self.hop_delay =
		{
			toplatform = nil,
			fromplatform = nil,
			starttick = -1,
			lasttick = -1,
		}
	end
end

function LocoMotor:StartUpdatingInternal()
    self.isupdating = true
    if not self.inst:IsAsleep() then
        self.inst:StartUpdatingComponent(self)
    end
end

function LocoMotor:StopUpdatingInternal()
    self.isupdating = nil
    self.inst:StopUpdatingComponent(self)
end

function LocoMotor:OnEntitySleep()
    self:Stop()
end

function LocoMotor:OnEntityWake()
    if self.isupdating then
        self.inst:StartUpdatingComponent(self)
    end
end

function LocoMotor:OnRemoveFromEntity()
    if self.ismastersim then
        self.inst:RemoveTag("locomotor")

		for ground_tile in pairs(self.faster_on_tiles) do
			self.inst:RemoveTag("turfrunner_"..tostring(ground_tile))
		end
    end
end

function LocoMotor:GetTimeMoving()
    local t = GetTime()
    if self.predictmovestarttime ~= nil then
        return t - self.predictmovestarttime
    elseif self.movestoptime ~= nil and t - self.movestoptime >= MOVE_TIMER_STOP_THRESHOLD then
        --stopped longer than threshold
        return 0
    end
    return t - self.movestarttime
end

function LocoMotor:StartMoveTimerInternal()
    if self.movestoptime ~= nil then
        local t = GetTime()
        if t - self.movestoptime >= MOVE_TIMER_STOP_THRESHOLD then
            self.movestarttime = t
        end
        self.movestoptime = nil
    end
end

function LocoMotor:StopMoveTimerInternal()
    if self.movestoptime == nil then
        self.movestoptime = GetTime()
    end
end

function LocoMotor:RestartPredictMoveTimer()
    self.predictmovestarttime = GetTime()
end

function LocoMotor:CancelPredictMoveTimer()
    self.predictmovestarttime = nil
end

function LocoMotor:StopMoving()
    self.isrunning = false
    self.inst.Physics:Stop()
end

--V2C: we always call this to recalculate even if only one value
--     changes, so we can always do custom math here
function LocoMotor:RecalculateExternalSpeedMultiplier(sources)
    local m = 1
    for source, src_params in pairs(sources) do
        for k, v in pairs(src_params.multipliers) do
            m = m * v
        end
    end
    return m
end

function LocoMotor:SetExternalSpeedMultiplier(source, key, m)
    if key == nil then
        return
    elseif m == nil or m == 1 then
        self:RemoveExternalSpeedMultiplier(source, key)
        return
    end
    local src_params = self._externalspeedmultipliers[source]
    if src_params == nil then
        self._externalspeedmultipliers[source] = {
            multipliers = { [key] = m },
            onremove = function(source)
                self._externalspeedmultipliers[source] = nil
                self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(self._externalspeedmultipliers)
            end,
        }
        self.inst:ListenForEvent("onremove", self._externalspeedmultipliers[source].onremove, source)
        self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(self._externalspeedmultipliers)
    elseif src_params.multipliers[key] ~= m then
        src_params.multipliers[key] = m
        self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(self._externalspeedmultipliers)
    end
end

--key is optional if you want to remove the entire source
function LocoMotor:RemoveExternalSpeedMultiplier(source, key)
    local src_params = self._externalspeedmultipliers[source]
    if src_params == nil then
        return
    elseif key ~= nil then
        src_params.multipliers[key] = nil
        if next(src_params.multipliers) ~= nil then
            --this source still has other keys
            self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(self._externalspeedmultipliers)
            return
        end
    end
    --remove the entire source
    self.inst:RemoveEventCallback("onremove", src_params.onremove, source)
    self._externalspeedmultipliers[source] = nil
    self.externalspeedmultiplier = self:RecalculateExternalSpeedMultiplier(self._externalspeedmultipliers)
end

--key is optional if you want to calculate the entire source
function LocoMotor:GetExternalSpeedMultiplier(source, key)
    local src_params = self._externalspeedmultipliers[source]
    if src_params == nil then
        return 1
    elseif key == nil then
        local m = 1
        for k, v in pairs(src_params.multipliers) do
            m = m * v
        end
        return m
    end
    return src_params.multipliers[key] or 1
end

function LocoMotor:SetPredictExternalSpeedMultiplier(source, key, m)
	if not self.predictexternalspeedmultiplier then
		self.predictexternalspeedmultiplier = SourceModifierList(self.inst)
	end
	self.predictexternalspeedmultiplier:SetModifier(source, m, key)
end

--key is optional if you want to remove the entire source
function LocoMotor:RemovePredictExternalSpeedMultiplier(source, key)
	if self.predictexternalspeedmultiplier then
		self.predictexternalspeedmultiplier:RemoveModifier(source, key)
	end
end

--key is optional if you want to calculate the entire source
function LocoMotor:GetPredictExternalSpeedMultipler(source, key)
	return self.predictexternalspeedmultiplier and self.predictexternalspeedmultiplier:Get() or 1
end

function LocoMotor:SetSlowMultiplier(m)
    self.slowmultiplier = m
end

function LocoMotor:SetTriggersCreep(triggers)
    self.triggerscreep = triggers
end

function LocoMotor:SetFasterOnCreep(faster)
    self.fasteroncreep = faster
end

function LocoMotor:EnableGroundSpeedMultiplier(enable)
    self.enablegroundspeedmultiplier = enable
    if not enable then
        self.groundspeedmultiplier = 1
        self.tempgroundspeedmultiplier = nil
        self.tempgroundspeedmulttime = nil
        self.tempgroundtile = nil
    end
end

function LocoMotor:GetWalkSpeed()
    return self.walkspeed * self:GetSpeedMultiplier()
end

function LocoMotor:GetRunSpeed()
    return self:RunSpeed() * self:GetSpeedMultiplier()
end

function LocoMotor:SetFasterOnGroundTile(ground_tile, is_faster)
	if self.ismastersim then
		self.faster_on_tiles[ground_tile] = is_faster
        self.inst:AddOrRemoveTag("turfrunner_"..tostring(ground_tile), is_faster)
	end
end

function LocoMotor:UpdateGroundSpeedMultiplier()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local oncreep = TheWorld.GroundCreep:OnCreep(x, y, z)

    if oncreep and self.triggerscreep then
        -- if this ever needs to happen when self.enablegroundspeedmultiplier is set, need to move the check for self.enablegroundspeedmultiplier above
        if not self.wasoncreep then
            local spawners = TheWorld.GroundCreep:GetTriggeredCreepSpawners(x, y, z)
            local eventdata = { target = self.inst, spawners = spawners, }
            for _, v in ipairs(spawners) do
                v:PushEvent("creepactivate", eventdata)
            end
            self.inst:PushEvent("walkoncreep", eventdata)
            self.wasoncreep = true
        end
        self.groundspeedmultiplier = self.slowmultiplier
    else
        if self.wasoncreep and self.triggerscreep then
            self.inst:PushEvent("walkoffcreep")
        end
        self.wasoncreep = false

        local current_ground_tile = TheWorld.Map:GetTileAtPoint(x, 0, z)
        self.groundspeedmultiplier = (self:IsFasterOnGroundTile(current_ground_tile) or 
                                     (self:FasterOnRoad() and ((RoadManager ~= nil and RoadManager:IsOnRoad(x, 0, z)) or GROUND_ROADWAYS[current_ground_tile])) or
                                     (oncreep and self:FasterOnCreep()))
									 and self.fastmultiplier
									 or 1
    end
end

function LocoMotor:PushTempGroundSpeedMultiplier(mult, tile)
    if self.enablegroundspeedmultiplier then
        local t = GetTime()
        if self.tempgroundspeedmultiplier == nil or
            t > self.tempgroundspeedmulttime or
            mult <= self.tempgroundspeedmultiplier then
            self.tempgroundspeedmultiplier = mult
            self.tempgroundtile = tile
        end
        self.tempgroundspeedmulttime = t
    end
end

function LocoMotor:TempGroundSpeedMultiplier()
    if self.tempgroundspeedmultiplier ~= nil then
        if self.tempgroundspeedmulttime + 0.034 > GetTime() then
            return self.tempgroundspeedmultiplier
        end
        self.tempgroundspeedmultiplier = nil
        self.tempgroundspeedmulttime = nil
        self.tempgroundtile = nil
    end
end

function LocoMotor:TempGroundTile()
    if self.tempgroundtile ~= nil then
        if self.tempgroundspeedmulttime + 0.034 > GetTime() then
            return self.tempgroundtile
        end
        self.tempgroundspeedmultiplier = nil
        self.tempgroundspeedmulttime = nil
        self.tempgroundtile = nil
    end
end

function LocoMotor:StartStrafing()
	if self.ismastersim and not self.inst.player_classified.isstrafing:value() then
		self:SetStrafing(true)
		self.inst.player_classified.isstrafing:set(true)
		self.inst:PushEvent("startstrafing")
	end
end

function LocoMotor:StopStrafing()
	if self.ismastersim and self.inst.player_classified.isstrafing:value() then
		self:SetStrafing(false)
		self.inst.player_classified.isstrafing:set(false)
		self.inst:PushEvent("stopstrafing")
	end
end

function LocoMotor:SetStrafing(strafing)
	if not strafing then
		self.strafedir = nil
	elseif self.strafedir == nil then
		self.strafedir = self.inst.Transform:GetRotation()
	end
end

function LocoMotor:SetMoveDir(dir)
	if self.strafedir then
		self.strafedir = dir
	else
		self.inst.Transform:SetRotation(dir)
	end
end

function LocoMotor:FaceMovePoint(x, y, z)
	if self.strafedir == nil then
		self.inst:FacePoint(x, y, z)
	elseif not (self.inst.sg and self.inst.sg:HasStateTag("busy")) then
		self.strafedir = self.inst:GetAngleToPoint(x, y, z)
	end
end

local function SetMotorVelRelToStrafeDir(inst, speed, dir, strafedir)
	local angle = (strafedir - dir) * DEGREES
	inst.Physics:SetMotorVel(speed * math.cos(angle), 0, -speed * math.sin(angle))
end

function LocoMotor:SetMotorSpeed(speed)
	if self.strafedir then
		SetMotorVelRelToStrafeDir(self.inst, speed, self.inst.Transform:GetRotation(), self.strafedir)
	else
		self.inst.Physics:SetMotorVel(speed, 0, 0)
	end
end

function LocoMotor:OnStrafeFacingChanged(dir)
	if self.strafedir and dir ~= self.inst.Transform:GetRotation() then
		self.inst.Transform:SetRotation(dir)
		SetMotorVelRelToStrafeDir(self.inst, self.inst.Physics:GetMotorSpeed(), dir, self.strafedir)
	end
end

function LocoMotor:WalkForward(direct)
    self.isrunning = false
    if direct then self.wantstomoveforward = true end
	self:SetMotorSpeed(self:GetWalkSpeed())
    self:StartUpdatingInternal()
end

function LocoMotor:RunForward(direct)
    self.isrunning = true
    if direct then self.wantstomoveforward = true end
	self:SetMotorSpeed(self:GetRunSpeed())
    self:StartUpdatingInternal()
end

function LocoMotor:Clear()
    --Print(VERBOSITY.DEBUG, "LocoMotor:Clear", self.inst.prefab)
    self.dest = nil
    self.atdestfn = nil
    self.wantstomoveforward = nil
    self.wantstorun = nil
    self.bufferedaction = nil
    --self:ResetPath()
end

function LocoMotor:ResetPath()
    --Print(VERBOSITY.DEBUG, "LocoMotor:ResetPath", self.inst.prefab)
    self:KillPathSearch()
    self.path = nil
end

function LocoMotor:KillPathSearch()
    --Print(VERBOSITY.DEBUG, "LocoMotor:KillPathSearch", self.inst.prefab)
    if self:WaitingForPathSearch() then
        TheWorld.Pathfinder:KillSearch(self.path.handle)
    end
end

function LocoMotor:SetReachDestinationCallback(fn)
    self.atdestfn = fn
end

function LocoMotor:PreviewAction(bufferedaction, run, try_instant)
    if bufferedaction == nil then
        return
    end

    if bufferedaction.action.pre_action_cb ~= nil then
        bufferedaction.action.pre_action_cb(bufferedaction)
    end

    self.throttle = 1
    self:Clear()
    local action_pos = bufferedaction:GetActionPoint()

    if bufferedaction.action == ACTIONS.WALKTO then
        if bufferedaction.target ~= nil then
            self:GoToEntity(bufferedaction.target, bufferedaction, run)
        elseif action_pos ~= nil then
            self:GoToPoint(nil, bufferedaction, run)
        end
    elseif bufferedaction.action == ACTIONS.LOOKAT and
        self.inst.sg ~= nil and
        self.inst.components.playercontroller ~= nil and
        not self.inst.components.playercontroller.directwalking then
		if self.inst.sg:HasStateTag("overridelocomote") then
			self.inst:PreviewBufferedAction(bufferedaction)
		else
			local closeinspect = false
			if bufferedaction.target then
				if CLOSEINSPECTORUTIL.CanCloseInspect(self.inst, bufferedaction.target) then
					closeinspect = true
					self:GoToEntity(bufferedaction.target, bufferedaction, run)
				end
			elseif action_pos then
				if CLOSEINSPECTORUTIL.CanCloseInspect(self.inst, action_pos) then
					closeinspect = true
					self:GoToPoint(nil, bufferedaction, run)
				end
			end
			if not closeinspect then
				self:Stop()

				--V2C: since LOOKAT now has an action handler for closeinspect support,
				--     we can use options.instant to bypass it during preview.
				--     see EntityScript:PreviewBufferedAction
				bufferedaction.options.instant = true

				if bufferedaction.target ~= nil then
					self:FaceMovePoint(bufferedaction.target.Transform:GetWorldPosition())
				end
				if not self.inst.sg:HasStateTag("idle") then
					local idle_anim = self.inst:HasTag("playerghost") and "idle" or "idle_loop"
					if not self.inst.AnimState:IsCurrentAnimation(idle_anim) then
						self.inst.AnimState:PlayAnimation(idle_anim, true)
					end
				end
				self.inst:PreviewBufferedAction(bufferedaction)
				self.inst.sg:GoToState("idle", "noanim")
			end
		end
    elseif bufferedaction.forced then
        if action_pos ~= nil then
            self:GoToPoint(nil, bufferedaction, run)
        end
	elseif bufferedaction.action.instant or bufferedaction.action.do_not_locomote or bufferedaction.options.instant then
        self.inst:PreviewBufferedAction(bufferedaction)
    elseif bufferedaction.target ~= nil then
		local inventoryitem = bufferedaction.target.replica.inventoryitem
		local owner = inventoryitem ~= nil and inventoryitem:IsHeld() and bufferedaction.target.entity:GetParent() or nil
		if owner ~= nil and owner:HasTag("pocketdimension_container") then
			--don't try to walk to this container at (0, 0, 0)
			self:FaceMovePoint(bufferedaction.target.Transform:GetWorldPosition())
			self.inst:PushBufferedAction(bufferedaction)
		elseif bufferedaction.distance ~= nil and bufferedaction.distance >= math.huge then
            --essentially instant
			self:FaceMovePoint(bufferedaction.target.Transform:GetWorldPosition())
            self.inst:PreviewBufferedAction(bufferedaction)
        else
            self:GoToEntity(bufferedaction.target, bufferedaction, run)
        end
    elseif action_pos == nil then
        self.inst:PreviewBufferedAction(bufferedaction)
    elseif bufferedaction.action == ACTIONS.CASTAOE then
        if self.inst:GetDistanceSqToPoint(action_pos) <= bufferedaction.distance * bufferedaction.distance then
			self:FaceMovePoint(action_pos:Get())
            self.inst:PreviewBufferedAction(bufferedaction)
        else
            self:GoToPoint(nil, bufferedaction, run)
            if self.bufferedaction == bufferedaction then
                self.inst:PushEvent("bufferedcastaoe", bufferedaction)
            end
        end
    elseif bufferedaction.distance ~= nil and bufferedaction.distance >= math.huge then
        --essentially instant
		self:FaceMovePoint(action_pos:Get())
        self.inst:PreviewBufferedAction(bufferedaction)
    else
        self:GoToPoint(nil, bufferedaction, run)
    end
end

function LocoMotor:PushAction(bufferedaction, run, try_instant)
    if bufferedaction == nil then
        return
	elseif self.inst.components.playercontroller ~= nil then
		self.inst.components.playercontroller:OnRemoteBufferedAction()
	end

	--V2C: see PlayerController:RepeatHeldAction()
	if self.no_predict_fastforward then
		bufferedaction.options.no_predict_fastforward = true
	end

    if bufferedaction.action.pre_action_cb ~= nil then
        bufferedaction.action.pre_action_cb(bufferedaction)
    end

    self.throttle = 1
    local success, reason = bufferedaction:TestForStart()
    if not success then
        self.inst:PushEvent("actionfailed", { action = bufferedaction, reason = reason })
        return
    end

    self:Clear()
    local action_pos = bufferedaction:GetActionPoint()
    if bufferedaction.action == ACTIONS.WALKTO then
        if bufferedaction.target ~= nil then
            self:GoToEntity(bufferedaction.target, bufferedaction, run)
        elseif action_pos then
            self:GoToPoint(nil, bufferedaction, run)
        else
            return
        end
    elseif bufferedaction.action == ACTIONS.LOOKAT and
        self.inst.components.playercontroller ~= nil then
		local closeinspect = false
		if bufferedaction.target then
			if CLOSEINSPECTORUTIL.CanCloseInspect(self.inst, bufferedaction.target) then
				closeinspect = true
				self:GoToEntity(bufferedaction.target, bufferedaction, run)
			end
		elseif action_pos then
			if CLOSEINSPECTORUTIL.CanCloseInspect(self.inst, action_pos) then
				closeinspect = true
				self:GoToPoint(nil, bufferedaction, run)
			end
		end
		if not closeinspect then
			local pos = self.inst.components.playercontroller:GetRemotePredictPosition()
			if pos and not self.inst.components.playercontroller.directwalking then
				self:GoToPoint(pos, bufferedaction, run)
			else
				self.inst:PushBufferedAction(bufferedaction)
			end
		end
    elseif bufferedaction.forced then
        if bufferedaction.action.rangecheckfn ~= nil and
            not bufferedaction.action.rangecheckfn(bufferedaction.doer, bufferedaction.target) then
            bufferedaction.target = nil
            bufferedaction.initialtargetowner = nil
        end
        if action_pos ~= nil then
            self:GoToPoint(nil, bufferedaction, run, bufferedaction.overridedest)
        end
	elseif bufferedaction.action.instant or bufferedaction.action.do_not_locomote or bufferedaction.options.instant then
        self.inst:PushBufferedAction(bufferedaction)
    elseif bufferedaction.target ~= nil then
		local owner = bufferedaction.target.components.inventoryitem ~= nil and bufferedaction.target.components.inventoryitem.owner or nil
		if owner ~= nil and owner:HasTag("pocketdimension_container") then
			--don't try to walk to this container at (0, 0, 0)
			self:FaceMovePoint(bufferedaction.target.Transform:GetWorldPosition())
			self.inst:PushBufferedAction(bufferedaction)
		elseif bufferedaction.distance ~= nil and bufferedaction.distance >= math.huge then
            --essentially instant
			self:FaceMovePoint(bufferedaction.target.Transform:GetWorldPosition())
            self.inst:PushBufferedAction(bufferedaction)
        else
            self:GoToEntity(bufferedaction.target, bufferedaction, run)
        end
    elseif action_pos == nil then
        self.inst:PushBufferedAction(bufferedaction)
    elseif bufferedaction.action == ACTIONS.CASTAOE then
        if self.inst:GetDistanceSqToPoint(action_pos) <= bufferedaction.distance * bufferedaction.distance then
			self:FaceMovePoint(action_pos:Get())
            self.inst:PushBufferedAction(bufferedaction)
        else
            self:GoToPoint(nil, bufferedaction, run)
            if self.bufferedaction == bufferedaction then
                self.inst:PushEvent("bufferedcastaoe", bufferedaction)
            end
        end
    elseif bufferedaction.distance ~= nil and bufferedaction.distance >= math.huge then
        --essentially instant
		self:FaceMovePoint(action_pos:Get())
        self.inst:PushBufferedAction(bufferedaction)
    else
        self:GoToPoint(nil, bufferedaction, run)
    end
end

function LocoMotor:GoToEntity(target, bufferedaction, run)
    self.dest = Dest(target)
    self.throttle = 1

    self:CancelPredictMoveTimer() --if we reach here, means client is not predicting

    self:SetBufferedAction(bufferedaction)
    self.wantstomoveforward = true

    local arrive_dist

    if bufferedaction ~= nil and bufferedaction.arrivedist ~= nil then
        arrive_dist = bufferedaction.arrivedist

    elseif bufferedaction ~= nil and bufferedaction.distance ~= nil then
        --NOTE: use actual physics (ignoring physicsradiusoverride)
        --      as fallback if bufferedaction.distance is too small
		local owner = target.components.inventoryitem and target.components.inventoryitem:GetGrandOwner() or target
		arrive_dist = ARRIVE_STEP + (owner.Physics and owner.Physics:GetRadius() or 0) + self.inst.Physics:GetRadius()
        arrive_dist = math.max(arrive_dist, bufferedaction.distance)

    else
		local owner = target.components.inventoryitem and target.components.inventoryitem:GetGrandOwner() or target
		arrive_dist = ARRIVE_STEP + owner:GetPhysicsRadius(0) + self.inst:GetPhysicsRadius(0)

        local extra_arrive_dist = (bufferedaction ~= nil and bufferedaction.action ~= nil and bufferedaction.action.extra_arrive_dist) or nil
        if extra_arrive_dist ~= nil then
            arrive_dist = arrive_dist + extra_arrive_dist(self.inst, self.dest)
        end

        if bufferedaction ~= nil and bufferedaction.action.mindistance ~= nil and bufferedaction.action.mindistance > arrive_dist then
            arrive_dist = bufferedaction.action.mindistance
        end
    end

    self.arrive_dist = arrive_dist

    if self.directdrive then
        if run then
            self:RunForward()
        else
            self:WalkForward()
        end
    else
        self:FindPath()
    end

    self.wantstorun = run
    --self.arrive_step_dist = ARRIVE_STEP
    self:StartUpdatingInternal()

	--Try instant arrive check if we're not moving
	if not (self.inst.sg and self.inst.sg:HasStateTag("moving")) then
		self:OnUpdate(0, true)
	end
end

--V2C: Added overridedest for additional network controller support
function LocoMotor:GoToPoint(pt, bufferedaction, run, overridedest)
    self.dest = Dest(overridedest, pt, bufferedaction)
    self.throttle = 1

    self:CancelPredictMoveTimer() --if we reach here, means client is not predicting

    self.arrive_dist =
        bufferedaction ~= nil
        and (bufferedaction.arrivedist or bufferedaction.distance or math.max(bufferedaction.action.mindistance or 0, ARRIVE_STEP))
        or ARRIVE_STEP

    local extra_arrive_dist = (bufferedaction ~= nil and bufferedaction.action ~= nil and bufferedaction.action.extra_arrive_dist) or nil
    if extra_arrive_dist ~= nil then
        self.arrive_dist = self.arrive_dist + extra_arrive_dist(self.inst, self.dest, bufferedaction)
    end

    --self.arrive_step_dist = ARRIVE_STEP
    self.wantstorun = run

    if self.directdrive then
        if run then
            self:RunForward()
        else
            self:WalkForward()
        end
    else
        self:FindPath()
    end
    self.wantstomoveforward = true
    self:SetBufferedAction(bufferedaction)
    self:StartUpdatingInternal()

	--Try instant arrive check if we're not moving
	if not (self.inst.sg and self.inst.sg:HasStateTag("moving")) then
		self:OnUpdate(0, true)
	end
end

function LocoMotor:SetBufferedAction(act)
    if self.bufferedaction ~= nil then
        self.bufferedaction:Fail()
    end
    self.bufferedaction = act
    if self.allow_platform_hopping then
        self.last_platform_visited = INVALID_PLATFORM_ID
    end
	if act ~= nil and self.inst.components.playercontroller ~= nil then
		self.inst.components.playercontroller:OnLocomotorBufferedAction(act)
	end
end

function LocoMotor:Stop(sgparams)
    --Print(VERBOSITY.DEBUG, "LocoMotor:Stop", self.inst.prefab)
    self.isrunning = false
    self.dest = nil
    self:ResetPath()
    self.lastdesttile = nil
    --self.arrive_step_dist = 0

    --self:SetBufferedAction(nil)
    self.wantstomoveforward = false
    self.wantstorun = false

    if self.softstop and self.inst.sg ~= nil and self.inst.sg:HasStateTag("softstop") then
        self.isrunning = false
        --Let stategraph handle stopping physics
        --self.inst.Physics:Stop()
    else
        self:StopMoveTimerInternal()
        self:StopMoving()
    end

    self.inst:PushEvent("locomote", sgparams)
    self:StopUpdatingInternal()
end

function LocoMotor:WalkInDirection(direction, should_run)
    --Print(VERBOSITY.DEBUG, "LocoMotor:WalkInDirection ", self.inst.prefab)
    self:SetBufferedAction(nil)
    if not self.inst.sg or self.inst.sg:HasStateTag("canrotate") then
		self:SetMoveDir(direction)
    end

    self.wantstomoveforward = true
    self.wantstorun = should_run
    self:ResetPath()
    self.lastdesttile = nil

    if self.directdrive then
        self:WalkForward()
    end
	self.inst:PushEvent("locomote", self.pusheventwithdirection and { dir = direction } or nil)
    self:StartUpdatingInternal()
end

function LocoMotor:RunInDirection(direction, throttle)
    --Print(VERBOSITY.DEBUG, "LocoMotor:RunInDirection ", self.inst.prefab)

    self.throttle = throttle or 1

    self:SetBufferedAction(nil)
    self.dest = nil
    self:ResetPath()
    self.lastdesttile = nil

    if not self.inst.sg or self.inst.sg:HasStateTag("canrotate") then
		self:SetMoveDir(direction)
    end

    self.wantstomoveforward = true
    self.wantstorun = true

    if self.directdrive then
        self:RunForward()
    end
	self.inst:PushEvent("locomote", self.pusheventwithdirection and { dir = direction } or nil)
    self:StartUpdatingInternal()
end

function LocoMotor:GetDebugString()
    local pathtile_x = -1
    local pathtile_y = -1
    local tile_x = -1
    local tile_y = -1
    local ground = TheWorld
    if ground then
        pathtile_x, pathtile_y = ground.Pathfinder:GetPathTileIndexFromPoint(self.inst.Transform:GetWorldPosition())
        tile_x, tile_y = ground.Map:GetTileCoordsAtPoint(self.inst.Transform:GetWorldPosition())
    end
    local state = self.wantstorun and "RUN" or "WALK"
    return string.format("%s, (%0.2f) [%s] [%s] (%u, %u):(%u, %u) +/-%2.2f", state, self.wantstorun and self:GetRunSpeed() or self:GetWalkSpeed(), tostring(self.dest), tostring(self.bufferedaction), tile_x, tile_y, pathtile_x, pathtile_y, self.arrive_step_dist or 0)
end

function LocoMotor:HasDestination()
    return self.dest ~= nil
end

function LocoMotor:SetShouldRun(should_run)
    self.wantstorun = should_run
end

function LocoMotor:WantsToRun()
    return self.wantstorun == true
end

function LocoMotor:WantsToMoveForward()
    return self.wantstomoveforward == true
end

function LocoMotor:WaitingForPathSearch()
    return self.path and self.path.handle
end

function LocoMotor:UpdateHopping(dt) -- deprecated
    --self.inst.Physics:Stop()
end

function LocoMotor:FinishHopping()
    self.hopping = false
end

function LocoMotor:SetAllowPlatformHopping(enabled)
    self.allow_platform_hopping = enabled
    if enabled then
        self.last_platform_visited = INVALID_PLATFORM_ID
    end
end

function LocoMotor:CheckEdge(my_platform, map, my_x, my_z, dir_x, dir_z, radius)
    local pt_x, pt_z = my_x + dir_x * radius, my_z + dir_z * radius
    local platform = map:GetPlatformAtPoint(pt_x, pt_z)
    local is_water = not map:IsVisualGroundAtPoint(pt_x, 0, pt_z)
    return (is_water and platform == nil) or platform ~= my_platform
end

function LocoMotor:IsAtEdge(my_platform, map, my_x, my_z, dir_x, dir_z)
    local radius = self.inst.Physics:GetRadius()
    local edge_range = 0.25
    return self:CheckEdge(my_platform, map, my_x, my_z, dir_x, dir_z, radius) or
           self:CheckEdge(my_platform, map, my_x, my_z, dir_x, dir_z, radius - edge_range) or
           self:CheckEdge(my_platform, map, my_x, my_z, dir_x, dir_z, radius + edge_range)
end

function LocoMotor:GetHopDistance(speed_mult)
	return self.hop_distance_fn ~= nil and self.hop_distance_fn(self.inst, speed_mult or 1) or self.hop_distance
end

local WALL_TAGS = { "wall" }
function LocoMotor:ScanForPlatformInDir(my_platform, map, my_x, my_z, dir_x, dir_z, steps, step_size)
    local is_at_edge = self:IsAtEdge(my_platform, map, my_x, my_z, dir_x, dir_z)
    local is_first_hop_point = true
    for i = 1,steps do
        local pt_x, pt_z = my_x + dir_x * i * step_size, my_z + dir_z * i * step_size
        local platform = map:GetPlatformAtPoint(pt_x, pt_z)

        -- prevent jumping back onto the same platform because if you click an action and land near the edge of a platform
        -- you would sometimes turn around and jump right back
        if not (self.last_platform_visited == platform) then
            local is_water = not map:IsVisualGroundAtPoint(pt_x, 0, pt_z)
            if not is_water then
                --search for nearby walls and fences with active physics.
                for _, v in ipairs(TheSim:FindEntities(math.floor(pt_x), 0, math.floor(pt_z), 1, WALL_TAGS)) do
                    if v ~= self.inst and
                    v.entity:IsVisible() and
                    v.components.placer == nil and
                    v.entity:GetParent() == nil and
                    v.Physics:IsActive() then
                        return false, 0, 0, nil
                    end
                end
            end
            --print(i, is_at_edge, my_platform, platform, pt_x - my_x, pt_z - my_z, is_water, step_size)
            if is_at_edge and platform ~= my_platform then
                if platform ~= nil or not is_water then
					if self.hop_delay and self.dest == nil then
						--keep pushing toward the same direction during the delay before the hop is actually triggered
                        local platform_delay = math.max(
							platform and platform.components.platformhopdelay and platform.components.platformhopdelay:GetDelayTicks() or 0,
							my_platform and my_platform.components.platformhopdelay and my_platform.components.platformhopdelay:GetDelayTicks() or 0
						)
						local delay = platform_delay > 0 and platform_delay or self.inst.forced_platformhopdelay or TUNING.PLATFORM_HOP_DELAY_TICKS
						if delay > 0 then
							--detect boat bridges (only from boat->boat)
							local is_boat_bridge = false
							if platform and my_platform then
								--boatringdata is available on clients!
								local vx, vy, vz = platform.Physics:GetVelocity()
								if vx == 0 and vy == 0 and vz == 0 and not (platform.components.boatringdata and platform.components.boatringdata:IsRotating()) then
									vx, vy, vz = my_platform.Physics:GetVelocity()
									if vx == 0 and vy == 0 and vz == 0 and not (my_platform.components.boatringdata and my_platform.components.boatringdata:IsRotating()) then
										is_boat_bridge = true
									end
								end
							end

							if not is_boat_bridge then
								local tick = GetTick()
								if platform ~= self.hop_delay.toplatform or my_platform ~= self.hop_delay.fromplatform or tick > self.hop_delay.lasttick + 1 then
									self.hop_delay.toplatform = platform
									self.hop_delay.fromplatform = my_platform
									self.hop_delay.starttick = tick
								end
								self.hop_delay.lasttick = tick
								if tick - self.hop_delay.starttick < delay then
									return false, 0, 0, nil
								end
							end
						end
					end
                    --print("SUCCESS!")
                    if is_first_hop_point then
                        is_first_hop_point = false
                    else
                        return true, pt_x, pt_z, platform
                    end
                end
            end
        end
    end
    return false, 0, 0, nil
end

local PLATFORM_SCAN_STEP_SIZE = 0.5
local PLATFORM_SCAN_LANDING_RANGE = 1
local BLOCKER_TAGS = {"blocker"}
function LocoMotor:TestForBlocked(my_x, my_z, dir_x, dir_z, radius, test_length)
    local step_count = (test_length + PLATFORM_SCAN_LANDING_RANGE) / PLATFORM_SCAN_STEP_SIZE
    for i = 1, step_count do
        local step_amount = i * PLATFORM_SCAN_STEP_SIZE
        local pt_x, pt_z = my_x + dir_x * step_amount, my_z + dir_z * step_amount
        if #TheSim:FindEntities(pt_x, 0, pt_z, radius + PLATFORM_SCAN_STEP_SIZE, BLOCKER_TAGS) > 0 then
            return true
        end
    end

    return false
end

function LocoMotor:ScanForPlatform(my_platform, target_x, target_z, hop_distance)
    local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
    local dir_x, dir_z = target_x - my_x, target_z - my_z
    local dir_length = VecUtil_Length(dir_x, dir_z)
    dir_x, dir_z = dir_x / dir_length, dir_z / dir_length

    local step_count = math.min(dir_length + PLATFORM_SCAN_LANDING_RANGE, hop_distance) / PLATFORM_SCAN_STEP_SIZE

    local can_hop, px, pz, found_platform = self:ScanForPlatformInDir(my_platform, TheWorld.Map, my_x, my_z, dir_x, dir_z, step_count, PLATFORM_SCAN_STEP_SIZE)
    local blocked = false
    if can_hop then
        -- If we found a place to hop to, we need to check that our path is clear of obstacles.
        local path_x, path_z = px - my_x, pz - my_z

        local p_length = VecUtil_Length(path_x, path_z)

        -- Awkwardly, when we hop to platforms, we hop towards the center, despite getting a px/pz that does not reflect that.
        -- So, we need to quickly calculate the actual center-boat direction to test with.
        local platform_dir_x, platform_dir_z = nil, nil
        if found_platform and found_platform.Transform then
            local platform_x, _, platform_z = found_platform.Transform:GetWorldPosition()
            platform_dir_x, platform_dir_z = VecUtil_Normalize(platform_x - my_x, platform_z - my_z)
        else
            platform_dir_x, platform_dir_z = path_x / p_length, path_z / p_length
        end

        --[[
        if self:TestForBlocked(my_x, my_z, platform_dir_x, platform_dir_z, self.inst:GetPhysicsRadius(0), p_length) then
            can_hop = false
            blocked = true
        end
        ]]--
    end

    return can_hop, px, pz, found_platform, blocked
end

function LocoMotor:StartHopping(x,z,target_platform)
    local embarker = self.inst.components.embarker
    if embarker ~= nil then
        if target_platform ~= nil then
            embarker:SetEmbarkable(target_platform)
        else
            embarker:SetDisembarkPos(x, z)
        end
        if not self.inst.sg:HasStateTag("jumping") then
            self.inst:PushEvent("onhop")
        end
    end

    self.hopping = true

    -- Don't allow the player to hop for another ~200ms. This is to give the server a little bit of time to land it's hop before the client starts hopping again.
    -- This also solves an issue where the player controller which polls for hops has time to poll and realize that the first hop is done before the second on starts.
    self.time_before_next_hop_is_allowed = 0.2
end

function LocoMotor:OnUpdate(dt, arrive_check_only)
    if self.hopping then
        --self:UpdateHopping(dt)
        return
    end

    if not self.inst:IsValid() then
        Print(VERBOSITY.DEBUG, "OnUpdate INVALID", self.inst.prefab)
        self:ResetPath()
        self:StopUpdatingInternal()
        self:StopMoveTimerInternal()
        return
    end

	if self.enablegroundspeedmultiplier and not arrive_check_only then
        local x, y, z = self.inst.Transform:GetWorldPosition()
        local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(x, 0, z)
        if tx ~= self.lastpos.x or ty ~= self.lastpos.y then
            self:UpdateGroundSpeedMultiplier()
            self.lastpos = { x = tx, y = ty }
        end
    end

	local facedir

    --Print(VERBOSITY.DEBUG, "OnUpdate", self.inst.prefab)
    if self.dest then
        --Print(VERBOSITY.DEBUG, "    w dest")
        if not self.dest:IsValid() or (self.bufferedaction and not self.bufferedaction:IsValid()) then
            self:Clear()
            return
        end

        if self.inst.components.health and self.inst.components.health:IsDead() then
            self:Clear()
            return
        end

        local destpos_x, destpos_y, destpos_z = self.dest:GetPoint()
        local mypos_x, mypos_y, mypos_z = self.inst.Transform:GetWorldPosition()

        local reached_dest, invalid, in_cooldown = nil, nil, false
		if self.bufferedaction and self.bufferedaction.action.customarrivecheck then
			reached_dest, invalid = self.bufferedaction.action.customarrivecheck(self.inst, self.dest)
		else
			local dsq = distsq(destpos_x, destpos_z, mypos_x, mypos_z)
			local arrive_dsq = self.arrive_dist * self.arrive_dist
			if dt > 0 then
				local run_dist = self:GetRunSpeed() * dt * .5
				arrive_dsq = math.max(arrive_dsq, run_dist * run_dist)
			end
			reached_dest = dsq <= arrive_dsq

			--special case for attacks (in_cooldown can get set here)
			if self.bufferedaction and
				self.bufferedaction.action == ACTIONS.ATTACK and
				not (self.bufferedaction.forced and self.bufferedaction.target == nil)
			then
				local combat = self.inst.replica.combat
				if combat then
					reached_dest, invalid, in_cooldown = combat:LocomotorCanAttack(reached_dest, self.bufferedaction.target)
				end
			end
        end

        if invalid then
            self:Stop()
            self:Clear()
        elseif reached_dest then
        	--I think this is fine? we might need to make OnUpdateFinish() function that we can run to finish up the OnUpdate so we don't duplicate code
            if in_cooldown then return end
            --Print(VERBOSITY.DEBUG, "REACH DEST")
            self.inst:PushEvent("onreachdestination", { target = self.dest.inst, pos = Point(destpos_x, destpos_y, destpos_z) })
            if self.atdestfn ~= nil then
                self.atdestfn(self.inst)
            end

            if self.bufferedaction ~= nil and self.bufferedaction ~= self.inst.bufferedaction then
                if self.bufferedaction.target ~= nil and self.bufferedaction.target.Transform ~= nil and not self.bufferedaction.action.skip_locomotor_facing then
					self:FaceMovePoint(self.bufferedaction.target.Transform:GetWorldPosition())
                elseif self.bufferedaction.invobject ~= nil and not self.bufferedaction.action.skip_locomotor_facing then
                    local act_pos = self.bufferedaction:GetActionPoint()
                    if act_pos ~= nil then
						self:FaceMovePoint(act_pos:Get())
                    end
                end
                if self.ismastersim then
                    self.inst:PushBufferedAction(self.bufferedaction)
                else
                    self.inst:PreviewBufferedAction(self.bufferedaction)
                end
            end
            self:Stop()
            self:Clear()
		elseif not arrive_check_only then
            --Print(VERBOSITY.DEBUG, "LOCOMOTING")
            if self:WaitingForPathSearch() then
                local pathstatus = TheWorld.Pathfinder:GetSearchStatus(self.path.handle)
                --Print(VERBOSITY.DEBUG, "HAS PATH SEARCH", pathstatus)
                if pathstatus ~= STATUS_CALCULATING then
                    --Print(VERBOSITY.DEBUG, "PATH CALCULATION complete", pathstatus)
                    if pathstatus == STATUS_FOUNDPATH then
                        --Print(VERBOSITY.DEBUG, "PATH FOUND")
                        local foundpath = TheWorld.Pathfinder:GetSearchResult(self.path.handle)
                        if foundpath then
                            --Print(VERBOSITY.DEBUG, string.format("PATH %d steps ", #foundpath.steps))

                            if #foundpath.steps > 2 then
                                self.path.steps = foundpath.steps
                                self.path.currentstep = 2

                                -- for k,v in ipairs(foundpath.steps) do
                                --     Print(VERBOSITY.DEBUG, string.format("%d, %s", k, tostring(Point(v.x, v.y, v.z))))
                                -- end

                            else
                                --Print(VERBOSITY.DEBUG, "DISCARDING straight line path")
                                self.path.steps = nil
                                self.path.currentstep = nil
                            end
                        else
                            Print(VERBOSITY.DEBUG, "EMPTY PATH")
                        end
                    else
                        if pathstatus == nil then
                            Print(VERBOSITY.DEBUG, string.format("LOST PATH SEARCH %u. Maybe it timed out?", self.path.handle))
                        else
                            Print(VERBOSITY.DEBUG, "NO PATH")
                        end
                    end

                    TheWorld.Pathfinder:KillSearch(self.path.handle)
                    self.path.handle = nil
                end
            end

			local canrotate = self.inst.sg == nil or self.inst.sg:HasStateTag("canrotate")
			if canrotate or self.pusheventwithdirection then
                --Print(VERBOSITY.DEBUG, "CANROTATE")
                local facepos_x, facepos_y, facepos_z = destpos_x, destpos_y, destpos_z

                if self.path and self.path.steps and self.path.currentstep < #self.path.steps then
                    --Print(VERBOSITY.DEBUG, "FOLLOW PATH")
                    local step = self.path.steps[self.path.currentstep]
                    local steppos_x, steppos_y, steppos_z = step.x, step.y, step.z

                    --Print(VERBOSITY.DEBUG, string.format("CURRENT STEP %d/%d - %s", self.path.currentstep, #self.path.steps, tostring(steppos)))

                    local step_distsq = distsq(mypos_x, mypos_z, steppos_x, steppos_z)

                    local maxsteps = #self.path.steps
                    if self.path.currentstep < maxsteps then -- Add tolerance to step points that aren't the final destination.
                        local physdiameter = self.inst:GetPhysicsRadius(0)*2
                        step_distsq = step_distsq - physdiameter * physdiameter
                    end

                    if step_distsq <= (self.arrive_step_dist)*(self.arrive_step_dist) then
                        self.path.currentstep = self.path.currentstep + 1

                        if self.path.currentstep < maxsteps then
                            step = self.path.steps[self.path.currentstep]
                            steppos_x, steppos_y, steppos_z = step.x, step.y, step.z

                            --Print(VERBOSITY.DEBUG, string.format("NEXT STEP %d/%d - %s", self.path.currentstep, #self.path.steps, tostring(steppos)))
                        else
                            --Print(VERBOSITY.DEBUG, string.format("LAST STEP %s", tostring(destpos)))
                            steppos_x, steppos_y, steppos_z = destpos_x, destpos_y, destpos_z
                        end
                    end
                    facepos_x, facepos_y, facepos_z = steppos_x, steppos_y, steppos_z
                end

				facedir = self.inst:GetAngleToPoint(facepos_x, facepos_y, facepos_z)

                local x,y,z = self.inst.Physics:GetMotorVel()
				if x < 0 and self.strafedir == nil then
					facedir = facedir + 180
					if canrotate then
						--V2C: matching legacy behaviour, where this ignores busy state
						--Print(VERBOSITY.DEBUG, "SET ROT", facedir)
						self:SetMoveDir(facedir)
					end
				elseif canrotate and not (self.inst.sg and self.inst.sg:HasStateTag("busy")) then
					--V2C: while I'd like to remove the busy check,
					--     we'll keep it to match legacy behaviour:
					--     it used to call self.inst:FaceMovePoint(...)
					--Print(VERBOSITY.DEBUG, "FACE PT", Point(facepos_x, facepos_y, facepos_z))
					self:SetMoveDir(facedir)
                end
            end

            self.wantstomoveforward = self.wantstomoveforward or not self:WaitingForPathSearch()
        end
    end

	if arrive_check_only then
		return
	end

    local should_locomote = false
    if (self.ismastersim and not self.inst:IsInLimbo()) or not (self.ismastersim or self.inst:HasTag("INLIMBO")) then
        local is_moving = self.inst.sg ~= nil and self.inst.sg:HasStateTag("moving")
        local is_running = self.inst.sg ~= nil and self.inst.sg:HasStateTag("running")
        --'not' is being used below as a cast-to-boolean operator
        should_locomote =
            (not is_moving ~= not self.wantstomoveforward) or
            (is_moving and (not is_running ~= not self.wantstorun))

        if is_moving or is_running then
            self:StartMoveTimerInternal()
        end
    end

    if should_locomote then
		self.inst:PushEvent("locomote", self.pusheventwithdirection and facedir and { dir = facedir } or nil)
    elseif not self.wantstomoveforward and not self:WaitingForPathSearch() then
        self:ResetPath()
        self:StopUpdatingInternal()
        self:StopMoveTimerInternal()
    end

    local cur_speed = self.inst.Physics:GetMotorSpeed()
    if cur_speed > 0 then
        if self.allow_platform_hopping and (self.bufferedaction == nil or not self.bufferedaction.action.disable_platform_hopping) then
            local mypos_x, mypos_y, mypos_z = self.inst.Transform:GetWorldPosition()

            local rotation = self.inst.Transform:GetRotation() * DEGREES
            local forward_x, forward_z = math.cos(rotation), -math.sin(rotation)

			local hop_distance = self:GetHopDistance(self:GetSpeedMultiplier())

            local my_platform = self.inst:GetCurrentPlatform()
            local other_platform = nil
            local destpos_x, destpos_y, destpos_z
            if self.dest and self.dest:IsValid() then
				if my_platform == self.dest:GetPlatform() then
				    destpos_x, destpos_y, destpos_z = self.dest:GetPoint()
					other_platform = my_platform
				end
			end
			if other_platform == nil then
                destpos_x, destpos_z = forward_x * hop_distance + mypos_x, forward_z * hop_distance + mypos_z
				other_platform = TheWorld.Map:GetPlatformAtPoint(destpos_x, destpos_z)
			end

            local can_hop = false
            local hop_x, hop_z, target_platform, blocked
            local too_early_top_hop = self.time_before_next_hop_is_allowed > 0
            if my_platform ~= other_platform and not too_early_top_hop then
                can_hop, hop_x, hop_z, target_platform, blocked = self:ScanForPlatform(my_platform, destpos_x, destpos_z, hop_distance)
            end
            if not blocked then
                if can_hop then
                    self.last_platform_visited = my_platform

                    self:StartHopping(hop_x, hop_z, target_platform)
                elseif self.inst.components.amphibiouscreature ~= nil and other_platform == nil and not self.inst.sg:HasStateTag("jumping") then
                    local dist = self.inst:GetPhysicsRadius(0) + 2.5
                    local _x, _z = forward_x * dist + mypos_x, forward_z * dist + mypos_z
                    if my_platform ~= nil then
                        local _
                        can_hop, _, _, _, blocked = self:ScanForPlatform(nil, _x, _z, hop_distance)
                    end

                    if not can_hop and self.inst.components.amphibiouscreature:ShouldTransition(_x, _z) then
                        -- If my_platform ~= nil, we already ran the "is blocked" test as part of ScanForPlatform.
                        -- Otherwise, run one now.
                        if (my_platform ~= nil and not blocked) or
                                not self:TestForBlocked(mypos_x, mypos_z, forward_x, forward_z, self.inst:GetPhysicsRadius(0), dist * 1.41421) then -- ~sqrt(2); _x,_z are a dist right triangle so sqrt(dist^2 + dist^2)
                            self.inst:PushEvent("onhop", {x = _x, z = _z})
                        end
                    end
                end
            end

            if (not can_hop and my_platform == nil and target_platform == nil and not self.inst.sg:HasStateTag("jumping")) and self.inst.components.drownable ~= nil and self.inst.components.drownable:ShouldDrown() then
                self.inst:PushEvent("onsink")
            end
        else
            local speed_mult = self:GetSpeedMultiplier()
            local desired_speed = self.isrunning and self:RunSpeed() or self.walkspeed
            if self.dest and self.dest:IsValid() then
                local destpos_x, destpos_y, destpos_z = self.dest:GetPoint()
                local mypos_x, mypos_y, mypos_z = self.inst.Transform:GetWorldPosition()
                local dsq = distsq(destpos_x, destpos_z, mypos_x, mypos_z)
                if dsq <= .25 then
                    speed_mult = math.max(.33, math.sqrt(dsq))
                end
            end

			self:SetMotorSpeed(desired_speed * speed_mult)
        end
    end

    self.time_before_next_hop_is_allowed = math.max(self.time_before_next_hop_is_allowed - dt, 0)
end

function LocoMotor:IsAquatic()
	return self.pathcaps ~= nil and self.pathcaps.allowocean == true and self.pathcaps.ignoreLand == true
end

function LocoMotor:CanPathfindOnWater()
    return self.pathcaps ~= nil and self.pathcaps.allowocean == true
end

function LocoMotor:IsTerrestrial()
    -- We use "not" because the pathcaps may be unassigned or assigned false (i.e. if they're changed at runtime)
    return self.pathcaps ~= nil and (not self.pathcaps.allowocean) and (not self.pathcaps.ignoreLand)
end

function LocoMotor:CanPathfindOnLand()
    return self.pathcaps == nil or (not self.pathcaps.ignoreLand)
end

function LocoMotor:FindPath()
    --Print(VERBOSITY.DEBUG, "LocoMotor:FindPath", self.inst.prefab)

    --if self.inst.prefab ~= "wilson" then return end

    if not self.dest:IsValid() then
        return
    end

    local p0 = Vector3(self.inst.Transform:GetWorldPosition())
    local p1 = Vector3(self.dest:GetPoint())
    local dist = math.sqrt(distsq(p0, p1))
    --Print(VERBOSITY.DEBUG, string.format("    %s -> %s distance %2.2f", tostring(p0), tostring(p1), dist))

    -- if dist > PATHFIND_MAX_RANGE then
    --     Print(VERBOSITY.DEBUG, string.format("TOO FAR to pathfind %2.2f > %2.2f", dist, PATHFIND_MAX_RANGE))
    --     return
    -- end

    local ground = TheWorld
    if ground then
        --Print(VERBOSITY.DEBUG, "GROUND")

        local desttile_x, desttile_y = ground.Pathfinder:GetPathTileIndexFromPoint(p1.x, p1.y, p1.z)
        --Print(VERBOSITY.DEBUG, string.format("    dest tile %d, %d", desttile_x, desttile_y))

        if desttile_x and desttile_y and self.lastdesttile then
            --Print(VERBOSITY.DEBUG, string.format("    last dest tile %d, %d", self.lastdesttile.x, self.lastdesttile.y))
            if desttile_x == self.lastdesttile.x and desttile_y == self.lastdesttile.y then
                --Print(VERBOSITY.DEBUG, "SAME PATH")
                return
            end
        end

        self.lastdesttile = {x = desttile_x, y = desttile_y}

        --Print(VERBOSITY.DEBUG, string.format("CHECK LOS for [%s] %s -> %s", self.inst.prefab, tostring(p0), tostring(p1)))

        if ground.Pathfinder:IsClear(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z, self.pathcaps) then
            --print("HAS LOS")
            self:ResetPath()
        else
            --print("NO LOS - PATHFIND")

            -- while chasing a moving target, the path may get reset frequently before any search completes
            -- only start a new search if we're not already waiting for the previous one to complete OR
            -- we already have a completed path we can keep following until new search returns
            if (self.path and self.path.steps) or not self:WaitingForPathSearch() then

                self:KillPathSearch()

                local handle = ground.Pathfinder:SubmitSearch(p0.x, p0.y, p0.z, p1.x, p1.y, p1.z, self.pathcaps)
                if handle then
                    --Print(VERBOSITY.DEBUG, string.format("PATH handle %d ", handle))

                    --if we already had a path, just keep following it until we get our new one
                    self.path = self.path or {}
                    self.path.handle = handle

                else
                    Print(VERBOSITY.DEBUG, "SUBMIT PATH FAILED")
                end
            end
        end
    end
end

return LocoMotor
