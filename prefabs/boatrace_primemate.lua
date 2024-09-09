local assets =
{
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
    Asset("ANIM", "anim/ds_pig_attacks.zip"),
    Asset("ANIM", "anim/ds_pig_elite.zip"),
    Asset("ANIM", "anim/ds_pig_boat_jump.zip"),
    Asset("ANIM", "anim/ds_pig_monkey.zip"),
    Asset("ANIM", "anim/monkeymen_build.zip"),

    --for water fx build overrides
    Asset("ANIM", "anim/slide_puff.zip"),
    Asset("ANIM", "anim/splash_water_rot.zip"),

    Asset("SOUND", "sound/monkey.fsb"),
}

local prefabs =
{
    "boatrace_seastack_monkey_throwable_deploykit",
    "cave_banana",
    "dragonheadhat",
    "monkey_mediumhat",
    "monkeyprojectile",
    "oar_monkey",
    "poop",
    "smallmeat",
}

local brain = require "brains/boatrace_primematebrain"

local function CLIENT_OnTalk(inst)--, script)
    inst.SoundEmitter:PlaySound("monkeyisland/primemate/speak")
end

local function path_is_blocked(inst, target)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local tx, ty, tz = target.Transform:GetWorldPosition()

    local distance_to_placer = math.sqrt(distsq(ix, iz, tx, tz))
    local num_steps = math.floor(distance_to_placer / TILE_SCALE)
    local Map = TheWorld.Map
    local blocked = false
    if num_steps > 0 then
        local placer_to_helper_normal = Vector3(ix - tx, 0, iz - tz) / distance_to_placer
        local test_x, test_z
        for i = 0, num_steps-1 do
            test_x = tx + placer_to_helper_normal.x * i * TILE_SCALE
            test_z = tz + placer_to_helper_normal.z * i * TILE_SCALE
            if not Map:IsOceanAtPoint(test_x, 0, test_z, true) then
                blocked = true
                break
            end
        end
    end

    return blocked
end

local function initialize(inst)
    local dragon_hat = SpawnPrefab("dragonheadhat")
    dragon_hat.persists = false
    dragon_hat.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.components.inventory:Equip(dragon_hat)
end

local BOATRACE_CHECKPOINT_MUSTTAGS = {"boatrace_proximitybeacon"}
local function boat_command_update(inst)
    local crewmember = inst.components.crewmember
    if not crewmember then return end

    local current_platform = inst:GetCurrentPlatform()
    if current_platform ~= crewmember.boat or not current_platform then return end

    local boatracecrew = current_platform.components.boatracecrew
    if not boatracecrew then return end

    local boatrace_checkpoint_indicator = inst.components.entitytracker:GetEntity("indicator")
    if not boatrace_checkpoint_indicator then
        -- Lazily pick up our checkpoint indicator; it's ok to be "soft" about our timing here.
        boatrace_checkpoint_indicator = FindEntity(
            inst,
            2*TUNING.DRAGON_BOAT_RADIUS,
            function(test_entity, i)
                return test_entity:GetCurrentPlatform() == current_platform
                    or test_entity.parent == current_platform
            end,
            BOATRACE_CHECKPOINT_MUSTTAGS
        )
        if boatrace_checkpoint_indicator then
            inst.components.entitytracker:TrackEntity("indicator", boatrace_checkpoint_indicator)
            inst:ListenForEvent("checkpoint_found", inst._on_checkpoint_found, boatrace_checkpoint_indicator)
        end
    end
    if not boatrace_checkpoint_indicator then return end

    local current_checkpoint = boatrace_checkpoint_indicator._current_checkpoint
    if current_checkpoint and current_checkpoint ~= boatracecrew.target then
        if boatrace_checkpoint_indicator.GetCheckpoints and path_is_blocked(inst, current_checkpoint) then
            local all_checkpoints = boatrace_checkpoint_indicator:GetCheckpoints()
            if all_checkpoints then
                current_checkpoint = GetRandomItemWithIndex(all_checkpoints)
            end
        end
        boatracecrew:SetTarget(current_checkpoint)
        inst:PushEvent("command")

        -- Sometimes, when we get a new checkpoint, generate a buoy into our inventory.
        -- The brain should pick this up and toss it if a player gets close enough.
        if inst.components.inventory and math.random() < TUNING.BOATRACE_PRIMEMATE_BUOYCHANCE then
            local buoy = SpawnPrefab("boatrace_seastack_monkey_throwable_deploykit")
            buoy.Transform:SetPosition(inst.Transform:GetWorldPosition())
            buoy.persists = false
            buoy._spawner = inst
            buoy:ListenForEvent("onremove", function() buoy._spawner = nil end, inst)
            inst.components.inventory:GiveItem(buoy)
        end
    end
