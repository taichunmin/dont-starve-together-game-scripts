local assets =
{
    Asset("ANIM", "anim/bernie.zip"),
    Asset("ANIM", "anim/bernie_build.zip"),
}

local prefabs =
{
    "small_puff",
}

local function CanBeRevivedBy(inst, reviver)
    return reviver:HasTag("bernie_reviver")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(.35)
    MakeCharacterPhysics(inst, 50, inst.physicsradiusoverride)
    inst.DynamicShadow:SetSize(1.1, .55)

    inst.Transform:SetScale(TUNING.LAVAARENA_BERNIE_SCALE, TUNING.LAVAARENA_BERNIE_SCALE, TUNING.LAVAARENA_BERNIE_SCALE)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("bernie")
    inst.AnimState:SetBuild("bernie_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("character")
    inst:AddTag("smallcreature")
    inst:AddTag("companion")
    inst:AddTag("notarget")

    inst:AddComponent("revivablecorpse")
    inst.components.revivablecorpse:SetCanBeRevivedByFn(CanBeRevivedBy)

    inst:Hide()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_bernie").master_postinit(inst)

    return inst
end

return Prefab("lavaarena_bernie", fn, assets, prefabs)
