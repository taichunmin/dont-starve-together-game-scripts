local function OnUsedTouchStoneID(self, id)
    if id > 0 then
        self.used[id] = true
        if self.inst.player_classified ~= nil then
            local used = {}
            for k, v in pairs(self.used) do
                table.insert(used, k)
            end
            self.inst.player_classified:SetUsedTouchStones(used)
        end
    end
end

local function OnUsedTouchStone(inst, touchstone)
    OnUsedTouchStoneID(inst.components.touchstonetracker, touchstone:GetTouchStoneID())
end

local TouchStoneTracker = Class(function(self, inst)
    self.inst = inst
    self.used = {} --Data for current shard
    self.used_foreign = {} --Retained save data from other shards
    inst:ListenForEvent("usedtouchstone", OnUsedTouchStone)
end)

function TouchStoneTracker:OnRemoveFromEntity()
    self.inst.player_classified:SetUsedTouchStones({})
    self.inst:RemoveEventCallback("usedtouchstone", OnUsedTouchStone)
end

function TouchStoneTracker:GetDebugString()
    local str = ""
    for k, v in pairs(self.used) do
        str = (#str <= 0 and "Used: " or (str..", "))..tostring(k)
    end
    return str
end

function TouchStoneTracker:IsUsed(touchstone)
    return self.used[touchstone:GetTouchStoneID()] == true
end

function TouchStoneTracker:OnSave()
    local data = {}

    if next(self.used) ~= nil then
        local used = {}
        for k, v in pairs(self.used) do
            table.insert(used, k)
        end
        data[TheWorld.meta.session_identifier] = used
    end

    for sessionid, sessionused in pairs(self.used_foreign) do
        local used = {}
        for i, v in ipairs(sessionused) do
            table.insert(used, v)
        end
        data[sessionid] = used
    end

    return { usedinsessions = data }
end

function TouchStoneTracker:OnLoad(data)
    if data ~= nil and data.usedinsessions ~= nil then
        for sessionid, sessionused in pairs(data.usedinsessions) do
            if sessionid == TheWorld.meta.session_identifier then
                for i, v in ipairs(sessionused) do
                    OnUsedTouchStoneID(self, v)
                end
            else
                local used = {}
                for i, v in ipairs(sessionused) do
                    table.insert(used, v)
                end
                self.used_foreign[sessionid] = used
            end
        end
    end
end

return TouchStoneTracker
