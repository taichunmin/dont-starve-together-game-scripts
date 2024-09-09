local AutoTerraformer = Class(function(self, inst)
    assert(inst.components.container ~= nil, "AutoTerraformer requires the Container component")
    self.inst = inst

    self.repeat_tile_delay = TUNING.AUTOTERRAFORMER_REPEAT_DELAY

    --self.onfinishterraformingfn = nil

    self.container = inst.components.container
end)

function AutoTerraformer:FinishTerraforming(x, y, z)
	self.inst:PushEvent("onterraform")

    if self.inst.components.finiteuses then
        self.inst.components.finiteuses:Use()
    end

    if self.onfinishterraformingfn then
        self.onfinishterraformingfn(self.inst, x, y, z)
    end
end

function AutoTerraformer:DoTerraform(px, py, pz, x, y)
    local map = TheWorld.Map

    local item_tile
    local item = self.container:GetItemInSlot(1)
    if item and item.tile then
        item_tile = item.tile
    end

    local original_tile_type = map:GetTile(x, y)
    if item_tile == original_tile_type then
        return
    end

    --place our turf if we can do that
    if item_tile ~= nil and map:CanPlaceTurfAtPoint(px, py, pz) then
        self.container:RemoveItem(item, false):Remove()
        map:SetTile(x, y, item_tile)
        self:FinishTerraforming(px, py, pz)
        return
    end

	if not map:CanTerraformAtPoint(px, py, pz) then
        return
    end

    local underneath_tile = TheWorld.components.undertile:GetTileUnderneath(x, y)
    if underneath_tile then
        map:SetTile(x, y, underneath_tile)
    else
        if item_tile then
            self.container:RemoveItem(item, false):Remove()
        end
        map:SetTile(x, y, item_tile or WORLD_TILES.DIRT)
    end

    HandleDugGround(original_tile_type, px, py, pz)

    for _, ent in ipairs(TheWorld.Map:GetEntitiesOnTileAtPoint(px, py, pz)) do
        if ent:HasTag("soil") then
            ent:PushEvent("collapsesoil")
        end
    end

    self:FinishTerraforming(px, py, pz)

    return underneath_tile ~= nil
end

function AutoTerraformer:StartTerraforming()
    self.last_x, self.last_y, self.repeat_delay = nil, nil, nil
    self.inst:StartUpdatingComponent(self)
end

function AutoTerraformer:StopTerraforming()
    self.inst:StopUpdatingComponent(self)
end

function AutoTerraformer:OnUpdate(dt)
    local px, py, pz = self.inst.Transform:GetWorldPosition()
    local x, y = TheWorld.Map:GetTileXYAtPoint(px, py, pz)

    if self.repeat_delay ~= nil then
        self.repeat_delay = math.max(self.repeat_delay - dt, 0)
    end

    if (self.last_x == nil and self.last_y == nil) or
    (self.last_x ~= x or self.last_y ~= y) or
    (self.last_x == x and self.last_y == y and self.repeat_delay == 0) then
        self.repeat_delay = nil
        local repeat_tile = self:DoTerraform(px, py, pz, x, y)

        self.last_x, self.last_y = x, y
        if repeat_tile then
            self.repeat_delay = self.repeat_tile_delay
        end
    end
end

return AutoTerraformer
