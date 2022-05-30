local carratrace_common = require("prefabs/yotc_carrat_race_common")

local assets =
{
	Asset("ANIM", "anim/yotc_carrat_race_finish.zip"),
	Asset("ANIM", "anim/yotc_carrat_race_finish_colour_swap.zip"),

	Asset("SCRIPT", "scripts/prefabs/yotc_carrat_race_common.lua"),
	Asset("ANIM", "anim/winona_battery_placement.zip"),
	Asset("ANIM", "anim/winona_spotlight_placement.zip"),
}

local prefabs =
{
	"small_puff",
	"yotc_carrat_rug",
	"yotc_carrat_race_finish_light",
}

local sounds =
{
	onbuilt = "yotc_2020/gym/finish/place",
	finishrace = "yotc_2020/gym/finish/active_LP",
}

local WIN_ANIM_MIN_TIME = 3.5

local lightcolors = carratrace_common.lightcolors

local DEFAULT_LIGHT_COLOR = "green"

local LIGHT_RADIUS = 3
local LIGHT_INTENSITY = .88
local LIGHT_FALLOFF = 0.42

--[[local function OnUpdateFlicker(inst, starttime) -- Not using flicker for now
    local time = starttime ~= nil and (GetTime() - starttime) * 15 or 0
    local flicker = (math.sin(time) + math.sin(time + 2) + math.sin(time + 0.7777)) * .5 -- range = [-1 , 1]
    flicker = (1 + flicker) * .5 -- range = 0:1
    inst.Light:SetRadius(LIGHT_RADIUS + .1 * flicker)
    flicker = flicker * 2 / 255
	inst.Light:SetColour(LIGHT_COLOUR.x + flicker, LIGHT_COLOUR.y + flicker, LIGHT_COLOUR.z + flicker)
end]]

local function RemoveLight(inst)
	if inst._light ~= nil and inst._light:IsValid() then
		inst._light:Remove()
	end
	inst._light = nil
end

local function MakeLight(inst)
	RemoveLight(inst)
	inst._light = SpawnPrefab("yotc_carrat_race_finish_light")
	inst._light.Transform:SetPosition(0, 0, 0)
	inst._light.entity:SetParent(inst.entity)
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
	inst.SoundEmitter:PlaySound(sounds.onbuilt)

	inst._rug:PushEvent("onbuilt")
end

local function OnInactive(inst)
	inst._active = false
	inst._winner = nil

	RemoveLight(inst)

	inst.SoundEmitter:KillSound("finish_lp")
end

local function Spin(inst)
	if inst._active then
		inst.AnimState:PlayAnimation("active_loop", true)
	else
		inst.AnimState:PlayAnimation("active_pst")
		inst.AnimState:PushAnimation("idle", false)

		inst:RemoveEventCallback("animover", Spin)
	end
end

local function OnFinishRace(inst, data)
	if not inst._active then
		inst._active = true

		MakeLight(inst)
		local currentlightcol = nil

		if data ~= nil and data.racer ~= nil then
			local color = data.racer._color

			if color ~= nil then
				currentlightcol = color

				inst.AnimState:OverrideSymbol("fx_glow", "yotc_carrat_race_finish_colour_swap", color.."_fx_glow")
				inst.AnimState:OverrideSymbol("fx_spark_specks", "yotc_carrat_race_finish_colour_swap", color.."_fx_spark_specks")
			else
				inst.AnimState:ClearOverrideSymbol("fx_glow")
				inst.AnimState:ClearOverrideSymbol("fx_spark_specks")
			end

			local trainer = (data.racer.components.entitytracker and data.racer.components.entitytracker:GetEntity("yotc_trainer")) or nil
			if trainer ~= nil then
				inst._winner = { name = trainer.name, userid = trainer.userid }
			end
		end
		inst._light.Light:SetColour(carratrace_common.GetLightColor(currentlightcol or DEFAULT_LIGHT_COLOR):Get())

		inst.AnimState:PlayAnimation("active_pre")
		inst.AnimState:PushAnimation("active_loop", true)

		inst:ListenForEvent("animover", Spin)

		inst.SoundEmitter:PlaySound(sounds.finishrace, "finish_lp")
	end
