local function on_is_anchor_lowered(self, is_anchor_lowered)
	if is_anchor_lowered then
		self.inst:RemoveTag("anchor_raised")
		self.inst:AddTag("anchor_lowered")
	else
		self.inst:RemoveTag("anchor_lowered")
		self.inst:AddTag("anchor_raised")
	end
end

local function on_is_anchor_transitioning(self, is_anchor_transitioning)
    if not self.is_boat_moving then
        if is_anchor_transitioning then
            self.inst:StartUpdatingComponent(self)
        else
            self.inst:StopUpdatingComponent(self)
        end
    end
end

local function on_is_boat_moving(self, is_boat_moving)
    if not self.is_anchor_transitioning then
        if is_boat_moving then
            self.inst:StartUpdatingComponent(self)
        else
            self.inst:StopUpdatingComponent(self)
        end
    end
end


local function SetBoat(self, boat)
	if self.boat ~= nil then
		self.inst:RemoveEventCallback("onremove", self.OnBoatRemoved, self.boat)
		self.inst:RemoveEventCallback("boat_stop_moving", self.OnBoatStopMoving, self.boat)
		self.inst:RemoveEventCallback("boat_start_moving", self.OnBoatStartMoving, self.boat)
	end
	self.boat = boat
	if self.boat ~= nil then
        self.is_boat_moving = self.boat.components.boatphysics.was_moving
	    self.inst:ListenForEvent("onremove", self.OnBoatRemoved, self.boat)
		self.inst:ListenForEvent("boat_stop_moving", self.OnBoatStopMoving, self.boat)
		self.inst:ListenForEvent("boat_start_moving", self.OnBoatStartMoving, self.boat)
	end
end

local Anchor = Class(function(self, inst)
    self.inst = inst

    self.is_anchor_lowered = false

    self.raisers = {}
    self.numberofraisers = 0
    self.raiseunits = 0
    self.currentraiseunits = 0
    self.autolowerunits = 3

    self.is_boat_moving = false

    self.OnBoatRemoved = function()
        self.boat = nil
        self.is_boat_moving = false
    end
    self.OnBoatStopMoving = function()
        self.is_boat_moving = false
    end
    self.OnBoatStartMoving = function()
        self.is_boat_moving = true
    end

    if not POPULATING then
	    self.inst:DoTaskInTime(0, function() SetBoat(self, inst:GetCurrentPlatform()) end)
	end
end,
nil,
{
    is_anchor_lowered = on_is_anchor_lowered,
    is_anchor_transitioning = on_is_anchor_transitioning,
    is_boat_moving = on_is_boat_moving,
})

function Anchor:SetVelocityMod(set)
    self.max_velocity_mod = set
end

function Anchor:OnSave()
    local data =
    {
        raiseunits = self.raiseunits,
    }

    return data
end

function Anchor:GetCurrentDepth()
    local depth = 0.1
    if self.boat and self.boat:IsValid() then
        local tile = TheWorld.Map:GetTileAtPoint(self.inst.Transform:GetWorldPosition())
        if tile then
			local tile_info = GetTileInfo(tile)
			if tile_info ~= nil and tile_info.ocean_depth ~= nil then
				depth = TUNING.ANCHOR_DEPTH_TIMES[tile_info.ocean_depth]
			end
        end
    end
    return depth
end

function Anchor:OnLoad(data)
    if data ~= nil then
        if data.raiseunits then
            self.raiseunits = data.raiseunits
        end
    end
end

function Anchor:LoadPostPass()--newents, data)
    if not self.inst:HasTag("burnt") then
        SetBoat(self, self.inst:GetCurrentPlatform())

        if self.raiseunits <= 0 then
            self.inst.sg:GoToState("raised")
        else
            local depth = self:GetCurrentDepth()

            if self.raiseunits >= depth then
                if not self.boat then
                    self.inst.sg:GoToState("lowered_land")
                else
                    self.inst.sg:GoToState("lowered")
                end
            else
                self.is_anchor_transitioning = true
                self.inst.sg:GoToState("lowering")
            end
        end
    end
end


function Anchor:GetBoat()
	return self.boat
end

