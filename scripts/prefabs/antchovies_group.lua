local assets =
{
    Asset("ANIM", "anim/water_antchovies.zip"),
}

local prefabs =
{
    "antchovies",
}

local function fn()

   local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("ignorewalkableplatforms")

    inst.AnimState:SetBank("antchovies")
    inst.AnimState:SetBuild("water_antchovies")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetMultColour(0.4,0.4,0.4,1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst:SetStateGraph("SGantchovies")
    inst:AddComponent("fishschool")
    inst.components.fishschool:SetNettedPrefab("antchovies")
    inst.components.fishschool:StartReplenish(10)

    return inst
end

return Prefab("antchovies_group", fn, assets, prefabs)
