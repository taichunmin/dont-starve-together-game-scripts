--NOTE: This component is used client-side as well

local LavaArenaMobTracker = Class(function(self, inst)
    self.inst = inst
    self.ents = {}
    self.count = 0

    self._onremovemob = function(ent) self:StopTracking(ent) end
end)

function LavaArenaMobTracker:StartTracking(ent)
    if self.ents[ent] == nil then
        self.ents[ent] = true
        self.inst:ListenForEvent("onremove", self._onremovemob, ent)
    end
end

function LavaArenaMobTracker:StopTracking(ent)
    if self.ents[ent] ~= nil then
        self.ents[ent] = nil
        self.inst:RemoveEventCallback("onremove", self._onremovemob, ent)
    end
end

function LavaArenaMobTracker:GetNumMobs()
    return self.count
end

function LavaArenaMobTracker:GetAllMobs()
    local ret = {}
    for k, v in pairs(self.ents) do
        table.insert(ret, k)
    end
    return ret
end

function LavaArenaMobTracker:FindMobs(x, y, z, r, musttags, canttags, mustoneoftags)
    r = r * r
    local ret = {}
    local dists = {}
    for k, v in pairs(self.ents) do
        local dsq = k:GetDistanceSqToPoint(x, 0, z)
        if dsq < r then
            local success = true
            if musttags ~= nil then
                for i, tag in ipairs(musttags) do
                    if not k:HasTag(tag) then
                        success = false
                        break
                    end
                end
            end
            if success then
                if canttags ~= nil then
                    for i, tag in ipairs(canttags) do
                        if k:HasTag(tag) then
                            success = false
                            break
                        end
                    end
                end
                if success then
                    if mustoneoftags ~= nil then
                        success = false
                        for i, tag in ipairs(mustoneoftags) do
                            if k:HasTag(tag) then
                                success = true
                                break
                            end
                        end
                    end
                    if success then
                        table.insert(ret, k)
                        dists[k] = dsq
                    end
                end
            end
        end
    end
    table.sort(ret, function(l, r) return dists[l] < dists[r] end)
    return ret
end

function LavaArenaMobTracker:ForEachMob(cb, params)
    for k, v in pairs(self.ents) do
        cb(k, params)
    end
end

return LavaArenaMobTracker
