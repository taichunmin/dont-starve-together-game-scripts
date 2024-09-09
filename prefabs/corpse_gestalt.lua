require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/lunarthrall_plant_gestalt.zip"),
}

local CORPSE_TRACK_NAME = "corpse"

local brain = require "brains/corpse_gestalt_brain"

local function Spawn(inst)
    inst.Transform:SetRotation(math.random()*360)
    inst.sg:GoToState("spawn")
end

local function GeSpawnPoint(inst, target)
    local pos = target:GetPosition()
    local offset = FindWalkableOffset(pos, TWOPI*math.random(), 30, 12, true, false, nil, true, true)

    return pos + (offset or Vector3(0,0,0))
end

local function SetTarget(inst, target)
    if target ~= nil and target:IsValid() then
        inst.components.entitytracker:TrackEntity(CORPSE_TRACK_NAME, target)

        local pos = GeSpawnPoint(inst, target)
        inst.Physics:Teleport(pos:Get())
    else
        inst.components.entitytracker:ForgetEntity(CORPSE_TRACK_NAME)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local phys = inst.entity:AddPhysics()
    phys:SetMass(1)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.FLYERS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.GROUND)
    phys:SetCapsule(0.5, 1)

    inst:AddTag("brightmare")
    inst:AddTag("NOBLOCK")
    inst:AddTag("soulless") -- no wortox souls
    inst:AddTag("lunar_aligned")

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBuild("lunarthrall_plant_gestalt")
    inst.AnimState:SetBank("lunarthrall_plant_gestalt")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetMultColour(1,1,1,0.6)
	inst.AnimState:SetLightOverride(0.1)
    inst.AnimState:UsePointFiltering(true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("entitytracker")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_MED

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.CORPSE_GESTALT_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.CORPSE_GESTALT_RUN_SPEED
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }

    inst.Spawn = Spawn
    inst.SetTarget = SetTarget

    inst:AddComponent("knownlocations")

    inst:SetStateGraph("SGlunarthrall_plant_gestalt")
    inst:SetBrain(brain)

    return inst
end

return Prefab("corpse_gestalt", fn, assets)
