require("stategraphs/commonstates")

local actionhandlers =
{
}

local events=
{
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("nointerrupt") and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack") end end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnSink(),
}

local states=
{

    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle", true)
			if math.random() < .2 then
				inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream_short")
			end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack") end),
            TimeEvent(25*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/attack_grunt") end),
            TimeEvent(28*FRAMES, function(inst) inst:PerformBufferedAction() inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/swipe") end),
            TimeEvent(28*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },

        events=
        {
            EventHandler("animover", function(inst)inst.sg:GoToState("idle") end),
        },
    },

  	State{
		name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/hurt")
        end,

        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
		name = "taunt",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream")
        end,

        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
		name = "makenest",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("cocoon")
            --inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/taunt")
        end,

		timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream") end),
        },

        events=
        {
			EventHandler("animover", function(inst)
				inst.Physics:ClearCollisionMask()
				inst:Remove()
				local den = SpawnPrefab("spiderden")
				den.AnimState:PlayAnimation("cocoon_small")
				den.Transform:SetPosition(inst.Transform:GetWorldPosition())
			end),
        },
    },


	State{
		name = "birth",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.AnimState:PlayAnimation("enter")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/emerge_voice")
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/emerge_foley")
		end,

		timeline=
        {
        },


        events=
        {
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
        },
    },

	State{
		name = "poop_pre",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("poop_pre")

        end,

        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/scream_short") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("poop_loop") end),
        },
    },

    State{
        name = "poop_loop",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            local angle = TheCamera:GetHeadingTarget()*DEGREES -- -22.5*DEGREES
            inst.Transform:SetRotation(angle / DEGREES)
            inst.AnimState:PlayAnimation("poop_loop")

        end,

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/givebirth_voice") end),

            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/givebirth_foley") end),
            TimeEvent(10*FRAMES, function(inst)
                if inst.components.incrementalproducer then
                    inst.components.incrementalproducer:TryProduce()
                end
            end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                if inst.components.incrementalproducer and inst.components.incrementalproducer:CanProduce() then
                    inst.sg:GoToState("poop_loop")
                else
                    inst.sg:GoToState("poop_pst")
                end
            end),
        },
    },

    State{
        name = "poop_pst",
        tags = {"busy", "nointerrupt"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            local angle = TheCamera:GetHeadingTarget()*DEGREES -- -22.5*DEGREES
            inst.Transform:SetRotation(angle / DEGREES)
            inst.AnimState:PlayAnimation("poop_pst")

        end,
        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/die")
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,

    },

}

CommonStates.AddSleepStates(states,
	{
		sleeptimeline = {
	        TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/sleeping") end),
		},
	},
	{
		onsleep = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/fallasleep")
		end,
		onwake = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/wakeup")
		end
	}
)


CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
		TimeEvent(38*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/walk_spiderqueen") end),
	},
})

CommonStates.AddFrozenStates(states)
CommonStates.AddSinkAndWashAshoreStates(states)


return StateGraph("spiderqueen", states, events, "idle", actionhandlers)

