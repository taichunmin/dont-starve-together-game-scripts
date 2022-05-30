local MapSpotRevealer = Class(function(self, inst)
    self.inst = inst

	self.gettargetfn = nil
	self.prerevealfn = nil

	self.open_map_on_reveal = true
end)

function MapSpotRevealer:SetGetTargetFn(fn)
	self.gettargetfn = fn
end

function MapSpotRevealer:SetPreRevealFn(fn)
	self.prerevealfn = fn
end

function MapSpotRevealer:RevealMap(doer)
	if self.prerevealfn ~= nil then
		local allow_mapreveal = self.prerevealfn(self.inst, doer)

		if allow_mapreveal == false then
			return true
		end
	end

	if self.gettargetfn == nil then
		return false, "NO_TARGET"
	end

	local targetpos, reason = self.gettargetfn(self.inst, doer)

	if not targetpos then
		return targetpos, reason
	end

	local x, y, z = targetpos.x, targetpos.y, targetpos.z

	if not x then
		return false, "NO_TARGET"
	end

	self.inst:PushEvent("on_reveal_map_spot_pre", targetpos)

	if doer.player_classified ~= nil then
		if self.open_map_on_reveal then
			doer.player_classified.revealmapspot_worldx:set(x)
			doer.player_classified.revealmapspot_worldz:set(z)
			doer.player_classified.revealmapspotevent:push()
		end

		doer:DoTaskInTime(4*FRAMES, function()
			doer.player_classified.MapExplorer:RevealArea(x, y, z, true, true)
		end)
	else
		return false, "NO_MAP"
	end

	self.inst:PushEvent("on_reveal_map_spot_pst", targetpos)

    return true
end

return MapSpotRevealer