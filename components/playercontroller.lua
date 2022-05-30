local START_DRAG_TIME = 8 * FRAMES
local BUTTON_REPEAT_COOLDOWN = .5
local ACTION_REPEAT_COOLDOWN = 0.2
local INVENTORY_ACTIONHOLD_REPEAT_COOLDOWN = 0.8
local BUFFERED_CASTAOE_TIME = .5
local CONTROLLER_TARGETING_LOCK_TIME = 1.0
local RUBBER_BAND_PING_TOLERANCE_IN_SECONDS = 0.7
local RUBBER_BAND_DISTANCE = 4
local RUBBER_BAND_DISTANCE_SQ = RUBBER_BAND_DISTANCE * RUBBER_BAND_DISTANCE

local function OnPlayerActivated(inst)
    inst.components.playercontroller:Activate()
end

local function OnPlayerDeactivated(inst)
    inst.components.playercontroller:Deactivate()
end

local function GetWorldControllerVector()
    local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
    local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
    local deadzone = .3
    if math.abs(xdir) >= deadzone or math.abs(ydir) >= deadzone then
        local dir = TheCamera:GetRightVec() * xdir - TheCamera:GetDownVec() * ydir
        return dir:GetNormalized()
    end
end

local function OnBufferedCastAOE(inst, buffaction)
    local self = inst.components.playercontroller
    if self.directwalking then
        local dir
        if self.handler == nil then
            dir = self:GetRemoteDirectVector()
        else
            dir = GetWorldControllerVector()
        end
        if dir ~= nil then
            self.bufferedcastaoe =
            {
                act = buffaction,
                t = BUFFERED_CASTAOE_TIME,
                x = dir.x,
                z = dir.z,
            }
        end
    end
end

local function HasItemSlots(self)
    return self._hasitemslots
end

local function CacheHasItemSlots(self)
    self.HasItemSlots = HasItemSlots
    self._hasitemslots = self.inst.replica.inventory:GetNumSlots() > 0
    return self._hasitemslots
end

local PlayerController = Class(function(self, inst)
    self.inst = inst

    --cache variables
    self.map = TheWorld.Map
    self.ismastersim = TheWorld.ismastersim
    self.locomotor = self.inst.components.locomotor
    self.HasItemSlots = CacheHasItemSlots

    --attack control variables
    self.attack_buffer = nil
    self.controller_attack_override = nil

    --remote control variables
    self.remote_vector = Vector3()
    self.remote_controls = {}

    --castaoe action cancelling prevention
    self.bufferedcastaoe = nil

    self.dragwalking = false
    self.directwalking = false
    self.predictwalking = false
    self.predictionsent = false
    self.draggingonground = false
    self.is_hopping = false
    self.startdragtestpos = nil
    self.startdragtime = nil
    self.isclientcontrollerattached = false
	 
    self.mousetimeout = 10
    self.time_direct_walking = 0

    self.controller_target = nil
    self.controller_target_age = math.huge
    self.controller_attack_target = nil
    self.controller_attack_target_ally_cd = nil
    --self.controller_attack_target_age = math.huge

	self.controller_targeting_modifier_down = false
	self.controller_targeting_lock_timer = nil
	self.controller_targeting_lock_target = false
	self.controller_targeting_targets = {}
	self.controller_targeting_target_index = nil

    self.reticule = nil
    self.terraformer = nil
    self.deploy_mode = not TheInput:ControllerAttached()
    self.deployplacer = nil
    self.placer = nil
    self.placer_recipe = nil
    self.placer_recipe_skin = nil
    self.placer_cached = nil

    self.LMBaction = nil
    self.RMBaction = nil

    self.handler = nil
    self.actionbuttonoverride = nil

    --self.actionholding = false
    --self.actionholdtime = nil
    --self.lastheldaction = nil
    --self.actionrepeatfunction = nil
    self.heldactioncooldown = 0

    if self.ismastersim then
        self.is_map_enabled = true
        self.can_use_map = true
        self.classified = inst.player_classified
        inst:ListenForEvent("bufferedcastaoe", OnBufferedCastAOE)
        inst:StartUpdatingComponent(self)
        inst:StartWallUpdatingComponent(self)
    elseif self.classified == nil and inst.player_classified ~= nil then
        self:AttachClassified(inst.player_classified)
    end

    inst:ListenForEvent("playeractivated", OnPlayerActivated)
    inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
end)

--------------------------------------------------------------------------

function PlayerController:OnRemoveFromEntity()
    if self.ismastersim then
        self.inst:RemoveEventCallback("bufferedcastaoe", OnBufferedCastAOE)
    end
    self.inst:RemoveEventCallback("playeractivated", OnPlayerActivated)
    self.inst:RemoveEventCallback("playerdeactivated", OnPlayerDeactivated)
    self:Deactivate()
    if self.classified ~= nil then
        if self.ismastersim then
            self.classified = nil
        else
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

PlayerController.OnRemoveEntity = PlayerController.OnRemoveFromEntity

function PlayerController:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function PlayerController:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

--------------------------------------------------------------------------

local function OnBuild(inst)
    inst.components.playercontroller:CancelPlacement()
end

local function OnEquip(inst, data)
    --Reticule targeting items
    if data.eslot == EQUIPSLOTS.HANDS then
        local self = inst.components.playercontroller
        if data.item.components.aoetargeting ~= nil then
            if self.reticule ~= nil then
                self.reticule:DestroyReticule()
                self.reticule = nil
            end
            data.item.components.aoetargeting:StopTargeting()
        else
            local newreticule = data.item.components.reticule or inst.components.reticule
            if newreticule ~= self.reticule then
                if self.reticule ~= nil then
                    self.reticule:DestroyReticule()
                end
                self.reticule = newreticule
                if newreticule ~= nil and newreticule.reticule == nil and (newreticule.mouseenabled or TheInput:ControllerAttached()) then
                    newreticule:CreateReticule()
                end
            end
        end
    end
end

local function OnUnequip(inst, data)
    --Reticule targeting items
    if data.eslot == EQUIPSLOTS.HANDS then
        local self = inst.components.playercontroller
        if self.reticule ~= nil and self.reticule ~= inst.components.reticule then
            local equip = inst.replica.inventory:GetEquippedItem(data.eslot)
            if equip == nil or self.reticule ~= equip.components.reticule then
                self.reticule:DestroyReticule()
                self.reticule = inst.components.reticule
                if self.reticule ~= nil and self.reticule.reticule == nil and (self.reticule.mouseenabled or TheInput:ControllerAttached()) then
                    self.reticule:CreateReticule()
                end
            end
        end
    end
end

local function OnInventoryClosed(inst)
    --Reticule targeting items
    local self = inst.components.playercontroller
    if self.reticule ~= nil then
        self.reticule:DestroyReticule()
        self.reticule = nil
    end
end

local function OnZoom(inst, data)
    if data.zoomout then
        TheCamera:ZoomOut(data.zoom or 6)
    else
        TheCamera:ZoomIn(data.zoom or 6)
    end
end

local function OnContinueFromPause()
	local self = ThePlayer.components.playercontroller
    self:ToggleController(TheInput:ControllerAttached())

	-- this caches if the camera zooming is using the same physical controls as the scroll bar scrolling
	self.zoomin_same_as_scrollup = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_ZOOM_IN) == TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SCROLLBACK)
	self.zoomout_same_as_scrolldown = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_ZOOM_OUT) == TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_SCROLLFWD)
end

local function OnDeactivateWorld()
    --Essential cleanup when client is notified of
    --pending server c_reset or c_regenerateworld.
    ThePlayer.components.playercontroller:Deactivate()
end

local function OnReachDestination(inst)
    if inst.sg:HasStateTag("moving") then
        local x, y, z = inst.Transform:GetWorldPosition()
        inst.components.playercontroller:RemotePredictWalking(x, z)
    end
end

function PlayerController:Activate()
    if self.handler ~= nil then
        if self.inst ~= ThePlayer then
            self:Deactivate()
        end
    elseif self.inst == ThePlayer then
        self.handler = TheInput:AddGeneralControlHandler(function(control, value) self:OnControl(control, value) end)

        --reset the remote controllers just in case there was some old data
        self:ResetRemoteController()
        self.predictionsent = false
        self.isclientcontrollerattached = false

        self:RefreshReticule()

        self.inst:ListenForEvent("buildstructure", OnBuild)
        self.inst:ListenForEvent("equip", OnEquip)
        self.inst:ListenForEvent("unequip", OnUnequip)
        self.inst:ListenForEvent("zoomcamera", OnZoom)
        if not self.ismastersim then
            self.inst:ListenForEvent("deactivateworld", OnDeactivateWorld, TheWorld)
            self.inst:ListenForEvent("onreachdestination", OnReachDestination)
            self.inst:ListenForEvent("bufferedcastaoe", OnBufferedCastAOE)
            self.inst:StartUpdatingComponent(self)
            self.inst:StartWallUpdatingComponent(self)

            --Client only event, because when inventory is closed, we will stop
            --getting "equip" and "unequip" events, but we can also assume that
            --our inventory is emptied.
            self.inst:ListenForEvent("inventoryclosed", OnInventoryClosed)
        end
        self.inst:ListenForEvent("continuefrompause", OnContinueFromPause, TheWorld)
        OnContinueFromPause()
    end
end

function PlayerController:Deactivate()
    if self.handler ~= nil then
        self:CancelPlacement()
        self:CancelDeployPlacement()

        if self.terraformer ~= nil then
            self.terraformer:Remove()
            self.terraformer = nil
        end

        if self.reticule ~= nil then
            self.reticule:DestroyReticule()
            self.reticule = nil
        end

        self.handler:Remove()
        self.handler = nil

        --reset the remote controllers just in case there was some old data
        self:ResetRemoteController()
        self.predictionsent = false
        self.isclientcontrollerattached = false

        self.inst:RemoveEventCallback("buildstructure", OnBuild)
        self.inst:RemoveEventCallback("equip", OnEquip)
        self.inst:RemoveEventCallback("unequip", OnUnequip)
        self.inst:RemoveEventCallback("continuefrompause", OnContinueFromPause, TheWorld)
        if not self.ismastersim then
            self.inst:RemoveEventCallback("inventoryclosed", OnInventoryClosed)
            self.inst:RemoveEventCallback("deactivateworld", OnDeactivateWorld, TheWorld)
            self.inst:RemoveEventCallback("onreachdestination", OnReachDestination)
            self.inst:RemoveEventCallback("bufferedcastaoe", OnBufferedCastAOE)
            self.bufferedcastaoe = nil
            self.inst:RemoveEventCallback("zoomcamera", OnZoom)
            self.inst:StopUpdatingComponent(self)
            self.inst:StopWallUpdatingComponent(self)
        end
    end
end

--------------------------------------------------------------------------

function PlayerController:Enable(val)
    if self.ismastersim then
        self.classified.iscontrollerenabled:set(val)
    end
end

function PlayerController:ToggleController(val)
    if self.isclientcontrollerattached ~= val then
        self.isclientcontrollerattached = val
        if self.handler ~= nil then
            self:RefreshReticule()
        end
        if not self.ismastersim then
            SendRPCToServer(RPC.ToggleController, val)
        elseif val and self.inst.components.inventory ~= nil then
            self.inst.components.inventory:ReturnActiveItem()
        end
    end
end

function PlayerController:EnableMapControls(val)
    if self.ismastersim then
        self.is_map_enabled = val == true
        self.classified:EnableMapControls(val and self.can_use_map)
    end
end

function PlayerController:SetCanUseMap(val)
    if self.ismastersim then
        self.can_use_map = val == true
        self.classified:EnableMapControls(val and self.is_map_enabled)
    end
end

-- returns: enable/disable, "a hud element is up, but still allow for limited gameplay to happen"
function PlayerController:IsEnabled()
    if self.classified == nil or not self.classified.iscontrollerenabled:value() then
        return false
    elseif self.inst.HUD ~= nil and self.inst.HUD:HasInputFocus() then
		return false, self.inst.HUD:IsCraftingOpen() and TheFrontEnd.textProcessorWidget == nil
    end
    return true
end

function PlayerController:IsMapControlsEnabled()
    return self.classified ~= nil and
        self.classified.iscontrollerenabled:value() and
        self.classified.ismapcontrolsvisible:value() and
        self.inst.HUD ~= nil
end

function PlayerController:IsControlPressed(control)
    if self.handler ~= nil then
        return TheInput:IsControlPressed(control)
    else
        return self.remote_controls[control] ~= nil
    end
end

function PlayerController:IsAnyOfControlsPressed(...)
    if self.handler ~= nil then
        for i, v in ipairs({...}) do
            if TheInput:IsControlPressed(v) then
                return true
            end
        end
    else
        for i, v in ipairs({...}) do
            if self.remote_controls[v] ~= nil then
                return true
            end
        end
    end
end

function PlayerController:CooldownRemoteController(dt)
    for k, v in pairs(self.remote_controls) do
        self.remote_controls[k] = dt ~= nil and math.max(v - dt, 0) or 0
    end
    self:CooldownHeldAction(dt)
end

function PlayerController:CooldownHeldAction(dt)
    self.heldactioncooldown = dt ~= nil and math.max(self.heldactioncooldown - dt, 0) or 0
end

function PlayerController:OnRemoteStopControl(control)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.remote_controls[control] = nil
    end
end

function PlayerController:OnRemoteStopAllControls()
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        if next(self.remote_controls) ~= nil then
            self.remote_controls = {}
        end
    end
end

function PlayerController:RemoteStopControl(control)
    if self.remote_controls[control] ~= nil then
        self.remote_controls[control] = nil
        SendRPCToServer(RPC.StopControl, control)
    end
end

function PlayerController:RemoteStopAllControls()
    if next(self.remote_controls) ~= nil then
        self.remote_controls = {}
        SendRPCToServer(RPC.StopAllControls)
    end
end

function PlayerController:RemotePausePrediction(frames)
    if self.ismastersim then
        self.classified:PushPausePredictionFrames(frames or 0)
    end
end

function PlayerController:OnControl(control, down)

	-- do this first in order to not lose an up/down and get out of sync
	if control == CONTROL_TARGET_MODIFIER then
		self.controller_targeting_modifier_down = down
		if down then
			self.controller_targeting_lock_timer = 0.0
		else
			self.controller_targeting_lock_timer = nil
		end
	end

    if IsPaused() then
        return
	end

    local isenabled, ishudblocking = self:IsEnabled()
	if not isenabled and not ishudblocking then
		return
	end	
	
	-- actions that can be done while the crafting menu is open go in here
	if isenabled or ishudblocking then
		if control == CONTROL_ACTION then
			self:DoActionButton()
		elseif control == CONTROL_ATTACK then
			if self.ismastersim then
				self.attack_buffer = CONTROL_ATTACK
			else
				self:DoAttackButton()
			end
		end
	end

	if not isenabled then
		return
	end
	
    if control == CONTROL_PRIMARY then
        self:OnLeftClick(down)
    elseif control == CONTROL_SECONDARY then
        self:OnRightClick(down)
    elseif not down then
        if not self.ismastersim then
            self:RemoteStopControl(control)
        end
    elseif control == CONTROL_CANCEL then
        self:CancelPlacement()
		self:ControllerTargetLock(false)
    elseif control == CONTROL_INSPECT then
        self:DoInspectButton()
    elseif control == CONTROL_CONTROLLER_ALTACTION then
        self:DoControllerAltActionButton()
    elseif control == CONTROL_CONTROLLER_ACTION then
        self:DoControllerActionButton()
    elseif control == CONTROL_CONTROLLER_ATTACK then
        if self.ismastersim then
            self.attack_buffer = CONTROL_CONTROLLER_ATTACK
        else
            self:DoControllerAttackButton()
        end
    elseif self.controller_targeting_modifier_down then
		if control == CONTROL_TARGET_CYCLE_BACK then
			self:CycleControllerAttackTargetBack()
		elseif control == CONTROL_TARGET_CYCLE_FORWARD then
			self:CycleControllerAttackTargetForward()
		end
    elseif self.inst.replica.inventory:IsVisible() then
        local inv_obj = self:GetCursorInventoryObject()
        if inv_obj ~= nil then
            if control == CONTROL_INVENTORY_DROP then
                self:DoControllerDropItemFromInvTile(inv_obj)
            elseif control == CONTROL_INVENTORY_EXAMINE then
                self:DoControllerInspectItemFromInvTile(inv_obj)
            elseif control == CONTROL_INVENTORY_USEONSELF then
                self:DoControllerUseItemOnSelfFromInvTile(inv_obj)
            elseif control == CONTROL_INVENTORY_USEONSCENE then
                self:DoControllerUseItemOnSceneFromInvTile(inv_obj)
            end
        end
    end
end

--------------------------------------------------------------------------

local MOD_CONTROLS =
{
    CONTROL_FORCE_INSPECT,
    CONTROL_FORCE_ATTACK,
    CONTROL_FORCE_TRADE,
    CONTROL_FORCE_STACK,
}

function PlayerController:EncodeControlMods()
    local code = 0
    local bit = 1
    for i, v in ipairs(MOD_CONTROLS) do
        code = code + (TheInput:IsControlPressed(v) and bit or 0)
        bit = bit * 2
    end
    return code ~= 0 and code or nil
end

