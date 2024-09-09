local module_definitions = {}
local scandata_definitions = {}

-- Add a new creature/module/scandata combination for the scanner.
--      prefab_name -   The prefab name of the object to scan in the world.
--      module_name -   The type name of the module that will be produced by the scan (without the "wx78module_" prefix)
--      maxdata -       The maximum amount of data that will build up on the scannable prefab; see "dataanalyzer.lua"
-- Calling this function using a prefab name that has already been added will overwrite that prefab's prior entry.
local function AddCreatureScanDataDefinition(prefab_name, module_name, maxdata)
    scandata_definitions[prefab_name] = {
        maxdata = maxdata or 1,
        module = module_name,
    }
end

-- Given a creature prefab, return any module/data information for it, if it exists.
local function GetCreatureScanDataDefinition(prefab_name)
    return scandata_definitions[prefab_name]
end

---------------------------------------------------------------
local function maxhealth_change(inst, wx, amount, isloading)
    if wx.components.health ~= nil then
        local current_health_percent = wx.components.health:GetPercent()

        wx.components.health.maxhealth = wx.components.health.maxhealth + amount

        if not isloading then
            wx.components.health:SetPercent(current_health_percent)

            -- We want to force a badge pulse, but also maintain the health percent as much as we can.
            local badgedelta = (amount > 0 and 0.01) or -0.01
            wx.components.health:DoDelta(badgedelta, false, nil, true)
        end
    end
end

local function maxhealth_activate(inst, wx, isloading)
    maxhealth_change(inst, wx, TUNING.WX78_MAXHEALTH_BOOST, isloading)
end

local function maxhealth_deactivate(inst, wx)
    maxhealth_change(inst, wx, -TUNING.WX78_MAXHEALTH_BOOST)
end


local MAXHEALTH_MODULE_DATA =
{
    name = "maxhealth",
    slots = 1,
    activatefn = maxhealth_activate,
    deactivatefn = maxhealth_deactivate,
}
table.insert(module_definitions, MAXHEALTH_MODULE_DATA)

AddCreatureScanDataDefinition("spider", "maxhealth", 2)

---------------------------------------------------------------
local function maxsanity1_activate(inst, wx, isloading)
    if wx.components.sanity ~= nil then
        local current_sanity_percent = wx.components.sanity:GetPercent()

        wx.components.sanity:SetMax(wx.components.sanity.max + TUNING.WX78_MAXSANITY1_BOOST)

        if not isloading then
            wx.components.sanity:SetPercent(current_sanity_percent, false)
        end
    end
end

local function maxsanity1_deactivate(inst, wx)
    if wx.components.sanity ~= nil then
        local current_sanity_percent = wx.components.sanity:GetPercent()
        wx.components.sanity:SetMax(wx.components.sanity.max - TUNING.WX78_MAXSANITY1_BOOST)
        wx.components.sanity:SetPercent(current_sanity_percent, false)
    end
end

local MAXSANITY1_MODULE_DATA =
{
    name = "maxsanity1",
    slots = 1,
    activatefn = maxsanity1_activate,
    deactivatefn = maxsanity1_deactivate,
}
table.insert(module_definitions, MAXSANITY1_MODULE_DATA)

AddCreatureScanDataDefinition("butterfly", "maxsanity1", 1)
AddCreatureScanDataDefinition("moonbutterfly", "maxsanity1", 1)

---------------------------------------------------------------
local function maxsanity_activate(inst, wx, isloading)
    if wx.components.sanity ~= nil then
        local current_sanity_percent = wx.components.sanity:GetPercent()

        wx.components.sanity.dapperness = wx.components.sanity.dapperness + TUNING.WX78_MAXSANITY_DAPPERNESS
        wx.components.sanity:SetMax(wx.components.sanity.max + TUNING.WX78_MAXSANITY_BOOST)

        if not isloading then
            wx.components.sanity:SetPercent(current_sanity_percent, false)
        end
    end
end

local function maxsanity_deactivate(inst, wx)
    if wx.components.sanity ~= nil then
        local current_sanity_percent = wx.components.sanity:GetPercent()

        wx.components.sanity.dapperness = wx.components.sanity.dapperness - TUNING.WX78_MAXSANITY_DAPPERNESS
        wx.components.sanity:SetMax(wx.components.sanity.max - TUNING.WX78_MAXSANITY_BOOST)
        wx.components.sanity:SetPercent(current_sanity_percent, false)
    end
