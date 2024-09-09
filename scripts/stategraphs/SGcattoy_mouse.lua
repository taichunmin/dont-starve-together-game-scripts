local events =
{
    CommonHandlers.OnLocomote(true, false),
}

local states = {}

CommonStates.AddSimpleState(states, "idle", "idle", {"idle"})

CommonStates.AddRunStates(states, nil,
{
    startrun = "run_pre2",
}, nil, nil,
{
    startonenter = function(inst)
        inst.SoundEmitter:PlaySound("summerevent/carnival_games/herding_station/chicks/LP", "active_loop")
    end,
    endonenter = function(inst)
        inst.SoundEmitter:KillSound("active_loop")
    end,
})

return StateGraph("cattoy_mouse", states, events, "idle")
