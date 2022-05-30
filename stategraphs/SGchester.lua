require("stategraphs/commonstates")

local NUM_FX_VARIATIONS = 7
local MAX_RECENT_FX = 4
local MIN_FX_SCALE = .5
local MAX_FX_SCALE = 1.6

local function SpawnMoveFx(inst, scale)
    local fx = SpawnPrefab("hutch_move_fx")
    if fx ~= nil then
        if inst.sg.mem.recentfx == nil then
            inst.sg.mem.recentfx = {}
        end
        local recentcount = #inst.sg.mem.recentfx
        local rand = math.random(NUM_FX_VARIATIONS - recentcount)
        if recentcount > 0 then
            while table.contains(inst.sg.mem.recentfx, rand) do
                rand = rand + 1
            end
            if recentcount >= MAX_RECENT_FX then
                table.remove(inst.sg.mem.recentfx, 1)
            end
        end
        table.insert(inst.sg.mem.recentfx, rand)
        fx:SetVariation(rand, fx._min_scale + (fx._max_scale - fx._min_scale) * scale)
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

local actionhandlers =
{
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnHop(),
	CommonHandlers.OnSink(),
    EventHandler("attacked", function(inst)
        if inst.components.health and not inst.components.health:IsDead() then
            inst.sg:GoToState("hit")

            inst.SoundEmitter:PlaySound(inst.sounds.hurt)

        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("morph", function(inst, data)
        inst.sg:GoToState("morph", data.morphfn)
    end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")

            if not inst.sg.mem.pant_ducking or inst.sg:InNewState() then
				inst.sg.mem.pant_ducking = 1
			end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        timeline=
        {
            TimeEvent(7*FRAMES, function(inst)
				inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking or 1

				inst.SoundEmitter:PlaySound(inst.sounds.pant, nil, inst.sg.mem.pant_ducking)
				if inst.sg.mem.pant_ducking and inst.sg.mem.pant_ducking > .35 then
					inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking - .05
				end
			end),
        },
   },


    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.container:Close()
            inst.components.container:DropEverything()
            inst.components.container.canbeopened = false

            inst.SoundEmitter:PlaySound(inst.sounds.death)

            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
        end,
    },


    State{
        name = "open",
        tags = {"busy", "open"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.components.sleeper:WakeUp()
            inst.AnimState:PlayAnimation("open")
            if inst.SoundEmitter:PlayingSound("hutchMusic") then
                inst.SoundEmitter:SetParameter("hutchMusic", "intensity", 1)
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound( inst.sounds.open ) end),
        },
    },

    State{
        name = "open_idle",
        tags = {"busy", "open"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop_open")

            if not inst.sg.mem.pant_ducking or inst.sg:InNewState() then
				inst.sg.mem.pant_ducking = 1
			end

        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("open_idle") end ),
        },

        timeline=
        {


            TimeEvent(3*FRAMES, function(inst)
				inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking or 1
				inst.SoundEmitter:PlaySound( inst.sounds.pant , nil, inst.sg.mem.pant_ducking)
				if inst.sg.mem.pant_ducking and inst.sg.mem.pant_ducking > .35 then
					inst.sg.mem.pant_ducking = inst.sg.mem.pant_ducking - .05
				end
			end),
        },
    },

    State{
        name = "close",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("closed")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.muffled and inst.SoundEmitter:PlayingSound("hutchMusic") then
                inst.SoundEmitter:SetParameter("hutchMusic", "intensity", 0)
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound( inst.sounds.close ) end),
            TimeEvent(4*FRAMES, function(inst)
                if inst.SoundEmitter:PlayingSound("hutchMusic") then
                    inst.sg.statemem.muffled = true
                    inst.SoundEmitter:SetParameter("hutchMusic", "intensity", 0)
                end
            end)
        },
    },

    State{
        name = "transition",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()

            --Remove ability to open chester for short time.
            inst.components.container:Close()
            inst.components.container.canbeopened = false

            --Create light shaft
            inst.sg.statemem.light = SpawnPrefab("chesterlight")
            inst.sg.statemem.light.Transform:SetPosition(inst:GetPosition():Get())
            inst.sg.statemem.light:TurnOn()

            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/raise")

            inst.AnimState:PlayAnimation("idle_loop")
            inst.AnimState:PushAnimation("idle_loop")
            inst.AnimState:PushAnimation("idle_loop")
            inst.AnimState:PushAnimation("transition", false)
        end,

        onexit = function(inst)
            --Add ability to open chester again.
            inst.components.container.canbeopened = true
            --Remove light shaft
            if inst.sg.statemem.light then
                inst.sg.statemem.light:TurnOff()
            end
        end,

        timeline =
        {
            TimeEvent(56*FRAMES, function(inst)
                local x, y, z = inst.Transform:GetWorldPosition()
                SpawnPrefab("chester_transform_fx").Transform:SetPosition(x, y + 1, z)
            end),
            TimeEvent(60*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound( inst.sounds.pop )
                if inst.MorphChester ~= nil then
                    inst:MorphChester()
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "morph",
        tags = {"busy"},
        onenter = function(inst, morphfn)
            inst.Physics:Stop()

            inst.SoundEmitter:PlaySound("dontstarve/creatures/chester/raise")
            inst.AnimState:PlayAnimation("transition", false)

            --Remove ability to open chester for short time.
            inst.components.container.canbeopened = false
            inst.components.container:Close()

            inst.sg.statemem.morphfn = morphfn
        end,

        timeline =
        {

            TimeEvent(1*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/hutch/bounce")
            end),
            TimeEvent(22*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/hutch/clap")
            end),
            TimeEvent(27*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/hutch/clap")
            end),
            TimeEvent(32*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/hutch/clap")
            end),
            TimeEvent(36*FRAMES, function(inst)
                local x, y, z = inst.Transform:GetWorldPosition()
                SpawnPrefab("chester_transform_fx").Transform:SetPosition(x, y + 1, z)
            end),
            TimeEvent(37*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/hutch/clap")
            end),
            TimeEvent(40*FRAMES, function(inst)
                if inst.sg.statemem.morphfn ~= nil then
                    local morphfn = inst.sg.statemem.morphfn
                    inst.sg.statemem.morphfn = nil
                    morphfn(inst)
                end
                inst.SoundEmitter:PlaySound( inst.sounds.pop )
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },

        onexit = function(inst)
            if inst.sg.statemem.morphfn ~= nil then
                --In case state was interrupted
                local morphfn = inst.sg.statemem.morphfn
                inst.sg.statemem.morphfn = nil
                morphfn(inst)
            end
            --Add ability to open chester again.
            inst.components.container.canbeopened = true
        end,

    },
}

CommonStates.AddWalkStates(states, {
    walktimeline =
    {
        --TimeEvent(0*FRAMES, function(inst)  end),

        TimeEvent(1*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound( inst.sounds.boing )

            inst.components.locomotor:RunForward()

            --Cave chester leaves slime as he bounces
            if inst.leave_slime then
                inst.sg.statemem.slimein = true
                if inst.sg.mem.lastspawnlandingmovefx ~= nil and inst.sg.mem.lastspawnlandingmovefx + 2 > GetTime() then
                    inst.sg.statemem.slimeout = true
                    SpawnMoveFx(inst, .45 + math.random() * .1)
                end
            end
        end),

        TimeEvent(2 * FRAMES, function(inst)
            if inst.sg.statemem.slimeout then
                SpawnMoveFx(inst, .2 + math.random() * .1)
            end
        end),

        TimeEvent(4 * FRAMES, function(inst)
            if inst.sg.statemem.slimeout and math.random() < .7 then
                SpawnMoveFx(inst, .1 + math.random() * .1)
            end
        end),

        TimeEvent(7 * FRAMES, function(inst)
            if inst.sg.statemem.slimeout and math.random() < .3 then
                SpawnMoveFx(inst, 0)
            end
        end),

        TimeEvent(10 * FRAMES, function(inst)
            if inst.sg.statemem.slimein and math.random() < .6 then
                SpawnMoveFx(inst, .05 + math.random() * .1)
            end
        end),

        TimeEvent(12 * FRAMES, function(inst)
            if inst.sg.statemem.slimein then
                SpawnMoveFx(inst, .25 + math.random() * .1)
            end
        end),

        TimeEvent(13*FRAMES, function(inst)
            if inst.sounds.land_hit ~= nil then
                inst.SoundEmitter:PlaySound(inst.sounds.land_hit)
            end
            if inst.sg.statemem.slimein then
                if inst.sounds.land ~= nil then
                    inst.SoundEmitter:PlaySound(inst.sounds.land)
                end
                SpawnMoveFx(inst, .8 + math.random() * .2)
                inst.sg.mem.lastspawnlandingmovefx = GetTime()
            end
        end),

        TimeEvent(14*FRAMES, function(inst)
            PlayFootstep(inst)
            inst.components.locomotor:WalkForward()
        end),
    },

    endtimeline =
    {
        TimeEvent(1*FRAMES, function(inst)
--[[
            if inst.sounds.land_hit then
                inst.SoundEmitter:PlaySound( inst.sounds.land_hit )
            end
            ]]
            if inst.sg.statemem.slimein then
                if inst.sounds.land ~= nil then
                    inst.SoundEmitter:PlaySound(inst.sounds.land)
                end
                SpawnMoveFx(inst, .4 + math.random() * .2)
                inst.sg.mem.lastspawnlandingmovefx = GetTime()
            end
        end),
    },

}, nil, true)

CommonStates.AddHopStates(states, true, nil,
{

    hop_pre =
    {
        TimeEvent(0, function(inst)
            -- TODO(DANY):  This is when Chester starts jumping on the boat. There are a few other creatures that can jump on the boat
            --              but I thought it would make sense to just get chester working properly and then we can look at hooking up
            --              the other ones after.
            -- TODO(DANY):  This is when Chester lands on the boat.
            inst.SoundEmitter:PlaySound("dontstarve/common/dropGeneric")
        end),
    }
})

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound( inst.sounds.close ) end)
    },

    sleeptimeline =
    {
        TimeEvent(1*FRAMES, function(inst)
            if inst.sounds.sleep then
                inst.SoundEmitter:PlaySound( inst.sounds.sleep )
            end
        end)
    },
    waketimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound( inst.sounds.open ) end)
    },
})

CommonStates.AddSimpleState(states, "hit", "hit", {"busy"})
CommonStates.AddSinkAndWashAsoreStates(states)

return StateGraph("chester", states, events, "idle", actionhandlers)

