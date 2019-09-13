local straw_assets =
{
    Asset("ANIM", "anim/swap_bedroll_straw.zip"),
}

local furry_assets =
{
    Asset("ANIM", "anim/swap_bedroll_furry.zip"),
}

--We don't watch "stopnight" because that would not work in a clock
--without night phase
local function wakeuptest(inst, phase)
    if phase ~= "night" then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function onwake(inst, sleeper, nostatechange)
    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
        inst.sleeptask = nil
    end

    inst:StopWatchingWorldState("phase", wakeuptest)

    if not nostatechange then
        if sleeper.sg:HasStateTag("bedroll") then
            sleeper.sg.statemem.iswaking = true
        end
        sleeper.sg:GoToState("wakeup")
    end

    if inst.components.finiteuses == nil or inst.components.finiteuses:GetUses() <= 0 then
        if inst.components.stackable ~= nil then
            inst.components.stackable:Get():Remove()
        else
            inst:Remove()
        end
    end
end

local function onsleeptick(inst, sleeper)
    local isstarving = false

    if sleeper.components.hunger ~= nil then
        sleeper.components.hunger:DoDelta(TUNING.SLEEP_HUNGER_PER_TICK, true, true)
        isstarving = sleeper.components.hunger:IsStarving()
    end

    if sleeper.components.sanity ~= nil and sleeper.components.sanity:GetPercentWithPenalty() < 1 then
        sleeper.components.sanity:DoDelta(inst.sanity_tick, true)
    end

    if not isstarving and inst.components.sleepingbag.healthsleep and sleeper.components.health ~= nil then
        sleeper.components.health:DoDelta(TUNING.SLEEP_HEALTH_PER_TICK, true, "bedroll", true)
    end

    if sleeper.components.temperature ~= nil then
        if inst.sleep_temp_min ~= nil and sleeper.components.temperature:GetCurrent() < inst.sleep_temp_min then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        elseif inst.sleep_temp_max ~= nil and sleeper.components.temperature:GetCurrent() > inst.sleep_temp_max then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
        end
    end

    if isstarving then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function onsleep(inst, sleeper)
    -- check if we're in an invalid period (i.e. daytime). if so: wakeup
    inst:WatchWorldState("phase", wakeuptest)

    if inst.sleeptask ~= nil then
        inst.sleeptask:Cancel()
    end
    inst.sleeptask = inst:DoPeriodicTask(TUNING.SLEEP_TICK_PERIOD, onsleeptick, nil, sleeper)
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

local function common_fn(bank, build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.2, 0.95)

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
    inst.components.sleepingbag.onsleep = onsleep
    inst.components.sleepingbag.onwake = onwake

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

local function bedroll_straw()
    local inst = common_fn("swap_bedroll_straw", "swap_bedroll_straw")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst.sanity_tick = TUNING.SLEEP_SANITY_PER_TICK * .67
    --inst.temperature_target = nil
    inst.components.sleepingbag.healthsleep = false
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

    inst.sanity_tick = TUNING.SLEEP_SANITY_PER_TICK
    inst.sleep_temp_min = TUNING.SLEEP_TARGET_TEMP_BEDROLL_FURRY
    inst.sleep_temp_max = TUNING.SLEEP_TARGET_TEMP_BEDROLL_FURRY * 1.5
    inst.onuse = onuse_furry

    return inst
end

return Prefab("bedroll_straw", bedroll_straw, straw_assets),
    Prefab("bedroll_furry", bedroll_furry, furry_assets)
