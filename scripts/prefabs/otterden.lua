require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/otter_den.zip"),
    Asset("MINIMAP_IMAGE", "otter_den"),
}

local prefabs =
{
    "collapse_big",
    "otter",
    "otterden_dead",
}

local POSSIBLE_LOOT_ITEMS = {
    barnacle          = 1,
    boatpatch_kelp    = 1,
    bullkelp_root     = 1,
    driftwood_log     = 1,
    fishmeat          = 2,
    fishmeat_small    = 2,
    kelp              = 2,
    monstermeat       = 2,
    meat              = 2,
    smallmeat         = 2,
}
for loot_item in pairs(POSSIBLE_LOOT_ITEMS) do
    table.insert(prefabs, loot_item)
end

SetSharedLootTable("otterden",
{
    {"kelp",            1.00},
    {"kelp",            1.00},
    {"kelp",            0.75},
    {"boatpatch_kelp",  0.75},
    {"boatpatch_kelp",  0.50},
    {"barnacle",        0.50},
    {"barnacle",        0.25},
})

local SLEEP_TIMER_NAME = "push_sleep_anim"

local function spawn_child_and_do_aggro(inst, aggro_target)
    -- If we're spawning for aggression purposes,
    -- force the spawn, even if it's normally a no-spawn time period.
    inst._force_spawn = true
    inst.components.childspawner:SpawnChild(aggro_target)
    inst._force_spawn = nil
end

local function try_generate_loot_item(inst)
    local inventory = inst.components.inventory
    if inventory:IsFull() then
        local valid_options = nil
        inventory:ForEachItem(function(item)
            if POSSIBLE_LOOT_ITEMS[item.prefab]
                    and item.components.stackable
                    and not item.components.stackable:IsFull() then
                valid_options = valid_options or {}
                table.insert(valid_options, item)
            end
        end)
        if valid_options then
            local item = valid_options[math.random(#valid_options)]
            local item_stackable = item.components.stackable
            item_stackable:SetStackSize(item_stackable:StackSize() + 1)
            return true
        end
    else
        local item_to_spawn = weighted_random_choice(POSSIBLE_LOOT_ITEMS)
        inventory:GiveItem(SpawnPrefab(item_to_spawn))
        return true
    end

    return false
end

-- Spawner Functions
local function OnGoHome(inst, child)
    inst.SoundEmitter:PlaySound("meta4/otter_den/enter")

    -- What do we do when the inventory is full...?
    -- Could leave stuff around the den, could complicate the child to check for
    -- owner fullness at all times, etc.
    if not inst.components.inventory:IsFull() then
        child.components.inventory:TransferInventory(inst)
    else
        child.components.inventory:DropEverything()
    end

    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)
end

local function change_otter_sleeping_inside_state(inst, new_state)
    if new_state == inst._is_sleeping_inside then return end

    inst._is_sleeping_inside = new_state
    if new_state then
        inst.components.timer:ResumeTimer(SLEEP_TIMER_NAME)
        inst.SoundEmitter:PlaySound("meta4/otter_den/otter_in_den", "ottersound")
    else
        inst.components.timer:PauseTimer(SLEEP_TIMER_NAME)
        inst.SoundEmitter:KillSound("ottersound")
    end
end

local function OnSpawned(inst, child)
    inst.SoundEmitter:PlaySound("meta4/otter_den/enter")
end

local function OnOccupied(inst)
    change_otter_sleeping_inside_state(inst, true)
end

local function OnVacate(inst)
    change_otter_sleeping_inside_state(inst, false)
end

local function CanSpawn(inst)
    return inst._force_spawn
        or not (TheWorld.state.iscavenight or TheWorld.state.iswinter)
end

-- Combat Functions
local function OnHit(inst, attacker)
    if inst.components.health:IsDead() then return end

    spawn_child_and_do_aggro(inst, attacker)

    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_hit")
end

--
local function GetDenStatus(inst, viewer)
    return (inst.components.inventory:GetFirstItemInAnySlot() == nil and "GENERIC")
        or "HAS_LOOT"
end

--
local function OnSearched(inst, searcher)
    spawn_child_and_do_aggro(inst, searcher)

    local searched_item = inst.components.inventory:GetFirstItemInAnySlot()
    if not searched_item then
        return false, "NOTHING_INSIDE"
    end

    searched_item = (searched_item.components.stackable ~= nil and searched_item.components.stackable:Get())
        or searched_item
    if searcher.components.inventory then
        searcher.components.inventory:GiveItem(searched_item)
    else
        inst.components.inventory:DropItem(searched_item)
    end

    local half_inventory_count = math.floor(0.5 * inst.components.inventory.maxslots)
    if inst.components.inventory:NumStackedItems() <= half_inventory_count and inst._pile2_showing then
        inst.AnimState:Hide("pile2")
        inst._pile2_showing = nil
    end

    if not inst.components.inventory:GetFirstItemInAnySlot() then
        inst.components.searchable.canbesearched = false
        if inst._pile1_showing then
            inst.AnimState:Hide("pile1")
            inst._pile1_showing = nil
        end
    end

    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)

    return true
