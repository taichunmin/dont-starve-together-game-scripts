--------------------------------------------------------------------------
--[[ worldmeteorshower class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "worldmeteorshower should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _moonrockshell_chance = 0

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SpawnMeteorLoot(prefab)
	if prefab == "rock_moon" and _moonrockshell_chance < 1 then
		_moonrockshell_chance = _moonrockshell_chance + TUNING.MOONROCKSHELL_CHANCE

		if _moonrockshell_chance >= 1 or TheWorld.state.cycles >= 60 or math.random() <= _moonrockshell_chance then
			_moonrockshell_chance = 1
			return SpawnPrefab("rock_moon_shell")
		end
	end
	return SpawnPrefab(prefab)
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    return
    {
        moonrockshell_chance = _moonrockshell_chance,
    }
end

function self:OnLoad(data)
    _moonrockshell_chance = data.moonrockshell_chance or 0
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
