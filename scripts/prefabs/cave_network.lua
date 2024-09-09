local MakeWorldNetwork = require("prefabs/world_network")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/world_network.lua"),
}

local function custom_postinit(inst)
    inst:AddComponent("caveweather")
    inst:AddComponent("quaker")
    inst:AddComponent("nightmareclock")

    inst.components.worldtemperature:SetTemperatureMod(TUNING.CAVES_TEMP_MULT, TUNING.CAVES_TEMP_LOCUS)
end

return MakeWorldNetwork("cave_network", nil, assets, custom_postinit)
