local WalkablePlatformManager = Class(function(self, inst)
    self.inst = inst
    self.lastuid = -1
    self.walkable_platforms = {}
    self.walkable_platform_uids = {}
end)

--V2C: refactored. please do NOT recycle UIDs! players save the uids,
--     and those platforms can be destroyed while they are offline.
function WalkablePlatformManager:GetNewUID()
	self.lastuid = self.lastuid + 1
	return self.lastuid
end

function WalkablePlatformManager:UnregisterPlatform(platform)
    local uid = platform.components.walkableplatform.uid
    if not uid then
        print("Warn: attempted to unregister platform with no uid.")
    elseif self.walkable_platform_uids[uid] ~= platform then
        print("Warn: attempted to unregister platform with uid that doesnt match platform.")
    else
        self.walkable_platform_uids[uid] = nil
    end
end

function WalkablePlatformManager:RegisterPlatform(platform)
    local uid = platform.components.walkableplatform.uid
    if not uid then
        uid = self:GetNewUID()
        platform.components.walkableplatform.uid = uid
	elseif uid > self.lastuid then
		--V2C: legacy support... previously there was no proper uid management,
		--     so we don't rly know for sure what the lastuid is.
		self.lastuid = uid + 10000
    end

    if self.walkable_platform_uids[uid] then
        print("Warn: attempted to register platform with duplicate uid")
    else
        self.walkable_platform_uids[uid] = platform
    end
end

function WalkablePlatformManager:GetPlatformWithUID(uid)
    return self.walkable_platform_uids[uid]
end

function WalkablePlatformManager:AddPlatform(platform)
    self.walkable_platforms[platform] = true
end

function WalkablePlatformManager:RemovePlatform(platform)
    self.walkable_platforms[platform] = nil
end

function WalkablePlatformManager:PostUpdate(dt)
    if TheWorld.ismastersim then
        for k in pairs(self.walkable_platforms) do
            if k and k:IsValid() then
                k.components.walkableplatform:SetEntitiesOnPlatform(dt)
            else
                self.walkableplatform[k] = nil
            end
        end

        for i, v in ipairs(AllPlayers) do
            if v.components.walkableplatformplayer then
                v.components.walkableplatformplayer:TestForPlatform()
            end
        end

        for k in pairs(self.walkable_platforms) do
            k.components.walkableplatform:CommitPlayersOnPlatform()
        end
    --if we ever support movement prediction properly on more things than ThePlayer, fix this.
    elseif ThePlayer and ThePlayer.components.walkableplatformplayer then
        ThePlayer.components.walkableplatformplayer:TestForPlatform()
    end
end

function WalkablePlatformManager:OnSave()
	return { lastuid = self.lastuid }
end

function WalkablePlatformManager:OnLoad(data)
	if data.lastuid ~= nil then
		self.lastuid = data.lastuid
	end
end

return WalkablePlatformManager