local assets_break =
{
    Asset("ANIM", "anim/fossilized.zip"),
}

local assets_fossilizing =
{
    Asset("ANIM", "anim/sinkhole_spawn_fx.zip"),
}

local prefabs_fossilizing =
{
    "fossilizing_fx_1",
    "fossilizing_fx_2",
}

--------------------------------------------------------------------------

local function breakfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBuild("fossilized")
    inst.AnimState:PlayAnimation("fossilized_break_fx")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", ErodeAway)

    return inst
end

--------------------------------------------------------------------------

local function PlayFossilizingAnim(proxy, anim)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        inst.entity:SetParent(parent.entity)
    end

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("sinkhole_spawn_fx")
    inst.AnimState:SetBuild("sinkhole_spawn_fx")
    inst.AnimState:PlayAnimation(anim)
    inst.AnimState:SetMultColour(.75, .5, .5, 1)
    inst.AnimState:SetFinalOffset(2)

    local s = (parent ~= nil and parent:GetPhysicsRadius() or .5) + 1
    inst.Transform:SetScale(s, s * 1.2, s)

    inst:ListenForEvent("animover", inst.Remove)
end

local function MakeFossilizingFX(name, anim, prefabs)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            if anim == nil then
                anim = tostring(math.random(2))
                inst:SetPrefabName("fossilizing_fx_"..anim)
                anim = "idle"..anim
            end
            inst:DoTaskInTime(0, PlayFossilizingAnim, anim)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets_fossilizing, prefabs)
end

--------------------------------------------------------------------------

return Prefab("fossilized_break_fx", breakfn, assets_break),
    MakeFossilizingFX("fossilizing_fx", nil, prefabs_fossilizing),
    MakeFossilizingFX("fossilizing_fx_1", "idle1"),
    MakeFossilizingFX("fossilizing_fx_2", "idle2")