end

local MAXSANITY_MODULE_DATA =
{
    name = "maxsanity",
    slots = 2,
    activatefn = maxsanity_activate,
    deactivatefn = maxsanity_deactivate,
}
table.insert(module_definitions, MAXSANITY_MODULE_DATA)

AddCreatureScanDataDefinition("crawlinghorror", "maxsanity", 3)
AddCreatureScanDataDefinition("crawlingnightmare", "maxsanity", 6)
AddCreatureScanDataDefinition("terrorbeak", "maxsanity", 3)
AddCreatureScanDataDefinition("nightmarebeak", "maxsanity", 6)
AddCreatureScanDataDefinition("oceanhorror", "maxsanity", 3)

---------------------------------------------------------------
local function movespeed_activate(inst, wx)
    wx._movespeed_chips = (wx._movespeed_chips or 0) + 1

    wx.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * (1 + TUNING.WX78_MOVESPEED_CHIPBOOSTS[wx._movespeed_chips + 1])
end

local function movespeed_deactivate(inst, wx)
    wx._movespeed_chips = math.max(0, wx._movespeed_chips - 1)

    wx.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * (1 + TUNING.WX78_MOVESPEED_CHIPBOOSTS[wx._movespeed_chips + 1])
end

local MOVESPEED_MODULE_DATA =
{
    name = "movespeed",
    slots = 6,
    activatefn = movespeed_activate,
    deactivatefn = movespeed_deactivate,
}
table.insert(module_definitions, MOVESPEED_MODULE_DATA)

AddCreatureScanDataDefinition("rabbit", "movespeed", 2)

---------------------------------------------------------------

local MOVESPEED2_MODULE_DATA =
{
    name = "movespeed2",
    slots = 2,
    activatefn = movespeed_activate,
    deactivatefn = movespeed_deactivate,
}
table.insert(module_definitions, MOVESPEED2_MODULE_DATA)

AddCreatureScanDataDefinition("minotaur", "movespeed2", 6)
AddCreatureScanDataDefinition("rook", "movespeed2", 3)
AddCreatureScanDataDefinition("rook_nightmare", "movespeed2", 3)

---------------------------------------------------------------
local EXTRA_DRYRATE = 0.1
local function heat_activate(inst, wx)
    -- A higher mintemp means that it's harder to freeze.
    wx.components.temperature.mintemp = wx.components.temperature.mintemp + TUNING.WX78_MINTEMPCHANGEPERMODULE
    wx.components.temperature.maxtemp = wx.components.temperature.maxtemp + TUNING.WX78_MINTEMPCHANGEPERMODULE

    wx.components.moisture.maxDryingRate = wx.components.moisture.maxDryingRate + EXTRA_DRYRATE
    wx.components.moisture.baseDryingRate = wx.components.moisture.baseDryingRate + EXTRA_DRYRATE

    if wx.AddTemperatureModuleLeaning ~= nil then
        wx:AddTemperatureModuleLeaning(1)
    end
end

local function heat_deactivate(inst, wx)
    wx.components.temperature.mintemp = wx.components.temperature.mintemp - TUNING.WX78_MINTEMPCHANGEPERMODULE
    wx.components.temperature.maxtemp = wx.components.temperature.maxtemp - TUNING.WX78_MINTEMPCHANGEPERMODULE

    wx.components.moisture.maxDryingRate = wx.components.moisture.maxDryingRate - EXTRA_DRYRATE
    wx.components.moisture.baseDryingRate = wx.components.moisture.baseDryingRate - EXTRA_DRYRATE

    if wx.AddTemperatureModuleLeaning ~= nil then
        wx:AddTemperatureModuleLeaning(-1)
    end
end

local HEAT_MODULE_DATA =
{
    name = "heat",
    slots = 3,
    activatefn = heat_activate,
    deactivatefn = heat_deactivate,
}
table.insert(module_definitions, HEAT_MODULE_DATA)

AddCreatureScanDataDefinition("firehound", "heat", 4)
AddCreatureScanDataDefinition("dragonfly", "heat", 10)

---------------------------------------------------------------
local function nightvision_onworldstateupdate(wx)
    wx:SetForcedNightVision(TheWorld.state.isnight and not TheWorld.state.isfullmoon)
end

