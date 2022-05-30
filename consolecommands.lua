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
        save_slot = ShardGameIndex:GetSlot()
    })
end

function c_mermking()
    c_spawn("mermthrone")
    c_spawn("mermking")
end

function c_mermthrone()
    c_spawn("mermthrone_construction")
    c_give("kelp", 20)
    c_give("beefalowool", 15)
    c_give("pigskin", 10)
    c_give("carrot", 4)
    c_spawn("merm")
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
    if TheWorld ~= nil and not TheWorld.ismastersim then
        c_remote("c_reset()")
        return
    end

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
    if TheWorld ~= nil and not TheWorld.ismastersim then
        c_remote("c_regenerateshard()")
        return
    end
    local shouldpreserve = not wipesettings
    if TheWorld ~= nil and TheWorld.ismastersim then
        ShardGameIndex:Delete(
            doreset,
            shouldpreserve
        )
    end
end

-- Permanently delete all game worlds in a server cluster, regenerates new worlds afterwards
-- NOTE: This will not work properly for any shard that is offline or in a loading state
function c_regenerateworld()

    if TheWorld ~= nil and not TheWorld.ismastersim then
        c_remote("c_regenerateworld()")
        return
    end

    if TheWorld ~= nil and TheWorld.ismastersim then
        TheNet:SendWorldResetRequestToServer()
    end
end

function c_save()
    if TheWorld ~= nil and not TheWorld.ismastersim then
        c_remote("c_save()")
        return
    end

    if TheWorld ~= nil and TheWorld.ismastersim then
        TheWorld:PushEvent("ms_save")
    end
end

-- Shutdown the application, optionally close with out saving (saves by default)
function c_shutdown(save)
    if TheWorld ~= nil and not TheWorld.ismastersim then
        c_remote("c_shutdown()")
        return
    end

    print("c_shutdown", save)
    if save == false or TheWorld == nil then
        Shutdown()
    elseif TheWorld.ismastersim then
        for i, v in ipairs(AllPlayers) do
            v:OnDespawn()
        end
        TheSystemService:EnableStorage(true)
        ShardGameIndex:SaveCurrent(Shutdown, true)
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
        if inst and inst.components.skinner ~= nil and IsRestrictedCharacter(prefab) then
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
    if TheWorld ~= nil and not TheWorld.ismastersim then
        c_remote("c_despawn()")
        return
    end

    if TheWorld ~= nil and TheWorld.ismastersim then
        --V2C: need to avoid targeting c_spawned player entities
        --player = ListingOrConsolePlayer(player)
        if type(player) == "string" or type(player) == "number" then
            player = UserToPlayer(player)
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
    for i, v in ipairs(TheNet:GetClientTable() or {}) do
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
    if TheWorld ~= nil and not TheWorld.ismastersim then
        c_remote("c_freecrafting()")
        return
    end

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

