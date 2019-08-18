-- Boat camera zoom config variables.
local ZOOM_STEP = 0.25
local ZOOM_TARGET = 5
local ZOOM_TIME = 4

local NUM_ZOOMS = ZOOM_TARGET / ZOOM_STEP
local ZOOM_TASK_PERIOD = ZOOM_TIME / NUM_ZOOMS

local function OnRemove(inst)
    TheWorld.components.walkableplatformmanager:RemovePlatform(inst)

    if TheWorld.ismastersim then
        local shore_pt
        for k,v in pairs(inst.components.walkableplatform:GetEntitiesOnPlatform()) do
            if v.components.drownable ~= nil then
                if shore_pt == nil then
                    shore_pt = Vector3(FindRandomPointOnShoreFromOcean(inst.Transform:GetWorldPosition()))
                end
	            v:PushEvent("onsink", {boat = inst, shore_pt = shore_pt})
            else
	            v:PushEvent("onsink", {boat = inst})
			end
        end
        inst:PushEvent("onsink")
    end    

    --Removing the tag should make it so that entities being destroyed 
    --No longer detect the platform
    inst:RemoveTag("walkableplatform")

    local self = inst.components.walkableplatform

    self:DestroyObjectsOnPlatform()

    for k,v in pairs(self.previous_objects_on_platform) do
        if k:IsValid() then
            k:PushEvent("got_off_platform", inst)
        end
    end          
end

local WalkablePlatform = Class(function(self, inst)
    self.inst = inst    

    self.inst:AddTag("walkableplatform")

    TheWorld.components.walkableplatformmanager:AddPlatform(inst)

    if not TheWorld.ismastersim then
        self.inst:StartUpdatingComponent(self)
    end

    self.inst:ListenForEvent("onremove", OnRemove)

    self.player_zoomed_out = false
    self.player_zoom_task = nil
    self.player_zooms = NUM_ZOOMS

    self.previous_objects_on_platform = {}
    self.new_objects_on_platform = {}
    self.platform_radius = 4
end)

local IGNORE_WALKABLE_PLATFORM_TAGS_ON_REMOVE = { "ignorewalkableplatforms", "flying", "FX", "DECOR", "INLIMBO", "player" }
local IGNORE_WALKABLE_PLATFORM_TAGS = { "ignorewalkableplatforms", "flying", "FX", "DECOR", "INLIMBO" }


--Client Only
function WalkablePlatform:OnUpdate(dt) 
    self:CollectEntitiesOnPlatform(false)
    self:TriggerEvents()
end

function WalkablePlatform:CanBeWalkedOn()
    return self.inst:HasTag("walkableplatform")
end

function WalkablePlatform:DestroyObjectsOnPlatform()
    if not TheWorld.ismastersim then return end

    for k,v in pairs(self:GetEntitiesOnPlatform(nil, IGNORE_WALKABLE_PLATFORM_TAGS_ON_REMOVE)) do
        if v:IsValid() and v.components.amphibiouscreature == nil then
            if v.components.inventoryitem ~= nil then
                v.components.inventoryitem:SetLanded(false, true)
            else
                DestroyEntity(v, self.inst, true, true)
            end
        end
    end
end

function WalkablePlatform:GetEntitiesOnPlatform(must_have_tags, ignore_tags)
    ignore_tags = ignore_tags or IGNORE_WALKABLE_PLATFORM_TAGS
    local world_position_x, world_position_y, world_position_z = self.inst.Transform:GetWorldPosition()
    local entities = TheSim:FindEntities(world_position_x, world_position_y, world_position_z, self.platform_radius, must_have_tags, ignore_tags)

    local filtered_entities = {}

    for k, v in pairs(entities) do
        if v ~= self.inst and v:IsValid() and v.entity:GetParent() == nil then
            table.insert(filtered_entities, v)
        end
    end

    return filtered_entities
end

function WalkablePlatform:GetEmbarkPosition(embarker_x, embarker_z)
    local embark_distance_from_edge = 0.5
    local embarkable_radius = self.radius - embark_distance_from_edge
    local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
    local embarkable_x, embarkable_y, embarkable_z = self.inst.Transform:GetWorldPosition()
    local embark_x, embark_z = VecUtil_Normalize(embarker_x - embarkable_x, embarker_z - embarkable_z)
    return embarkable_x + embark_x * embarkable_radius, embarkable_z + embark_z * embarkable_radius         
end

