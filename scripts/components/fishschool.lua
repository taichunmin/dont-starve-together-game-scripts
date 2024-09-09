local FishSchool = Class(function(self, inst)
    self.inst = inst
    self.max_fish_level = 3
    self.fish_level = self.max_fish_level
    self.fish_prefab_name = nil
    self.replenish_task = nil

    self.inst.AnimState:PlayAnimation("group_pre", false)
    self.inst.AnimState:PushAnimation("group_loop1", true)

    self.inst:ListenForEvent("on_pre_net", function(inst, net) self:OnPreNet(net) end)
end)
function FishSchool:StartReplenish(replenish_rate)
    self:StopReplenish()
    self.replenish_task = self.inst:DoPeriodicTask(replenish_rate or 10, function(inst) inst.components.fishschool:Replenish() end)
end

function FishSchool:StopReplenish()
    if self.replenish_task ~= nil then
        self.replenish_task:Cancel()
        self.replenish_task = nil
    end
end

function FishSchool:SetNettedPrefab(fishing_net_prefab)
    self.fish_prefab_name = fishing_net_prefab
end

function FishSchool:OnPreNet(net)
	if self.fish_level > 0 then

		local net_x, net_y, net_z = net.Transform:GetWorldPosition()

        if self.fish_prefab_name then
		    for i = 1,self.fish_level,1 do
			    local antchovies = SpawnPrefab(self.fish_prefab_name)
			    antchovies.Transform:SetPosition(net_x, net_y, net_z)
			    antchovies:PushEvent("on_caught_in_net")
		    end
        end

		self.fish_level = 0
		self.inst.AnimState:PlayAnimation("group_pst", false)
	end
end

function FishSchool:Replenish()

	if self.fish_level ~= self.max_fish_level then
		if self.fish_level == 0 then
			self.inst.AnimState:PlayAnimation("group_pre", false)
			self.inst.AnimState:PushAnimation("group_loop1", true)
		end
		self.fish_level = math.min(self.fish_level + 1, self.max_fish_level)
	end
end

return FishSchool