function c_setinspiration(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.singinginspiration ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_setinspiration", true)
        player.components.singinginspiration:SetPercent(math.min(n, 1))
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

function c_setmightiness(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.mightiness then
        player.components.mightiness:SetPercent(n)
    end
end

function c_addelectricity(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.upgrademoduleowner ~= nil then
        player.components.upgrademoduleowner:AddCharge(n)
    end
end

function c_setwereness(n)
    local player = ConsoleCommandPlayer()
    if player ~= nil and player.components.wereness ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_setwereness", true)
        if type(n) == "number" then
            player.components.wereness:SetPercent(math.min(n, 1))
        else
            player.components.wereness:SetWereMode(n)
            player.components.wereness:SetPercent(1, true)
        end
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
        local first_inst = nil
        for i = 1, count or 1 do
            local inst = DebugSpawn(prefab)
            if inst ~= nil then
                if first_inst == nil then first_inst = inst end
                print("giving ", inst)
                MainCharacter.components.inventory:GiveItem(inst)
                if not dontselect then
                    SetDebugEntity(inst)
                end
                SuUsed("c_give_"..inst.prefab)
            end
        end
        return first_inst
    end
end

-- Receives a prefab and gives the player all ingredients to craft that prefab
-- Nothing happens if there's no recipe
function c_giveingredients(prefab)
    local recipe = AllRecipes[prefab]
    if recipe == nil then
        print ("No recipe found for prefab ", prefab)
        return
    end

    for i, v in ipairs(recipe.ingredients) do
        c_give(v.type, v.amount)
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
		if x == nil then
			x, y, z = ConsoleWorldPosition():Get()
		end
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
        inst = UserToPlayer(inst)
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

    if TheWorld ~= nil and not TheWorld.ismastersim then
        c_remote("c_godmode()")
        return
    end

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
    if TheWorld ~= nil and not TheWorld.ismastersim then
        c_remote("c_supergodmode()")
        return
    end

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
    if player ~= nil and player.components.health ~= nil then
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
    if name ~= nil then
        local next = c_findnext(string.lower(name))
        if next ~= nil and next.Transform ~= nil then
            return c_goto(next)
        end
    end
    return nil
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

function c_summonmalbatross()
    local player = ConsoleCommandPlayer()
    if player then
        print("Summoning malbatross at the fish shoal nearest to", player)
        TheWorld.components.malbatrossspawner:Summon(player)
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

function c_emptyworld()
    for k,ent in pairs(Ents) do
        if ent.widget == nil 
			and not ent.isplayer 
			and ent.entity:GetParent() == nil
			and ent.Network ~= nil
			and not ent:HasTag("CLASSIFIED") 
			and not ent:HasTag("INLIMBO") 
			then

            ent:Remove()
        end
    end
end

function c_netstats()
    local stats = TheNet:GetNetworkStatistics()
    if not stats then print("No Netstats yet") end

    for k,v in pairs(stats) do
        print(k.." -> "..tostring(v))
    end
end

function c_remove(entity)
    local mouseentity = entity ~= nil and entity or TheInput:GetWorldEntityUnderMouse()

    if TheWorld == nil or mouseentity == nil then
        return
    end    

    if mouseentity ~= ConsoleCommandPlayer() then
        if mouseentity.components.health then
            mouseentity.components.health:Kill()
        elseif mouseentity.Remove then
            mouseentity:Remove()
        end
    end
end

function c_removeat(x, y, z)
    local ents = TheSim:FindEntities(x,y,z, 1)
    for i, ent in ipairs(ents) do
        c_remove(ent)
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

function c_startinggear(player)
    player = ListingOrConsolePlayer(player)
    if player ~= nil then
        c_select(player)
        player.components.inventory:Equip( c_spawn("flowerhat", nil, true) )
        c_give("berries", 10, true)
        c_give("smallmeat", 5, true)
        c_give("cutgrass", 40, true)
        c_give("twigs", 40, true)
        c_give("log", 40, true)
        c_give("rocks", 40, true)
        c_give("flint", 20, true)
        c_give("goldnugget", 10, true)
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
    local localremotehistory = GetConsoleLocalRemoteHistory()
    if #history > 0 then
        if history[#history] == "c_repeatlastcommand()" then
            -- top command is this one, so we want the second last command
            history[#history] = nil
            localremotehistory[#localremotehistory] = nil
        end

        if localremotehistory[#localremotehistory] then
            ConsoleRemote("%s", {history[#history]})
        else
            ExecuteConsoleCommand(history[#history])
        end
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

function c_makeboat()
	local x, y, z = ConsoleWorldPosition():Get()

	local inst = SpawnPrefab("boat")
	inst.Transform:SetPosition(x, y, z)

	local inst = SpawnPrefab("mast")
	inst.Transform:SetPosition(x, y, z)
	inst = SpawnPrefab("steeringwheel")
	inst.Transform:SetPosition(x + 3.25, y, z)
	inst = SpawnPrefab("anchor")
	inst.Transform:SetPosition(x + 2.25, y, z + 2.25)

	inst = SpawnPrefab("oar")
	inst.Transform:SetPosition(x + 1, y, z - 2)
	inst = SpawnPrefab("oar_driftwood")
	inst.Transform:SetPosition(x + 1, y, z - 1.25)


	inst = SpawnPrefab("mast_item")
	inst.Transform:SetPosition(x - 1, y, z + 1.25)
	inst = SpawnPrefab("boatpatch")
	inst.Transform:SetPosition(x, y, z + 1.25)
	inst.components.stackable:SetStackSize(5)

	inst = SpawnPrefab("lantern")
	inst.Transform:SetPosition(x - 3.25, y, z)

	inst = SpawnPrefab("oceanfishingrod")
	inst.Transform:SetPosition(x - 3.25, y, z + 1.25)

end

function c_makecrabboat()
    local x, y, z = ConsoleWorldPosition():Get()

    local inst = SpawnPrefab("boat")
    inst.Transform:SetPosition(x, y, z)

    inst = SpawnPrefab("oar")
    inst.Transform:SetPosition(x + 1, y, z - 2)

    inst = SpawnPrefab("oar_driftwood")
    inst.Transform:SetPosition(x + 1, y, z - 1.25)

    inst = SpawnPrefab("hambat")
    inst.Transform:SetPosition(x + 1, y, z - 0.8)
    inst = SpawnPrefab("hambat")
    inst.Transform:SetPosition(x + 1, y, z - 0.8)

    inst = SpawnPrefab("boatpatch")
    inst.Transform:SetPosition(x, y, z + 1.25)
    inst.components.stackable:SetStackSize(20)

    inst = SpawnPrefab("boards")
    inst.Transform:SetPosition(x+1, y, z + 1.25)
    inst.components.stackable:SetStackSize(10)




    inst = SpawnPrefab("lantern")
    inst.Transform:SetPosition(x - 3, y, z)

    inst = SpawnPrefab("redgem")
    inst.Transform:SetPosition(x - 3.25, y, z)
    inst.components.stackable:SetStackSize(9)
    inst = SpawnPrefab("orangegem")
    inst.Transform:SetPosition(x - 3.25, y, z)
    inst.components.stackable:SetStackSize(9)
    inst = SpawnPrefab("yellowgem")
    inst.Transform:SetPosition(x - 3.25, y, z)
    inst.components.stackable:SetStackSize(9)
    inst = SpawnPrefab("greengem")
    inst.Transform:SetPosition(x - 3.25, y, z)
    inst.components.stackable:SetStackSize(9)
    inst = SpawnPrefab("bluegem")
    inst.Transform:SetPosition(x - 3.25, y, z)
    inst.components.stackable:SetStackSize(9)
    inst = SpawnPrefab("purplegem")
    inst.Transform:SetPosition(x - 3.25, y, z)
    inst.components.stackable:SetStackSize(9)

end

function c_makeboatspiral()
    local items = {
        boat_item = 1,
        steeringwheel_item = 1,
        anchor_item = 1,
        mast_item = 2,
        oar = 3,
        oar_driftwood = 1,
        propelomatic_item = 1,
		miniflare = 3,
		backpack = 3,
		redmooneye = 1,
        axe = 1,
        hammer = 1,
        pickaxe = 1,
        meat_dried = {5, 5, 5},
        boatpatch = 3,
        torch = 4,
        log = {20, 20},
        boards = {10, 10},
		lantern = 1,
        goldnugget = {5,5},
        rocks = {20,20},
        researchlab = 1,
    }

    local chord = 1.5
    local away_step = 0.25
    local theta = 0

    for prefab, stacks in pairs(items) do
		stacks = type(stacks) == "table" and stacks or {stacks}
		for _, count in pairs(stacks) do
			for i = 1, count, 1 do
				local inst = DebugSpawn(prefab)
				if inst ~= nil then

					local away = away_step * theta

					local x,y,z = inst.Transform:GetWorldPosition()
					local spiral_x = math.cos(theta) * away
					local spiral_z = math.sin(theta) * away

					x = x + spiral_x
					z = z + spiral_z
					inst.Transform:SetPosition(x, y, z)

					if away == 0 then
						away = away_step
					end

					theta = theta + chord / away

					if i == 1 and inst.components.stackable ~= nil then
						inst.components.stackable:SetStackSize(count)
						break
					end
				end
			end
		end
    end
end

function c_autoteleportplayers()
    TheWorld.auto_teleport_players = not TheWorld.auto_teleport_players
    print("auto_teleport_players:", TheWorld.auto_teleport_players)
end

function c_dumpentities()

    local ent_counts = {}

	local first = true

	local total = 0
    for k,v in pairs(Ents) do
        local name = v.prefab or (v.widget and v.widget.name) or v.name

        if(type(name) == "table") then
            name = tostring(name)
        end


		if name == nil then
			name = "NONAME"
		end
        local count = ent_counts[name]
        if count == nil then
            count = 1
        else
            count = count + 1
        end
        ent_counts[name] = count
		total = total + 1
    end

    local sorted_ent_counts = {}

    for ent, count in pairs(ent_counts) do
        table.insert(sorted_ent_counts, {ent, count})
    end

    table.sort(sorted_ent_counts, function(a,b) return a[2] > b[2] end )


    print("Entity, Count")
    for k,v in ipairs(sorted_ent_counts) do
        print(v[1] .. ",", v[2])
    end
	print("Total: ", total)
end

-- ========================================
-- Singing Shell song scripts

local note_to_semitone = {}
note_to_semitone["C"] = 1
note_to_semitone["C#"] = 2
note_to_semitone["D"] = 3
note_to_semitone["D#"] = 4
note_to_semitone["E"] = 5
note_to_semitone["F"] = 6
note_to_semitone["F#"] = 7
note_to_semitone["G"] = 8
note_to_semitone["G#"] = 9
note_to_semitone["A"] = 10
note_to_semitone["A#"] = 11
note_to_semitone["B"] = 12

local function NoteToSemitone(note)
    --print("note to semitone table:", note_to_semitone[string.upper(string.sub(note, 1, -2))])
	return tonumber(string.sub(note, -1)) * 12 + note_to_semitone[string.upper(string.sub(note, 1, -2))]
end

function c_shellsfromtable(song, startpos, placementfn, spacing_multiplier, out_of_range_mode)

    -- Example file: notetable_dsmaintheme

    song = song or require("notetable_dsmaintheme")

	if song == nil or type(song) ~= "table" then
		print("Error: Invalid 'notes' table")
		return false, "INVALID_NOTES_TABLE"
	end

	--

	local semitone_shell_start =
	{
		-- Semitone of lowest note of each shell
		singingshell_octave3 = 37,
		singingshell_octave4 = 49, -- middle C
		singingshell_octave5 = 61,
    }

    local allowed_semitone_range = { lower = 37, upper = 72 }

	local semitone_to_shell = {}
	for i = 1, 36 do
		table.insert(semitone_to_shell, "")
	end
	for i = 37, 48 do
		table.insert(semitone_to_shell, "singingshell_octave3")
	end
	for i = 49, 60 do
		table.insert(semitone_to_shell, "singingshell_octave4")
	end
	for i = 61, 72 do
		table.insert(semitone_to_shell, "singingshell_octave5")
	end

    --

    if out_of_range_mode ~= "AUTO_TRANSPOSE" and out_of_range_mode ~= "OMIT" and out_of_range_mode ~= "TRUNCATE" and out_of_range_mode ~= "TERMINATE" then
        out_of_range_mode = "AUTO_TRANSPOSE"
    end

    --

    startpos = startpos or ConsoleWorldPosition()

	placementfn = placementfn or function(currentpos, multiplier)
		-- Default placementfn spawns shells in a straight line along world x
		return Vector3( currentpos.x - 1 * multiplier, 0, currentpos.z)
	end

	spacing_multiplier = spacing_multiplier or 1

    --

    local shells_to_spawn = {}

	local spawning_pos = startpos
    local spawned_shells = {}

    local lowest_semitone = allowed_semitone_range.upper
    local highest_semitone = allowed_semitone_range.lower

	for i, notes in ipairs(song) do
		local applied_spawning_pos

		if notes.t == nil then
			spawning_pos = placementfn(spawning_pos, spacing_multiplier)
			applied_spawning_pos = spawning_pos
		else
			applied_spawning_pos = placementfn(spawning_pos, notes.t * spacing_multiplier)
		end

		if type(notes) ~= "table" then
			notes = { notes }
		end

		for _, note in ipairs(notes) do
			local sx = applied_spawning_pos.x
			local sy = applied_spawning_pos.y or 0
			local sz = applied_spawning_pos.z

			local semitone

			if type(note) == "string" then
				if tonumber(note) < 0 then
					semitone = -1
				else
					semitone = NoteToSemitone(note)
				end
			else
				-- Assume type is number
				semitone = note
            end

            if semitone >= 0 then
                lowest_semitone = math.min(semitone, lowest_semitone)
                highest_semitone = math.max(semitone, highest_semitone)

                table.insert(shells_to_spawn, {
                    semitone = semitone,
                    position = Vector3(sx, sy, sz),
                })
			end
		end
    end

    --

    local function CleanupShells(shells)
        for i, v in ipairs(shells) do
            v:Remove()
        end
    end

    local function SpawnShell(prefab, shell_data, semitones_to_raise)
        local shell = SpawnPrefab(prefab)
        shell.Transform:SetPosition(shell_data.position.x, shell_data.position.y, shell_data.position.z)
        shell.components.cyclable:SetStep(semitones_to_raise + 1, nil, true)

        return shell
    end

    local song_semitone_range = highest_semitone - lowest_semitone

    if out_of_range_mode == "AUTO_TRANSPOSE" then
        if song_semitone_range < allowed_semitone_range.upper - allowed_semitone_range.lower then
            local auto_transposition_steps = 0

            if lowest_semitone < allowed_semitone_range.lower then
                auto_transposition_steps = allowed_semitone_range.lower - lowest_semitone
            elseif highest_semitone > allowed_semitone_range.upper then
                auto_transposition_steps = -(highest_semitone - allowed_semitone_range.upper)
            end

            for i, shell_data in ipairs(shells_to_spawn) do

                local transposed_semitone = shell_data.semitone + auto_transposition_steps

                local shell_prefab = semitone_to_shell[transposed_semitone]

                if shell_prefab == nil or shell_prefab == "" then
                    print("Error: Auto-transposition failed for semitone "..shell_data.semitone.." at index "..i..".\nRemoving all spawned shell instances.")

                    CleanupShells(spawned_shells)
                    return nil
                else
                    table.insert(spawned_shells, SpawnShell(shell_prefab, shell_data, transposed_semitone - semitone_shell_start[shell_prefab]))
                end
            end
        else
            print("Error: Auto-transposition failed: Tonal range of song data is greater than 3 octaves")

            return nil
        end
    elseif out_of_range_mode == "OMIT" then
        for i, shell_data in ipairs(shells_to_spawn) do
            local shell_prefab = semitone_to_shell[shell_data.semitone]

            if shell_prefab ~= nil and shell_prefab ~= "" then
                table.insert(spawned_shells, SpawnShell(shell_prefab, shell_data, shell_data.semitone - semitone_shell_start[shell_prefab]))
            else
                print("Warning: Omitting shell at index "..i.." semitone "..shell_data.semitone..".\nSemitone outside shell tonal range 37(C3) - 72(B5).")
            end
        end
    elseif out_of_range_mode == "TRUNCATE" then
        for i, shell_data in ipairs(shells_to_spawn) do
            local shell_prefab = semitone_to_shell[shell_data.semitone]

            if shell_prefab ~= nil and shell_prefab ~= "" then
                table.insert(spawned_shells, SpawnShell(shell_prefab, shell_data, shell_data.semitone - semitone_shell_start[shell_prefab]))
            else
                print("Discontinuing shell spawning at index "..i..".\nSemitone "..shell_data.semitone.." outside shell tonal range 37(C3) - 72(B5).")

                return spawned_shells
            end
        end
    else
        -- else out_of_range_mode == "TERMINATE"
        for i, shell_data in ipairs(shells_to_spawn) do
            local shell_prefab = semitone_to_shell[shell_data.semitone]

            if shell_prefab ~= nil and shell_prefab ~= "" then
                table.insert(spawned_shells, SpawnShell(shell_prefab, shell_data, shell_data.semitone - semitone_shell_start[shell_prefab]))
            else
                print("Terminating shell spawning at index "..i..".\nSemitone "..shell_data.semitone.." outside shell tonal range 37(C3) - 72(B5).\nRemoving all spawned shell instances.")

                CleanupShells(spawned_shells)
                return nil
            end
        end
    end

	return spawned_shells
end

function c_guitartab(songdata, overrides, dont_spawn_shells)

    -- Example file: guitartab_dsmaintheme.lua

	if overrides == nil or type(overrides) ~= "table" then
		overrides = {}
    end

    songdata = songdata == nil and "guitartab_dsmaintheme" or songdata

	if type(songdata) == "string" then
		songdata = require(songdata)
	elseif type(songdata) ~= "table" then
		print("Error: Invalid file name/table")
		return false, "INVALID_SONGDATA"
	end

	local tab = songdata.tab
	if tab == nil then
		print("Error: No 'tab' table found in file")
		return false, "NO_TABLATURE_FOUND"
	end

	--

	-- Fallback to standard tuning:									E2, A2, D3, G3, B3, E4
	local tuning = overrides.tuning or songdata.tuning or		{	29,	34,	39,	44,	48,	53	}
	local transposition = overrides.transposition or songdata.transposition or 0

	local song = {}

	for beat_ind, beat in ipairs(songdata.tab) do
		local transcribed_beat = {}
		beat = type(beat) ~= "table" and { -1, -1, -1, -1, -1, -1 } or beat

		for string_ind, fret in ipairs(beat) do
			if fret >= 0 then
				table.insert(transcribed_beat, tuning[string_ind] + fret + transposition)
			end
			transcribed_beat.t = beat.t
		end

		table.insert(song, transcribed_beat)
	end

	local ret = { songtable = song }

	if not dont_spawn_shells then
		ret.shells_spawned = c_shellsfromtable(song, overrides.startpos,
			overrides.placementfn,
			overrides.spacing_multiplier or songdata.spacing_multiplier or 1)
	end

	return ret
end

-- ========================================



-- Nuke any controller mappings, for when people get in a hairy situation with a controller mapping that is totally busted.
function ResetControllersAndQuitGame()
    print("ResetControllersAndQuitGame requested")
    if not InGamePlay() then
	-- Nuke any controller configurations from our profile
	-- and clear the setting in the ini file
	TheSim:SetSetting("misc", "controller_popup", tostring(nil))
	Profile:SetValue("controller_popup",nil)
	Profile:SetValue("controls",{})
	Profile:Save()
	-- And quit the game, we want a restart
	RequestShutdown()
    else
	print("ResetControllersAndQuitGame can only be called from the frontend")
    end
end
