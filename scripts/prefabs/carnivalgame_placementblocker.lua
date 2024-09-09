

local function fn(parent, x, z)
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")
	inst:AddTag("carnivalgame_part")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	return inst
end


return Prefab("carnivalgame_placementblocker", fn)
