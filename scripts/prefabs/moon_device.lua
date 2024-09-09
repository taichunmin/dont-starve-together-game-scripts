local assets =
{
    Asset("ANIM", "anim/moon_device.zip"),
    Asset("ANIM", "anim/moon_device_break.zip"),

    Asset("MINIMAP_IMAGE", "moon_device"),
}

local prefabs =
{
    "moon_device_pillar",
    "moon_device_top",
    "moon_altar_link_contained",

    "alterguardian_phase1",
    "alterguardian_phase1fallfx",

    "moon_device_break_stage1",
    "moon_device_break_stage2",
    "moon_device_break_stage3",
    "moon_geyser_explode",

    "moon_altar_break",
    "moon_altar_claw_break",
    "moon_altar_crown_break",

    "burntground",

    "moon_device_meteor_spawner",

	"construction_container",
}

local meteor_spawner_prefabs =
{
    "shadowmeteor",
}

local break_stage1_assets =
{
    Asset("ANIM", "anim/moon_device_break.zip"),
}

local spawnpillars, spawntop -- Initialized as functions further down

local PLACER_SNAP_DISTANCE = 6

local BREAK_DELAY = 9.5

local existing_moon_device = nil

local construction_data = {
	{level = 1, name = "moon_device_construction1", construction_product = "moon_device_construction2" },
	{level = 2, name = "moon_device_construction2", construction_product = "moon_device" },
}

local METEOR_OFFSET_MIN = 9
local METEOR_OFFSET_VARIANCE = 10

local function OnConstructed(inst, doer)
    local concluded = true
    for i, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
        if inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
            concluded = false
            break
        end
    end

	if concluded then
        existing_moon_device = nil
        local new_inst = ReplacePrefab(inst, inst._construction_product)
        new_inst._has_replaced_moon_altar_link = true

        if new_inst.level == 2 then
            for _, v in ipairs(new_inst._pillars) do
                v.AnimState:PlayAnimation("stage2_idle_pre", false)
                v.AnimState:PushAnimation("stage2_idle", false)
            end

            new_inst.SoundEmitter:PlaySound("moonstorm/common/moon_device/2_craft")
        elseif new_inst.level >= 3 then
            new_inst._top.AnimState:PlayAnimation("stage3_idle_pre", false)
            new_inst._top.AnimState:PushAnimation("stage3_idle", true)

            new_inst.SoundEmitter:PlaySound("moonstorm/common/moon_device/3_craft")
        end
    end
end

local MOON_ALTAR_LINK_TAGS = { "moon_altar_link" }
local function base_onbuilt(inst)
    inst.SoundEmitter:PlaySound("moonstorm/common/moon_device/1_craft")

    inst.AnimState:PlayAnimation("stage1_idle_pre")
end

local function addpillar(inst, local_x, local_z, rotation)
    local pillar = SpawnPrefab("moon_device_pillar")
    pillar.entity:SetParent(inst.entity)
    pillar.Transform:SetPosition(local_x, 0, local_z)
    pillar.Transform:SetRotation(rotation)

    return pillar
end

spawnpillars = function(inst)
    if inst._pillars == nil then
        local x, y, z = inst.Transform:GetWorldPosition()

        local offset = 2.7

        inst._pillars = {}

        table.insert(inst._pillars, addpillar(inst, -offset, 0, 0))
        table.insert(inst._pillars, addpillar(inst, 0, -offset, 270))
        table.insert(inst._pillars, addpillar(inst, offset, 0, 180))
        table.insert(inst._pillars, addpillar(inst, 0, offset, 90))
    end
end

local function pillarfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("moon_device_stages")
    inst.AnimState:SetBuild("moon_device")
    inst.AnimState:PlayAnimation("stage2_idle")

    inst:SetPrefabNameOverride("moon_device")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function topfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()
    inst.Transform:SetRotation(45)

    inst.AnimState:SetBank("moon_device_stages")
    inst.AnimState:SetBuild("moon_device")
    inst.AnimState:PlayAnimation("stage3_idle", true)

    inst:SetPrefabNameOverride("moon_device")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

