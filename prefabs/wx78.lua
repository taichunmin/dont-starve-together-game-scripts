local MakePlayerCharacter = require("prefabs/player_common")
local WX78MoistureMeter = require("widgets/wx78moisturemeter")
local easing = require("easing")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),

    Asset("SOUND", "sound/wx78.fsb"),

    Asset("ANIM", "anim/player_idles_wx.zip"),
    Asset("ANIM", "anim/wx_upgrade.zip"),
    Asset("ANIM", "anim/player_mount_wx78_upgrade.zip"),
    Asset("ANIM", "anim/wx_fx.zip"),
}

local prefabs =
{
    "cracklehitfx",
    "gears",
    "sparks",
    "wx78_big_spark",
    "wx78_heat_steam",
    "wx78_moduleremover",
    "wx78_musicbox_fx",
    "wx78_scanner_item",
}

local WX78ModuleDefinitionFile = require("wx78_moduledefs")
local GetWX78ModuleByNetID = WX78ModuleDefinitionFile.GetModuleDefinitionFromNetID

local WX78ModuleDefinitions = WX78ModuleDefinitionFile.module_definitions
for mdindex, module_def in ipairs(WX78ModuleDefinitions) do
    table.insert(prefabs, "wx78module_"..module_def.name)
end

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WX78
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

----------------------------------------------------------------------------------------

local CHARGEREGEN_TIMERNAME = "chargeregenupdate"
local MOISTURETRACK_TIMERNAME = "moisturetrackingupdate"
local HUNGERDRAIN_TIMERNAME = "hungerdraintick"
local HEATSTEAM_TIMERNAME = "heatsteam_tick"

----------------------------------------------------------------------------------------

local function CLIENT_GetEnergyLevel(inst)
    if inst.components.upgrademoduleowner ~= nil then
        return inst.components.upgrademoduleowner.charge_level
    elseif inst.player_classified ~= nil then
        return inst.player_classified.currentenergylevel:value()
    else
        return 0
    end
end

local function get_plugged_module_indexes(inst)
    local upgrademodule_defindexes = {}
    for _, module in ipairs(inst.components.upgrademoduleowner.modules) do
        table.insert(upgrademodule_defindexes, module._netid)
    end

    -- Fill out the rest of the table with 0s
    while #upgrademodule_defindexes < TUNING.WX78_MAXELECTRICCHARGE do
        table.insert(upgrademodule_defindexes, 0)
    end

    return upgrademodule_defindexes
end

local DEFAULT_ZEROS_MODULEDATA = {0, 0, 0, 0, 0, 0}
local function CLIENT_GetModulesData(inst)
    local data = nil

    if inst.components.upgrademoduleowner ~= nil then
        data = get_plugged_module_indexes(inst)
    elseif inst.player_classified ~= nil then
        data = {}
        for _, module_netvar in ipairs(inst.player_classified.upgrademodules) do
            table.insert(data, module_netvar:value())
        end
    else
        data = DEFAULT_ZEROS_MODULEDATA
    end

    return data
end

local function CLIENT_CanUpgradeWithModule(inst, module_prefab)
    if module_prefab == nil then
        return false
    end

    local slots_inuse = (module_prefab._slots or 0)

    if inst.components.upgrademoduleowner ~= nil then
        for _, module in ipairs(inst.components.upgrademoduleowner.modules) do
            local modslots = (module.components.upgrademodule ~= nil and module.components.upgrademodule.slots)
                or 0
            slots_inuse = slots_inuse + modslots
        end
    elseif inst.player_classified ~= nil then
        for _, module_netvar in ipairs(inst.player_classified.upgrademodules) do
            local module_definition = GetWX78ModuleByNetID(module_netvar:value())
            if module_definition ~= nil then
                slots_inuse = slots_inuse + module_definition.slots
            end
        end
    else
        return false
    end

    return (TUNING.WX78_MAXELECTRICCHARGE - slots_inuse) >= 0
end

