local assets =
{
    Asset("ANIM", "anim/heat_rock.zip"),
    Asset("INV_IMAGE", "heat_rock1"),
    Asset("INV_IMAGE", "heat_rock2"),
    Asset("INV_IMAGE", "heat_rock3"),
    Asset("INV_IMAGE", "heat_rock4"),
    Asset("INV_IMAGE", "heat_rock5"),
}

local function OnSave(inst, data)
    if inst.highTemp ~= nil then
        data.highTemp = math.ceil(inst.highTemp)
    elseif inst.lowTemp ~= nil then
        data.lowTemp = math.floor(inst.lowTemp)
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.highTemp ~= nil then
            inst.highTemp = data.highTemp
            inst.lowTemp = nil
        elseif data.lowTemp ~= nil then
            inst.lowTemp = data.lowTemp
            inst.highTemp = nil
        end
    end
end

local function OnRemove(inst)
    inst._light:Remove()
    if IsSteam() then -- Only Steam consoles will not get logs so this would be wasted memory for them.
        inst._JBK_DEBUG_TRACE = _TRACEBACK() -- FIXME(JBK): Remove this when no longer needed.
    end
end

-- These represent the boundaries between the ranges (relative to ambient, so ambient is always "0")
local relative_temperature_thresholds = { -30, -10, 10, 30 }

local function GetRangeForTemperature(temp, ambient)
    local range = 1
    for i,v in ipairs(relative_temperature_thresholds) do
        if temp > ambient + v then
            range = range + 1
        end
    end
    return range
end

-- Heatrock emits constant temperatures depending on the temperature range it's in
local emitted_temperatures = { -10, 10, 25, 40, 60 }

local function HeatFn(inst, observer)
    local range = GetRangeForTemperature(inst.components.temperature:GetCurrent(), TheWorld.state.temperature)
    if range <= 2 then
        inst.components.heater:SetThermics(false, true)
    elseif range >= 4 then
        inst.components.heater:SetThermics(true, false)
    else
        inst.components.heater:SetThermics(false, false)
    end
    return emitted_temperatures[range]
end

local function GetStatus(inst)
    if inst.currentTempRange == 1 then
        return "FROZEN"
    elseif inst.currentTempRange == 2 then
        return "COLD"
    elseif inst.currentTempRange == 4 then
        return "WARM"
    elseif inst.currentTempRange == 5 then
        return "HOT"
    end
end

local function UpdateImages(inst, range)
    inst.currentTempRange = range

    inst.AnimState:PlayAnimation(tostring(range), true)
    inst.scrapbook_anim = tostring(range)
    local skinname = inst:GetSkinName()
    inst.components.inventoryitem:ChangeImageName((skinname or "heat_rock")..tostring(range))
    if range == 5 then
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst._light.Light:Enable(true)
    else
        inst.AnimState:ClearBloomEffectHandle()
        inst._light.Light:Enable(false)
    end
end

local function AdjustLighting(inst, range, ambient)
    if inst._JBK_DEBUG_TRACE then -- FIXME(JBK): Remove this when no longer needed.
        -- This is not important enough for a crash this issue has been around for a while and it generates log file bloat.
        print(">>> A thermal stone somehow deleted its light entity but still exists and is a bad state.")
        print(">>> Please add a bug report with this log file to help diagnose what went wrong!")
        print("--- Trace:")
        print(inst._JBK_DEBUG_TRACE)
        print("<<< Please add a bug report with this log file to help diagnose what went wrong!")
        inst._JBK_DEBUG_TRACE = nil
        return
    end
    if range == 5 then
        local relativetemp = inst.components.temperature:GetCurrent() - ambient
        local baseline = relativetemp - relative_temperature_thresholds[4]
        local brightline = relative_temperature_thresholds[4] + 20
        inst._light.Light:SetIntensity( math.clamp(0.5 * baseline/brightline, 0, 0.5 ) )
    else
        inst._light.Light:SetIntensity(0)
    end
end

