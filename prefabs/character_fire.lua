local assets =
{
    Asset("ANIM", "anim/fire_large_character.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "firefx_light",
}

local heats = { 50, 65, 80 }

local function GetHeatFn(inst)
    return heats[inst.components.firefx.level] or 40
end

local firelevels =
{
    {anim="loop_small", pre="pre_small", pst="post_small", sound="dontstarve/common/campfire", radius=2, intensity=.6, falloff=.7, colour = {197/255,197/255,170/255}, soundintensity=1},
    {anim="loop_med", pre="pre_med", pst="post_med",  sound="dontstarve/common/treefire", radius=3, intensity=.75, falloff=.5, colour = {255/255,255/255,192/255}, soundintensity=1},
    {anim="loop_large", pre="pre_large", pst="post_large",  sound="dontstarve/common/forestfire", radius=4, intensity=.8, falloff=.33, colour = {197/255,197/255,170/255}, soundintensity=1},
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fire_large_character")
    inst.AnimState:SetBuild("fire_large_character")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetFinalOffset(FINALOFFSET_MAX)

    inst:AddTag("FX")

    --HASHEATER (from heater component) added to pristine state for optimization
    inst:AddTag("HASHEATER")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("firefx")
    inst.components.firefx.levels = firelevels

    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn

    return inst
end

return Prefab("character_fire", fn, assets, prefabs)
