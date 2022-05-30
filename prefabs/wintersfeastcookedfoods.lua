require "tuning"
local fooddef = require("wintersfeastcookedfoods")

local function MakeFood(name)
    local assets =
    {
		Asset("ANIM", "anim/food_winters_feast_2019.zip"),
        Asset("INV_IMAGE", name),
    }

    local prefabs =
    {
        --"spoiled_food",
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("food_winters_feast_2019")
        inst.AnimState:SetBuild("food_winters_feast_2019")
        inst.AnimState:PlayAnimation("idle")
		inst.AnimState:OverrideSymbol("swap_food", "food_winters_feast_2019", name)

		local data = fooddef.foods[name]

        local float = data.floater
        if float ~= nil then
            MakeInventoryFloatable(inst, float[1], float[2], float[3])
        else
            MakeInventoryFloatable(inst)
        end

		inst:AddTag("wintersfeastcookedfood")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

		local uses = data.uses or TUNING.WINTERSFEASTBUFF.EATTIME
		inst:AddComponent("finiteuses")
		inst.components.finiteuses:SetMaxUses(uses)
		inst.components.finiteuses:SetUses(uses)
		--inst.components.finiteuses:SetOnFinished(inst.Remove) -- removed by the winters feast table

        inst:AddComponent("inspectable")
		inst.wet_prefix = data.wet_prefix

        inst:AddComponent("inventoryitem")

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
		MakeHauntableLaunchAndPerish(inst)

        inst:AddComponent("bait")

        inst:AddComponent("tradable")

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local prefs = {}
for foodname,fooddata in pairs(fooddef.foods) do
    table.insert(prefs, MakeFood(foodname))
end

return unpack(prefs)
