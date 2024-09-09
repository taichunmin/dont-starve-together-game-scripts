require "prefabutil" -- for the MakePlacer function

local rock_avocado_fruit_assets =
{
    Asset("ANIM", "anim/rock_avocado_fruit.zip"),
    Asset("ANIM", "anim/rock_avocado_fruit_build.zip"),
    Asset("INV_IMAGE", "rock_avocado_fruit_rockhard"),
}

local rock_avocado_fruit_ripe_assets =
{
    Asset("ANIM", "anim/rock_avocado_fruit.zip"),
    Asset("ANIM", "anim/rock_avocado_fruit_build.zip"),
    Asset("INV_IMAGE", "rock_avocado_fruit_ripe"),
}

local rock_avocado_fruit_ripe_cooked_assets =
{
    Asset("ANIM", "anim/rock_avocado_fruit.zip"),
    Asset("ANIM", "anim/rock_avocado_fruit_build.zip"),
    Asset("INV_IMAGE", "rock_avocado_fruit_ripe_cooked"),
}

local rock_avocado_fruit_sprout_assets =
{
    Asset("ANIM", "anim/rock_avocado_fruit.zip"),
    Asset("ANIM", "anim/rock_avocado_fruit_build.zip"),
    Asset("INV_IMAGE", "rock_avocado_fruit_sprout"),
}

local rock_avocado_fruit_sprout_sapling_assets =
{
    Asset("ANIM", "anim/rock_avocado_fruit.zip"),
    Asset("ANIM", "anim/rock_avocado_fruit_build.zip"),
    Asset("MINIMAP_IMAGE", "rock_avocado"),
}

local rock_fruit_prefabs = {
    "rocks",
    "rock_avocado_fruit_ripe",
    "rock_avocado_fruit_sprout",
    "rock_avocado_fruit_sprout_sapling",
}

local function on_mine(inst, miner, workleft, workdone)
    local num_fruits_worked = math.clamp(math.ceil(workdone / TUNING.ROCK_FRUIT_MINES), 1, inst.components.stackable:StackSize())

    local loot_data = TUNING.ROCK_FRUIT_LOOT
    if inst.components.stackable:StackSize() > num_fruits_worked then
        inst.AnimState:PlayAnimation("mined")
        inst.AnimState:PushAnimation("idle", false)
    end

    -- Generate a list of prefabs to create first and optimize the loop by having every type here.
    local spawned_prefabs = {
        ["rock_avocado_fruit_ripe"] = 0,
        ["rock_avocado_fruit_sprout"] = 0,
        ["rocks"] = 0,
    }
    local odds_ripe = loot_data.RIPE_CHANCE
    local odds_seed = odds_ripe + loot_data.SEED_CHANCE
    for _ = 1, num_fruits_worked do
        -- Choose a ripeness to spawn.
        local loot_roll = math.random()
        if loot_roll < odds_ripe then
            spawned_prefabs["rock_avocado_fruit_ripe"] = spawned_prefabs["rock_avocado_fruit_ripe"] + 1
        elseif loot_roll < odds_seed then
            spawned_prefabs["rock_avocado_fruit_sprout"] = spawned_prefabs["rock_avocado_fruit_sprout"] + 1
        else
            spawned_prefabs["rocks"] = spawned_prefabs["rocks"] + 1
        end
    end

    -- Then create these prefabs while stacking them up as much as they are able to.
    for prefab, count in pairs(spawned_prefabs) do
        local i = 1
        while i <= count do
            local loot = SpawnPrefab(prefab)
            local room = loot.components.stackable ~= nil and loot.components.stackable:RoomLeft() or 0
            if room > 0 then
                local stacksize = math.min(count - i, room) + 1
                loot.components.stackable:SetStackSize(stacksize)
                i = i + stacksize
            else
                i = i + 1
            end
            LaunchAt(loot, inst, miner, loot_data.SPEED, loot_data.HEIGHT, nil, loot_data.ANGLE)
            if prefab == "rock_avocado_fruit_ripe" then
                loot.AnimState:PlayAnimation("split_open")
                loot.AnimState:PushAnimation("idle_split_open")
            end
        end
    end

    -- Finally, remove the actual stack items we just consumed
    local top_stack_item = inst.components.stackable:Get(num_fruits_worked)
    top_stack_item:Remove()
end

local function OnExplosion_rock_avocado_fruit_full(inst, data)
    local miner = data and data.explosive or nil
    if miner then
        local loot_data = TUNING.ROCK_FRUIT_LOOT
        LaunchAt(inst, inst, miner, loot_data.SPEED, loot_data.HEIGHT, nil, loot_data.ANGLE)
    end
end

local function stack_size_changed(inst, data)
    if data ~= nil and data.stacksize ~= nil and inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(data.stacksize * TUNING.ROCK_FRUIT_MINES)
    end
end

local function rock_avocado_fruit_full()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("rock_avo_fruit_master")
    inst.AnimState:SetBuild("rock_avocado_fruit_build")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "rock"

    inst:AddTag("molebait")

    MakeInventoryPhysics(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("rock_avocado_fruit_rockhard")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.ROCK_FRUIT_MINES * inst.components.stackable.stacksize)
    --inst.components.workable:SetOnFinishCallback(on_mine)
    inst.components.workable:SetOnWorkCallback(on_mine)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 2
    inst:AddComponent("bait")

    -- The amount of work needs to be updated whenever the size of the stack changes
    inst:ListenForEvent("stacksizechange", stack_size_changed)
    -- Explosions knock around these fruits in specific.
    inst:ListenForEvent("explosion", OnExplosion_rock_avocado_fruit_full)

    MakeHauntableLaunch(inst)

    return inst
