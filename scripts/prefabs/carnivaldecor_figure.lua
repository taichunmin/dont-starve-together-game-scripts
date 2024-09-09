
local assets =
{
	Asset("ANIM", "anim/carnivaldecor_statue.zip"),
}

local assets_s2 =
{
	Asset("ANIM", "anim/carnivaldecor_statue_season2.zip"),
}

local prefabs =
{
	"carnival_unwrap_fx",
}

local rarity_weight_map =
{
	rare		= 1,
	uncommon	= 2.5,
	common		= 3,
}

local rarity_decor_vale_map =
{
	rare		= 20,
	uncommon	= 16,
	common		= 12,
}

local shape_rarity = {
{
	-- season 1
	s1 = "rare",
	s2 = "uncommon",
	s3 = "uncommon",
	s4 = "common",
	s5 = "common",
	s6 = "common",
	s7 = "uncommon",
	s8 = "common",
	s9 = "common",
	s10 = "common",
	s11 = "common",
	s12 = "common",
},
{
	-- season 2
	s1 = "common",
	s2 = "common",
	s3 = "uncommon",
	s4 = "uncommon",
	s5 = "common",
	s6 = "common",
	s7 = "common",
	s8 = "uncommon",
	s9 = "common",
	s10 = "uncommon",
	s11 = "common",
	s12 = "rare",
},
}

local shape_weights = {{}, {}}
for season_num, season_data in pairs(shape_rarity) do
	for shape, rarity in pairs(season_data) do
		shape_weights[season_num][shape] = rarity_weight_map[rarity]
	end
end
--[[
local total = 0
for _, v in pairs(shape_weights) do
	total = total + v
end
print("total", total)
for s, v in pairs(shape_weights) do
	print(" shape", s, v/total)
end
]]

local function onhammered(inst, worker)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function SetShape(inst, shape)
	shape = shape or weighted_random_choice(shape_weights[inst.carnival_season])

	if shape == inst.shape then
		return
	end

	if inst.shape ~= nil then
		inst:RemoveTag("blindbox_"..tostring(shape_rarity[inst.carnival_season][inst.shape]))
	end

	inst.shape = shape
	inst.components.carnivaldecor.value = rarity_decor_vale_map[ shape_rarity[inst.carnival_season][shape] ]
	inst:AddTag("blindbox_"..tostring(shape_rarity[inst.carnival_season][shape]))

    inst.AnimState:PlayAnimation(tostring(shape), true)
end

local function onbuilt(inst, data)
	if data ~= nil and data.deployable ~= nil then
		if data.deployable.shape ~= nil then
			SetShape(inst, data.deployable.shape)
		end
	end

	SpawnPrefab("carnival_unwrap_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
    
end

local function GetStatus(inst)
	return shape_rarity[inst.shape] == "rare" and "RARE"
			or shape_rarity[inst.shape] == "uncommon" and "UNCOMMON"
			or nil
end

local function GetDisplayName(inst)
	return inst:HasTag("blindbox_rare") and STRINGS.NAMES.CARNIVALDECOR_FIGURE_RARE
		or inst:HasTag("blindbox_uncommon") and STRINGS.NAMES.CARNIVALDECOR_FIGURE_UNCOMMON
		or STRINGS.NAMES.CARNIVALDECOR_FIGURE_COMMON
end

local function onreturntokit(inst, data)
	if data ~= nil and data.loot ~= nil and data.loot:IsValid() then
		data.loot.shape = inst.shape
	end
end

local function onsave(inst, data)
    data.shape = inst.shape
end

local function onload(inst, data)
	if data ~= nil and data.shape ~= nil then
		SetShape(inst, data.shape)
	end
end

local function fn(data, carnival_season, bank)
    local inst = CreateEntity()

	local carnival_active = IsSpecialEventActive(SPECIAL_EVENTS.CARNIVAL)

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.LESS] / 2) --match kit item
	if data.physics_radius then
		MakeObstaclePhysics(inst, data.physics_radius)
	end

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(bank)
    inst.AnimState:PlayAnimation("s1")

	inst:AddTag("carnivaldecor")
    inst:AddTag("structure")

	inst.displaynamefn = GetDisplayName
	inst:SetPrefabNameOverride("carnivaldecor_figure")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.carnival_season = carnival_season

	inst:AddComponent("carnivaldecor")

	SetShape(inst)

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("lootdropper")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onhammered)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

	inst.OnSave = onsave
	inst.OnLoad = onload

    inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("loot_prefab_spawned", onreturntokit)

	if data.master_postinit then
		data.master_postinit(inst)
	end

    return inst
end

local function fn_season1(data)
	return fn(data, 1, "carnivaldecor_statue")
end

local function fn_season2(data)
	return fn(data, 2, "carnivaldecor_statue_season2")
end

local deployable_data = 
{
	deployspacing = DEPLOYSPACING.LESS,

	OnSave = function(inst, data)
		data.shape = inst.shape
	end,

	OnLoad = function(inst, data)
		inst.shape = data ~= nil and data.shape or nil
	end,
}

local function placer_postinit_fn(inst)
	inst.deployhelper_key = "carnival_plaza_decor"
end

return Prefab("carnivaldecor_figure", fn_season1, assets, prefabs),
	MakeDeployableKitItem("carnivaldecor_figure_kit", "carnivaldecor_figure", "carnivaldecor_statue", "carnivaldecor_statue", "kit_item", nil, {size = "small", scale = 1.1}, nil, {fuelvalue = TUNING.SMALL_FUEL}, deployable_data),
	MakePlacer("carnivaldecor_figure_kit_placer", "carnivaldecor_statue", "carnivaldecor_statue", "kit_item", nil, nil, nil, nil, nil, nil, placer_postinit_fn),
	Prefab("carnivaldecor_figure_season2", fn_season2, assets_s2, prefabs),
	MakeDeployableKitItem("carnivaldecor_figure_kit_season2", "carnivaldecor_figure_season2", "carnivaldecor_statue_season2", "carnivaldecor_statue_season2", "kit_item", nil, {size = "small", scale = 1.1}, nil, {fuelvalue = TUNING.SMALL_FUEL}, deployable_data),
	MakePlacer("carnivaldecor_figure_kit_season2_placer", "carnivaldecor_statue_season2", "carnivaldecor_statue_season2", "kit_item", nil, nil, nil, nil, nil, nil, placer_postinit_fn)
