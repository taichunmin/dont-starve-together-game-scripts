local assets =
{
	Asset("ANIM", "anim/raindrop.zip"),
}

local function OnAnimOver(inst)
	if inst.pool ~= nil and inst.pool.valid then
		inst:RemoveFromScene()
		table.insert(inst.pool.ents, inst)
	else
		inst:Remove()
	end
end

local function RestartFx(inst)
	inst.AnimState:PlayAnimation("anim")
end

local function fn()
	local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

	inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBuild("raindrop")
    inst.AnimState:SetBank("raindrop")
	inst.AnimState:PlayAnimation("anim")

	inst:ListenForEvent("animover", OnAnimOver)

	inst.RestartFx = RestartFx

    return inst
end

return Prefab("raindrop", fn, assets)