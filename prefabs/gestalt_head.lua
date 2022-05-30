local assets =
{
    Asset("ANIM", "anim/brightmare_gestalt_head.zip"),
}

local assets_guard =
{
    Asset("ANIM", "anim/brightmare_gestalt_head_evolved.zip"),
}

local function fn(bank)

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(bank)
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

return Prefab("gestalt_head", function() return fn("brightmare_gestalt_head") end, assets),
		Prefab("gestalt_guard_head", function() return fn("brightmare_gestalt_head_evolved") end, assets_guard)

