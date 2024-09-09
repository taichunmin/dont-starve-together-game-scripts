local chestfunctions = require("scenarios/chestfunctions")
local terrarium_loot = require("scenarios/chest_terrarium")

local function transform(ent, player)
    if ent.components.werebeast ~= nil and not ent.components.werebeast:IsInWereState() 
		and ent.components.health ~= nil and not ent.components.health:IsDead() then
		ent.components.werebeast:SetWere()
		if player ~= nil and player:IsValid() then
			ent.components.combat:SetTarget(player)
		end
	end
end

local function triggertrap(inst, scenariorunner, data)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 16, {"pig"}, {"werepig"})
	for i, ent in ipairs(ents) do
        if ent.components.werebeast ~= nil and not ent.components.werebeast:IsInWereState() then
			ent:DoTaskInTime(0.25 * (i-1) + 0.25 * math.random(), transform, data ~= nil and data.player or nil)
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