local function nightvision_activate(inst, wx)
    wx._nightvision_modcount = (wx._nightvision_modcount or 0) + 1

    if wx._nightvision_modcount == 1 and TheWorld ~= nil and wx.SetForcedNightVision ~= nil then
        if TheWorld:HasTag("cave") then
            wx:SetForcedNightVision(true)
        else
            wx:WatchWorldState("isnight", nightvision_onworldstateupdate)
            wx:WatchWorldState("isfullmoon", nightvision_onworldstateupdate)
            nightvision_onworldstateupdate(wx)
        end
    end
end

local function nightvision_deactivate(inst, wx)
    wx._nightvision_modcount = math.max(0, wx._nightvision_modcount - 1)

    if wx._nightvision_modcount == 0 and TheWorld ~= nil and wx.SetForcedNightVision ~= nil then
        if TheWorld:HasTag("cave") then
            wx:SetForcedNightVision(false)
        else
            wx:StopWatchingWorldState("isnight", nightvision_onworldstateupdate)
            wx:StopWatchingWorldState("isfullmoon", nightvision_onworldstateupdate)
            wx:SetForcedNightVision(false)
        end
    end
end

local NIGHTVISION_MODULE_DATA =
{
    name = "nightvision",
    slots = 4,
    activatefn = nightvision_activate,
    deactivatefn = nightvision_deactivate,
}
table.insert(module_definitions, NIGHTVISION_MODULE_DATA)

AddCreatureScanDataDefinition("mole", "nightvision", 4)

---------------------------------------------------------------
local function cold_activate(inst, wx)
    -- A lower maxtemp means it's harder to overheat.
    wx.components.temperature.maxtemp = wx.components.temperature.maxtemp - TUNING.WX78_MINTEMPCHANGEPERMODULE
    wx.components.temperature.mintemp = wx.components.temperature.mintemp - TUNING.WX78_MINTEMPCHANGEPERMODULE

    if wx.AddTemperatureModuleLeaning ~= nil then
        wx:AddTemperatureModuleLeaning(-1)
    end
end

local function cold_deactivate(inst, wx)
    wx.components.temperature.maxtemp = wx.components.temperature.maxtemp + TUNING.WX78_MINTEMPCHANGEPERMODULE
    wx.components.temperature.mintemp = wx.components.temperature.mintemp + TUNING.WX78_MINTEMPCHANGEPERMODULE

    if wx.AddTemperatureModuleLeaning ~= nil then
        wx:AddTemperatureModuleLeaning(1)
    end
end

local COLD_MODULE_DATA =
{
    name = "cold",
    slots = 3,
    activatefn = cold_activate,
    deactivatefn = cold_deactivate,
}
table.insert(module_definitions, COLD_MODULE_DATA)

AddCreatureScanDataDefinition("icehound", "cold", 4)
AddCreatureScanDataDefinition("deerclops", "cold", 10)

---------------------------------------------------------------
local function taser_cooldown(inst)
    inst._cdtask = nil
end

local function taser_onblockedorattacked(wx, data, inst)
    if (data ~= nil and data.attacker ~= nil and not data.redirected) and inst._cdtask == nil then
        inst._cdtask = inst:DoTaskInTime(0.3, taser_cooldown)

        if data.attacker.components.combat ~= nil
                and (data.attacker.components.health ~= nil and not data.attacker.components.health:IsDead())
                and (data.attacker.components.inventory == nil or not data.attacker.components.inventory:IsInsulated())
                and (data.weapon == nil or 
                        (data.weapon.components.projectile == nil
                        and (data.weapon.components.weapon == nil or data.weapon.components.weapon.projectile == nil))
                ) then

            SpawnPrefab("electrichitsparks"):AlignToTarget(data.attacker, wx, true)

            local damage_mult = 1
            if not (data.attacker:HasTag("electricdamageimmune") or
                    (data.attacker.components.inventory ~= nil and data.attacker.components.inventory:IsInsulated())) then
                damage_mult = TUNING.ELECTRIC_DAMAGE_MULT

                local wetness_mult = (data.attacker.components.moisture ~= nil and data.attacker.components.moisture:GetMoisturePercent())
                    or (data.attacker:GetIsWet() and 1)
                    or 0
                damage_mult = damage_mult + wetness_mult
            end

            data.attacker.components.combat:GetAttacked(wx, damage_mult * TUNING.WX78_TASERDAMAGE, nil, "electric")
        end
    end
