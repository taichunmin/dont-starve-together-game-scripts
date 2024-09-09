local brain = require "brains/crabkingbrain"
local easing = require("easing")

----------------------------------------------------------------------------------------------------------------------------------------------

-- Red    gem -- CANNON DAMAGE
-- Blue   gem -- ICE CRACK DELAY
-- Purple gem -- MINIONS
-- Yellow gem -- TOWERS
-- Green  gem -- CLAWS
-- Orange gem -- REGEN BUFF

----------------------------------------------------------------------------------------------------------------------------------------------

local assets =
{
    Asset("ANIM", "anim/crab_king_basic.zip"),
    Asset("ANIM", "anim/crab_king_actions.zip"),
    Asset("ANIM", "anim/crab_king_build.zip"),
    Asset("ANIM", "anim/crab_king_hole_build.zip"),
}

local chipassets =
{
    Asset("ANIM", "anim/crabking_rockchip.zip"),
}

local prefabs =
{
    "boat_ice_crabking",
    "crab_king_bubble1",
    "crab_king_bubble2",
    "crab_king_bubble3",
    "crab_king_shine",
    "crab_king_waterspout",
    "crabking_cannontower",
    "crabking_chip_high",
    "crabking_chip_low",
    "crabking_chip_med",
    "crabking_claw",
    --"crabking_feeze", -- Deprecated.
    "crabking_geyserspawner",
    "crabking_icewall",
    "crabking_mob_knight",
    "crabking_mob",
    "crabking_ring_fx",
    "hermit_cracked_pearl",
    "moon_altar_cosmic",
    "moon_altar_crown",

    "meat",
    "barnacle",
    "boat_bumper_crabking",
    "singingshell_octave3",
    "singingshell_octave4",
    "singingshell_octave5",
    "messagebottle",
    "trident_blueprint",
    "chesspiece_crabking_sketch",
    "winter_ornament_boss_crabking",
    "winter_ornament_boss_crabkingpearl",
}

local geyserprefabs =
{
    "crab_king_bubble1",
    "crab_king_bubble2",
    "crab_king_bubble3",
    "crab_king_waterspout",
}

--[[local freezeprefabs =
{
    "mushroomsprout_glow",
    "crab_king_icefx",
}]]

----------------------------------------------------------------------------------------------------------------------------------------------

SetSharedLootTable("crabking",
{
    {"trident_blueprint",                   1.00},
    {"chesspiece_crabking_sketch",          1.00},
    {"boat_bumper_crabking_kit",            1.00},
    {"barnacle",                            1.00},
    {"barnacle",                            1.00},
    {"barnacle",                            0.25},
    {"barnacle",                            0.25},
    {"meat",                                1.00},
    {"meat",                                1.00},
    {"meat",                                1.00},
    {"meat",                                1.00},
    {"meat",                                1.00},
    {"meat",                                0.50},
    {"messagebottle",                       1.00},
    {"messagebottle",                       1.00},
    {"messagebottle",                       0.50},
    {"messagebottle",                       0.25},
    {"singingshell_octave3",                1.00},
    {"singingshell_octave3",                0.50},
    {"singingshell_octave3",                0.25},
    {"singingshell_octave4",                1.00},
    {"singingshell_octave4",                1.00},
    {"singingshell_octave4",                0.50},
    {"singingshell_octave4",                0.25},
    {"singingshell_octave5",                1.00},
    {"singingshell_octave5",                1.00},
    {"singingshell_octave5",                1.00},
    {"singingshell_octave5",                0.50},
    {"singingshell_octave5",                0.25},
})

----------------------------------------------------------------------------------------------------------------------------------------------

local TARGET_DIST = 16
local MAX_SOCKETS = 9

local ARMTIME = {
    0,
    0.25,
    0.1,
    0.2,
    0.15,
    0.3,
}

local MAXRANGE = 4

local CRABKING_SCALE = .7
local REGULAR_PHYSICS_RADIUS = 1.7
local ICEHOLE_PHYSICS_RADIUS = 6.0

----------------------------------------------------------------------------------------------------------------------------------------------

local KEYSTONE_MUST_TAGS = { "crabking_icewall" }
local ICE_ARENA_CLEANUP_CANT_TAGS = { "INLIMBO" }
local SEASTACK_MUST_TAGS = { "seastack" }
local SEASTACK_CANT_TAGS = { "waterplant" }
local RETARGET_MUST_TAGS = { "_combat", "hostile" }
local RETARGET_CANT_TAGS = { "wall", "INLIMBO", "crabking_ally" }
local BOAT_MUST_TAGS = { "boat" }
local CRABKING_SPELLGENERATOR_MUST_TAGS = { "crabking_spellgenerator" }
local REPAIRED_PATCH_MUST_TAGS = { "boat_repaired_patch" }
local LEAK_MUST_TAGS = { "boatleak" }

local COLLAPSIBLE_WORK_ACTIONS =
{
    CHOP = true,
    DIG = true,
    HAMMER = true,
    MINE = true,
}

local COLLAPSIBLE_TAGS = { "_combat", "NPC_workable", "frozen", "oceanfish" }
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
    table.insert(COLLAPSIBLE_TAGS, k.."_workable")
end

local NON_COLLAPSIBLE_TAGS = { "epic", "boat", "flying", "shadow", "ghost", "playerghost", "player", "FX", "INLIMBO" }

local DECOR_SYMBOL_LOOKUP =
{
    redgem          = "gems_red",
    purplegem       = "gems_purple",
    orangegem       = "gems_orange",
    yellowgem       = "gems_yellow",
    greengem        = "gems_green",
    opalpreciousgem = "gems_opal",
    hermit_pearl    = "hermit_pearl",
}

local GEM_TO_COLOR_LOOKUP =
{
    bluegem         = "blue",
    redgem          = "red",
    purplegem       = "purple",
    orangegem       = "orange",
    yellowgem       = "yellow",
    greengem        = "green",
}

local KEYSTONE_POSITIONS =
{
            {-2, 4}, {0, 4}, {2, 4},
         {-3, 3},                  {3, 3},
     {-4, 2},                          {4, 2},
     {-4, 0},                          {4, 0},
     {-4, -2},                         {4, -2},
         {-3, -3},                 {3, -3},
            {-2, -4}, {0, -4}, {2, -4},
}

local CHIP_SIZES =
{
    "crabking_chip_med",
    "crabking_chip_low",
    "crabking_chip_med",
    "crabking_chip_low",
    "crabking_chip_med",
    "crabking_chip_med",
    "crabking_chip_high",
    "crabking_chip_high",
    "crabking_chip_med",
    "crabking_chip_med",
}



----------------------------------------------------------------------------------------------------------------------------------------------

local function GetFreezeRange(inst)
    return TUNING.CRABKING_FREEZE_RANGE * (0.75 + Remap(inst.gemcount.blue, 0, 9, 0, 2.25)) / 2
end

local function AddSocketDecoration(inst, data, load)
    table.insert(inst.socketed, data)

    if data == nil or data.slot == nil or data.itemprefab == nil then
        return
    end

    local symbol = DECOR_SYMBOL_LOOKUP[data.itemprefab] or "gems_blue"

    inst.AnimState:OverrideSymbol("gem"..data.slot, "crab_king_build", symbol)

    if not load then
        inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/gem_place")

        inst:ShineSocketInSlot(data.slot)

        inst:PushEvent("socket")
    end
end

local function ClearAllSocketDecorations(inst)
    inst.AnimState:ClearOverrideSymbol("gems_blue")

    for i=1, MAX_SOCKETS do
        inst.AnimState:ClearOverrideSymbol("gem"..i)
    end
end

