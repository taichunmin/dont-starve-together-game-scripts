local assets =
{
    Asset("ANIM", "anim/boat_anchor.zip"),
}

local yotd_assets =
{
    Asset("ANIM", "anim/yotd_anchor.zip"),
}

local item_assets =
{
    Asset("ANIM", "anim/seafarer_anchor.zip"),
    Asset("INV_IMAGE", "anchor_item")
}

local prefabs =
{
    "collapse_small",
	"anchor_item", -- deprecated but kept for existing worlds and mods
}

local function on_hammered(inst, hammerer)
    inst.components.lootdropper:DropLoot()

    local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial("wood")

	if inst.components.anchor ~= nil then
		inst.components.anchor:SetIsAnchorLowered(false)
	end

	local boat = inst:GetCurrentPlatform()
	if boat ~= nil then
		boat:PushEvent("spawnnewboatleak", { pt = inst:GetPosition(), leak_size = "med_leak", playsoundfx = true })
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

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/place")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
end

local function onanchorlowered(inst)
	local boat = inst.components.anchor ~= nil and inst.components.anchor.boat or nil
	if boat ~= nil then
		ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, 0.3, 0.03, 0.12, boat)
	end
	inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/ocean_hit")
end

local function initialize(inst)
    local px, py, pz = inst.Transform:GetWorldPosition()
    if TheWorld.Map:IsVisualGroundAtPoint(px, py, pz) then
        inst.AnimState:Hide("fx")
    end
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

local function common_fn(build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --match kit item

    inst.AnimState:SetBank("boat_anchor")
    inst.AnimState:SetBuild(build or "boat_anchor")

    inst:AddTag("structure")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumBurnable(inst, nil, nil, true)
	inst:ListenForEvent("onburnt", onburnt)
	MakeMediumPropagator(inst)

	inst:AddComponent("anchor")

	local boatdrag = inst:AddComponent("boatdrag")
	boatdrag.drag = TUNING.BOAT.ANCHOR.BASIC.ANCHOR_DRAG
	boatdrag.max_velocity_mod = TUNING.BOAT.ANCHOR.BASIC.MAX_VELOCITY_MOD
	boatdrag.sailforcemodifier = TUNING.BOAT.ANCHOR.BASIC.SAILFORCEDRAG

    inst:AddComponent("inspectable")

    local hauntable = inst:AddComponent("hauntable")
    hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:SetStateGraph("SGanchor")

    -- The loot that this drops is generated from the uncraftable recipe; see recipes.lua for the items.
    inst:AddComponent("lootdropper")

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(3)
    workable:SetOnFinishCallback(on_hammered)
    workable:SetOnWorkCallback(onhit)

	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("anchor_lowered", onanchorlowered)

    inst:DoTaskInTime(0, initialize)

	inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function fn()
    return common_fn()
end

local function yotd_fn()
    return common_fn("yotd_anchor")
end

return Prefab("anchor", fn, assets, prefabs),
       MakeDeployableKitItem("anchor_item", "anchor", "seafarer_anchor", "seafarer_anchor", "idle", item_assets, nil, {"boat_accessory"}, {fuelvalue = TUNING.LARGE_FUEL}),
       MakePlacer("anchor_item_placer", "boat_anchor", "boat_anchor", "idle"),

       Prefab("yotd_anchor", yotd_fn, yotd_assets, prefabs),
       MakeDeployableKitItem(
            "yotd_anchor_item", "yotd_anchor",
            "seafarer_anchor", "yotd_anchor", "idle",
            item_assets, nil, {"boat_accessory"}, {fuelvalue = TUNING.LARGE_FUEL}),
       MakePlacer("yotd_anchor_item_placer", "boat_anchor", "yotd_anchor", "idle")
