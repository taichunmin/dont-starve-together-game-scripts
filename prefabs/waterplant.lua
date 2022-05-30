local assets =
{
    Asset("ANIM", "anim/barnacle_plant.zip"),
    Asset("ANIM", "anim/barnacle_plant_colour_swaps.zip"),
    Asset("MINIMAP_IMAGE", "barnacle_plant"),
}

local baseassets =
{
    Asset("ANIM", "anim/barnacle_plant.zip"),
}

local FISH_SUMMON_TYPE = "oceanfish_small_9"
local prefabs =
{
    FISH_SUMMON_TYPE,
    "barnacle",
    "barnacle_cooked",
    "waterplant_base",
    "waterplant_bomb",
    "waterplant_planter",
    "waterplant_pollen_fx",
    "waterplant_projectile",
    "waterplant_rock",
}

local brain = require("brains/waterplantbrain")

SetSharedLootTable("waterplant",
{
    {"waterplant_bomb",         1.00},
    {"waterplant_bomb",         1.00},
    {"waterplant_bomb",         0.50},
})

SetSharedLootTable("yellow_waterplant",
{
    {"waterplant_bomb",         1.00},
    {"waterplant_bomb",         1.00},
    {"waterplant_bomb",         1.00},
    {"waterplant_bomb",         0.50},
    {"waterplant_bomb",         0.50},
})

local FLOWER_COLOURS = {"", "white_", "yellow_"}

