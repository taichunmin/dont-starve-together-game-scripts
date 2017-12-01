local assets =
{
    Asset("ANIM", "anim/cane_shadow_fx.zip"),
}

local NUM_VARIATIONS = 3
local MIN_SCALE = 1
local MAX_SCALE = 1.8

local function PlayShadowAnim(proxy, anim, scale, flip)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("cane_shadow_fx")
    inst.AnimState:SetBuild("cane_shadow_fx")
    inst.AnimState:SetScale(flip and -scale or scale, scale)
    inst.AnimState:SetMultColour(1, 1, 1, .5)
    inst.AnimState:PlayAnimation(anim)

    inst:ListenForEvent("animover", inst.Remove)
end

local function OnRandDirty(inst)
    if inst._complete or inst._rand:value() <= 0 then
        return
    end

    --Delay one frame in case we are about to be removed
    local flip = inst._rand:value() > 31
    local scale = MIN_SCALE + (MAX_SCALE - MIN_SCALE) * (flip and inst._rand:value() - 32 or inst._rand:value() - 1) / 30
    inst:DoTaskInTime(0, PlayShadowAnim, "shad"..inst.variation, scale, flip)
end

local function DisableNetwork(inst)
    inst.Network:SetClassifiedTarget(inst)
end

local function MakeShadowFX(name, num, prefabs)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("shadowtrail")

        inst.variation = tostring(num or math.random(NUM_VARIATIONS))

        inst._rand = net_smallbyte(inst.GUID, "shadow_trail._rand", "randdirty")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            inst._complete = false
            inst:ListenForEvent("randdirty", OnRandDirty)
        end

        if num == nil then
            inst:SetPrefabName(name..inst.variation)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(.5, DisableNetwork)
        inst:DoTaskInTime(1.5, inst.Remove)

        inst._rand:set(math.random(62))

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local ret = {}
local prefs = {}
for i = 1, NUM_VARIATIONS do
    local name = "cane_ancient_fx"..tostring(i)
    table.insert(prefs, name)
    table.insert(ret, MakeShadowFX(name, i))
end
table.insert(ret, MakeShadowFX("cane_ancient_fx", nil, prefs))
prefs = nil

--For searching: "cane_ancient_fx1", "cane_ancient_fx2", "cane_ancient_fx3"
return unpack(ret)
