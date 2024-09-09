require "prefabutil" -- For the MakePlacer function.

local ancienttree_defs = require("prefabs/ancienttree_defs")
local TREE_DEFS  = ancienttree_defs.TREE_DEFS
local PLANT_DATA = ancienttree_defs.PLANT_DATA

local WAXED_PLANTS = require "prefabs/waxed_plant_common"

----------------------------------------------------------------------------------------------------------------------

local PAUSE_REASON =
{
    TILE = "WRONG_TILE",
    SEASON = "WRONG_SEASON",
}

local AMBIENCE_SOUNDNAME = "amb"

----------------------------------------------------------------------------------------------------------------------

local statedata =
{
    {
        name		= "seed",
        idleanim    = "idle_planted",
        bank        = "ancienttree_seed",
        build       = "ancienttree_seed",
        tag         = "seedstage",
    },
    {
        name		= "sprout",
        idleanim    = "sprout_idle",
        growanim    = "grow_seed_to_sprout",
    },
}

local function OnSetStage(inst)
    if inst.statedata ~= nil and inst.statedata.tag ~= nil then
        inst:RemoveTag(inst.statedata.tag)
    end

    inst.statedata = statedata[inst.components.growable.stage]

    if inst.statedata ~= nil and inst.statedata.tag ~= nil then
        inst:AddTag(inst.statedata.tag)
    end

    inst.AnimState:SetBank(inst.statedata.bank   or inst._bank )
    inst.AnimState:SetBuild(inst.statedata.build or inst._build)
    inst.AnimState:PlayAnimation(inst.statedata.idleanim, true)

    inst:DoTaskInTime(0, inst.CheckGrowConstraints) -- NOTES(DiogoW): Growable calls StartGrowing after setting a stage.
end

local function OnGrowth(inst)
    if inst:IsAsleep() then
        return
    end

    inst.SoundEmitter:PlaySound(inst.sounds.grow)

    inst.AnimState:PlayAnimation(inst.statedata.growanim)
    inst.AnimState:PushAnimation(inst.statedata.idleanim, true)
end

local function OnGrowthFull(inst)
    local tree = SpawnPrefab("ancienttree_"..inst.type)

    if tree ~= nil then
        tree.Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst:TransferPlantData(tree)
        tree:UpdatePickableRegenTime()

        if tree.components.pickable ~= nil then
            tree.components.pickable:MakeEmpty()
        end

        if inst:IsAsleep() then
            tree.AnimState:PlayAnimation(math.random() < .5 and "sway1_loop" or "sway2_loop", true)
        else
            tree.SoundEmitter:PlaySound(inst.sounds.grow)

            tree.AnimState:PlayAnimation("grow_sprout_to_full")
            tree.AnimState:PushAnimation(math.random() < .5 and "sway1_loop" or "sway2_loop", true)
        end
    end

    inst:Remove()

    return tree -- Mods.
end

local function GetGrowthTime(inst, state)
    return GetRandomWithVariance(TUNING.ANCIENTTREE_GROW_TIME[state].base, TUNING.ANCIENTTREE_GROW_TIME[state].random)
end

local GROWTH_STAGES =
{
    {
        time = GetGrowthTime,
        fn = OnSetStage,
    },
    {
        time = GetGrowthTime,
        growfn = OnGrowth,
        fn = OnSetStage,
    },
    {
        fn = OnGrowthFull,
    },
}

----------------------------------------------------------------------------------------------------------------------

local function Sapling_DigUp(inst)
    local loot = nil

    if inst.components.lootdropper ~= nil then
        if inst.components.growable.stage <= 1 then
            loot = inst.components.lootdropper:SpawnLootPrefab("ancienttree_seed")

            if loot ~= nil then
                loot:SetType(inst.type)
            end
        else
            loot = inst.components.lootdropper:SpawnLootPrefab(inst.prefab.."_item")
        end
    end

    if loot ~= nil then
        inst:TransferPlantData(loot)
    end
    
    inst:Remove()

    return loot -- Mods.
end

