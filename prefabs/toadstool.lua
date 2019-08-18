require("prefabs/mushtree_spores")

local easing = require("easing")

local assets =
{
    Asset("ANIM", "anim/toadstool_basic.zip"),
    Asset("ANIM", "anim/toadstool_actions.zip"),
    Asset("ANIM", "anim/toadstool_build.zip"),
    Asset("ANIM", "anim/toadstool_upg_build.zip"),
}

local assets_dark =
{
    Asset("ANIM", "anim/toadstool_basic.zip"),
    Asset("ANIM", "anim/toadstool_actions.zip"),
    Asset("ANIM", "anim/toadstool_dark_build.zip"),
    Asset("ANIM", "anim/toadstool_dark_upg_build.zip"),
}

local prefabs =
{
    "mushroomsprout",
    "mushroombomb_projectile",
    "mushroom_light_blueprint",
}

local prefabs_dark =
{
    "mushroomsprout_dark",
    "mushroombomb_dark_projectile",
    "sleepbomb_blueprint",
}

for i, v in ipairs({
    "sporebomb",

    --loot
    "froglegs",
    "meat",
    "shroom_skin",
    "red_cap",
    "blue_cap",
    "green_cap",
    "red_mushroomhat_blueprint",
    "green_mushroomhat_blueprint",
    "blue_mushroomhat_blueprint",
    "mushroom_light2_blueprint",
    MUSHTREE_SPORE_RED,
    MUSHTREE_SPORE_GREEN,
    MUSHTREE_SPORE_BLUE,
}) do
    table.insert(prefabs, v)
    table.insert(prefabs_dark, v)
end

local function AddSporeLoot(inst)
    -- 2-3 spores
    local spores = PickSomeWithDups(3, { MUSHTREE_SPORE_RED, MUSHTREE_SPORE_GREEN, MUSHTREE_SPORE_BLUE })
    inst.components.lootdropper:AddChanceLoot(spores[1], 1)
    inst.components.lootdropper:AddChanceLoot(spores[2], 1)
    inst.components.lootdropper:AddChanceLoot(spores[3], .5)
end

