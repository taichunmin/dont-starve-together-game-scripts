require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/moon_altar.zip"),
    Asset("ANIM", "anim/moon_fissure.zip"),
}

local prefabs =
{
	"moon_fissure",
    "moon_altar_idol",
    "moon_altar_glass",
    "moon_altar_seed",
	"collapse_small",
}

local LIGHT_RADIUS = 0.9
local LIGHT_INTENSITY = .6
local LIGHT_FALLOFF = .65

local function OnUpdateFlicker(inst, starttime)
    local time = (GetTime() - starttime) * 15
    local flicker = math.sin(time * 0.7 + math.sin(time * 6.28)) -- range = [-1 , 1]
    flicker = (1 + flicker) * .5 -- range = 0:1
    inst.Light:SetIntensity(LIGHT_INTENSITY + .05 * flicker)
end

local function onturnon(inst)
    if inst._stage == 3 then
        if inst.AnimState:IsCurrentAnimation("proximity_pre") or
            inst.AnimState:IsCurrentAnimation("proximity_loop") or
            inst.AnimState:IsCurrentAnimation("place3") then
            
            --NOTE: push again even if already playing, in case an idle was also pushed
            inst.AnimState:PushAnimation("proximity_pre")
        else
            inst.AnimState:PlayAnimation("proximity_pre")
        end

        inst.AnimState:PushAnimation("proximity_loop", true)
    end
end

local function onturnoff(inst)
    if inst._stage == 3 then
        inst.AnimState:PlayAnimation("proximity_pst")
        inst.AnimState:PushAnimation("idle3", false)
    end
end

local function set_stage(inst, stage)
    if stage == 3 then
	    if inst._stage == 2 then
            inst.AnimState:PlayAnimation("place3")
            inst.AnimState:PushAnimation("idle3", false)
        else
            inst.AnimState:PlayAnimation("idle3")
        end

		inst:AddComponent("prototyper")
		inst.components.prototyper.onturnon = onturnon
		inst.components.prototyper.onturnoff = onturnoff
        inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.MOON_ALTAR_FULL

        inst.components.lootdropper:SetLoot({ "moon_altar_idol", "moon_altar_glass", "moon_altar_seed" })

    elseif stage == 2 then
        if inst._stage == 1 then
            inst.AnimState:PlayAnimation("place2")
            inst.AnimState:PushAnimation("idle2", false)
        else
            inst.AnimState:PlayAnimation("idle2")
        end

        inst.components.lootdropper:SetLoot({ "moon_altar_glass", "moon_altar_seed" })
	end

    inst._stage = stage or 1
end

local function spawn_loot_apart(inst)
    local drop_x, drop_y, drop_z = inst.Transform:GetWorldPosition()

    local loot_prefabs = inst.components.lootdropper:GenerateLoot()
    for _, loot_prefab in pairs(loot_prefabs) do
        local spawn_location = Vector3(drop_x + math.random(-2, 2), drop_y, drop_z + math.random(-2, 2))
        inst.components.lootdropper:SpawnLootPrefab(loot_prefab, spawn_location)
    end
end

local function onhammered(inst, worker)
	local x, y, z = inst.Transform:GetWorldPosition()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)

	local altar = SpawnPrefab("moon_fissure")
	altar.Transform:SetPosition(x, y, z)

    spawn_loot_apart(inst)

	inst:Remove()
end

local function onhit(inst, hitter, work_left, work_done)
    -- If we have no work left, we're going to revert to crack_idle anyway, so don't play any anims.
    if work_left > 0 then
        if inst.components.prototyper ~= nil and inst.components.prototyper.on then
            inst.AnimState:PlayAnimation("hit_proximity")
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PlayAnimation("hit_inactive"..inst._stage)
            inst.AnimState:PushAnimation("idle"..inst._stage, false)
        end
    end
end

local function on_piece_slotted(inst, slotter, slotted_item)
	set_stage(inst, inst._stage + 1)
end

local function check_piece(inst, piece)
    if (inst._stage == 1 and piece.prefab == "moon_altar_seed") or
            (inst._stage == 2 and piece.prefab == "moon_altar_idol") then
        return true
    else
        return false, "WRONGPIECE"
    end
end

local function display_name_fn(inst)
    return (inst:HasTag("prototyper") and STRINGS.NAMES.MOON_ALTAR.MOON_ALTAR) or
            STRINGS.NAMES.MOON_ALTAR.MOON_ALTAR_WIP
end

local function getstatus(inst)
    return inst._stage < 3 and "MOON_ALTAR_WIP" or nil
end

local function OnEntitySleep(inst)
    if inst._flickertask ~= nil then
        inst._flickertask:Cancel()
		inst._flickertask = nil
    end
end

local function OnEntityWake(inst)
    if inst._flickertask == nil then
	    inst._flickertask = inst:DoPeriodicTask(.1, OnUpdateFlicker, 0, GetTime())
	end
end

local function on_save(inst, data)
    data.stage = inst._stage
end

local function on_load(inst, data)
    if data ~= nil and data.stage ~= nil then
        set_stage(inst, data.stage)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("moon_altar.png")

    inst.Light:SetFalloff(LIGHT_FALLOFF)
    inst.Light:SetIntensity(LIGHT_INTENSITY)
    inst.Light:SetRadius(LIGHT_RADIUS)
    inst.Light:SetColour(0.3, 0.45, 0.55)
    inst.Light:EnableClientModulation(true)
    inst._flickertask = inst:DoPeriodicTask(.1, OnUpdateFlicker, 0, GetTime())

    inst.AnimState:SetBank("moon_altar")
    inst.AnimState:SetBuild("moon_altar")
    inst.AnimState:PlayAnimation("idle1")

    inst:AddTag("structure")

    inst.displaynamefn = display_name_fn

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst._stage = 1

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({ "moon_altar_glass" })

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetMaxWork(TUNING.MOON_ALTAR_COMPLETE_WORK)
	inst.components.workable.workleft = TUNING.MOON_ALTAR_COMPLETE_WORK / 3
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    inst.components.workable.savestate = true

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = MATERIALS.MOON_ALTAR
    inst.components.repairable.onrepaired = on_piece_slotted
    inst.components.repairable.checkmaterialfn = check_piece
    inst.components.repairable.noannounce = true

    MakeSnowCovered(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    inst.OnSave = on_save
    inst.OnLoad = on_load

    return inst
end

return Prefab("moon_altar", fn, assets, prefabs)
