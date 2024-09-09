local MONKEY_CURSE_PREFAB = "cursed_monkey_token"

local events =
{
    EventHandler("stopcursechanneling", function(inst, data)
        if inst.sg:HasStateTag("channel") then
            if data.success then
                inst.sg:GoToState("removecurse_success")
            else
                inst.sg:GoToState("removecurse_fail")
            end
        end
    end),
}

local BLUEPRINT_LOOTS = {
    "boat_cannon_kit",
    "cannonball_rock_item",
    "dock_kit",
    "dock_woodposts_item",
    "turf_monkey_ground",
}

local BLUEPRINTLOOTS_MUSTTAGS = {"_inventoryitem"}
local function FindBlueprintLootsIndex(x, y, z)
    local lootsindex = nil
    local ents = TheSim:FindEntities(x, y, z, 16, BLUEPRINTLOOTS_MUSTTAGS)
    for _, ent in ipairs(ents) do
        if ent.prefab == "blueprint" then
            for index, lootname in ipairs(BLUEPRINT_LOOTS) do
                if ent.recipetouse == lootname then
                    if lootsindex == nil then
                        lootsindex = index
                    elseif index > lootsindex then
                        lootsindex = index
                    end
                end
            end
        end
    end
    return lootsindex
end

local states =
{
    State{
        name = "idle",
        tags = {"idle"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle")
        end,
        events = 
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },

    State{
        name = "getitem",
        tags = {"busy"},
        onenter = function(inst, data)
            inst.components.talker:Say(STRINGS["MONKEY_QUEEN_BANANAS"][math.random(1,#STRINGS["MONKEY_QUEEN_BANANAS"])])

            if data and data.item then
                if data.item.prefab == "cave_banana" then
                    inst.AnimState:OverrideSymbol("swap_item", "cave_banana", "cave_banana01")
                elseif data.item.prefab == "cave_banana_cooked" then
                    inst.AnimState:OverrideSymbol("swap_item", "cave_banana", "cave_banana02")
                end            
            end
            
            inst.AnimState:PlayAnimation("receive_item")

            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/receive_item")

            inst.sg.statemem.giver = data.giver
        end,

        events = 
        {
            EventHandler("animover", function(inst) 
                local takemonkeycurse = false
                if inst.sg.statemem.giver then
                    if inst.sg.statemem.giver.components.cursable and (inst.sg.statemem.giver.components.cursable.curses.MONKEY or 0) > 0 then
                        takemonkeycurse = true
                    elseif inst.sg.statemem.giver:HasTag("wonkey") then -- NOTES(JBK): This only is true if the player gets into an invalid state, saves and reloads the save.
                        takemonkeycurse = true
                    end
                end
                if takemonkeycurse then
                    inst.sg:GoToState("removecurse", {giver = inst.sg.statemem.giver})
                else 
                    if inst.sg.statemem.giver:HasTag("player") then
                        local builder = inst.sg.statemem.giver.components.builder
                        local x, y, z = inst.Transform:GetWorldPosition()
                        local lootsindex = FindBlueprintLootsIndex(x, y, z)

                        local lootname
                        for index, recipename in ipairs(BLUEPRINT_LOOTS) do
                            if lootsindex == nil or lootsindex < index then
                                if builder == nil or not builder:KnowsRecipe(recipename) then
                                    lootname = recipename
                                    break
                                end
                            end
                        end

                        if not lootname then
                            lootname = BLUEPRINT_LOOTS[math.random(#BLUEPRINT_LOOTS)]
                        end

                        local loot = SpawnPrefab(lootname .. "_blueprint")
                        inst.components.lootdropper:FlingItem(loot)
                        loot:AddTag("nosteal")
                    end
                    inst.sg:GoToState("happy",{say="MONKEY_QUEEN_HAPPY"})
                end
            end)
        },
    },

    State{
        name = "happy",
        tags = {"busy"},
        onenter = function(inst, data)
            inst.components.talker:Say(STRINGS[data.say][math.random(1,#STRINGS[data.say])])
            inst.AnimState:PlayAnimation("happy")

            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/happy")
        end,

        events = 
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end)
        },    
    },

    State{
        name = "removecurse",
        tags = {"busy"},
        onenter = function(inst, data)
            inst.components.talker:Say(STRINGS["MONKEY_QUEEN_REMOVE_CURSE"][math.random(1,#STRINGS["MONKEY_QUEEN_REMOVE_CURSE"])])
            inst.AnimState:PlayAnimation("curse_remove_pre")
            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/channel_magic_pre")
            inst.sg.statemem.giver = data.giver
        end,

        events = 
        {
            EventHandler("animover", function(inst)
                -- NOTES(JBK): This handler must spawn a prop even if the original giver no longer exists to get out of the removecurse_channel state.
                local curseprop = SpawnPrefab("cursed_monkey_token_prop")
                curseprop:RemoveComponent("inventoryitem")
                curseprop:RemoveComponent("curseditem")
                local giver = inst.sg.statemem.giver
                if giver and giver:IsValid() then
                    curseprop.Transform:SetPosition(giver.Transform:GetWorldPosition())
                    if giver.components.inventory then
                        if giver.components.cursable then
                            giver.components.cursable:RemoveCurse("MONKEY", 4)
                        end
                        local curses =  giver.components.inventory:FindItems(function(thing) return thing:HasTag("monkey_token") end)
                        if #curses >= 0 then
                            inst.right_of_passage = true
                            if inst.components.timer:TimerExists("right_of_passage") then
                                inst.components.timer:SetTimeLeft("right_of_passage", TUNING.MONKEY_QUEEN_GRACE_TIME) -- TUNING.TOTAL_DAY_TIME/2 )
                            else
                                inst.components.timer:StartTimer("right_of_passage", TUNING.MONKEY_QUEEN_GRACE_TIME) -- TUNING.TOTAL_DAY_TIME/2
                            end
                        end
                    end
                else
                    curseprop.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
                curseprop.target = inst -- Set after SetPosition in case .target becomes something that has a function callback.
                inst.sg:GoToState("removecurse_channel")
            end)
        },
    },

    State{
        name = "removecurse_channel",
        tags = {"busy","channel"},
        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("channel_loop",true)

            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/channel_magic_lp","channel")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("channel")
        end
    },

    State{
        name = "removecurse_success",
        tags = {"busy"},
        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("curse_success")
            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/remove_curse_success")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end)
        },
    },

    State{
        name = "removecurse_fail",
        tags = {"busy"},
        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("curse_fail")
            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/remove_curse_fail")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end)
        },
    },    

    State{
        name = "sleep",
        tags = {"sleeping"},
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("sleep_pre")
            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/sleep_pre")
        end,

        events = 
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("sleeping")
            end)
        },
    },

    State{
        name = "sleeping",
        tags = {"sleeping"},
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("sleep_loop")
            if not inst.SoundEmitter:PlayingSound("sleep_lp") then
                inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/sleep_lp","sleep_lp")
            end
        end,

        onexit = function(inst,data)
            if not inst.sg.statemem.keeploopsnd == true then
                inst.SoundEmitter:KillSound("sleep_lp")
            end
        end,

        events = 
        {
            EventHandler("animover", function(inst) 
                inst.sg.statemem.keeploopsnd = true
                inst.sg:GoToState("sleeping")
            end)
        },
    },

    State{
        name = "wake",
        tags = {"waking"},
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("sleep_pst")
            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/sleep_post")
        end,

        events = 
        {
            EventHandler("animover", function(inst)
                inst.components.talker:Say(STRINGS["MONKEY_QUEEN_WAKE"][math.random(1,#STRINGS["MONKEY_QUEEN_WAKE"])])
                inst.sg:GoToState("idle")
            end)
        },
    },        

    State{
        name = "refuse",
        tags = {"busy"},
        onenter = function(inst,data)
            inst.AnimState:PlayAnimation("unimpressed")
            inst.SoundEmitter:PlaySound("monkeyisland/monkeyqueen/unimpressed")
        end,

        events = 
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end)
        },
    },    
}

return StateGraph("monkeyqueen", states, events, "idle")