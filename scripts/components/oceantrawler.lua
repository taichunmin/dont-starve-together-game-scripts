local FISH_DATA = require("prefabs/oceanfishdef")

local function UpdateFishNetAnim(inst, data)
    -- Swap out the fish net anim depending on the number of fish caught
    local container = inst.components.container
    local symbolname
    if inst.components.oceantrawler:HasFishEscaped() then
        symbolname = "net_untied"
    elseif container:IsEmpty() then
        symbolname = "net_empty"
    elseif container:IsFull() then
        symbolname = "net_full"
    else
        symbolname = "net_medium"
    end
    local skinbuild = inst.AnimState:GetSkinBuild()
    if skinbuild and skinbuild ~= "" then
        inst.AnimState:OverrideItemSkinSymbol("net_empty", skinbuild, symbolname, inst.GUID, "ocean_trawler")
    else
        inst.AnimState:OverrideSymbol("net_empty", "ocean_trawler", symbolname)
    end
end

local OceanTrawler = Class(function(self, inst)
    self.inst = inst
    self.lowered = false

    self.range = 2.5 -- Check for fish range
    self.nearbytrawlerrange = 16 -- Nearby trawlers affect the chance to collect fish while sleeping
    self.nearbyshoalrange = 16 -- Range to look for ocean fish shoals
    self.checkperiod = .75 -- How often to check for fish when not sleeping
    self.catchfishchance = 0.125 -- The chance to catch a fish when entity awake
    self.sleepcheckperiod = TUNING.SEG_TIME -- Check once every segment time
    self.sleepcatchfishchance = 0.0625 -- Catch on average 1 fish per day (1 / 16 segments per day)
    self.baitcatchfishmodifier = 2 -- If bait is in the trawler, the modifer applied to the catch chance

    self.task = nil
    self.startsleeptime = 0
    self.elapsedsleeptime = 0

    self.overflowfish = {} -- The number of extra fish caught beyond the number of slots. They will pop out of the net when raised.
    self.overflowescapepercent = 0.2 -- The more fish caught when full increases the chance of them all escaping.
    self.fishescaped = false

    self.inst:AddComponent("timer")

    self.inst:ListenForEvent("itemlose", UpdateFishNetAnim)
    self.inst:ListenForEvent("itemget", UpdateFishNetAnim)
end)

function OceanTrawler:Reset()
    self:StopUpdating()
    self.lowered = false

    self.startsleeptime = 0
    self.elapsedsleeptime = 0

    self.overflowfish = {}
    self.inst:RemoveTag("trawler_fish_escaped")
    self.fishescaped = false
end

function OceanTrawler:OnSave()
    local data =
    {
        lowered = self.lowered,
        elapsedsleeptime = self.startsleeptime > 0 and self.elapsedsleeptime + GetTime() - self.startsleeptime or 0,
        overflowfish = self.overflowfish,
        fishescaped = self.fishescaped,
    }

    return data
end

function OceanTrawler:OnLoad(data)
    if data == nil then
        return
    end

    -- Also set minimap icon here depending on the raised/lowered state
    self.lowered = data.lowered
    if self.lowered then
        self:Lower()
        self.inst.MiniMapEntity:SetIcon("ocean_trawler_down.png")
    else
        self.inst.MiniMapEntity:SetIcon("ocean_trawler.png")
    end

    self.elapsedsleeptime = data.elapsedsleeptime or 0
    self.overflowfish = data.overflowfish or {}
    self.fishescaped = data.fishescaped
    if self.fishescaped then
        self.inst:AddTag("trawler_fish_escaped")
    end
end

--[[function OceanTrawler:LoadPostPass()
    self:CheckForMalbatross()
end]]

function OceanTrawler:HasCaughtItem()
    return self.inst.components.container and not self.inst.components.container:IsEmpty()
end

function OceanTrawler:HasFishEscaped()
    return self.fishescaped
end

function OceanTrawler:IsLowered()
    return self.lowered
end

function OceanTrawler:Lower()
    self.inst:AddTag("trawler_lowered")
    self.lowered = true
    self.inst.sg:GoToState("lower")
    self.inst.MiniMapEntity:SetIcon("ocean_trawler_down.png")

    if self.inst.components.container then
        self.inst.components.container.canbeopened = false
        self.inst.components.container:Close()
    end

    self:StartUpdate()
end

-- Used to determine if there's an increased chance to spawn sea creatures near lowered & full trawlers
function OceanTrawler:GetOceanTrawlerSpawnChanceModifier(spawnpoint)
    if self:IsLowered() and self.inst.components.container and self.inst.components.container:IsFull() then
        return TUNING.OCEAN_TRAWLER_SPAWN_FISH_MODIFIER
    end

    return 1
end