spawntop = function(inst)
    if inst._top == nil then
        inst._top = SpawnPrefab("moon_device_top")
        inst._top.entity:SetParent(inst.entity)
    end
end

local function playlinkanimation(inst, stage)
    if inst._link == nil then
        inst._link = SpawnPrefab("moon_altar_link_contained")
        inst._link.entity:SetParent(inst.entity)
    end

    inst._link:_set_stage_fn(stage)
end

local function stage3_break(inst)
    SpawnPrefab("moon_device_break_stage3").Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst._top:DoTaskInTime(FRAMES, inst._top.Remove)
end

local function stage2_break(inst)
    for _, v in ipairs(inst._pillars) do
        local x, y, z = v.Transform:GetWorldPosition()
        local pillar = SpawnPrefab("moon_device_break_stage2")
        pillar.Transform:SetPosition(x, y, z)
        pillar.Transform:SetRotation(v.Transform:GetRotation())

        v:DoTaskInTime(FRAMES, v.Remove)
    end
end

local function meteor_invitem_behaviour(inst, v)
    local x, y, z = inst.Transform:GetWorldPosition()

    if v.components.container ~= nil then
        -- Spill backpack contents, but don't destroy backpack
        if math.random() <= TUNING.METEOR_SMASH_INVITEM_CHANCE then
            v.components.container:DropEverything()
        end
    elseif v.components.mine ~= nil and not v.components.mine.inactive then
        -- Always smash things on the periphery so that we don't end up with a ring of flung loot
        v.components.mine:Deactivate()
    elseif math.random() <= TUNING.METEOR_SMASH_INVITEM_CHANCE and not v:HasTag("irreplaceable") then
        -- Always smash things on the periphery so that we don't end up with a ring of flung loot
        local vx, vy, vz = v.Transform:GetWorldPosition()
        SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(vx, 0, vz)
        v:Remove()
    end

    if not v.components.inventoryitem.nobounce then
        Launch(v, inst, TUNING.LAUNCH_SPEED_SMALL)
    elseif v.Physics ~= nil and v.Physics:IsActive() then
        local vx, vy, vz = v.Transform:GetWorldPosition()
        local dx, dz = vx - x, vz - z
        local spd = math.sqrt(dx * dx + dz * dz)
        local angle = (spd > 0 and math.atan2(dz / spd, dx / spd) + (math.random() * 20 - 10) * DEGREES)
            or math.random() * TWOPI
        spd = 3 + math.random() * 1.5
        v.Physics:Teleport(vx, 0, vz)
        v.Physics:SetVel(math.cos(angle) * spd, 0, math.sin(angle) * spd)
    end
    v.components.inventoryitem:SetLanded(false, true)
end

