local GymStates = {}

local function getfull(inst)
    local full =""
   
    if inst.components.mightiness:GetPercent() >= 1 then
        full = "_full"
    end

    return full
end

local function exitgym(inst)
    local gym = inst.components.strongman.gym 
    if gym then
        gym.components.mightygym:CharacterExitGym(inst)
    end
end

GymStates.AddGymStates = function(states, actionhandlers, events)
    table.insert(actionhandlers, ActionHandler(ACTIONS.ENTER_GYM, "give") )

    table.insert(actionhandlers, ActionHandler(ACTIONS.LIFT_GYM_SUCCEED_PERFECT, function(inst)  
        --print("handler LIFT_GYM_SUCCEED_PERFECT") 
		if inst.components.strongman.gym ~= nil and inst.components.strongman.gym:IsValid() then
			inst.sg.statemem.dontleavegym = true 
			return "mighty_gym_success_perfect" 
		end
		return nil
    end) )
    table.insert(actionhandlers, ActionHandler(ACTIONS.LIFT_GYM_SUCCEED, function(inst)         
        -- print("handler LIFT_GYM_SUCCEED") 
		if inst.components.strongman.gym ~= nil and inst.components.strongman.gym:IsValid() then
			inst.sg.statemem.dontleavegym = true 
			return "mighty_gym_success" 
		end
		return nil
    end) )
    table.insert(actionhandlers, ActionHandler(ACTIONS.LIFT_GYM_FAIL, function(inst)            
        --print("handler LIFT_GYM_FAIL") 
		if inst.components.strongman.gym ~= nil and inst.components.strongman.gym:IsValid() then
			inst.sg.statemem.dontleavegym = true 
			return "mighty_gym_workout_fail" 
		end
		return nil
    end) )

    table.insert(states, State{
        name = "workout_gym",
        tags = { "gym", "busy", "silentmorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("pickup")
            inst.sg:SetTimeout(6 * FRAMES)
        end,

        ontimeout = function(inst)
            inst:PerformBufferedAction()
        end,
    })

    table.insert(states, State{
        name = "mighty_gym_active_pre",
        onenter = function(inst, norestart)
            inst.sg.statemem.norestart = norestart 

            inst.AnimState:PlayAnimation("mighty_gym_active_pre"..getfull(inst))
        end,

        events = 
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.dontleavegym = true
                inst.sg:GoToState("mighty_gym_workout_loop")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.norestart then
                inst.ResetBell(inst)
            end
            if not inst.sg.statemem.dontleavegym then
                exitgym(inst)
            end
        end,

    })

    table.insert(states, State{
        name = "mighty_gym_workout_loop",
        onenter = function(inst)
			if not inst:IsInLight() then
               exitgym(inst)
			else
				inst.AnimState:PlayAnimation("mighty_gym_active_loop"..getfull(inst))

				if not inst.SoundEmitter:PlayingSound("workout_LP") then
					inst.SoundEmitter:PlaySound("wolfgang2/common/gym/working_LP","workout_LP") 
				end

				inst.player_classified.gym_bell_start:push()
			end
        end,

        events = 
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.dontleavegym = true
                inst.sg:GoToState("mighty_gym_workout_loop")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.dontleavegym then
               exitgym(inst)
            end
        end,
    })

    table.insert(states, State{
        name = "mighty_gym_success_perfect",
        tags = { "busy" },
        onenter = function(inst,data)
            local gym = inst.components.strongman.gym
            local old = inst.components.mightiness:GetState()
            local oldpercent = inst.components.mightiness:GetPercent()
            inst.components.mightiness:DoDelta(gym.components.mightygym:CalculateMightiness(true), true, nil, true, true)
            local newpercent = inst.components.mightiness:GetPercent() 

            local change = ""
            if newpercent >= 1 then
                if newpercent == oldpercent then
                    change = "_full"
                else
                    change = "_full_pre"
                end
            end       
            if inst.components.mightiness:GetState() ~= old then
                change = "_change"
            end                
            inst.AnimState:PlayAnimation("lift_pre")
            inst.AnimState:PushAnimation("mighty_gym_success_big"..change, false)

            inst.SoundEmitter:PlaySound("wolfgang2/common/gym/success")

            inst:PerformBufferedAction()
        end,

        events = 
        {
            EventHandler("animqueueover", function(inst)
                --if inst.components.mightiness:GetPercent() == 1 then
                --    print(inst.components.mightiness:GetCurrent(), inst.components.mightiness:GetMax(),inst.components.mightiness:GetOverMax())
                if inst.components.mightiness:GetCurrent() >= inst.components.mightiness:GetMax() + inst.components.mightiness:GetOverMax() then 
                    exitgym(inst)
                else
                    inst.sg.statemem.dontleavegym = true
                    inst.sg:GoToState("mighty_gym_workout_loop")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.dontleavegym then
              exitgym(inst)
            end
        end,
    })

    table.insert(states, State{
        name = "mighty_gym_success",
        tags = { "busy" },
        onenter = function(inst,data)
            local gym = inst.components.strongman.gym    
            local old = inst.components.mightiness:GetState()
            local oldpercent = inst.components.mightiness:GetPercent()
            inst.components.mightiness:DoDelta(gym.components.mightygym:CalculateMightiness(false), true, nil, true, true)
            local newpercent = inst.components.mightiness:GetPercent() 

            local change = ""
            if newpercent >= 1 then
                if newpercent == oldpercent then
                    change = "_full"
                else
                    change = "_full_pre"
                end
            end
            if inst.components.mightiness:GetState() ~= old then
                change = "_change"
            end
            inst.AnimState:PlayAnimation("lift_pre")
            inst.AnimState:PushAnimation("mighty_gym_success_normal"..change, false)

            inst.SoundEmitter:PlaySound("wolfgang2/common/gym/success")

            inst:PerformBufferedAction()
        end,

        events = 
        {
            EventHandler("animqueueover", function(inst)
                --if inst.components.mightiness:GetPercent() == 1 then
                --         print(inst.components.mightiness:GetCurrent(), inst.components.mightiness:GetMax(),inst.components.mightiness:GetOverMax())
                if inst.components.mightiness:GetCurrent() >= inst.components.mightiness:GetMax() + inst.components.mightiness:GetOverMax() then 
                    exitgym(inst)
                else                
                    inst.sg.statemem.dontleavegym = true
                    inst.sg:GoToState("mighty_gym_workout_loop")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.dontleavegym then
              exitgym(inst)
            end
        end,

    })

    table.insert(states, State{
        name = "mighty_gym_workout_fail",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("lift_pre")
            inst.AnimState:PushAnimation("mighty_gym_fail"..getfull(inst), false)

            inst.SoundEmitter:KillSound("workout_LP")

            inst:PerformBufferedAction()
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wolfgang2/common/gym/fail") end),
        },

        events = 
        {
            EventHandler("animqueueover", function(inst)
                inst.sg.statemem.dontleavegym = true 
                inst.sg:GoToState("mighty_gym_active_pre", true)
            end)
        },

        onexit = function(inst)
            if not inst.sg.statemem.dontleavegym then
                exitgym(inst)
            end
        end,
    })
end

return GymStates