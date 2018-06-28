local ret = {}
for i, v in pairs({
	"cravings",
    "delay",
    "dialog",
    "allplayersspawned",
    "endofmatch",
    "wait",
    "resetgame",
	"pushevent",
}) do
    table.insert(ret, Prefab("quagmirestage_"..v, function()
        return event_server_data("quagmire", "prefabs/quagmire_eventstages")[v.."fn"]()
    end))
end
return unpack(ret)
