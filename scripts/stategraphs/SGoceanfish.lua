require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.EAT,
		function(inst, action)
			return action.target.components.oceanfishable ~= nil and "bitehook_pre" or "eat"
		end),
}

local events=
{
    CommonHandlers.OnLocomote(true, true),
    EventHandler("dobreach", function(inst, data)
		if not inst.sg:HasStateTag("jumping") and ( inst.food_target == nil or not inst.food_target:HasTag("oceantrawler") )then
            inst.sg:GoToState("breach")
        end
    end),
    EventHandler("doleave", function(inst, data)
        if not inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("jumping") then
            inst.sg:GoToState("leave")
        end
    end),
    EventHandler("oceanfishing_stoppedfishing", function(inst, data)
		if not inst.leaving and not inst.sg:HasStateTag("jumping") then
            inst.sg:GoToState("breach")
		end
		inst.leaving = true
    end),
    EventHandler("putoutfire", function(inst, data)
        if not inst.sg:HasStateTag("jumping") and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("shoot", { fire_pos = data.firePos })
        end
    end),
}

local function SpawnSplashFx(inst)
	if inst.fish_def.breach_fx ~= nil and not inst.sg.statemem.underboat then
		SpawnPrefab(inst.fish_def.breach_fx[math.random(#inst.fish_def.breach_fx)]).Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

local function IsUnderBoat(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
	inst.sg.statemem.underboat = TheWorld.Map:GetPlatformAtPoint(x, y, z, inst:GetPhysicsRadius(0)) ~= nil
	return inst.sg.statemem.underboat
end

local function SetBreaching(inst, is_in_air)
	if is_in_air then
		inst.Transform:SetTwoFaced()
		inst.AnimState:SetSortOrder(0)
        inst.AnimState:SetLayer(LAYER_WORLD)
		if inst.Light then
			inst.Light:Enable(true)
		end
	else
		inst.Transform:SetSixFaced()
		inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
        inst.AnimState:SetLayer(LAYER_WIP_BELOW_OCEAN)
		if inst.Light then
			inst.Light:Enable(false)
		end
	end
end

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop", true)
            if inst.timetoleave then
                inst.sg:GoToState("leave")
            end
        end,
    },

    State{
        name = "arrive",
        tags = {"busy", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("spawn_in")
        end,

        events =
        {
	        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
    },

    State{
        name = "leave",
        tags = {"busy"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("spawn_out")
			inst.persists = false
        end,

        events =
        {
	        EventHandler("animover", function(inst) inst:Remove() end),
		},
    },

    State{
        name = "eat",
        tags = {"busy", "jumping"},

        onenter = function(inst)
			if IsUnderBoat(inst) then
				inst:PerformBufferedAction()
				inst.sg:GoToState("idle")
				return
			end

            inst.components.locomotor:Stop()
            if inst.food_target == nil or not inst.food_target:HasTag("oceantrawler") then
                inst.AnimState:PlayAnimation("breach")
			    SetBreaching(inst, true)
			    SpawnSplashFx(inst)
            end

			inst:PerformBufferedAction()
        end,

        timeline =
        {
            TimeEvent(16*FRAMES, function(inst)
				SpawnSplashFx(inst)
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

		onexit = function(inst)
			SetBreaching(inst, false)
		end,
    },

    State{
        name = "bitehook_pre",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("struggle_pre")
			inst:PerformBufferedAction()
        end,

        events =
		{
	        EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					if inst.components.oceanfishable ~= nil and inst.components.oceanfishable:GetRod() ~= nil then
						inst.sg:GoToState("bitehook_loop")
					else
						inst.sg:GoToState("bitehook_escape")
					end
				end
			end),
		},
    },

    State{
        name = "bitehook_loop",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("struggle_loop", true)
            inst.sg:SetTimeout(inst.fish_def.set_hook_time.base + math.random() * inst.fish_def.set_hook_time.var)
        end,

		onupdate = function(inst)
			if inst.components.oceanfishable ~= nil and inst.components.oceanfishable:GetRod() ~= nil then
				if not inst:HasTag("partiallyhooked") then
					inst.sg:GoToState("idle")
				end
			else
				inst.sg:GoToState("bitehook_escape")
				inst.leaving = true
				inst.components.oceanfishable:SetRod(nil)
			end
		end,

        ontimeout = function(inst)
			if inst:HasTag("partiallyhooked") then
				inst.sg:GoToState("bitehook_escape")
				if inst.components.oceanfishable ~= nil and inst.components.oceanfishable:GetRod() ~= nil then
					inst.leaving = true
					inst.components.oceanfishable:GetRod().components.oceanfishingrod:StopFishing("linetooloose")
				else
					inst.leaving = true
					inst.components.oceanfishable:SetRod(nil)
				end
			end
        end,
    },

    State{
        name = "bitehook_escape",
        tags = {"busy", "jumping"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.sg.statemem.underboat = IsUnderBoat(inst)
			if inst.sg.statemem.underboat then
				inst.AnimState:PlayAnimation("idle")
			else
				inst.AnimState:PlayAnimation("struggle_to_breach")
				inst.AnimState:PushAnimation("breach", false)
			end
        end,

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
				SpawnSplashFx(inst)
				SetBreaching(inst, true)
			end),
            TimeEvent(3*FRAMES, function(inst)
				if not inst.sg.statemem.underboat then
					inst.Physics:SetMotorVelOverride(-1, 0, 0)
				end
			end),
            TimeEvent(21*FRAMES, function(inst)
				SpawnSplashFx(inst)
				inst.Physics:ClearMotorVelOverride()
				inst.components.locomotor:Stop()
            end),
        },

		events =
		{
	        EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					SpawnSplashFx(inst)
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			SetBreaching(inst, false)
			inst.Physics:ClearMotorVelOverride()
			if inst:HasTag("partiallyhooked") and inst.components.oceanfishable ~= nil then
				inst.components.oceanfishable:SetRod(nil)
			end
		end,
    },

    State{
        name = "breach",
        tags = {"busy", "jumping"},

        onenter = function(inst)
			if IsUnderBoat(inst) then
				inst.sg:GoToState("idle")
				return
			end

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("breach_pre", false)
            inst.AnimState:PushAnimation("breach", false)
        end,

		timeline =
		{
            TimeEvent(3*FRAMES, function(inst)
				SpawnSplashFx(inst)
				SetBreaching(inst, true)
			end),
            TimeEvent(5*FRAMES, function(inst)
				inst.Physics:SetMotorVelOverride(1.5, 0, 0)
			end),
            TimeEvent(24*FRAMES, function(inst)
				SpawnSplashFx(inst)
                inst.Physics:ClearMotorVelOverride()
                inst.components.locomotor:Stop()
            end),
		},

        events =
        {
            EventHandler("animqueueover", function(inst)
				inst.Physics:ClearMotorVelOverride()
                inst.sg:GoToState("idle")
            end),
        },

		onexit = function(inst)
			SetBreaching(inst, false)
		end,

    },

    State{
        name = "launched_out_of_water",
        tags = {"busy", "jumping"},

        onenter = function(inst)
			SpawnSplashFx(inst)
            inst.components.locomotor:Stop()
		    inst.AnimState:PlayAnimation("catching_loop", true)
        end,
    },

    State{
        name = "shoot",
        tags = {"busy", "shooting", "jumping"},

        onenter = function(inst, data)
            if IsUnderBoat(inst) then
                inst.sg:GoToState("idle")
                return
            end

            inst.AnimState:PlayAnimation("spit")
            inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small", nil, .25)

            inst.sg.statemem.fire_pos = data.fire_pos
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_shoot")
                inst:LaunchProjectile(inst.sg.statemem.fire_pos)

                SpawnSplashFx(inst)
                SetBreaching(inst, true)
            end),
            TimeEvent(25 * FRAMES, function(inst)
                inst.components.firedetector:DetectFire()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            SetBreaching(inst, false)
        end,
    },
}

CommonStates.AddWalkStates(states)
CommonStates.AddRunStates(states)

return StateGraph("sgoceanfish", states, events, "idle", actionhandlers)
