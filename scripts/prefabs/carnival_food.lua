
local food_defs =
{
    {name = "carnivalfood_corntea", anim = "corn_tea", art = "carnival_food", food=FOODTYPE.VEGGIE, hunger = TUNING.CALORIES_TINY, health = 0, sanity = TUNING.SANITY_TINY,	perishtime = TUNING.PERISH_SUPERFAST, temperature = TUNING.COLD_FOOD_BONUS_TEMP, temperatureduration = TUNING.FOOD_TEMP_LONG, floater = {"small", .9}},
}

local function MakeFood(def)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(def.art)
        inst.AnimState:SetBuild(def.art)
        inst.AnimState:PlayAnimation(def.anim)
        inst.scrapbook_anim = def.anim

        if def.art.tags ~= nil then
            for _,v in ipairs(def.art.tags) do
                inst:AddTag(v)
            end
        end
        inst:AddTag("pre-preparedfood")

        MakeInventoryFloatable(inst)

        if def.floater ~= nil then
            inst.components.floater:SetSize(def.floater[1])
            inst.components.floater:SetScale(def.floater[2])
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("edible")
        inst.components.edible.foodtype = def.food
        inst.components.edible.hungervalue = def.hunger
        inst.components.edible.healthvalue = def.health
        inst.components.edible.sanityvalue = def.sanity
        inst.components.edible.temperaturedelta = def.temperature or 0
        inst.components.edible.temperatureduration = def.temperatureduration or 0

		if def.perishtime ~= nil and def.perishtime > 0 then
			inst:AddComponent("perishable")
			inst.components.perishable:SetPerishTime(def.perishtime)
			inst.components.perishable:StartPerishing()
			inst.components.perishable.onperishreplacement = "spoiled_food"
		end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("tradable")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

		MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
		MakeSmallPropagator(inst)

        MakeHauntableLaunch(inst)

        return inst
    end

	local assets =
	{
		Asset("ANIM", "anim/"..def.art..".zip"),
	}


    -- NOTES(JBK): Use this to help export the bottom table to make this file findable.
    --print(string.format("%s %s", def.food or FOODTYPE.GENERIC, def.name))
    return Prefab(def.name, fn, assets)
end

local ret = {}
for i, def in ipairs(food_defs) do
    table.insert(ret, MakeFood(def))
end

return unpack(ret)

-- NOTES(JBK): These are here to make this file findable.
--[[
FOODTYPE.VEGGIE carnivalfood_corntea
]]
