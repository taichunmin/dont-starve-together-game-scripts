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
    local num_fruits_worked = math.clamp(workdone / TUNING.ROCK_FRUIT_MINES, 1, TUNING.ROCK_FRUIT_LOOT.MAX_SPAWNS)
    num_fruits_worked = math.min(num_fruits_worked, inst.components.stackable:StackSize())

    if inst.components.stackable:StackSize() > num_fruits_worked then
        inst.AnimState:PlayAnimation("mined")
        inst.AnimState:PushAnimation("idle", false)

        if num_fruits_worked == TUNING.ROCK_FRUIT_LOOT.MAX_SPAWNS then
            -- If we got hit hard, also launch the remaining fruit stack.
            LaunchAt(inst, inst, miner, TUNING.ROCK_FRUIT_LOOT.SPEED, TUNING.ROCK_FRUIT_LOOT.HEIGHT, nil, TUNING.ROCK_FRUIT_LOOT.ANGLE)
        end
    end

    for _ = 1, num_fruits_worked do
        -- Choose a ripeness to spawn.
        local loot_roll = math.random()
        if loot_roll < TUNING.ROCK_FRUIT_LOOT.RIPE_CHANCE then
            local loot = SpawnPrefab("rock_avocado_fruit_ripe")
            LaunchAt(loot, inst, miner, TUNING.ROCK_FRUIT_LOOT.SPEED, TUNING.ROCK_FRUIT_LOOT.HEIGHT, nil, TUNING.ROCK_FRUIT_LOOT.ANGLE)
            if loot ~= nil then
                loot.AnimState:PlayAnimation("split_open")
                loot.AnimState:PushAnimation("idle_split_open")
            end
        elseif loot_roll < (TUNING.ROCK_FRUIT_LOOT.RIPE_CHANCE + TUNING.ROCK_FRUIT_LOOT.SEED_CHANCE) then
            LaunchAt(SpawnPrefab("rock_avocado_fruit_sprout"), inst, miner, TUNING.ROCK_FRUIT_LOOT.SPEED, TUNING.ROCK_FRUIT_LOOT.HEIGHT, nil, TUNING.ROCK_FRUIT_LOOT.ANGLE)
        else
            LaunchAt(SpawnPrefab("rocks"), inst, miner, TUNING.ROCK_FRUIT_LOOT.SPEED, TUNING.ROCK_FRUIT_LOOT.HEIGHT, nil, TUNING.ROCK_FRUIT_LOOT.ANGLE)
        end
    end

    -- Finally, remove the actual stack items we just consumed
    local top_stack_item = inst.components.stackable:Get(num_fruits_worked)
    top_stack_item:Remove()
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

    inst:SetPrefabNameOverride("ROCK_AVOCADO_FRUIT_SPROUT")

    inst.MiniMapEntity:SetIcon("rock_avocado.png")

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