local function Sapling_OnDeploy(inst, pt)
    local sapling = SpawnPrefab("ancienttree_"..inst.type.."_sapling")
    sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    sapling.Transform:SetPosition(pt:Get())

    sapling.components.growable:SetStage(2)
    sapling.components.growable:StartGrowing()

    sapling:CheckGrowConstraints()

    inst:TransferPlantData(sapling)

    if inst.components.stackable ~= nil then
        inst.components.stackable:Get():Remove()
    else
        inst:Remove()
    end

    return sapling -- Mods.
end

local function Sapling_CheckGrowConstraints(inst)
    local constraints = TREE_DEFS[inst.type].GROW_CONSTRAINT

    local tile = TheWorld.Map:GetTileAtPoint(inst.Transform:GetWorldPosition())
    local season = TheWorld.state.season

    local correct_tile   = tile == constraints.TILE
    local correct_season = season == constraints.SEASON

    if inst.statedata ~= nil and inst.statedata.name == "seed" then
        -- The seed may grow if one of the requirements are met.
        if correct_tile or correct_season then
            inst.components.growable:Resume(PAUSE_REASON.TILE)
            inst.components.growable:Resume(PAUSE_REASON.SEASON)

            return
        end
    end

    if correct_tile then
        inst.components.growable:Resume(PAUSE_REASON.TILE)
    else
        inst.components.growable:Pause(PAUSE_REASON.TILE)
    end

    if correct_season then
        inst.components.growable:Resume(PAUSE_REASON.SEASON)
    else
        inst.components.growable:Pause(PAUSE_REASON.SEASON)
    end
end

local function Sapling_OnEntityWake(inst)
    local growable = inst.components.growable

    if growable ~= nil and growable.pausedremaining ~= nil and growable.pausedremaining <= 0 then
        -- NOTES(DiogoW): It "grew" offscreen, but waited for Growable:OnEntityWake() to be called and then got paused because of the season change.
        --                It might be worth fixing this in the component sometime.
        growable:Resume(PAUSE_REASON.TILE)
        growable:Resume(PAUSE_REASON.SEASON)
    end
end

local function Sapling_DoMagicGrowthFn(inst, doer)
    inst.magic_growth_delay = nil

    inst:CheckGrowConstraints()

    if not inst.components.growable:IsGrowing() then
        return -- Paused or stopped.
    end

    inst.components.growable:DoGrowth()
end

local function Sapling_GetStatus(inst)
    local pausereasons = inst.components.growable.pausereasons

    return
        pausereasons[PAUSE_REASON.TILE]   and PAUSE_REASON.TILE   or
        pausereasons[PAUSE_REASON.SEASON] and PAUSE_REASON.SEASON or
        nil
end

local function Sapling_DisplayNameFn(inst)
    local is_seed = inst:HasTag("seedstage")

    return STRINGS.NAMES[is_seed and "ANCIENTTREE_SEED_PLANTED" or string.upper(inst.prefab)]
end

----------------------------------------------------------------------------------------------------------------------

local function TransferPlantData(inst, target)
    target._plantdata = inst._plantdata
end

local function PlantData_OnSave(inst, data)
    data.plantdata = inst._plantdata
end

local function PlantData_OnLoad(inst, data)
    if data ~= nil and data.plantdata ~= nil then
        inst._plantdata = data.plantdata
    end
end

----------------------------------------------------------------------------------------------------------------------

local function Full_OnWorked(inst, worker, workleft)
    if inst.directional_fall and not (worker ~= nil and worker:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            worker ~= nil and worker:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree"
        )
    end

    inst.AnimState:PlayAnimation("hit_full")
    inst.AnimState:PushAnimation(math.random() < .5 and "sway1_loop" or "sway2_loop", true)
end

local function Full_DigUpStump(inst, digger)
    inst.components.lootdropper:SetChanceLootTable(inst.prefab.."_stump")
    inst.components.lootdropper:DropLoot()

    inst:Remove()
end

