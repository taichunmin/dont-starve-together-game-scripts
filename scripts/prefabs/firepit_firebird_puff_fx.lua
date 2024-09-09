local assets =
{
    Asset("ANIM", "anim/campfire_fire.zip"),
    Asset("DYNAMIC_ANIM", "anim/dynamic/firepit_firebird.zip"),
    Asset("PKGREF", "anim/dynamic/firepit_firebird.dyn"),
}

local function PlayPuffAnim(proxy)
    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        local inst = CreateEntity()

        inst:AddTag("FX")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst.entity:SetParent(parent.entity)
        inst.Transform:SetFromProxy(proxy.GUID)

        inst.AnimState:SetBank("firepit_firebird")
        inst.AnimState:SetBuild("campfire_fire")
        inst.AnimState:OverrideItemSkinSymbol("fire_puff", "firepit_firebird", "fire_puff", parent.GUID, "campfire_fire")
        inst.AnimState:PlayAnimation("puff"..tostring(proxy.level:value()))
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(3)

        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        --Delay one frame so that we are positioned properly before starting the effect
        --or in case we are about to be removed
        inst:DoTaskInTime(0, PlayPuffAnim)
    end

    inst.level = net_tinybyte(inst.GUID, "firepit_firebird_puff_fx.level")
    inst.level:set(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

return Prefab("firepit_firebird_puff_fx", fn, assets)
