local assets =
{
    Asset("ANIM", "anim/rock_avocado.zip"),
    Asset("ANIM", "anim/rock_avocado_build.zip"),
    Asset("ANIM", "anim/rock_avocado_diseased_build.zip"),
    Asset("MINIMAP_IMAGE", "rock_avocado"),
}

local prefabs =
{
    "rock_avocado_fruit",
    "dug_rock_avocado_bush",
    "twigs",
}

local BUSH_ANIMS =
{
    { idle="idle1", grow = "crumble" },
    { idle="idle2", grow = "grow1" },
    { idle="idle3", grow = "grow2" },
    { idle="idle4", grow = "grow3" },
}

local function play_idle(inst, stage)
    inst.AnimState:PlayAnimation(BUSH_ANIMS[stage].idle)
end

local function play_grow(inst, stage)
    inst.AnimState:PlayAnimation(BUSH_ANIMS[stage].grow)
    inst.AnimState:PushAnimation(BUSH_ANIMS[stage].idle)
end

local function set_stage1(inst)
    inst.components.pickable:ChangeProduct(nil)

    inst.components.pickable.canbepicked = false

    play_idle(inst, 1)
end

local function grow_to_stage1(inst)
    play_grow(inst, 1)
end

local function set_stage2(inst)
    inst.components.pickable:ChangeProduct(nil)

    inst.components.pickable.canbepicked = false

    play_idle(inst, 2)
end

local function grow_to_stage2(inst)
    play_grow(inst, 2)
end

local function set_stage3(inst)
    inst.components.pickable:ChangeProduct("rock_avocado_fruit")

    inst.components.pickable:Regen()

    play_idle(inst, 3)
end

local function grow_to_stage3(inst)
    play_grow(inst, 3)
end

local function set_stage4(inst)
    inst.components.pickable:ChangeProduct(nil)

    -- If we got set here directly, instead of going through stage 3, we still need to be pickable.
    if not inst.components.pickable:CanBePicked() then
        inst.components.pickable:Regen()
    end

    play_idle(inst, 4)
end

local function grow_to_stage4(inst)
    play_grow(inst, 4)
end

local STAGE1 = "stage_1"
local STAGE2 = "stage_2"
local STAGE3 = "stage_3"
local STAGE4 = "stage_4"

local growth_stages =
{
    {
        name = STAGE1,
        time = function(inst) return GetRandomWithVariance(TUNING.ROCK_FRUIT_REGROW.EMPTY.BASE, TUNING.ROCK_FRUIT_REGROW.EMPTY.VAR) end,
        fn = set_stage1,
        growfn = grow_to_stage1,
    },
    {
        name = STAGE2,
        time = function(inst) return GetRandomWithVariance(TUNING.ROCK_FRUIT_REGROW.PREPICK.BASE, TUNING.ROCK_FRUIT_REGROW.PREPICK.VAR) end,
        fn = set_stage2,
        growfn = grow_to_stage2,
    },
    {
        name = STAGE3,
        time = function(inst) return GetRandomWithVariance(TUNING.ROCK_FRUIT_REGROW.PICK.BASE, TUNING.ROCK_FRUIT_REGROW.PICK.VAR) end,
        fn = set_stage3,
        growfn = grow_to_stage3,
    },
    {
        name = STAGE4,
        time = function(inst) return GetRandomWithVariance(TUNING.ROCK_FRUIT_REGROW.CRUMBLE.BASE, TUNING.ROCK_FRUIT_REGROW.CRUMBLE.VAR) end,
        fn = set_stage4,
        growfn = grow_to_stage4,
    },
}

local function onregenfn(inst)
    -- If we got here via debug and we're not at pickable yet, just skip us ahead to the first pickable stage.
    if inst.components.growable.stage < 3 then
        inst.components.growable:SetStage(3)
    end
end

local function on_bush_burnt(inst)
    -- Since the rock avocados themselves are rock hard, they don't burn up, but the bush does!
    if inst.components.growable.stage == 3 then
        inst.components.lootdropper:SpawnLootPrefab("rock_avocado_fruit")
        inst.components.lootdropper:SpawnLootPrefab("rock_avocado_fruit")
        inst.components.lootdropper:SpawnLootPrefab("rock_avocado_fruit")
    end

    -- The bush, of course, stops growing once it's been burnt.
    inst.components.growable:StopGrowing()

    DefaultBurntFn(inst)
end

local function on_ignite(inst)
    -- Function empty; we make a custom function just to bypass the persists = false portion of the default ignite function.
end