local function Full_MakeStump(inst)
    local is_mineable = inst.components.workable:GetWorkAction() == ACTIONS.MINE
    local work_action = is_mineable and ACTIONS.MINE or ACTIONS.DIG
    local work_left = is_mineable and 3 or 1

    inst:RemoveComponent("workable")
    inst:RemoveComponent("pickable")

    inst:AddTag("stump")
    inst:RemoveTag("shelter")

    RemovePhysicsColliders(inst)

    if inst.DynamicShadow ~= nil then
        inst.DynamicShadow:Enable(false)
    end

    inst.SoundEmitter:KillSound(AMBIENCE_SOUNDNAME)

    inst.MiniMapEntity:SetIcon(inst.prefab.."_stump.png")
    inst.MiniMapEntity:SetPriority(1)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(work_action)
    inst.components.workable:SetOnFinishCallback(Full_DigUpStump)
    inst.components.workable:SetWorkLeft(work_left)
end

local function ShakeCamera(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .25, .03, .5, inst, 6)
end

local function Full_OnWorkedFinish(inst, worker)
    local pt = inst:GetPosition()

    local right, left = pt, pt
    local is_right = math.random() > .5

    if inst.directional_fall then
        if worker ~= nil then
            is_right = (worker:GetPosition() - pt):Dot(TheCamera:GetRightVec()) > 0
        end

        right = right + TheCamera:GetRightVec()
        left  = left  - TheCamera:GetRightVec()
    end

    inst.AnimState:Hide("fruit")
    inst.SoundEmitter:PlaySound(inst.sounds.onworkfinish)

    inst.AnimState:PlayAnimation(is_right and "fallright" or "fallleft")
    inst.AnimState:PushAnimation("stump")

    inst.components.lootdropper:DropLoot(is_right and right or left)

    if inst.components.pickable:CanBePicked() then
        local product_pos = is_right and left or right

        for i=1, inst.components.pickable.numtoharvest do
            inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product, product_pos)
        end
    end

    local seed = inst.components.lootdropper:SpawnLootPrefab("ancienttree_seed", is_right and right or left)

    if seed ~= nil then
        seed:SetType(inst.type)
        inst:TransferPlantData(seed)
    end

    inst:MakeStump()

    inst:DoTaskInTime(16*FRAMES, ShakeCamera)
end

local function Full_OnPickedFn(inst, picker)
    inst.AnimState:Hide("fruit")
end

local function Full_OnMakeEmptyFn(inst)
    inst.AnimState:Hide("fruit")
end

local function _MakeEmpty(inst)
    if inst.components.pickable ~= nil then
        inst.components.pickable:MakeEmpty()
    end
end

local function Full_CanRegenFruits(inst)
    local constraints = TREE_DEFS[inst.type].GROW_CONSTRAINT

    local tile = TheWorld.Map:GetTileAtPoint(inst.Transform:GetWorldPosition())

    -- NOTES(DiogoW): Won't grow fruit on wrong tile!
    return tile == constraints.TILE
end

local function Full_OnRegenFn(inst)
    if not inst:CanRegenFruits() then
        inst:DoTaskInTime(0, _MakeEmpty) -- Needs to be delayed because Pickable:Regen would mess with things set by MakeEmpty.

        return
    end

    inst.AnimState:Show("fruit")

    if inst:IsAsleep() then
        inst.AnimState:PlayAnimation(math.random() < .5 and "sway1_loop" or "sway2_loop", true)
    else
        inst.AnimState:PlayAnimation("fruit_full")
        inst.AnimState:PushAnimation(math.random() < .5 and "sway1_loop" or "sway2_loop", true)

        inst.SoundEmitter:PlaySound(inst.sounds.onshowfruits)
    end
end

local function Full_UpdatePickableRegenTime(inst)
    if inst.components.pickable ~= nil and inst._plantdata ~= nil and inst._plantdata.fruit_regen ~= nil then
        inst.components.pickable.regentime = inst._plantdata.fruit_regen
        inst.components.pickable.baseregentime = inst._plantdata.fruit_regen
    end
end

local function Full_OnSave(inst, data)
    PlantData_OnSave(inst, data)

    if inst:HasTag("stump") then
        data.stump = true
    end
end

local function Full_OnLoad(inst, data)
    PlantData_OnLoad(inst, data)

    if data ~= nil and data.stump then
        inst:MakeStump()
        inst.AnimState:PlayAnimation("stump")
    end

    inst:UpdatePickableRegenTime()
end

local function Full_OnEntityWake(inst)
    if not inst:HasTag("stump") then
        inst.SoundEmitter:PlaySound(inst.sounds.ambience, AMBIENCE_SOUNDNAME)
    end
