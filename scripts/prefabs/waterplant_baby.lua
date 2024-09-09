local assets =
{
    Asset("ANIM", "anim/barnacle_plant.zip"),
    Asset("ANIM", "anim/barnacle_plant_colour_swaps.zip"),
    Asset("MINIMAP_IMAGE", "barnacle_plant"),
}

local prefabs =
{
    "barnacle",
    "barnacle_cooked",
    "waterplant",
    "waterplant_rock",
}

local function hide_barnacles(inst)
    inst.AnimState:Hide("bud1")
    inst.AnimState:Hide("bud2")
    inst.AnimState:Hide("bud3")
end

local function update_layers(inst, pct)
    if pct == 0 then
        hide_barnacles(inst)
    else
        if pct >= 0.33 then
            inst.AnimState:Show("bud1")
        end

        if pct >= 0.66 then
            inst.AnimState:Show("bud2")
        end

        if pct >= 1.00 then
            inst.AnimState:Show("bud3")
        end
    end
end

local function finish_full_grow(inst)
    local grown_plant = SpawnPrefab("waterplant")
    grown_plant.Transform:SetPosition(inst.Transform:GetWorldPosition())

    -- It's hard to legitimately harvest in the span of the growth animation, but I did it one time, so...
    if inst.components.harvestable ~= nil and inst.components.harvestable.produce < TUNING.WATERPLANT.MAX_BARNACLES then
        grown_plant.components.shaveable.prize_count = inst.components.harvestable.produce
        grown_plant.components.harvestable.produce = inst.components.harvestable.produce
        grown_plant.components.harvestable:StartGrowing()
        if grown_plant.UpdateBarnacleLayers ~= nil then
            grown_plant:UpdateBarnacleLayers(inst.components.harvestable.produce / TUNING.WATERPLANT.MAX_BARNACLES)
        end
    end

    inst:Remove()
end

local function do_full_grow(inst)
    inst:DoTaskInTime(16*FRAMES, finish_full_grow)
    inst.AnimState:PlayAnimation("growth1")
    inst.AnimState:Show("stage2")
    inst.AnimState:Show("top_bud")
end

local function try_full_grow(inst)
    if inst.components.harvestable == nil or inst.components.harvestable.produce < TUNING.WATERPLANT.MAX_BARNACLES then
        inst._grow_task:Cancel()
        inst._grow_task = nil
    else
        do_full_grow(inst)
    end
end

local function on_full_moon(inst)
    if inst.components.harvestable ~= nil and inst.components.harvestable.produce == inst.components.harvestable.maxproduce then
        -- Do a random delay so they all don't transform at the same time.
        if inst._grow_task == nil then
            inst._grow_task = inst:DoTaskInTime(math.random()*2 + 2, try_full_grow)
        end
    end
end

local function on_harvested(inst, picker, produce)
    update_layers(inst, 0)

    -- Keep shaveable and harvestable in lockstep
    if inst.components.shaveable ~= nil then
        inst.components.shaveable.prize_count = 0
    end
end

local function on_grow(inst, produce)
    update_layers(inst, produce / TUNING.WATERPLANT.MAX_BARNACLES)

    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle2", true)

    -- Keep shaveable and harvestable in lockstep
    if inst.components.shaveable ~= nil then
        inst.components.shaveable.prize_count = produce
    end

    if TheWorld.state.isfullmoon and produce == inst.components.harvestable.maxproduce then
        -- Do a random delay so they all don't transform at the same time.
        if inst._grow_task == nil then
            inst._grow_task = inst:DoTaskInTime(math.random()*2 + 2, try_full_grow)
        end
    end
end

local function can_shave(inst, shaver, shave_item)
    if inst.components.harvestable:CanBeHarvested() then
        return true
    else
        return false
    end
end

local function on_shaved(inst, shaver, shave_item)
    update_layers(inst, 0)

    -- Keep shaveable and harvestable in lockstep
    if inst.components.harvestable ~= nil then
        inst.components.harvestable.produce = 0
        inst.components.harvestable:StartGrowing()
    end
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

local function on_save(inst, data)
    if inst._rebirth_finish_time ~= nil then
        data.rebirth_time = inst._rebirth_finish_time - GetTime()
    elseif inst._grow_task ~= nil then
        data.grow_on_load = true
    end
end

local function on_load(inst, data)
    if data ~= nil then
        if data.rebirth_time ~= nil and inst._rebirth_task == nil then
            inst:WaitForRebirth(data.rebirth_time)
        elseif data.grow_on_load and inst._grow_task == nil then
            inst._grow_task = inst:DoTaskInTime(math.random()*2 + 2, try_full_grow)
        end
    end

    update_layers(inst, inst.components.harvestable.produce / TUNING.WATERPLANT.MAX_BARNACLES)
end

local function do_rebirth(inst)
    inst.AnimState:Show("stage1")
    inst.AnimState:PlayAnimation("rebirth")
    inst.AnimState:PushAnimation("idle2", true)

    inst.components.harvestable:StartGrowing()

    inst._rebirth_finish_time = nil
end

local function wait_for_rebirth(inst, rebirth_time)
    hide_barnacles(inst)

    inst.components.harvestable:StopGrowing()
    inst.components.harvestable.produce = 0

    inst.AnimState:Hide("stage1")

    rebirth_time = rebirth_time or TUNING.WATERPLANT.REBIRTH_TIME

    inst:DoTaskInTime(rebirth_time, do_rebirth)
    inst._rebirth_finish_time = GetTime() + rebirth_time
end

local PRIZE_PREFAB = "barnacle"
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()

    inst:SetPhysicsRadiusOverride(2.35)
    MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)

    inst.MiniMapEntity:SetIcon("barnacle_plant.png")

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("seastack")
    inst:AddTag("waterplant")

    inst.AnimState:SetBank("barnacle_plant")
    inst.AnimState:SetBuild("barnacle_plant_colour_swaps")
    inst.AnimState:PlayAnimation("idle2", true)

    hide_barnacles(inst)

    inst.AnimState:Hide("stage2")

    inst.AnimState:Hide("stage3")

    MakeInventoryFloatable(inst, "med", 0.1, {1.1, 0.9, 1.1})
    inst.components.floater:SetIsObstacle()
    inst.components.floater.bob_percent = 0
    inst.components.floater.splash = false

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    local land_time = (POPULATING and math.random()*5*FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst:AddComponent("harvestable")
    inst.components.harvestable:SetUp(PRIZE_PREFAB, TUNING.WATERPLANT.MAX_BARNACLES, TUNING.WATERPLANT.GROW_TIME, on_harvested, on_grow)

    inst:AddComponent("shaveable")
    inst.components.shaveable:SetPrize(PRIZE_PREFAB, TUNING.WATERPLANT.MAX_BARNACLES)
    inst.components.shaveable.can_shave_test = can_shave
    inst.components.shaveable.on_shaved = on_shaved

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    MakeMediumBurnable(inst)
    MakeMediumPropagator(inst)

    MakeSnowCovered(inst)

    inst:ListenForEvent("onburnt", on_burnt)

    inst:WatchWorldState("isfullmoon", on_full_moon)

    inst.OnSave = on_save
    inst.OnLoad = on_load
    inst.WaitForRebirth = wait_for_rebirth
    inst._DoFullGrow = do_full_grow -- exposed for debug & development purposes

    return inst
end

return Prefab("waterplant_baby", fn, assets, prefabs)
