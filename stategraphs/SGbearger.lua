require("stategraphs/commonstates")

local SHAKE_DIST = 40

local YAWNTARGET_CANT_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO" }
local YAWNTARGET_ONEOF_TAGS = { "sleeper", "player" }

function yawnfn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.BEARGER_YAWN_RANGE, nil, YAWNTARGET_CANT_TAGS, YAWNTARGET_ONEOF_TAGS)
    for i, v in ipairs(ents) do
        if v ~= inst and v:IsValid() and
            not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and
            not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) and
            not (v.components.fossilizable ~= nil and v.components.fossilizable:IsFossilized()) then
            local mount = v.components.rider ~= nil and v.components.rider:GetMount() or nil
            if mount ~= nil then
                mount:PushEvent("ridersleep", { sleepiness = 7, sleeptime = TUNING.BEARGER_YAWN_SLEEPTIME })
            end
            if v:HasTag("player") then
                v:PushEvent("yawn", { grogginess = 4, knockoutduration = TUNING.BEARGER_YAWN_SLEEPTIME })
            elseif v.components.sleeper ~= nil then
                v.components.sleeper:AddSleepiness(7, TUNING.BEARGER_YAWN_SLEEPTIME)
            elseif v.components.grogginess ~= nil then
                v.components.grogginess:AddGrogginess(4, TUNING.BEARGER_YAWN_SLEEPTIME)
            else
                v:PushEvent("knockedout")
            end
        end
    end
    inst.canyawn = nil
    return true
end

local function onattackedfn(inst, data)
    if inst.components.health ~= nil and
        not inst.components.health:IsDead() and
		not CommonHandlers.HitRecoveryDelay(inst) and
       (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("frozen")) then

        -- Clear out the inventory if he got interrupted
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        while target ~= nil do
            target:Remove()
            target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        end

        inst.sg:GoToState("hit")
    end
end

local function onattackfn(inst)
    if inst.components.health ~= nil and
        not inst.components.health:IsDead() and
        (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then

        -- Clear out the inventory if he got interrupted
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        while target ~= nil do
            target:Remove()
            target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        end

        if inst.components.combat ~= nil and
            inst.components.combat.target ~= nil and
            inst.components.combat.target:HasTag("beehive") then
            inst.sg:GoToState("attack")
            return
        end

        if not (inst.cangroundpound or inst.components.timer:TimerExists("GroundPound")) then
            inst.components.timer:StartTimer("GroundPound", TUNING.BEARGER_NORMAL_GROUNDPOUND_COOLDOWN)
        end

        if not (inst.canyawn or inst.components.timer:TimerExists("Yawn")) and inst:HasTag("hibernation") then
            --print("Starting yawn timer ", TUNING.BEARGER_YAWN_COOLDOWN)
            inst.components.timer:StartTimer("Yawn", TUNING.BEARGER_YAWN_COOLDOWN)
        end

        if inst.sg:HasStateTag("running") then
            inst.sg:GoToState("pound")
        elseif inst.canyawn and not inst.sg:HasStateTag("yawn") then
            inst.sg:GoToState("yawn")
        elseif inst.cangroundpound then
            inst.sg:GoToState("pound")
        else
            inst.sg:GoToState("attack")
        end
    end
end

local DESTROYSTUFF_CANT_TAGS = { "INLIMBO", "NET_workable" }
local function destroystuff(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 5, nil, DESTROYSTUFF_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() and
            v.components.workable ~= nil and
            v.components.workable:CanBeWorked() and
            v.components.workable.action ~= ACTIONS.NET then
            SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
            v.components.workable:Destroy(inst)
        end
    end
end

local actionhandlers =
{
	--ActionHandler(ACTIONS.HAMMER, "attack"),
	ActionHandler(ACTIONS.GOHOME, "taunt"),

	ActionHandler(ACTIONS.STEAL, "steal"),
	ActionHandler(ACTIONS.HAMMER, "steal"),
	ActionHandler(ACTIONS.EAT, "eat_loop"),

	ActionHandler(ACTIONS.PICKUP, "action"),
	ActionHandler(ACTIONS.HARVEST, "action"),
	ActionHandler(ACTIONS.PICK, "action"),

	ActionHandler(ACTIONS.ATTACK, "attack")
}
local events =
{
	CommonHandlers.OnLocomote(true,true),
	CommonHandlers.OnSleep(),
	CommonHandlers.OnFreeze(),
	CommonHandlers.OnDeath(),
	EventHandler("doattack", onattackfn),
	EventHandler("attacked", onattackedfn),
}

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 1, inst, 40)
end

local function ShakeIfClose_Pound(inst)
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .025, 1.25, inst, 40)
end

local function ShakeIfClose_Footstep(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 1, inst, 40)
end