function PlayerController:DecodeControlMods(code)
    code = code or 0
    local bit = 2 ^ (#MOD_CONTROLS - 1)
    for i = #MOD_CONTROLS, 1, -1 do
        if code >= bit then
            self.remote_controls[MOD_CONTROLS[i]] = 0
            code = code - bit
        else
            self.remote_controls[MOD_CONTROLS[i]] = nil
        end
        bit = bit / 2
    end
end

function PlayerController:ClearControlMods()
    for i, v in ipairs(MOD_CONTROLS) do
        self.remote_controls[v] = nil
    end
end

function PlayerController:CanLocomote()
    return self.ismastersim
        or (self.locomotor ~= nil and
            not (self.inst.sg:HasStateTag("busy") or
                self.inst:HasTag("pausepredict") or
                (self.classified ~= nil and self.classified.pausepredictionframes:value() > 0)) and
            self.inst.entity:CanPredictMovement())
end

function PlayerController:IsBusy()
    if self.ismastersim then
        return self.inst.sg:HasStateTag("busy")
    else
        return self.inst:HasTag("busy")
            or (self.inst.sg ~= nil and self.inst.sg:HasStateTag("busy"))
            or (self.classified ~= nil and self.classified.pausepredictionframes:value() > 0)
    end
end

--------------------------------------------------------------------------

function PlayerController:GetCursorInventoryObject()
    if self.inst.HUD ~= nil and TheInput:ControllerAttached() then
        local item = self.inst.HUD.controls.inv:GetCursorItem()
        return item ~= nil and item:IsValid() and item or nil
    end
end

function PlayerController:GetCursorInventorySlotAndContainer()
    if self.inst.HUD ~= nil and TheInput:ControllerAttached() then
        return self.inst.HUD.controls.inv:GetCursorSlot()
    end
end

function PlayerController:DoControllerActionButton()
    if self.placer ~= nil and self.placer_recipe ~= nil then
        --do the placement
        if  self.placer.components.placer.can_build then
            if self.inst.replica.builder ~= nil and
                not self.inst.replica.builder:IsBusy() then
                self.inst.replica.builder:MakeRecipeAtPoint(self.placer_recipe,
                    self.placer.components.placer.override_build_point_fn ~= nil and self.placer.components.placer.override_build_point_fn(self.placer) or self.placer:GetPosition(),
                    self.placer:GetRotation(), self.placer_recipe_skin)
                self:CancelPlacement()
            end
        elseif self.placer.components.placer.onfailedplacement ~= nil then
            self.placer.components.placer.onfailedplacement(self.inst, self.placer)
        end
        return
    end

    local obj = nil
    local act = nil
	local isspecial = nil
    if self.deployplacer ~= nil then
        if self.deployplacer.components.placer.can_build then
            act = self.deployplacer.components.placer:GetDeployAction()
            if act ~= nil then
                obj = act.invobject
                act.distance = 1
            end
        end
    elseif self:IsAOETargeting() then
        if self:IsBusy() then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative", nil, .4)
            self.reticule:Blip()
            return
        end
        obj, act = self:GetGroundUseAction()
        if act == nil or act.action ~= ACTIONS.CASTAOE then
            return
        end
        obj = nil --meh.. reusing obj =P
        self.reticule:PingReticuleAt(act:GetActionPoint())
        self:CancelAOETargeting()
    else
        obj = self:GetControllerTarget()
        if obj ~= nil then
            act = self:GetSceneItemControllerAction(obj)
        end
		if act == nil then
			act = self:GetGroundUseSpecialAction(nil, false)
			if act ~= nil then
				isspecial = true
			end
		end
    end

    if act == nil then
        return
    end

    if self.ismastersim then
        self.inst.components.combat:SetTarget(nil)
    elseif self.deployplacer ~= nil then
        if self.locomotor == nil then
            self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
            SendRPCToServer(RPC.ControllerActionButtonDeploy, obj, act.pos.local_pt.x, act.pos.local_pt.z, act.rotation ~= 0 and act.rotation or nil, nil, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
        elseif self:CanLocomote() then
            act.preview_cb = function()
                self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
                local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
                SendRPCToServer(RPC.ControllerActionButtonDeploy, obj, act.pos.local_pt.x, act.pos.local_pt.z, act.rotation ~= 0 and act.rotation or nil, isreleased, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
            end
        end
    elseif obj == nil then
        if self.locomotor == nil then
            self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
            SendRPCToServer(RPC.ControllerActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, nil, act.action.canforce, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil, isspecial)
        elseif self:CanLocomote() then
            act.preview_cb = function()
                self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
                local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
                SendRPCToServer(RPC.ControllerActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, isreleased, nil, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil, isspecial)
            end
        end
    elseif self.locomotor == nil then
        self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
        SendRPCToServer(RPC.ControllerActionButton, act.action.code, obj, nil, act.action.canforce, act.action.mod_name)
    elseif self:CanLocomote() then
        act.preview_cb = function()
            self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
            local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
            SendRPCToServer(RPC.ControllerActionButton, act.action.code, obj, isreleased, nil, act.action.mod_name)
        end
    end

    self:DoAction(act)
end

function PlayerController:OnRemoteControllerActionButton(actioncode, target, isreleased, noforce, mod_name)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.inst.components.combat:SetTarget(nil)

        self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
        self:ClearControlMods()
        SetClientRequestedAction(actioncode, mod_name)
        local lmb, rmb = self:GetSceneItemControllerAction(target)
        ClearClientRequestedAction()
        if isreleased then
            self.remote_controls[CONTROL_CONTROLLER_ACTION] = nil
        end

        --Possible for lmb action to switch to rmb after autoequip
        lmb =  (lmb ~= nil and
                lmb.action.code == actioncode and
                lmb.action.mod_name == mod_name and
                lmb)
            or (rmb ~= nil and
                rmb.action.code == actioncode and
                rmb.action.mod_name == mod_name and
                rmb)
            or nil

        if lmb ~= nil then
            if lmb.action.canforce and not noforce then
                lmb:SetActionPoint(self:GetRemotePredictPosition() or self.inst:GetPosition())
                lmb.forced = true
            end
            self:DoAction(lmb)
        --elseif mod_name ~= nil then
            --print("Remote controller action button action failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
        --else
            --print("Remote controller action button action failed: "..tostring(ACTION_IDS[actioncode]))
        end
    end
end

function PlayerController:OnRemoteControllerActionButtonPoint(actioncode, position, isreleased, noforce, mod_name, isspecial)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.inst.components.combat:SetTarget(nil)

        self.remote_controls[CONTROL_CONTROLLER_ACTION] = 0
        self:ClearControlMods()
        SetClientRequestedAction(actioncode, mod_name)
        local lmb, rmb
        if isspecial then
			lmb = self:GetGroundUseSpecialAction(position, false)
		else
			lmb, rmb = self:GetGroundUseAction(position)
		end
        ClearClientRequestedAction()
        if isreleased then
            self.remote_controls[CONTROL_CONTROLLER_ACTION] = nil
        end

        --Possible for lmb action to switch to rmb after autoequip
        lmb =  (lmb ~= nil and
                lmb.action.code == actioncode and
                lmb.action.mod_name == mod_name and
                lmb)
            or (rmb ~= nil and
                rmb.action.code == actioncode and
                rmb.action.mod_name == mod_name and
                rmb)
            or nil

        if lmb ~= nil then
            if lmb.action.canforce and not noforce then
                lmb:SetActionPoint(self:GetRemotePredictPosition() or self.inst:GetPosition())
                lmb.forced = true
            end
            self:DoAction(lmb)
        --elseif mod_name ~= nil then
            --print("Remote controller action button action failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
        --else
            --print("Remote controller action button action failed: "..tostring(ACTION_IDS[actioncode]))
        end
    end
end

function PlayerController:OnRemoteControllerActionButtonDeploy(invobject, position, rotation, isreleased)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.inst.components.combat:SetTarget(nil)

        self.remote_controls[CONTROL_CONTROLLER_ACTION] = not isreleased and 0 or nil

        if invobject.components.inventoryitem ~= nil and invobject.components.inventoryitem:GetGrandOwner() == self.inst then
            --Must match placer:GetDeployAction(), with an additional distance = 1 parameter
            self:DoAction(BufferedAction(self.inst, nil, ACTIONS.DEPLOY, invobject, position, nil, 1, nil, rotation or 0))
        --else
            --print("Remote controller action button deploy failed")
        end
    end
end

function PlayerController:DoControllerAltActionButton()
    self:ClearActionHold()

    if self.placer_recipe ~= nil then
        self:CancelPlacement()
        return
    elseif self.deployplacer ~= nil then
        self:CancelDeployPlacement()
        return
    elseif self:IsAOETargeting() then
        self:CancelAOETargeting()
        return
	elseif self:IsControllerTargetLockEnabled() then
		self:ControllerTargetLock(false)
		return
    end

    self.actionholdtime = GetTime()

    local lmb, act = self:GetGroundUseAction()
    local isspecial = nil
    local obj = nil
    if act == nil then
        obj = self:GetControllerTarget()
        if obj ~= nil then
            lmb, act = self:GetSceneItemControllerAction(obj)
        end
        if act == nil then
            local rider = self.inst.replica.rider
            if rider ~= nil and rider:IsRiding() then
                obj = self.inst
                act = BufferedAction(obj, obj, ACTIONS.DISMOUNT)
            else
                obj = nil
                act = self:GetGroundUseSpecialAction(nil, true)
                if act == nil then
                    self:TryAOETargeting()
                    return
                end
                isspecial = true
            end
        end
    end

    if self.reticule ~= nil and self.reticule.reticule ~= nil then
        self.reticule:PingReticuleAt(act:GetActionPoint())
    end

    if self.ismastersim then
        self.inst.components.combat:SetTarget(nil)
    elseif obj ~= nil then
        if self.locomotor == nil then
            self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
            SendRPCToServer(RPC.ControllerAltActionButton, act.action.code, obj, nil, act.action.canforce, act.action.mod_name)
        elseif self:CanLocomote() then
            act.preview_cb = function()
                self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
                local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ALTACTION)
                SendRPCToServer(RPC.ControllerAltActionButton, act.action.code, obj, isreleased, nil, act.action.mod_name)
            end
        end
    elseif self.locomotor == nil then
        self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
        SendRPCToServer(RPC.ControllerAltActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, nil, act.action.canforce, isspecial, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
    elseif self:CanLocomote() then
        act.preview_cb = function()
            self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
            local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ALTACTION)
            SendRPCToServer(RPC.ControllerAltActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, isreleased, nil, isspecial, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
        end
    end

    self:DoAction(act)
end

function PlayerController:OnRemoteControllerAltActionButton(actioncode, target, isreleased, noforce, mod_name)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.inst.components.combat:SetTarget(nil)

        self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
        self:ClearControlMods()
        SetClientRequestedAction(actioncode, mod_name)
        local lmb, rmb = self:GetSceneItemControllerAction(target)
        ClearClientRequestedAction()
        if isreleased then
            self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = nil
        end

        --Possible for rmb action to switch to lmb after autoequip
        --Probably not, but fairly inexpensive to be safe =)
        rmb =  (rmb ~= nil and
                rmb.action.code == actioncode and
                rmb.action.mod_name == mod_name and
                rmb)
            or (lmb ~= nil and
                lmb.action.code == actioncode and
                lmb.action.mod_name == mod_name and
                lmb)
            or nil

        if rmb ~= nil then
            if rmb.action.canforce and not noforce then
                rmb:SetActionPoint(self:GetRemotePredictPosition() or self.inst:GetPosition())
                rmb.forced = true
            end
            self:DoAction(rmb)
        --elseif mod_name ~= nil then
            --print("Remote controller alt action button action failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
        --else
            --print("Remote controller alt action button action failed: "..tostring(ACTION_IDS[actioncode]))
        end
    end
end

function PlayerController:OnRemoteControllerAltActionButtonPoint(actioncode, position, isreleased, noforce, isspecial, mod_name)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.inst.components.combat:SetTarget(nil)

        self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
        self:ClearControlMods()
        local lmb, rmb
        SetClientRequestedAction(actioncode, mod_name)
        if isspecial then
            rmb = self:GetGroundUseSpecialAction(position, true)
        else
            lmb, rmb = self:GetGroundUseAction(position)
        end
        ClearClientRequestedAction()
        if isreleased then
            self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = nil
        end

        --Possible for rmb action to switch to lmb after autoequip
        --Probably not, but fairly inexpensive to be safe =)
        rmb =  (rmb ~= nil and
                rmb.action.code == actioncode and
                rmb.action.mod_name == mod_name and
                rmb)
            or (lmb ~= nil and
                lmb.action.code == actioncode and
                lmb.action.mod_name == mod_name and
                lmb)
            or nil

        if rmb ~= nil then
            if rmb.action.canforce and not noforce then
                rmb:SetActionPoint(self:GetRemotePredictPosition() or self.inst:GetPosition())
                rmb.forced = true
            end
            self:DoAction(rmb)
        --elseif mod_name ~= nil then
            --print("Remote controller alt action button point action failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
        --else
            --print("Remote controller alt action button point action failed: "..tostring(ACTION_IDS[actioncode]))
        end
    end
end

function PlayerController:DoControllerAttackButton(target)
    if target == nil and self:IsAOETargeting() then
        return
    elseif target ~= nil then
        --Don't want to spam the controller attack button when retargetting
        if not self.ismastersim and (self.remote_controls[CONTROL_CONTROLLER_ATTACK] or 0) > 0 then
            return
        end

        if self.inst.sg ~= nil then
            if self.inst.sg:HasStateTag("attack") then
                return
            end
        elseif self.inst:HasTag("attack") then
            return
        end

        if not self.inst.replica.combat:CanHitTarget(target) or
            IsEntityDead(target, true) or
            not CanEntitySeeTarget(self.inst, target) then
            return
        end
    else
        target = self.controller_attack_target
        if target ~= nil then
            if target == self.inst.replica.combat:GetTarget() then
                --Still need to let the server know our controller attack button is down
                if not self.ismastersim and
                    self.locomotor == nil and
                    self.remote_controls[CONTROL_CONTROLLER_ATTACK] == nil then
                    self.remote_controls[CONTROL_CONTROLLER_ATTACK] = 0
                    SendRPCToServer(RPC.ControllerAttackButton, true)
                end
                return
            elseif not self.inst.replica.combat:CanTarget(target) then
                target = nil
            end
        end
        --V2C: controller attacks still happen even with no valid target
        if target == nil and (
            self.directwalking or
            self.inst:HasTag("playerghost") or
            self.inst:HasTag("weregoose") or
            self.inst.replica.inventory:IsHeavyLifting() or
			(self.classified and self.classified.inmightygym:value() > 0) or
            GetGameModeProperty("no_air_attack")
        ) then
            --Except for player ghosts!
            return
        end
    end

    local act = BufferedAction(self.inst, target, ACTIONS.ATTACK)

    if self.ismastersim then
        self.inst.components.combat:SetTarget(nil)
    elseif self.locomotor == nil then
        self.remote_controls[CONTROL_CONTROLLER_ATTACK] = BUTTON_REPEAT_COOLDOWN
        SendRPCToServer(RPC.ControllerAttackButton, target, nil, act.action.canforce)
    elseif self:CanLocomote() then
        act.preview_cb = function()
            self.remote_controls[CONTROL_CONTROLLER_ATTACK] = BUTTON_REPEAT_COOLDOWN
            local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ATTACK)
            SendRPCToServer(RPC.ControllerAttackButton, target, isreleased)
        end
    end

    self:DoAction(act)
end

function PlayerController:OnRemoteControllerAttackButton(target, isreleased, noforce)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        --Check if target is valid, otherwise make
        --it nil so that we still attack and miss.
        if target == true then
            --Special case, just flagging the button as down
            self.remote_controls[CONTROL_CONTROLLER_ATTACK] = 0
        elseif not noforce then
            if self.inst.sg:HasStateTag("attack") then
                self.inst.sg.statemem.chainattack_cb = function()
                    self:OnRemoteControllerAttackButton(target)
                end
            else
                target = self.inst.components.combat:CanTarget(target) and target or nil
                self.attack_buffer = BufferedAction(self.inst, target, ACTIONS.ATTACK, nil, nil, nil, nil, true)
                self.attack_buffer._controller = true
                self.attack_buffer._predictpos = true
            end
        else
            self.remote_controls[CONTROL_CONTROLLER_ATTACK] = 0
            if self.inst.components.combat:CanTarget(target) then
                self.attack_buffer = BufferedAction(self.inst, target, ACTIONS.ATTACK)
                self.attack_buffer._controller = true
            else
                self.attack_buffer = BufferedAction(self.inst, nil, ACTIONS.ATTACK, nil, nil, nil, nil, true)
                self.attack_buffer._controller = true
                self.attack_buffer._predictpos = true
                self.attack_buffer.overridedest = self.inst
            end
        end
    end
end

function PlayerController:DoControllerDropItemFromInvTile(item, single)
    self.inst.replica.inventory:DropItemFromInvTile(item, single)
end

function PlayerController:DoControllerInspectItemFromInvTile(item)
    self.inst.replica.inventory:InspectItemFromInvTile(item)
end

function PlayerController:DoControllerUseItemOnSelfFromInvTile(item)
    if item ~= nil then
        self.actionholdtime = GetTime()
        self.lastheldaction = nil
        self.actionrepeatfunction = self.DoControllerUseItemOnSelfFromInvTile
    else
        item = self:GetCursorInventoryObject()
        if item == nil then self.actionrepeatfunction = nil return end
    end
    if not self.deploy_mode and
        item.replica.inventoryitem:IsDeployable(self.inst) and
        item.replica.inventoryitem:IsGrandOwner(self.inst) then
        self.deploy_mode = true
        return
    end
    self.inst.replica.inventory:ControllerUseItemOnSelfFromInvTile(item)
end

function PlayerController:DoControllerUseItemOnSceneFromInvTile(item)
    if item ~= nil then
        self.actionholdtime = GetTime()
        self.lastheldaction = nil
        self.actionrepeatfunction = self.DoControllerUseItemOnSceneFromInvTile
    else
        item = self:GetCursorInventoryObject()
        if item == nil then self.actionrepeatfunction = nil return end
    end
    if item.replica.inventoryitem ~= nil and not item.replica.inventoryitem:IsGrandOwner(self.inst) then
        local slot, container = self:GetCursorInventorySlotAndContainer()
        if slot ~= nil and container ~= nil then
            container:MoveItemFromAllOfSlot(slot, self.inst)
        end
    else
        self.inst.replica.inventory:ControllerUseItemOnSceneFromInvTile(item)
    end
end

function PlayerController:RotLeft()
    if not TheCamera:CanControl() then
        return
    end
    local rotamount = 45 ---90-- TheWorld:HasTag("cave") and 22.5 or 45
    if not IsPaused() then
        TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - rotamount)
        --UpdateCameraHeadings()
    elseif self.inst.HUD ~= nil and self.inst.HUD:IsMapScreenOpen() then
        TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - rotamount)
        TheCamera:Snap()
    end
end

function PlayerController:RotRight()
    if not TheCamera:CanControl() then
        return
    end
    local rotamount = 45 --90--TheWorld:HasTag("cave") and 22.5 or 45
    if not IsPaused() then
        TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + rotamount)
        --UpdateCameraHeadings()
    elseif self.inst.HUD ~= nil and self.inst.HUD:IsMapScreenOpen() then
        TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + rotamount)
        TheCamera:Snap()
    end
