require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/seafaring_prototyper.zip"),
    Asset("MINIMAP_IMAGE", "seafaring_prototyper"),
}

local prefabs =
{
    "collapse_small",
}

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        if inst.components.prototyper.on then
            inst.AnimState:PushAnimation("proximity_loop", true)
            if not inst.SoundEmitter:PlayingSound("loop_sound") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/seafaring_prototyper/LP", "loop_sound")
            end
        else
            inst.AnimState:PushAnimation("idle", false)
            inst.SoundEmitter:KillSound("loop_sound")
        end
    end
end

local function onturnoff(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:KillSound("loop_sound")
    end
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function onturnon(inst)
    if not inst:HasTag("burnt") then
        if inst.AnimState:IsCurrentAnimation("proximity_loop") or
            inst.AnimState:IsCurrentAnimation("place") or
            inst.AnimState:IsCurrentAnimation("use") then
            --NOTE: push again even if already playing, in case an idle was also pushed
            inst.AnimState:PushAnimation("proximity_loop", true)
            if not inst.SoundEmitter:PlayingSound("loop_sound") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/seafaring_prototyper/LP", "loop_sound")
            end
        else
            inst.AnimState:PlayAnimation("proximity_loop", true)
            if not inst.SoundEmitter:PlayingSound("loop_sound") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/seafaring_prototyper/LP", "loop_sound")
            end
        end
    end
end

local function onactivate(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("use")
        inst.AnimState:PushAnimation("proximity_loop", true)
        inst.SoundEmitter:PlaySound("turnoftides/common/together/seafaring_prototyper/use")
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/seafaring_prototyper/place")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("seafaring_prototyper.png")

    inst.AnimState:SetBank("lighthouse")
    inst.AnimState:SetBuild("seafaring_prototyper")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.onactivate = onactivate
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.SEAFARING_STATION

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)

    MakeLargeBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return Prefab("seafaring_prototyper", fn, assets, prefabs),
    MakePlacer("seafaring_prototyper_placer", "lighthouse", "seafaring_prototyper", "idle")
