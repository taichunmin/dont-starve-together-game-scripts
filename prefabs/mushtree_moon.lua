local function tree_burnt(inst)
    inst.components.lootdropper:SpawnLootPrefab("ash")
    if math.random() < 0.5 then
        inst.components.lootdropper:SpawnLootPrefab("charcoal")
    end
    SpawnPrefab(inst.prefab.."_burntfx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function stump_burnt(inst)
    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function dig_up_stump(inst)
    inst.components.lootdropper:SpawnLootPrefab("log")
    inst:Remove()
end

local function inspect_tree(inst)
    return (inst:HasTag("stump") and "CHOPPED")
        or nil
end

local function onspawnfn(inst, spawn)
    inst.AnimState:PlayAnimation("cough")
    inst.AnimState:PushAnimation("idle_loop", true)

    inst.SoundEmitter:PlaySound("dontstarve/cave/mushtree_tall_spore_fart")

    local pos = inst:GetPosition()
    local radius = spawn:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0) + 0.75
    local offset = FindWalkableOffset(pos, math.random() * 2 * PI, radius, 8)

    if offset ~= nil then
        pos = pos + offset
    end

    spawn.Transform:SetPosition(pos.x, 0, pos.z)
end

local REMOVABLE =
{
    ["log"] = true,
    ["moon_cap"] = true,
    ["charcoal"] = true,
}

local DECAYREMOVE_MUST_TAGS = { "_inventoryitem" }
local DECAYREMOVE_CANT_TAGS = { "INLIMBO", "fire" }
local function ontimerdone(inst, data)
    if data.name == "decay" then
        local x, y, z = inst.Transform:GetWorldPosition()
        if inst:IsAsleep() then
            -- before we disappear, clean up any crap left on the ground
            -- too many objects is as bad for server health as too few!
            local leftone = false
            for i, v in ipairs(TheSim:FindEntities(x, y, z, 6, DECAYREMOVE_MUST_TAGS, DECAYREMOVE_CANT_TAGS)) do
                if REMOVABLE[v.prefab] then
                    if leftone then
                        v:Remove()
                    else
                        leftone = true
                    end
                end
            end
        else
            SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
        end
        inst:Remove()
    end
end

local data =
{
    moon =
    {
        bank = "mushroom_tree",
        build = "mutatedmushroom_tree_build",
        spore = "spore_moon",
        icon = "mushtree_moon.png",
        loot =
        {
            "log",
            "log",
            "moon_cap",
        },
        work = TUNING.MUSHTREE_CHOPS_TALL,
        lightradius = 1.25,
        lightcolour = { 227/255, 227/255, 227/255 },
    },
}

local function onsave(inst, data)
    data.burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or nil
    data.stump = inst:HasTag("stump") or nil
end

--V2C: Not using an fx proxy because this was originally meant to be an
--     animated death state of the original entity so it would probably
--     look more consistent this way.
--     BTW this was done so that the burnt state can immediately remove
--     the original entity rather than creating edge case bugs while it
--     was still interactable during the crumbling animation.
local function makeburntfx(name, data)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBuild(data.build)
        inst.AnimState:SetBank(data.bank)
        inst.AnimState:PlayAnimation("chop_burnt")

        inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:ListenForEvent("animover", inst.Remove)
        -- In case we're off screen and animation is asleep
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)

        return inst
    end
end

local function swapbuild(inst, build)
    inst._changetask = nil
    if not inst:HasTag("stump") then
        inst.AnimState:SetBuild(build)
    end
end

local function startchange(inst, build, soundname)
    if inst:HasTag("stump") then
        inst._changetask = nil
    else
        inst.AnimState:PlayAnimation("change")
        inst.AnimState:PushAnimation("idle_loop", true)
        inst.SoundEmitter:PlaySound(soundname)
        inst._changetask = inst:DoTaskInTime(14 * FRAMES, swapbuild, build)
    end
end

