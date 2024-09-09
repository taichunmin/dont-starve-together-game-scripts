local assets =
{
    Asset("ANIM", "anim/boat_wheel.zip"),
}

local item_assets =
{
    Asset("ANIM", "anim/seafarer_wheel.zip"),
    Asset("INV_IMAGE", "steeringwheel_item"),

    Asset("ANIM", "anim/yotd_steeringwheel.zip"),
}

local prefabs =
{
    "collapse_small",
	"steeringwheel_item", -- deprecated but kept for existing worlds and mods
}

local function on_start_steering(inst, sailor)
	inst.AnimState:HideSymbol("boat_wheel_round")
	inst.AnimState:HideSymbol("boat_wheel_stick")

    if inst.skinname ~= nil then
        local skin_build = GetBuildForItem(inst.skinname)
        sailor.AnimState:OverrideItemSkinSymbol( "boat_wheel_round", skin_build, "boat_wheel_round", inst.GUID, "player_boat")
        sailor.AnimState:OverrideItemSkinSymbol( "boat_wheel_stick", skin_build, "boat_wheel_stick", inst.GUID, "player_boat")
    elseif inst._steeringwheel_build_override then
        -- NOTES(JBK): Hack for "skinned" base steeringwheels.
        sailor.AnimState:OverrideSymbol("boat_wheel_round", inst._steeringwheel_build_override, "boat_wheel_round")
        sailor.AnimState:OverrideSymbol("boat_wheel_stick", inst._steeringwheel_build_override, "boat_wheel_stick")
    else
        sailor.AnimState:AddOverrideBuild("player_boat")
    end
end

local function on_stop_steering(inst, sailor)
	inst.AnimState:ShowSymbol("boat_wheel_round")
	inst.AnimState:ShowSymbol("boat_wheel_stick")

    if sailor ~= nil then
        sailor.AnimState:ClearOverrideSymbol("boat_wheel_round")
        sailor.AnimState:ClearOverrideSymbol("boat_wheel_stick")
    end
end

local function on_hammered(inst, hammerer)
    inst.components.lootdropper:DropLoot()

    local collapse_fx = SpawnPrefab("collapse_small")
    collapse_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    collapse_fx:SetMaterial("wood")

    if inst.components.steeringwheel ~= nil and inst.components.steeringwheel.sailor ~= nil then
        inst.components.steeringwheel:StopSteering()
    end

    inst:Remove()
end

local function onignite(inst)
	DefaultBurnFn(inst)

	if inst.components.steeringwheel.sailor ~= nil then
		local sailor = inst.components.steeringwheel.sailor
		inst.components.steeringwheel:StopSteering()

		sailor.components.steeringwheeluser:SetSteeringWheel(nil)
		sailor:PushEvent("stop_steering_boat")
	end
end

local function onburnt(inst)
	DefaultBurntStructureFn(inst)

	inst:RemoveComponent("steeringwheel")
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/steering_wheel/place")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
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

local function common_fn(build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boat_wheel")
    inst.AnimState:SetBuild(build or "boat_wheel")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetFinalOffset(1)

    inst:AddTag("structure")

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.MEDIUM] / 2) --match kit item
	inst:SetPhysicsRadiusOverride(0.25)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._steeringwheel_build_override = build

    inst:AddComponent("inspectable")

    local steeringwheel = inst:AddComponent("steeringwheel")
	steeringwheel:SetOnStartSteeringFn(on_start_steering)
	steeringwheel:SetOnStopSteeringFn(on_stop_steering)

    inst:AddComponent("lootdropper")

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(3)
    workable:SetOnFinishCallback(on_hammered)

    local burnable = MakeSmallBurnable(inst, nil, nil, true)
    burnable:SetOnIgniteFn(onignite)
    burnable:SetOnBurntFn(onburnt)

    MakeSmallPropagator(inst)

    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function fn()
    return common_fn()
end

local function yotd_fn()
    return common_fn("yotd_steeringwheel")
end

return Prefab("steeringwheel", fn, assets, prefabs),
        MakeDeployableKitItem(
            "steeringwheel_item", "steeringwheel",
            "seafarer_wheel", "seafarer_wheel", "idle",
            item_assets, {size = "med", scale = 0.77}, {"boat_accessory"}, {fuelvalue = TUNING.LARGE_FUEL}, { deployspacing = DEPLOYSPACING.MEDIUM }),
        MakePlacer("steeringwheel_item_placer", "boat_wheel", "boat_wheel", "idle"),

        Prefab("yotd_steeringwheel", yotd_fn, assets, prefabs),
        MakeDeployableKitItem(
            "yotd_steeringwheel_item", "yotd_steeringwheel",
            "seafarer_wheel", "yotd_steeringwheel", "idle",
            item_assets, {size = "med", scale = 0.77}, {"boat_accessory"}, {fuelvalue = TUNING.LARGE_FUEL}, { deployspacing = DEPLOYSPACING.MEDIUM }),
        MakePlacer("yotd_steeringwheel_item_placer", "boat_wheel", "yotd_steeringwheel", "idle")