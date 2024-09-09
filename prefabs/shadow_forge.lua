require("prefabutil")

local assets =
{
    Asset("ANIM", "anim/shadow_forge.zip"),
}

local prefabs =
{
    "collapse_small",
}

local kit_assets =
{
    Asset("ANIM", "anim/shadow_forge.zip"),
    Asset("INV_IMAGE", "shadow_forge_kit"),
}

----
local function on_finished_hammering(inst, worker)
    -- Drop recipe loot
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")

    inst:Remove()
end

local function onhit(inst, worker)
    if inst.components.prototyper.on then
        inst.AnimState:PlayAnimation("hit_open")
        inst.AnimState:PushAnimation("proximity_loop", true)
    else
        inst.AnimState:PlayAnimation("hit_close")
        inst.AnimState:PushAnimation("idle", false)
    end
end

----
local function onturnon(inst)
    if not inst._activetask then
        if inst.AnimState:IsCurrentAnimation("proximity_loop") or inst.AnimState:IsCurrentAnimation("use") then
            --In case other animations were still in queue
            inst.AnimState:PlayAnimation("proximity_loop", true)
        else
            if inst.AnimState:IsCurrentAnimation("place") then
                inst.AnimState:PushAnimation("proximity_pre")
            else
                inst.AnimState:PlayAnimation("proximity_pre")
            end
            inst.AnimState:PushAnimation("proximity_loop", true)
        end
    end

    if not inst.SoundEmitter:PlayingSound("loopsound") then
        inst.SoundEmitter:PlaySound("rifts2/shadow_forge/proximity_lp", "loopsound")
    end
end

local function onturnoff(inst)
    if not inst._activetask then
        inst.AnimState:PushAnimation("proximity_pst")
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:PlaySound("rifts2/shadow_forge/proximity_pst")
    end
    inst.SoundEmitter:KillSound("loopsound")
end

----
local function do_on_action(inst)
    inst._activecount = math.max(inst._activecount - 1, 0)
end

local function done_action(inst)
    inst._activetask = nil
    if inst.components.prototyper.on then
        onturnon(inst)
    else
        onturnoff(inst)
    end
end

local function onactivate(inst)
    inst.AnimState:PlayAnimation("use")
    inst.SoundEmitter:PlaySound("rifts2/shadow_forge/use")
    inst._activecount = inst._activecount + 1
    inst:DoTaskInTime(1.5, do_on_action)

    if inst._activetask then
        inst._activetask:Cancel()
    end
    inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), done_action)
end

----
local function onbuilt(inst, data)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("rifts2/shadow_forge/place")
end

----
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --match kit item
    MakeObstaclePhysics(inst, 0.4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("shadow_forge.png")

    inst.AnimState:SetBank("shadow_forge")
    inst.AnimState:SetBuild("shadow_forge")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("shadow_forge")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst.scrapbook_specialinfo = "SHADOWFORGE"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_anim = "proximity_loop"

    inst._activecount = 0
    inst._activetask = nil

    --
    inst:AddComponent("inspectable")

    --
    local prototyper = inst:AddComponent("prototyper")
    prototyper.onturnon = onturnon
    prototyper.onturnoff = onturnoff
    prototyper.onactivate = onactivate
    prototyper.trees = TUNING.PROTOTYPER_TREES.SHADOW_FORGE

    -- Lootdropper to drop recipe components on hammer
    inst:AddComponent("lootdropper")

    --
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.HAMMER)
    workable:SetWorkLeft(4)
    workable:SetOnFinishCallback(on_finished_hammering)
    workable:SetOnWorkCallback(onhit)

    --
    local hauntable = inst:AddComponent("hauntable")
    hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    --
    MakeSnowCovered(inst)

    --
    inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

return Prefab("shadow_forge", fn, assets, prefabs),
    MakeDeployableKitItem("shadow_forge_kit", "shadow_forge", "shadow_forge", "shadow_forge", "kit", assets),
    MakePlacer("shadow_forge_kit_placer", "shadow_forge", "shadow_forge", "idle")
