--local TIMEOUT = 20

local function OnItemExited(self, item)
    if self.inst.HUD == nil then
        return
    end

    for i, v in ipairs(self.offScreenItems) do
        if v == item then
            self.inst.HUD:RemoveTargetIndicator(v)
            table.remove(self.offScreenItems, i)
            break
        end
    end
end

local HudIndicatorWatcher = Class(function(self, inst)
    self.inst = inst

    self.offScreenItems = {}
    self.onScreenItemsLastTick = {}
    --self.recentTargetRemoved = {}

    self.onitemexited = function(world, item)
        OnItemExited(self, item)
    end

    inst:ListenForEvent("playerexited", self.onitemexited, TheWorld)
    inst:ListenForEvent("unregister_hudindicatable", self.onitemexited, TheWorld)

    inst:StartUpdatingComponent(self)
end)

function HudIndicatorWatcher:OnRemoveFromEntity()
    if self.offScreenItems == nil then
        return
    end

    self.inst:RemoveEventCallback("playerexited", self.onitemexited, TheWorld)
    self.inst:RemoveEventCallback("unregister_hudindicatable", self.onitemexited, TheWorld)

    if self.inst.HUD == nil then
        return
    end

    for i, v in ipairs(self.offScreenItems) do
        self.inst.HUD:RemoveTargetIndicator(v)
    end

    self.offScreenItems = nil
end

HudIndicatorWatcher.OnRemoveEntity = HudIndicatorWatcher.OnRemoveFromEntity

function HudIndicatorWatcher:ShouldShowIndicator(target)
    return target.components.hudindicatable:ShouldTrack(self.inst)
      --  and table.contains(self.onScreenItemsLastTick, target)
end

function HudIndicatorWatcher:ShouldRemoveIndicator(target)
    return not target.components.hudindicatable:ShouldTrack(self.inst)
end

function HudIndicatorWatcher:OnUpdate()
    if self.inst.HUD == nil then
        return
    end

    local checked = {}

    --Check which indicators' players have moved within view or too far
    for i, v in ipairs(self.offScreenItems) do
        checked[v] = false
        while self:ShouldRemoveIndicator(v) do
            self.inst.HUD:RemoveTargetIndicator(v)
            table.remove(self.offScreenItems, i)
            v = self.offScreenItems[i]
            if v == nil then
                break
            end
            checked[v] = true
        end
    end

    --Check which players have moved outside of view
    if TheWorld.components.hudindicatablemanager then
        for i, v in pairs(TheWorld.components.hudindicatablemanager.items) do
            if not (checked[v] or v == self.inst) and self:ShouldShowIndicator(v) then
                if not table.contains(self.offScreenItems, v) then
                    self.inst.HUD:AddTargetIndicator(v)
                    table.insert(self.offScreenItems, v)
                end
            end
        end

        --[[
        self.onScreenItemsLastTick = {}
         for i, v in pairs(TheWorld.components.hudindicatablemanager.items) do
            if v ~= self.inst and v.entity:FrustumCheck() then
           --     table.insert(self.onScreenItemsLastTick, v)
            end
        end
        ]]
    end
end

return HudIndicatorWatcher