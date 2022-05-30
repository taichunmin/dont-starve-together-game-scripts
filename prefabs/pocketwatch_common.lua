
local function OnDropped(inst)
	local rechargeable = inst.components.rechargeable
	if rechargeable ~= nil and not rechargeable:IsCharged() then
		inst.AnimState:PlayAnimation(rechargeable.chargetime > 4 and "cooldown_long" or "cooldown_short")
		local anim_length = inst.AnimState:GetCurrentAnimationLength()
		inst.AnimState:SetTime(anim_length * rechargeable:GetPercent())
		inst.AnimState:SetDeltaTimeMultiplier(anim_length / rechargeable.chargetime)
	end
end

local function OnCharged(inst)
	if inst.components.pocketwatch ~= nil then
	    inst.components.pocketwatch.inactive = true
		inst.AnimState:PlayAnimation("idle")
	end
end

local function OnDischarged(inst)
	if inst.components.pocketwatch ~= nil then
		inst.components.pocketwatch.inactive = false
	end
	OnDropped(inst)
end

local function GetStatus(inst)
	return (inst.components.rechargeable ~= nil and not inst.components.rechargeable:IsCharged()) and "RECHARGING"
			or nil
end

local function common_fn(bank, build, DoCastSpell, cast_from_inventory, tags, common_postinit, master_postinit)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})

	inst:AddTag("pocketwatch")
	inst:AddTag("cattoy")

	if cast_from_inventory then
		inst:AddTag("pocketwatch_castfrominventory")
	end

	if tags ~= nil then
		for _, tag in ipairs(tags) do
			inst:AddTag(tag)
		end
	end

    if common_postinit ~= nil then
		common_postinit(inst)
	end

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
		
	inst:AddComponent("rechargeable")
	inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
	inst.components.rechargeable:SetOnChargedFn(OnCharged)

	inst:AddComponent("pocketwatch")
	inst.components.pocketwatch.DoCastSpell = DoCastSpell

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

    MakeHauntableLaunch(inst)

    if master_postinit ~= nil then
		master_postinit(inst)
	end
    return inst
end

-------------------------------------------------------------------------------

local function recallmarker_remove(inst)
	if inst.marker ~= nil and inst.marker:IsValid() then
		inst.marker:RemoveMarker()
		inst.marker = nil
	end
end

local function recallmarker_ondropped(inst)
	if inst._owner ~= nil then
		inst:RemoveEventCallback("ms_respawnedfromghost", inst._respawnedfromghost_handler, inst._owner)
		inst._owner = nil
	end

	recallmarker_remove(inst)
end

local function recallmarker_create(inst)
	recallmarker_remove(inst)

	if inst.components.recallmark:IsMarked() then
		local owner = inst.components.inventoryitem:GetGrandOwner()
		if owner ~= nil and not owner:HasTag("playerghost") then
			local x, y, z = inst.components.recallmark:GetMarkedPosition() -- if this returns nil, then it is not marked or the marked poistion is in another shard
			if owner ~= nil and x ~= nil then
				inst.marker = SpawnPrefab("pocketwatch_recall_marker")
				inst.marker.Transform:SetPosition(x, y, z)
				inst.marker.Transform:SetRotation(math.random(360))
				inst.marker:ShowMarker(owner)

				inst.marker:ListenForEvent("death", function() recallmarker_remove(inst) end, owner)
				
				if inst._owner == nil then
					inst._owner = owner
					inst:ListenForEvent("ms_respawnedfromghost", inst._respawnedfromghost_handler, owner)
				end
			end
		end
	end
end

local function RecallMarkable_GetStatus(inst, viewer)
	return (inst.components.rechargeable ~= nil and not inst.components.rechargeable:IsCharged()) and "RECHARGING"
			or viewer:HasTag("pocketwatchcaster") and ((inst.components.recallmark ~= nil and inst.components.recallmark:IsMarked()) and (inst.components.recallmark.recall_worldid == TheShard:GetShardId() and "MARKED_SAMESHARD" or "MARKED_DIFFERENTSHARD") or "UNMARKED")
			or nil
end

local function MakeRecallMarkable(inst)
	inst:AddComponent("recallmark")
	inst.components.recallmark.onMarkPosition = recallmarker_create

	inst:ListenForEvent("onputininventory", recallmarker_create)
	inst:ListenForEvent("onownerputininventory", recallmarker_create)
	inst:ListenForEvent("ondropped", recallmarker_ondropped)
	inst:ListenForEvent("onownerdropped", recallmarker_ondropped)
	inst:ListenForEvent("onremove", recallmarker_remove)

	inst._respawnedfromghost_handler = function() recallmarker_create(inst) end

	inst.components.inspectable.getstatus = RecallMarkable_GetStatus

	inst:DoTaskInTime(0, recallmarker_create)
end

-------------------------------------------------------------------------------

return {
	common_fn = common_fn,
	MakeRecallMarkable = MakeRecallMarkable,
}