end

function PlayerController:GetHoverTextOverride()
    return self.placer_recipe ~= nil and (STRINGS.UI.HUD.BUILD.." "..(STRINGS.NAMES[string.upper(self.placer_recipe.name)] or STRINGS.UI.HUD.HERE)) or nil
end

function PlayerController:CancelPlacement(cache)
    if not cache then
        self.placer_cached = nil
    elseif self.placer_recipe ~= nil then
        self.placer_cached = { self.placer_recipe, self.placer_recipe_skin }
        --V2C: Leave cache alone if recipe is already nil
        --     This can get called repeatedly when controls are disabled
    end

    if self.placer ~= nil then
        self.placer:Remove()
        self.placer = nil
    end
    self.placer_recipe = nil
    self.placer_recipe_skin = nil
end

function PlayerController:CancelDeployPlacement()
    self.deploy_mode = not TheInput:ControllerAttached()
    if self.deployplacer ~= nil then
        self.deployplacer:Remove()
        self.deployplacer = nil
    end
end

function PlayerController:StartBuildPlacementMode(recipe, skin)
    self.placer_cached = nil
    self.placer_recipe = recipe
    self.placer_recipe_skin = skin

    if self.placer ~= nil then
        self.placer:Remove()
    end
    self.placer =
        skin ~= nil and
        SpawnPrefab(recipe.placer, skin, nil, self.inst.userid) or
        SpawnPrefab(recipe.placer)

    self.placer.components.placer:SetBuilder(self.inst, recipe)
    self.placer.components.placer.testfn = function(pt, rot)
        local builder = self.inst.replica.builder
        return builder ~= nil and builder:CanBuildAtPoint(pt, recipe, rot)
    end
end

function PlayerController:GetAOETargetingPos()
    return self.reticule ~= nil and self.reticule.targetpos or nil
end

function PlayerController:IsAOETargeting()
    return self.reticule ~= nil and self.reticule.inst.components.aoetargeting ~= nil
end

function PlayerController:HasAOETargeting()
    local item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    return item ~= nil
        and item.components.aoetargeting ~= nil
        and item.components.aoetargeting:IsEnabled()
        and not (self.inst.replica.rider ~= nil and self.inst.replica.rider:IsRiding())
end

function PlayerController:TryAOETargeting()
    local item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if item ~= nil and
        item.components.aoetargeting ~= nil and
        item.components.aoetargeting:IsEnabled() and
        --not self:IsBusy() and
        not (self.inst.replica.rider ~= nil and self.inst.replica.rider:IsRiding()) then
        item.components.aoetargeting:StartTargeting()
    end
end

function PlayerController:CancelAOETargeting()
    if self.reticule ~= nil and self.reticule.inst.components.aoetargeting ~= nil then
        self.reticule.inst.components.aoetargeting:StopTargeting()
    end
end

function PlayerController:EchoReticuleAt(x, y, z)
    local reticule = SpawnPrefab(self.reticule.reticuleprefab)
    if reticule ~= nil then
        reticule.Transform:SetPosition(x, 0, z)
        if reticule.Flash ~= nil then
            reticule:Flash()
        else
            reticule:DoTaskInTime(1, reticule.Remove)
        end
    end
end

function PlayerController:RefreshReticule()
    local item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if self.reticule ~= nil then
        self.reticule:DestroyReticule()
    end
    self.reticule = item ~= nil and item.components.reticule or self.inst.components.reticule
    if self.reticule ~= nil and self.reticule.reticule == nil and (self.reticule.mouseenabled or TheInput:ControllerAttached()) then
        self.reticule:CreateReticule()
        if self.reticule.reticule ~= nil and not self:IsEnabled() then
            self.reticule.reticule:Hide()
        end
    end
end

local function TargetIsHostile(inst, target)
    if inst.HostileTest ~= nil then
        return inst:HostileTest(target)
    else
        return target:HasTag("hostile")
    end
end

local function ValidateAttackTarget(combat, target, force_attack, x, z, has_weapon, reach)
    if not combat:CanTarget(target) then
        return false
    end

    --no combat if light/extinguish target
    local targetcombat = target.replica.combat
    if targetcombat ~= nil then
        if combat:IsAlly(target) then
            return false
        elseif not (force_attack or
                    combat:IsRecentTarget(target) or
                    targetcombat:GetTarget() == combat.inst) then
            --must use force attack non-hostile creatures
            if not TargetIsHostile(combat.inst, target) then
                return false
            end
            --must use force attack on players' followers
            local follower = target.replica.follower
            if follower ~= nil then
                local leader = follower:GetLeader()
                if leader ~= nil and
                    leader:HasTag("player") and
                    leader.replica.combat:GetTarget() ~= combat.inst then
                    return false
                end
            end
        end
    end

    --Now we ensure the target is in range
    --light/extinguish targets may not have physics
    reach = reach + target:GetPhysicsRadius(0)
    return target:GetDistanceSqToPoint(x, 0, z) <= reach * reach
end

local REGISTERED_FIND_ATTACK_TARGET_TAGS = TheSim:RegisterFindTags({ "_combat" }, { "INLIMBO" })

function PlayerController:GetAttackTarget(force_attack, force_target, isretarget)
    if self.inst:HasTag("playerghost") or
        self.inst:HasTag("weregoose") or
		(self.classified and self.classified.inmightygym:value() > 0) or
        self.inst.replica.inventory:IsHeavyLifting() then
        return
    end

    local combat = self.inst.replica.combat
    if combat == nil then
        return
    end

    --Don't want to spam the attack button before the server actually starts the buffered action
    if not self.ismastersim and (self.remote_controls[CONTROL_ATTACK] or 0) > 0 then
        return
    end

    if isretarget and force_target and not IsEntityDead(force_target) and CanEntitySeeTarget(self.inst, force_target) then
        return force_target
    end

    if self.inst.sg ~= nil then
        if self.inst.sg:HasStateTag("attack") then
            return
        end
    elseif self.inst:HasTag("attack") then
        return
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local attackrange = combat:GetAttackRangeWithWeapon()
    local rad = self.directwalking and attackrange or attackrange + 6
    --"not self.directwalking" is autowalking

    --Beaver teeth counts as having a weapon
    local has_weapon = self.inst:HasTag("beaver")
    if not has_weapon then
        local inventory = self.inst.replica.inventory
        local tool = inventory ~= nil and inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
        if tool ~= nil then
            local inventoryitem = tool.replica.inventoryitem
            has_weapon = inventoryitem ~= nil and inventoryitem:IsWeapon()
            if has_weapon and not force_attack and tool:HasTag("propweapon") then
                --don't require pressing force_attack when using prop weapons
                force_attack = true
            end
        end
    end

    local reach = self.inst:GetPhysicsRadius(0) + rad + .1

    if force_target ~= nil then
        return ValidateAttackTarget(combat, force_target, force_attack, x, z, has_weapon, reach) and force_target or nil
    end

    --To deal with entity collision boxes we need to pad the radius.
    --Only include combat targets for auto-targetting, not light/extinguish
    --See entityreplica.lua (re: "_combat" tag)
    local nearby_ents = TheSim:FindEntities_Registered(x, y, z, rad + 5, REGISTERED_FIND_ATTACK_TARGET_TAGS)

    local nearest_dist = math.huge
    isretarget = false --reusing variable for flagging when we've found recent target
    force_target = nil --reusing variable for our nearest target
    for i, v in ipairs(nearby_ents) do
        if ValidateAttackTarget(combat, v, force_attack, x, z, has_weapon, reach) and
            CanEntitySeeTarget(self.inst, v) then
            local dsq = self.inst:GetDistanceSqToInst(v)
            local dist = dsq <= 0 and 0 or math.max(0, math.sqrt(dsq) - v:GetPhysicsRadius(0))
            if not isretarget and combat:IsRecentTarget(v) then
                if dist < attackrange + .1 then
                    return v
                end
                isretarget = true
            end
            if dist < nearest_dist then
                nearest_dist = dist
                force_target = v
            end
        elseif not isretarget and combat:IsRecentTarget(v) then
            isretarget = true
        end
    end
    return force_target
end

function PlayerController:DoAttackButton(retarget)
    --if retarget == nil and self:IsAOETargeting() then
    --    return
    --end

    local force_attack = TheInput:IsControlPressed(CONTROL_FORCE_ATTACK)
    local target = self:GetAttackTarget(force_attack, retarget, retarget ~= self:GetCombatTarget())

    if target == nil then
        --Still need to let the server know our attack button is down
        if not self.ismastersim and
            self.locomotor == nil and
            self.remote_controls[CONTROL_ATTACK] == nil then
            self:RemoteAttackButton()
        end
        return --no target
    end

    if self.ismastersim then
        self.locomotor:PushAction(BufferedAction(self.inst, target, ACTIONS.ATTACK), true)
    elseif self.locomotor == nil then
        self:RemoteAttackButton(target, force_attack)
    elseif self:CanLocomote() then
        local buffaction = BufferedAction(self.inst, target, ACTIONS.ATTACK)
        buffaction.preview_cb = function()
            self:RemoteAttackButton(target, force_attack)
        end
        self.locomotor:PreviewAction(buffaction, true)
    end
end

function PlayerController:OnRemoteAttackButton(target, force_attack, noforce)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        --Check if target is valid, otherwise make
        --it nil so that we still attack and miss.
        if target ~= nil and not noforce then
            if self.inst.sg:HasStateTag("attack") then
                self.inst.sg.statemem.chainattack_cb = function()
                    self:OnRemoteAttackButton(target, force_attack)
                end
            else
                target = self:GetAttackTarget(force_attack, target, target ~= self:GetCombatTarget())
                self.attack_buffer = BufferedAction(self.inst, target, ACTIONS.ATTACK, nil, nil, nil, nil, true)
                self.attack_buffer._predictpos = true
            end
        else
            self.remote_controls[CONTROL_ATTACK] = 0
            target = target ~= nil and self:GetAttackTarget(force_attack, target) or nil
            if target ~= nil then
                self.attack_buffer = BufferedAction(self.inst, target, ACTIONS.ATTACK)
            end
        end
    end
end

function PlayerController:RemoteAttackButton(target, force_attack)
    if self.locomotor ~= nil then
        SendRPCToServer(RPC.AttackButton, target, force_attack)
    elseif target ~= nil then
        self.remote_controls[CONTROL_ATTACK] = BUTTON_REPEAT_COOLDOWN
        SendRPCToServer(RPC.AttackButton, target, force_attack, true)
    else
        self.remote_controls[CONTROL_ATTACK] = 0
        SendRPCToServer(RPC.AttackButton)
    end
end

local function ValidateHaunt(target)
    return target:HasActionComponent("hauntable")
end

local function ValidateBugNet(target)
    return not IsEntityDead(target)
end

local function ValidateUnsaddler(target)
    return not IsEntityDead(target)
end

local function ValidateCorpseReviver(target, inst)
    --V2C: revivablecorpse is on clients as well
    return target.components.revivablecorpse:CanBeRevivedBy(inst)
end

local function GetPickupAction(self, target, tool)
    if target:HasTag("smolder") then
        return ACTIONS.SMOTHER
    elseif tool ~= nil then
        for k, v in pairs(TOOLACTIONS) do
            if target:HasTag(k.."_workable") then
                if tool:HasTag(k.."_tool") then
                    return ACTIONS[k]
                end
                break
            end
        end
    end

    if target:HasTag("quagmireharvestabletree") and not target:HasTag("fire") then
        return ACTIONS.HARVEST_TREE
    elseif target:HasTag("trapsprung") then
        return ACTIONS.CHECKTRAP
    elseif target:HasTag("minesprung") and not target:HasTag("mine_not_reusable") then
        return ACTIONS.RESETMINE
    elseif target:HasTag("inactive") and not target:HasTag("activatable_forcenopickup") and target.replica.inventoryitem == nil then
        return (not target:HasTag("wall") or self.inst:IsNear(target, 2.5)) and ACTIONS.ACTIVATE or nil
    elseif target.replica.inventoryitem ~= nil and
        target.replica.inventoryitem:CanBePickedUp() and
        not (target:HasTag("heavy") or target:HasTag("fire") or target:HasTag("catchable")) and
        not target:HasTag("spider") then
        return (self:HasItemSlots() or target.replica.equippable ~= nil) and ACTIONS.PICKUP or nil
    elseif target:HasTag("pickable") and not target:HasTag("fire") then
        return ACTIONS.PICK
    elseif target:HasTag("harvestable") then
        return ACTIONS.HARVEST
    elseif target:HasTag("readyforharvest") or
        (target:HasTag("notreadyforharvest") and target:HasTag("withered")) then
        return ACTIONS.HARVEST
    elseif target:HasTag("tapped_harvestable") and not target:HasTag("fire") then
        return ACTIONS.HARVEST
    elseif target:HasTag("tendable_farmplant") and not self.inst:HasTag("mime") and not target:HasTag("fire") then
        return ACTIONS.INTERACT_WITH
    elseif target:HasTag("dried") and not target:HasTag("burnt") then
        return ACTIONS.HARVEST
    elseif target:HasTag("donecooking") and not target:HasTag("burnt") then
        return ACTIONS.HARVEST
    elseif tool ~= nil and tool:HasTag("unsaddler") and target:HasTag("saddled") and not IsEntityDead(target) then
        return ACTIONS.UNSADDLE
    elseif tool ~= nil and tool:HasTag("brush") and target:HasTag("brushable") and not IsEntityDead(target) then
        return ACTIONS.BRUSH
    elseif self.inst.components.revivablecorpse ~= nil and target:HasTag("corpse") and ValidateCorpseReviver(target, self.inst) then
        return ACTIONS.REVIVE_CORPSE
    end
    --no action found
end

function PlayerController:IsDoingOrWorking()
    if self.inst.sg == nil then
        return self.inst:HasTag("doing")
            or self.inst:HasTag("working")
    elseif not self.ismastersim and self.inst:HasTag("autopredict") then
        return self.inst.sg:HasStateTag("doing")
            or self.inst.sg:HasStateTag("working")
    end
    return self.inst.sg:HasStateTag("doing")
        or self.inst.sg:HasStateTag("working")
        or self.inst:HasTag("doing")
        or self.inst:HasTag("working")
end

local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local REGISTERED_CONTROLLER_ATTACK_TARGET_TAGS = TheSim:RegisterFindTags({ "_combat" }, TARGET_EXCLUDE_TAGS)

local PICKUP_TARGET_EXCLUDE_TAGS = { "catchable", "mineactive", "intense" }
local HAUNT_TARGET_EXCLUDE_TAGS = { "haunted", "catchable" }
for i, v in ipairs(TARGET_EXCLUDE_TAGS) do
    table.insert(PICKUP_TARGET_EXCLUDE_TAGS, v)
    table.insert(HAUNT_TARGET_EXCLUDE_TAGS, v)
end

