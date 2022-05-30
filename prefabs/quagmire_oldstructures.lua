
local assets =
{
	Asset("ANIM", "anim/quagmire_victorian_structures.zip"),
	Asset("ANIM", "anim/quagmire_rubble.zip"),
}

local function decorfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("DECOR")
    inst:AddTag("NOCLICK")

    --[[Non-networked entity]]
    inst.persists = false

    inst.AnimState:SetBank("quagmire_rubble")
    inst.AnimState:SetBuild("quagmire_rubble")

    return inst
end

local decore_seed = 123456789;
local function decore_rand()
	decore_seed = (1664525 * decore_seed + 1013904223) % 2147483648
	return decore_seed / 2147483649;
end

local function SpawnDecor(inst, x, z)
	if decore_rand() < 0.8 then
		local rubble = SpawnPrefab("quagmire_old_rubble")
		rubble.entity:SetParent(inst.entity)

		local r = 0.15
		rubble.Transform:SetPosition(x + decore_rand()*r - r*.5, 0, z + decore_rand()*r - r*.5)

		local scale = .8 - (decore_rand() * .2)
		rubble.Transform:SetScale(scale, scale, scale)
		local tint = .8 - (decore_rand() * .1)
		rubble.AnimState:OverrideMultColour(tint, tint, tint, 1)
		rubble.AnimState:PlayAnimation("f"..math.floor(decore_rand() * 8) + 1)
	end
end

local function PopulateDecor(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	decore_seed = math.floor(math.abs(x) * 281 + math.abs(z) * 353)
	local half_cells = 3
	local cell_spacing = .72
	for x = -half_cells+1, half_cells-1 do
		SpawnDecor(inst, x*cell_spacing, -half_cells*cell_spacing)
		SpawnDecor(inst, x*cell_spacing, half_cells*cell_spacing)
	end
	for z = -half_cells, half_cells do
		SpawnDecor(inst, -half_cells*cell_spacing, z*cell_spacing)
		SpawnDecor(inst, half_cells*cell_spacing, z*cell_spacing)
	end
end

local function common_fn(anim, add_decor)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	if anim ~= nil then
		inst.entity:AddAnimState()
	end
	inst.entity:AddNetwork()

	if anim ~= nil then
		inst.AnimState:SetBank("quagmire_victorian_structures")
		inst.AnimState:SetBuild("quagmire_victorian_structures")
		inst.AnimState:PlayAnimation(anim)

		MakeObstaclePhysics(inst, 1)
	else
	    inst:AddTag("NOCLICK")
	end

    if not TheNet:IsDedicated() then
		if add_decor then
			inst:DoTaskInTime(0, PopulateDecor)
		end
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	if anim ~= nil then
		inst:AddComponent("inspectable")
	end

	return inst
end


local function MakeStrcuture(name, anim, add_decor)
	local function fn()
		return common_fn(anim, add_decor)
	end

	return Prefab("quagmire_rubble_"..name, fn, assets, {"quagmire_old_rubble"})
end

return Prefab("quagmire_old_rubble", decorfn, assets),
		MakeStrcuture("carriage", "carriage"),
		MakeStrcuture("empty", nil, true),
		MakeStrcuture("clock", "grandfather_clock", true),
		MakeStrcuture("cathedral", "cathedral", true),
		MakeStrcuture("pubdoor", "pub_door", true),
		--MakeStrcuture("door", "door", true),
		MakeStrcuture("roof", "roof", true),
		MakeStrcuture("clocktower", "clocktower", true),
		MakeStrcuture("house", "house", true),
		MakeStrcuture("chimney", "chimney", true),
		MakeStrcuture("chimney2", "chimney2", true),
		MakeStrcuture("bike", "penny_farthing")

