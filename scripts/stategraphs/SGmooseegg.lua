require("stategraphs/commonstates")

local actionhandlers = {}

local events =
{
	-- EventHandler("lightningstrike", function(inst)
	--	   if not inst.EggHatched then
	--		   inst.sg:GoToState("crack")
	--	   end
	-- end),
}

local function ReleaseMossling(inst)
	local mossling = SpawnPrefab("mossling")
	mossling.Transform:SetPosition(inst:GetPosition():Get())
	mossling.sg:GoToState("hatch")
	inst.components.herd:AddMember(mossling)
end

local function Hatch(inst)
	local pt = inst:GetPosition()
	local time = 0

	for i = 1, TUNING.MOOSE_EGG_NUM_MOSSLINGS do
		inst:DoTaskInTime(time, ReleaseMossling)
		time = time + 0.2
	end

	inst:DoTaskInTime(time, function(inst)
		local mother = inst.components.entitytracker:GetEntity("mother")
		if mother then
			inst.components.guardian:SummonGuardian(mother)
			inst.components.guardian:DoDelta(1)
		else
			inst.components.guardian:OnGuardianDeath()
		end
	end)
end

local states =
{
	State{
		name = "land",
		tags = {"busy", "egg"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("lay")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/egg_bounce")
		end,

		timeline = {},

		events = {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle_full") end)
		},
	},

	State{
		name = "idle_full",
		tags = {"idle", "egg"},

		onenter = function(inst)
			local function doeffect(inst)
				--print("spawning effect")
				local fx = SpawnPrefab("moose_nest_fx_idle")
				local pos = inst:GetPosition()
				fx.Transform:SetPosition(pos.x, 0.1, pos.z)
				if inst.fx_task then
					inst.fx_task:Cancel()
					inst.fx_task = nil
				end
				inst.fx_task = inst:DoTaskInTime(math.random() * 10, doeffect)
			end
			doeffect(inst)
			if not inst.components.workable then
				inst:MakeWorkable(true)
			end

			inst.AnimState:PlayAnimation("idle")
			inst.components.named.possiblenames = {STRINGS.NAMES["MOOSEEGG1"], STRINGS.NAMES["MOOSEEGG2"]}
		end,

		onexit = function(inst)
			if inst.fx_task then
				inst.fx_task:Cancel()
				inst.fx_task = nil
			end

		end,
	},

	State{
		name = "idle_empty",
		tags = {"idle"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("nest")
			inst.components.named.possiblenames = {STRINGS.NAMES["MOOSENEST1"], STRINGS.NAMES["MOOSENEST2"]}
			inst:MakeWorkable(false)
		end,
	},

	State{
		name = "hit",
		tags = {"busy", "egg"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("hit")
			local fx = SpawnPrefab("moose_nest_fx_hit")
			local pos = inst:GetPosition()
			fx.Transform:SetPosition(pos.x, 0.1, pos.z)
		end,

		events = {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle_full") end)
		},
	},

	State{
		name = "crack",
		tags = {"busy", "egg"},

		onenter = function(inst)
			inst:RemoveTag("lightningrod")
            if inst:IsAsleep() then
                inst.sg:GoToState("hatch")
            else
                inst.AnimState:PlayAnimation("crack")
            end
		end,

		timeline =
		{
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/egg_crack") end)
		},

		events = {
			EventHandler("animover", function(inst) inst.sg:GoToState("hatch") end)
		},
	},

	State{
		name = "hatch",
		tags = {"busy", "egg"},

		onenter = function(inst)
            if inst:IsAsleep() then
                inst.components.named.possiblenames = { STRINGS.NAMES["MOOSENEST1"], STRINGS.NAMES["MOOSENEST2"] }
                Hatch(inst)
                inst.sg:GoToState("idle_empty")
            else
                inst.AnimState:PlayAnimation("hatch")
            end
		end,

		timeline =
		{
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/egg_bounce") end),
			TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/egg_bounce") end),
			TimeEvent(50*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/egg_bounce") end),
			TimeEvent(60*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/egg_burst")
				inst.components.named.possiblenames = {STRINGS.NAMES["MOOSENEST1"], STRINGS.NAMES["MOOSENEST2"]}
			end),
			TimeEvent(60*FRAMES, function(inst) Hatch(inst) inst.sg:RemoveStateTag("egg") end)
		},

		events = {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle_empty") end)
		},
	},
}

return StateGraph("mooseegg", states, events, "idle_empty", actionhandlers)
