--Planted in the ground version.

--prefab transforms between different prefabs depending on state.
	--mandrake_planted --> mandrake_active (picked)
	--mandrake_planted <-- mandrake_active (replant)
	--mandrake_active --> mandrake_inactive (death)

local assets =
{
	Asset("ANIM", "anim/mandrake.zip"),
}

local prefabs =
{
	"cookedmandrake",
	"mandrake",
}

local function replant(inst)
	inst.AnimState:PlayAnimation("plant")
	inst.AnimState:PushAnimation("ground", true)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/plant")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/plant_dirt")
end

local function onpicked(inst, picker)
	--Go to mandrake_active
	local pos = inst:GetPosition()

	local active = SpawnPrefab("mandrake_active")
	active.Transform:SetPosition(pos:Get())
	active:onpicked(picker)

	inst:Remove()
end

local function fn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mandrake")
    inst.AnimState:SetBuild("mandrake")
    inst.AnimState:PlayAnimation("ground")

    inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	inst:AddComponent("pickable")
	inst.components.pickable.onpickedfn = onpicked
	inst.components.pickable:Regen()

	inst.replant = replant

	return inst
end

return Prefab("mandrake_planted", fn, assets, prefabs)
