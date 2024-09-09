local assets =
{
    Asset("ANIM", "anim/polly_rogers.zip"),    
}

local prefabs =
{

}

local brain = require("brains/pollyrogerbrain")


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
        
    inst.entity:AddPhysics()
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetMass(1)
    inst.Physics:SetSphere(1)

    inst.scrapbook_animoffsety = 5
    inst.scrapbook_animpercent = 0.3
    inst.scrapbook_specialinfo = "POLLYROGERS"

    inst.DynamicShadow:SetSize(1, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("polly_rogers")
    inst.AnimState:SetBuild("polly_rogers")
    inst.AnimState:PlayAnimation("idle_ground")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("bird")
    inst:AddTag("smallcreature")
    inst:AddTag("untrappable")
    inst:AddTag("companion")
    inst:AddTag("noplayertarget")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("NOBLOCK")

    inst.sounds =
    {
        takeoff = "dontstarve/birds/takeoff_crow",
        chirp = "dontstarve/birds/chirp_crow",
        flyin = "dontstarve/birds/flyin",
    }

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.POLLY_ROGERS_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.POLLY_ROGERS_RUN_SPEED
    inst.components.locomotor.pathcaps = { allowocean = true }
    inst.components.locomotor:SetTriggersCreep(false)
    inst:SetStateGraph("SGpolly_rogers")

    inst:SetBrain(brain)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.SEEDS }, { FOODTYPE.SEEDS })

    inst:AddComponent("follower")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.POLLY_ROGERS_MAX_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "polly_body"

    MakeSmallBurnableCharacter(inst, "polly_body")
    MakeTinyFreezableCharacter(inst, "polly_body")

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")
   -- inst:AddComponent("sleeper")
    --inst.components.sleeper.watchlight = true
    
    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1

--    MakeHauntablePanic(inst)

  --  inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab("polly_rogers", fn, assets, prefabs)
