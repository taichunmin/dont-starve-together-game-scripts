
local PotionCommon = require "prefabs/halloweenpotion_common"

local potion_tunings =
{
	halloweenpotion_health_small =
	{
        HEALTH = TUNING.HEALING_MEDSMALL,
		TICK_RATE = 2,
		TICK_VALUE = 1,
		DURATION = TUNING.SEG_TIME * 2,
        FUEL = TUNING.SMALL_FUEL,
        FLOATER = {"small", 0.15, 0.55},
	},
	halloweenpotion_health_large =
	{
        HEALTH = TUNING.HEALING_MED,
		TICK_RATE = 2,
		TICK_VALUE = 1,
		DURATION = TUNING.SEG_TIME * 2,
        FUEL = TUNING.MED_FUEL,
        FLOATER = {"small", 0.15, 0.8},
	},
	halloweenpotion_sanity_small =
	{
        SANITY = TUNING.SANITY_TINY,
		TICK_RATE = 2,
		TICK_VALUE = 1,
		DURATION = TUNING.SEG_TIME * 2,
        FUEL = TUNING.SMALL_FUEL,
        FLOATER = {"small", 0.1, 0.5},
	},
	halloweenpotion_sanity_large =
	{
        SANITY = TUNING.SANITY_MED,
		TICK_RATE = 2,
		TICK_VALUE = 1,
		DURATION = TUNING.SEG_TIME * 2,
        FUEL = TUNING.MED_FUEL,
        FLOATER = {"small", 0.2, 0.4},
	},
	halloweenpotion_bravery_small =
	{
		DURATION = TUNING.TOTAL_DAY_TIME * .5,
        FUEL = TUNING.SMALL_FUEL,
		WISECRACKER = "ANNOUNCE_BRAVERY_POTION",
        FLOATER = {"small", 0.15, 0.75},
	},
	halloweenpotion_bravery_large =
	{
		DURATION = TUNING.TOTAL_DAY_TIME * .75,
        FUEL = TUNING.MED_FUEL,
		WISECRACKER = "ANNOUNCE_BRAVERY_POTION",
        FLOATER = {"small", 0.15, nil},
	},
}

local puff_fx = {"halloween_firepuff_1", "halloween_firepuff_2", "halloween_firepuff_3", }
local puff_fx_cold = {"halloween_firepuff_cold_1", "halloween_firepuff_cold_2", "halloween_firepuff_cold_3", }

local function potion_oneatenfn(inst, eater)
    eater:AddDebuff(inst.buff_id, inst.buff_prefab, nil, nil, function()
        if inst.potion_tunings.WISECRACKER ~= nil and eater.components.talker ~= nil and not eater:HasDebuff(inst.buff_id) then
            eater.components.talker:Say(GetString(eater, inst.potion_tunings.WISECRACKER))
        end
    end)
end

local function potion_onputinfire(inst, target)
	if target:HasTag("campfire") then
		PotionCommon.SpawnPuffFx(inst, target)
	end
end