local function CLIENT_CanRemoveModules(inst)
    if inst.components.upgrademoduleowner ~= nil then
        return inst.components.upgrademoduleowner:NumModules() > 0
    elseif inst.player_classified ~= nil then
        -- Assume that, if the first module slot netvar is 0, we have no modules.
        return inst.player_classified.upgrademodules[1]:value() ~= 0
    else
        return false
    end
end

----------------------------------------------------------------------------------------
local function OnForcedNightVisionDirty(inst)
    if inst.components.playervision ~= nil then
        inst.components.playervision:ForceNightVision(inst._forced_nightvision:value())
    end
end

local NIGHTVISIONMODULE_GRUEIMMUNITY_NAME = "wxnightvisioncircuit"
local function SetForcedNightVision(inst, nightvision_on)
    inst._forced_nightvision:set(nightvision_on)
    if inst.components.playervision ~= nil then
        inst.components.playervision:ForceNightVision(nightvision_on)
    end

    -- The nightvision event might get consumed during save/loading,
    -- so push an extra custom immunity into the table.
    if nightvision_on then
        inst.components.grue:AddImmunity(NIGHTVISIONMODULE_GRUEIMMUNITY_NAME)
    else
        inst.components.grue:RemoveImmunity(NIGHTVISIONMODULE_GRUEIMMUNITY_NAME)
    end
end

local function OnPlayerDeactivated(inst)
    inst:RemoveEventCallback("onremove", OnPlayerDeactivated)
    if not TheNet:IsDedicated() then
        inst:RemoveEventCallback("forced_nightvision_dirty", OnForcedNightVisionDirty)
    end
end

local function OnPlayerActivated(inst)
    inst:ListenForEvent("onremove", OnPlayerDeactivated)
    if not TheNet:IsDedicated() then
        inst:ListenForEvent("forced_nightvision_dirty", OnForcedNightVisionDirty)
        OnForcedNightVisionDirty(inst)
    end
end

----------------------------------------------------------------------------------------

local function do_chargeregen_update(inst)
    if not inst.components.upgrademoduleowner:ChargeIsMaxed() then
        inst.components.upgrademoduleowner:AddCharge(1)
    end
end

local function OnUpgradeModuleChargeChanged(inst, data)
    -- The regen timer gets reset every time the energy level changes, whether it was by the regen timer or not.
    inst.components.timer:StopTimer(CHARGEREGEN_TIMERNAME)
    
    if not inst.components.upgrademoduleowner:ChargeIsMaxed() then
        inst.components.timer:StartTimer(CHARGEREGEN_TIMERNAME, TUNING.WX78_CHARGE_REGENTIME)

        -- If we just got put to 0 from a non-0 value, tell the player.
        if data.old_level ~= 0 and data.new_level == 0 then
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_DISCHARGE"))
        end
    else
        -- If our charge is maxed (this is a post-assignment callback), and our previous charge was not,
        -- we just hit the max, so tell the player.
        if data.old_level ~= inst.components.upgrademoduleowner.max_charge then
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_CHARGE"))
        end
    end
end

----------------------------------------------------------------------------------------

local function OnLoad(inst, data)
    if data ~= nil then
        if data.gears_eaten ~= nil then
            inst._gears_eaten = data.gears_eaten
        end

        -- Compatability with pre-refresh WX saves
        if data.level ~= nil then
            inst._gears_eaten = (inst._gears_eaten or 0) + data.level
        end

        -- WX-78 needs to manually save/load health, hunger, and sanity, in case their maxes
        -- were modified by upgrade circuits, because those components only save current,
        -- and that gets overridden by the default max values during construction.
        -- So, if we wait to re-apply them in our OnLoad, we will have them properly
        -- (as entity OnLoad runs after component OnLoads)
        if data._wx78_health then
            inst.components.health:SetCurrentHealth(data._wx78_health)
        end

        if data._wx78_sanity then
            inst.components.sanity.current = data._wx78_sanity
        end

        if data._wx78_hunger then
            inst.components.hunger.current = data._wx78_hunger
        end
    end
