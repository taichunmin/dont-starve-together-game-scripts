local assets =
{
    Asset("ANIM", "anim/meat.zip"),
    Asset("ANIM", "anim/meat_monster.zip"),
    Asset("ANIM", "anim/meat_small.zip"),
    Asset("ANIM", "anim/meat_human.zip"),
    Asset("ANIM", "anim/drumstick.zip"),
    Asset("ANIM", "anim/fishmeat.zip"),
    Asset("ANIM", "anim/fishmeat_small.zip"),
    Asset("ANIM", "anim/meat_rack_food.zip"),
    Asset("ANIM", "anim/meat_rack_food_tot.zip"),
    Asset("ANIM", "anim/batwing.zip"),
    Asset("ANIM", "anim/plant_meat.zip"),
    Asset("ANIM", "anim/barnacle.zip"),
}

local quagmire_assets =
{
    Asset("ANIM", "anim/quagmire_meat_small.zip"),
}

local batnose_assets =
{
    Asset("ANIM", "anim/batnose.zip"),
}

local prefabs =
{
    "cookedmeat",
    "meat_dried",
    "spoiled_food",
}

local smallprefabs =
{
    "cookedsmallmeat",
    "smallmeat_dried",
    "spoiled_food",
}

local monsterprefabs =
{
    "cookedmonstermeat",
    "monstermeat_dried",
    "spoiled_food",
}

local humanprefabs =
{
    "humanmeat_cooked",
    "humanmeat_dried",
    "spoiled_food",
}

local drumstickprefabs =
{
    "drumstick_cooked",
    "spoiled_food",
}

local fishmeat_smallprefabs =
{
    "fishmeat_small_cooked",
    "meat_dried",
    "spoiled_fish_small",
}

local fishmeat_prefabs =
{
    "fishmeat_cooked",
    "meat_dried",
    "spoiled_fish",
}

local batwingprefabs =
{
    "batwing_cooked",
    "meat_dried",
    "spoiled_food",
}

local plantmeatprefabs =
{
    "plantmeat_cooked",
    "spoiled_food",
}

local quagmire_prefabs =
{
    "quagmire_cookedsmallmeat",
}

local function AddMonsterMeatChange(inst, prefab)
    AddHauntableCustomReaction(inst, function(inst, haunter)
        if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
            local x, y, z = inst.Transform:GetWorldPosition()
            SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
            local new = SpawnPrefab(prefab)
            if new ~= nil then
                new.Transform:SetPosition(x, y, z)
                if new.components.stackable ~= nil and inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
                    new.components.stackable:SetStackSize(inst.components.stackable:StackSize())
                end
                if new.components.inventoryitem ~= nil and inst.components.inventoryitem ~= nil then
                    new.components.inventoryitem:InheritMoisture(inst.components.inventoryitem:GetMoisture(), inst.components.inventoryitem:IsWet())
                end
                if new.components.perishable ~= nil and inst.components.perishable ~= nil then
                    new.components.perishable:SetPercent(inst.components.perishable:GetPercent())
                end
                new:PushEvent("spawnedfromhaunt", { haunter = haunter, oldPrefab = inst })
                inst:PushEvent("despawnedfromhaunt", { haunter = haunter, newPrefab = new })
                inst.persists = false
                inst.entity:Hide()
                inst:DoTaskInTime(0, inst.Remove)
            end
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
            return true
        end
        return false
    end, false, true, false)
end

local function OnSpawnedFromHaunt(inst, data)
    Launch(inst, data.haunter, TUNING.LAUNCH_SPEED_SMALL)
end

local function common(bank, build, anim, tags, dryable, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim)
    inst.scrapbook_anim = anim

    --inst.pickupsound = "squidgy"

    inst:AddTag("meat")
    if tags ~= nil then
        for i, v in ipairs(tags) do
            inst:AddTag(v)
        end
    end

    if dryable ~= nil then
        --dryable (from dryable component) added to pristine state for optimization
        inst:AddTag("dryable")
        inst:AddTag("lureplant_bait")
    end

    if cookable ~= nil then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT

    inst:AddComponent("bait")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    if dryable ~= nil and dryable.product ~= nil then
        inst:AddComponent("dryable")
        inst.components.dryable:SetProduct(dryable.product)
        inst.components.dryable:SetDryTime(dryable.time)
		inst.components.dryable:SetBuildFile(dryable.build)
        inst.components.dryable:SetDriedBuildFile(dryable.dried_build)
    end

    if cookable ~= nil then
        inst:AddComponent("cookable")
        inst.components.cookable.product = cookable.product
    end

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/meats").master_postinit(inst, cookable)
    end

    MakeHauntableLaunchAndPerish(inst)
    inst:ListenForEvent("spawnedfromhaunt", OnSpawnedFromHaunt)

    return inst
end

