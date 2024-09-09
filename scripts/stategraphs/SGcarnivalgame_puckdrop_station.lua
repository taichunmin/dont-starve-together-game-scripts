
local LANDING_LEFT = 1
local LANDING_CENTER = 2
local LANDING_RIGHT = 3

local states =
{
    State{
        name = "place",
        onenter = function(inst, target)
			inst.AnimState:PlayAnimation("place")
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/place")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_off") end),
        },
    },

    State{
        name = "idle_off",
		tags = {"off"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_off")
        end,
    },

    State{
        name = "turn_on",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("turn_on")
            inst.AnimState:PushAnimation("idle_on")
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/turn_on")
        end,
    },

    State{
        name = "cycle_doors",
        onenter = function(inst, loop)
			if not loop then
				inst._current_door = inst._current_door + 1
				if inst._current_door > 3 then
					inst._current_door = 1
				end

	            inst.AnimState:PlayAnimation("door"..inst._current_door.."_pre")
			else
	            inst.AnimState:PlayAnimation("door"..inst._current_door.."_pst")
				inst._current_door = inst._current_door + 1
				if inst._current_door > 3 then
					inst._current_door = 1
				end
	            inst.AnimState:PushAnimation("door"..inst._current_door.."_pre", false)
			end

			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/door_open")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst) 
				if inst._inactive_timeout ~= nil then
					inst.sg:GoToState("cycle_doors", true)
				else
					inst.sg:GoToState("drop_ball")
				end
			end),
        },
    },


    State{
        name = "drop_ball",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("play_door"..inst._current_door.."_pre")
			inst.components.minigame:RecordExcitement()
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("play_door"..inst._current_door.."_game"..inst._current_game) end),
        },
    },

    State{
        name = "gameover",
        onenter = function(inst)
			local landing = inst.sg.mem.landing_bucket
			if inst._minigame_score == 0 then
				inst.sg:GoToState("no_rewards")
				return
			elseif landing == LANDING_CENTER then
				inst._minigame_score = inst._minigame_score * 2
			end

            inst.AnimState:PlayAnimation("win_"..landing.."_pst", false)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState(inst.sg.mem.landing_bucket == LANDING_CENTER and  "spawn_rewards_x2" or "spawn_rewards") end),
        },
    },

    State{
        name = "spawn_rewards",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("spawn_rewards", true)
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/land_shelf")
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/spawn_rewards", "rewards_loop")
        end,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("rewards_loop")
		end,
    },

    State{
        name = "spawn_rewards_x2",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("spawn_rewards_2", true)
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/land_nest")
			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/spawn_rewards", "rewards_loop")
        end,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("rewards_loop")
		end,
    },

    State{
        name = "no_rewards",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("win_"..inst.sg.mem.landing_bucket.."_pst", false)
        end,
    },

    State{
        name = "turn_off",
		tags = {"off"},
        onenter = function(inst)
			inst.AnimState:PushAnimation("turn_off", false) -- lets the current animation finish
			inst.AnimState:PushAnimation("idle_off", false)

			inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/endbell")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle_off") end),
        },
    },

}

local test_scores = nil --{{}, {}, {}} -- assign this to nil to {{}, {}, {}} to enable checking of the scores
local test_score_marker = TimeEvent(1, function() end)
local test_score_function = function() return test_score_marker end

local function AddPlayState(states, door_number, game_number, landing_bucket, timeline)
	table.insert(states, State{
        name = "play_door"..door_number.."_game"..game_number,

        onenter = function(inst)
			inst.sg.mem.landing_bucket = landing_bucket
            inst.AnimState:PlayAnimation("play_door"..door_number.."_game"..game_number, false)
        end,

        timeline = timeline,

        events =
        {
            EventHandler("animover", function(inst)
				if inst.components.minigame:GetIsPlaying() then
					inst:FlagGameComplete()
				end
			end),
        },
    })

	if test_scores ~= nil then
		test_scores[door_number][game_number] = 0
	
		-- side = x1, nest = x2
		for k, v in pairs(timeline) do
			if v == test_score_marker then
				test_scores[door_number][game_number] = test_scores[door_number][game_number] + 1
			end
		end
		if landing_bucket == LANDING_CENTER then
			test_scores[door_number][game_number] = test_scores[door_number][game_number] * 2
		end
	end
end


