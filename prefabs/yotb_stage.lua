local yotb_common = require("prefabs/yotb_placer_common")

local assets =
{
    Asset("ANIM", "anim/tent.zip"),
    Asset("ANIM", "anim/yotb_stagebooth.zip"),
    Asset("MINIMAP_IMAGE", "yotb_stagebooth"),
    Asset("SCRIPT", "scripts/prefabs/yotb_placer_common.lua"),
}

local prefabs =
{
    "collapse_big",
    "yotb_stage_voice",
    "yotb_confetti",
    "yotb_pattern_fragment_1",
    "yotb_pattern_fragment_2",
    "yotb_pattern_fragment_3",
    "confetti_fx",
}

local assets_item =
{
    Asset("ANIM", "anim/yotb_stagebooth_item.zip"),
}

local prefabs_item =
{
    "yotb_stage",
}

local DEPLOYRING_DATA =
{
    bank =  "firefighter_placement",
    build = "firefighter_placement",
    anim =  "idle",
    scale = 2,
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")

    inst:Remove()
end

local function onhit(inst, worker)
    if inst.sg:HasStateTag("ready") then
        inst.sg:GoToState("hit_ready")
    else
        inst.sg:GoToState("hit_closed")
    end
end

local function onbuilt(inst)
    inst.sg:GoToState("place")
end

local function onremove(inst)
    TheWorld:PushEvent("yotb_onstagedestroyed", {stage = inst})
    inst.SoundEmitter:KillSound("eventbg")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(.5)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.MiniMapEntity:SetIcon("yotb_stagebooth.png")

    inst:AddTag("structure")
    inst:AddTag("yotb_stage")
    inst:AddTag("appraiser")

    inst.AnimState:SetBank("stagebooth")
    inst.AnimState:SetBuild("yotb_stagebooth")
    inst.AnimState:PlayAnimation("idle_closed", true)

    MakeSnowCoveredPristine(inst)

    inst:AddComponent("talker")
    inst.components.talker.offset = Vector3(0, -700, 0)
    inst.components.talker.font = TALKINGFONT_TRADEIN

    yotb_common.AddDeployHelper(inst, {"yotb_post"})

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("yotb_stager")

    inst:AddComponent("timer")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeSnowCovered(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("onremove", onremove)

    inst:SetStateGraph("SGyotb_stage")

    inst:DoTaskInTime(0,function()
        TheWorld:PushEvent("yotb_onstagebuilt", {stage = inst})
    end)

    return inst
end

local function voicefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("")
    inst.AnimState:SetBuild("")

    inst:AddTag("NOCLICK")
    inst:AddTag("fx")

    inst:AddComponent("talker")
    inst.components.talker.offset = Vector3(0, -500, 0)
    inst.components.talker.font = TALKINGFONT_TRADEIN

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("donetalking", function()
        if inst.proxy then
            inst.proxy:PushEvent("donetalking")
        end
    end)
    inst:ListenForEvent("ontalk", function()
        if inst.proxy then
            inst.proxy:PushEvent("ontalk")
        end
    end)

    return inst
end

local function placer_postinit_fn(inst)
    --Show the flingo placer on top of the flingo range ground placer
    return yotb_common.AddPlacerRing(inst, DEPLOYRING_DATA, "yotb_stage")
end

local function ondeploy(inst, pt, deployer)
    local stage = SpawnPrefab("yotb_stage")
    if stage ~= nil then
        stage.Physics:SetCollides(false)
        stage.Physics:Teleport(pt.x, 0, pt.z)
        stage.Physics:SetCollides(true)
        stage.AnimState:PlayAnimation("place")
        stage.AnimState:PushAnimation("idle_closed", false)
        stage.SoundEmitter:PlaySound("yotb_2021/common/stagebooth/place")
        inst:Remove()
        PreventCharacterCollisionsWithPlacedObjects(stage)
    end
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("yotb_stagebooth_item")
    inst.AnimState:SetBuild("yotb_stagebooth_item")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("portableitem")

    MakeInventoryFloatable(inst, "med", 0.05, 0.9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)

    return inst
end

return Prefab("yotb_stage", fn, assets, prefabs),
       Prefab("yotb_stage_voice", voicefn),
       Prefab("yotb_stage_item", itemfn, assets_item, prefabs_item),
       MakePlacer("yotb_stage_item_placer", "stagebooth", "yotb_stagebooth", "idle_closed", nil, nil, nil, nil, nil, nil, placer_postinit_fn)