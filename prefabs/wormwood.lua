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
    Asset("ANIM", "anim/wormwood_pollen_fx.zip"),
    Asset("ANIM", "anim/wormwood_bloom_fx.zip"),
}

local prefabs =
{
    "wormwood_plant_fx",
}

local start_inv =
{
    default =
    {
    },
}
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
    for i = #inst.plantbonuses, 1, -1 do
        local v = inst.plantbonuses[i]
        if v.t > dt then
            v.t = v.t - dt
        else
            table.remove(inst.plantbonuses, i)
        end
        amt = amt + v.amt
    end
    for i = #inst.plantpenalties, 1, -1 do
        local v = inst.plantpenalties[i]
        if v.t > dt then
            v.t = v.t - dt
        else
            table.remove(inst.plantpenalties, i)
        end
        amt = amt + v.amt
    end
    return amt
end

local function DoPlantBonus(inst, bonus, overtime)
    if overtime then
        table.insert(inst.plantbonuses, { amt = bonus / SANITY_DRAIN_TIME, t = SANITY_DRAIN_TIME })
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
        table.insert(inst.plantpenalties, { amt = -penalty / SANITY_DRAIN_TIME, t = SANITY_DRAIN_TIME })
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
    if inst._onitemplanted == nil then
        inst._onitemplanted = function(src, data)
            if data == nil then
                --shouldn't happen
            elseif data.doer == inst then
                DoPlantBonus(inst, TUNING.SANITY_TINY * 2)
            elseif data.pos ~= nil then
                local distsq = inst:GetDistanceSqToPoint(data.pos)
                if distsq < WATCH_WORLD_PLANTS_DIST_SQ then
                    DoPlantBonus(inst, CalcSanityMult(distsq) * TUNING.SANITY_SUPERTINY * 2, true)
                end
            end
        end
        inst:ListenForEvent("itemplanted", inst._onitemplanted, TheWorld)
    end
    if inst._onplantkilled == nil then
        inst._onplantkilled = function(src, data)
            if data == nil then
                --shouldn't happen
            elseif data.doer == inst then
                DoKillPlantPenalty(inst, data.workaction ~= nil and data.workaction ~= ACTIONS.DIG and TUNING.SANITY_MED or TUNING.SANITY_TINY)
            elseif data.pos ~= nil then
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
    if inst._onitemplanted ~= nil then
        inst:RemoveEventCallback("itemplanted", inst._onitemplanted, TheWorld)
        inst._onitemplanted = nil
    end
    if inst._onplantkilled ~= nil then
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

    if inst.replica.rider ~= nil and inst.replica.rider:IsRiding() then
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
    inst.bloomfx:set(inst.overrideskinmode == nil or inst.overrideskinmode == "stage_2")
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

local function DoSpawnPollen(inst)
    --This is an untracked task from PollenTick, so we nil check .pollentask instead.
    if inst.pollentask ~= nil and
        not (inst.sg:HasStateTag("nomorph") or
            inst.sg:HasStateTag("silentmorph") or
            inst.sg:HasStateTag("ghostbuild") or
            inst.components.health:IsDead()) and
        inst.entity:IsVisible() then
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

local function PlantTick(inst)
    if inst.sg:HasStateTag("ghostbuild") or inst.components.health:IsDead() or not inst.entity:IsVisible() then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    if #TheSim:FindEntities(x, y, z, PLANTS_RANGE, { "wormwood_plant_fx" }) < MAX_PLANTS then
        local map = TheWorld.Map
        local pt = Vector3(0, 0, 0)
        local offset = FindValidPositionByFan(
            math.random() * 2 * PI,
            math.random() * PLANTS_RANGE,
            3,
            function(offset)
                pt.x = x + offset.x
                pt.z = z + offset.z
                local tile = map:GetTileAtPoint(pt:Get())
                return tile ~= GROUND.ROCKY
                    and tile ~= GROUND.ROAD
                    and tile ~= GROUND.WOODFLOOR
                    and tile ~= GROUND.CARPET
                    and tile ~= GROUND.IMPASSABLE
                    and tile ~= GROUND.INVALID
                    and #TheSim:FindEntities(pt.x, 0, pt.z, .5, { "wormwood_plant_fx" }) < 3
                    and map:IsDeployPointClear(pt, nil, .5)
                    and not map:IsPointNearHole(pt, .4)
            end
        )
        if offset ~= nil then
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

