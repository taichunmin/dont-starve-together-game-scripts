local TREE_DEFS = require("prefabs/ancienttree_defs").TREE_DEFS

local gem_assets =
{
    Asset("ANIM", "anim/ancienttree_gem_fruit.zip"),
}

local nightvision_assets =
{
    Asset("ANIM", "anim/ancienttree_nightvision_fruit.zip"),
    Asset("IMAGE", "images/colour_cubes/nightvision_fruit_cc.tex"),
}

local nightvision_prefabs =
{
    "nightvision_buff",
    "ancientfruit_nightvision_cooked",
}

local GEMFRUIT_UPDATE_TIME = 2
local HATCH_TIMER_NAME = "hatch_timer"

local FIRE_MUST_TAGS = { "HASHEATER" }
local FIRE_MUST_NOT_TAGS = { "INLIMBO" }

local GEMS_WEIGHTED_LIST = {
    bluegem   = 4,
    redgem    = 4,
    purplegem = 3,
    greengem  = 1,
    orangegem = 1,
    yellowgem = 1,
}

local GEMS = {}

for gem, _ in pairs(GEMS_WEIGHTED_LIST) do
    GEMS[gem] = 0
end

local gem_prefabs = table.getkeys(GEMS)

local function GemFruit_OnUpdate(inst, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.HATCH_CAMPFIRE_RADIUS, FIRE_MUST_TAGS, FIRE_MUST_NOT_TAGS)
    local heatindex = 0

    for _, ent in ipairs(ents) do
        if ent.components.heater ~= nil and (ent.components.heater:IsExothermic() or ent.components.heater:IsEndothermic()) then -- Make sure they emit temperature.
            heatindex = heatindex + (ent.components.heater:GetHeat(inst) or 0) -- Cold fires produce negative heat.

            if heatindex >= TUNING.ANCIENTFRUIT_GEM_MIN_HEAT then
                inst._temperature = math.min(inst._temperature + dt, TUNING.ANCIENTFRUIT_GEM_TEMPERATURE_THRESHOLD.MAX)

                break
            end
        end
    end

    if heatindex < TUNING.ANCIENTFRUIT_GEM_MIN_HEAT then
        inst._temperature = math.max(inst._temperature - dt, 0)
    end

    if inst._temperature >= TUNING.ANCIENTFRUIT_GEM_TEMPERATURE_THRESHOLD.MIN then
        if inst._temperature >= TUNING.ANCIENTFRUIT_GEM_TEMPERATURE_THRESHOLD.HEATED then
            if not inst.AnimState:IsCurrentAnimation("heatin_loop") then
                inst.AnimState:PlayAnimation("heatin_loop")
                inst.AnimState:SetFrame(inst.AnimState:GetCurrentAnimationNumFrames())

            elseif math.random() > .75 and (inst._last_smoke_time == nil or (inst._last_smoke_time + 8) <= GetTime()) then
                inst._last_smoke_time = GetTime()
                inst.AnimState:PlayAnimation("heatin_loop")
            end

            inst.components.timer:ResumeTimer(HATCH_TIMER_NAME)

        elseif inst._temperature >= TUNING.ANCIENTFRUIT_GEM_TEMPERATURE_THRESHOLD.WARMED then
            if not inst.AnimState:IsCurrentAnimation("heating_2") then
                inst.AnimState:PlayAnimation("heating_2")
            end

            inst.components.timer:PauseTimer(HATCH_TIMER_NAME)

        elseif not inst.AnimState:IsCurrentAnimation("heating_1") then
            inst.AnimState:PlayAnimation("heating_1")

            inst.components.timer:PauseTimer(HATCH_TIMER_NAME)
        end
    else
        if not inst.AnimState:IsCurrentAnimation("idle") then
            inst.AnimState:PlayAnimation("idle")
        end

        inst.components.timer:PauseTimer(HATCH_TIMER_NAME)
    end
end

local function GemFruit_OnExitLimbo(inst)
    if inst:IsInLimbo() then
        return
    end

    if inst._inlimbo_time ~= nil then
        inst:_OnUpdate(GetTime() - inst._inlimbo_time)

        inst._inlimbo_time = nil
    end


    if inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end

    inst._task = inst:DoPeriodicTask(GEMFRUIT_UPDATE_TIME, inst._OnUpdate, 0, GEMFRUIT_UPDATE_TIME)
end

