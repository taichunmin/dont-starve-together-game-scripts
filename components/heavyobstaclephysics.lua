--------------------------------------------------------------------------
--This component should be paired with MakeHeavyObstaclePhysics.
--------------------------------------------------------------------------

local PHYSICS_STATE_NAMES =
{
    "ITEM",
    "OBSTACLE",
    "FALLING",
}
local PHYSICS_STATE = table.invert(PHYSICS_STATE_NAMES)

local function SetCurrentRadius(self, radius)
    if self.currentradius ~= radius then
        self.currentradius = radius
        self.inst.Physics:SetCapsule(radius, 2)
    end
end

local function SetPhysicsState(self, state)
    self.physicsstate = state
    if self.onphysicsstatechangedfn ~= nil then
        self.onphysicsstatechangedfn(self.inst, PHYSICS_STATE_NAMES[state])
    end
end

local function CancelObstacleTask(self)
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
        self.ischaracterpassthrough = nil
    end
end

local function ChangeToItem(inst)
    local self = inst.components.heavyobstaclephysics
    if self.onchangetoitemfn ~= nil then
        self.onchangetoitemfn(inst)
        if not inst:IsValid() then
            return
        end
    end
    CancelObstacleTask(self)
    if self.physicsstate ~= PHYSICS_STATE.ITEM then
        if self.physicsstate ~= PHYSICS_STATE.FALLING then
            SetCurrentRadius(self, self.maxradius)
            inst.Physics:SetMass(1)
            inst.Physics:SetDamping(0) --might have been changed when falling
            inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
            inst.Physics:ClearCollisionMask()
        end
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
        SetPhysicsState(self, PHYSICS_STATE.ITEM)
    end
end

local CHARACTER_MUST_TAGS = { "character", "locomotor" }
local CHARACTER_CANT_TAGS = { "INLIMBO", "NOCLICK", "flying", "ghost" }
local function OnUpdateObstacleSize(inst, self)
    local x, y, z = inst.Transform:GetWorldPosition()
    local mindist = math.huge
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 2, CHARACTER_MUST_TAGS, CHARACTER_CANT_TAGS)) do
        if v.entity:IsVisible() then
            local d = v:GetDistanceSqToPoint(x, y, z)
            d = d > 0 and (v.Physics ~= nil and math.sqrt(d) - v.Physics:GetRadius() or math.sqrt(d)) or 0
            if d < mindist then
                if d <= 0 then
                    mindist = 0
                    break
                end
                mindist = d
            end
        end
    end
    local radius = math.clamp(mindist, 0, self.maxradius)
    if radius > 0 then
        SetCurrentRadius(self, radius)
        if self.ischaracterpassthrough then
            self.ischaracterpassthrough = nil
            inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        end
        if radius >= self.maxradius then
            CancelObstacleTask(self)
        end
    end
end

local function OnChangeToObstacle(inst, self)
    inst.Physics:SetMass(0)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    if self.issmall then
        inst.Physics:SetCollisionGroup(COLLISION.SMALLOBSTACLES)
    else
        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
    end
    SetPhysicsState(self, PHYSICS_STATE.OBSTACLE)
    if not inst:IsValid() then
        return
    end
    self.ischaracterpassthrough = true
    self.task = inst:DoPeriodicTask(.5, OnUpdateObstacleSize, nil, self)
    OnUpdateObstacleSize(inst, self)
    inst.Physics:Teleport(inst.Transform:GetWorldPosition())
end

local function ChangeToObstacle(inst)
    local self = inst.components.heavyobstaclephysics
    if self.onchangetoobstaclefn ~= nil then
        self.onchangetoobstaclefn(inst)
        if not inst:IsValid() then
            return
        end
    end
    CancelObstacleTask(self)
    if self.physicsstate ~= PHYSICS_STATE.OBSTACLE then
        self.task = inst:DoTaskInTime(.5, OnChangeToObstacle, self)
    end
end

local function OnStartFalling(inst)
    local self = inst.components.heavyobstaclephysics
    if self.onstartfallingfn ~= nil then
        self.onstartfallingfn(inst)
        if not inst:IsValid() then
            return
        end
    end
    CancelObstacleTask(self)
    if self.physicsstate ~= PHYSICS_STATE.FALLING then
        if self.physicsstate ~= PHYSICS_STATE.ITEM then
            SetCurrentRadius(self, self.maxradius)
            inst.Physics:SetMass(1)
            inst.Physics:SetDamping(0) --might have been changed by quaker
            inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
            inst.Physics:Teleport(inst.Transform:GetWorldPosition()) --force physics to wakeup
        end
        inst.Physics:ClearCollisionMask()
        SetPhysicsState(self, PHYSICS_STATE.FALLING)
    end
end

local function OnStopFalling(inst)
    local self = inst.components.heavyobstaclephysics
    if self.onstopfallingfn ~= nil then
        self.onstopfallingfn(inst)
        if not inst:IsValid() then
            return
        end
    end
    CancelObstacleTask(self)
    OnChangeToObstacle(inst, self)
end

--------------------------------------------------------------------------

local HeavyObstaclePhysics = Class(function(self, inst)
    self.inst = inst

    self.maxradius = nil
    self.currentradius = nil
    self.physicsstate = nil
    self.ischaracterpassthrough = nil
    self.issmall = nil
    self.task = nil
    self.onphysicsstatechangedfn = nil
    self.onchangetoitemfn = nil
    self.onchangetoobstaclefn = nil
    self.onstartfallingfn = nil
    self.onstopfallingfn = nil
end)

function HeavyObstaclePhysics:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("onputininventory", ChangeToItem)
    self.inst:RemoveEventCallback("ondropped", ChangeToObstacle)
    self.inst:RemoveEventCallback("startfalling", OnStartFalling)
    self.inst:RemoveEventCallback("stopfalling", OnStopFalling)
end

function HeavyObstaclePhysics:SetRadius(radius)
    self.maxradius = radius
    self.currentradius = radius
    self.physicsstate = PHYSICS_STATE.OBSTACLE
    self.inst:ListenForEvent("onputininventory", ChangeToItem)
    self.inst:ListenForEvent("ondropped", ChangeToObstacle)
end

function HeavyObstaclePhysics:MakeSmallObstacle()
    self.issmall = true
end

function HeavyObstaclePhysics:AddFallingStates()
    self.inst:ListenForEvent("startfalling", OnStartFalling)
    self.inst:ListenForEvent("stopfalling", OnStopFalling)
end

function HeavyObstaclePhysics:GetPhysicsState()
    return PHYSICS_STATE_NAMES[self.physicsstate]
end

function HeavyObstaclePhysics:IsItem()
    return self.physicsstate == PHYSICS_STATE.ITEM
end

function HeavyObstaclePhysics:IsObstacle()
    return self.physicsstate == PHYSICS_STATE.OBSTACLE
end

function HeavyObstaclePhysics:IsFalling()
    return self.physicsstate == PHYSICS_STATE.FALLING
end

function HeavyObstaclePhysics:SetOnPhysicsStateChangedFn(fn)
    self.onphysicsstatechangedfn = fn
end

function HeavyObstaclePhysics:SetOnChangeToItemFn(fn)
    self.onchangetoitemfn = fn
end

function HeavyObstaclePhysics:SetOnChangeToObstacleFn(fn)
    self.onchangetoobstaclefn = fn
end

function HeavyObstaclePhysics:SetOnStartFallingFn(fn)
    self.onstartfallingfn = fn
end

function HeavyObstaclePhysics:SetOnStopFallingFn(fn)
    self.onstopfallingfn = fn
end

return HeavyObstaclePhysics
