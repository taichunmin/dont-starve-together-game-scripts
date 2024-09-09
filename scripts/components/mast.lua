local function on_is_sail_raised(self)
	if self.is_sail_raised then
		self.inst:RemoveTag("saillowered")
		self.inst:AddTag("sailraised")
	else
		self.inst:RemoveTag("sailraised")
		self.inst:AddTag("saillowered")
	end
end

local function on_is_sail_transitioning(self, is_sail_transitioning)
    if is_sail_transitioning then
        self.inst:StartUpdatingComponent(self)
    else
        self.inst:StopUpdatingComponent(self)
    end
end

local Mast = Class(function(self, inst)
    self.inst = inst
    self.is_sail_raised = false
	self.inverted = false
    self.sail_force = TUNING.BOAT.MAST.BASIC.SAIL_FORCE
    self.has_speed = false
    self.boat = nil
    self.rudder = nil
    --self.max_velocity_mod = TUNING.BOAT.MAST.BASIC.MAX_VELOCITY_MOD
    self.max_velocity = TUNING.BOAT.MAST.BASIC.MAX_VELOCITY
    self.rudder_turn_drag = TUNING.BOAT.MAST.BASIC.RUDDER_TURN_DRAG

    self.furlunits_max = 4.5 -- takes 1 person 5 seconds
    self.furlunits = self.furlunits_max
    self.autounfurlunits = 8
    self.furlers = {}

    self.OnBoatRemoved = function() self.boat = nil end
    self.OnBoatDeath = function() self:OnDeath() end

    self:SetRudder(SpawnPrefab("rudder"))

    self._setup_boat_task = self.inst:DoTaskInTime(0, function()
        self:SetBoat(self.inst:GetCurrentPlatform())
		self._setup_boat_task = nil
    end)
end,
nil,
{
    is_sail_raised = on_is_sail_raised,
    is_sail_transitioning = on_is_sail_transitioning,
})

function Mast:OnRemoveFromEntity()
	if self._setup_boat_task ~= nil then
		self._setup_boat_task:Cancel()
        self._setup_boat_task = nil
	end
end

function Mast:OnRemoveEntity()
	local mast_sinking

	if self.sink_fx ~= nil and (self.boat_death or self.boat ~= nil) then
		mast_sinking = SpawnPrefab(self.sink_fx)
    else
        mast_sinking = SpawnPrefab("collapse_small")
	end

	if mast_sinking ~= nil then
		local x_pos, y_pos, z_pos = self.inst.Transform:GetWorldPosition()
		mast_sinking.Transform:SetPosition(x_pos, y_pos, z_pos)
	end

	self:SetBoat(nil)
end

function Mast:SetReveseDeploy(set)
	self.furlunits = set and 0 or self.furlunits
	self.is_sail_raised = set
    self.inverted = set
end

function Mast:SetSailForce(set)
    self.sail_force = set
end

function Mast:CalcSailForce()
	if self.inverted and (not self.is_sail_raised or self.is_sail_transitioning) then
		return self.sail_force * (self.furlunits / self.furlunits_max)
	elseif not self.inverted and self.is_sail_raised then
		return self.sail_force * (1 - (self.furlunits / self.furlunits_max))
	end
	return 0
end

function Mast:CalcMaxVelocity()
	if self.inverted and (not self.is_sail_raised or self.is_sail_transitioning) then
		return self.max_velocity * (self.furlunits / self.furlunits_max)
	elseif not self.inverted and self.is_sail_raised then
		return self.max_velocity * (1 - (self.furlunits / self.furlunits_max))
	end
	return 0
end

function Mast:SetVelocityMod(set)
    self.max_velocity_mod = set
end

function Mast:SetBoat(boat)
    if boat == self.boat then return end

    if self.boat ~= nil then
        self.boat.components.boatphysics:RemoveMast(self)
        self.inst:RemoveEventCallback("onremove", self.OnBoatRemoved, boat)
        self.inst:RemoveEventCallback("death", self.OnBoatDeath, boat)
    end

    self.boat = boat

    if boat ~= nil then
        self.inst.Transform:SetRotation(self.boat.Transform:GetRotation())
        boat.components.boatphysics:AddMast(self)
        self.inst:ListenForEvent("onremove", self.OnBoatRemoved, boat)
        self.inst:ListenForEvent("death", self.OnBoatDeath, boat)
		self.inst:RemoveTag("rotatableobject")
	else
		self.inst:AddTag("rotatableobject")
    end
