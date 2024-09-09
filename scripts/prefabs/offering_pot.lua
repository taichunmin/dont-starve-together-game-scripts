require "prefabutil"

local prefabs =
{
    "kelp",
    "collapse_small",
    "offering_pot_upgraded",
}

local assets =
{
    Asset("ANIM", "anim/offering_pot.zip"),
    Asset("ANIM", "anim/offering_pot_upgraded_build.zip"),
    Asset("ANIM", "anim/ui_chest_2x2.zip"),
}

--------------------------------------------------------------------------------------------------------------------------

local NUM_KELPS = 6
local KELP_LAYERS = {}

for i = 1, NUM_KELPS do
    table.insert(KELP_LAYERS, "kelp_"..tostring(i))
end

--------------------------------------------------------------------------------------------------------------------------

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

local CIRCLE_RADIUS_SCALE = 1888 / 150 / 2 -- Source art size / anim_scale / 2 (halved to get radius).

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

    inst.AnimState:SetBank("firefighter_placement")
    inst.AnimState:SetBuild("firefighter_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    local scale = TUNING.WURT_OFFERING_POT_RANGE / CIRCLE_RADIUS_SCALE -- Convert to rescaling for our desired range.

    inst.AnimState:SetScale(scale, scale)

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

--------------------------------------------------------------------------------------------------------------------------

local function OnHammered(inst)
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
        inst.SoundEmitter:PlaySound("meta4/merm_alter/offering_place")
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")

        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
        end
    end
end

local function OnBuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)

    inst.SoundEmitter:PlaySound("meta4/merm_alter/place"..(inst._upgraded and "_upgraded" or ""))
end

--------------------------------------------------------------------------------------------------------------------------

local function UpdateDecor(inst, data)
    local count = inst.components.container ~= nil and inst.components.container:NumItems() or 0

    for i = 1, NUM_KELPS do
        if i <= count then
            inst.AnimState:Show("kelp_"..i)
        else
            inst.AnimState:Hide("kelp_"..i)
        end
    end

    if not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("meta4/merm_alter/offering_place")

        inst.AnimState:PlayAnimation("give")
        inst.AnimState:PushAnimation("idle", true)
    end

    TheWorld:PushEvent("ms_updateofferingpotstate", { inst = inst, count = count} )
end

--------------------------------------------------------------------------------------------------------------------------

local function GetStatus(inst)
    local num_decor = inst.components.container ~= nil and inst.components.container:NumItems() or 0
    local num_slots = inst.components.container ~= nil and inst.components.container.numslots or 1

    return
        (num_decor >= num_slots and "LOTS_OF_KELP") or
        (num_decor > 0          and "SOME_KELP"   ) or
        nil
end

--------------------------------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------------------------------

local function OnRemoved(inst)
    TheWorld:PushEvent("ms_updateofferingpotstate", { inst = inst, count = 0 })
end

local function OnBurnt(inst, ...)
    DefaultBurntStructureFn(inst, ...)

    inst:RemoveMermCaller()
    inst:RemoveComponent("activatable")
end

--------------------------------------------------------------------------------------------------------------------------

local function RemoveMermCaller(inst)
    inst.merm_caller = nil

    if inst.components.activatable ~= nil then
        inst.components.activatable.inactive = true
    end

    if inst.caller_task ~= nil then
        inst.caller_task:Cancel()
        inst.caller_task = nil
    end
end

local function ValidateMermGathering(inst)
    if inst.merm_caller == nil or
        not inst.merm_caller:IsValid() or
        inst:GetDistanceSqToInst(inst.merm_caller) > 20*20 or
        inst.components.container == nil or
        inst.components.container:IsEmpty()
    then
        inst:RemoveMermCaller()
    end
end

local function _IsKelp(item)
    return item.prefab == "kelp"
end

local function AnswerCall(inst, merm)
    if inst.components.container == nil then
        return
    end

    local kelp = inst.components.container:FindItem(_IsKelp)

    if kelp ~= nil and inst.merm_caller ~= nil then
        merm.components.inventory:GiveItem(kelp)
        merm:dohiremerms(inst.merm_caller, kelp)

        merm:PushBufferedAction(BufferedAction(merm, kelp, ACTIONS.EAT))
    end

    if inst.components.container:IsEmpty() then
        inst:RemoveMermCaller()
    end
end

