local terraformer_assets =
{
    Asset("ANIM", "anim/groundcrystal_growth.zip"),
}

local terraformer_prefabs =
{
    "lunarrift_terraformer_visual",
    "lunarrift_terraformer_explosion",
}

--------------------------------------------------------------------------------
local TERRAFORM_INDEX_TEMPLATE = "%d %d"
local TILE_RADIUS_PLUS_OVERHANG = (TILE_SCALE / 2) + 1.5

local TERRAFORM_TILE_REMOVE_CANT_TAGS = {"DECOR", "FX", "INLIMBO", "NOCLICK", "structure", "crystal", "intense"}
local TERRAFORM_TILE_REMOVE_ONEOF_TAGS = {"CHOP_workable", "DIG_workable", "MINE_workable", "NPC_workable", "pickable"}
local function _TerraformTile(inst, tx, ty)
    local index = string.format(TERRAFORM_INDEX_TEMPLATE, tx, ty)
    inst._terraform_tasks[index] = nil

    local _world = TheWorld
    local _map = _world.Map
    local current_tile = _map:GetTile(tx, ty)
    if not IsOceanTile(current_tile) and current_tile ~= WORLD_TILES.RIFT_MOON then
        local undertile = _world.components.undertile
        local current_undertile = undertile:GetTileUnderneath(tx, ty)

        _map:SetTile(tx, ty, WORLD_TILES.RIFT_MOON)

        -- farming_manager.lua will clear this if we do it before the SetTile call.
        if undertile then
            -- If the undertile component already has an entry at this location,
            -- we'll just keep that instead of over-writing with the current one.
            -- This plays a bit better with farm plots.
            undertile:SetTileUnderneath(tx, ty, current_undertile or current_tile)
        end

        local tcx, tcy, tcz = _map:GetTileCenterPoint(tx, ty)
        local entities_on_tile = TheSim:FindEntities(tcx, 0, tcz, TILE_RADIUS_PLUS_OVERHANG, nil, TERRAFORM_TILE_REMOVE_CANT_TAGS, TERRAFORM_TILE_REMOVE_ONEOF_TAGS)
        for _, entity_on_tile in ipairs(entities_on_tile) do
            local workable = entity_on_tile.components.workable
            if workable and workable:CanBeWorked() and not (entity_on_tile.sg and entity_on_tile.sg:HasStateTag("busy")) then
                local work_action = workable:GetWorkAction()
                --V2C: nil action for NPC_workable (e.g. campfires)
                if not (work_action == ACTIONS.DIG and (entity_on_tile.components.spawner or entity_on_tile.components.childspawner)) then
                    workable:WorkedBy(inst, 20)
                end
                if entity_on_tile:IsValid() and entity_on_tile:HasTag("stump") then
                    entity_on_tile:Remove()
                end
            else
                local pickable = entity_on_tile.components.pickable
                if pickable then
                    -- NOTES(JBK): This will drop the items at the location of the pickable if it has drops and the groundpounder will knock loose items around when those go.
                    pickable:Pick(_world)
                end
            end
        end
    end
end

local RESET_TILE_REMOVE_CANT_TAGS = {"DECOR", "FX", "NOCLICK"}
local RESET_TILE_REMOVE_ONEOF_TAGS = {"crystal"}
local function _RevertTile(inst, tx, ty)
    local index = string.format(TERRAFORM_INDEX_TEMPLATE, tx, ty)
    inst._terraform_tasks[index] = nil

    -- First, reset the tile.
    local _map = TheWorld.Map
    local undertile = TheWorld.components.undertile
    local old_tile = WORLD_TILES.DIRT
    if undertile then
        old_tile = undertile:GetTileUnderneath(tx, ty) or old_tile
        undertile:ClearTileUnderneath(tx, ty)
    end
    _map:SetTile(tx, ty, old_tile)

    -- Then, find anything related to us on the tile, and clean it up.
    local tcx, tcy, tcz = _map:GetTileCenterPoint(tx, ty)
    local entities_near_resetting_tile = TheSim:FindEntities(tcx, 0, tcz, TILE_RADIUS_PLUS_OVERHANG, nil, RESET_TILE_REMOVE_CANT_TAGS, RESET_TILE_REMOVE_ONEOF_TAGS)
    for _, entity in ipairs(entities_near_resetting_tile) do
        if entity:IsInLimbo() then
            entity:Remove()
        else
            entity.components.lootdropper:SetLoot(nil)
            entity.components.lootdropper:SetChanceLootTable(nil)
            entity.components.workable:Destroy(entity)
        end
    end

    local explosion_cover = SpawnPrefab("lunarrift_terraformer_explosion")
    explosion_cover.Transform:SetPosition(tcx, tcy, tcz)
end