function OceanTrawler:GetBait(eater)
    local container = self.inst.components.container
    local fishdiet = FISH_DATA.fish[eater].diet
    if container == nil or fishdiet == nil then
        return nil
    end

    for _, item in pairs(container.slots) do
        if item ~= nil and item.components.edible ~= nil and not item:HasTag("oceanfish") then -- TODO(JBK): This is a very similar version of eater component's TestFood. Make this function more generic and global?
            for _, v in ipairs(fishdiet.caneat) do
                if type(v) == "table" then
                    for _, v2 in ipairs(v.types) do
                        if item:HasTag("edible_"..v2) then
                            return item
                        end
                    end
                elseif item:HasTag("edible_"..v) then
                    return item
                end
            end
        end
    end

    return nil
end

local INITIAL_LAUNCH_HEIGHT = 2
local SPEED_XZ = 4
local SPEED_Y = 16
local function launch_away(inst, launch_height, speed_xz, speed_y)
    -- Launch outwards from position at a random angle
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    inst.Physics:Teleport(ix, iy + launch_height, iz)
    inst.Physics:SetFriction(0.2)

    local angle = (180 - math.random() * 360) * DEGREES
    local sina, cosa = math.sin(angle), math.cos(angle)
    inst.Physics:SetVel(speed_xz * cosa, speed_y, speed_xz * sina)
end

function OceanTrawler:ReleaseOverflowFish()
    -- If there are an overflow amount of fish, spawn them out of the net
    for i, fish in ipairs(self.overflowfish) do
        local fishprefab = SpawnPrefab(fish)
        if fishprefab ~= nil then
            local pt = self.inst:GetPosition()
            fishprefab.Transform:SetPosition(pt.x, pt.y, pt.z)
            launch_away(fishprefab, INITIAL_LAUNCH_HEIGHT, SPEED_XZ, SPEED_Y)
        end
    end

    self.overflowfish = {}
end

function OceanTrawler:Raise()
    self.inst:RemoveTag("trawler_lowered")
    self.lowered = false
    self.inst.sg:GoToState("raise")
    self.inst.MiniMapEntity:SetIcon("ocean_trawler.png")

    if self.inst.components.container then
        self.inst.components.container.canbeopened = true
    end

    self:ReleaseOverflowFish()

    UpdateFishNetAnim(self.inst)
end

function OceanTrawler:Fix()
    self.inst:RemoveTag("trawler_fish_escaped")
    self.fishescaped = false
    UpdateFishNetAnim(self.inst)
end

function OceanTrawler:StopUpdating()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

local function _OnUpdate(inst, self)
    self:OnUpdate(self.checkperiod)
end

function OceanTrawler:StartUpdate()
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(self.checkperiod, _OnUpdate, (.5 + math.random() * .5) * self.checkperiod, self)
    end
end

local ESCAPE_LAUNCH_HEIGHT = 0
local ESCAPE_SPEED_XZ = 4
local ESCAPE_SPEED_Y = 1
local function ProcessFishOverflow(self, container, was_sleeping)
    local numfish = #self.overflowfish or 0
    if math.random() < self.overflowescapepercent * numfish then
        if not was_sleeping then
            local pt = self.inst:GetPosition()

            for i = 1, container:GetNumSlots() do
                local item = container:GetItemInSlot(i)
                if item ~= nil then
                    local escapedfish = SpawnAt(item.prefab, pt)
                    if escapedfish then
                        launch_away(escapedfish, ESCAPE_LAUNCH_HEIGHT, ESCAPE_SPEED_XZ, ESCAPE_SPEED_Y)
                    end
                end
            end

            self.inst.sg:GoToState("overload")
        end

        local fishToRemove = container:RemoveAllItems()
        for i, fish in ipairs(fishToRemove) do
            fish:Remove()
        end

        self.overflowfish = {}
        self.inst:AddTag("trawler_fish_escaped")
        self.fishescaped = true
    end
end

--[[function OceanTrawler:CheckForMalbatross()
    local container = self.inst.components.container
    if container == nil then
        return
    end

    local pt = self.inst:GetPosition()
    local tile_at_spawnpoint = TheWorld.Map:GetTileAtPoint(pt:Get())
    if tile_at_spawnpoint ~= WORLD_TILES.OCEAN_SWELL and tile_at_spawnpoint ~= WORLD_TILES.OCEAN_ROUGH then
        return
    end

    -- Register this as a possible malbatross spawn area if the trawler is full
    if container:IsFull() then
        TheWorld:PushEvent("ms_registerfishshoal", self.inst)
    -- Fish escaped, so malbatross won't spawn here
    elseif self:HasFishEscaped() then
        TheWorld:PushEvent("ms_unregisterfishshoal", self.inst)
    end
end]]

