require("stategraphs/commonstates")

local actionhandlers = 
{
	ActionHandler(ACTIONS.HAMMER, "attack"),
	ActionHandler(ACTIONS.GOHOME, "taunt"),
}

local SHAKE_DIST = 40

local function DeerclopsFootstep(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/step")
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .03, 2, inst, SHAKE_DIST)
end

local function SpawnIceFx(inst, target)
    if not inst or not target then return end
    local numFX = math.random(15,20)
    local pos = inst:GetPosition()
    local targetPos = target:GetPosition()
    local vec = targetPos - pos
    vec = vec:Normalize()
    local dist = pos:Dist(targetPos)
    local angle = inst:GetAngleToPoint(targetPos:Get())

    for i = 1, numFX do
        inst:DoTaskInTime(math.random() * 0.25, function(inst)
            local prefab = "icespike_fx_"..math.random(1,4)
            local fx = SpawnPrefab(prefab)
            if fx then
                local x = GetRandomWithVariance(0, 3)
                local z = GetRandomWithVariance(0, 3)
                local offset = (vec * math.random(dist * 0.25, dist)) + Vector3(x,0,z)
                fx.Transform:SetPosition((offset+pos):Get())
            end
        end)
    end
end

local events=
{
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local states=
{
    State{
        name = "gohome",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst:ClearBufferedAction()
            inst.components.knownlocations:RememberLocation("home", nil)
        end,
        
        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_grrr") end),
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_howl") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },      
    
	State{
        name = "taunt",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            
            if inst.bufferedaction and inst.bufferedaction.action == ACTIONS.GOHOME then
            	inst:PerformBufferedAction()
            end
        end,
        
        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_grrr") end),
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/taunt_howl") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

}

CommonStates.AddWalkStates( states,
{
	starttimeline =
	{
        TimeEvent(7*FRAMES, DeerclopsFootstep),
	},
    walktimeline = 
    { 
        TimeEvent(23*FRAMES, DeerclopsFootstep),
        TimeEvent(42*FRAMES, DeerclopsFootstep),
    },
    endtimeline=
    {
        TimeEvent(5*FRAMES, DeerclopsFootstep),
    },
})

CommonStates.AddCombatStates(states,
{
	hittimeline =
	{
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/hurt") end),
	},
    attacktimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/attack") end),
        TimeEvent(29*FRAMES, function(inst) SpawnIceFx(inst, inst.components.combat.target) end),
        TimeEvent(35*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/swipe")
            inst.components.combat:DoAttack(inst.sg.statemem.target)
            if inst.bufferedaction and inst.bufferedaction.action == ACTIONS.HAMMER then
                inst.bufferedaction.target.components.workable:SetWorkLeft(1)
                inst:PerformBufferedAction()
            end
            ShakeAllCameras(CAMERASHAKE.FULL, .5, .05, 2, inst, SHAKE_DIST)
        end),
        TimeEvent(36*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
    },
    deathtimeline=
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/death") end),
        TimeEvent(50*FRAMES, function(inst)
            if TheWorld.state.snowlevel > 0.02 then
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_snow")
            else
                inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_dirt")
            end
            ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 3, inst, SHAKE_DIST)
        end),
    },
})

CommonStates.AddIdle(states)
CommonStates.AddSleepStates(states,
{
    sleeptimeline = 
    {
        --TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.grunt) end)
    },
})
CommonStates.AddFrozenStates(states)

return StateGraph("deerclops", states, events, "idle", actionhandlers)

