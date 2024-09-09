local assets =
{
    Asset("ANIM", "anim/monkey_queen.zip"),
    Asset("MINIMAP_IMAGE", "monkey_queen"),
}

local prefabs =
{
    "dock_kit",
}

local WAKEUP_DIST = 10
local SLEEP_DIST = 15

local function is_monkey_curse_item(item)
    return item.prefab == MONKEY_CURSE_PREFAB
end

local function on_accept_item(inst, giver, item)
    inst.sg:GoToState("getitem",{giver=giver, item=item})
    item:Remove()
end

local function on_refuse_item(inst, giver, item)
    inst.sg:GoToState("refuse")
end

local function able_to_accept_trade_test(inst, item, giver)
    local success = true
    local reason = nil

    if inst.sg:HasStateTag("busy") then
        success = false
        reason = "QUEENBUSY"
    end
    --[[
    if not giver:HasTag("wonkey") then
        success = false
        reason = "NOTAMONKEY"
    end
    ]]
    return success, reason
end

local function accept_trade_test(inst, item, giver)
    return item:HasTag("monkeyqueenbribe")
end

local function speech_override_fn(inst, speech)
    if not ThePlayer or ThePlayer:HasTag("wonkey") then
        return speech
    else
        return CraftMonkeySpeech()
    end 
end

local function FindGivingMonkey(inst, dist)
    return FindEntity(inst, dist, function(guy) 
        return guy.components.inventory and guy.components.inventory:FindItem(function(thing) return thing.prefab == "cave_banana" or thing.prefab == "cave_banana_cooked" end)
    end)
end

local function findwakereason(inst, dist)
    return FindClosestPlayerToInst(inst, WAKEUP_DIST, true) or FindGivingMonkey(inst, WAKEUP_DIST)
end

local function playerproxcheck(inst,dt)

    if findwakereason(inst, WAKEUP_DIST) then
        if inst.sg:HasStateTag("sleeping") then
            inst.sg:GoToState("wake")
        end
    elseif not findwakereason(inst, SLEEP_DIST) then
        if not inst.sg:HasStateTag("sleeping") and not inst.sg:HasStateTag("channel") and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("sleep")
        end
    end
end
local MONKEY_MUST = {"pirate"}
local function ontimerdone(inst, data)
    if data ~= nil then
        if data.name == "right_of_passage" then
            local x,y,z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 40, MONKEY_MUST)
            for i, ent in ipairs(ents) do
                ent:DoTaskInTime(
                    math.random()* 2, 
                    function() 
                        ent:PushEvent("victory",{say=STRINGS["MONKEY_BATTLECRY_TIME_UP"][math.random(1,#STRINGS["MONKEY_BATTLECRY_TIME_UP"])]} )
                    end)
            end
        end
    end
end

local function ontalk(inst, script)
    for i, text in ipairs(STRINGS.MONKEY_QUEEN_HAPPY) do
        if text == script then 
            return nil
        end
    end

    for i, text in ipairs(STRINGS.MONKEY_QUEEN_BANANAS) do
        if text == script then 
            return nil
        end
    end    
    inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/speak")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("monkeyisland/amb/island_amb_monkeys", "loop")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddDynamicShadow()
    
    inst:SetStateGraph("SGmonkeyqueen")

    inst.DynamicShadow:SetSize(6, 3.5)

    inst.MiniMapEntity:SetIcon("monkey_queen.png")
    inst.MiniMapEntity:SetPriority(1)

    inst.AnimState:SetBank ("monkey_queen")
    inst.AnimState:SetBuild("monkey_queen")
    inst.AnimState:PlayAnimation("idle", true)

    --trader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")
    inst:AddTag("shelter")
    inst:AddTag("monkey")
    inst:AddTag("monkeyqueen")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -1200, 0)
    inst.components.talker:MakeChatter()
    inst.components.talker.ontalk = ontalk

    inst.speech_override_fn = speech_override_fn    
    inst.scrapbook_anim = "scrapbook"

    if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(-190)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")
    
    ------------------------------------------------------
    inst:AddComponent("inspectable")

    ------------------------------------------------------
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(able_to_accept_trade_test)
    inst.components.trader:SetAcceptTest(accept_trade_test)
    inst.components.trader.onaccept = on_accept_item
    inst.components.trader.onrefuse = on_refuse_item

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(playerproxcheck)

    inst:AddComponent("timer")

    inst:ListenForEvent("timerdone", ontimerdone)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

return Prefab("monkeyqueen", fn, assets, prefabs)