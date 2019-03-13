local assets =
{
    Asset("ANIM", "anim/quagmire_crate.zip"),
}

local KIT_NAMES =
{
    "pot_hanger",
    "oven",
    "grill_small",
    "grill",
}
local KITS = table.invert(KIT_NAMES)

local KIT_ITEMS =
{
    ["pot_hanger"] =
    {
        "quagmire_pot_hanger_item",
        "quagmire_pot_small",
    },
    ["oven"] =
    {
        "quagmire_oven_item",
        "quagmire_casseroledish_small",
    },
    ["grill_small"] =
    {
        "quagmire_grill_small_item",
    },
    ["grill"] =
    {
        "quagmire_grill_item",
    },
}

local function displaynamefn(inst)
    return STRINGS.NAMES[string.upper("quagmire_crate_"..(KIT_NAMES[inst._kitid:value()]))]
end

local function MakeCrate(kit)
    local prefabs
    if kit ~= nil then
        prefabs =
        {
            "quagmire_crate",
        }
        for i, v in ipairs(KIT_ITEMS[kit]) do
            table.insert(prefabs, v)
        end
    else
        prefabs =
        {
            "ash",
            "quagmire_crate_unwrap",
        }
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("quagmire_crate")
        inst.AnimState:SetBuild("quagmire_crate")
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("bundle")

        --unwrappable (from unwrappable component) added to pristine state for optimization
        inst:AddTag("unwrappable")

        inst._kitid = net_tinybyte(inst.GUID, "quagmire_crate._kitid", "productdirty")
        inst.displaynamefn = displaynamefn
        if kit ~= nil then
            inst:SetPrefabName("quagmire_crate")
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_crates").master_postinit(inst, kit, KIT_NAMES, KITS, KIT_ITEMS)

        return inst
    end

    return Prefab("quagmire_crate"..(kit ~= nil and ("_"..kit) or ""), fn, assets, prefabs)
end

local ret =
{
    MakeCrate(),
}
for i, v in ipairs(KIT_NAMES) do
    table.insert(ret, MakeCrate(v))
end
return unpack(ret)
