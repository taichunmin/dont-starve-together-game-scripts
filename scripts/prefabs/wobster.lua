require "stategraphs/SGwobster"
require "stategraphs/SGwobsterland"

local sheller_assets =
{
    Asset("ANIM", "anim/lobster.zip"),
    Asset("ANIM", "anim/lobster_water.zip"),
    Asset("ANIM", "anim/lobster_sheller.zip"),
    Asset("INV_IMAGE", "wobster_sheller_land"),
}

local moonglass_assets =
{
    Asset("ANIM", "anim/lobster.zip"),
    Asset("ANIM", "anim/lobster_water.zip"),
    Asset("ANIM", "anim/lobster_moonglass.zip"),
    Asset("INV_IMAGE", "wobster_moonglass_land"),
}

local dead_assets =
{
    Asset("ANIM", "anim/lobster.zip"),
    Asset("ANIM", "anim/lobster_sheller.zip"),
    Asset("INV_IMAGE", "wobster_sheller_dead"),
}

local cooked_assets =
{
    Asset("ANIM", "anim/lobster.zip"),
    Asset("ANIM", "anim/lobster_sheller.zip"),
    Asset("INV_IMAGE", "wobster_sheller_dead_cooked"),
}

local ocean_prefabs =
{
    "ocean_splash_small1",
    "wobster_sheller_land",
}

local moonglass_ocean_prefabs =
{
    "ocean_splash_small1",
    "wobster_moonglass_land",
}

local land_prefabs =
{
    "wobster_sheller_dead",
    "wobster_sheller_dead_cooked",
    "wobster_den",
}

local moonglass_land_prefabs =
{
    "moonglass",
    "moonglass_wobster_den",
}

local dead_prefabs =
{
    "spoiled_fish",
    "wobster_sheller_dead_cooked",
}

local cooked_prefabs =
{
    "spoiled_fish",
}

local brain_water = require "brains/wobsterbrain"
local brain_land = require "brains/wobsterlandbrain"

local SWIMMING_COLLISION_MASK   = COLLISION.GROUND
                                + COLLISION.LAND_OCEAN_LIMITS
                                + COLLISION.OBSTACLES
                                + COLLISION.SMALLOBSTACLES
local PROJECTILE_COLLISION_MASK = COLLISION.GROUND

local function on_projectile_landed(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    if TheWorld.Map:IsPassableAtPoint(x, y, z) then
        local wobster = SpawnPrefab(inst.fish_def.prefab.."_land")
        wobster.Transform:SetPosition(x, y, z)
        wobster.Transform:SetRotation(inst.Transform:GetRotation())
        wobster.components.inventoryitem:SetLanded(true, false)

		if inst.components.weighable ~= nil and wobster.components.weighable ~= nil then
			wobster.components.weighable:CopyWeighable(inst.components.weighable)
		end

        inst:Remove()
    else
        inst:RemoveComponent("complexprojectile")

        inst.Physics:SetCollisionMask(SWIMMING_COLLISION_MASK)
        inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
        inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)

        inst.sg:GoToState("idle", "jump_pst")
        inst:RestartBrain()

        SpawnPrefab("splash").Transform:SetPosition(x, y, z)

		if inst.components.weighable ~= nil then
			inst.components.weighable:SetPlayerAsOwner(nil)
		end
    end
end

local function on_make_projectile(inst)
    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnHit(on_projectile_landed)

    inst:StopBrain()
    inst.sg:GoToState("launched_out_of_water")

    inst.Physics:SetCollisionMask(PROJECTILE_COLLISION_MASK)
    inst.AnimState:SetSortOrder(0)
    inst.AnimState:SetLayer(LAYER_WORLD)

    SpawnPrefab("splash").Transform:SetPosition(inst.Transform:GetWorldPosition())

    return inst
end

local function on_reeling_in(inst, doer, angle)
    -- Go from partially hooked to fully hooked
    if inst:HasTag("partiallyhooked") then
        inst:RemoveTag("partiallyhooked")
        inst.components.oceanfishable:ResetStruggling()
    end
end

local function set_on_rod(inst, rod)
    if rod ~= nil then
        inst:AddTag("partiallyhooked")
        inst:AddTag("scarytooceanprey")
    else
        inst:RemoveTag("partiallyhooked")
        inst:RemoveTag("scarytooceanprey")
    end
end

