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

    inst:AddTag("FX")
    --[[Non-networked entity]]
    --Should be following parent's sleep state
    --inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(bank)
    inst.AnimState:PlayAnimation("idle", true)

    inst.Transform:SetFourFaced()

    return inst
end

return Prefab("gestalt_head", function() return fn("brightmare_gestalt_head") end, assets),
		Prefab("gestalt_guard_head", function() return fn("brightmare_gestalt_head_evolved") end, assets_guard)