end

local function taser_activate(inst, wx)
    if inst._onblocked == nil then
        inst._onblocked = function(owner, data)
            taser_onblockedorattacked(owner, data, inst)
        end
    end

    inst:ListenForEvent("blocked", inst._onblocked, wx)
    inst:ListenForEvent("attacked", inst._onblocked, wx)

    if wx.components.inventory ~= nil then
        wx.components.inventory.isexternallyinsulated:SetModifier(inst, true)
    end
end

local function taser_deactivate(inst, wx)
    inst:RemoveEventCallback("blocked", inst._onblocked, wx)
    inst:RemoveEventCallback("attacked", inst._onblocked, wx)

    if wx.components.inventory ~= nil then
        wx.components.inventory.isexternallyinsulated:RemoveModifier(inst)
    end
end

local TASER_MODULE_DATA =
{
    name = "taser",
    slots = 2,
    activatefn = taser_activate,
    deactivatefn = taser_deactivate,

    extra_prefabs = { "electrichitsparks", },
}
table.insert(module_definitions, TASER_MODULE_DATA)

AddCreatureScanDataDefinition("lightninggoat", "taser", 5)

---------------------------------------------------------------
local LIGHT_R, LIGHT_G, LIGHT_B = 235 / 255, 121 / 255, 12 / 255
local function light_activate(inst, wx)
    wx._light_modules = (wx._light_modules or 0) + 1

    wx.Light:SetRadius(TUNING.WX78_LIGHT_BASERADIUS + (wx._light_modules - 1) * TUNING.WX78_LIGHT_EXTRARADIUS)
    
    -- If we had 0 before, set up the light properties.
    if wx._light_modules == 1 then
        wx.Light:SetIntensity(0.90)
        wx.Light:SetFalloff(0.50)
        wx.Light:SetColour(LIGHT_R, LIGHT_G, LIGHT_B)

        wx.Light:Enable(true)
    end
end

local function light_deactivate(inst, wx)
    wx._light_modules = math.max(0, wx._light_modules - 1)

    if wx._light_modules == 0 then
        -- Reset properties to the electrocute light properties, since that's the player_common default.
        wx.Light:SetRadius(0.5)
        wx.Light:SetIntensity(0.8)
        wx.Light:SetFalloff(0.65)
        wx.Light:SetColour(255 / 255, 255 / 255, 236 / 255)

        wx.Light:Enable(false)
    else
        wx.Light:SetRadius(TUNING.WX78_LIGHT_BASERADIUS + (wx._light_modules - 1) * TUNING.WX78_LIGHT_EXTRARADIUS)
    end
end

local LIGHT_MODULE_DATA =
{
    name = "light",
    slots = 3,
    activatefn = light_activate,
    deactivatefn = light_deactivate,
}
table.insert(module_definitions, LIGHT_MODULE_DATA)

AddCreatureScanDataDefinition("squid", "light", 6)
AddCreatureScanDataDefinition("worm", "light", 6)
AddCreatureScanDataDefinition("lightflier", "light", 6)

---------------------------------------------------------------
local function maxhunger_activate(inst, wx, isloading)
    if wx.components.hunger ~= nil then
        local current_hunger_percent = wx.components.hunger:GetPercent()

        wx.components.hunger:SetMax(wx.components.hunger.max + TUNING.WX78_MAXHUNGER_BOOST)

        if not isloading then
            wx.components.hunger:SetPercent(current_hunger_percent, false)
        end

        -- Tie it to the module instance so we don't have to think too much about removing them.
        wx.components.hunger.burnratemodifiers:SetModifier(inst, TUNING.WX78_MAXHUNGER_SLOWPERCENT)
    end
end

local function maxhunger_deactivate(inst, wx)
    if wx.components.hunger ~= nil then
        local current_hunger_percent = wx.components.hunger:GetPercent()

        wx.components.hunger:SetMax(wx.components.hunger.max - TUNING.WX78_MAXHUNGER_BOOST)
        wx.components.hunger:SetPercent(current_hunger_percent, false)

        wx.components.hunger.burnratemodifiers:RemoveModifier(inst)
    end
end

local MAXHUNGER_MODULE_DATA =
{
    name = "maxhunger",
    slots = 2,
    activatefn = maxhunger_activate,
    deactivatefn = maxhunger_deactivate,
}
table.insert(module_definitions, MAXHUNGER_MODULE_DATA)

