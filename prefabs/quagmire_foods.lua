local prefabs =
{
    "quagmire_food_plate_goop",
    "quagmire_food_bowl_goop",
    "quagmire_salting_plate_fx",
    "quagmire_salting_bowl_fx",
}

local DISH_NAMES =
{
    "plate",
    "bowl",
}
local DISH_IDS = table.invert(DISH_NAMES)

local function LoadKeys(inst, name)
    if QUAGMIRE_USE_KLUMP then
        LoadKlumpFile("images/quagmire_food_inv_images_"..name..".tex", inst.klumpkey:value())
        LoadKlumpFile("images/quagmire_food_inv_images_hires_"..name..".tex", inst.klumpkey:value())
        LoadKlumpFile("anim/dynamic/"..name..".dyn", inst.klumpkey:value())
        LoadKlumpString("STRINGS.NAMES."..string.upper(name), inst.klumpkey:value())
    end
end

local function OnKeyDirty(inst)
    LoadKeys(inst, inst.prefab)
    inst.name = STRINGS.NAMES[string.upper(inst.prefab)]
    inst:PushEvent("imagechange")
end

local function OnDishDirty(inst)
    inst.basedish = DISH_NAMES[inst.basedishid:value()]
    inst.inv_image_bg.image = inst.basedish..(inst.replate:value():len() > 0 and ("_"..inst.replate:value()..".tex") or ".tex")
    inst:PushEvent("imagechange")
end

local function DisplayNameFn(inst)
    return inst:HasTag("quagmire_salted") and subfmt(STRINGS.NAMES.QUAGMIRE_SALTED_FOOD_FMT, { food = inst.name }) or nil
end

local function MakeFood(name)
    local assets =
    {
        Asset("ANIM", "anim/quagmire_generic_plate.zip"),
        Asset("ANIM", "anim/quagmire_generic_bowl.zip"),
        Asset("ATLAS", "images/quagmire_food_common_inv_images.xml"),
        Asset("IMAGE", "images/quagmire_food_common_inv_images.tex"),

        Asset("DYNAMIC_ATLAS", "images/quagmire_food_inv_images_"..name..".xml"),
        Asset("DYNAMIC_ATLAS", "images/quagmire_food_inv_images_hires_"..name..".xml"),
        Asset("DYNAMIC_ANIM", "anim/dynamic/"..name..".zip"),
    }
    if QUAGMIRE_USE_KLUMP then
        table.insert( assets, Asset("PKGREF", "klump/images/quagmire_food_inv_images_"..name..".tex") )
        table.insert( assets, Asset("PKGREF", "klump/images/quagmire_food_inv_images_hires_"..name..".tex") )
        table.insert( assets, Asset("PKGREF", "klump/anim/dynamic/"..name..".dyn") )
        table.insert( assets, Asset("PKGREF", "klump/strings/STRINGS.NAMES."..string.upper(name)) )
    else
        table.insert( assets, Asset("PKGREF", "images/quagmire_food_inv_images_"..name..".tex") )
        table.insert( assets, Asset("PKGREF", "images/quagmire_food_inv_images_hires_"..name..".tex") )
        table.insert( assets, Asset("PKGREF", "anim/dynamic/"..name..".dyn") )
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("quagmire_generic_plate")
        inst.AnimState:SetBuild("quagmire_generic_plate")
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:OverrideSymbol("swap_food", name, "swap_food")

        inst:AddTag("preparedfood")
        inst:AddTag("quagmire_stewable")
        inst:AddTag("quagmire_replatable")
        inst:AddTag("quagmire_saltable")

        inst.klumpkey = net_string(inst.GUID, name..".klumpkey", "keydirty")
        inst.replate = net_string(inst.GUID, name..".replate", "dishdirty")
        inst.basedishid = net_tinybyte(inst.GUID, name..".basedishid", "dishdirty")
        inst.basedish = "plate"
        inst.basedishid:set(DISH_IDS[inst.basedish])
        inst.inv_image_bg = { atlas = "images/quagmire_food_common_inv_images.xml", image = "plate.tex" }

        inst.displaynamefn = DisplayNameFn

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("keydirty", OnKeyDirty)
            inst:ListenForEvent("dishdirty", OnDishDirty)

            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_foods").master_postinit(inst, name, DISH_NAMES, DISH_IDS, LoadKeys, OnDishDirty)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local prefs, ret = {}, {}
for i = 1, QUAGMIRE_NUM_FOOD_PREFABS do
    local name = string.format("quagmire_food_%03i", i)
    table.insert(prefs, name)
    table.insert(ret, MakeFood(name))
end
table.insert(ret, Prefab("quagmire_food", function() end, nil, prefs))
prefs = nil
return unpack(ret)
