require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/charlie_lectern.zip"),
    --Asset("ANIM", "anim/ui_board_5x3.zip"),
    Asset("MINIMAP_IMAGE", "charlie_lectern"),
}

local prefabs =
{
    "collapse_small",
}

local function flippage(inst)
    inst.entity:AddSoundEmitter()
    local anim = (math.random() < 0.5 and "pageturn_extra") or "pageturn"
    inst.AnimState:PlayAnimation(anim, false)
    inst.SoundEmitter:PlaySound("stageplay_set/stage/lecturn_pageturn")
    inst.AnimState:PushAnimation("idle", true)
end

local function checkidleanim(inst)
    if inst.AnimState:IsCurrentAnimation("idle") then
        inst.AnimState:PlayAnimation("idle_vine_move_"..math.random(1,3))
        inst.AnimState:PushAnimation("idle")
    end
    inst:DoTaskInTime(math.random()*3 + 2, checkidleanim)
end

local function on_playbill_stage_set(inst, stage)
    inst.components.entitytracker:ForgetEntity("stage")
    inst.components.entitytracker:TrackEntity("stage", stage)
end

local function on_load_postpass(inst, newents, data)
    local stage = inst.components.entitytracker:GetEntity("stage")
    if stage then
        inst.components.playbill_lecturn:SetStage(stage)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .2)

    inst.MiniMapEntity:SetIcon("charlie_lectern.png")

    inst.AnimState:SetBank("charlie_lectern")
    inst.AnimState:SetBuild("charlie_lectern")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst:AddTag("structure")

    --Sneak these into pristine state for optimization
    inst:AddTag("_writeable")
    inst:AddTag("playbill_lecturn") -- from playbill_lecturn component
    inst.scrapbook_proxy = "charlie_stage_post"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_writeable")

    inst:AddComponent("entitytracker")

    inst:AddComponent("inspectable")
    inst:AddComponent("writeable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("playbill_lecturn")
    inst.components.playbill_lecturn.onstageset = on_playbill_stage_set

    MakeSnowCovered(inst)

    inst.checkidleanim = checkidleanim

    MakeHauntableWork(inst)

    inst:ListenForEvent("text_changed", flippage)

    inst:DoTaskInTime(math.random()*3 + 2, checkidleanim)

    inst.OnLoadPostPass = on_load_postpass

    MakeRoseTarget_CreateFuel(inst)

    return inst
end

return Prefab("charlie_lecturn", fn, assets, prefabs)    
