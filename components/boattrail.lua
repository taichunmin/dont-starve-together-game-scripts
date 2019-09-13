local function OnSleep(inst)
    local boat_trail = inst.components.boattrail
    inst:StopUpdatingComponent(boat_trail)
end

local function OnWake(inst)
    local boat_trail = inst.components.boattrail
    inst:StartUpdatingComponent(boat_trail)    
    local x, y, z = inst.Transform:GetWorldPosition()
    boat_trail.total_distance_traveled = 0
    boat_trail.last_x = x
    boat_trail.last_z = z    
end

local BoatTrail = Class(function(self, inst)
    self.inst = inst

    self.anim_idx = 0 -- zero based index

    inst:ListenForEvent("entitysleep", OnSleep)
    inst:ListenForEvent("entitywake", OnWake)
end)

local ANIMS = { "idle_loop_1", "idle_loop_2", "idle_loop_3" }

function BoatTrail:SpawnEffectPrefab(x, y, z, dir_x, dir_z)
    local fx = SpawnPrefab("boat_water_fx")

    local radius = 3
    fx.Transform:SetPosition(x - dir_x * radius, y, z - dir_z * radius)         

	self.anim_idx = (self.anim_idx + (math.random() > 0.5 and 1 or -1)) % #ANIMS
    fx.AnimState:PlayAnimation(ANIMS[self.anim_idx + 1])

    if fx.components.boattrailmover ~= nil then
	    fx.components.boattrailmover:Setup(dir_x, dir_z, 0.5, -0.125)
	end
end

function BoatTrail:OnUpdate(dt)
    local total_distance_traveled = self.total_distance_traveled
    local x, y, z = self.inst.Transform:GetWorldPosition()
    
    if not total_distance_traveled then
        self.last_x, self.last_z = x, z
        self.total_distance_traveled = 0
        return
    end

    local effect_spawn_rate = 1.0
    local dir_x, dir_z = x - self.last_x, z - self.last_z
    local distance_traveled = VecUtil_Length(dir_x, dir_z)
    distance_traveled = math.min(effect_spawn_rate, distance_traveled)

    total_distance_traveled = total_distance_traveled + distance_traveled

    dir_x, dir_z = VecUtil_Normalize(dir_x, dir_z)

    local angle_apart = 30

    if total_distance_traveled > effect_spawn_rate then   
        self:SpawnEffectPrefab(x, y, z, dir_x, dir_z)

        total_distance_traveled = total_distance_traveled - effect_spawn_rate
    end        

    self.total_distance_traveled = total_distance_traveled

    self.last_x = x
    self.last_z = z
    self.last_dir_x = dir_x
    self.last_dir_z = dir_z

end

return BoatTrail