local function set_flower_type(inst, colour)
    if inst._colour == nil or (colour ~= nil and inst._colour ~= colour) then
        inst._colour = colour or FLOWER_COLOURS[math.random(#FLOWER_COLOURS)]

        inst.AnimState:OverrideSymbol("bc_bud", "barnacle_plant_colour_swaps", inst._colour.."bc_bud")
        inst.AnimState:OverrideSymbol("bc_face", "barnacle_plant_colour_swaps", inst._colour.."bc_face")
        inst.AnimState:OverrideSymbol("bc_flower_petal", "barnacle_plant_colour_swaps", inst._colour.."bc_flower_petal")
    end

    if inst._colour == "yellow_" then
        inst.components.combat:SetAttackPeriod(TUNING.WATERPLANT.YELLOW_ATTACK_PERIOD)

        inst.components.lootdropper:SetChanceLootTable("yellow_waterplant")
    elseif inst._colour == "white_" then
        inst.components.childspawner:SetRegenPeriod(TUNING.WATERPLANT.FISH_SPAWN.WHITE_REGEN_PERIOD)
        inst.components.childspawner:StartRegen() -- to reset childspawner.timetonextregen
    else
        inst._pollen_reset_time = TUNING.WATERPLANT.PINK_POLLEN_RESETTIME
    end
end

local function syncanim(inst, animname, loop)
    inst.AnimState:PlayAnimation(animname, loop)
    inst.base.AnimState:PlayAnimation(animname, loop)
end

local function syncanimpush(inst, animname, loop)
    inst.AnimState:PushAnimation(animname, loop)
    inst.base.AnimState:PushAnimation(animname, loop)
end

local SHARE_TARGET_DISTANCE = TUNING.WATERPLANT.ATTACK_DISTANCE
local SHARE_TARGET_MUSTTAGS = { "_combat", "waterplant" }
local function set_target(inst, target)
    inst.components.combat:SuggestTarget(target)
    inst.components.combat:ShareTarget(target,
        SHARE_TARGET_DISTANCE,
        function(other_entity)
            return not other_entity.components.sleeper:IsAsleep()
        end,
        4,
        SHARE_TARGET_MUSTTAGS
    )
end

local function update_barnacle_layers(inst, pct)
    if pct >= 0.33 then
        inst.base.AnimState:Show("bud1")
    else
        inst.base.AnimState:Hide("bud1")
    end

    if pct >= 0.66 then
        inst.base.AnimState:Show("bud2")
    else
        inst.base.AnimState:Hide("bud2")
    end

    if pct >= 1.00 then
        inst.base.AnimState:Show("bud3")
    else
        inst.base.AnimState:Hide("bud3")
    end
end

local function go_to_stage(inst, new_stage)
    if new_stage == 2 then
        inst._stage = 2

        inst.AnimState:Show("stage2")

        inst.AnimState:Hide("stage3")
    elseif new_stage == 3 then
        inst._stage = 3

        inst.AnimState:Hide("stage2")

        inst.AnimState:Show("stage3")
    end
end

local function revert_to_rock(inst)
    local rock = SpawnPrefab("waterplant_rock")
    rock.Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst.base:Remove()
    inst:Remove()
end

local function on_harvested(inst, picker, picked_amount)
    update_barnacle_layers(inst, 0)

    -- Keep shaveable and harvestable in lockstep
    if inst.components.shaveable ~= nil then
        inst.components.shaveable.prize_count = 0
    end

    if not picker:HasTag("plantkin") then
        inst.components.sleeper:WakeUp()

        set_target(inst, picker)
    end
end

local function on_grown(inst, produce_count)
    update_barnacle_layers(inst, produce_count / inst.components.harvestable.maxproduce)

    inst:PushEvent("barnacle_grown")

    -- Keep shaveable and harvestable in lockstep
    if inst.components.shaveable ~= nil then
        inst.components.shaveable.prize_count = produce_count
    end

    -- Set a new grow time, so we can have some variance
    inst.components.harvestable:SetGrowTime(TUNING.WATERPLANT.GROW_TIME + (math.random() * TUNING.WATERPLANT.GROW_VARIANCE))
end

local function can_shave(inst, shaver, shave_item)
    if inst.components.harvestable:CanBeHarvested() then
        return true
    else
        return false
    end
end

local function on_shaved(inst, shaver, shave_item)
    update_barnacle_layers(inst, 0)

    -- Keep shaveable and harvestable in lockstep
    if inst.components.harvestable ~= nil then
        inst.components.harvestable.produce = 0
        inst.components.harvestable:StartGrowing()
    end

    -- If we're awake, target the shaver. However, if we're asleep, we won't wake up to fight.
    if shaver ~= nil and not inst.components.sleeper:IsAsleep() and not shaver:HasTag("plantkin") then
        set_target(inst, shaver)
    end
end

local function retarget(inst)
    return nil
end

local function keeptarget(inst, target)
    return (target ~= nil and target:IsValid())
            and (target.components.health ~= nil and not target.components.health:IsDead())
            and inst:IsNear(target, TUNING.WATERPLANT.ATTACK_DISTANCE + 4)
end

local function equip_ranged_weapon(inst)
    if inst.components.inventory and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        --[[Non-networked entity]]
        local ranged_weapon = CreateEntity()
        ranged_weapon.persists = false

        ranged_weapon.entity:AddTransform()

        ranged_weapon:AddComponent("weapon")
        ranged_weapon.components.weapon:SetDamage(inst.components.combat.defaultdamage)
        ranged_weapon.components.weapon:SetRange(inst.components.combat.attackrange, inst.components.combat.attackrange + 4)
        ranged_weapon.components.weapon:SetProjectile("waterplant_projectile")

        ranged_weapon:AddComponent("inventoryitem")
        ranged_weapon.components.inventoryitem:SetOnDroppedFn(ranged_weapon.Remove)

        ranged_weapon:AddComponent("equippable")

        inst.components.inventory:Equip(ranged_weapon)
    end
end

local function on_own_fish(inst, fish)
    fish.sg:GoToState("arrive")
end

local function on_attacked(inst, data)
    set_target(inst, data.attacker)
end

local ATTACK_RANGE_DSQ = TUNING.WATERPLANT.ATTACK_DISTANCE * TUNING.WATERPLANT.ATTACK_DISTANCE
local function find_and_attack_nearby_player(inst)
    -- Would just use SuggestTarget, but we can avoid some calculations without...
    if inst.components.combat ~= nil and not inst.components.combat:HasTarget() then
        local px, py, pz = inst.Transform:GetWorldPosition()
        local closest_player_in_range = FindClosestPlayerInRangeSq(px, py, pz, ATTACK_RANGE_DSQ, true)
        if closest_player_in_range ~= nil then
            set_target(inst, closest_player_in_range)
        end
    end
end

local function on_ignited(inst, data)
    -- When a waterplant gets set on fire, it gets upset, and attacks the closest player it can find,
    -- irrelevant of whether they're the actual cause or not.
    find_and_attack_nearby_player(inst)

    inst.components.harvestable:Disable()
end

local function on_burnt(inst)
    local pos = inst:GetPosition()
    if inst.components.harvestable ~= nil and inst.components.harvestable.produce > 0 then
        for p = 1, inst.components.harvestable.produce do
            inst.components.lootdropper:SpawnLootPrefab("barnacle_cooked", pos)
        end
    end

    -- NOTE: don't use RevertToRock here; it removes at the end, and the burnt handler also removes.
    local rock = SpawnPrefab("waterplant_rock")
    rock.Transform:SetPosition(pos:Get())
end

local function on_extinguish(inst)
    inst.components.harvestable:Enable()
end

local function on_frozen(inst)
    inst.components.harvestable:Disable()
end

local function on_unfrozen(inst)
    inst.components.harvestable:Enable()

    -- If we are frozen with a target, we'll drop it.
    -- Since our ally plants continue to attack, it looks silly when we wake up and
    -- have stopped attacking (since we don't actively acquire targets).
    if inst.sg and inst.sg.mem.frozen_withtarget then
        find_and_attack_nearby_player(inst)
    end
end

local function on_collide(inst, data)
    local other_boat_physics = data.other.components.boatphysics
    if other_boat_physics == nil then
        return
    end

    local hit_velocity = math.abs(other_boat_physics:GetVelocity() * data.hit_dot_velocity) / other_boat_physics.max_velocity
    if hit_velocity > TUNING.WATERPLANT.ANGERING_HIT_VELOCITY then
        find_and_attack_nearby_player(inst)
    end
end

local function on_new_combat_target(inst, data)
    inst.components.combat:BlankOutAttacks(math.random() * 4)
end

local function on_dropped_target(inst, data)
    if inst._stage == 3 and (inst.components.freezable == nil or not inst.components.freezable:IsFrozen())
            and (inst.components.health ~= nil and not inst.components.health:IsDead()) then
        inst.sg:GoToState("switch_to_bud")
    end
end

local function spawn_pollen_cloud(inst)
    local pollen = SpawnPrefab("waterplant_pollen_fx")
    pollen.Transform:SetPosition(inst.Transform:GetWorldPosition())
    pollen._source_flower = inst

    inst._can_cloud = false
    inst.components.timer:StartTimer(
        "resetcloud",
        GetRandomWithVariance(inst._pollen_reset_time, TUNING.WATERPLANT.POLLEN_RESETVARIANCE)
    )
end

local function release_all_fish(inst)
    inst.components.childspawner:ReleaseAllChildren()
end

-- To prevent every plant spraying when they wake up in the morning,
-- pause the cloud reset timer while sleeping.
local function go_to_sleep(inst)
    inst.components.timer:PauseTimer("resetcloud")
end

local function on_wakeup(inst)
    inst.components.timer:ResumeTimer("resetcloud")
end

local function on_timer_finished(inst, data)
    if data.name == "equipweapon" then
        equip_ranged_weapon(inst)
    elseif data.name == "resetcloud" then
        inst._can_cloud = true
    end
end

local function on_entity_sleep(inst)
    if not POPULATING then
        inst._can_cloud = false
        inst.components.timer:StopTimer("resetcloud")
    end
end

local function on_entity_wake(inst)
    if not inst._can_cloud then
        inst.components.timer:StartTimer("resetcloud", 0.5 + (math.random() * inst._pollen_reset_time))
    end
end

local function on_save(inst, data)
    data.colour = inst._colour
end

local function on_load(inst, data)
    set_flower_type(inst, data ~= nil and data.colour or nil)
    update_barnacle_layers(inst, inst.components.harvestable.produce / inst.components.harvestable.maxproduce)
end

local PRIZE_PREFAB = "barnacle"
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(2.35)
    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

    inst.MiniMapEntity:SetIcon("barnacle_plant.png")

    inst.Transform:SetSixFaced()

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("seastack")
    inst:AddTag("veggie")
    inst:AddTag("waterplant")       -- So that plants don't try to affect each other

    inst.AnimState:SetBank("barnacle_plant")
    inst.AnimState:SetBuild("barnacle_plant_colour_swaps")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:Hide("stage1")
    inst.AnimState:Hide("bud1")
    inst.AnimState:Hide("bud2")
    inst.AnimState:Hide("bud3")
    inst.AnimState:Hide("vines")
    inst.AnimState:Hide("rock")

    inst.AnimState:Hide("stage3")

    inst.AnimState:SetFinalOffset(1)

    MakeInventoryFloatable(inst, "med", 0.1, {1.1, 0.9, 1.1})
    inst.components.floater.bob_percent = 0
    inst.components.floater.splash = false

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.base = SpawnPrefab("waterplant_base")
    inst.base.entity:SetParent(inst.entity)
    inst.base.Transform:SetPosition(0,0,0)

    -- Stop the plants from idling in unison.
    local random_anim_time = math.random() * inst.AnimState:GetCurrentAnimationLength()
    inst.AnimState:SetTime(random_anim_time)
    inst.base.AnimState:SetTime(random_anim_time)

    inst.highlightchildren = { inst.base }

    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())

    local land_time = (POPULATING and math.random()*5*FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst:AddComponent("sleeper")

    inst:AddComponent("colouradder")
    inst.components.colouradder:AttachChild(inst.base)

    inst:AddComponent("harvestable")
    local grow_time_with_variance = TUNING.WATERPLANT.GROW_TIME + (math.random() * TUNING.WATERPLANT.GROW_VARIANCE)
    inst.components.harvestable:SetUp(PRIZE_PREFAB, TUNING.WATERPLANT.MAX_BARNACLES, grow_time_with_variance, on_harvested, on_grown)
    inst.components.harvestable.produce = TUNING.WATERPLANT.MAX_BARNACLES

    inst:AddComponent("shaveable")
    inst.components.shaveable:SetPrize(PRIZE_PREFAB, TUNING.WATERPLANT.MAX_BARNACLES)
    inst.components.shaveable.can_shave_test = can_shave
    inst.components.shaveable.on_shaved = on_shaved

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.WATERPLANT.DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.WATERPLANT.ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.WATERPLANT.ATTACK_DISTANCE)
    inst.components.combat:SetRetargetFunction(1, retarget)
    inst.components.combat:SetKeepTargetFunction(keeptarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WATERPLANT.HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("waterplant")

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    inst:AddComponent("childspawner")
    inst.components.childspawner:SetRegenPeriod(TUNING.WATERPLANT.FISH_SPAWN.REGEN_PERIOD)
    inst.components.childspawner:SetMaxChildren(TUNING.WATERPLANT.FISH_SPAWN.MAX_CHILDREN)
    inst.components.childspawner.spawnradius = TUNING.WATERPLANT.FISH_SPAWN.SPAWN_RADIUS
    inst.components.childspawner.childname = FISH_SUMMON_TYPE
    inst.components.childspawner.wateronly = true
    inst.components.childspawner:SetOnTakeOwnershipFn(on_own_fish)
    inst.components.childspawner:StartRegen()

    inst:AddComponent("timer")

    MakeMediumBurnable(inst)
    inst.components.burnable.nocharring = true

    MakeMediumPropagator(inst)
    MakeLargeFreezableCharacter(inst)

    inst:ListenForEvent("attacked", on_attacked)
    inst:ListenForEvent("onignite", on_ignited)
    inst:ListenForEvent("onburnt", on_burnt)
    inst:ListenForEvent("onextinguish", on_extinguish)
    inst:ListenForEvent("freeze", on_frozen)
    inst:ListenForEvent("unfreeze", on_unfrozen)
    inst:ListenForEvent("droppedtarget", on_dropped_target)
    inst:ListenForEvent("on_collide", on_collide)
    inst:ListenForEvent("newcombattarget", on_new_combat_target)
    inst:ListenForEvent("pollenlanded", release_all_fish)
    inst:ListenForEvent("gotosleep", go_to_sleep)
    inst:ListenForEvent("onwakeup", on_wakeup)
    inst:ListenForEvent("timerdone", on_timer_finished)

    inst._stage = 2
    inst.GoToStage = go_to_stage
    inst.RevertToRock = revert_to_rock
    inst.UpdateBarnacleLayers = update_barnacle_layers

    inst.PlaySyncAnimation = syncanim
    inst.PushSyncAnimation = syncanimpush

    inst:SetStateGraph("SGwaterplant")
    inst:SetBrain(brain)

    inst.components.timer:StartTimer("equipweapon", math.random() * 2 * FRAMES)

    inst._pollen_reset_time = TUNING.WATERPLANT.POLLEN_RESETTIME
    if not POPULATING then
        set_flower_type(inst)
    end

    inst._can_cloud = false
    inst.components.timer:StartTimer("resetcloud", math.random() * inst._pollen_reset_time)
    inst.SpawnCloud = spawn_pollen_cloud

    inst.OnEntitySleep = on_entity_sleep
    inst.OnEntityWake = on_entity_wake
    inst.OnSave = on_save
    inst.OnLoad = on_load

    return inst
end

local function client_on_base_replicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.prefab == "waterplant" then
        parent.highlightchildren = { inst }
    end
end

local function basefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("barnacle_plant")
    inst.AnimState:SetBuild("barnacle_plant_colour_swaps")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:Hide("stage1")
    inst.AnimState:Hide("stage2")
    inst.AnimState:Hide("stage3")

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        -- To hook up highlightchildren on clients.
        inst.OnEntityReplicated = client_on_base_replicated

        return inst
    end
    MakeLargeFreezableCharacter(inst)

    inst.persists = false

    return inst
end

local function spawnerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    return inst
end

return Prefab("waterplant", fn, assets, prefabs),
        Prefab("waterplant_base", basefn, baseassets),
        Prefab("waterplant_spawner_rough", spawnerfn, assets, prefabs)
