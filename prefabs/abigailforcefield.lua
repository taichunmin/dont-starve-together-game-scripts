local assets =
{
   Asset("ANIM", "anim/abigail_shield.zip"),
}

local function buff_OnAttached(inst, target)
    target:AddTag("forcefield")

	if target.components.health ~= nil then
	    target.components.health.externalabsorbmodifiers:SetModifier(inst, TUNING.ABIGAIL_FORCEFIELD_ABSORPTION, "forcefield")
	end

	inst.entity:SetParent(target.entity)
	inst.Transform:SetPosition(0, 0, 0)

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

end

local function buff_OnDetached(inst, target)
	if target ~= nil and target:IsValid() then
		target:RemoveTag("forcefield")
	end
    inst:Remove()
end

local function expire(inst)
	inst.components.debuff:Stop()
end

local function fn(anim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("abigail_shield")
	inst.AnimState:SetBuild("abigail_shield")
	inst.AnimState:PlayAnimation(anim)
    inst.AnimState:SetFinalOffset(1)

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("debuff")
	inst.components.debuff:SetAttachedFn(buff_OnAttached)
	inst.components.debuff:SetDetachedFn(buff_OnDetached)

	inst.persits = false

	inst:ListenForEvent("animover", expire)

	return inst
end

local function MakeBuffFx(name, anim)
	return Prefab(name, function() return fn(anim) end, assets)
end

return MakeBuffFx("abigailforcefield", "shield"),
	MakeBuffFx("abigailforcefieldbuffed", "shield_buff"),
	MakeBuffFx("abigailforcefieldretaliation", "shield_retaliation")
