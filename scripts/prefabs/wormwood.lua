local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/wormwood.fsb"),
    Asset("ANIM", "anim/player_wormwood.zip"),
    Asset("ANIM", "anim/player_wormwood_fertilizer.zip"),
    Asset("ANIM", "anim/player_mount_wormwood.zip"),
    Asset("ANIM", "anim/player_mount_wormwood_fertilizer.zip"),
    Asset("ANIM", "anim/player_idles_wormwood.zip"),
    Asset("ANIM", "anim/wormwood_skills.zip"),
    Asset("ANIM", "anim/player_mount_wormwood_skills.zip"),
	Asset("ANIM", "anim/wormwood_skills_fx.zip"),
    Asset("ANIM", "anim/wormwood_pollen_fx.zip"),
    Asset("ANIM", "anim/wormwood_bloom_fx.zip"),
    Asset("SCRIPT", "scripts/prefabs/skilltree_wormwood.lua"),
}

local prefabs =
{
    "wormwood_plant_fx",
    "compostheal_buff",
    "wormwood_vined_debuff",

    "wormwood_mutantproxy_carrat",
    "wormwood_mutantproxy_lightflier",
    "wormwood_mutantproxy_fruitdragon",
    "wormwood_lunar_transformation_finish",

    "ipecacsyrup",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WORMWOOD
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local WATCH_WORLD_PLANTS_DIST_SQ = 20 * 20
local SANITY_DRAIN_TIME = 5

local function customidleanimfn(inst)
    return inst.AnimState:CompareSymbolBuilds("hand", "hand_idle_wormwood") and "idle_wormwood" or nil
end

local function OnEquip(inst, data)
    if data.eslot == EQUIPSLOTS.HEAD and not data.item:HasTag("open_top_hat") then
        --V2C: HAH! There's no "beard" in "player_wormwood" build.
        --     This hides the flower, which uses the beard symbol.
        inst.AnimState:OverrideSymbol("beard", "player_wormwood", "beard")
    end
end

local function OnUnequip(inst, data)
    if data.eslot == EQUIPSLOTS.HEAD then
        inst.AnimState:ClearOverrideSymbol("beard")
    end
end

local function SanityRateFn(inst, dt)
    local amt = 0
    for bonus_index = #inst.plantbonuses, 1, -1 do
        local bonus_data = inst.plantbonuses[bonus_index]
        if bonus_data.t > dt then
            bonus_data.t = bonus_data.t - dt
        else
            table.remove(inst.plantbonuses, bonus_index)
        end
        amt = amt + bonus_data.amt
    end
    for bonus_index = #inst.plantpenalties, 1, -1 do
        local penalty_data = inst.plantpenalties[bonus_index]
        if penalty_data.t > dt then
            penalty_data.t = penalty_data.t - dt
        else
            table.remove(inst.plantpenalties, bonus_index)
        end
        amt = amt + penalty_data.amt
    end
    return amt
end

local function DoPlantBonus(inst, bonus, overtime)
    if overtime then
        table.insert(inst.plantbonuses, {
            amt = bonus / SANITY_DRAIN_TIME,
            t = SANITY_DRAIN_TIME
        })
    else
        while #inst.plantpenalties > 0 do
            table.remove(inst.plantpenalties)
        end
        inst.components.sanity:DoDelta(bonus)
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_GROWPLANT"))
    end
end

local function DoKillPlantPenalty(inst, penalty, overtime)
    if overtime then
        table.insert(inst.plantpenalties, {
            amt = -penalty / SANITY_DRAIN_TIME,
            t = SANITY_DRAIN_TIME
        })
    else
        while #inst.plantbonuses > 0 do
            table.remove(inst.plantbonuses)
        end
        inst.components.sanity:DoDelta(-penalty)
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_KILLEDPLANT"))
    end
end

local function CalcSanityMult(distsq)
    distsq = 1 - math.sqrt(distsq / WATCH_WORLD_PLANTS_DIST_SQ)
    return distsq * distsq
end

local function WatchWorldPlants(inst)
    if not inst._onitemplanted then
        inst._onitemplanted = function(src, data)
            if not data then
                --shouldn't happen
            elseif data.doer == inst then
                DoPlantBonus(inst, TUNING.SANITY_TINY * 2)
            elseif data.pos then
                local distsq = inst:GetDistanceSqToPoint(data.pos)
                if distsq < WATCH_WORLD_PLANTS_DIST_SQ then
                    DoPlantBonus(inst, CalcSanityMult(distsq) * TUNING.SANITY_SUPERTINY * 2, true)
                end
            end
        end
        inst:ListenForEvent("itemplanted", inst._onitemplanted, TheWorld)
    end

    if not inst._onplantkilled then
        inst._onplantkilled = function(src, data)
            if not data then
                --shouldn't happen
            elseif data.doer == inst then
                DoKillPlantPenalty(inst, data.workaction and data.workaction ~= ACTIONS.DIG and TUNING.SANITY_MED or TUNING.SANITY_TINY)
            elseif data.pos then
                local distsq = inst:GetDistanceSqToPoint(data.pos)
                if distsq < WATCH_WORLD_PLANTS_DIST_SQ then
                    DoKillPlantPenalty(inst, CalcSanityMult(distsq) * TUNING.SANITY_SUPERTINY * 2, true)
                end
            end
        end
        inst:ListenForEvent("plantkilled", inst._onplantkilled, TheWorld)
    end
end

local function StopWatchingWorldPlants(inst)
    if inst._onitemplanted then
        inst:RemoveEventCallback("itemplanted", inst._onitemplanted, TheWorld)
        inst._onitemplanted = nil
    end
    if inst._onplantkilled then
        inst:RemoveEventCallback("plantkilled", inst._onplantkilled, TheWorld)
        inst._onplantkilled = nil
    end
end

local function OnBloomFXDirty(inst)
    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()

    fx.AnimState:SetBank("wormwood_bloom_fx")
    fx.AnimState:SetBuild("wormwood_bloom_fx")
    fx.AnimState:SetFinalOffset(2)

    if inst.replica.rider and inst.replica.rider:IsRiding() then
        fx.Transform:SetSixFaced()
        fx.AnimState:PlayAnimation(inst.bloomfx:value() and "poof_mounted_less" or "poof_mounted")
    else
        fx.Transform:SetFourFaced()
        fx.AnimState:PlayAnimation(inst.bloomfx:value() and "poof_less" or "poof")
    end

    fx:ListenForEvent("animover", fx.Remove)

    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx.Transform:SetRotation(inst.Transform:GetRotation())

    local skin_build = string.match(inst.AnimState:GetSkinBuild() or "", "wormwood(_.+)") or ""
    skin_build = skin_build:match("(.*)_build$") or skin_build
    skin_build = skin_build:match("(.*)_stage_?%d$") or skin_build
    if skin_build:len() > 0 then
        fx.AnimState:OverrideSkinSymbol("bloom_fx_swap_leaf", "wormwood"..skin_build, "bloom_fx_swap_leaf")
    end
end

local function SpawnBloomFX(inst)
    inst.bloomfx:set_local(false)
    inst.bloomfx:set(not inst.overrideskinmode or inst.overrideskinmode == "stage_2")
    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        OnBloomFXDirty(inst)
    end
    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds", nil, .6)
end

local function OnPollenDirty(inst)
    local fx = CreateEntity()

    fx:AddTag("FX")
    fx:AddTag("NOCLICK")
    --[[Non-networked entity]]
    fx.entity:SetCanSleep(false)
    fx.persists = false

    fx.entity:AddTransform()
    fx.entity:AddAnimState()

    fx.AnimState:SetBank("wormwood_pollen_fx")
    fx.AnimState:SetBuild("wormwood_pollen_fx")
    fx.AnimState:PlayAnimation("pollen"..tostring(inst.pollen:value()))
    fx.AnimState:SetFinalOffset(2)

    fx:ListenForEvent("animover", fx.Remove)

    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function DoSpawnPollen(inst, fertilized)
    --This is an untracked task from PollenTick, so we nil check .pollentask instead.
    if (fertilized or inst.pollentask)
            and (inst.sg:HasStateTag("self_fertilizing") or not (inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph") or inst.sg:HasStateTag("ghostbuild") or inst.components.health:IsDead()))
            and inst.entity:IsVisible() then
        --randomize, favoring ones that haven't been used recently
        local rnd = math.random()
        rnd = table.remove(inst.pollenpool, math.clamp(math.ceil(rnd * rnd * #inst.pollenpool), 1, #inst.pollenpool))
        table.insert(inst.pollenpool, rnd)
        inst.pollen:set_local(0)
        inst.pollen:set(rnd)
        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            OnPollenDirty(inst)
        end
    end
end

local function PollenTick(inst)
    inst:DoTaskInTime(math.random() * .6, DoSpawnPollen)
end

local PLANTS_RANGE = 1
local MAX_PLANTS = 18

local PLANTFX_TAGS = { "wormwood_plant_fx" }
local function PlantTick(inst)
    if inst.sg:HasStateTag("ghostbuild") or inst.components.health:IsDead() or not inst.entity:IsVisible() then
        return
    end

    local t = inst.components.bloomness.timer
    local chance = TheWorld.state.isspring and 1
                    or t <= TUNING.WORMWOOD_BLOOM_PLANTS_WARNING_TIME_LOW and 1/3
                    or t <= TUNING.WORMWOOD_BLOOM_PLANTS_WARNING_TIME_MED and 2/3
                    or 1

    if (chance < 1 and math.random() > chance)
            or inst:GetCurrentPlatform() then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if #TheSim:FindEntities(x, y, z, PLANTS_RANGE, PLANTFX_TAGS) < MAX_PLANTS then
        local map = TheWorld.Map
        local pt = Vector3(0, 0, 0)
        local offset = FindValidPositionByFan(
            math.random() * TWOPI,
            math.random() * PLANTS_RANGE,
            3,
            function(offset)
                pt.x = x + offset.x
                pt.z = z + offset.z
                return map:CanPlantAtPoint(pt.x, 0, pt.z)
                    and #TheSim:FindEntities(pt.x, 0, pt.z, .5, PLANTFX_TAGS) < 3
                    and map:IsDeployPointClear(pt, nil, .5)
                    and not map:IsPointNearHole(pt, .4)
            end
        )
        if offset then
            local plant = SpawnPrefab("wormwood_plant_fx")
            plant.Transform:SetPosition(x + offset.x, 0, z + offset.z)
            --randomize, favoring ones that haven't been used recently
            local rnd = math.random()
            rnd = table.remove(inst.plantpool, math.clamp(math.ceil(rnd * rnd * #inst.plantpool), 1, #inst.plantpool))
            table.insert(inst.plantpool, rnd)
            plant:SetVariation(rnd)
        end
    end
end

local function EnableBeeBeacon(inst, enable)
    if enable then
        if not inst.beebeacon then
            inst.beebeacon = true
            inst:AddTag("beebeacon")
        end
    elseif inst.beebeacon then
        inst.beebeacon = nil
        inst:RemoveTag("beebeacon")
    end
end

local AOE_EFFECTS_ONEOF_TAGS = { "tendable_farmplant", "trap_bramble" }
local AOE_EFFECTS_CANT_TAGS = { "INLIMBO", "FX"}
local DAYLIGHT_MUST_TAGS = {"daylight"}
local DAYLIGHT_CANT_TAGS = {"INLIMBO"}
local function DoAOEeffect(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local skilltreeupdater = inst.components.skilltreeupdater

    local reset_brambletraps, grow_in_daylight
    if skilltreeupdater ~= nil then
        reset_brambletraps = skilltreeupdater:IsActivated("wormwood_blooming_trapbramble")
        grow_in_daylight = skilltreeupdater:IsActivated("wormwood_blooming_photosynthesis")
    end

    local interact_range_multiplier = (
        skilltreeupdater ~= nil and skilltreeupdater:IsActivated("wormwood_blooming_farmrange1") and TUNING.WORMWOOD_TENDRANGE_MULT
        or 1
    )

    local interact_range = TUNING.WORMWOOD_BLOOM_FARM_PLANT_INTERACT_RANGE * interact_range_multiplier
    for _, v in pairs(TheSim:FindEntities(x, y, z, interact_range, nil, AOE_EFFECTS_CANT_TAGS, AOE_EFFECTS_ONEOF_TAGS)) do
        if v.components.farmplanttendable then
            v.components.farmplanttendable:TendTo(inst)

        elseif reset_brambletraps and v.components.mine ~= nil and v:HasTag("minesprung") then
            if v.last_reset == nil or v.last_reset + TUNING.WORMWOOD_TRAP_BRAMBLE_AUTO_RESET_COOLDOWN < GetTime() then
                v.components.mine:Reset()
            end
        end
    end

    local should_grow_in_daylight = TheWorld.state.isday
    if grow_in_daylight and not should_grow_in_daylight then
        local ents = TheSim:FindEntities(x, y, z, TUNING.DAYLIGHT_SEARCH_RANGE, DAYLIGHT_MUST_TAGS, DAYLIGHT_CANT_TAGS)
        for _, v in ipairs(ents) do
            local lightrad = v.Light:GetCalculatedRadius() * .7
            if v:GetDistanceSqToPoint(x, y, z) < lightrad * lightrad then
                should_grow_in_daylight = true
                break
            end
        end
    end

    inst:UpdatePhotosynthesisState(should_grow_in_daylight)
end

local function EnableFullBloom(inst, enable)
    if enable then
        if not inst.fullbloom then
            inst.fullbloom = true

            local skilltreeupdater = inst.components.skilltreeupdater
            local has_upgraded_overheat_protection = (skilltreeupdater ~= nil and skilltreeupdater:IsActivated("wormwood_blooming_overheatprotection"))
            inst.components.temperature.inherentsummerinsulation = (has_upgraded_overheat_protection and TUNING.INSULATION_MED_LARGE)
                or TUNING.INSULATION_SMALL

            if not inst.tendplanttask then
                inst.tendplanttask = inst:DoPeriodicTask(.5, DoAOEeffect)
            end

            -- trail effects
            if not inst.pollentask then
                inst.pollentask = inst:DoPeriodicTask(.7, PollenTick)
            end
            if not inst.planttask then
                inst.planttask = inst:DoPeriodicTask(.25, PlantTick)
            end

            inst:UpdatePhotosynthesisState(TheWorld.state.isday)
        end
    elseif inst.fullbloom then
        inst.fullbloom = nil
        inst.components.temperature.inherentsummerinsulation = 0
        if inst.tendplanttask then
            inst.tendplanttask:Cancel()
            inst.tendplanttask = nil
        end

        -- trail effects
        if inst.pollentask then
            inst.pollentask:Cancel()
            inst.pollentask = nil
        end
        if inst.planttask then
            inst.planttask:Cancel()
            inst.planttask = nil
        end

        inst:UpdatePhotosynthesisState(TheWorld.state.isday)
    end
end

local function SetStatsLevel(inst, level)
    --V2C: setting .runspeed does not stack with mount speed
    local mult = Remap(level, 0, 3, 1, 1.2)
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * mult
    inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE * mult)
end

local function SetUserFlagLevel(inst, level)
    --No bit ops support, but in this case, + results in same as |
    local flags = USERFLAGS.CHARACTER_STATE_1 + USERFLAGS.CHARACTER_STATE_2 + USERFLAGS.CHARACTER_STATE_3
    if level > 0 then
        local addflag = USERFLAGS["CHARACTER_STATE_"..tostring(level)]
        --No bit ops support, but in this case, - results in same as &~
        inst.Network:RemoveUserFlag(flags - addflag)
        inst.Network:AddUserFlag(addflag)
    else
        inst.Network:RemoveUserFlag(flags)
    end
end

local function SetSkinType(inst, skintype, defaultbuild)
    --Return true if build change needs to spawn bloom FX
    local oldskintype = inst.components.skinner:GetSkinMode()
    if oldskintype ~= skintype and
            not (skintype == "ghost_skin" and oldskintype == "normal_skin") and
            not (oldskintype == "ghost_skin" and skintype == "normal_skin") then
        inst.components.skinner:SetSkinMode(skintype, defaultbuild)
        return true
    end
end

local function OnNewSGState(inst)
    if not inst.sg:HasStateTag("nomorph") then
        inst:UpdateBloomStage()
    end
end

local function OnStopGhostBuildInState(inst)
    if inst.overrideskinmode then
        SpawnBloomFX(inst)
    end
end

local function UpdateBloomStage(inst, stage)
    --The setters will all check for dirty values, since refreshing bloom
    --stage can potentially get triggered quite often with state changes.

    stage = stage or inst.components.bloomness:GetLevel()
    local is_blooming = inst.components.bloomness.is_blooming

    local isghost = inst:HasTag("playerghost") or inst.sg:HasStateTag("ghostbuild")

    if not isghost and inst.sg:HasStateTag("nomorph") then
        inst._queued_morph = true
        inst:ListenForEvent("newstate", OnNewSGState)
        return
    else
        EnableBeeBeacon(inst, stage > 0)
        EnableFullBloom(inst, stage >= 3)
        SetStatsLevel(inst, stage)
        SetUserFlagLevel(inst, stage)
    end

    if inst._queued_morph then
        inst._queued_morph = false
        inst:RemoveEventCallback("newstate", OnNewSGState)
    end

    local silent = inst._loading or inst.components.health:IsDead() or not inst.entity:IsVisible() or inst.sg:HasStateTag("silentmorph")

    if stage <= 0 then
        inst:RemoveEventCallback("stopghostbuildinstate", OnStopGhostBuildInState)
        inst.overrideskinmode = nil
        if isghost then
            SetSkinType(inst, "ghost_skin", "ghost_wilson_build")
        elseif SetSkinType(inst, "normal_skin", "wilson") and not silent then
            SpawnBloomFX(inst)
        end
    else
        if not inst.overrideskinmode and not silent and not isghost then
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_BLOOMING"))
        end
        inst.overrideskinmode = "stage_"..tostring(stage + 1)
        inst:ListenForEvent("stopghostbuildinstate", OnStopGhostBuildInState)
        if isghost then
            SetSkinType(inst, "ghost_skin", "ghost_wilson_build")
        elseif SetSkinType(inst, inst.overrideskinmode, "wilson") and not silent then
            SpawnBloomFX(inst)
        end
    end
end

local function OnFertilizedWithFormula(inst, value)
    if value > 0 and inst.components.bloomness then
        if inst.components.skilltreeupdater:IsActivated("wormwood_blooming_max_upgrade") then
            value = value * TUNING.WORMWOOD_BLOOM_MAX_UPGRADE_MULT
        end
        inst.components.bloomness:Fertilize(value)
    end
end

local function OnFertilizedWithCompost(inst, value)
    if value > 0 and inst.components.health and not inst.components.health:IsDead() then
        local healing = TUNING.WORMWOOD_COMPOST_HEAL_VALUES[math.ceil(value / 8)] or TUNING.WORMWOOD_COMPOST_HEAL_VALUES[1]
        inst:AddDebuff("compostheal_buff", "compostheal_buff", {duration = healing * (TUNING.WORMWOOD_COMPOST_HEALOVERTIME_TICK/TUNING.WORMWOOD_COMPOST_HEALOVERTIME_HEALTH)})
    end
end

local function OnFertilizedWithManure(inst, value, src)
    if value > 0 and inst.components.bloomness then
        local healing = TUNING.WORMWOOD_MANURE_HEAL_VALUES[math.ceil(value / 8)] or TUNING.WORMWOOD_MANURE_HEAL_VALUES[1]
        inst.components.health:DoDelta(healing, false, src.prefab)
    end
end

local function OverrideAcidRainTickFn(inst, damage)
    inst:OnFertilizedWithFormula(damage)
end

local function OnFertilized(inst, fertilizer_obj)
    if inst.components.health and inst.components.health.canheal then
        local fertilizer = fertilizer_obj.components.fertilizer
        if fertilizer and fertilizer.nutrients then
            if fertilizer.planthealth then
                --inst.components.health:DoDelta(fertilizer.planthealth, false, fertilizer_obj.prefab)
            end
            if fertilizer.nutrients then
                inst:OnFertilizedWithFormula(fertilizer.nutrients[TUNING.FORMULA_NUTRIENTS_INDEX], fertilizer_obj)
                inst:OnFertilizedWithCompost(fertilizer.nutrients[TUNING.COMPOST_NUTRIENTS_INDEX], fertilizer_obj)
                inst:OnFertilizedWithManure(fertilizer.nutrients[TUNING.MANURE_NUTRIENTS_INDEX], fertilizer_obj)
                return true
            end
        end
    end
end

local function CalcBloomRateFn(inst, level, is_blooming, fertilizer)
    local season_mult = 1
    if TheWorld.state.season == "spring" then
        if is_blooming then
            season_mult = TUNING.WORMWOOD_SPRING_BLOOM_MOD
        else
            return TUNING.WORMWOOD_SPRING_BLOOMDRAIN_RATE
        end
    elseif TheWorld.state.season == "winter" then
        if is_blooming then
            season_mult = TUNING.WORMWOOD_WINTER_BLOOM_MOD
        else
            return TUNING.WORMWOOD_WINTER_BLOOMDRAIN_RATE
        end
    end

    local rate = (is_blooming and fertilizer > 0) and (season_mult * (1 + fertilizer * TUNING.WORMWOOD_FERTILIZER_RATE_MOD)) or 1
    return rate
end

local function CalcFullBloomDurationFn(inst, value, remaining, full_bloom_duration)
    value = value * TUNING.WORMWOOD_FERTILIZER_BLOOM_TIME_MOD

    local actual_maximum = (inst.components.skilltreeupdater and
                                inst.components.skilltreeupdater:IsActivated("wormwood_blooming_max_upgrade") and
                                TUNING.WORMWOOD_BLOOM_FULL_MAX_DURATION_UPGRADED)
                            or TUNING.WORMWOOD_BLOOM_FULL_MAX_DURATION
    return math.min(remaining + value, actual_maximum)
end

local function OnSeasonChange(inst, season)
    if season == "spring" and not inst:HasTag("playerghost") then
        inst.components.bloomness:Fertilize()
    else
        inst.components.bloomness:UpdateRate()
    end
end

local function OnBecameGhost(inst)
    inst.components.bloomness:SetLevel(0)
    StopWatchingWorldPlants(inst)

    inst:UpdatePhotosynthesisState(TheWorld.state.isday)
end

local function OnRespawnedFromGhost(inst)
    if TheWorld.state.isspring then
        inst.components.bloomness:Fertilize()
    end
    WatchWorldPlants(inst)

    inst:UpdatePhotosynthesisState(TheWorld.state.isday)
end

local function WLFSort(a, b) -- Better than roundcheck!
    return a.GUID < b.GUID
end

local function RecalculateLightFlierLight(inst)
    local pets = inst.components.petleash and inst.components.petleash:GetPetsWithPrefab("wormwood_lightflier") or nil
    if pets == nil then
        return
    end

    local mult = Remap(#pets, 1, TUNING.WORMWOOD_PET_LIGHTFLIER_LIMIT, 1, 2)

    for i, pet in ipairs(pets) do
        pet.Light:SetRadius(1.8 * mult)
    end
end

local function RecalculateLightFlierPattern(inst)
    local pets = inst.components.petleash and inst.components.petleash:GetPetsWithPrefab("wormwood_lightflier") or nil
    if pets then
        inst.wormwood_lightflier_pattern = pets
        table.sort(pets, WLFSort)
        for i, v in ipairs(pets) do
            pets[v] = i
        end
        pets.maxpets = #pets
    else
        inst.wormwood_lightflier_pattern = nil
    end
end

local function RecalculateDragonHealth(inst)
    local pets = inst.components.petleash and inst.components.petleash:GetPetsWithPrefab("wormwood_fruitdragon") or nil
    if pets == nil then
        return
    end

    if #pets >= TUNING.WORMWOOD_PET_FRUITDRAGON_LIMIT then
        for i, pet in ipairs(pets) do
            local oldpercent = pet.components.health:GetPercent()
            pet.components.health:SetMaxHealth(TUNING.WORMWOOD_PET_FRUITDRAGON_BUFF_HEALTH)
            pet.components.health:SetCurrentHealth(TUNING.WORMWOOD_PET_FRUITDRAGON_BUFF_HEALTH*oldpercent)
        end
    else
        for i, pet in ipairs(pets) do
            local oldpercent = pet.components.health:GetPercent()
            pet.components.health:SetMaxHealth(TUNING.WORMWOOD_PET_FRUITDRAGON_HEALTH)
            pet.components.health:SetCurrentHealth(TUNING.WORMWOOD_PET_FRUITDRAGON_HEALTH*oldpercent)
        end        
    end
end

local function OnSpawnPet(inst, pet)
    if pet.prefab == "wormwood_lightflier" then
        inst:RecalculateLightFlierPattern()
        inst:RecalculateLightFlierLight()
    end

    if pet.prefab == "wormwood_fruitdragon" then
        inst:RecalculateDragonHealth()
    end

    if inst._OnSpawnPet ~= nil then
        inst:_OnSpawnPet(pet)
    end
end

local function OnDespawnPet(inst, pet)
    if pet.prefab == "wormwood_lightflier" then
        inst:RecalculateLightFlierPattern()
        inst:RecalculateLightFlierLight()
    end

    if pet.prefab == "wormwood_fruitdragon" then
        inst:RecalculateDragonHealth()
    end

    if inst._OnDespawnPet ~= nil then
        inst:_OnDespawnPet(pet)
    end
end

local function OnRemovedPet(inst, pet)
    if pet.prefab == "wormwood_lightflier" then
        inst:RecalculateLightFlierPattern()
        inst:RecalculateLightFlierLight()
    end

    if pet.prefab == "wormwood_fruitdragon" then
        inst:RecalculateDragonHealth()
    end    
end

local function OnNewSpawn(inst)
    if inst.inittask then
        inst.inittask:Cancel()
        inst.inittask = nil
    end
    if TheWorld.state.isspring then
        inst.components.bloomness:Fertilize()
    end
end

local function OnPreLoad(inst)
    if inst.inittask then
        inst.inittask:Cancel()
        inst.inittask = nil
    end
    inst._loading = true
end

local function OnLoad(inst)
    inst._loading = nil
end

local function OnInit(inst)
    --Client listeners
    inst:ListenForEvent("pollendirty", OnPollenDirty)
    inst:ListenForEvent("bloomfxdirty", OnBloomFXDirty)
end

-- Also called from skilltree_wormwood.lua
local function UpdatePhotosynthesisState(inst, isday)
    local should_photosynthesize = false
    if isday and inst.fullbloom and inst.components.skilltreeupdater and inst.components.skilltreeupdater:IsActivated("wormwood_blooming_photosynthesis") and not inst:HasTag("playerghost") then
        should_photosynthesize = true
    end
    if should_photosynthesize ~= inst.photosynthesizing then
        inst.photosynthesizing = should_photosynthesize
        if inst.components.health then
            if should_photosynthesize then
                local regen = TUNING.WORMWOOD_PHOTOSYNTHESIS_HEALTH_REGEN
                inst.components.health:AddRegenSource(inst, regen.amount, regen.period, "photosynthesis_skill")
            else
                inst.components.health:RemoveRegenSource(inst, "photosynthesis_skill")
            end
        end
    end
end

local function RemoveWormwoodPets(inst)
    local todespawn = {}
    for k, v in pairs(inst.components.petleash:GetPets()) do
        if v:HasTag("wormwood_pet") then
            table.insert(todespawn, v)
        end
    end
    for i, v in ipairs(todespawn) do
        v:RemoveWormwoodPet()
    end
end

local function common_postinit(inst)
    inst:AddTag("plantkin")
    inst:AddTag("self_fertilizable")

	--inst.AnimState:AddOverrideBuild("player_wormwood") --V2C: "form_log" state now overrides symbol everytime, depending on product
    inst.AnimState:AddOverrideBuild("player_wormwood_fertilizer")
    inst.AnimState:AddOverrideBuild("wormwood_skills")

    if LOC.GetTextScale() == 1 then
        --Note(Peter): if statement is hack/guess to make the talker not resize for users that are likely to be speaking using the fallback font.
        --Doesn't work for users across multiple languages or if they speak in english despite having a UI set to something else, but it's more likely to be correct, and is safer than modifying the talker

        inst.components.talker.fontsize = 40
    end
    inst.components.talker.font = TALKINGFONT_WORMWOOD

    inst.pollen = net_tinybyte(inst.GUID, "wormwood.pollen", "pollendirty")
    inst.bloomfx = net_bool(inst.GUID, "wormwood.bloomfx", "bloomfxdirty")
    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, OnInit)
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.endtalksound = "dontstarve/characters/wormwood/end"
    --inst.endghosttalksound = nil

    inst.components.health:SetMaxHealth(TUNING.WORMWOOD_HEALTH)
    inst.components.hunger:SetMax(TUNING.WORMWOOD_HUNGER)
    inst.components.sanity:SetMax(TUNING.WORMWOOD_SANITY)

    inst.customidleanim = customidleanimfn

    inst.components.health.fire_damage_scale = TUNING.WORMWOOD_FIRE_DAMAGE

    inst.plantbonuses = {}
    inst.plantpenalties = {}
    inst.components.sanity.custom_rate_fn = SanityRateFn
    inst.components.sanity.no_moisture_penalty = true

    if inst.components.eater then
        --No health from food
        inst.components.eater:SetAbsorptionModifiers(0, 1, 1)
    end

    if inst.components.petleash ~= nil then
        inst._OnSpawnPet = inst.components.petleash.onspawnfn
        inst._OnDespawnPet = inst.components.petleash.ondespawnfn
    else
        inst:AddComponent("petleash")
    end
    local petleash = inst.components.petleash
    petleash:SetOnSpawnFn(OnSpawnPet)
    petleash:SetOnDespawnFn(OnDespawnPet)
    petleash:SetOnRemovedFn(OnRemovedPet)
    petleash:SetMaxPetsForPrefab("wormwood_lightflier", TUNING.WORMWOOD_PET_LIGHTFLIER_LIMIT)
    petleash:SetMaxPetsForPrefab("wormwood_carrat", TUNING.WORMWOOD_PET_CARRAT_LIMIT)
    petleash:SetMaxPetsForPrefab("wormwood_fruitdragon", TUNING.WORMWOOD_PET_FRUITDRAGON_LIMIT)

    inst.components.foodaffinity:AddPrefabAffinity("cave_banana_cooked", TUNING.AFFINITY_15_CALORIES_SMALL)

    inst.components.burnable:SetBurnTime(TUNING.WORMWOOD_BURN_TIME)

    inst.fullbloom = nil
    inst.beebeacon = nil
    inst.overrideskinmode = nil

    inst.pollentask = nil
    inst.pollenpool = { 1, 2, 3, 4, 5 }
    for i = #inst.pollenpool, 1, -1 do
        --randomize in place
        table.insert(inst.pollenpool, table.remove(inst.pollenpool, math.random(i)))
    end

    inst.planttask = nil
    inst.plantpool = { 1, 2, 3, 4 }
    for i = #inst.plantpool, 1, -1 do
        --randomize in place
        table.insert(inst.plantpool, table.remove(inst.plantpool, math.random(i)))
    end

    local bloomness = inst:AddComponent("bloomness")
    bloomness:SetDurations(TUNING.WORMWOOD_BLOOM_STAGE_DURATION, TUNING.WORMWOOD_BLOOM_FULL_DURATION)
    bloomness.onlevelchangedfn = UpdateBloomStage
    bloomness.calcratefn = CalcBloomRateFn
    bloomness.calcfullbloomdurationfn = CalcFullBloomDurationFn

    local fertilizable = inst:AddComponent("fertilizable")
    fertilizable.onfertlizedfn = OnFertilized

    inst.components.acidlevel:SetOverrideAcidRainTickFn(OverrideAcidRainTickFn)

    inst.OnFertilizedWithFormula = OnFertilizedWithFormula
    inst.OnFertilizedWithCompost = OnFertilizedWithCompost
    inst.OnFertilizedWithManure = OnFertilizedWithManure

    inst:ListenForEvent("equip", OnEquip)
    inst:ListenForEvent("unequip", OnUnequip)
    inst:ListenForEvent("ms_becameghost", OnBecameGhost)
    inst:ListenForEvent("ms_respawnedfromghost", OnRespawnedFromGhost)
	inst:ListenForEvent("ms_playerreroll", RemoveWormwoodPets)
	inst:ListenForEvent("death", RemoveWormwoodPets)
    inst:WatchWorldState("season", OnSeasonChange)
    WatchWorldPlants(inst)

    inst.UpdateBloomStage = UpdateBloomStage
    inst.RecalculateLightFlierPattern = RecalculateLightFlierPattern
    inst.RecalculateDragonHealth = RecalculateDragonHealth
    inst.RecalculateLightFlierLight = RecalculateLightFlierLight
    inst.UpdatePhotosynthesisState = UpdatePhotosynthesisState

    inst.OnPreLoad = OnPreLoad
    inst.OnLoad = OnLoad
    inst.OnNewSpawn = OnNewSpawn
    inst.inittask = inst:DoTaskInTime(0, OnNewSpawn)
end

return MakePlayerCharacter("wormwood", prefabs, assets, common_postinit, master_postinit)
