local assets =
{
    Asset("ANIM", "anim/statue_small.zip"),
    Asset("ANIM", "anim/statue_small_harp_build.zip"),
    Asset("ANIM", "anim/statue_small_harp_vine_build.zip"),    
    Asset("MINIMAP_IMAGE", "statue_small"),
}

local prefabs =
{
    "marble",
    "rock_break_fx",

    "mask_dollhat",
    "mask_dollbrokenhat",
    "mask_dollrepairedhat",
    "mask_blacksmithhat",
    "mask_mirrorhat",
    "mask_queenhat",
    "mask_kinghat",
    "mask_treehat",
    "mask_foolhat",
 
    "costume_doll_body",
    "costume_queen_body",
    "costume_blacksmith_body",
    "costume_mirror_body",
    "costume_tree_body",
    "costume_fool_body",
    "costume_king_body",
}

SetSharedLootTable( "statue_harp_hedgespawner",
{
    {"marble",  1.0},
    {"marble",  1.0},
    {"marble",  0.3},
})

local COSTUME_ITEMS =
{
    {"costume_doll_body",       "mask_dollhat",         },
    {"costume_doll_body",       "mask_dollbrokenhat",   },
    {"costume_doll_body",       "mask_dollrepairedhat", },
    {"costume_blacksmith_body", "mask_blacksmithhat",   },
    {"costume_mirror_body",     "mask_mirrorhat",       },
    {"costume_queen_body",      "mask_queenhat",        },
    {"costume_king_body",       "mask_kinghat",         },
    {"costume_tree_body",       "mask_treehat",         },
    {"costume_fool_body",       "mask_foolhat",         },
 }
local function GetCostumesForHoundDrops()
    -- NOTE: This function actually rearranges the input array,
    -- but we can tolerates that here.
    local costumes = shuffleArray(COSTUME_ITEMS)
    return {costumes[1][1], costumes[2][1], costumes[1][2], costumes[2][2]}
end

local function SpawnHound(inst, loc, item)
    local bush = SpawnPrefab("hedgehound_bush")
    bush.Transform:SetPosition(loc.x, 0, loc.z)
    bush:SetReward(item)
    bush.holdasbush = true
end

local function SpawnHedgeHounds(inst)
    local pos = inst:GetPosition()
    local dropped_props = GetCostumesForHoundDrops()
    local radius = 4
    local offset, angle = nil, nil

    for i, drop in ipairs(dropped_props) do
        angle = PI * ((2 * i - 1) / 4)
        offset = FindWalkableOffset(pos, angle, radius, nil, false, true)
            or Vector3FromTheta(angle, radius)
        SpawnHound(inst, pos + offset, drop)
    end
end

local LOW_WORK = TUNING.MARBLEPILLAR_MINE * (1/3)
local MED_WORK = TUNING.MARBLEPILLAR_MINE * (2/3)
local function OnWorked(inst, worker, workleft)
    if workleft < LOW_WORK then
        inst.AnimState:PlayAnimation("low")
        if not inst._has_dropped_loot then
            inst.components.lootdropper:DropLoot(inst:GetPosition())
            inst._has_dropped_loot = true
        end
        inst.components.workable:SetWorkable(false)
    else
        inst.AnimState:PlayAnimation((workleft < MED_WORK and "med") or "full")
    end
end

local function OnWorkLoad(inst)
    OnWorked(inst, nil, inst.components.workable.workleft)
end

local function starthedgerespawn(inst)
    if not inst.components.timer:TimerExists("hedgerespawn") then
        inst.components.timer:StartTimer("hedgerespawn", TUNING.STATUEHARP_HEDGESPAWNER_RESET_TIME)
    end
end

local function primehounds(inst)
    if not inst.charlie_test then
        inst.charlie_test = true
        SpawnHedgeHounds(inst)
    end
end

local function onsave(inst, data)
    data.charlie_test = inst.charlie_test
    data.has_dropped_loot = inst._has_dropped_loot
end

local function onpreload(inst, data, newents)
    -- This flag needs to be loaded before the workable component runs its onload
    if data then
        inst._has_dropped_loot = data.has_dropped_loot
    end
end

local function onload(inst, data)
   if data and data.charlie_test then
        inst.charlie_test = data.charlie_test
   end
end

local function OnTimerDone(inst, data)
    if data.name == "hedgerespawn" then
        SpawnHedgeHounds(inst)
    elseif data.name == "primehounds" then
        primehounds(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.66)

    inst:AddTag("statue")
    inst:AddTag("hedgespawner")

    inst.AnimState:SetBank("statue_small")
    inst.AnimState:SetBuild("statue_small")
    inst.AnimState:OverrideSymbol("swap_statue", "statue_small_harp_build", "swap_statue")
    inst.AnimState:PlayAnimation("full")
    inst.AnimState:AddOverrideBuild("statue_small_harp_vine_build")

    inst.MiniMapEntity:SetIcon("statue_small.png")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    ----------------------------------------------------------------------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("statue_harp_hedgespawner")

    ----------------------------------------------------------------------------------
    inst:AddComponent("inspectable")

    ----------------------------------------------------------------------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.MARBLEPILLAR_MINE)
    inst.components.workable:SetOnWorkCallback(OnWorked)
    inst.components.workable:SetOnLoadFn(OnWorkLoad)
    inst.components.workable.savestate = true

    ----------------------------------------------------------------------------------
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("primehounds", 0)

    ----------------------------------------------------------------------------------
    inst:ListenForEvent("trigger_hedge_respawn", starthedgerespawn)
    inst:ListenForEvent("timerdone", OnTimerDone)

    ----------------------------------------------------------------------------------
    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnPreLoad = onpreload

    ----------------------------------------------------------------------------------
    MakeHauntableWork(inst)

    MakeRoseTarget_CreateFuel(inst)

    return inst
end

return Prefab("statueharp_hedgespawner", fn, assets, prefabs)