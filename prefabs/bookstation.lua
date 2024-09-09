require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/bookstation.zip"),
    Asset("ANIM", "anim/ui_bookstation_4x5.zip")
}

local prefabs =
{
    "collapse_small",
}

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
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation(inst.components.prototyper.on and "proximity_loop" or "idle", inst.components.prototyper.on)
    end
end

local function doonact(inst)--, soundprefix)
    if inst._activecount > 1 then
        inst._activecount = inst._activecount - 1
    else
        inst._activecount = 0
        inst.SoundEmitter:KillSound("sound")
    end
    --inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_ding")
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

local function onturnon(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") then
        if inst.AnimState:IsCurrentAnimation("place") then
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PlayAnimation("proximity_loop", true)
        end
        inst.SoundEmitter:KillSound("idlesound")
    end
end

local function onturnoff(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:KillSound("proximity_loop")
    end
end

local function doneact(inst)
    inst._activetask = nil
    if not inst:HasTag("burnt") then
        if inst.components.prototyper.on then
            onturnon(inst)
        else
            onturnoff(inst)
        end
    end
end

local function onactivate(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("craft")
        inst.AnimState:PushAnimation("idle", true)
        if not inst.SoundEmitter:PlayingSound("sound") then
            inst.SoundEmitter:PlaySound("wickerbottom_rework/bookstation/craft", "sound")
            inst.SoundEmitter:SetVolume("sound", 0.5) -- TODO(JBK): Remove this line after audio engineer lowers this in the source sound file.
        end
        inst._activecount = inst._activecount + 1
        inst:DoTaskInTime(1.5, doonact)--, soundprefix)
        if inst._activetask ~= nil then
            inst._activetask:Cancel()
        end
        inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, doneact)
    end
end

local function onbuilt(inst, data)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("wickerbottom_rework/bookstation/place")
end

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation(inst.components.prototyper.on and "proximity_loop" or "idle", inst.components.prototyper.on)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation(inst.components.prototyper.on and "proximity_loop" or "idle", inst.components.prototyper.on)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
end

local function RestoreBooks(inst)

    local wicker_bonus = 1
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TUNING.BOOKSTATION_BONUS_RANGE, true)

    for _, player in ipairs(players) do
        if player:HasTag("bookbuilder") then
            wicker_bonus = TUNING.BOOKSTATION_WICKER_BONUS
            break
        end
    end

    for k,v in pairs(inst.components.container.slots) do
        if v:HasTag("book") and v.components.finiteuses then
            local percent = v.components.finiteuses:GetPercent()
            if percent < 1 then
                v.components.finiteuses:SetPercent(math.min(1, percent + (TUNING.BOOKSTATION_RESTORE_AMOUNT * wicker_bonus)))
            end
        end
    end
end

local function CountBooks(inst)
    local cmp = inst.components.container
    return cmp and (cmp:NumItems() / cmp:GetNumSlots()) or 0
end

local BOOKS_SOME = "empty"
local BOOKS_MORE = "mid"
local BOOKS_FULL = "full"

local function UpdateBookAesthetics(inst, countoverride)
    local count = countoverride or CountBooks(inst)
    if count == 0 then
        inst.AnimState:Hide(BOOKS_SOME)
        inst.AnimState:Hide(BOOKS_MORE)
        inst.AnimState:Hide(BOOKS_FULL)
    elseif count < 0.5 then
        inst.AnimState:Show(BOOKS_SOME)
        inst.AnimState:Hide(BOOKS_MORE)
        inst.AnimState:Hide(BOOKS_FULL)
    elseif count < 1 then
        inst.AnimState:Show(BOOKS_SOME)
        inst.AnimState:Show(BOOKS_MORE)
        inst.AnimState:Hide(BOOKS_FULL)
    else
        inst.AnimState:Show(BOOKS_SOME)
        inst.AnimState:Show(BOOKS_MORE)
        inst.AnimState:Show(BOOKS_FULL)
    end
end

local function ItemGet(inst)
    if inst.RestoreTask == nil then
        if inst.components.container:HasItemWithTag("book", 1) then
            inst.RestoreTask = inst:DoPeriodicTask(TUNING.BOOKSTATION_RESTORE_TIME, RestoreBooks)
        end
    end
    UpdateBookAesthetics(inst)
end

local function ItemLose(inst)
    if not inst.components.container:HasItemWithTag("book", 1) then
        if inst.RestoreTask ~= nil then
            inst.RestoreTask:Cancel()
            inst.RestoreTask = nil
        end
    end
    UpdateBookAesthetics(inst)
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
    inst.MiniMapEntity:SetIcon("bookstation.png")

    inst.AnimState:SetBank ("bookstation")
    inst.AnimState:SetBuild("bookstation")
    inst.AnimState:PlayAnimation("idle")
    UpdateBookAesthetics(inst, 0)

    inst:AddTag("structure")
    inst:AddTag("giftmachine")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- TODO: review this:
    inst._activecount = 0
    inst._activetask = nil

    inst:AddComponent("inspectable")
    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.BOOKCRAFT
    inst.components.prototyper.onactivate = onactivate

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("bookstation")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    
    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeSnowCovered(inst)
    MakeLargeBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:ListenForEvent("itemget", ItemGet)
    inst:ListenForEvent("itemlose", ItemLose)

    inst:ListenForEvent("ms_giftopened", onactivate)

    return inst
end

--------------------------------------------------------------------------

return Prefab("bookstation", fn, assets, prefabs),
       MakePlacer("bookstation_placer", "bookstation", "bookstation", "idle")