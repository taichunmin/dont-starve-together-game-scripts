local assets =
{
    Asset("ANIM", "anim/boat_net.zip"),
}

local prefabs =
{
    "fishingnetvisualizerfx"
}

local function fn()
    local inst = CreateEntity()

    inst:AddTag("ignorewalkableplatforms")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFourFaced()

    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("boat_net")
    inst.AnimState:SetBuild("boat_net")
    inst.AnimState:SetSortOrder(5)

    inst:AddComponent("groundshadowhandler")
    inst.components.groundshadowhandler:SetSize(3, 2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:SetStateGraph("SGfishingnetvisualizer")

    inst:AddComponent("fishingnetvisualizer")

    return inst
end

return Prefab("fishingnetvisualizer", fn, assets, prefabs)
