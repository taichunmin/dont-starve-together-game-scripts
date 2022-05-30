local Emitter = Class(function(self, inst)
    self.inst = inst
	self.area_emitter = function() print("no emitter") end
	self.config = {}

	self.max_lifetime = 1
	self.ground_height = 1
	self.particles_per_tick = 1
	self.num_particles_to_emit = 1
	self.density_factor = 1

end)


function Emitter:Emit()
	--print("Emit()....")

	--just one of these should be set
	local effect = self.inst.VFXEffect
	local emitter = self.inst.ParticleEmitter --legacy

	if effect then
		effect:SetMaxNumParticles( 0, self.density_factor * self.config.max_num_particles)
	else
		emitter:SetMaxNumParticles( self.density_factor * self.config.max_num_particles)
	end

	local tick_time = TheSim:GetTickTime()

	local desired_particles_per_second = self.density_factor * 1 --/ max_lifetime
	local particles_per_tick = desired_particles_per_second * tick_time

	local emit_fn = function()
		--print("emit....")
		local vx, vy, vz = 0.01 * UnitRand(), 0, 0.01 * UnitRand()
		local lifetime = self.max_lifetime * ( 0.9 + UnitRand() * 0.1 )
		local px, pz

		local py = self.ground_height

		px, pz = self.area_emitter()
		--print("px", px, "py", py, "pz", pz, "lifetime", lifetime)


		if effect then
			effect:AddParticle(
				0,
				lifetime,			-- lifetime
				px, py, pz,			-- position
				vx, vy, vz			-- velocity
			)
		else
			emitter:AddParticle(
				lifetime,			-- lifetime
				px, py, pz,			-- position
				vx, vy, vz			-- velocity
			)
		end
		--print("emit.... complete")
	end

	local updateFunc = function()
		--print("emit updateFunc....", self.num_particles_to_emit)
		while self.num_particles_to_emit > 1 do
			emit_fn( effect or emitter )
			self.num_particles_to_emit = self.num_particles_to_emit - 1
		end

		self.num_particles_to_emit = self.num_particles_to_emit + self.particles_per_tick
		--print("emit updateFunc.... complete")
	end


	EmitterManager:AddEmitter( self.inst, nil, updateFunc )
	--print("Emit().... complete")
end

return Emitter