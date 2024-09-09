local function AddWorldEntities(savedata)
	-- NOTES(JBK): Inject unique entities that must exist for all worlds and shards here before they get instantiated.
	-- There is no checking inherently made here for if an entity already exists you will have to do this yourself.
	local enttable = savedata.ents

	-- Pocket dimension containers, one of each type per world is expected.
	local POCKETDIMENSIONCONTAINER_DEFS = require("prefabs/pocketdimensioncontainer_defs").POCKETDIMENSIONCONTAINER_DEFS
	for _, v in ipairs(POCKETDIMENSIONCONTAINER_DEFS) do
		local prefab = v.prefab
		local ents = enttable[prefab]
		if GetTableSize(ents) == 0 then
			enttable[prefab] = {{x=0,z=0}} -- Position data for the save to go through.
		end
	end
end

return { AddWorldEntities = AddWorldEntities, }