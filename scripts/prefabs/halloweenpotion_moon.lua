local PotionCommon = require "prefabs/halloweenpotion_common"

local assets =
{
    Asset("ANIM", "anim/halloween_potion_moon.zip"),
}

local prefabs =
{
	"halloween_moonpuff",
}

local function onusefn(inst, doer, target, success, transformed_inst, container)
	-- transformed_inst == nil when either the potion had no effect or the target's halloweenmoonmutable
	-- component uses a conversion override fn (i.e. no new instance is spawned on conversion).
	local spawn_fx_at = (container ~= nil and container.inst) or transformed_inst or target or doer
	if spawn_fx_at ~= nil then
		SpawnPrefab("halloween_moonpuff").Transform:SetPosition(spawn_fx_at.Transform:GetWorldPosition())
	end

	if not success and doer ~= nil then
		doer:PushEvent("on_halloweenmoonpotion_failed")

		target:PushEvent("attacked", {attacker = doer, damage = 0})
	end
end

local function onputinfirefn(inst, target)
	if target:HasTag("campfire") then
		PotionCommon.SpawnPuffFx(inst, target)
	end
end

local function PlayRandomIdle(inst)
	local r = math.random(1, 4)
	inst.AnimState:PlayAnimation("idle_"..r)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("halloween_potion_moon")
    inst.AnimState:SetBuild("halloween_potion_moon")
	PlayRandomIdle(inst)

	MakeInventoryFloatable(inst, "small", 0.15, 0.65)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.scrapbook_specialinfo = "HALLOWEENPOTIONMOON"
	inst.scrapbook_anim = "idle_1"

	inst:AddComponent("halloweenpotionmoon")
	inst.components.halloweenpotionmoon:SetOnUseFn(onusefn)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")

    MakeHauntableLaunch(inst)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
	inst.components.fuel.ontaken = onputinfirefn

	inst:ListenForEvent("animqueueover", PlayRandomIdle)

    return inst
end

return Prefab("halloweenpotion_moon", fn, assets, prefabs)
