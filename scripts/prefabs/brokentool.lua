local assets =
{
    Asset("ANIM", "anim/broken_tool.zip"),
}

local function PlayBrokenAnim(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("broketool")
    inst.AnimState:SetBuild("broken_tool")
    inst.AnimState:PlayAnimation("used")

    inst:ListenForEvent("animover", inst.Remove)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    --Delay one frame so that we are positioned properly before starting the effect
    --or in case we are about to be removed
    inst:DoTaskInTime(0, PlayBrokenAnim)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

return Prefab("brokentool", fn, assets)
