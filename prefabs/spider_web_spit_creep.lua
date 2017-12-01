local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddGroundCreepEntity()
    inst.entity:AddNetwork()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.GroundCreepEntity:SetRadius(3)

	inst:DoTaskInTime(5, inst.Remove)
	inst.persists = false

	return inst
end

return Prefab("spider_web_spit_creep", fn)