local assets =
{
    Asset("ANIM", "anim/oceantree_short.zip"),
    Asset("ANIM", "anim/oceantree_normal.zip"),
    Asset("ANIM", "anim/oceantree_tall.zip"),
    Asset("ANIM", "anim/oceantree_tall_jammed_build.zip"),

    Asset("SOUND", "sound/forest.fsb"),

    Asset("MINIMAP_IMAGE", "oceantree_tall"),

    Asset("MINIMAP_IMAGE", "oceantree_burnt"),
    Asset("MINIMAP_IMAGE", "oceantree_stump"),
}

local prefabs =
{
    "log",
    "charcoal",
    "pine_needles_chop",
    "small_puff",
    "oceantreenut",
    "splash_green",
    "splash_green_large",
    "oceantree_pillar",
    "oceantree_ripples_short",
    "oceantree_ripples_normal",
    "oceantree_ripples_tall",
    "oceantree_roots_short",
    "oceantree_roots_normal",
    "oceantree_roots_tall",
    "oceantree_falling",
    "collapse_small",
    "oceantree_leaf_fx_chop",
}

local falling_prefabs =
{
    "splash_green",
    "splash_green_large",
}

local tree_data =
{
    prefab_name="oceantree",
    regrowth_tuning=TUNING.EVERGREEN_REGROWTH,
    grow_times=TUNING.EVERGREEN_GROW_TIME,
    normal_loot = {"log", "log"},
    short_loot = {"log"},
    tall_loot = {"log", "log", "log"},
    oceantreenut_chance_short = nil,
    oceantreenut_chance_medium = 0.25,
    oceantreenut_chance_tall = 1,
    chop_camshake_delay=0.4,
}

local anims = {
    idle="idle",
    sway1="sway1_loop",
    sway2="sway2_loop",
    chop="chop",
    fallleft="fallleft",
    fallright="fallright",
    stump="stump",
    burning="burning_loop",
    burnt="burnt",
    chop_burnt="chop_burnt",
    idle_chop_burnt="idle_chop_burnt",
}

local STAGES_TO_SUPERTALL = 4

local function update_ripples_roots(inst)
    --@waterlog_todo: since the growable cmp is removed on burn/chop down this won't work when trees in those
    -- states are saved and loaded (since this fn otherwise relies on growable.stage)

    if inst.ripples ~= nil then
        inst.ripples:Remove()
    end

    if inst.roots ~= nil then
        inst.roots:Remove()
    end

    if inst.components.growable == nil then return end

    local suffix = inst.components.growable.stage == 3 and "tall" or inst.components.growable.stage == 2 and "normal" or "short"

    inst.ripples = SpawnPrefab("oceantree_ripples_"..suffix)
    inst.ripples.entity:SetParent(inst.entity)
    
    inst.roots = SpawnPrefab("oceantree_roots_"..suffix)
    inst.roots.entity:SetParent(inst.entity)
end

local function IsEnriched(inst)
    return inst.components.timer ~= nil and inst.components.timer:TimerExists("enriched_cooldown")
end

local function dig_up_stump(inst, chopper)
    inst.components.lootdropper:SpawnLootPrefab("log")
    inst:Remove()
end

local function chop_down_burnt_tree(inst, chopper)
    inst:RemoveComponent("workable")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    inst.AnimState:PlayAnimation(inst.anims.chop_burnt)
    RemovePhysicsColliders(inst)
    inst:ListenForEvent("animover", inst.Remove)
    inst.components.lootdropper:SpawnLootPrefab("charcoal")
    inst.components.lootdropper:DropLoot()
end

local function OnBurnt(inst, immediate)
    local function changes()
        if inst.components.burnable ~= nil then
            inst.components.burnable:Extinguish()
        end
        inst:RemoveComponent("burnable")
        inst:RemoveComponent("propagator")
        inst:RemoveComponent("growable")
        inst:RemoveComponent("hauntable")
        inst:RemoveTag("shelter")
        MakeHauntableWork(inst)

        inst.components.lootdropper:SetLoot({})

        if inst.components.workable then
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnWorkCallback(nil)
            inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
        end
    end

    if immediate then
        changes()
    else
        inst:DoTaskInTime(.5, changes)
    end
    inst.AnimState:PlayAnimation(inst.anims.burnt, true)

    inst.AnimState:SetRayTestOnBB(true)
    inst:AddTag("burnt")

    inst.MiniMapEntity:SetIcon("oceantree_burnt.png")
end

local function PushSway(inst)
    inst.AnimState:PushAnimation(math.random() > .5 and inst.anims.sway1 or inst.anims.sway2, true)
