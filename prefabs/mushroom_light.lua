require("prefabutil")
require("prefabs/mushtree_spores")

local prefabs =
{
    "collapse_small",
}

local function IsLightOn(inst)
    return inst.Light:IsEnabled()
end

local light_str =
{
    {radius = 2.5, falloff = .85, intensity = 0.75},
    {radius = 3.25, falloff = .85, intensity = 0.75},
    {radius = 4.25, falloff = .85, intensity = 0.75},
    {radius = 5.5, falloff = .85, intensity = 0.75},
}
local fulllight_light_str =
{
    radius = 5.5, falloff = 0.85, intensity = 0.75
}

local colour_tint = { 0.4, 0.3, 0.25, 0.2, 0.1 }
local mult_tint = { 0.7, 0.6, 0.55, 0.5, 0.45 }

local sounds_1 =
{
    toggle = "dontstarve/common/together/mushroom_lamp/lantern_1_on",
    craft = "dontstarve/common/together/mushroom_lamp/craft_1",
}
local sounds_2 =
{
    toggle = "dontstarve/common/together/mushroom_lamp/lantern_2_on",
    colour = "dontstarve/common/together/mushroom_lamp/change_colour",
    craft = "dontstarve/common/together/mushroom_lamp/craft_2",
}

local function ClearSoundQueue(inst)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
        inst._soundtask = nil
    end
end

local function OnQueuedSound(inst, soundname)
    inst._soundtask = nil
    inst.SoundEmitter:PlaySound(soundname)
end

local function QueueSound(inst, delay, soundname)
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
    end
    inst._soundtask = inst:DoTaskInTime(delay, OnQueuedSound, soundname)
end

local COLOURED_LIGHTS =
{
    red =
    {
        [MUSHTREE_SPORE_RED] = true,
        ["winter_ornament_light1"] = true,
        ["winter_ornament_light5"] = true,
    },

    green =
    {
        [MUSHTREE_SPORE_GREEN] = true,
        ["winter_ornament_light2"] = true,
        ["winter_ornament_light6"] = true,
    },

    blue =
    {
        [MUSHTREE_SPORE_BLUE] = true,
        ["winter_ornament_light3"] = true,
        ["winter_ornament_light7"] = true,
    },
}

local function IsRedSpore(item)
    if COLOURED_LIGHTS.red[item.prefab] then
        return true
    elseif item.components.container ~= nil then
        return item.components.container:FindItem(IsRedSpore) ~= nil
    else
        return false
    end
end

local function IsGreenSpore(item)
    if COLOURED_LIGHTS.green[item.prefab] then
        return true
    elseif item.components.container ~= nil then
        return item.components.container:FindItem(IsGreenSpore) ~= nil
    else
        return false
    end
end

local function IsBlueSpore(item)
    if COLOURED_LIGHTS.blue[item.prefab] then
        return true
    elseif item.components.container ~= nil then
        return item.components.container:FindItem(IsBlueSpore) ~= nil
    else
        return false
    end
end

local function is_battery_type(item)
    return item:HasTag("lightbattery")
        or item:HasTag("spore")
        or item:HasTag("lightcontainer")
end

local function is_fulllighter(item)
    return item:HasTag("fulllighter")
end