local function SocketItem(inst, item, socketnum, load)
    -- Find open slot.
    if socketnum then
        table.removearrayvalue(inst.socketlist, socketnum)
    else
        if #inst.socketlist <= 0 or item.prefab == "hermit_pearl" then
            socketnum = 5
        else
            local idx = math.random(1, #inst.socketlist)
            socketnum = inst.socketlist[idx]
            table.remove(inst.socketlist, idx)
        end
    end

    inst:AddSocketDecoration({slot = socketnum, itemprefab = item.prefab}, load)

    item:RemoveTag("irreplaceable")
    item:Remove()

    inst:UpdateGemCount()

    if #inst.socketed >= MAX_SOCKETS then        
        MakeLargeBurnableCharacter(inst, "swap_fire", nil, 3)
        MakeHugeFreezableCharacter(inst, "swap_fire")

        inst.components.freezable:SetResistance(3 + inst.gemcount.blue)

        inst:AddTag("epic")
        inst:AddTag("animal")
        inst:AddTag("scarytoprey")
        inst:AddTag("hostile")

        inst:PushEvent("activate", { isload = load })
    end
end

local function ShineSocketInSlot(inst, slot)
    inst.shinefx = SpawnPrefab("crab_king_shine")
    inst.shinefx.entity:AddFollower()
    inst.shinefx.Follower:FollowSymbol(inst.GUID, "gem"..slot, 0, 0, 0)
end

local function ShineSocketOfColor(inst, color)
    if inst.socketed == nil then
        return
    end

    local t = 0

    for i, data in ipairs(inst.socketed) do
        if GEM_TO_COLOR_LOOKUP[data.itemprefab] == color or (data.itemprefab == "opalpreciousgem" or data.itemprefab == "hermit_pearl") then
            inst:DoTaskInTime(t * 0.15, inst.ShineSocketInSlot, data.slot)
            t = t + 1
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function RetargetFn(inst)
    local range = inst:GetPhysicsRadius(0) + 8
    return FindEntity(
            inst,
            TARGET_DIST,
            function(guy)
                return inst.components.combat:CanTarget(guy)
                    and (   guy.components.combat:TargetIs(inst) or
                            guy:IsNear(inst, range)
                        )
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS
        )
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function ShouldAcceptItem(inst, item)
    return item:HasTag("gem") and #inst.socketed < MAX_SOCKETS
end

local function OnGetItemFromPlayer(inst, giver, item)
    inst:SocketItem(item)
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function OnAttacked(inst, data)
    if data.attacker == nil then
        return
    end

    local fx = SpawnPrefab("mining_fx")
    local radius = inst:GetPhysicsRadius(0) - ( .2 + math.random() * .5 )
    local x, y, z = inst.Transform:GetWorldPosition()
    local theta
 
    local x1, y1, z1 = data.attacker.Transform:GetWorldPosition()
    if x ~= x1 or z ~= z1 then
        theta = math.atan2(z - z1, x1 - x) + math.random() * 1 - 0.5
    end

    if theta == nil then
        theta = math.random() * TWOPI
    end
    fx.Transform:SetPosition(
        x + radius * math.cos(theta),
        math.random(),
        z - radius * math.sin(theta)
    )

end

local function OnRemove(inst)
        if inst.arms == nil or next(inst.arms) == nil then
            return
        end

        for i, arm in ipairs(inst.arms) do
            if arm.task ~= nil then
                arm.task:Cancel()
                arm.task = nil
            end
        end
    end

----------------------------------------------------------------------------------------------------------------------------------------------

local function EndIceStage(inst)
    inst.end_ice_task = nil

    if not inst:HasTag("icewall") then
        return
    end

    inst:RemoveTag("icewall")
    inst:RemoveTag("notarget")

    inst.damagetotal = 0

    inst.components.timer:StartTimer("freeze_cooldown", 20)

    inst:RemoveIceArena()

    inst.tasks.spawncannons = inst:DoTaskInTime(MAXRANGE * 2 + 3, inst.SpawnCannons)
end

local function KillKeyStone(ent)
    if ent:IsValid() and not ent.components.health:IsDead() then
        ent.dontchainremove = true
        ent.components.health:Kill()
    end
end

local function startendicetask(inst)
    if inst.end_ice_task == nil then
        local time = math.max(3, Remap(inst.gemcount.blue, 0, 11, 25, 3 ))
        inst.end_ice_task = inst:DoTaskInTime(time, inst.EndIceStage)
    end
end

local function OnKeyStoneRemoved(inst, stone)
    if inst.keystones ~= nil then
        table.removearrayvalue(inst.keystones, stone)
    end

    if stone.dontchainremove then
        return
    end

    inst:RemoveTag("notarget")

    startendicetask(inst)

    local x, y, z = stone.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, 3, KEYSTONE_MUST_TAGS)

    for _, ent in pairs(ents) do
        if ent ~= stone then
            ent:DoTaskInTime(0.3 * math.random(), KillKeyStone)
        end
    end
end

local function OnCannonTowerRemoved(inst, tower)
    if inst.cannontowers ~= nil then
        for i, cannon in pairs(inst.cannontowers) do
            if tower == cannon then
                inst.cannontowers[i] = false
                break
            end
        end
    end
end

local function CleanUpArena(inst, remove)
    -- Clear ice.
    inst:RemoveTag("icewall")
    inst:RemoveTag("notarget")
    inst:RemoveIceArena(remove)

    -- Clear claws.
    if inst.arms ~= nil then
        for i, arm in pairs(inst.arms) do
            if arm.task ~= nil then
                arm.task:Cancel()
                arm.task = nil
            else
                inst:RemoveEventCallback("onremove", inst.onarmremoved, arm)

                if remove then
                    arm:Remove()

                elseif arm.components.health ~= nil then
                    arm.components.health:Kill()
                end
            end
        end

        inst.arms = nil
    end

    -- Clear towers. Note: tower can be "false".
    if inst.cannontowers ~= nil then
        for i, tower in pairs(inst.cannontowers) do
            -- Tower can be false...
            if tower then
                inst:RemoveEventCallback("onremove", inst.oncannontowerremoved, tower)

                if remove then
                    tower:Remove()

                elseif tower.components.health ~= nil then
                    tower.components.health:Kill()
                end
            end
        end

        inst.cannontowers = nil
    end

    -- clean geysers
    if inst.geysers and #inst.geysers > 0 then
        for i=#inst.geysers,1,-1 do
            local geyser = inst.geysers[i]
            geyser:Remove()
            inst.geysers[i] = nil
        end
    end

    -- Clear tasks.
    for i, task in pairs(inst.tasks) do
        task:Cancel()
    end

    inst.tasks = {}
end

local function OnEntitySleep(inst)
    if inst.sg:HasStateTag("inert") then
        return
    end

    inst.components.health:SetMaxHealth(TUNING.CRABKING_HEALTH)

    inst:OnHealthChange({
        oldpercent = 0,
        newpercent = 1,
        instant = true,
    })

    inst:CleanUpArena(true)

    inst:SpawnSeaStacks()
    inst:DropSocketedGems()

    inst:RemoveTag("animal")
    inst:RemoveTag("epic")
    inst:RemoveTag("hostile")
    inst:RemoveTag("scarytoprey")

    inst:RemoveComponent("freezable")
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")

    inst.sg:GoToState("inert")
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function OnSave(inst, data)
    local ents = {}

    data.socketlist = inst.socketlist
    data.socketed = {}
    data.socketedslot = {}

    if #inst.socketed > 0 then
        for k, v in ipairs(inst.socketed) do
            table.insert(data.socketed, v.itemprefab)
            table.insert(data.socketedslot, v.slot)
        end
    end

    if inst.arms ~= nil then
        data.arms = {}

        for i, arm in pairs(inst.arms) do
            if arm.prefab ~= nil and arm:IsValid() then
                data.arms[i] = arm.GUID
                table.insert(ents, arm.GUID)
            end
        end
    end

    if inst.cannontowers ~= nil then
        data.cannontowers = {}

        for i, tower in pairs(inst.cannontowers) do
            if tower and tower:IsValid() then
                data.cannontowers[i] = tower.GUID
                table.insert(ents, tower.GUID)
            end
        end
    end

    if inst.keystones ~= nil then
        data.keystones = {}

        for i, stone in pairs(inst.keystones) do
            if stone:IsValid() then
                table.insert(data.keystones,stone.GUID)
                table.insert(ents, stone.GUID)
            end
        end
    end

    data.healthpercent = inst.components.health:GetPercent()

    if inst.damagetotal then
        data.damagetotal = inst.damagetotal
    end

    if inst:HasTag("icewall") then
        data.icewall = true
    end

    if inst.components.timer:TimerExists("freeze_cooldown") then
        data.freezetime = inst.components.timer:GetTimeLeft()
    end

    return ents
end

