local assets =
{
    Asset("ANIM", "anim/moonglass_bigwaterfall.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBuild("moonglass_bigwaterfall")
    inst.AnimState:SetBank("moonglass_bigwaterfall")
    inst.AnimState:PlayAnimation("water_big", true)

    inst:AddTag("NOCLICK")

    inst.no_wet_prefix = true

	inst:SetDeploySmartRadius(3.5)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    return inst
end

return Prefab("grotto_waterfall_big", fn, assets)