local function potion_fn(anim, potion_tunings, buff_id, buff_prefab, nameoverride)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("halloween_potions")
    inst.AnimState:SetBuild("halloween_potions")
    inst.AnimState:PlayAnimation(anim)
    inst.scrapbook_anim = anim

    inst:AddTag("potion")
    inst:AddTag("pre-preparedfood")

    if potion_tunings.FLOATER ~= nil then
        MakeInventoryFloatable(inst, potion_tunings.FLOATER[1], potion_tunings.FLOATER[2], potion_tunings.FLOATER[3])
    else
        MakeInventoryFloatable(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.buff_id = buff_id
	inst.buff_prefab = buff_prefab
	inst.potion_tunings = potion_tunings

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = nameoverride

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    MakeHauntableLaunch(inst)

	inst:AddComponent("edible")
	inst.components.edible.foodtype = FOODTYPE.GOODIES
	inst.components.edible.healthvalue = potion_tunings.HEALTH or 0
	inst.components.edible.hungervalue = potion_tunings.HUNGER or 0
	inst.components.edible.sanityvalue = potion_tunings.SANITY or 0
	inst.components.edible:SetOnEatenFn(potion_oneatenfn)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = potion_tunings.FUEL
	inst.components.fuel.ontaken = potion_onputinfire

    return inst
end

local function health_dodelta(inst, target)
	target.components.health:DoDelta(inst.potion_tunings.TICK_VALUE, nil, inst.prefab)
end

local function sanity_dodelta(inst, target)
	if target.components.sanity ~= nil then
		target.components.sanity:DoDelta(inst.potion_tunings.TICK_VALUE)
	end
end

local function buff_OnTick(inst, target)
    if target.components.health ~= nil and
        not target.components.health:IsDead() and
        not target:HasTag("playerghost") then
		inst.potion_dodelta(inst, target)
    else
        inst.components.debuff:Stop()
    end
end

local function buff_OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0) --in case of loading
	if inst.potion_tunings.TICK_RATE ~= nil then
	    inst.task = inst:DoPeriodicTask(inst.potion_tunings.TICK_RATE, buff_OnTick, nil, target)
	end
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
end

local function buff_OnTimerDone(inst, data)
    if data.name == "regenover" then
        inst.components.debuff:Stop()
    end
end

local function buff_OnExtended(inst, target)
    if (inst.components.timer:GetTimeLeft("regenover") or 0) < inst.potion_tunings.DURATION then
        inst.components.timer:StopTimer("regenover")
        inst.components.timer:StartTimer("regenover", inst.potion_tunings.DURATION)
    end
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = inst:DoPeriodicTask(inst.potion_tunings.TICK_RATE, buff_OnTick, nil, target)
	end
end

local function buff_fn(tunings, dodelta_fn)
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

	inst.potion_tunings = tunings
	inst.potion_dodelta = dodelta_fn

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(buff_OnAttached)
    inst.components.debuff:SetDetachedFn(inst.Remove)
    inst.components.debuff:SetExtendedFn(buff_OnExtended)
    inst.components.debuff.keepondespawn = true

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("regenover", tunings.DURATION)
    inst:ListenForEvent("timerdone", buff_OnTimerDone)

    return inst
end

local function AddPotion(potions, name, size, buff_dodelta_fn, nameoverride_postfix)
	local potion_prefab = "halloweenpotion_"..name.."_"..size
	local buff_prefab = potion_prefab.."_buff"
	local buff_id = "halloweenpotion_"..name.."_buff"
    local nameoverride = nameoverride_postfix ~= nil and ("halloweenpotion_drinks_"..nameoverride_postfix) or ("halloweenpotion_"..name)

	local assets = JoinArrays(PotionCommon.assets,
	{
		Asset("ANIM", "anim/halloween_potions.zip"),
		Asset("SCRIPT", "scripts/prefabs/halloweenpotion_common.lua"),
	})
	local prefabs = JoinArrays(PotionCommon.prefabs, {potion_prefab})

	local function _buff_fn() return buff_fn(potion_tunings[potion_prefab], buff_dodelta_fn) end
	local function _potion_fn() return potion_fn(name .. "_" .. size, potion_tunings[potion_prefab], buff_id, buff_prefab, nameoverride) end

	table.insert(potions, Prefab(potion_prefab, _potion_fn, assets, prefabs))
	table.insert(potions, Prefab(buff_prefab, _buff_fn))
end


local potions = {}
AddPotion(potions, "health", "small", health_dodelta, "weak")
AddPotion(potions, "health", "large", health_dodelta, "potent")
AddPotion(potions, "sanity", "small", sanity_dodelta, "weak")
AddPotion(potions, "sanity", "large", sanity_dodelta, "potent")
AddPotion(potions, "bravery", "small", nil, nil)
AddPotion(potions, "bravery", "large", nil, nil)

return unpack(potions)
