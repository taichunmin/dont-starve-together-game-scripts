local PlayerActionPicker = Class(function(self, inst)
    self.inst = inst
    self.map = TheWorld.Map
    self.containers = {}
    self.leftclickoverride = nil
    self.rightclickoverride = nil
    self.pointspecialactionsfn = nil
    self.actionfilterstack = {} -- only the highest priority filter is active
    self.actionfilter = nil
end)

function PlayerActionPicker:RegisterContainer(container)
    if container ~= nil and self.containers[container] == nil then
        self.containers[container] = function()
            self:UnregisterContainer(container)
        end
        self.inst:ListenForEvent("onremove", self.containers[container], container)
    end
end

function PlayerActionPicker:UnregisterContainer(container)
    if container ~= nil and self.containers[container] ~= nil then
        self.inst:RemoveEventCallback("onremove", self.containers[container], container)
        self.containers[container] = nil
    end
end

function PlayerActionPicker:HasContainerWidgetAction()
    return next(self.containers) ~= nil
end

function PlayerActionPicker:OnUpdateActionFilterStack()
    local num = #self.actionfilterstack
    if num > 0 then
        local topfilter = self.actionfilterstack[num]
        for i = num - 1, 1, -1 do
            local filter = self.actionfilterstack[i]
            if filter.priority > topfilter.priority then
                topfilter = filter
            end
        end
        self.actionfilter = topfilter.fn
    else
        self.actionfilter = nil
    end
end

function PlayerActionPicker:PushActionFilter(filterfn, priority)
    table.insert(self.actionfilterstack, { fn = filterfn, priority = priority or 0 })
    self:OnUpdateActionFilterStack()
end

function PlayerActionPicker:PopActionFilter(filterfn)
    if filterfn ~= nil then
        for i = #self.actionfilterstack, 1, -1 do
            if self.actionfilterstack[i].fn == filterfn then
                table.remove(self.actionfilterstack, i)
                self:OnUpdateActionFilterStack()
                return
            end
        end
    else
        table.remove(self.actionfilterstack, #self.actionfilterstack)
        self:OnUpdateActionFilterStack()
    end
end

local function OrderByPriority(l, r)
    return l.priority > r.priority
end

-- All the action picker functions that do the heavy lifting run their resulting table through the SortActionList function
-- so we can just do the ghost action selection here, rather than littering it throughout the component.
function PlayerActionPicker:SortActionList(actions, target, useitem)
    if #actions == 0 then
        return actions
    end

    table.sort(actions, OrderByPriority)

    local ret = {}

    for i, v in ipairs(actions) do
        if self.actionfilter == nil or self.actionfilter(self.inst, v) then
            local distance = v == ACTIONS.CASTAOE and useitem ~= nil and useitem.components.aoetargeting ~= nil and useitem.components.aoetargeting:GetRange() or nil
            if target == nil then
                table.insert(ret, BufferedAction(self.inst, nil, v, useitem, nil, nil, distance, nil, nil))
            elseif target:is_a(EntityScript) then
                table.insert(ret, BufferedAction(self.inst, target, v, useitem, nil, nil, distance, nil, nil))
            elseif target:is_a(Vector3) then
                table.insert(ret, BufferedAction(self.inst, nil, v, useitem, target, nil, distance, nil, nil))
            end
        end
    end

    return ret
end

function PlayerActionPicker:GetSceneActions(useitem, right)
    local actions = {}

    useitem:CollectActions("SCENE", self.inst, actions, right)

    if useitem ~= self.inst then
        if not right and useitem.inherentsceneaction ~= nil then
            table.insert(actions, useitem.inherentsceneaction)
        elseif right and useitem.inherentscenealtaction ~= nil then
            table.insert(actions, useitem.inherentscenealtaction)
        end
    end

    local sorted_acts = self:SortActionList(actions, useitem)

    if #sorted_acts == 0 and
        useitem ~= self.inst and
        (self.inst.CanExamine == nil or self.inst:CanExamine()) and
        useitem:HasTag("inspectable") and
        (self.inst.sg == nil or self.inst.sg:HasStateTag("moving") or self.inst.sg:HasStateTag("idle")) and
        (self.inst:HasTag("moving") or self.inst:HasTag("idle")) then
        sorted_acts = self:SortActionList({ ACTIONS.WALKTO }, useitem)
    end

    return sorted_acts
end


function PlayerActionPicker:GetUseItemActions(target, useitem, right)
    local actions = {}

    useitem:CollectActions("USEITEM", self.inst, target, actions, right)

    return self:SortActionList(actions, target, useitem)
end

function PlayerActionPicker:GetSteeringActions(inst, pos, right)
    if not self.inst:HasTag("steeringboat") then return nil end

    if right then
        return self:SortActionList({ ACTIONS.STOP_STEERING_BOAT }, pos)
    else
        if not TheInput:ControllerAttached() then
            return self:SortActionList({ ACTIONS.SET_HEADING }, pos)
        end
    end

    return nil
end

function PlayerActionPicker:GetPointActions(pos, useitem, right)
    local actions = {}

    useitem:CollectActions("POINT", self.inst, pos, actions, right)

    local sorted_acts = self:SortActionList(actions, pos, useitem)

    if not self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_STACK) then
        for i, v in ipairs(sorted_acts) do
            if v.action == ACTIONS.DROP then
                v.options.wholestack = true
                break
            end
        end
    end

    return sorted_acts
