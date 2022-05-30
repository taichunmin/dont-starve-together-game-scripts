local carratrace_common = require("prefabs/yotc_carrat_race_common")

require "prefabutil"

local FOOD_LAUNCH_SPEED = 2
local FOOD_LAUNCH_STARTHEIGHT = 1

local function ejectitem(inst,item)
    if item ~= nil then
        if item ~= inst.components.shelf.itemonshelf then
            inst.components.inventory:DropItem(item)
        end
        inst.components.shelf:TakeItem(nil) -- taker == nil means item isn't given to an inventory
        if item.sg ~= nil then
            item.sg:GoToState("idle")
        end
    end
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end
end

local function OnIgnite(inst)
    if inst.components.trader then
        inst.components.trader:Disable()
    end
    DefaultBurnFn(inst)
    if inst.components.gym and inst.components.gym.trainee then
        ejectitem(inst,inst.components.gym.trainee)
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
    if inst.components.gym and inst.components.gym.trainee then
        ejectitem(inst,inst.components.gym.trainee)
    end
    inst:PushEvent("hit")
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

local function ShouldAcceptItem(inst, item, giver)
    if item.prefab == "carrat" and inst.components.inventory:NumItems() <= 0 then
        if (not item.components.perishable or item.components.perishable:GetPercent() >(TUNING.CARRAT_GYM.TRAINING_TIME/TUNING.CARRAT.PERISH_TIME + 0.1) ) then
            return true
        else
            giver.components.talker:Say(GetString(giver, "ANNOUNCE_WEAK_RAT"))
        end
    end
end

local function getcarrat(inst, item, train)
    inst:PushEvent("ratupdate")
    if inst.components.trader ~= nil then
        inst.components.trader:Disable()
    end
    inst.components.shelf:PutItemOnShelf(item)
    inst.components.gym:SetTrainee(item)
    if train then
        inst.components.gym:StartTraining(inst)
    end
    if item._color ~= nil then
        inst.AnimState:OverrideSymbol("carrat_tail", "yotc_carrat_colour_swaps", item._color.."_carrat_tail")
        inst.AnimState:OverrideSymbol("carrat_ear", "yotc_carrat_colour_swaps", item._color.."_carrat_ear")
        inst.AnimState:OverrideSymbol("carrot_parts", "yotc_carrat_colour_swaps", item._color.."_carrot_parts")
    else
        inst.AnimState:OverrideSymbol("carrat_tail", "carrat_build", "carrat_tail")
        inst.AnimState:OverrideSymbol("carrat_ear", "carrat_build", "carrat_ear")
        inst.AnimState:OverrideSymbol("carrot_parts", "carrat_build", "carrot_parts")
    end
    if TheWorld.state.isnight then
        inst:PushEvent("rest")
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    if giver:HasTag("player") then
        inst.rat_trainer_id = giver.userid
    end
    if item then
        if item.prefab == "carrat" and not inst.components.burnable:IsBurning() then
            getcarrat(inst, item, true)
        else
            ejectitem(inst,item)
        end
    end
end

local function OnLoseItem(inst)
    inst._musicstate:set(CARRAT_MUSIC_STATES.NONE)
    inst:PushEvent("ratupdate")
    if inst.components.trader ~= nil then
        inst.components.trader:Enable()
    end
    inst.components.gym:StopTraining()
    inst.AnimState:ClearOverrideSymbol("carrat_tail")
    inst.AnimState:ClearOverrideSymbol("carrat_ear")
    inst.AnimState:ClearOverrideSymbol("carrot_parts")
    inst.rat_trainer_id = nil
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

        if inst.components.gym and item == inst.components.gym.trainee then
            inst.components.gym:RemoveTrainee()
        end
    end
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
                taker.components.talker:Say(GetActionFailString(taker, "PICKUP", "NOTMINE_YOTC"))
                return false
            end
        end

        -- The owner is no longer on the server; you are allowed to remove their rat.
        return true
    end
end

