
BufferedAction = Class(function(self, doer, target, action, invobject, pos, recipe, distance, forced, rotation, arrivedist)
    self.doer = doer
    self.target = target
    self.initialtargetowner = target ~= nil and target.components.inventoryitem ~= nil and target.components.inventoryitem.owner or nil
    self.action = action
    self.invobject = invobject
    self.doerownsobject = doer ~= nil and invobject ~= nil and invobject.replica.inventoryitem ~= nil and invobject.replica.inventoryitem:IsHeldBy(doer)
    self.pos = pos ~= nil and DynamicPosition(pos) or nil
    self.rotation = rotation or 0
    self.onsuccess = {}
    self.onfail = {}
    self.recipe = recipe
    self.options = {}
    self.distance = distance or action.distance
    self.arrivedist = arrivedist or action.arrivedist
    self.forced = forced
    self.autoequipped = nil --true if invobject should've been auto-equipped
    self.skin = nil
end)

function BufferedAction:Do()
    if not self:IsValid() then
        return false
    end
    local success, reason = self.action.fn(self)
    if success then
        if self.invobject ~= nil and self.invobject:IsValid() then
            self.invobject:OnUsedAsItem(self.action, self.doer, self.target)
        end
        self:Succeed()
    else
        self:Fail()
    end
    return success, reason
end

function BufferedAction:IsValid()
    return (self.invobject == nil or self.invobject:IsValid()) and
           (self.doer == nil or (self.doer:IsValid() and (not self.autoequipped or self.doer.replica.inventory:GetActiveItem() == nil))) and
           (self.target == nil or (self.target:IsValid() and self.initialtargetowner == (self.target.components.inventoryitem ~= nil and self.target.components.inventoryitem.owner or nil))) and
           (self.pos == nil or self.pos.walkable_platform == nil or self.pos.walkable_platform:IsValid()) and
           (not self.doerownsobject or (self.doer ~= nil and self.invobject ~= nil and self.invobject.replica.inventoryitem ~= nil and self.invobject.replica.inventoryitem:IsHeldBy(self.doer))) and
           (self.validfn == nil or self.validfn(self)) and
           (not TheWorld.ismastersim or (self.action.validfn == nil or self.action.validfn(self)))
end

--V2C: TestForStart can return "reason" as a second return value (but we don't in DST)
BufferedAction.TestForStart = BufferedAction.IsValid

function BufferedAction:GetActionString()
    local str, overriden = nil, nil
	if self.doer ~= nil and self.doer.ActionStringOverride ~= nil then
		 str, overriden = self.doer:ActionStringOverride(self)
	end
    if str ~= nil then
        return str, overriden
    elseif self.action.stroverridefn ~= nil then
        str = self.action.stroverridefn(self)
        if str ~= nil then
            return str, true
        end
    end
    return GetActionString(self.action.id, self.action.strfn ~= nil and self.action.strfn(self) or nil)
end

function BufferedAction:__tostring()
    return (self:GetActionString().." "..tostring(self.target))
        ..(self.invobject ~= nil and (" With Inv: "..tostring(self.invobject)) or "")
        ..(self.recipe ~= nil and (" Recipe: "..self.recipe) or "")
end

function BufferedAction:AddFailAction(fn)
    table.insert(self.onfail, fn)
end

function BufferedAction:AddSuccessAction(fn)
    table.insert(self.onsuccess, fn)
end

function BufferedAction:Succeed()
    for k, v in pairs(self.onsuccess) do
        v()
    end
    self.onsuccess = {}
    self.onfail = {}
end

function BufferedAction:GetActionPoint()
	-- returns a Vector3 or nil
	return self.pos ~= nil and self.pos:GetPosition() or nil
end

function BufferedAction:GetDynamicActionPoint()
	-- returns a DynamicPosition or nil
	return self.pos
end

function BufferedAction:SetActionPoint(pt)
	self.pos = DynamicPosition(pt)
end

function BufferedAction:Fail()
    for k,v in pairs(self.onfail) do
        v()
    end
    self.onsuccess = {}
    self.onfail = {}
end
