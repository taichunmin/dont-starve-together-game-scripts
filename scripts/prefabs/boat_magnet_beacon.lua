local assets =
{
    Asset("ANIM", "anim/boat_magnet_beacon.zip"),
    Asset("INV_IMAGE", "boat_magnet_beacon_on"),
}

local item_assets =
{
    Asset("ANIM", "anim/boat_magnet_beacon.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function on_hammered(inst, hammerer)
    inst.components.lootdropper:DropLoot()

    local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial("wood")

    inst:Remove()
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/steering_wheel/place")
    inst.sg:GoToState("place")
end

local function onsave(inst, data)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	end
end

local function onload(inst, data)
	if data ~= nil and data.burnt == true then
        inst.components.burnable.onburnt(inst)
	end
end

local function getstatus(inst, viewer)
    local beaconcmp = inst.components.boatmagnetbeacon
    if beaconcmp and beaconcmp:PairedMagnet() ~= nil then
        return "ACTIVATED"
    else
        return "GENERIC"
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("boat_magnet_beacon")
    inst.AnimState:SetBuild("boat_magnet_beacon")
	inst.AnimState:SetFinalOffset(1)

    inst:AddTag("boatmagnetbeacon")
    inst:AddTag("structure")

	inst:SetPhysicsRadiusOverride(0.25)

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("inventoryitem")

    inst:AddComponent("boatmagnetbeacon")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(on_hammered)

    MakeSmallBurnable(inst)

    MakeSmallPropagator(inst)

    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:SetStateGraph("SGboatmagnetbeacon")

	inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("boat_magnet_beacon", fn, assets, prefabs)
