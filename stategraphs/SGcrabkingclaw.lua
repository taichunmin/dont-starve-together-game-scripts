require("stategraphs/commonstates")



local function removeboat(inst)
    inst.boat = nil
    inst:PushEvent("releaseclamp")
end

local function removeshadow(inst)
    if inst.shadow then
        inst.shadow:Remove()
        inst.shadow = nil
    end
end

local function addshadow(inst)
    if not inst.shadow then
        inst.shadow = SpawnPrefab("crabking_claw_shadow")
        local pos = Vector3(inst.Transform:GetWorldPosition())
        inst.shadow.Transform:SetPosition(pos.x,pos.y,pos.z)
        inst.shadow.Transform:SetRotation(inst.Transform:GetRotation())
    end
end

local function play_shadow_animation(inst, anim, loop)
    --addshadow(inst)
    inst.AnimState:PlayAnimation(anim,loop)
    if inst.shadow then
        inst.shadow.AnimState:PlayAnimation(anim,loop)
    end
end
local function push_shadow_animation(inst, anim, loop)
    --addshadow(inst)
    inst.AnimState:PushAnimation(anim,loop)
    if inst.shadow then
        inst.shadow.AnimState:PushAnimation(anim,loop)
    end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.HAMMER, "attack"),
}

local events =
{
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),

    EventHandler("attacked", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
            and (not inst.sg:HasStateTag("busy") or
                inst.sg:HasStateTag("caninterrupt") or
                inst.sg:HasStateTag("frozen")) then

            if inst.sg:HasStateTag("clampped") then
                inst.sg.statemem.keepclamp = true
                inst.sg:GoToState("clamp_hit")
            else
                inst.sg:GoToState("hit")
            end
        end
    end),
    EventHandler("doattack", function(inst, data)
    end),
    EventHandler("emerge", function(inst, data)
        inst.sg:GoToState("emerge")
    end),
    EventHandler("clamp", function(inst, data)
        inst.sg:GoToState("clamp_pre",data.target)
    end),
    EventHandler("releaseclamp", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead() and inst.sg:HasStateTag("clampped") then
            inst.sg:GoToState((data ~= nil and data.immediate) and "idle" or "clamp_pst")
        end
    end),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            --pushanim could be bool or string?
            if pushanim then
                if type(pushanim) == "string" then
                    play_shadow_animation(inst, pushanim)
                    --inst.AnimState:PlayAnimation(pushanim)
                end
                push_shadow_animation(inst, "idle")
                --inst.AnimState:PushAnimation("idle")
            else
                play_shadow_animation(inst, "idle")
                --inst.AnimState:PlayAnimation("idle")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    State{
        name = "emerge",
        tags = { "busy", "canrotate" },

        onenter = function(inst, pushanim)
            play_shadow_animation(inst, "emerge")
            --inst.AnimState:PlayAnimation("emerge")
            inst.SoundEmitter:PlaySound("turnoftides/common/together/water/emerge/medium")

        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    --[[ CLAMP STATES ]]
    State{
        name = "clamp_pre",
        tags = { "busy", "canrotate","clampped"},

        onenter = function(inst,target)

            inst.Transform:SetEightFaced()
            if target:IsValid() then
                inst.boat = target
                inst:ListenForEvent("onremove", function() removeboat( inst ) end, inst.boat)
            end
            play_shadow_animation(inst, "clamp_pre")
        end,

        onupdate = function(inst)
            if inst.boat and inst.boat:IsValid() then
                inst:ForceFacePoint(inst.boat:GetPosition())
            end
        end,

        timeline=
        {
            TimeEvent(14*FRAMES, function(inst)
                inst.components.locomotor:StopMoving()
                inst.clamp(inst)
                inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage", {intensity= .5})
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.keepclamp then
                inst.releaseclamp(inst)
            end
            inst.Transform:SetSixFaced()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.keepclamp = true
                inst.sg:GoToState("clamp")
            end),
        },
    },
    State{
        name = "clamp",
        tags = {"canrotate","clampped"},

        onenter = function(inst)
            inst.Transform:SetEightFaced()

            play_shadow_animation(inst, "clamp")
        end,

        onexit = function(inst)
            inst.Transform:SetSixFaced()

            if not inst.sg.statemem.keepclamp then
                inst.releaseclamp(inst)
            end
        end,

        events =
        {
            EventHandler("clamp_attack", function(inst, boat)
                inst.sg.statemem.keepclamp = true
                inst.sg:GoToState("clamp_attack",boat)
            end),
            EventHandler("animover", function(inst)
                inst.sg.statemem.keepclamp = true
                inst.sg:GoToState("clamp")
            end),
        },
    },
    State{
        name = "clamp_hit",
        tags = {"busy","canrotate","clampped"},

        onenter = function(inst)
            inst.Transform:SetEightFaced()

            play_shadow_animation(inst, "clamp_hit")
        end,

        onexit = function(inst)
            inst.Transform:SetSixFaced()

            if not inst.sg.statemem.keepclamp then
                inst.releaseclamp(inst)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.keepclamp = true
                inst.sg:GoToState("clamp")
            end),
        },
    },
    State{
        name = "clamp_attack",
        tags = {"busy","canrotate","clampped"},

        onenter = function(inst,boat)
            inst.sg.statemem.boat = boat
            inst.Transform:SetEightFaced()

            play_shadow_animation(inst, "clamping")
        end,

        timeline=
        {
            TimeEvent(11*FRAMES, function(inst)
                local boat = inst.sg.statemem.boat
                if boat and boat:IsValid() then
                    inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage", {intensity= .3})
                    boat.components.health:DoDelta(-TUNING.CRABKING_CLAW_BOATDAMAGE/4)
                    ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.3, 0.03, 0.25, boat, boat:GetPhysicsRadius(4))
                end
            end),
            TimeEvent(22*FRAMES, function(inst)
                local boat = inst.sg.statemem.boat
                if boat and boat:IsValid() then
                    inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage", {intensity= .3})
                    boat.components.health:DoDelta(-TUNING.CRABKING_CLAW_BOATDAMAGE/4)
                    ShakeAllCameras(CAMERASHAKE.VERTICAL, 0.3, 0.03, 0.25, boat, boat:GetPhysicsRadius(4))
                end
            end),
        },

        onexit = function(inst)
            inst.Transform:SetSixFaced()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("clamp")
            end),
        },
    },
    State{
        name = "clamp_pst",
        tags = { "busy", "canrotate"},

        onenter = function(inst)
            inst.Transform:SetEightFaced()

            play_shadow_animation(inst, "clamp_pst")
        end,

        onexit = function(inst)
            --removeshadow(inst)
            inst.Transform:SetSixFaced()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
}

CommonStates.AddWalkStates(states,
{},{
    startwalk = "walk_pre",
    walk = "walk_loop",
    stopwalk = "walk_pst",
})
CommonStates.AddRunStates(states,
{},{
    startwalk = "walk_pre",
    walk = "walk_loop",
    stopwalk = "walk_pst",
})
--CommonStates.AddSleepStates(states)
CommonStates.AddFrozenStates(states)


CommonStates.AddCombatStates(states,{
    deathtimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/creatures/boss/crabking/rock") end),
    },
})


return StateGraph("crabkingclaw", states, events, "idle", actionhandlers)
