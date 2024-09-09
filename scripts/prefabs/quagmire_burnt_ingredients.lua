local function fn()
    return event_server_data("quagmire", "prefabs/quagmire_burnt_ingredients").fn()
end

return Prefab("quagmire_burnt_ingredients", fn)