local function DoFootstep(inst)
	if inst:IsStandState("quad") then
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft")
	else
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
		ShakeIfClose_Footstep(inst)
	end
end

local function GoToStandState(inst, state, customtrans)
	if inst.IsStandState(inst, state) then
		return true
	end
	inst.sg:GoToState(string.lower(state), {endstate = inst.sg.currentstate.name, customtrans = customtrans})
end


local states=
{

	State{
		name = "bi",
		tags = {"busy"},
		onenter = function(inst, data)
			inst.Physics:Stop()
			inst.sg.statemem.endstate = data.endstate
			inst.AnimState:PlayAnimation(data.customtrans or "taunt_pre")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				inst:SetStandState("bi")
				--inst.components.locomotor:SetShouldRun(true)
				inst.sg:GoToState(inst.sg.statemem.endstate)
			end)
		},

		timeline=
		{
			TimeEvent(6*FRAMES, function(inst) PlayFootstep(inst) end),
		},
	},

	State{
		name = "quad",
		tags = {"busy"},
		onenter = function(inst, data)
			inst.Physics:Stop()
			inst.sg.statemem.endstate = data.endstate
			inst.AnimState:PlayAnimation(data.customtrans or "taunt_pst")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				inst:SetStandState("quad")
				--inst.components.locomotor:SetShouldRun(false)
				inst.sg:GoToState(inst.sg.statemem.endstate)
			end)
		},

		timeline=
		{
			TimeEvent(7*FRAMES, function(inst)
				inst:SetStandState("quad")
				DoFootstep(inst)
			end),
		},
	},

	State{
		name = "idle",
		tags = {"idle"},

		onenter = function(inst)
			inst.Physics:Stop()
			if GoToStandState(inst, "bi") then
				inst.AnimState:PlayAnimation("idle_loop", true)
			end
		end,

		timeline=
		{
			-- TimeEvent(14*FRAMES, function(inst)
			--	   if inst:IsStandState("bi") and math.random() < .3 then
			--		   -- Make sure he's not too noisy
			--		   if ((GetTime() - inst.last_growl_time) > TUNING.BEARGER_GROWL_INTERVAL) then
			--			   inst.last_growl_time = GetTime()
			--			   inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/idle")
			--		   end
			--	   end
			-- end),
			-- TimeEvent(22*FRAMES, function(inst)
			--	   if inst:IsStandState("quad") and math.random() < .3 then
			--		   -- Make sure he's not too noisy
			--		   if ((GetTime() - inst.last_growl_time) > TUNING.BEARGER_GROWL_INTERVAL) then
			--			   inst.last_growl_time = GetTime()
			--			   inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/idle")
			--		   end
			--	   end
			-- end),
		},
	},

