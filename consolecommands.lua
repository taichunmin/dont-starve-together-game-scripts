-- not local - debugkeys use it too
function ConsoleCommandPlayer()
    return (c_sel() ~= nil and c_sel():HasTag("player") and c_sel()) or ThePlayer or AllPlayers[1]
end

function ConsoleWorldPosition()
    return TheInput.overridepos or TheInput:GetWorldPosition()
end

function ConsoleWorldEntityUnderMouse()
    if TheInput.overridepos == nil then
        return TheInput:GetWorldEntityUnderMouse()
    else
        local x, y, z = TheInput.overridepos:Get()
        local ents = TheSim:FindEntities(x, y, z, 1)
        for i, v in ipairs(ents) do
            if v.entity:IsVisible() then
                return v
            end
        end
    end
end

local function ListingOrConsolePlayer(input)
    if type(input) == "string" or type(input) == "number" then
        return UserToPlayer(input)
    end
    return input or ConsoleCommandPlayer()
end

local function Spawn(prefab)
    --TheSim:LoadPrefabs({prefab})
    return SpawnPrefab(prefab)
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Console Functions -- These are simple helpers made to be typed at the console.
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

-- Show server announcements:
-- To send a one time announcement:   c_announce(msg)
-- To repeat a periodic announcement: c_announce(msg, interval)
-- To cancel a periodic announcement: c_announce()
function c_announce(msg, interval, category)
    if msg == nil then
        if TheWorld.__announcementtask ~= nil then
            TheWorld.__announcementtask:Cancel()
            TheWorld.__announcementtask = nil
        end
    elseif interval == nil or interval <= 0 then
        if category == "system" then
            TheNet:SystemMessage(msg)
        else
            TheNet:Announce(msg, nil, nil, category)
        end
    else
        if TheWorld.__announcementtask ~= nil then
            TheWorld.__announcementtask:Cancel()
        end
        TheWorld.__announcementtask =
            TheWorld:DoPeriodicTask(
                interval,
                category == "system" and
                function() TheNet:SystemMessage(msg) end or
                function() TheNet:Announce(msg, nil, nil, category) end,
                0
            )
    end
end

local function doreset()
    StartNextInstance({
        reset_action = RESET_ACTION.LOAD_SLOT,
        save_slot = SaveGameIndex:GetCurrentSaveSlot()
    })
end

-- * Roll back *count* number of saves (default 1)
-- * c_rollback() or c_rollback(1) will roll back to the
--   last save file, if it's been longer than 30 seconds
-- * c_rollback(0) is the same as c_reset()
function c_rollback(count)
    if TheWorld ~= nil and TheWorld.ismastersim then
        TheNet:SendWorldRollbackRequestToServer(count)
    end
end

-- Restart the server to the last save file (same as c_rollback(0))
function c_reset()
    if not InGamePlay() then
        StartNextInstance()
    elseif TheWorld ~= nil and TheWorld.ismastersim then
        TheNet:SendWorldRollbackRequestToServer(0)
    end
end

-- Permanently delete the game world, regenerates a new world afterwards
-- NOTE: It is not recommended to use this instead of c_regenerateworld,
--       unless you need to regenerate only one shard in a cluster
function c_regenerateshard(wipesettings)
    local shouldpreserve = true
    if wipesettings ~= nil then
        shouldpreserve = not wipesettings
    end
    if TheWorld ~= nil and TheWorld.ismastersim then
        SaveGameIndex:DeleteSlot(
            SaveGameIndex:GetCurrentSaveSlot(),
            doreset,
            shouldpreserve
        )
    end
end

-- Permanently delete all game worlds in a server cluster, regenerates new worlds afterwards
-- NOTE: This will not work properly for any shard that is offline or in a loading state
function c_regenerateworld()
    if TheWorld ~= nil and TheWorld.ismastersim then
        TheNet:SendWorldResetRequestToServer()
    end
end

function c_save()
    if TheWorld ~= nil and TheWorld.ismastersim then
        TheWorld:PushEvent("ms_save")
    end
end

