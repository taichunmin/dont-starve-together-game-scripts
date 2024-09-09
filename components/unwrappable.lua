local function oncanbeunwrapped(self, canbeunwrapped)
    if canbeunwrapped then
        self.inst:AddTag("unwrappable")
    else
        self.inst:RemoveTag("unwrappable")
    end
end

local Unwrappable = Class(function(self, inst)
    self.inst = inst
    self.itemdata = nil
    self.canbeunwrapped = true
    self.onwrappedfn = nil
    self.onunwrappedfn = nil
    self.origin = nil

    --V2C: Recommended to explicitly add tags to prefab pristine state
    --On construciton, "unwrappable" tag is added by default
end,
nil,
{
    canbeunwrapped = oncanbeunwrapped,
})

function Unwrappable:SetOnWrappedFn(fn)
    self.onwrappedfn = fn
end

function Unwrappable:SetOnUnwrappedFn(fn)
    self.onunwrappedfn = fn
end

function Unwrappable:WrapItems(items, doer)
    if #items > 0 then
        self.origin = TheWorld.meta.session_identifier
        self.itemdata = {}
        local item, is_string
        for _, v in ipairs(items) do
            is_string = (type(v) == "string")
            item = (is_string and SpawnPrefab(v)) or v

            local data = item:GetSaveRecord()
            table.insert(self.itemdata, data)

            if is_string then
                item:Remove()
            end
        end

        if self.onwrappedfn then
            self.onwrappedfn(self.inst, #self.itemdata, doer)
        end
    end
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

function Unwrappable:Unwrap(doer)
    local pos = self.inst:GetPosition()
    pos.y = 0
    if self.itemdata ~= nil then
		if doer ~= nil and self.inst.components.inventoryitem ~= nil then
			local owner = self.inst.components.inventoryitem:GetGrandOwner()
			if owner ~= nil then
				if owner ~= doer and owner:HasTag("pocketdimension_container") then
					owner = doer.components.inventory ~= nil and doer.components.inventory:GetOpenContainerProxyFor(owner) or nil
					if owner ~= nil then
						pos.x, pos.y, pos.z = owner.Transform:GetWorldPosition()
						pos.y = 0
					else
						owner = doer
					end
				end
				if owner == doer then
					local doerpos = doer:GetPosition()
					local offset = FindWalkableOffset(doerpos, doer.Transform:GetRotation() * DEGREES, 1, 8, false, true, NoHoles)
					if offset ~= nil then
						pos.x = doerpos.x + offset.x
						pos.z = doerpos.z + offset.z
					else
						pos.x, pos.z = doerpos.x, doerpos.z
					end
				end
			end
        end
        local creator = self.origin ~= nil and TheWorld.meta.session_identifier ~= self.origin and { sessionid = self.origin } or nil
        for i, v in ipairs(self.itemdata) do
            local item = SpawnPrefab(v.prefab, v.skinname, v.skin_id, creator)
            if item ~= nil and item:IsValid() then
                if item.Physics ~= nil then
                    item.Physics:Teleport(pos:Get())
                else
                    item.Transform:SetPosition(pos:Get())
                end
                item:SetPersistData(v.data)
                if item.components.inventoryitem ~= nil then
                    item.components.inventoryitem:OnDropped(true, .5)
                end
            end
        end
        self.itemdata = nil
    end
    if self.onunwrappedfn ~= nil then
        self.onunwrappedfn(self.inst, pos, doer)
    end
end

function Unwrappable:OnSave()
    return self.itemdata ~= nil
        and {
            items = self.itemdata,
            origin = self.origin,
        }
        or nil
end

function Unwrappable:OnLoad(data)
    if data.items ~= nil and #data.items > 0 then
        self.itemdata = data.items
        self.origin = data.origin
        if self.onwrappedfn ~= nil then
            self.onwrappedfn(self.inst, #self.itemdata)
        end
    end
end

return Unwrappable
