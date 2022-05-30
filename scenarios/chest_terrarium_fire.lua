local chestfunctions = require("scenarios/chestfunctions")
local terrarium_loot = require("scenarios/chest_terrarium")

local function triggertrap(inst, scenariorunner, data)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 6, {"flower"}, {"INLIMBO"})
	for _, ent in ipairs(ents) do
		if ent.prefab == "flower_evil" and ent.components.burnable ~= nil then
			ent.components.burnable:Ignite(true)
		end
	end
end

local function OnLoad(inst, scenariorunner)
    chestfunctions.InitializeChestTrap(inst, scenariorunner, triggertrap, 1.0)
end

return
{
    OnLoad = OnLoad,
	OnCreate = terrarium_loot.OnCreate,
    OnDestroy = chestfunctions.OnDestroy,
}