end

local function OnSave(inst, data)
    data.gears_eaten = inst._gears_eaten

    -- WX-78 needs to manually save/load health, hunger, and sanity, in case their maxes
    -- were modified by upgrade circuits, because those components only save current,
    -- and that gets overridden by the default max values during construction.
    -- So, if we wait to re-apply them in our OnLoad, we will have them properly
    -- (as entity OnLoad runs after component OnLoads)
    data._wx78_health = inst.components.health.currenthealth
    data._wx78_sanity = inst.components.sanity.current
    data._wx78_hunger = inst.components.hunger.current
end

----------------------------------------------------------------------------------------

local function OnLightningStrike(inst)
    if inst.components.health ~= nil and not (inst.components.health:IsDead() or inst.components.health:IsInvincible()) then
        if inst.components.inventory:IsInsulated() then
            inst:PushEvent("lightningdamageavoided")
        else
            inst.components.health:DoDelta(TUNING.HEALING_SUPERHUGE, false, "lightning")
            inst.components.sanity:DoDelta(-TUNING.SANITY_LARGE)

            inst.components.upgrademoduleowner:AddCharge(1)
        end
    end
end

----------------------------------------------------------------------------------------
local HEATSTEAM_TICKRATE = 5
local function do_steam_fx(inst)
    local steam_fx = SpawnPrefab("wx78_heat_steam")
    steam_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    steam_fx.Transform:SetRotation(inst.Transform:GetRotation())

    inst.components.timer:StartTimer(HEATSTEAM_TIMERNAME, HEATSTEAM_TICKRATE)
end

-- Negative is colder, positive is warmer
local function AddTemperatureModuleLeaning(inst, leaning_change)
    inst._temperature_modulelean = inst._temperature_modulelean + leaning_change

    if inst._temperature_modulelean > 0 then
        inst.components.heater:SetThermics(true, false)

        if not inst.components.timer:TimerExists(HEATSTEAM_TIMERNAME) then
            inst.components.timer:StartTimer(HEATSTEAM_TIMERNAME, HEATSTEAM_TICKRATE, false, 0.5)
        end

        inst.components.frostybreather:ForceBreathOff()
    elseif inst._temperature_modulelean == 0 then
        inst.components.heater:SetThermics(false, false)

        inst.components.timer:StopTimer(HEATSTEAM_TIMERNAME)

        inst.components.frostybreather:ForceBreathOff()
    else
        inst.components.heater:SetThermics(false, true)

        inst.components.timer:StopTimer(HEATSTEAM_TIMERNAME)

        inst.components.frostybreather:ForceBreathOn()
    end
end

-- Wetness/Moisture/Rain ---------------------------------------------------------------
local function initiate_moisture_update(inst)
    if not inst.components.timer:TimerExists(MOISTURETRACK_TIMERNAME) then
        inst.components.timer:StartTimer(MOISTURETRACK_TIMERNAME, TUNING.WX78_MOISTUREUPDATERATE*FRAMES)
    end
end

local function stop_moisturetracking(inst)
    inst.components.timer:StopTimer(MOISTURETRACK_TIMERNAME)

    inst._moisture_steps = 0
end

