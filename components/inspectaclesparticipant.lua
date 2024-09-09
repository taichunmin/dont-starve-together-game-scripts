local function OnInspectaclesGameChanged_Bridge(inst, data)
    inst.components.inspectaclesparticipant:OnInspectaclesGameChanged(data)
end

local function OnClosePopup_Bridge(inst, data)
    inst.components.inspectaclesparticipant:OnClosePopup(data)
end

local function OnEquipChanged_Bridge(inst, data)
    local item = data and (data.prev_item or data.item) or nil
    if item and item:IsValid() and item:HasTag("inspectaclesvision") then
        inst.components.inspectaclesparticipant:UpdateInspectacles()
    end
end

local function OnInit_Bridge(inst)
    inst.components.inspectaclesparticipant:UpdateInspectacles()
end

local InspectaclesParticipant = Class(function(self, inst)
    self.inst = inst

    self.ismastersim = TheWorld.ismastersim
    self.GRIDSIZE = 3 -- Used in widget UI.
    self.VALIDVALUEMAX = 4 -- Constant defined strictly from the puzzle data values being from 0 to 3 inclusive.

    self.inst:ListenForEvent("inspectaclesgamechanged", OnInspectaclesGameChanged_Bridge)
    if self.ismastersim then
        self.inst:ListenForEvent("ms_closepopup", OnClosePopup_Bridge)
        self.inst:ListenForEvent("itemget", OnEquipChanged_Bridge)
        self.inst:ListenForEvent("equip", OnEquipChanged_Bridge)
        self.inst:ListenForEvent("itemlose", OnEquipChanged_Bridge)
        self.inst:ListenForEvent("unequip", OnEquipChanged_Bridge)
        self.oninittask = self.inst:DoTaskInTime(0, OnInit_Bridge)
    end
end)

function InspectaclesParticipant:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("inspectaclesgamechanged", OnClosePopup_Bridge)
    if self.ismastersim then
        self.inst:RemoveEventCallback("ms_closepopup", OnClosePopup_Bridge)
        self.inst:RemoveEventCallback("itemget", OnEquipChanged_Bridge)
        self.inst:RemoveEventCallback("equip", OnEquipChanged_Bridge)
        self.inst:RemoveEventCallback("itemlose", OnEquipChanged_Bridge)
        self.inst:RemoveEventCallback("unequip", OnEquipChanged_Bridge)
        if self.oninittask ~= nil then
            self.oninittask:Cancel()
            self.oninittask = nil
        end
    end
    if self.cooldowntask ~= nil then
        self.cooldowntask:Cancel()
        self.cooldowntask = nil
    end
end

function InspectaclesParticipant:OnClosePopup(data)
    if data.popup == POPUPS.INSPECTACLES then
        local solution = data.args[1] or 0
        if self:CheckGameSolution(solution) then
            self:FinishCurrentGame()
        end
    end
end

function InspectaclesParticipant:CalculateGamePuzzle(gameid, posx, posz)
    -- NOTES(JBK): This is so the client and server can generate the same random puzzle using only the game's data.
    -- This will be used as a soft check for players submitting an answer to the puzzle.
    -- The number of bits here go up to 4095 and the world tile size limit is smaller than this the positions are guaranteed to be unique.
    -- The number of unique games to play will keep the seed at an acceptable size.
    -- Uses of this bit data should not go beyond the lower 24 bits.
    -- This data is cached as self.puzzle or self.CLIENT_puzzle.
    local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(posx, 0, posz)
    local x = bit.lshift(bit.band(tx, 0xFFF), 12)
    local z = bit.band(ty, 0xFFF)
    return bit.band(gameid * (x + z), 0xFFFFFF) -- Force 24 bits truncation.
end

local function GetNext(data)
    local value = data[data.index + 1]
    data.index = (data.index + 1 ) % data.size
    return value
end

local function Reset(data)
    data.index = 0
end

function InspectaclesParticipant:MakePuzzleDataARingBuffer(data)
    -- NOTES(JBK): Meta fields to make this a ring buffer like object but lightweight.
    -- There is a RingBuffer object in utils but it is unused in the rest of the code base so I will avoid it here.
    data.size = #data
    data.index = 0
    data.GetNext = GetNext
    data.Reset = Reset
end

