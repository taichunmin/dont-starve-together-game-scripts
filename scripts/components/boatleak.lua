local PLUG_STATES_LOOKUP =
{
    small_leak = "small_leak_plugged",
    med_leak   = "med_leak_plugged",
}

local UNPLUG_STATES_LOOKUP = table.invert(PLUG_STATES_LOOKUP)

local function onisdynamic(self, isdynamic)
    self.inst.persists = isdynamic
end

local BoatLeak = Class(function(self, inst)
    self.inst = inst

    self.has_leaks = false
	self.leak_build = "boat_leak_build"
    --self.leak_build_override = nil

	self.isdynamic = false
end,
nil,
{
    isdynamic = onisdynamic,
})

local function set_repair_state(inst, repair_state)
    if inst.components.boatleak then
        inst.components.boatleak:SetState(repair_state)
    end
end

local function set_repair_timeout_state(inst, current_state, repair_state)
    if inst.components.boatleak == nil then
        return
    end

    local fx = SpawnPrefab(current_state.."_timeout_fx")

    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end

    inst.components.boatleak.current_state = current_state
    inst.components.boatleak:SetState(repair_state)
end

local function start_repair_timeout(inst)
    if inst.components.boatleak == nil then
        return
    end

    inst.components.boatleak._repaired_timeout_task = nil

    inst.AnimState:PlayAnimation("pre_timeout")

    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, set_repair_timeout_state, inst.components.boatleak.current_state, "med_leak")

    inst.components.boatleak.current_state = "med_leak" -- For save/load.
end

function BoatLeak:Repair(doer, patch_item)
    if not self.inst:HasTag("boat_leak") then
        return false
    end

    local consumed = false

    if patch_item.components.repairer ~= nil then
        local current_platform = self.inst:GetCurrentPlatform()

        local repairable = current_platform ~= nil and current_platform.components.repairable or nil

        if repairable ~= nil and repairable:Repair(doer, patch_item) then
            consumed = true -- Consumed in the repair.
        end
    end

    if not consumed then
        if patch_item.components.stackable ~= nil then
            patch_item.components.stackable:Get():Remove()
        else
            patch_item:Remove()
        end
    end

    local patch_type = patch_item.components.boatpatch ~= nil and patch_item.components.boatpatch:GetPatchType() or nil
    local repair_state = patch_type ~= nil and "repaired_"..patch_type or "repaired"

    self.inst.AnimState:PlayAnimation("leak_small_pst")
    self.inst:DoTaskInTime(0.4, set_repair_state, repair_state)

	return true
end

function BoatLeak:ChangeToRepaired(repair_build_name, sndoverride)
    self.inst:RemoveTag("boat_leak")
    self.inst:AddTag("boat_repaired_patch")

    local AnimState = self.inst.AnimState
    AnimState:SetBuild(repair_build_name)
    AnimState:SetBankAndPlayAnimation("boat_repair", "pre_idle")
    AnimState:SetSortOrder(3)
    AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    AnimState:SetLayer(LAYER_BACKGROUND)

    if not sndoverride then
        self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/repair")
    else
        self.inst.SoundEmitter:PlaySound(sndoverride)
    end

    self.inst.SoundEmitter:KillSound("small_leak")
    self.inst.SoundEmitter:KillSound("med_leak")

    self.has_leaks = false

    if self.onrepairedleak ~= nil then
        self.onrepairedleak(self.inst)
    end
end

function BoatLeak:SetRepairedTime(time)
    if self._repaired_timeout_task ~= nil then
        self._repaired_timeout_task:Cancel()
    end

    self._repaired_timeout_task = self.inst:DoTaskInTime(time, start_repair_timeout)
end

function BoatLeak:GetRemainingRepairedTime()
    return self._repaired_timeout_task ~= nil and GetTaskRemaining(self._repaired_timeout_task) or nil
end

function BoatLeak:SetPlugged(setting)
    local lookup = setting ~= false and PLUG_STATES_LOOKUP or UNPLUG_STATES_LOOKUP
    local new_state = lookup[self.current_state]

    if new_state ~= nil then
        self:SetState(new_state)
    end
end

