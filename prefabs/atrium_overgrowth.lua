local assets =
{
    Asset("ANIM", "anim/atrium_overgrowth.zip"),
}

local nightmare_assets =
{
    Asset("ANIM", "anim/atrium_overgrowth.zip"),
}

local function fn(bank)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild(bank)
    inst.AnimState:SetBank(bank)
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon(bank..".png")

    MakeObstaclePhysics(inst, 1.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SUPERHUGE

    inst:AddComponent("inspectable")
    MakeRoseTarget_CreateFuel_IncreasedHorror(inst)

    return inst
end

local function idolfn()
    local inst = fn("atrium_overgrowth")

    inst:SetPrefabName("atrium_overgrowth")

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("atrium_overgrowth", function() return fn("atrium_overgrowth") end, assets, prefabs),
    Prefab("atrium_idol", idolfn, assets, prefabs) -- deprecated
