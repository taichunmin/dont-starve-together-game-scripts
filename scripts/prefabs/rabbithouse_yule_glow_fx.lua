local assets =
{
}

local function glowfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("rabbithouse_glowfx")
    inst.AnimState:SetBuild("rabbit_house")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetLightOverride(0.7)
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    return inst
end

--------------------------------------------------------------------------

return Prefab("rabbithouse_yule_glow_fx", glowfn, assets)
