local straw_assets =
{
    Asset("ANIM", "anim/swap_bedroll_straw.zip"),
}

local furry_assets =
{
    Asset("ANIM", "anim/swap_bedroll_furry.zip"),
}

local function onwake(inst, sleeper, nostatechange)
    if inst.components.finiteuses == nil or inst.components.finiteuses:GetUses() <= 0 then
        if inst.components.stackable ~= nil then
            inst.components.stackable:Get():Remove()
        else
            inst:Remove()
        end
    end
end

local function onuse_straw(inst, sleeper)
    sleeper.AnimState:OverrideSymbol("swap_bedroll", "swap_bedroll_straw", "bedroll_straw")
end

local function onuse_furry(inst, sleeper)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        sleeper.AnimState:OverrideItemSkinSymbol("swap_bedroll", skin_build, "bedroll_furry", inst.GUID, "swap_bedroll_furry")
    else
        sleeper.AnimState:OverrideSymbol("swap_bedroll", "swap_bedroll_furry", "bedroll_furry")
    end
end

local function temperaturetick(inst, sleeper)
    if sleeper.components.temperature ~= nil then
        if inst.sleep_temp_min ~= nil and sleeper.components.temperature:GetCurrent() < inst.sleep_temp_min then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        elseif inst.sleep_temp_max ~= nil and sleeper.components.temperature:GetCurrent() > inst.sleep_temp_max then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
        end
    end
end

local function common_fn(bank, build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")

    local swap_data = {bank = bank, anim = "idle"}
    MakeInventoryFloatable(inst, "small", 0.2, 0.95, nil, nil, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeSmallBurnable(inst, TUNING.LONG_BURNABLE)
    MakeSmallPropagator(inst)

    inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onwake = onwake
    inst.components.sleepingbag:SetTemperatureTickFn(temperaturetick)


    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

local function bedroll_straw()
    local inst = common_fn("swap_bedroll_straw", "swap_bedroll_straw")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.sleepingbag.healthsleep = false
    inst.components.sleepingbag.sanity_tick = TUNING.SLEEP_SANITY_PER_TICK * .67

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst.onuse = onuse_straw

    return inst
end

local function bedroll_furry()
    local inst = common_fn("swap_bedroll_furry", "swap_bedroll_furry")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetConsumption(ACTIONS.SLEEPIN, 1)
    inst.components.finiteuses:SetMaxUses(3)
    inst.components.finiteuses:SetUses(3)

    inst.components.sleepingbag.sleep_temp_min = TUNING.SLEEP_TARGET_TEMP_BEDROLL_FURRY
    inst.components.sleepingbag.sleep_temp_max = TUNING.SLEEP_TARGET_TEMP_BEDROLL_FURRY * 1.5
    inst.onuse = onuse_furry

    return inst
end

return Prefab("bedroll_straw", bedroll_straw, straw_assets),
    Prefab("bedroll_furry", bedroll_furry, furry_assets)