function Anchor:SetIsAnchorLowered(is_lowered)
	if is_lowered ~= self.is_anchor_lowered then
		self.is_anchor_lowered = is_lowered
		local boat = self.boat
		if boat ~= nil then
			if is_lowered then
				boat.components.boatphysics:AddBoatDrag(self.inst)
			else
				boat.components.boatphysics:RemoveBoatDrag(self.inst)
			end
		end
	end
end

function Anchor:StartRaisingAnchor()
    if self.inst:HasTag("burnt") or self.inst:HasTag("anchor_raised") then
        return false
    else
	    self.inst:PushEvent("raising_anchor")
        return true
    end
end

function Anchor:StartLoweringAnchor()
    if self.inst:HasTag("burnt") or self.inst:HasTag("anchor_lowered") then
        return false
    else
        if not self.is_anchor_transitioning then
            self.is_anchor_transitioning = true
            self.inst:AddTag("anchor_transitioning")
	        self.inst:PushEvent("lowering_anchor")
            return true
        end
    end
end

function Anchor:AddAnchorRaiser(doer)
    if self.inst:HasTag("burnt") then
        return false
    end

    if not self.is_anchor_transitioning then
        self.inst:AddTag("anchor_transitioning")
        self.is_anchor_transitioning = true
    end
    self.inst:PushEvent("raising_anchor")
    self.rasing = true
    if not self.raisers[doer] then
        self.numberofraisers = self.numberofraisers +1
    end

    self.raisers[doer] = doer.components.expertsailor ~= nil and doer.components.expertsailor:GetAnchorRaisingSpeed() or 1	-- raise units/second

    self.currentraiseunits = self.currentraiseunits + self.raisers[doer]
    return true
end

function Anchor:RemoveAnchorRaiser(doer)
    if self.raisers[doer] then
        self.currentraiseunits = self.currentraiseunits - self.raisers[doer]
        self.numberofraisers = self.numberofraisers -1
        self.raisers[doer] = nil
        doer:PushEvent("stopraisinganchor")
    end
    if not next(self.raisers) then
        if self.is_anchor_transitioning then
            self.inst:PushEvent("lowering_anchor")
        end
        self.rasing = nil
    end
end

function Anchor:AnchorRaised()
    self.is_anchor_transitioning = nil
    self.inst.AnimState:SetDeltaTimeMultiplier(1)
    self.inst:RemoveTag("anchor_transitioning")
    for raiser,data in pairs(self.raisers)do
        self:RemoveAnchorRaiser(raiser)
    end
    self.inst:PushEvent("anchor_raised")
end

function Anchor:AnchorLowered()
    self.is_anchor_transitioning = nil
    self.inst.AnimState:SetDeltaTimeMultiplier(1)
    self.inst:RemoveTag("anchor_transitioning")
    self.inst:PushEvent("anchor_lowered")
end

function Anchor:OnUpdate(dt)

    local depth = self:GetCurrentDepth()
    --print("RAISE UNITS",self.raiseunits, "BOTTOM",self:GetCurrentDepth(),self.is_anchor_transitioning)
    if self.is_anchor_transitioning then
        if next(self.raisers) then
            self.raiseunits =  math.max(0,self.raiseunits - (dt*self.currentraiseunits))
        else
            self.raiseunits = math.min(depth ,self.raiseunits + (dt*self.autolowerunits))
        end
        --print("self.raiseunits",self.raiseunits)

        if self.numberofraisers > 0 then
            local speed = 0.2 + (self.numberofraisers * 0.3)
            self.inst.AnimState:SetDeltaTimeMultiplier(speed)
        else
            -- drop fast
            self.inst.AnimState:SetDeltaTimeMultiplier(1)
        end

        if self.raiseunits <= 0 then
            self:AnchorRaised()
        end
        if self.raiseunits >= depth and self.numberofraisers <= 0 then
            self:AnchorLowered()
        end
    else
        if self.raiseunits > 0 and self.raiseunits < depth then
            self.inst:RemoveTag("anchor_lowered")
            self:StartLoweringAnchor()
        end
    end
end

function Anchor:GetDebugString()
	local s = "Boat: " .. tostring(self.boat)

    local depth = self:GetCurrentDepth()
    s = s.." numberofraisers: "..self.numberofraisers.." raiseunits: "..self.raiseunits.." currentraiseunits: "..self.currentraiseunits.." depth: "..depth

    return s
end

return Anchor