end

local function rock_avocado_fruit_ripe()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("rock_avo_fruit_master")
    inst.AnimState:SetBuild("rock_avocado_fruit_build")
    inst.AnimState:PlayAnimation("idle_split_open")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    inst:AddTag("molebait")

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "idle_split_open"

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = 0
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("bait")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable.onperishreplacement = "spoiled_food"
    inst.components.perishable:StartPerishing()

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("rock_avocado_fruit_ripe")

    inst:AddComponent("tradable")

    inst:AddComponent("cookable")
    inst.components.cookable.product = "rock_avocado_fruit_ripe_cooked"

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

local function rock_avocado_fruit_ripe_cooked()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("rock_avo_fruit_master")
    inst.AnimState:SetBuild("rock_avocado_fruit_build")
    inst.AnimState:PlayAnimation("cooked")

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "cooked"

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = 0
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_TWO_DAY)
    inst.components.perishable.onperishreplacement = "spoiled_food"
    inst.components.perishable:StartPerishing()

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("rock_avocado_fruit_ripe_cooked")

    inst:AddComponent("tradable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

local function dig_sprout(inst, digger)
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function grow_anim_over(inst)
    -- Spawn a bush where the seed grew, and remove the seed prefab.
    local seedx, seedy, seedz = inst.Transform:GetWorldPosition()
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    inst:Remove()

    local bush = SpawnPrefab("rock_avocado_bush")
    bush.Transform:SetPosition(seedx, seedy, seedz)
end

local function on_grow_timer_done(inst, data)
    if data.name ~= "grow" then
        return
    end

    inst:ListenForEvent("animover", grow_anim_over)
    inst.AnimState:PlayAnimation("seed_growth")
end

local function start_sprout_growing(inst)
    if inst.components.timer ~= nil and not inst.components.timer:TimerExists("grow") then
        inst.components.timer:StartTimer("grow", TUNING.ROCK_FRUIT_SPROUT_GROWTIME)
    end
end

local function stop_sprout_growing(inst)
    if inst.components.timer ~= nil then
        inst.components.timer:StopTimer("grow")
    end
end

local function rock_avocado_fruit_sprout_sapling()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("rock_avo_fruit_master")
    inst.AnimState:SetBuild("rock_avocado_fruit_build")
    inst.AnimState:PlayAnimation("idle_buried_seed")

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --sprout deployspacing/2

    inst:SetPrefabNameOverride("ROCK_AVOCADO_FRUIT_SPROUT")

    inst.MiniMapEntity:SetIcon("rock_avocado.png")

    inst.scrapbook_anim = "idle_buried_seed"
    inst.scrapbook_adddeps = { "rock_avocado_bush" }

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "rock_avocado_fruit_sprout"

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"rock_avocado_fruit_sprout"})

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_sprout)
    inst.components.workable:SetWorkLeft(1)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", on_grow_timer_done)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    inst.components.burnable:SetOnIgniteFn(stop_sprout_growing)
    inst.components.burnable:SetOnExtinguishFn(start_sprout_growing)
    MakeSmallPropagator(inst)

    MakeHauntableIgnite(inst)

    start_sprout_growing(inst)

    return inst
end

local function on_deploy_fn(inst, position)
    inst = inst.components.stackable:Get()
    inst:Remove()

    local sapling = SpawnPrefab("rock_avocado_fruit_sprout_sapling")
    sapling.Transform:SetPosition(position:Get())
    sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
end

local function rock_avocado_fruit_sprout()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("rock_avo_fruit_master")
    inst.AnimState:SetBuild("rock_avocado_fruit_build")
    inst.AnimState:PlayAnimation("idle_seed")

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "small", nil, 0.4)

    inst:AddTag("deployedplant")

    inst.scrapbook_specialinfo = "PLANTABLE"
    inst.scrapbook_anim = "idle_seed"
    inst.scrapbook_adddeps = { "rock_avocado_fruit_sprout_sapling" }

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("rock_avocado_fruit_sprout")

    inst:AddComponent("tradable")

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable.ondeploy = on_deploy_fn

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("rock_avocado_fruit_ripe_cooked", rock_avocado_fruit_ripe_cooked, rock_avocado_fruit_ripe_cooked_assets),
    Prefab("rock_avocado_fruit_ripe", rock_avocado_fruit_ripe, rock_avocado_fruit_ripe_assets, {"rock_avocado_fruit_ripe_cooked"}),
    Prefab("rock_avocado_fruit_sprout", rock_avocado_fruit_sprout, rock_avocado_fruit_sprout_assets),
    MakePlacer("rock_avocado_fruit_sprout_placer", "rock_avo_fruit_master", "rock_avocado_fruit_build", "idle_buried_seed"),
    Prefab("rock_avocado_fruit_sprout_sapling", rock_avocado_fruit_sprout_sapling, rock_avocado_fruit_sprout_sapling_assets),
    Prefab("rock_avocado_fruit", rock_avocado_fruit_full, rock_avocado_fruit_assets, rock_fruit_prefabs)