local function TemperatureChange(inst, data)
    local ambient_temp = TheWorld.state.temperature
    local cur_temp = inst.components.temperature:GetCurrent()
    local range = GetRangeForTemperature(cur_temp, ambient_temp)

    AdjustLighting(inst, range, ambient_temp)

    if range <= 1 then
        if inst.lowTemp == nil or inst.lowTemp > cur_temp then
            inst.lowTemp = math.floor(cur_temp)
        end
        inst.highTemp = nil
    elseif range >= 5 then
        if inst.highTemp == nil or inst.highTemp < cur_temp then
            inst.highTemp = math.ceil(cur_temp)
        end
        inst.lowTemp = nil
    elseif inst.lowTemp ~= nil then
        if GetRangeForTemperature(inst.lowTemp, ambient_temp) >= 3 then
            inst.lowTemp = nil
        end
    elseif inst.highTemp ~= nil and GetRangeForTemperature(inst.highTemp, ambient_temp) <= 3 then
        inst.highTemp = nil
    end

    if range ~= inst.currentTempRange then
        UpdateImages(inst, range)

        if (inst.lowTemp ~= nil and range >= 3) or
            (inst.highTemp ~= nil and range <= 3) then
            inst.lowTemp = nil
            inst.highTemp = nil
            inst.components.fueled:SetPercent(inst.components.fueled:GetPercent() - 1 / TUNING.HEATROCK_NUMUSES)
        end
    end
end

local function OnOwnerChange(inst)
    local newowners = {}
    local owner = inst
    while owner.components.inventoryitem ~= nil do
        newowners[owner] = true

        if inst._owners[owner] then
            inst._owners[owner] = nil
        else
            inst:ListenForEvent("onputininventory", inst._onownerchange, owner)
            inst:ListenForEvent("ondropped", inst._onownerchange, owner)
        end

        local nextowner = owner.components.inventoryitem.owner
        if nextowner == nil then
            break
        end

        owner = nextowner
    end

	if owner:HasTag("pocketdimension_container") or owner:HasTag("buried") then
		inst._light.entity:SetParent(inst.entity)
		if not inst._light:IsInLimbo() then
			inst._light:RemoveFromScene()
		end
	else
		inst._light.entity:SetParent(owner.entity)
		if inst._light:IsInLimbo() then
			inst._light:ReturnToScene()
		end
	end

    for k, v in pairs(inst._owners) do
        if k:IsValid() then
            inst:RemoveEventCallback("onputininventory", inst._onownerchange, k)
            inst:RemoveEventCallback("ondropped", inst._onownerchange, k)
        end
    end

    inst._owners = newowners
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("heat_rock")
    inst.AnimState:SetBuild("heat_rock")

    inst:AddTag("heatrock")
    inst:AddTag("icebox_valid")

    inst:AddTag("bait")
    inst:AddTag("molebait")

    --HASHEATER (from heater component) added to pristine state for optimization
    inst:AddTag("HASHEATER")

    MakeInventoryFloatable(inst, "small", 0.2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_fueled_rate = TUNING.HEATROCK_NUMUSES
    inst.scrapbook_fueled_uses = true

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")
    inst.components.tradable.rocktribute = 12

    inst:AddComponent("temperature")
    inst.components.temperature.current = TheWorld.state.temperature
    inst.components.temperature.inherentinsulation = TUNING.INSULATION_MED
    inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_MED
    inst.components.temperature:IgnoreTags("heatrock")

    inst:AddComponent("heater")
    inst.components.heater.heatfn = HeatFn
    inst.components.heater.carriedheatfn = HeatFn
    inst.components.heater.carriedheatmultiplier = TUNING.HEAT_ROCK_CARRIED_BONUS_HEAT_FACTOR
    inst.components.heater:SetThermics(false, false)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(100)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    inst:ListenForEvent("temperaturedelta", TemperatureChange)
    inst.currentTempRange = 0

    --Create light
    inst._light = SpawnPrefab("heatrocklight")
    inst._owners = {}
    inst._onownerchange = function() OnOwnerChange(inst) end
    --

    UpdateImages(inst, 3)
    OnOwnerChange(inst)

    MakeHauntableLaunchAndSmash(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnRemoveEntity = OnRemove

    return inst
end

local function lightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235 / 255, 165 / 255, 12 / 255)
    inst.Light:Enable(false)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("heatrock", fn, assets),
    Prefab("heatrocklight", lightfn)
