local prefabs = {
    "wurt_swamp_terraform_fx",
    "wurt_terraformer_fx_shadow",
    "wurt_terraformer_fx_lunar",
}

local fx_functions =
{
    ["SHADOW"] = "wurt_terraformer_fx_shadow",
    ["LUNAR"] = "wurt_terraformer_fx_lunar",
}

local function SetType(inst, terraform_type)
    inst.type = terraform_type or "SHADOW"
    inst.tile = WORLD_TILES[inst.type.."_MARSH"]

    -- Could already exist if we're loading.
    if not inst.components.timer:TimerExists("do_terraforming_fx") then
        inst.components.timer:StartTimer("do_terraforming_fx", 0.5)
    end
end

local DEFAULT_ORIGINAL_TILE = WORLD_TILES.DIRT
local function default_terraform_pattern_fn(_)
    local x_pattern, y_pattern = {0}, {0}
    for off_x = 0, TUNING.WURT_TERRAFORMING_TILERANGE do
        for off_y = 0, TUNING.WURT_TERRAFORMING_TILERANGE do
            if off_x ~= 0 or off_y ~= 0 then
                table.insert(x_pattern, off_x)
                table.insert(y_pattern, off_y)

                if off_x ~= 0 then
                    table.insert(x_pattern, -off_x)
                    table.insert(y_pattern, off_y)
                end

                if off_x ~= 0 and off_y ~= 0 then
                    table.insert(x_pattern, -off_x)
                    table.insert(y_pattern, -off_y)
                end

                if off_y ~= 0 then
                    table.insert(x_pattern, off_x)
                    table.insert(y_pattern, -off_y)
                end
            end
        end
    end

    return x_pattern, y_pattern
end

local function DoTerraformFx(inst)
    local x_pattern, y_pattern = default_terraform_pattern_fn(inst)
    local pattern_count = #x_pattern
    local fx_prefab = fx_functions[inst.type or "SHADOW"]
    if pattern_count > 0 and fx_prefab then
        local _map = TheWorld.Map
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        local middle_tile_x, middle_tile_y = _map:GetTileCoordsAtPoint(ix, iy, iz)
        local random, sqrt, sin, cos = math.random, math.sqrt, math.sin, math.cos
        local fx_radius = (TILE_SCALE * 0.4)
        local tile_x, x_offset
        local tile_y, y_offset
        local current_tile, angle, offset

        for i = 1, pattern_count do
            if random() > 0.9 then
                x_offset, y_offset = x_pattern[i], y_pattern[i]
                tile_x = middle_tile_x + x_offset
                tile_y = middle_tile_y + y_offset
                current_tile = _map:GetTile(tile_x, tile_y)
                if current_tile == inst.tile then
                    local cx, _, cz = _map:GetTileCenterPoint(tile_x, tile_y)
                    angle = random() * TWOPI
                    offset = fx_radius * sqrt(random())

                    SpawnPrefab(fx_prefab).Transform:SetPosition(cx + offset * cos(angle), 0, cz + offset * sin(angle))
                end
            end
        end
    end

    inst.components.timer:StartTimer("do_terraforming_fx", 0.35)
end

local function TerraformTileCallback(inst, tile_x, tile_y, current_tile)
    local current_undertile = TheWorld.components.undertile:GetTileUnderneath(tile_x, tile_y)

    TheWorld.Map:SetTile(tile_x, tile_y, inst.tile)

    -- farming_manager.lua will clear this if we do it before the SetTile call.
    -- If the undertile component already has an entry at this location,
    -- we'll just keep that instead of over-writing with the current one.
    -- This plays a bit better with farm plots.
    TheWorld.components.undertile:SetTileUnderneath(tile_x, tile_y, current_undertile or current_tile)

    local tx, ty, tz = TheWorld.Map:GetTileCenterPoint(tile_x, tile_y)
    local swamp_cover_fx = SpawnPrefab("wurt_swamp_terraform_fx")
    swamp_cover_fx.Transform:SetPosition(tx, ty, tz)

    inst._terraforms_to_do = inst._terraforms_to_do - 1
end
local function play_terraform_splash_sound(inst)
    inst.SoundEmitter:PlaySound("meta4/wurt_swampitem/terraform")
