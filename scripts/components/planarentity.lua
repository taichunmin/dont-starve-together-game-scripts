local PlanarEntity = Class(function(self, inst)
	self.inst = inst
end)

function PlanarEntity:AbsorbDamage(damage, attacker, weapon, spdmg)
	damage = (math.sqrt(damage * 4 + 64) - 8) * 4
	if spdmg == nil or spdmg.planar == nil then
		self:OnResistNonPlanarAttack(attacker)
	end
	return damage, spdmg
end

function PlanarEntity:OnResistNonPlanarAttack(attacker)
	local fx = SpawnPrefab("planar_resist_fx")
	local radius = self.inst:GetPhysicsRadius(0) + .2 + math.random() * .5
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local theta
	if attacker ~= nil then
		local x1, y1, z1 = attacker.Transform:GetWorldPosition()
		if x ~= x1 or z ~= z1 then
			theta = math.atan2(z - z1, x1 - x) + math.random() * 2 - 1
		end
	end
	if theta == nil then
		theta = math.random() * TWOPI
	end
	fx.Transform:SetPosition(
		x + radius * math.cos(theta),
		math.random(),
		z - radius * math.sin(theta)
	)
end

function PlanarEntity:OnPlanarAttackUndefended(target)
	SpawnPrefab("planar_hit_fx").entity:SetParent(target.entity)
end

return PlanarEntity