AddCreatureScanDataDefinition("bearger", "maxhunger", 6)
AddCreatureScanDataDefinition("slurper", "maxhunger", 3)

---------------------------------------------------------------
local function maxhunger1_activate(inst, wx, isloading)
    if wx.components.hunger ~= nil then
        local current_hunger_percent = wx.components.hunger:GetPercent()

        wx.components.hunger:SetMax(wx.components.hunger.max + TUNING.WX78_MAXHUNGER1_BOOST)

        if not isloading then
            wx.components.hunger:SetPercent(current_hunger_percent, false)
        end
    end
end

local function maxhunger1_deactivate(inst, wx)
    if wx.components.hunger ~= nil then
        local current_hunger_percent = wx.components.hunger:GetPercent()

        wx.components.hunger:SetMax(wx.components.hunger.max - TUNING.WX78_MAXHUNGER1_BOOST)
        wx.components.hunger:SetPercent(current_hunger_percent, false)
    end
end

local MAXHUNGER1_MODULE_DATA =
{
    name = "maxhunger1",
    slots = 1,
    activatefn = maxhunger1_activate,
    deactivatefn = maxhunger1_deactivate,
}
table.insert(module_definitions, MAXHUNGER1_MODULE_DATA)

AddCreatureScanDataDefinition("hound", "maxhunger1", 2)

---------------------------------------------------------------
local function music_sanityaura_fn(wx, observer)
    local num_modules = wx._music_modules or 1
    return TUNING.WX78_MUSIC_SANITYAURA * num_modules
end

local function music_sanityfalloff_fn(inst, observer, distsq)
    return 1
end

local MUSIC_TENDINGTAGS_MUST = {"farm_plant"}
local function music_update_fn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.WX78_MUSIC_TENDRANGE, MUSIC_TENDINGTAGS_MUST)
    for _, v in ipairs(ents) do
        if v.components.farmplanttendable ~= nil then
            v.components.farmplanttendable:TendTo(inst)
        end
    end

    SpawnPrefab("wx78_musicbox_fx").Transform:SetPosition(x, y, z)
end

local function music_activate(inst, wx)
    wx._music_modules = (wx._music_modules or 0) + 1

    -- Sanity auras don't affect their owner, so add dapperness to also give WX sanity regen.
    wx.components.sanity.dapperness = wx.components.sanity.dapperness + TUNING.WX78_MUSIC_DAPPERNESS

    if wx._music_modules == 1 then
        if wx.components.sanityaura == nil then
            wx:AddComponent("sanityaura")
            wx.components.sanityaura.aurafn = music_sanityaura_fn
            wx.components.sanityaura.fallofffn = music_sanityfalloff_fn

            wx.components.sanityaura.max_distsq = TUNING.WX78_MUSIC_AURADSQ
        end

        if wx._tending_update == nil then
            wx._tending_update = wx:DoPeriodicTask(TUNING.WX78_MUSIC_UPDATERATE, music_update_fn, 1)
        end

        wx.SoundEmitter:PlaySound("WX_rework/module/musicmodule_lp", "music_sound")
    elseif wx._music_modules == 2 then
        wx.SoundEmitter:SetParameter("music_sound", "wathgrithr_intensity", 1)
    end
end

local function music_deactivate(inst, wx)
    wx._music_modules = math.max(0, wx._music_modules - 1)

    wx.components.sanity.dapperness = wx.components.sanity.dapperness - TUNING.WX78_MUSIC_DAPPERNESS

    wx.components.sanityaura.max_distsq = (wx._music_modules * TUNING.WX78_MUSIC_TENDRANGE) * (wx._music_modules * TUNING.WX78_MUSIC_TENDRANGE)

    if wx._music_modules == 0 then
        wx:RemoveComponent("sanityaura")

        if wx._tending_update ~= nil then
            wx._tending_update:Cancel()
            wx._tending_update = nil
        end

        wx.SoundEmitter:KillSound("music_sound")
    elseif wx._music_modules == 1 then
        wx.SoundEmitter:SetParameter("music_sound", "wathgrithr_intensity", 0)
    end
end

local MUSIC_MODULE_DATA =
{
    name = "music",
    slots = 3,
    activatefn = music_activate,
    deactivatefn = music_deactivate,

    scannable_prefabs = { "crabking", },
}
table.insert(module_definitions, MUSIC_MODULE_DATA)

