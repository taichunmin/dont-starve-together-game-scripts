local function OnSleep(inst)
    inst:StopUpdatingComponent(inst.components.boattrail)
end

local function OnWake(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local boat_trail = inst.components.boattrail
    boat_trail.total_distance_traveled = 0
    boat_trail.last_x = x
    boat_trail.last_z = z

    inst:StartUpdatingComponent(boat_trail)
end

local BoatTrail = Class(function(self, inst)
    self.inst = inst

    self.anim_idx = 0 -- zero based index
    self.effect_spawn_rate = 1
    self.radius = 3
    self.scale_x = 1
    self.scale_z = 1

    inst:ListenForEvent("entitysleep", OnSleep)
    inst:ListenForEvent("entitywake", OnWake)
end)

local ANIMS = { "idle_loop_1", "idle_loop_2", "idle_loop_3" }
function BoatTrail:SpawnEffectPrefab(x, y, z, dir_x, dir_z)
    local fx = SpawnPrefab("boat_water_fx")

    fx.Transform:SetPosition(x - dir_x * self.radius, y, z - dir_z * self.radius)
    fx.Transform:SetScale(self.scale_x, 1, self.scale_z)

    self.anim_idx = (self.anim_idx + (math.random() > 0.5 and 1 or -1)) % #ANIMS
    fx.AnimState:PlayAnimation(ANIMS[self.anim_idx + 1])

    if fx.components.boattrailmover ~= nil then
        fx.components.boattrailmover:Setup(dir_x, dir_z, 0.5, -0.125)
    end
end

function BoatTrail:OnUpdate(dt)
    local x, y, z = self.inst.Transform:GetWorldPosition()

    if not self.total_distance_traveled then
        self.last_x, self.last_z = x, z
        self.total_distance_traveled = 0
        return
    end

    local nx, nz, distance_traveled = VecUtil_NormalAndLength(x - self.last_x, z - self.last_z)

    local total_distance_traveled = self.total_distance_traveled + math.min(self.effect_spawn_rate, distance_traveled)

    if total_distance_traveled > self.effect_spawn_rate then
        self:SpawnEffectPrefab(x, y, z, nx, nz)

        total_distance_traveled = total_distance_traveled - self.effect_spawn_rate
    end

    self.total_distance_traveled = total_distance_traveled
    self.last_x = x
    self.last_z = z
    self.last_dir_x = nx
    self.last_dir_z = nz
end

return BoatTrail