end

-- Fire
local function OnIgnited(inst, source, doer)
    local childspawner = inst.components.childspawner
    for child in pairs(childspawner.childrenoutside) do
        if child.components.combat then
            child.components.combat:SuggestTarget(doer or source)
        end
    end
    childspawner:ReleaseAllChildren(doer or source)

    DefaultBurnFn(inst, source, doer)
end

-- Event listeners
local function OnKilled(inst, data)
    RemovePhysicsColliders(inst)

    inst.components.childspawner:ReleaseAllChildren((data and data.afflicter) or nil)

    local ipos = inst:GetPosition()
    inst.components.lootdropper:DropLoot(ipos)

    local platform = inst:GetCurrentPlatform()
    if platform and platform.components.health and not platform.components.health:IsDead() then
        local dead_den = SpawnPrefab("otterden_dead")
        dead_den.Transform:SetPosition(ipos:Get())
    end

    inst:Remove()
end

local function OnItemGet(inst, data)
    local inventory = inst.components.inventory

    inst.components.searchable.canbesearched = (
        data ~= nil
        and data.item ~= nil
        and inventory:GetFirstItemInAnySlot() ~= nil
    )

    local half_inventory_count = math.floor(0.5 * inventory.maxslots)
    local num_stacked_items = inventory:NumStackedItems()
    if num_stacked_items > half_inventory_count then
        if not inst._pile1_showing then
            inst.AnimState:Show("pile1")
            inst._pile1_showing = true
        end
        if not inst._pile2_showing then
            inst.AnimState:Show("pile2")
            inst._pile2_showing = true
        end
    elseif inventory:NumStackedItems() == 1 then
        inst.AnimState:Show("pile1")
        inst._pile1_showing = true
    end
end

local function OnMoved(inst, mover)
    local childspawner = inst.components.childspawner
    for child in pairs(childspawner.childrenoutside) do
        if child.components.combat then
            child.components.combat:SuggestTarget(mover)
        end
    end
end

local function OnIsNightChanged(inst, isnight)
    if not isnight then
        inst.components.childspawner:StartSpawning()
    else
        inst.components.childspawner:StopSpawning()
    end
end

-- Entity Sleep/Wake
local SLEEPING_LOOT_TIME = (TUNING.AUTUMN_LENGTH * TUNING.TOTAL_DAY_TIME) / (2 * TUNING.OTTERDEN_INVENTORY_SLOTS)
local SLEEPING_LOOT_NAME = "entitysleep_generate_loot"
local function IsWinter_UpdateLootGeneration(inst, iswinter)
    local timer = inst.components.timer
    if iswinter and timer:TimerExists(SLEEPING_LOOT_NAME) then
        timer:StopTimer(SLEEPING_LOOT_NAME)
    elseif not iswinter and not timer:TimerExists(SLEEPING_LOOT_NAME) then
        timer:StartTimer(SLEEPING_LOOT_NAME, SLEEPING_LOOT_TIME)
    end
end

local function OnEntitySleep(inst)
    local timer = inst.components.timer
    if not TheWorld.state.iswinter and not timer:TimerExists(SLEEPING_LOOT_NAME) then
        timer:StartTimer(SLEEPING_LOOT_NAME, SLEEPING_LOOT_TIME)
    end
    inst:WatchWorldState("iswinter", IsWinter_UpdateLootGeneration)
end

local function OnEntityWake(inst)
    inst:StopWatchingWorldState("iswinter", IsWinter_UpdateLootGeneration)
    inst.components.timer:StopTimer(SLEEPING_LOOT_NAME)
end

-- Save/Load
local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.OTTERDEN_SPAWN_PERIOD, TUNING.OTTERDEN_REGEN_PERIOD)
end