end

local function Sway(inst)
    inst.AnimState:PlayAnimation(math.random() > .5 and inst.anims.sway1 or inst.anims.sway2, true)
end

local function Sprout(inst)
    inst.AnimState:PlayAnimation("grow_seed_to_short")

    PushSway(inst)

    SpawnPrefab("splash_green").Transform:SetPosition(inst:GetPosition():Get())
end

local function SetShort(inst)
    inst.drop_oceantreenut_chance = tree_data.oceantreenut_chance_short

    inst.AnimState:SetBank("oceantree_short")
    inst.AnimState:SetBuild("oceantree_short")

    if inst.components.workable then
        inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_SMALL)
    end

    inst.components.lootdropper:SetLoot(tree_data.short_loot)

    inst:AddTag("shelter")

    Sway(inst)

    update_ripples_roots(inst)
end

local function GrowShort(inst)
    inst.AnimState:PlayAnimation("grow_tall_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    PushSway(inst)
end

local function SetNormal(inst)
    inst.drop_oceantreenut_chance = tree_data.oceantreenut_chance_medium

    inst.AnimState:SetBank("oceantree_normal")
    inst.AnimState:SetBuild("oceantree_normal")

    if inst.components.workable then
        inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_NORMAL)
    end

    inst.components.lootdropper:SetLoot(tree_data.normal_loot)

    inst:AddTag("shelter")

    Sway(inst)

    update_ripples_roots(inst)
end

local function GrowNormal(inst)
    inst.AnimState:PlayAnimation("grow_short_to_normal")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    PushSway(inst)
end

local function SetTall(inst)
    inst.drop_oceantreenut_chance = tree_data.oceantreenut_chance_tall

    inst.AnimState:SetBank("oceantree_tall")
    inst.AnimState:SetBuild("oceantree_tall")

    if inst.components.workable then
        inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_TALL)
    end

    inst.components.lootdropper:SetLoot(tree_data.tall_loot)
    
    inst:AddTag("shelter")

    Sway(inst)

    update_ripples_roots(inst)
end

local function GrowTall(inst)
    inst.AnimState:PlayAnimation("grow_normal_to_tall")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    PushSway(inst)
end

local function inspect_tree(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst:HasTag("stump") and "CHOPPED")
        or nil
end

local growth_stages =
{
    {
        name = "short",
        time = function(inst) return GetRandomWithVariance(tree_data.grow_times[1].base, tree_data.grow_times[1].random) end,
        fn = SetShort,
        growfn = GrowShort,
    },
    {
        name = "normal",
        time = function(inst) return GetRandomWithVariance(tree_data.grow_times[2].base, tree_data.grow_times[2].random) end,
        fn = SetNormal,
        growfn = GrowNormal,
    },
    {
        name = "tall",
        time = function(inst) return GetRandomWithVariance(tree_data.grow_times[3].base, tree_data.grow_times[3].random) end,
        fn = SetTall,
        growfn = GrowTall,
    },
}

local function chop_tree(inst, chopper, chopsleft, numchops)

    
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then

            inst.SoundEmitter:PlaySound(
                chopper ~= nil and chopper:HasTag("beaver") and
                "dontstarve/characters/woodie/beaver_chop_tree" or
                chopper ~= nil and chopper:HasTag("boat") and
                "dontstarve/characters/woodie/beaver_chop_tree" or
                "dontstarve/wilson/use_axe_tree"
            )
    end

    inst.AnimState:PlayAnimation(inst.anims.chop)
    inst.AnimState:PushAnimation(inst.anims.sway1, true)
    
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("oceantree_leaf_fx_chop").Transform:SetPosition(x, y + math.random() * 2, z)
end

local function make_stump(inst)
    inst:RemoveComponent("burnable")
    MakeSmallBurnable(inst)
    inst:RemoveComponent("propagator")
    MakeSmallPropagator(inst)
    inst:RemoveComponent("workable")
    inst:RemoveTag("shelter")
    inst:RemoveComponent("hauntable")
    MakeHauntableIgnite(inst)

    local x, _, z = inst.Transform:GetWorldPosition()
    if not TheWorld.Map:IsOceanAtPoint(x, 0, z) then
        RemovePhysicsColliders(inst)
    end

    inst:AddTag("stump")
    if inst.components.growable ~= nil then
        inst.components.growable:StopGrowing()
    end

    inst.MiniMapEntity:SetIcon("oceantree_stump.png")
end

