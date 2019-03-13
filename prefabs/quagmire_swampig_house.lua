local assets =
{
    Asset("ANIM", "anim/pig_house.zip"), -- bank
    Asset("ANIM", "anim/quagmire_werepig_house.zip"), -- build
    Asset("ANIM", "anim/quagmire_merm_house.zip"), -- build
    Asset("SOUND", "sound/pig.fsb"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("pig_house")
    inst.AnimState:SetBuild("quagmire_merm_house")
    inst.AnimState:PlayAnimation("rundown")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    return inst
end

local function rubblefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("pig_house")
    inst.AnimState:SetBuild("quagmire_werepig_house")
    inst.AnimState:PlayAnimation("rubble")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    return inst
end

return Prefab("quagmire_swampig_house", fn, assets),
    Prefab("quagmire_swampig_house_rubble", rubblefn, assets)
