local assets =
{
    Asset("ANIM", "anim/wurt_planar_casting_fx.zip"),
}

--------------------------------------------------------------------------------------------------------------

local function MakeFx(data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        if data.ismount then
            inst.Transform:SetSixFaced()
        else
            inst.Transform:SetFourFaced()
        end

        inst.AnimState:SetBank("wurt_planar_casting_fx")
        inst.AnimState:SetBuild("wurt_planar_casting_fx")
        inst.AnimState:PlayAnimation(data.anim)
        inst.AnimState:SetFinalOffset(1)

        if not TheNet:IsDedicated() and data.clientpostinit ~= nil then
            data.clientpostinit(inst, data)
        end

        if data.commonpostinit ~= nil then
            data.commonpostinit(inst, data)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end

    return Prefab(data.name, fn, assets)
end

--------------------------------------------------------------------------------------------------------------

local function CreateHorrorFuelCore(parent, data)
    local anim = "horrorfuel_top_cast".. (data.ismount and "_mount" or "")

    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    if data.ismount then
        inst.Transform:SetSixFaced()
    else
        inst.Transform:SetFourFaced()
    end

    inst.AnimState:SetBank("wurt_planar_casting_fx")
    inst.AnimState:SetBuild("wurt_planar_casting_fx")
    inst.AnimState:PlayAnimation(anim, false)

    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetLightOverride(.1)
    inst.AnimState:SetSymbolLightOverride("horror_fx", 0.5)

    inst.entity:SetParent(parent.entity)

    return inst
end

local function PureBrilliancePostInit(inst, data)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetSymbolLightOverride("pb_energy_loop", .3)
    inst.AnimState:SetSymbolLightOverride("pb_ray", .3)
    inst.AnimState:SetSymbolLightOverride("SparkleBit", .3)
    inst.AnimState:SetLightOverride(.1)
end

local function HorrorFuelPostInit(inst, data)
    inst.AnimState:SetMultColour(1, 1, 1, 0.5)
    inst.AnimState:SetSymbolLightOverride("horror_fx", 0.5)
    inst.AnimState:UsePointFiltering(true)
    inst.AnimState:SetLightOverride(.1)
end

--------------------------------------------------------------------------------------------------------------

return
    MakeFx({
        name = "purebrilliance_castfx",
        anim = "purebrilliance_cast",
        commonpostinit = PureBrilliancePostInit,
    }),
    MakeFx({
        name = "purebrilliance_castfx_mount",
        anim = "purebrillance_cast_mount",
        commonpostinit = PureBrilliancePostInit,
        ismount = true,
    }),
    MakeFx({
        name = "horrorfuel_castfx",
        anim = "horrorfuel_bottom_cast",
        commonpostinit = HorrorFuelPostInit,
        clientpostinit = CreateHorrorFuelCore,
    }),
    MakeFx({
        name = "horrorfuel_castfx_mount",
        anim = "horrorfuel_bottom_cast_mount",
        commonpostinit = HorrorFuelPostInit,
        clientpostinit = CreateHorrorFuelCore,
        ismount = true,
    })
