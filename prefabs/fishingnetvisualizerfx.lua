local assets =
{
    Asset("ANIM", "anim/boat_net_fx.zip"),
}

local prefabs =
{
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.persists = false

    inst:AddTag("NOBLOCK")
    inst:AddTag("FX")

    inst.AnimState:SetBank("boat_net_fx")
    inst.AnimState:SetBuild("boat_net_fx")
    inst.AnimState:PlayAnimation("hit", false)
    inst.AnimState:SetSortOrder(5)

    inst:ListenForEvent("animover", function() inst:Remove() end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("fishingnetvisualizerfx", fn, assets, prefabs)
