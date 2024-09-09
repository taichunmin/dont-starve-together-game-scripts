require "prefabutil"

local prefabs =
{
    "collapse_small",
}

local assets =
{
    Asset("ANIM", "anim/stagehand.zip"),
    Asset("ANIM", "anim/swap_flower.zip"),
    Asset("SOUND", "sound/sfx.fsb"),
}

local function HasFreshFlowers(inst)
    return inst.flowerid ~= nil and inst.task ~= nil
end

local function RemoveFlower(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.Light:Enable(false)
    if inst.lighttask ~= nil then
        inst.lighttask:Cancel()
        inst.lighttask = nil
    end

    inst.flowerid = nil
    inst.AnimState:HideSymbol("swap_flower")
    inst.AnimState:SetLightOverride(0)
end

local function WiltFlower(inst)
    if inst._hack_do_not_wilt then
        if inst.task ~= nil then
            inst.task:Cancel()
            inst.task = nil
        end
        inst.task = inst:DoTaskInTime(inst._hack_do_not_wilt, WiltFlower)
        return
    end

    inst.AnimState:ShowSymbol("swap_flower")
    inst.AnimState:OverrideSymbol("swap_flower", "swap_flower", "f"..tostring(inst.flowerid).."_wilt")
    inst.AnimState:SetLightOverride(0)

    inst.Light:Enable(false)
    if inst.lighttask ~= nil then
        inst.lighttask:Cancel()
        inst.lighttask = nil
    end

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function updatelight(inst)
    local remaining = GetTaskRemaining(inst.task) / TUNING.ENDTABLE_FLOWER_WILTTIME
    inst.Light:SetRadius(1.5 + (1.5 * remaining))
    inst.Light:SetIntensity(0.4 + (0.4 * remaining))
    inst.Light:SetFalloff(0.8 + (1 - 1 * remaining))
end

local function GiveFlower(inst, flowerid, lifespan, giver)
    if TUNING.VASE_FLOWER_SWAPS[flowerid].sanityboost ~= 0 and
        giver ~= nil and
        giver.components.sanity ~= nil and
        not HasFreshFlowers(inst) then
        -- Placing fresh flowers gives a sanity boost
        giver.components.sanity:DoDelta(TUNING.VASE_FLOWER_SWAPS[flowerid].sanityboost)
    end

    inst.flowerid = flowerid

    inst.AnimState:ShowSymbol("swap_flower")
    inst.AnimState:OverrideSymbol("swap_flower", "swap_flower", "f"..tostring(inst.flowerid))

    if inst.lighttask ~= nil then
        inst.lighttask:Cancel()
        inst.lighttask = nil
    end

    if TUNING.VASE_FLOWER_SWAPS[inst.flowerid].lightsource then
        inst.AnimState:SetLightOverride(0.3)
        inst.Light:Enable(true)
        inst.lighttask = inst:DoPeriodicTask(TUNING.ENDTABLE_LIGHT_UPDATE + math.random(), updatelight, 0)
        inst._hack_do_not_wilt = nil
    else
        inst.AnimState:SetLightOverride(0)
        inst.Light:Enable(false)
        inst._hack_do_not_wilt = lifespan
    end

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.task = inst:DoTaskInTime(lifespan, WiltFlower)
end

local function ondeconstructstructure(inst)
    if inst.flowerid ~= nil then
		inst.components.lootdropper:SpawnLootPrefab("spoiled_food") -- because destroying an endtable will spoil any flowers in it
    end
end

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker, workleft)
    if workleft > 0 and not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stagehand/hit")
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stagehand/hit")
end

local function ongetitem(inst, giver, item)
    local wilttime = item.components.perishable ~= nil and item.components.perishable:GetPercent() * TUNING.ENDTABLE_FLOWER_WILTTIME or TUNING.ENDTABLE_FLOWER_WILTTIME
    GiveFlower(inst, GetRandomItem(TUNING.VASE_FLOWER_MAP[item.prefab]), wilttime, giver)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stagehand/hit")
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
end

local function onignite(inst)
    if inst.components.vase ~= nil then
        inst.components.vase:Disable()
    end

    if inst.flowerid ~= nil then
        inst._hack_do_not_wilt = nil
        WiltFlower(inst)
    end

    DefaultBurnFn(inst)
end

local function onextinguish(inst)
    if inst.components.vase ~= nil then
        inst.components.vase:Enable()
    end
    DefaultExtinguishFn(inst)
end

local function onburnt(inst)
    if inst.components.vase ~= nil then
        inst:RemoveComponent("vase")
    end

    if inst.flowerid ~= nil then
        inst.components.lootdropper:SpawnLootPrefab("ash")
        RemoveFlower(inst)
    end

    DefaultBurntStructureFn(inst)
end

local function lootsetfn(lootdropper)
    if lootdropper.inst.flowerid ~= nil then
        lootdropper:SetLoot({ "spoiled_food" }) -- because destroying an endtable will spoil any flowers in it
    end
end

local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.flowerid == nil and "EMPTY")
        or (inst.task == nil and "WILTED")
        or (TUNING.VASE_FLOWER_SWAPS[inst.flowerid].lightsource and (GetTaskRemaining(inst.task) / TUNING.ENDTABLE_FLOWER_WILTTIME < .1 and "OLDLIGHT" or "FRESHLIGHT"))
        or nil
end

--
local function OnLongUpdate(inst, dt)
    if inst.task then
        local time_remaining = GetTaskRemaining(inst.task) - dt
        inst.task:Cancel()

        if time_remaining > 0 then
            inst.task = inst:DoTaskInTime(time_remaining, WiltFlower)
        else
            WiltFlower(inst)
        end
    end
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    elseif inst.flowerid ~= nil then
        data.flowerid = inst.flowerid
        if inst.task ~= nil then
            data.wilttime = GetTaskRemaining(inst.task)
        end
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end

        if data.flowerid ~= nil then
            if data.wilttime ~= nil then
                GiveFlower(inst, data.flowerid, data.wilttime)
            else
                inst.flowerid = data.flowerid
                WiltFlower(inst)
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Light:SetFalloff(0.9)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(1.5)
    inst.Light:SetColour(169/255, 231/255, 245/255)
    inst.Light:Enable(false)

	inst:SetDeploySmartRadius(0.75) --recipe min_spacing/2

    MakeObstaclePhysics(inst, .6)

    inst:AddTag("structure")
    inst:AddTag("vase")

    inst.AnimState:SetBank("stagehand")
    inst.AnimState:SetBuild("stagehand")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:HideSymbol("swap_flower")  -- no flowers on placement

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("vase")
    inst.components.vase.ondecorate = ongetitem

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(lootsetfn)

    MakeSmallBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnExtinguishFn(onextinguish)
    inst.components.burnable:SetOnBurntFn(onburnt)

    MakeSmallPropagator(inst)
    MakeHauntableWork(inst)
    MakeSnowCovered(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("ondeconstructstructure", ondeconstructstructure)

    inst.OnLongUpdate = OnLongUpdate
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("endtable", fn, assets, prefabs),
       MakePlacer("endtable_placer", "stagehand", "stagehand", "idle", nil, nil, nil, nil, nil, nil, function(inst) inst.AnimState:HideSymbol("swap_flower") end)
