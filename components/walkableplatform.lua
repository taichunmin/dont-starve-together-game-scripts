local WalkablePlatform = Class(function(self, inst)
    self.inst = inst

    self.players_on_platform = {}
    self.objects_on_platform = {}
    self.platform_radius = 4

    self.inst:AddTag("walkableplatform")

    if TheWorld.ismastersim then
        self.inst:DoTaskInTime(0, function() self:SpawnPlayerCollision() end)
        self:StartUpdating()
    end
end)

function WalkablePlatform:OnRemoveEntity()
    if TheWorld.ismastersim then
        self:StopUpdating()
        self:DespawnPlayerCollision()

        local shore_pt
        for k in pairs(self:GetEntitiesOnPlatform()) do
            if k.components.drownable ~= nil then
                if shore_pt == nil then
                    shore_pt = Vector3(FindRandomPointOnShoreFromOcean(self.inst.Transform:GetWorldPosition()))
                end
                k:PushEvent("onsink", {boat = self.inst, shore_pt = shore_pt})
            else
                k:PushEvent("onsink", {boat = self.inst})
            end
        end
        self.inst:PushEvent("onsink")
        self:DestroyObjectsOnPlatform()

        for k in pairs(self.objects_on_platform) do
            self.inst:RemovePlatformFollower(k)
        end

        if self.uid then
            TheWorld.components.walkableplatformmanager:UnregisterPlatform(self.inst)
        end
    end
end

function WalkablePlatform:GetUID()
    if not self.uid then
        TheWorld.components.walkableplatformmanager:RegisterPlatform(self.inst)
    end
    return self.uid
end

function WalkablePlatform:OnSave()
    return self.uid ~= nil and { uid = self.uid } or nil
end

function WalkablePlatform:OnLoad(data)
    self.uid = data.uid or nil
    TheWorld.components.walkableplatformmanager:RegisterPlatform(self.inst)
end

function WalkablePlatform:StartUpdating()
    TheWorld.components.walkableplatformmanager:AddPlatform(self.inst)
end

function WalkablePlatform:StopUpdating()
    TheWorld.components.walkableplatformmanager:RemovePlatform(self.inst)
end

local IGNORE_WALKABLE_PLATFORM_TAGS_ON_REMOVE = { "ignorewalkableplatforms", "ignorewalkableplatformdrowning", "activeprojectile", "flying", "FX", "DECOR", "INLIMBO", "player" }
local IGNORE_WALKABLE_PLATFORM_TAGS = { "ignorewalkableplatforms", "activeprojectile", "flying", "FX", "DECOR", "INLIMBO", "herd" }

function WalkablePlatform:DestroyObjectsOnPlatform()
    if not TheWorld.ismastersim then return end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, self.platform_radius, nil, IGNORE_WALKABLE_PLATFORM_TAGS_ON_REMOVE)) do
        if v ~= self.inst and v.entity:GetParent() == nil and v.components.amphibiouscreature == nil and v.components.drownable == nil then
            if v.components.inventoryitem ~= nil then
                v.components.inventoryitem:SetLanded(false, true)
            else
                DestroyEntity(v, self.inst, true, true)
            end
        end
    end
end

function WalkablePlatform:GetEntitiesOnPlatform()
    return self.objects_on_platform
end

function WalkablePlatform:GetPlayersOnPlatform()
    return self.players_on_platform
end

function WalkablePlatform:AddPlayerOnPlatform(player)
    self.players_on_platform[player] = player
end

function WalkablePlatform:RemovePlayerOnPlatform(player)
    self.players_on_platform[player] = nil
end

function WalkablePlatform:GetEmbarkPosition(embarker_x, embarker_z, embarker_min_dist)
    local embark_distance_from_edge = 0.5
    local embarkable_radius = self.platform_radius - embark_distance_from_edge - (embarker_min_dist ~= nil and embarker_min_dist or 0)
    local embarkable_x, embarkable_y, embarkable_z = self.inst.Transform:GetWorldPosition()
    local embark_x, embark_z = VecUtil_Normalize(embarker_x - embarkable_x, embarker_z - embarkable_z)
    return embarkable_x + embark_x * embarkable_radius, embarkable_z + embark_z * embarkable_radius
end

function WalkablePlatform:AddEntityToPlatform(ent)
    if ent.entity:GetParent() == nil then
        if not self.objects_on_platform[ent] then
            self.inst:AddPlatformFollower(ent)
        else
            self.objects_on_platform[ent] = true
        end
    end
end

--server only.
function WalkablePlatform:SetEntitiesOnPlatform()
    local new_objects_on_platform = {}
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local entities = TheSim:FindEntities(x, y, z, self.platform_radius, nil, IGNORE_WALKABLE_PLATFORM_TAGS)
    for i, v in ipairs(entities) do
        if v ~= self.inst and v.entity:GetParent() == nil then
            new_objects_on_platform[v] = true
            if self.objects_on_platform[v] then
                self.objects_on_platform[v] = nil
            else
                self.inst:AddPlatformFollower(v)
            end
        end
    end

    for k in pairs(self.objects_on_platform) do
        self.inst:RemovePlatformFollower(k)
    end

    self.objects_on_platform = new_objects_on_platform
end

function WalkablePlatform:SpawnPlayerCollision()
    if self.player_collision_prefab then
        self.player_collision = SpawnPrefab(self.player_collision_prefab)
        self.inst:AddPlatformFollower(self.player_collision)
        self.player_collision.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
        self.player_collision:ListenForEvent("onremove", function() self:DespawnPlayerCollision() end, self.inst)
    end
end

function WalkablePlatform:DespawnPlayerCollision()
    if self.player_collision then
        self.player_collision:Remove()
        self.player_collision = nil
    end
end

function WalkablePlatform:CommitPlayersOnPlatform()
    local has_players = not IsTableEmpty(self.players_on_platform)
    if self.had_players and not has_players then
        if self.inst.components.boatdrifter then
            self.inst.components.boatdrifter:OnStartDrifting()
        end
    elseif not self.had_players and has_players then
        if self.inst.components.boatdrifter then
            self.inst.components.boatdrifter:OnStopDrifting()
        end
    end
    self.had_players = has_players
end

return WalkablePlatform