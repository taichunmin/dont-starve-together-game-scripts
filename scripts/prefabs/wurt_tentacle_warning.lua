local assets =
{
    Asset("ANIM", "anim/wurt_xray.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	--[[Non-networked entity]]

    inst.AnimState:SetBank("wurt_xray")
    inst.AnimState:SetBuild("wurt_xray")
    inst.AnimState:PlayAnimation("idle_pre")
    inst.AnimState:PushAnimation("idle_loop", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("DECOR")
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")

    inst.entity:SetCanSleep(false)
    inst.persists = false

    return inst
end

return Prefab("wurt_tentacle_warning", fn, assets)