local function chop_down_tree(inst, chopper)
    local pt = inst:GetPosition()

    local he_right = true

    if chopper then
        local hispos = chopper:GetPosition()
        he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0
    else
        if math.random() > 0.5 then
            he_right = false
        end
    end

    local falling_tree = SpawnPrefab("oceantree_falling")
    falling_tree.Transform:SetPosition(inst:GetPosition():Get())
    if  inst.buds_used then
        for i,bud in ipairs(inst.buds_used) do
            falling_tree.AnimState:Show("tree_bud"..bud)
        end
    end

    local stage = inst.components.growable and inst.components.growable.stage or 3
    local bank = "oceantree_"..growth_stages[stage].name

    if he_right then
        falling_tree:start_falling_fn(inst.AnimState:GetBuild(), bank, true, stage, TheCamera:GetRightVec())
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
    else
        falling_tree:start_falling_fn(inst.AnimState:GetBuild(), bank, false, stage, TheCamera:GetRightVec())
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
    end

    if chopper ~= nil and chopper.components.boatphysics ~= nil then
        inst.components.lootdropper:SpawnLootPrefab("log")
        inst:Remove()
    else
        make_stump(inst)
        inst.AnimState:PlayAnimation(inst.anims.stump)
    end
end

local function tree_burnt(inst)
    OnBurnt(inst)
end

local DAMAGE_SCALE = 0.5
local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * DAMAGE_SCALE / boat_physics.max_velocity + 0.5)
        if inst:HasTag("stump") then
            if hit_velocity >= 0.75 then
                inst.components.lootdropper:SpawnLootPrefab("log")
                SpawnPrefab("collapse_small").Transform:SetPosition(inst:GetPosition():Get())
                inst:Remove()
            end
        elseif inst.components.workable ~= nil then
            inst.components.workable:WorkedBy(data.other, hit_velocity * TUNING.OCEANTREE_CHOPS_NORMAL)
        end
    end
end

local function MakeEnriched(inst)
    inst:DoTaskInTime(15*FRAMES, function() inst.AnimState:SetBuild("oceantree_tall_jammed_build") end)
    inst:AddTag("no_force_grow")

    inst.AnimState:PlayAnimation("gooped")
    PushSway(inst)

    if inst.components.growable ~= nil then
        inst:RemoveComponent("growable")
    end

    inst.no_grow = true
end

local function showbuds(inst)
    for i,num in ipairs(inst.buds_used) do
        inst.AnimState:Show("tree_bud"..num)
    end
end

