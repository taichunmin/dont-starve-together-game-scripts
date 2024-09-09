--V2C: -purposely not using "idle" or "busy" tags to avoid tag/networking overhead
--     -also don't need to check AnimState:AnimDone() since we don't have to worry
--      about how state transitions are triggered for this guy.

local function TrySplashFX(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
		SpawnPrefab("ocean_splash_small"..tostring(math.random(2))).Transform:SetPosition(x, 0, z)
	end
end

local states =
{
	State{
		name = "spawn",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("spawn")
		end,

		timeline =
		{
			TimeEvent(0, function(inst)
				inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/spawn")
				TrySplashFX(inst)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},

	State{
		name = "idle",
		tags = { "candetect", "canactivate" },

		onenter = function(inst, randomize)
			inst.AnimState:PlayAnimation("idle", true)
			if randomize then
				inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
			end
		end,
	},

	State{
		name = "near_idle_pre",
		tags = { "near", "canactivate" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("trigger_start")
			inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/trigger_start")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("near_idle")
			end),
		},
	},

	State{
		name = "near_idle",
		tags = { "near", "candetect", "canactivate" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("trigger_loop", true)
			inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/trigger_lp", "trigger_lp")
		end,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("trigger_lp")
		end,
	},

	State{
		name = "near_idle_pst",
		tags = { "canactivate" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("trigger_out")
			inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/trigger_out")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},

	State{
		name = "activate",
		tags = { "activated" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("tension_pre")
			inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/tension_pre")
			inst:EnableTargetFX(true)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg.statemem.activating = true
				inst.sg:GoToState("activating_loop")
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.activating then
				inst:EnableTargetFX(false)
			end
		end,
	},

	State{
		name = "activating_loop",
		tags = { "activated" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("tension_loop")
			inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/tension_lp", "tension_lp")
			inst:EnableGroundFX(true)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg.statemem.activating = true
				inst.sg:GoToState("trigger")
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.activating then
				inst:EnableTargetFX(false)
				inst:EnableGroundFX(false)
			end
			inst.SoundEmitter:KillSound("tension_lp")
		end,
	},

	State{
		name = "trigger",
		tags = { "activated" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("explode")
			inst.SoundEmitter:PlaySound("maxwell_rework/shadow_trap/explode")

			--shadow_despawn is in the air => detaches from sinking boats
			--shadow_glob_fx is on ground => dies with sinking boats

			--SpawnPrefab("shadow_despawn").entity:SetParent(inst.entity)
			--inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_despawn")

			local x, y, z = inst.Transform:GetWorldPosition()
			local fx = SpawnPrefab("shadow_glob_fx")
			local platform = inst:GetCurrentPlatform()
			if platform ~= nil then
				fx.entity:SetParent(platform.entity)
				fx.Transform:SetPosition(platform.entity:WorldToLocalSpace(x, y, z))
			else
				fx.Transform:SetPosition(x, y, z)
				fx:EnableRipples(true)
			end
			fx.AnimState:SetScale(math.random() < .5 and -1.8 or 1.8, 1.8, 1.8)

			TrySplashFX(inst)
			inst.base:KillFX()
			inst.shockwave:push()
			inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

			inst:EnableTargetFX(false)
			inst:TriggerTrap()
		end,

		onexit = BRANCH == "dev" and function(inst)
			assert(false)
		end or nil,
	},

	State{
		name = "dispell",
		tags = { "activated" },

		onenter = function(inst, collidewithboat)
			inst.AnimState:PlayAnimation("dispell")

			--shadow_despawn is in the air => detaches from sinking boats
			--shadow_glob_fx is on ground => dies with sinking boats

			SpawnPrefab("shadow_despawn").entity:SetParent(inst.entity)

			if not collidewithboat then
				local x, y, z = inst.Transform:GetWorldPosition()
				local fx = SpawnPrefab("shadow_glob_fx")
				local platform = inst:GetCurrentPlatform()
				if platform ~= nil then
					fx.entity:SetParent(platform.entity)
					fx.Transform:SetPosition(platform.entity:WorldToLocalSpace(x, y, z))
				else
					fx.Transform:SetPosition(x, y, z)
					fx:EnableRipples(true)
				end
				fx.AnimState:SetScale(math.random() < .5 and -1.2 or 1.2, 1.2, 1.2)

				TrySplashFX(inst)
				inst.base:KillFX()
			else
				inst.base:Remove()
			end

			--wait for shadow_despawn to finish
			inst.sg:SetTimeout(1)
		end,

		ontimeout = function(inst)
			inst:Remove()
		end,

		onexit = BRANCH == "dev" and function(inst)
			assert(false)
		end or nil,
	},
}

return StateGraph("shadow_trap", states, {}, "spawn")