function InspectaclesParticipant:GetPuzzleData(puzzle)
    -- NOTES(JBK): This is a data array to be used in the puzzle and will be closely tied to what the UI does and what rewards are granted.
    -- This data is cached as self.puzzledata or self.CLIENT_puzzledata.
    local data = {}

    -- Inject values 0 through 3 evenly through it in case this is used as a random value we must guarantee all values exist at some point.
    local injectedmodulo = math.floor(11/4)
    local injectedvalue = 0
    local halfnibble = 0x3
    for i = 0, 11 do -- 24 bits eaten.
        local tinkers = bit.rshift(bit.band(puzzle, halfnibble), i * 2)
        table.insert(data, tinkers)
        halfnibble = bit.lshift(halfnibble, 2)
        if injectedvalue < 4 and i % injectedmodulo == 0 then
            table.insert(data, injectedvalue)
            injectedvalue = injectedvalue + 1
        end
    end

    self:MakePuzzleDataARingBuffer(data)

    return data
end

function InspectaclesParticipant:CheckGameSolution(solution)
    if not self.ismastersim then
        return false
    end

    --local game, puzzle, puzzledata = self:GetSERVERDetails()
    -- NOTES(JBK): This is where puzzle data could be validated with some algorithm. [IPGVR]
    -- But this is not worth the cost of time so if solution is zero it is deemed good.
    return solution == 0
end

function InspectaclesParticipant:OnInspectaclesGameChanged(data)
    if self.inst == ThePlayer then
        if data.gameid == 0 then
            self.CLIENT_game = nil
            self.CLIENT_posx = nil
            self.CLIENT_posz = nil
            self.CLIENT_puzzle = nil
            self.CLIENT_puzzledata = nil
        else
            self.CLIENT_game = INSPECTACLES_GAMES_LOOKUP[data.gameid]
            self.CLIENT_posx = data.posx
            self.CLIENT_posz = data.posz
            self.CLIENT_puzzle = self:CalculateGamePuzzle(data.gameid, data.posx, data.posz)
            self.CLIENT_puzzledata = self:GetPuzzleData(self.CLIENT_puzzle)
        end
    end
end

function InspectaclesParticipant:OnSignalPulse()
    if self.CLIENT_game then
        -- Client side.
        local tx, tz = self.CLIENT_posx, self.CLIENT_posz
        -- self.inst == ThePlayer
        self.inst:PushEvent("inspectaclesping", {tx = tx, tz = tz,})
    end
    if self.game then
        -- Server side.
        self:UpdateBox()
    end
end

function InspectaclesParticipant:IsParticipantClose(range)
    if not self.game and not self.CLIENT_game then
        return false
    end
    range = range or 4
    local rangesq = range * range

    local posx, posz
    if self.box then
        local x, y, z = self.box.Transform:GetWorldPosition()
        posx, posz = x, z
    else
        posx, posz = self.posx or self.CLIENT_posx, self.posz or self.CLIENT_posz
    end
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local dx, dz = x - posx, z - posz
    return dx * dx + dz * dz < rangesq
end

function InspectaclesParticipant:GetCLIENTDetails()
    return self.CLIENT_game, self.CLIENT_puzzle, self.CLIENT_puzzledata
end

function InspectaclesParticipant:GetSERVERDetails()
    return self.game, self.puzzle, self.puzzledata
end

function InspectaclesParticipant:IsFreeGame(game)
    -- NOTES(JBK): These games are free in that there is no minigame for them and the results should be sent immediately.
    return game == "NONE" or game:find("FREE") == 1
end

--------------------------------------------------------------------------
-- Server only but do not assert if a client tries to call these.
--------------------------------------------------------------------------
function InspectaclesParticipant:NetworkCurrentGame()
    if not self.ismastersim then
        return
    end

    local player_classified = self.inst.player_classified
    if player_classified == nil then
        return
    end

    player_classified.inspectacles_game:set_local(0) -- Force an event push in case of same game duplicates.
    if self:ShouldStopGameInteractions() then
        player_classified.inspectacles_game:set(0)
        player_classified.inspectacles_posx:set(0)
        player_classified.inspectacles_posz:set(0)
    else
        player_classified.inspectacles_game:set(INSPECTACLES_GAMES[self.game])
        player_classified.inspectacles_posx:set(self.posx)
        player_classified.inspectacles_posz:set(self.posz)
    end
end

function InspectaclesParticipant:ShouldStopGameInteractions()
    return not self.ismastersim or self.hide or not self.game or self.shardid ~= TheShard:GetShardId()
end

