require("stategraphs/commonstates")

local function startaura(inst)
    inst.Light:SetColour(255/255, 32/255, 32/255)
    inst.SoundEmitter:PlaySound(inst:HasTag("girl") and "dontstarve/ghost/ghost_girl_attack_LP" or "dontstarve/ghost/ghost_attack_LP", "angry")
    inst.AnimState:SetMultColour(207/255, 92/255, 92/255, 1)
end

local function stopaura(inst)
    inst.Light:SetColour(180/255, 195/255, 225/255)
    inst.SoundEmitter:KillSound("angry")
    inst.AnimState:SetMultColour(1, 1, 1, 1)
end

local events =
{
    CommonHandlers.OnLocomote(true, true),
    EventHandler("startaura", startaura),
    EventHandler("stopaura", stopaura),
    EventHandler("attacked", function(inst)
        if not (inst.sg:HasStateTag("jumping") or inst.components.health:IsDead()) and not CommonHandlers.HitRecoveryDelay(inst) then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("knockback", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("knockback", data)
        end
    end),
    EventHandler("updatepetmastery", function(inst, data)
        if inst._pet_level ~= nil and data ~= nil and inst._pet_level == data.newlevel then
            --cancel change
            inst.sg.mem.queuelevelchange = nil
        else
            inst.sg.mem.queuelevelchange = true
            if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) and inst.sg.currentstate.name ~= "appear" then
                inst.sg:GoToState("levelup")
            end
        end
    end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("dissipate")
    end),
}

local function getidleanim(inst)
    return ((inst.components.combat:HasTarget() or inst.components.aura.applying) and "angry")
        or (inst.components.health:GetPercent() < .25 and "shy")
        or "idle"
end

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate", "canslide" },

        onenter = function(inst)
            if inst.sg.mem.queuelevelchange then
                inst.sg:GoToState("levelup")
            else
                inst.AnimState:PlayAnimation(getidleanim(inst), true)
            end
        end,
    },

    State{
        name = "appear",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("appear")
            inst.SoundEmitter:PlaySound(inst:HasTag("girl") and "dontstarve/ghost/ghost_girl_howl" or "dontstarve/ghost/ghost_howl")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.aura:Enable(true)
        end,
    },

    State{
        name = "hit",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst:HasTag("girl") and "dontstarve/ghost/ghost_girl_howl" or "dontstarve/ghost/ghost_howl")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
			CommonHandlers.UpdateHitRecoveryDelay(inst)
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
        name = "haunted",
        tags = { "busy" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst:HasTag("girl") and "dontstarve/ghost/ghost_girl_attack_LP" or "dontstarve/ghost/ghost_attack_LP", "haunted")
            inst.AnimState:PlayAnimation("angry")
            inst.Physics:Stop()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("haunted")
        end
    },

    State{
        name = "dissipate",
        tags = { "busy", "noattack", "nointerrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound(inst:HasTag("girl") and "dontstarve/ghost/ghost_girl_howl" or "dontstarve/ghost/ghost_howl")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.components.lootdropper ~= nil then
                        inst.components.lootdropper:DropLoot()
                    end
                    inst:PushEvent("detachchild")
                    inst:Remove()
                end
            end)
        },
    },

    State{
        name = "knockback",
        tags = { "busy", "jumping" },

        onenter = function(inst, data)
            inst.SoundEmitter:PlaySound(inst:HasTag("girl") and "dontstarve/ghost/ghost_girl_howl" or "dontstarve/ghost/ghost_howl")
            inst.AnimState:PlayAnimation("brace")
            inst.components.locomotor:Stop()

            if data ~= nil and data.radius ~= nil and data.knocker ~= nil and data.knocker:IsValid() then
                local x, y, z = data.knocker.Transform:GetWorldPosition()
                local distsq = inst:GetDistanceSqToPoint(x, y, z)
                local rangesq = data.radius * data.radius
                local rot = inst.Transform:GetRotation()
                local rot1 = distsq > 0 and inst:GetAngleToPoint(x, y, z) or data.knocker.Transform:GetRotation() + 180
                local drot = math.abs(rot - rot1)
                while drot > 180 do
                    drot = math.abs(drot - 360)
                end
                local k = distsq < rangesq and .3 * distsq / rangesq - 1 or -.7
                inst.sg.statemem.speed = (data.strengthmult or 1) * 20 * k
                inst.sg.statemem.dspeed = 0
                if drot > 90 then
                    inst.sg.statemem.reverse = true
                    inst.Transform:SetRotation(rot1 + 180)
                    inst.Physics:SetMotorVel(-(inst.sg.statemem.speed + 15), 0, 0)
                else
                    inst.Transform:SetRotation(rot1)
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed + 15, 0, 0)
                end
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + 1
                    inst.Physics:SetMotorVel(inst.sg.statemem.reverse and -inst.sg.statemem.speed or inst.sg.statemem.speed, 0, 0)
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
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("hit")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
        end,
    },

    State{
        name = "levelup",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dissipate")
            inst.SoundEmitter:PlaySound(inst:HasTag("girl") and "dontstarve/ghost/ghost_girl_howl" or "dontstarve/ghost/ghost_howl")

            inst.components.health:SetInvincible(true)
            inst.components.aura:Enable(true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.mem.queuelevelchange then
                        inst.sg.mem.queuelevelchange = nil
                        inst:PushEvent("petbuff_dolevelchange")
                    end
                    inst.sg:GoToState("appear")
                end
            end),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            if not inst.components.health:IsDead() then
                inst.components.aura:Enable(true)
            end
        end,
    },
}

CommonStates.AddSimpleWalkStates(states, getidleanim)
CommonStates.AddSimpleRunStates(states, getidleanim)

return StateGraph("ghost", states, events, "appear")
