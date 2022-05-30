local assets =
{
    Asset("ANIM", "anim/coldfire_fire.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "firefx_light",
}

local lightColour = { 0, 183 / 255, 1 }
local heats = { -10, -20, -30, -40 }
local function GetHeatFn(inst)
    return heats[inst.components.firefx.level] or -20
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("coldfire_fire")
    inst.AnimState:SetBuild("coldfire_fire")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetFinalOffset(3)

    inst:AddTag("FX")

    --HASHEATER (from heater component) added to pristine state for optimization
    inst:AddTag("HASHEATER")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn
    inst.components.heater:SetThermics(false, true)

    inst:AddComponent("firefx")
    inst.components.firefx.levels =
    {
        { anim = "level1", sound = "dontstarve_DLC001/common/coldfire", radius = 2, intensity = .8, falloff = .33, colour = lightColour, soundintensity = .1 },
        { anim = "level2", sound = "dontstarve_DLC001/common/coldfire", radius = 3, intensity = .8, falloff = .33, colour = lightColour, soundintensity = .3 },
        { anim = "level3", sound = "dontstarve_DLC001/common/coldfire", radius = 4, intensity = .8, falloff = .33, colour = lightColour, soundintensity = .6 },
        { anim = "level4", sound = "dontstarve_DLC001/common/coldfire", radius = 5, intensity = .8, falloff = .33, colour = lightColour, soundintensity = 1 },
    }
    inst.components.firefx:SetLevel(1)
    inst.components.firefx.usedayparamforsound = true

    return inst
end

return Prefab("coldfirefire", fn, assets, prefabs)
