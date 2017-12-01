local assets =
{
    Asset("ANIM", "anim/cook_pot_food.zip"),
}

local prefabs =
{
    "spoiled_food",
}

local function MakePreparedFood(data)
    local foodprefabs = prefabs
    if data.prefabs ~= nil then
        foodprefabs = deepcopy(prefabs)
        for i, v in ipairs(data.prefabs) do
            if not table.contains(foodprefabs, v) then
                table.insert(foodprefabs, v)
            end
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBuild("cook_pot_food")
        inst.AnimState:SetBank("food")
        inst.AnimState:PlayAnimation(data.name, false)

        inst:AddTag("preparedfood")
        if data.tags then
            for i,v in pairs(data.tags) do
                inst:AddTag(v)
            end
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("edible")
        inst.components.edible.healthvalue = data.health
        inst.components.edible.hungervalue = data.hunger
        inst.components.edible.foodtype = data.foodtype or FOODTYPE.GENERIC
        inst.components.edible.sanityvalue = data.sanity or 0
        inst.components.edible.temperaturedelta = data.temperature or 0
        inst.components.edible.temperatureduration = data.temperatureduration or 0
        inst.components.edible:SetOnEatenFn(data.oneatenfn)

        inst:AddComponent("inspectable")
        inst.wet_prefix = data.wet_prefix
        
        inst:AddComponent("inventoryitem")

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		if data.perishtime ~= nil and data.perishtime > 0 then
			inst:AddComponent("perishable")
			inst.components.perishable:SetPerishTime(data.perishtime)
			inst.components.perishable:StartPerishing()
			inst.components.perishable.onperishreplacement = "spoiled_food"
		end
		
        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableLaunchAndPerish(inst)
        AddHauntableCustomReaction(inst, function(inst, haunter)
            --#HAUNTFIX
            --if math.random() <= TUNING.HAUNT_CHANCE_SUPERRARE then
                --if inst.components.burnable and not inst.components.burnable:IsBurning() then
                    --inst.components.burnable:Ignite()
                    --inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
                    --inst.components.hauntable.cooldown_on_successful_haunt = false
                    --return true
                --end
            --end
            return false
        end, true, false, true)
        ---------------------        

        inst:AddComponent("bait")

        ------------------------------------------------
        inst:AddComponent("tradable")
        
        ------------------------------------------------  

        return inst
    end

    return Prefab(data.name, fn, assets, foodprefabs)
end

local prefs = {}

local foods = require("preparedfoods")
for k,v in pairs(foods) do
    table.insert(prefs, MakePreparedFood(v))
end

return unpack(prefs)
