local assets_single =
{
    Asset("ANIM", "anim/bulb_plant_single.zip"),
}

local assets_double =
{
    Asset("ANIM", "anim/bulb_plant_double.zip"),
}

local prefabs =
{
    "lightbulb",
}

local FADE_FRAMES = 40
local FADE_INTENSITY = .8
local FADE_FALLOFF = .5

local function OnUpdateFade(inst)
    local k
    if inst._fade:value() <= FADE_FRAMES then
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES))
        k = inst._fade:value() / FADE_FRAMES
        k = k * k
    else
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES * 2 + 1))
        k = (FADE_FRAMES * 2 + 1 - inst._fade:value()) / FADE_FRAMES
    end

    inst.Light:SetIntensity(FADE_INTENSITY * k)
    inst.Light:SetRadius(inst._faderadius * k)
    inst.Light:SetFalloff(1 - (1 - FADE_FALLOFF) * k)

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._fade:value() > 0 and inst._fade:value() <= FADE_FRAMES * 2)
    end

    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
end

local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end

local function FadeOut(inst, instant)
    if instant then
        inst._fade:set(FADE_FRAMES * 2 + 1)
        OnFadeDirty(inst)
    elseif inst._fade:value() <= FADE_FRAMES then
        inst._fade:set(FADE_FRAMES * 2 + 1 - inst._fade:value())
        if inst._fadetask == nil then
            inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
        end
    end
end

local function KillPlant(inst)
    inst._killtask = nil
    inst.components.pickable.caninteractwith = false
    FadeOut(inst)
    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("wilt")
end

local function OnBloomed(inst)
    inst:RemoveEventCallback("animover", OnBloomed)
    inst.AnimState:PlayAnimation("idle", true)
    inst.components.pickable.caninteractwith = true
    inst._killtask = inst:DoTaskInTime(TUNING.STALKER_BLOOM_DECAY + math.random(), KillPlant)
end

local function OnPicked(inst)--, picker, loot)
    if inst._killtask ~= nil then
        inst._killtask:Cancel()
        inst._killtask = nil
    end
    FadeOut(inst, true)
    inst:RemoveEventCallback("animover", OnBloomed)
    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("picked_wilt")
end

local function commonfn(bank, build, radius)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Light:SetFalloff(FADE_FALLOFF)
    inst.Light:SetIntensity(FADE_INTENSITY)
    inst.Light:SetRadius(radius)
    inst.Light:SetColour(237 / 255, 237 / 255, 209 / 255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("bloom")

    inst:AddTag("plant")
    inst:AddTag("stalkerbloom")

    inst._faderadius = radius
    inst._fade = net_byte(inst.GUID, "stalker_bulb._fade", "fadedirty")
    inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)

    inst:SetPrefabNameOverride("flower_cave")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", OnFadeDirty)

        return inst
    end

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/flowergrow")

    local color = .75 + math.random() * .25
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
    inst.components.pickable.onpickedfn = OnPicked
    inst.components.pickable.caninteractwith = false

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:ListenForEvent("animover", OnBloomed)

    ---------------------
    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)
    --Clear default handlers so we don't stomp our .persists flag
    inst.components.burnable:SetOnIgniteFn(nil)
    inst.components.burnable:SetOnExtinguishFn(nil)
    ---------------------

    MakeHauntableIgnite(inst)

    inst.persists = false

    return inst
end

local function single()
    local inst = commonfn("bulb_plant_single", "bulb_plant_single", 3)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.pickable:SetUp("lightbulb", 1000000)
    inst.components.pickable:Pause()

    return inst
end

local function double()
    local inst = commonfn("bulb_plant_double", "bulb_plant_double", 4.5)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.pickable:SetUp("lightbulb", 1000000, 2)
    inst.components.pickable:Pause()

    return inst
end

return Prefab("stalker_bulb", single, assets_single, prefabs),
    Prefab("stalker_bulb_double", double, assets_double, prefabs)