----------------------COMBAT------------------------

	State{
		name = "targetstolen",
		tags = {"busy", "canrotate"},

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.Physics:Stop()
				inst.AnimState:PlayAnimation("taunt")
			end
		end,

		timeline=
		{
			TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt") end),
			TimeEvent(9*FRAMES, function(inst) DoFootstep(inst) end),
			TimeEvent(33*FRAMES, function(inst) DoFootstep(inst) end),
		},

		events=
		{
			EventHandler("animover", function(inst) inst:ClearBufferedAction() inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "hit",
		tags = {"hit", "busy"},

		onenter = function(inst, cb)
			if inst.components.locomotor then
				inst.components.locomotor:StopMoving()
			end

			if inst:IsStandState("quad") then
				inst.AnimState:PlayAnimation("hit")
			else
				inst.AnimState:PlayAnimation("standing_hit")
			end
			CommonHandlers.UpdateHitRecoveryDelay(inst)
		end,

		events =
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "yawn",
		tags = {"yawn", "busy"},

		onenter = function(inst)

			if inst.components.locomotor then
				inst.components.locomotor:StopMoving()
			end

			inst.AnimState:PlayAnimation("yawn")
		end,

		timeline =
		{
			TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/yawn") end),
			TimeEvent(50*FRAMES, yawnfn),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
					if not inst.components.timer:TimerExists("Yawn") then
						--print("Starting yawn timer ", TUNING.BEARGER_YAWN_COOLDOWN)
						inst.components.timer:StartTimer("Yawn", TUNING.BEARGER_YAWN_COOLDOWN)
					end

					inst.sg:GoToState("idle")
			end),
		},
	},

	State{
		name = "attack",
		tags = {"attack", "busy", "canrotate"},

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				if inst.components.locomotor then
					inst.components.locomotor:StopMoving()
				end
				inst.components.combat:StartAttack()
				inst.AnimState:PlayAnimation("atk")
			end
		end,

		timeline=
		{
			TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			--TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			TimeEvent(35*FRAMES, function(inst) inst.components.combat:DoAttack() inst.WorkEntities(inst) end),
		},


		events=
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "pound",
		tags = {"attack", "busy"},

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				if inst.components.locomotor then
					inst.components.locomotor:StopMoving()
				end
				inst.AnimState:PlayAnimation("ground_pound")
			end
		end,

		timeline=
		{
			TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			TimeEvent(20*FRAMES, function(inst)
				ShakeIfClose_Pound(inst)
				inst.components.groundpounder:GroundPound()
				inst.cangroundpound = false
				if not inst.components.timer:TimerExists("GroundPound") then
					inst.components.timer:StartTimer("GroundPound", TUNING.BEARGER_NORMAL_GROUNDPOUND_COOLDOWN)
				end
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
			end),
		},

		events=
		{
			EventHandler("animover", function(inst)
				inst:SetStandState("quad")
				inst.sg:GoToState("idle")
			end),
		},
	},

	State{
		name = "death",
		tags = {"busy"},

		onenter = function(inst)
			if inst.components.locomotor then
				inst.components.locomotor:StopMoving()
			end

			if GoToStandState(inst, "bi") then
				inst.AnimState:PlayAnimation("death")
				RemovePhysicsColliders(inst)
			end
		end,

		timeline=
		{
			TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/death") end),
			TimeEvent(50*FRAMES, function(inst)
				ShakeIfClose(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
				inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
			end),
		},

	},

-------------------EATING-------------------------

	State{
		name = "action",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			if GoToStandState(inst, "bi") then
				inst.AnimState:PlayAnimation("action")
				inst.AnimState:PushAnimation("eat_loop", false)
			end
		end,

		timeline =
		{
			TimeEvent(5*FRAMES, function(inst) end),
			TimeEvent(15*FRAMES, function(inst)
				inst:PerformBufferedAction()
				inst.sg:RemoveStateTag("busy")
				inst.sg:AddStateTag("wantstoeat")
				inst.last_eat_time = GetTime()
                if inst.brain ~= nil then
                    inst.brain:ForceUpdate()
                end
			end),
			TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/gulp") end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("eat_pst") end)
		}
	},

	State{
		name = "eat_loop",
		tags = {"busy"},

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.Physics:Stop()
				inst.AnimState:PushAnimation("eat_loop", true)
				local timeout = math.random()+.5
				local ba = inst:GetBufferedAction()
				if ba and ba.target and ba.target:HasTag("honeyed") then
					timeout = timeout*2
				end
				inst.sg:SetTimeout(timeout)
			end
		end,

		timeline=
		{
			TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew") end),
			TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew") end),
			TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew") end),
		},

		ontimeout = function(inst)
			local ba = inst:GetBufferedAction()
			if (ba and ba.target) then
				inst.last_food_good = ba.target.components.stackable and ba.target.components.stackable:StackSize() or 1

				if ba.target:HasTag("honeyed") then
					inst.last_food_good = inst.last_food_good * 2
				end
			else
				inst.last_food_good = 0
			end
			inst:PerformBufferedAction()
			inst.last_eat_time = GetTime()
			inst.sg:GoToState("eat_pst")
		end,

	},

	State{
		name = "eat_pst",
		tags = {"busy"},

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.Physics:Stop()
				inst.AnimState:PlayAnimation("eat_pst")
			end
		end,

		timeline=
		{
		},

		events=
		{
			EventHandler("animover", function(inst)
				inst.num_good_food_eaten = inst.last_food_good and inst.num_good_food_eaten + inst.last_food_good or inst.num_good_food_eaten
				inst.last_food_good = nil
				inst.sg:GoToState("idle")
			end),
		},
	},

	State{
		name = "steal",
		tags = {"busy"},

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.Physics:Stop()
				inst.AnimState:PlayAnimation("atk", false)
			end
		end,

		timeline=
		{
			TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			--TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			TimeEvent(35*FRAMES, function(inst) inst:PerformBufferedAction() end),
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

---------------------------WALKING---------------

	State{
			name = "walk_start",
			tags = {"moving", "canrotate"},

			onenter = function(inst)
				local anim = (inst.components.combat.target and not inst.components.combat.target:HasTag("beehive")) and "charge_pre" or "walk_pre"
				if GoToStandState(inst, "bi") then
					inst.AnimState:PlayAnimation(anim)
				end
			end,

			events =
			{
				EventHandler("animqueueover", function(inst) inst.sg:GoToState("walk") end ),
			},
		},

	State{
			name = "walk",
			tags = {"moving", "canrotate"},

			onenter = function(inst)
				local anim = (inst.components.combat.target and not inst.components.combat.target:HasTag("beehive")) and "charge_loop" or "walk_loop"
				if GoToStandState(inst, "bi") then
					inst.AnimState:PlayAnimation(anim)
				end
				inst.components.locomotor:WalkForward()
				if inst.components.combat and inst.components.combat.target and math.random() < .5 then
					inst:DoTaskInTime(math.random(13)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/grrrr") end)
				end
			end,

			events=
			{
				EventHandler("animqueueover", function(inst) inst.sg:GoToState("walk") end ),
			},

			timeline=
			{
				TimeEvent(2*FRAMES, function(inst)
					if inst.components.combat.target then
						DoFootstep(inst)
					end
				end),
				TimeEvent(18*FRAMES, function(inst)
					if inst.components.combat.target then
						DoFootstep(inst)
					end
				end),
				TimeEvent(4*FRAMES, function(inst)
					if not inst.components.combat.target then
						DoFootstep(inst)
					end
				end),
				TimeEvent(30*FRAMES, function(inst)
					if not inst.components.combat.target then
						DoFootstep(inst)
					end
				end),
			},
		},

	State{
			name = "walk_stop",
			tags = {"canrotate"},

			onenter = function(inst)
				inst.components.locomotor:StopMoving()
				local anim = (inst.components.combat.target and not inst.components.combat.target:HasTag("beehive")) and "charge_pst" or "walk_pst"
				DoFootstep(inst)
				if GoToStandState(inst, "bi") then
					inst.AnimState:PlayAnimation(anim)
				end
			end,

			events=
			{
				EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
			},
		},

	State{
			name = "run_start",
			tags = {"moving", "running", "atk_pre", "canrotate"},

			onenter = function(inst)
				if GoToStandState(inst, "bi") then
					inst.components.locomotor:RunForward()
					inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt", "taunt")
					inst.AnimState:PlayAnimation("charge_pre")
				end
			end,

			events =
			{
				EventHandler("animqueueover", function(inst) inst.sg:GoToState("run") end ),
			},
		},

	State{

			name = "run",
			tags = {"moving", "running", "canrotate"},

			onenter = function(inst)
				inst.components.locomotor:RunForward()
				if not inst.SoundEmitter:PlayingSound("taunt") then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt", "taunt") end
				inst.AnimState:PlayAnimation("charge_roar_loop")
			end,

			timeline=
			{
				TimeEvent(3*FRAMES, function(inst)
					DoFootstep(inst)
					destroystuff(inst)
				end),
				TimeEvent(11*FRAMES, function(inst)
					DoFootstep(inst)
					destroystuff(inst)
				end),
			},

			events=
			{
				EventHandler("animqueueover", function(inst) inst.sg:GoToState("run") end ),
			},
		},

	State{

			name = "run_stop",
			tags = {"canrotate"},

			onenter = function(inst)
				inst.components.locomotor:StopMoving()
				local should_softstop = false
				inst.AnimState:PlayAnimation("charge_pst")
			end,

			events=
			{
				EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
			},
		},

------------------SLEEPING-----------------

		State{
			name = "sleep",
			tags = {"busy", "sleeping"},

			onenter = function(inst)
				inst.components.locomotor:StopMoving()
				inst.last_eat_time = nil -- Unset eat timer
				if inst:IsStandState("quad") then
					inst.AnimState:PushAnimation("sleep_pre", false)
				else
					inst.AnimState:PlayAnimation("standing_sleep_pre")
					inst.AnimState:PushAnimation("sleep_pre", false)
				end
			end,

			events=
			{
				EventHandler("animqueueover", function(inst) inst.sg:GoToState("sleeping") end ),
				EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
			},

			timeline=
			{
				TimeEvent(25*FRAMES, function(inst)
					if inst:IsStandState("bi") then
						inst:SetStandState("quad")
						DoFootstep(inst)
					end
				end),
			},
		},

		State{

			name = "sleeping",
			tags = {"busy", "sleeping"},

			onenter = function(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/sleep")
				inst.AnimState:PlayAnimation("sleep_loop")
			end,

			events=
			{
				EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end ),
				EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
			},
		},

		State{

			name = "wake",
			tags = {"busy", "waking"},

			onenter = function(inst)
				inst.last_eat_time = GetTime() -- Fake this as eating so he doesn't aggro immediately
				inst.components.locomotor:StopMoving()
				inst.AnimState:PlayAnimation("sleep_pst")
				if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
					inst.components.sleeper:WakeUp()
				end
				if not inst:IsStandState("quad") then inst:SetStandState("quad") end
			end,

			events=
			{
				EventHandler("animover", function(inst)  inst.sg:GoToState("yawn") end ),
			},

			timeline=
			{
				TimeEvent(27*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt_short") end),
			},
		},
}

CommonStates.AddFrozenStates(states)

return StateGraph("bearger", states, events, "idle", actionhandlers)
