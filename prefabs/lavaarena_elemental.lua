local assets =
{
    Asset("ANIM", "anim/lavaarena_elemental_basic.zip"),
}

local prefabs =
{
    "fireball_projectile",
    "fireball_cast_fx",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(1.1, .7)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("lavaarena_elemental_basic")
    inst.AnimState:SetBuild("lavaarena_elemental_basic")
    inst.AnimState:Hide("head_spikes")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("elemental")
    inst:AddTag("companion")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("notraptrigger")
    inst:AddTag("NOCLICK")

    inst:SetPhysicsRadiusOverride(.65)
    inst.Physics:SetMass(450)
    inst.Physics:SetFriction(10)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.Physics:SetCapsule(inst.physicsradiusoverride, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_elemental").master_postinit(inst)

    return inst
end

return Prefab("lavaarena_elemental", fn, assets, prefabs)