local function moisturetrack_update(inst)
    local current_moisture = inst.components.moisture:GetMoisture()
    if current_moisture > TUNING.WX78_MINACCEPTABLEMOISTURE then
        -- The update will loop until it is stopped by going under the acceptable moisture level.
        initiate_moisture_update(inst)
    end

    if inst:HasTag("moistureimmunity") then
        return
    end

    inst._moisture_steps = inst._moisture_steps + 1

    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("sparks").Transform:SetPosition(x, y + 1 + math.random() * 1.5, z)

    if inst._moisture_steps >= TUNING.WX78_MOISTURESTEPTRIGGER then
        local damage_per_second = easing.inSine(
                current_moisture - TUNING.WX78_MINACCEPTABLEMOISTURE,
                TUNING.WX78_MIN_MOISTURE_DAMAGE,
                TUNING.WX78_PERCENT_MOISTURE_DAMAGE,
                inst.components.moisture:GetMaxMoisture() - TUNING.WX78_MINACCEPTABLEMOISTURE
        )
        local seconds_per_update = TUNING.WX78_MOISTUREUPDATERATE / 30

        inst.components.health:DoDelta(inst._moisture_steps * seconds_per_update * damage_per_second, false, "water")
        inst.components.upgrademoduleowner:AddCharge(-1)
        inst._moisture_steps = 0

        SpawnPrefab("wx78_big_spark"):AlignToTarget(inst)

        inst.sg:GoToState("hit")
    end

    -- Send a message for the UI.
    inst:PushEvent("do_robot_spark")
    if inst.player_classified ~= nil then
        inst.player_classified.uirobotsparksevent:push()
    end
end

local function OnWetnessChanged(inst, data)
    if not (inst.components.health ~= nil and inst.components.health:IsDead()) then
        if data.new >= TUNING.WX78_COLD_ICEMOISTURE and inst.components.upgrademoduleowner:GetModuleTypeCount("cold") > 0 then
            inst.components.moisture:SetMoistureLevel(0)

            local x, y, z = inst.Transform:GetWorldPosition()
            for i = 1, TUNING.WX78_COLD_ICECOUNT do
                local ice = SpawnPrefab("ice")
                ice.Transform:SetPosition(x, y, z)
                Launch(ice, inst)
            end

            stop_moisturetracking(inst)
        elseif data.new > TUNING.WX78_MINACCEPTABLEMOISTURE and data.old <= TUNING.WX78_MINACCEPTABLEMOISTURE then
            initiate_moisture_update(inst)
        elseif data.new <= TUNING.WX78_MINACCEPTABLEMOISTURE and data.old > TUNING.WX78_MINACCEPTABLEMOISTURE then
            stop_moisturetracking(inst)
        end
    end
end

---------------------------------------------------------------------------------------

local function OnBecameRobot(inst)
    --Override with overcharge light values
    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(0.75)
    inst.Light:SetIntensity(.9)
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    if not inst.components.upgrademoduleowner:ChargeIsMaxed() then
        inst.components.timer:StartTimer(CHARGEREGEN_TIMERNAME, TUNING.WX78_CHARGE_REGENTIME)
    end
end

local function OnBecameGhost(inst)
    stop_moisturetracking(inst)
    inst.components.timer:StopTimer(HUNGERDRAIN_TIMERNAME)
    inst.components.timer:StopTimer(CHARGEREGEN_TIMERNAME)
end

local function OnDeath(inst)
    inst.components.upgrademoduleowner:PopAllModules()
    inst.components.upgrademoduleowner:SetChargeLevel(0)

    stop_moisturetracking(inst)
    inst.components.timer:StopTimer(HUNGERDRAIN_TIMERNAME)
    inst.components.timer:StopTimer(CHARGEREGEN_TIMERNAME)

    if inst._gears_eaten > 0 then
        local dropgears = math.random(math.floor(inst._gears_eaten / 3), math.ceil(inst._gears_eaten / 2))
        local x, y, z = inst.Transform:GetWorldPosition()
        for i = 1, dropgears do
            local gear = SpawnPrefab("gears")
            if gear ~= nil then
                if gear.Physics ~= nil then
                    local speed = 2 + math.random()
                    local angle = math.random() * 2 * PI
                    gear.Physics:Teleport(x, y + 1, z)
                    gear.Physics:SetVel(speed * math.cos(angle), speed * 3, speed * math.sin(angle))
                else
                    gear.Transform:SetPosition(x, y, z)
                end

                if gear.components.propagator ~= nil then
                    gear.components.propagator:Delay(5)
                end
            end
        end

        inst._gears_eaten = 0
    end
end