function WalkablePlatform:UpdatePositions()
	if self.previous_position_x == nil then
        self.previous_position_x, self.previous_position_y, self.previous_position_z = self.inst.Transform:GetWorldPosition()
		return
	end

    local is_master_sim = TheWorld.ismastersim

    local world_position_x, world_position_y, world_position_z = self.inst.Transform:GetWorldPosition()
	local delta_position_x, delta_position_z = VecUtil_Sub(world_position_x, world_position_z, self.previous_position_x, self.previous_position_z)

    local should_update_pos = VecUtil_LengthSq(delta_position_x, delta_position_z) > 0

    self:CollectEntitiesOnPlatform(true)

    for k, v in pairs(self.new_objects_on_platform) do
        if k:IsValid() then
            local is_client_player_with_prediction_enabled = ThePlayer == k and ThePlayer.components.locomotor
            if is_master_sim or is_client_player_with_prediction_enabled then

    		    local entity_position_x, entity_position_y, entity_position_z = k.Transform:GetWorldPosition()
                local new_entity_position_x, new_entity_position_z = VecUtil_Add(entity_position_x, entity_position_z, delta_position_x, delta_position_z)

                local physics = k.Physics
                if physics ~= nil then
                    physics:TeleportRespectingInterpolation(new_entity_position_x, entity_position_y, new_entity_position_z)
                else
    		        k.Transform:SetPosition(new_entity_position_x, entity_position_y, new_entity_position_z)
                end
            end
        end
    end

    self.previous_position_x, self.previous_position_y, self.previous_position_z = world_position_x, world_position_y, world_position_z

    self:TriggerEvents()
end

function WalkablePlatform:CollectEntitiesOnPlatform(check_previous_objects)
    local entities = self:GetEntitiesOnPlatform(nil, IGNORE_WALKABLE_PLATFORM_TAGS)
    for k, v in pairs(entities) do
        self.new_objects_on_platform[v] = true
    end

    local platform_x, platform_z = self.previous_position_x, self.previous_position_z
    local bias = 0.01
    local platform_radius_sq = self.platform_radius * self.platform_radius + bias

    -- check for objects that were on the boat at the previous boat position and move them forward as well
    if check_previous_objects then
        for entity, unused in pairs(self.previous_objects_on_platform) do
            if entity:IsValid() and not entity.components.embarker then
                if not self.new_objects_on_platform[entity] and not entity.entity:GetParent() == nil then
                    local entity_x, entity_y, entity_z = entity.Transform:GetWorldPosition()
                    local delta_x, delta_z = entity_x - platform_x, entity_z - platform_z
                    local dist_sq = delta_x * delta_x + delta_z * delta_z
                    if dist_sq <= platform_radius_sq then
                        self.new_objects_on_platform[entity] = true
                    end
                end 
            end
        end
    end
end

local function player_zoom(boat_inst, self, player_inst)
    -- If our player inst is still valid and we haven't done all of our zoomes yet,
    -- send another zoom message to the camera. Otherwise, end ourselves.
    if player_inst and player_inst:IsValid() and self.player_zooms <= NUM_ZOOMS then
        player_inst:PushEvent("zoomcamera", {zoomout = self.player_zoomed_out, zoom = ZOOM_STEP})
        self.player_zooms = self.player_zooms + 1
    else
        self.player_zoom_task:Cancel()
        self.player_zoom_task = nil
    end
end

function WalkablePlatform:TriggerEvents()
    for k, v in pairs(self.previous_objects_on_platform) do
        if self.new_objects_on_platform[k] == nil then
            k:PushEvent("got_off_platform", self.inst)
            self.inst:PushEvent("obj_got_off_platform", k)

            -- If our player was zoomed out and just jumped off of the platform,
            -- we should undo our zoom effect.
			-- TODO: Fix this next
            if self.player_zoomed_out and k == ThePlayer and Profile:IsBoatCameraEnabled() then
                self.player_zoomed_out = false
                self.player_zooms = NUM_ZOOMS - self.player_zooms

                if self.player_zoom_task == nil then
                    self.player_zoom_task = self.inst:DoPeriodicTask(ZOOM_TASK_PERIOD, player_zoom, nil, self, k)
                end
            end
        end
    end

    for k, v in pairs(self.new_objects_on_platform) do
        if self.previous_objects_on_platform[k] == nil then
            k:PushEvent("got_on_platform", self.inst)
            self.inst:PushEvent("obj_got_on_platform", k)
        end

        -- If this object is the player, we need to check for whether we should zoom in/out.
        if k == ThePlayer then
            local should_zoom = false
            local has_zoom_tag = self.inst:HasTag("doplatformcamerazoom")

            if self.player_zoomed_out == false and has_zoom_tag then
                self.player_zoomed_out = true
                should_zoom = true
            elseif self.player_zoomed_out == true and not has_zoom_tag then
                self.player_zoomed_out = false
                should_zoom = true
            end

            if should_zoom then
                self.player_zooms = NUM_ZOOMS - self.player_zooms

                if self.player_zoom_task == nil then
                    self.player_zoom_task = self.inst:DoPeriodicTask(ZOOM_TASK_PERIOD, player_zoom, nil, self, k)
                end
            end
        end
    end

    self.previous_objects_on_platform = self.new_objects_on_platform
    self.new_objects_on_platform = {}
end

return WalkablePlatform