local assets =
{
    Asset("ANIM", "anim/boat_rotator.zip"),
}

local item_assets =
{
    Asset("ANIM", "anim/boat_rotator.zip"),
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

local function onignite(inst)
	DefaultBurnFn(inst)
end

local function onburnt(inst)
	DefaultBurntStructureFn(inst)

	inst:RemoveComponent("boatrotator")
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boat_rotator")
    inst.AnimState:SetBuild("boat_rotator")
	inst.AnimState:SetFinalOffset(1)

    inst:AddTag("structure")

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.LESS] / 2) --match kit item
	inst:SetPhysicsRadiusOverride(0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("boatrotator")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(on_hammered)

    MakeSmallBurnable(inst, nil, nil, true)
	inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnBurntFn(onburnt)


    MakeSmallPropagator(inst)

    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:SetStateGraph("SGboatrotator")

	inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("boat_rotator", fn, assets, prefabs),
       MakeDeployableKitItem("boat_rotator_kit", "boat_rotator", "boat_rotator", "boat_rotator", "kit", item_assets, {size = "med", scale = 0.77}, {"boat_accessory"}, {fuelvalue = TUNING.LARGE_FUEL}, { deployspacing = DEPLOYSPACING.LESS }),
       MakePlacer("boat_rotator_kit_placer", "boat_rotator", "boat_rotator", "idle")