end

local function sleep_ai_update(inst)
    local crewmember = inst.components.crewmember
    if not crewmember then return end

    local current_platform = inst:GetCurrentPlatform()
    if current_platform ~= crewmember.boat or not current_platform then return end

    -- First, look for leaks.
    local entities_on_platform = (current_platform.components.walkableplatform
        and current_platform.components.walkableplatform:GetEntitiesOnPlatform())
        or nil
    if entities_on_platform then
        for entity_on_platform in pairs(entities_on_platform) do
            if entity_on_platform.components.boatleak and entity_on_platform.components.boatleak.has_leaks then
                entity_on_platform.components.boatleak:Repair(inst, SpawnPrefab("treegrowthsolution"))
                return
            end
        end
    end

    -- If we didn't find any leaks, see if we have a target to row to, and row to it.
    local boatracecrew = current_platform.components.boatracecrew
    if not boatracecrew or not boatracecrew.target then return end

    inst.components.crewmember:Row()
end

local function OnEntitySleep(inst)
    -- If we're asleep, our brain won't do any rowing for us,
    -- so let's just set up a trivial row task for while we're offscreen.
    inst._sleep_row_task = inst._sleep_row_task or inst:DoPeriodicTask(18*FRAMES, sleep_ai_update, 5*FRAMES)
end

local function OnEntityWake(inst)
    if inst._sleep_row_task then
        inst._sleep_row_task:Cancel()
        inst._sleep_row_task = nil
    end
end

--
local BOATRACE_PRIMEMATE_PATHINGCAPABILITIES = { ignorecreep = false }
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, 1.25)

    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 10, 0.25)

    inst.AnimState:SetBank("pigman")
    inst.AnimState:SetBuild("monkeymen_build")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:OverrideSymbol("fx_slidepuff01", "slide_puff", "fx_slidepuff01")
    inst.AnimState:OverrideSymbol("splash_water_rot", "splash_water_rot", "splash_water_rot")
    inst.AnimState:OverrideSymbol("fx_water_spot", "splash_water_rot", "fx_water_spot")
    inst.AnimState:OverrideSymbol("fx_splash_wide", "splash_water_rot", "fx_splash_wide")
    inst.AnimState:OverrideSymbol("fx_water_spray", "splash_water_rot", "fx_water_spray")
    inst.AnimState:UsePointFiltering(true)
    inst.AnimState:SetMultColour(0, 0, 0, 0.85)

    inst.AnimState:Hide("ARM_carry_up")

    inst:AddTag("character")
    inst:AddTag("monkey")
    inst:AddTag("nomagic")
    inst:AddTag("pirate")
    inst:AddTag("racer")
    inst:AddTag("scarytoprey")

    local talker = inst:AddComponent("talker")
    talker.fontsize = 35
    talker.font = TALKINGFONT
    talker.offset = Vector3(0, -400, 0)
    talker:MakeChatter()
    talker.ontalk = CLIENT_OnTalk

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._on_checkpoint_found = function(indicator)
        inst:PushEvent("cheer")
    end

    --
    inst:AddComponent("drownable")

    --
    inst:AddComponent("entitytracker")

    --
    inst:AddComponent("inspectable")

    --
    local inventory = inst:AddComponent("inventory")
    inventory:DisableDropOnDeath()
    inventory.maxslots = 10

    --
    inst:AddComponent("knownlocations")

    --
    local locomotor = inst:AddComponent("locomotor")
    locomotor:SetSlowMultiplier( 1 )
    locomotor:SetTriggersCreep(false)
    locomotor.pathcaps = BOATRACE_PRIMEMATE_PATHINGCAPABILITIES
    locomotor.walkspeed = 0.5 * TUNING.MONKEY_MOVE_SPEED

    --
    inst:AddComponent("timer")

    --
    MakeMediumBurnableCharacter(inst, "pig_torso")
    MakeMediumFreezableCharacter(inst)

    --
    MakeHauntablePanic(inst)

    --
    inst:DoTaskInTime(FRAMES, initialize)
    inst:DoPeriodicTask(1, boat_command_update)

    --
    inst:SetBrain(brain)
    inst:SetStateGraph("SGprimemate")

    --
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    --
    inst.persists = false

    --
    return inst
end

return Prefab("boatrace_primemate", fn, assets, prefabs)