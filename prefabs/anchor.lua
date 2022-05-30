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

	inst:AddComponent("boatdrag")
	inst.components.boatdrag.drag = TUNING.BOAT.ANCHOR.BASIC.ANCHOR_DRAG
	inst.components.boatdrag.max_velocity_mod = TUNING.BOAT.ANCHOR.BASIC.MAX_VELOCITY_MOD
	inst.components.boatdrag.sailforcemodifier = TUNING.BOAT.ANCHOR.BASIC.SAILFORCEDRAG

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

	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("anchor_lowered", onanchorlowered)

    inst:DoTaskInTime(0,function()
        local pt = Vector3(inst.Transform:GetWorldPosition())
        if TheWorld.Map:IsVisualGroundAtPoint(pt.x,pt.y,pt.z) then
            inst.AnimState:Hide("fx")
        end
    end)

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

return Prefab("anchor", fn, assets, prefabs),
       MakeDeployableKitItem("anchor_item", "anchor", "seafarer_anchor", "seafarer_anchor", "idle", item_assets, nil, {"boat_accessory"}, {fuelvalue = TUNING.LARGE_FUEL}),
       MakePlacer("anchor_item_placer", "boat_anchor", "boat_anchor", "idle")
