require("class")

EmitterManagerClass = Class( function(self)
	self.awakeEmitters =
	{
		limitedLifetimes = {},
		infiniteLifetimes = {},
	}
	self.sleepingEmitters =
	{
		limitedLifetimes = {},
		infiniteLifetimes = {},
	}
end)

function EmitterManagerClass:AddEmitter( inst, lifetime, updateFunc )
	inst.emitter = inst
	local statusTable = self.awakeEmitters
	if not inst.entity:IsAwake() then
		statusTable = self.sleepingEmitters
	end

	local destinationTable = statusTable.limitedLifetimes
	if lifetime == nil then
		destinationTable = statusTable.infiniteLifetimes
	end

	destinationTable[ inst ] = { lifetime = lifetime, updateFunc = updateFunc }

    inst:ListenForEvent( "onremove", function() self:RemoveEmitter(inst)  end, inst )
end


function EmitterManagerClass:RemoveEmitter(inst)
    self.awakeEmitters.limitedLifetimes[inst] = nil
    self.awakeEmitters.infiniteLifetimes[inst] = nil

    self.sleepingEmitters.limitedLifetimes[inst] = nil
    self.sleepingEmitters.infiniteLifetimes[inst] = nil
end

function EmitterManagerClass:PostUpdate()
	if TheNet:IsServerPaused() or global_error_widget ~= nil then
		return
	end

	local ticktime = TheSim:GetTickTime()

	-- AWAKE --
	for inst, data in pairs( self.awakeEmitters.limitedLifetimes ) do
		print( data )
		if data.lifetime <= 0 then
			inst:Remove()
			self.awakeEmitters.limitedLifetimes[ inst ] = nil
		else
			data.updateFunc()
		end

		data.lifetime = data.lifetime - ticktime
	end

	for inst, data in pairs( self.awakeEmitters.infiniteLifetimes ) do
		data.updateFunc()
	end

	-- SLEEPING --
	for inst, data in pairs( self.sleepingEmitters.limitedLifetimes ) do
		if data.lifetime <= 0 then
			inst:Remove()
			self.sleepingEmitters.limitedLifetimes[ inst ] = nil
		end

		data.lifetime = data.lifetime - ticktime
	end
end

function EmitterManagerClass:Hibernate( inst )
	if self.awakeEmitters.limitedLifetimes[ inst ] then
		self.sleepingEmitters.limitedLifetimes[ inst ] = self.awakeEmitters.limitedLifetimes[ inst ]
		self.awakeEmitters.limitedLifetimes[ inst ] = nil
	elseif self.awakeEmitters.infiniteLifetimes[ inst ] then
		self.sleepingEmitters.infiniteLifetimes[ inst ] = self.awakeEmitters.infiniteLifetimes[ inst ]
		self.awakeEmitters.infiniteLifetimes[ inst ] = nil
	end
end

function EmitterManagerClass:Wake( inst )
	if self.sleepingEmitters.limitedLifetimes[ inst ] then
		self.awakeEmitters.limitedLifetimes[ inst ] = self.sleepingEmitters.limitedLifetimes[ inst ]
		self.sleepingEmitters.limitedLifetimes[ inst ] = nil
	elseif self.sleepingEmitters.infiniteLifetimes[ inst ] then
		self.awakeEmitters.infiniteLifetimes[ inst ] = self.sleepingEmitters.infiniteLifetimes[ inst ]
		self.sleepingEmitters.infiniteLifetimes[ inst ] = nil
	end
end

EmitterManager = EmitterManagerClass()

--------------------------------------------------------------------------

function UnitRand()
	return math.random() * 2.0 - 1.0
end

function CreateDiscEmitter( radius )
	return function()
		return UnitRand() * radius, UnitRand() * radius
	end
end

function CreateCircleEmitter( radius )
	local sqrt = math.sqrt
	local rand = math.random
	local sin = math.sin
	local cos = math.cos

    return function()
        local point_rand = radius * sqrt(rand())
        local angle_rand = PI2 * rand()
        return point_rand * cos(angle_rand),
            point_rand * sin(angle_rand)
    end
end

function CreateRingEmitter( radius )
	local sqrt = math.sqrt

	return function()
		local x = UnitRand() * radius
		local y = sqrt( radius * radius - x * x )
		if UnitRand() <= 0 then
			y = -y
		end

		return x, y
	end
end

-- Emits on the surface of the sphere
function CreateSphereEmitter( radius )
	local sqrt = math.sqrt
	local rand = math.random
	local sin = math.sin
	local cos = math.cos

	return function()
		local z = 2.0 * rand() - 1.0
		local t = 2.0 * PI * rand()
		local w = sqrt( 1.0 - z * z )
		local x = w * cos( t )
		local y = w * sin( t )

		return radius * x, radius * y, radius * z
	end
end

-- NOTE from gjans: These params don't make much sense, because UnitRand is [-1,1]. So the min/max
-- behave kinda more like center/halfwidth, but not really. I'm not changing it now though.
function CreateBoxEmitter( x_min, y_min, z_min, x_max, y_max, z_max )
	local dx = x_max - x_min
	local dy = y_max - y_min
	local dz = z_max - z_min

	return function()
		return x_min + dx * UnitRand(), y_min + dy * UnitRand(), z_min + dz * UnitRand()
	end
end

function CreateAreaEmitter(polygon, centroid)

	return function()
		local p1_idx = math.random(1, #polygon)
		local p2_idx = p1_idx + 1
		if p2_idx > #polygon then
			p2_idx = 1
		end

		local v0 = { x = polygon[p1_idx][1] - centroid[1], y = polygon[p1_idx][2] - centroid[2]}
		local v2 = { x = polygon[p2_idx][1] - centroid[1], y = polygon[p2_idx][2] - centroid[2]}

		-- u = random [0-1]
		local u = math.random()

		-- v = random [0-1]
		local v =  math.random()

		-- u+v < 1
		if u + v > 1 then
			u = 1-u
			v = 1-v
		end

		-- P = centroid + u*v0 + v*v2
		--local p = {centroid[1] + v0.x*u + v2.x*v, centroid[2] + v0.y*u + v2.y*v}
		-- The consumer of this is expecting relative positions
		return  v0.x*u + v2.x*v, v0.y*u + v2.y*v
	end
end

function Create2DTriEmitter(tris, scale)
	return function(camera_right, camera_up)
		local tri = tris[math.random(1, #tris)]
		-- u = random [0-1]
		local u = math.random()
		local u_sqrt = math.sqrt(u)
		-- v = random [0-1]
		local v =  math.random()

		local inverted_u_sqrt = 1 - u_sqrt
		local u_sqrt_x_inverted_v = u_sqrt * (1 - v)
		local u_sqrt_x_v = u_sqrt * v

		local x = inverted_u_sqrt * tri[1].x + u_sqrt_x_inverted_v * tri[2].x + u_sqrt_x_v * tri[3].x
		local y = inverted_u_sqrt * tri[1].y + u_sqrt_x_inverted_v * tri[2].y + u_sqrt_x_v * tri[3].y

		return (((camera_right * -x) + (camera_up * -y)) * scale):Get()
	end
end
