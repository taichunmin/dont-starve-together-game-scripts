local assets =
{
    Asset("ANIM", "anim/stagehand.zip"),
    Asset("SOUND", "sound/sfx.fsb"),
}

local prefabs =
{
    "campfirefire",
    "endtable_blueprint",
}

local brain = require("brains/stagehandbrain")

SetSharedLootTable('stagehand_creature',
{
    {'endtable_blueprint', 1.0},
})

local function onworked(inst, worker)
    -- make sure it never runs out of work to do
    inst.components.workable:SetWorkLeft(TUNING.STAGEHAND_HITS_TO_GIVEUP)
end

local function getstatus(inst)
    return inst.sg:HasStateTag("hiding") and "HIDING" or "AWAKE"
end

local function CanStandUp(inst)
    -- if not in light or off screen (off screen is so it doesnt get stuck forever on things like firefly/pighouse light), then it can stand up and walk around
    return (not inst:IsInLight()) or (TheWorld.state.isnight and (not TheWorld.state.isfullmoon) and not inst:IsNearPlayer(30))
end

local sounds =
{
    hit         = "dontstarve/creatures/together/stagehand/hit",
    awake_pre   = "dontstarve/creatures/together/stagehand/awake_pre",
    footstep    = "dontstarve/creatures/together/stagehand/footstep",
}

local function ChangePhysics(inst, is_standing)
    if is_standing then
        if inst:HasTag("blocker") then
            inst:RemoveTag("blocker")
            inst.Physics:SetMass(100)
            inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
            inst.Physics:CollidesWith(COLLISION.WORLD)
        end
    elseif not inst:HasTag("blocker") then
        inst:AddTag("blocker")
        inst.Physics:SetMass(0)
        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    ChangePhysics(inst, false)
    inst.Physics:SetCapsule(.5, 1)

    inst.AnimState:SetBank("stagehand")
    inst.AnimState:SetBuild("stagehand")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("notraptrigger")
    inst:AddTag("antlion_sinkhole_blocker")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeSmallPropagator(inst)
    MakeHauntableWork(inst)
    MakeSnowCovered(inst)

    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 0, 0), "swap_fire")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(TUNING.STAGEHAND_HITS_TO_GIVEUP)
    --inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onworked)

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 8
	inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.sounds = sounds

    inst.CanStandUp = CanStandUp
    inst.ChangePhysics = ChangePhysics

    inst:SetStateGraph("SGstagehand")
    inst:SetBrain(brain)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('stagehand_creature')

    return inst
end

return Prefab("stagehand", fn, assets, prefabs)