local function GemFruit_OnEnterLimbo(inst)
    inst.components.timer:PauseTimer(HATCH_TIMER_NAME)

    inst._inlimbo_time = GetTime()

    if inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end
end

local function GemFruit_OnSave(inst, data)
    if inst._temperature > 0 then
        data.temperature = inst._temperature

        if inst._inlimbo_time ~= nil then
            data.temperature = data.temperature - (GetTime() - inst._inlimbo_time)

            if data.temperature <= 0 then
                data.temperature = nil
            end
        end
    end
end

local function GemFruit_OnLoad(inst, data)
    if data.temperature ~= nil then
        inst._temperature = data.temperature

        inst:_OnUpdate(0)
    end
end

local function GemFruit_SpawnGem(inst, x, z, prefab)
    local y

    if x == nil or z == nil then
        x, y, z = inst.Transform:GetWorldPosition()
    end

    local gem = SpawnPrefab(prefab or weighted_random_choice(inst.GEMS_WEIGHTS))

    if gem ~= nil then
        gem.Transform:SetPosition(x, 0, z)
    end

    return gem -- Mods.
end

local function GemFruit_SpawnAndLaunchGems(inst)
    if inst.components.stackable == nil or not inst.components.stackable:IsStack() then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()

    -- Generate a list of prefabs to create first and optimize the loop by having every type here.
    local spawned_prefabs = shallowcopy(GEMS)

    local gem
    for _ = 1, inst.components.stackable:StackSize() do
        gem = weighted_random_choice(inst.GEMS_WEIGHTS)

        spawned_prefabs[gem] = spawned_prefabs[gem] + 1
    end

    -- Then create these prefabs while stacking them up as much as they are able to.
    local i, loot, room, stacksize
    for prefab, count in pairs(spawned_prefabs) do
        i = 1

        while i <= count do
            loot = inst:SpawnGem(x, z, prefab)
            room = loot.components.stackable ~= nil and loot.components.stackable:RoomLeft() or 0

            if room > 0 then
                stacksize = math.min(count - i, room) + 1
                loot.components.stackable:SetStackSize(stacksize)

                i = i + stacksize
            else
                i = i + 1
            end

            Launch2(loot, inst, 1.5, 1.25, 0.3, 0, 2)
        end
    end

    return spawned_prefabs -- Mods.
end

local function GemFruit_OnTimerDone(inst, data)
    if data == nil or data.name ~= HATCH_TIMER_NAME then
        return
    end

    if inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end

    inst.components.inventoryitem.canbepickedup = false

    inst.AnimState:PlayAnimation("breaking")
    inst.AnimState:SetFinalOffset(1)

    inst.SoundEmitter:PlaySound("meta4/ancienttree/gemfruit/fruit_break")

    if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
        inst:DoTaskInTime(13 * FRAMES, inst.SpawnAndLaunchGems)
    else
        inst:SpawnGem()
    end

    inst.persists = false
    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() - FRAMES, inst.Remove)
end

local function GemFruit_OnDestack(new, inst)
    new._temperature = inst._temperature

    if new._OnUpdate ~= nil then
        new:_OnUpdate(0)
    end
end

