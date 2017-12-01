local function update(inst)
	inst:PushEvent("deciduousleaffx")
end

local function OnSeasonChange(inst, data)
	local wdtu = inst.components.worlddeciduoustreeupdater
	if not TheWorld.state.isautumn then
		if wdtu and wdtu.updatetask then
			inst:DoTaskInTime(TUNING.MAX_LEAF_CHANGE_TIME, function(inst)
				if wdtu and wdtu.updatetask then
	    			wdtu.updatetask:Cancel()
	    			wdtu.updatetask = nil
	    		end
    		end)
		end
	elseif wdtu and not wdtu.updatetask then
		inst:DoTaskInTime(TUNING.MIN_LEAF_CHANGE_TIME, function(inst)
			if wdtu and not wdtu.updatetask then
    			wdtu.updatetask = inst:DoPeriodicTask(3, function(inst) update(inst) end)
    		end
    	end)	
	end
end

local WorldDeciduousTreeUpdater = Class(function(self, inst)

    self.inst = inst
    self.update = update

    self.updatetask = nil
    if TheWorld.state.isautumn then
    	self.updatetask = self.inst:DoPeriodicTask(3, function(inst) update(inst) end)
    end

    self.inst:WatchWorldState("season", OnSeasonChange)
end)

return WorldDeciduousTreeUpdater