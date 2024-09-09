local assets =
{
    Asset("ANIM", "anim/winter_ornaments.zip"),
}

local foodinfo =
{
    {food=FOODTYPE.GOODIES, health=0,     hunger=3,  sanity=1, treeornament=true, floater={"med", 0.65}}, -- Gingerbread Cookies
    {food=FOODTYPE.GOODIES, health=0,     hunger=2,  sanity=2, treeornament=true, floater={"small", 0.90}}, -- Sugar Cookies
    {food=FOODTYPE.GOODIES, health=2,     hunger=0,  sanity=2, treeornament=true, floater={"med", 0.65}}, -- Candy Cane
    {food=FOODTYPE.VEGGIE,  health=-2,    hunger=6,  sanity=-2, treeornament=true, floater={"med", 0.83}, tags = {"donotautopick"}}, -- Fruitcake
    {food=FOODTYPE.GOODIES, health=1,     hunger=2,  sanity=1, treeornament=true, floater={"med", 0.65}}, -- chocolate log cake
    {food=FOODTYPE.VEGGIE,  health=0,     hunger=4,  sanity=0, treeornament=false, floater={"small", 0.80}}, -- plum pudding
    {food=FOODTYPE.VEGGIE,  health=2,     hunger=0,  sanity=1, treeornament=false, floater={"small", 0.93}, temperature = TUNING.HOT_FOOD_BONUS_TEMP, temperatureduration = TUNING.FOOD_TEMP_LONG}, -- hot apple cider
    {food=FOODTYPE.GOODIES, health=1,     hunger=0,  sanity=2, treeornament=false, floater={"small", 0.55}, temperature = TUNING.HOT_FOOD_BONUS_TEMP, temperatureduration = TUNING.FOOD_TEMP_LONG}, -- hot coco
    {food=FOODTYPE.MEAT,    health=0,     hunger=3,  sanity=0, treeornament=false, floater={"small", 0.45}, temperature = TUNING.COLD_FOOD_BONUS_TEMP, temperatureduration = TUNING.FOOD_TEMP_LONG}, -- eggnog
}

assert(#foodinfo == NUM_WINTERFOOD)

local function MakeFood(num)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("winter_ornaments")
        inst.AnimState:SetBuild("winter_ornaments")
        inst.AnimState:PlayAnimation("food"..tostring(num))
        inst.scrapbook_anim = "food"..tostring(num)

        inst:AddTag("cattoy")
        inst:AddTag("wintersfeastfood")
        inst:AddTag("pre-preparedfood")

        if foodinfo[num].treeornament then
            inst:AddTag("winter_ornament")
            inst.winter_ornamentid = "food"..tostring(num)
        end

        if foodinfo[num].tags ~= nil then
            for _,v in ipairs(foodinfo[num].tags) do
                inst:AddTag(v)
            end
        end

        MakeInventoryFloatable(inst)

        if foodinfo[num].floater ~= nil then
            inst.components.floater:SetSize(foodinfo[num].floater[1])
            inst.components.floater:SetScale(foodinfo[num].floater[2])
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("edible")
        inst.components.edible.foodtype = foodinfo[num].food
        inst.components.edible.hungervalue = foodinfo[num].hunger
        inst.components.edible.healthvalue = foodinfo[num].health
        inst.components.edible.sanityvalue = foodinfo[num].sanity
        inst.components.edible.temperaturedelta = foodinfo[num].temperature or 0
        inst.components.edible.temperatureduration = foodinfo[num].temperatureduration or 0

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("tradable")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        MakeHauntableLaunch(inst)

        return inst
    end

    -- NOTES(JBK): Use this to help export the bottom table to make this file findable.
    --print(string.format("%s %s", foodinfo[num].food or FOODTYPE.GENERIC, "winter_food"..tostring(num)))
    return Prefab("winter_food"..tostring(num), fn, assets)
end

local ret = {}
for k = 1, NUM_WINTERFOOD do
    table.insert(ret, MakeFood(k))
end

return unpack(ret)

-- NOTES(JBK): These are here to make this file findable.
--[[
FOODTYPE.GOODIES winter_food1
FOODTYPE.GOODIES winter_food2
FOODTYPE.GOODIES winter_food3
FOODTYPE.GOODIES winter_food5
FOODTYPE.GOODIES winter_food8
FOODTYPE.MEAT winter_food9
FOODTYPE.VEGGIE winter_food4
FOODTYPE.VEGGIE winter_food6
FOODTYPE.VEGGIE winter_food7
]]