end
local function DoTerraform(inst, pattern_fn, is_load)
    local _map = TheWorld.Map

    local middle_tile_x, middle_tile_y = _map:GetTileCoordsAtPoint(inst.Transform:GetWorldPosition())
    local tile_x, tile_y

    pattern_fn = pattern_fn or default_terraform_pattern_fn
    local x_pattern, y_pattern = pattern_fn(inst)
    local pattern_count = #x_pattern
    if pattern_count > 0 then
        for i = 1, pattern_count do
            tile_x = middle_tile_x + x_pattern[i]
            tile_y = middle_tile_y + y_pattern[i]
            if not _map:IsTerraformingBlockedByAnObject(tile_x, tile_y) then
                local current_tile = _map:GetTile(tile_x, tile_y)

                -- Avoid swamping up impassable tiles (ocean, cave void)
                -- and other temporary tiles (monkey docks, ocean ice, Charlie vines, etc)
                if TileGroupManager:IsLandTile(current_tile)
                        and not TileGroupManager:IsOceanTile(current_tile)
                        and not TileGroupManager:IsImpassableTile(current_tile)
                        and not TileGroupManager:IsTemporaryTile(current_tile) then
                    local pattern_percent = i/pattern_count
                    inst:DoTaskInTime(
                        FRAMES * (TUNING.WURT_TERRAFORMING_FX_BASE + TUNING.WURT_TERRAFORMING_FX_RAND * pattern_percent),
                        TerraformTileCallback, tile_x, tile_y, current_tile
                    )

                    if not is_load then
                        table.insert(inst._terraformed_tiles, {tile_x, tile_y})
                    end
                end
            end
        end
    end

    if not is_load then
        -- Assume that we loaded both the todo count and the timer task.
        inst._terraforms_to_do = #inst._terraformed_tiles
        inst.components.timer:StartTimer("undo_terraforming", TUNING.WURT_TERRAFORMING_TIME)

        play_terraform_splash_sound(inst)
        inst:DoTaskInTime(2*FRAMES, play_terraform_splash_sound)
        inst:DoTaskInTime(4*FRAMES, play_terraform_splash_sound)
        inst:DoTaskInTime(6*FRAMES, play_terraform_splash_sound)
        inst:DoTaskInTime(8*FRAMES, play_terraform_splash_sound)
        inst:DoTaskInTime(10*FRAMES, play_terraform_splash_sound)
    end
end

local function DeTerraformTileCallback(inst, tile_x, tile_y)
    local old_tile = TheWorld.components.undertile:GetTileUnderneath(tile_x, tile_y) or DEFAULT_ORIGINAL_TILE
    TheWorld.components.undertile:ClearTileUnderneath(tile_x, tile_y)
    TheWorld.Map:SetTile(tile_x, tile_y, old_tile)

    local tx, ty, tz = TheWorld.Map:GetTileCenterPoint(tile_x, tile_y)
    local swamp_cover_fx = SpawnPrefab("wurt_swamp_terraform_fx")
    swamp_cover_fx.Transform:SetPosition(tx, ty, tz)

    inst._terraforms_to_undo = inst._terraforms_to_undo - 1
end
local function UndoTerraform(inst, is_load)
    local _map = TheWorld.Map

    local tile_x, tile_y, current_tile
    for _, tile_data in pairs(inst._terraformed_tiles) do
        tile_x, tile_y = tile_data[1], tile_data[2]
        current_tile = _map:GetTile(tile_x, tile_y)
        if current_tile == inst.tile then
            inst:DoTaskInTime(
                FRAMES * (TUNING.WURT_TERRAFORMING_FX_BASE + TUNING.WURT_TERRAFORMING_FX_RAND * math.random()),
                DeTerraformTileCallback, tile_x, tile_y
            )

            if not is_load then
                -- Assume that we'll load this value, modified by the tasks that already successfully ran.
                inst._terraforms_to_undo = inst._terraforms_to_undo + 1
            end
        end
    end

    local timer = inst.components.timer
    local remove_time = 1.5 * (TUNING.WURT_TERRAFORMING_FX_BASE + TUNING.WURT_TERRAFORMING_FX_RAND) * FRAMES
    if timer:TimerExists("remove") then
        -- If we're loading, we need to reset our remove time, so that the DoTasks setup above
        -- have a chance to finish before the remove does (since it'll be save/loaded mid-task,
        -- but the DoTask will be restarted)
        timer:SetTimeLeft("remove", remove_time)
    else
        inst.components.timer:StartTimer("remove", remove_time)
    end
end

local function OnTimerDone(inst, data)
    if data.name == "undo_terraforming" then
        inst:UndoTerraform()
    elseif data.name == "remove" then
        inst:Remove()
    elseif data.name == "do_terraforming_fx" then
        DoTerraformFx(inst)
    end
end

-- Save/Load
local function OnSave(inst, data)
    data.terraformed_tiles = shallowcopy(inst._terraformed_tiles)
    data.terraforms_to_do = inst._terraforms_to_do
    data.terraforms_to_undo = inst._terraforms_to_undo
    data.terraform_type = inst.type
end

local function OnLoad(inst, data)
    inst._terraformed_tiles = shallowcopy(data.terraformed_tiles)
    inst._terraforms_to_do = data.terraforms_to_do
    inst._terraforms_to_undo = data.terraforms_to_undo

    inst:SetType(data.terraform_type)

    if data.terraforms_to_do > 0 then
        inst:DoTerraform(nil, true)
    elseif data.terraforms_to_undo > 0 then
        inst:UndoTerraform(true)
    end
end

--
local function swamp_terraformer()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst._terraforms_to_do = 0
    inst._terraforms_to_undo = 0
    inst._terraformed_tiles = {}

    inst.tile = WORLD_TILES.SHADOW_MARSH
    inst.type = "SHADOW"
    inst.SetType = SetType
    inst.DoTerraform = DoTerraform
    inst.UndoTerraform = UndoTerraform

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("wurt_swamp_terraformer", swamp_terraformer, nil, prefabs)