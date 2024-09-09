local assets =
{
    Asset("ANIM", "anim/halloweencandy.zip"),
}

local candyinfo =
{
    {food=FOODTYPE.GOODIES, health=1, hunger=1, sanity=1, floater={"small", 0.10, 0.75 }}, -- Candy Apple
    {food=FOODTYPE.GOODIES, health=1, hunger=0, sanity=2, floater={"small", nil,  nil  }}, -- Candy Corn
    {food=FOODTYPE.VEGGIE,  health=1, hunger=2, sanity=0, floater={"small", 0.05, 0.75 }}, -- Not-So-Candy Corn
    {food=FOODTYPE.GOODIES, health=2, hunger=0, sanity=1, floater={"small", nil,  nil  }}, -- Gummy Spider
    {food=FOODTYPE.GOODIES, health=1, hunger=0, sanity=2, floater={"small", 0.10, nil  }}, -- Catcoon Candy
    {food=FOODTYPE.VEGGIE,  health=2, hunger=1, sanity=0, floater={"med",   nil,  0.65 }}, -- "Raisins"
    {food=FOODTYPE.VEGGIE,  health=2, hunger=0, sanity=1, floater={"med",   nil,  0.70 }}, -- Raisins
    {food=FOODTYPE.GOODIES, health=1, hunger=0, sanity=2, floater={"med",   0.05, 0.65 }}, -- Ghost Pop
    {food=FOODTYPE.GOODIES, health=1, hunger=2, sanity=0, floater={"small", 0.05, 0.90 }}, -- Jelly Worm
    {food=FOODTYPE.GOODIES, health=2, hunger=0, sanity=1, floater={"small", 0.05, 0.90 }}, -- Tentacle Lolli
    {food=FOODTYPE.GOODIES, health=1, hunger=1, sanity=1, floater={"small", 0.05, 0.95 }}, -- Choco Pigs
    {food=FOODTYPE.GOODIES, health=1, hunger=2, sanity=0, floater={"med",   0.10, 0.60 }}, -- ONI
    {food=FOODTYPE.GOODIES, health=1, hunger=0, sanity=2, floater={"small", 0.05, 0.90 }}, -- Griftlands
    {food=FOODTYPE.VEGGIE,  health=0, hunger=1, sanity=2, floater={"small", 0.10, 0.85 }}, -- HotLava
}

assert(#candyinfo == NUM_HALLOWEENCANDY)

local function MakeCandy(num)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("halloweencandy")
        inst.AnimState:SetBuild("halloweencandy")
        inst.AnimState:PlayAnimation(tostring(num))
        inst.scrapbook_anim = tostring(num)

        inst:AddTag("cattoy")
        inst:AddTag("halloweencandy")
        inst:AddTag("pre-preparedfood")

        local fp = candyinfo[num].floater
        MakeInventoryFloatable(inst, fp[1], fp[2], fp[3])

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("edible")
        inst.components.edible.foodtype = candyinfo[num].food
        inst.components.edible.hungervalue = candyinfo[num].hunger
        inst.components.edible.healthvalue = candyinfo[num].health
        inst.components.edible.sanityvalue = candyinfo[num].sanity

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("tradable")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        MakeHauntableLaunch(inst)

        inst:AddComponent("bait")

        return inst
    end

    -- NOTES(JBK): Use this to help export the bottom table to make this file findable.
    --print(string.format("%s %s", candyinfo[num].food or FOODTYPE.GENERIC, "halloweencandy_"..tostring(num)))
    return Prefab("halloweencandy_"..tostring(num), fn, assets, prefabs)
end

local ret = {}
for k = 1, NUM_HALLOWEENCANDY do
    table.insert(ret, MakeCandy(k))
end

return unpack(ret)

-- NOTES(JBK): These are here to make this file findable.
--[[
FOODTYPE.GOODIES halloweencandy_1
FOODTYPE.GOODIES halloweencandy_10
FOODTYPE.GOODIES halloweencandy_11
FOODTYPE.GOODIES halloweencandy_12
FOODTYPE.GOODIES halloweencandy_13
FOODTYPE.GOODIES halloweencandy_2
FOODTYPE.GOODIES halloweencandy_4
FOODTYPE.GOODIES halloweencandy_5
FOODTYPE.GOODIES halloweencandy_8
FOODTYPE.GOODIES halloweencandy_9
FOODTYPE.VEGGIE halloweencandy_14
FOODTYPE.VEGGIE halloweencandy_3
FOODTYPE.VEGGIE halloweencandy_6
FOODTYPE.VEGGIE halloweencandy_7
]]
