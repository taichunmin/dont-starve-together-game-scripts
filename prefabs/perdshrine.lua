require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/perdshrine.zip"),
}

local prefabs =
{
    "collapse_small",
    "ash",
    "dug_berrybush",
    "dug_berrybush2",
    "dug_berrybush_juicy",
}

local function OnDeconstructStructure(inst)
    if inst.components.lootdropper.loot ~= nil then
        for i, v in ipairs(inst.components.lootdropper.loot) do
            inst.components.lootdropper:SpawnLootPrefab(v, inst:GetPosition())
        end
    end
end

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
        inst.AnimState:PushAnimation("idle", false)
    end
end

local PERD_TAG = { "perd" }
local SPAWNBUSH_MUST_TAGS = { "bush", "pickable" }
local SPAWNBUSH_CANT_TAGS = { "fire", "smolder", "diseased" }
local function TrySpawnPerd(inst)
    if not (inst.components.burnable ~= nil and
            (inst.components.burnable:IsBurning() or inst.components.burnable:IsSmoldering()) or
            inst:HasTag("burnt")) and
        inst.components.prototyper ~= nil and
        TheWorld.state.isday and
        FindEntity(inst, 16, nil, PERD_TAG) == nil then
        --spawn a perd from a nearby bush if there isn't one already
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 8, SPAWNBUSH_MUST_TAGS, SPAWNBUSH_CANT_TAGS)
        for i = #ents, 1, -1 do
            if string.sub(ents[i].prefab, 1, 9) ~= "berrybush" then
                table.remove(ents, i)
            end
        end
        if #ents > 0 then
            ents[math.random(#ents)]:PushEvent("spawnperd")
        end
    end
end

local function OnStartDay(inst)
    inst:DoTaskInTime(GetRandomMinMax(3, 5), TrySpawnPerd)
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end
    inst:StopWatchingWorldState("startday", OnStartDay)
    inst.components.lootdropper:SetLoot(inst.bush ~= "empty" and { "ash" } or nil)
end

local function OnIgnite(inst)
    if inst.components.trader ~= nil then
        inst.components.trader:Disable()
    end
    DefaultBurnFn(inst)
end

local function OnExtinguish(inst)
    if inst.components.trader ~= nil then
        inst.components.trader:Enable()
    end
    DefaultExtinguishFn(inst)
end

local function MakePrototyper(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end

    if inst.components.prototyper == nil then
        inst:AddComponent("prototyper")
        inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.PERDSHRINE

        if IsSpecialEventActive(SPECIAL_EVENTS.YOTG) then
            inst:WatchWorldState("startday", OnStartDay)
        end
    end
end

local function SetBush(inst, bush, loading)
    if bush == inst.bush then
        return
    elseif bush == "dug_berrybush" then
        inst.bush = nil
        inst.AnimState:ClearOverrideSymbol("berrybush")
    elseif bush == "dug_berrybush2" then
        inst.bush = "2"
        inst.AnimState:OverrideSymbol("berrybush", "perdshrine", "berrybush2")
    elseif bush == "dug_berrybush_juicy" then
        inst.bush = "_juicy"
        inst.AnimState:OverrideSymbol("berrybush", "perdshrine", "berrybush_juicy")
    else
        return
    end
    if not loading then
        inst.SoundEmitter:PlaySound("dontstarve/common/plant")
    end
    inst.AnimState:Show("bush")
    inst.components.lootdropper:SetLoot({ bush })
    MakePrototyper(inst)
end

local function ongivenitem(inst, giver, item)
    SetBush(inst, item.prefab, false)
end

local function abletoaccepttest(inst, item)
    return item.prefab == "dug_berrybush"
        or item.prefab == "dug_berrybush2"
        or item.prefab == "dug_berrybush_juicy"
end

local function MakeEmpty(inst)
    inst.bush = "empty"
    inst.AnimState:Hide("bush")

    if inst.components.prototyper ~= nil then
        inst:RemoveComponent("prototyper")
    end

    if inst.components.trader == nil then
        inst:AddComponent("trader")
        inst.components.trader:SetAbleToAcceptTest(abletoaccepttest)
        inst.components.trader.acceptnontradable = true
        inst.components.trader.onaccept = ongivenitem
    end

    inst.components.lootdropper:SetLoot(nil)

    inst:StopWatchingWorldState("startday", OnStartDay)
end

local function onbuilt(inst)
    --Make empty when first built.
    --Pristine state is not empty.
    MakeEmpty(inst)

    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/perd_shrine_place")
end

local function onsave(inst, data)
    data.bush = inst.bush
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.bush == "empty" then
            MakeEmpty(inst)
        else
            SetBush(inst, "dug_berrybush"..(data.bush or ""), true)
        end
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end
    end
end

local function GetStatus(inst)
    --return BURNT here otherwise EMPTY will always have priority over BURNT
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.prototyper == nil and "EMPTY")
        or nil
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(0.9) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("perdshrine.png")

    inst.AnimState:SetBank("perdshrine")
    inst.AnimState:SetBuild("perdshrine")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("perdshrine")

    --prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    MakePrototyper(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({ "dug_berrybush" })

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguish)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("ondeconstructstructure", OnDeconstructStructure)

    return inst
end

return Prefab("perdshrine", fn, assets, prefabs),
    MakePlacer("perdshrine_placer", "perdshrine", "perdshrine", "idle",
        nil, nil, nil, nil, nil, nil,
        function(inst)
            inst.AnimState:Hide("bush")
        end)
