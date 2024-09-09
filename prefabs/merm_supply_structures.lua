require "prefabutil"

local armnory_prefabs =
{
    "collapse_small",
}

local armory_assets =
{
    Asset("ANIM", "anim/merm_armory.zip"),
    Asset("ANIM", "anim/ui_chest_1x2.zip"),
    Asset("INV_IMAGE", "merm_armory"),
    Asset("INV_IMAGE", "merm_armory_upgraded"),
}

local toolshed_prefabs =
{
    "collapse_small",
}

local toolshed_assets =
{
    Asset("ANIM", "anim/merm_toolshed.zip"),
    Asset("ANIM", "anim/ui_chest_1x2.zip"),
    Asset("INV_IMAGE", "merm_toolshed"),
    Asset("INV_IMAGE", "merm_toolshed_upgraded"),
}

---------------------------------------------------------------------------------------------------------------------------------

local SOUNDS =
{
    merm_toolshed = {
        place = "meta4/mermery/shoddy_place",
        use   = "meta4/mermery/use",
    },
    merm_toolshed_upgraded = {
        place = "meta4/mermery/lessshoddy_place",
        use   = "meta4/mermery/use",
    },
    merm_armory = {
        place = "meta4/mermery/armermry_place",
        use   = "meta4/mermery/use",
    },
    merm_armory_upgraded = {
        place = "meta4/mermery/superior_armermry_place",
        use   = "meta4/mermery/use",
    },
}

---------------------------------------------------------------------------------------------------------------------------------

local NUM_INITIAL_RESOURCES = 5

local CACHED_RECIPE_COST = {}

local function CacheRecipeCost(inst, recname)
    local recipe = AllRecipes[recname]

    if recipe ~= nil then
        local ingredients = {}

        for _, v in pairs(recipe.ingredients) do
            if v.amount > 0 then
                ingredients[v.type] = v.amount
            end
        end

        return ingredients
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local FUNNY_IDLE_TIME = 4
local FUNNY_IDLE_RAND_TIME = 8

local function PlayFunnyIdle(inst)
    local tasktime = FUNNY_IDLE_RAND_TIME * math.random() + FUNNY_IDLE_TIME

    if inst.AnimState:IsCurrentAnimation("idle") or inst.AnimState:IsCurrentAnimation("idle_empty") then
        local extraloop = math.random() <= .5

        local sufix = inst._closed and "" or "_empty"

        inst.AnimState:PlayAnimation("idle2"..sufix)
        inst.AnimState:PushAnimation("idle2"..sufix)

        if extraloop then
            inst.AnimState:PushAnimation("idle2"..sufix)

            tasktime = tasktime * 1.25
        end

        inst.AnimState:PushAnimation("idle"..sufix)
    end

    inst._funnyidletask = inst:DoTaskInTime(tasktime, inst.PlayFunnyIdle)
end

local function OnEntityWake(inst)
    if inst:IsAsleep() then
        return
    end

    if inst._funnyidletask ~= nil then
        inst._funnyidletask:Cancel()
        inst._funnyidletask = nil
    end

    local tasktime = FUNNY_IDLE_RAND_TIME * math.random() + FUNNY_IDLE_TIME

    inst._funnyidletask = inst:DoTaskInTime(tasktime, inst.PlayFunnyIdle)
end

local function OnEntitySleep(inst)
    if inst._funnyidletask ~= nil then
        inst._funnyidletask:Cancel()
        inst._funnyidletask = nil
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local PLACER_SCALE = 1.9

local function OnUpdatePlacerHelper(helperinst)
    if not helperinst.placerinst:IsValid() then
        helperinst.components.updatelooper:RemoveOnUpdateFn(OnUpdatePlacerHelper)
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)

    elseif helperinst:IsNear(helperinst.placerinst, TUNING.WURT_OFFERING_POT_RANGE) then
        helperinst.AnimState:SetAddColour(helperinst.placerinst.AnimState:GetAddColour())

    else
        helperinst.AnimState:SetAddColour(0, 0, 0, 0)
    end
end

