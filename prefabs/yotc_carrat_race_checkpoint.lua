require "prefabutil"
local carratrace_common = require("prefabs/yotc_carrat_race_common")

local assets =
{
    Asset("ANIM", "anim/yotc_carrat_race_checkpoint.zip"),
    Asset("ANIM", "anim/yotc_carrat_race_checkpoint_colour_swaps.zip"),

	Asset("SCRIPT", "scripts/prefabs/yotc_carrat_race_common.lua"),
	Asset("ANIM", "anim/winona_battery_placement.zip"),
	Asset("ANIM", "anim/winona_spotlight_placement.zip"),

    --yotc_carrat_race_checkpoint
}

local prefabs =
{
}

local DEFAULT_LIGHT_COLOR = "red"

local function ToggleLights(inst, turn_on, pushanim, setcolor)
	local anim = turn_on and "idle_on" or "idle_off"
	inst.is_on = turn_on
	inst.Light:Enable(turn_on)

	if pushanim then
		inst.AnimState:PushAnimation(anim, true)
	else
		inst.AnimState:PlayAnimation(anim, true)
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("yotc_2020/gym/checkpoint/place")
	ToggleLights(inst, false, true)
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
	if not inst:HasTag("burnt") and not inst.AnimState:IsCurrentAnimation("place") and not inst._active then
		inst.AnimState:PlayAnimation(inst.is_on and "hit_on" or "hit")
		ToggleLights(inst, inst.is_on, true)
	end
end

local function OnRacerAtCheckpoint(inst, data)
	-- print (data.racer)
	-- print (data.racer._color)
	local racer = data.racer
	if racer and not inst.taken then
		inst.AnimState:PlayAnimation("hit_on")
        inst.SoundEmitter:PlaySound("yotc_2020/gym/checkpoint/active")
		ToggleLights(inst, true, true)

		if racer._color then
			inst.AnimState:OverrideSymbol("lantern", "yotc_carrat_race_checkpoint_colour_swaps", racer._color .. "_lantern")
            inst.AnimState:OverrideSymbol("light", "yotc_carrat_race_checkpoint_colour_swaps", racer._color .. "_light")

            inst.Light:SetColour(carratrace_common.GetLightColor(racer._color):Get())
        else
            inst.AnimState:ClearOverrideSymbol("lantern")
            inst.AnimState:ClearOverrideSymbol("light")

            inst.Light:SetColour(carratrace_common.GetLightColor(DEFAULT_LIGHT_COLOR):Get())
        end

		inst.taken = true
	end
end

local function ResetLights(inst)
	inst.AnimState:ClearOverrideSymbol("lantern")
	inst.AnimState:ClearOverrideSymbol("light")
	inst.AnimState:PlayAnimation("hit")
	inst.taken = false
	ToggleLights(inst, false, true)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    inst.MiniMapEntity:SetIcon("yotc_carrat_race_checkpoint.png")

    inst:AddTag("structure")
    inst:AddTag("yotc_racecheckpoint")

    inst.AnimState:SetBank("yotc_carrat_race_checkpoint")
    inst.AnimState:SetBuild("yotc_carrat_race_checkpoint")

    inst.AnimState:PlayAnimation("idle_off", true)

    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(0.8)
    inst.Light:SetRadius(1.5)
    inst.Light:SetColour(200/255, 100/255, 170/255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

	carratrace_common.AddDeployHelper(inst, {"yotc_carrat_race_deploy_start", "yotc_carrat_race_deploy_checkpoint", "yotc_carrat_race_deploy_finish"})

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnWorkCallback(onhit)
    inst.components.workable:SetOnFinishCallback(onhammered)

    MakeHauntableWork(inst)
    inst:AddComponent("inspectable")

    MakeMediumBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("yotc_racer_at_checkpoint", OnRacerAtCheckpoint)
    inst:ListenForEvent("yotc_race_over", ResetLights)


    inst.is_on = false
    inst.taken = false

    return inst
end


return Prefab("yotc_carrat_race_checkpoint", fn, assets, prefabs ),
       MakeDeployableKitItem("yotc_carrat_race_checkpoint_item", "yotc_carrat_race_checkpoint", "yotc_carrat_racekit_checkpoint", "yotc_carrat_racekit_checkpoint", "idle", {Asset("ANIM", "anim/yotc_carrat_racekit_checkpoint.zip")}, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.LARGE_FUEL}, carratrace_common.deployable_data),
		MakePlacer("yotc_carrat_race_checkpoint_item_placer", "yotc_carrat_race_checkpoint", "yotc_carrat_race_checkpoint", "idle_off", nil, nil, nil, nil, nil, nil,
		function(inst)
			return carratrace_common.PlacerPostInit_AddPlacerRing(inst, "yotc_carrat_race_deploy_checkpoint")
		end)