end

function PlayerActionPicker:GetPointSpecialActions(pos, useitem, right)
    return self.pointspecialactionsfn ~= nil and self:SortActionList(self.pointspecialactionsfn(self.inst, pos, useitem, right), pos) or {}
end

function PlayerActionPicker:GetEquippedItemActions(target, useitem, right)
    local actions = {}

    useitem:CollectActions("EQUIPPED", self.inst, target, actions, right)

    return self:SortActionList(actions, target, useitem)
end

function PlayerActionPicker:GetInventoryActions(useitem, right)
    local actions = {}

	if not self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_TRADE) then
		useitem:CollectActions("INVENTORY", self.inst, actions, right)
	else
		actions = {ACTIONS.DROP}
	end

    local sorted_acts = self:SortActionList(actions, nil, useitem)

    if not self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_STACK) then
        for i, v in ipairs(sorted_acts) do
            if v.action == ACTIONS.DROP then
                v.options.wholestack = true
                break
            end
        end
    end

    return sorted_acts
end

local function TargetIsHostile(inst, target)
    if inst.HostileTest ~= nil then
        return inst:HostileTest(target)
    else
        return target:HasTag("hostile")
    end
end

function PlayerActionPicker:GetLeftClickActions(position, target)
    if self.leftclickoverride ~= nil then
        local actions, usedefault = self.leftclickoverride(self.inst, target, position)
        if not usedefault or (actions ~= nil and #actions > 0) then
            return actions or {}
        end
    end

    local actions = nil
    local useitem = self.inst.replica.inventory:GetActiveItem()
    local equipitem = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local ispassable = self.map:IsPassableAtPoint(position:Get())

    self.disable_right_click = false

    local steering_actions = self:GetSteeringActions(self.inst, position, false)
    if steering_actions ~= nil then
        --self.disable_right_click = true
        return steering_actions
    end

    --if we're specifically using an item, see if we can use it on the target entity
    if useitem ~= nil then
        if useitem:IsValid() then
            if target == self.inst then
                actions = self:GetInventoryActions(useitem)
            elseif target ~= nil  and not target:HasTag("walkableplatform") then
                actions = self:GetUseItemActions(target, useitem)
            else
                actions = self:GetPointActions(position, useitem)
            end
        end
    elseif target ~= nil and target ~= self.inst then
        --if we're clicking on a scene entity, see if we can use our equipped object on it, or just use it
        if self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_INSPECT) and
                target:HasTag("inspectable") and
                (self.inst.CanExamine == nil or self.inst:CanExamine()) and
                (self.inst.sg == nil or self.inst.sg:HasStateTag("moving") or self.inst.sg:HasStateTag("idle") or self.inst.sg:HasStateTag("channeling")) and
                (self.inst:HasTag("moving") or self.inst:HasTag("idle") or self.inst:HasTag("channeling")) then
            actions = self:SortActionList({ ACTIONS.LOOKAT }, target, nil)
        elseif (    self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK)
                    or TargetIsHostile(self.inst, target)
                ) and target.replica.combat ~= nil and self.inst.replica.combat:CanTarget(target) then
            actions = self:SortActionList({ ACTIONS.ATTACK }, target, nil)
        elseif equipitem ~= nil and equipitem:IsValid() then
            actions = self:GetEquippedItemActions(target, equipitem)
        end

        if actions == nil or #actions == 0 then
            actions = self:GetSceneActions(target)
        end
    end

    if actions == nil and target == nil and ispassable then
        if equipitem ~= nil and equipitem:IsValid() then
            --can we use our equipped item at the point?
            actions = self:GetPointActions(position, equipitem)
            --this is to make it so you don't auto-drop equipped items when you left click the ground. kinda ugly.
            if actions ~= nil then
                for i, v in ipairs(actions) do
                    if v.action == ACTIONS.DROP then
                        table.remove(actions, i)
                        break
                    end
                end
            end
        end
        if actions == nil or #actions <= 0 then
            actions = self:GetPointSpecialActions(position, useitem, false)
        end
    end

    return actions or {}
