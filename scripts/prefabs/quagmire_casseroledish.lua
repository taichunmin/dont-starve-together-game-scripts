local prefabs =
{
    "quagmire_food",
    "quagmire_burnt_ingredients",
}

local function MakePot(suffix, numslots)
    local name = "quagmire_casseroledish"..suffix
    local assets =
    {
        Asset("ANIM", "anim/quagmire_grill.zip"),
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
        inst.AnimState:OverrideSymbol("goop", "quagmire_oven", "goop")
        inst.AnimState:Hide("goop")

        inst:AddTag("quagmire_stewer")
        inst:AddTag("quagmire_casseroledish")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("quagmire", "prefabs/quagmire_casseroledish").master_postinit(inst, suffix, numslots)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

--For searching: "quagmire_casseroledish", "quagmire_casseroledish_small"
return MakePot("", 4),
    MakePot("_small", 3)
