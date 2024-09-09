local ret = {}
for i, v in pairs({
    "attack",
    "delay",
    "dialog",
    "allplayersspawned",
    "wait",
    "endofround",
    "endofmatch",
    "resetgame",
    "goto",
    "blank",
    "startround",
}) do
    table.insert(ret, Prefab("lavaarenastage_"..v, function()
        return event_server_data("lavaarena", "prefabs/lavaarena_eventstages")[v.."fn"]()
    end))
end
return unpack(ret)
