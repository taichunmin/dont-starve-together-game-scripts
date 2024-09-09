local assets =
{
    Asset("ANIM", "anim/wolfgang_whistle.zip"),
}

local function DoAnnounce(doer, str)
	if doer.components.talker ~= nil then
		doer.components.talker:Say(GetString(doer, str))
	end
end

local function OnPlayed(inst, doer)
	if doer.components.coach ~= nil and doer.components.mightiness ~= nil and doer:HasTag("wolfgang_coach") then
		local str
		if doer.components.mightiness:IsNormal() then
			if doer:HasTag("coaching") then
				doer.components.coach:Disable()
				str = "ANNOUNCE_WOLFGANG_END_COACHING"
			else
				doer.components.coach:Enable()
				str = "ANNOUNCE_WOLFGANG_BEGIN_COACHING"
			end
		elseif doer.components.mightiness:IsWimpy() then
			str = "ANNOUNCE_WOLFGANG_WIMPY_COACHING"
		elseif doer.components.mightiness:IsMighty() then
			str = "ANNOUNCE_WOLFGANG_MIGHTY_COACHING"
		end

		if str ~= nil then
			local delay = doer.AnimState:IsCurrentAnimation("whistle") and doer.AnimState:GetCurrentAnimationLength() - doer.AnimState:GetCurrentAnimationTime() - 5 * FRAMES or 0
			if delay > 0 then
				doer:DoTaskInTime(delay, DoAnnounce, str)
			else
				DoAnnounce(doer, str)
			end
		end
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wolfgang_whistle")
    inst.AnimState:SetBuild("wolfgang_whistle")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "metal"

    inst:AddTag("cattoy")
	inst:AddTag("whistle")
	inst:AddTag("coach_whistle")

	--tool (from tool component) added to pristine state for optimization
	inst:AddTag("tool")

    MakeInventoryFloatable(inst, "med", 0.05, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.whistle_build = "wolfgang_whistle"
    inst.whistle_symbol = "wolfgang_whistle01"
    inst.whistle_sound = "meta2/wolfgang/whistle"

    inst:AddComponent("inventoryitem")

    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")

	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.PLAY)

	inst:AddComponent("instrument")
	inst.components.instrument:SetOnPlayedFn(OnPlayed)

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("wolfgang_whistle", fn, assets)
