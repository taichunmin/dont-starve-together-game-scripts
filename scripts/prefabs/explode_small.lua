local assets =
{
    Asset("ANIM", "anim/explode.zip")
}

local function MakeExplosion(data)
    local function PlayExplodeAnim(proxy)
        local inst = CreateEntity()

        inst:AddTag("FX")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        inst.Transform:SetFromProxy(proxy.GUID)

        if data ~= nil and data.scale ~= nil then
            inst.Transform:SetScale(data.scale, data.scale, data.scale)
        end

        inst.AnimState:SetBank(data ~= nil and data.bank or "explode")
        inst.AnimState:SetBuild(data ~= nil and data.build or "explode")
        if data ~= nil and data.skin_build ~= nil then
            inst.AnimState:OverrideItemSkinSymbol(data.skin_symbol, data.skin_build, "shadow_dust", inst.GUID, "explode") --"explode" is unused here
        end

        inst.AnimState:PlayAnimation(data ~= nil and data.anim or "small")
        if data ~= nil and data.bloom ~= false then
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end
        inst.AnimState:SetLightOverride(data ~= nil and data.light_override or 1)

        if data ~= nil and type(data.sound) == "function" then
            data.sound(inst)
        else
            inst.SoundEmitter:PlaySound(data ~= nil and data.sound or "dontstarve/common/blackpowder_explo")
        end

        inst:ListenForEvent("animover", inst.Remove)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            inst:DoTaskInTime(0, PlayExplodeAnim)
        end

        inst.Transform:SetFourFaced()

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return fn
end

local extras =
{
    reskin =
    {
        bank = "fx_shadow_dust",
        build = "reskin_tool_fx",
        anim = "puff",
        sound = "dontstarve/common/together/reskin_tool",
    },
    reskin_brush =
    {
        bank = "fx_shadow_dust",
        skin_build = "reskin_tool_brush",
        skin_symbol = "shadow_dust",
        anim = "puff",
        sound = "terraria1/skins/spectrepaintbrush",
        bloom = false,
        light_override = 0,
    },
    reskin_bouquet =
    {
        bank = "fx_shadow_dust",
        skin_build = "reskin_tool_bouquet",
        skin_symbol = "shadow_dust",
        anim = "puff",
        sound = "dontstarve/common/together/reskin_tool",
        bloom = false,
        light_override = 0,
    },
    slurtle =
    {
        sound = "dontstarve/creatures/slurtle/explode",
    },
    slurtlehole =
    {
        sound = "dontstarve/creatures/slurtle/mound_explode",
    },
    firecrackers =
    {
        anim = "small_firecrackers",
        sound = function(inst)
            inst.SoundEmitter:PlaySoundWithParams("dontstarve/common/together/fire_cracker", { start = math.random() })
        end,
        scale = .5,
    },
}

return Prefab("explode_small", MakeExplosion(), assets),
    Prefab("explode_reskin", MakeExplosion(extras.reskin), assets),
    Prefab("reskin_tool_brush_explode_fx", MakeExplosion(extras.reskin_brush), assets),
    Prefab("reskin_tool_bouquet_explode_fx", MakeExplosion(extras.reskin_bouquet), assets),
    Prefab("explode_small_slurtle", MakeExplosion(extras.slurtle), assets),
    Prefab("explode_small_slurtlehole", MakeExplosion(extras.slurtlehole), assets),
    Prefab("explode_firecrackers", MakeExplosion(extras.firecrackers), assets)