local function OnLoadPostPass(inst, newents, data)
    -- Reset sockets.
    inst:ClearAllSocketDecorations()

    if data == nil then
        return
    end

    if data.socketed ~= nil then
        inst.socketlist = data.socketlist

        for k, v in ipairs(data.socketed) do
            inst:SocketItem(SpawnPrefab(v), data.socketedslot[k], true)
        end
    end

    if data.arms ~= nil then
        inst.arms = {}

        for i, arm in pairs(data.arms) do
            if newents[arm] ~= nil then
                inst.arms[i] = newents[arm].entity
                inst.arms[i].armpos = i

                inst:ListenForEvent("onremove", inst.onarmremoved, inst.arms[i])
            end
        end
    end

    if data.cannontowers ~= nil then
        inst.cannontowers = {}

        for i, tower in pairs(data.cannontowers) do
            if newents[tower] ~= nil then
                local cannontower = newents[tower].entity

                inst.cannontowers[i] = cannontower
                inst:ListenForEvent("onremove", inst.oncannontowerremoved, cannontower)

                local platform = cannontower:GetCurrentPlatform() -- Intentionally not using GetBoatIntersectingPhysics. We should be already at a proper position on load.

                if platform ~= nil and platform.components.boatphysics ~= nil then
                    cannontower.sg:GoToState("breach")

                    platform.components.boatphysics:AddEmergencyBrakeSource("crabking_cannontower"..cannontower.GUID)

                    if platform.leak_build_override ~= nil then
                        tower.AnimState:AddOverrideBuild(platform.leak_build_override)
                    end

                    cannontower:ListenForEvent("onremove", function()
                        if platform:IsValid() then
                            platform.components.boatphysics:RemoveEmergencyBrakeSource("crabking_cannontower"..cannontower.GUID)
                        end
                    end)
                end
            end
        end
    end

    if data.keystones ~= nil then
        inst.keystones = {}

        for i, stone in pairs(data.keystones) do
            if newents[stone] ~= nil then
                inst.keystones[i] = newents[stone].entity
                inst:ListenForEvent("onremove", inst.onkeystoneremoved, inst.keystones[i])
            end
        end
    end

    if data.healthpercent ~= nil then
        inst.components.health:SetPercent(data.healthpercent)
    end

    if data.damagetotal ~= nil then
        inst.damagetotal = data.damagetotal
    end

    if data.icewall then
        inst:AddTag("icewall")
        inst.AnimState:Show("water")
        inst:DoTaskInTime(0, function() inst.Physics:SetCapsule(ICEHOLE_PHYSICS_RADIUS, 2) end)


        local keystonecount = 0

        for i,stone in ipairs(inst.keystones) do
            if stone then
                keystonecount = keystonecount + 1
            end
        end

        if inst.keystones ~= nil and #inst.keystones < #KEYSTONE_POSITIONS then
            startendicetask(inst)
            inst:AddTag("notarget")
        end
    else
        inst:RemoveIceArena()
    end

    if data.freezetime ~= nil then
        inst.components.timer:StartTimer("freeze_cooldown", data.freezetime)
    end

    inst:OnHealthChange({
        oldpercent = 1,
        newpercent = inst.components.health:GetPercent(),
        instant = true,
    })

    -- Retrofit crabking spawner.
    if not TheSim:FindFirstEntityWithTag("crabking_spawner") then
        local spawner = SpawnPrefab("crabking_spawner")
        spawner.Transform:SetPosition(inst.Transform:GetWorldPosition())

        spawner.components.childspawner.childreninside = 0
        spawner.components.childspawner:TakeOwnership(inst)
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function StartCastSpell(inst, freeze)
    if inst.arms == nil then
        return
    end

    for i, arm in ipairs(inst.arms) do
        if arm.task == nil then
            arm:PushEvent("submerge")
        else
            arm.task:Cancel()
            arm.task = nil
        end
    end

    inst.arms = nil
end

local function LaunchCrabMob(inst, prefab)
    local pos = inst:GetPosition()

    for i=1, 30 do
        local theta = math.random()*TWOPI
        local radius = inst.Physics:GetRadius() + 1 + math.random() * 2
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

        if TheWorld.Map:IsVisualGroundAtPoint(pos.x+offset.x, 0, pos.z+offset.z) then
            local mob = inst:LaunchProjectile(pos+offset, prefab)

            mob.components.sleeper:SetSleepTest(nil)
            mob.components.sleeper:SetWakeTest(nil)

            local resistance = 2

            if inst.gemcount.purple > 4 then resistance = resistance + 10 end
            if inst.gemcount.purple > 7 then resistance = resistance + 10 end

            if mob:HasTag("crab_mob_knight") then resistance = resistance + 10 end

            mob.components.sleeper:SetResistance(resistance)

            local health = mob.components.health.currenthealth
            local increment = 20
            if inst.gemcount.purple > 4 then increment = 30 end
            if inst.gemcount.purple > 7 then increment = 40 end
            health = health + inst.gemcount.purple * increment
            if inst.gemcount.purple >= 11 then
               health = health + TUNING.CRABKING_MOB_HEALTH_BONUS_MAXGEM
            end

            mob.components.health:SetMaxHealth(health)
            mob.components.health:SetPercent(1) -- For pushing events?
            break
        end
    end
end

local function RemoveIceInRadius(world, radius, pt, instant)
    for ix= -radius, radius do
        for iz = -radius, radius do
            if (math.abs(ix * ix) + math.abs(iz * iz) <= radius * radius) and (radius-1 == 0 or not (math.abs(ix * ix) + math.abs(iz * iz) <= radius-1 * radius-1)) then
                local fx = pt.x + (ix * TILE_SCALE)
                local fz = pt.z + (iz * TILE_SCALE)

                if instant then
                    world.components.oceanicemanager:DestroyIceAtPoint(fx, 0, fz, { silent = instant })
                else
                    world.components.oceanicemanager:QueueDestroyForIceAtPoint(fx, 0, fz, { icefloe_prefab = "boat_ice_crabking" })
                end
            end
        end
    end
end

local function RemoveIceArena(inst, instant)
    if instant then
        inst.AnimState:Hide("water")
        inst.Physics:SetCapsule(REGULAR_PHYSICS_RADIUS, 2)
    end

    if inst.keystones ~= nil then
        for i, stone in ipairs(inst.keystones) do
            inst:RemoveEventCallback("onremove", inst.onkeystoneremoved, stone)

            if instant then
                stone:Remove()
            else
                stone:DoTaskInTime(0.8 * math.random(), KillKeyStone)
            end
        end

        inst.keystones = nil
    end

    for radius=1, MAXRANGE do
        if instant then
            RemoveIceInRadius(TheWorld, radius, inst:GetPosition(), true)
        else
            TheWorld:DoTaskInTime((radius-1)*4 + math.random(), RemoveIceInRadius, radius, inst:GetPosition())
        end
    end
end

local function CleanUpAreaForIceTile(inst, x, z)
    local ents = TheSim:FindEntities(x, 0, z, TILE_SCALE, nil, NON_COLLAPSIBLE_TAGS, COLLAPSIBLE_TAGS)

    for _, ent in ipairs(ents) do
        if ent:IsValid() and ent:IsOnOcean(false) then
            local isworkable = false
            if ent.components.workable ~= nil then
                local work_action = ent.components.workable:GetWorkAction()
                    --V2C: nil action for NPC_workable (e.g. campfires)
                --     allow digging spawners (e.g. rabbithole)
                isworkable = (
                        (work_action == nil and ent:HasTag("NPC_workable")) or
                        (work_action ~= nil and ent.components.workable:CanBeWorked() and COLLAPSIBLE_WORK_ACTIONS[work_action.id])
                )
            end

            local health = ent.components.health
            local locomotor = ent.components.locomotor

            if ent:HasTag("frozen") and ent.components.inventoryitem ~= nil then
                ent:Remove()

            elseif isworkable and ent.components.inventoryitem == nil then
                ent.components.workable:Destroy(inst)

                if ent:IsValid() and ent:HasTag("stump") then
                    ent:Remove()
                end

            elseif health ~= nil and locomotor ~= nil and locomotor:IsAquatic() then
                if not health:IsDead() then
                    health:Kill()
                end

            elseif ent:HasTag("oceanfish") then
                ent:Remove()
            end
        end
    end
end

local function DoSpawnIceTile(inst, radius)
    inst.tasks["spawnice_"..radius] = nil

    local x, y, z = inst.Transform:GetWorldPosition()

    for ix= -radius, radius do
        for iz = -radius, radius do
            if (math.abs(ix * ix) + math.abs(iz * iz) <= radius * radius) and (radius-1 == 0 or not (math.abs(ix * ix) + math.abs(iz * iz) <= radius-1 * radius-1)) then
                local fx = x + (ix * TILE_SCALE)
                local fz = z + (iz * TILE_SCALE)
                local width, height = TheWorld.Map:GetWorldSize()

                local tile_x, tile_y = TheWorld.Map:GetTileCoordsAtPoint(fx, 0, fz)

                local nx = (tile_x - width/2) * TILE_SCALE
                local nz = (tile_y - height/2) * TILE_SCALE

                if not (TheSim:CountEntities(nx, 0, nz, 8, BOAT_MUST_TAGS) > 0) and not TheWorld.Map:IsVisualGroundAtPoint(nx, 0, nz) then
                    CleanUpAreaForIceTile(inst, nx, nz)

                    TheWorld.components.oceanicemanager:CreateIceAtPoint(nx, 0, nz)
                end
            end
        end
    end
