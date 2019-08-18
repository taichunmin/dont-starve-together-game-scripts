local WalkablePlatformManager = Class(function(self, inst)
    self.inst = inst

    self.walkable_platforms = {}
end)

function WalkablePlatformManager:AddPlatform(platform)
    table.insert(self.walkable_platforms, platform)
end

function WalkablePlatformManager:RemovePlatform(platform)
	for i, v in ipairs(self.walkable_platforms) do
		if v == platform then
			table.remove(self.walkable_platforms, i)
			return
		end
	end
end


function WalkablePlatformManager:PostUpdate(dt)
    for i, v in ipairs(self.walkable_platforms) do
        if v ~= nil and v:IsValid() then
            v.components.walkableplatform:UpdatePositions(dt)
        end
    end
end

return WalkablePlatformManager