end

local function Full_OnEntitySleep(inst)
    inst.SoundEmitter:KillSound(AMBIENCE_SOUNDNAME)
end

local function Full_GetStatus(inst, data)
    return inst:HasTag("stump") and "STUMP" or nil
end

----------------------------------------------------------------------------------------------------------------------

local function MakeAncientTree(name, data)
    local assets = 	{
        Asset("ANIM", "anim/"..data.build..".zip"),
        Asset("MINIMAP_IMAGE", "ancienttree_"..name.."_stump.png"),

        Asset("SCRIPT", "scripts/prefabs/ancienttree_defs.lua"),
    }

    local prefabs_tree = {
        data.fruit_prefab,
        "ancienttree_"..name.."_sapling",
        "ancienttree_"..name.."_sapling_item",
        "ancienttree_"..name.."_sapling_item_waxed",
        "ancienttree_"..name.."_sapling_item_placer",
    }

    SetSharedLootTable("ancienttree_"..name, data.LOOT.full)
    SetSharedLootTable("ancienttree_"..name.."_stump", data.LOOT.stump)

    local function FullTreeFn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        if data.shadow_size ~= nil then
            inst.entity:AddDynamicShadow()
            inst.DynamicShadow:SetSize(data.shadow_size, data.shadow_size)
        end

        MakeObstaclePhysics(inst, data.physics_rad)
		inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.PLACER_DEFAULT] / 2) --seed deployspacing/2

        inst.MiniMapEntity:SetIcon("ancienttree_"..name..".png")
        inst.MiniMapEntity:SetPriority(3)

        inst.AnimState:SetBank(data.build)
        inst.AnimState:SetBuild(data.bank)
        inst.AnimState:PlayAnimation(math.random() < .5 and "sway1_loop" or "sway2_loop", true)

        inst:AddTag("plant")
        inst:AddTag("tree")
        inst:AddTag("no_force_grow")
        inst:AddTag("ancienttree")
        inst:AddTag("event_trigger")

        if data.shelter then
            inst:AddTag("shelter")
        end

        if data.snowcovered then
            MakeSnowCoveredPristine(inst)
        end

        if data.common_postinit ~= nil then
            data.common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.type = name
        inst.sounds = TREE_DEFS[inst.type].sounds
        inst.directional_fall = data.directional_fall

        inst.scrapbook_anim = "sway1_loop"

        inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)

        local multcolor = 0.75 + math.random() * 0.25
        inst.AnimState:SetMultColour(multcolor, multcolor, multcolor, 1)

        inst.TransferPlantData = TransferPlantData
        inst.UpdatePickableRegenTime = Full_UpdatePickableRegenTime
        inst.CanRegenFruits = Full_CanRegenFruits
        inst.MakeStump = Full_MakeStump
        
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = Full_GetStatus

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable("ancienttree_"..name)

        inst:AddComponent("pickable")
        inst.components.pickable.picksound = data.sounds.onpicked
    
        inst.components.pickable:SetUp(data.fruit_prefab, PLANT_DATA.fruit_regen.max, data.numtoharvest)
        inst.components.pickable.onregenfn   = Full_OnRegenFn
        inst.components.pickable.onpickedfn  = Full_OnPickedFn
        inst.components.pickable.makeemptyfn = Full_OnMakeEmptyFn

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS[data.workaction])
        inst.components.workable:SetOnWorkCallback(Full_OnWorked)
        inst.components.workable:SetOnFinishCallback(Full_OnWorkedFinish)
        inst.components.workable:SetWorkLeft(TUNING.ANCIENTTREE_WORK)

        MakeHauntableWork(inst)

        if data.snowcovered then
            MakeSnowCovered(inst)
        end

        inst.OnSave = Full_OnSave
        inst.OnLoad = Full_OnLoad

        inst.OnEntityWake  = Full_OnEntityWake
        inst.OnEntitySleep = Full_OnEntitySleep

        MakeWaxablePlant(inst)

        if data.master_postinit ~= nil then
            data.master_postinit(inst)
        end

        return inst
    end

    local function SaplingFn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

		inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.PLACER_DEFAULT] / 2) --seed deployspacing/2

        inst.AnimState:SetBank("ancienttree_seed")
        inst.AnimState:SetBuild("ancienttree_seed")
        inst.AnimState:PlayAnimation("idle_planted", true)

        inst.displaynamefn = Sapling_DisplayNameFn

        inst:AddTag("silviculture")

        if data.common_postinit ~= nil then
            data.common_postinit(inst)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_anim  = statedata[#statedata].idleanim
        inst.scrapbook_bank  = data.bank
        inst.scrapbook_build = data.build 

        inst.type   = name
        inst.sounds = TREE_DEFS[inst.type].sounds
        inst._bank  = data.bank
        inst._build = data.build

        inst.CheckGrowConstraints = Sapling_CheckGrowConstraints
        inst.TransferPlantData = TransferPlantData

        local multcolor = 0.75 + math.random() * 0.25
        inst.AnimState:SetMultColour(multcolor, multcolor, multcolor, 1)

        inst:AddComponent("lootdropper")

        inst:AddComponent("inspectable")
        inst.components.inspectable:SetNameOverride("ancienttree_sapling")
        inst.components.inspectable.getstatus = Sapling_GetStatus

        inst:AddComponent("growable")
        inst.components.growable.magicgrowable = true
        inst.components.growable.domagicgrowthfn = Sapling_DoMagicGrowthFn
        inst.components.growable.stages = GROWTH_STAGES
        inst.components.growable:SetStage(1)
        inst.components.growable:StartGrowing()

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetOnFinishCallback(Sapling_DigUp)
        inst.components.workable:SetWorkLeft(1)

        inst:WatchWorldState("season", inst.CheckGrowConstraints)

        inst:DoTaskInTime(0, inst.CheckGrowConstraints)

        inst.OnSave = PlantData_OnSave
        inst.OnLoad = PlantData_OnLoad

        inst.OnEntityWake  = Sapling_OnEntityWake

        MakeHauntableWork(inst)

        MakeWaxablePlant(inst)

        if data.master_postinit ~= nil then
            data.master_postinit(inst)
        end

        return inst
    end

    local function SaplingItemFn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)
        inst.AnimState:PlayAnimation("sprout_item")

        inst:AddTag("deployedplant")

        MakeInventoryFloatable(inst, "large", 0.2, 0.55)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.type = name
        inst.sounds = TREE_DEFS[inst.type].sounds

        inst.TransferPlantData = TransferPlantData

        inst:AddComponent("inventoryitem")

        inst:AddComponent("inspectable")
        inst.components.inspectable:SetNameOverride("ancienttree_sapling_item")

        inst:AddComponent("deployable")
        inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.PLACER_DEFAULT)
        inst.components.deployable.ondeploy = Sapling_OnDeploy

        inst.OnSave = PlantData_OnSave
        inst.OnLoad = PlantData_OnLoad

        MakeHauntableLaunch(inst)

        return inst
    end

    local function WaxedSaplingItem_MasterPostInit(inst)
        inst.components.deployable:SetDeployMode(DEPLOYMODE.DEFAULT)

        inst:RemoveComponent("fuel")
    end

    return
        Prefab("ancienttree_"..name, FullTreeFn, assets, prefabs_tree),
        Prefab("ancienttree_"..name.."_sapling", SaplingFn, assets),
        Prefab("ancienttree_"..name.."_sapling_item", SaplingItemFn, assets),
        MakePlacer("ancienttree_"..name.."_sapling_item_placer", data.bank, data.build, "sprout_idle"),
        WAXED_PLANTS.CreateDugWaxedPlant({
            name     = "ancienttree_"..name.."_sapling",
            prefab   = "ancienttree_"..name.."_sapling_item",
            bank     = data.bank,
            build    = data.build,
            animname = "sprout_item",
            floater  = {"large", 0.2, 0.55},
            deployspacing = DEPLOYSPACING.PLCAER_DEFAULT,
            master_postinit = WaxedSaplingItem_MasterPostInit,
        })

end

-- For search:
    -- ancienttree_gem
    -- ancienttree_nightvision

local tree_prefabs = {}

for name, data in pairs(TREE_DEFS) do
    ConcatArrays(tree_prefabs, { MakeAncientTree(name, data) })
end

return unpack(tree_prefabs)