local function AddSpecialLoot(inst)
    -- one hat
    local hats = { "red_mushroomhat_blueprint", "green_mushroomhat_blueprint", "blue_mushroomhat_blueprint" }
    inst.components.lootdropper:AddChanceLoot(hats[math.random(#hats)], 1)

    -- one mushroom light
    inst.components.lootdropper:AddChanceLoot(math.random() < .33 and "mushroom_light2_blueprint" or "mushroom_light_blueprint", 1)

    AddSporeLoot(inst)
end

local function AddSpecialLootDark(inst)
    -- two hats
    local hats = { "red_mushroomhat_blueprint", "green_mushroomhat_blueprint", "blue_mushroomhat_blueprint" }
    inst.components.lootdropper:AddChanceLoot(table.remove(hats, math.random(#hats)), 1)
    inst.components.lootdropper:AddChanceLoot(table.remove(hats, math.random(#hats)), 1)

    AddSporeLoot(inst)
end

SetSharedLootTable('toadstool',
{
    {"froglegs",      1.00},
    {"meat",          1.00},
    {"meat",          1.00},
    {"meat",          1.00},
    {"meat",          0.50},
    {"meat",          0.25},

    {"shroom_skin",   1.00},

    {"red_cap",       1.00},
    {"red_cap",       0.33},
    {"red_cap",       0.33},

    {"blue_cap",      1.00},
    {"blue_cap",      0.33},
    {"blue_cap",      0.33},

    {"green_cap",     1.00},
    {"green_cap",     0.33},
    {"green_cap",     0.33},
})

SetSharedLootTable('toadstool_dark',
{
    {"froglegs",      1.00},
    {"meat",          1.00},
    {"meat",          1.00},
    {"meat",          1.00},
    {"meat",          0.50},
    {"meat",          0.25},

    {"shroom_skin",   1.00},
    {"shroom_skin",   1.00},

    {"red_cap",       1.00},
    {"red_cap",       0.33},
    {"red_cap",       0.33},

    {"blue_cap",      1.00},
    {"blue_cap",      0.33},
    {"blue_cap",      0.33},

    {"green_cap",     1.00},
    {"green_cap",     0.33},
    {"green_cap",     0.33},

    {"mushroom_light2_blueprint", 1.00},
    {"sleepbomb_blueprint", 1.00},
})

--------------------------------------------------------------------------

local brain = require("brains/toadstoolbrain")

--------------------------------------------------------------------------

local FADE_FRAMES = 20
local FADE_INTENSITY = .75
local FADE_RADIUS = 2
local FADE_FALLOFF = .5

local function OnUpdateFade(inst)
    local k
    if inst._fade:value() <= FADE_FRAMES then
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES))
        k = inst._fade:value() / FADE_FRAMES
    else
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES * 2 + 1))
        k = (FADE_FRAMES * 2 + 1 - inst._fade:value()) / FADE_FRAMES
    end

    inst.Light:SetIntensity(FADE_INTENSITY * k)
    inst.Light:SetRadius(FADE_RADIUS * k)
    inst.Light:SetFalloff(1 - (1 - FADE_FALLOFF) * k)

    if TheWorld.ismastersim then
        inst.Light:Enable(inst._fade:value() > 0 and inst._fade:value() <= FADE_FRAMES * 2)
    end

    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
end

local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end

local function FadeOut(inst)
    inst._fade:set(FADE_FRAMES + 1)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
end

local function CancelFade(inst)
    inst._fade:set(FADE_FRAMES)
    OnFadeDirty(inst)
end

--------------------------------------------------------------------------

local function FindSporeBombTargets(inst, preferredtargets)
    local targets = {}

    if preferredtargets ~= nil then
        for i, v in ipairs(preferredtargets) do
            if v:IsValid() and v.entity:IsVisible() and
                v.components.debuffable ~= nil and
                v.components.debuffable:IsEnabled() and
                not v.components.debuffable:HasDebuff("sporebomb") and
                not (v.components.health ~= nil and
                    v.components.health:IsDead()) and
                not v:HasTag("playerghost") and
                v:IsNear(inst, TUNING.TOADSTOOL_SPOREBOMB_HIT_RANGE) then
                table.insert(targets, v)
                if #targets >= inst.sporebomb_targets then
                    return targets
                end
            end
        end
    end

    local newtargets = {}
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.TOADSTOOL_SPOREBOMB_ATTACK_RANGE, { "debuffable" }, { "ghost", "playerghost", "shadow", "shadowminion", "noauradamage", "INLIMBO" })
    for i, v in ipairs(ents) do
        if v.entity:IsVisible() and
            v.components.debuffable ~= nil and
            not v.components.debuffable:HasDebuff("sporebomb") and
            not (v.components.health ~= nil and
                v.components.health:IsDead()) then
            table.insert(newtargets, v)
        end
    end

    for i = #targets + 1, inst.sporebomb_targets do
        if #newtargets <= 0 then
            return targets
        end
        table.insert(targets, table.remove(newtargets, math.random(#newtargets)))
    end

    return targets
end

local function DoSporeBomb(inst, targets)
    for i, v in ipairs(FindSporeBombTargets(inst, targets)) do
        v.components.debuffable:AddDebuff("sporebomb", "sporebomb")
    end
end

--------------------------------------------------------------------------

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function FindMushroomBombTargets(inst)
    --ring with a random gap
    local maxbombs = inst.mushroombomb_variance > 0 and inst.mushroombomb_count + math.random(inst.mushroombomb_variance) or inst.mushroombomb_count
    local delta = (1 + math.random()) * PI / maxbombs
    local offset = 2 * PI * math.random()
    local angles = {}
    for i = 1, maxbombs do
        table.insert(angles, i * delta + offset)
    end

    --shorten range when mobbed by NPC
    local pt = inst:GetPosition()
    local maxrange = TUNING.TOADSTOOL_MUSHROOMBOMB_MAX_RANGE
    for i = 1, 2 do
        local closerange = (TUNING.TOADSTOOL_MUSHROOMBOMB_MIN_RANGE + maxrange) * .5
        local targets = TheSim:FindEntities(pt.x, 0, pt.z, closerange, { "_combat", "_health" }, { "player", "INLIMBO" })
        if #targets < inst.components.grouptargeter.num_targets then
            break
        end
        maxrange = closerange
    end

    local range = GetRandomMinMax(TUNING.TOADSTOOL_MUSHROOMBOMB_MIN_RANGE, maxrange)
    local targets = {}
    while #angles > 0 do
        local theta = table.remove(angles, math.random(#angles))
        local offset = FindWalkableOffset(pt, theta, range, 12, true, true, NoHoles)
        if offset ~= nil then
            offset.x = offset.x + pt.x
            offset.y = 0
            offset.z = offset.z + pt.z
            table.insert(targets, offset)
        end
    end

    return targets
end

local function SpawnMushroomBombProjectile(inst, targets)
    local x, y, z = inst.Transform:GetWorldPosition()
    local projectile = SpawnPrefab(inst.mushroombomb_prefab)
    projectile.Transform:SetPosition(x, y, z)
    projectile.components.entitytracker:TrackEntity("toadstool", inst)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local targetpos = table.remove(targets, 1)
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = 15
    local bigNum = 15 -- 13 + (math.random()*4)
    local speed = easing.linear(rangesq, bigNum, 3, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)

    if #targets > 0 then
        inst:DoTaskInTime(FRAMES, SpawnMushroomBombProjectile, targets)
    end
end

local function DoMushroomBomb(inst)
    local targets = FindMushroomBombTargets(inst)
    if #targets > 0 then
        inst:DoTaskInTime(FRAMES, SpawnMushroomBombProjectile, targets)
    end
end

--------------------------------------------------------------------------

local function FindMushroomSproutAngles(inst)
    --evenly spaced ring
    local maxspawns = TUNING.TOADSTOOL_MUSHROOMSPROUT_NUM
    local delta = 2 * PI / maxspawns
    local offset = 2 * PI * math.random()
    local angles = {}
    for i = 1, maxspawns do
        table.insert(angles, i * delta + offset)
    end
    return angles
end

local function SproutLaunch(inst, launcher, basespeed)
    local x0, y0, z0 = launcher.Transform:GetWorldPosition()
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local dx, dz = x1 - x0, z1 - z0
    local dsq = dx * dx + dz * dz
    local angle
    if dsq > 0 then
        local dist = math.sqrt(dsq)
        angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
    else
        angle = 2 * PI * math.random()
    end
    local speed = basespeed + math.random()
    inst.Physics:Teleport(x1, .1, z1)
    inst.Physics:SetVel(math.cos(angle) * speed, speed * 4 + math.random() * 2, math.sin(angle) * speed)
end

local function DoMushroomSprout(inst, angles)
    if angles == nil or #angles <= 0 then
        return
    end

    local map = TheWorld.Map
    local pt = inst:GetPosition()
    local theta = table.remove(angles, math.random(#angles))
    local radius = GetRandomMinMax(TUNING.TOADSTOOL_MUSHROOMSPROUT_MIN_RANGE, TUNING.TOADSTOOL_MUSHROOMSPROUT_MAX_RANGE)
    local offset = FindWalkableOffset(pt, theta, radius, 12, true, false, NoHoles)
    pt.y = 0

    --number of attempts to find an unblocked spawn point
    local min_spacing = DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT]
    local min_spacing_sq = min_spacing * min_spacing
    for i = 1, 12 do
        if i > 1 then
            offset = FindWalkableOffset(pt, 2 * PI * math.random(), 2.5, 8, true, false, NoHoles)
        end
        if offset ~= nil then
            pt.x = pt.x + offset.x
            pt.z = pt.z + offset.z
            if #TheSim:FindEntities(pt.x, 0, pt.z, min_spacing, nil, { "_inventoryitem", "playerskeleton", "quickpick", "DIG_workable", "NOBLOCK", "FX", "INLIMBO", "DECOR" }) <= 0 then
                --destroy skeletons and diggables
                for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, 1.2, nil, nil, { "playerskeleton", "DIG_workable" })) do
                    v.components.workable:Destroy(inst)
                end

                local totoss = TheSim:FindEntities(pt.x, 0, pt.z, 1, { "_inventoryitem" }, { "locomotor", "INLIMBO" })

                --toss flowers out of the way
                for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, 1, { "quickpick", "pickable" }, { "intense" })) do
                    local num = v.components.pickable.numtoharvest or 1
                    local product = v.components.pickable.product
                    local x1, y1, z1 = v.Transform:GetWorldPosition()
                    v.components.pickable:Pick(inst) -- only calling this to trigger callbacks on the object
                    if product ~= nil and num > 0 then
                        for i = 1, num do
                            local loot = SpawnPrefab(product)
                            loot.Transform:SetPosition(x1, 0, z1)
                            table.insert(totoss, loot)
                        end
                    end
                end

                local ent = SpawnPrefab(inst.mushroomsprout_prefab)
                ent.Transform:SetPosition(pt:Get())
                ent:PushEvent("linktoadstool", inst)

                --toss stuff out of the way
                for i, v in ipairs(totoss) do
                    if v:IsValid() then
                        if v.components.mine ~= nil then
                            v.components.mine:Deactivate()
                        end
                        if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
                            SproutLaunch(v, ent, 1.5)
                        end
                    end
                end
                break
            end
        end
    end
end

--------------------------------------------------------------------------

local function CalculateLevel(links)
    return (links < 1 and 0)
        or (links < 5 and 1)
        or (links < 8 and 2)
        or 3
end

local function UpdateLevel(inst)
    local level = CalculateLevel(inst._numlinks)

    if not (inst.sg:HasStateTag("frozen") or inst.sg:HasStateTag("thawing")) then
        inst.level = level

        inst.components.locomotor.walkspeed = TUNING.TOADSTOOL_SPEED_LVL[level]
        if inst.dark then
            inst.components.health:SetAbsorptionAmount(TUNING.TOADSTOOL_DARK_ABSORPTION_LVL[level])
            inst.components.combat:SetDefaultDamage(TUNING.TOADSTOOL_DARK_DAMAGE_LVL[level])
        else
            inst.components.health:SetAbsorptionAmount(TUNING.TOADSTOOL_ABSORPTION_LVL[level])
            inst.components.combat:SetDefaultDamage(TUNING.TOADSTOOL_DAMAGE_LVL[level])
        end
        inst.components.combat:SetAttackPeriod(TUNING.TOADSTOOL_ATTACK_PERIOD_LVL[level])
        inst.hit_recovery = TUNING.TOADSTOOL_HIT_RECOVERY_LVL[level]
        inst.mushroombomb_variance = TUNING.TOADSTOOL_MUSHROOMBOMB_VAR_LVL[level]
        inst.mushroombomb_maxchain = TUNING.TOADSTOOL_MUSHROOMBOMB_CHAIN_LVL[level]

        if level < 1 then
            inst.AnimState:ClearOverrideSymbol("toad_mushroom")
        else
            inst.AnimState:OverrideSymbol("toad_mushroom", inst.dark and "toadstool_dark_upg_build" or "toadstool_upg_build", "toad_mushroom"..tostring(level))
        end
    end

    inst:PushEvent("toadstoollevel", level)
end

local function OnUnlinkMushroomSprout(inst, link)
    if inst._links[link] ~= nil then
        inst:RemoveEventCallback("onremove", inst._links[link], link)
        inst._links[link] = nil
        inst._numlinks = inst._numlinks - 1
        UpdateLevel(inst)
    end
end

local function OnLinkMushroomSprout(inst, link)
    if inst._links[link] == nil then
        inst._numlinks = inst._numlinks + 1
        inst._links[link] = function(link) OnUnlinkMushroomSprout(inst, link) end
        inst:ListenForEvent("onremove", inst._links[link], link)
        UpdateLevel(inst)
    end
end

--------------------------------------------------------------------------

local function UpdatePlayerTargets(inst)
    local toadd = {}
    local toremove = {}
    local pos = inst.components.knownlocations:GetLocation("spawnpoint")

    for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
        toremove[k] = true
    end
    for i, v in ipairs(FindPlayersInRange(pos.x, pos.y, pos.z, TUNING.TOADSTOOL_DEAGGRO_DIST, true)) do
        if toremove[v] then
            toremove[v] = nil
        else
            table.insert(toadd, v)
        end
    end

    for k, v in pairs(toremove) do
        inst.components.grouptargeter:RemoveTarget(k)
    end
    for i, v in ipairs(toadd) do
        inst.components.grouptargeter:AddTarget(v)
    end
end

local function RetargetFn(inst)
    UpdatePlayerTargets(inst)

    local player = inst.components.combat.target
    if player ~= nil and player:HasTag("player") then
        local newplayer = inst.components.grouptargeter:TryGetNewTarget()
        if newplayer ~= nil and newplayer:IsNear(inst, TUNING.TOADSTOOL_ATTACK_RANGE) then
            return newplayer, true
        elseif player:IsNear(inst, TUNING.TOADSTOOL_ATTACK_RANGE) then
            return
        elseif newplayer ~= nil then
            player = newplayer
        end
    else
        player = nil
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local nearplayers = FindPlayersInRange(x, y, z, TUNING.TOADSTOOL_ATTACK_RANGE, true)
    if #nearplayers > 0 then
        return nearplayers[math.random(#nearplayers)], true
    end

    --Also needs to deal with other creatures in the world
    local spawnpoint = inst.components.knownlocations:GetLocation("spawnpoint")
    local deaggro_dist_sq = TUNING.TOADSTOOL_DEAGGRO_DIST * TUNING.TOADSTOOL_DEAGGRO_DIST
    local creature = FindEntity(
        inst,
        TUNING.TOADSTOOL_AGGRO_DIST,
        function(guy)
            return inst.components.combat:CanTarget(guy)
                and guy:GetDistanceSqToPoint(spawnpoint) < deaggro_dist_sq
        end,
        { "_combat" }, --see entityreplica.lua
        { "INLIMBO", "prey", "companion"--[[, "smallcreature" <- the beeees... - _-" ]] }
    )

    if player ~= nil and
        (   creature == nil or
            player:GetDistanceSqToPoint(x, y, z) <= creature:GetDistanceSqToPoint(x, y, z)
        ) then
        return player, true
    end

    if creature ~= nil then
        return creature, true
    end
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
        and target:GetDistanceSqToPoint(inst.components.knownlocations:GetLocation("spawnpoint")) < TUNING.TOADSTOOL_DEAGGRO_DIST * TUNING.TOADSTOOL_DEAGGRO_DIST
end

local function OnNewTarget(inst, data)
    if data.target ~= nil then
        inst:RemoveEventCallback("newcombattarget", OnNewTarget)
        inst.engaged = true

        --Ability first use timers 
        inst.components.timer:StartTimer("sporebomb_cd", TUNING.TOADSTOOL_ABILITY_INTRO_CD)
        --inst.components.timer:StartTimer("mushroombomb_cd", inst.mushroombomb_cd)
        inst.components.timer:StartTimer("mushroomsprout_cd", inst.mushroomsprout_cd)
        inst.components.timer:StartTimer("pound_cd", TUNING.TOADSTOOL_ABILITY_INTRO_CD, true)
    end
end

local function OnNewState(inst)
    if inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("frozen") or inst.sg:HasStateTag("thawing") then
        inst.components.timer:PauseTimer("mushroomsprout_cd")
    else
        inst.components.timer:ResumeTimer("mushroomsprout_cd")
    end
end

local function ClearRecentAttacker(inst, attacker)
    if inst._recentattackers[attacker] ~= nil then
        inst._recentattackers[attacker]:Cancel()
        inst._recentattackers[attacker] = nil
    end
end

local function OnAttacked(inst, data)
    if data.attacker ~= nil and data.attacker:HasTag("player") then
        if inst._recentattackers[data.attacker] ~= nil then
            inst._recentattackers[data.attacker]:Cancel()
        end
        inst._recentattackers[data.attacker] = inst:DoTaskInTime(120, ClearRecentAttacker, data.attacker)
    end
end

local function AnnounceWarning(inst, player)
    if player:IsValid() and player.entity:IsVisible() and
        not (player.components.health ~= nil and player.components.health:IsDead()) and
        not player:HasTag("playerghost") and
        not (inst.sg:HasStateTag("noattack") or
            inst.components.combat:HasTarget() or
            inst.components.health:IsDead()) and
        player.components.talker ~= nil then
        player.components.talker:Say(GetString(player, "ANNOUNCE_TOADESCAPING"))
    end
end

local function OnFleeWarning(inst)
    if not (inst.sg:HasStateTag("noattack") or inst.components.health:IsDead()) then
        --Toadstool escaping soon, announce to all live players in range
        --Must re-validate Toadstool state
        local x, y, z = inst.Transform:GetWorldPosition()
        local players = FindPlayersInRange(x, y, z, 40)
        for i, v in ipairs(players) do
            if inst._recentattackers[v] ~= nil then
                inst:DoTaskInTime(math.random() * 2, AnnounceWarning, v)
            end
        end
    end
end

local function AnnounceEscaped(player)
    if player:IsValid() and player.entity:IsVisible() and
        not (player.components.health ~= nil and player.components.health:IsDead()) and
        not player:HasTag("playerghost") and
        player.components.talker ~= nil then
        player.components.talker:Say(GetString(player, "ANNOUNCE_TOADESCAPED"))
    end
end

local function OnEscaped(inst)
    --Toadstool escaped, announce to all live players in range
    --Don't validate Toadstool state
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, 40)
    for i, v in ipairs(players) do
        if inst._recentattackers[v] ~= nil or v:IsNear(inst, 15) then
            v:DoTaskInTime(math.random(), AnnounceEscaped)
        end
    end

    inst:Remove()
end

--------------------------------------------------------------------------

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

--------------------------------------------------------------------------

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
    end
    inst._sleeptask = not inst.components.health:IsDead() and inst:DoTaskInTime(10, inst.Remove) or nil
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end
end

--------------------------------------------------------------------------

local PHASE2_HEALTH = .7
local PHASE3_HEALTH = .4
local PHASE4_HEALTH = .2 --Only triggered for dark version

local function SetPhaseLevel(inst, phase)
    inst.phase = phase
    inst.pound_rnd = phase > 3 and inst.dark
    phase = math.min(3, phase)
    inst.sporebomb_targets = TUNING.TOADSTOOL_SPOREBOMB_TARGETS_PHASE[phase]
    inst.sporebomb_cd = TUNING.TOADSTOOL_SPOREBOMB_CD_PHASE[phase]
    inst.mushroombomb_count = TUNING.TOADSTOOL_MUSHROOMBOMB_COUNT_PHASE[phase]
    if phase > 2 then
        inst.components.timer:ResumeTimer("pound_cd")
    else
        inst.components.timer:StopTimer("pound_cd")
        inst.components.timer:StartTimer("pound_cd", TUNING.TOADSTOOL_ABILITY_INTRO_CD, true)
    end
end

local function DropShroomSkin(inst)
    local player--[[, rangesq]] = inst:GetNearestPlayer()
    LaunchAt(SpawnPrefab("shroom_skin"), inst, player, 1, 4, 2)
end

local function EnterPhase2Trigger(inst)
    if inst.phase < 2 then
        SetPhaseLevel(inst, 2)
        if inst.components.health:GetPercent() > PHASE3_HEALTH then
            DropShroomSkin(inst)
        end
        inst:PushEvent("roar")
    end
end

local function EnterPhase3Trigger(inst)
    if inst.phase < 3 then
        SetPhaseLevel(inst, 3)
        if not inst.components.health:IsDead() then
            DropShroomSkin(inst)
        end
        inst:PushEvent("roar")
    end
end

local function EnterPhase3TriggerDark(inst)
    if inst.phase < 3 then
        SetPhaseLevel(inst, 3)
        if inst.components.health:GetPercent() > PHASE4_HEALTH then
            DropShroomSkin(inst)
        end
        inst:PushEvent("roar")
    end
end

local function EnterPhase4TriggerDark(inst)
    if inst.phase < 4 then
        SetPhaseLevel(inst, 4)
        if not inst.components.health:IsDead() then
            DropShroomSkin(inst)
        end
        inst:PushEvent("roar")
    end
end

local function OnSave(inst, data)
    data.phase = inst.phase
    data.engaged = inst.engaged or nil
    data.poundspeed = inst.pound_speed > 0 and math.floor(inst.pound_speed) or nil
end

local function OnLoad(inst, data)
    if data ~= nil and data.phase ~= nil then
        SetPhaseLevel(inst, data.phase)
    else
        local healthpct = inst.components.health:GetPercent()
        SetPhaseLevel(
            inst,
            (healthpct > PHASE2_HEALTH and 1) or
            (healthpct > PHASE3_HEALTH and 2) or
            ((not inst.dark or healthpct > PHASE4_HEALTH) and 3) or
            4
        )
    end

    if data ~= nil then
        if data.poundspeed ~= nil then
            inst.pound_speed = math.max(0, data.poundspeed)
        end
        if data.engaged then
            inst:RemoveEventCallback("newcombattarget", OnNewTarget)
            inst.engaged = true
        end
    end
end

--------------------------------------------------------------------------

local function ClearRecentlyCharged(inst, other)
    inst.recentlycharged[other] = nil
end

local function OnDestroyOther(inst, other)
    if other:IsValid() and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked() and
        other.components.workable.action ~= ACTIONS.NET and
        not inst.recentlycharged[other] then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        if other.components.lootdropper ~= nil and (other:HasTag("tree") or other:HasTag("boulder")) then
            other.components.lootdropper:SetLoot({})
        end
        other.components.workable:Destroy(inst)
        if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
            inst.recentlycharged[other] = true
            inst:DoTaskInTime(3, ClearRecentlyCharged, other)
        end
    end
end

local function OnCollide(inst, other)
    if other ~= nil and
        other:IsValid() and
        other.components.workable ~= nil and
        other.components.workable:CanBeWorked() and
        other.components.workable.action ~= ACTIONS.NET and
        not inst.recentlycharged[other] then
        inst:DoTaskInTime(2 * FRAMES, OnDestroyOther, other)
    end
end

--------------------------------------------------------------------------

local function getstatus(inst)
    return inst.level >= 3  and "RAGE" or nil
end

local function PushMusic(inst)
    if ThePlayer == nil then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 30 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "toadstool" })
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 40) then
        inst._playingmusic = false
    end
end

--------------------------------------------------------------------------

local function common_fn(build)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    inst.DynamicShadow:SetSize(6, 3.5)

    inst.Light:SetRadius(FADE_RADIUS)
    inst.Light:SetFalloff(FADE_FALLOFF)
    inst.Light:SetIntensity(FADE_INTENSITY)
    inst.Light:SetColour(255 / 255, 235 / 255, 153 / 255)
    inst.Light:EnableClientModulation(true)

    MakeGiantCharacterPhysics(inst, 1000, 2.5)

    inst.AnimState:SetBank("toadstool")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetLightOverride(.3)

    inst:AddTag("epic")
    inst:AddTag("noepicmusic")
    inst:AddTag("monster")
    inst:AddTag("toadstool")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("cavedweller")

    inst._fade = net_smallbyte(inst.GUID, "toadstool._fade", "fadedirty")

    inst.entity:SetPristine()

    --Dedicated server does not need to trigger music
    if not TheNet:IsDedicated() then
        inst._playingmusic = false
        inst:DoPeriodicTask(1, PushMusic, 0)
    end

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", OnFadeDirty)

        return inst
    end

    inst.recentlycharged = {}
    inst.Physics:SetCollisionCallback(OnCollide)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
    inst.components.inspectable:RecordViews()

    inst:AddComponent("lootdropper")

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper.diminishingreturns = true

    inst:AddComponent("locomotor")
    inst.components.locomotor.pathcaps = { ignorewalls = true }
    inst.components.locomotor.walkspeed = TUNING.TOADSTOOL_SPEED_LVL[0]

    inst:AddComponent("health")
    inst.components.health.nofadeout = true

    inst:AddComponent("healthtrigger")
    inst.components.healthtrigger:AddTrigger(PHASE2_HEALTH, EnterPhase2Trigger)

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(TUNING.TOADSTOOL_ATTACK_PERIOD_LVL[0])
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.TOADSTOOL_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.battlecryenabled = false
    inst.components.combat.hiteffectsymbol = "toad_torso"

    inst:AddComponent("explosiveresist")

    inst:AddComponent("sanityaura")

    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(TUNING.TOADSTOOL_EPICSCARE_RANGE)

    inst:AddComponent("timer")

    inst:AddComponent("grouptargeter")

    inst:AddComponent("groundpounder")
    inst.components.groundpounder.platformPushingRings = 0

    inst:AddComponent("knownlocations")

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeHugeFreezableCharacter(inst, "toad_torso")
    inst.components.freezable.diminishingreturns = true

    inst:SetStateGraph("SGtoadstool")
    inst:SetBrain(brain)

    inst.FindSporeBombTargets = FindSporeBombTargets
    inst.DoSporeBomb = DoSporeBomb
    inst.DoMushroomBomb = DoMushroomBomb
    inst.FindMushroomSproutAngles = FindMushroomSproutAngles
    inst.DoMushroomSprout = DoMushroomSprout
    inst.OnEscaped = OnEscaped

    inst.sporebomb_targets = TUNING.TOADSTOOL_SPOREBOMB_TARGETS_PHASE[1]
    inst.sporebomb_cd = TUNING.TOADSTOOL_SPOREBOMB_CD_PHASE[1]

    inst.mushroombomb_count = TUNING.TOADSTOOL_MUSHROOMBOMB_COUNT_PHASE[1]
    inst.mushroombomb_variance = TUNING.TOADSTOOL_MUSHROOMBOMB_VAR_LVL[0]
    inst.mushroombomb_maxchain = TUNING.TOADSTOOL_MUSHROOMBOMB_CHAIN_LVL[0]
    inst.mushroombomb_cd = TUNING.TOADSTOOL_MUSHROOMBOMB_CD

    inst.mushroomsprout_cd = TUNING.TOADSTOOL_MUSHROOMSPROUT_CD

    inst.pound_cd = TUNING.TOADSTOOL_POUND_CD
    inst.pound_speed = 0
    inst.pound_rnd = false

    inst.hit_recovery = TUNING.TOADSTOOL_HIT_RECOVERY_LVL[0]

    inst.phase = 1
    inst.level = 0
    inst._numlinks = 0
    inst._links = {}
    inst:ListenForEvent("linkmushroomsprout", OnLinkMushroomSprout)
    inst:ListenForEvent("unlinkmushroomsprout", OnUnlinkMushroomSprout)

    inst._recentattackers = {}
    inst.engaged = false

    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("newstate", OnNewState)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("fleewarning", OnFleeWarning)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.FadeOut = FadeOut
    inst.CancelFade = CancelFade

    inst.UpdateLevel = UpdateLevel

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

local function normal_fn()
    local inst = common_fn("toadstool_build")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.health:SetMaxHealth(TUNING.TOADSTOOL_HEALTH)
    inst.components.health:SetAbsorptionAmount(TUNING.TOADSTOOL_ABSORPTION_LVL[0])

    inst.components.healthtrigger:AddTrigger(PHASE3_HEALTH, EnterPhase3Trigger)

    inst.components.combat:SetDefaultDamage(TUNING.TOADSTOOL_DAMAGE_LVL[0])

    inst.components.lootdropper:SetChanceLootTable("toadstool")
    AddSpecialLoot(inst)

    inst.mushroombomb_prefab = "mushroombomb_projectile"
    inst.mushroomsprout_prefab = "mushroomsprout"

    return inst
end

local function dark_fn()
    local inst = common_fn("toadstool_dark_build")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.dark = true
    inst.components.inspectable.nameoverride = "toadstool"

    inst.components.health:SetMaxHealth(TUNING.TOADSTOOL_DARK_HEALTH)
    inst.components.health:SetAbsorptionAmount(TUNING.TOADSTOOL_DARK_ABSORPTION_LVL[0])
    inst.components.healthtrigger:AddTrigger(PHASE3_HEALTH, EnterPhase3TriggerDark)

    inst.components.healthtrigger:AddTrigger(PHASE4_HEALTH, EnterPhase4TriggerDark)

    inst.components.combat:SetDefaultDamage(TUNING.TOADSTOOL_DARK_DAMAGE_LVL[0])

    inst.components.lootdropper:SetChanceLootTable("toadstool_dark")
    AddSpecialLootDark(inst)

    inst.mushroombomb_prefab = "mushroombomb_dark_projectile"
    inst.mushroomsprout_prefab = "mushroomsprout_dark"

    return inst
end

return Prefab("toadstool", normal_fn, assets, prefabs),
    Prefab("toadstool_dark", dark_fn, assets_dark, prefabs_dark)
