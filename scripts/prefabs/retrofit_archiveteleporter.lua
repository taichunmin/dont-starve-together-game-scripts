
local prefabs =
{
	"wormhole",
	"homesign",
}

local STRUCTURE_TAGS = {"structure"}
local ALTAR_TAGS = {"altar"}
local LOCOMOTOR_TAGS = {"locomotor"}

local function can_spawn_here(x, z)
	local min_space = .5
	if TheWorld.Map:IsAboveGroundAtPoint(x, 0, z) and
		TheWorld.Map:IsAboveGroundAtPoint(x + min_space, 0, z) and
		TheWorld.Map:IsAboveGroundAtPoint(x, 0, z + min_space) and
		TheWorld.Map:IsAboveGroundAtPoint(x - min_space, 0, z) and
		TheWorld.Map:IsAboveGroundAtPoint(x, 0, z - min_space) then
		return #TheSim:FindEntities(x, 0, z, min_space) == 0
	end

	return false
end

local function DoRetrofitting(inst, force_pt)
	local w2 = nil
	if force_pt == nil then
		-- find location in blue mush forest for a wormhole to add
		local id_prefx = "BlueForest"
		local topology = TheWorld.topology
		local mush_node_indexies = {}		-- TODO: find all "MoonMushForest" rooms
		for i, id in ipairs(topology.ids) do
			if id:sub(1, #id_prefx) == id_prefx then
				table.insert(mush_node_indexies, i)
			end
		end
		shuffleArray(mush_node_indexies)

		for _, index in ipairs(mush_node_indexies) do
			local area =  topology.nodes[index]
			local points_x, points_z = TheWorld.Map:GetRandomPointsForSite(area.x, area.y, area.poly, 15)
			for i = 1, #points_x do
				if can_spawn_here(points_x[i], points_z[i]) then
					w2 = SpawnPrefab("wormhole")
					w2.Transform:SetPosition(points_x[i], 0, points_z[i])
					break
				end
			end
			if w2 ~= nil then
				break
			end
		end

	elseif force_pt.x ~= nil and force_pt.y ~= nil and force_pt.z ~= nil then
		w2 = SpawnPrefab("wormhole")
		w2.Transform:SetPosition(force_pt:Get())
	end

	if w2 ~= nil then
		local x, y, z = inst.Transform:GetWorldPosition()

		-- replace this marker with a wormhole
		local w1 = SpawnPrefab("wormhole")
		w1.Transform:SetPosition(x, y, z)

		w1.components.teleporter:Target(w2)
		w2.components.teleporter:Target(w1)

		-- this wormhole is being added because we cannot reliably retrofit the land masses being connected to the mainland, no need to have a sanity cost for using it
		w1.disable_sanity_drain = true
		w2.disable_sanity_drain = true

		inst:Remove()

		return true
	end

	return false
end

-- c_spawn("retrofit_archiveteleporter"):DoRetrofitting()

local function fn()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:AddTransform()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.DoRetrofitting = DoRetrofitting

    return inst
end

return Prefab("retrofit_archiveteleporter", fn)