end

function PlayerActionPicker:GetRightClickActions(position, target)

    if self.disable_right_click then
        return {}
    end

    if self.rightclickoverride ~= nil then
        local actions, usedefault = self.rightclickoverride(self.inst, target, position)
        if not usedefault or (actions ~= nil and #actions > 0) then
            return actions or {}
        end
    end

    local steering_actions = self:GetSteeringActions(self.inst, position, true)
    if steering_actions ~= nil then
        --self.disable_right_click = true
        return steering_actions
    end

    local actions = nil
    local useitem = self.inst.replica.inventory:GetActiveItem()
    local equipitem = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local ispassable = self.map:IsPassableAtPoint(position:Get())

    if target ~= nil and self.containers[target] then
        --check if we have container widget actions
        actions = self:GetSceneActions(target, true)
    elseif useitem ~= nil then
        --if we're specifically using an item, see if we can use it on the target entity
        if useitem:IsValid() then
            if target == self.inst then
                actions = self:GetInventoryActions(useitem, true)
            elseif target ~= nil and (not target:HasTag("walkableplatform") or (useitem:HasTag("repairer") and not useitem:HasTag("deployable"))) then
                actions = self:GetUseItemActions(target, useitem, true)
            else
                actions = self:GetPointActions(position, useitem, true)
            end
        end
    elseif target ~= nil and not target:HasTag("walkableplatform") then
        --if we're clicking on a scene entity, see if we can use our equipped object on it, or just use it
        if equipitem ~= nil and equipitem:IsValid() then
            actions = self:GetEquippedItemActions(target, equipitem, true)

            --strip out all other actions for weapons with right click special attacks
            if equipitem.components.aoetargeting ~= nil then
                return (#actions <= 0 or actions[1].action == ACTIONS.CASTAOE) and actions or {}
            end
        end

        if actions == nil or #actions == 0 then
            actions = self:GetSceneActions(target, true)
        end
    elseif equipitem ~= nil and equipitem:IsValid() and (ispassable or equipitem:HasTag("allow_action_on_impassable") or (equipitem.components.aoetargeting ~= nil and equipitem.components.aoetargeting.alwaysvalid and equipitem.components.aoetargeting:IsEnabled())) then
        actions = self:GetPointActions(position, equipitem, true)
    end

    if (actions == nil or #actions <= 0) and (target == nil or target:HasTag("walkableplatform")) and ispassable then
        actions = self:GetPointSpecialActions(position, useitem, true)
    end

    return actions or {}
end

function PlayerActionPicker:DoGetMouseActions(position, target)
    local isaoetargeting = false
    local wantsaoetargeting = false

    if position == nil then
        if TheInput:GetHUDEntityUnderMouse() ~= nil then
            return
        end

        isaoetargeting = self.inst.components.playercontroller:IsAOETargeting()
        wantsaoetargeting = not isaoetargeting and self.inst.components.playercontroller:HasAOETargeting()

        if target == nil and not isaoetargeting then
            target = TheInput:GetWorldEntityUnderMouse()
        end
        position = isaoetargeting and self.inst.components.playercontroller:GetAOETargetingPos() or TheInput:GetWorldPosition()

        local cansee
        if target == nil then
            local x, y, z = position:Get()
            cansee = CanEntitySeePoint(self.inst, x, y, z)
        else
            cansee = target == self.inst or CanEntitySeeTarget(self.inst, target)
        end

        --Check for actions in the dark
        if not cansee then
            local lmb = nil
            local rmb = nil
            if not isaoetargeting then
                local lmbs = self:GetLeftClickActions(position)
                for i, v in ipairs(lmbs) do
                    if (v.action == ACTIONS.DROP and self.inst:GetDistanceSqToPoint(position:Get()) < 16) or
                        v.action == ACTIONS.SET_HEADING then
                        lmb = v
                    end
                end

                local rmbs = self:GetRightClickActions(position)
                for i, v in ipairs(rmbs) do
                    if (v.action == ACTIONS.STOP_STEERING_BOAT) then
                        rmb = v
                    end
                end
            end

            return lmb, rmb
        end
    end

    local lmb = not isaoetargeting and self:GetLeftClickActions(position, target)[1] or nil
    local rmb = not wantsaoetargeting and self:GetRightClickActions(position, target)[1] or nil

    return lmb, rmb ~= nil and (lmb == nil or lmb.action ~= rmb.action) and rmb or nil
end

return PlayerActionPicker