local function on_dug_up(inst, digger)
    local withered = inst.components.witherable ~= nil and inst.components.witherable:IsWithered()

    if withered or inst.components.pickable:IsBarren() then
        -- If we're withered, digging us up just drops twigs
        inst.components.lootdropper:SpawnLootPrefab("twigs")
        inst.components.lootdropper:SpawnLootPrefab("twigs")
    else
        -- Even though we have a digger, we don't want the produce to go directly
        -- to their inventory, so we still just harvest without a harvester.
        if inst.components.growable.stage == 3 then
            inst.components.lootdropper:SpawnLootPrefab("rock_avocado_fruit")
            inst.components.lootdropper:SpawnLootPrefab("rock_avocado_fruit")
            inst.components.lootdropper:SpawnLootPrefab("rock_avocado_fruit")
        end

        inst.components.lootdropper:SpawnLootPrefab("dug_rock_avocado_bush")
    end

    -- This actual bush is now no longer needed.
    inst:Remove()
end

local function onpickedfn(inst, picker)
    local picked_anim = (inst.components.growable.stage == 3 and "picked") or "crumble"

    inst.components.growable:SetStage(1)

    -- Play the proper picked animation.
    inst.AnimState:PlayAnimation(picked_anim)
    if inst.components.pickable:IsBarren() then
        -- NOTE: IsBarren just tests cycles_left; MakeBarren hasn't actually been called!
        -- So we need to do the relevant parts of that function. Copied here just to not overload SetStage/animations.
        inst.AnimState:PushAnimation("idle1_to_dead1", false)
        inst.AnimState:PushAnimation("dead1", false)
        inst.components.growable:StopGrowing()
        inst.components.growable.magicgrowable = false
    else
        inst.AnimState:PushAnimation("idle1", false)
    end
end

local function makeemptyfn(inst)
    if not POPULATING then
        -- SetStage(1) will change the animation, so store whether we came into this function dead first.
        local emptying_dead = inst.AnimState:IsCurrentAnimation("dead1")

        inst.components.growable:SetStage(1)
        inst.components.growable:StartGrowing()
        inst.components.growable.magicgrowable = true

        if not (inst:HasTag("withered") or emptying_dead) then
            inst.AnimState:PlayAnimation("idle1", false)
        else
            inst.AnimState:PlayAnimation("dead1_to_idle1")
            inst.AnimState:PushAnimation("idle1", false)
        end
    end
end

local function makebarrenfn(inst, wasempty)
    inst.components.growable:SetStage(1)
    inst.components.growable:StopGrowing()
    inst.components.growable.magicgrowable = false

    if not POPULATING and inst:HasTag("withered") then
        inst.AnimState:PlayAnimation("idle1_to_dead1")
        inst.AnimState:PushAnimation("dead1", false)
    else
        inst.AnimState:PlayAnimation("dead1")
    end
end

local function ontransplantfn(inst)
    inst.components.pickable:MakeBarren()
end

local function on_save(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        data.burning = true
    end
end

local function on_load(inst, data)
    if data == nil then
        return
    end

    if data.burning then
        on_bush_burnt(inst)
    elseif inst.components.witherable:IsWithered() then
        inst.components.witherable:ForceWither()
    elseif not inst.components.pickable:IsBarren() and data.growable ~= nil and data.growable.stage == nil then
        -- growable doesn't call SetStage on load if the stage was saved out as nil (assuming initial state is ok).
        -- Since we randomly choose a stage on prefab creation, we want to explicitly call SetStage(1) for that case.
        inst.components.growable:SetStage(1)
    end
end

local function rock_avocado_bush()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("rock_avocado")
    inst.AnimState:SetBuild("rock_avocado_build")
    inst.AnimState:PlayAnimation("idle1")

    MakeSmallObstaclePhysics(inst, .1)

    inst:AddTag("plant")
    inst:AddTag("renewable")

    inst.MiniMapEntity:SetIcon("rock_avocado.png")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumBurnable(inst)
    inst.components.burnable:SetOnBurntFn(on_bush_burnt)
    inst.components.burnable:SetOnIgniteFn(on_ignite)

    MakeMediumPropagator(inst)

    MakeHauntableIgnite(inst)

    inst:AddComponent("lootdropper")

    if not GetGameModeProperty("disable_transplanting") then
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(on_dug_up)
    end

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"

    -- We will have 3 rock fruit, but we only have real product for one stage, and it's not our initial stage.
    -- We use ChangeProduct to set this up elsewhere.
    inst.components.pickable.numtoharvest = 3
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.makebarrenfn = makebarrenfn
    inst.components.pickable.ontransplantfn = ontransplantfn
    inst.components.pickable.onregenfn = onregenfn

    inst.components.pickable.max_cycles = TUNING.ROCK_FRUIT_PICKABLE_CYCLES
    inst.components.pickable.cycles_left = inst.components.pickable.max_cycles

    inst:AddComponent("witherable")

    inst:AddComponent("inspectable")

    inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst.components.growable.loopstages = true
    inst.components.growable.springgrowth = true
    inst.components.growable.magicgrowable = true
    inst.components.growable:SetStage(math.random(1, 4))
    inst.components.growable:StartGrowing()

    inst.OnSave = on_save
    inst.OnLoad = on_load

    MakeSnowCovered(inst)

    return inst
end

return Prefab("rock_avocado_bush", rock_avocado_bush, assets, prefabs)
