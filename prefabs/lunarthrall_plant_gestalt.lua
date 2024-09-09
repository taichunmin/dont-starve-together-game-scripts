require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/lunarthrall_plant_gestalt.zip"),
}

local function Spawn(inst)
    inst.components.timer:StartTimer("justspawned",15)
    inst.Transform:SetRotation(math.random()*360)
	inst.sg:GoToState("spawn")
end

local brain = require "brains/lunarthrall_plant_gestalt_brain"

local function fn()
    local inst = CreateEntity()

    --Core components
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --Initialize physics
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

    inst:AddComponent("timer")

    inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = TUNING.SANITYAURA_MED

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.LUNARTHRALL_PLANT_GESTALT_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.LUNARTHRALL_PLANT_GESTALT_RUN_SPEED
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }

    inst.Spawn = Spawn

	inst:AddComponent("knownlocations")

    inst:SetStateGraph("SGlunarthrall_plant_gestalt")
    inst:SetBrain(brain)

    return inst
end

return Prefab("lunarthrall_plant_gestalt", fn, assets)