local function UpdateLightState(inst)
    if inst:HasTag("burnt") then
        return
    end

    ClearSoundQueue(inst)

    local sound = inst.onlywhite and sounds_1 or sounds_2
    local num_batteries = #inst.components.container:FindItems(is_battery_type)
    local was_on = IsLightOn(inst)

    if num_batteries > 0 then
        local num_fulllights = #inst.components.container:FindItems(is_fulllighter)

        local new_perishrate = (num_fulllights > 0 and 0) or TUNING.PERISH_MUSHROOM_LIGHT_MULT
        inst.components.preserver:SetPerishRateMultiplier(new_perishrate)

        if num_fulllights > 0 then
            inst.Light:SetRadius(fulllight_light_str.radius)
            inst.Light:SetFalloff(fulllight_light_str.falloff)
            inst.Light:SetIntensity(fulllight_light_str.intensity)
        else
            inst.Light:SetRadius(light_str[num_batteries].radius)
            inst.Light:SetFalloff(light_str[num_batteries].falloff)
            inst.Light:SetIntensity(light_str[num_batteries].intensity)
        end

        if not inst.onlywhite then
            -- For the GlowCap, spores will tint the light colour to allow for a disco/rave in your base
            local r = #inst.components.container:FindItems(IsRedSpore)
            local g = #inst.components.container:FindItems(IsGreenSpore)
            local b = #inst.components.container:FindItems(IsBlueSpore)

            inst.Light:SetColour(colour_tint[g+b + 1] + r/11, colour_tint[r+b + 1] + g/11, colour_tint[r+g + 1] + b/11)
            inst.AnimState:SetMultColour(mult_tint[g+b + 1], mult_tint[r+b + 1], mult_tint[r+g + 1], 1)
        end

        if not was_on then
            inst.Light:Enable(true)
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        end

        if POPULATING then
            inst.AnimState:PlayAnimation("idle_on")
        elseif not was_on or inst.onlywhite then
            inst.AnimState:PlayAnimation("turn_on")
            inst.AnimState:PushAnimation("idle_on", false)
            inst.SoundEmitter:PlaySound(sound.toggle)
        else
            inst.AnimState:PlayAnimation("colour_change")
            inst.AnimState:PushAnimation("idle_on", false)
            inst.SoundEmitter:PlaySound(sound.toggle)
            QueueSound(inst, 13 * FRAMES, sound.colour)
        end
    else
        inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_MUSHROOM_LIGHT_MULT)

        inst.Light:Enable(false)
        inst.AnimState:ClearBloomEffectHandle()
        inst.AnimState:SetMultColour(.7, .7, .7, 1)
        if POPULATING then
            inst.AnimState:PlayAnimation("idle")
        elseif was_on then
            inst.AnimState:PlayAnimation("turn_off")
            inst.AnimState:PushAnimation("idle", false)
            inst.SoundEmitter:PlaySound(sound.toggle)
        end
    end
end

local function onworkfinished(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    inst:Remove()
end

local function onworked(inst, worker, workleft)
    if workleft > 0 and not inst:HasTag("burnt") then
        ClearSoundQueue(inst)
        inst.AnimState:PlayAnimation(IsLightOn(inst) and "hit_on" or "hit")
        inst.AnimState:PushAnimation(IsLightOn(inst) and "idle_on" or "idle", false)

        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
            inst.components.container:Close()
        end
    end
end

local function onbuilt(inst)
    ClearSoundQueue(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound(inst.onlywhite and sounds_1.craft or sounds_2.craft)
end

local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
           or (IsLightOn(inst) and "ON")
           or "OFF"
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function MakeMushroomLight(name, onlywhite, physics_rad)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("ANIM", "anim/ui_lamp_1x4.zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

		inst:SetDeploySmartRadius(0.5) --recipe min_spacing/2

        MakeObstaclePhysics(inst, physics_rad)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetMultColour(.7, .7, .7, 1)

        inst.Light:SetColour(.65, .65, .5)
        inst.Light:Enable(false)

        inst:AddTag("structure")
        inst:AddTag("lamp")

        MakeSnowCoveredPristine(inst)

        inst.scrapbook_specialinfo = "MUSHROOMLIGHT"

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.onlywhite = onlywhite

        MakeSmallBurnable(inst, nil, nil, true)
        MakeSmallPropagator(inst)
        MakeHauntableWork(inst)
        MakeSnowCovered(inst)

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onworkfinished)
        inst.components.workable:SetOnWorkCallback(onworked)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

        inst:AddComponent("lootdropper")

        inst:AddComponent("container")
        inst.components.container:WidgetSetup(name)

		inst:AddComponent("preserver")
		inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_MUSHROOM_LIGHT_MULT)

        inst:ListenForEvent("onbuilt", onbuilt)
        inst:ListenForEvent("itemget", UpdateLightState)
        inst:ListenForEvent("itemlose", UpdateLightState)
        inst:ListenForEvent("burntup", ClearSoundQueue)

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeMushroomLight("mushroom_light", true, .25),
       MakeMushroomLight("mushroom_light2", false, .4),
       MakePlacer("mushroom_light_placer", "mushroom_light", "mushroom_light", "idle"),
       MakePlacer("mushroom_light2_placer", "mushroom_light2", "mushroom_light2", "idle")
