require("stategraphs/commonstates")

local AREACLEAR_COMBAT = {"_combat"}
local AREACLEAR_CHECK_FOR_HOSTILES = {"hostile", "monster"}
local RINGOUT_TEXT_DATA = {text = STRINGS.RABBIT_GIVEUP}

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EQUIP, "pickup"),
    ActionHandler(ACTIONS.ADDFUEL, "pickup"),
    ActionHandler(ACTIONS.DROP, "pickup"),
    ActionHandler(ACTIONS.ATTACK, "attack_object"),
}

local events =
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(nil, TUNING.BUNNYMAN_MAX_STUN_LOCKS),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnHop(),
	CommonHandlers.OnSink(),
    EventHandler("gobacktocave", function(inst, data)
        if not inst.sg:HasStateTag("sleeping") and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("despawn")
        end
    end),

    EventHandler("cheer", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            inst.sg:GoToState("cheer", data)
        end
    end),

    EventHandler("disappoint", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            inst.sg:GoToState("disappoint", data)
        end
    end),

    EventHandler("dance", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            inst.sg:GoToState("dance", data)
        end
    end),

    EventHandler("reject", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            inst.sg:GoToState("reject", data)
        end
    end),

    EventHandler("question", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            inst.sg:GoToState("creepy", data)
        end
    end),

    EventHandler("hide", function(inst, data)
        if not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("hide")
        end
    end),

    EventHandler("digtolocation", function(inst, data)
        if not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("sleeping") then
            inst.sg:GoToState("digtolocation",data)
        end
    end),

    EventHandler("raiseobject", function(inst, data)
        if not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("sleeping") then
            inst.sg:GoToState("attack_object_pre", data)
        end
    end),

    EventHandler("pillowfight_ringout", function(inst, data)
        if inst.components.health and not inst.components.health:IsDead()
                and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            inst.sg:GoToState("disappoint", RINGOUT_TEXT_DATA)
        end
    end),

    EventHandler("doattack", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
                and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            inst.sg:GoToState((inst.sg.mem.is_holding_overhead and "attack_object")
                or "attack")
        end
    end),

    EventHandler("pillowfight_ended", function(inst, data)
        if data and data.won then
            inst.sg:GoToState("cheer", {})
        else
            inst.sg:GoToState("disappoint", {})
        end
    end),

    EventHandler("knockback", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("knockback", data)
        end
    end),

    EventHandler("gotyotrtoken", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("gottoken", data)
        end
    end),

    EventHandler("cheating", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("disappoint", {text = STRINGS.COZY_RABBIT_SPOILSPORT})
        end
    end),
}

