local function onnewobjectfn(inst, obj)
    inst:ListenForEvent("onremove", function(obj)
        table.removearrayvalue(inst.components.objectspawner.objects, obj)
    end, obj)

    if inst.listenforprefabsawp then
		inst:ListenForEvent("onprefabswaped", function(_, data)
			inst.components.objectspawner:TakeOwnership(data.newobj)
		end, obj)
    end
end

local TRYSPAWN_CANT_TAGS = { "INLIMBO" }

local function tryspawn(inst)
    if inst.resetruins and #inst.components.objectspawner.objects <= 0 then
        local x, y, z = inst.Transform:GetWorldPosition()
        for i, v in ipairs(TheSim:FindEntities(x, y, z, 1, nil, TRYSPAWN_CANT_TAGS)) do
            if v.components.workable ~= nil and v.components.workable:GetWorkAction() ~= ACTIONS.NET then
                v.components.workable:Destroy(v)
            end
        end

        local obj = inst.components.objectspawner:SpawnObject(inst.spawnprefab)
        obj.spawnlocation = Vector3(x, y, z)
        obj.Transform:SetPosition(x, y, z)
  		if inst.onrespawnfn ~= nil then
			inst.onrespawnfn(obj, inst)
		end

    end

    inst.resetruins = nil
end

local function onsave(inst, data)
    data.resetruins = inst.resetruins
end

local function onload(inst, data)
    if data ~= nil then
        inst.resetruins = data.resetruins
    end
end

local function OnLoadPostPass(inst)
	if inst.resetruins then
		tryspawn(inst)
	end
end

local function MakeFn(obj, onrespawnfn, data)
	local fn = function()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		--[[Non-networked entity]]

		inst:AddTag("CLASSIFIED")

		inst.spawnprefab = obj
		inst.onrespawnfn = onrespawnfn

		inst:AddComponent("objectspawner")
		inst.components.objectspawner.onnewobjectfn = onnewobjectfn

		inst:ListenForEvent("resetruins", function()
			inst.resetruins = true
			inst:DoTaskInTime(math.random()*0.75, function() tryspawn(inst) end)
		end, TheWorld)

		inst.OnSave = onsave
		inst.OnLoad = onload
		inst.OnLoadPostPass = OnLoadPostPass

		inst.listenforprefabsawp = data ~= nil and data.listenforprefabsawp or nil

		return inst
	end
	return fn
end

local function MakeRuinsRespawnerInst(obj, onrespawnfn, data)
	return Prefab(obj.."_ruinsrespawner_inst", MakeFn(obj, onrespawnfn, data), nil, { obj, obj.."_spawner" })
end

local function MakeRuinsRespawnerWorldGen(obj, onrespawnfn, data)
	local function worldgenfn()
		local inst = MakeFn(obj, onrespawnfn, data)()

		inst:SetPrefabName(obj.."_ruinsrespawner_inst")

        inst.resetruins = true
		inst:DoTaskInTime(0, tryspawn)

		return inst
	end

	return Prefab(obj.."_spawner", worldgenfn, nil, { obj })
end

return {Inst = MakeRuinsRespawnerInst, WorldGen = MakeRuinsRespawnerWorldGen}
