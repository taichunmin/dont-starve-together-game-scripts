local function fn()
	local inst = CreateEntity()

    inst.entity:SetCanSleep(false)

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddComponent("replayproxy")

    inst.persists = false
    inst:AddTag("entityproxy")

    return inst
end

return Prefab("entityproxy", fn)
