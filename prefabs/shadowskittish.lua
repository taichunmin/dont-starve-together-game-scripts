local assets =
{
	Asset("ANIM", "anim/shadow_skittish.zip"),
}

local function Disappear(inst)
    if inst.deathtask ~= nil then
        inst.deathtask:Cancel()
        inst.deathtask = nil
        inst.AnimState:PlayAnimation("disappear")
        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function fn()
    local inst = CreateEntity()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("shadowcreatures")
    inst.AnimState:SetBuild("shadow_skittish")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(1, 1, 1, 0)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(5, 8)
    inst.components.playerprox:SetOnPlayerNear(Disappear)

    inst:AddComponent("transparentonsanity")

    inst.deathtask = inst:DoTaskInTime(5 + 10 * math.random(), Disappear)

    return inst
end

return Prefab("shadowskittish", fn, assets)