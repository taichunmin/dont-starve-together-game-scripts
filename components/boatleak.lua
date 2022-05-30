local BoatLeak = Class(function(self, inst)
    self.inst = inst

    self.has_leaks = false
	self.leak_build = "boat_leak_build"

	self.isdynamic = false
end)

function BoatLeak:Repair(doer, patch_item)
    if not self.inst:HasTag("boat_leak") then return false end

    if patch_item.components.repairer and self.inst:GetCurrentPlatform() and self.inst:GetCurrentPlatform().components.repairable then
        self.inst:GetCurrentPlatform().components.repairable:Repair(doer, patch_item)
        -- consumed in the repair
    else
        if patch_item.components.stackable ~= nil then
            patch_item.components.stackable:Get():Remove()
        else
            patch_item:Remove()
        end
    end

    local repair_state = "repaired"
    local patch_type = (patch_item.components.boatpatch ~= nil and patch_item.components.boatpatch:GetPatchType()) or nil
    if patch_type ~= nil then
        repair_state = repair_state.."_"..patch_type
    end

    self.inst.AnimState:PlayAnimation("leak_small_pst")
    self.inst:DoTaskInTime(0.4, function(inst)
        self:SetState(repair_state)
    end)

	return true
end

function BoatLeak:ChangeToRepaired(repair_build_name, sndoverride)
    self.inst:RemoveTag("boat_leak")
    self.inst:AddTag("boat_repaired_patch")

    local anim_state = self.inst.AnimState
    anim_state:SetBuild(repair_build_name)
    anim_state:SetBankAndPlayAnimation("boat_repair", "pre_idle")
    anim_state:SetSortOrder(3)
    anim_state:SetOrientation(ANIM_ORIENTATION.OnGround)
    anim_state:SetLayer(LAYER_BACKGROUND)

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

function BoatLeak:SetState(state, skip_open)
	if state == self.current_state then return end

    local anim_state = self.inst.AnimState

	if state == "small_leak" then
        self.inst:RemoveTag("boat_repaired_patch")
	    self.inst:AddTag("boat_leak")

        anim_state:SetBuild(self.leak_build)
		anim_state:SetBankAndPlayAnimation("boat_leak", "leak_small_pre")
    	anim_state:PushAnimation("leak_small_loop", true)
        anim_state:SetSortOrder(0)
        anim_state:SetOrientation(ANIM_ORIENTATION.BillBoard)
        anim_state:SetLayer(LAYER_WORLD)
        if skip_open then
            anim_state:SetTime(11 * FRAMES)
        end

        self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_small_LP", "small_leak")

        self.has_leaks = true

		if self.onsprungleak ~= nil then
			self.onsprungleak(self.inst, state)
		end
	elseif state == "med_leak" then
        self.inst:RemoveTag("boat_repaired_patch")
	    self.inst:AddTag("boat_leak")

        anim_state:SetBuild(self.leak_build)
		anim_state:SetBankAndPlayAnimation("boat_leak", "leak_med_pre")
    	anim_state:PushAnimation("leak_med_loop", true)
        anim_state:SetSortOrder(0)
        anim_state:SetOrientation(ANIM_ORIENTATION.BillBoard)
        anim_state:SetLayer(LAYER_WORLD)
        if skip_open then
            anim_state:SetTime(11 * FRAMES)
        end

        self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_medium_LP", "med_leak")

        if not self.has_leaks then
            self.has_leaks = true

			if self.onsprungleak ~= nil then
				self.onsprungleak(self.inst, state)
			end
        end
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
    end

	self.current_state = state
end

function BoatLeak:SetBoat(boat)
    self.boat = boat

end

-- Note: Currently save and load is only used for dynamic leaks (e.g. caused by cookie cutter). Saving/loading
-- for leaks caused by collision is handled from HullHealth.
function BoatLeak:OnSave(data)
	return (self.current_state ~= nil and self.isdynamic) and { leak_state = self.current_state } or nil
end

function BoatLeak:OnLoad(data)
	if data ~= nil and data.leak_state ~= nil then
		self.isdynamic = true

		self.inst:DoTaskInTime(0, function()
			local boat = self.inst:GetCurrentPlatform()

			if boat ~= nil then
				self:SetBoat(boat)
				self:SetState(data.leak_state)
				table.insert(boat.components.hullhealth.leak_indicators_dynamic, self.inst)
			else
				self.inst:Remove()
			end
		end)
    end
end

return BoatLeak