local ALTAR_FX_PREFABS =
{
    moon_altar = "moon_altar_break",
    moon_altar_cosmic = "moon_altar_crown_break",
    moon_altar_astral = "moon_altar_claw_break"
}
local BREAK_CLEAR_AREA_RADIUS = 15
local BREAK_CLEAR_DAMAGE_RSQ = 30.25 -- 5.5^2
local BREAK_CLEAR_AREA_DESTROY_TAGS_CANT = {
    "FX", "ghost", "INLIMBO", "NOCLICK", "playerghost",
}
local BREAK_CLEAR_AREA_DESTROY_TAGS_ONEOF = { "_combat", "_inventoryitem", "CHOP_workable", "DIG_workable", "HAMMER_workable", "MINE_workable" }
local function ClearArea(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, 0.91, 0.026, 0.75, inst, 50)

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, BREAK_CLEAR_AREA_RADIUS, nil, BREAK_CLEAR_AREA_DESTROY_TAGS_CANT, BREAK_CLEAR_AREA_DESTROY_TAGS_ONEOF)
    for _, v in ipairs(ents) do
        if v ~= inst and v:IsValid() then
            local fx_prefab = ALTAR_FX_PREFABS[v.prefab]
            if fx_prefab ~= nil then
                local altar_x, altar_y, altar_z = v.Transform:GetWorldPosition()
                SpawnPrefab(fx_prefab).Transform:SetPosition(altar_x, altar_y, altar_z)
                SpawnPrefab("moon_fissure").Transform:SetPosition(altar_x, 0, altar_z)
                v:Remove()
            elseif v.components.health ~= nil and v:HasTag("smashable") then
                v.components.health:Kill()
            elseif v.components.workable ~= nil and v.components.workable:CanBeWorked()
                    and v.components.workable.action ~= ACTIONS.NET then
                if not v:HasTag("moonglass") then
                    SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
                end
                v.components.workable:Destroy(inst)
            elseif v.components.health ~= nil and v.components.combat ~= nil
                    and not v.components.health:IsDead()
                    and v:GetDistanceSqToPoint(x, y, z) < BREAK_CLEAR_DAMAGE_RSQ then
                v.components.combat:GetAttacked(inst, TUNING.ALTERGUARDIAN_PHASE1_ROLLDAMAGE)
            elseif v.components.inventoryitem ~= nil then
                meteor_invitem_behaviour(inst, v)
            end
        end
    end
end

local function spawnscorchmark(x, z, scale)
    local scorch = SpawnPrefab("burntground")
    scorch.Transform:SetPosition(x, 0, z)
    scorch.Transform:SetScale(scale, scale, scale)
end

local function stage1_break(inst)
    ClearArea(inst)

    local ix, _, iz = inst.Transform:GetWorldPosition()

    SpawnPrefab("moon_device_break_stage1").Transform:SetPosition(ix, 0, iz)
    SpawnPrefab("moon_geyser_explode").Transform:SetPosition(ix, 0, iz)

    spawnscorchmark(ix, iz, 1.6)

    local angle_offset = math.random() * PI
    for i = 1, 3 do
        local theta = (TWOPI / 3) * i + angle_offset
        local offset = 1 + math.random()
        spawnscorchmark(ix + math.cos(theta) * offset, iz + math.sin(theta) * offset, 1.1 + 0.4 * math.random())
    end
end

local function play_fallwarning_sfx(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/meteor_spawn")
end

local function do_boss_spawn(inst)
    local ix, _, iz = inst.Transform:GetWorldPosition()
    local boss = SpawnPrefab("alterguardian_phase1")
    boss.Transform:SetPosition(ix, 0, iz)
    boss.sg:GoToState("prespawn_idle")

    inst:Remove()
end

local function break_device(inst)
    stage3_break(inst)
    stage2_break(inst)
    stage1_break(inst)

    inst:DoTaskInTime(1*FRAMES, do_boss_spawn)
    inst.SoundEmitter:PlaySound("moonstorm/creatures/boss/alterguardian1/spawn_pre")
end

local function breaksequence(inst)
    local fall_fx = SpawnPrefab("alterguardian_phase1fallfx")
    fall_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

    -- Should be timed up with the phase1fallfx anim/fx spawned above.
    inst:DoTaskInTime(9*FRAMES, break_device)
end

local function getstatus(inst, viewer)
	return inst.level == 2 and "CONSTRUCTION2"
        or inst.level == 1 and "CONSTRUCTION1"
        or nil -- GENERIC = completed
end

local function validate_spawn(inst)
    if not inst._has_replaced_moon_altar_link then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, PLACER_SNAP_DISTANCE, MOON_ALTAR_LINK_TAGS)
        if #ents > 0 then
            local link_x, _, link_z = ents[1].Transform:GetWorldPosition()
            inst.Transform:SetPosition(link_x, 0, link_z)

            ents[1]:Remove()

            inst._has_replaced_moon_altar_link = true
        else
            print("moon_device must be instantiated on top of a moon_altar_link -- removing instance")
            inst:Remove()
        end
    end