local CATCHABLE_TAGS = { "catchable" }
local PINNED_TAGS = { "pinned" }
local CORPSE_TAGS = { "corpse" }
function PlayerController:GetActionButtonAction(force_target)
    local isenabled, ishudblocking = self:IsEnabled()
	
    --Don't want to spam the action button before the server actually starts the buffered action
    --Also check if playercontroller is enabled
    --Also check if force_target is still valid
    if (not self.ismastersim and (self.remote_controls[CONTROL_ACTION] or 0) > 0) or
        (not isenabled and not ishudblocking) or
        self:IsBusy() or
        (force_target ~= nil and (not force_target.entity:IsVisible() or force_target:HasTag("INLIMBO") or force_target:HasTag("NOCLICK"))) then
        --"DECOR" should never change, should be safe to skip that check
        return

    elseif self.actionbuttonoverride ~= nil then
        local buffaction, usedefault = self.actionbuttonoverride(self.inst, force_target)
        if not usedefault or buffaction ~= nil then
            return buffaction
        end

    elseif self.inst.replica.inventory:IsHeavyLifting()
        and not (self.inst.replica.rider ~= nil and self.inst.replica.rider:IsRiding()) then
        --hands are full!
        return

    elseif not self:IsDoingOrWorking() then
        local force_target_distsq = force_target ~= nil and self.inst:GetDistanceSqToInst(force_target) or nil

        if self.inst:HasTag("playerghost") then
            --haunt
            if force_target == nil then
                local target = FindEntity(self.inst, self.directwalking and 3 or 6, ValidateHaunt, nil, HAUNT_TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.HAUNT)
                end
            elseif force_target_distsq <= (self.directwalking and 9 or 36) and
                not (force_target:HasTag("haunted") or force_target:HasTag("catchable")) and
                ValidateHaunt(force_target) then
                return BufferedAction(self.inst, force_target, ACTIONS.HAUNT)
            end
            return
        end

        local tool = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        --bug catching (has to go before combat)
        if tool ~= nil and tool:HasTag(ACTIONS.NET.id.."_tool") then
            if force_target == nil then
                local target = FindEntity(self.inst, 5, ValidateBugNet, { "_health", ACTIONS.NET.id.."_workable" }, TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.NET, tool)
                end
            elseif force_target_distsq <= 25 and
                force_target.replica.health ~= nil and
                ValidateBugNet(force_target) and
                force_target:HasTag(ACTIONS.NET.id.."_workable") then
                return BufferedAction(self.inst, force_target, ACTIONS.NET, tool)
            end
        end

        --catching
        if self.inst:HasTag("cancatch") then
            if force_target == nil then
                local target = FindEntity(self.inst, 10, nil, CATCHABLE_TAGS, TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.CATCH)
                end
            elseif force_target_distsq <= 100 and
                force_target:HasTag("catchable") then
                return BufferedAction(self.inst, force_target, ACTIONS.CATCH)
            end
        end

        --unstick
        if force_target == nil then
            local target = FindEntity(self.inst, self.directwalking and 3 or 6, nil, PINNED_TAGS, TARGET_EXCLUDE_TAGS)
            if CanEntitySeeTarget(self.inst, target) then
                return BufferedAction(self.inst, target, ACTIONS.UNPIN)
            end
        elseif force_target_distsq <= (self.directwalking and 9 or 36) and
            force_target:HasTag("pinned") then
            return BufferedAction(self.inst, force_target, ACTIONS.UNPIN)
        end

        --revive (only need to do this if i am also revivable)
        if self.inst.components.revivablecorpse ~= nil then
            if force_target == nil then
                local target = FindEntity(self.inst, 3, ValidateCorpseReviver, CORPSE_TAGS, TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.REVIVE_CORPSE)
                end
            elseif force_target_distsq <= 9
                and force_target:HasTag("corpse")
                and ValidateCorpseReviver(force_target, self.inst) then
                return BufferedAction(self.inst, force_target, ACTIONS.REVIVE_CORPSE)
            end
        end

        --misc: pickup, tool work, smother
        if force_target == nil then
            local pickup_tags =
            {
                "_inventoryitem",
                "pickable",
                "donecooking",
                "readyforharvest",
                "notreadyforharvest",
                "harvestable",
                "trapsprung",
                "minesprung",
                "dried",
                "inactive",
                "smolder",
                "saddled",
                "brushable",
                "tapped_harvestable",
                "tendable_farmplant",
            }
            if tool ~= nil then
                for k, v in pairs(TOOLACTIONS) do
                    if tool:HasTag(k.."_tool") then
                        table.insert(pickup_tags, k.."_workable")
                    end
                end
            end
            if self.inst.components.revivablecorpse ~= nil then
                table.insert(pickup_tags, "corpse")
            end
            local x, y, z = self.inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, self.directwalking and 3 or 6, nil, PICKUP_TARGET_EXCLUDE_TAGS, pickup_tags)
            for i, v in ipairs(ents) do
                if v ~= self.inst and v.entity:IsVisible() and CanEntitySeeTarget(self.inst, v) then
                    local action = GetPickupAction(self, v, tool)
                    if action ~= nil then
                        return BufferedAction(self.inst, v, action, action ~= ACTIONS.SMOTHER and tool or nil)
                    end
                end
            end
        elseif force_target_distsq <= (self.directwalking and 9 or 36) then
            local action = GetPickupAction(self, force_target, tool)
            if action ~= nil then
                return BufferedAction(self.inst, force_target, action, action ~= ACTIONS.SMOTHER and tool or nil)
            end
        end
    end
end

function PlayerController:DoActionButton()
    --if self:IsAOETargeting() then
    --    return
    --end
    if self.placer == nil then        
        local buffaction = self:GetActionButtonAction()
        if buffaction ~= nil then
            if buffaction.action.pre_action_cb ~= nil then
                buffaction.action.pre_action_cb(buffaction)
            end

            if self.ismastersim then
                self.locomotor:PushAction(buffaction, true)
                return
            elseif self.locomotor == nil then
                self:RemoteActionButton(buffaction)
                return
            elseif self:CanLocomote() then
                if buffaction.action ~= ACTIONS.WALKTO then
                    buffaction.preview_cb = function()
                        self:RemoteActionButton(buffaction, not TheInput:IsControlPressed(CONTROL_ACTION) or nil)
                    end
                end
                self.locomotor:PreviewAction(buffaction, true)
            end
        end
    elseif self.placer.components.placer.can_build and
        self.inst.replica.builder ~= nil and
        not self.inst.replica.builder:IsBusy() then
        --do the placement
        self.inst.replica.builder:MakeRecipeAtPoint(self.placer_recipe,
            self.placer.components.placer.override_build_point_fn ~= nil and self.placer.components.placer.override_build_point_fn(self.placer) or self.placer:GetPosition(),
            self.placer:GetRotation(), self.placer_recipe_skin)
    elseif self.placer.components.placer.onfailedplacement ~= nil then
        self.placer.components.placer.onfailedplacement(self.inst, self.placer)
    end

    --Still need to let the server know our action button is down
    if not self.ismastersim and self.remote_controls[CONTROL_ACTION] == nil then
        self:RemoteActionButton()
    end
end

