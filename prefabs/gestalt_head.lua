local assets =
{
    Asset("ANIM", "anim/brightmare_gestalt_head.zip"),
}

local prefabs =
{

}

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.AnimState:SetBank("brightmare_gestalt_head")
    inst.AnimState:SetBuild("brightmare_gestalt_head")     
    inst.AnimState:PlayAnimation("idle", true)

    inst.Transform:SetFourFaced()

	inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

    return inst
end

return Prefab("gestalt_head", fn, assets, prefabs)
