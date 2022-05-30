local carratrace_common = require("prefabs/yotc_carrat_race_common")
require "prefabutil"

local FOOD_LAUNCH_SPEED = 2
local FOOD_LAUNCH_STARTHEIGHT = 1

local function SetStat(inst, dir, stam, reac, speed)
    if dir and stam and reac and speed then
        inst:DoTaskInTime(12 * FRAMES, function() inst.AnimState:OverrideSymbol("scale_rod_direction", "yotc_carrat_scale", "direction_"..dir) end)
        inst:DoTaskInTime(12 * FRAMES, function() inst.AnimState:OverrideSymbol("scale_rod_stamina", "yotc_carrat_scale", "stamina_"..stam) end)
        inst:DoTaskInTime(12 * FRAMES, function() inst.AnimState:OverrideSymbol("scale_rod_reaction", "yotc_carrat_scale", "reaction_"..reac) end)
        inst:DoTaskInTime(12 * FRAMES, function() inst.AnimState:OverrideSymbol("scale_rod_speed", "yotc_carrat_scale", "speed_"..speed) end)
    end
    inst:DoTaskInTime(29 * FRAMES, function()
        if inst.AnimState:IsCurrentAnimation("on_extend") then
            inst.SoundEmitter:PlaySound("yotc_2020/gym/scale/close")
        end
    end)
end

local function ejectitem(inst,item)
    if item ~= nil then
        if item ~= inst.components.shelf.itemonshelf then
            inst.components.inventory:DropItem(item)
        end
        inst.components.shelf:TakeItem(nil) -- taker == nil means item isn't given to an inventory
        inst.AnimState:PlayAnimation("idle",true)
    end
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end
end

local function OnIgnite(inst)
    inst.components.trader:Disable()
    DefaultBurnFn(inst)
    if inst.rat then
        ejectitem(inst,inst.rat)
    end
end

local function OnExtinguish(inst)
    if inst.components.trader ~= nil then
        inst.components.trader:Enable()
    end
    DefaultExtinguishFn(inst)
end

local function onhit(inst)
   -- toss rat
    if inst.rat then
        ejectitem(inst,inst.rat)
    end
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle",true)
end

