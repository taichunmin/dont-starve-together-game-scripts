local CHECK_INTERVAL = 5

FindClosest = Class(BehaviourNode, function(self, inst, see_dist, safe_dist, tags, exclude_tags, one_of_tags)
    BehaviourNode._ctor(self, "FindClosest")
    self.inst = inst
    self.targ = nil
    self.see_dist = see_dist
    self.safe_dist = safe_dist
    self.lastchecktime = 0
    self.tags = type(tags) == "string" and { tags } or tags
    self.exclude_tag = type(exclude_tags) == "string" and { exclude_tags } or exclude_tags
    self.one_of_tags = type(one_of_tags) == "string" and { one_of_tags } or one_of_tags
end)

function FindClosest:DBString()
    return string.format("Stay near target %s", tostring(self.targ))
end

function FindClosest:Visit()
    if self.status == READY then
        self:PickTarget()
        self.status = RUNNING
    end

    if self.status == RUNNING then
        if GetTime() - self.lastchecktime > CHECK_INTERVAL then
            self:PickTarget()
        else
			local valid_target = self.targ ~= nil and self.targ:IsValid()

			-- Has all of the tags
			if valid_target and self.tags ~= nil then
				for i,k in ipairs(self.tags) do
					if not self.targ:HasTag(k) then
						valid_target = false
						break
					end
				end
			end

			-- Has none of the tags
			if valid_target and self.exclude_tag ~= nil then
				for i,k in ipairs(self.exclude_tag) do
					if self.targ:HasTag(k) then
						valid_target = false
						break
					end
				end
			end

			-- Has or or more of the tags
			if valid_target and self.one_of_tags ~= nil then
				valid_target = false
				for i,k in ipairs(self.one_of_tags) do
					if self.targ:HasTag(k) then
						valid_target = true
						break
					end
				end
			end

			if not valid_target then
				self.targ = nil
			end
        end

        if self.targ == nil or not self.targ:IsValid() then
            self.status = FAILED
        else
            local actual_safe_dist = FunctionOrValue(self.safe_dist, self.inst, self.targ) or 5
            if self.inst:IsNear(self.targ, actual_safe_dist) then
                self.status = SUCCESS
                self.inst.components.locomotor:Stop()
            else
                self.inst.components.locomotor:GoToPoint(self.inst:GetPositionAdjacentTo(self.targ, actual_safe_dist * 0.98), nil, true)
            end
        end
    end
end

function FindClosest:PickTarget()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.see_dist, self.tags, self.exclude_tag, self.one_of_tags)
    self.targ = ents[1] ~= self.inst and ents[1] or ents[2] -- note: its okay that ents[2] might be nil

    self.lastchecktime = GetTime()
end
