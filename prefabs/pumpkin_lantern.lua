local assets =
{
    Asset("ANIM", "anim/pumpkin_lantern.zip"),
}

local prefabs =
{
    "fireflies",
}

local FADE_FRAMES = 5
local FADE_INTENSITY = .8
local FADE_RADIUS = 1.5
local FADE_FALLOFF = .5

local function OnUpdateFlicker(inst, starttime)
    local time = (GetTime() - starttime) * 30
    local flicker = (math.sin(time) + math.sin(time + 2) + math.sin(time + 0.7777)) * .5 -- range = [-1 , 1]
    flicker = (1 + flicker) * .5 -- range = 0:1
    inst.Light:SetRadius(FADE_RADIUS + .1 * flicker)
end

local function OnUpdateFade(inst)
    local k
    if inst._fade:value() <= FADE_FRAMES then
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES))
        k = inst._fade:value() / FADE_FRAMES
    else
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES * 2 + 1))
        k = (FADE_FRAMES * 2 + 1 - inst._fade:value()) / FADE_FRAMES
    end

    inst.Light:SetIntensity(FADE_INTENSITY * k)
    inst.Light:SetRadius(FADE_RADIUS * k)
    inst.Light:SetFalloff(1 - (1 - FADE_FALLOFF) * k)

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._fade:value() > 0 and inst._fade:value() <= FADE_FRAMES * 2)
    end

    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end

    if inst._fade:value() == FADE_FRAMES then
        if inst._flickertask == nil then
            inst._flickertask = inst:DoPeriodicTask(.1, OnUpdateFlicker, 0, GetTime())
        end
    elseif inst._flickertask ~= nil then
        inst._flickertask:Cancel()
        inst._flickertask = nil
    end
end

local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end

local function FadeIn(inst, instant)
    if instant then
        if not inst.AnimState:IsCurrentAnimation("idle_night_loop") then
            inst.AnimState:PlayAnimation("idle_night_loop", true)
        end
        inst._fade:set(FADE_FRAMES)
        OnFadeDirty(inst)
    else
        if not (inst.AnimState:IsCurrentAnimation("idle_night_loop") or
                inst.AnimState:IsCurrentAnimation("idle_night_pre")) then
            inst.AnimState:PlayAnimation("idle_night_pre")
            inst.AnimState:PushAnimation("idle_night_loop", true)
        end
        inst._fade:set(
            inst._fade:value() <= FADE_FRAMES and
            inst._fade:value() or
            math.max(0, 2 * FRAMES + 1 - inst._fade:value())
        )
        if inst._fadetask == nil then
            inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
        end
    end
end

local function FadeOut(inst, instant)
    if instant then
        if not (inst.AnimState:IsCurrentAnimation("idle_day") or
                inst.components.health:IsDead()) then
            inst.AnimState:PlayAnimation("idle_day")
        end
        inst._fade:set(FADE_FRAMES * 2 + 1)
        OnFadeDirty(inst)
    else
        if not (inst.AnimState:IsCurrentAnimation("idle_night_pst") or
                inst.AnimState:IsCurrentAnimation("idle_day") or
                inst.components.health:IsDead()) then
            inst.AnimState:PlayAnimation("idle_night_pst")
            inst.AnimState:PushAnimation("idle_day", false)
        end
        inst._fade:set(
            inst._fade:value() > FADE_FRAMES and
            inst._fade:value() or
            2 * FADE_FRAMES + 1 - inst._fade:value()
        )
        if inst._fadetask == nil then
            inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
        end
    end
end

local function ondeath(inst)
    if inst._daytask ~= nil then
        inst._daytask:Cancel()
        inst._daytask = nil
    end
    FadeOut(inst, true)
    inst.components.perishable:StopPerishing()
    if not inst.AnimState:IsCurrentAnimation("rotten") then
        inst.AnimState:PlayAnimation("broken")
        inst.SoundEmitter:PlaySound("dontstarve/common/vegi_smash")
        inst.components.lootdropper:SpawnLootPrefab("fireflies")
    end
end

local function onperish(inst)
    inst.AnimState:PlayAnimation("rotten")
    inst.components.health:Kill()
end

local function CanFade(inst)
    return not (inst.components.inventoryitem:IsHeld() or inst.components.health:IsDead())
end

local function OnIsDay(inst, isday, delayed)
    if inst._daytask ~= nil then
        if not delayed then
            inst._daytask:Cancel()
        end
        inst._daytask = nil
    end
    if CanFade(inst) then
        if not delayed then
            inst._daytask = inst:DoTaskInTime(2 + math.random(), OnIsDay, isday, true)
        elseif isday then
            FadeOut(inst)
        else
            FadeIn(inst)
        end
    end
end

local function OnDropped(inst)
    if not inst.components.health:IsDead() then
        inst.components.perishable:StartPerishing()
    end
    if inst._daytask ~= nil then
        inst._daytask:Cancel()
        inst._daytask = nil
    end
    if not TheWorld.state.isday and CanFade(inst) then
        FadeIn(inst)
    else
        FadeOut(inst, true)
    end
end

local function OnPutInInventory(inst)
    inst.components.perishable:StopPerishing()
    if inst._daytask ~= nil then
        inst._daytask:Cancel()
        inst._daytask = nil
    end
    FadeOut(inst, true)
end

local function OnLoad(inst)
    if inst._daytask ~= nil then
        inst._daytask:cancel()
        inst._daytask = nil
    end
    if CanFade(inst) then
        if TheWorld.state.isday then
            FadeOut(inst, true)
        else
            FadeIn(inst, true)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("veggie")

    MakeInventoryPhysics(inst)

    inst.Light:SetFalloff(FADE_FALLOFF)
    inst.Light:SetIntensity(FADE_INTENSITY)
    inst.Light:SetRadius(FADE_RADIUS)
    inst.Light:SetColour(200/255, 100/255, 170/255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst.AnimState:SetBank("pumpkin")
    inst.AnimState:SetBuild("pumpkin_lantern")
    inst.AnimState:PlayAnimation("idle_day")

    inst._fade = net_smallbyte(inst.GUID, "pumpkin_lantern._fade", "fadedirty")
    inst._fade:set(FADE_FRAMES * 2 + 1)

    MakeInventoryFloatable(inst, "med", 0.1, 0.78)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", OnFadeDirty)

        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true

    inst:AddComponent("combat")
    inst:AddComponent("health")
    inst.components.health.canmurder = false
    inst:AddComponent("lootdropper")
    inst.components.health:SetMaxHealth(1)
    inst:ListenForEvent("death", ondeath)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and TUNING.PERISH_SUPERSLOW or TUNING.PERISH_MED)
    inst.components.perishable:SetOnPerishFn(onperish)
    inst.components.perishable:StartPerishing()

    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    inst:WatchWorldState("isday", OnIsDay)
    if not TheWorld.state.isday then
        FadeIn(inst)
    end

    inst.OnLoad = OnLoad

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

return Prefab("pumpkin_lantern", fn, assets, prefabs)
