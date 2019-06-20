local assets =
{
    Asset("ANIM", "anim/quagmire_hoe.zip"),
}

local prefabs =
{
    "quagmire_soil",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("quagmire_hoe")
    inst.AnimState:SetBuild("quagmire_hoe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")

    if TheNet:GetServerGameMode() ~= "quagmire" then
        --weapon (from weapon component) added to pristine state for optimization
        inst:AddTag("weapon")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/quagmire_hoe").master_postinit(inst)

    return inst
end

return Prefab("quagmire_hoe", fn, assets, prefabs)