local function terraformer_addtask(inst, tx, ty, time, facing, is_revert)
    local index = string.format(TERRAFORM_INDEX_TEMPLATE, tx, ty)

    local current_task_data = inst._terraform_tasks[index]
    if current_task_data then
        if current_task_data.task then
            current_task_data.task:Cancel()
        end

        if current_task_data.visuals then
            current_task_data.visuals:PushEvent("earlyexit")
        end
    end

    local _map = TheWorld.Map
    local tile = _map:GetTile(tx, ty)
    local tile_is_rift = (tile == WORLD_TILES.RIFT_MOON)
    if (is_revert and tile_is_rift)
            or (not is_revert and not IsOceanTile(tile) and not tile_is_rift) then

        local visuals = nil
        if not is_revert then
            visuals = SpawnPrefab("lunarrift_terraformer_visual")
            visuals.Transform:SetPosition(_map:GetTileCenterPoint(tx, ty))
            visuals:SetAppearTime(time)
            if facing then
                visuals:SetFacing(facing)
            end
        end

        local _TaskFunction = (is_revert and _RevertTile) or _TerraformTile
        inst._terraform_tasks[index] = {
            tx = tx, ty = ty,
            is_revert = is_revert,
            endtime = GetTime() + time,
            facing = facing,
            visuals = visuals,
            task = inst:DoTaskInTime(time, _TaskFunction, tx, ty),
        }
    end
end

local function terraformer_remainingtasktimefortile(inst, tx, ty)
    local tile_data = inst._terraform_tasks[string.format(TERRAFORM_INDEX_TEMPLATE, tx, ty)]
    return (tile_data and (tile_data.endtime - GetTime())) or 0
end

------------------------------------------------------------------

local function terraformer_onparentremoved(inst)
    for _, task_data in pairs(inst._terraform_tasks) do
        if task_data.task ~= nil then
            task_data.task:Cancel()
        end
        if task_data.visuals ~= nil then
            task_data.visuals:Remove()
        end
    end

    inst._terraform_tasks = {}
end


local function terraformer_forcefinishterraform(inst)
    for _, task_data in pairs(inst._terraform_tasks) do
        if task_data.task then
            task_data.task:Cancel()
            task_data.task = nil
        end
        if task_data.visuals then
            task_data.visuals:PushEvent("earlyexit")
        end
        ((task_data.is_revert and _RevertTile) or _TerraformTile)(inst, task_data.tx, task_data.ty)
    end
end

------------------------------------------------------------------
local function on_terraformer_save(inst, data)
    for _, task_data in pairs(inst._terraform_tasks) do
        data.terraform_tasks = data.terraform_tasks or {}
        table.insert(data.terraform_tasks, {
            tx = task_data.tx,
            ty = task_data.ty,
            facing = task_data.facing,
            is_revert = task_data.is_revert,
            time = task_data.endtime - GetTime()
        })
    end
end

local function on_terraformer_load(inst, data)
    if data then
        if data.terraform_tasks then
            for _, task_data in ipairs(data.terraform_tasks) do
                terraformer_addtask(inst,
                    task_data.tx,
                    task_data.ty,
                    task_data.time,
                    task_data.facing,
                    task_data.is_revert
                )
            end
        end
    end
end

local function on_terraformer_longupdate(inst, delta_time)
    if inst._terraform_tasks then
        for _, task_data in pairs(inst._terraform_tasks) do
            local time_remaining = GetTaskRemaining(task_data.task)
            local new_time = math.max(FRAMES, time_remaining - delta_time)

            task_data.task:Cancel()

            if task_data.visuals ~= nil then
                task_data.visuals:SetAppearTime(new_time)
            end

            task_data.task = inst:DoTaskInTime(
                new_time,
                (task_data.is_revert and _RevertTile) or _TerraformTile,
                task_data.tx, task_data.ty
            )
        end
    end
end


local function terraformer_timerdone(inst, data)
    if data and data.name == "remove" then
        inst:Remove()
    end
end

------------------------------------------------------------------
local function terraformerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("birdblocker")
    inst:AddTag("FX")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("NOBLOCK")
    inst:AddTag("scarytoprey")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --
    inst._terraform_tasks = {}

    --
    inst.AddTerraformTask = terraformer_addtask
    inst.OnParentRemoved  = terraformer_onparentremoved
    inst.TaskTimeForTile  = terraformer_remainingtasktimefortile

    --
    inst:ListenForEvent("forcefinishterraforming", terraformer_forcefinishterraform)
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", terraformer_timerdone)

    --
    inst.OnSave = on_terraformer_save
    inst.OnLoad = on_terraformer_load
    inst.OnLongUpdate = on_terraformer_longupdate

    return inst
end

--------------------------------------------------------------------------------
local function terraformer_visuals_finish(inst)
    if inst._hidden then
        inst:Show()
        inst._hidden = false
    end
    local explosion = SpawnPrefab("lunarrift_terraformer_explosion")
    explosion.Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst.AnimState:PlayAnimation("glow_dispel"..inst._facing_direction, false)
    inst:DoTaskInTime(1.0, inst.Remove)
end

local function terraformer_visuals_glow(inst)
    if inst._hidden then
        inst:Show()
        inst._hidden = false
    end
    inst.AnimState:SetDeltaTimeMultiplier(1.0)
    inst.AnimState:SetLightOverride(0.1)
    inst.AnimState:PlayAnimation("glow"..inst._facing_direction)
    inst.AnimState:PushAnimation("glow_idle"..inst._facing_direction, false)

    inst.components.timer:StartTimer("do_finish", 1.0)
