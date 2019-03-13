local assets =
{
    Asset("ANIM", "anim/quagmire_elderswampig.zip"),
}

local prefabs =
{
    "axe",
    "shovel",
    "quagmire_hoe",
    "fertilizer",
    "quagmire_key",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 2, .5)

    inst.MiniMapEntity:SetIcon("pigking.png")
    inst.MiniMapEntity:SetPriority(1)

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    inst.AnimState:SetBank("quagmire_elderswampig")
    inst.AnimState:SetBuild("quagmire_elderswampig")
    inst.AnimState:PlayAnimation("sleep_loop", true)

    inst:AddTag("character")

    --Sneak these into pristine state for optimization
    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -600, 0)
    inst.components.talker:MakeChatter()

    inst.quagmire_shoptab = QUAGMIRE_RECIPETABS.QUAGMIRE_TRADER_ELDER

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_swampigelder").master_postinit(inst, prefabs)

    return inst
end

return Prefab("quagmire_swampigelder", fn, assets, prefabs)