local function gem_fruit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("ancienttree_gem_fruit")
    inst.AnimState:SetBank("ancienttree_gem_fruit")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "rock"

    inst:AddTag("molebait")

    MakeInventoryPhysics(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._temperature = 0
    inst.GEMS_WEIGHTS = GEMS_WEIGHTED_LIST -- Mod friendly.

    inst.OnEnterLimbo = GemFruit_OnEnterLimbo
    inst.OnExitLimbo  = GemFruit_OnExitLimbo

    inst._OnUpdate = GemFruit_OnUpdate

    inst.OnTimerDone = GemFruit_OnTimerDone
    inst.SpawnGem = GemFruit_SpawnGem
    inst.SpawnAndLaunchGems = GemFruit_SpawnAndLaunchGems

    inst:AddComponent("bait")
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("tradable")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 3

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("stackable")
    inst.components.stackable:SetOnDeStack(GemFruit_OnDestack)
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("timer")
    inst.components.timer:StartTimer(HATCH_TIMER_NAME, TUNING.ANCIENTFRUIT_GEM_HATCH_TIME)

    inst._task = inst:DoPeriodicTask(GEMFRUIT_UPDATE_TIME, inst._OnUpdate, 0, GEMFRUIT_UPDATE_TIME)

    inst:ListenForEvent("enterlimbo", inst.OnEnterLimbo)
    inst:ListenForEvent("exitlimbo",  inst.OnExitLimbo)

    inst:ListenForEvent("timerdone", inst.OnTimerDone)

    inst.OnSave = GemFruit_OnSave
    inst.OnLoad = GemFruit_OnLoad

    MakeHauntableLaunch(inst)

    return inst
end

---------------------------------------------------------------------------------------------------------------------------------

local ANCIENTFRUIT_NIGHTVISION_COLOURCUBES =
{
    day = "images/colour_cubes/nightvision_fruit_cc.tex",
    dusk = "images/colour_cubes/nightvision_fruit_cc.tex",
    night = "images/colour_cubes/nightvision_fruit_cc.tex",
    full_moon = "images/colour_cubes/nightvision_fruit_cc.tex",

    nightvision_fruit = true, -- NOTES(DiogoW): Here for convinience.
}

local BEAT_SOUNDNAME = "BEAT_SOUND"

local function NightVision_OnEaten(inst, eater)
    if eater.components.playervision ~= nil then
        eater:AddDebuff("nightvision_buff", "nightvision_buff")
    end

    -- We don't want to knock out the target.
    if eater.components.grogginess ~= nil then
        eater.components.grogginess:MakeGrogginessAtLeast(1.5)
    end
end

local function NightVision_PlayBeatingSound(inst)
    inst.SoundEmitter:KillSound(BEAT_SOUNDNAME)
    inst.SoundEmitter:PlaySound("meta4/ancienttree/nightvision/fruit_pulse", BEAT_SOUNDNAME)
end

local function NightVision_DoBeatingBounce(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    if y >= .1 then
        return -- We are mid air!
    end

    local angle = math.random() * TWOPI
    local spd = math.random() * .5 + .5

    inst.Physics:SetVel(math.cos(angle) * spd, 5, math.sin(angle) * spd)
    inst.components.inventoryitem:SetLanded(false, true)
end

local function NightVision_OnEntityWake(inst)
    if inst._beatsoundtask ~= nil or inst:IsInLimbo() or inst:IsAsleep() then
        return
    end

    if inst._beatsoundtask ~= nil then
        inst._beatsoundtask:Cancel()
        inst._beatsoundtask = nil
    end

    if inst._beatbouncetask ~= nil then
        inst._beatbouncetask:Cancel()
        inst._beatbouncetask = nil
    end

    local fulltime    = inst.AnimState:GetCurrentAnimationLength()
    local currenttime = inst.AnimState:GetCurrentAnimationTime()

    inst:PlayBeatingSound() -- This one might be out of sync, but that's fine!

    inst._beatsoundtask  = inst:DoPeriodicTask(fulltime, inst.PlayBeatingSound, fulltime - currenttime             )
    inst._beatbouncetask = inst:DoPeriodicTask(fulltime, inst.DoBeatingBounce, (fulltime - currenttime) + 12*FRAMES)
end

local function NightVision_OnEntitySleep(inst)
    inst.SoundEmitter:KillSound(BEAT_SOUNDNAME)

    if inst._beatsoundtask ~= nil then
        inst._beatsoundtask:Cancel()
        inst._beatsoundtask = nil
    end

    if inst._beatbouncetask ~= nil then
        inst._beatbouncetask:Cancel()
        inst._beatbouncetask = nil
    end
end

local function nightvision_fruit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild("ancienttree_nightvision_fruit")
    inst.AnimState:SetBank("ancienttree_nightvision_fruit")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:SetLightOverride(0.1)
    inst.AnimState:SetSymbolLightOverride("fruit", 0.4)

    inst.pickupsound = "vegetation_firm"

    MakeInventoryFloatable(inst, "small", .08, .75)

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.PlayBeatingSound = NightVision_PlayBeatingSound
    inst.DoBeatingBounce = NightVision_DoBeatingBounce

    inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("tradable")

    inst:AddComponent("edible")
    inst.components.edible.hungervalue =  TUNING.CALORIES_SMALL
    inst.components.edible.healthvalue = -TUNING.HEALING_MEDSMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_MEDLARGE
    inst.components.edible:SetOnEatenFn(NightVision_OnEaten)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("cookable")
    inst.components.cookable.product = "ancientfruit_nightvision_cooked"

    inst.OnEntityWake  = NightVision_OnEntityWake
    inst.OnEntitySleep = NightVision_OnEntitySleep
    inst:ListenForEvent("exitlimbo",  inst.OnEntityWake)
    inst:ListenForEvent("enterlimbo", inst.OnEntitySleep)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

local function cooked_nightvision_fruit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild("ancienttree_nightvision_fruit")
    inst.AnimState:SetBank("ancienttree_nightvision_fruit")
    inst.AnimState:PlayAnimation("cooked", false)

    MakeInventoryFloatable(inst, "small", 0.1, 0.9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")
    inst.components.edible.hungervalue =  TUNING.CALORIES_MEDSMALL
    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_TINY

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

---------------------------------------------------------------------------------------------------------------------------------

local function buff_OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)

    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)

    if target.components.playervision ~= nil then
        target.components.playervision:PushForcedNightVision(inst, 1, ANCIENTFRUIT_NIGHTVISION_COLOURCUBES, true)
        inst._enabled:set(true)
    end

    if target.components.sanity ~= nil then
        target.components.sanity.externalmodifiers:SetModifier(inst, -TUNING.DAPPERNESS_MED_LARGE)
    end
end

local function buff_OnDetached(inst, target)
    if target ~= nil and target:IsValid() then
        if target.components.playervision ~= nil then
            target.components.playervision:PopForcedNightVision(inst)
            inst._enabled:set(false)
        end

        if target.components.sanity ~= nil then
            target.components.sanity.externalmodifiers:RemoveModifier(inst)
        end
    end

    -- NOTES(DiogoW): Delayed removal to let the client run the dirty event.
    inst:DoTaskInTime(10*FRAMES, inst.Remove)
end

local function buff_Expire(inst)
    if inst.components.debuff ~= nil then
        inst.components.debuff:Stop()
    end
end

local function buff_OnExtended(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.task = inst:DoTaskInTime(TUNING.ANCIENTTREE_NIGHTVISION_FRUIT_BUFF_DURATION, buff_Expire)
end

local function buff_OnSave(inst, data)
    if inst.task ~= nil then
        data.remaining = GetTaskRemaining(inst.task)
    end
end

local function buff_OnLoad(inst, data)
    if data == nil then
        return
    end

    if data.remaining then
        if inst.task ~= nil then
            inst.task:Cancel()
            inst.task = nil
        end

        inst.task = inst:DoTaskInTime(data.remaining, buff_Expire)
    end
end

local function buff_OnLongUpdate(inst, dt)
    if inst.task == nil then
        return
    end

    local remaining = GetTaskRemaining(inst.task) - dt

    inst.task:Cancel()

    if remaining > 0 then
        inst.task = inst:DoTaskInTime(remaining, buff_Expire)
    else
        buff_Expire(inst)
    end
end

local function buff_OnEnabledDirty(inst)
    if ThePlayer ~= nil and inst.entity:GetParent() == ThePlayer and ThePlayer.components.playervision ~= nil then
        if inst._enabled:value() then
            ThePlayer.components.playervision:PushForcedNightVision(inst, 1, ANCIENTFRUIT_NIGHTVISION_COLOURCUBES, true)
        else
            ThePlayer.components.playervision:PopForcedNightVision(inst)
        end
    end
end

local function fn_nightvisionbuff()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("CLASSIFIED")

    inst._enabled = net_bool(inst.GUID, "nightvision_buff._enabled", "enableddirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("enableddirty", buff_OnEnabledDirty)

        return inst
    end

    inst.entity:Hide()

    inst.persists = false

    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(buff_OnAttached)
    inst.components.debuff:SetDetachedFn(buff_OnDetached)
    inst.components.debuff:SetExtendedFn(buff_OnExtended)
    inst.components.debuff.keepondespawn = true

    buff_OnExtended(inst)

    inst.OnSave = buff_OnSave
    inst.OnLoad = buff_OnLoad

    inst.OnLongUpdate = buff_OnLongUpdate

    return inst
end


return
    Prefab("ancientfruit_gem",                gem_fruit_fn,                gem_assets,         gem_prefabs        ),
    Prefab("ancientfruit_nightvision",        nightvision_fruit_fn,        nightvision_assets, nightvision_prefabs),
    Prefab("ancientfruit_nightvision_cooked", cooked_nightvision_fruit_fn, nightvision_assets, nightvision_prefabs),
    Prefab("nightvision_buff",                fn_nightvisionbuff                                                  )