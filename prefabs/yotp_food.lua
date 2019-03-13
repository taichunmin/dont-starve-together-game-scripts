local assets =
{
    Asset("ANIM", "anim/yotp_food.zip"),
}

local foodinfo =
{
    {food=FOODTYPE.MEAT,		hunger = TUNING.CALORIES_SUPERHUGE,			health = TUNING.HEALING_SMALL*4,	sanity = TUNING.SANITY_TINY,		perishtime = TUNING.PERISH_SLOW},	-- tribute roast (same tuning as bonestew)
    {food=FOODTYPE.HORRIBLE,	hunger = TUNING.CALORIES_SUPERHUGE,			health = 0,							sanity = 0},															-- mud pie
    {food=FOODTYPE.MEAT,		hunger = TUNING.CALORIES_HUGE,				health = TUNING.HEALING_SMALL*2,	sanity = TUNING.SANITY_SUPERTINY,	perishtime = TUNING.PERISH_SLOW},	-- fish head skewers
}

local function MakeFood(num)
	local data = foodinfo[num]

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("yotp_food")
        inst.AnimState:SetBuild("yotp_food")
        inst.AnimState:PlayAnimation("food"..tostring(num))

        if data.tags ~= nil then
            for _,v in ipairs(data.tags) do
                inst:AddTag(v)
            end
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("edible")
        inst.components.edible.foodtype = data.food
        inst.components.edible.hungervalue = data.hunger
        inst.components.edible.healthvalue = data.health
        inst.components.edible.sanityvalue = data.sanity
        inst.components.edible.temperaturedelta = data.temperature or 0
        inst.components.edible.temperatureduration = data.temperatureduration or 0

		if data.perishtime ~= nil and data.perishtime > 0 then
			inst:AddComponent("perishable")
			inst.components.perishable:SetPerishTime(data.perishtime)
			inst.components.perishable:StartPerishing()
			inst.components.perishable.onperishreplacement = "spoiled_food"
		end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("tradable")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("yotp_food"..num, fn, assets)
end

local ret = {}
for k = 1, #foodinfo do
    table.insert(ret, MakeFood(k))
end

return unpack(ret)
