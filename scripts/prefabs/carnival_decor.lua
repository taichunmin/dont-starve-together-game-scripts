
local decor_defs =
{
	carnivaldecor_plant = {
		bank = "carnivaldecor_plant", build = "carnivaldecor_plant", 
		sound_place = "summerevent/decor/place",
		num_anims = 3,
		physics_radius = 0.25,
	},

	carnivaldecor_banner = {
		bank = "carnivaldecor_banner", build = "carnivaldecor_banner",
		sound_place = "summerevent/decor/place",
		num_anims = 3,
		physics_radius = 0.25,
	},
}

local function onhammered(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function onbuilt(inst, data)
    inst.AnimState:PlayAnimation("place_"..inst.shape)
    inst.AnimState:PushAnimation("idle_"..inst.shape, true)
    inst.SoundEmitter:PlaySound(inst.data.sound_place)
end

local function onsave(inst, data)
    data.shape = inst.shape
end

local function onload(inst, data)
	if data ~= nil and data.shape ~= nil and data.shape ~= inst.shape then
		inst.shape = data.shape
	    inst.AnimState:PlayAnimation("idle_"..tostring(inst.shape), true)
	end
end

local function common_fn(data)
    local inst = CreateEntity()

	local carnival_active = IsSpecialEventActive(SPECIAL_EVENTS.CARNIVAL)

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --match kit item
	if data.physics_radius then
		MakeObstaclePhysics(inst, data.physics_radius)
	end

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build)
    inst.AnimState:PlayAnimation("idle_1", true)

	inst:AddTag("carnivaldecor")
    inst:AddTag("structure")

	if data.common_postinit then
		data.common_postinit(inst, data)
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.data = data

	inst.shape = math.random(data.num_anims)
	if inst.shape ~= 1 then
	    inst.AnimState:PlayAnimation("idle_"..tostring(inst.shape), true)
	end

    inst:AddComponent("inspectable")
	inst:AddComponent("lootdropper")
	
	inst:AddComponent("carnivaldecor")
	inst.components.carnivaldecor.value = 24

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onhammered)

	MakeMediumBurnable(inst)
	MakeMediumPropagator(inst)

	inst.OnSave = onsave
	inst.OnLoad = onload

    inst:ListenForEvent("onbuilt", onbuilt)

	if data.master_postinit then
		data.master_postinit(inst)
	end

    return inst
end

local function make_decor(prefabname, data)
	local function fn()
		return common_fn(data)
	end

	local assets =
	{
		Asset("ANIM", "anim/"..data.bank..".zip"),
		Asset("ANIM", "anim/"..data.build..".zip"),
	}

	return Prefab(prefabname, fn, assets, prefabs)
end

local function placer_postinit_fn(inst)
	inst.deployhelper_key = "carnival_plaza_decor"
end

local objects = {}
for prefabname, data in pairs(decor_defs) do
    table.insert(objects, make_decor(prefabname, data))
	table.insert(objects, MakeDeployableKitItem(prefabname.."_kit", prefabname, data.bank, data.build, "kit_item", nil, {size = "small", scale = 1.1}, nil, {fuelvalue = TUNING.SMALL_FUEL}, nil, TUNING.STACK_SIZE_LARGEITEM))
	table.insert(objects, MakePlacer(prefabname.."_kit_placer", data.bank, data.build, "kit_item", nil, nil, nil, nil, nil, nil, placer_postinit_fn))
end

return unpack(objects)