function InspectaclesParticipant:SetCurrentGame(gameid, posx, posz)
    if not self.ismastersim then
        return
    end

    self.game = INSPECTACLES_GAMES_LOOKUP[gameid]
    if self.game then
        self.posx = posx
        self.posz = posz
        self.puzzle = self:CalculateGamePuzzle(gameid, posx, posz)
        self.puzzledata = self:GetPuzzleData(self.puzzle)
        self.shardid = self.shardid or TheShard:GetShardId()
        -- Do not set upgraded here set it only in CreateNewAndOrShowCurrentGame.
    else
        self.posx = nil
        self.posz = nil
        self.puzzle = nil
        self.puzzledata = nil
        self.upgraded = nil
        self.shardid = nil
    end

    self:NetworkCurrentGame()
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end
function InspectaclesParticipant:FindGameLocation(gameid)
    local pt = self.inst:GetPosition()

    local foundoffset = nil
    for radius = PLAYER_CAMERA_SEE_DISTANCE, PLAYER_CAMERA_SEE_DISTANCE  - 4 * 3, -4 do
        local offset = FindWalkableOffset(pt, math.random() * TWOPI, radius, math.floor(radius * 0.25), false, true, NoHoles)
        if offset ~= nil then
            foundoffset = offset
            break
        end
    end
    if not foundoffset then
        for radius = PLAYER_CAMERA_SEE_DISTANCE + 4, PLAYER_CAMERA_SEE_DISTANCE + 4 * 3, 4 do
            local offset = FindWalkableOffset(pt, math.random() * TWOPI, radius, math.floor(radius * 0.25), false, true, NoHoles)
            if offset ~= nil then
                foundoffset = offset
                break
            end
        end
    end

    if not foundoffset then
        return nil, nil
    end
    return pt.x + foundoffset.x, pt.z + foundoffset.z
end

local BLOCKERS_ONEOF_TAGS = {"structure", "blocker", "antlion_sinkhole_blocker"}
local BLOCKERS_RADIUS = 2
local BLOCKERS_ATTEMPTS_TO_FIND_CLEARING = 10
function InspectaclesParticipant:CreateBox()
    if not self.ismastersim or self.box then
        return
    end

	self.box = SpawnPrefab(self:IsUpgradedBox() and "inspectaclesbox2" or "inspectaclesbox")
    local spawnx, spawnz = self.posx, self.posz
    local ents = TheSim:FindEntities(spawnx, 0, spawnz, BLOCKERS_RADIUS, nil, nil, BLOCKERS_ONEOF_TAGS)
    if ents[1] ~= nil then -- Not clear.
        local offset = nil
        for tries = 1, BLOCKERS_ATTEMPTS_TO_FIND_CLEARING do
            local pt = Vector3(spawnx, 0, spawnz)
            offset = FindWalkableOffset(pt, math.random() * PI2, BLOCKERS_RADIUS, 8, true, true)
            if offset ~= nil then
                spawnx, spawnz = spawnx + offset.x, spawnz + offset.z -- Intentional random walk.
                ents = TheSim:FindEntities(spawnx, 0, spawnz, BLOCKERS_RADIUS, nil, nil, BLOCKERS_ONEOF_TAGS)
                if ents[1] == nil then -- Clear!
                    break
                end
            end
        end
    end
    self.box.Transform:SetPosition(spawnx, 0, spawnz)
    if self:IsFreeGame(self.game) then
        self.box:SetRepaired()
    end
    self.box:SetViewingOwner(self.inst)
    self.inst:ListenForEvent("onremove", function()
        self.box = nil
    end, self.box)
    self.box:ListenForEvent("onremove", function(inst)
        self.box:DoTaskInTime(0, self.box.Remove) -- Delay a frame to prevent stack overflows in loading sequences.
    end, self.inst)
end

function InspectaclesParticipant:CanCreateGameInWorld()
    return not TheWorld:HasTag("cave")
end

