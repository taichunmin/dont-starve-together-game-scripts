local rock1_assets =
{
    Asset("ANIM", "anim/rock.zip"),
    Asset("MINIMAP_IMAGE", "rock"),
}

local rock2_assets =
{
    Asset("ANIM", "anim/rock2.zip"),
    Asset("MINIMAP_IMAGE", "rock_gold"),
}

local rock_flintless_assets =
{
    Asset("ANIM", "anim/rock_flintless.zip"),
    Asset("MINIMAP_IMAGE", "rock"),
}

local rock_moon_assets =
{
    Asset("ANIM", "anim/rock7.zip"),
    Asset("MINIMAP_IMAGE", "rock_moon"),
}

local rock_moon_shell_assets =
{
    Asset("ANIM", "anim/moonrock_shell.zip"),
    Asset("MINIMAP_IMAGE", "rock_moon"),
}

local rock_moon_glass_assets =
{
    Asset("ANIM", "anim/moonglass_rock.zip"),
    Asset("ANIM", "anim/moonglass_rock2.zip"),
    Asset("ANIM", "anim/moonglass_rock3.zip"),
    Asset("ANIM", "anim/moonglass_rock4.zip"),
    Asset("MINIMAP_IMAGE", "rock_moonglass"),
}

local rock_petrified_tree_assets =
{
    Asset("ANIM", "anim/petrified_tree.zip"),
    Asset("ANIM", "anim/petrified_tree_tall.zip"),
    Asset("ANIM", "anim/petrified_tree_short.zip"),
    Asset("ANIM", "anim/petrified_tree_old.zip"),
    Asset("MINIMAP_IMAGE", "petrified_tree"),
}

local prefabs =
{
    "rocks",
    "nitre",
    "flint",
    "goldnugget",
    "moonrocknugget",
    "moonglass",
    "moonrockseed",
    "rock_break_fx",
    "collapse_small",
}

SetSharedLootTable( 'rock1',
{
    {'rocks',  1.00},
    {'rocks',  1.00},
    {'rocks',  1.00},
    {'nitre',  1.00},
    {'flint',  1.00},
    {'nitre',  0.25},
    {'flint',  0.60},
})

SetSharedLootTable( 'rock2',
{
    {'rocks',       1.00},
    {'rocks',       1.00},
    {'rocks',       1.00},
    {'goldnugget',  1.00},
    {'flint',       1.00},
    {'goldnugget',  0.25},
    {'flint',       0.60},
})

SetSharedLootTable( 'rock_flintless',
{
    {'rocks',   1.0},
    {'rocks',   1.0},
    {'rocks',   1.0},
    {'rocks',   1.0},
    {'rocks',   0.6},
})

SetSharedLootTable( 'rock_flintless_med',
{
    {'rocks', 1.0},
    {'rocks', 1.0},
    {'rocks', 1.0},
    {'rocks', 0.4},
})

SetSharedLootTable( 'rock_flintless_low',
{
    {'rocks', 1.0},
    {'rocks', 1.0},
    {'rocks', 0.2},
})

SetSharedLootTable( 'rock_moon',
{
    {'rocks',           1.00},
    {'flint',           1.00},
    {'moonrocknugget',  1.00},
    {'moonrocknugget',  1.00},
    {'moonrocknugget',  0.6},
    {'moonrocknugget',  0.3},
})

SetSharedLootTable( 'rock_moon_shell',
{
    {'rocks',           1.00},
    {'flint',           1.00},
    {'moonrocknugget',  1.00},
    {'moonrocknugget',  1.00},
    {'moonrocknugget',  1.00},
    {'moonrocknugget',  0.3},
})

SetSharedLootTable( 'rock_moon_glass',
{
    {'moonglass',       1.00},
    {'moonglass',       1.00},
    {'moonglass',       0.25},
})

SetSharedLootTable( 'rock_petrified_tree',
{
    {'rocks',  1.00},
    {'rocks',  0.75},
    {'nitre',  0.4},
    {'flint',  0.25},
})
SetSharedLootTable( 'rock_petrified_tree_tall',
{
    {'rocks',  1.00},
    {'rocks',  1.00},
    {'rocks',  0.35},
    {'nitre',  0.65},
    {'flint',  0.75},
})
SetSharedLootTable( 'rock_petrified_tree_short',
{
    {'rocks',  1.00},
    {'rocks',  0.35},
    {'nitre',  0.25},
    {'flint',  0.25},
})
SetSharedLootTable( 'rock_petrified_tree_old',
{
    {'rocks',  0.50},
    {'rocks',  0.50},
    {'nitre',  0.25},
    {'flint',  0.75},
})