end

local function DoSpawnIceWall(inst)
    inst.tasks.spawnwall = nil

    inst.AnimState:Show("water")
    inst.Physics:SetCapsule(ICEHOLE_PHYSICS_RADIUS, 2)

    inst.keystones = {}

    local x, y, z = inst.Transform:GetWorldPosition()

    for i, coord in ipairs(KEYSTONE_POSITIONS) do

        local icewall  = SpawnPrefab("crabking_icewall")
        local health = TUNING.CRABKING_ICEWALL_HEALTH
        if inst.gemcount.blue > 4 then health = health + TUNING.CRABKING_ICEWALL_HEALTH_BONUS end
        if inst.gemcount.blue > 7 then health = health + TUNING.CRABKING_ICEWALL_HEALTH_BONUS end
        if inst.gemcount.blue >= 11 then health = health + TUNING.CRABKING_ICEWALL_HEALTH_BONUS_MAXGEM end
        icewall.components.health:SetMaxHealth(health)

        local angle = inst:GetAngleToPoint(x+coord[1], 0, z+coord[2])

        icewall.Transform:SetPosition(x+coord[1], 0, z+coord[2])
        icewall.Transform:SetRotation(angle)

        inst:ListenForEvent("onremove", inst.onkeystoneremoved, icewall)
        table.insert(inst.keystones, icewall)
    end
end

local function EndCastSpell(inst, lastwasfreeze)
    if inst.components.timer:TimerExists("spell_cooldown") then
        inst.components.timer:SetTimeLeft("spell_cooldown", TUNING.CRABKING_CAST_DELAY)
    else
        inst.components.timer:StartTimer("spell_cooldown", TUNING.CRABKING_CAST_DELAY)
    end

    if inst.wavetask ~= nil then
        inst.wavetask:Cancel()
        inst.wavetask = nil
    end

    inst:AddTag("icewall")
    inst:AddTag("notarget")

    inst.components.timer:StartTimer("taunt",TUNING.CRABKING_TAUNTTIME)

    inst.wantstotaunt = true
    inst.wantstoheal = nil
    inst.wantstofreeze = nil

    if inst.geysers and #inst.geysers > 0 then
        for i=#inst.geysers,1,-1 do
            local geyser = inst.geysers[i]
            geyser:Remove()
            inst.geysers[i] = nil
        end
    end

    SpawnPrefab("crabking_ring_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:PushEvent("ck_taunt")
    for radius=1, MAXRANGE do
        inst.tasks["spawnice_"..radius] = inst:DoTaskInTime(radius*0.2 + 0.2, inst.DoSpawnIceTile, radius)
    end

    inst.tasks.spawnwall = inst:DoTaskInTime(0.4, inst.DoSpawnIceWall)

    inst.tasks.spawnminion = inst:DoTaskInTime(0.2 * MAXRANGE, function()
        for i=1, TUNING.CRABKING_BASE_MINIONS + (math.floor(inst.gemcount.purple/2)) do
            inst:LaunchCrabMob("crabking_mob")
        end

        if inst.components.health:GetPercent() < 0.35 then
            inst:LaunchCrabMob("crabking_mob_knight")
        end

        inst:ShineSocketOfColor("purple")
    end)

    inst.dofreezecast = nil

    inst:ShineSocketOfColor("blue")
end

local function FindCannonPositions(inst, num, i)
    local arc = TWOPI/num
    local radius = 20

    local x, y, z = inst.Transform:GetWorldPosition()
    local theta = (arc * i) + (math.random()*(arc*0.7) - (arc*0.7)/2)

    return Vector3(x + radius * math.cos(theta), 0, z - radius * math.sin(theta))
end

local function SpawnCannonTower(inst, i, pt, numcannons)
    pt = pt or inst:FindCannonPositions(numcannons, i)

    if pt == nil then
        inst.cannontowers[i] = false

        return
    end

    local tower = SpawnPrefab("crabking_cannontower")

    tower.Transform:SetPosition(pt.x, 0, pt.z)

    local health = TUNING.CRABKING_CANNONTOWER_HEALTH
    if inst.gemcount.yellow > 4 then health = health + TUNING.CRABKING_CANNONTOWER_HEALTH end
    if inst.gemcount.yellow > 7 then health = health + TUNING.CRABKING_CANNONTOWER_HEALTH end

    if inst.gemcount.yellow >= 11 then
       health = health + TUNING.CRABKING_CANNONTOWER_HEALTH
    end

    tower.components.health:SetMaxHealth(health)
    tower.components.health:SetPercent(1) -- For pushing events?
    tower.redgemcount = inst.gemcount.red -- Saved in prefab.
    tower.yellowgemcount = inst.gemcount.yellow -- Saved in prefab.

    inst:ListenForEvent("onremove", inst.oncannontowerremoved, tower)

    inst.cannontowers[i] = tower

    local platform = tower:GetBoatIntersectingPhysics()
    local max_dist = platform ~= nil and math.max(0, platform:GetSafePhysicsRadius() - 2.5) or nil -- Maximum distance from platform origin.

    -- Too close to the platform border.
    if max_dist ~= nil and not tower:IsNear(platform, max_dist) then
        pt = tower:GetPositionAdjacentTo(platform, max_dist)

        -- Moves the tower closer to the platform origin and get the platform again for safety.
        tower.Transform:SetPosition(pt.x, 0, pt.z)
        platform = tower:GetBoatIntersectingPhysics()
    end

    if platform == nil or platform.components.health == nil then
        tower:PushEvent("ck_spawn") -- Open ocean, just spawn.

        return
    end

    -- Platform is leak proof, destroy it instantly.
    if platform ~= nil and platform.components.hullhealth.leakproof then
        platform:InstantlyBreakBoat()

        tower:PushEvent("ck_spawn")

        return
    end

    local destruction_radius = tower.Physics:GetRadius() + 0.8
    local leaks = TheSim:FindEntities(pt.x, 0, pt.z, destruction_radius, LEAK_MUST_TAGS)

    for i, leak in pairs(leaks) do
        leak:Remove()
    end

    platform.components.health:DoDelta(-TUNING.CRABKING_CANNONTOWER_HULL_SMASH_DAMAGE)
    platform.components.boatphysics:AddEmergencyBrakeSource("crabking_cannontower"..tower.GUID)

    if platform.leak_build_override ~= nil then
        tower.AnimState:AddOverrideBuild(platform.leak_build_override)
    end

    tower:PushEvent("ck_breach")

    tower:ListenForEvent("onremove", function()
        if platform:IsValid() then
            platform.components.boatphysics:RemoveEmergencyBrakeSource("crabking_cannontower"..tower.GUID)
        end
    end)

    return tower -- Mods.
end

local function BubbleSeaStack(inst, doer, i)
    local MAXRADIUS = 2
    local x,y,z = inst.Transform:GetWorldPosition()
    local theta = math.random()*TWOPI
    local radius = math.pow(math.random(),0.8)* MAXRADIUS
    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
    local prefab = "crab_king_bubble"..math.random(1,3)

    if TheWorld.Map:IsOceanAtPoint(x+offset.x, 0, z+offset.z) then
        SpawnPrefab(prefab).Transform:SetPosition(x+offset.x, 0, z+offset.z)
    end

    doer.tasks["bubble_stack_"..i] = inst:DoTaskInTime(0.3 + math.random() * 0.1, inst.BubbleSeaStack, doer, i)
end

local function DoDestroySeaStack(inst, doer, i)
    if doer.tasks["bubble_stack_"..i] ~= nil then
        doer.tasks["bubble_stack_"..i]:Cancel()
        doer.tasks["bubble_stack_"..i] = nil
    end

    doer.tasks["destroy_stack_"..i] = nil

    doer = doer:IsValid() and doer or nil

    SpawnPrefab("crab_king_waterspout").Transform:SetPosition(inst.Transform:GetWorldPosition())

    if inst.components.workable ~= nil then
        inst.components.workable:Destroy(doer)
    end
end

local function SpawnCannons(inst)
    inst.tasks.spawncannons = nil

    if inst.cannontowers == nil then
        inst.cannontowers = {}
    end

    local x, y, z = inst.Transform:GetWorldPosition()

    local stacks = TheSim:FindEntities(x, 0, z, 30, SEASTACK_MUST_TAGS, SEASTACK_CANT_TAGS)

    for i, stack in ipairs(stacks) do
        inst.tasks["bubble_stack_"..i]  = stack:DoTaskInTime(0.3 + math.random() * 0.1, inst.BubbleSeaStack, inst, i)
        inst.tasks["destroy_stack_"..i] = stack:DoTaskInTime(math.random() * 2 + 1, inst.DoDestroySeaStack, inst, i)
    end

    local numcannons = TUNING.CRABKING_BASE_CANNONS + inst.gemcount.yellow

    for i=1, numcannons do
        if not inst.cannontowers[i] then
            inst:SpawnCannonTower(i, nil, numcannons)
        end
    end

    inst:ShineSocketOfColor("red")
    inst:ShineSocketOfColor("yellow")
end

local function OnFreeze(inst)
    local x,y,z = inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, 0, z, 25, nil, nil, CRABKING_SPELLGENERATOR_MUST_TAGS)

    if #ents > 0 then
        for i, ent in pairs(ents) do
            ent:Remove()
        end
    end
