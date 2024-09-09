require("stategraphs/commonstates")

local SGDaywalkerCommon = {}

--------------------------------------------------------------------------

SGDaywalkerCommon.DoRoarShake = function(inst)
	ShakeAllCameras(CAMERASHAKE.FULL, 1.4, .02, .2, inst, 30)
end

SGDaywalkerCommon.DoPounceShake = function(inst)
	ShakeAllCameras(CAMERASHAKE.FULL, .4, .02, .15, inst, 20)
end

SGDaywalkerCommon.DoDefeatShake = function(inst)
	ShakeAllCameras(CAMERASHAKE.VERTICAL, .6, .025, .2, inst, 20)
end

SGDaywalkerCommon.DoSleepShake = function(inst)
	ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .02, .15, inst, 20)
end

--------------------------------------------------------------------------

SGDaywalkerCommon.TryChatter = function(inst, delaytbl, strtblname, index, ignoredelay, prioritylevel)
	local t = GetTime()
	local delays = delaytbl[strtblname]
	if ignoredelay or (inst.sg.mem.lastchatter or 0) + (delays and delays.delay or 0) < t then
		prioritylevel = prioritylevel or CHATPRIORITIES.LOW
		inst.sg.mem.lastchatter = t
		inst.components.talker:Chatter(strtblname, index or math.random(#STRINGS[strtblname]), (delays and delays.len) or nil, nil, prioritylevel)
	end
end

--------------------------------------------------------------------------

local function DoFootstep(inst, volume)
	inst.sg.mem.lastfootstep = GetTime()
	inst.SoundEmitter:PlaySound(inst.footstep, nil, volume)
end

local function OnEnterWalkingStates(inst)
	inst.sg:AddStateTag("walk")
	inst:SetHeadTracking(true)
	if inst.autostalk then
		inst:SetStalking(inst.components.combat.target)
	end
	if inst:IsStalking() then
		inst.sg:AddStateTag("stalking")
	end
end

SGDaywalkerCommon.AddWalkStates = function(states, override_timelines, override_fns)
	local timelines =
	{
		starttimeline =
		{
			FrameEvent(0, function(inst) DoFootstep(inst, 0.5) end),
		},
		walktimeline =
		{
			FrameEvent(19, DoFootstep),
			FrameEvent(43, DoFootstep),
		},
		endtimeline =
		{
			FrameEvent(0, function(inst)
				inst.sg.statemem.noexitstep = true
				local t = GetTime()
				if (inst.sg.mem.lastfootstep or -math.huge) + 0.5 < t then
					inst.sg.mem.lastfootstep = t
					inst.SoundEmitter:PlaySound(inst.footstep)
				end
			end),
		},
	}

	local fns =
	{
		startonenter = OnEnterWalkingStates,
		walkonenter = OnEnterWalkingStates,
		endonenter = OnEnterWalkingStates,
		endonexit = function(inst)
			if not inst.sg.statemem.noexitstep then
				local t = GetTime()
				if (inst.sg.mem.lastfootstep or -math.huge) + 0.5 < t then
					inst.sg.mem.lastfootstep = t
					inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.5)
				end
			end
		end,
	}

	if override_timelines then
		shallowcopy(override_timelines, timelines)
	end
	if override_fns then
		shallowcopy(override_fns, fns)
	end

	CommonStates.AddWalkStates(states, timelines, nil, nil, nil, fns)
end

SGDaywalkerCommon.AddRunStates = function(states, override_timelines, override_fns)
	local timelines =
	{
		starttimeline =
		{
			FrameEvent(0, function(inst) DoFootstep(inst, 0.5) end),
		},
		runtimeline =
		{
			FrameEvent(9, DoFootstep),
			FrameEvent(22, DoFootstep),
		},
		endtimeline =
		{
			FrameEvent(0, function(inst)
				inst.sg.statemem.noexitstep = true
				local t = GetTime()
				if (inst.sg.mem.lastfootstep or -math.huge) + 0.3 < t then
					inst.sg.mem.lastfootstep = t
					inst.SoundEmitter:PlaySound(inst.footstep)
				end
			end),
		},
	}

	local fns =
	{
		startonenter = function(inst)
			inst:SetStalking(nil)
		end,
		endonexit = function(inst)
			if not inst.sg.statemem.noexitstep then
				local t = GetTime()
				if (inst.sg.mem.lastfootstep or -math.huge) + 0.3 < t then
					inst.sg.mem.lastfootstep = t
					inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.5)
				end
			end
		end,
	}

	if override_timelines then
		shallowcopy(override_timelines, timelines)
	end
	if override_fns then
		shallowcopy(override_fns, fns)
	end

	CommonStates.AddRunStates(states, timelines, nil, nil, nil, fns)
end

--------------------------------------------------------------------------

return SGDaywalkerCommon