local function 	SetupWeighable(inst)
    inst.components.weighable.type = TROPHYSCALE_TYPES.FISH
    inst.components.weighable:Initialize(inst.fish_def.weight_min, inst.fish_def.weight_max)

	local _weight_scale = math.random()
    inst.components.weighable:SetWeight(Lerp(inst.fish_def.weight_min, inst.fish_def.weight_max, _weight_scale*_weight_scale*_weight_scale))
end

local function base_water_wobster(build_name, fish_def)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:SetCollisionMask(SWIMMING_COLLISION_MASK)
    inst.Physics:SetCapsule(0.5, 1)

    inst:AddTag("ediblefish_meat")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")
    inst:AddTag("oceanfishable")
    inst:AddTag("oceanfishable_creature")
    inst:AddTag("oceanfishinghookable")
    inst:AddTag("swimming")

    inst.AnimState:SetBank("lobster_water")
    inst.AnimState:SetBuild(build_name)
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
    inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)

    inst.scrapbook_proxy = fish_def.prefab.."_land"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.fish_def = fish_def

    inst:AddComponent("weighable")
	SetupWeighable(inst)

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.runspeed = TUNING.WOBSTER.SPEED.SWIM
    inst.components.locomotor.pathcaps = { allowocean = true, ignoreLand = true }

    inst:AddComponent("oceanfishable")
    inst.components.oceanfishable.makeprojectilefn = on_make_projectile
    inst.components.oceanfishable.onreelinginfn = on_reeling_in
    inst.components.oceanfishable.onsetrodfn = set_on_rod
    inst.components.oceanfishable:StrugglingSetup(TUNING.WOBSTER.SPEED.SWIM, TUNING.WOBSTER.SPEED.GROUND, TUNING.WOBSTER.FISHABLE_STAMINA)
    inst.components.oceanfishable.catch_distance = TUNING.OCEAN_FISHING.FISHING_CATCH_DIST

    inst:AddComponent("knownlocations")

    inst:SetStateGraph("SGwobster")
    inst:SetBrain(brain_water)

    return inst
end

local WOBSTER_FISH_DEF =
{
    prefab = "wobster_sheller",
    loot = {"wobster_sheller_dead"},
    lures = TUNING.OCEANFISH_LURE_PREFERENCE.WOBSTER,
    weight_min = 153.67,
    weight_max = 307.34,
}

local function wobster_water()
    return base_water_wobster("lobster_sheller", WOBSTER_FISH_DEF)
end

local MOONGLASS_WOBSTER_FISH_DEF =
{
    prefab = "wobster_moonglass",
    loot = {"moonglass"},
    lures = TUNING.OCEANFISH_LURE_PREFERENCE.WOBSTER,
    weight_min = 112.06,
    weight_max = 224.12,
}

local function moonglass_water()
    local inst = base_water_wobster("lobster_moonglass", MOONGLASS_WOBSTER_FISH_DEF)
    inst:AddTag("lunar_aligned")
    return inst
end

local function play_cooked_sound(inst)
    inst.SoundEmitter:PlaySound(inst._hit_sound)
end

local function on_ground_wobster_landed(inst)
    if inst.components.inventoryitem:IsHeld() then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:IsPassableAtPoint(x, y, z) then
        inst.sg:GoToState("stunned", false)
    else
        local ocean_wobster = SpawnPrefab(inst.fish_def.prefab)
        ocean_wobster.Transform:SetPosition(x, y, z)
        ocean_wobster.Transform:SetRotation(inst.Transform:GetRotation())

        if inst.components.weighable ~= nil and ocean_wobster.components.weighable ~= nil then
            ocean_wobster.components.weighable:CopyWeighable(inst.components.weighable)
            inst.components.weighable:SetPlayerAsOwner(nil)
        end

        SpawnPrefab("splash").Transform:SetPosition(x, y, z)

        inst:Remove()
    end
end

local function on_dropped_as_loot(inst, data)
    if data ~= nil and data.dropped ~= nil then
        inst.components.wighable.prefab_override_owner = data.dropper.prefab
    end
end