local function go_to_idle(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState("idle")
    end
end

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, data)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            if math.random()<0.05 then
                inst.AnimState:PlayAnimation("idle_earrub",false)
            else
                inst.AnimState:PlayAnimation("idle_loop",false)
            end
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "cheer",
        tags = { "canrotate", "emote"},

        onenter = function(inst, data)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            if data.text then
                if type(data.text) == "table" then
                    data.text = data.text[math.random(1,#data.text)]
                end
                inst.components.talker:Say(data.text)
            end

            inst.AnimState:PlayAnimation("idle_happy",false)
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "dance",
        tags = { "canrotate", "emote"},

        onenter = function(inst, data)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end


            if data.text then
                if type(data.text) == "table" then
                    data.text = data.text[math.random(1,#data.text)]
                end
                inst.components.talker:Say(data.text)
            end
            inst.AnimState:PlayAnimation("dance",false)
         
        end,

        timeline =
            {
                TimeEvent(10 * FRAMES, function(inst)
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/happy")
            end),
            },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),

        },
    },

    State{
        name = "disappoint",
        tags = { "canrotate", "emote"},

        onenter = function(inst, data)
            inst.sayspoilsport = nil
            
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            if data.text then
                if type(data.text) == "table" then
                    data.text = data.text[math.random(1,#data.text)]
                end
                inst.components.talker:Say(data.text)
            end

            inst.AnimState:PlayAnimation("abandon",false)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },


    State{
        name = "creepy",
        tags = { "idle", "canrotate", "emote" },

        onenter = function(inst, data)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            if data.text then
                if type(data.text) == "table" then
                    data.text = data.text[math.random(1,#data.text)]
                end
                inst.components.talker:Say(data.text)
            end

            inst.AnimState:PlayAnimation("idle_creepy",false)
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "reject",
        tags = { "idle", "canrotate", "emote" },

        onenter = function(inst, data)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            if data.text then
                if type(data.text) == "table" then
                    data.text = data.text[math.random(1,#data.text)]
                end
                inst.components.talker:Say(data.text)
            end

            inst.AnimState:PlayAnimation("pig_reject",false)
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "funnyidle",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()

            if inst.components.health:GetPercent() < TUNING.BUNNYMAN_PANIC_THRESH then
                inst.AnimState:PlayAnimation("idle_angry")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/angry_idle")
            elseif inst.components.follower:GetLeader() ~= nil and inst.components.follower:GetLoyaltyPercent() < .05 then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
            elseif inst.components.combat:HasTarget() then
                inst.AnimState:PlayAnimation("idle_angry")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/angry_idle")
            elseif inst.components.follower:GetLeader() ~= nil and inst.components.follower:GetLoyaltyPercent() > .3 then
                inst.AnimState:PlayAnimation("idle_happy")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/happy")
            else
                inst.AnimState:PlayAnimation("idle_creepy")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/idle_med")
            end
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.causeofdeath = data ~= nil and data.afflicter or nil
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
    },

    State{
        name = "abandon",
        tags = { "busy" },

        onenter = function(inst, leader)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("abandon")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/angry_idle")
            if leader ~= nil and leader:IsValid() then
                inst:FacePoint(leader:GetPosition())
            end
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/attack")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/bite")
                inst.components.combat:DoAttack()
                inst.sg:RemoveStateTag("attack")
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "attack_object_pre_idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop_overhead", true)
        end,
    },

    State{
        name = "attack_object",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/attack")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk_object")
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/bite")
                inst.components.combat:DoAttack()
                inst:ClearBufferedAction()
                inst.sg:RemoveStateTag("attack")
                inst.sg:RemoveStateTag("busy")

                inst.sg.mem.is_holding_overhead = nil
            end),
        },

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "eat",
        tags = { "busy" },

        onenter = function(inst, data)
            local ba = inst:GetBufferedAction()
            if ba.target and ba.target.prefab == "hareball" and ba.target:IsValid() then
                inst.sg.statemem.barf = ba.target
            end

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/eat")
        end,

        timeline =
        {
                
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.barf then
                    if inst.sg.statemem.barf:IsValid() then
                        inst.components.inventory:GiveItem(inst.sg.statemem.barf)
                    end
                else
                    if inst.components.entitytracker:GetEntity("carrot") and inst:GetBufferedAction().target == inst.components.entitytracker:GetEntity("carrot") then
                        inst.sg.statemem.nocheer = true
                    end
                    inst:PerformBufferedAction()

                end
            end),

            TimeEvent(20 * FRAMES, function(inst)
                if inst.sg.statemem.barf then
                    if inst.sg.statemem.barf:IsValid() then
                        inst.sg.statemem.barf:PushEvent("oneaten",{eater=inst})
                        inst.sg.statemem.barf:Remove()
                    end
                    inst.sg:GoToState("disgust")
                end
            end),
        },

        events =
        {
            EventHandler("animover",  function(inst)
                if inst.sg.statemem.nocheer then
                    inst.sg:GoToState("idle")
                else
                    inst.sg:GoToState("dance",{text=STRINGS.COZY_RABBIT_YUM})                    
                end
            end),
        },
    },

    State{
        name = "disgust",
        tags = { "busy", "canrotate" },

        onenter = function(inst, data)
            inst.sg.statemem.loop = data and data.loopcount or nil
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("disgust")
            inst.SoundEmitter:PlaySound("yotr_2023/common/bunnyman_disgust")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if not inst.sg.statemem.loop then
                    inst.Transform:SetRotation(inst.Transform:GetRotation() +180)
                    inst.sg:GoToState("disgust",{loopcount = 1})
                elseif inst.sg.statemem.loop > 0 then
                    inst.Transform:SetRotation(inst.Transform:GetRotation() +180)
                    inst.sg:GoToState("disgust",{loopcount = inst.sg.statemem.loop-1})                
                else                                    
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/hurt")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },

    State{
        name = "spawn_pre",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            inst.Physics:SetActive(false)
            inst.AnimState:PlayAnimation("spawn_pre")
            inst.Physics:Stop()
            inst.SoundEmitter:PlaySound("yotr_2023/common/burrow_pre_rumble", "rumble_lp")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                SpawnPrefab("shovel_dirt").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
            TimeEvent(16 * FRAMES, function(inst)
                SpawnPrefab("shovel_dirt").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("spawn_loop")
            end),
        },
    }, 

    State{
        name = "spawn_loop",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            --start loop sound
            inst.AnimState:PlayAnimation("spawn_loop",true)
            inst.Physics:Stop()
            inst.sg:SetTimeout(math.random()*4 + 2)
        end,

        onupdate = function(inst)
            if math.random()< 0.05 then
                SpawnPrefab("shovel_dirt").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
        end,

        onexit = function(inst)
         -- end loop sound
        end,

        ontimeout = function(inst)
           inst.sg:GoToState("spawn_pst")
        end,
    }, 

    State{
        name = "spawn_pst",
        tags = { "busy" },

        onenter = function(inst)
            inst.DynamicShadow:Enable(true)
            inst.Physics:SetActive(true)
            inst.AnimState:PlayAnimation("spawn_pst")
            inst.Physics:Stop()
            inst.SoundEmitter:KillSound("rumble_lp")
            inst.SoundEmitter:PlaySound("yotr_2023/common/burrow_arrival")
        end,

        events =
        {
            EventHandler("animover", go_to_idle),
        },
    }, 


    State{
        name = "despawn",
        tags = { "busy" },

        onenter = function(inst)
            --inst.SoundEmitter:PlaySound("yotr_2023/common/burrow_down")
            inst.AnimState:PlayAnimation("despawn")
            inst.Physics:Stop()
        end,

        timeline =
        {
            TimeEvent(34 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst:Remove()
            end),
        },
    }, 

    State{
        name = "hide",
        tags = { "busy","hide" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("yotr_2023/common/burrow_down")
            inst.AnimState:PlayAnimation("despawn")
            inst.Physics:Stop()
            inst.Physics:SetActive(false)
            inst.shouldhide = false

            inst.sg:SetTimeout(math.random()*4 + 2)

            if inst.components.timer:TimerExists("shouldhide") then
                inst.components.timer:StopTimer("shouldhide")
            end
        end,

        ontimeout = function(inst)
            inst.sg.statemem.endhide=true
        end,

        onupdate = function(inst)
            local x,y,z = inst.Transform:GetWorldPosition()

            local shouldemerge = true
            local x, y, z = inst.Transform:GetWorldPosition()

            if shouldemerge == true then
                local ents = TheSim:FindEntities(x, y, z, 20, nil, nil, AREACLEAR_CHECK_FOR_HOSTILES) -- musttags, canttags, mustoneoftags
                if #ents > 0 then
                    shouldemerge = false
                end
            end

            if shouldemerge == true then
                local ents = TheSim:FindEntities(x, y, z, 20, nil, nil, AREACLEAR_COMBAT) -- musttags, canttags, mustoneoftags
                for _, ent in ipairs(ents) do
                    if ent.components.combat:HasTarget() and not ent:HasTag("cozy_bunnyman") then
                        shouldemerge = false
                    end
                end
            end

            if shouldemerge and inst.sg.statemem.endhide then
                if not inst.emergetask then
                    inst.emergetask = inst:DoTaskInTime(3 + (math.random()*2), function()
                        inst.sg:GoToState("spawn_pre")
                    end)
                end
            else 
                if inst.emergetask then
                    inst.emergetask:Cancel()
                    inst.emergetask = nil
                end
            end
        end,

        timeline =
        {
            TimeEvent(34 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetPercent(1)
                inst.DynamicShadow:Enable(false)
                inst.Physics:SetActive(false)
            end),
        },

        onexit = function(inst)
            inst:Show()
            inst.DynamicShadow:Enable(true)
            inst.Physics:SetActive(true)
            inst.shouldquestion = true
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:Hide()
            end),
        },
    }, 

    State{
        name = "alert",
        tags = {"idle", "canrotate", "alert"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("alert_pre")
            inst.AnimState:PushAnimation("alert_loop",true)
        end,
    },

    State{
        name = "digtolocation",
        tags = { "busy", "hide"},

        onenter = function(inst, data)
            inst.sg.statemem.pos = data.pos
            inst.sg.statemem.arena = data.arena
            inst.SoundEmitter:PlaySound("yotr_2023/common/burrow_down")
            inst.SoundEmitter:PlaySound("yotr_2023/common/burrow_pre_rumble", "rumble_lp")
            inst.AnimState:PlayAnimation("despawn", false)
            inst.AnimState:PushAnimation("spawn_pre", false)
            inst.AnimState:PushAnimation("spawn_loop", false)
            inst.AnimState:PushAnimation("spawn_pst", false)
            inst.Physics:Stop()
        end,

        timeline =
        {
            TimeEvent(34 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
            end),
            TimeEvent(40 * FRAMES, function(inst)
                local pos_teleported
                if inst.sg.statemem.pos then
                    inst.Physics:Teleport(inst.sg.statemem.pos:Get())
                    pos_teleported = true
                end

                if inst.sg.statemem.arena and inst.sg.statemem.arena:IsValid() then
                    inst.sg.statemem.arena:PushEvent("pillowfight_fighterarrived", {
                        fighter = inst,
                        already_teleported = pos_teleported,
                    })
                end

                inst.sg.statemem.did_teleport = true
            end),

            TimeEvent(83 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("noattack")
            end),
            TimeEvent(95 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("rumble_lp")
                inst.SoundEmitter:PlaySound("yotr_2023/common/burrow_arrival")
            end),
        },

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
            inst.Physics:SetActive(true)
            inst.SoundEmitter:KillSound("rumble_lp")
            if inst.sg.statemem.did_teleport then
                inst._return_to_pillow_spot = nil
            end
        end,

        events =
        {
            EventHandler("animqueueover", go_to_idle),
        },
    },

    State{
        name = "knockback",
        tags = { "busy", "jumping" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("hit_big")

            if data ~= nil and data.radius ~= nil and data.knocker ~= nil and data.knocker:IsValid() then
                local x, y, z = data.knocker.Transform:GetWorldPosition()
                local distsq = inst:GetDistanceSqToPoint(x, y, z)

                local rangesq = data.radius * data.radius
                local k = (distsq < rangesq and 0.3 * distsq / rangesq - 1) or -.7
                inst.sg.statemem.speed = (data.strengthmult or 1) * 7.5 * k
                inst.sg.statemem.dspeed = 0

                local rot = inst.Transform:GetRotation()
                local rot1 = (distsq > 0 and inst:GetAngleToPoint(x, y, z))
                            or data.knocker.Transform:GetRotation() + 180

                local drot = math.abs(rot - rot1)
                while drot > 180 do
                    drot = math.abs(drot - 360)
                end
                if drot > 90 then
                    inst.sg.statemem.reverse_mod = -1
                    inst.Transform:SetRotation(rot1 + 180)
                else
                    inst.sg.statemem.reverse_mod = 1
                    inst.Transform:SetRotation(rot1)
                end
                inst.Physics:SetMotorVel(inst.sg.statemem.reverse_mod * inst.sg.statemem.speed, 0, 0)
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + .1
                    inst.Physics:SetMotorVel(inst.sg.statemem.reverse_mod * inst.sg.statemem.speed, 0, 0)
                else
                    inst.sg.statemem.speed = nil
                    inst.sg.statemem.dspeed = nil
                    inst.Physics:Stop()
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState((not inst.sg.mem.is_holding_overhead and "idle")
                    or "attack_object_pre_idle")
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.speed then
                inst.Physics:Stop()
            end
        end,
    },

    State{
        name = "pickup",
        tags = { "busy" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end

            local bufferedaction = inst:GetBufferedAction()

            if bufferedaction then
                if bufferedaction.action.id == "DROP" and bufferedaction.invobject and bufferedaction.invobject.prefab == "hareball" then
                    inst.AnimState:PlayAnimation("disgust")
                    inst.sg.statemem.disgust = true
                    inst.SoundEmitter:PlaySound("yotr_2023/common/bunnyman_disgust")
                elseif bufferedaction.action.id == "PICKUP" and bufferedaction.target and bufferedaction.target:HasTag("bodypillow") then
                    inst.sg.statemem.pickup_bodypillow = bufferedaction.target
                end
            end

            if not inst.sg.statemem.disgust then
                inst.AnimState:PlayAnimation("pig_pickup")
            end
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.disgust then
                    local body_pillow = inst.sg.statemem.pickup_bodypillow
                    if body_pillow and body_pillow:IsValid() and not body_pillow.components.inventoryitem then
                        body_pillow:AddComponent("inventoryitem")
                    end
                    inst:PerformBufferedAction()
                end
            end),
            TimeEvent(18 * FRAMES, function(inst)
                if inst.sg.statemem.disgust then
                    inst:PerformBufferedAction()
                end
            end),
        },

        events =
        {
            EventHandler("animover",  function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "gottoken",
        tags = { "busy" },

        onenter = function(inst, data)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/hurt")
            inst.AnimState:PlayAnimation("hit")
            inst.AnimState:PushAnimation("idle_happy", false)
            inst.Physics:Stop()

            if data and data.text then
                inst.components.talker:Say((type(data.text) ~= "table" and data.text)
                    or data.text[math.random(1, #data.text)])
            end
        end,

        events =
        {
            EventHandler("animqueueover", go_to_idle),
        },
    },

}

CommonStates.AddWalkStates(states, {
    walktimeline =
    {
        TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/hop") end),
        TimeEvent(4 * FRAMES, function(inst)
            inst.components.locomotor:WalkForward()
        end),
        TimeEvent(12 * FRAMES, function(inst)
            PlayFootstep(inst)
            inst.Physics:Stop()
        end),
    },
},
{
    startwalk = function(inst)
        return (inst.sg.mem.is_holding_overhead and "walk_overhead_pre") or "walk_pre"
    end,
    walk = function(inst)
        return (inst.sg.mem.is_holding_overhead and "walk_overhead_loop") or "walk_loop"
    end,
    stopwalk = function(inst)
        return (inst.sg.mem.is_holding_overhead and "walk_overhead_pst") or "walk_pst"
    end,
}, true)

CommonStates.AddRunStates(states, {
    runtimeline =
    {
        TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/hop") end),
        TimeEvent(4 * FRAMES, function(inst)
            inst.components.locomotor:RunForward()
        end),
        TimeEvent(8 * FRAMES, function(inst)
            PlayFootstep(inst)
            inst.Physics:Stop()
        end),
    },
}, 
{
    startrun = function(inst)
        return (inst.sg.mem.is_holding_overhead and "walk_overhead_pre") or "run_pre"
    end,
    run = function(inst)
        return (inst.sg.mem.is_holding_overhead and "walk_overhead_loop") or "run_loop"
    end,
    stoprun = function(inst)
        return (inst.sg.mem.is_holding_overhead and "walk_overhead_pst") or "run_pst"
    end,
}, true)

CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        TimeEvent(35 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/sleep") end),
    },
})

CommonStates.AddSimpleState(states, "refuse", "pig_reject", { "busy" })
CommonStates.AddFrozenStates(states)
--CommonStates.AddSimpleActionState(states, "pickup", "pig_pickup", 10 * FRAMES, { "busy" })
CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4 * FRAMES, { "busy" })
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst"})
CommonStates.AddSinkAndWashAshoreStates(states)
CommonStates.AddSimpleState(states, "attack_object_pre", "atk_object_pre", { "busy" }, "attack_object_pre_idle", nil,
{
    onenter = function(inst, data)
        inst.sg.mem.is_holding_overhead = true
    end,
})

return StateGraph("cozy_bunnyman", states, events, "idle", actionhandlers)
