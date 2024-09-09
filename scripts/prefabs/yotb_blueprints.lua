local assets =
{
    Asset("ANIM", "anim/blueprint_sewing_machine_yotb.zip"),
    Asset("INV_IMAGE", "blueprint_sewing_machine_yotb"),
}

local prefabs =
{
    "yotb_beefalo_doll_war",
    "yotb_beefalo_doll_doll",
    "yotb_beefalo_doll_festive",
    "yotb_beefalo_doll_nature",
    "yotb_beefalo_doll_robot",
    "yotb_beefalo_doll_ice",
    "yotb_beefalo_doll_formal",
    "yotb_beefalo_doll_victorian",
    "yotb_beefalo_doll_beast",
}

local function getprefab(inst)
    if inst.prefab == "war_blueprint" then
        return "yotb_beefalo_doll_war"
    elseif inst.prefab == "doll_blueprint" then
        return "yotb_beefalo_doll_doll"
    elseif inst.prefab == "festive_blueprint" then
        return "yotb_beefalo_doll_festive"
    elseif inst.prefab == "nature_blueprint" then
        return "yotb_beefalo_doll_nature"
    elseif inst.prefab == "robot_blueprint" then
        return "yotb_beefalo_doll_robot"
    elseif inst.prefab == "ice_blueprint" then
        return "yotb_beefalo_doll_ice"
    elseif inst.prefab == "formal_blueprint" then
        return "yotb_beefalo_doll_formal"
    elseif inst.prefab == "victorian_blueprint" then
        return "yotb_beefalo_doll_victorian"
    elseif inst.prefab == "beast_blueprint" then
        return "yotb_beefalo_doll_beast"
    end
end

local function makedoll(inst)
    local skin = getprefab(inst)
    if skin then
        local doll = SpawnPrefab(skin)
        inst.components.lootdropper:FlingItem(doll)
    end
end

local function MakeCostumeBlueprint(data)

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

		inst.AnimState:SetBuild("blueprint_sewing_machine_yotb")
		inst.AnimState:SetBank("blueprint_yotb")
        inst.AnimState:PlayAnimation("idle")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:ChangeImageName("blueprint_sewing_machine_yotb")

        inst:AddComponent("lootdropper")
		inst:AddComponent("erasablepaper")

        inst:AddComponent("yotb_skinunlocker")
        inst.components.yotb_skinunlocker:SetSkin(data.skin_name)

        inst.makedoll = makedoll

        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(data.prefab_name, fn, assets, prefabs)
end

local prefs = {}
for k, v in pairs(require("yotb_costumes").costumes) do
    if v.test ~= nil then
        table.insert(prefs, MakeCostumeBlueprint(v))
    end
end

return unpack(prefs)