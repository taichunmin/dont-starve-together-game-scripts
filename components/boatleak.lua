local BoatLeak = Class(function(self, inst)
    self.inst = inst    

    self.has_leaks = false
	self.leak_build = "boat_leak_build"
end)

function BoatLeak:Repair(doer, patch_item)
    if not self.inst:HasTag("boat_leak") then return false end

    if patch_item.components.stackable ~= nil then
        patch_item.components.stackable:Get():Remove()
    else
        patch_item:Remove()
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

function BoatLeak:ChangeToRepaired(repair_build_name)
    self.inst:RemoveTag("boat_leak")

    local anim_state = self.inst.AnimState
    anim_state:SetBuild(repair_build_name)
    anim_state:SetBankAndPlayAnimation("boat_repair", "pre_idle")
    anim_state:SetSortOrder(3)
    anim_state:SetOrientation(ANIM_ORIENTATION.OnGround)
    anim_state:SetLayer(LAYER_BACKGROUND)

    self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/repair")
    self.inst.SoundEmitter:KillSound("small_leak")
    self.inst.SoundEmitter:KillSound("med_leak")

    self.has_leaks = false

    if self.onrepairedleak ~= nil then
        self.onrepairedleak(self.inst)
    end
end

function BoatLeak:SetState(state)
	if state == self.current_state then return end

    local anim_state = self.inst.AnimState

	if state == "small_leak" then
	    self.inst:AddTag("boat_leak")

        anim_state:SetBuild(self.leak_build)
		anim_state:SetBankAndPlayAnimation("boat_leak", "leak_small_pre")
    	anim_state:PushAnimation("leak_small_loop", true)  
        anim_state:SetSortOrder(0)
        anim_state:SetOrientation(ANIM_ORIENTATION.BillBoard) 
        anim_state:SetLayer(LAYER_WORLD)           

        self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/fountain_small_LP", "small_leak")                  

        self.has_leaks = true

		if self.onsprungleak ~= nil then
			self.onsprungleak(self.inst, state)
		end
	elseif state == "med_leak" then
	    self.inst:AddTag("boat_leak")

        anim_state:SetBuild(self.leak_build)
		anim_state:SetBankAndPlayAnimation("boat_leak", "leak_med_pre")
    	anim_state:PushAnimation("leak_med_loop", true)  
        anim_state:SetSortOrder(0)
        anim_state:SetOrientation(ANIM_ORIENTATION.BillBoard) 
        anim_state:SetLayer(LAYER_WORLD)                   

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
    end

	self.current_state = state
end

function BoatLeak:SetBoat(boat)
    self.boat = boat

end

return BoatLeak