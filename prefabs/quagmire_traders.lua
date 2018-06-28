local assets =
{
    Asset("ANIM", "anim/merm_trader1_build.zip"),
    Asset("ANIM", "anim/merm_trader2_build.zip"),
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
}

local prefabs_merm =
{
    "quagmire_seedpacket_2",
    "quagmire_seedpacket_5",
    "quagmire_seedpacket_6",
    "quagmire_seedpacket_4",
    "quagmire_seedpacket_1",
    "quagmire_seedpacket_mix",
    "quagmire_key_park",
}

local prefabs_merm2 =
{
    "quagmire_seedpacket_7",
    "quagmire_seedpacket_3",
    "quagmire_sapbucket",
    "quagmire_pot_syrup",
    "quagmire_pot",
    "quagmire_casseroledish",
    "quagmire_crate_grill",
}

local function commonfn(common_init)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pigman")
    inst.AnimState:SetBuild("merm_trader1_build")

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst:AddTag("character")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()

    if common_init ~= nil then
        common_init(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_traders").master_postinit(inst)

    return inst
end

local function mermfn()
    local inst = commonfn(function(inst)
        MakeObstaclePhysics(inst, 1)
        inst.Transform:SetRotation(-90)
        inst.quagmire_shoptab = QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM1
    end)

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_traders").master_postinit_merm(inst, prefabs_merm)

    return inst
end

local function merm2fn()
    local inst = commonfn(function(inst)
        inst.AnimState:SetBuild("merm_trader2_build")
        MakeObstaclePhysics(inst, .5)
        inst.quagmire_shoptab = QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_MERM2
    end)

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_traders").master_postinit_merm2(inst, prefabs_merm2)

    return inst
end

return Prefab("quagmire_trader_merm", mermfn, assets, prefabs_merm),
    Prefab("quagmire_trader_merm2", merm2fn, assets, prefabs_merm2)