----------------------------------------------------------------------------------------

local function OnEat(inst, food)
    if food ~= nil and food.components.edible ~= nil then
        if food.components.edible.foodtype == FOODTYPE.GEARS then
            inst._gears_eaten = inst._gears_eaten + 1

            inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/levelup")
        end
    end

    local charge_amount = TUNING.WX78_CHARGING_FOODS[food.prefab]
    if charge_amount ~= nil then
        inst.components.upgrademoduleowner:AddCharge(charge_amount)
    end
end

----------------------------------------------------------------------------------------

local function OnFrozen(inst)
    if inst.components.freezable == nil or not inst.components.freezable:IsFrozen() then
        SpawnPrefab("wx78_big_spark"):AlignToTarget(inst)

        if not inst.components.upgrademoduleowner:IsChargeEmpty() then
            inst.components.upgrademoduleowner:AddCharge(-TUNING.WX78_FROZEN_CHARGELOSS)
        end
    end
end

----------------------------------------------------------------------------------------

local function OnUpgradeModuleAdded(inst, moduleent)
    local slots_for_module = moduleent.components.upgrademodule.slots
    inst._chip_inuse = inst._chip_inuse + slots_for_module

    local upgrademodule_defindexes = get_plugged_module_indexes(inst)

    inst:PushEvent("upgrademodulesdirty", upgrademodule_defindexes)
    if inst.player_classified ~= nil then
        local newmodule_index = inst.components.upgrademoduleowner:NumModules()
        inst.player_classified.upgrademodules[newmodule_index]:set(moduleent._netid or 0)
    end
end

local function OnUpgradeModuleRemoved(inst, moduleent)
    inst._chip_inuse = inst._chip_inuse - moduleent.components.upgrademodule.slots

    -- If the module has 1 use left, it's about to be destroyed, so don't return it to the inventory.
    if moduleent.components.finiteuses == nil or moduleent.components.finiteuses:GetUses() > 1 then
        if moduleent.components.inventoryitem ~= nil and inst.components.inventory ~= nil then
            inst.components.inventory:GiveItem(moduleent, nil, inst:GetPosition())
        end
    end
end

local function OnOneUpgradeModulePopped(inst, moduleent)
    inst:PushEvent("upgrademodulesdirty", get_plugged_module_indexes(inst))
    if inst.player_classified ~= nil then
        -- This is a callback of the remove, so our current NumModules should be
        -- 1 lower than the index of the module that was just removed.
        local top_module_index = inst.components.upgrademoduleowner:NumModules() + 1
        inst.player_classified.upgrademodules[top_module_index]:set(0)
    end
end

local function OnAllUpgradeModulesRemoved(inst)
    SpawnPrefab("wx78_big_spark"):AlignToTarget(inst)

    inst:PushEvent("upgrademoduleowner_popallmodules")

    if inst.player_classified ~= nil then
        inst.player_classified.upgrademodules[1]:set(0)
        inst.player_classified.upgrademodules[2]:set(0)
        inst.player_classified.upgrademodules[3]:set(0)
        inst.player_classified.upgrademodules[4]:set(0)
        inst.player_classified.upgrademodules[5]:set(0)
        inst.player_classified.upgrademodules[6]:set(0)
    end
end

local function CanUseUpgradeModule(inst, moduleent)
    if (TUNING.WX78_MAXELECTRICCHARGE - inst._chip_inuse) < moduleent.components.upgrademodule.slots then
        return false, "NOTENOUGHSLOTS"
    else
        return true
    end
end

----------------------------------------------------------------------------------------

local function OnChargeFromBattery(inst, battery)
    if inst.components.upgrademoduleowner:ChargeIsMaxed() then
        return false, "CHARGE_FULL"
    end

    inst.components.health:DoDelta(TUNING.HEALING_SMALL, false, "lightning")
    inst.components.sanity:DoDelta(-TUNING.SANITY_SMALL)

    inst.components.upgrademoduleowner:AddCharge(1)

    if not inst.components.inventory:IsInsulated() then
        inst.sg:GoToState("electrocute")
    end

    return true
