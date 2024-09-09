local assets =
{
    Asset("ANIM", "anim/rocks.zip"),
}

local names = { "f1", "f2", "f3" }

local function onsave(inst, data)
    data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
        inst.AnimState:PlayAnimation(inst.animname)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("rocks")
    inst.AnimState:SetBuild("rocks")

    inst.pickupsound = "rock"

    inst:AddTag("molebait")
    inst:AddTag("quakedebris")
    inst:AddTag("rocks")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.animname = names[math.random(#names)]
    inst.AnimState:PlayAnimation(inst.animname)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 1

    inst:AddComponent("tradable")
    inst.components.tradable.rocktribute = 1

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("bait")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.STONE
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_ROCKS_HEALTH

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/inv_rocks").master_postinit(inst)
    end

    MakeHauntableLaunchAndSmash(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("rocks", fn, assets)