-- Shutdown the application, optionally close with out saving (saves by default)
function c_shutdown(save)
    print("c_shutdown", save)
    if save == false or TheWorld == nil then
        Shutdown()
    elseif TheWorld.ismastersim then
        for i, v in ipairs(AllPlayers) do
            v:OnDespawn()
        end
        TheSystemService:EnableStorage(true)
        SaveGameIndex:SaveCurrent(Shutdown, true)
    else
        SerializeUserSession(ThePlayer)
        Shutdown()
    end
end

-- Remotely execute a lua string
function c_remote( fnstr )
    local x, y, z = TheSim:ProjectScreenPos(TheSim:GetPosition())
    TheNet:SendRemoteExecute(fnstr, x, z)
end

-- Spawn At Cursor and select the new ent
-- Has a gimpy short name so it's easier to type from the console
function c_spawn(prefab, count, dontselect)
    count = count or 1
    local inst = nil

    prefab = string.lower(prefab)

    for i = 1, count do
        inst = DebugSpawn(prefab)
        if inst.components.skinner ~= nil and IsRestrictedCharacter(prefab) then
            inst.components.skinner:SetSkinMode("normal_skin")
        end
    end
    if not dontselect then
        SetDebugEntity(inst)
    end
    SuUsed("c_spawn_"..prefab, true)
    return inst
end

-- c_despawn helper
local function dodespawn(player)
    if TheWorld ~= nil and TheWorld.ismastersim then
        --V2C: #spawn #despawn
        --     This was where we used to announce player left.
        --     Now we announce it when you actually disconnect
        --     but not during a shard migration disconnection.
        --TheNet:Announce(string.format(STRINGS.UI.NOTIFICATION.LEFTGAME, player:GetDisplayName()), player.entity, true, "leave_game")

        --Delete must happen when the player is actually removed
        --This is currently handled in playerspawner listening to ms_playerdespawnanddelete
        TheWorld:PushEvent("ms_playerdespawnanddelete", player)
    end
end

-- Despawn a player, returning to character select screen
function c_despawn(player)
    if TheWorld ~= nil and TheWorld.ismastersim then
        --V2C: need to avoid targeting c_spawned player entities
        --player = ListingOrConsolePlayer(player)
        if type(player) == "string" or type(player) == "number" then
            player = UserToPlayer(input)
        end
        if player == nil then
            player = c_sel() ~= nil and c_sel():HasTag("player") and c_sel() or nil
        end
        if player == nil or player.components.playercontroller == nil then
            player = ThePlayer or AllPlayers[1]
        end
        -------------------------------------------------------------------
        if player ~= nil and player:IsValid() then
            --Queue it because remote command may currently be overriding
            --ThePlayer, which will get stomped during delete
            player:DoTaskInTime(0, dodespawn)
        end
    end
end

