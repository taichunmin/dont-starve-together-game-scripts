require "prefabutil"

local beefalo_sewing = require ("yotb_sewing")

local assets =
{
    Asset("ANIM", "anim/yotb_beefalo_sewingmachine.zip"),
    Asset("MINIMAP_IMAGE", "yotb_sewingmachine"),
}

local item_assets =
{
    Asset("ANIM", "anim/yotb_sewingmachine_item.zip"),
    Asset("INV_IMAGE", "yotb_sewingmachine_item"),
}

local prefabs =
{
    "collapse_small"
}

for k, v in pairs(beefalo_sewing.recipes) do
    table.insert(prefabs, v.prefab_name)
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end

    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        if inst.components.container ~= nil and inst.components.container:IsOpen() then
            inst.components.container:Close()
            --onclose will trigger sfx already
        else
            inst.SoundEmitter:PlaySound("yotb_2021/common/sewing_machine/close")
        end

        -- TODO: figure this out
        inst.AnimState:PlayAnimation("hit_empty")
        inst.AnimState:PushAnimation("idle_empty", false)
    end
end

--anim and sound callbacks
local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.AnimState:PushAnimation("idle_open", true)

        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("yotb_2021/common/sewing_machine/open")
        -- inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot", "snd")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        if not inst.components.yotb_sewer:IsSewing() then
            inst.AnimState:PlayAnimation("close")
            inst.AnimState:PushAnimation("idle_closed", true)

            inst.SoundEmitter:KillSound("snd")
        end

        inst.SoundEmitter:PlaySound("yotb_2021/common/sewing_machine/close")
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("yotb_2021/common/sewing_machine/place")
end

local function OnStartSewing(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("active_pre")
        inst.AnimState:PushAnimation("active_loop", true)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("yotb_2021/common/sewing_machine/LP", "snd")
    end
end

local function OnContinueSewing(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("active_pre")
        inst.AnimState:PushAnimation("active_loop", true)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("yotb_2021/common/sewing_machine/LP", "snd")
    end
end

local function OnContinueDone(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle")
    end
end

local function OnDoneSewing(inst)
    if not inst:HasTag("burnt") then
        --inst.AnimState:PlayAnimation("active_post")
        inst.AnimState:PushAnimation("active_spit")
        inst.AnimState:PushAnimation("idle", true)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("yotb_2021/common/sewing_machine/stop")
        inst.SoundEmitter:PlaySound("yotb_2021/common/sewing_machine/done")
    end
end


local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or "EMPTY"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("yotb_sewingmachine.png")

    inst.Transform:SetScale(0.9,0.9,0.9)

    inst:AddTag("structure")
    inst:AddTag("sewingmachine")

    inst.AnimState:SetBank("beefalo_sewingmachine")
    inst.AnimState:SetBuild("yotb_beefalo_sewingmachine")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("yotb_sewingmachine")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("yotb_sewer")
    inst.components.yotb_sewer.onstartsewing = OnStartSewing
    inst.components.yotb_sewer.oncontinuesewing = OnContinueSewing
    inst.components.yotb_sewer.oncontinuedone =   OnContinueDone
    inst.components.yotb_sewer.ondonesewing =     OnDoneSewing

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("yotb_sewingmachine", fn, assets, prefabs),
    MakeDeployableKitItem("yotb_sewingmachine_item", "yotb_sewingmachine", "yotb_sewingmachine_item", "yotb_sewingmachine_item", "idle", item_assets, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.MED_FUEL}),
    MakePlacer("yotb_sewingmachine_item_placer", "beefalo_sewingmachine", "yotb_beefalo_sewingmachine", "placer")
