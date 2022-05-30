local assets =
{
    Asset("DYNAMIC_ANIM", "anim/dynamic/lantern_crystal.zip"),
    Asset("PKGREF", "anim/dynamic/lantern_crystal.dyn"),
}

local function KillFX(inst)
    inst:Remove()
end

local function commonfn( anim )
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("lantern_crystal_fx")
    inst.AnimState:SetBuild("lantern")
    inst.AnimState:PlayAnimation(anim, true)
    inst.AnimState:SetFinalOffset(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.KillFX = KillFX

    return inst
end

local function groundfn()
    return commonfn( "idle_ground" )
end

local function heldfn()
    return commonfn( "idle_held" )
end

return Prefab("lantern_crystal_fx_ground", groundfn, assets),
Prefab("lantern_crystal_fx_held", heldfn, assets)