local function CreatePlacerRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("winona_battery_placement")
    inst.AnimState:SetBuild("winona_battery_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(1)
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    inst.AnimState:Hide("inner")

    return inst
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
    if enabled then
        inst.helper = CreatePlacerRing()
        inst.helper.entity:SetParent(inst.entity)

        inst.helper:AddComponent("updatelooper")
        inst.helper.components.updatelooper:AddOnUpdateFn(OnUpdatePlacerHelper)
        inst.helper.placerinst = placerinst
        OnUpdatePlacerHelper(inst.helper)

    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function OnStartHelper(inst)
    if inst.AnimState:IsCurrentAnimation("place") then
        inst.components.deployhelper:StopHelper()
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local function OnHammered(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    inst.components.lootdropper:DropLoot()

    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst:Remove()
end

local function OnHit(inst, worker, workleft)
    if workleft > 0 and not inst:HasTag("burnt") then
        local sufix = inst._closed and "" or "_empty"

        inst.AnimState:PlayAnimation("hit" ..sufix)
        inst.AnimState:PushAnimation("idle"..sufix)
    end
end

local function OnBuilt(inst)
    inst.SoundEmitter:PlaySound(inst.sounds.place)

    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")

    if inst.supply_cost == nil then -- Just in case.
        return
    end

    for prefab, count in pairs(inst.supply_cost) do
        local item = SpawnPrefab(prefab)

        if item.components.stackable ~= nil then
            item.components.stackable:SetStackSize(NUM_INITIAL_RESOURCES)
        end

        inst.components.container:GiveItem(item)
    end
end

local function OnBurnt(inst, ...)
    DefaultBurntStructureFn(inst, ...)

    if inst._funnyidletask ~= nil then
        inst._funnyidletask:Cancel()
        inst._funnyidletask = nil
    end

    inst.OnEntityWake = nil
    inst.OnEntitySleep = nil
end

---------------------------------------------------------------------------------------------------------------------------------

local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local function CanSupply(inst)
    if inst.components.container == nil or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        return false -- Burnt!
    end

    if inst.supply_cost == nil then -- Just in case.
        return false
    end

    for prefab, count in pairs(inst.supply_cost) do
        if not inst.components.container:Has(prefab, count, false) then
            return false
        end
    end

    return true
end

local function OnSupply(inst, merm)
    if not inst:CanSupply() then
        return
    end

    merm.components.inventory:GiveItem(SpawnPrefab(inst.supply_prefab))

    for prefab, count in pairs(inst.supply_cost) do
        inst.components.container:ConsumeByName(prefab, count)
    end

    if inst:CanSupply() then
        inst.AnimState:PlayAnimation("use")
        inst.AnimState:PushAnimation("idle")

        inst.SoundEmitter:PlaySound(inst.sounds.use)

        inst._closed = true
    else
        if not inst:HasTag("burnt") then
            inst.AnimState:PlayAnimation("idle_pre_empty")
            inst.AnimState:PushAnimation("idle_empty")
        end

        inst._closed = nil
    end
end

local function OnContainerStateChanged(inst)
    if inst.AnimState:IsCurrentAnimation("place") then
        return
    end

    if inst:CanSupply() then
        if not inst._closed then
            inst.AnimState:PlayAnimation("use")
            inst.AnimState:SetFrame(5) --FIXME(DiogoW): Proper close anim?
            inst.AnimState:PushAnimation("idle")

            inst._closed = true
        end

    elseif inst._closed then
        if not inst:HasTag("burnt") then
            inst.AnimState:PlayAnimation("idle_pre_empty")
            inst.AnimState:PushAnimation("idle_empty")
        end


        inst._closed = nil
    end
end

---------------------------------------------------------------------------------------------------------------------------------

local function CreateMermSupplyStructure(data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .5)

        inst:AddTag("structure")
        inst:AddTag("mermonly")

        if data.tag ~= nil then
            inst:AddTag(data.tag)
        end

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)
        inst.AnimState:PlayAnimation("idle")

        if data.hiddensymbol ~= nil then
            inst.AnimState:Hide(data.hiddensymbol)
        end

        inst.MiniMapEntity:SetIcon(data.prefab..".png")

        MakeSnowCoveredPristine(inst)

        -- Dedicated server does not need deployhelper.
        if not TheNet:IsDedicated() then
            inst:AddComponent("deployhelper")
            inst.components.deployhelper:AddRecipeFilter(data.deployhelperfilter)
            inst.components.deployhelper.onenablehelper = OnEnableHelper
            inst.components.deployhelper.onstarthelper = OnStartHelper
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_hide = data.hiddensymbol ~= nil and { data.hiddensymbol } or nil

        inst._closed = true

        inst.supply_prefab = data.supplyprefab
        inst.sounds = SOUNDS[data.prefab]

        inst.OnSupply = OnSupply
        inst.CanSupply = CanSupply
        inst.OnContainerStateChanged = OnContainerStateChanged
        inst.PlayFunnyIdle  = PlayFunnyIdle
        inst.CacheRecipeCost = CacheRecipeCost

        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetOnFinishCallback(OnHammered)
        inst.components.workable:SetOnWorkCallback(OnHit)
        inst.components.workable:SetWorkLeft(4)

        inst:AddComponent("container")
        inst.components.container:WidgetSetup(data.prefab)

        inst.OnBuilt = OnBuilt

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        inst.OnEntityWake  = OnEntityWake
        inst.OnEntitySleep = OnEntitySleep

        inst:ListenForEvent("itemget",  inst.OnContainerStateChanged)
        inst:ListenForEvent("itemlose", inst.OnContainerStateChanged)

        inst:DoTaskInTime(0, inst.OnContainerStateChanged)

        MakeMediumBurnable(inst, nil, nil, true)
        MakeMediumPropagator(inst)
        MakeHauntableWork(inst)
        MakeSnowCovered(inst)

        inst.components.burnable:SetOnBurntFn(OnBurnt)

        if CACHED_RECIPE_COST[data.supplyprefab] == nil then
            CACHED_RECIPE_COST[data.supplyprefab] = inst:CacheRecipeCost(data.supplyprefab)
        end

        inst.supply_cost = CACHED_RECIPE_COST[data.supplyprefab]

        return inst
    end

    local prefabs = shallowcopy(data.prefabs)
    table.insert(prefabs, data.supplyprefab)

    return Prefab(data.prefab, fn, data.assets, prefabs)
end

local function CreateMermSupplyStructurePlacer(data)
    local placer_postinit_fn = data.hiddensymbol ~= nil and function(inst) inst.AnimState:Hide(data.hiddensymbol) end or nil

    return MakePlacer(data.prefab, data.bank, data.build, "placer", nil, nil, nil, nil, nil, nil, placer_postinit_fn)
end

return
    CreateMermSupplyStructure({
        prefab = "merm_armory",
        build  = "merm_armory",
        bank   = "merm_armory",
        tag    = "merm_armory",
        hiddensymbol = "UPGRADED",
        supplyprefab = "mermarmorhat",
        deployhelperfilter = "mermwatchtower",
        assets = armory_assets,
        prefabs = armnory_prefabs,
    }),

    CreateMermSupplyStructure({
        prefab = "merm_armory_upgraded",
        build  = "merm_armory",
        bank   = "merm_armory",
        tag    = "merm_armory_upgraded",
        hiddensymbol = "NOUPGRADED",
        supplyprefab = "mermarmorupgradedhat",
        deployhelperfilter = "mermwatchtower",
        assets = armory_assets,
        prefabs = armnory_prefabs,
    }),

    CreateMermSupplyStructure({
        prefab = "merm_toolshed",
        build  = "merm_toolshed",
        bank   = "merm_toolshed",
        tag    = "merm_toolshed",
        hiddensymbol = "UPGRADED",
        supplyprefab = "merm_tool",
        deployhelperfilter = "mermhouse_crafted",
        assets = toolshed_assets,
        prefabs = toolshed_prefabs,
    }),

    CreateMermSupplyStructure({
        prefab = "merm_toolshed_upgraded",
        build  = "merm_toolshed",
        bank   = "merm_toolshed",
        tag    = "merm_toolshed_upgraded",
        hiddensymbol = "NOUPGRADED",
        supplyprefab = "merm_tool_upgraded",
        deployhelperfilter = "mermhouse_crafted",
        assets = toolshed_assets,
        prefabs = toolshed_prefabs,
    }),

    CreateMermSupplyStructurePlacer({
        prefab = "merm_armory_placer",
        bank   = "merm_armory",
        build  = "merm_armory",
        hiddensymbol = "UPGRADED",
    }),

    CreateMermSupplyStructurePlacer({
        prefab = "merm_armory_upgraded_placer",
        bank   = "merm_armory",
        build  = "merm_armory",
        hiddensymbol = "NOUPGRADED",
    }),

    CreateMermSupplyStructurePlacer({
        prefab = "merm_toolshed_placer",
        bank   = "merm_toolshed",
        build  = "merm_toolshed",
        hiddensymbol = "UPGRADED",
    }),

    CreateMermSupplyStructurePlacer({
        prefab = "merm_toolshed_upgraded_placer",
        bank   = "merm_toolshed",
        build  = "merm_toolshed",
        hiddensymbol = "NOUPGRADED",
    })
