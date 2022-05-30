require("stategraphs/commonstates")

local actionhandlers =
{
}


local events=
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

    EventHandler("rollattack", function(inst)
                                if inst:IsValid() and ( not inst.components.health or not inst.components.health:IsDead()) and (inst.sg:HasStateTag("canroll") or inst.sg:HasStateTag("moving") ) then
                                    inst.sg:GoToState("roll_start")
                                end
                            end),

}

local TARGET_CANT_TAGS = { "INLIMBO","ancient_clockwork" }
local TARGET_ONEOF_TAGS = { "character", "monster" }

local function doAOEattack(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local targets = TheSim:FindEntities(x,y,z, TUNING.ARCHIVE_CENTIPEDE.AOE_RANGE, nil, TARGET_CANT_TAGS,TARGET_ONEOF_TAGS)
    for i=#targets,1,-1 do
        local target = targets[i]
        if not target.components.health and not target.components.combat then
            table.remove(targets,i)
        end
    end
    inst.components.combat:SetDefaultDamage(TUNING.ARCHIVE_CENTIPEDE.AOE_DAMAGE)
    for i,target in ipairs(targets)do
        inst.components.combat:DoAttack(target)
    end
    inst.components.combat:SetDefaultDamage(TUNING.ARCHIVE_CENTIPEDE.DAMAGE)
end

local function attackexit(inst)
    inst.doAOE = true
end

local states=
{
     State{

        name = "idle",
        tags = {"idle", "canrotate","canroll"},
        onenter = function(inst, playanim)

            if inst.light_params and  inst._endlight ~= inst.light_params.on then
                inst._endlight = inst.light_params.on
                inst.copyparams(inst._startlight, inst._endlight)
                inst.copyparams(inst._currentlight, inst._endlight)
                inst.pushparams(inst, inst._currentlight)
            end

            local targets = {}
            if inst.doAOE then
                local x,y,z = inst.Transform:GetWorldPosition()
                targets = TheSim:FindEntities(x,y,z, TUNING.ARCHIVE_CENTIPEDE.AOE_RANGE, nil, TARGET_CANT_TAGS,TARGET_ONEOF_TAGS)
            end
            if #targets > 0 then
                inst.sg:GoToState("atk_aoe")
            else
                inst.Physics:Stop()
                if playanim then
                    inst.AnimState:PlayAnimation(playanim)
                    inst.AnimState:PushAnimation("idle", true)
                else
                    inst.AnimState:PlayAnimation("idle", true)
                end
            end
            inst.doAOE = nil
        end,

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
            inst.SoundEmitter:PlaySound("grotto/creatures/centipede/taunt")
        end,


        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "spawn",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("spawn")
            inst.SoundEmitter:PlaySound("grotto/creatures/centipede/spawn")
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                inst.copyparams( inst._startlight, inst.light_params.off)
                inst.copyparams( inst._endlight, inst.light_params.on)
                inst.beginfade(inst)
            end ),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{  name = "roll_start",
            tags = {"moving", "running", "busy", "atk_pre", "canrotate", "charge"},

            onenter = function(inst)
                if inst.components.combat and inst.components.combat.target then
                    local x,y,z = inst.components.combat.target.Transform:GetWorldPosition()
                    local angle = inst:GetAngleToPoint(x,y,z)
                    inst.Transform:SetRotation(angle)
                end
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("atk_roll_pre")
            end,

            timeline=
            {
                TimeEvent(1*FRAMES,  function(inst)

                end ),
            },

            events=
            {
                EventHandler("animover", function(inst)
                    inst:PushEvent("attackstart" )
                    inst.sg:GoToState("roll")
                end),
            },
        },

    State{  name = "roll",
            tags = {"moving", "running", "charge"},

            onenter = function(inst)
                inst.components.locomotor:Stop()
                inst.components.locomotor:EnableGroundSpeedMultiplier(false)
                inst.Physics:SetMotorVelOverride(15,0,0)
--                inst.components.locomotor:RunForward()
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/rolling_atk_LP","roll")

                if not inst.AnimState:IsCurrentAnimation("atk_roll") then
                    inst.AnimState:PlayAnimation("atk_roll_loop", true)
                end
                inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength()*2)
                --inst.sg:SetTimeout(1)
            end,

            timeline=
            {

            },

            onexit = function(inst)
                inst.components.locomotor:Stop()
                inst.components.locomotor:EnableGroundSpeedMultiplier(true)
                inst.Physics:ClearMotorVelOverride()
                inst.SoundEmitter:KillSound("roll")
            end,

            ontimeout = function(inst)
                inst.sg:GoToState("roll_stop")
            end,
        },

    State{  name = "roll_stop",
            tags = {"canrotate", "idle", "charge"},

            onenter = function(inst)

                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("atk_roll_pst")
            end,

            timeline=
            {
                 TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("grotto/creatures/centipede/taunt") end),
            },

            events=
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
            },
        },
    State{  name = "atk_aoe",
            tags = {"canrotate", "busy", "atk_pre"},

            onenter = function(inst)
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("atk_aoe")
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/aoe")

            end,

            timeline=
            {
                TimeEvent(25*FRAMES,  function(inst)
                    doAOEattack(inst)
                end ),
            },

            events=
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
            },
        },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
	    TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end ),
        TimeEvent(1*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/walk")
            end ),
    },
	walktimeline = {
		    TimeEvent(0*FRAMES, function(inst) inst.components.locomotor:WalkForward() end ),
            TimeEvent(0*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/walk")
            end ),
            TimeEvent(4*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/walk")
            end ),
            TimeEvent(8*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/walk")
            end ),
            TimeEvent(12*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/walk")
            end ),
            TimeEvent(16*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/walk")
            end ),
    },
    endtimeline = {
            TimeEvent(4*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/walk")
            end ),
            TimeEvent(7*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("grotto/creatures/centipede/walk")
            end ),
	},
}, nil,true)

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("grotto/creatures/centipede/sleep") end ),
        TimeEvent(0*FRAMES, function (inst) inst.SoundEmitter:SetParameter("alive", "active", .9) end),
    },

	sleeptimeline =
    {

	},

    waketimeline =
    {
        TimeEvent(0*FRAMES, function (inst) inst.SoundEmitter:SetParameter("alive", "active", 0) end),
        TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("grotto/creatures/centipede/sleep")
        end),
    },
})

CommonStates.AddCombatStates(states,
{
    attacktimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("grotto/creatures/centipede/attack") end),
        TimeEvent(9*FRAMES, function(inst) inst.components.combat:DoAttack() end),
    },
    hittimeline =
    {
       TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("grotto/creatures/centipede/hit_react") end),
    },
    deathtimeline =
    {
        TimeEvent(0*FRAMES, function(inst)
            inst.copyparams( inst._endlight, inst.light_params.off)
            inst.beginfade(inst)
        end),

        TimeEvent(0*FRAMES, function (inst) inst.SoundEmitter:PlaySound("grotto/creatures/centipede/death")
        end),

        TimeEvent(17*FRAMES, function(inst)
            inst.SoundEmitter:KillSound("alive")
        end),
    },

},nil,{attackexit= attackexit})

CommonStates.AddFrozenStates(states)


return StateGraph("centipede", states, events, "idle", actionhandlers)

