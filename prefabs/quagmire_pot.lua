local prefabs =
{
    "quagmire_food",
    "quagmire_burnt_ingredients",
}

local function MakePot(suffix, goop_suffix, numslots, tag)
    local name = "quagmire_pot"..suffix
    local assets =
    {
        Asset("ANIM", "anim/quagmire_pot_hanger.zip"),
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("ANIM", "anim/quagmire_ui_pot_1x"..tostring(numslots)..".zip"),
        Asset("INV_IMAGE", name.."_overcooked"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:OverrideSymbol("goop"..goop_suffix, "quagmire_pot_hanger", "goop"..goop_suffix)
        inst.AnimState:Hide("goop")

        inst:AddTag("quagmire_stewer")
        inst:AddTag("quagmire_pot")

        if tag ~= nil then
            inst:AddTag(tag)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_pot").master_postinit(inst, suffix, numslots)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

--For searching: "quagmire_pot", "quagmire_pot_small", "quagmire_pot_syrup"
return MakePot("", "", 4),
    MakePot("_small", "", 3),
    MakePot("_syrup", "_syrup", 3, "quagmire_syrup_cooker")