end

function Mast:SetRudder(obj)
    self.rudder = obj
    obj.entity:SetParent(self.inst.entity)

    if self.inst.highlightchildren ~= nil then
        table.insert(self.inst.highlightchildren, obj)
    else
        self.inst.highlightchildren = { obj }
    end
end

function Mast:OnDeath()
	if self.inst:IsValid() then
		self.boat_death = true
	    self.inst.SoundEmitter:KillSound("boat_movement")
        self:SetBoat(nil)
	end
end

function Mast:AddSailFurler(doer, strength)
    self.is_sail_transitioning = true
    self.inst:AddTag("sail_transitioning")
    self.furlers[doer] = strength
    self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_open")
end

function Mast:RemoveSailFurler(doer)
    if self.furlers[doer] then
        self.furlers[doer] = nil
        doer:PushEvent("stopfurling")
    end
end

function Mast:GetCurrentFurlUnits()
    local total_strength = 0
    for furler,strength in pairs(self.furlers) do
		if furler.AnimState:IsCurrentAnimation("pull_small_loop") or (furler.AnimState:IsCurrentAnimation("pull_big_loop") and furler.AnimState:GetCurrentAnimationFrame() < TUNING.BOAT.MAST.HEAVABLE_ACTIVE_FRAME) then
            total_strength = total_strength + strength
        end
    end
    return total_strength
end

function Mast:UnfurlSail() -- lowering sail
    self.is_sail_transitioning = true
    self.inst:AddTag("sail_transitioning")
    self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_open")
    self.inst.AnimState:PlayAnimation("knot_release")
    self.inst.AnimState:PushAnimation("open_pre")
end

function Mast:SailFurled() -- sail is raised
	self.furlunits = self.furlunits_max
    self.is_sail_transitioning = nil
    self.inst:RemoveTag("sail_transitioning")
    if not self.is_sail_raised then
		return
	end

	self.is_sail_raised = false
	if self.inverted then
		self.inst.AnimState:PlayAnimation("knot_tie", false)
		self.inst.AnimState:PushAnimation("open_loop", true)
	else
		self.inst.AnimState:PlayAnimation("knot_tie", false)
		self.inst.AnimState:PushAnimation("closed", false)
	end
	self.inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/top")

    for furler,data in pairs(self.furlers)do
        self:RemoveSailFurler(furler)
    end
end

function Mast:SailUnfurled() -- sail is lowered
	self.furlunits = 0
    self.is_sail_transitioning = nil
    self.inst:RemoveTag("sail_transitioning")
    self.is_sail_raised = true
	if self.inverted then
		self.inst.AnimState:PlayAnimation("closed", false)
	else
	    self.inst.AnimState:PlayAnimation("open_loop", true)
	end
end

--instantly closes the sail to the "inactive state"
function Mast:CloseSail()
    if self.inverted then
        self:SailUnfurled()
    else
        self:SailFurled()
    end
end

function Mast:GetFurled0to1()
    return self.furlunits / self.furlunits_max
end

function Mast:SetRudderDirection(rudder_direction_x, rudder_direction_z)
    local mast_x, mast_y, mast_z = self.inst.Transform:GetWorldPosition()
    self.inst:FacePoint(rudder_direction_x + mast_x, 0, rudder_direction_z + mast_z)
end

function Mast:OnUpdate(dt)
    if self.is_sail_transitioning and not self.inst.AnimState:IsCurrentAnimation("knot_release") then
        if self.is_sail_transitioning then

            if next(self.furlers) then
                self.furlunits = math.min(self.furlunits_max,self.furlunits + (dt*self:GetCurrentFurlUnits()))

                if self.furlunits >= self.furlunits_max * 0.95 then
                    self:SailFurled()
                end
            else
                self.furlunits = math.max(0,self.furlunits - (dt*self.autounfurlunits))

                if self.furlunits <= 0 then
                    self:SailUnfurled()
                end
            end

        end
        -- it still transitioning
        if self.is_sail_transitioning then
            -- update sail art.
            self.inst.AnimState:SetPercent("open_pst",self.furlunits / self.furlunits_max)
        end
    end
end

return Mast
