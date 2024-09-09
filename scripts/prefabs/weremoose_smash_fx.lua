local assets =
{
	Asset("ANIM", "anim/weremoose_attacks.zip"),
}

local function AddBackFX(parent)
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.Transform:SetFourFaced()

	inst.entity:SetParent(parent.entity)

	inst.AnimState:SetBank("weremoose")
	inst.AnimState:SetBuild("weremoose_build")
	inst.AnimState:PlayAnimation("moose_slam_fx_back")
	inst.AnimState:SetFrame(parent.AnimState:GetCurrentAnimationFrame())
	inst.AnimState:SetFinalOffset(-1)

	return inst
end

local function OnOwnerDirty(inst)
	if inst._owner:value() == ThePlayer then
		--Predicting! so we'll have spawned our own fx locally already
		inst:Hide()
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("weremoose")
	inst.AnimState:SetBuild("weremoose_build")
	inst.AnimState:PlayAnimation("moose_slam_fx_front")
	inst.AnimState:SetFinalOffset(3)

	inst._owner = net_entity(inst.GUID, "weremoose_smash_fx._owner", "ownerdirty")

	inst.entity:SetPristine()

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst:DoTaskInTime(0, AddBackFX)
	end

	if not TheWorld.ismastersim then
		if ThePlayer ~= nil and ThePlayer.sg ~= nil then
			inst:ListenForEvent("ownerdirty", OnOwnerDirty)
		end

		return inst
	end

	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

return Prefab("weremoose_smash_fx", fn, assets)