local function MakeNotEnriched(inst)

    inst:DoTaskInTime(15*FRAMES, function() inst.AnimState:SetBuild("oceantree_"..growth_stages[3].name) end)
    inst.AnimState:PlayAnimation("ungooped")
    PushSway(inst)

    local random = math.random(1,#inst.buds)
    table.insert(inst.buds_used,inst.buds[random])
    table.remove(inst.buds,random)

    showbuds(inst)
        
    inst:RemoveTag("no_force_grow")
end

local function OnTimerDone(inst, data)
    if data.name == "enriched_cooldown" then
         if inst.supertall_growth_progress >= STAGES_TO_SUPERTALL then
            local x, _, z = inst.Transform:GetWorldPosition()

            inst.AnimState:PlayAnimation("grow_tall_to_pillar",false)

            inst.SoundEmitter:PlaySound("waterlogged2/common/watertree_pillar/grow")

            inst:ListenForEvent("animover", function()
                if inst.AnimState:IsCurrentAnimation("grow_tall_to_pillar") then
                    local new_obj = SpawnPrefab("oceantree_pillar")
                    new_obj.Transform:SetPosition(x, 0, z)
                    if new_obj.sproutfn ~= nil then
                        new_obj:sproutfn()
                    end
                    inst:Remove()
                end
            end)
        else
            MakeNotEnriched(inst)
        end
    end
end

local function OnTreeGrowthSolution(inst, item)
    if (inst.supertall_growth_progress ~= nil and inst.supertall_growth_progress > 0) or inst.components.growable.stage == 3 then
        inst.supertall_growth_progress = (inst.supertall_growth_progress or 0) + 1
        MakeEnriched(inst)
        inst.components.timer:StartTimer("enriched_cooldown", TUNING.OCEANTREE_ENRICHED_COOLDOWN_MIN + math.random() * TUNING.OCEANTREE_ENRICHED_COOLDOWN_VARIANCE)
    else
        inst.components.growable:DoGrowth()
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end

    if inst:HasTag("stump") then
        data.stump = true
    end

    if inst.no_grow ~= nil then
        data.no_grow = inst.no_grow
    end

    if inst.buds then
        data.buds = inst.buds
    end
    if inst.buds_used then
        data.buds_used = inst.buds_used
    end

    data.supertall_growth_progress = inst.supertall_growth_progress
end

local function onload(inst, data)
    if data ~= nil then
        if data.stump then
            make_stump(inst)
            inst.AnimState:PlayAnimation(inst.anims.stump)
            if data.burnt or inst:HasTag("burnt") then
                DefaultBurntFn(inst)
            end
        elseif data.burnt and not inst:HasTag("burnt") then
            OnBurnt(inst, true)
        end

        if not inst:IsValid() then
            return
        end

        inst.no_grow = data.no_grow
        if inst.no_grow then
            SetTall(inst)
            if inst.components.growable ~= nil then
                inst:RemoveComponent("growable")
            end
        end
        

        if data.buds then
            inst.buds = data.buds
        end
        if data.buds_used then
            inst.buds_used = data.buds_used
           
        end
        inst.supertall_growth_progress = data.supertall_growth_progress
    end
end

local function onloadpostpass(inst, newents, data)
    if IsEnriched(inst) and not inst:HasTag("stump") and not inst:HasTag("burnt") then
        MakeEnriched(inst)
    end
    showbuds(inst)
end

local function OnEntitySleep(inst)
    local doBurnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning()
    if doBurnt and inst:HasTag("stump") then
        DefaultBurntFn(inst)
    else
        inst:RemoveComponent("burnable")
        inst:RemoveComponent("propagator")
        inst:RemoveComponent("inspectable")
        if doBurnt then
            inst:RemoveComponent("growable")
            inst:AddTag("burnt")
        end
    end
end

local function OnEntityWake(inst)
    if inst:HasTag("burnt") then
        tree_burnt(inst)
    else
        local isstump = inst:HasTag("stump")

        if not (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
            if inst.components.burnable == nil then
                if isstump then
                    MakeSmallBurnable(inst)
                else
                    MakeLargeBurnable(inst, TUNING.TREE_BURN_TIME)
                    inst.components.burnable:SetFXLevel(5)
                    inst.components.burnable:SetOnBurntFn(tree_burnt)
                end
            end

            if inst.components.propagator == nil then
                if isstump then
                    MakeSmallPropagator(inst)
                else
                    MakeMediumPropagator(inst)
                end
            end
        end
    end

    if inst.components.inspectable == nil then
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree
    end
end

local function tree(name, stage, data)
    local function fn()

        if stage == 0 then
            stage = math.random(1, 3)
        end

        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst.MiniMapEntity:SetIcon("oceantree_tall.png")
        inst.MiniMapEntity:SetPriority(-1)

        inst:SetPhysicsRadiusOverride(2.35)
        MakeWaterObstaclePhysics(inst, 0.80, 2, 0.75)
        
        inst:AddTag("ignorewalkableplatforms")
        inst:AddTag("shelter")
        inst:AddTag("plant")
        inst:AddTag("event_trigger")
        inst:AddTag("tree")        
        
        local bank = "oceantree_"..growth_stages[stage].name
        local build = bank
        inst.AnimState:SetBuild(build)
        inst.AnimState:SetBank(bank)        

        local scale = 1.1
        inst.Transform:SetScale(scale, scale, scale)

        inst:SetPrefabName(tree_data.prefab_name)

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.sproutfn = Sprout

        inst.override_treegrowthsolution_fn = OnTreeGrowthSolution
        inst.supertall_growth_progress = 0
        -- inst.no_grow = nil

        -- inst.falling_left = nil

        inst.anims = anims

        local color = .5 + math.random() * .5
        inst.AnimState:SetMultColour(color, color, color, 1)

        -------------------
        MakeLargeBurnable(inst, TUNING.TREE_BURN_TIME)
        inst.components.burnable:SetFXLevel(5)
        inst.components.burnable:SetOnBurntFn(tree_burnt)
        MakeMediumPropagator(inst)

        -------------------
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree

        -------------------
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetOnWorkCallback(chop_tree)
        inst.components.workable:SetOnFinishCallback(chop_down_tree)

        -------------------
        inst:AddComponent("lootdropper")

        ---------------------
        inst:AddComponent("growable")
        inst.components.growable.stages = growth_stages
        inst.components.growable:SetStage(stage)
        inst.components.growable.loopstages = true
        inst.components.growable.springgrowth = true
        inst.components.growable:StartGrowing()

        ---------------------

        inst:AddComponent("timer")

        ---------------------

        inst:AddComponent("hauntable")

        inst:ListenForEvent("on_collide", OnCollide)
        inst:ListenForEvent("timerdone", OnTimerDone)

        ---------------------

        inst.OnSave = onsave
        inst.OnLoad = onload
        inst.OnLoadPostPass = onloadpostpass

        MakeSnowCovered(inst)
        ---------------------

        if data == "stump" then
            inst:AddTag("stump")
            inst:RemoveTag("shelter")

            inst:RemoveComponent("burnable")
            MakeSmallBurnable(inst)
            inst:RemoveComponent("workable")
            inst:RemoveComponent("propagator")
            MakeSmallPropagator(inst)
            inst:RemoveComponent("growable")
            inst.AnimState:PlayAnimation(inst.anims.stump)
            inst.MiniMapEntity:SetIcon("evergreen_stump.png")

            inst:DoTaskInTime(0, function()
                RemovePhysicsColliders(inst)
            end)
        else
            inst.AnimState:SetTime(math.random() * 2)
            if data == "burnt" then
                OnBurnt(inst)
            else
                inst:DoTaskInTime(0, function()
                    local x, _, z = inst.Transform:GetWorldPosition()
                    if not TheWorld.Map:IsOceanAtPoint(x, 0, z) then
                        RemovePhysicsColliders(inst)
                        MakeObstaclePhysics(inst, .25)
                    end
                end)
            end

            update_ripples_roots(inst)
        end

        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake

        inst.buds = {1,2,3,5,6,7}
        inst.buds_used = {}
        for i=1,7 do
            inst.AnimState:Hide("tree_bud"..i)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function make_ripples(name, build)
    local function ripples_fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        
        inst.AnimState:SetBank(build)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("root_ripple", true)

        inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        return inst
    end

    return Prefab(name, ripples_fn)
end

local function make_roots(name, build)
    local function roots_fn(data)
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        
        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
    
        inst.AnimState:SetBank(build)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("root_shadow", false)
    
        inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
        inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)
    
        inst.entity:SetPristine()
    
        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
    
        return inst
    end

    return Prefab(name, roots_fn)
end

local function falling_tree_land(inst)
    local scale, splash_dist, fxprefab
    
    local stage = inst.growth_stage
    if stage >= 3 then
        scale = .5
        splash_dist = 4.5
        fxprefab = "splash_green_large"
    elseif stage >= 2 then
        scale = .25
        splash_dist = 4
        fxprefab = "splash_green_large"
    else
        scale = .25
        splash_dist = 3
        fxprefab = "splash_green"
    end

    ShakeAllCameras(CAMERASHAKE.FULL, .25, .03, scale, inst, 6)
    
    local pt = inst:GetPosition()
    local splash_pt = pt + (inst.camera_right_on_start_falling * splash_dist * (inst.falling_left and -1 or 1))

    if TheWorld.Map:IsOceanAtPoint(splash_pt.x, 0, splash_pt.z, false) then
        SpawnPrefab(fxprefab).Transform:SetPosition(splash_pt.x, 0, splash_pt.z)
        inst:Remove()
    else
        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function falling_tree_start_falling(inst, build, bank, fallleft, growth_stage, camera_right)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")

    inst.falling_left = fallleft
    inst.growth_stage = growth_stage
    inst.camera_right_on_start_falling = camera_right

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(inst.falling_left and "fallleft" or "fallright")
    inst.AnimState:Hide("stump")

    inst.buds = {1,2,3,5,6,7}
    inst.buds_used = {}
    for i=1,7 do
        inst.AnimState:Hide("tree_bud"..i)
    end
    
    --inst.AnimState:Hide("snow")

    inst:DoTaskInTime(tree_data.chop_camshake_delay, falling_tree_land)
end

local function falling_tree_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")        

    -- Build, bank, and anim are set from falling_tree_start_falling()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    
    MakeSnowCovered(inst)
    
    inst.start_falling_fn = falling_tree_start_falling

    return inst
end

return  tree("oceantree", 0),
        tree("oceantree_normal", 2),
        tree("oceantree_tall", 3),
        tree("oceantree_short", 1),

        tree("oceantree_burnt", 0, "burnt"),
        tree("oceantree_stump", 0, "stump"),
        
        make_ripples("oceantree_ripples_short", "oceantree_short"),
        make_ripples("oceantree_ripples_normal", "oceantree_normal"),
        make_ripples("oceantree_ripples_tall", "oceantree_tall"),
        make_roots("oceantree_roots_short", "oceantree_short"),
        make_roots("oceantree_roots_normal", "oceantree_normal"),
        make_roots("oceantree_roots_tall", "oceantree_tall"),

        Prefab("oceantree_falling", falling_tree_fn)