local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        local pt = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pt:Get())
        inst.components.lootdropper:DropLoot(pt)

        if inst.showCloudFXwhenRemoved then
            local fx = SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end

		if not inst.doNotRemoveOnWorkDone then
	        inst:Remove()
		end
    else
        inst.AnimState:PlayAnimation(
            (workleft < TUNING.ROCKS_MINE / 3 and "low") or
            (workleft < TUNING.ROCKS_MINE * 2 / 3 and "med") or
            "full"
        )
    end
end

local function setPetrifiedTreeSize(inst)
    if inst.treeSize == 4 then
        inst.AnimState:SetBuild("petrified_tree_old")
        inst.AnimState:SetBank("petrified_tree_old")
        inst.components.lootdropper:SetChanceLootTable('rock_petrified_tree_old')
        inst.components.workable:SetWorkLeft(TUNING.PETRIFIED_TREE_OLD)
        inst.Physics:SetCapsule(.25, 2)
    elseif inst.treeSize == 3 then
        inst.AnimState:SetBuild("petrified_tree_tall")
        inst.AnimState:SetBank("petrified_tree_tall")
        inst.components.lootdropper:SetChanceLootTable('rock_petrified_tree_tall')
        inst.components.workable:SetWorkLeft(TUNING.PETRIFIED_TREE_TALL)
        inst.Physics:SetCapsule(1, 2)
    elseif inst.treeSize == 1 then
        inst.AnimState:SetBuild("petrified_tree_short")
        inst.AnimState:SetBank("petrified_tree_short")
        inst.components.lootdropper:SetChanceLootTable('rock_petrified_tree_short')
        inst.components.workable:SetWorkLeft(TUNING.PETRIFIED_TREE_SMALL)
        inst.Physics:SetCapsule(.25, 2)
    else
        inst.AnimState:SetBuild("petrified_tree")
        inst.AnimState:SetBank("petrified_tree")
        inst.components.lootdropper:SetChanceLootTable('rock_petrified_tree')
        inst.components.workable:SetWorkLeft(TUNING.PETRIFIED_TREE_NORMAL)
        inst.Physics:SetCapsule(.65, 2)
    end
end

local function onsave(inst, data)
    data.treeSize = inst.treeSize
end

local function onload(inst, data)
    if data ~= nil and data.treeSize ~= nil then
        inst.treeSize = data.treeSize
        --V2C: Note that this will reset workleft as well
        --     Gotta change this if you set workable to savestate
        setPetrifiedTreeSize(inst)
    end
end

local function baserock_fn(bank, build, anim, icon, tag, multcolour)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    if icon ~= nil then
        inst.MiniMapEntity:SetIcon(icon)
    end

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)

    if type(anim) == "table" then
        for i, v in ipairs(anim) do
            if i == 1 then
                inst.AnimState:PlayAnimation(v)
            else
                inst.AnimState:PushAnimation(v, false)
            end
        end
    else
        inst.AnimState:PlayAnimation(anim)
    end

    MakeSnowCoveredPristine(inst)

    inst:AddTag("boulder")
    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
    inst.components.workable:SetOnWorkCallback(OnWork)

    if multcolour == nil or (0 <= multcolour and multcolour < 1) then
        if multcolour == nil then
            multcolour = 0.5
        end

        local color = multcolour + math.random() * (1.0 - multcolour)
        inst.AnimState:SetMultColour(color, color, color, 1)
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "ROCK"
    MakeSnowCovered(inst)

    MakeHauntableWork(inst)

    return inst
end

local function rock1_fn()
    local inst = baserock_fn("rock", "rock", "full", "rock.png")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.lootdropper:SetChanceLootTable('rock1')

    return inst
end

local function rock2_fn()
    local inst = baserock_fn("rock2", "rock2", "full", "rock_gold.png")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.lootdropper:SetChanceLootTable('rock2')

    return inst
end

local function rock_flintless_fn()
    local inst = baserock_fn("rock_flintless", "rock_flintless", "full", "rock_flintless.png")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.lootdropper:SetChanceLootTable('rock_flintless')

    return inst
end

local function rock_flintless_med()
    local inst = baserock_fn("rock_flintless", "rock_flintless", "med", "rock_flintless.png")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE_MED)

    inst.components.lootdropper:SetChanceLootTable('rock_flintless_med')

    return inst
end

local function rock_flintless_low()
    local inst = baserock_fn("rock_flintless", "rock_flintless", "low", "rock_flintless.png")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.lootdropper:SetChanceLootTable('rock_flintless_low')
    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE_LOW)

    return inst
end

local function rock_moon()
    local inst = baserock_fn("rock5", "rock7", "full", "rock_moon.png")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.inspectable.nameoverride = "ROCK_MOON"
    inst.components.lootdropper:SetChanceLootTable('rock_moon')

    return inst