local function workcallback(inst, worker, workleft)
    if not (worker ~= nil and worker:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_mushroom")
    end
    if workleft > 0 then
        inst.AnimState:PlayAnimation("chop")
        inst.AnimState:PushAnimation("idle_loop", true)

        inst.components.periodicspawner:ForceNextSpawn()
    end
    --V2C: different anims are played in workfinishcallback if workleft <= 0
end

local function maketree(name, data, state)
    local function normal_tree(inst, instant)
        if inst._changetask ~= nil then
            inst._changetask:Cancel()
        end
        if instant then
            swapbuild(inst, data.build)
        else
            inst._changetask = inst:DoTaskInTime(math.random() * 3 * TUNING.SEG_TIME, startchange, data.build, "dontstarve/cave/mushtree_tall_shrink")
        end
    end

    local function makestump(inst)
        if inst:HasTag("stump") then
            return
        end

        if inst._changetask ~= nil then
            inst._changetask:Cancel()
            inst._changetask = nil
        end

        RemovePhysicsColliders(inst)

        inst:AddTag("stump")
        inst:RemoveTag("shelter")

        inst:RemoveComponent("propagator")
        inst:RemoveComponent("burnable")

        MakeSmallPropagator(inst)
        MakeSmallBurnable(inst)
        inst.components.burnable:SetOnBurntFn(stump_burnt)

        inst.components.periodicspawner:Stop()

        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetOnWorkCallback(nil)
        inst.components.workable:SetOnFinishCallback(dig_up_stump)
        inst.components.workable:SetWorkLeft(1)

        inst.AnimState:PlayAnimation("idle_stump")

        inst.MiniMapEntity:SetIcon("mushroom_tree_stump.png")

        inst.Light:Enable(false)

        inst:ListenForEvent("timerdone", ontimerdone)

        if not inst.components.timer:TimerExists("decay") then
            inst.components.timer:StartTimer("decay", GetRandomWithVariance(TUNING.MUSHTREE_REGROWTH.DEAD_DECAY_TIME, TUNING.MUSHTREE_REGROWTH.DEAD_DECAY_TIME * .5))
        end
    end

    local function workfinishcallback(inst)
        inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
        makestump(inst)

        inst.AnimState:PlayAnimation("fall")
        inst.AnimState:PushAnimation("idle_stump")

        inst.components.lootdropper:DropLoot(inst:GetPosition())
    end

    local function onload(inst, loaddata)
        if loaddata ~= nil then
            if loaddata.burnt then
                if loaddata.stump then
                    stump_burnt(inst)
                else
                    tree_burnt(inst)
                end
            elseif loaddata.stump then
                makestump(inst)
            else
                normal_tree(inst, true)
            end
        end
    end

    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .25)

        inst.AnimState:SetBuild(data.build)
        inst.AnimState:SetBank(data.bank)
        inst.AnimState:PlayAnimation("idle_loop", true)

        inst.MiniMapEntity:SetIcon(data.icon)

        inst.Light:SetFalloff(.5)
        inst.Light:SetIntensity(.8)
        inst.Light:SetRadius(data.lightradius)
        inst.Light:SetColour(unpack(data.lightcolour))

        inst:AddTag("cavedweller")
        inst:AddTag("mushtree")
        inst:AddTag("plant")
        inst:AddTag("shelter")
        inst:AddTag("tree")

        inst:SetPrefabName(name)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        local color = .5 + math.random() * .5
        inst.AnimState:SetMultColour(color, color, color, 1)
        inst.AnimState:SetTime(math.random() * 2)

        MakeMediumPropagator(inst)
        MakeLargeBurnable(inst)
        inst.components.burnable:SetFXLevel(5)
        inst.components.burnable:SetOnBurntFn(tree_burnt)

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot(data.loot)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetWorkLeft(data.work)
        inst.components.workable:SetOnWorkCallback(workcallback)
        inst.components.workable:SetOnFinishCallback(workfinishcallback)

        inst:AddComponent("periodicspawner")
        inst.components.periodicspawner:SetPrefab(data.spore)
        inst.components.periodicspawner:SetOnSpawnFn(onspawnfn)
        inst.components.periodicspawner:SetDensityInRange(TUNING.MUSHSPORE_MAX_DENSITY_RAD, TUNING.MUSHSPORE_MAX_DENSITY)
        inst.components.periodicspawner:Stop()

        inst:AddComponent("plantregrowth")
        inst.components.plantregrowth:SetRegrowthRate(TUNING.MUSHTREE_REGROWTH.OFFSPRING_TIME)
        inst.components.plantregrowth:SetProduct(name)
        inst.components.plantregrowth:SetSearchTag("mushtree")

        inst:AddComponent("timer")

        MakeHauntableIgnite(inst)

        inst.OnSave = onsave
        inst.OnLoad = onload

        if state == "stump" then
            makestump(inst)
        else
            normal_tree(inst, true)
        end

        return inst
    end
end

local treeprefabs = {}
function treeset(name, data, build_file_name)
    local buildasset = Asset("ANIM", build_file_name)
    local assets =
    {
        buildasset,
        Asset("MINIMAP_IMAGE", data.icon),
        Asset("MINIMAP_IMAGE", "mushroom_tree_stump"),
    }

    local prefabs =
    {
        data.spore,
        name.."_stump",
        name.."_burntfx",
        "ash",
        "charcoal",
        "log",
        "small_puff",
        "moon_cap",
    }

    table.insert(treeprefabs, Prefab(name, maketree(name, data), assets, prefabs))
    table.insert(treeprefabs, Prefab(name.."_stump", maketree(name, data, "stump"), assets, prefabs))
    table.insert(treeprefabs, Prefab(name.."_burntfx", makeburntfx(name, data, false), { buildasset }))
end

treeset("mushtree_moon", data.moon, "anim/mutatedmushroom_tree_build.zip")

return unpack(treeprefabs)