local function OnActivate(inst, doer)
    if not doer:HasTag("merm_builder") then
        return false
    end

    doer.components.talker:Say(GetString(doer, "ANNOUNCE_GATHER_MERM"))

    inst.merm_caller = doer

    if inst.caller_task == nil then
        inst.caller_task = inst:DoPeriodicTask(1, inst.ValidateMermGathering)
    end

    return true
end

local function CanActivateFn(inst,doer)
    if inst:HasTag("burnt") or inst.components.container == nil then
        return false
    end

    if not doer:HasTag("merm_builder") then
        return false, "NOTMERM"
    end

    if inst.merm_caller and inst.merm_caller ~= doer then
        return false, "HASMERMLEADER"
    end

    if inst.components.container:IsEmpty() then
        return false, "NOKELP"
    end

    return true
end

--------------------------------------------------------------------------------------------------------------------------

local function GetVerb()
    return "GATHER_MERM"
end

--------------------------------------------------------------------------------------------------------------------------

local function MakeOfferingPot(name, build, large)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, large and .7 or .35)

        inst.MiniMapEntity:SetIcon(name..".png")

        inst:AddTag("structure")
        inst:AddTag("offering_pot")

        inst.AnimState:SetBank("offering_pot")
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle")

        for _, v in ipairs(KELP_LAYERS) do
            inst.AnimState:Hide(v)
        end

        MakeSnowCoveredPristine(inst)

        -- Dedicated server does not need deployhelper.
        if not TheNet:IsDedicated() then
            local deployhelper = inst:AddComponent("deployhelper")
            deployhelper:AddRecipeFilter("mermhouse_crafted")
            deployhelper:AddRecipeFilter("mermwatchtower")
            deployhelper.onenablehelper = OnEnableHelper
            deployhelper.onstarthelper = OnStartHelper
        end

        inst.GetActivateVerb = GetVerb

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst._upgraded = large

        inst.scrapbook_scale = large and .5 or nil
        inst.scrapbook_animoffsetx = large and -50 or nil
        inst.scrapbook_animoffsety = large and -70 or nil

        inst.UpdateDecor = UpdateDecor
        inst.RemoveMermCaller = RemoveMermCaller
        inst.ValidateMermGathering = ValidateMermGathering
        inst.AnswerCall = AnswerCall

        inst:AddComponent("lootdropper")

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = GetStatus

        inst:AddComponent("container")
        inst.components.container:WidgetSetup(name)

        local workable = inst:AddComponent("workable")
        workable:SetWorkAction(ACTIONS.HAMMER)
        workable:SetWorkLeft(4)
        workable:SetOnFinishCallback(OnHammered)
        workable:SetOnWorkCallback(OnHit)

        local activatable = inst:AddComponent("activatable")
        activatable.CanActivateFn = CanActivateFn
        activatable.OnActivate = OnActivate
        activatable.forcerightclickaction = true
        activatable.quickaction = true

        inst:ListenForEvent("itemget",  inst.UpdateDecor)
        inst:ListenForEvent("itemlose", inst.UpdateDecor)

        inst.OnBuilt = OnBuilt
        inst.OnRemoveEntity = OnRemoved

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        if large then
            MakeLargeBurnable(inst, nil, nil, true)
            MakeLargePropagator(inst)
        else
            MakeMediumBurnable(inst, nil, nil, true)
            MakeMediumPropagator(inst)
        end

        inst.components.burnable:SetOnBurntFn(OnBurnt)

        MakeHauntableWork(inst)
        MakeSnowCovered(inst)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

--------------------------------------------------------------------------------------------------------------------------

local function placer_postinit_fn(inst)
    local radius = CreatePlacerRing()

    radius.entity:SetParent(inst.entity)
    inst.components.placer:LinkEntity(radius)

    return radius -- Mods.
end

local function MakeOfferingPotPlacer(name, build)
    return MakePlacer(name, "offering_pot", build, "placer", nil, nil, nil, nil, nil, nil, placer_postinit_fn)
end

--------------------------------------------------------------------------------------------------------------------------

return
    MakeOfferingPot("offering_pot",          "offering_pot",                false),
    MakeOfferingPot("offering_pot_upgraded", "offering_pot_upgraded_build", true ),

    MakeOfferingPotPlacer("offering_pot_placer",          "offering_pot"               ),
    MakeOfferingPotPlacer("offering_pot_upgraded_placer", "offering_pot_upgraded_build")