end

local function OnRockMoonCapsuleWorkFinished(inst)
    RemovePhysicsColliders(inst)

	local seed = SpawnPrefab("moonrockseed")
	seed.Transform:SetPosition(inst.Transform:GetWorldPosition())
    if seed.OnSpawned ~= nil then
        seed:OnSpawned()
    end

	inst.persists = false
    inst:AddTag("NOCLICK")

	inst.AnimState:PlayAnimation("break")
	inst:DoTaskInTime(2, ErodeAway)
end

local function rock_moon_shell()
    local inst = baserock_fn("moonrock_shell", "moonrock_shell", "full", "rock_moon.png", "meteor_protection")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.inspectable.nameoverride = "ROCK_MOON"
    inst.components.lootdropper:SetChanceLootTable('rock_moon_shell')

	inst.doNotRemoveOnWorkDone = true
	inst:ListenForEvent("workfinished", OnRockMoonCapsuleWorkFinished)

    return inst
end

local function on_save_moonglass(inst, data)
    data.rock_type = inst.rock_type
end

local function set_moonglass_type(inst, new_type)
    inst.rock_type = new_type
    local anim_name = (inst.rock_type == 1 and "moonglass_rock") or ("moonglass_rock"..tostring(new_type))
    inst.AnimState:SetBuild(anim_name)
    inst.AnimState:SetBank(anim_name)
end

local function on_load_moonglass(inst, data)
    if data ~= nil and data.rock_type ~= nil then
        set_moonglass_type(inst, data.rock_type)
    end
end

local function rock_moon_glass()
    local inst = baserock_fn("moonglass_rock", "moonglass_rock", "full", "rock_moonglass.png", "moonglass", 1.0)

    inst:SetPrefabName("moonglass_rock")

    if not TheWorld.ismastersim then
        return inst
    end

    set_moonglass_type(inst, math.random(4))

    inst.components.inspectable.nameoverride = "MOONGLASS_ROCK"
    inst.components.lootdropper:SetChanceLootTable('rock_moon_glass')

    inst.OnSave = on_save_moonglass
    inst.OnLoad = on_load_moonglass

    return inst
end

local function rock_petrified_tree_common(size)
    local inst = baserock_fn("petrified_tree", "petrified_tree", { "petrify_in", "full" }, "petrified_tree.png", "shelter")

    inst:SetPrefabName("rock_petrified_tree")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.showCloudFXwhenRemoved = true

    if not size then
        local rand = math.random()
        if rand > 0.90 then
            size = 4
        elseif rand > 0.60 then
            size = 1
        elseif rand < 0.30 then
            size = 2
        else
            size = 3
        end
    end

    inst.treeSize = size

    setPetrifiedTreeSize(inst)

    inst.components.inspectable.nameoverride = "PETRIFIED_TREE"

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function rock_petrified_tree()
    return rock_petrified_tree_common()
end

local function rock_petrified_tree_short()
    return rock_petrified_tree_common(1)
end

local function rock_petrified_tree_med()
    return rock_petrified_tree_common(2)
end

local function rock_petrified_tree_tall()
    return rock_petrified_tree_common(3)
end

local function rock_petrified_tree_old()
    return rock_petrified_tree_common(4)
end

return Prefab("rock1", rock1_fn, rock1_assets, prefabs),
    Prefab("rock2", rock2_fn, rock2_assets, prefabs),
    Prefab("rock_flintless", rock_flintless_fn, rock_flintless_assets, prefabs),
    Prefab("rock_flintless_med", rock_flintless_med, rock_flintless_assets, prefabs),
    Prefab("rock_flintless_low", rock_flintless_low, rock_flintless_assets, prefabs),
    Prefab("rock_moon", rock_moon, rock_moon_assets, prefabs),
    Prefab("rock_moon_shell", rock_moon_shell, rock_moon_shell_assets, prefabs),
    Prefab("moonglass_rock", rock_moon_glass, rock_moon_glass_assets, prefabs),
    Prefab("rock_petrified_tree", rock_petrified_tree, rock_petrified_tree_assets, prefabs),
    Prefab("rock_petrified_tree_med", rock_petrified_tree_med, rock_petrified_tree_assets, prefabs),
    Prefab("rock_petrified_tree_tall", rock_petrified_tree_tall, rock_petrified_tree_assets, prefabs),
    Prefab("rock_petrified_tree_short", rock_petrified_tree_short, rock_petrified_tree_assets, prefabs),
    Prefab("rock_petrified_tree_old", rock_petrified_tree_old, rock_petrified_tree_assets, prefabs)
