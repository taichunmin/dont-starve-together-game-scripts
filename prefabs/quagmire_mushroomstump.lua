local assets =
{
    Asset("ANIM", "anim/quagmire_mushroomstump.zip"),
}

local prefabs =
{
    "quagmire_mushrooms",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(0.7, 0.7, 0.7)

    MakeSmallObstaclePhysics(inst, .2)
    inst:SetPhysicsRadiusOverride(1.0)

    inst.MiniMapEntity:SetIcon("quagmire_mushroomstump.png")

    inst.AnimState:SetBank("quagmire_mushroomstump")
    inst.AnimState:SetBuild("quagmire_mushroomstump")
    inst.AnimState:PlayAnimation("idle", true)

    -- for stats tracking
    inst:AddTag("quagmire_wildplant")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_mushroomstump").master_postinit(inst)

    return inst
end

return Prefab("quagmire_mushroomstump", fn, assets, prefabs)
