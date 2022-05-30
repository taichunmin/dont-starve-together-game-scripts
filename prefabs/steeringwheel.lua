local assets =
{
    Asset("ANIM", "anim/boat_wheel.zip"),
}

local item_assets =
{
    Asset("ANIM", "anim/seafarer_wheel.zip"),
    Asset("INV_IMAGE", "steeringwheel_item")
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boat_wheel")
    inst.AnimState:SetBuild("boat_wheel")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetFinalOffset(1)

    inst:AddTag("structure")

	inst:SetPhysicsRadiusOverride(0.25)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("steeringwheel")
	inst.components.steeringwheel:SetOnStartSteeringFn(on_start_steering)
	inst.components.steeringwheel:SetOnStopSteeringFn(on_stop_steering)

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

	inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function ondeploy(inst, pt, deployer)
    local wheel = SpawnPrefab("steeringwheel")
    if wheel ~= nil then
        wheel.Transform:SetPosition(pt:Get())
        wheel.SoundEmitter:PlaySound("turnoftides/common/together/boat/steering_wheel/place")
        wheel.AnimState:PlayAnimation("place")
        wheel.AnimState:PushAnimation("idle")

        inst:Remove()
    end
end

return Prefab("steeringwheel", fn, assets, prefabs),
       MakeDeployableKitItem("steeringwheel_item", "steeringwheel", "seafarer_wheel", "seafarer_wheel", "idle", item_assets, {size = "med", scale = 0.77}, {"boat_accessory"}, {fuelvalue = TUNING.LARGE_FUEL}),
       MakePlacer("steeringwheel_item_placer", "boat_wheel", "boat_wheel", "idle")
