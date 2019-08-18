local GroundTiles = require("worldtiledefs")

local function on_is_anchor_lowered(self, is_anchor_lowered)
	if is_anchor_lowered then
		self.inst:RemoveTag("anchor_raised")
		self.inst:AddTag("anchor_lowered")
	else
		self.inst:RemoveTag("anchor_lowered")
		self.inst:AddTag("anchor_raised")
	end
end

local function on_remove(inst)
    local anchor = inst.components.anchor
    if anchor ~= nil then
        if anchor.is_anchor_lowered then
            local boat = anchor:GetBoat()
            if boat ~= nil and boat:IsValid() then
                boat.components.boatphysics:RemoveAnchorCmp(anchor)
            end
        end
        anchor.inst:RemoveEventCallback("onremove", on_remove)
    end
end

local Anchor = Class(function(self, inst)
    self.inst = inst
    self.inst:ListenForEvent("onremove", on_remove)

    self.is_anchor_lowered = false
    self.drag = TUNING.BOAT.ANCHOR.BASIC.ANCHOR_DRAG
    self.max_velocity_mod =  TUNING.BOAT.ANCHOR.BASIC.MAX_VELOCITY_MOD

    self.raisers = {}        
    self.numberofraisers = 0
    self.raiseunits = 0
    self.bottomunits = 0.1 -- 4
    self.currentraiseunits = 0
    self.autolowerunits = 3    

    self.inst:StartUpdatingComponent(self)
    self.inst:DoTaskInTime(0,
        function() 
            self.boat = inst:GetCurrentPlatform()
        end)    
end,
nil,
{
    is_anchor_lowered = on_is_anchor_lowered,
})

function Anchor:SetVelocityMod(set)
    self.max_velocity_mod = set
end

function Anchor:GetVelocityMod()
    return (self.inst:HasTag("burnt") and 1) or self.max_velocity_mod 
end

function Anchor:GetDrag()
    return (self.inst:HasTag("burnt") and 0) or self.drag
end

function Anchor:OnSave()
    local data =
    {
        raiseunits = self.raiseunits,
    }

    return data
end

function Anchor:GetCurrentDepth()
    local depth = self.bottomunits            
    local ground = TheWorld
    if self.boat then
        local tile = ground.Map:GetTileAtPoint(self.boat.Transform:GetWorldPosition())
        if tile then
            local depthcategory = GetTileInfo(tile).ocean_depth
            depth = TUNING.ANCHOR_DEPTH_TIMES[depthcategory]
        end
    end

    return depth
end

function Anchor:OnLoad(data)
    if data ~= nil then

        if data.raiseunits then
            self.raiseunits = data.raiseunits
        end

        self.inst:DoTaskInTime(0,
                function(i)
                   
                    if not i:HasTag("burnt") then
                        self.boat = self.inst:GetCurrentPlatform()
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
                end)
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
				boat.components.boatphysics:AddAnchorCmp(self)
			else
				boat.components.boatphysics:RemoveAnchorCmp(self)
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
    self.raisers[doer] = 1  -- raise units/second
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
    if self.boat then
        ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.3, 0.03, 0.5, self.boat, self.boat:GetPhysicsRadius(4))
    end
end

function Anchor:OnUpdate(dt)
    if self.is_anchor_transitioning then

        local depth = self:GetCurrentDepth()

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
        if self.raiseunits >= depth then
            self:AnchorLowered()
        end        
    end    
end

return Anchor
