require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/madscience_lab.zip"),
}

local prefabs =
{
    "madscience_lab_fire",
    "madscience_lab_goop",
    "madscience_lab_glow",
    "collapse_small",
}

local SCIENCE_STAGES =
{
    { time = 2, anim = "cooking_loop1", fire_anim = "fire1"},
    { time = 2, anim = "cooking_loop2", fire_anim = "fire1"},
    { time = 2, anim = "cooking_loop3", pre_anim = "cooking_loop3_pre", fire_pre_anim = "fire3_pre", fire_anim = "fire3"},
}

local EXPERIMENT_RESULTS =
{
    halloween_experiment_bravery =
    {
        halloweenpotion_bravery_small = 2,
        halloweenpotion_bravery_large = 1,
    },
    halloween_experiment_health =
    {
        halloweenpotion_health_small = 2,
        halloweenpotion_health_large = 1,
    },
    halloween_experiment_sanity =
    {
        halloweenpotion_sanity_small = 2,
        halloweenpotion_sanity_large = 1,
    },
    halloween_experiment_volatile =
    {
        halloweenpotion_embers = 1,
        halloweenpotion_sparks = 1,
    },
    halloween_experiment_moon =
    {
        halloweenpotion_moon = 1,
    },
    halloween_experiment_root =
    {
        livingtree_root = 1,
    },
}

local NUM_TO_SPAWN =
{
	halloweenpotion_moon = { [1] = 0.5, [2] = 0.3, [3] = 0.2 },
}

for _, v in pairs(EXPERIMENT_RESULTS) do
    for k, _ in pairs(v) do
		table.insert(prefabs, k)
    end
end

local function PlayAnimation(inst, anim, loop)
    inst.AnimState:PlayAnimation(anim, loop)
    inst._goop.AnimState:PlayAnimation(anim, loop)
    inst._glow.AnimState:PlayAnimation(anim, loop)
end

local function PushAnimation(inst, anim, loop)
    inst.AnimState:PushAnimation(anim, loop)
    inst._goop.AnimState:PushAnimation(anim, loop)
    inst._glow.AnimState:PushAnimation(anim, loop)
end

local function StartMakingScience(inst, doer, recipe)
    if recipe.product ~= nil then
        inst.components.madsciencelab:StartMakingScience(recipe.product)
    end
end

local function onturnon(inst)
    if inst.components.madsciencelab ~= nil and not inst:HasTag("burnt") and not inst.components.madsciencelab:IsMakingScience() then
        if not (inst.AnimState:IsCurrentAnimation("hit") or inst.AnimState:IsCurrentAnimation("place")) then
            PlayAnimation(inst, "proximity_loop", true)
        else
            PushAnimation(inst, "proximity_loop", true)
        end

        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:PlaySound("dontstarve/halloween_2018/madscience_machine/idle_LP", "loop")
    end
end

local function onturnoff(inst)
    if inst.components.madsciencelab ~= nil and not inst:HasTag("burnt") and not inst.components.madsciencelab:IsMakingScience() then
        PushAnimation(inst, "idle", false)
        inst.SoundEmitter:KillSound("loop")
    end
end

local function MakePrototyper(inst)
    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.onactivate = StartMakingScience
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.MADSCIENCE
end

local function MakeFireFx(owner)
    local fx = SpawnPrefab("madscience_lab_fire")
    fx.entity:SetParent(owner.entity)
    fx.entity:AddFollower()
    fx.Follower:FollowSymbol(owner.GUID, "fire_guide", 0, 0, 0)

    owner._firefx = fx

    owner.Light:Enable(true)
end

local function RemoveFireFx(owner)
    if owner._firefx ~= nil then
        if owner._firefx:IsValid() then
            owner._firefx:Remove()
        end
        owner._firefx = nil
    end
    owner.Light:Enable(false)
end

local function OnInactive(inst)
    if not inst:HasTag("burnt") then
        inst:RemoveEventCallback("animover", OnInactive)
        PlayAnimation(inst, "idle", true)
        MakePrototyper(inst)
        RemoveFireFx(inst)
    end
end

local function OnFireFXOver(firefx)
    local owner = firefx.entity:GetParent()
    firefx:Remove()
    if owner ~= nil then
        RemoveFireFx(owner)
    end
end

local function OnStageStarted(inst, stage)
    inst:RemoveComponent("prototyper")

    if SCIENCE_STAGES[stage].pre_anim then
        PlayAnimation(inst, SCIENCE_STAGES[stage].pre_anim)
    end
    PushAnimation(inst, SCIENCE_STAGES[stage].anim, true)

    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve/halloween_2018/madscience_machine/cooking_LP", "loop", stage / #SCIENCE_STAGES)

    RemoveFireFx(inst)
    MakeFireFx(inst)
    if SCIENCE_STAGES[stage].fire_pre_anim then
        inst._firefx.AnimState:PlayAnimation(SCIENCE_STAGES[stage].fire_pre_anim)
    end
    inst._firefx.AnimState:PushAnimation(SCIENCE_STAGES[stage].fire_anim, true)