local function getstatus(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst.components.gym and inst.components.gym.trainee then
        return "RAT"
    end
end

local function DirectionGymTrain(inst,trainee)
    trainee.dodirectiongym(trainee)
end

local function SpeedGymTrain(inst,trainee)
    trainee.dospeedgym(trainee)
end

local function StaminaGymTrain(inst,trainee)
    trainee.dostaminagym(trainee)
end

local function ReactionGymTrain(inst,trainee)
    trainee.doreactiongym(trainee)
end

local function OnMusicStateDirty(inst)
    if inst._musicstate:value() > 0 and ThePlayer ~= nil then
        if inst._musicstate:value() == CARRAT_MUSIC_STATES.TRAINING then
            if ThePlayer:GetDistanceSqToInst(inst) < 20*20 then
                ThePlayer:PushEvent("playtrainingmusic")
            end
        end
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
            inst:PushEvent("onburnt")
        end
        inst.rat_trainer_id = data.rat_trainer_id
    end
end

local function OnLoadPostPass(inst)
    if not IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
        inst.components.inventory:DropEverything()
    end

    if inst.components.inventory:FindItem(function(item) if item.prefab == "carrat" then return true end end) then
        local item = inst.components.inventory:FindItem(function(item) if item.prefab == "carrat" then return true end end)
        getcarrat(inst, item)
    end
end

local function onburnt(inst)
    DefaultBurntStructureFn(inst)

    if inst.components.yotc_racestart ~= nil then
        inst:RemoveComponent("yotc_racestart")
    end

    inst.AnimState:PlayAnimation("burnt")

    inst._rug:PushEvent("onburntup")
end

local function MakeGym(name, build, size)
    local assets =
    {
        Asset("ANIM", "anim/yotc_"..name..".zip"),
        Asset("ANIM", "anim/yotc_"..build..".zip"),
        Asset("ANIM", "anim/yotc_carrat_colour_swaps.zip"),
        Asset("ANIM", "anim/carrat_build.zip"),
        Asset("ANIM", "anim/yotc_"..name.."_item.zip"),
        Asset("INV_IMAGE", "yotc_"..name),
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

        MakeObstaclePhysics(inst, size)

        inst.MiniMapEntity:SetIcon("yotc_"..name..".png")

        inst:AddTag("structure")

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild("yotc_"..build)
        inst.AnimState:AddOverrideBuild("carrat_build")
        if name == "carrat_gym_stamina" then
            inst.AnimState:Hide("mouseover")
        end

        inst.AnimState:PlayAnimation("idle")

        MakeSnowCoveredPristine(inst)

        inst._musicstate = net_tinybyte(inst.GUID, "gym.musicstate", "musicstatedirty")
        inst._musicstate:set(CARRAT_MUSIC_STATES.NONE)

        if not TheNet:IsDedicated() then
            inst:ListenForEvent("musicstatedirty", OnMusicStateDirty)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("lootdropper")
        inst:SetStateGraph("SGrat_gym")

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

        if IsSpecialEventActive(SPECIAL_EVENTS.YOTC) then
            inst:AddComponent("trader")
            inst.components.trader:SetAcceptTest(ShouldAcceptItem)
            inst.components.trader.onaccept = OnGetItemFromPlayer
            inst.components.trader.deleteitemonaccept = false
        end

        inst:AddComponent("inventory")
        inst.components.inventory.maxslots = 1

        inst:AddComponent("timer")

        inst:AddComponent("gym")
        if name == "carrat_gym_direction" then
            inst.components.gym:SetTrainFn(DirectionGymTrain)
        elseif name == "carrat_gym_speed" then
            inst.components.gym:SetTrainFn(SpeedGymTrain)
        elseif name == "carrat_gym_stamina" then
            inst.components.gym:SetTrainFn(StaminaGymTrain)
        elseif name == "carrat_gym_reaction" then
            inst.components.gym:SetTrainFn(ReactionGymTrain)
        end
        inst.components.gym:SetOnRemoveTraineeFn(OnLoseItem)

        --inst:ListenForEvent("itemget", OnGetItem)
        inst:ListenForEvent("itemlose", OnLoseItem)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus

        MakeSnowCovered(inst)
        MakeHauntableWork(inst)

        MakeMediumBurnable(inst, nil, nil, true)

        MakeSmallPropagator(inst)
        inst.components.burnable:SetOnBurntFn(OnBurnt)
        inst.components.burnable:SetOnIgniteFn(OnIgnite)
        inst.components.burnable:SetOnExtinguishFn(OnExtinguish)

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        inst.OnLoadPostPass = OnLoadPostPass

        return inst
    end

    return Prefab("yotc_"..name, fn, assets, prefabs ),
        MakeDeployableKitItem(
            "yotc_"..name.."_item",                             -- name
            "yotc_"..name,                                      -- prefab_to_deploy
            "yotc_"..name.."_item",                             -- bank
            "yotc_"..name.."_item",                             -- build
            "idle",                                             -- anim
            {Asset("ANIM", "anim/yotc_"..name.."_item.zip")},   -- assets
            {size = "med", scale = 0.77},                       -- float data
            nil,                                                -- tags
            {fuelvalue = TUNING.LARGE_FUEL},                    -- burnable
            carratrace_common.deployable_data                   -- deploy
        ),
        MakePlacer("yotc_"..name.."_item_placer", name, "yotc_"..build, "placer")
end

local GYMDEFS ={
    {"carrat_gym_direction", "carrat_gym_direction_build", 1},
    {"carrat_gym_speed", "carrat_gym_speed_build", 1},
    {"carrat_gym_reaction", "carrat_gym_reaction_build", 1},
    {"carrat_gym_stamina", "carrat_gym_stamina_build", 1},
}

local gyms = {}
for i,gymdata in ipairs(GYMDEFS) do
    local gym,item,placer = MakeGym(gymdata[1], gymdata[2], gymdata[3])
    table.insert(gyms,gym)
    table.insert(gyms,item)
    table.insert(gyms,placer)
end
return unpack(gyms)

