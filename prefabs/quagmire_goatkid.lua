local assets =
{
    Asset("ANIM", "anim/quagmire_goatkid_basic.zip"),
}

local prefabs =
{
    --"quagmire_pigeon_shop_item",
    "quagmire_salt_rack_item",
    "fishingrod",
    "trap",
    "birdtrap",
    "quagmire_crabtrap",
    "quagmire_slaughtertool",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .4)

    inst.DynamicShadow:SetSize(1.5, 0.75)

    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(.8, .8, .8)

    inst.AnimState:SetBank("quagmire_goatkid_basic")
    inst.AnimState:SetBuild("quagmire_goatkid_basic")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:Hide("hat")

    inst:AddTag("character")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()

    inst.quagmire_shoptab = QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_KID

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_goatkid").master_postinit(inst, prefabs)

    return inst
end

return Prefab("quagmire_goatkid", fn, assets, prefabs)