end


local function OnEntitySleep(inst)
    if inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:KillSound("loop")
    end
end

local function OnEntityWake(inst)
    if not inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:PlaySound("grotto/common/moon_alter/link/LP", "loop")
        inst.SoundEmitter:SetParameter("loop", "intensity", 1)
    end
end

local function OnSave(inst, data)
    data.has_replaced_moon_altar_link = inst._has_replaced_moon_altar_link
end

local function OnLoad(inst, data)
    if data ~= nil and data.has_replaced_moon_altar_link then
        inst._has_replaced_moon_altar_link = true
    end
end

local function MakeDeviceStage(name, client_postinit, master_postinit, construction_data)
	local function fn()

   		local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

		inst.MiniMapEntity:SetIcon("moon_device_construction1.png")

        inst:AddTag("moon_device")
        inst:AddTag("structure")
        inst:AddTag("nomagic")

        if construction_data then
            inst.level = construction_data.level
        else
            inst.level = 3
        end

        inst.Transform:SetEightFaced()

		inst.AnimState:SetBank("moon_device_stages")
		inst.AnimState:SetBuild("moon_device")
        inst.AnimState:PlayAnimation("stage1_idle", false)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(1)

		if construction_data then
			inst:AddTag("constructionsite")
		end

        inst:AddTag("antlion_sinkhole_blocker")

        -- inst._pillars = nil
        -- inst._top = nil

        inst:SetPrefabNameOverride("moon_device")

        MakeSnowCoveredPristine(inst)

        inst.scrapbook_anim = "stage1_idle"
        inst.scrapbook_specialinfo = "MOONDEVICE"
        inst.scrapbook_proxy = "moon_device"

		inst.entity:SetPristine()

        if client_postinit ~= nil then
            client_postinit(inst)
        end

		if not TheWorld.ismastersim then
			return inst
		end

        inst._construction_product = construction_data ~= nil and construction_data.construction_product or nil

        playlinkanimation(inst, inst.level)

        if inst.level >= 2 then
            spawnpillars(inst)
        end

        if inst.level == 3 then
            spawntop(inst)

            if not POPULATING then
                inst:DoTaskInTime(0, function()
                    local x, y, z = inst.Transform:GetWorldPosition()
                    SpawnPrefab("moon_device_meteor_spawner").Transform:SetPosition(x, y, z)
                end)
            end

            inst:DoTaskInTime(BREAK_DELAY - 1, play_fallwarning_sfx)
            inst:DoTaskInTime(BREAK_DELAY, breaksequence)
        else
            inst:AddComponent("constructionsite")
            inst.components.constructionsite:SetConstructionPrefab("construction_container")
            inst.components.constructionsite:SetOnConstructedFn(OnConstructed)
        end

		inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

		inst:ListenForEvent("onbuilt", base_onbuilt)

        if existing_moon_device == nil then
            existing_moon_device = inst

            inst:ListenForEvent("onremove", function()
                existing_moon_device = nil
            end)

            inst:DoTaskInTime(0, validate_spawn)
        else
            print("Multiple instances of moon_device")
            inst:DoTaskInTime(0, inst.Remove)
        end

        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake

		inst.OnSave = OnSave
		inst.OnLoad = OnLoad

        if master_postinit then
           master_postinit(inst)
        end

        return inst
	end

	local product = construction_data and construction_data.construction_product or nil
	return Prefab(name, fn, assets, prefabs, product)
end

local function placer_onupdatetransform(inst)
    local pos = inst:GetPosition()
    local ents = TheSim:FindEntities(pos.x, 0, pos.z, PLACER_SNAP_DISTANCE, { "moon_altar_link" })

    if #ents > 0 then
        local targetpos = ents[1]:GetPosition()
        inst.Transform:SetPosition(targetpos.x, 0, targetpos.z)

        inst.accept_placement = ents[1]:HasTag("can_build_moon_device")
    else
        inst.accept_placement = false
    end
