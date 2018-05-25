local assets =
{
    Asset("ANIM", "anim/winter_ornaments.zip"),
}

local foodinfo =
{
    {food=FOODTYPE.GOODIES, health=0,     hunger=3,  sanity=1, treeornament=true}, -- Gingerbread Cookies
    {food=FOODTYPE.GOODIES, health=0,     hunger=2,  sanity=2, treeornament=true}, -- Sugar Cookies
    {food=FOODTYPE.GOODIES, health=2,     hunger=0,  sanity=2, treeornament=true}, -- Candy Cane
    {food=FOODTYPE.VEGGIE,  health=-2,    hunger=6,  sanity=-2, treeornament=true}, -- Fruitcake
    {food=FOODTYPE.GOODIES, health=1,     hunger=2,  sanity=1, treeornament=true}, -- chocolate log cake
    {food=FOODTYPE.VEGGIE,  health=0,     hunger=4,  sanity=0, treeornament=false}, -- plum pudding
    {food=FOODTYPE.VEGGIE,  health=2,     hunger=0,  sanity=1, treeornament=false, temperature = TUNING.HOT_FOOD_BONUS_TEMP, temperatureduration = TUNING.FOOD_TEMP_LONG}, -- hot apple cider
    {food=FOODTYPE.GOODIES, health=1,     hunger=0,  sanity=2, treeornament=false, temperature = TUNING.HOT_FOOD_BONUS_TEMP, temperatureduration = TUNING.FOOD_TEMP_LONG}, -- hot coco
    {food=FOODTYPE.MEAT,    health=0,     hunger=3,  sanity=0, treeornament=false, temperature = TUNING.COLD_FOOD_BONUS_TEMP, temperatureduration = TUNING.FOOD_TEMP_LONG}, -- eggnog
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

        inst:AddTag("cattoy")
        inst:AddTag("wintersfeastfood")

        if foodinfo[num].treeornament then
            inst:AddTag("winter_ornament")
            inst.winter_ornamentid = "food"..tostring(num)
        end

        if foodinfo[num].tags ~= nil then
            for _,v in ipairs(foodinfo[num].tags) do
                inst:AddTag(v)
            end
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

    return Prefab("winter_food"..tostring(num), fn, assets)
end

local ret = {}
for k = 1, NUM_WINTERFOOD do
    table.insert(ret, MakeFood(k))
end

return unpack(ret)
