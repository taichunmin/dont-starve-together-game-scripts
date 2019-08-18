local hotspring_assets =
{
    Asset("ANIM", "anim/crater_pool.zip"),
    Asset("MINIMAP_IMAGE", "hotspring"),
}

local hotspring_prefabs =
{
    "bluegem",
    "crater_steam_fx1",
    "crater_steam_fx2",
    "crater_steam_fx3",
    "crater_steam_fx4",
    "slow_steam_fx1",
    "slow_steam_fx2",
    "slow_steam_fx3",
    "slow_steam_fx4",
    "slow_steam_fx5",
    "moonglass",
    "redgem",
}

local function choose_anim_by_level(remaining, low, med, full)
    return (remaining < (TUNING.HOTSPRING_WORK / 3) and low) or (remaining < (TUNING.HOTSPRING_WORK * 2 / 3) and med) or full
end

local function RemoveGlass(inst)
    inst._glassed = false
    inst:RemoveTag("moonglass")
    inst.components.bathbombable:SetCanBeBathBombed(true)

    inst.AnimState:PlayAnimation("refill", false)
    inst.AnimState:PushAnimation("idle", true)
end

local function OnGlassedSpringMineFinished(inst, miner)
    inst.components.lootdropper:DropLoot()
    if math.random() < TUNING.HOTSPRING_GEM_DROP_CHANCE then
        inst.components.lootdropper:SpawnLootPrefab((math.random(2) == 1 and "bluegem") or "redgem")
    end
    RemoveGlass(inst)
end

local function OnGlassSpringMined(inst, miner, mines_remaining, num_mines)
    local glass_idle = choose_anim_by_level(mines_remaining, "glass_low", "glass_med", "glass_full")
    inst.AnimState:PlayAnimation(glass_idle)
end

local function push_special_idle(inst)
    if inst._glassed then
        -- We need to push a size-relevant sparkle, and then also the size-relevant idle.
		inst._glass_sparkle_tick = (inst._glass_sparkle_tick or 0) - 1

		if inst._glass_sparkle_tick < 0 then
			local work_remaining = (inst.components.workable ~= nil and inst.components.workable.workleft) or TUNING.HOTSPRING_WORK
			local sparkle_anim = choose_anim_by_level(work_remaining, "glass_low_sparkle1", "glass_med_sparkle"..math.random(2), "glass_full_sparkle"..math.random(3))
			inst.AnimState:PushAnimation(sparkle_anim, false)

			local idle_anim = choose_anim_by_level(work_remaining, "glass_low", "glass_med", "glass_full")
			inst.AnimState:PushAnimation(idle_anim)

			inst._glass_sparkle_tick = math.random(1, 3)
		end
    elseif inst._bathbombed then
        local steam_anim_index = math.random(4)
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("crater_steam_fx"..steam_anim_index).Transform:SetPosition(x, y, z)
    else
        local steam_anim_index = math.random(5)
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("slow_steam_fx"..steam_anim_index).Transform:SetPosition(x, y, z)
    end
end

local MINED_GLASS_LOOT_TABLE = {"moonglass", "moonglass", "moonglass", "moonglass", "moonglass"}

local function AddGlass(inst, is_loading)
    inst._glassed = true
    inst:AddTag("moonglass")
    inst._bathbombed = false

    inst.Light:Enable(false)

    if is_loading then
        local work_remaining = (inst.components.workable ~= nil and inst.components.workable.workleft) or TUNING.HOTSPRING_WORK
        local glass_idle = choose_anim_by_level(work_remaining, "glass_low", "glass_med", "glass_full")
        inst.AnimState:PlayAnimation(glass_idle)
    else
        inst.AnimState:PlayAnimation("glassify", false)
    end

    inst.components.workable:SetWorkable(true)
end

--------------------------------------------------------------------------

local function GetHeat(inst)
    return (inst._bathbombed and TUNING.HOTSPRING_HEAT.ACTIVE) 
			or (not inst._glassed and TUNING.HOTSPRING_HEAT.PASSIVE)
			or 0
end

--------------------------------------------------------------------------

