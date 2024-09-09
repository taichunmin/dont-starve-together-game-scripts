local function OnEnabledDirty(inst)
    local self = inst.components.aoetargeting
    if not self.enabled:value() then
        self:StopTargeting()
    end
end

local AOETargeting = Class(function(self, inst)
    self.inst = inst
    self.reticule =
    {
        ease = false,
        smoothing = 6.66,
        targetfn = nil,
        reticuleprefab = "reticule",
        validcolour = { 204 / 255, 131 / 255, 57 / 255, 1 },
        invalidcolour = { 1, 0, 0, 1 },
        mouseenabled = false,
		twinstickmode = nil,
		twinstickrange = nil,
        pingprefab = nil,
    }
    self.targetprefab = nil
    self.alwaysvalid = false
	self.allowwater = false
	self.allowriding = true
	self.deployradius = 0
    self.range = 8
	self.shouldrepeatcastfn = nil

    self.enabled = net_bool(inst.GUID, "aoetargeting.enabled", "enableddirty")
    self.enabled:set(true)
    if not TheWorld.ismastersim then
        inst:ListenForEvent("enableddirty", OnEnabledDirty)
    end
end)

function AOETargeting:IsEnabled()
    return self.enabled:value()
end

function AOETargeting:SetEnabled(enabled)
    if TheWorld.ismastersim then
        self.enabled:set(enabled)
        OnEnabledDirty(self.inst)
    end
end

function AOETargeting:SetTargetFX(prefab)
    self.targetprefab = prefab
end

function AOETargeting:SetAlwaysValid(val)
    self.alwaysvalid = val ~= false
end

function AOETargeting:SetAllowWater(val)
	self.allowwater = val ~= false
end

function AOETargeting:SetAllowRiding(val)
	self.allowriding = val ~= false
end

function AOETargeting:SetRange(range)
    self.range = range
end

function AOETargeting:GetRange()
    return self.range
end

function AOETargeting:SetDeployRadius(radius)
	self.deployradius = radius
end

function AOETargeting:SetShouldRepeatCastFn(fn)
	self.shouldrepeatcastfn = fn
end

function AOETargeting:CanRepeatCast()
	return self.shouldrepeatcastfn ~= nil
end

function AOETargeting:ShouldRepeatCast(doer)
	return self.shouldrepeatcastfn ~= nil and self.shouldrepeatcastfn(self.inst, doer)
end

function AOETargeting:StartTargeting()
    if self.inst.components.reticule == nil then
		local owner = ThePlayer
		if owner.components.playercontroller ~= nil then
			local inventoryitem = self.inst.replica.inventoryitem
			if inventoryitem ~= nil and inventoryitem:IsGrandOwner(owner) then
				self.inst:AddComponent("reticule")
				for k, v in pairs(self.reticule) do
					self.inst.components.reticule[k] = v
				end
				owner.components.playercontroller:RefreshReticule(self.inst)
			end
		end
    end
end

function AOETargeting:StopTargeting()
    if self.inst.components.reticule ~= nil then
        self.inst:RemoveComponent("reticule")
		if ThePlayer.components.playercontroller ~= nil then
			ThePlayer.components.playercontroller:RefreshReticule()
		end
    end
end

function AOETargeting:SpawnTargetFXAt(pos)
	if self.targetprefab ~= nil and pos ~= nil then
		local platform
		if pos:is_a(DynamicPosition) then
			platform = pos.walkable_platform
			pos = pos.local_pt
		end
		if pos ~= nil and (platform == nil or platform:IsValid()) then
			local fx = SpawnPrefab(self.targetprefab)
			if fx ~= nil then
				if platform ~= nil then
					fx.entity:SetParent(platform.entity)
					fx:ListenForEvent("onremove", function()
						fx.Transform:SetPosition(fx.Transform:GetWorldPosition())
						fx.entity:SetParent(nil)
					end, platform)
				end
				fx.Transform:SetPosition(pos:Get())
				return fx
			end
		end
	end
end

return AOETargeting
