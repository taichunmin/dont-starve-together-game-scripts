require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "eat"),
}

local function SetInvincible(inst, invincible)
	if inst.components.health ~= nil and not inst.components.health:IsDead() then
		inst.components.health.invincible = invincible
	end
end

local events =
{
	EventHandler("attacked", function(inst)
		if inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
			if inst.sg.mem.in_water then
				-- getting attacked while swimming should result in fleeing
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()

				inst.sg:GoToState("idle")
				if inst.brain ~= nil then
					inst.brain:ForceUpdate()
				end
			else
				inst.sg:GoToState("drill_hit")
			end
		end
	end),
	EventHandler("onsink", function(inst)
		if inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("jumping") and not inst.sg:HasStateTag("drilling_pst") then
			if inst.sg:HasStateTag("drilling") then
				inst.sg:GoToState("drill_pst")
			else
				inst.sg:GoToState("gohome")
			end
		end
	end),
	EventHandler("gohome", function(inst) if inst.components.health ~= nil and not inst.components.health:IsDead() then inst.sg:GoToState("gohome") end end),
	EventHandler("death", function(inst)
		if inst.sg.mem.in_water then
			inst.sg:GoToState("death")
		else
			inst.sg:GoToState("death_boat")
		end
	end),
	EventHandler("gotosleep", function(inst) if inst.components.health ~= nil and not inst.components.health:IsDead() and inst:HasTag("swimming") and not inst.sg:HasStateTag("jumping") then inst.sg:GoToState(inst.sg:HasStateTag("sleeping") and "sleeping" or "sleep") end end),
    EventHandler("teleported", function(inst)
		if inst.components.health ~= nil and not inst.components.health:IsDead() then
			inst.sg:GoToState("jump_pst_water")
        end
    end),
	CommonHandlers.OnLocomote(true, true),
}

local function RestoreCollidesWith(inst)
	inst.Physics:CollidesWith(COLLISION.WORLD
						+ COLLISION.OBSTACLES
						+ COLLISION.SMALLOBSTACLES
						+ COLLISION.CHARACTERS
						+ COLLISION.GIANTS)
end

local function SetSortOrderIsInWater(inst, in_water)
	if in_water then
		inst.sg.mem.in_water = true
		inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.BOAT_LIP)
		inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
	elseif not in_water then
		inst.sg.mem.in_water = false
		inst.AnimState:SetSortOrder(0)
		inst.AnimState:SetLayer(LAYER_WORLD)
		RestoreCollidesWith(inst)
	end
end

local function UpdateWalkSpeedAndHopping(inst)
	inst.components.locomotor.walkspeed = (inst.target_wood ~= nil and inst.target_wood:IsValid()) and TUNING.COOKIECUTTER.APPROACH_SPEED or TUNING.COOKIECUTTER.WANDER_SPEED
end