-- Timer
local function OnTimerDone(inst, data)
    if data.name == SLEEPING_LOOT_NAME then
        if try_generate_loot_item(inst) then
            inst.components.timer:StartTimer(SLEEPING_LOOT_NAME, SLEEPING_LOOT_TIME)
        end
    elseif data.name == SLEEP_TIMER_NAME then
        if inst._is_sleeping_inside then
            if inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("sleep")
                inst.AnimState:PushAnimation("idle", true)
                inst.components.timer:StartTimer(SLEEP_TIMER_NAME, 6 + 3 * math.random())
            else
                -- Do a shorter time period if we "missed" due to not being in idle
                inst.components.timer:StartTimer(SLEEP_TIMER_NAME, 1 + math.random())
            end
        else
            -- If we don't have a sleeping otter anymore, we still want to re-queue the anim,
            -- but we pause it immediately so it can be resumed properly if things change.
            inst.components.timer:StartTimer(SLEEP_TIMER_NAME, 6 + 3 * math.random(), true)
        end
    end
end

--
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.7)

    inst.MiniMapEntity:SetIcon("otter_den.png")

    inst.AnimState:SetBuild("otter_den")
    inst.AnimState:SetBank("otter_den")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("pile1")
    inst.AnimState:Hide("pile2")

    inst:AddTag("angry_when_rowed")
    inst:AddTag("pickable_search_str") -- To change the action string, b/c searchable piggybacks on ACTIONS.PICK
    inst:AddTag("soulless")
    inst:AddTag("wet")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    local childspawner = inst:AddComponent("childspawner")
    childspawner.childname = "otter"
    childspawner.allowwater = true
    childspawner.allowboats = true
    childspawner:SetRegenPeriod(TUNING.OTTERDEN_REGEN_PERIOD)
    childspawner:SetSpawnPeriod(TUNING.OTTERDEN_SPAWN_PERIOD)
    childspawner:SetMaxChildren(2)
    childspawner:SetGoHomeFn(OnGoHome)
    childspawner:SetSpawnedFn(OnSpawned)
    childspawner:SetOccupiedFn(OnOccupied)
    childspawner:SetVacateFn(OnVacate)
    childspawner.canspawnfn = CanSpawn
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.OTTERDEN_REGEN_PERIOD, TUNING.OTTERDEN_ENABLED)
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.OTTERDEN_SPAWN_PERIOD, TUNING.OTTERDEN_ENABLED)
    if not TUNING.OTTERDEN_ENABLED then
        childspawner.childreninside = 0
    end
    childspawner:StartRegen()
    childspawner:StartSpawning()

    --
    local combat = inst:AddComponent("combat")
    combat:SetOnHit(OnHit)

    --
    local health = inst:AddComponent("health")
    health:SetMaxHealth(TUNING.OTTERDEN_HEALTH)
    health.nofadeout = true

    --
    local inspectable = inst:AddComponent("inspectable")
    inspectable.getstatus = GetDenStatus

    --
    local inventory = inst:AddComponent("inventory")
    inventory.maxslots = TUNING.OTTERDEN_INVENTORY_SLOTS

    --
    local lootdropper = inst:AddComponent("lootdropper")
    lootdropper:SetChanceLootTable("otterden")

    --
    local searchable = inst:AddComponent("searchable")
    searchable.onsearchfn = OnSearched

    --
    local timer = inst:AddComponent("timer")
    timer:StartTimer(SLEEP_TIMER_NAME, 5, true)

    --
    local burnable = MakeMediumBurnable(inst)
    burnable:SetOnIgniteFn(OnIgnited)
    burnable:SetOnBurntFn(OnKilled)

    --
    MakeHauntable(inst)

    --
    MakeSnowCovered(inst)

    --
    inst:ListenForEvent("death", OnKilled)
    inst:ListenForEvent("itemget", OnItemGet)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("onmoved", OnMoved)

    --
    inst:WatchWorldState("iscavenight", OnIsNightChanged)

    --
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    --
    inst.OnPreLoad = OnPreLoad

    --
    return inst
end

-- DESTROYED DEN
local function on_dead_initialize(inst)
    local current_platform = inst:GetCurrentPlatform()
    if current_platform ~= nil then
        current_platform:PushEvent("dead_otterden_added", inst)
    end
end

local function deadfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.7)

    inst.MiniMapEntity:SetIcon("otter_den.png")

    inst.AnimState:SetBuild("otter_den")
    inst.AnimState:SetBank("otter_den")
    inst.AnimState:PlayAnimation("dead", true)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    inst:AddComponent("inspectable")

    --
    MakeHauntable(inst)

    --
    MakeSnowCovered(inst)

    --
    inst:DoTaskInTime(0, on_dead_initialize)

    --
    return inst
end

return Prefab("otterden", fn, assets, prefabs),
    Prefab("otterden_dead", deadfn, assets)