local function humanmeat()
    --selfstacker (from selfstacker component) added to pristine state for optimization
    local inst = common("meat_human", "meat_human", "raw", {"selfstacker"}, { product = "humanmeat_dried", time = TUNING.DRY_FAST }, { product = "humanmeat_cooked" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = -TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_LARGE
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst.components.tradable.goldvalue = 0

    inst.components.floater:SetVerticalOffset(0.1)

    inst:AddComponent("selfstacker")

    return inst
end

local function humanmeat_cooked()
    local inst = common("meat_human", "meat_human", "cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.tradable.goldvalue = 0

    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_LARGE

    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)

    inst.components.floater:SetVerticalOffset(0.1)

    return inst
end

local function humanmeat_dried()
    local inst = common("meat_rack_food", "meat_rack_food", "idle_dried_human")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_MED

    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)

    return inst
end

local function monster()
    --selfstacker (from selfstacker component) added to pristine state for optimization
    local inst = common("monstermeat", "meat_monster", "idle", { "monstermeat", "selfstacker" }, { product = "monstermeat_dried", time = TUNING.DRY_FAST }, { product = "cookedmonstermeat" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.secondaryfoodtype = FOODTYPE.MONSTER
    inst.components.edible.healthvalue = -TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_MED
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst.components.tradable.goldvalue = 0

    inst.components.floater:SetVerticalOffset(0.05)

    inst:AddComponent("selfstacker")

    return inst
end


local function cookedmonster()
    local inst = common("monstermeat", "meat_monster", "cooked", { "monstermeat" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.tradable.goldvalue = 0

    inst.components.edible.secondaryfoodtype = FOODTYPE.MONSTER
    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)

    inst.components.floater:SetVerticalOffset(0.05)

    return inst
end

local function driedmonster()
    local inst = common("meat_rack_food", "meat_rack_food", "idle_dried_monster", { "monstermeat" }, { isdried = true })
    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.secondaryfoodtype = FOODTYPE.MONSTER
    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_TINY

    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)

    return inst
end

local function cooked()
    local inst = common("meat", "meat", "cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
    inst.components.edible.sanityvalue = 0
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    inst.components.floater:SetVerticalOffset(0.05)

    AddMonsterMeatChange(inst, "cookedmonstermeat")

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/meats").master_postinit_cooked(inst)
    end

    return inst
end

local function driedmeat()
    local inst = common("meat_rack_food", "meat_rack_food", "idle_dried_large", nil, { isdried = true })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
    inst.components.edible.sanityvalue = TUNING.SANITY_MED
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)

    AddMonsterMeatChange(inst, "monstermeat_dried")

    return inst
end

local function raw()
    local inst = common("meat", "meat", "raw", { "catfood", "rawmeat" }, { product = "meat_dried", time = TUNING.DRY_MED }, { product = "cookedmeat" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst.components.floater:SetVerticalOffset(0.05)

    AddMonsterMeatChange(inst, "monstermeat")

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/meats").master_postinit_raw(inst)
    end

    return inst
end

local function smallmeat()
    local inst = common("meat_small", "meat_small", "raw", { "catfood", "rawmeat" }, { product = "smallmeat_dried", time = TUNING.DRY_FAST }, { product = "cookedsmallmeat" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst.components.floater:SetScale(0.9)

    return inst
end

local function cookedsmallmeat()
    local inst = common("meat_small", "meat_small", "cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = 0

    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst.components.floater:SetScale(0.9)

    return inst
end

local function driedsmallmeat()
	local inst = common("meat_rack_food", "meat_rack_food", "idle_dried_small", nil, { isdried = true })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = TUNING.SANITY_SMALL

    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)

	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    return inst
end

local function drumstick()
	local inst = common("drumstick", "drumstick", "raw", { "drumstick", "catfood", "rawmeat" }, { product = "smallmeat_dried", time = TUNING.DRY_FAST }, { product = "drumstick_cooked" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst.components.floater:SetVerticalOffset(0.2)

    return inst
end

local function drumstick_cooked()
	local inst = common("drumstick", "drumstick", "cooked", { "drumstick" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    inst.components.floater:SetVerticalOffset(0.15)
    inst.components.floater:SetScale(0.85)

    return inst
end

local function fishmeat_small()
	local inst = common("fishmeat_small", "fishmeat_small", "raw", { "fishmeat", "catfood" }, { product = "smallmeat_dried", build = "meat_rack_food_tot", dried_build = "meat_rack_food", time = TUNING.DRY_FAST }, { product = "fishmeat_small_cooked" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL

    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable.onperishreplacement = "spoiled_fish_small"

    return inst
end

local function fishmeat_small_cooked()
	local inst = common("fishmeat_small", "fishmeat_small", "cooked", { "fishmeat" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable.onperishreplacement = "spoiled_fish_small"

    inst.components.floater:SetVerticalOffset(0.2)
    inst.components.floater:SetScale(0.75)

    return inst
end

local function fishmeat()
	local inst = common("fishmeat", "fishmeat", "raw", { "fishmeat", "catfood", "rawmeat" }, { product = "meat_dried", build = "meat_rack_food_tot", dried_build = "meat_rack_food", time = TUNING.DRY_FAST }, { product = "fishmeat_cooked" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MED

    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable.onperishreplacement = "spoiled_fish"

    return inst
end

local function fishmeat_cooked()
	local inst = common("fishmeat", "fishmeat", "cooked", { "fishmeat" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MED

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable.onperishreplacement = "spoiled_fish"

    return inst
end

local function batwing()
    local inst = common("batwing", "batwing", "raw", { "batwing", "catfood", "rawmeat" }, { product = "smallmeat_dried", time = TUNING.DRY_MED }, { product = "batwing_cooked" })

    inst.components.floater:SetSize("med")
    inst.components.floater:SetVerticalOffset(0.02)
    inst.components.floater:SetScale(0.8)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    return inst
end

local function batwing_cooked()
    local inst = common("batwing", "batwing", "cooked", { "batwing" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

local function plantmeat()
    local inst = common("plant_meat", "plant_meat", "raw", {"lureplant_bait", "rawmeat"}, nil, { product = "plantmeat_cooked" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    return inst
end

local function plantmeat_cooked()
    local inst = common("plant_meat", "plant_meat", "cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

local function quagmire_smallmeat()
    local inst = common("quagmire_meat_small", "quagmire_meat_small", "raw", { "catfood", "rawmeat" }, nil, { product = "quagmire_cookedsmallmeat" })

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/meats").master_postinit_smallmeat(inst)

    return inst
end

local function quagmire_cookedsmallmeat()
    local inst = common("quagmire_meat_small", "quagmire_meat_small", "cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("quagmire", "prefabs/meats").master_postinit_cookedsmallmeat(inst)

    return inst
end

local function barnacle()
    --selfstacker (from selfstacker component) added to pristine state for optimization
    local inst = common("barnacle", "barnacle", "raw", {"barnacle", "rawmeat", "selfstacker"}, nil, { product = "barnacle_cooked" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_TINY
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst.components.tradable.goldvalue = 0

    inst.components.floater:SetVerticalOffset(0.05)

    inst:AddComponent("selfstacker")

    return inst
end


local function barnacle_cooked()
    local inst = common("barnacle", "barnacle", "cooked", {"barnacle"})

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.tradable.goldvalue = 0
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = 0
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)

    inst.components.floater:SetVerticalOffset(0.05)

    return inst
end

local BATNOSE_TAGS = { "catfood", "rawmeat" }
local BATNOSE_DRYABLE_DATA =
{
    product = "smallmeat_dried",
    time = TUNING.DRY_MED,
    build = "meat_rack_food_tot",
    dried_build = "meat_rack_food",
}
local BATNOSE_COOKABLE_DATA = { product = "batnose_cooked" }
local function batnose()
    local inst = common("batnose", "batnose", "raw", BATNOSE_TAGS, BATNOSE_DRYABLE_DATA, BATNOSE_COOKABLE_DATA)

    inst.components.floater:SetSize("med")
    inst.components.floater:SetScale(0.7)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    return inst
end

local function batnose_cooked()
    local inst = common("batnose", "batnose", "cooked")

    inst.components.floater:SetSize("med")
    inst.components.floater:SetScale(0.7)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

return Prefab("meat", raw, assets, prefabs),
        Prefab("cookedmeat", cooked, assets),
        Prefab("meat_dried", driedmeat, assets),
        Prefab("monstermeat", monster, assets, monsterprefabs),
        Prefab("cookedmonstermeat", cookedmonster, assets),
        Prefab("monstermeat_dried", driedmonster, assets),
        Prefab("smallmeat", smallmeat, assets, smallprefabs),
        Prefab("cookedsmallmeat", cookedsmallmeat, assets),
        Prefab("smallmeat_dried", driedsmallmeat, assets),
        Prefab("drumstick", drumstick, assets, drumstickprefabs),
        Prefab("drumstick_cooked", drumstick_cooked, assets),
        Prefab("batwing", batwing, assets, batwingprefabs),
        Prefab("batwing_cooked", batwing_cooked, assets),
        Prefab("plantmeat", plantmeat, assets, plantmeatprefabs),
        Prefab("plantmeat_cooked", plantmeat_cooked, assets),
        Prefab("fishmeat_small", fishmeat_small, assets, fishmeat_smallprefabs),
        Prefab("fishmeat_small_cooked", fishmeat_small_cooked, assets),
        Prefab("fishmeat", fishmeat, assets, fishmeat_prefabs),
        Prefab("fishmeat_cooked", fishmeat_cooked, assets),
        Prefab("humanmeat", humanmeat, assets, humanprefabs),
        Prefab("humanmeat_cooked", humanmeat_cooked, assets),
        Prefab("humanmeat_dried", humanmeat_dried, assets),
        Prefab("quagmire_smallmeat", quagmire_smallmeat, quagmire_assets, quagmire_prefabs),
        Prefab("quagmire_cookedsmallmeat", quagmire_cookedsmallmeat, quagmire_assets),
        Prefab("barnacle", barnacle, assets),
        Prefab("barnacle_cooked", barnacle_cooked, assets),
        Prefab("batnose", batnose, batnose_assets, batwingprefabs),
        Prefab("batnose_cooked", batnose_cooked, batnose_assets)
