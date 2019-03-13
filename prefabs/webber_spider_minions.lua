local assets =
{
    Asset("ANIM", "anim/ds_spider_basic.zip"),
    Asset("ANIM", "anim/spider_build.zip"),
    Asset("ANIM", "anim/spider_warrior_lavaarena_build.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local prefab =
{
    "die_fx",
}

local SCALE = .5

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .2)

    inst.DynamicShadow:SetSize(1.5 * SCALE, .25 * SCALE)

    inst.Transform:SetScale(SCALE, SCALE, SCALE)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("spider")
    inst.AnimState:SetBuild("spider_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst.SoundEmitter:OverrideVolumeMultiplier(.3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/webber_spider_minions").master_postinit(inst)

    return inst
end

return Prefab("webber_spider_minion", fn, assets, prefabs)