local function enter_water(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local ocean_wobster = SpawnPrefab(inst.fish_def.prefab)
    ocean_wobster.Transform:SetPosition(ix, iy, iz)
    ocean_wobster.sg:GoToState("hop_pst")

    if inst.components.weighable ~= nil and ocean_wobster.components.weighable ~= nil then
        ocean_wobster.components.weighable:CopyWeighable(inst.components.weighable)
        inst.components.weighable:SetPlayerAsOwner(nil)
    end

    inst:Remove()
end

local function base_land_wobster(build_name, nameoverride, fish_def, fadeout, cook_product)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local phys = inst.entity:AddPhysics()
    phys:SetMass(1)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.CHARACTERS)
    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    phys:SetCapsule(0.5, 1)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("lobster")
    inst.AnimState:SetBuild(build_name)
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("animal")
    inst:AddTag("canbetrapped")
    inst:AddTag("prey")
    inst:AddTag("smallcreature")
    inst:AddTag("whackable")
	inst:AddTag("smalloceancreature")
    inst:AddTag("stunnedbybomb")

    if cook_product ~= nil then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    --weighable_fish (from weighable component) added to pristine state for optimization
    inst:AddTag("weighable_fish")

    inst:SetPrefabNameOverride(nameoverride)

    MakeSmallPerishableCreaturePristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.fish_def = fish_def

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.WOBSTER.SPEED.GROUND
    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = nameoverride

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true

    inst:AddComponent("murderable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(inst.fish_def.loot)
    inst.components.lootdropper.forcewortoxsouls = true -- NOTES(JBK): Work around the issue that Wobster has a loot dropper component but some times does not drop anything when it dies.

    inst:AddComponent("weighable")
	SetupWeighable(inst)

    if cook_product ~= nil then
        inst:AddComponent("cookable")
        inst.components.cookable.product = cook_product
        inst.components.cookable:SetOnCookedFn(play_cooked_sound)
    end

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    inst:AddComponent("sleeper")

    inst._hit_sound = "hookline_2/creatures/wobster/hit"

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WOBSTER.HEALTH)
    inst.components.health.murdersound = inst._hit_sound
    inst.components.health.nofadeout = not fadeout
    inst._fades_out = fadeout

    inst:AddComponent("combat")

    MakeSmallBurnableCharacter(inst)
    MakeTinyFreezableCharacter(inst)

    MakeHauntableLaunchAndPerish(inst)

    inst:ListenForEvent("on_landed", on_ground_wobster_landed)
    inst:ListenForEvent("on_loot_dropped", on_dropped_as_loot)

    inst._enter_water = enter_water

    inst:SetStateGraph("SGwobsterland")
    inst:SetBrain(brain_land)

    MakeSmallPerishableCreature(inst, TUNING.WOBSTER.SURVIVE_TIME)

    return inst
end

local function wobster_land()
    local inst = base_land_wobster("lobster_sheller", "wobster_sheller", WOBSTER_FISH_DEF, false, "wobster_sheller_dead_cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("halloweenmoonmutable")
    inst.components.halloweenmoonmutable:SetPrefabMutated("wobster_moonglass_land")

    return inst
end

local function moonglass_land()
    local inst = base_land_wobster("lobster_moonglass", "wobster_moonglass", MOONGLASS_WOBSTER_FISH_DEF, true)

    inst:AddTag("lunar_aligned")

    return inst
end

local function lobster_dead_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("lobster")
    inst.AnimState:SetBuild("lobster_sheller")
    inst.AnimState:PlayAnimation("idle_dead")

    MakeInventoryFloatable(inst)

    inst:AddTag("fishmeat")
    inst:AddTag("catfood")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_fish"

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL

    inst:AddComponent("cookable")
    inst.components.cookable.product = "wobster_sheller_dead_cooked"

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    return inst
end

local function lobster_dead_cooked_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst.AnimState:SetBank("lobster")
    inst.AnimState:SetBuild("lobster_sheller")
    inst.AnimState:PlayAnimation("idle_cooked")

    inst:AddTag("fishmeat")
    inst:AddTag("catfood")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_fish"

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    return inst
end

return Prefab("wobster_sheller_land", wobster_land, sheller_assets, land_prefabs),
        Prefab("wobster_moonglass_land", moonglass_land, moonglass_assets, moonglass_land_prefabs),
        Prefab("wobster_sheller", wobster_water, sheller_assets, ocean_prefabs),
        Prefab("wobster_moonglass", moonglass_water, moonglass_assets, moonglass_ocean_prefabs),
        Prefab("wobster_sheller_dead", lobster_dead_fn, dead_assets, dead_prefabs),
        Prefab("wobster_sheller_dead_cooked", lobster_dead_cooked_fn, cooked_assets, cooked_prefabs)
