require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/mushroom_farm.zip"),
    Asset("ANIM", "anim/mushroom_farm_red_build.zip"),
    Asset("ANIM", "anim/mushroom_farm_green_build.zip"),
    Asset("ANIM", "anim/mushroom_farm_blue_build.zip"),
    Asset("ANIM", "anim/mushroom_farm_moon_build.zip"),
}

local prefabs =
{
    "red_cap",
    "green_cap",
    "blue_cap",
    "moon_cap",
    "collapse_small",
    "spore_tall",
    "spore_medium",
    "spore_small",
}

local levels =
{
    { amount=6, grow="mushroom_4", idle="mushroom_4_idle", hit="hit_mushroom_4" },  -- this can only be reached by starting with spores
    { amount=4, grow="mushroom_3", idle="mushroom_3_idle", hit="hit_mushroom_3" },  -- max for starting with mushrooms
    { amount=2, grow="mushroom_2", idle="mushroom_2_idle", hit="hit_mushroom_2" },
    { amount=1, grow="mushroom_1", idle="mushroom_1_idle", hit="hit_mushroom_1" },
    { amount=0, idle="idle", hit="hit_idle" },
}

local spore_to_cap =
{
    spore_tall = "blue_cap",
    spore_medium = "red_cap",
    spore_small = "green_cap",
}

local FULLY_REPAIRED_WORKLEFT = 3

local function DoMushroomOverrideSymbol(inst, product)
    inst.AnimState:OverrideSymbol("swap_mushroom", "mushroom_farm_"..(string.split(product, "_")[1]).."_build", "swap_mushroom")
end

local function StartGrowing(inst, giver, product)
    if inst.components.harvestable ~= nil then
        local is_spore = product:HasTag("spore")

        local grower_skilltreeupdater = giver.components.skilltreeupdater
        local planter_is_improved = (grower_skilltreeupdater and grower_skilltreeupdater:IsActivated("wormwood_mushroomplanter_upgrade"))

        local max_produce = ((is_spore or planter_is_improved) and levels[1].amount) or levels[2].amount
        local productname = (is_spore and spore_to_cap[product.prefab]) or product.prefab

        local grow_time_percent = 1.0

        if grower_skilltreeupdater ~= nil then
            if grower_skilltreeupdater:IsActivated("wormwood_mushroomplanter_ratebonus2") then
                grow_time_percent = TUNING.WORMWOOD_MUSHROOMPLANTER_RATEBONUS_2
            elseif grower_skilltreeupdater:IsActivated("wormwood_mushroomplanter_ratebonus1") then
                grow_time_percent = TUNING.WORMWOOD_MUSHROOMPLANTER_RATEBONUS_1
            end
        end

        local grow_time = grow_time_percent * TUNING.MUSHROOMFARM_FULL_GROW_TIME

        DoMushroomOverrideSymbol(inst, productname)

        inst.components.harvestable:SetProduct(productname, max_produce)
        inst.components.harvestable:SetGrowTime(grow_time / max_produce)
        inst.components.harvestable:Grow()

        TheWorld:PushEvent("itemplanted", { doer = giver, pos = inst:GetPosition() }) --this event is pushed in other places too
    end
end

local function setlevel(inst, level, dotransition)
    if not inst:HasTag("burnt") then
        if inst.anims == nil then
            inst.anims = {}
        end
        if inst.anims.idle == level.idle then
            dotransition = false
        end

        inst.anims.idle = level.idle
        inst.anims.hit = level.hit

        if inst.remainingharvests == 0 then
            inst.anims.idle = "expired"
            inst.components.trader:Enable()
            inst.components.harvestable:SetGrowTime(nil)
            inst.components.workable:SetWorkLeft(1)
        elseif TheWorld.state.issnowcovered then
            inst.components.trader:Disable()
        elseif inst.components.harvestable:CanBeHarvested() then
            inst.components.trader:Disable()
        else
            inst.components.trader:Enable()
            inst.components.harvestable:SetGrowTime(nil)
        end

        if dotransition then
            inst.AnimState:PlayAnimation(level.grow)
            inst.AnimState:PushAnimation(inst.anims.idle, false)
            inst.SoundEmitter:PlaySound(level ~= levels[1] and "dontstarve/common/together/mushroomfarm/grow" or "dontstarve/common/together/mushroomfarm/spore_grow")
        else
            inst.AnimState:PlayAnimation(inst.anims.idle)
        end

    end
end

local function updatelevel(inst, dotransition)
    if not inst:HasTag("burnt") then
        if TheWorld.state.issnowcovered then
            if inst.components.harvestable:CanBeHarvested() then
                for i= 1,inst.components.harvestable.produce do
                    inst.components.lootdropper:SpawnLootPrefab("spoiled_food")
                end

                inst.components.harvestable.produce = 0
                inst.components.harvestable:StopGrowing()
                inst.remainingharvests = inst.remainingharvests - 1
            end
        end

        for k, v in pairs(levels) do
            if inst.components.harvestable.produce >= v.amount then
                setlevel(inst, v, dotransition)
                break
            end
        end
    end
end

local function onharvest(inst, picker)
    if not inst:HasTag("burnt") then
        inst.remainingharvests = inst.remainingharvests - 1
        updatelevel(inst)
    end
end

local function ongrow(inst, produce)
    updatelevel(inst, true)

    -- if started with spores, there is a chance it will release one spore when it hits max level.
    if produce == levels[1].amount then
        if math.random() <= TUNING.MUSHROOMFARM_SPAWN_SPORE_CHANCE then
            for k,v in pairs(spore_to_cap) do
                if v == inst.components.harvestable.product then
                    inst.components.lootdropper:SpawnLootPrefab(k)
                    break
                end
            end
        end
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle, false)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/mushroomfarm/craft")
end