local function OnFullMoonChanged(inst, isfullmoon)
    if not inst._glassed and inst._bathbombed then
        if isfullmoon then
            -- Since we're essentially starting a new glass stack, reset the work to max.
            inst.components.workable:SetWorkLeft(TUNING.HOTSPRING_WORK)
            AddGlass(inst)
        else
            -- NOTE: This shouldn't be reachable; we should glassify if we're bath bombed during the full moon,
            -- and otherwise the above branch should have been hit. This is to protect against any unforseen edge cases.
            inst.AnimState:PlayAnimation("glow_pst", false)
            inst.AnimState:PushAnimation("idle", true)
            inst.Light:Enable(false)
            inst._bathbombed = false
        end
    end
end

--------------------------------------------------------------------------

local function OnBathBombed(inst, bath_bomb)
    inst.components.bathbombable:SetCanBeBathBombed(false)
    inst.Light:Enable(true)

    inst.AnimState:PlayAnimation("bath_bomb", false)
    inst.AnimState:PushAnimation("glow_pre", false)
    if TheWorld.state.isfullmoon then
        -- Since we're essentially starting a new glass stack, reset the work to max.
        inst.components.workable:SetWorkLeft(TUNING.HOTSPRING_WORK)
        AddGlass(inst)
    else
        -- If we didn't glassify immediately, we should track that we are bathbombed.
        inst._bathbombed = true
        inst.AnimState:PushAnimation("glow_loop", true)
    end
end

--------------------------------------------------------------------------

local function OnSave(inst, data)
    data.glassed = inst._glassed
    data.isbathbombed = inst._bathbombed
    -- NOTE: workable state is also saved in its component.
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.glassed then
            -- NOTE: Workable component is loaded before this.
            -- The behavior of AddGlass produces the intended animations by accessing workable.workleft
            AddGlass(inst, true)
            inst.components.bathbombable:SetCanBeBathBombed(false)
        elseif data.isbathbombed then
            OnBathBombed(inst)
        end
    end
end

--------------------------------------------------------------------------

local function OnSleep(inst)
    if inst._idles_task ~= nil then
        inst._idles_task:Cancel()
        inst._idles_task = nil
    end
end

local function StartIdles(inst)
    inst._idles_task = inst:DoPeriodicTask(TUNING.HOTSPRING_IDLE.BASE, push_special_idle, math.random() * TUNING.HOTSPRING_IDLE.DELAY)
end

local function OnWake(inst)
    if inst._idles_task == nil then
        StartIdles(inst)
    end
end

local function GetStatus(inst)
	return inst._glassed and "GLASS"
			or inst._bathbombed and "BOMBED" 
			or nil
end

--------------------------------------------------------------------------

local function hotspring()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeSmallObstaclePhysics(inst, 1)

    inst.AnimState:SetBuild("crater_pool")
    inst.AnimState:SetBank("crater_pool")
    inst.AnimState:PlayAnimation("idle", true)

    --inst.AnimState:SetLayer(LAYER_BACKGROUND) -- TODO: these should be enabled but then the player will stand on top of the glass, so the glass needs to be seperated out in order for this to work.
    --inst.AnimState:SetSortOrder(2)

    inst.MiniMapEntity:SetIcon("hotspring.png")

    inst:AddTag("watersource")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")

    inst.Light:Enable(false)
    inst.Light:SetRadius(TUNING.HOTSPRING_GLOW.RADIUS)
    inst.Light:SetIntensity(TUNING.HOTSPRING_GLOW.INTENSITY)
    inst.Light:SetFalloff(TUNING.HOTSPRING_GLOW.FALLOFF)
    inst.Light:SetColour(0.1, 1.6, 2)

    inst.no_wet_prefix = true

    inst:SetDeployExtraSpacing(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeat

    -- The hot spring uses full moon changes to trigger calcification.
    inst:WatchWorldState("isfullmoon", OnFullMoonChanged)

    inst:AddComponent("bathbombable")
    inst.components.bathbombable:SetOnBathBombedFn(OnBathBombed)
    inst.components.bathbombable:SetCanBeBathBombed(true)
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetOnFinishCallback(OnGlassedSpringMineFinished)
    inst.components.workable:SetOnWorkCallback(OnGlassSpringMined)
    inst.components.workable:SetWorkLeft(TUNING.HOTSPRING_WORK)
    inst.components.workable:SetWorkable(false)
    inst.components.workable.savestate = true

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(MINED_GLASS_LOOT_TABLE)

    inst._bathbombed = false
    inst._glassed = false

    StartIdles(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.OnEntitySleep = OnSleep
    inst.OnEntityWake = OnWake

    return inst
end

return Prefab("hotspring", hotspring, hotspring_assets, hotspring_prefabs)
