require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/fossil_piece.zip"),
}

local prefabs =
{
    "fossil_stalker",
}

local NUM_FOSSIL_TYPES = 4

local function SetFossilType(inst, fossiltype)
    if inst.fossiltype ~= fossiltype then
        inst.fossiltype = fossiltype
        inst.AnimState:PlayAnimation("f"..tostring(fossiltype))
    end
end

local function onsave(inst, data)
    data.fossiltype = inst.fossiltype
end

local function onload(inst, data)
    if data ~= nil and
        data.fossiltype ~= nil and
        data.fossiltype >= 1 and
        data.fossiltype <= NUM_FOSSIL_TYPES then
        SetFossilType(inst, data.fossiltype)
    end
end

local function ondeploy(inst, pt)
    local mound = SpawnPrefab("fossil_stalker")
    mound.Transform:SetPosition(pt:Get())
    mound.SoundEmitter:PlaySound("dontstarve/creatures/together/fossil/repair")
	PreventCharacterCollisionsWithPlacedObjects(mound)

    inst.components.stackable:Get():Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.pickupsound = "rock"

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("fossil_piece")
    inst.AnimState:SetBuild("fossil_piece")
    SetFossilType(inst, 1)

    MakeInventoryFloatable(inst, "small", 0.0, {1.3, 0.75, 1.3})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "f1"

    SetFossilType(inst, math.random(NUM_FOSSIL_TYPES))

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    ------------------
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    --inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.PLACER_DEFAULT)

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.FOSSIL
    inst.components.repairer.workrepairvalue = 1

    --------SaveLoad
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

--TODO: REMOVE (someday)! Deprecated, but might be in existing save data
function cleanfn()
    local inst = fn()

    inst:SetPrefabName("fossil_piece")

    return inst
end

return Prefab("fossil_piece", fn, assets, prefabs),
       MakePlacer("fossil_piece_placer", "fossil_stalker", "fossil_stalker", "1_1"),
       Prefab("fossil_piece_clean", cleanfn, assets, prefabs)
