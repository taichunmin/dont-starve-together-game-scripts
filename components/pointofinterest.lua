local SCRAPBOOK_DATA_SET = require("screens/redux/scrapbookdata")

local DEFAULT_SCALE = 2

local HUD_INDICATOR_DATA = { image = "poi_question.tex", atlas = "images/avatars.xml" }

local function _CommonIndicator(data)
    local inst = CreateEntity()

    --[[Non-networked entity]]
    if not TheWorld.ismastersim then
        inst.entity:SetCanSleep(false)
    end

    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build)
    inst.AnimState:PlayAnimation(data.anim)

    inst.Transform:SetScale(DEFAULT_SCALE, DEFAULT_SCALE, DEFAULT_SCALE)

    inst.alpha = 1
    inst.scale = 1

    return inst
end

local function PrefabIndicator()
    return _CommonIndicator({ bank = "poi_marker", build = "poi_marker", anim = "idle" })
end

local function CreateRing()
    local inst = _CommonIndicator({ bank = "poi_marker", build = "poi_marker", anim = "ring"  })

    inst.entity:AddFollower()

    return inst
end

local function Stand()
    return _CommonIndicator({ bank = "poi_stand", build = "flint", anim = "idle"  })
end

------------------------------------------------------------------------------------------------------------------------

local PointOfInterest = Class(function(self, inst)
    self.inst = inst

    self._showinghud = nil
    self.shouldshowfn = nil

    self._updating = false

    self.height = 0

    self._TryStartingUpdating = function(inst, self) self:TryStartUpdating() end

    inst:DoTaskInTime(0, self._TryStartingUpdating, self)
end)

------------------------------------------------------------------------------------------------------------------------

function PointOfInterest:TryStartUpdating()
    local entry = TheScrapbookPartitions:RedirectThing(self.inst)

    if SCRAPBOOK_DATA_SET[entry] and TheScrapbookPartitions:GetLevelFor(entry) < 2 then
        self._updating = true
        self.inst:StartUpdatingComponent(self)
    end
end

------------------------------------------------------------------------------------------------------------------------

function PointOfInterest:SetShouldShowFn(fn)
    self.shouldshowfn = fn
end

function PointOfInterest:SetHeight(height)
    self.height = height
end

------------------------------------------------------------------------------------------------------------------------

function PointOfInterest:OnEntitySleep() -- Master sim only.
    self:RemoveEverything()
end

function PointOfInterest:OnEntityWake() -- Master sim only.
    self:TryStartUpdating()
end

------------------------------------------------------------------------------------------------------------------------

function PointOfInterest:RemoveHudIndicator()
    if self._showinghud and ThePlayer ~= nil and ThePlayer.HUD ~= nil then
        self._showinghud = false
        ThePlayer.HUD:RemoveTargetIndicator(self.inst)
    end
end

function PointOfInterest:CreateWorldIndicator()
    if self.stand ~= nil or self._removing then
        return
    end

    self.stand = Stand()
    self.inst:AddChild(self.stand)

    self.marker = PrefabIndicator()
    self.marker.entity:AddFollower()

    self.marker.Follower:FollowSymbol(self.stand.GUID, "marker", 0, self.height, 0)
end

function PointOfInterest:TriggerPulse()
    if self.marker == nil then
        return
    end

    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/poi_register")

    self.marker.AnimState:PlayAnimation("dark")

    self._removing = true

    self.marker.scale = 1
    self.marker.target = 0.7
    self.loops = 0
end

function PointOfInterest:TriggerRemove()
    self:RemoveHudIndicator(self.inst)
    self:TriggerPulse()
end

local THINGS_TO_REMOVE =
{
    "ring1",
    "ring2",
    "marker",
    "stand",
}

function PointOfInterest:RemoveEverything()
    if self._updating then
        self._updating = false
        self.inst:StopUpdatingComponent(self)
    end

    self._removing = false

    for _, k in ipairs(THINGS_TO_REMOVE) do
        if self[k] ~= nil then
            self[k]:Remove()
            self[k] = nil
        end
    end
end

function PointOfInterest:ShouldShowHudIndicator(distsq)
    return distsq >= TUNING.MIN_INDICATOR_RANGE and distsq <= TUNING.MAX_INDICATOR_RANGE
end

function PointOfInterest:UpdateRing(ring, dt)
    if ring ~= nil then
        ring.scale = ring.scale + (1.05 * dt)
        ring.alpha = ring.alpha - (2.00 * dt)

        if ring.scale > 2 then
            ring:Remove()
            ring = nil
        else
            local _scale = ring.scale * DEFAULT_SCALE

            ring.Transform:SetScale(_scale, _scale, _scale)
            ring.AnimState:SetMultColour(1, 1, 1, ring.alpha)
        end
    end
end

function PointOfInterest:UpdateRemovePulse(dt)
    self:UpdateRing(self.ring1, dt)
    self:UpdateRing(self.ring2, dt)

    if self.marker.target ~= nil then
        self.marker.scale = self.marker.scale - (0.75 * dt)
        self.marker.Transform:SetScale(self.marker.scale * DEFAULT_SCALE, self.marker.scale * DEFAULT_SCALE, self.marker.scale * DEFAULT_SCALE)

        if self.loops == 2 then
            local marker_alpha = Remap(self.marker.scale, 1, self.marker.target, 1.5, 0)

            self.marker.AnimState:SetMultColour(1, 1, 1, marker_alpha)
        end
        
        if self.marker.scale < self.marker.target then
            self.loops = self.loops + 1
            
            if self.loops == 1 then
                self.marker.scale = 1.3
                self.marker.target = 1

                self.ring1 = CreateRing()
                self.ring1.Follower:FollowSymbol(self.stand.GUID, "marker", 0, self.height, 0)
                
            elseif self.loops == 2 then
                self.marker.scale = 1
                self.marker.target = 0.5

                self.ring2 = CreateRing()
                self.ring2.Follower:FollowSymbol(self.stand.GUID, "marker", 0, self.height, 0)

            else
                self:RemoveEverything()
            end
        end
    end
end

function PointOfInterest:OnUpdate(dt)

    if self.marker then       
        if Profile:GetPOIDisplay() then
            self.marker:Show()
        else
            self.marker:Hide()
        end
    end

    if ThePlayer ~= nil and
        ThePlayer.HUD ~= nil and
        not self._removing and
        (self.shouldshowfn == nil or self.shouldshowfn(self.inst))        
    then
        if Profile:GetPOIDisplay() then
            local dist = math.sqrt(ThePlayer:GetDistanceSqToInst(self.inst))

            if TheScrapbookPartitions:GetLevelFor(self.inst) < 2  then
                self:CreateWorldIndicator()

                if not self:ShouldShowHudIndicator(dist) then
                    self:RemoveHudIndicator()

                elseif not self._showinghud then
                    self._showinghud = true
                    ThePlayer.HUD:AddTargetIndicator(self.inst, HUD_INDICATOR_DATA)
                end

            else
                self:TriggerRemove()
            end 
        else
            self:RemoveHudIndicator()
        end
    end

    if self._removing and self.marker ~= nil then
        self:UpdateRemovePulse(dt)
    end
end

function PointOfInterest:OnRemoveEntity()
    self:RemoveHudIndicator()
    self:RemoveEverything()
end

PointOfInterest.OnRemoveFromEntity = PointOfInterest.OnRemoveEntity

function PointOfInterest:DebugForceShowIndicator()
    self:CreateWorldIndicator()

    self._updating = true
    self.inst:StartUpdatingComponent(self)
end

return PointOfInterest
