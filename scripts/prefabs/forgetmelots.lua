local assets =
{
    Asset("ANIM", "anim/forgetmelots.zip"),
}

local prefabs =
{
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("forgetmelots")
    inst.AnimState:SetBuild("forgetmelots")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.0, 0.7)

    inst:AddTag("cattoy")
    inst:AddTag("vasedecoration")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("vasedecoration")

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
	inst.components.edible.sanityvalue = TUNING.SANITY_SUPERTINY
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

local function respawner_test_point(pt)
    return not TheWorld.Map:IsPointNearHole(pt) and TheWorld.Map:CanTillSoilAtPoint(pt.x, pt.y, pt.z)
end

local function respawner_OnTimerDone(inst, data)
    if data.name == "regenover" then
		local x, y, z = inst.Transform:GetWorldPosition()

		if not TheWorld.Map:CanTillSoilAtPoint(x, y, z) then
			local pt = Vector3(x, y, z)
			local angle = math.random() * TWOPI

			local offset = FindWalkableOffset(pt, angle, 2, 8, true, true, respawner_test_point, false, false)
							or FindWalkableOffset(pt, angle, 3, 8, true, true, respawner_test_point, false, false)
			if offset ~= nil then
				x = x + offset.x
				y = y + offset.y
				z = z + offset.z
			else
				x = nil
			end
		end

		if x ~= nil then
			TheWorld.Map:CollapseSoilAtPoint(x, y, z)
			SpawnPrefab("weed_forgetmelots").Transform:SetPosition(x, y, z)
		end

		inst:Remove()
    end
end

local function respawner_fn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
	inst:AddTag("NOBLOCK")
    inst:AddTag("CLASSIFIED")
	inst:AddTag("weed_forgetmelots_respawner")

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("regenover", TUNING.FORGETMELOTS_RESPAWNER_MIN + math.random() * TUNING.FORGETMELOTS_RESPAWNER_VAR)
    inst:ListenForEvent("timerdone", respawner_OnTimerDone)

    return inst
end

local function OnTick(inst, target)
    if target.components.health ~= nil
        and not target.components.health:IsDead()
		and target.components.sanity ~= nil
        and not target:HasTag("playerghost") then
        target.components.sanity:DoDelta(TUNING.SWEETTEA_SANITY_DELTA)
    else
        inst.components.debuff:Stop()
    end
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading
    inst.task = inst:DoPeriodicTask(TUNING.SWEETTEA_TICK_RATE, OnTick, nil, target)
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
end

local function OnTimerDone(inst, data)
    if data.name == "regenover" then
        inst.components.debuff:Stop()
    end
end

local function OnExtended(inst, target)
    inst.components.timer:StopTimer("regenover")
    inst.components.timer:StartTimer("regenover", TUNING.SWEETTEA_DURATION)
    inst.task:Cancel()
    inst.task = inst:DoPeriodicTask(TUNING.SWEETTEA_TICK_RATE, OnTick, nil, target)
end

local function debuff_fn()
    local inst = CreateEntity()

    if not TheWorld.ismastersim then
        --Not meant for client!
        inst:DoTaskInTime(0, inst.Remove)

        return inst
    end

    inst.entity:AddTransform()

    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.entity:Hide()
    inst.persists = false

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(inst.Remove)
    inst.components.debuff:SetExtendedFn(OnExtended)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("regenover", TUNING.SWEETTEA_DURATION)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("forgetmelots", fn, assets, prefabs),
	Prefab("sweettea_buff", debuff_fn),
	Prefab("weed_forgetmelots_respawner", respawner_fn)

