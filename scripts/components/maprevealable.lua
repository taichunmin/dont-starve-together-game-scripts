local MapRevealable = Class(function(self, inst)
    self.inst = inst

    self.refreshperiod = 1.5
    self.iconname = nil
    self.iconpriority = nil
    self.iconprefab = "globalmapicon"
    self.icon = nil
    self.task = nil
    self.revealsources = {}
    self._onremovesource = function(source)
        self:RemoveRevealSource(source)
    end

    self:Start(math.random() * self.refreshperiod)
end)

function MapRevealable:SetIcon(iconname)
    if self.iconname ~= iconname then
        self.iconname = iconname
        if self.icon ~= nil then
            self.icon.MiniMapEntity:SetIcon(iconname)
        end
    end
end

function MapRevealable:SetIconPriority(priority)
    if self.iconpriority ~= priority then
        self.iconpriority = priority
        if self.icon ~= nil then
            self.icon.MiniMapEntity:SetPriority(priority)
        end
    end
end

function MapRevealable:SetIconPrefab(prefab)
    if self.iconprefab ~= prefab then
        self.iconprefab = prefab
        if self.icon ~= nil then
            self:StopRevealing()
            self:RefreshRevealSources()
        end
    end
end

function MapRevealable:AddRevealSource(source, restriction)
    if self.revealsources[source] == nil then
        self.revealsources[source] = { restriction = restriction }
        if type(source) == "table" and source.entity ~= nil then
            self.revealsources[source].isentity = true
            self.inst:ListenForEvent("onremove", self._onremovesource, source)
        end
        self:RefreshRevealSources()
    elseif self.revealsources[source].restriction ~= restriction then
        self.revealsources[source].restriction = restriction
        self:RefreshRevealSources()
    end
end

function MapRevealable:RemoveRevealSource(source)
    if self.revealsources[source] ~= nil then
        if self.revealsources[source].isentity then
            self.inst:RemoveEventCallback("onremove", self._onremovesource, source)
        end
        self.revealsources[source] = nil
        self:RefreshRevealSources()
    end
end

function MapRevealable:RefreshRevealSources()
    if next(self.revealsources) == nil then
        self:StopRevealing()
        return
    end
    local restriction
    for k, v in pairs(self.revealsources) do
        if v.restriction == nil then
            self:StartRevealing()
            return
        else
            restriction = v.restriction
        end
    end
    self:StartRevealing(restriction)
end

function MapRevealable:StartRevealing(restriction)
    if self.icon == nil then
        self.icon = SpawnPrefab(self.iconprefab)
        if self.iconpriority ~= nil then
            self.icon.MiniMapEntity:SetPriority(self.iconpriority)
        end
        self.icon:TrackEntity(self.inst, restriction, self.iconname)
    else
        self.icon.MiniMapEntity:SetRestriction(restriction or "")
    end
end

function MapRevealable:StopRevealing()
    if self.icon ~= nil then
        self.icon:Remove()
        self.icon = nil
    end
end

local MAPREVEALER_TAGS = {"maprevealer"}
function MapRevealable:Refresh()
    if self.task ~= nil then
        if GetClosestInstWithTag(MAPREVEALER_TAGS, self.inst, PLAYER_REVEAL_RADIUS) ~= nil then
            self:AddRevealSource("maprevealer")
        else
            self:RemoveRevealSource("maprevealer")
        end
    end
end

local function Refresh(inst, self)
    self:Refresh()
end

function MapRevealable:Start(delay)
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(self.refreshperiod, Refresh, delay, self)
    end
end

function MapRevealable:Stop()
    self:RemoveRevealSource("maprevealer")
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function MapRevealable:OnRemoveFromEntity()
    self:Stop()
    local toremove = {}
    for k, v in pairs(self.revealsources) do
        table.insert(toremove, k)
    end
    for i, v in ipairs(toremove) do
        self:RemoveRevealSource(v)
    end
end

return MapRevealable