end

local function DoSpawnSeaStack(inst, x, z)
    inst.tasks.spawnseastacks = nil

    if TheSim:CountEntities(x, 0, z, 1.5, SEASTACK_MUST_TAGS) <= 0 then
        local stack = SpawnPrefab("seastack")

        stack.Transform:SetPosition(x, 0, z)

        if not stack:IsAsleep() then
            stack.AnimState:PlayAnimation(stack.stackid.."_emerge")
            stack.AnimState:PushAnimation(stack.stackid.."_full")

            SpawnPrefab("splash_green_large").Transform:SetPosition(x, 0, z)
        else
            stack.AnimState:PlayAnimation(stack.stackid.."_full")
        end

        return stack -- Mods.
    end
end

local function SpawnSeaStacks(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local numstacks =  math.max(0, TUNING.CRABKING_STACKS - TheSim:CountEntities(x, 0, z, 20, SEASTACK_MUST_TAGS))

    if numstacks <= 0 then
        return
    end

    for i=1, numstacks do
        local theta = math.random()*TWOPI
        local radius = 9 + (math.pow(math.random(), 0.8) * (17-9))
        local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))

        local x2, y2, z2 = x + radius * math.cos(theta), 0, z - radius * math.sin(theta)

        if not TheWorld.Map:GetPlatformAtPoint(x2, z2) and TheSim:CountEntities(x2, 0, z2, 3, SEASTACK_MUST_TAGS) <= 0 then
            inst.tasks.spawnseastacks = inst:DoTaskInTime(math.random()*0.5, inst.DoSpawnSeaStack, x2, z2)
        end
    end
end

local function OnArmRemoved(inst, armpos)
    if inst.arms == nil then
        return
    end

    if inst.arms[armpos] ~= nil and inst.arms[armpos].task ~= nil then
        inst.arms[armpos].task:Cancel()
    end

    inst.arms[armpos] = {}
    inst.arms[armpos].task = inst:DoTaskInTime(15, inst.DoSpawnArm, armpos)

    inst.components.timer:StartTimer("claw_regen_delay"..armpos, TUNING.CRABKING_CLAW_RESPAWN_DELAY)

    local noarms = true
    for i, arm in ipairs(inst.arms) do
        if arm.prefab ~= nil then
            noarms = false
            break
        end
    end


    if noarms and inst.tasks.triggerice_task == nil then

        inst.tasks.triggerice_task = inst:DoTaskInTime(5, function()

            inst.tasks.triggerice_task = nil
            inst.damagetotal = (inst.damagetotal or 0) - TUNING.CRABKING_FREEZE_THRESHOLD
        end)
    end
end

local function IsValidArmSpawnPoint(x, z)
    if TheWorld.Map:IsVisualGroundAtPoint(x, 0, z) then
        return false
    end

    local self_radius = 0.7
    local check_radius = self_radius + (MAX_PHYSICS_RADIUS + 0.18)

    local boats = TheSim:FindEntities(x, 0, z, check_radius, BOAT_MUST_TAGS) -- Biggest radius check may include smaller boats.

    for _, boat in ipairs(boats) do
        local boat_radius = boat.GetSafePhysicsRadius and boat:GetSafePhysicsRadius() or (boat.components.hull ~= nil and boat.components.hull:GetRadius() or TUNING.BOAT.RADIUS) + 0.18 -- Add a small offset for item overhangs.
        local bx, by, bz = boat.Transform:GetWorldPosition()
        local dx, dz = bx - x, bz - z
        local dist = math.sqrt(dx * dx + dz * dz)

        if dist - boat_radius <= self_radius then
            return false
        end
    end

    return true
end

local function TrySpawningArm(inst, armpos, numclaws)
    if inst.arms == nil then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()

    local wedge = TWOPI/numclaws
    local theta = armpos*wedge + (math.random() * wedge - wedge/2)
    local radius = 4 + 8*math.random()

    x, z = x + radius * math.cos(theta), z - radius * math.sin(theta)

    if IsValidArmSpawnPoint(x, z) then
        local arm = SpawnPrefab("crabking_claw")
        arm.Transform:SetPosition(x, 0, z)

        if inst.arms[armpos].task ~= nil then
            inst.arms[armpos].task:Cancel()
            inst.arms[armpos].task = nil
        end

        inst.arms[armpos] = arm

        local health = TUNING.CRABKING_CLAW_HEALTH
        if inst.gemcount.green > 4 then health = health + TUNING.CRABKING_CLAW_HEALTH_BOOST end
        if inst.gemcount.green > 7 then health = health + TUNING.CRABKING_CLAW_HEALTH_BOOST end
        if inst.gemcount.green >= 11 then health = health + TUNING.CRABKING_CLAW_HEALTH_BOOST_MAXGEM end

        arm.components.health:SetMaxHealth(health)
        arm.components.combat:SetDefaultDamage(TUNING.CRABKING_CLAW_PLAYER_DAMAGE + (math.floor(inst.gemcount.green/2) * TUNING.CRABKING_CLAW_DAMAGE_BOOST))
        
        arm.armpos = armpos
        arm.crabking = inst -- Saved in prefab.

        arm:PushEvent("emerge")

        inst:ListenForEvent("onremove", inst.onarmremoved, arm)

        return arm -- Mods.
    end
end

local function DoSpawnArm(inst, armpos, fx)
    if inst.arms == nil then -- This happens when the Crab King goes into entity sleep we should not continue spawning arms.
        return
    end

    if inst.arms[armpos] and (inst.arms[armpos].prefab or inst.arms[armpos].task) then
        return
    end

    local numclaws = TUNING.CRABKING_BASE_CLAWS + (math.floor(inst.gemcount.green/2))

    if not inst.arms[armpos] then
        inst.arms[armpos] = {}
    end

    inst.arms[armpos].task = inst:DoPeriodicTask(0.3, TrySpawningArm, nil, armpos, numclaws)
end

