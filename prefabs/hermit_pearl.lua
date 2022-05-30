local assets =
{
    Asset("ANIM", "anim/hermit_pearl.zip"),
}

local prefabs =
{

}

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("irreplaceable")

	MakeInventoryFloatable(inst, "med", .15, 0.7)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    MakeHauntableLaunch(inst)

    return inst
end

local function fn()
    local inst = commonfn()
    inst:AddTag("gem")

    inst.AnimState:SetBank("hermit_pearl")
    inst.AnimState:SetBuild("hermit_pearl")
    inst.AnimState:PlayAnimation("idle")

    return inst
end
local function crackedfn()
    local inst = commonfn()

    inst.AnimState:SetBank("hermit_pearl")
    inst.AnimState:SetBuild("hermit_pearl")
    inst.AnimState:PlayAnimation("cracked")

    return inst
end

return Prefab("hermit_pearl", fn, assets, prefabs),
       Prefab("hermit_cracked_pearl", crackedfn, assets, prefabs)