end

local function OnRaceOver(inst)
	inst:DoTaskInTime(WIN_ANIM_MIN_TIME, function() OnInactive(inst) end)
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function OnHit(inst)
	if not inst:HasTag("burnt") and not inst.AnimState:IsCurrentAnimation("place") and not inst._active then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle", false)
	end
end

local function onburnt(inst)
	DefaultBurntStructureFn(inst)

	RemoveLight(inst)

	inst.AnimState:PlayAnimation("burnt")
	inst.SoundEmitter:KillSound("finish_lp")

	inst._rug:PushEvent("onburntup")
end

local function MakeRug(inst)
	local rug = SpawnPrefab("yotc_carrat_rug")
	rug.entity:SetParent(inst.entity)

	inst._rug = rug
end

local function getdesc(inst, viewer)
	if inst:HasTag("burnt") then
		return GetDescription(viewer, inst, "BURNT")
	elseif inst._active and inst._winner ~= nil then
		if inst._winner.userid ~= nil and inst._winner.userid == viewer.userid then
			return GetDescription(viewer, inst, "I_WON")
		elseif inst._winner.name ~= nil then
			return subfmt(GetDescription(viewer, inst, "SOMEONE_ELSE_WON"), { winner = inst._winner.name })
		end
	end

	return GetDescription(viewer, inst) or nil
end

local function OnSave(inst, data)
	if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
		data.burnt = true
	end
	if inst.prize then
		data.prize = inst.prize
	end
end

local function OnLoad(inst, data)
	if data ~= nil then
		if data.burnt then
			inst.components.burnable.onburnt(inst)
		end
		if data.prize then
			inst.prize = data.prize
		end
	end
end

local function light_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetIntensity(LIGHT_INTENSITY)
    --inst.Light:SetColour(lightcolors.NEUTRAL.x, lightcolors.NEUTRAL.y, lightcolors.NEUTRAL.z)
    inst.Light:SetFalloff(LIGHT_FALLOFF)
    inst.Light:SetRadius(LIGHT_RADIUS)
    --inst.Light:EnableClientModulation(true)

    --inst:DoPeriodicTask(.1, OnUpdateFlicker, nil, GetTime())
    --OnUpdateFlicker(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, .4)

	inst.MiniMapEntity:SetIcon("yotc_carrat_race_finish.png")

    inst.AnimState:SetBank("yotc_carrat_race_finish")
    inst.AnimState:SetBuild("yotc_carrat_race_finish")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("structure")
	inst:AddTag("yotc_racecheckpoint")
	inst:AddTag("yotc_racefinishline")

	carratrace_common.AddDeployHelper(inst, {"yotc_carrat_race_deploy_start", "yotc_carrat_race_deploy_checkpoint"})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	--inst._rug = nil
	--inst._light = nil
	--inst._winner = nil
	inst._active = false

	inst:AddComponent("inspectable")
	inst.components.inspectable.getspecialdescription = getdesc

	inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(OnHit)

    MakeMediumBurnable(inst, nil, nil, true)
	inst.components.burnable:SetOnBurntFn(onburnt)

    MakeSmallPropagator(inst)

	MakeHauntableWork(inst)

	MakeRug(inst)

	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("yotc_racer_at_checkpoint", OnFinishRace)
	inst:ListenForEvent("yotc_race_over", OnRaceOver)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("yotc_carrat_race_finish", fn, assets, prefabs),
    MakeDeployableKitItem("yotc_carrat_race_finish_item", "yotc_carrat_race_finish", "yotc_carrat_racekit_finish", "yotc_carrat_racekit_finish", "idle", {Asset("ANIM", "anim/yotc_carrat_racekit_finish.zip")}, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.LARGE_FUEL}, carratrace_common.deployable_data),
	MakePlacer("yotc_carrat_race_finish_item_placer", "yotc_carrat_race_finish", "yotc_carrat_race_finish", "idle", nil, nil, nil, nil, nil, nil,
		function(inst)
			return carratrace_common.PlacerPostInit_AddCarpetAndPlacerRing(inst, "yotc_carrat_race_deploy_finish")
		end),
	Prefab("yotc_carrat_race_finish_light", light_fn)