local function SpawnClawArms(inst)
    local numclaws = TUNING.CRABKING_BASE_CLAWS + (math.floor(inst.gemcount.green/2))

    if inst.arms == nil then
        inst.arms = {}
    end

    for i=1, numclaws do
        if inst.arms[i] == nil or (inst.arms[i].prefab == nil and inst.arms[i].task == nil) then
            inst:DoTaskInTime(ARMTIME[i%#ARMTIME+1], inst.DoSpawnArm, i)
        end
    end
end

local function DropSocketedGems(inst)
    for i, socket in pairs(inst.socketed) do
        inst.components.lootdropper:FlingItem(SpawnPrefab(socket.itemprefab))
    end

    inst.socketed = {}
    inst.socketlist = { 1, 2, 3, 4, 6, 7, 8, 9 } -- Missing 5 on purpuse!

    inst:UpdateGemCount()
    inst:ClearAllSocketDecorations()
end

local function RemoveGem(inst, gemname)
    for i=#inst.socketed, 1, -1 do
        if inst.socketed[i].itemprefab == gemname then
            table.remove(inst.socketed, i)
        end
    end

    inst:UpdateGemCount()
end

local function AddGem(inst,gemname)
    table.insert(inst.socketed, { itemprefab = gemname })

    inst:UpdateGemCount()
end

local function UpdateGemCount(inst)
    local gems =
    {
        red    = 0,
        blue   = 0,
        purple = 0,
        orange = 0,
        yellow = 0,
        green  = 0,
        opal   = 0,
        pearl  = 0,
    }

    if inst.socketed == nil then
        inst.gemcount = gems

        return
    end

    for i, data in pairs(inst.socketed) do
        local color = GEM_TO_COLOR_LOOKUP[data.itemprefab]

        if color ~= nil and gems[color] then
            gems[color] = gems[color] + 1

        elseif data.itemprefab == "opalpreciousgem" then
            gems.green  = gems.green  + 1
            gems.yellow = gems.yellow + 1
            gems.orange = gems.orange + 1
            gems.red    = gems.red    + 1
            gems.blue   = gems.blue   + 1
            gems.purple = gems.purple + 1
            gems.opal   = gems.opal   + 1

        elseif data.itemprefab == "hermit_pearl" then
            gems.green  = gems.green  + 3
            gems.yellow = gems.yellow + 3
            gems.orange = gems.orange + 3
            gems.red    = gems.red    + 3
            gems.blue   = gems.blue   + 3
            gems.purple = gems.purple + 3
            gems.pearl  = gems.pearl  + 1
        end
    end

    inst.gemcount = gems
end

local function SpawnChunk(inst, prefab, pos)
    local chip = SpawnPrefab(prefab)

    if chip ~= nil and pos ~= nil then
        chip.Transform:SetPosition(pos.x, 0, pos.z)
    end

    return chip
end

local function SetDamagedArt(inst, instant)
    local index = math.random(1, #inst.nondamagedsymbollist)
    local art = inst.nondamagedsymbollist[index]

    table.remove(inst.nondamagedsymbollist, index)
    table.insert(inst.damagedsymbollist, art)

    if not instant then
        local fx = SpawnPrefab("round_puff_fx_lg")
        fx.entity:AddFollower()
        fx.entity:SetParent(inst.entity)
        fx.Follower:FollowSymbol(inst.GUID, "damage"..art, 0, 0, 0)

        local chip = CHIP_SIZES[art]

        if chip ~= nil then
            inst:SpawnChunk(chip, inst:GetPosition())
        end

        inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/rock_hit")
    end

    inst.AnimState:OverrideSymbol("damage"..art, "crab_king_build", "nil")
end

local function SetRepairedArt(inst, instant)
    local index = math.random(1, #inst.damagedsymbollist)
    local art = inst.damagedsymbollist[index]

    table.remove(inst.damagedsymbollist, index)
    table.insert(inst.nondamagedsymbollist, art)

    inst.AnimState:OverrideSymbol("damage"..art, "crab_king_build", "damage"..art)
end

local function OnHealthChange(inst, data)
    -- data.instant is a custom key.

    local current = data.oldpercent

    if inst.damagetotal == nil then
        inst.damagetotal = 0
    end

    if data ~= nil and data.amount ~= nil and not data.instant and data.amount < 0 then
        inst.damagetotal = inst.damagetotal + data.amount
    end

    local done = nil

    while data.newpercent and not done do
        if data.oldpercent > data.newpercent then
            current = math.max(current - 0.1, data.newpercent)
        else
            current = math.min(current + 0.1, data.newpercent)
        end

        if (current <= 0.9 and current > 0.8 and #inst.nondamagedsymbollist >= 10) or
           (current <= 0.8 and current > 0.7 and #inst.nondamagedsymbollist >= 9) or
           (current <= 0.7 and current > 0.6 and #inst.nondamagedsymbollist >= 8) or
           (current <= 0.6 and current > 0.5 and #inst.nondamagedsymbollist >= 7) or
           (current <= 0.5 and current > 0.4 and #inst.nondamagedsymbollist >= 6) or
           (current <= 0.4 and current > 0.3 and #inst.nondamagedsymbollist >= 5) or
           (current <= 0.3 and current > 0.2 and #inst.nondamagedsymbollist >= 4) or
           (current <= 0.2 and current > 0.1 and #inst.nondamagedsymbollist >= 3) or
           (current <= 0.1 and current > 0.0 and #inst.nondamagedsymbollist >= 2) or
           (current <= 0.0                   and #inst.nondamagedsymbollist >= 1) then

            inst:SetDamagedArt(data.instant)
        end

        if (current >= 1.0                   and #inst.nondamagedsymbollist < 10) or
           (current >= 0.9 and current < 1.0 and #inst.nondamagedsymbollist < 9) or
           (current >= 0.8 and current < 0.9 and #inst.nondamagedsymbollist < 8) or
           (current >= 0.7 and current < 0.8 and #inst.nondamagedsymbollist < 7) or
           (current >= 0.6 and current < 0.7 and #inst.nondamagedsymbollist < 6) or
           (current >= 0.5 and current < 0.6 and #inst.nondamagedsymbollist < 5) or
           (current >= 0.4 and current < 0.5 and #inst.nondamagedsymbollist < 4) or
           (current >= 0.3 and current < 0.4 and #inst.nondamagedsymbollist < 3) or
           (current >= 0.2 and current < 0.3 and #inst.nondamagedsymbollist < 2) or
           (current >= 0.1 and current < 0.2 and #inst.nondamagedsymbollist < 1) then

            inst:SetRepairedArt(data.instant)
        end

        if current == data.newpercent then
            done = true
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function GetWintersFeastOrnaments(inst)
    local is_pearled = inst.gemcount.pearl > 0

    if not is_pearled and inst.gemcount.opal >= 3 then
        local hermit = TheWorld.components.messagebottlemanager ~= nil and TheWorld.components.messagebottlemanager:GetHermitCrab()
        is_pearled = hermit and hermit.pearlgiven
    end

    return is_pearled and { basic = 2, special = "winter_ornament_boss_crabkingpearl" } or { basic = 1, special = "winter_ornament_boss_crabking" }
end

local function PushMusic(inst)
    if ThePlayer == nil or not inst:HasTag("epic") then
        inst._playingmusic = false

    elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "crabking" })

    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
        inst._playingmusic = false
    end
end

local function GetStatus(inst)
    return inst.sg ~= nil and inst.sg:HasStateTag("inert") and "INERT" or nil
end

local function RestoreProjectileCollisionMask(inst, mask)
    inst.Physics:SetCollisionMask(mask)
end

local function LaunchProjectile(inst, targetpos, projectile)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab(projectile or "cannonball_rock")

    if projectile.components.complexprojectile == nil then
        projectile:AddComponent("complexprojectile")
    end

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = TUNING.FIRE_DETECTOR_RANGE
    local speed = easing.linear(rangesq, 15, 3, maxrange * maxrange)

    projectile:DoTaskInTime(60*FRAMES, RestoreProjectileCollisionMask, projectile.Physics:GetCollisionMask())

    projectile.Physics:SetCollisionMask(COLLISION.GROUND)
    projectile.Physics:Teleport(x, 5, z)

    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-25)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)

    return projectile
end

local function OnDeath(inst, data)
    inst:CleanUpArena()
end

local function OnIceTileBreak(inst, floe)
    -- Ice broke near us, get rid of the water hole.
    if floe:GetDistanceSqToInst(inst) < 8 * 8 then
        inst.AnimState:Hide("water")
        inst.Physics:SetCapsule(REGULAR_PHYSICS_RADIUS, 2)
    end
end

local function SnapToGrid(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    inst.Transform:SetPosition(math.floor(x)+0.5, 0, math.floor(z)+0.5)
end

----------------------------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(3.4)

    MakeWaterObstaclePhysics(inst, REGULAR_PHYSICS_RADIUS, 2, 0.1)

    inst.MiniMapEntity:SetIcon("crabking.png")

    inst.Transform:SetScale(CRABKING_SCALE, CRABKING_SCALE, CRABKING_SCALE)

    inst.AnimState:SetBank("king_crab")
    inst.AnimState:SetBuild("crab_king_build")
    inst.AnimState:PlayAnimation("inert", true)

    inst.AnimState:AddOverrideBuild("crab_king_hole_build")
    inst.AnimState:Hide("water")

    --  Added so the crab king will not get attached to a moving boat when it is past entity-sleep range.
    inst:AddTag("ignorewalkableplatforms")

    inst:AddTag("birdblocker")
    inst:AddTag("crabking")
    inst:AddTag("gemsocket")
    inst:AddTag("largecreature")
    inst:AddTag("crabking_ally")
    inst:AddTag("lunar_aligned")
    inst:AddTag("whip_crack_imune")

    inst.entity:SetPristine()

    if not TheNet:IsDedicated() then
        inst.PushMusic = PushMusic

        inst._playingmusic = false
        inst:DoPeriodicTask(1, inst.PushMusic, 0)
    end

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_removedeps = { "moon_altar_cosmic" }

    inst.scrapbook_maxhealth = TUNING.CRABKING_HEALTH
    inst.scrapbook_damage = 0

    inst.socketlist = { 1, 2, 3, 4, 6, 7, 8, 9 } -- Missing 5 on purpuse!
    inst.nondamagedsymbollist = { 1,2,3,4,5,6,7,8,9,10 }
    inst.damagedsymbollist = {}
    inst.socketed = {}
    inst.tasks = {}

    -- Internal and external functions.
    inst.AddGem = AddGem
    inst.RemoveGem = RemoveGem
    inst.DropSocketedGems = DropSocketedGems
    inst.EndCastSpell = EndCastSpell
    inst.ShineSocketOfColor = ShineSocketOfColor
    inst.SpawnCannons = SpawnCannons
    inst.SpawnChunk = SpawnChunk
    inst.SpawnClawArms = SpawnClawArms
    inst.StartCastSpell = StartCastSpell

    -- Internal functions.
    inst.SocketItem = SocketItem
    inst.AddSocketDecoration = AddSocketDecoration
    inst.ClearAllSocketDecorations = ClearAllSocketDecorations
    inst.SetDamagedArt = SetDamagedArt
    inst.SetRepairedArt = SetRepairedArt
    inst.ShineSocketInSlot = ShineSocketInSlot
    inst.UpdateGemCount = UpdateGemCount

    inst.BubbleSeaStack = BubbleSeaStack
    inst.DoDestroySeaStack = DoDestroySeaStack
    inst.DoSpawnSeaStack = DoSpawnSeaStack
    inst.SpawnSeaStacks = SpawnSeaStacks

    inst.DoSpawnIceTile = DoSpawnIceTile
    inst.DoSpawnIceWall = DoSpawnIceWall
    inst.EndIceStage = EndIceStage
    inst.RemoveIceArena = RemoveIceArena
    inst.CleanUpArena = CleanUpArena
    inst.GetFreezeRange = GetFreezeRange -- Deprecated.
    inst.SnapToGrid = SnapToGrid

    inst.DoSpawnArm = DoSpawnArm
    inst.LaunchCrabMob = LaunchCrabMob
    inst.LaunchProjectile = LaunchProjectile

    inst.FindCannonPositions = FindCannonPositions
    inst.SpawnCannonTower = SpawnCannonTower

    -- Event Listeners.
    inst.OnFreeze = OnFreeze -- Deprecated.
    inst.OnAttacked = OnAttacked
    inst.OnDeath = OnDeath
    inst.OnHealthChange = OnHealthChange

    inst.onkeystoneremoved    = function(stone)       OnKeyStoneRemoved(inst, stone)    end
    inst.oncannontowerremoved = function(tower)       OnCannonTowerRemoved(inst, tower) end
    inst.onarmremoved         = function(arm)         OnArmRemoved(inst, arm.armpos)    end
    inst.onicetilebreak       = function(world, floe) OnIceTileBreak(inst, floe)        end

    inst:AddComponent("entitytracker")
    inst:AddComponent("explosiveresist")
    inst:AddComponent("inventory")
    inst:AddComponent("knownlocations")
    inst:AddComponent("timer")

    inst:SetStateGraph("SGcrabking")
    inst:SetBrain(brain)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CRABKING_HEALTH)
    inst.components.health.destroytime = 5

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.CRABKING_DAMAGE)
    inst.components.combat.playerdamagepercent = TUNING.CRABKING_DAMAGE_PLAYER_PERCENT
    inst.components.combat:SetRange(TUNING.CRABKING_ATTACK_RANGE)
    inst.components.combat:SetAreaDamage(TUNING.CRABKING_AOE_RANGE, TUNING.CRABKING_AOE_SCALE)
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetAttackPeriod(TUNING.CRABKING_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("crabking")
    inst.components.lootdropper.GetWintersFeastOrnaments = GetWintersFeastOrnaments

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable:RecordViews()

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.deleteitemonaccept = false

    inst:ListenForEvent("attacked", inst.OnAttacked)
    inst:ListenForEvent("death", inst.OnDeath)
    inst:ListenForEvent("healthdelta", inst.OnHealthChange)
    inst:ListenForEvent("freeze", inst.OnFreeze)
    inst:ListenForEvent("icefloebreak", inst.onicetilebreak, TheWorld)

    inst:UpdateGemCount()

    inst:ClearAllSocketDecorations()

    inst.OnSave = OnSave
    inst.OnLoadPostPass = OnLoadPostPass

    inst.OnEntitySleep = OnEntitySleep
    inst.OnRemoveEntity = OnRemove

    inst.snaptogridtask = inst:DoTaskInTime(0, inst.SnapToGrid)

    return inst
        end

----------------------------------------------------------------------------------------------------------------------------------------------

local function dogeyserburbletask(inst)
    if inst.burbletask then
        inst.burbletask:Cancel()
        inst.burbletask = nil
    end
    local totalcasttime = TUNING.CRABKING_WAVE_ATTACK_TIMEOUT_TIME
    local time = Remap(inst.components.age:GetAge(),0,totalcasttime,0.2,0.01)
    inst.burbletask = inst:DoTaskInTime(time,function() inst.burble(inst) end) -- 0.01+ math.random()*0.1
end

local function burble(inst)
    local MAXRADIUS = 6
    local x,y,z = inst.Transform:GetWorldPosition()
    local theta = math.random()*TWOPI
    local radius = math.pow(math.random(),0.8)* MAXRADIUS
    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
    local prefab = "crab_king_bubble"..math.random(1,3)

    if TheWorld.Map:IsOceanAtPoint(x+offset.x, 0, z+offset.z) then
        local fx = SpawnPrefab(prefab)
        fx.Transform:SetPosition(x+offset.x,y+offset.y,z+offset.z)
    else
        local boat = TheWorld.Map:GetPlatformAtPoint(x+offset.x, z+offset.z)
        if boat then
            ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.1, 0.01, 0.3, boat, boat:GetPhysicsRadius(4))
        end
    end

    dogeyserburbletask(inst)
end


local function endgeyser(inst)
    inst:DoTaskInTime(2.4,function()
        if inst.burbletask then
            inst.burbletask:Cancel()
            inst.burbletask = nil
        end
    end)

    for i=1,TUNING.CRABKING_DEADLY_GEYSERS do
        inst:DoTaskInTime(math.random()*0.4,function()
            local MAXRADIUS = 4.5
            local x,y,z = inst.Transform:GetWorldPosition()
            local theta = math.random()*TWOPI
            local radius = math.pow(math.random(),0.8)* MAXRADIUS
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            local prefab = "crab_king_waterspout"
            if TheWorld.Map:IsOceanAtPoint(x+offset.x, 0, z+offset.z) then
                local fx = SpawnPrefab(prefab)
                fx.Transform:SetPosition(x+offset.x,y+offset.y,z+offset.z)

                local INITIAL_LAUNCH_HEIGHT = 0.1
                local SPEED = 8
                local CANT_HAVE_TAGS = {"INLIMBO", "outofreach", "DECOR"}
                local function launch_away(inst, position)
                    local ix, iy, iz = inst.Transform:GetWorldPosition()
                    inst.Physics:Teleport(ix, iy + INITIAL_LAUNCH_HEIGHT, iz)

                    local px, py, pz = position:Get()
                    local angle = (180 - inst:GetAngleToPoint(px, py, pz)) * DEGREES
                    local sina, cosa = math.sin(angle), math.cos(angle)
                    inst.Physics:SetVel(SPEED * cosa, 4 + SPEED, SPEED * sina)
                end
                local affected_entities = TheSim:FindEntities(x+offset.x,y+offset.y,z+offset.z, 2, nil, CANT_HAVE_TAGS)
                for _, v in ipairs(affected_entities) do
                    if v.components.oceanfishable ~= nil then
                        -- Launch fishable things because why not.

                        local projectile = v.components.oceanfishable:MakeProjectile()
                        if projectile.components.weighable ~= nil then
                            projectile.components.weighable.prefab_override_owner = inst.fisher_prefab
                        end
                        local position = Vector3(x+offset.x,y+offset.y,z+offset.z)
                        if projectile.components.complexprojectile then
                            projectile.components.complexprojectile:SetHorizontalSpeed(16)
                            projectile.components.complexprojectile:SetGravity(-30)
                            projectile.components.complexprojectile:SetLaunchOffset(Vector3(0, 0.5, 0))
                            projectile.components.complexprojectile:SetTargetOffset(Vector3(0, 0.5, 0))

                            local v_position = v:GetPosition()
                            local launch_position = v_position + (v_position - position):Normalize() * SPEED
                            projectile.components.complexprojectile:Launch(launch_position, projectile)
                        else
                            launch_away(projectile, position)
                        end
                    end
                end


            else
                local boat = TheWorld.Map:GetPlatformAtPoint(x+offset.x, z+offset.z)
                if boat then
                    local pt = Vector3(x+offset.x,0,z+offset.z)
                    boat.components.health:DoDelta(-TUNING.CRABKING_GEYSER_BOATDAMAGE)

                    -- look for patches
                    local nearpatch = TheSim:FindEntities(pt.x, 0, pt.z, 2, REPAIRED_PATCH_MUST_TAGS)
                    for i,patch in pairs(nearpatch)do
                        pt = Vector3(patch.Transform:GetWorldPosition())
                        patch:Remove()
                        break
                    end

                    boat:PushEvent("spawnnewboatleak", {pt = pt, leak_size = "small_leak", playsoundfx = true})
                end
            end
        end)
    end

    inst:DoTaskInTime(2, endgeyser)
end

local function geyserfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("fx")
    inst:AddTag("crabking_spellgenerator")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("age")

    inst.persists = false

    inst.burble = burble
    inst.dogeyserburbletask = dogeyserburbletask

    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/bubble_LP","burble")
    inst.SoundEmitter:SetParameter("burble", "intensity", 0)
    inst.burblestarttime = GetTime()
    inst.burbleintensity = inst:DoPeriodicTask(1,function()
            local totalcasttime = TUNING.CRABKING_WAVE_ATTACK_TIMEOUT_TIME
            local intensity = math.min(1,( GetTime() - inst.burblestarttime ) / totalcasttime)

            inst.SoundEmitter:SetParameter("burble", "intensity", intensity)
      end)
    inst:ListenForEvent("onremove", function()
        if inst.burbletask then
            inst.burbletask:Cancel()
            inst.burbletask = nil
        end
        if inst.burbleintensity then
            inst.burbleintensity:Cancel()
            inst.burbleintensity = nil
        end
        inst.SoundEmitter:KillSound("burble")
    end)

    inst:DoTaskInTime(TUNING.CRABKING_WAVE_ATTACK_TIMEOUT_TIME,function()
        endgeyser(inst)
    end)

    dogeyserburbletask(inst)

    return inst
end



-- FREEZE FX

local function onfreeze(inst, target)
    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end

    if target.components.burnable ~= nil then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    if target.components.combat ~= nil and inst.crab and inst.crab:IsValid() then
        target.components.combat:SuggestTarget(inst.crab)
    end

    if target.sg ~= nil and not target.sg:HasStateTag("frozen") and inst.crab and inst.crab:IsValid() then
        target:PushEvent("attacked", { attacker = inst.crab, damage = 0, weapon = inst })
    end

    if target.components.freezable ~= nil then
        target.components.freezable:AddColdness(10,10 + Remap((inst.crab and inst.crab:IsValid() and inst.crab.gemcount.blue or 0),0,9,0,10) )
        target.components.freezable:SpawnShatterFX()
    end
end

local function dofreezefz(inst)
    if inst.freezetask then
        inst.freezetask:Cancel()
        inst.freezetask = nil
    end
    local time = 0.1
    inst.freezetask = inst:DoTaskInTime(time,function() inst.freezefx(inst) end)
end

local function freezefx(inst)
    local function spawnfx()
        local MAXRADIUS = inst.crab and inst.crab:IsValid() and inst.crab:GetFreezeRange() or (TUNING.CRABKING_FREEZE_RANGE * 0.75)
        local x,y,z = inst.Transform:GetWorldPosition()
        local theta = math.random()*TWOPI
        local radius = 4+ math.pow(math.random(),0.8)* MAXRADIUS
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

        local prefab = "crab_king_icefx"
        local fx = SpawnPrefab(prefab)
        fx.Transform:SetPosition(x+offset.x,y+offset.y,z+offset.z)
    end

    local MAXFX = Remap(( inst.crab and inst.crab:IsValid() and inst.crab.gemcount.blue or 0),0, 9,5,15)


    local fx = Remap(inst.components.age:GetAge(),0,TUNING.CRABKING_CAST_TIME_FREEZE - (math.min((inst.crab and inst.crab:IsValid() and math.floor(inst.crab.gemcount.yellow/2) or 0),4)),1,MAXFX)

    for i=1,fx do
        if math.random()<0.2 then
            spawnfx()
        end
    end

    dofreezefz(inst)
end

local FREEZE_CANT_TAGS = { "crabking_ally", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }

local function dofreeze(inst)
    local interval = 0.2
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local range = inst.crab and inst.crab:IsValid() and inst.crab:GetFreezeRange() or (TUNING.CRABKING_FREEZE_RANGE * 0.75)
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, range, nil, FREEZE_CANT_TAGS)
    for i,v in pairs(ents)do
        if v.components.temperature then
            local rate = (TUNING.CRABKING_BASE_FREEZE_AMOUNT + ((inst.crab and inst.crab:IsValid() and inst.crab.gemcount.blue or 0) * TUNING.CRABKING_FREEZE_INCRAMENT)) /( (TUNING.CRABKING_CAST_TIME_FREEZE - (inst.crab and inst.crab:IsValid() and math.floor(inst.crab.gemcount.yellow/2) or 0) ) /interval)
            if v.components.moisture then
                rate = rate * Remap(v.components.moisture:GetMoisture(),0,v.components.moisture.maxmoisture,1,3)
            end

            local mintemp = v.components.temperature.mintemp
            local curtemp = v.components.temperature:GetCurrent()
            if mintemp < curtemp then
                v.components.temperature:DoDelta(math.max(-rate, mintemp - curtemp))
            end
        end
    end

    local time = 0.2
    inst.lowertemptask = inst:DoTaskInTime(time,function() inst.dofreeze(inst) end)
end

local function endfreeze(inst)
    if inst.freezetask then
        inst.freezetask:Cancel()
        inst.freezetask = nil
    end

    if inst.lowertemptask then
        inst.lowertemptask:Cancel()
        inst.lowertemptask = nil
    end

    local pos = Vector3(inst.Transform:GetWorldPosition())
    local range = inst.crab and inst.crab:IsValid() and inst.crab:GetFreezeRange() or (TUNING.CRABKING_FREEZE_RANGE * 0.75)
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, range, nil, FREEZE_CANT_TAGS)
    for i,v in pairs(ents)do
        onfreeze(inst, v)
    end
    SpawnPrefab("crabking_ring_fx").Transform:SetPosition(pos.x,pos.y,pos.z)
    inst:DoTaskInTime(1, inst.Remove)
end

local function freezefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("fx")
    inst:AddTag("crabking_spellgenerator")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("age")

    inst.persists = false

    inst.freezefx = freezefx
    inst.dofreeze = dofreeze
    inst:DoTaskInTime(0,function()
        dofreezefz(inst)
        dofreeze(inst)
    end)

    inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/ice_attack")

    inst:ListenForEvent("onremove", function()
        if inst.burbletask then
            inst.burbletask:Cancel()
            inst.burbletask = nil
        end
    end)

    inst:ListenForEvent("endspell", function()
        endfreeze(inst)
    end)

    inst:DoTaskInTime(TUNING.CRABKING_CAST_TIME+2,function()
        endfreeze(inst)
    end)

    return inst
end

local function chipfn(type)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local phys = inst.entity:AddPhysics()
    phys:SetMass(1)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.FLYERS)
    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    phys:SetCapsule(0.5, 1)

    local s  = 0.7
    inst.Transform:SetScale(s, s, s)

    inst.AnimState:SetBank("rockchip")
    inst.AnimState:SetBuild("crabking_rockchip")
    inst.AnimState:PlayAnimation("rockchip_"..type)

    inst:AddTag("NOCLICK")
    inst:AddTag("fx")

    local down = TheCamera:GetDownVec()
    local offset = (math.random()*30 + 50)
    if math.random() > 0.5 then
        offset = -offset
    end
    local angle = (math.atan2(-down.z, down.x) / DEGREES ) + offset
    inst.Transform:SetRotation(angle)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("hit_water") or inst.AnimState:IsCurrentAnimation("hit_land") then
            inst:Remove()
        end
        if not inst.landed then
            inst.Physics:Stop()
            inst.landed = true
            local pos = Vector3(inst.Transform:GetWorldPosition())
            if not TheWorld.Map:IsVisualGroundAtPoint(pos.x,pos.y,pos.z) and not TheWorld.Map:GetPlatformAtPoint(pos.x,pos.z) then
                inst.AnimState:PlayAnimation("hit_water")
            else
                inst.AnimState:PlayAnimation("hit_land")
            end
        end
    end)

    inst.Physics:SetMotorVel(math.random(8,12), 0, 0)

    inst.persists = false

    return inst
end

return Prefab("crabking", fn, assets, prefabs),
       Prefab("crabking_geyserspawner", geyserfn, nil, geyserprefabs),
       --Prefab("crabking_feeze", freezefn, nil, freezeprefabs),
       Prefab("crabking_chip_high", function() return chipfn("high") end, chipassets),
       Prefab("crabking_chip_med",  function() return chipfn("mid") end, chipassets),
       Prefab("crabking_chip_low",  function() return chipfn("low") end,  chipassets)
