--Down when players are near, up when players are far.
local assets =
{
    Asset("ANIM", "anim/atrium_fence.zip"),
}

local NUM_SHAPES = 5
local NEAR_DIST_SQ = 7 * 7
local FAR_DIST_SQ = 8 * 8

local function setclosedphysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local function setopenedphysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local function transitionclosed(inst)
    inst.closed = true
    inst.AnimState:PlayAnimation("grow"..tostring(inst.fenceid))
    inst.AnimState:PushAnimation("idle"..tostring(inst.fenceid)..(inst.locked and "_active" or ""), false)
    setclosedphysics(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium/gate_spike")
end

local function transitionopened(inst)
    inst.closed = false
    inst.AnimState:PlayAnimation("shrink"..tostring(inst.fenceid))
    inst.AnimState:PushAnimation("shrunk", false)
    setopenedphysics(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/atrium/retract")
end

local function setclosed(inst)
    if not inst.closed and inst.closingtask == nil then
        if inst.openingtask ~= nil then
            inst.openingtask:Cancel()
            inst.openingtask = nil
        end

        inst.closingtask = inst:DoTaskInTime(math.random(), transitionclosed)
    end
end

local function setopened(inst)
    if inst.closed and inst.openingtask == nil then
        if inst.closingtask ~= nil then
            inst.closingtask:Cancel()
            inst.closingtask = nil
        end

        inst.openingtask = inst:DoTaskInTime(math.random(), transitionopened)
    end
end

local function onupdate(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.closed then
        if not inst.locked and IsAnyPlayerInRangeSq(x, y, z, NEAR_DIST_SQ) then
            setopened(inst)
        end
    elseif inst.locked or not IsAnyPlayerInRangeSq(x, y, z, FAR_DIST_SQ) then
        setclosed(inst)
    end
end

local function OnPoweredFn(inst, ispowered)
    if inst.locked == nil or inst.locked ~= ispowered then
        inst.locked = ispowered

        if inst.closed then
            inst.AnimState:PushAnimation("idle"..tostring(inst.fenceid)..(inst.locked and "_active" or ""), false)
        end

        onupdate(inst)
    end
end

local function OnSave(inst, data)
    data.fenceid = inst.fenceid
end

local function OnLoad(inst, data)
    if data ~= nil and data.fenceid ~= nil then
        inst.fenceid = data.fenceid
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("atrium_fence")
    inst.AnimState:SetBuild("atrium_fence")
    inst.AnimState:PlayAnimation("shrunk")

    MakeObstaclePhysics(inst, .1)
    setopenedphysics(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.fenceid = math.random(NUM_SHAPES)
    inst.closed = false
    inst.closingtask = nil
    inst.openingtask = nil

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("atriumpowered", function(_, ispowered) OnPoweredFn(inst, ispowered) end, TheWorld)

    inst:DoPeriodicTask(.2, onupdate, math.random() * .2)

    return inst
end

return Prefab("atrium_fence", fn, assets)
