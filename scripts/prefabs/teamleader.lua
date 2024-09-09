local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()

	inst:AddComponent("teamleader")
	inst:AddTag("teamleader")
    --[[Non-networked entity]]

	return inst
end

return Prefab("teamleader", fn)