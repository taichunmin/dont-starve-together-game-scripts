local function OnDayComplete(self)
    if not self.pause then
        self.daysgrowth = self.daysgrowth + 1
        local cb = self.callbacks[self.daysgrowth]
        if cb ~= nil then
            cb(self.inst, self.skinname)
        end
    end
end

local function OnRespawn(inst)
    inst.components.beard:Reset()
end

local Beard = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("bearded")

    self.daysgrowth = 0
    self.callbacks = {}
    self.prize = nil
    self.bits = 0
    self.insulation_factor = 1
    self.pause = nil
    self.onreset = nil

    inst:ListenForEvent("ms_respawnedfromghost", OnRespawn)

    self.isgrowing = nil --force dirty for initial EnableGrowth call
    self:EnableGrowth(true)
end)

function Beard:OnRemoveFromEntity()
    self:EnableGrowth(false)
    self.inst:RemoveTag("bearded")
    self.inst:RemoveEventCallback("ms_respawnedfromghost", OnRespawn)
end

function Beard:EnableGrowth(enable)
    if enable then
        if not self.isgrowing then
            self.isgrowing = true
            self:WatchWorldState("cycles", OnDayComplete)
        end
    elseif self.isgrowing then
        self.isgrowing = nil
        self:StopWatchingWorldState("cycles", OnDayComplete)
    end
end

function Beard:GetInsulation()
    return self.bits * TUNING.INSULATION_PER_BEARD_BIT * self.insulation_factor
end

function Beard:ShouldTryToShave(who, whithwhat)
    if self.bits == 0 then
        return false, "NOBITS"
    elseif self.canshavetest ~= nil then
        local pass, reason = self.canshavetest(self.inst, who)
        if not pass then
            return false, reason
        end
    end
    return true
end

function Beard:Shave(who, withwhat)
    if self.bits == 0 then
        return false, "NOBITS"
    elseif self.canshavetest ~= nil then
        local pass, reason = self.canshavetest(self.inst, who)
        if not pass then
            return false, reason
        end
    end

    if self.prize ~= nil then
        for k = 1 , self.bits do
            local bit = SpawnPrefab(self.prize)
            local x, y, z = self.inst.Transform:GetWorldPosition()
            bit.Transform:SetPosition(x, y + 2, z)
            local speed = 1 + math.random()
            local angle = math.random() * 2 * PI
            bit.Physics:SetVel(speed * math.cos(angle), 2 + math.random() * 3, speed * math.sin(angle))
        end
        self:Reset()
    end

    if who == self.inst and who.components.sanity ~= nil then
        who.components.sanity:DoDelta(TUNING.SANITY_SMALL)
    end

    self.inst:PushEvent("shaved")

    return true
end

function Beard:AddCallback(day, cb)
    self.callbacks[day] = cb
end

function Beard:Reset()
    self.daysgrowth = 0
    self.bits = 0
    if self.onreset ~= nil then
        self.onreset(self.inst)
    end
end

function Beard:OnSave()
    return
    {
        growth = self.daysgrowth,
        bits = self.bits,
        skinname = self.skinname
    }
end

function Beard:OnLoad(data)
    -- because there is an unknowable delay between the day callback and actually
    -- growing more hair, we need to store how much hair we _actually_ had on quit
    -- to determing the current beefalo state.
    if data.bits ~= nil then
        self.bits = data.bits
    end
    if data.growth ~= nil then
        self.daysgrowth = data.growth
    end
    if data.skinname ~= nil then
        self.skinname = data.skinname
    end
    for k = 0, self.daysgrowth do
        local cb = self.callbacks[k]
        if cb ~= nil then
            cb(self.inst, self.skinname)
        end
    end
end

function Beard:SetSkin(skinname)
    self.skinname = skinname
    for k = 0, self.daysgrowth do
        local cb = self.callbacks[k]
        if cb ~= nil then
            cb(self.inst, self.skinname)
        end
    end
end

function Beard:GetDebugString()
    local nextevent = math.huge
    for k, v in pairs(self.callbacks) do
        if k >= self.daysgrowth and k < nextevent then
            nextevent = k
        end
    end
    return string.format("Bits: %d Daysgrowth: %d Next Event: %d", self.bits, self.daysgrowth, nextevent)
end

--used for networking beard skins to client for oversized veggie pictures.
function Beard:GetBeardSkinAndLength()
    local length = 0
    for k = 0, self.daysgrowth do
        --assume that every callback equals 1 length, this works out nicely for webber and wilson, if this doesn't hold true, adjust this logic.
        if self.callbacks[k] then
            length = length + 1
        end
    end
    if length == 0 then return end --don't bother networking data that wont do anything
    return self.skinname, length
end

return Beard
