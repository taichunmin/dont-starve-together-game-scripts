local assets =
{
    Asset("ANIM", "anim/boat_magnet.zip"),
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

local function onburnt(inst)
	DefaultBurntStructureFn(inst)

    local boatmagnet = inst.components.boatmagnet
    if boatmagnet then
        boatmagnet:SetBoat(nil)
        inst:RemoveComponent("boatmagnet")
    end

	inst.sg:GoToState("burnt")
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("monkeyisland/autopilot/magnet_place")
    inst.sg:GoToState("place")
end

-- Boat magnet callbacks
local function onpairedwithbeacon(inst, beacon)
    local state = ((beacon.components.boatmagnetbeacon:IsTurnedOff()
        or inst.components.boatmagnet:IsBeaconOnSameBoat(beacon)) and "idle")
        or "pull_pre"
    inst.sg:GoToState(state)
end

local function onunpairedwithbeacon(inst)
    if not inst.sg:HasStateTag("burnt") then
        inst.sg:GoToState("pull_pst")
    end
end

local function beaconturnedon(inst, beacon)
    inst.sg:GoToState(
        (inst.components.boatmagnet:IsBeaconOnSameBoat(beacon) and "idle")
        or "pull"
    )
end

local function beaconturnedoff(inst)
    inst.sg:GoToState("pull_pst")
end

--
local function onsave(inst, data)
	if inst.components.burnable and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	end
end

local function onload(inst, data)
	if data and data.burnt == true then
        inst.components.burnable.onburnt(inst)
	end
end

local function getstatus(inst, viewer)
    local magnetcmp = inst.components.boatmagnet
    return (magnetcmp ~= nil and magnetcmp:IsActivated() and "ACTIVATED")
        or "GENERIC"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("boat_magnet")
    inst.AnimState:SetBuild("boat_magnet")
	inst.AnimState:SetFinalOffset(1)

    inst:AddTag("boatmagnet")
    inst:AddTag("structure")

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.MEDIUM] / 2) --match kit item
    MakeObstaclePhysics(inst, .2)
	inst:SetPhysicsRadiusOverride(0.25)
    inst.Transform:SetEightFaced()

    inst.scrapbook_specialinfo = "BOATMAGNET"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --
    local inspectable = inst:AddComponent("inspectable")
    inspectable.getstatus = getstatus

    --
    local boatmagnet = inst:AddComponent("boatmagnet")
    boatmagnet.onpairedwithbeaconfn = onpairedwithbeacon
    boatmagnet.onunpairedwithbeaconfn = onunpairedwithbeacon
    boatmagnet.beaconturnedonfn = beaconturnedon
    boatmagnet.beaconturnedofffn = beaconturnedoff

    inst:AddComponent("lootdropper")

    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(3)
    workable:SetOnFinishCallback(on_hammered)

    local burnable = MakeSmallBurnable(inst, nil, nil, true)
    burnable:SetOnBurntFn(onburnt)

    MakeSmallPropagator(inst)

    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:SetStateGraph("SGboatmagnet")

	inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("boat_magnet", fn, assets, prefabs),
       MakeDeployableKitItem("boat_magnet_kit", "boat_magnet", "boat_magnet", "boat_magnet", "kit", assets, {size = "med", scale = 0.77}, {"boat_accessory"}, {fuelvalue = TUNING.LARGE_FUEL}, { deployspacing = DEPLOYSPACING.MEDIUM }),
       MakePlacer("boat_magnet_kit_placer", "boat_magnet", "boat_magnet", "idle")
