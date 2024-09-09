local assets_plate =
{
    Asset("ANIM", "anim/quagmire_generic_plate.zip"),
    Asset("ATLAS", "images/quagmire_food_common_inv_images.xml"),
    Asset("IMAGE", "images/quagmire_food_common_inv_images.tex"),
}

local assets_bowl =
{
    Asset("ANIM", "anim/quagmire_generic_bowl.zip"),
    Asset("ATLAS", "images/quagmire_food_common_inv_images.xml"),
    Asset("IMAGE", "images/quagmire_food_common_inv_images.tex"),
}

local prefabs_plate =
{
    "quagmire_salting_plate_fx",
}

local prefabs_bowl =
{
    "quagmire_salting_bowl_fx",
}

local function DisplayNameFn(inst)
    return inst:HasTag("quagmire_salted") and subfmt(STRINGS.NAMES.QUAGMIRE_SALTY_FOOD_FMT, { food = STRINGS.NAMES[string.upper(inst.nameoverride)] }) or nil
end

local function MakeFood(dish, food, assets, prefabs)
    local function OnReplateDirty(inst)
        inst.inv_image_bg.image = dish..(inst.replate:value():len() > 0 and ("_"..inst.replate:value()..".tex") or ".tex")
        inst:PushEvent("imagechange")
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("quagmire_generic_"..dish)
        inst.AnimState:SetBuild("quagmire_generic_"..dish)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:OverrideSymbol("swap_food", "quagmire_generic_"..dish, food)

        inst:AddTag("show_spoiled")
        inst:AddTag("overcooked")
        inst:AddTag("quagmire_stewable")
        inst:AddTag("quagmire_replatable")
        inst:AddTag("quagmire_saltable")

        inst.replate = net_string(inst.GUID, "quagmire_food_"..dish..".replate", "replatedirty")
        inst.inv_image_bg = { atlas = "images/quagmire_food_common_inv_images.xml", image = dish..".tex" }

        inst:SetPrefabNameOverride(food == "goop" and "wetgoop" or ("quagmire_food_"..food))

        inst.displaynamefn = DisplayNameFn

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("replatedirty", OnReplateDirty)

            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_food_burnt").master_postinit(inst, dish, food, OnReplateDirty)

        return inst
    end

    return Prefab("quagmire_food_"..dish.."_"..food, fn, assets, prefabs)
end

return MakeFood("plate", "burnt", assets_plate, prefabs_plate),
    MakeFood("plate", "goop", assets_plate, prefabs_plate),
    MakeFood("bowl", "burnt", assets_bowl, prefabs_bowl),
    MakeFood("bowl", "goop", assets_bowl, prefabs_bowl)
