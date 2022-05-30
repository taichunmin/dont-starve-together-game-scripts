--Raw/ cooked versions
--Can not transform.

local assets =
{
    Asset("ANIM", "anim/mandrake.zip"),
}

local prefabs =
{
    "mandrake_active",
}

local function onpickup(inst)
    inst.AnimState:PlayAnimation("object")
end

local SLEEPTARGETS_CANT_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO" }
local SLEEPTARGETS_ONEOF_TAGS = { "sleeper", "player" }

local function doareasleep(inst, range, time)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, range, nil, SLEEPTARGETS_CANT_TAGS, SLEEPTARGETS_ONEOF_TAGS)
    local canpvp = not inst:HasTag("player") or TheNet:GetPVPEnabled()
    for i, v in ipairs(ents) do
        if (v == inst or canpvp or not v:HasTag("player")) and
            not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and
            not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) and
            not (v.components.fossilizable ~= nil and v.components.fossilizable:IsFossilized()) then
            local mount = v.components.rider ~= nil and v.components.rider:GetMount() or nil
            if mount ~= nil then
                mount:PushEvent("ridersleep", { sleepiness = 7, sleeptime = time + math.random() })
            end
            if v:HasTag("player") then
                v:PushEvent("yawn", { grogginess = 4, knockoutduration = time + math.random() })
            elseif v.components.sleeper ~= nil then
                v.components.sleeper:AddSleepiness(7, time + math.random())
            elseif v.components.grogginess ~= nil then
                v.components.grogginess:AddGrogginess(4, time + math.random())
            else
                v:PushEvent("knockedout")
            end
        end
    end
end

local function oneaten_raw(inst, eater)
    eater.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/death")
    eater:DoTaskInTime(0.5, function()
        doareasleep(eater, TUNING.MANDRAKE_SLEEP_RANGE, TUNING.MANDRAKE_SLEEP_TIME)
    end)
end

local function oncooked(inst, cooker, chef)
    chef.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/death")
    chef:DoTaskInTime(0.5, function()
        doareasleep(chef, TUNING.MANDRAKE_SLEEP_RANGE_COOKED, TUNING.MANDRAKE_SLEEP_TIME)
    end)
end

local function oneaten_cooked(inst, eater)
    eater.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/death")
    eater:DoTaskInTime(0.5, function()
        doareasleep(eater, TUNING.MANDRAKE_SLEEP_RANGE_COOKED, TUNING.MANDRAKE_SLEEP_TIME)
    end)
end

local function commonfn(anim, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mandrake")
    inst.AnimState:SetBuild("mandrake")
    inst.AnimState:PlayAnimation(anim)

    if cookable then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    MakeInventoryFloatable(inst, "med", 0.2, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("tradable")

    if cookable then
        inst:AddComponent("cookable")
        inst.components.cookable.product = "cookedmandrake"
        inst.components.cookable:SetOnCookedFn(oncooked)
    end

    return inst
end

local function rawfn()
    local inst = commonfn("object", true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_HUGE
    inst.components.edible.hungervalue = TUNING.CALORIES_HUGE
    inst.components.edible:SetOnEatenFn(oneaten_raw)

    inst.components.inventoryitem:SetOnPickupFn(onpickup)

    return inst
end

local function cookedfn()
    local inst = commonfn("cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_SUPERHUGE
    inst.components.edible.hungervalue = TUNING.CALORIES_SUPERHUGE
    inst.components.edible:SetOnEatenFn(oneaten_cooked)

    return inst
end

return Prefab("mandrake", rawfn, assets, prefabs),
    Prefab("cookedmandrake", cookedfn, assets)