function PlayerController:OnRemoteActionButton(actioncode, target, isreleased, noforce, mod_name)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.remote_controls[CONTROL_ACTION] = 0
        if actioncode ~= nil then
            SetClientRequestedAction(actioncode, mod_name)
            local buffaction = self:GetActionButtonAction(target)
            ClearClientRequestedAction()
            if buffaction ~= nil and buffaction.action.code == actioncode and buffaction.action.mod_name == mod_name then
                if buffaction.action.canforce and not noforce then
                    buffaction:SetActionPoint(self:GetRemotePredictPosition() or self.inst:GetPosition())
                    buffaction.forced = true
                end
                self.locomotor:PushAction(buffaction, true)
            --elseif mod_name ~= nil then
                --print("Remote action button action failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
            --else
                --print("Remote action button action failed: "..tostring(ACTION_IDS[actioncode]))
            end
        end
        if isreleased then
            self.remote_controls[CONTROL_ACTION] = nil
        end
    end
end

function PlayerController:RemoteActionButton(action, isreleased)
    local actioncode = action ~= nil and action.action.code or nil
    local action_mod_name = action ~= nil and action.action.mod_name or nil
    local target = action ~= nil and action.target or nil
    local noforce = self.locomotor == nil and action ~= nil and action.action.canforce or nil
    self.remote_controls[CONTROL_ACTION] = action ~= nil and BUTTON_REPEAT_COOLDOWN or 0
    SendRPCToServer(RPC.ActionButton, actioncode, target, isreleased, noforce, action_mod_name)
end

function PlayerController:GetInspectButtonAction(target)
    return target ~= nil and
        target:HasTag("inspectable") and
        (self.inst.CanExamine == nil or self.inst:CanExamine()) and
        (self.inst.sg == nil or self.inst.sg:HasStateTag("moving") or self.inst.sg:HasStateTag("idle") or self.inst.sg:HasStateTag("channeling")) and
        (self.inst:HasTag("moving") or self.inst:HasTag("idle") or self.inst:HasTag("channeling")) and
        BufferedAction(self.inst, target, ACTIONS.LOOKAT) or
        nil
end

function PlayerController:DoInspectButton()
    if not self:IsEnabled()
        or (self.inst.HUD ~= nil and
            self.inst.HUD:IsPlayerAvatarPopUpOpen()) then
        --V2C: Closing the avatar popup takes priority
        return
    end
    local buffaction = TheInput:ControllerAttached() and self:GetInspectButtonAction(self:GetControllerTarget()) or nil
    if buffaction == nil then
        return
    end

    if buffaction.action == ACTIONS.LOOKAT and
        buffaction.target ~= nil and
        buffaction.target.components.playeravatardata ~= nil and
        self.inst.HUD ~= nil then
        local client_obj = buffaction.target.components.playeravatardata:GetData()
        if client_obj ~= nil then
            client_obj.inst = buffaction.target
            self.inst.HUD:TogglePlayerAvatarPopup(client_obj.name, client_obj, true)
        end
    end

    if self.ismastersim then
        self.locomotor:PushAction(buffaction, true)
    elseif self.locomotor == nil then
        self:RemoteInspectButton(buffaction)
    elseif self:CanLocomote() then
        buffaction.preview_cb = function()
            self:RemoteInspectButton(buffaction)
        end
        self.locomotor:PreviewAction(buffaction, true)
    end
end

function PlayerController:OnRemoteInspectButton(target)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        local buffaction = self:GetInspectButtonAction(target)
        if buffaction ~= nil then
            self.locomotor:PushAction(buffaction, true)
        --else
            --print("Remote inspect button action failed")
        end
    end
end

function PlayerController:RemoteInspectButton(action)
    SendRPCToServer(RPC.InspectButton, action.target)
end

function PlayerController:GetResurrectButtonAction()
    return self.inst:HasTag("playerghost") and
        (self.inst.sg == nil or self.inst.sg:HasStateTag("moving") or self.inst.sg:HasStateTag("idle")) and
        (self.inst:HasTag("moving") or self.inst:HasTag("idle")) and
        self.inst.components.attuner:HasAttunement("remoteresurrector") and
        BufferedAction(self.inst, nil, ACTIONS.REMOTERESURRECT) or
        nil
end

function PlayerController:DoResurrectButton()
    if not self:IsEnabled() then
        return
    end
    local buffaction = self:GetResurrectButtonAction()
    if buffaction == nil then
        return
    elseif self.ismastersim then
        self.locomotor:PushAction(buffaction, true)
    elseif self.locomotor == nil then
        self:RemoteResurrectButton(buffaction)
    elseif self:CanLocomote() then
        buffaction.preview_cb = function()
            self:RemoteResurrectButton(buffaction)
        end
        self.locomotor:PreviewAction(buffaction, true)
    end
end

function PlayerController:OnRemoteResurrectButton()
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        local buffaction = self:GetResurrectButtonAction()
        if buffaction ~= nil then
            self.locomotor:PushAction(buffaction, true)
        --else
            --print("Remote resurrect button action failed")
        end
    end
end

function PlayerController:RemoteResurrectButton()
    SendRPCToServer(RPC.ResurrectButton)
end

function PlayerController:UsingMouse()
    return not TheInput:ControllerAttached()
end

function PlayerController:ClearActionHold()
    self.actionholding = false
    self.actionholdtime = nil
    self.lastheldaction = nil
    self.lastheldactiontime = nil
    self.actionrepeatfunction = nil
    if not self.ismastersim then
        SendRPCToServer(RPC.ClearActionHold)
    end
end

local ACTIONHOLD_CONTROLS = {CONTROL_PRIMARY, CONTROL_SECONDARY, CONTROL_CONTROLLER_ALTACTION, CONTROL_INVENTORY_USEONSELF, CONTROL_INVENTORY_USEONSCENE}
local function IsAnyActionHoldButtonHeld()
    for i, v in ipairs(ACTIONHOLD_CONTROLS) do
        if TheInput:IsControlPressed(v) then
            return true
        end
    end
    return false
end

function PlayerController:RepeatHeldAction()
    if not self.ismastersim then
        if self.actionrepeatfunction and (self.lastheldactiontime == nil or GetTime() - self.lastheldactiontime < 1) then
            self.lastheldactiontime = GetTime()
            if self.heldactioncooldown == 0 then
                self.heldactioncooldown = INVENTORY_ACTIONHOLD_REPEAT_COOLDOWN
                self:actionrepeatfunction()
            end
        else
            SendRPCToServer(RPC.RepeatHeldAction)
        end
    else
        if self.lastheldaction and self.lastheldaction:IsValid() and (self.lastheldactiontime == nil or GetTime() - self.lastheldactiontime < 1) then
            self.lastheldactiontime = GetTime()
            if self.heldactioncooldown == 0 then
                self.heldactioncooldown = ACTION_REPEAT_COOLDOWN
                self:DoAction(self.lastheldaction)
            end
        elseif self.actionrepeatfunction and (self.lastheldactiontime == nil or GetTime() - self.lastheldactiontime < 1) then
            self.lastheldactiontime = GetTime()
            if self.heldactioncooldown == 0 then
                self.heldactioncooldown = INVENTORY_ACTIONHOLD_REPEAT_COOLDOWN
                self:actionrepeatfunction()
            end
        else
            self:ClearActionHold()
        end
    end
end

function PlayerController:OnWallUpdate(dt)
    if self.handler then
        self:DoCameraControl()
    end
end

function PlayerController:GetCombatRetarget()
    if self.inst.sg then
        return self.inst.sg.statemem.retarget
    elseif self.inst.replica.combat then
        return self.inst.replica.combat:GetTarget()
    end
end

function PlayerController:GetCombatTarget()
    if self.inst.sg then
        return self.inst.sg.statemem.attacktarget
    end
    return nil
end

function PlayerController:OnUpdate(dt)
    local isenabled, ishudblocking = self:IsEnabled()
    self.predictionsent = false

	if self:IsControllerTargetingModifierDown() and self.controller_targeting_lock_timer then
		-- check whether the controller targeting modifier has been held long enough to toggle locking
		self.controller_targeting_lock_timer = self.controller_targeting_lock_timer + dt
		if CONTROLLER_TARGETING_LOCK_TIME < self.controller_targeting_lock_timer then
			self:ControllerTargetLock(true)
			-- Use the block below if you want to both lock and unlock the target by holding down the modifier button
			--[[
			if self:IsControllerTargetLockEnabled() then
				self:ControllerTargetLock(false)
			else
				self:ControllerTargetLock(true)
			end
			--]]
			self.controller_targeting_lock_timer = nil
		end
    end

    if self.actionholding and not (isenabled and IsAnyActionHoldButtonHeld()) then
        self:ClearActionHold()
    end

    if self.draggingonground and not (isenabled and TheInput:IsControlPressed(CONTROL_PRIMARY)) then
        if self.locomotor ~= nil then
            self.locomotor:Stop()
        end
        self.draggingonground = false
        self.startdragtime = nil
        TheFrontEnd:LockFocus(false)
    end

    --ishudblocking set to true lets us know that the only reason for isenabled returning false is due to HUD wanting to handle some input.
    if not isenabled then
		local allow_loco = ishudblocking
		if not allow_loco then
			if self.directwalking or self.dragwalking then
				if self.locomotor ~= nil then
					self.locomotor:Stop()
					self.locomotor:Clear()
				end
				self.directwalking = false
				self.dragwalking = false
				self.predictwalking = false
				if not self.ismastersim then
					self:RemoteStopWalking()
				end
			end
		end

        if self.handler ~= nil then
            self:CancelPlacement(true)
            self:CancelDeployPlacement()
            self:CancelAOETargeting()

            if self.reticule ~= nil and self.reticule.reticule ~= nil then
                self.reticule.reticule:Hide()
            end

            if self.terraformer ~= nil then
                self.terraformer:Remove()
                self.terraformer = nil
            end

            self.LMBaction, self.RMBaction = nil, nil
            self.controller_target = nil
            self.controller_attack_target = nil
            self.controller_attack_target_ally_cd = nil
            if self.highlight_guy ~= nil and self.highlight_guy:IsValid() and self.highlight_guy.components.highlight ~= nil then
                self.highlight_guy.components.highlight:UnHighlight()
            end
            self.highlight_guy = nil
        end

        if self.ismastersim then
            self:ResetRemoteController()
        else
            self:RemoteStopAllControls()

            --Other than HUD blocking, we would've been enabled otherwise
            if not self:IsBusy() then
                self:DoPredictWalking(dt)
            end
        end

        self.controller_attack_override = nil
        self.bufferedcastaoe = nil

		if not allow_loco then
	        self.attack_buffer = nil
		end
    end

	--Attack controls are buffered and handled here in the update
	if self.attack_buffer ~= nil then
		if self.attack_buffer == CONTROL_ATTACK then
			self:DoAttackButton()
		elseif self.attack_buffer == CONTROL_CONTROLLER_ATTACK then
			self:DoControllerAttackButton()
		else
			if self.attack_buffer._predictpos then
				self.attack_buffer:SetActionPoint(self:GetRemotePredictPosition() or self.inst:GetPosition())
			end
			if self.attack_buffer._controller then
				if self.attack_buffer.target == nil then
					self.controller_attack_override = self:IsControlPressed(CONTROL_CONTROLLER_ATTACK) and self.attack_buffer or nil
				end
				self:DoAction(self.attack_buffer)
			else
				self.locomotor:PushAction(self.attack_buffer, true)
			end
		end
		self.attack_buffer = nil
	end

    if isenabled then
		--Restore cached placer
		if self.placer_cached ~= nil then
			if self.inst.replica.inventory:IsVisible() then
				self:StartBuildPlacementMode(unpack(self.placer_cached))
			end
			self.placer_cached = nil
		end


		if self.handler ~= nil then
			local controller_mode = TheInput:ControllerAttached()
			local new_highlight = nil
			if not self.inst:IsActionsVisible() then
				--Don't highlight when actions are hidden
			elseif controller_mode then
				self.LMBaction, self.RMBaction = nil, nil
				self:UpdateControllerTargets(dt)
				new_highlight = self.controller_target
			else
				self.controller_target = nil
				self.controller_attack_target = nil
				self.controller_attack_target_ally_cd = nil
				self.LMBaction, self.RMBaction = self.inst.components.playeractionpicker:DoGetMouseActions()

				--If an action has a target, highlight the target.
				--If an action has no target and no pos, then it should
				--be an inventory action where doer is ourself and we are
				--targeting ourself, so highlight ourself
				new_highlight =
					(self.LMBaction ~= nil
					and (self.LMBaction.target
						or (self.LMBaction.pos == nil and
							self.LMBaction.doer == self.inst and
							self.inst))) or
					(self.RMBaction ~= nil
					and (self.RMBaction.target
						or (self.RMBaction.pos == nil and
							self.RMBaction.doer == self.inst and
							self.inst))) or
					nil
			end

			local new_highlight_guy = new_highlight ~= nil and new_highlight.highlightforward or new_highlight
			if new_highlight_guy ~= self.highlight_guy then
				if self.highlight_guy ~= nil and self.highlight_guy:IsValid() and self.highlight_guy.components.highlight ~= nil then
					self.highlight_guy.components.highlight:UnHighlight()
				end
				self.highlight_guy = new_highlight_guy
			end

			if new_highlight_guy ~= nil and new_highlight_guy:IsValid() then
				if new_highlight_guy.components.highlight == nil then
					new_highlight_guy:AddComponent("highlight")
				end

				if not self.inst.shownothightlight then
					--V2C: check tags on the original, not the forwarded
					if new_highlight:HasTag("burnt") then
						new_highlight_guy.components.highlight:Highlight(.5, .5, .5)
					else
						new_highlight_guy.components.highlight:Highlight()
					end
				end
			else
				self.highlight_guy = nil
			end

			if self.reticule ~= nil and not (controller_mode or self.reticule.mouseenabled) then
				self.reticule:DestroyReticule()
				self.reticule = nil
			end

			if self.placer ~= nil and self.placer_recipe ~= nil and
				not (self.inst.replica.builder ~= nil and self.inst.replica.builder:IsBuildBuffered(self.placer_recipe.name)) then
				self:CancelPlacement()
			end

			local placer_item = controller_mode and self:GetCursorInventoryObject() or self.inst.replica.inventory:GetActiveItem()
			--show deploy placer
			if self.deploy_mode and
				self.placer == nil and
				placer_item ~= nil and
				placer_item.replica.inventoryitem ~= nil and
				placer_item.replica.inventoryitem:IsDeployable(self.inst) then

				local placer_name = placer_item.replica.inventoryitem:GetDeployPlacerName()
				local placer_skin = placer_item.AnimState:GetSkinBuild() --hack that relies on the build name to match the linked skinname
                if placer_skin == "" then
                    placer_skin = nil
                end
                if self.deployplacer ~= nil and (self.deployplacer.prefab ~= placer_name or self.deployplacer.skinname ~= placer_skin) then
					self:CancelDeployPlacement()
				end
				if self.deployplacer == nil then
					self.deployplacer = SpawnPrefab(placer_name, placer_skin, nil, self.inst.userid )
					if self.deployplacer ~= nil then
						self.deployplacer.components.placer:SetBuilder(self.inst, nil, placer_item)
						self.deployplacer.components.placer.testfn = function(pt)
							local mouseover = TheInput:GetWorldEntityUnderMouse()
							return placer_item:IsValid() and
								placer_item.replica.inventoryitem ~= nil and
								placer_item.replica.inventoryitem:CanDeploy(pt, mouseover, self.inst, self.deployplacer.Transform:GetRotation()),
								(mouseover ~= nil and not mouseover:HasTag("walkableplatform")) or TheInput:GetHUDEntityUnderMouse() ~= nil
						end
						self.deployplacer.components.placer:OnUpdate(0) --so that our position is accurate on the first frame
					end
				end
			else
				self:CancelDeployPlacement()
			end

			local terraform = false
			local hidespecialactionreticule = false
			local terraform_action = nil
			if controller_mode then
				local lmb, rmb = self:GetGroundUseAction()
				if rmb ~= nil then
					terraform = rmb.action.tile_placer ~= nil
					terraform_action = rmb.action
					hidespecialactionreticule = self.reticule ~= nil and self.reticule.inst == self.inst
				else
					if self.controller_target ~= nil then
						lmb, rmb = self:GetSceneItemControllerAction(self.controller_target)
					end
					if rmb ~= nil then
						hidespecialactionreticule = true
					else
						local rider = self.inst.replica.rider
						hidespecialactionreticule = rider ~= nil and rider:IsRiding() or not self:HasGroundUseSpecialAction(true)
					end
				end
			else
				local rmb = self:GetRightMouseAction()
				if rmb ~= nil then
					terraform = rmb.action.tile_placer ~= nil and (rmb.action.show_tile_placer_fn == nil or rmb.action.show_tile_placer_fn(self:GetRightMouseAction()))
					terraform_action = rmb.action
				end
			end

			--show right action reticule
			if self.placer == nil and self.deployplacer == nil then
				if terraform then
					if self.terraformer == nil then
						self.terraformer = SpawnPrefab(terraform_action.tile_placer)
						if self.terraformer ~= nil and self.terraformer.components.placer ~= nil then
							self.terraformer.components.placer:SetBuilder(self.inst)
							self.terraformer.components.placer:OnUpdate(0)
						end
					end
				elseif self.terraformer ~= nil then
					self.terraformer:Remove()
					self.terraformer = nil
				end

				if self.reticule ~= nil and self.reticule.reticule ~= nil then
					if hidespecialactionreticule or self.reticule:ShouldHide() then
						self.reticule.reticule:Hide()
					else
						self.reticule.reticule:Show()
					end
				end
			else
				if self.terraformer ~= nil then
					self.terraformer:Remove()
					self.terraformer = nil
				end

				if self.reticule ~= nil and self.reticule.reticule ~= nil then
					self.reticule.reticule:Hide()
				end
			end

			if not self.actionholding and self.actionholdtime and IsAnyActionHoldButtonHeld() then
				if GetTime() - self.actionholdtime > START_DRAG_TIME then
					self.actionholding = true
				end
			end

			if not self.draggingonground and self.startdragtime ~= nil and TheInput:IsControlPressed(CONTROL_PRIMARY) then
				local now = GetTime()
				if now - self.startdragtime > START_DRAG_TIME then
					TheFrontEnd:LockFocus(true)
					self.draggingonground = true
				end
			end

			if TheFrontEnd:GetFocusWidget() ~= self.inst.HUD then
				if self.draggingonground then
					self.draggingonground = false
					self.startdragtime = nil

					TheFrontEnd:LockFocus(false)

					if self:CanLocomote() then
						self.locomotor:Stop()
					end
				elseif self.actionholding then
					self:ClearActionHold()
				end
			end
		elseif self.ismastersim and self.inst:HasTag("nopredict") and self.remote_vector.y >= 3 then
			self.remote_vector.y = 0
		end

		self:CooldownHeldAction(dt)
		if self.actionholding then
			self:RepeatHeldAction()
		end

		if self.controller_attack_override ~= nil and
			not (self.locomotor.bufferedaction == self.controller_attack_override and
				self:IsControlPressed(CONTROL_CONTROLLER_ATTACK)) then
			self.controller_attack_override = nil
		end
	end

    self:DoPredictHopping(dt)

	if not isenabled and not ishudblocking then
		return
	end

    --NOTE: isbusy is used further below as well
    local isbusy = self:IsBusy()
	if isbusy and self.inst.sg ~= nil and self.inst:HasTag("jumping") then
		isbusy = isbusy and self.inst.sg:HasStateTag("jumping")
	end

    if isbusy or
        self:DoPredictWalking(dt) or
        self:DoDragWalking(dt) then
        self.bufferedcastaoe = nil
    else
        if not self.inst:HasTag("steeringboat") then
            if self.wassteering then
                -- end reticule
                local boat = self.inst:GetCurrentPlatform()
                if boat then
                    boat:PushEvent("endsteeringreticule",{player=self.inst})
                end
                self.wassteering = nil
            end
            self:DoDirectWalking(dt)
        else
            if not self.wassteering then
                -- start reticule
                local boat = self.inst:GetCurrentPlatform()
                if boat then
                    boat:PushEvent("starsteeringreticule",{player=self.inst})
                end
            end
            self.wassteering = true
            self:DoBoatSteering(dt)

        end
    end

    --do automagic control repeats
	if self.handler ~= nil then
        local isidle = self.inst:HasTag("idle")

        if not self.ismastersim then
            --clear cooldowns if we actually did something on the server
            --otherwise just decrease
            --if the server is still "idle", then it hasn't begun processing the action yet
            --when using movement prediction, the RPC is sent AFTER reaching the destination,
            --so we must also check that the server is not still "moving"
            self:CooldownRemoteController((isidle or (self.inst.sg ~= nil and self.inst:HasTag("moving"))) and dt or nil)
        end

        if self.inst.sg ~= nil then
            isidle = self.inst.sg:HasStateTag("idle") or (isidle and self.inst:HasTag("nopredict"))
        end
        if isidle then
            if TheInput:IsControlPressed(CONTROL_ACTION) then
                self:OnControl(CONTROL_ACTION, true)
            elseif TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
                and not self:IsDoingOrWorking() then
                self:OnControl(CONTROL_CONTROLLER_ACTION, true)
            end
        end
    end

    if self.ismastersim and self.handler == nil and not self.inst.sg.mem.localchainattack then
        if self.inst.sg.statemem.chainattack_cb ~= nil then
            if self.locomotor ~= nil and self.locomotor.bufferedaction ~= nil and self.locomotor.bufferedaction.action == ACTIONS.CASTAOE then
                self.inst.sg.statemem.chainattack_cb = nil
            elseif not self.inst.sg:HasStateTag("attack") then
                --Handles chain attack commands received at irregular intervals
                local fn = self.inst.sg.statemem.chainattack_cb
                self.inst.sg.statemem.chainattack_cb = nil
                fn()
            end
        end
    elseif (self.ismastersim or self.handler ~= nil)
        and not (self.directwalking or isbusy)
        and not (self.locomotor ~= nil and self.locomotor.bufferedaction ~= nil and self.locomotor.bufferedaction.action == ACTIONS.CASTAOE) then
        local attack_control = false
        local currenttarget = self:GetCombatTarget()
        local retarget = self:GetCombatRetarget()
        if self.inst.sg ~= nil then
            attack_control = not self.inst.sg:HasStateTag("attack") or currenttarget ~= retarget
        else
            attack_control = not self.inst:HasTag("attack")
        end
        if attack_control then
            attack_control = (self.handler == nil or not IsPaused())
                and ((self:IsControlPressed(CONTROL_ATTACK) and CONTROL_ATTACK) or
                    (self:IsControlPressed(CONTROL_PRIMARY) and CONTROL_PRIMARY) or
                    (self:IsControlPressed(CONTROL_CONTROLLER_ATTACK) and not self:IsAOETargeting() and CONTROL_CONTROLLER_ATTACK))
                or nil
            if attack_control ~= nil then
                if retarget and not IsEntityDead(retarget) and CanEntitySeeTarget(self.inst, retarget) then
                    --Handle chain attacking
                    if self.inst.sg ~= nil then
                        if self.handler == nil then
                            retarget = self:GetAttackTarget(false, retarget, retarget ~= currenttarget)
                            if retarget ~= nil then
                                self.locomotor:PushAction(BufferedAction(self.inst, retarget, ACTIONS.ATTACK), true)
                            end
                        elseif attack_control ~= CONTROL_CONTROLLER_ATTACK then
                            self:DoAttackButton(retarget)
                        else
                            self:DoControllerAttackButton(retarget)
                        end
                    end
                elseif attack_control ~= CONTROL_PRIMARY and self.handler ~= nil then
                    --Check for starting a new attack
                    local isidle
                    if self.inst.sg ~= nil then
                        isidle = self.inst.sg:HasStateTag("idle") or (self.inst:HasTag("idle") and self.inst:HasTag("nopredict"))
                    else
                        isidle = self.inst:HasTag("idle")
                    end
                    if isidle then
                        self:OnControl(attack_control, true)
                    end
                end
            end
        end
    end

    if self.handler ~= nil and TheInput:TryRecacheController() then
        --Could also push pause screen, but it won't come up right
        --away if controls were disabled at the time of the switch
        TheWorld:PushEvent("continuefrompause")
        TheInput:EnableMouse(not TheInput:ControllerAttached())
    end
end

local function UpdateControllerAttackTarget(self, dt, x, y, z, dirx, dirz)
    if self.inst:HasTag("playerghost") or self.inst.replica.inventory:IsHeavyLifting() then
        self.controller_attack_target = nil
        self.controller_attack_target_ally_cd = nil

		-- we can't target right now; disable target locking
		self.controller_targeting_lock_target = false
        return
    end

    local combat = self.inst.replica.combat

    self.controller_attack_target_ally_cd = math.max(0, (self.controller_attack_target_ally_cd or 1) - dt)

    if self.controller_attack_target ~= nil and
        not (combat:CanTarget(self.controller_attack_target) and
            CanEntitySeeTarget(self.inst, self.controller_attack_target)) then
        self.controller_attack_target = nil

		-- target is no longer valid; disable target locking
		self.controller_targeting_lock_target = false
        --it went invalid, but we're not resetting the age yet
    end

    --self.controller_attack_target_age = self.controller_attack_target_age + dt
    --if self.controller_attack_target_age < .3 then
        --prevent target flickering
    --    return
    --end

    local min_rad = 4
    local max_rad = math.max(min_rad, combat:GetAttackRangeWithWeapon()) + 3
    local min_rad_sq = min_rad * min_rad
    local max_rad_sq = max_rad * max_rad

    --see entity_replica.lua for "_combat" tag

	local nearby_ents = TheSim:FindEntities_Registered(x, y, z, max_rad, REGISTERED_CONTROLLER_ATTACK_TARGET_TAGS)
    if self.controller_attack_target ~= nil then
        --Note: it may already contain controller_attack_target,
        --      so make sure to handle it only once later
        table.insert(nearby_ents, 1, self.controller_attack_target)
    end

    local target = nil
    local target_score = 0
    local target_isally = true
    local preferred_target =
        TheInput:IsControlPressed(CONTROL_CONTROLLER_ATTACK) and
        self.controller_attack_target or
        combat:GetTarget() or
        nil

	local current_controller_targeting_targets = {}
	local selected_target_index = 0
    for i, v in ipairs(nearby_ents) do
        if v ~= self.inst and (v ~= self.controller_attack_target or i == 1) then
            local isally = combat:IsAlly(v)
            if not (isally and
                    self.controller_attack_target_ally_cd > 0 and
                    v ~= preferred_target) and
                combat:CanTarget(v) then
                --Check distance including y value
                local x1, y1, z1 = v.Transform:GetWorldPosition()
                local dx, dy, dz = x1 - x, y1 - y, z1 - z
                local dsq = dx * dx + dy * dy + dz * dz

                if dsq < max_rad_sq and CanEntitySeePoint(self.inst, x1, y1, z1) then
                    local dist = dsq > 0 and math.sqrt(dsq) or 0
                    local dot = dist > 0 and dx / dist * dirx + dz / dist * dirz or 0
                    if dot > 0 or dist < min_rad then
                        local score = dot + 1 - .5 * dsq / max_rad_sq

                        if isally then
                            score = score * .25
                        elseif v:HasTag("epic") then
                            score = score * 5
                        elseif v:HasTag("monster") then
                            score = score * 4
                        end

                        if v.replica.combat:GetTarget() == self.inst then
                            score = score * 6
                        end

                        if v == preferred_target then
                            score = score * 10
                        end

						table.insert(current_controller_targeting_targets, v)
                        if score > target_score then
							selected_target_index = #current_controller_targeting_targets
                            target = v
                            target_score = score
                            target_isally = isally
                        end
                    end
                end
            end
        end
    end

	if self.controller_attack_target ~= nil and self.controller_targeting_lock_target then
		-- we have a target and target locking is enabled so only update the list of valid targets, ie. check for targets that have appeared or disappeared

		-- first check if any targets should be removed
		for idx_outer = #self.controller_targeting_targets, 1, -1 do
			local found = false
			local existing_target = self.controller_targeting_targets[idx_outer]
			for idx_inner = #current_controller_targeting_targets, 1, -1 do
				if existing_target == current_controller_targeting_targets[idx_inner] then
					-- we found the existing target in the list of current nearby entities so remove it from the current entity list to
					-- make later addition of new entities more straightforward
					table.remove(current_controller_targeting_targets, idx_inner)
					found = true
					break
				end
			end

			-- if the existing target isn't found in the nearby entities then remove it from the targets
			if not found then
				table.remove(self.controller_targeting_targets, idx_outer)
			end
		end

		-- now add new targets; check everything left in the nearby_ents table as we've been
		-- removing existing targets from it as we checked for targets that were no longer valid
		for i, v in ipairs(current_controller_targeting_targets) do
			table.insert(self.controller_targeting_targets, v)
		end

		-- fin
		return
	end

    if self.controller_target ~= nil and self.controller_target:IsValid() then
        if target ~= nil then
            if target:HasTag("wall") and
                self.classified ~= nil and
                self.classified.hasgift:value() and
                self.classified.hasgiftmachine:value() and
                self.controller_target:HasTag("giftmachine") then
                --if giftmachine has (Y) control priority, then it
                --should also have (X) control priority over walls
                target = nil
                target_isally = true
            end
        elseif self.controller_target:HasTag("wall") and not IsEntityDead(self.controller_target, true) then
            --if we have no (X) control target, then give
            --it to our (Y) control target if it's a wall
            target = self.controller_target
            target_isally = false
        end
    end

    if target ~= self.controller_attack_target then
        self.controller_attack_target = target
		self.controller_targeting_target_index = selected_target_index
        --self.controller_attack_target_age = 0
    end

    if not target_isally then
        --reset ally targeting cooldown
        self.controller_attack_target_ally_cd = nil
    end
end

local function UpdateControllerInteractionTarget(self, dt, x, y, z, dirx, dirz)

	local attack_target = self:GetControllerAttackTarget()
	if self.controller_targeting_lock_target and attack_target then
		self.controller_target = attack_target
		return
	end

    if self.placer ~= nil or (self.deployplacer ~= nil and self.deploy_mode) then
        self.controller_target = nil
        self.controller_target_age = 0
        return
    elseif self.controller_target ~= nil
        and (not self.controller_target:IsValid() or
            self.controller_target:HasTag("INLIMBO") or
            self.controller_target:HasTag("NOCLICK") or
            not CanEntitySeeTarget(self.inst, self.controller_target)) then
        --"FX" and "DECOR" tag should never change, should be safe to skip that check
        self.controller_target = nil
        --it went invalid, but we're not resetting the age yet
    end

    self.controller_target_age = self.controller_target_age + dt
    if self.controller_target_age < .2 then
        --prevent target flickering
        return
    end

    --catching
    if self.inst:HasTag("cancatch") then
        local target = FindEntity(self.inst, 10, nil, CATCHABLE_TAGS, TARGET_EXCLUDE_TAGS)
        if CanEntitySeeTarget(self.inst, target) then
            if target ~= self.controller_target then
                self.controller_target = target
                self.controller_target_age = 0
            end
            return
        end
    end

    local equiped_item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    --Fishing targets may have large radius, making it hard to target with normal priority
    local fishing = equiped_item ~= nil and equiped_item:HasTag("fishingrod")

    -- we want to never target our fishing hook, but others can
    local ocean_fishing_target = (equiped_item ~= nil and equiped_item.replica.oceanfishingrod ~= nil) and equiped_item.replica.oceanfishingrod:GetTarget() or nil

    local min_rad = 1.5
    local max_rad = 6
    local min_rad_sq = min_rad * min_rad
    local max_rad_sq = max_rad * max_rad
    local rad =
            self.controller_target ~= nil and
            math.max(min_rad, math.min(max_rad, math.sqrt(self.inst:GetDistanceSqToInst(self.controller_target)))) or
            max_rad
    local rad_sq = rad * rad + .1 --allow small error

    local nearby_ents = TheSim:FindEntities(x, y, z, fishing and max_rad or rad, nil, TARGET_EXCLUDE_TAGS)
    if self.controller_target ~= nil then
        --Note: it may already contain controller_target,
        --      so make sure to handle it only once later
        table.insert(nearby_ents, 1, self.controller_target)
    end

    local target = nil
    local target_score = 0
    local canexamine = (self.inst.CanExamine == nil or self.inst:CanExamine())
				and (not self.inst.HUD:IsPlayerAvatarPopUpOpen())
				and (self.inst.sg == nil or self.inst.sg:HasStateTag("moving") or self.inst.sg:HasStateTag("idle") or self.inst.sg:HasStateTag("channeling"))
				and (self.inst:HasTag("moving") or self.inst:HasTag("idle") or self.inst:HasTag("channeling"))

    for i, v in ipairs(nearby_ents) do
        if v ~= ocean_fishing_target then

            --Only handle controller_target if it's the one we added at the front
            if v ~= self.inst and (v ~= self.controller_target or i == 1) and v.entity:IsVisible() then
                if v.entity:GetParent() == self.inst and v:HasTag("bundle") then
                    --bundling or constructing
                    target = v
                    break
                end

                --Check distance including y value
                local x1, y1, z1 = v.Transform:GetWorldPosition()
                local dx, dy, dz = x1 - x, y1 - y, z1 - z
                local dsq = dx * dx + dy * dy + dz * dz

                if fishing and v:HasTag("fishable") then
                    local r = v:GetPhysicsRadius(0)
                    if dsq <= r * r then
                        dsq = 0
                    end
                end

                if (dsq < min_rad_sq
                    or (dsq <= rad_sq
                        and (v == self.controller_target or
                            v == self.controller_attack_target or
                            dx * dirx + dz * dirz > 0))) and
                    CanEntitySeePoint(self.inst, x1, y1, z1) then

                    local dist = dsq > 0 and math.sqrt(dsq) or 0
                    local dot = dist > 0 and dx / dist * dirx + dz / dist * dirz or 0

                    --keep the angle component between [0..1]
                    local angle_component = (dot + 1) / 2

                    --distance doesn't matter when you're really close, and then attenuates down from 1 as you get farther away
                    local dist_component = dsq < min_rad_sq and 1 or min_rad_sq / dsq

                    --for stuff that's *really* close - ie, just dropped
                    local add = dsq < .0625 --[[.25 * .25]] and 1 or 0

                    --just a little hysteresis
                    local mult = v == self.controller_target and not v:HasTag("wall") and 1.5 or 1

                    local score = angle_component * dist_component * mult + add

                    --make it easier to target stuff dropped inside the portal when alive
                    --make it easier to haunt the portal for resurrection in endless mode
                    if v:HasTag("portal") then
                        score = score * (self.inst:HasTag("playerghost") and GetPortalRez(TheNet:GetServerGameMode()) and 1.1 or .9)
                    end

                    --print(v, angle_component, dist_component, mult, add, score)

                    if score < target_score or
                        (   score == target_score and
                            (   (target ~= nil and not (target.CanMouseThrough ~= nil and target:CanMouseThrough())) or
                                (v.CanMouseThrough ~= nil and v:CanMouseThrough())
                            )
                        ) then
                        --skip
                    elseif canexamine and v:HasTag("inspectable") then
                        target = v
                        target_score = score
                    else
                        --this is kind of expensive, so ideally we don't get here for many objects
                        local lmb, rmb = self:GetSceneItemControllerAction(v)
                        if lmb ~= nil or rmb ~= nil then
                            target = v
                            target_score = score
                        else
                            local inv_obj = self:GetCursorInventoryObject()
                            if inv_obj ~= nil and self:GetItemUseAction(inv_obj, v) ~= nil then
                                target = v
                                target_score = score
                            end
                        end
                    end
                end
            end
        end
    end
    if target ~= self.controller_target then
        self.controller_target = target
        self.controller_target_age = 0
    end
end

function PlayerController:UpdateControllerTargets(dt)
    if self:IsAOETargeting() or (self.inst:HasTag("weregoose") and not self.inst:HasTag("playerghost") or (self.classified and self.classified.inmightygym:value() > 0)) then
        self.controller_target = nil
        self.controller_target_age = 0
        self.controller_attack_target = nil
        self.controller_attack_target_ally_cd = nil
        self.controller_targeting_lock_target = nil
        return
    end
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local heading_angle = -self.inst.Transform:GetRotation()
    local dirx = math.cos(heading_angle * DEGREES)
    local dirz = math.sin(heading_angle * DEGREES)
    UpdateControllerInteractionTarget(self, dt, x, y, z, dirx, dirz)
    UpdateControllerAttackTarget(self, dt, x, y, z, dirx, dirz)
end

function PlayerController:GetControllerTarget()
    return self.controller_target ~= nil and self.controller_target:IsValid() and self.controller_target or nil
end

function PlayerController:GetControllerAttackTarget()
    return self.controller_attack_target ~= nil and self.controller_attack_target:IsValid() and self.controller_attack_target or nil
end

function PlayerController:IsControllerTargetingModifierDown()
    return self.controller_targeting_modifier_down
end

function PlayerController:IsControllerTargetLockEnabled()
	return self.controller_targeting_lock_target
end

function PlayerController:IsControllerTargetLocked()
	return self.controller_targeting_lock_target and self.controller_attack_target
end

function PlayerController:ControllerTargetLock(enable)
	if enable then
		-- only enable locking if there's a target
		if self.controller_attack_target then
			self.controller_targeting_lock_target = enable
		end
	else
		-- disable locking at any time
		self.controller_targeting_lock_target = enable
	end
end

function PlayerController:CycleControllerAttackTargetForward()
	local num_targets = #self.controller_targeting_targets
	if self.controller_targeting_lock_target and num_targets > 0 then
		self.controller_targeting_target_index = self.controller_targeting_target_index + 1
		if self.controller_targeting_target_index > num_targets then
			self.controller_targeting_target_index = 1
		end
		self.controller_attack_target = self.controller_targeting_targets[self.controller_targeting_target_index]
	end
end

function PlayerController:CycleControllerAttackTargetBack()
	local num_targets = #self.controller_targeting_targets
	if self.controller_targeting_lock_target and num_targets > 0 then
		self.controller_targeting_target_index = self.controller_targeting_target_index - 1
		if self.controller_targeting_target_index < 1 then
			self.controller_targeting_target_index = num_targets
		end
		self.controller_attack_target = self.controller_targeting_targets[self.controller_targeting_target_index]
	end
end


--------------------------------------------------------------------------
--remote_vector.y is used as a flag for stop/direct/drag walking
--since its value is never actually used in the walking function

function PlayerController:ResetRemoteController()
    self.remote_vector.y = 0
    if next(self.remote_controls) ~= nil then
        self.remote_controls = {}
    end
end

function PlayerController:GetRemoteDirectVector()
    return self.remote_vector.y == 1 and self.remote_vector or nil
end

function PlayerController:GetRemoteDragPosition()
    return self.remote_vector.y == 2 and self.remote_vector or nil
end

function PlayerController:GetRemotePredictPosition()
    return self.remote_vector.y >= 3 and self.remote_vector or nil
end

function PlayerController:OnRemoteDirectWalking(x, z)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.remote_vector.x = x
        self.remote_vector.y = 1
        self.remote_vector.z = z
    end
end

function PlayerController:OnRemoteDragWalking(x, z)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.remote_vector.x = x
        self.remote_vector.y = 2
        self.remote_vector.z = z
    end
end

function PlayerController:OnRemotePredictWalking(x, z, isdirectwalking)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.remote_vector.x = x
        self.remote_vector.y = isdirectwalking and 3 or 4
        self.remote_vector.z = z
    end
end

function PlayerController:OnRemoteStartHop(x, z, platform)
    if not self.ismastersim then return end
    if not self:IsEnabled() then return end
    if not self.handler == nil then return end

    local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
    local target_x, target_y, target_z = x, 0, z
    local platform_for_velocity_calculation = platform

    if platform ~= nil then
        target_x, target_z = platform.components.walkableplatform:GetEmbarkPosition(my_x, my_z)
    else
        platform_for_velocity_calculation = self.inst:GetCurrentPlatform()
    end

	if platform == nil and (platform_for_velocity_calculation == nil or TheWorld.Map:IsOceanAtPoint(target_x, 0, target_z)) then
        return
	end

    local hop_dir_x, hop_dir_z = target_x - my_x, target_z - my_z
    local hop_distance_sq = hop_dir_x * hop_dir_x + hop_dir_z * hop_dir_z

    local target_velocity_rubber_band_distance = 0
    local platform_velocity_x, platform_velocity_z = 0, 0
    if platform_for_velocity_calculation ~= nil then
        local platform_physics = platform_for_velocity_calculation.Physics
        if platform_physics ~= nil then
            platform_velocity_x, platform_velocity_z = platform_physics:GetVelocity()
            if platform_velocity_x ~= 0 or platform_velocity_z ~= 0 then
                local hop_distance = math.sqrt(hop_distance_sq)
                local normalized_hop_dir_x, normalized_hop_dir_z = hop_dir_x / hop_distance, hop_dir_z / hop_distance
                local velocity = math.sqrt(platform_velocity_x * platform_velocity_x + platform_velocity_z * platform_velocity_z)
                local normalized_platform_velocity_x, normalized_platform_velocity_z = platform_velocity_x / velocity, platform_velocity_z / velocity
                local hop_dir_dot_platform_velocity = normalized_platform_velocity_x * normalized_hop_dir_x + normalized_platform_velocity_z * normalized_hop_dir_z
                if hop_dir_dot_platform_velocity > 0 then
                    target_velocity_rubber_band_distance = RUBBER_BAND_PING_TOLERANCE_IN_SECONDS * velocity * hop_dir_dot_platform_velocity
                end
            end
        end
    end

    local locomotor = self.inst.components.locomotor
    local hop_rubber_band_distance = RUBBER_BAND_DISTANCE + target_velocity_rubber_band_distance + locomotor:GetHopDistance()
    local hop_rubber_band_distance_sq = hop_rubber_band_distance * hop_rubber_band_distance

    if hop_distance_sq > hop_rubber_band_distance_sq then
        print("Hop discarded:", "\ntarget_velocity_rubber_band_distance", target_velocity_rubber_band_distance, "\nplatform_velocity_x", platform_velocity_x, "\nplatform_velocity_z", platform_velocity_z, "\nhop_distance", math.sqrt(hop_distance_sq), "\nhop_rubber_band_distance", math.sqrt(hop_rubber_band_distance_sq))
        return
    end

    self.remote_vector.y = 6
    self.inst.components.locomotor:StartHopping(x,z,platform)
end

function PlayerController:OnRemoteStopWalking()
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.remote_vector.y = 0
    end
end

function PlayerController:OnRemoteStopHopping()
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.remote_vector.y = 0
    end
end

function PlayerController:RemoteDirectWalking(x, z)
    if self.remote_vector.x ~= x or self.remote_vector.z ~= z or self.remote_vector.y ~= 1 then
        SendRPCToServer(RPC.DirectWalking, x, z) -- x and z are directions, not positions, so we don't need it to be platform relative
        self.remote_vector.x = x
        self.remote_vector.y = 1
        self.remote_vector.z = z
    end
end

function PlayerController:RemoteDragWalking(x, z)
    if self.remote_vector.x ~= x or self.remote_vector.z ~= z or self.remote_vector.y ~= 2 then
		local platform, pos_x, pos_z = self:GetPlatformRelativePosition(x, z)
        SendRPCToServer(RPC.DragWalking, pos_x, pos_z, platform, platform ~= nil)
        self.remote_vector.x = x
        self.remote_vector.y = 2
        self.remote_vector.z = z
    end
end

function PlayerController:RemotePredictWalking(x, z)
    local y = self.directwalking and 3 or 4
    if self.remote_vector.x ~= x or self.remote_vector.z ~= z or (self.remote_vector.y ~= y and self.remote_vector.y ~= 0) then
		local platform, pos_x, pos_z = self:GetPlatformRelativePosition(x, z)
        SendRPCToServer(RPC.PredictWalking, pos_x, pos_z, self.directwalking, platform, platform ~= nil)
        self.remote_vector.x = x
        self.remote_vector.y = y
        self.remote_vector.z = z
        self.predictionsent = true
    end
end

function PlayerController:RemoteStopWalking()
    if self.remote_vector.y ~= 0 then
        SendRPCToServer(RPC.StopWalking)
        self.remote_vector.y = 0
    end
end

function PlayerController:DoPredictHopping(dt)
    if ThePlayer == self.inst and not self.ismastersim then
        local locomotor = self.inst.components.locomotor
        if locomotor ~= nil then
            if locomotor.hopping and not self.is_hopping then
                local embarker = locomotor.inst.components.embarker
                local disembark_x, disembark_z = embarker:GetEmbarkPosition()
                local target_platform = embarker.embarkable
                SendRPCToServer(RPC.StartHop, disembark_x, disembark_z, target_platform, target_platform ~= nil)
            end
            self.is_hopping = locomotor.hopping
        else
            self.is_hopping = false
        end
    end
end

function PlayerController:IsLocalOrRemoteHopping()
    local pt = self:GetRemotePredictPosition()
    if pt ~= nil and pt.y == 6 then return true end

    local locomotor = self.inst.components.locomotor
    if locomotor ~= nil then return locomotor.hopping end
    return false
end

function PlayerController:DoPredictWalking(dt)
    if self.ismastersim then
        local pt = self:GetRemotePredictPosition()
        if pt ~= nil and not self:IsLocalOrRemoteHopping() then
            local x0, y0, z0 = self.inst.Transform:GetWorldPosition()
            local distancetotargetsq = distsq(pt.x, pt.z, x0, z0)
            local stopdistancesq = .05

            if pt.y == 5 and
                (self.locomotor.bufferedaction ~= nil or
                self.inst.bufferedaction ~= nil or
                not (self.inst.sg:HasStateTag("idle") or
                    self.inst.sg:HasStateTag("moving"))) then
                --We're performing an action now, so ignore predict walking
                self.directwalking = false
                self.dragwalking = false
                self.predictwalking = false
                if distancetotargetsq <= stopdistancesq then
                    self.remote_vector.y = 0
                end
                return true
            end

            if pt.y < 5 then
                self.inst:ClearBufferedAction()
            end

            if distancetotargetsq > stopdistancesq then
                self.locomotor:RunInDirection(self.inst:GetAngleToPoint(pt))
            else
                --Destination reached, queued (instead of immediate) stop
                --so that prediction may be resumed before the next frame
                self.inst:FacePoint(pt)
                self.locomotor:Stop({ force_idle_state = true }) --force idle state in case this tiny motion was meant to cancel an action
            end

            --Even though we're predict walking, we want the server to behave
            --according to whether the client thinks he's direct/drag walking
            if pt.y == 3 then
                if self.directwalking then
                    self.time_direct_walking = self.time_direct_walking + dt
                else
                    self.time_direct_walking = dt
                    self.directwalking = true
                    self.dragwalking = false
                    self.predictwalking = false
                end

                if self.time_direct_walking > .2 and not self.inst.sg:HasStateTag("attack") then
                    self.inst.components.combat:SetTarget(nil)
                end
            elseif pt.y == 4 then
                self.directwalking = false
                self.dragwalking = true
                self.predictwalking = false
            else
                self.directwalking = false
                self.dragwalking = false
                self.predictwalking = true
            end

            --Detect stop, teleport, or prediction errors
            --Cancel the cached prediction vector and force resync if necessary
            if distancetotargetsq <= stopdistancesq then
                self.remote_vector.y = 0
            elseif distancetotargetsq > RUBBER_BAND_DISTANCE_SQ then
                self.remote_vector.y = 0
                self.inst.Physics:Teleport(self.inst.Transform:GetWorldPosition())
            end

            return true
        end
    else
        local x, y, z = self.inst.Transform:GetPredictionPosition()
        if self:CanLocomote() then
            if self.inst.sg:HasStateTag("moving") then
                if x ~= nil and y ~= nil and z ~= nil then
                    self:RemotePredictWalking(x, z)
                end
            end
        end
    end
end

function PlayerController:DoDragWalking(dt)
    if self:IsLocalOrRemoteHopping() then return end
    local pt = nil
    if self.locomotor == nil or self:CanLocomote() then
        if self.handler == nil then
            pt = self:GetRemoteDragPosition()
        elseif self.draggingonground then
            pt = TheInput:GetWorldPosition()
        end
    end
    if pt ~= nil then
        local x0, y0, z0 = self.inst.Transform:GetWorldPosition()
        if distsq(pt.x, pt.z, x0, z0) > 1 then
            self.inst:ClearBufferedAction()
            if not self.ismastersim then
                self:CooldownRemoteController()
            end
            if self:CanLocomote() then
                self.locomotor:RunInDirection(self.inst:GetAngleToPoint(pt))
            end
        end
        self.directwalking = false
        self.dragwalking = true
        self.predictwalking = false
        if not self.ismastersim and self.locomotor == nil then
            self:RemoteDragWalking(pt.x, pt.z)
        end
        return true
    end
end

function PlayerController:DoBoatSteering(dt)
    local dir = nil

    if self.handler == nil then
        dir = self:GetRemoteDirectVector()
    else
        dir = GetWorldControllerVector()
    end

    if dir ~= nil then
        if self.ismastersim then
            local steeringwheeluser = self.inst.components.steeringwheeluser
            if steeringwheeluser ~= nil then
                steeringwheeluser:SteerInDir(dir.x, dir.z)
            end
        else
            SendRPCToServer(RPC.SteerBoat, dir.x, dir.z)
        end
    end
end

function PlayerController:DoDirectWalking(dt)
    if self:IsLocalOrRemoteHopping() then return end
    local dir = nil
    if (self.locomotor == nil or self:CanLocomote()) and
        not (self.controller_attack_override ~= nil or
            (self.inst.sg ~= nil and
            self.inst.sg:HasStateTag("attack") and
            self:IsControlPressed(CONTROL_CONTROLLER_ATTACK))) then
        if self.handler == nil then
            dir = self:GetRemoteDirectVector()
        else
            dir = GetWorldControllerVector()
        end
        --Prevent cancelling actions when letting go of direct walking controls late
        if dir ~= nil and
            self.bufferedcastaoe ~= nil and
            self.bufferedcastaoe.t > dt and
            self.bufferedcastaoe.x == dir.x and
            self.bufferedcastaoe.z == dir.z and
            self.bufferedcastaoe.act == self.locomotor.bufferedaction then
            self.bufferedcastaoe.t = self.bufferedcastaoe.t - dt
        else
            self.bufferedcastaoe = nil
        end
    else
        self.bufferedcastaoe = nil
    end
    if self.bufferedcastaoe ~= nil then
        self.directwalking = false
        self.dragwalking = false
        self.predictwalking = false
        if not self.ismastersim then
            self:CooldownRemoteController()
        end
    elseif dir ~= nil then
        self.inst:ClearBufferedAction()

        if not self.ismastersim then
            self:CooldownRemoteController()
        end

        if self:CanLocomote() then
            self.locomotor:SetBufferedAction(nil)
            self.locomotor:RunInDirection(-math.atan2(dir.z, dir.x) / DEGREES)
        end

        if self.directwalking then
            self.time_direct_walking = self.time_direct_walking + dt
        else
            self.time_direct_walking = dt
            self.directwalking = true
            self.dragwalking = false
            self.predictwalking = false
        end

        if not self.ismastersim then
            if self.locomotor == nil then
                self:RemoteDirectWalking(dir.x, dir.z)
            end
        elseif self.time_direct_walking > .2 and not self.inst.sg:HasStateTag("attack") then
            self.inst.components.combat:SetTarget(nil)
        end
    elseif self.predictwalking then
        if self.locomotor.bufferedaction == nil then
            self.locomotor:Stop()
        end
        self.directwalking = false
        self.dragwalking = false
        self.predictwalking = false
    elseif self.directwalking or self.dragwalking then
        if self:CanLocomote() and self.controller_attack_override == nil then
            self.locomotor:Stop()
        end
        self.directwalking = false
        self.dragwalking = false
        self.predictwalking = false
        if not self.ismastersim then
            self:CooldownRemoteController()
            if self.locomotor == nil then
                self:RemoteStopWalking()
            end
        end
    end
end

--------------------------------------------------------------------------
local ROT_REPEAT = .25
local ZOOM_REPEAT = .1

function PlayerController:DoCameraControl()
    if not TheCamera:CanControl() then
        return
    end

    local isenabled, ishudblocking = self:IsEnabled()
    if not isenabled and not ishudblocking then
		return
    end

    local time = GetStaticTime()
	local invert_rotation = Profile:GetInvertCameraRotation()

    if not self:IsControllerTargetingModifierDown() and (self.lastrottime == nil or time - self.lastrottime > ROT_REPEAT) then
        if TheInput:IsControlPressed(invert_rotation and CONTROL_ROTATE_RIGHT or CONTROL_ROTATE_LEFT) then
            self:RotLeft()
            self.lastrottime = time
        elseif TheInput:IsControlPressed(invert_rotation and CONTROL_ROTATE_LEFT or CONTROL_ROTATE_RIGHT) then
            self:RotRight()
            self.lastrottime = time
        end
    end

	if self.lastzoomtime == nil or time - self.lastzoomtime > ZOOM_REPEAT then
		if TheInput:IsControlPressed(CONTROL_ZOOM_IN) then
			if not self.zoomin_same_as_scrollup or (self.inst.HUD ~= nil and self.inst.HUD.controls ~= nil and not self.inst.HUD.controls.craftingmenu.focus) then
				TheCamera:ZoomIn()
				self.lastzoomtime = time
			end
		elseif TheInput:IsControlPressed(CONTROL_ZOOM_OUT) then
			if not self.zoomout_same_as_scrolldown or (self.inst.HUD ~= nil and self.inst.HUD.controls ~= nil and not self.inst.HUD.controls.craftingmenu.focus) then
				TheCamera:ZoomOut()
				self.lastzoomtime = time
			end
		end
	end
end

local function IsWalkButtonDown()
    return TheInput:IsControlPressed(CONTROL_MOVE_UP) or TheInput:IsControlPressed(CONTROL_MOVE_DOWN) or TheInput:IsControlPressed(CONTROL_MOVE_LEFT) or TheInput:IsControlPressed(CONTROL_MOVE_RIGHT)
end

function PlayerController:OnLeftUp()
    if not self:IsEnabled() then
        return
    end

    if self.draggingonground then
        if self:CanLocomote() and not IsWalkButtonDown() then
            self.locomotor:Stop()
        end
        self.draggingonground = false
        self.startdragtime = nil
        TheFrontEnd:LockFocus(false)
    end
    self.startdragtime = nil

    if not self.ismastersim then
        self:RemoteStopControl(CONTROL_PRIMARY)
    end
end

function PlayerController:DoAction(buffaction)
    --Check if the action is actually valid.
    --Cached LMB/RMB actions can become invalid.
    --Also check if we're busy.

    if buffaction == nil or
        (buffaction.invobject ~= nil and not buffaction.invobject:IsValid()) or
        (buffaction.target ~= nil and not buffaction.target:IsValid()) or
        (buffaction.doer ~= nil and not buffaction.doer:IsValid()) or
        self:IsBusy() then
        self.actionholdtime = nil
        return
    end

    --Check for duplicate actions
    local currentbuffaction = self.inst:GetBufferedAction()
    if currentbuffaction ~= nil and
        currentbuffaction.action == buffaction.action and
        currentbuffaction.target == buffaction.target and
        (   (currentbuffaction.pos == nil and buffaction.pos == nil) or
            (currentbuffaction.pos == buffaction.pos) -- Note: see overloaded DynamicPosition:__eq function
        ) and
        not (currentbuffaction.ispreviewing and
            self.inst:HasTag("idle") and
            self.inst.sg:HasStateTag("idle")) then
        --The "not" bit is in case we are stuck waiting for server
        --to act but it never does
        return
    end

    if buffaction.action == ACTIONS.ATTACK and self.inst.sg then
        self.inst.sg.statemem.retarget = buffaction.target
    end

    if self.handler ~= nil and buffaction.target ~= nil then
        local highlight_guy = buffaction.target.highlightforward or buffaction.target
        if highlight_guy.components.highlight == nil then
            highlight_guy:AddComponent("highlight")
        end
        highlight_guy.components.highlight:Flash(.2, .125, .1)
    end

    --Clear any buffered attacks since we're starting a new action
    self.attack_buffer = nil

    self:DoActionAutoEquip(buffaction)

    if not buffaction.action.instant and not buffaction.action.invalid_hold_action and buffaction:IsValid() then
        self.lastheldaction = buffaction
    else
        self.actionholdtime = nil
    end

    if buffaction.action and buffaction.action.pre_action_cb ~= nil then
        buffaction.action.pre_action_cb(buffaction)
    end

    if self.ismastersim then
        self.locomotor:PushAction(buffaction, true)
    elseif self:CanLocomote() then
        self.locomotor:PreviewAction(buffaction, true)
    end
end

function PlayerController:DoActionAutoEquip(buffaction)
    local equippable = buffaction.invobject ~= nil and buffaction.invobject.replica.equippable or nil
    if equippable ~= nil and
        equippable:EquipSlot() == EQUIPSLOTS.HANDS and
        not equippable:IsRestricted(self.inst) and
        buffaction.action ~= ACTIONS.DROP and
        buffaction.action ~= ACTIONS.COMBINESTACK and
        buffaction.action ~= ACTIONS.STORE and
        buffaction.action ~= ACTIONS.BUNDLESTORE and
        buffaction.action ~= ACTIONS.EQUIP and
        buffaction.action ~= ACTIONS.GIVETOPLAYER and
        buffaction.action ~= ACTIONS.GIVEALLTOPLAYER and
        buffaction.action ~= ACTIONS.GIVE and
        buffaction.action ~= ACTIONS.ADDFUEL and
        buffaction.action ~= ACTIONS.ADDWETFUEL and
        buffaction.action ~= ACTIONS.DEPLOY and
        buffaction.action ~= ACTIONS.CONSTRUCT and
        buffaction.action ~= ACTIONS.ADDCOMPOSTABLE then
        self.inst.replica.inventory:EquipActionItem(buffaction.invobject)
        buffaction.autoequipped = true
    end
end

function PlayerController:OnLeftClick(down)
    if not self:UsingMouse() then
        return
    elseif not down then
        self:OnLeftUp()
        return
    end

    self:ClearActionHold()

    self.startdragtime = nil

    if not self:IsEnabled() then
        return
    elseif TheInput:GetHUDEntityUnderMouse() ~= nil then
        self:CancelPlacement()
        return
    elseif self.placer_recipe ~= nil and self.placer ~= nil then

        --do the placement
        if self.placer.components.placer.can_build then

            if self.inst.replica.builder ~= nil and not self.inst.replica.builder:IsBusy() then
                self.inst.replica.builder:MakeRecipeAtPoint(self.placer_recipe,
                    self.placer.components.placer.override_build_point_fn ~= nil and self.placer.components.placer.override_build_point_fn(self.placer) or TheInput:GetWorldPosition(),
                    self.placer:GetRotation(), self.placer_recipe_skin)
                self:CancelPlacement()
            end

        elseif self.placer.components.placer.onfailedplacement ~= nil then
            self.placer.components.placer.onfailedplacement(self.inst, self.placer)
        end

        return
    end

    self.actionholdtime = GetTime()

    local act = nil
    if self:IsAOETargeting() then
        if self:IsBusy() then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative", nil, .4)
            self.reticule:Blip()
            return
        end
        act = self:GetRightMouseAction()
        if act == nil or act.action ~= ACTIONS.CASTAOE then
            return
        end
        self.reticule:PingReticuleAt(act:GetActionPoint())
        self:CancelAOETargeting()
    elseif act == nil then
        act = self:GetLeftMouseAction() or BufferedAction(self.inst, nil, ACTIONS.WALKTO, nil, TheInput:GetWorldPosition())
    end

    if act.action == ACTIONS.WALKTO then
        local entity_under_mouse = TheInput:GetWorldEntityUnderMouse()
        if act.target == nil and (entity_under_mouse == nil or entity_under_mouse:HasTag("walkableplatform")) then
            self.startdragtime = GetTime()
        end
    elseif act.action == ACTIONS.ATTACK then
        if self.inst.sg ~= nil then
            self.inst.sg.statemem.retarget = act.target
            if self.inst.sg:HasStateTag("attack") and act.target == self.inst.replica.combat:GetTarget() then
                return
            end
        elseif self.inst:HasTag("attack") and act.target == self.inst.replica.combat:GetTarget() then
            return
        end
    elseif act.action == ACTIONS.LOOKAT and act.target ~= nil and self.inst.HUD ~= nil then
        if act.target.components.playeravatardata ~= nil then
            local client_obj = act.target.components.playeravatardata:GetData()
            if client_obj ~= nil then
                client_obj.inst = act.target
                self.inst.HUD:TogglePlayerAvatarPopup(client_obj.name, client_obj, true)
            end
        elseif act.target.quagmire_shoptab ~= nil then
            self.inst:PushEvent("quagmire_shoptab", act.target.quagmire_shoptab)
        end
    end

    if self.ismastersim then
        self.inst.components.combat:SetTarget(nil)
    else
        local mouseover, platform, pos_x, pos_z
        if act.action == ACTIONS.CASTAOE then
			platform = act.pos.walkable_platform
			pos_x = act.pos.local_pt.x
			pos_z = act.pos.local_pt.z
        else
            local position = TheInput:GetWorldPosition()
			platform, pos_x, pos_z = self:GetPlatformRelativePosition(position.x, position.z)
            mouseover = act.action ~= ACTIONS.DROP and TheInput:GetWorldEntityUnderMouse() or nil
        end

        local controlmods = self:EncodeControlMods()
        if self.locomotor == nil then
            self.remote_controls[CONTROL_PRIMARY] = 0
            SendRPCToServer(RPC.LeftClick, act.action.code, pos_x, pos_z, mouseover, nil, controlmods, act.action.canforce, act.action.mod_name, platform, platform ~= nil)
        elseif act.action ~= ACTIONS.WALKTO and self:CanLocomote() then
            act.preview_cb = function()
                self.remote_controls[CONTROL_PRIMARY] = 0
                local isreleased = not TheInput:IsControlPressed(CONTROL_PRIMARY)
                SendRPCToServer(RPC.LeftClick, act.action.code, pos_x, pos_z, mouseover, isreleased, controlmods, nil, act.action.mod_name, platform, platform ~= nil)
            end
        end
    end

    self:DoAction(act)
end

function PlayerController:OnRemoteLeftClick(actioncode, position, target, isreleased, controlmodscode, noforce, mod_name)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.inst.components.combat:SetTarget(nil)

        self.remote_controls[CONTROL_PRIMARY] = 0
        self:DecodeControlMods(controlmodscode)
        SetClientRequestedAction(actioncode, mod_name)
        local lmb, rmb = self.inst.components.playeractionpicker:DoGetMouseActions(position, target)
        ClearClientRequestedAction()
        if isreleased then
            self.remote_controls[CONTROL_PRIMARY] = nil
        end
        self:ClearControlMods()

        --Default fallback lmb action is WALKTO
        --Possible for lmb action to switch to rmb after autoequip
        lmb =  (lmb == nil and
                actioncode == ACTIONS.WALKTO.code and
                mod_name == nil and
                BufferedAction(self.inst, nil, ACTIONS.WALKTO, nil, position))
            or (lmb ~= nil and
                lmb.action.code == actioncode and
                lmb.action.mod_name == mod_name and
                lmb)
            or (rmb ~= nil and
                rmb.action.code == actioncode and
                rmb.action.mod_name == mod_name and
                rmb)
            or nil

        if lmb ~= nil then
            if lmb.action.canforce and not noforce then
                lmb:SetActionPoint(self:GetRemotePredictPosition() or self.inst:GetPosition())
                lmb.forced = true
            end
            self:DoAction(lmb)
        --elseif mod_name ~= nil then
            --print("Remote left click action failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
        --else
            --print("Remote left click action failed: "..tostring(ACTION_IDS[actioncode]))
        end
    end
end

function PlayerController:GetPlatformRelativePosition(absolute_x,absolute_z)
    local platform = TheWorld.Map:GetPlatformAtPoint(absolute_x,absolute_z)
    if platform ~= nil then
        local platform_x, platform_y, platform_z = platform.Transform:GetWorldPosition()
        absolute_x = absolute_x - platform_x
        absolute_z = absolute_z - platform_z
    end

    return platform, absolute_x, absolute_z
end

function PlayerController:OnRightClick(down)
    if not self:UsingMouse() then
        return
    elseif not down then
        if self:IsEnabled() then
            self:RemoteStopControl(CONTROL_SECONDARY)
        end
        return
    end

    self:ClearActionHold()

    self.startdragtime = nil

    if self.placer_recipe ~= nil then
        self:CancelPlacement()
        return
    elseif self:IsAOETargeting() then
        self:CancelAOETargeting()
        return
    elseif not self:IsEnabled() or TheInput:GetHUDEntityUnderMouse() ~= nil then
        return
    end

    self.actionholdtime = GetTime()

    local act = self:GetRightMouseAction()
    if act == nil then
		if self.inst.HUD ~= nil and self.inst.HUD:IsCraftingOpen() then
			self.inst.HUD:CloseCrafting()
		else
			self.inst.replica.inventory:ReturnActiveItem()
			self:TryAOETargeting()
		end
    else
        if self.reticule ~= nil and self.reticule.reticule ~= nil then
            self.reticule:PingReticuleAt(act:GetActionPoint())
        end
        if self.deployplacer ~= nil and act.action == ACTIONS.DEPLOY then
            act.rotation = self.deployplacer.Transform:GetRotation()
        end
        if not self.ismastersim then
            local position = TheInput:GetWorldPosition()
            local mouseover = TheInput:GetWorldEntityUnderMouse()
            local controlmods = self:EncodeControlMods()
            local platform, pos_x, pos_z = self:GetPlatformRelativePosition(position.x, position.z)
            if self.locomotor == nil then
                self.remote_controls[CONTROL_SECONDARY] = 0
                SendRPCToServer(RPC.RightClick, act.action.code, pos_x, pos_z, mouseover, act.rotation ~= 0 and act.rotation or nil, nil, controlmods, act.action.canforce, act.action.mod_name, platform, platform ~= nil)
            elseif act.action ~= ACTIONS.WALKTO and self:CanLocomote() then
                act.preview_cb = function()
                    self.remote_controls[CONTROL_SECONDARY] = 0
                    local isreleased = not TheInput:IsControlPressed(CONTROL_SECONDARY)
                    SendRPCToServer(RPC.RightClick, act.action.code, pos_x, pos_z, mouseover, act.rotation ~= 0 and act.rotation or nil, isreleased, controlmods, nil, act.action.mod_name, platform, platform ~= nil)
                end
            end
        end
        self:DoAction(act)
    end
end

function PlayerController:OnRemoteRightClick(actioncode, position, target, rotation, isreleased, controlmodscode, noforce, mod_name)
    if self.ismastersim and self:IsEnabled() and self.handler == nil then
        self.remote_controls[CONTROL_SECONDARY] = 0
        self:DecodeControlMods(controlmodscode)
        SetClientRequestedAction(actioncode, mod_name)
        local lmb, rmb = self.inst.components.playeractionpicker:DoGetMouseActions(position, target)
        ClearClientRequestedAction()
        if isreleased then
            self.remote_controls[CONTROL_SECONDARY] = nil
        end
        self:ClearControlMods()

        if rmb ~= nil and rmb.action.code == actioncode and rmb.action.mod_name == mod_name then
            if rmb.action.canforce and not noforce then
                rmb:SetActionPoint(self:GetRemotePredictPosition() or self.inst:GetPosition())
                rmb.forced = true
            end
            rmb.rotation = rotation or rmb.rotation
            self:DoAction(rmb)
        --elseif mod_name ~= nil then
            --print("Remote right click action failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
        --else
            --print("Remote right click action failed: "..tostring(ACTION_IDS[actioncode]))
        end
    end
end

function PlayerController:GetLeftMouseAction()
    return self.LMBaction
end

function PlayerController:GetRightMouseAction()
    return self.RMBaction
end

function PlayerController:GetItemSelfAction(item)
    if item == nil or (self.handler ~= nil and self.deploy_mode) then
        return
    end
    local act =
        --[[rmb]] self.inst.components.playeractionpicker:GetInventoryActions(item, true)[1] or
        --[[lmb]] self.inst.components.playeractionpicker:GetInventoryActions(item, false)[1]
    return act ~= nil and act.action ~= ACTIONS.LOOKAT and act or nil
end

function PlayerController:GetSceneItemControllerAction(item)
    if item == nil or self:IsAOETargeting() then
        return
    end
    local itempos = item:GetPosition()
    local lmb = self.inst.components.playeractionpicker:GetLeftClickActions(itempos, item)[1]
    local rmb = self.inst.components.playeractionpicker:GetRightClickActions(itempos, item)[1]
    if lmb ~= nil
        and (lmb.action == ACTIONS.LOOKAT or
            (lmb.action == ACTIONS.ATTACK and item.replica.combat ~= nil) or
            lmb.action == ACTIONS.WALKTO) then
        lmb = nil
    end
    if rmb ~= nil
        and (rmb.action == ACTIONS.LOOKAT or
            (rmb.action == ACTIONS.ATTACK and item.replica.combat ~= nil) or
            rmb.action == ACTIONS.WALKTO) then
        rmb = nil
    end
    return lmb, rmb ~= nil and (lmb == nil or lmb.action ~= rmb.action) and rmb or nil
end

function PlayerController:GetGroundUseAction(position)
    if self.inst.components.playeractionpicker:HasContainerWidgetAction() then
        return
    end

    local islocal = position == nil
    position = position or
        (self.reticule ~= nil and self.reticule.inst ~= self.inst and self.reticule.targetpos) or
        (self.terraformer ~= nil and self.terraformer:GetPosition()) or
        (self.placer ~= nil and self.placer:GetPosition()) or
        (self.deployplacer ~= nil and self.deployplacer:GetPosition()) or
        self.inst:GetPosition()

    if CanEntitySeePoint(self.inst, position:Get()) then
        --Check validitiy because FE controls may call this in WallUpdate
        local equipitem = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equipitem ~= nil and equipitem:IsValid() and
            (   equipitem:HasTag("allow_action_on_impassable") or
                self.map:IsPassableAtPoint(position:Get()) or
                (   equipitem.components.aoetargeting ~= nil and
                    equipitem.components.aoetargeting.alwaysvalid and
                    equipitem.components.aoetargeting:IsEnabled()
                )
            ) then
            local isaoetargeting = islocal and self:IsAOETargeting()
            local lmb = not isaoetargeting and self.inst.components.playeractionpicker:GetPointActions(position, equipitem, false)[1] or nil
            local rmb = (not islocal or isaoetargeting or equipitem.components.aoetargeting == nil or not equipitem.components.aoetargeting:IsEnabled()) and self.inst.components.playeractionpicker:GetPointActions(position, equipitem, true)[1] or nil
            if lmb ~= nil then
                if lmb.action == ACTIONS.DROP then
                    lmb = nil
                elseif lmb.action == ACTIONS.TERRAFORM then
                    lmb.distance = 2
                end
            end
            if rmb ~= nil and rmb.action == ACTIONS.TERRAFORM then
                rmb.distance = 2
            end
            return lmb, rmb ~= nil and (lmb == nil or lmb.action ~= rmb.action) and rmb or nil
        end
    end
end

function PlayerController:GetGroundUseSpecialAction(position, right)
    --local islocal = position == nil
    position = position or
        (self.reticule ~= nil and self.reticule.targetpos) or
        (self.terraformer ~= nil and self.terraformer:GetPosition()) or
        (self.placer ~= nil and self.placer:GetPosition()) or
        (self.deployplacer ~= nil and self.deployplacer:GetPosition()) or
        self.inst:GetPosition()

    return CanEntitySeePoint(self.inst, position:Get())
        and self.map:IsPassableAtPoint(position:Get())
        and self.inst.components.playeractionpicker:GetPointSpecialActions(position, nil, right)[1]
        or nil
end

function PlayerController:HasGroundUseSpecialAction(right)
    return #self.inst.components.playeractionpicker:GetPointSpecialActions(self.inst:GetPosition(), nil, right) > 0
end

local function ValidateItemUseAction(self, act, active_item, target)
    return act ~= nil and
        (active_item.replica.equippable == nil or not active_item:HasTag(act.action.id.."_tool")) and
        ((act.action ~= ACTIONS.STORE and act.action ~= ACTIONS.BUNDLESTORE) or target.replica.inventoryitem == nil or not target.replica.inventoryitem:IsGrandOwner(self.inst)) and
        act.action ~= ACTIONS.COMBINESTACK and
        act.action ~= ACTIONS.ATTACK and
        act or nil
end

function PlayerController:GetItemUseAction(active_item, target)
    if active_item == nil then
        return
    end
    target = target or self:GetControllerTarget()
    local act = target ~= nil and (
        ValidateItemUseAction(--[[rmb]] self, self.inst.components.playeractionpicker:GetUseItemActions(target, active_item, true)[1], active_item, target) or
        ValidateItemUseAction(--[[lmb]] self, self.inst.components.playeractionpicker:GetUseItemActions(target, active_item, false)[1], active_item, target)
    ) or nil

    --V2C: Use self actions blocked by controller R.Dpad "TOGGLE_DEPLOY_MODE"
    --     e.g. Murder/Plant, Eat/Plant
    if act ~= nil or not (active_item.replica.inventoryitem:IsDeployable(self.inst) and active_item.replica.inventoryitem:IsGrandOwner(self.inst)) then
        return act
    end
    act = --[[rmb]] self.inst.components.playeractionpicker:GetInventoryActions(active_item, true)
    act = act[1] ~= nil and act[1].action ~= ACTIONS.TOGGLE_DEPLOY_MODE and act[1] or act[2]
    if act == nil then
        act = --[[lmb]] self.inst.components.playeractionpicker:GetInventoryActions(active_item, false)
        act = act[1] ~= nil and act[1].action ~= ACTIONS.TOGGLE_DEPLOY_MODE and act[1] or act[2]
    end
    return act ~= nil and act.action ~= ACTIONS.LOOKAT and act or nil
end

function PlayerController:RemoteUseItemFromInvTile(buffaction, item)
    if not self.ismastersim then
        local controlmods = self:EncodeControlMods()
        if self.locomotor == nil then
            SendRPCToServer(RPC.UseItemFromInvTile, buffaction.action.code, item, controlmods, buffaction.action.mod_name)
        elseif buffaction.action ~= ACTIONS.WALKTO
            and self:CanLocomote()
            and not self:IsBusy() then
            buffaction.preview_cb = function()
                SendRPCToServer(RPC.UseItemFromInvTile, buffaction.action.code, item, controlmods, buffaction.action.mod_name)
            end
            self.locomotor:PreviewAction(buffaction, true)
        end
    end
end

function PlayerController:RemoteControllerUseItemOnItemFromInvTile(buffaction, item, active_item)
    if not self.ismastersim then
        if self.locomotor == nil then
            SendRPCToServer(RPC.ControllerUseItemOnItemFromInvTile, buffaction.action.code, item, active_item, buffaction.action.mod_name)
        elseif buffaction.action ~= ACTIONS.WALKTO
            and self:CanLocomote()
            and not self:IsBusy() then
            buffaction.preview_cb = function()
                SendRPCToServer(RPC.ControllerUseItemOnItemFromInvTile, buffaction.action.code, item, active_item, buffaction.action.mod_name)
            end
            self.locomotor:PreviewAction(buffaction, true)
        end
    end
end

function PlayerController:RemoteControllerUseItemOnSelfFromInvTile(buffaction, item)
    if not self.ismastersim then
        if self.locomotor == nil then
            SendRPCToServer(RPC.ControllerUseItemOnSelfFromInvTile, buffaction.action.code, item, buffaction.action.mod_name)
        elseif buffaction.action ~= ACTIONS.WALKTO
            and self:CanLocomote()
            and not self:IsBusy() then
            buffaction.preview_cb = function()
                SendRPCToServer(RPC.ControllerUseItemOnSelfFromInvTile, buffaction.action.code, item, buffaction.action.mod_name)
            end
            self.locomotor:PreviewAction(buffaction, true)
        end
    end
end

function PlayerController:RemoteControllerUseItemOnSceneFromInvTile(buffaction, item)
    if not self.ismastersim then
        if self.locomotor == nil then
            SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, buffaction.action.code, item, buffaction.target, buffaction.action.mod_name)
        elseif buffaction.action ~= ACTIONS.WALKTO
            and self:CanLocomote()
            and not self:IsBusy() then
            buffaction.preview_cb = function()
                SendRPCToServer(RPC.ControllerUseItemOnSceneFromInvTile, buffaction.action.code, item, buffaction.target, buffaction.action.mod_name)
            end
            self.locomotor:PreviewAction(buffaction, true)
        end
    end
end

function PlayerController:RemoteInspectItemFromInvTile(item)
    if not self.ismastersim then
        if self.locomotor == nil then
            SendRPCToServer(RPC.InspectItemFromInvTile, item)
        elseif self:CanLocomote() then
            local buffaction = BufferedAction(self.inst, nil, ACTIONS.LOOKAT, item)
            buffaction.preview_cb = function()
                SendRPCToServer(RPC.InspectItemFromInvTile, item)
            end
            self.locomotor:PreviewAction(buffaction, true)
        end
    end
end

function PlayerController:RemoteDropItemFromInvTile(item, single)
    if not self.ismastersim then
        if self.locomotor == nil then
            SendRPCToServer(RPC.DropItemFromInvTile, item, single or nil)
        elseif self:CanLocomote() then
            local buffaction = BufferedAction(self.inst, nil, ACTIONS.DROP, item, self.inst:GetPosition())
            buffaction.preview_cb = function()
                SendRPCToServer(RPC.DropItemFromInvTile, item, single or nil)
            end
            self.locomotor:PreviewAction(buffaction, true)
        end
    end
end

function PlayerController:RemoteMakeRecipeFromMenu(recipe, skin)
    if not self.ismastersim then
        local skin_index = skin ~= nil and PREFAB_SKINS_IDS[recipe.product][skin] or nil
        if self.locomotor == nil then
            SendRPCToServer(RPC.MakeRecipeFromMenu, recipe.rpc_id, skin_index)
        elseif self:CanLocomote() then
            self.locomotor:Stop()
            local buffaction = BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, nil, recipe.name, 1)
            buffaction.preview_cb = function()
                SendRPCToServer(RPC.MakeRecipeFromMenu, recipe.rpc_id, skin_index)
            end
            self.locomotor:PreviewAction(buffaction, true)
        end
    end
end

function PlayerController:RemoteMakeRecipeAtPoint(recipe, pt, rot, skin)
    if not self.ismastersim then
        local skin_index = skin ~= nil and PREFAB_SKINS_IDS[recipe.name][skin] or nil
        if self.locomotor == nil then
	        local platform, pos_x, pos_z = self:GetPlatformRelativePosition(pt.x, pt.z)
            SendRPCToServer(RPC.MakeRecipeAtPoint, recipe.rpc_id, pos_x, pos_z, rot, skin_index, platform, platform ~= nil)
        elseif self:CanLocomote() then
            self.locomotor:Stop()
            local act = BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, pt, recipe.name, 1, nil, rot)
            act.preview_cb = function()
                SendRPCToServer(RPC.MakeRecipeAtPoint, recipe.rpc_id, act.pos.local_pt.x, act.pos.local_pt.z, rot, skin_index, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
            end
            self.locomotor:PreviewAction(act, true)
        end
    end
end

local function DoRemoteBufferedAction(inst, self, buffaction)
    if self.classified ~= nil and self.classified.iscontrollerenabled:value() then
        buffaction.preview_cb()
    end
end

function PlayerController:RemoteBufferedAction(buffaction)
    if not self.ismastersim and buffaction.preview_cb ~= nil then
        --Delay one frame if we just sent movement prediction so that
        --this RPC arrives a frame after the movement prediction RPC
        if self.predictionsent then
            self.inst:DoTaskInTime(0, DoRemoteBufferedAction, self, buffaction)
        else
            DoRemoteBufferedAction(self.inst, self, buffaction)
        end
    end
end

function PlayerController:OnRemoteBufferedAction()
    if self.ismastersim then
        --If we're starting a remote buffered action, prevent the last
        --movement prediction vector from cancelling us out right away
        if self.remote_vector.y >= 3 then
            self.remote_vector.y = 5
        elseif self.remote_vector.y == 0 then
            self.directwalking = false
            self.dragwalking = false
            self.predictwalking = false
        end
    end
end

return PlayerController
