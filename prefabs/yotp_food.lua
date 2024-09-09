local assets =
{
    Asset("ANIM", "anim/yotp_food.zip"),
    Asset("ANIM", "anim/yotp_food_water.zip"),
}

local foodinfo =
{
    {food=FOODTYPE.MEAT,		hunger = TUNING.CALORIES_SUPERHUGE,			health = TUNING.HEALING_SMALL*4,	sanity = TUNING.SANITY_TINY,		perishtime = TUNING.PERISH_SLOW,    floater = {"med", 0.9, false}},     -- tribute roast (same tuning as bonestew)
    {food=FOODTYPE.HORRIBLE,	hunger = TUNING.CALORIES_SUPERHUGE,			health = 0,							sanity = 0},															                                    -- mud pie
    {food=FOODTYPE.MEAT,		hunger = TUNING.CALORIES_HUGE,				health = TUNING.HEALING_SMALL*2,	sanity = TUNING.SANITY_SUPERTINY,	perishtime = TUNING.PERISH_SLOW,    floater = {"med", {0.8, 0.5, 0.8}, true}},    -- fish head skewers
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

        local anim_name = "food"..tostring(num)
        inst.AnimState:PlayAnimation(anim_name)

        if data.tags ~= nil then
            for _,v in ipairs(data.tags) do
                inst:AddTag(v)
            end
        end
        inst:AddTag("pre-preparedfood")

        MakeInventoryFloatable(inst)

        if data.floater ~= nil then
            inst.components.floater:SetSize(data.floater[1])
            inst.components.floater:SetScale(data.floater[2])

            -- The bool in slot 3 means "uses an override anim"
            if data.floater[3] then
                inst.AnimState:AddOverrideBuild("yotp_food_water")
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

        if data.floater ~= nil and data.floater[3] then
            -- The bool in slot 3 means "uses an override anim"
            inst:ListenForEvent("floater_startfloating", function(inst) inst.AnimState:PlayAnimation(anim_name.."_float") end)
            inst:ListenForEvent("floater_stopfloating", function(inst) inst.AnimState:PlayAnimation(anim_name) end)
        end

        MakeHauntableLaunch(inst)

        return inst
    end

    -- NOTES(JBK): Use this to help export the bottom table to make this file findable.
    --print(string.format("%s %s", data.food or FOODTYPE.GENERIC, "yotp_food"..num))
    return Prefab("yotp_food"..num, fn, assets)
end

local ret = {}
for k = 1, #foodinfo do
    table.insert(ret, MakeFood(k))
end

return unpack(ret)

-- NOTES(JBK): These are here to make this file findable.
--[[
FOODTYPE.HORRIBLE yotp_food2
FOODTYPE.MEAT yotp_food1
FOODTYPE.MEAT yotp_food3
]]
