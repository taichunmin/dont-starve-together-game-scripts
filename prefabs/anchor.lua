local assets =
{
    Asset("ANIM", "anim/boat_anchor.zip"),
}

local item_assets =
{
    Asset("ANIM", "anim/seafarer_anchor.zip"),
    Asset("INV_IMAGE", "anchor_item")
}

local prefabs =
{
    "collapse_small",
}

local item_prefabs =
{
    "anchor",
}

local function on_hammered(inst, hammerer)
    inst.components.lootdropper:DropLoot()

    local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial("wood")

	if inst.components.anchor ~= nil then
		inst.components.anchor:SetIsAnchorLowered(false)
	end

    inst:Remove()
end

local function onhit(inst)
    inst:PushEvent("workinghit")
end

local function onburnt(inst)
    inst.SoundEmitter:KillSound("mooring")
    inst.sg:Stop()
end

local function onsave(inst, data)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	end
end

local function onload(inst, data)
	if data ~= nil and data.burnt then
		inst.components.burnable.onburnt(inst)
		inst:PushEvent("onburnt")
    end
end

local function fn()
    
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boat_anchor")
    inst.AnimState:SetBuild("boat_anchor")

    inst:AddTag("structure")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumBurnable(inst, nil, nil, true)
	inst:ListenForEvent("onburnt", onburnt)
    MakeMediumPropagator(inst)

    inst:AddComponent("anchor")

    inst:AddComponent("hauntable")
    inst:AddComponent("inspectable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:SetStateGraph("SGanchor")

    -- The loot that this drops is generated from the uncraftable recipe; see recipes.lua for the items.
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(on_hammered)
    inst.components.workable:SetOnWorkCallback(onhit)

	inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function ondeploy(inst, pt, deployer)
    local anchor = SpawnPrefab("anchor")
    if anchor ~= nil then
        anchor.Transform:SetPosition(pt:Get())
        anchor.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/place")
        anchor.AnimState:PlayAnimation("place")
        anchor.AnimState:PushAnimation("idle")

        inst:Remove()
    end
end

local function anchor_itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("boat_accessory")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("seafarer_anchor")
    inst.AnimState:SetBuild("seafarer_anchor")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "anchor"

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("anchor", fn, assets, prefabs),
       Prefab("anchor_item", anchor_itemfn, item_assets, item_prefabs),
       MakePlacer("anchor_item_placer", "boat_anchor", "boat_anchor", "idle")