function BoatLeak:SetState(state, skip_open)
	if state == self.current_state then return end

    if self._repaired_timeout_task ~= nil then
        self._repaired_timeout_task:Cancel()
        self._repaired_timeout_task = nil
    end

    local AnimState = self.inst.AnimState

	if state == "small_leak" then
        self.inst:RemoveTag("boat_repaired_patch")
	    self.inst:AddTag("boat_leak")

        AnimState:SetBuild(self.leak_build)
		AnimState:SetBankAndPlayAnimation("boat_leak", "leak_small_pre")
        AnimState:PushAnimation("leak_small_loop", true)
        AnimState:SetSortOrder(0)
        AnimState:SetOrientation(ANIM_ORIENTATION.BillBoard)
        AnimState:SetLayer(LAYER_WORLD)
        if skip_open then
            AnimState:SetTime(11 * FRAMES)
        end

        if self.leak_build_override ~= nil then
            AnimState:AddOverrideBuild(self.leak_build_override)
        end

        self.inst.SoundEmitter:KillSound("small_leak")
        self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_small_LP", "small_leak")

        self.has_leaks = true

		if self.onsprungleak ~= nil then
			self.onsprungleak(self.inst, state)
		end

    elseif state == "small_leak_plugged" then
        local x,y,z = self.inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("splash")
        fx.Transform:SetPosition(x,y,z)

        self.inst.SoundEmitter:PlaySound("meta4/boat_patch/plugged_thunk")

        self.inst.SoundEmitter:KillSound("small_leak")
        self.inst.SoundEmitter:PlaySound("meta4/boat_patch/plugged_spray", "small_leak")

        AnimState:PushAnimation("leak_small_plugged", true)

	elseif state == "med_leak" then
        self.inst:RemoveTag("boat_repaired_patch")
	    self.inst:AddTag("boat_leak")

        AnimState:SetBuild(self.leak_build)
		AnimState:SetBankAndPlayAnimation("boat_leak", "leak_med_pre")
        AnimState:PushAnimation("leak_med_loop", true)
        AnimState:SetSortOrder(0)
        AnimState:SetOrientation(ANIM_ORIENTATION.BillBoard)
        AnimState:SetLayer(LAYER_WORLD)
        if skip_open then
            AnimState:SetTime(11 * FRAMES)
        end

        if self.leak_build_override ~= nil then
            AnimState:AddOverrideBuild(self.leak_build_override)
        end

        self.inst.SoundEmitter:KillSound("med_leak")
        self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_medium_LP", "med_leak")

        if not self.has_leaks then
            self.has_leaks = true

			if self.onsprungleak ~= nil then
				self.onsprungleak(self.inst, state)
			end
        end

    elseif state == "med_leak_plugged" then
        local x,y,z = self.inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("splash")
        fx.Transform:SetPosition(x,y,z)

        self.inst.SoundEmitter:PlaySound("meta4/boat_patch/plugged_thunk")

        self.inst.SoundEmitter:KillSound("med_leak")
        self.inst.SoundEmitter:PlaySound("meta4/boat_patch/plugged_spray", "med_leak")

        AnimState:PushAnimation("leak_med_plugged",true)
     
	elseif state == "repaired" then
        self:ChangeToRepaired("boat_repair_build")

	elseif state == "repaired_tape" then
        self:ChangeToRepaired("boat_repair_tape_build")

    elseif state == "repaired_treegrowth" then
        self:ChangeToRepaired("treegrowthsolution","waterlogged2/common/repairgoop")
        self.inst.AnimState:SetBankAndPlayAnimation("treegrowthsolution", "pre_idle")
        self.inst:ListenForEvent("animover", function()
            if self.inst.AnimState:IsCurrentAnimation("pre_idle") then
                self.inst.AnimState:PlayAnimation("idle")
            elseif self.inst.AnimState:IsCurrentAnimation("idle") then
                self.inst:Remove()
            end
        end)

    elseif state == "repaired_kelp" then
        self:ChangeToRepaired("boat_repair_kelp", "meta4/boat_patch/kelp_place")
        self.inst.AnimState:SetBankAndPlayAnimation("boat_repair_kelp", "pre_idle")
        self:SetRepairedTime(
            self.current_state == "med_leak" and TUNING.BOAT_REPAIR_KELP_REPAIR_TIME_MED_LEAK
            or TUNING.BOAT_REPAIR_KELP_REPAIR_TIME_SMALL_LEAK
        )
    end

	self.current_state = state
end

function BoatLeak:SetBoat(boat)
    self.boat = boat

   if self.boat.leak_build ~= nil then
        self.leak_build = self.boat.leak_build
    end

    if self.boat.leak_build_override ~= nil then
        self.leak_build_override = self.boat.leak_build_override
    end
end

function BoatLeak:IsFinishedSpawning()
    if self.current_state == "small_leak" then
        return self.inst.AnimState:IsCurrentAnimation("leak_small_loop")
    elseif self.current_state == "med_leak" then
        return self.inst.AnimState:IsCurrentAnimation("leak_med_loop")
    else
        return true
    end
end

-- Note: Currently save and load is only used for dynamic leaks (e.g. caused by cookie cutter). Saving/loading
-- for leaks caused by collision is handled from HullHealth. Don't save plugged states.
function BoatLeak:OnSave(data)
    if self.current_state ~= nil and self.isdynamic then
        return {
            leak_state = UNPLUG_STATES_LOOKUP[self.current_state] or self.current_state,
            repaired_timeout = self:GetRemainingRepairedTime(),
        }
    end
end

local function on_load_delayed_callback(inst, leak_state, repaired_timeout)
    local self = inst.components.boatleak
    if not self then return end

    local boat = inst:GetCurrentPlatform()

    if not boat then
        inst:Remove()
    else
        self:SetBoat(boat)
        self:SetState(leak_state)
        table.insert(boat.components.hullhealth.leak_indicators_dynamic, inst)

        if repaired_timeout ~= nil then
            self:SetRepairedTime(repaired_timeout)
        end
    end
end

function BoatLeak:OnLoad(data)
	if data ~= nil and data.leak_state ~= nil then
		self.isdynamic = true

		self.inst:DoTaskInTime(0, on_load_delayed_callback, data.leak_state, data.repaired_timeout)
    end
end

function BoatLeak:LongUpdate(dt)
    if self._repaired_timeout_task == nil then
        return
    end

    local remaining = GetTaskRemaining(self._repaired_timeout_task) - dt

    self._repaired_timeout_task:Cancel()

    if remaining > 0 then
        self:SetRepairedTime(remaining)
    else
        set_repair_timeout_state(self.inst, self.current_state, "med_leak")
    end
end

return BoatLeak