require("stategraphs/commonstates")

local function spawnsplash(inst)

    local theta = (inst.Transform:GetRotation()-180) * DEGREES
    local dist = 1
    local offset = Vector3(dist * math.cos( theta ), 0, -dist * math.sin( theta ))
    local fx = SpawnPrefab("weregoose_splash")
    local newpt = offset + Vector3(inst.Transform:GetWorldPosition())
    fx.Transform:SetPosition(newpt:Get())
end

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.PICKUP, "action"),
    ActionHandler(ACTIONS.GIVE, "action"),
    ActionHandler(ACTIONS.STEAL, "steal"),
    ActionHandler(ACTIONS.PICK, "action"),
    ActionHandler(ACTIONS.ATTACK, "attack"),
    ActionHandler(ACTIONS.BOAT_CANNON_SHOOT, "action"),
    ActionHandler(ACTIONS.HARVEST, "action"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.ROW, "row"),
    ActionHandler(ACTIONS.EMPTY_CONTAINER, "empty"),

    ActionHandler(ACTIONS.LOWER_ANCHOR, "action"),
    ActionHandler(ACTIONS.RAISE_SAIL, "action"),
    ActionHandler(ACTIONS.LOWER_SAIL, "action"),
    ActionHandler(ACTIONS.HAMMER, "hammer"),
    ActionHandler(ACTIONS.ABANDON, "dive"),
}

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnHop(),
    CommonHandlers.OnSink(),
    CommonHandlers.OnSleep(),

    EventHandler("victory", function(inst, data)
        inst.sg:GoToState("victory",data)
    end),

    EventHandler("cheer", function(inst, data)
        inst.sg:GoToState("taunt",data)
    end),

    EventHandler("onsink", function(inst, data)
        if (inst.components.health == nil or not inst.components.health:IsDead()) and not inst.sg:HasStateTag("drowning") and (inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown()) then
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
				inst.components.inventory:DropEverything(true)
                inst:Remove()
            end
    end),
}

local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end

