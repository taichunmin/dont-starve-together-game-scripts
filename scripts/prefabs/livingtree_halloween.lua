local assets =
{
    Asset("ANIM", "anim/evergreen_living_wood_growable.zip"),
    Asset("ANIM", "anim/ui_chest_3x1.zip"),
    Asset("MINIMAP_IMAGE", "livingtree_burnt"),
    Asset("MINIMAP_IMAGE", "livingtree_stump"),
}

local prefabs =
{
    "livinglog",
    "eyeflame",
}

local NUM_GROWTH_STAGES = 2
local statedata =
{
    { -- short
        anim_postfix    = "young",
        workleft        = TUNING.LIVINGTREE_YOUNG_WORK,
        loot            = {"livinglog"},
    },
    { -- tall
        anim_postfix = "old",
        growanim    = "grow_young_to_old",
        workleft    = TUNING.LIVINGTREE_WORK,
        loot        = {"livinglog", "livinglog"},
    },
}

local function TurnOffEyes(inst)
    if inst._eyeflames ~= nil then
        inst._eyeflames:set(false)
    end
end

local function SetGrowth(inst)
    local new_size = inst.components.growable.stage
    inst.statedata = statedata[new_size]
    inst.AnimState:PlayAnimation("idle_"..inst.statedata.anim_postfix, true)

    inst.components.workable:SetWorkLeft(inst.statedata.workleft)

    if new_size >= #statedata then
        inst.components.growable:StopGrowing()
    end
end

local function DoGrow(inst)
    inst.AnimState:PlayAnimation(inst.statedata.growanim)
    inst.SoundEmitter:PlaySound("dontstarve/halloween_2018/living_tree/grow_3")
    inst.AnimState:PushAnimation("idle_"..inst.statedata.anim_postfix, true)
end

local GROWTH_STAGES =
{
    {
        time = function(inst) return GetRandomWithVariance(TUNING.LIVINGTREE_YOUNG_GROW_TIME, TUNING.LIVINGTREE_YOUNG_GROW_TIME*0.05) end,
        fn = function(inst) SetGrowth(inst) end,
    },
    {
        fn = function(inst) SetGrowth(inst) end,
        growfn = function(inst) DoGrow(inst)  end,
    },
}

local function OnEyeFlamesDirty(inst)
    if TheWorld.ismastersim then
        if not inst._eyeflames:value() then
            inst.AnimState:SetLightOverride(0)
            inst.SoundEmitter:KillSound("eyeflames")
        else
            inst.AnimState:SetLightOverride(.2)
            if not inst.SoundEmitter:PlayingSound("eyeflames") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "eyeflames")
                inst.SoundEmitter:SetParameter("eyeflames", "intensity", .2)
            end
        end
        if TheNet:IsDedicated() then
            return
        end
    end

    if inst._eyeflames:value() then
        if inst.eyefxl == nil then
            inst.eyefxl = SpawnPrefab("eyeflame")
            inst.eyefxl.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
            inst.eyefxl.entity:AddFollower()
            inst.eyefxl.Follower:FollowSymbol(inst.GUID, "eye1", 0, 0, 0)
        end
        if inst.eyefxr == nil then
            inst.eyefxr = SpawnPrefab("eyeflame")
            inst.eyefxr.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
            inst.eyefxr.entity:AddFollower()
            inst.eyefxr.Follower:FollowSymbol(inst.GUID, "eye2", 0, 0, 0)
        end
    else
        if inst.eyefxl ~= nil then
            inst.eyefxl:Remove()
            inst.eyefxl = nil
        end
        if inst.eyefxr ~= nil then
            inst.eyefxr:Remove()
            inst.eyefxr = nil
        end
    end
end

local function chop_down_burnt_tree(inst, chopper)
    TurnOffEyes(inst)
    inst:RemoveComponent("workable")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    inst.AnimState:PlayAnimation("chop_burnt_"..inst.statedata.anim_postfix)
    RemovePhysicsColliders(inst)
    inst:ListenForEvent("animover", inst.Remove)
    inst.components.lootdropper:SpawnLootPrefab("charcoal")
    inst.components.lootdropper:DropLoot()
end

local function Extinguish(inst)
    if inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("hauntable")
    MakeHauntableWork(inst)

    inst.components.lootdropper:SetLoot({})

    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnWorkCallback(nil)
        inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
    end
end

local function OnBurnt(inst)
    TurnOffEyes(inst)
    inst:RemoveComponent("sanityaura")

    inst.components.growable:StopGrowing()
    inst:DoTaskInTime(0.5, Extinguish)
    inst.AnimState:PlayAnimation("burnt_"..inst.statedata.anim_postfix, true)
    inst.AnimState:SetRayTestOnBB(true)
    inst:AddTag("burnt")
    inst.MiniMapEntity:SetIcon("livingtree_burnt.png")

    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
        inst:RemoveComponent("container")
    end
end

local function ondug(inst)
    inst.components.lootdropper:SpawnLootPrefab("livinglog")
    inst:Remove()
end