local HitBumpper = function(frame)		return TimeEvent((frame - 1) * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/hit_bumper") inst._minigame_score = inst._minigame_score + 1 inst.components.minigame:RecordExcitement() end) end
local function HitRubberBand(frame)		return TimeEvent((frame - 1) * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/hit_rubberband") end) end
local function HitPeg(frame)			return TimeEvent((frame - 1) * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/hit_peg") end) end
local function HitFrame(frame)			return TimeEvent((frame - 1) * FRAMES, function(inst) inst.SoundEmitter:PlaySound("summerevent2022/carnivalgame_puckdrop/hit_frame") end) end
local function HitLand(frame)			return TimeEvent((frame - 1) * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sg.mem.landing_bucket == LANDING_CENTER and "summerevent2022/carnivalgame_puckdrop/hit_frame" or "summerevent2022/carnivalgame_puckdrop/hit_frame") end) end

if test_scores ~= nil then
	HitBumpper = test_score_function
end


------------------------------------------------------------------------------------------------------------------
--													DOOR 1
AddPlayState(states, 1, 1, LANDING_LEFT,
{
	HitBumpper(12),
	HitRubberBand(14),
	HitFrame(22),
	HitBumpper(27),
	HitBumpper(41),
	HitBumpper(50),
	HitBumpper(52),
	HitBumpper(54),
	HitBumpper(56),
	HitBumpper(58),
	HitBumpper(60),
	HitBumpper(62),
	HitBumpper(64),
	HitRubberBand(67),
	HitRubberBand(74),
	HitBumpper(78),

	HitLand(83),
})

AddPlayState(states, 1, 2, LANDING_LEFT,
{
	HitFrame(12),
	HitPeg(25),
	HitPeg(37),

	HitLand(53),
})

AddPlayState(states, 1, 3, LANDING_CENTER,
{
	HitFrame(12),
	HitPeg(20),
	HitRubberBand(24),
	HitRubberBand(28),
	HitPeg(35),
	HitPeg(44),

	HitLand(65),
})

AddPlayState(states, 1, 4, LANDING_RIGHT,
{
	HitBumpper(9),
	HitBumpper(23),
	HitRubberBand(27),
	HitBumpper(32),
	HitBumpper(46),
	HitBumpper(56),
	HitFrame(70),
	HitFrame(79),
	HitRubberBand(87),
	HitBumpper(91),
	HitPeg(95),
	HitPeg(97),

	HitLand(102),
})

AddPlayState(states, 1, 5, LANDING_CENTER,
{
	HitBumpper(9),
	HitBumpper(23),
	HitBumpper(31),
	HitBumpper(35),
	HitBumpper(37),
	HitRubberBand(39),
	HitBumpper(43),
	HitBumpper(45),
	HitBumpper(47),
	HitBumpper(49),
	HitBumpper(51),
	HitBumpper(53),
	HitBumpper(55),
	HitBumpper(57),
	HitBumpper(59),
	HitBumpper(61),
	HitBumpper(63),
	HitBumpper(65),
	HitBumpper(67),
	HitBumpper(69),
	HitPeg(75),
	HitPeg(87),
	HitLand(96),
})

------------------------------------------------------------------------------------------------------------------
--													DOOR 2
AddPlayState(states, 2, 1, LANDING_RIGHT,
{
	HitPeg(8),
	HitRubberBand(14),
	HitFrame(18),
	HitBumpper(22),
	HitFrame(33),
	HitRubberBand(45),
	HitBumpper(48),
	HitRubberBand(50),
	HitBumpper(69),
	HitBumpper(71),
	HitBumpper(73),
	HitBumpper(75),
	HitBumpper(77),
	HitBumpper(80),

	HitLand(84),
})

AddPlayState(states, 2, 2, LANDING_CENTER,
{
	HitPeg(9),
	HitBumpper(20),
	HitBumpper(31),
	HitBumpper(44),
	HitFrame(56),
	HitBumpper(58),
	HitFrame(59),
	HitPeg(65),
	HitBumpper(68),
	HitPeg(70),
	HitBumpper(74),
	HitRubberBand(76),
	HitBumpper(79),
	HitRubberBand(82),
	HitBumpper(85),
	HitRubberBand(88),
	HitRubberBand(93),
	HitBumpper(96),
	HitPeg(99),
	HitPeg(110),

	HitLand(158),
})

AddPlayState(states, 2, 3, LANDING_RIGHT,
{
	HitPeg(9),
	HitBumpper(20),
	HitBumpper(31),
	HitBumpper(44),
	HitFrame(56),
	HitBumpper(58),
	HitFrame(59),
	HitPeg(65),
	HitBumpper(68),
	HitPeg(70),
	HitBumpper(74),
	HitRubberBand(76),
	HitBumpper(79),
	HitRubberBand(82),
	HitBumpper(85),
	HitRubberBand(88),
	HitRubberBand(93),
	HitBumpper(96),
	HitPeg(99),
	HitPeg(110),

	HitLand(150),
})

AddPlayState(states, 2, 4, LANDING_LEFT,
{
	HitRubberBand(10),
	HitBumpper(20),
	HitBumpper(23),
	HitBumpper(25),
	HitBumpper(27),
	HitFrame(29),
	HitFrame(41),

	HitLand(49),
})

AddPlayState(states, 2, 5, LANDING_RIGHT,
{
	HitPeg(9),
	HitPeg(24),
	HitRubberBand(37),
	HitBumpper(40),
	HitBumpper(44),
	HitBumpper(46),
	HitBumpper(48),
	HitBumpper(50),
	HitFrame(54),
	HitRubberBand(67),
	HitBumpper(71),

	HitLand(75),
})

------------------------------------------------------------------------------------------------------------------
--													DOOR 3
AddPlayState(states, 3, 1, LANDING_LEFT,
{
	HitBumpper(14),
	HitRubberBand(17),
	HitFrame(23),
	HitBumpper(29),
	HitBumpper(43),
	HitPeg(44),
	HitBumpper(48),
	HitBumpper(50),
	HitBumpper(52),
	HitBumpper(54),
	HitBumpper(56),
	HitBumpper(58),
	HitBumpper(60),
	HitBumpper(62),
	HitRubberBand(66),
	HitRubberBand(74),
	HitBumpper(76),

	HitLand(80),
})

AddPlayState(states, 3, 2, LANDING_CENTER,
{
	HitBumpper(10),
	HitFrame(21),
	HitPeg(34),
	HitPeg(46),

	HitLand(69),
})

AddPlayState(states, 3, 3, LANDING_CENTER,
{
	HitBumpper(12),
	HitBumpper(28),
	HitFrame(43),
	HitRubberBand(49),
	HitBumpper(53),
	HitPeg(56),

	HitLand(79),
})

AddPlayState(states, 3, 4, LANDING_CENTER,
{
	HitBumpper(9),
	HitBumpper(23),
	HitRubberBand(27),
	HitBumpper(32),
	HitBumpper(46),
	HitBumpper(56),
	HitFrame(69),
	HitFrame(79),
	HitRubberBand(88),
	HitBumpper(90),

	HitLand(94),
})

AddPlayState(states, 3, 5, LANDING_RIGHT,
{
	HitBumpper(9),
	HitBumpper(23),
	HitBumpper(33),
	HitBumpper(42),
	HitBumpper(45),
	HitBumpper(47),
	HitRubberBand(50),
	HitBumpper(53),
	HitBumpper(55),
	HitBumpper(57),
	HitBumpper(59),
	HitBumpper(61),
	HitBumpper(63),
	HitBumpper(65),
	HitBumpper(67),
	HitPeg(73),
	HitPeg(84),

	HitLand(93),
})

function PrintTestScores()
	if test_scores == nil then
		return 
	end

	local totoal_score = 0
	local totoal_wins = 0
	local totoal_plays = 0
	for door_num, games in ipairs(test_scores) do
		local num_wins = 0
		local door_score = 0
		for game_num, score in ipairs(games) do
			door_score = door_score + score

			totoal_plays = totoal_plays + 1
			if score > 0 then
				num_wins = num_wins + 1
			end
		end
		totoal_score = totoal_score + door_score
		totoal_wins = totoal_wins + num_wins
		print("Door "..door_num..": average = " .. door_score/#test_scores[door_num] .. ", num wins = " .. num_wins .."/".. #test_scores[door_num] .. ", total points = " .. door_score)
	end
	print("Total:  average = " .. totoal_score/totoal_plays .. ", num wins = " .. totoal_wins .."/".. totoal_plays .. ", total points = "..totoal_score)
	dumptable(test_scores)
end

return StateGraph("carnivalgame_puckdrop_station", states, {}, "idle_off")

