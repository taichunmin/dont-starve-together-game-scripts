
local defs =
{
	carnivaldecor_eggride1 = {
		bank = "carnivaldecor_eggride1", build = "carnivaldecor_eggride1",
		physics_radius = 0.25,
		sound_fx = {place = "summerevent/egg_rides/1/place", turnon = "", on = "summerevent/egg_rides/1/LP", turnoff = "summerevent/egg_rides/turn_off"},
	},

	carnivaldecor_eggride2 = {
		bank = "carnivaldecor_eggride2", build = "carnivaldecor_eggride2",
		physics_radius = 0.25,
		sound_fx = {place = "summerevent/egg_rides/2/place", turnon = "", on = "summerevent/egg_rides/2/LP", turnoff = "summerevent/egg_rides/turn_off"},
	},

	carnivaldecor_eggride3 = {
		bank = "carnivaldecor_eggride3", build = "carnivaldecor_eggride3",
		physics_radius = 0.25,
		sound_fx = {place = "summerevent/egg_rides/3/place", turnon = "", on = "summerevent/egg_rides/3/LP", turnoff = "summerevent/egg_rides/turn_off"},
	},
}

local function onhammered(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function TurnOffRide(inst)
	inst.AnimState:PushAnimation("turn_off", false)
	inst.AnimState:PushAnimation("off", false)

	if inst.def.sound_fx ~= nil then
		inst.SoundEmitter:PlaySound(inst.def.sound_fx.turnoff)
		inst.SoundEmitter:KillSound("loop")
	end

	if inst.components.activatable ~= nil then
		inst.components.activatable.inactive = true
	end

	inst.turnofftask = nil
end

local function TurnOnRide(inst, duration)
	if inst.turnofftask ~= nil then
		inst.turnofftask:Cancel()
	else
	    inst.AnimState:PlayAnimation("turn_on")
	    inst.AnimState:PushAnimation("loop")
		if inst.def.sound_fx ~= nil then
			inst.SoundEmitter:PlaySound(inst.def.sound_fx.turnon)
			inst.SoundEmitter:PlaySound(inst.def.sound_fx.on, "loop")
		end
	end
	inst.turnofftask = inst:DoTaskInTime(duration, TurnOffRide)
end

local function OnActivate(inst, doer)
	TurnOnRide(inst, TUNING.CARNIVALDECOR_EGGRIDE_ACTIVATE_TIME)
	return true
end

local function OnAcceptItem(inst, doer)
	TurnOnRide(inst, TUNING.CARNIVALDECOR_EGGRIDE_TOKEN_TIME)
	return true
end

local function AbleToAcceptTest(inst, item, giver)
	if not inst:HasTag("inactive") then
		return false
	end

	if item.prefab == "carnival_gametoken" then
		return true
	end
	return false, "CARNIVALGAME_INVALID_ITEM"
end

local function OnBuilt(inst)
	inst.AnimState:PlayAnimation("place", false)
	inst.AnimState:PushAnimation("off", true)

	if inst.def.sound_fx ~= nil then
		inst.SoundEmitter:PlaySound(inst.def.sound_fx.place)
	end
end

local function common_fn(data)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	if data.physics_radius then
		MakeObstaclePhysics(inst, data.physics_radius)
	end

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build)
    inst.AnimState:PlayAnimation("off")

	inst:AddTag("carnivaldecor")
    inst:AddTag("structure")
    inst:AddTag("cattoyairborne")

	if data.common_postinit then
		data.common_postinit(inst, data)
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.def = data

    inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "carnivaldecor_eggride"

	inst:AddComponent("lootdropper")

	inst:AddComponent("carnivaldecor")
	inst.components.carnivaldecor.value = 36


	inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)
    inst.components.trader.onaccept = OnAcceptItem

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onhammered)

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.quickaction = true

	inst:ListenForEvent("onbuilt", OnBuilt)

	MakeMediumBurnable(inst)
	MakeMediumPropagator(inst)

	if data.master_postinit then
		data.master_postinit(inst)
	end

    return inst
end

local function make_cannon(prefabname, data)
	local assets =
	{
		Asset("ANIM", "anim/"..data.bank..".zip"),
		Asset("ANIM", "anim/"..data.build..".zip"),
	}

	local prefabs = { data.fx }

	local function fn()
		return common_fn(data)
	end

	return Prefab(prefabname, fn, assets, prefabs)
end

local function kit_master_postinit(inst)
	inst.components.inspectable.nameoverride = "carnivaldecor_eggride_kit"
end

local function placer_postinit_fn(inst)
	inst.deployhelper_key = "carnival_plaza_decor"
end

local objects = {}
for prefabname, data in pairs(defs) do
    table.insert(objects, make_cannon(prefabname, data))
	table.insert(objects, MakeDeployableKitItem(prefabname.."_kit", prefabname, data.bank, data.build, "kit_item", nil, {size = "small", scale = 1.1}, nil, {fuelvalue = TUNING.SMALL_FUEL}, {master_postinit = kit_master_postinit}, TUNING.STACK_SIZE_LARGEITEM))
	table.insert(objects, MakePlacer(prefabname.."_kit_placer", data.bank, data.build, "off", nil, nil, nil, nil, nil, nil, placer_postinit_fn))
end

return unpack(objects)
