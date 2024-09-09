local assets =
{
    Asset("ANIM", "anim/cave_ferns.zip"),
}

local prefabs =
{
    "foliage",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("ferns")
    inst.AnimState:SetBuild("cave_ferns")
    inst.AnimState:SetRayTestOnBB(true)

    inst:SetPhysicsRadiusOverride(0.4)

    -- for stats tracking
    inst:AddTag("quagmire_wildplant")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_fern").master_postinit(inst)

    return inst
end

return Prefab("quagmire_fern", fn, assets, prefabs)