local states =
{
    State{

        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/idle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.components.combat.target and
                    inst.components.combat.target:HasTag("player") then

                    if math.random() < 0.05 then
                        inst.sg:GoToState("taunt")
                        return
                    end
                end

                inst.sg:GoToState("idle")
            end),
        },
    },

    State{

        name = "action",
        tags = {"busy", "action", "caninterrupt"},
        onenter = function(inst, playanim)
            if inst:GetBufferedAction().target and inst:GetBufferedAction().target.components.boatcannon then
                local cannon = inst:GetBufferedAction().target
                cannon.components.timer:StartTimer("monkey_biz", 4)
                if not cannon.components.boatcannon:IsAmmoLoaded() then
                    cannon.components.boatcannon:LoadAmmo("cannonball_rock")
                end
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("action_pre")
            inst.AnimState:PushAnimation("action",false)
           -- inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst)
                local ba = inst:GetBufferedAction()
                if ba and ba.target
                        and ba.target.components.boatcannon
                        and inst.cannon ~= nil then
                    inst.cannon.operator = nil
                    inst.cannon = nil
                end

                inst.ClearTinkerTarget(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", go_to_idle),
        }
    },

    State{
        name = "hammer",
        tags = {"busy", "action", "caninterrupt"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(17*FRAMES, function(inst)
                inst.ClearTinkerTarget(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        }
    },

    State{

        name = "empty",
        tags = {"busy", "caninterrupt"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("unequipped_atk")
        end,

        timeline =
        {
            TimeEvent(15*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
                inst:PerformBufferedAction()
            end)
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        }
    },


    State{
        name = "victory",
        tags = {"busy", "caninterrupt"},
        onenter = function(inst, data)
            inst.Physics:Stop()

            inst.victory = true

            if data.say then
                inst.sg.statemem.say = data.say
            end

            if data and data.item then
                if data.item.prefab == "cave_banana" then
                    inst.AnimState:OverrideSymbol("swap_item", "cave_banana", "cave_banana01")
                elseif data.item.prefab == "cave_banana_cooked" then
                    inst.AnimState:OverrideSymbol("swap_item", "cave_banana", "cave_banana02")
                end
                inst.AnimState:PlayAnimation("action_victory_pre")

                inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/victory_pre")
            else
                inst.sg:GoToState("victory_pst", data)
            end
        end,

        events =
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("victory_pst", {say = inst.sg.statemem.say} )
            end),
        }
    },

    State{
        name = "victory_pst",
        tags = {"busy", "caninterrupt"},
        onenter = function(inst, data)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("victory")
            inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/victory")

            local say_script = (data and data.say)
                or STRINGS["MONKEY_BATTLECRY_VICTORY_CHEER"][math.random(#STRINGS["MONKEY_BATTLECRY_VICTORY_CHEER"])]
            inst.components.talker:Say(say_script)
        end,

        timeline =
        {
            TimeEvent(9*FRAMES, function(inst)
                PlayFootstep(inst)
            end),

            TimeEvent(25*FRAMES, function(inst)
                local crewmember = inst.components.crewmember
                if crewmember and crewmember.boat and crewmember.boat.components.boatcrew then
                    crewmember.boat.components.boatcrew:CrewCheer()
                end
                PlayFootstep(inst)
            end),

            TimeEvent(40*FRAMES, function(inst)
                PlayFootstep(inst)
            end),

            TimeEvent(54*FRAMES, function(inst)
                PlayFootstep(inst)
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        }
    },

    State{

        name = "eat",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat", true)
        end,

        onexit = function(inst)
            inst:PerformBufferedAction()
        end,

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst)
                local waittime = FRAMES*8
                for i = 0, 3 do
                    inst:DoTaskInTime((i * waittime), function(inst2)
                        inst2.SoundEmitter:PlaySound("monkeyisland/powdermonkey/eat")
                    end)
                end
            end)
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        }
    },

    State{
        name = "taunt",
        tags = {"busy", "caninterrupt"},

        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.sg.statemem.say = data and data.say
        end,

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst)
                local bc = inst.components.crewmember and inst.components.crewmember.boat and inst.components.crewmember.boat.components.boatcrew or nil                
                inst.components.talker:Say(
                    inst.sg.statemem.say
                    or (bc and bc.statis == "retreat" and STRINGS["MONKEY_TALK_RETREAT"][math.random(#STRINGS["MONKEY_TALK_RETREAT"])])
                    or STRINGS["MONKEY_BATTLECRY"][math.random(#STRINGS["MONKEY_BATTLECRY"])]
                )
                inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/taunt")
            end)
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "row",
        tags = {"busy", "caninterrupt"},
        onenter = function(inst, playanim)
            local boat = inst:GetCurrentPlatform()
            if boat then
                inst.Transform:SetRotation(inst:GetAngleToPoint(boat.Transform:GetWorldPosition()))
            end
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("row_pre",false)
            inst.AnimState:PushAnimation("row_loop",false)
            inst.AnimState:PushAnimation("row_pst",false)

            inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/row")

        end,

        timeline =
        {
            TimeEvent(7*FRAMES, function(inst)
                spawnsplash(inst)
                if inst.components.crewmember then
                    inst.components.crewmember:Row()
                end
                inst:ClearBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function (inst)
                if inst.components.crewmember and inst.components.crewmember:Shouldrow() then
                    inst.sg:GoToState((math.random() < 0.1 and "taunt") or "row")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        }
    },


    State{
        name = "dive",
        tags = {"busy", "nomorph"},

        onenter = function(inst)
            local platform = inst:GetCurrentPlatform()
            if platform then
                local pt = inst:GetPosition()
                local angle = platform:GetAngleToPoint(pt)
                inst.Transform:SetRotation(angle)
            end

            inst.AnimState:PlayAnimation("dive")
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.SoundEmitter:PlaySound("monkeyisland/primemate/dive")
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.sg.statemem.collisionmask = inst.Physics:GetCollisionMask()
                inst.Physics:SetCollisionMask(COLLISION.GROUND)
                if not TheWorld.ismastersim then
                    inst.Physics:SetLocalCollisionMask(COLLISION.GROUND)
                end

                inst.Physics:SetMotorVelOverride(5,0,0)
            end),

            TimeEvent(30*FRAMES, function(inst)
                inst.Physics:Stop()
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
        },

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()

            inst.Physics:ClearLocalCollisionMask()
            if inst.sg.statemem.collisionmask ~= nil then
                inst.Physics:SetCollisionMask(inst.sg.statemem.collisionmask)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                local x, y, z = inst.Transform:GetWorldPosition()
                if TheWorld.Map:IsVisualGroundAtPoint(x, y, z) or inst:GetCurrentPlatform() then
                    inst.sg:GoToState("dive_pst_land")
                else
                    SpawnPrefab("splash_green").Transform:SetPosition(x, y, z)

					inst.components.inventory:DropEverything(true)
                    inst:Remove()
                end
            end),
        },
    },

    State{
        name = "steal",
        tags = {"busy","caninterrupt"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("unequipped_atk")
        end,

        timeline =
        {
            TimeEvent(14*FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/attack_unarmed")
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },


    State{
        name = "dive_pst_land",
        tags = {"busy"},

        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("dive_pst_land")
            PlayFootstep(inst)
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {

    },

	walktimeline =
    {
        TimeEvent(5*FRAMES, PlayFootstep),
        TimeEvent(13*FRAMES, PlayFootstep),
	},

    endtimeline =
    {
        TimeEvent(5*FRAMES, PlayFootstep),
    },
})


CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/sleep_pre") 
        end),
    },

    sleeptimeline =
    {
        TimeEvent(FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/sleep_lp", "sleep_lp") 
        end),
    },

    endtimeline =
    {
        TimeEvent(FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/sleep_pst") 
        end),
    },
},{
    onsleepexit = function(inst)
        inst.SoundEmitter:KillSound("sleep_lp")
    end,
})

CommonStates.AddCombatStates(states,
{
    attacktimeline =
    {
        TimeEvent(14*FRAMES, function(inst)
            local act = inst:GetBufferedAction()
            if act and act.action.id == ACTIONS.ATTACK.id and act.target then
                inst.components.combat:DoAttack(act.target)
                inst:ClearBufferedAction()
            else
                inst.components.combat:DoAttack()
            end

            inst.SoundEmitter:PlaySound(
                (inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and "monkeyisland/powdermonkey/attack_sword")
                or "monkeyisland/powdermonkey/attack_unarmed"
            )
        end),
    },

    hittimeline =
    {
        TimeEvent(FRAMES, function(inst)
            inst.components.timer:StartTimer("hit",2+(math.random()*2))
            inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/hit")
        end),
    },

    deathtimeline =
    {
        TimeEvent(FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("monkeyisland/powdermonkey/death")
        end),
    },
},nil,{
    attackanimfn = function(inst) 
        return (inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) and "atk")
            or "unequipped_atk"
    end
})

CommonStates.AddFrozenStates(states)
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst"})

return StateGraph("powdermonkey", states, events, "idle", actionhandlers)
