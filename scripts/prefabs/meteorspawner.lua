local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("meteorshower")

    return inst
end

return Prefab("meteorspawner", fn)