end

local HORIZONTAL_SOUND_TIMINGS =
{
    0.03, 1.36, 1.86, 2.70, 3.06,
    4.80, 5.30, 5.73, 6.83, 7.36,
    7.56, 9.03, 9.50, 10.30, 11.30,
    11.67, 12.03, 13.67, 14.23,
    14.47, 16.03, 16.47, 16.8, 17.9,
    18.23
}
local DIAGONAL_SOUND_TIMINGS =
{
    0.03, 0.60, 1.83, 4.03, 4.53,
    6.23, 6.80, 7.13, 8.43, 8.73,
    9.73, 10.06, 10.36, 10.53,
    12.53, 13.26, 13.40, 13.73,
    14.13, 16.10, 16.50, 16.80, 17.10,
    18.23, 18.46
}
local function play_creep_sound(inst)
    inst.SoundEmitter:PlaySound("rifts/rift_crystal/floor_creep")
end
local function terraformer_queue_sounds(inst)
    local timings = (inst._facing_direction == "_horizontal" and HORIZONTAL_SOUND_TIMINGS)
        or DIAGONAL_SOUND_TIMINGS
    for _, time in ipairs(timings) do
        inst:DoTaskInTime(time, play_creep_sound)
    end
end

local FINISH_DELAY = 23.0
local function terraformer_visuals_appear(inst)
    if inst._hidden then
        inst:Show()
        inst._hidden = false
    end

    inst.AnimState:PlayAnimation("grow"..inst._facing_direction)
    inst.AnimState:PushAnimation("grow_idle"..inst._facing_direction, true)
    
    if inst.components.timer:TimerExists("do_glow") then
        inst.components.timer:SetTimeLeft("do_glow", FINISH_DELAY)
    else
        inst.components.timer:StartTimer("do_glow", FINISH_DELAY)
    end

    terraformer_queue_sounds(inst)
end

local function terraformer_visuals_setappeartime(inst, time)
    if time < FINISH_DELAY then
        if inst._hidden then
            inst:Show()
            inst._hidden = false
        end
        inst.AnimState:PlayAnimation("grow_idle"..inst._facing_direction, true)

        if inst.components.timer:TimerExists("do_glow") then
            inst.components.timer:SetTimeLeft("do_glow", time)
        else
            inst.components.timer:StartTimer("do_glow", time)
        end
    else
        inst.components.timer:StartTimer("do_appear", time - FINISH_DELAY)
    end
end

local HALF_PI = PI/2
local function terraformer_visuals_setfacing(inst, facing)
    local fx, fz = facing[1], facing[2]
    local input_facing_angle = math.atan2(fx, fz)

    -- We default to "_horizontal"
    local modulo_facing_angle = (input_facing_angle % HALF_PI)
    if modulo_facing_angle > PI/8 then
        inst._facing_direction = "_diagonal"
    end

    local rounded_facing_angle = HALF_PI * math.floor(input_facing_angle / HALF_PI)
    inst.Transform:SetRotation( (rounded_facing_angle * RADIANS) - 90)
end

----------------------
local function terraformer_visuals_earlyexit(inst)
    if inst._hidden then
        inst:Show()
        --inst._hidden = false -- We're being Removed, so...
        local explosion = SpawnPrefab("lunarrift_terraformer_explosion")
        explosion.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    inst:Remove()
end

local function terraformer_visuals_earlyexit_helper(inst)
    inst.components.timer:StartTimer("do_earlyexit", math.random())
end

----------------------
local function terraformer_visuals_timerdone(inst, data)
    if data.name == "do_earlyexit" then
        terraformer_visuals_earlyexit(inst)
    elseif not inst.components.timer:TimerExists("do_earlyexit") then
        if data.name == "do_appear" then
            terraformer_visuals_appear(inst)
        elseif data.name == "do_glow" then
            terraformer_visuals_glow(inst)
        elseif data.name == "do_finish" then
            terraformer_visuals_finish(inst)
        end
    end
end

local function terraformvisualsfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local anim_state = inst.AnimState
    anim_state:SetBank("groundcrystal_growth")
    anim_state:SetBuild("groundcrystal_growth")
    anim_state:SetOrientation(ANIM_ORIENTATION.OnGround)
    anim_state:SetLayer(LAYER_BACKGROUND)
    anim_state:SetScale(1.5, 1.5)

    inst:AddTag("birdblocker")
    inst:AddTag("FX")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._hidden = true
    inst._facing_direction = "_horizontal"

    --
    inst:AddComponent("timer")

    --
    inst:ListenForEvent("earlyexit", terraformer_visuals_earlyexit_helper)
    inst:ListenForEvent("timerdone", terraformer_visuals_timerdone)

    --
    inst.SetAppearTime = terraformer_visuals_setappeartime
    inst.SetFacing = terraformer_visuals_setfacing

    --
    inst.persists = false

    --
    inst:Hide()

    return inst
end

return Prefab("rift_terraformer", terraformerfn, terraformer_assets, terraformer_prefabs),
    Prefab("lunarrift_terraformer_visual", terraformvisualsfn, terraformer_assets)