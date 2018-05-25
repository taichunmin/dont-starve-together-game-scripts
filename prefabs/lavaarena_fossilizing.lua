local assets =
{
    Asset("ANIM", "anim/sinkhole_spawn_fx.zip"),
}

local prefabs_fossilizing =
{
    "lavaarena_fossilizedebris",
}

--------------------------------------------------------------------------

local NUM_DEBRIS_VARIATIONS = 3

local function UpdateDebrisTint(inst, delta)
    if inst.tint > delta then
        inst.tint = inst.tint - delta
        local c = 1 - inst.tint
        inst.AnimState:SetMultColour(.8 + .2 * c, c, c, 1)
    else
        inst.AnimState:SetMultColour(1, 1, 1, 1)
        inst.tinttask:Cancel()
        inst.tinttask = nil
    end
end

local function PlayDebrisAnim(proxy, variation)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("sinkhole_spawn_fx")
    inst.AnimState:SetBuild("sinkhole_spawn_fx")
    inst.AnimState:PlayAnimation("idle"..tostring(variation))

    inst.tint = 1
    inst.tinttask = inst:DoPeriodicTask(0, UpdateDebrisTint, nil, .1)
    UpdateDebrisTint(inst, 0)

    inst:ListenForEvent("animover", inst.Remove)
end

local function MakeFossilizeDebris(name, variation, prefabs)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("lavaarena_fossilizedebris")

        local v = variation or math.random(NUM_DEBRIS_VARIATIONS)
        if variation == nil then
            inst:SetPrefabName(name..tostring(v))
        end
        inst:SetPrefabNameOverride("lavaarena_fossilizedebris")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            inst:DoTaskInTime(0, PlayDebrisAnim, v)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(.3, inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local ret = {}
local prefs = {}
for i = 1, NUM_DEBRIS_VARIATIONS do
    local name = "lavaarena_fossilizedebris"..tostring(i)
    table.insert(prefs, name)
    table.insert(ret, MakeFossilizeDebris(name, i))
end
table.insert(ret, MakeFossilizeDebris("lavaarena_fossilizedebris", nil, prefs))
prefs = nil

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/lavaarena_fossilizing").master_postinit(inst)

    return inst
end

table.insert(ret, Prefab("lavaarena_fossilizing", fn, nil, prefabs_fossilizing))

--------------------------------------------------------------------------

--For searching: "lavaarena_fossilizedebris1", "lavaarena_fossilizedebris2", "lavaarena_fossilizedebris3"
return unpack(ret)
