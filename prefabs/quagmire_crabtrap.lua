local assets =
{
    Asset("ANIM", "anim/quagmire_crab_trap.zip"),
    Asset("SCRIPT", "scripts/prefabs/wortox_soul_common.lua"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("birdtrap.png")

    inst.AnimState:SetBank("quagmire_crab_trap")
    inst.AnimState:SetBuild("quagmire_crab_trap")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("trap")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_crabtrap").master_postinit(inst)

    return inst
end

return Prefab("quagmire_crabtrap", fn, assets)
