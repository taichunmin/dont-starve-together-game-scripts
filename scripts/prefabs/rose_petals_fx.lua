local assets =
{
	Asset("ANIM", "anim/rose_petals_fx.zip"),
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter() --some places might need an entity to play sfx on
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.AnimState:SetBank("rose_petals_fx")
	inst.AnimState:SetBuild("rose_petals_fx")
	inst.AnimState:PlayAnimation("fall")
	inst.AnimState:SetFinalOffset(-1)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:ListenForEvent("animover", ErodeAway)

	inst.persists = false

	return inst
end

return Prefab("rose_petals_fx", fn, assets)