local function AddFish(self, fishprefab)
    local container = self.inst.components.container
    if container == nil then
        return
    end

    -- If bait is present, remove it
    local bait = self:GetBait(fishprefab)
    if bait ~= nil then
        container:RemoveItem(bait, true):Remove()
    end

    if not container:IsFull() then
        local ent = SpawnPrefab(fishprefab .. "_inv")
        container:GiveItem( ent )
    else
        table.insert(self.overflowfish, fishprefab .. "_inv")
        ProcessFishOverflow(self, container)
    end

    --self:CheckForMalbatross()
end

local OCEANTRAWLER_MUST_TAGS = { "oceantrawler" }
local OCEANTRAWLER_CANT_TAGS = { "burnt", "dead" }
local SHOAL_MUST_TAGS = { "oceanshoalspawner" }
function OceanTrawler:SimulateCatchFish()
    local container = self.inst.components.container
    if self.lowered and container then
        -- Calculate if a fish should be added to the caught list, based on the amount of ocean around the trawler, the number of nearby trawlers, and elapsed time
        if not self.fishescaped then
            local pt = self.inst:GetPosition()
            local schoolspawner = TheWorld.components.schoolspawner
            if not schoolspawner then
                return
            end

            local fishprefab = schoolspawner:GetFishPrefabAtPoint(pt)
            if fishprefab == nil then
                return
            end

            self.elapsedsleeptime = self.elapsedsleeptime + GetTime() - self.startsleeptime
            local timestocheck = math.floor(self.elapsedsleeptime / self.sleepcheckperiod)

            local percent_ocean = TheWorld.Map:CalcPercentOceanTilesAtPoint(pt.x, pt.y, pt.z, 25)
            local nearbytrawlers = TheSim:FindEntities(pt.x, pt.y, pt.z, self.nearbytrawlerrange, OCEANTRAWLER_MUST_TAGS, OCEANTRAWLER_CANT_TAGS) or 0
            local numtrawlersmodifier = #nearbytrawlers > 0 and 1 / #nearbytrawlers or 1

            local catchfishchance = self.sleepcatchfishchance * percent_ocean * numtrawlersmodifier

            for i = 1, timestocheck do
                local bait = self:GetBait(fishprefab)
                local baitchance = bait ~= nil and self.baitcatchfishmodifier or 1

                if math.random() < catchfishchance * baitchance then
                    AddFish(self, fishprefab)

                    if self.fishescaped then
                        break
                    end

                    -- An ocean shoal nearby? Send an event to notify listners
                    local shoals = TheSim:FindEntities(pt.x, pt.y, pt.z, self.nearbyshoalrange, SHOAL_MUST_TAGS)
                    if shoals ~= nil then
                        local shoal = shoals[1]
                        TheWorld:PushEvent("ms_shoalfishhooked", shoal)
                    end
                end
            end
            UpdateFishNetAnim(self.inst)
            local data = {}
            if container:IsEmpty() then
                data.empty = true
            end
            self.inst.sg:GoToState("catch", data)
        end
    end
end

function OceanTrawler:OnEntitySleep()
    self.startsleeptime = GetTime()
    if self.task ~= nil then
        self.task:Cancel()
    end
end

function OceanTrawler:OnEntityWake()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil

        -- Check if we caught anything while sleeping
        self:SimulateCatchFish()

        self.elapsedsleeptime = 0

        self:StartUpdate()
    end
end

local function CheckTrappable(inst)
    return inst.components.health == nil or not inst.components.health:IsDead()
end

local OCEAN_FISH_TAGS = { "oceanfish" }
local TRAP_NO_TAGS = { "INLIMBO", "untrappable", "_inventoryitem" }
function OceanTrawler:OnUpdate(dt)
    local container = self.inst.components.container
    if self.lowered and not self.fishescaped and container then
        local fish = FindEntity(self.inst, self.range, CheckTrappable, OCEAN_FISH_TAGS, TRAP_NO_TAGS)
        if fish ~= nil then

            local bait = self:GetBait(fish.prefab)
            local baitchance = bait ~= nil and self.baitcatchfishmodifier or 1
            if math.random() < self.catchfishchance * baitchance then
                local data = {}

                -- Empty to medium
                local status = 0
                if container:IsEmpty() then
                    data.empty = true
                end

                AddFish(self, fish.prefab)

                -- An ocean shoal fish was caught, send an event to notify listners
                if fish.components.homeseeker ~= nil
                        and fish.components.homeseeker.home ~= nil
                        and fish.components.homeseeker.home:IsValid()
                        and fish.components.homeseeker.home.prefab == "oceanfish_shoalspawner" then
                    TheWorld:PushEvent("ms_shoalfishhooked", fish.components.homeseeker.home)
                end

                fish:Remove()

                UpdateFishNetAnim(self.inst)
                self.inst.sg:GoToState("catch", data)
            end
        end
    end
end

return OceanTrawler