function c_getnumplayers()
    print(#AllPlayers)
end

function c_getmaxplayers()
    print(TheNet:GetDefaultMaxPlayers())
end

-- Return a listing of currently active players
function c_listplayers()
    local isdedicated = not TheNet:GetServerIsClientHosted()
    local index = 1
    for i, v in ipairs(TheNet:GetClientTable()) do
        if not isdedicated or v.performance == nil then
            print(string.format("%s[%d] (%s) %s <%s>", v.admin and "*" or " ", index, v.userid, v.name, v.prefab))
            index = index + 1
        end
    end
end

-- Return a listing of AllPlayers table
function c_listallplayers()
    for i, v in ipairs(AllPlayers) do
        print(string.format("[%d] (%s) %s <%s>", i, v.userid, v.name, v.prefab))
    end
end

-- Get the currently selected entity, so it can be modified etc.
-- Has a gimpy short name so it's easier to type from the console
function c_sel()
    return GetDebugEntity()
end

function c_select(inst)
    if not inst then
        inst = ConsoleWorldEntityUnderMouse()
    end
    print("Selected "..tostring(inst or "<nil>") )
    SetDebugEntity(inst)
    return inst
end

-- Print the (visual) tile under the cursor
function c_tile()
    local s = ""

    local map = TheWorld.Map
    local mx, my, mz = ConsoleWorldPosition():Get()
    local tx, ty = map:GetTileCoordsAtPoint(mx,my,mz)
    s = s..string.format("world[%f,%f,%f] tile[%d,%d] ", mx,my,mz, tx,ty)

    local tile = map:GetTileAtPoint(ConsoleWorldPosition():Get())
    for k,v in pairs(GROUND) do
        if v == tile then
            s = s..string.format("ground[%s] ", k)
            break
        end
    end

    print(s)
end

-- Apply a scenario script to the selection and run it.
function c_doscenario(scenario)
    local inst = GetDebugEntity()
    if not inst then
        print("Need to select an entity to apply the scenario to.")
        return
    end
    if inst.components.scenariorunner then
        inst.components.scenariorunner:ClearScenario()
    end

    -- force reload the script -- this is for testing after all!
    package.loaded["scenarios/"..scenario] = nil

    inst:AddComponent("scenariorunner")
    inst.components.scenariorunner:SetScript(scenario)
    inst.components.scenariorunner:Run()
    SuUsed("c_doscenario_"..scenario, true)
end


-- Some helper shortcut functions
function c_freecrafting()
    local player = ConsoleCommandPlayer()
	player.components.builder:GiveAllRecipes() 
	player:PushEvent("techlevelchange")
end


function c_sel_health()
    if c_sel() then
        local health = c_sel().components.health
        if health then
            return health
        else
            print("Gah! Selection doesn't have a health component!")
            return
        end
    else
        print("Gah! Need to select something to access it's components!")
    end
end

function c_sethealth(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.health ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_sethealth", true)
        player.components.health:SetPercent(math.min(n, 1))
    end
end

function c_setminhealth(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.health ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_minhealth", true)
        player.components.health:SetMinHealth(n)
    end
end

function c_setsanity(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.sanity ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_setsanity", true)
        player.components.sanity:SetPercent(math.min(n, 1))
    end
end

function c_sethunger(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.hunger ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_sethunger", true)
        player.components.hunger:SetPercent(math.min(n, 1))
    end
end

function c_setbeaverness(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.beaverness ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_setbeaverness", true)
        player.components.beaverness:SetPercent(math.min(n, 1))
    end
end

function c_setmoisture(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.moisture ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_setmoisture", true)
        player.components.moisture:SetPercent(math.min(n, 1))
    end
end

function c_settemperature(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.temperature ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_settemperature", true)
        player.components.temperature:SetTemperature(n)
    end
end

-- Work in progress direct connect code.
-- Currently, to join an online server you must authenticate first.
-- In the future this authentication will be taken care of for you.
function c_connect(ip, port, password)
    if not InGamePlay() and TheNet:StartClient(ip, port, 0, password) then
        DisableAllDLC()
        return true
    end
    return false
end

-- Put an item(s) in the player's inventory
function c_give(prefab, count, dontselect)
    local MainCharacter = ConsoleCommandPlayer()

    prefab = string.lower(prefab)

    if MainCharacter ~= nil then
        for i = 1, count or 1 do
            local inst = DebugSpawn(prefab)
            if inst ~= nil then
                print("giving ", inst)
                MainCharacter.components.inventory:GiveItem(inst)
                if not dontselect then
                    SetDebugEntity(inst)
                end
                SuUsed("c_give_"..inst.prefab)
            end
        end
    end
end

function c_mat(recname)
    local player = ConsoleCommandPlayer()
    local recipe = AllRecipes[recname]
    if player.components.inventory and recipe then
        for ik, iv in pairs(recipe.ingredients) do
            for i = 1, iv.amount do
                local item = SpawnPrefab(iv.type)
                player.components.inventory:GiveItem(item)
                SuUsed("c_mat_" .. iv.type , true)
            end
        end
    end
end

function c_pos(inst)
    return inst ~= nil and inst:GetPosition() or nil
end

function c_printpos(inst)
    print(c_pos(inst))
end

function c_teleport(x, y, z, inst)
    inst = ListingOrConsolePlayer(inst)
    if inst ~= nil then
        inst.Transform:SetPosition(x, y, z)
        SuUsed("c_teleport", true)
    end
end

function c_move(inst)
    inst = inst or c_sel()
    if inst ~= nil then
        inst.Transform:SetPosition(ConsoleWorldPosition():Get())
        SuUsed("c_move", true)
    end
end

function c_goto(dest, inst)
    if type(dest) == "string" or type(dest) == "number" then
        dest = UserToPlayer(dest)
    end
    if dest ~= nil then
        inst = ListingOrConsolePlayer(inst)
        if inst ~= nil then
            if inst.Physics ~= nil then
                inst.Physics:Teleport(dest.Transform:GetWorldPosition())
            else
                inst.Transform:SetPosition(dest.Transform:GetWorldPosition())
            end
            SuUsed("c_goto", true)
            return dest
        end
    end
end

function c_inst(guid)
    return Ents[guid]
end

function c_list(prefab)
    local x,y,z = ConsoleCommandPlayer().Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 9001)
    for k,v in pairs(ents) do
        if v.prefab == prefab then
            print(string.format("%s {%2.2f, %2.2f, %2.2f}", tostring(v), v.Transform:GetWorldPosition()))
        end
    end
end

function c_listtag(tag)
    local tags = {tag}
    local x,y,z = ConsoleCommandPlayer().Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 9001, tags)
    for k,v in pairs(ents) do
        print(string.format("%s {%2.2f, %2.2f, %2.2f}", tostring(v), v.Transform:GetWorldPosition()))
    end
end

local lastroom = -1
function c_gotoroom(roomname, inst)
    inst = ListingOrConsolePlayer(inst)
    if inst == nil then
        return
    end

    local found = nil
    local foundid = nil
    local reallowest = nil
    local reallowestid = nil
    local count = 0

    print("Finding room containing",roomname)

    roomname = string.lower(roomname)

    for i, node in ipairs(TheWorld.topology.nodes) do
        if string.lower(TheWorld.topology.ids[i]):find(roomname) then
            if reallowest == nil then
                reallowest = node
                reallowestid = i
            end
            count = count + 1
            if i > lastroom then
                found = node
                foundid = i
                break
            end
        end
    end

    if found == nil and reallowest ~= nil then
        found = reallowest
        foundid = reallowestid
    end

    if found ~= nil then
        print("Going to ", TheWorld.topology.ids[foundid], "("..count..")")
        c_teleport(found.cent[1],0,found.cent[2],inst)
        lastroom = foundid
    else
        print("Couldn't find a matching room.")
    end
end

local lastfound = -1
local lastprefab = nil
function c_findnext(prefab, radius, inst)
    if type(inst) == "string" or type(inst) == "number" then
        inst = UserToPlayer(input)
        if inst == nil then
            return
        end
    end
    inst = inst or ConsoleCommandPlayer() or TheWorld
    if inst == nil then
        return
    end
    prefab = prefab or lastprefab
    lastprefab = prefab

    local trans = inst.Transform
    local found = nil
    local foundlowestid = nil
    local reallowest = nil
    local reallowestid = nil
    local reallowestidx = -1

    print("Finding a ",prefab)

    local x,y,z = trans:GetWorldPosition()
    local ents = {}
    if radius == nil then
        ents = Ents
    else
        -- note: this excludes CLASSIFIED
        ents = TheSim:FindEntities(x,y,z, radius)
    end
    local total = 0
    local idx = -1
    for k,v in pairs(ents) do
        if v ~= inst and v.prefab == prefab then
            total = total+1
            if v.GUID > lastfound and (foundlowestid == nil or v.GUID < foundlowestid) then
                idx = total
                found = v
                foundlowestid = v.GUID
            end
            if not reallowestid or v.GUID < reallowestid then
                reallowest = v
                reallowestid = v.GUID
                reallowestidx = total
            end
        end
    end
    if not found then
        found = reallowest
        idx = reallowestidx
    end
    if not found then
        print("Could not find any objects matching '"..prefab.."'.")
        lastfound = -1
    else
        print(string.format("Found %s (%d/%d)", found.GUID, idx, total ))
        lastfound = found.GUID
    end
    return found
end

function c_godmode(player)
    player = ListingOrConsolePlayer(player)
    if player ~= nil then
        SuUsed("c_godmode", true)
        if player:HasTag("playerghost") then
            player:PushEvent("respawnfromghost")
            print("Reviving "..player.name.." from ghost.")
            return
        elseif player:HasTag("corpse") then
            player:PushEvent("respawnfromcorpse")
            print("Reviving "..player.name.." from corpse.")
            return
        elseif player.components.health ~= nil then
            local godmode = player.components.health.invincible
            player.components.health:SetInvincible(not godmode)
            print("God mode: "..tostring(not godmode))
        end
    end
end

function c_supergodmode(player)
    player = ListingOrConsolePlayer(player)
    if player ~= nil then
        SuUsed("c_supergodmode", true)
        if player:HasTag("playerghost") then
            player:PushEvent("respawnfromghost")
            print("Reviving "..player.name.." from ghost.")
            return
        elseif player.components.health ~= nil then
            local godmode = player.components.health.invincible
            player.components.health:SetInvincible(not godmode)
            c_sethealth(1)
            c_setsanity(1)
            c_sethunger(1)
            c_settemperature(25)
            c_setmoisture(0)
            print("God mode: "..tostring(not godmode))
        end
    end
end

function c_armor(player)
    player = ListingOrConsolePlayer(player)
    if player ~= nil then
        SuUsed("c_armor", true)
        player.components.health:SetAbsorptionAmount(1)
        print("Enabled full absorption on " .. tostring(player.userid))
	end
end

function c_armour(player)
	c_armor(player)
end

function c_find(prefab, radius, inst)
    inst = ListingOrConsolePlayer(inst)
    if inst == nil then
        return
    end
    radius = radius or 9001

    local trans = inst.Transform
    local found = nil
    local founddistsq = nil

    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, radius)
    for k,v in pairs(ents) do
        if v ~= inst and v.prefab == prefab then
            if not founddistsq or inst:GetDistanceSqToInst(v) < founddistsq then 
                found = v
                founddistsq = inst:GetDistanceSqToInst(v)
            end
        end
    end
    return found
end

function c_findtag(tag, radius, inst)
    inst = ListingOrConsolePlayer(inst)
    return inst ~= nil and GetClosestInstWithTag(tag, inst, radius or 1000) or nil
end

function c_gonext(name)
    name = string.lower(name)
    return c_goto(c_findnext(name))
end

function c_printtextureinfo( filename )
    TheSim:PrintTextureInfo( filename )
end

function c_simphase(phase)
    TheWorld:PushEvent("phasechange", {newphase = phase})
end

function c_countprefabs(prefab, noprint)
    local count = 0
    for k,v in pairs(Ents) do
        if v.prefab == prefab then
            count = count + 1
        end
    end
    if not noprint then
        print("There are ", count, prefab.."s in the world.")
    end
    return count
end

function c_counttagged(tag, noprint)
    local count = 0
    for k,v in pairs(Ents) do
        if v:HasTag(tag) then
            count = count + 1
        end
    end
    if not noprint then
        print("There are ", count, tag.."-tagged ents in the world.")
    end
    return count
end

function c_countallprefabs()
    local total = 0
    local unk = 0
    local counted = {}
    for k,v in pairs(Ents) do
        if v.prefab ~= nil then
            if counted[v.prefab] == nil then
            counted[v.prefab] = 1
            else
                counted[v.prefab] = counted[v.prefab] + 1
            end
            total = total + 1
        else
            unk = unk + 1
        end
    end

    local function pairsByKeys (t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
    end

    for k,v in pairsByKeys(counted) do
        print(k, v)
    end

    print(string.format("There are %d different prefabs in the world, %d total (and %d unknown)", GetTableSize(counted), total, unk))
end

function c_speedmult(multiplier)
    local inst = ConsoleCommandPlayer()
    if inst ~= nil then
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "c_speedmult", multiplier)
    end
end

function c_dump()
    local ent = GetDebugEntity()
    if not ent then
        ent = ConsoleWorldEntityUnderMouse()
    end
    DumpEntity(ent)
end

function c_dumpseasons()
    local str = TheWorld.net.components.seasons:GetDebugString()
    print(str)
end

function c_dumpworldstate()
    print("")
    print("//======================== DUMPING WORLD STATE ========================\\\\")
    print("\n"..TheWorld.components.worldstate:Dump())
    print("\\\\=====================================================================//")
    print("")
end

function c_worldstatedebug()
    WORLDSTATEDEBUG_ENABLED = not WORLDSTATEDEBUG_ENABLED
end

function c_makeinvisible()
    local player = ConsoleCommandPlayer()
    player:AddTag("debugnoattack")
    print("Has debugnoattack tag?", player, player:HasTag("debugnoattack"))
end

function c_selectnext(name)
    return c_select(c_findnext(name))
end

function c_selectnear(prefab, rad)
    local player = ConsoleCommandPlayer()
    local x,y,z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, rad or 30)
    local closest = nil
    local closeness = nil
    for k,v in pairs(ents) do
			print("found", v.prefab)
        if v.prefab == prefab then
			print("found", v.prefab)
            if closest == nil or player:GetDistanceSqToInst(v) < closeness then
                closest = v
                closeness = player:GetDistanceSqToInst(v)
            end
        end
    end
    if closest then
        c_select(closest)
    end
end


function c_summondeerclops()
    local player = ConsoleCommandPlayer()
    if player then 
        TheWorld.components.deerclopsspawner:SummonMonster(player)
    end
end

function c_summonbearger()
    local player = ConsoleCommandPlayer()
    print("Summoning bearger for player ", player)
    if player then 
        TheWorld.components.beargerspawner:SummonMonster(player)
    end
end

function c_gatherplayers()
    local x,y,z = ConsoleWorldPosition():Get()
    for k,v in pairs(AllPlayers) do
        v.Transform:SetPosition(x,y,z)
    end
end

function c_speedup()
    TheSim:SetTimeScale(TheSim:GetTimeScale() *10)
    print("Speed is now ", TheSim:GetTimeScale())
end

function c_skip(num)
    num = num or 1
    LongUpdate(TUNING.TOTAL_DAY_TIME * num)
end

function c_groundtype()
    local index, table = ConsoleCommandPlayer():GetCurrentTileType()
    print("Ground type is ", index)

    for k,v in pairs(table) do 
        print(k,v)
    end
end

function c_searchprefabs(str)
    local regex = ""
    for i=1,str:len() do
        if i > 1 then
            regex = regex .. ".*"
        end
        regex = regex .. str:sub(i,i)
    end
    local res = {}
    for prefab,v in pairs(Prefabs) do
        local s,f = string.lower(prefab):find(regex)
        if s ~= nil then
            -- Tightest match first, with a bias towards the match near the beginning, and shorter prefab names
            local weight = (f-s) - (100-s)/100 - (100-prefab:len())/100
            table.insert(res, {name=prefab,weight=weight})
        end
    end

    table.sort(res, function(a,b) return a.weight < b.weight end)

    if #res == 0 then
        print("Found no prefabs matching "..str)
    elseif #res == 1 then
        print("Found a prefab called "..res[1].name)
        return res[1].name
    else
        print("Found "..tostring(#res).." matches:")
        for i,v in ipairs(res) do
            print("\t"..v.name)
        end
        return res[1].name
    end
end

function c_maintainhealth(player, percent)
    player = ListingOrConsolePlayer(player)
    if player ~= nil and player.components.health ~= nil then
        if player.debug_maintainhealthtask ~= nil then
            player.debug_maintainhealthtask:Cancel()
        end
        player.debug_maintainhealthtask = player:DoPeriodicTask(3, function(inst) inst.components.health:SetPercent(percent or 1) end)
    end
end

function c_maintainsanity(player, percent)
    player = ListingOrConsolePlayer(player)
    if player ~= nil and player.components.sanity ~= nil then
        if player.debug_maintainsanitytask ~= nil then
            player.debug_maintainsanitytask:Cancel()
        end
        player.debug_maintainsanitytask = player:DoPeriodicTask(3, function(inst) inst.components.sanity:SetPercent(percent or 1) end)
    end
end

function c_maintainhunger(player, percent)
    player = ListingOrConsolePlayer(player)
    if player ~= nil and player.components.hunger ~= nil then
        if player.debug_maintainhungertask ~= nil then
            player.debug_maintainhungertask:Cancel()
        end
        player.debug_maintainhungertask = player:DoPeriodicTask(3, function(inst) inst.components.hunger:SetPercent(percent or 1) end)
    end
end

function c_maintaintemperature(player, temp)
    player = ListingOrConsolePlayer(player)
    if player ~= nil and player.components.temperature ~= nil then
        if player.debug_maintaintemptask ~= nil then
            player.debug_maintaintemptask:Cancel()
        end
        player.debug_maintaintemptask = player:DoPeriodicTask(3, function(inst) inst.components.temperature:SetTemperature(temp or 25) end)
    end
end

function c_maintainmoisture(player, percent)
    player = ListingOrConsolePlayer(player)
    if player ~= nil and player.components.moisture ~= nil then
        if player.debug_maintainmoisturetask ~= nil then
            player.debug_maintainmoisturetask:Cancel()
        end
        player.debug_maintainmoisturetask = player:DoPeriodicTask(3, function(inst) inst.components.moisture:SetPercent(percent or 0) end)
    end
end

-- Use this instead of godmode if you still want to see deltas and things
function c_maintainall(player)
    player = ListingOrConsolePlayer(player)
    if player ~= nil then
        c_maintainhealth(player)
        c_maintainsanity(player)
        c_maintainhunger(player)
        c_maintaintemperature(player)
        c_maintainmoisture(player)
    end
end

function c_cancelmaintaintasks(player)
    player = ListingOrConsolePlayer(player)
    if player ~= nil then
        if player.debug_maintainhealthtask ~= nil then
            player.debug_maintainhealthtask:Cancel()
            player.debug_maintainhealthtask = nil
        end
        if player.debug_maintainsanitytask ~= nil then
            player.debug_maintainsanitytask:Cancel()
            player.debug_maintainsanitytask = nil
        end
        if player.debug_maintainhungertask ~= nil then
            player.debug_maintainhungertask:Cancel()
            player.debug_maintainhungertask = nil
        end
        if player.debug_maintaintemptask ~= nil then
            player.debug_maintaintemptask:Cancel()
            player.debug_maintaintemptask = nil
        end
        if player.debug_maintainmoisturetask ~= nil then
            player.debug_maintainmoisturetask:Cancel()
            player.debug_maintainmoisturetask = nil
        end
    end
end

function c_removeallwithtags(...)
    local count = 0
    for k,ent in pairs(Ents) do
        for i,tag in ipairs(arg) do
            if ent:HasTag(tag) then
                ent:Remove()
                count = count + 1
                break
            end
        end
    end
    print("removed",count)
end

function c_netstats()
    local stats = TheNet:GetNetworkStatistics()
    if not stats then print("No Netstats yet") end

    for k,v in pairs(stats) do
        print(k.." -> "..tostring(v))
    end
end

function c_removeall(name)
    local count = 0
    for k,ent in pairs(Ents) do
        if ent.prefab == name then
            ent:Remove()
            count = count + 1
        end
    end
    print("removed",count)
end

function c_forcecrash(unique)
    local path = "a"
    if unique then
        path = string.random(10, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV")
    end

    if TheWorld then
        TheWorld:DoTaskInTime(0,function() _G[path].b = 0 end)
    elseif TheFrontEnd then
        TheFrontEnd.screenroot.inst:DoTaskInTime(0,function() _G[path].b = 0 end)
    end
end

function c_knownassert(key)
    key = key or "CONFIG_DIR_WRITE_PERMISSION"

    if TheWorld then
        TheWorld:DoTaskInTime(0,function() known_assert(false, key) end)
    elseif TheFrontEnd then
        TheFrontEnd.screenroot.inst:DoTaskInTime(0,function() known_assert(false, key) end)
    end
end

function c_migrationportal(worldId, portalId)
    local inst = c_spawn("migration_portal")
    if portalId then
        inst.components.worldmigrator:SetReceivedPortal( worldId, portalId )
    else
        inst.components.worldmigrator:SetDestinationWorld( worldId )
    end
end

function c_goadventuring(player)
    player = ListingOrConsolePlayer(player)
    if player ~= nil then
        c_select(player)
        player.components.inventory:Equip( c_spawn("backpack", nil, true) )
        c_give("lantern", nil, true)
        c_give("minerhat", nil, true)
        c_give("axe", nil, true)
        c_give("pickaxe", nil, true)
        c_give("footballhat", nil, true)
        c_give("armorwood", nil, true)
        c_give("spear", nil, true)
        c_give("carrot_cooked", 10, true)
        c_give("berries_cooked", 10, true)
        c_give("smallmeat_dried", 5, true)
        c_give("flowerhat", nil, true)
        c_give("cutgrass", 20, true)
        c_give("twigs", 20, true)
        c_give("log", 20, true)
        c_give("flint", 20, true)
    end
end

function c_sounddebug()
    if not package.loaded["debugsounds"] then
        require "debugsounds"
    end
    SOUNDDEBUG_ENABLED = true
    SOUNDDEBUGUI_ENABLED = false
    TheSim:SetDebugRenderEnabled(true)
end

function c_sounddebugui()
    if not package.loaded["debugsounds"] then
        require "debugsounds"
    end
    SOUNDDEBUG_ENABLED = true
    SOUNDDEBUGUI_ENABLED = true
    TheSim:SetDebugRenderEnabled(true)
end

function c_migrateto(worldId, portalId)
    local player = ConsoleCommandPlayer()
    if player ~= nil then
        portalId = portalId or 1
        TheWorld:PushEvent(
            "ms_playerdespawnandmigrate",
            { player = player, portalid = portalId, worldid = worldId }
        )
    end
end

function c_debugshards()
    local count = 0
    print("Connected shards:")
    for k,v in pairs(Shard_GetConnectedShards()) do
        print("\t",k,v)
        count = count + 1
    end
    print(count, "shards")
    count = 0
    print("Known portals:")
    for i,v in ipairs(ShardPortals) do
        print("\t",v,v.components.worldmigrator:GetDebugString())
        count = count + 1
    end
    print(count, "known portals")
    count = 0
    print("Portal targets actually available:")
    for i,v in ipairs(ShardPortals) do
        print("\t",v,Shard_IsWorldAvailable(v.components.worldmigrator.linkedWorld))
    end
    print("Portals not known:")
    local portals = {}
    for k,v in pairs(Ents) do
        if v.components and v.components.worldmigrator then
            table.insert(portals, v)
        end
    end
    for i,v in ipairs(portals) do
        local found = false
        for i2,v2 in ipairs(ShardPortals) do
            if v == v2 then
                found = true
                break
            end
        end
        if not found then
            print("\t",v)
            count = count + 1
        end
    end
    print(count, "unknown portals")
    count = 0
end

function c_reregisterportals()
    local shards = Shard_GetConnectedShards()
    for i,v in ipairs(ShardPortals) do
        v.components.worldmigrator:SetDestinationWorld(next(shards))
    end
end

function c_repeatlastcommand()
    local history = GetConsoleHistory()
    if #history > 0 then
        if history[#history] == "c_repeatlastcommand()" then
            -- top command is this one, so we want the second last command
            history[#history] = nil
        end
        ExecuteConsoleCommand(history[#history])
    end
end

function c_startvote(commandname, playeroruserid)
    local userid = playeroruserid
    if type(userid) == "table" then
        userid = userid.userid
    elseif type(userid) == "string" or type(userid) == "number" then
        userid = UserToClientID(userid)
        if userid == nil then
            return
        end
    end
    TheNet:StartVote(smallhash(commandname), userid)
end

function c_stopvote()
    TheNet:StopVote()
end
