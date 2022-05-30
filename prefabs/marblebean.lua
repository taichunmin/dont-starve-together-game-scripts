require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/marblebean.zip"),
}

local prefabs =
{
    "marblebean_sapling",
}

local function ondeploy(inst, pt, deployer)
    local sapling = SpawnPrefab("marblebean_sapling")
    sapling:StartGrowing()
    sapling.Transform:SetPosition(pt:Get())
    sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("marblebean")
    inst.AnimState:SetBuild("marblebean")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")
    inst:AddTag("molebait")
    inst:AddTag("treeseed")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    MakeHauntableLaunch(inst)

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable.ondeploy = ondeploy

    return inst
end

return Prefab("marblebean", fn, assets, prefabs),
	MakePlacer("marblebean_placer", "marblebean", "marblebean", "idle_planted")