function InspectaclesParticipant:CreateNewAndOrShowCurrentGame()
    if not self.ismastersim or self.cooldowntask ~= nil or not self:CanCreateGameInWorld() then
        return false
    end

    if not self.game then
        local gameid = math.random(1, #INSPECTACLES_GAMES_LOOKUP)
        local posx, posz = self:FindGameLocation(gameid)
        if not posx then
            return false
        end
        posx = math.clamp(math.floor(posx), -32767, 32767) -- Transform floats to netvar integers.
        posz = math.clamp(math.floor(posz), -32767, 32767)
        self:SetCurrentGame(gameid, posx, posz)

        local skilltreeupdater = self.inst.components.skilltreeupdater
        self.upgraded = skilltreeupdater and skilltreeupdater:IsActivated("winona_wagstaff_2") and math.random() < TUNING.SKILLS.WINONA.INSPECTACLES_UPGRADE_CHANCE or nil
    end

    self:UpdateBox()
    self:ShowCurrentGame()
    return true
end

function InspectaclesParticipant:FinishCurrentGame()
    if self:ShouldStopGameInteractions() then
        return
    end

    self:GrantRewards()
    self:SetCurrentGame(nil)
    self:ApplyCooldown()
    self:UpdateInspectacles()
end

function InspectaclesParticipant:UpdateBox()
    if not self.ismastersim then
        return
    end

    if self.box == nil then
        self:CreateBox()
    end
end

function InspectaclesParticipant:GrantRewards()
    if not self.ismastersim then
        return
    end

    self:UpdateBox()
    self.box:DoLootPinata()
end

function InspectaclesParticipant:UpdateInspectacles()
    if not self.ismastersim then
        return
    end

    local items = self.inst.components.inventory:ReferenceAllItems()
    for _, item in ipairs(items) do
        if item:HasTag("inspectaclesvision") and item.UpdateInspectacles then
            item:UpdateInspectacles()
        end
    end
end

function InspectaclesParticipant:HideCurrentGame()
    if not self.ismastersim or not self.game or self.hide then
        return
    end

    self.hide = true
    self:NetworkCurrentGame()
end

function InspectaclesParticipant:ShowCurrentGame()
    if not self.ismastersim or not self.game or not self.hide then
        return
    end

    self.hide = nil
    self:NetworkCurrentGame()
end

function InspectaclesParticipant:OnCooldownFinished()
    if self.cooldowntask ~= nil then
        self.cooldowntask:Cancel()
        self.cooldowntask = nil
    end
    if self.inst.components.inventory:EquipHasTag("inspectaclesvision") then
        self:CreateNewAndOrShowCurrentGame()
    end
    self:UpdateInspectacles()
end

local function OnCooldownFinished_Bridge(inst)
    inst.components.inspectaclesparticipant:OnCooldownFinished()
end

function InspectaclesParticipant:ApplyCooldown(overridetime)
    if not self.ismastersim or self.game then
        return
    end

    if self.cooldowntask ~= nil then
        self.cooldowntask:Cancel()
        self.cooldowntask = nil
    end
    local cooldowntime = overridetime or TUNING.SKILLS.WINONA.INSPECTACLES_COOLDOWNTIME
    self.cooldowntask = self.inst:DoTaskInTime(cooldowntime, OnCooldownFinished_Bridge)
end

function InspectaclesParticipant:IsInCooldown()
    return self.cooldowntask ~= nil
end

function InspectaclesParticipant:IsUpgradedBox()
    return self.upgraded
end

--------------------------------------------------------------------------

function InspectaclesParticipant:LongUpdate(dt)
    if self.cooldowntask ~= nil then
        local cooldowntime = GetTaskRemaining(self.cooldowntask) - dt
        self.cooldowntask:Cancel()
        self.cooldowntask = nil
        if cooldowntime > 0 then
            self.cooldowntask = self.inst:DoTaskInTime(cooldowntime, OnCooldownFinished_Bridge)
        end
    end
end

function InspectaclesParticipant:OnSave()
    if self.game ~= nil then
        return {
            hide = self.hide,
            game = self.game,
            posx = self.posx,
            posz = self.posz,
            upgraded = self.upgraded,
            shardid = self.shardid,
        }
    end

    if self.cooldowntask ~= nil then
        return {
            cooldown = GetTaskRemaining(self.cooldowntask),
        }
    end

    return nil
end

function InspectaclesParticipant:OnLoad(data)
    if data == nil then
        return
    end

    self.upgraded = data.upgraded
    if data.game then
        local gameid = INSPECTACLES_GAMES[data.game]
        self.hide = data.hide
        self.shardid = data.shardid or TheShard:GetShardId()
        self:SetCurrentGame(gameid, data.posx or 0, data.posz or 0)
    elseif data.cooldown then
        self:ApplyCooldown(data.cooldown)
    end
end

function InspectaclesParticipant:LongUpdate(dt)
    if self.cooldowntask ~= nil then
        local remaining = GetTaskRemaining(self.cooldowntask) - dt
        self.cooldowntask:Cancel()
        if remaining > 0 then
            self.cooldowntask = self.inst:DoTaskInTime(cooldowntime, OnCooldownFinished_Bridge)
        else
            self.cooldowntask = nil
            self:OnCooldownFinished()
        end
    end
end

--------------------------------------------------------------------------

function InspectaclesParticipant:GetDebugString()
    local game = self.game or self.CLIENT_game
    if game == nil then
        if self.ismastersim then
            return string.format("NO GAME, Cooldown %f", GetTaskRemaining(self.cooldowntask))
        end
        return "NO GAME"
    end
    local posx = self.posx or self.CLIENT_posx
    local posz = self.posz or self.CLIENT_posz
    local puzzle = self.puzzle or self.CLIENT_puzzle
    local shardid = self.shardid or "N/A"

    return string.format("%s%s @(%d, %d) Puzzle %X Shard %s", self.hide and "[HIDDEN] " or "", game, posx, posz, puzzle, shardid)
end

return InspectaclesParticipant