end

----------------------------------------------------------------------------------------

local function ModuleBasedPreserverRateFn(inst, item)
    return (inst._temperature_modulelean > 0 and TUNING.WX78_PERISH_HOTRATE)
        or (inst._temperature_modulelean < 0 and TUNING.WX78_PERISH_COLDRATE)
        or 1
end

----------------------------------------------------------------------------------------

local function GetThermicTemperatureFn(inst, observer)
    return inst._temperature_modulelean * TUNING.WX78_HEATERTEMPPERMODULE
end

----------------------------------------------------------------------------------------

local function CanSleepInBagFn(wx, bed)
    if wx._light_modules == nil or wx._light_modules == 0 then
        return true
    else
        return false, "ANNOUNCE_NOSLEEPHASPERMANENTLIGHT"
    end
end

----------------------------------------------------------------------------------------
local function OnStartStarving(inst)
    inst.components.timer:StartTimer(HUNGERDRAIN_TIMERNAME, TUNING.WX78_HUNGRYCHARGEDRAIN_TICKTIME)
end

local function OnStopStarving(inst)
    inst.components.timer:StopTimer(HUNGERDRAIN_TIMERNAME)
end

local function on_hunger_drain_tick(inst)
    if inst.components.health ~= nil and not (inst.components.health:IsDead() or inst.components.health:IsInvincible()) then
        inst.components.upgrademoduleowner:AddCharge(-1)

        SpawnPrefab("wx78_big_spark"):AlignToTarget(inst)

        inst.sg:GoToState("hit")
    end
    inst.components.timer:StartTimer(HUNGERDRAIN_TIMERNAME, TUNING.WX78_HUNGRYCHARGEDRAIN_TICKTIME)
end

----------------------------------------------------------------------------------------

local function OnTimerFinished(inst, data)
    if data.name == HUNGERDRAIN_TIMERNAME then
        on_hunger_drain_tick(inst)
    elseif data.name == MOISTURETRACK_TIMERNAME then
        moisturetrack_update(inst)
    elseif data.name == CHARGEREGEN_TIMERNAME then
        do_chargeregen_update(inst)
    elseif data.name == HEATSTEAM_TIMERNAME then
        do_steam_fx(inst)
    end
end

----------------------------------------------------------------------------------------