end

local function placer_override_build_point(inst)
    -- Gamepad defaults to this behavior, but mouse input normally takes
    -- mouse position over placer position, ignoring the placer snapping
    -- to a nearby moon geyser
    return inst:GetPosition()
end

local function placer_override_testfn(inst)
    local can_build, mouse_blocked = true, false

    if inst.components.placer.testfn ~= nil then
        can_build, mouse_blocked = inst.components.placer.testfn(inst:GetPosition(), inst:GetRotation())
    end

    -- can_build = can_build and inst.accept_placement

    -- testfn just checks Map:CanDeployRecipeAtPoint(). If there is a valid geyser but the build
    -- position doesn't pass this check it's either because
    --      1.  The area is blocked by an item that can exist on top of the device, so building under it is fine
    --      2.  The area is blocked by a structure; it doesn't really matter if we allow building under it
    --      3.  The area is invalid (over water or something); shouldn't really be hitting this since the
    --          moon_altar_link wouldn't be valid at that point, but if something goes wrong it's better to
    --          just allow building on it than locking all further progress

    -- Better to just override can_build.

    can_build = inst.accept_placement

    return can_build, mouse_blocked
end

local function placer_postinit_fn(inst)
	inst.Transform:SetEightFaced()

    inst.components.placer.onupdatetransform = placer_onupdatetransform
    inst.components.placer.override_build_point_fn = placer_override_build_point

    inst.components.placer.override_testfn = placer_override_testfn

    inst.accept_placement = false
end

local function break_stage1_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("moon_device_break")
    inst.AnimState:SetBuild("moon_device_break")
    inst.AnimState:PlayAnimation("stage1_break", false)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(1.5, ErodeAway)

    return inst
end

local function spawnmeteor(inst)
    local x, _, z = inst.Transform:GetWorldPosition()

    local offset = METEOR_OFFSET_MIN + math.random() * METEOR_OFFSET_VARIANCE
    local theta = math.random() * TWOPI

    SpawnPrefab("shadowmeteor").Transform:SetPosition(x + math.cos(theta) * offset, 0, z + math.sin(theta) * offset)
end

local function spawnmeteorandremove(inst)
    spawnmeteor(inst)
    inst:Remove()
end

local function meteor_spawner_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    -- inst.entity:AddNetwork() -- non-networked entity

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(BREAK_DELAY * 0.49, spawnmeteor)
    inst:DoTaskInTime(BREAK_DELAY * 0.58, spawnmeteor)
    inst:DoTaskInTime(BREAK_DELAY * 0.65, spawnmeteor)
    inst:DoTaskInTime(BREAK_DELAY * 0.72, spawnmeteor)

    inst:DoTaskInTime(BREAK_DELAY * 1.06, spawnmeteor)
    inst:DoTaskInTime(BREAK_DELAY * 1.12, spawnmeteorandremove)

    return inst
end

local ret = {}
table.insert(ret, MakeDeviceStage("moon_device"))
for i = 1, #construction_data do
	table.insert(ret, MakeDeviceStage(construction_data[i].name, nil, nil, construction_data[i]))
end

table.insert(ret, Prefab("moon_device_pillar", pillarfn, assets, prefabs))
table.insert(ret, Prefab("moon_device_top", topfn, assets, prefabs))

table.insert(ret, MakePlacer("moon_device_construction1_placer", "moon_device_stages", "moon_device", "stage1_idle", true, nil, nil, nil, nil, nil, placer_postinit_fn))

table.insert(ret, Prefab("moon_device_break_stage1", break_stage1_fn, break_stage1_assets))
table.insert(ret, Prefab("moon_device_meteor_spawner", meteor_spawner_fn, nil, meteor_spawner_prefabs))

return unpack(ret)