local function onhammered(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("wood")

    inst:Remove()
end

local function ShouldAcceptItem(inst, item,giver)

    if item.prefab == "carrat" then
        if (not item.components.perishable or item.components.perishable:GetPercent() >(TUNING.CARRAT_GYM.TRAINING_TIME/TUNING.CARRAT.PERISH_TIME + 0.1) ) then
            return true
        else
            giver.components.talker:Say(GetString(giver, "ANNOUNCE_WEAK_RAT"))
        end
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    if giver:HasTag("player") then
        inst.rat_trainer_id = giver.userid
    end
end

local function OnGetItem(inst, data, notrain)
    local item = data.item
    if item then
        if item.prefab == "carrat" and not inst.components.burnable:IsBurning() then
            inst.rat = item
            item.gymscale = inst
            --inst:PushEvent("ratupdate")
            inst.components.trader:Disable()
            item.OnRemoveFn = function() inst.OnRemoveItem(inst) end
            inst:ListenForEvent("removed", item.OnRemoveFn, item)
            inst.components.shelf:PutItemOnShelf(data.item)
            -- inst.components.gym:SetTrainee(data.item)
            inst.AnimState:PlayAnimation("on")
            inst.AnimState:PushAnimation("on_extend",false)
            inst.AnimState:PushAnimation("on_loop",true)

            local stats = inst.rat.components.yotc_racestats
            if not stats then
                stats = {}
                stats.direction = 0
                stats.stamina = 0
                stats.reaction = 0
                stats.speed = 0
            end
            SetStat(inst,stats.direction,stats.stamina,stats.reaction,stats.speed)

            inst.SoundEmitter:PlaySound("yotc_2020/gym/scale/slide")

            if item._color ~= nil then
                inst.AnimState:OverrideSymbol("carrat_tail", "yotc_carrat_colour_swaps", item._color.."_carrat_tail")
                inst.AnimState:OverrideSymbol("carrat_ear", "yotc_carrat_colour_swaps", item._color.."_carrat_ear")
                inst.AnimState:OverrideSymbol("carrot_parts", "yotc_carrat_colour_swaps", item._color.."_carrot_parts")
            else
                inst.AnimState:OverrideSymbol("carrat_tail", "carrat_build", "carrat_tail")
                inst.AnimState:OverrideSymbol("carrat_ear", "carrat_build", "carrat_ear")
                inst.AnimState:OverrideSymbol("carrot_parts", "carrat_build", "carrot_parts")
            end
        else
            ejectitem(inst,item)
        end
    end
end

local function updateratstats(inst)
    if inst.rat then
        local stats = inst.rat.components.yotc_racestats
        if not stats then
            stats = {}
            stats.direction = 0
            stats.stamina = 0
            stats.reaction = 0
            stats.speed = 0
        end
        SetStat(inst,stats.direction,stats.stamina,stats.reaction,stats.speed)

        inst.AnimState:PlayAnimation("on_extend")
        inst.AnimState:PushAnimation("on_loop",true)

        inst.SoundEmitter:PlaySound("yotc_2020/gym/scale/slide")
    end
end

local function OnLoseItem(inst, data)
    if inst.rat then
        inst.rat.gymscale = nil
    end
    inst.rat = nil
    --inst:PushEvent("ratupdate")
    inst.components.trader:Enable()

    SetStat(inst,5,5,5,5)

    inst:DoTaskInTime(7 * FRAMES,function()
        if inst.AnimState:IsCurrentAnimation("off") then
            inst.SoundEmitter:PlaySound("yotc_2020/gym/scale/close")
        end
    end)

    inst.AnimState:PlayAnimation("off")
    inst.AnimState:PushAnimation("off_pst")
    inst.AnimState:PushAnimation("idle",true)

    inst.AnimState:ClearOverrideSymbol("carrat_tail")
    inst.AnimState:ClearOverrideSymbol("carrat_ear")
    inst.AnimState:ClearOverrideSymbol("carrot_parts")
end

local function OnRemoveItem(inst, taker, item)
    OnLoseItem(inst)
    if item and item:IsValid() then
        if item.OnRemoveFn then
            inst:RemoveEventCallback("removed", item.OnRemoveFn, item)
        end
    end
end

local function OnGotShelfItem(inst, item)
    item.on_rot_fn = function() ejectitem(inst, item) end
    inst:ListenForEvent("perished", item.on_rot_fn, item)
end

local function OnLoseShelfItem(inst, taker, item)
    if item and item:IsValid() then
        if item.on_rot_fn ~= nil then
            inst:RemoveEventCallback("perished", item.on_rot_fn, item)
        end
    end

    OnRemoveItem(inst, taker, item)
end

local function OnShelfTakeTest(inst, taker, item)
    if taker == nil then
        -- We're allowed to drop our shelved carrats onto the ground in case of emergency
        return true
    elseif not taker:HasTag("player") then
        -- Non-players cannot remove shelved carrats
        return false
    end

    local taker_id = taker.userid
    if taker_id == inst.rat_trainer_id then
        return true
    else
        for i, v in ipairs(AllPlayers) do
            if v.userid == inst.rat_trainer_id then
                taker.components.talker:Say(GetActionFailString(taker, "RECOVER_RACER"))
                return false
            end
        end

        -- The owner is no longer on the server; you are allowed to remove their rat.
        return true
    end
end

local function OnSave(inst, data)
    data.rat_trainer_id = inst.rat_trainer_id

    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function OnLoad(inst, data)
    if data then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end
        inst.rat_trainer_id = data.rat_trainer_id
    end
end

local function OnLoadPostPass(inst)
    if not IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
        inst.components.inventory:DropEverything()
    end
end

local function getstatus(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst.rat then
        local stats = inst.rat.components.yotc_racestats
        return (stats ~= nil and (stats.direction >= 5 or stats.reaction >= 5 or stats.speed >= 5 or stats.stamina >= 5)) and "CARRAT_GOOD" or "CARRAT"
    end
end

local function TestForCarratIdle(inst)
    if inst.AnimState:IsCurrentAnimation("on_loop") then
        if inst.rat then
            if inst.rat.components.yotc_racestats then
                local total = inst.rat.components.yotc_racestats:GetNumStatPoints()
                local stat = "speed"
                local rand = math.random(1,50)
                if rand <= total then
                    if rand <= inst.rat.components.yotc_racestats.speed then
                        stat = "speed"
                    elseif rand <= inst.rat.components.yotc_racestats.speed + inst.rat.components.yotc_racestats.direction then
                        stat = "direction"
                    elseif rand <= inst.rat.components.yotc_racestats.speed + inst.rat.components.yotc_racestats.direction + inst.rat.components.yotc_racestats.reaction then
                        stat = "reaction"
                    elseif rand <= inst.rat.components.yotc_racestats.speed + inst.rat.components.yotc_racestats.direction + inst.rat.components.yotc_racestats.reaction + inst.rat.components.yotc_racestats.stamina then
                        stat = "stamina"
                    end
                    inst.AnimState:PlayAnimation(stat)
                    inst.AnimState:PushAnimation("on_loop", true)
                else
                    inst.AnimState:PlayAnimation("on_loop", true)
                end
            else
                inst.AnimState:PlayAnimation("on_loop", true)
            end
        end
    end
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("yotc_2020/gym/scale/place")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
end


local assets =
{
    Asset("ANIM", "anim/yotc_carrat_scale.zip"),
    Asset("ANIM", "anim/yotc_carrat_colour_swaps.zip"),
    Asset("ANIM", "anim/carrat_build.zip"),
    Asset("INV_IMAGE", "yotc_carrat_scale_item"),
}

local prefabs =
{
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.25)

    inst.MiniMapEntity:SetIcon("yotc_carrat_scale.png")

    inst:AddTag("structure")

    inst.AnimState:SetBank("yotc_carrat_scale")
    inst.AnimState:SetBuild("yotc_carrat_scale")
    inst.AnimState:AddOverrideBuild("carrat_build")

    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("shelf")
    inst.components.shelf:SetOnShelfItem(OnGotShelfItem)
    inst.components.shelf:SetOnTakeItem(OnLoseShelfItem)
    inst.components.shelf.cantakeitem = true
    inst.components.shelf.takeitemtstfn = OnShelfTakeTest

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1

    inst:AddComponent("timer")

    inst:ListenForEvent("itemget", OnGetItem)
    inst:ListenForEvent("itemlose", OnLoseItem)
    inst:ListenForEvent("animover", TestForCarratIdle)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguish)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst.updateratstats = updateratstats

    inst.OnRemoveItem = OnRemoveItem
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("yotc_carrat_scale", fn, assets, prefabs ),
        MakeDeployableKitItem(
            "yotc_carrat_scale_item",
            "yotc_carrat_scale",
            "yotc_carrat_scale_item",
            "yotc_carrat_scale_item",
            "idle",
            {Asset("ANIM", "anim/yotc_carrat_scale_item.zip")},
            {size = "med", scale = 0.77},
            nil,
            {fuelvalue = TUNING.LARGE_FUEL},
            carratrace_common.deployable_data
        ),
       MakePlacer("yotc_carrat_scale_item_placer", "yotc_carrat_scale", "yotc_carrat_scale", "placer")


