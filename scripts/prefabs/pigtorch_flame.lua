local assets =
{
    --Asset("ANIM", "anim/fire_large_character.zip"),
    Asset("ANIM", "anim/campfire_fire.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "firefx_light",
}

local firelevels =
{
    {anim="level1", sound="dontstarve/common/campfire", radius=3, intensity=.8, falloff=.44, colour = {255/255,255/255,192/255}, soundintensity=.1},
    {anim="level2", sound="dontstarve/common/campfire", radius=4, intensity=.8, falloff=.44, colour = {255/255,255/255,192/255}, soundintensity=.6},
    {anim="level3", sound="dontstarve/common/campfire", radius=5, intensity=.8, falloff=.44, colour = {255/255,255/255,192/255}, soundintensity=1},
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("campfire_fire")
    inst.AnimState:SetBuild("campfire_fire")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("firefx")
    inst.components.firefx.levels = firelevels

    return inst
end

return Prefab("pigtorch_flame", fn, assets, prefabs)