local function getstatus(inst)
    if inst.components.harvestable == nil then
        return nil
    end

    return inst.remainingharvests == 0 and "ROTTEN"
			or TheWorld.state.issnowcovered and "SNOWCOVERED"
            or inst.components.harvestable.produce == levels[1].amount and "STUFFED"
            or inst.components.harvestable.produce == levels[2].amount and "LOTS"
            or inst.components.harvestable:CanBeHarvested() and "SOME"
            or "EMPTY"
end

local function lootsetfn(lootdropper)
    local inst = lootdropper.inst

    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) or (not inst.components.harvestable:CanBeHarvested()) then
        return
    end

    local loot = {}
    for i= 1,inst.components.harvestable.produce do
        table.insert(loot, inst.components.harvestable.product)
    end
    lootdropper:SetLoot(loot)
end

local function onburnt(inst)
    DefaultBurntStructureFn(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end
end

local function onignite(inst)
    DefaultBurnFn(inst)
    if inst.components.harvestable ~= nil then
        if inst.components.harvestable:CanBeHarvested() then
            for i= 1,inst.components.harvestable.produce do
                inst.components.lootdropper:SpawnLootPrefab("ash")
            end
        end

        inst.components.harvestable.produce = 0
        inst.components.harvestable:StopGrowing()
        updatelevel(inst)
    end

    if inst.components.trader ~= nil then
        inst.components.trader:Disable()
    end
end

local function onextinguish(inst)
    DefaultExtinguishFn(inst)
    updatelevel(inst)
end

local function accepttest(inst, item, giver)
    if item == nil then
        return false
    elseif inst.remainingharvests == 0 then
        if item.prefab == "livinglog" then -- only livinglog for now because that is the recipe
            return true
        end
        return false, "MUSHROOMFARM_NEEDSLOG"
    elseif not (item:HasTag("mushroom") or item:HasTag("spore")) then
        return false, "MUSHROOMFARM_NEEDSSHROOM"
    elseif item:HasTag("moonmushroom") then
        local grower_skilltreeupdater = giver.components.skilltreeupdater
        if grower_skilltreeupdater and grower_skilltreeupdater:IsActivated("wormwood_moon_cap_eating") then
            return true
        else
            return false, "MUSHROOMFARM_NOMOONALLOWED"
        end
    else
        return true
    end
end

local function onacceptitem(inst, giver, item)
    if inst.remainingharvests == 0 then
        inst.remainingharvests = TUNING.MUSHROOMFARM_MAX_HARVESTS
        inst.components.workable:SetWorkLeft(FULLY_REPAIRED_WORKLEFT)
        updatelevel(inst)
    else
        StartGrowing(inst, giver, item)
    end
end

local function onsnowcoveredchagned(inst, covered)
    if inst.components.harvestable ~= nil then
        updatelevel(inst)
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    elseif inst.components.harvestable ~= nil then
        data.growtime = inst.components.harvestable.growtime
        data.product = inst.components.harvestable.product
        data.maxproduce = inst.components.harvestable.maxproduce
        data.remainingharvests = inst.remainingharvests
    end
end


local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        else
            inst.components.harvestable.growtime = data.growtime
            inst.components.harvestable.product = data.product
            inst.components.harvestable.maxproduce = data.maxproduce

            inst.remainingharvests = data.remainingharvests or 0

            if inst.components.harvestable.product ~= nil then
                DoMushroomOverrideSymbol(inst, inst.components.harvestable.product)
            end

            updatelevel(inst)
        end
    end
end

local function domagicgrowth(inst, doer)
    if inst.components.harvestable:Grow() then
        inst.components.harvestable:Disable()
        inst.components.trader:Disable()

        inst:DoTaskInTime(0.5, domagicgrowth)
    else
        inst.components.harvestable:Enable()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("mushroom_farm.png")

    inst.AnimState:SetBank("mushroom_farm")
    inst.AnimState:SetBuild("mushroom_farm")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("playerowned")
    inst:AddTag("mushroom_farm")

    --trader, alltrader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")
    inst:AddTag("alltrader")

    MakeSnowCoveredPristine(inst)

    inst.scrapbook_specialinfo = "MUSHROOMFARM"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------
    inst:AddComponent("harvestable")
    inst.components.harvestable:SetOnGrowFn(ongrow)
    inst.components.harvestable:SetOnHarvestFn(onharvest)
    inst.components.harvestable:SetDoMagicGrowthFn(domagicgrowth)
    -------------------

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(accepttest)
    inst.components.trader.onaccept = onacceptitem
    inst.components.trader.acceptnontradable = true

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(lootsetfn)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(FULLY_REPAIRED_WORKLEFT)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:WatchWorldState("issnowcovered", onsnowcoveredchagned)

    MakeHauntableWork(inst)

    MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)
    inst.components.burnable:SetOnBurntFn(onburnt)
    inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnExtinguishFn(onextinguish)

    inst.remainingharvests = TUNING.MUSHROOMFARM_MAX_HARVESTS

    inst.OnSave = onsave
    inst.OnLoad = onload

    updatelevel(inst)

    return inst
end

return Prefab("mushroom_farm", fn, assets, prefabs),
    MakePlacer("mushroom_farm_placer", "mushroom_farm", "mushroom_farm", "idle")