local WALKABLEPLATFORM_TAGS = {"walkableplatform"}

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, push_idle_anim)
			SetSortOrderIsInWater(inst, true)
			inst.Physics:Stop()
			if push_idle_anim then
				inst.AnimState:PushAnimation("idle", true)
			else
				inst.AnimState:PlayAnimation("idle", true)
			end
        end,
    },

    State{
        name = "resurface",
        tags = { "busy", "noattack", "nosleep", "nointerrupt" },

        onenter = function(inst, should_relocate)
			SetSortOrderIsInWater(inst, true)
			inst:AddTag("NOCLICK")
            inst.AnimState:PlayAnimation("resurface")

			if should_relocate then

				local pt = inst:GetPosition()
				local a = math.random() * 2 - 1
				local r = math.random() * 2
				local boat = inst:GetCurrentPlatform()
				local boat_dir = (boat ~= nil and boat.components.boatphysics ~= nil) and Vector3(boat.components.boatphysics.velocity_x, 0, boat.components.boatphysics.velocity_z) or nil
				if boat_dir ~= nil then
					pt = pt + boat_dir * -TUNING.MAX_WALKABLE_PLATFORM_RADIUS
				end
				local start_angle = (inst.Transform:GetRotation() + 180 + a*a*a*30) * DEGREES
				local min_dist_to_boat = TUNING.MAX_WALKABLE_PLATFORM_RADIUS + inst:GetPhysicsRadius(0) + 1
				local function testfn(new_pt) return #TheSim:FindEntities(new_pt.x, 0, new_pt.z, min_dist_to_boat, WALKABLEPLATFORM_TAGS) == 0 end

				local offset = FindSwimmableOffset(pt, start_angle, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + r, 16, true, nil, testfn, true) -- allowing boats because testfn will handle it
										or FindSwimmableOffset(pt, start_angle, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + r + 3, 16, true, nil, testfn, true)
										or FindSwimmableOffset(pt, start_angle, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + r + 6, 16, true, nil, testfn, true)

				if offset ~= nil then
					inst.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)
				else
					inst:DoReturnHome()
				end
			end
		end,

		timeline =
		{
			TimeEvent(9*FRAMES, function(inst)
				inst:RemoveTag("NOCLICK")
				inst.sg:RemoveStateTag("noattack")
				inst.sg:RemoveStateTag("nosleep")
				inst.sg:RemoveStateTag("nointerrupt")
			end),
		},

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

		onexit = function(inst)
			inst:RemoveTag("NOCLICK")
		end,
    },

	State{
        name = "gohome",
        tags = { "busy", "noattack", "nosleep", "nointerrupt" },

        onenter = function(inst, cb)
			SetSortOrderIsInWater(inst, true)
            inst.AnimState:PlayAnimation("leave")
		end,

        events =
        {
            EventHandler("animover", function(inst)
				inst:DoReturnHome()
			end),
        },
	},

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
			SetSortOrderIsInWater(inst, true)
            inst.Physics:Stop()

		    inst.AnimState:PlayAnimation("death")
			inst.AnimState:PushAnimation("death_idle", true)

            inst.SoundEmitter:PlaySound("saltydog/creatures/cookiecutter/death")
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
    },

    State{
        name = "death_boat",
        tags = { "busy" },

        onenter = function(inst)
			SetSortOrderIsInWater(inst, false)
            inst.Physics:Stop()

	        inst.AnimState:PlayAnimation("boat_death")
	        inst.AnimState:PushAnimation("boat_death_idle", true)
	        RemovePhysicsColliders(inst)

            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,

		timeline =
		{
			TimeEvent(5*FRAMES, function(inst)
	            inst.SoundEmitter:PlaySound("saltydog/creatures/cookiecutter/death")
			end),
			TimeEvent(16*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/thunk")
			end),
		},
    },

    State{
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
			SetSortOrderIsInWater(inst, true)
			inst.components.locomotor:WalkForward()
			inst.AnimState:PlayAnimation("walk_pre")
        end,

		onupdate = UpdateWalkSpeedAndHopping,

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("walk")
				end
			end),
        },
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
			inst.AnimState:PlayAnimation("walk_loop", true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

		onupdate = UpdateWalkSpeedAndHopping,

        ontimeout = function(inst)
			inst.sg:GoToState("walk")
		end,
    },

	State{
        name = "walk_stop",
        tags = { "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PushAnimation("walk_pst", false)
        end,

		onupdate = UpdateWalkSpeedAndHopping,

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
        name = "run_start",
        tags = { "moving", "running", "canrotate", "noattack", "nosleep", "nointerrupt" },

        onenter = function(inst)
			SetSortOrderIsInWater(inst, true)
            inst.components.locomotor:RunForward()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pre")
			inst:AddTag("NOCLICK")
			SetInvincible(inst, true)
        end,

		timeline =
		{
			TimeEvent(9*FRAMES, function(inst)
	            inst.components.locomotor:RunForward()
			end),
		},

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("run")
				end
			end),
        },

		onexit = function(inst)
			inst:RemoveTag("NOCLICK")
			SetInvincible(inst, false)
		end,
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate", "noattack", "nosleep", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop", true)
			inst:AddTag("NOCLICK")
			SetInvincible(inst, true)
        end,

		onexit = function(inst)
			inst:RemoveTag("NOCLICK")
			SetInvincible(inst, false)
		end,

    },

	State{
        name = "run_stop",
        tags = { "busy", "noattack", "nosleep", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("run_pst")
			inst:AddTag("NOCLICK")
			SetInvincible(inst, true)
        end,

		timeline =
		{
			TimeEvent(9*FRAMES, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},

        events =
        {
            EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle") -- fail safe exit, normal exit should happen in the timeline
				end
			end),
        },

		onexit = function(inst)
			inst:RemoveTag("NOCLICK")
			SetInvincible(inst, false)
		end,
    },

    State{
        name = "eat",

        onenter = function(inst, cb)
			inst.sg:GoToState("jump_pre", (inst:GetBufferedAction() ~= nil and inst:GetBufferedAction().target) and inst:GetBufferedAction().target:GetPosition() or nil)
        end,
    },

	State{
        name = "jump_pre",
        tags = { "busy", "canrotate", "nosleep", "noattack", "nointerrupt" },

        onenter = function(inst, target_pt)
			SetSortOrderIsInWater(inst, true)


			if target_pt ~= nil then
				inst.sg.statemem.target_pt = target_pt
				inst:ForceFacePoint(inst.sg.statemem.target_pt:Get())
			end
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("jump_pre")
        end,

		timeline =
		{
			TimeEvent(10*FRAMES, function(inst)
				SpawnPrefab("splash").Transform:SetPosition(inst.Transform:GetWorldPosition())
				inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small")
			end),
		},

        events =
        {
            EventHandler("animover", function(inst)
				inst.sg:GoToState("jumping", inst.sg.statemem.target_pt ~= nil and (inst:GetPosition() - inst.sg.statemem.target_pt):Length() + math.random() or nil)
			end),
        },
    },

	State{
        name = "jumping",
        tags = { "busy", "jumping", "nosleep", "noattack", "nointerrupt" },

        onenter = function(inst, motor_speed)
			SetSortOrderIsInWater(inst, false)

			inst.AnimState:PlayAnimation("jumping")

            inst.components.locomotor:Stop()

	        inst.Physics:SetCollisionMask(COLLISION.GROUND)

			if motor_speed ~= nil then
	            inst.Physics:SetMotorVelOverride(motor_speed, 0, 0)
			end
        end,

        timeline =
        {
			TimeEvent(12, function(inst)
	            inst.Physics:ClearMotorVelOverride()
			end),

			TimeEvent(14, function(inst)
		        inst.Physics:SetCollisionMask(COLLISION.WORLD) -- collide with the ground and limits, this will let physics push the cookie cutter on or off boats
			end),

			TimeEvent(15*FRAMES, function(inst)
                inst.components.combat:DoAreaAttack(inst, TUNING.COOKIECUTTER.JUMP_ATTACK_RADIUS, nil, nil, nil, { "cookiecutter", "INLIMBO", "invisible", "noattack", "flight", "playerghost", "shadow", "shadowchesspiece", "shadowcreature" })
			end),
        },

        events =
        {
            EventHandler("animover", function(inst)
				if inst:GetCurrentPlatform() ~= nil then
					inst.sg.statemem.collisionmask = nil

					inst.sg:GoToState("jump_pst_boat")
				else
					if inst:GetBufferedAction() ~= nil then
						inst:PerformBufferedAction()
					end
					inst.sg:GoToState("jump_pst_water")
				end
			end),
        },

		onexit = function(inst)
            inst.Physics:ClearMotorVelOverride()
			RestoreCollidesWith(inst)
			if inst:GetBufferedAction() ~= nil then
				inst:ClearBufferedAction()
			end
		end,
    },

	State{
        name = "jump_pst_water",
        tags = { "busy", "nosleep", "noattack", "nointerrupt" },

        onenter = function(inst)
			SetSortOrderIsInWater(inst, true)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("jump_pst_water")

			SpawnPrefab("splash").Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/small")
        end,

        events =
        {
            EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
        },
    },

	State{
        name = "jump_pst_boat",
        tags = { "busy", "nosleep", "drilling" },

        onenter = function(inst)
			SetSortOrderIsInWater(inst, false)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("jump_pst_boat")
			inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/damage_small")
			inst.components.cookiecutterdrill:ResetDrilling()
	        inst.Physics:SetCollisionMask(COLLISION.GROUND)
        end,

        events =
        {
            EventHandler("animover", function(inst)
				inst.sg.statemem.notinterupted = true
				inst.sg:GoToState("drill")
			end),
        },

		onexit = function(inst)
			SetSortOrderIsInWater(inst, not inst.sg.statemem.notinterupted)
			RestoreCollidesWith(inst)
		end,
    },

    State{
        name = "drill",
		tags = { "drilling", "nosleep" },

        onenter = function(inst)
			SetSortOrderIsInWater(inst, false)
	        inst.Physics:SetCollisionMask(COLLISION.GROUND)
			if inst.target_wood ~= nil and inst.target_wood:IsValid() and inst.target_wood:HasTag("boat") then
				inst.AnimState:PlayAnimation("drill_loop", true)
				inst.SoundEmitter:PlaySound("saltydog/creatures/cookiecutter/eat_LP", "eat_LP")

				inst.components.cookiecutterdrill:ResumeDrilling()

				inst.sg.statemem.fx_task = inst:DoPeriodicTask(inst.AnimState:GetCurrentAnimationLength(), function(i) SpawnPrefab("wood_splinter_drill").Transform:SetPosition(i.Transform:GetWorldPosition()) end, 0)
			else
				inst.sg:GoToState("drill_pst")
			end
		end,

        onupdate = function(inst)
			if inst.components.cookiecutterdrill:GetIsDoneDrilling() then
				inst.sg:GoToState("drill_pst")
			end
		end,

		onexit = function(inst)
			if inst.sg.statemem.fx_task ~= nil then
				inst.sg.statemem.fx_task:Cancel()
			end
			RestoreCollidesWith(inst)
			inst.SoundEmitter:KillSound("eat_LP")
			inst.components.cookiecutterdrill:PauseDrilling()
		end,
    },

    State{
        name = "drill_pst",
        tags = { "busy", "drilling", "drilling_pst", "nosleep", "noattack", "nointerrupt" },

        onenter = function(inst)
			SetSortOrderIsInWater(inst, false)
	        inst.Physics:SetCollisionMask(COLLISION.GROUND)
			inst:AddTag("NOCLICK")

            inst.Physics:Stop()
    		inst.AnimState:PlayAnimation("drill_pst")
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 1.0 + math.random() * 0.5)

			if inst.target_wood ~= nil and inst.target_wood:IsValid() and inst.target_wood:HasTag("boat") then
				inst.SoundEmitter:PlaySound("saltydog/creatures/cookiecutter/attack")
			end
		end,

        timeline =
        {
			TimeEvent(3*FRAMES, function(inst)
				if inst.components.eater ~= nil then
					inst.components.eater.lasteattime = GetTime()
				end
				inst.components.cookiecutterdrill:FinishDrilling()
			end),
        },

        events =
        {
            EventHandler("animover", function(inst)
				inst:Hide()
			end),
        },

        ontimeout = function(inst)
			inst.sg:GoToState("resurface", true)
		end,

		onexit = function(inst)
			RestoreCollidesWith(inst)
			inst:RemoveTag("NOCLICK")
			inst:Show()
		end,
    },

    State{
        name = "drill_hit",
        tags = { "busy", "hit", "drilling" },

        onenter = function(inst)
			SetSortOrderIsInWater(inst, false)
	        inst.Physics:SetCollisionMask(COLLISION.GROUND)

            inst.Physics:Stop()
			inst.AnimState:PlayAnimation("hit")
            inst.AnimState:PushAnimation("attack_loop", false)
			inst.SoundEmitter:PlaySound("saltydog/creatures/cookiecutter/hit")

        end,

        timeline =
        {
			TimeEvent(19*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("saltydog/creatures/cookiecutter/attack")
			end),
			TimeEvent(25*FRAMES, function(inst)
                inst.components.combat:DoAreaAttack(inst, TUNING.COOKIECUTTER.ATTACK_RADIUS, nil, nil, nil, { "cookiecutter", "INLIMBO", "invisible", "noattack", "flight", "playerghost", "shadow", "shadowchesspiece", "shadowcreature" })
			end),
			TimeEvent(27*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("saltydog/creatures/cookiecutter/attack")
			end),
        },

        events =
        {
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("drill") end),
        },

		onexit = function(inst)
			RestoreCollidesWith(inst)
		end,
    },

}

CommonStates.AddSleepStates(states, {})

return StateGraph("cookiecutter", states, events, "resurface", actionhandlers)