local function EnableFullBloom(inst, enable)
    if enable then
        if not inst.fullbloom then
            inst.fullbloom = true
            if inst.pollentask == nil then
                inst.pollentask = inst:DoPeriodicTask(.7, PollenTick)
            end
            if inst.planttask == nil then
                inst.planttask = inst:DoPeriodicTask(.25, PlantTick)
            end
        end
    elseif inst.fullbloom then
        inst.fullbloom = nil
        if inst.pollentask ~= nil then
            inst.pollentask:Cancel()
            inst.pollentask = nil
        end
        if inst.planttask ~= nil then
            inst.planttask:Cancel()
            inst.planttask = nil
        end
    end
end

local function SetStatsLevel(inst, level)
    --V2C: setting .runspeed does not stack with mount speed
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * Remap(level, 0, 3, 1, 1.2)
    inst.components.hunger:SetRate(Remap(level, 0, 3, TUNING.WILSON_HUNGER_RATE, TUNING.WILSON_HUNGER_RATE * 2))
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

local function SetBloomStage(inst, stage)
    --The setters will all check for dirty values, since refreshing bloom
    --stage can potentially get triggered quite often with state changes.

    local isghost = inst:HasTag("playerghost") or inst.sg:HasStateTag("ghostbuild")
    if isghost then
        EnableBeeBeacon(inst, false)
        EnableFullBloom(inst, false)
        SetStatsLevel(inst, 0)
        SetUserFlagLevel(inst, 0)
    end

    if (inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph") or not inst.entity:IsVisible()) and not inst._forcestage then
        return
    elseif not isghost then
        EnableBeeBeacon(inst, stage > 0)
        EnableFullBloom(inst, stage >= 3)
        SetStatsLevel(inst, stage)
        SetUserFlagLevel(inst, stage)
    end

    if stage <= 0 then
        inst.overrideskinmode = nil
        if isghost then
            SetSkinType(inst, "ghost_skin", "ghost_wilson_build")
        elseif SetSkinType(inst, "normal_skin", "wilson") and not (inst._loading or inst._forcestage or inst.components.health:IsDead()) then
            SpawnBloomFX(inst)
        end
    else
        if inst.overrideskinmode == nil and not (isghost or inst._loading) then
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_BLOOMING"))
        end
        inst.overrideskinmode = "stage_"..tostring(stage + 1)
        if isghost then
            SetSkinType(inst, "ghost_skin", "ghost_wilson_build")
        elseif SetSkinType(inst, inst.overrideskinmode, "wilson") and not (inst._loading or inst._forcestage or inst.components.health:IsDead()) then
            SpawnBloomFX(inst)
        end
    end
end

local function OnSeasonProgress(inst, progress)
    if TheWorld.state.isspring then
        local progress = math.floor(progress * 6)
        SetBloomStage(inst, progress < 3 and progress + 1 or math.max(1, 6 - progress))
    else
        SetBloomStage(inst, 1)
    end
end

local function OnNewState(inst)
    if inst._wasnomorph ~= (inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph")) then
        inst._wasnomorph = not inst._wasnomorph
        if not inst._wasnomorph then
            if inst.blooming then
                OnSeasonProgress(inst, TheWorld.state.seasonprogress)
            else
                SetBloomStage(inst, 0)
                --overrideskinmode == nil means successfully set bloom stage 0
                if inst.overrideskinmode == nil then
                    inst._wasnomorph = nil
                    inst:RemoveEventCallback("newstate", OnNewState)
                end
            end
        end
    end
end

local function OnStopGhostBuildInState(inst)
    if inst.overrideskinmode ~= nil then
        SpawnBloomFX(inst)
    end
end

local function OnStartBlooming(inst)
    inst.bloomingtask = nil
    inst.blooming = true
    inst:ListenForEvent("stopghostbuildinstate", OnStopGhostBuildInState)
    inst:WatchWorldState("seasonprogress", OnSeasonProgress)
    OnSeasonProgress(inst, TheWorld.state.seasonprogress)

    if inst._wasnomorph == nil then
        inst._wasnomorph = inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph")
        inst:ListenForEvent("newstate", OnNewState)
    end
end

local function OnStopBlooming(inst)
    inst.unbloomingtask = nil
    inst.blooming = nil
    inst:RemoveEventCallback("stopghostbuildinstate", OnStopGhostBuildInState)
    inst:StopWatchingWorldState("seasonprogress", OnSeasonProgress)
    SetBloomStage(inst, 0)
    --overrideskinmode == nil means successfully set bloom stage 0
    if inst._wasnomorph and inst.overrideskinmode == nil then
        inst._wasnomorph = nil
        inst:RemoveEventCallback("newstate", OnNewState)
    end
end

local function SetBlooming(inst, blooming, instant)
    if blooming then
        if inst.blooming then
            if inst.unbloomingtask ~= nil then
                inst.unbloomingtask:Cancel()
                inst.unbloomingtask = nil
            end
            OnSeasonProgress(inst, TheWorld.state.seasonprogress)
        elseif instant or inst._loading then
            if inst.bloomingtask ~= nil then
                inst.bloomingtask:Cancel()
            end
            OnStartBlooming(inst)
        elseif inst.bloomingtask == nil then
            inst.bloomingtask = inst:DoTaskInTime(math.random() * TUNING.SEG_TIME, OnStartBlooming)
        end
    elseif inst.bloomingtask ~= nil then
        inst.bloomingtask:Cancel()
        inst.bloomingtask = nil
    elseif not inst.blooming then
        --do nothing
    elseif instant or inst._loading then
        if inst.unbloomingtask ~= nil then
            inst.unbloomingtask:Cancel()
        end
        OnStopBlooming(inst)
    elseif inst.unbloomingtask == nil then
        inst.unbloomingtask = inst:DoTaskInTime(math.random() * TUNING.SEG_TIME, OnStopBlooming)
    end
end

local function OnIsSpring(inst, isspring)
    if not inst:HasTag("playerghost") then
        SetBlooming(inst, isspring, false)
    elseif not isspring then
        SetBlooming(inst, false, true)
    end
end

local function OnBecameGhost(inst)
    if inst.blooming then
        if TheWorld.state.isspring then
            OnSeasonProgress(inst, TheWorld.state.seasonprogress)
        else
            SetBlooming(inst, false, true)
        end
    end
    StopWatchingWorldPlants(inst)
end

local function OnRespawnedFromGhost(inst)
    inst.components.burnable:SetBurnTime(TUNING.WORMWOOD_BURN_TIME)
    if inst.blooming then
        inst._forcestage = not inst.sg:HasStateTag("ghostbuild")
        OnSeasonProgress(inst, TheWorld.state.seasonprogress)
        inst._forcestage = nil
    elseif TheWorld.state.isspring then
        SetBlooming(inst, true, false)
    end
    WatchWorldPlants(inst)
end

local function OnNewSpawn(inst)
    if inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = nil
    end
    SetBlooming(inst, TheWorld.state.isspring, false)
end

local function OnPreLoad(inst)
    if inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = nil
    end
    inst._loading = true
end

local function OnLoad(inst)
    SetBlooming(inst, TheWorld.state.isspring, true)
    inst._loading = nil
end

local function OnInit(inst)
    --Client listeners
    inst:ListenForEvent("pollendirty", OnPollenDirty)
    inst:ListenForEvent("bloomfxdirty", OnBloomFXDirty)
end

local function common_postinit(inst)
    inst:AddTag("plantkin")
    inst:AddTag("healonfertilize")

    inst.AnimState:AddOverrideBuild("player_wormwood")
    inst.AnimState:AddOverrideBuild("player_wormwood_fertilizer")

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

    inst.customidleanim = customidleanimfn

    inst.components.health.fire_damage_scale = TUNING.WORMWOOD_FIRE_DAMAGE

    inst.plantbonuses = {}
    inst.plantpenalties = {}
    inst.components.sanity.custom_rate_fn = SanityRateFn

    if inst.components.eater ~= nil then
        --No health from food
        inst.components.eater:SetAbsorptionModifiers(0, 1, 1)
    end

    inst.components.burnable:SetBurnTime(TUNING.WORMWOOD_BURN_TIME)

    inst.blooming = nil
    inst.bloomingtask = nil
    inst.unbloomingtask = nil
    inst.fullbloom = nil
    inst.beebeacon = nil
    inst.overrideskinmode = nil
    inst._wasnomorph = nil

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

    inst:ListenForEvent("equip", OnEquip)
    inst:ListenForEvent("unequip", OnUnequip)
    inst:ListenForEvent("ms_becameghost", OnBecameGhost)
    inst:ListenForEvent("ms_respawnedfromghost", OnRespawnedFromGhost)
    inst:WatchWorldState("isspring", OnIsSpring)
    WatchWorldPlants(inst)

    inst.OnPreLoad = OnPreLoad
    inst.OnLoad = OnLoad
    inst.OnNewSpawn = OnNewSpawn
    inst.inittask = inst:DoTaskInTime(0, OnNewSpawn)
end

return MakePlayerCharacter("wormwood", prefabs, assets, common_postinit, master_postinit)
