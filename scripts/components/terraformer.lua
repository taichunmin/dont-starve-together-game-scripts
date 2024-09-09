local GroundTiles = require("worldtiledefs")

local Terraformer = Class(function(self, inst)
    self.inst = inst

	--self.nospawnturf = false
	--self.turf = WORLD_TILES.DIRT
	--self.onterraformfn
	--self.plow
end)

function Terraformer:Terraform(pt, doer)
    local world = TheWorld
    local map = world.Map
	local _x, _y, _z = pt:Get()
	if (self.plow and not map:CanPlowAtPoint(_x, _y, _z)) or
		(not self.plow and not map:CanTerraformAtPoint(_x, _y, _z)) then
        return false
    end

    local original_tile_type = map:GetTileAtPoint(_x, _y, _z)
    local x, y = map:GetTileCoordsAtPoint(_x, _y, _z)

	local turf = self.turf or TheWorld.components.undertile:GetTileUnderneath(x, y) or WORLD_TILES.DIRT

    map:SetTile(x, y, turf)

	if self.onterraformfn ~= nil then
		self.onterraformfn(self.inst, pt, original_tile_type, GroundTiles.turf[original_tile_type])
	else
		HandleDugGround(original_tile_type, _x, _y, _z)
	end

	if not self.plow then
		for _, ent in ipairs(TheWorld.Map:GetEntitiesOnTileAtPoint(_x, _y, _z)) do
			if ent:HasTag("soil") then
				ent:PushEvent("collapsesoil")
			end
		end
	end

	self.inst:PushEvent("onterraform")
	if doer ~= nil then
		doer:PushEvent("onterraform") -- NOTES(JBK): This is for Wolfgang.
	end

    return true
end

return Terraformer