local function common_postinit(inst)
    inst:AddTag("electricdamageimmune")
    --electricdamageimmune is for combat and not lightning strikes
    --also used in stategraph for not stomping custom light values
    
    inst:AddTag("batteryuser")          -- from batteryuser component
    inst:AddTag("chessfriend")
    inst:AddTag("HASHEATER")            -- from heater component
    inst:AddTag("soulless")
    inst:AddTag("upgrademoduleowner")   -- from upgrademoduleowner component

    if TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_shopper")
    else
        if not TheNet:IsDedicated() then
            inst.CreateMoistureMeter = WX78MoistureMeter
        end

        inst._forced_nightvision = net_bool(inst.GUID, "wx78.forced_nightvision", "forced_nightvision_dirty")
        inst:ListenForEvent("playeractivated", OnPlayerActivated)
        inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
    end

    inst.AnimState:AddOverrideBuild("wx_upgrade")

    inst.components.talker.mod_str_fn = string.utf8upper

    inst.foleysound = "dontstarve/movement/foley/wx78"

    ----------------------------------------------------------------
    -- For UI save/loading
    inst.GetEnergyLevel = CLIENT_GetEnergyLevel
    inst.GetModulesData = CLIENT_GetModulesData

    ----------------------------------------------------------------
    -- For actionfail tests
    inst.CanUpgradeWithModule = CLIENT_CanUpgradeWithModule
    inst.CanRemoveModules = CLIENT_CanRemoveModules
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	inst.customidlestate = "wx78_funnyidle"

    ----------------------------------------------------------------
    inst.components.health:SetMaxHealth(TUNING.WX78_HEALTH)
    inst.components.hunger:SetMax(TUNING.WX78_HUNGER)
    inst.components.sanity:SetMax(TUNING.WX78_SANITY)

    ----------------------------------------------------------------
    inst._gears_eaten = 0
    inst._chip_inuse = 0
    inst._moisture_steps = 0
    inst._temperature_modulelean = 0        -- Positive if "hot", negative if "cold"; see wx78_moduledefs
    inst._num_frostybreath_modules = 0      -- So modules can activate WX's frostybreath outside of winter/low worldstate temperature

    ----------------------------------------------------------------
    if inst.components.eater ~= nil then
        inst.components.eater:SetIgnoresSpoilage(true)
        inst.components.eater:SetCanEatGears()
        inst.components.eater:SetOnEatFn(OnEat)
    end

    ----------------------------------------------------------------
    if inst.components.freezable ~= nil then
        inst.components.freezable.onfreezefn = OnFrozen
    end

    ----------------------------------------------------------------
    inst:AddComponent("upgrademoduleowner")
    inst.components.upgrademoduleowner.onmoduleadded = OnUpgradeModuleAdded
    inst.components.upgrademoduleowner.onmoduleremoved = OnUpgradeModuleRemoved
    inst.components.upgrademoduleowner.ononemodulepopped = OnOneUpgradeModulePopped
    inst.components.upgrademoduleowner.onallmodulespopped = OnAllUpgradeModulesRemoved
    inst.components.upgrademoduleowner.canupgradefn = CanUseUpgradeModule
    inst.components.upgrademoduleowner:SetChargeLevel(3)

    inst:ListenForEvent("energylevelupdate", OnUpgradeModuleChargeChanged)

    ----------------------------------------------------------------
    inst:AddComponent("dataanalyzer")
    inst.components.dataanalyzer:StartDataRegen(TUNING.SEG_TIME)

    ----------------------------------------------------------------
    inst:AddComponent("batteryuser")
    inst.components.batteryuser.onbatteryused = OnChargeFromBattery

    ----------------------------------------------------------------
    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(ModuleBasedPreserverRateFn)

    ----------------------------------------------------------------
    inst:AddComponent("heater")
    inst.components.heater:SetThermics(false, false)
    inst.components.heater.heatfn = GetThermicTemperatureFn

    ----------------------------------------------------------------
    inst.components.foodaffinity:AddPrefabAffinity("butterflymuffin", TUNING.AFFINITY_15_CALORIES_LARGE)

    ----------------------------------------------------------------
    inst.components.sleepingbaguser:SetCanSleepFn(CanSleepInBagFn)

    ----------------------------------------------------------------
    inst:ListenForEvent("ms_respawnedfromghost", OnBecameRobot)
    inst:ListenForEvent("ms_becameghost", OnBecameGhost)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("ms_playerreroll", OnDeath)
    inst:ListenForEvent("moisturedelta", OnWetnessChanged)
    inst:ListenForEvent("startstarving", OnStartStarving)
    inst:ListenForEvent("stopstarving", OnStopStarving)
    inst:ListenForEvent("timerdone", OnTimerFinished)

    ----------------------------------------------------------------
    inst.components.playerlightningtarget:SetHitChance(TUNING.WX78_LIGHTNING_TARGET_CHANCE)
    inst.components.playerlightningtarget:SetOnStrikeFn(OnLightningStrike)

    ----------------------------------------------------------------
    OnBecameRobot(inst)

    ----------------------------------------------------------------
    inst.AddTemperatureModuleLeaning = AddTemperatureModuleLeaning
    inst.SetForcedNightVision = SetForcedNightVision

    ----------------------------------------------------------------
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    ----------------------------------------------------------------
    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/wx78").master_postinit(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/wx78").master_postinit(inst)
    end
end

return MakePlayerCharacter("wx78", prefabs, assets, common_postinit, master_postinit)