local function makestump(inst, instant)
    TurnOffEyes(inst)
    inst.components.growable:StopGrowing()

    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
        inst:RemoveComponent("container")
    end

    inst:RemoveComponent("sanityaura")
    inst:RemoveComponent("workable")
    inst:RemoveComponent("burnable")
    MakeMediumBurnable(inst)
    inst:RemoveComponent("propagator")
    MakeSmallPropagator(inst)
    inst:RemoveComponent("hauntable")
    MakeHauntableIgnite(inst)
    RemovePhysicsColliders(inst)
    if instant then
        inst.AnimState:PlayAnimation("stump_"..inst.statedata.anim_postfix)
    else
        inst.AnimState:PushAnimation("stump_"..inst.statedata.anim_postfix)
    end
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(ondug)
    inst.components.workable:SetWorkLeft(1)
    inst:AddTag("stump")

    inst.MiniMapEntity:SetIcon("livingtree_stump.png")
end

local function onworked(inst, chopper, workleft)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree"
        )
    end
    inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/livingtree_hit")
    inst.AnimState:PlayAnimation("chop_"..inst.statedata.anim_postfix)
    inst.AnimState:PushAnimation("idle_"..inst.statedata.anim_postfix, true)

    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end
end

local function ShakeCamera(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .25, .03, .5, inst, 6)
end

local function onworkfinish(inst, chopper)
    local pt = inst:GetPosition()
    local hispos = chopper:GetPosition()
    local he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0

    inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/livingtree_die")

    inst.components.lootdropper:SetLoot(inst.statedata.loot)
    if he_right then
        inst.AnimState:PlayAnimation("fallleft_"..inst.statedata.anim_postfix)
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
    else
        inst.AnimState:PlayAnimation("fallright_"..inst.statedata.anim_postfix)
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
    end

    inst:DoTaskInTime(.4, ShakeCamera)

    makestump(inst)
end

local function GrowFromSeed(inst)
    inst.components.growable:StartGrowing()
    inst.AnimState:PlayAnimation("grow_seed_to_young")
    inst.AnimState:PushAnimation("idle_"..inst.statedata.anim_postfix, true)
    inst.SoundEmitter:PlaySound("dontstarve/halloween_2018/living_tree/grow_2")
end

local function HideDecor(inst, data)
    inst.AnimState:ClearOverrideSymbol("decor"..data.slot)
    inst.AnimState:Hide("decor"..data.slot)
    inst.AnimState:Hide("rope"..data.slot)
end

local function ShowDecor(inst, data)
    if inst:HasTag("burnt") or data == nil or data.slot == nil or data.item == nil or (data.item.halloween_ornamentid == nil and data.item.halloween_ornamentbuildoverride == nil and data.item.halloween_ornamentsymboloverride == nil) then
        return
    end

    inst.AnimState:Show("decor"..data.slot)
    inst.AnimState:Show("rope"..data.slot)
    inst.AnimState:OverrideSymbol("decor"..data.slot, data.item.halloween_ornamentbuildoverride or "halloween_ornaments", data.item.halloween_ornamentsymboloverride or ("decor_" .. tostring(data.item.halloween_ornamentid)))
end

local function onsave(inst, data)
    if inst:HasTag("stump") then
        data.stump = true
    end

    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.stump then
            makestump(inst, true)
            if data.burnt or inst:HasTag("burnt") then
                DefaultBurntFn(inst)
            end
        elseif data.burnt and not inst:HasTag("burnt") then
            OnBurnt(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .75)

    inst.MiniMapEntity:SetIcon("livingtree.png")

    inst:AddTag("plant")
    inst:AddTag("tree")
    inst:AddTag("decoratable")
    inst:AddTag("fridge")

    inst.AnimState:SetBank("evergreen_living_wood_growable")
    inst.AnimState:SetBuild("evergreen_living_wood_growable")
    inst.AnimState:PlayAnimation("idle_old", true)

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --livingtree_root deployspacing/2

    MakeSnowCoveredPristine(inst)

    if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
        inst._eyeflames = net_bool(inst.GUID, "livingtree._eyeflames", "eyeflamesdirty")
        inst:ListenForEvent("eyeflamesdirty", OnEyeFlamesDirty)
	else
		inst.AnimState:Hide("eye")
    end

    inst:SetPrefabNameOverride("livingtree")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.statedata = statedata[#statedata]

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetWorkLeft(20)
    inst.components.workable:SetOnWorkCallback(onworked)
    inst.components.workable:SetOnFinishCallback(onworkfinish)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("livingtree_halloween")
    inst.components.container.canbeopened = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS)

    if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
    end

    MakeLargeBurnable(inst)
    inst.components.burnable:SetFXLevel(5)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    MakeMediumPropagator(inst)
    MakeHauntableWorkAndIgnite(inst)

    inst:AddComponent("growable")
    inst.components.growable.stages = GROWTH_STAGES
    inst.components.growable.growoffscreen = true
    inst.components.growable:SetStage(1)
    inst.components.growable:StartGrowing()

    MakeSnowCovered(inst)

    inst.growfromseed = GrowFromSeed

    for i = 1, inst.components.container:GetNumSlots() do
        HideDecor(inst, {slot=i})
    end

    inst:ListenForEvent("itemget", ShowDecor)
    inst:ListenForEvent("itemlose", HideDecor)

    inst.OnSave = onsave
    inst.OnLoad = onload

    if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
        inst._eyeflames:set(true)
    end

    return inst
end

return Prefab("livingtree_halloween", fn, assets, prefabs)