AddCreatureScanDataDefinition("crabking", "music", 8)
AddCreatureScanDataDefinition("hermitcrab", "music", 4)

---------------------------------------------------------------
local function bee_tick(wx, inst)
    if wx._bee_modcount and wx._bee_modcount > 0 and wx.components.inventory ~= nil then
        local health_tick = wx._bee_modcount * TUNING.WX78_BEE_HEALTHPERTICK
        wx.components.health:DoDelta(health_tick, false, inst, true)
    end
end

local function bee_activate(inst, wx, isloading)
    wx._bee_modcount = (wx._bee_modcount or 0) + 1

    if wx._bee_modcount == 1 then
        if wx._bee_regentask ~= nil then
            wx._bee_regentask:Cancel()
        end
        wx._bee_regentask = wx:DoPeriodicTask(TUNING.WX78_BEE_TICKPERIOD, bee_tick, nil, inst)
    end

    maxsanity_activate(inst, wx, isloading)
end

local function bee_deactivate(inst, wx)
    wx._bee_modcount = math.max(0, wx._bee_modcount - 1)

    if wx._bee_modcount == 0 then
        if wx._bee_regentask ~= nil then
            wx._bee_regentask:Cancel()
            wx._bee_regentask = nil
        end
    end

    maxsanity_deactivate(inst, wx)
end

local BEE_MODULE_DATA =
{
    name = "bee",
    slots = 3,
    activatefn = bee_activate,
    deactivatefn = bee_deactivate,
}
table.insert(module_definitions, BEE_MODULE_DATA)

AddCreatureScanDataDefinition("beequeen", "bee", 10)

---------------------------------------------------------------
-- We calculate the boost locally becuase it's slightly nicer
-- if mods want to change the tuning values.
local function maxhealth2_activate(inst, wx, isloading)
    local maxhealth2_boost = TUNING.WX78_MAXHEALTH_BOOST * TUNING.WX78_MAXHEALTH2_MULT
    maxhealth_change(inst, wx, maxhealth2_boost, isloading)
end

local function maxhealth2_deactivate(inst, wx)
    local maxhealth2_boost = TUNING.WX78_MAXHEALTH_BOOST * TUNING.WX78_MAXHEALTH2_MULT
    maxhealth_change(inst, wx, -maxhealth2_boost)
end

local MAXHEALTH2_MODULE_DATA =
{
    name = "maxhealth2",
    slots = 2,
    activatefn = maxhealth2_activate,
    deactivatefn = maxhealth2_deactivate,
}
table.insert(module_definitions, MAXHEALTH2_MODULE_DATA)

AddCreatureScanDataDefinition("spider_healer", "maxhealth2", 4)

---------------------------------------------------------------
local module_netid = 1
local module_netid_lookup = {}

-- Add a new module definition table, passing a table with the following properties:
--      name -          The type-name of the module (without the "wx78module_" prefix)
--      slots -         How many energy slots the module requires to be plugged in & activated
--      activatefn -    The function that runs whenever the module is activated [signature (module instance, owner instance)]. This can run during loading.
--      deactivatefn -  The function that runs whenever the module is deactivated [signature (module instance, owner instance)]
--      extra_prefabs - Additional prefabs to be imported alongside the module, such as fx prefabs
--
--      returns a net id for the module, to send for UI purposes; also adds that net id (as module_netid) to the passed definition.
local function AddNewModuleDefinition(module_definition)
    assert(module_netid < 64, "To support additional WX modules, player_classified.upgrademodules must be updated")

    module_definition.module_netid = module_netid
    module_netid_lookup[module_netid] = module_definition
    module_netid = module_netid + 1

    return module_definition.module_netid
end

-- Given a module net id, get the definition table of that module.
local function GetModuleDefinitionFromNetID(netid)
    return (netid ~= nil and module_netid_lookup[netid])
        or nil
end

for _, definition in ipairs(module_definitions) do
    AddNewModuleDefinition(definition)
end

---------------------------------------------------------------

return {
    module_definitions = module_definitions,
    AddNewModuleDefinition = AddNewModuleDefinition,
    GetModuleDefinitionFromNetID = GetModuleDefinitionFromNetID,

    AddCreatureScanDataDefinition = AddCreatureScanDataDefinition,
    GetCreatureScanDataDefinition = GetCreatureScanDataDefinition,
}
