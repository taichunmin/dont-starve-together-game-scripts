local assets =
{
    Asset("ANIM", "anim/boat_plank.zip"),
    Asset("ANIM", "anim/boat_plank_build.zip"),
}

local item_assets =
{
    Asset("ANIM", "anim/boat_plank.zip"),
    Asset("INV_IMAGE", "anchor_item")
}

local prefabs =
{
    "collapse_small",
}

local item_prefabs =
{

}

local function on_hammered(inst, hammerer)
    inst.components.lootdropper:DropLoot()

    local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial("wood")

    inst.components.anchor:SetIsAnchorLowered(false)

    inst:Remove()
end

local function fn()
    
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    --MakeObstaclePhysics(inst, .2)

    inst:SetStateGraph("SGwalkingplank")

    inst.AnimState:SetBank("plank")
    inst.AnimState:SetBuild("boat_plank_build")  
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER.OCEAN_BOAT)
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    -- from walkingplank component
    inst:AddTag("walkingplank")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("walkingplank")
    inst:AddComponent("hauntable")
    inst:AddComponent("inspectable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    -- The loot that this drops is generated from the uncraftable recipe; see recipes.lua for the items.
    inst:AddComponent("lootdropper")
    --[[
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(on_hammered)
    ]]--

    return inst
end

local function ondeploy(inst, pt, deployer)
    local plank = SpawnPrefab("walkingplank")
    if plank ~= nil then
        plank.Transform:SetPosition(pt:Get())
        plank.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/place")
        plank.AnimState:PlayAnimation("place")
        plank.AnimState:PushAnimation("idle")

        inst:Remove()
    end
end

local function itemfn()
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

return Prefab("walkingplank", fn, assets, prefabs),
       Prefab("walkingplank_item", itemfn, item_assets, item_prefabs),
       MakePlacer("walkingplank_item_placer", "boat_anchor", "boat_anchor", "idle")