end

local function OnScienceWasMade(inst, experiement_id)
	local result = EXPERIMENT_RESULTS[experiement_id] ~= nil and weighted_random_choice(EXPERIMENT_RESULTS[experiement_id]) or nil
	if result ~= nil then
		local weights = NUM_TO_SPAWN[result]
		local num_to_spawn = weights ~= nil and weighted_random_choice(weights) or 1

		local x, y, z = inst.Transform:GetWorldPosition()
		for i=1,num_to_spawn do
			LaunchAt(SpawnPrefab(result), inst, FindClosestPlayer(x, y, z, true), 1, 2.5, 1)
		end
	end

    PlayAnimation(inst, "cooking_finish")
    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve/halloween_2018/madscience_machine/finish")
    inst:ListenForEvent("animover", OnInactive)

    inst._firefx.AnimState:PlayAnimation("cooking_finish_fire")
    inst:ListenForEvent("animover", OnFireFXOver, inst._firefx)
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")

    inst:Remove()
end

local function onhit(inst, worker)
    if not inst.AnimState:IsCurrentAnimation("cooking_finish") then
        if inst.components.madsciencelab ~= nil and inst.components.madsciencelab:IsMakingScience() then
            PlayAnimation(inst, "hit")
            PushAnimation(inst, SCIENCE_STAGES[inst.components.madsciencelab.stage].anim, true)
        elseif inst.components.prototyper ~= nil and inst.components.prototyper.on then
            PlayAnimation(inst, "hit")
            inst.SoundEmitter:PlaySound("dontstarve/halloween_2018/madscience_machine/hit")
            onturnon(inst)
        else
            PlayAnimation(inst, "hit")
            inst.SoundEmitter:PlaySound("dontstarve/halloween_2018/madscience_machine/hit")
            PushAnimation(inst, "idle", false)
        end
    end
end

local function getstatus(inst)
    return (inst.components.madsciencelab:IsMakingScience() and "MIXING")
        or nil
end

local function onbuilt(inst)
    PlayAnimation(inst, "place")
    PushAnimation(inst, "idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/halloween_2018/madscience_machine/place")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(1.25) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("madscience_lab.png")

    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1.5)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(250/255,180/255,50/255)
   -- inst.Light:EnableClientModulation(true)

    inst:AddTag("structure")
	inst:AddTag("madsciencelab")

    inst.AnimState:SetBank("madscience_lab")
    inst.AnimState:SetBuild("madscience_lab")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:Hide("goop")
    inst.AnimState:Hide("glow")
    inst.AnimState:SetLightOverride(.05)

    MakeSnowCoveredPristine(inst)

    inst.scrapbook_specialinfo = "MADSCIENCELAB"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._goop = SpawnPrefab("madscience_lab_goop")
    inst._goop.entity:SetParent(inst.entity)

    inst._glow = SpawnPrefab("madscience_lab_glow")
    inst._glow.entity:SetParent(inst.entity)
	inst.highlightchildren = { inst._glow }

    inst._firefx = nil

    MakePrototyper(inst)

    inst:AddComponent("madsciencelab")
    inst.components.madsciencelab.OnStageStarted = OnStageStarted
    inst.components.madsciencelab.OnScienceWasMade = OnScienceWasMade
    inst.components.madsciencelab.stages = SCIENCE_STAGES

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeSnowCovered(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

-------------------------------------------------------------------------------

local function fire_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("madscience_lab")
    inst.AnimState:SetBuild("madscience_lab")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:PlayAnimation(SCIENCE_STAGES[1].fire_anim)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function goop_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("madscience_lab")
    inst.AnimState:SetBuild("madscience_lab")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(.5)
    inst.AnimState:Hide("lab")
    inst.AnimState:Hide("glow")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function glow_OnEntityReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.prefab == "madscience_lab" then
        parent.highlightchildren = { inst }
    end
end

local function glow_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("madscience_lab")
    inst.AnimState:SetBuild("madscience_lab")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(.3)
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:Hide("lab")
    inst.AnimState:Hide("goop")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = glow_OnEntityReplicated

        return inst
    end

    inst.persists = false

    return inst
end

local function dummy_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()

    --[[Non-networked entity]]
    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
		return inst
	end

    inst.persists = false
	inst:DoTaskInTime(0, inst.Remove)
	return inst
end


local prefab_list = {}
table.insert(prefab_list, Prefab("madscience_lab", fn, assets, prefabs))
table.insert(prefab_list, Prefab("madscience_lab_goop", goop_fn))
table.insert(prefab_list, Prefab("madscience_lab_fire", fire_fn))
table.insert(prefab_list, Prefab("madscience_lab_glow", glow_fn))
table.insert(prefab_list, MakePlacer("madscience_lab_placer", "madscience_lab", "madscience_lab", "idle"))

-- add fake prefabs for all the experiments so the game doesnt log about non-existing prefabs due to recipes
for k, _ in pairs(EXPERIMENT_RESULTS) do
    table.insert(prefab_list, Prefab(k, dummy_fn))
end

return unpack(prefab_list)
