local assets =
{
    Asset("ANIM", "anim/lavaarena_shadow_lunge.zip"),
    Asset("ANIM", "anim/waxwell_shadow_mod.zip"),
    Asset("ANIM", "anim/swap_nightmaresword_shadow.zip"),
}

local prefabs =
{
    "statue_transition_2",
    "shadowstrike_slash_fx",
    "shadowstrike_slash2_fx",
    "weaponsparks",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced(inst)

    inst.AnimState:SetBank("lavaarena_shadow_lunge")
    inst.AnimState:SetBuild("waxwell_shadow_mod")
    inst.AnimState:AddOverrideBuild("lavaarena_shadow_lunge")
    inst.AnimState:SetMultColour(0, 0, 0, .5)
    inst.AnimState:OverrideSymbol("swap_object", "swap_nightmaresword_shadow", "swap_nightmaresword_shadow")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetCapsule(.5, 1)

    inst:AddTag("scarytoprey")
    inst:AddTag("NOBLOCK")

    inst:Hide()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/waxwell_shadowstriker").master_postinit(inst)

    return inst
end

return Prefab("waxwell_shadowstriker", fn, assets, prefabs)
