local module_definitions = require("wx78_moduledefs").module_definitions

local assets =
{
    Asset("ANIM", "anim/wx_chips.zip"),

    Asset("SCRIPT", "scripts/wx78_moduledefs.lua"),
}

local function on_module_removed(inst)
    if inst.components.finiteuses ~= nil then
        inst.components.finiteuses:Use()
    end
end

local function MakeModule(data)
    local prefabs = {}
    if data.extra_prefabs ~= nil then
        for _, extra_prefab in ipairs(data.extra_prefabs) do
            table.insert(prefabs, extra_prefab)
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("chips")
        inst.AnimState:SetBuild("wx_chips")
        inst.AnimState:PlayAnimation(data.name)
        inst.scrapbook_anim = data.name

        if data.slots > 4 then
            MakeInventoryFloatable(inst, "med", 0.1, 0.75)
        else
            MakeInventoryFloatable(inst, nil, 0.1, (data.slots == 1 and 0.75) or 1.0)
        end

        --------------------------------------------------------------------------
        -- For client-side access to information that should not be mutated
        inst._netid = data.module_netid
        inst._slots = data.slots

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        --------------------------------------------------------------------------
        inst:AddComponent("inspectable")

        --------------------------------------------------------------------------
        inst:AddComponent("inventoryitem")

        --------------------------------------------------------------------------
        inst:AddComponent("upgrademodule")
        inst.components.upgrademodule:SetRequiredSlots(data.slots)
        inst.components.upgrademodule.onactivatedfn = data.activatefn
        inst.components.upgrademodule.ondeactivatedfn = data.deactivatefn
        inst.components.upgrademodule.onremovedfromownerfn = on_module_removed

        --------------------------------------------------------------------------
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TUNING.WX78_MODULE_USES)
        inst.components.finiteuses:SetUses(TUNING.WX78_MODULE_USES)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        return inst
    end

    return Prefab("wx78module_"..data.name, fn, assets, prefabs)
end

local module_prefabs = {}
for _, def in ipairs(module_definitions) do
    table.insert(module_prefabs, MakeModule(def))
end

return unpack(module_prefabs)
