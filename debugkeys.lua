require "consolecommands"

local function DebugKeyPlayer()
    return ConsoleCommandPlayer()
end

----this gets called by the frontend code if a rawkey event has not been consumed by the current screen
handlers = {}

function DoDebugKey(key, down)
    if handlers[key] then
        for k,v in ipairs(handlers[key]) do
            if v(down) then
                return true
            end
        end
    end
end

--use this to register debug key handlers from within this file
function AddGameDebugKey(key, fn, down)
    down = down or true
    handlers[key] = handlers[key] or {}
    table.insert( handlers[key], function(_down) if _down == down and inGamePlay then return fn() end end)
end

function AddGlobalDebugKey(key, fn, down)
    down = down or true
    handlers[key] = handlers[key] or {}
    table.insert( handlers[key], function(_down) if _down == down then return fn() end end)
end

function SimBreakPoint()
    if not TheSim:IsDebugPaused() then
        TheSim:ToggleDebugPause()
    end
end

-------------------------------------DEBUG KEYS

local currentlySelected
global("c_ent")
global("c_ang")

local function Spawn(prefab)
    --TheSim:LoadPrefabs({prefab})
    return SpawnPrefab(prefab)
end

local userName = TheSim:GetUsersName() 
--
-- Put your own username in here to enable "dprint"s to output to the log window 
if CHEATS_ENABLED and userName == "My Username" then
    global("CHEATS_KEEP_SAVE")
    global("CHEATS_ENABLE_DPRINT")
    global("DPRINT_USERNAME")
    global("c_ps")

    DPRINT_USERNAME = "My Username"
    CHEATS_KEEP_SAVE = true
    CHEATS_ENABLE_DPRINT = true
end

AddGlobalDebugKey(KEY_HOME, function()
    if not TheSim:IsDebugPaused() then
        print("Home key pressed PAUSING GAME")
        TheSim:ToggleDebugPause()
    end
    if TheInput:IsKeyDown(KEY_CTRL) then
        TheSim:ToggleDebugPause()
    else
        print("Home key pressed STEPPING")
        TheSim:Step()
    end
    return true
end)

AddGlobalDebugKey(KEY_F1, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        TheSim:TogglePerfGraph()
        return true
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
		c_select(TheWorld)
    else
        c_select()
        if c_sel() ~= nil then
            if c_sel().prefab == "beefalo" then
                c_sel():DoPeriodicTask(1, function(inst)
                    print("Tendencies:",
                        "default", inst.components.domesticatable.tendencies.DEFAULT or 'nil',
                        "ornery", inst.components.domesticatable.tendencies.ORNERY or 'nil',
                        "rider", inst.components.domesticatable.tendencies.RIDER or 'nil',
                        "pudgy", inst.components.domesticatable.tendencies.PUDGY or 'nil')
                end)
            elseif c_sel():HasTag("player") then
                c_sel():ListenForEvent("onattackother", function(inst)
                    --print("I DID ATTTACCCCKED")
                end)
            end
        end
    end

end)

AddGlobalDebugKey(KEY_R, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        if TheInput:IsKeyDown(KEY_SHIFT) then
            c_regenerateworld()
        else
            c_reset()
        end
    else
        c_repeatlastcommand()
    end
    return true
end)

AddGameDebugKey(KEY_F2, function()
    if c_sel() == TheWorld then
        c_select(TheWorld.net)
    else
        c_select(TheWorld)
    end
end)

AddGameDebugKey(KEY_F3, function()
    for i=1,TheWorld.state.remainingdaysinseason do
        TheWorld:PushEvent("ms_advanceseason")
    end
end)

AddGameDebugKey(KEY_R, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        local ent = TheInput:GetWorldEntityUnderMouse()
        if ent ~= nil and ent.prefab ~= nil then
            ent:Remove()
        end
        return true
    end 
end)

AddGameDebugKey(KEY_I, function()
	if TheInput:IsKeyDown(KEY_CTRL) and TheInput:IsKeyDown(KEY_SHIFT) then
		TheInventory:Debug_LocalGift()
		return true
    elseif TheInput:IsKeyDown(KEY_CTRL) then
        TheInventory:Debug_ForceHeartbeatGift("")
        return true
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        c_spawn("researchlab")
        return true
    end
end)

AddGameDebugKey(KEY_F4, function()
    -- Spawn a ready-made base!
    local pos = TheInput:GetWorldPosition()
    local topleft = Vector3(pos.x - 15, 0, pos.z - 15)
    local bottomright = Vector3(pos.x + 15, 0, pos.z + 15)
    local width = bottomright-topleft
    for i=0,width.x do
        if i < width.x/2-1 or i > width.x/2+1 then
            local wall = SpawnPrefab("wall_stone")
            wall.Transform:SetPosition(topleft.x + i, 0, topleft.z)
            wall = SpawnPrefab("wall_stone")
            wall.Transform:SetPosition(bottomright.x - i, 0, bottomright.z)
        end
    end
    for i=0,width.z do
        if i < width.z/2-1 or i > width.z/2+1 then
            local wall = SpawnPrefab("wall_wood")
            wall.Transform:SetPosition(topleft.x, 0, topleft.z + i)
            wall = SpawnPrefab("wall_hay")
            wall.Transform:SetPosition(bottomright.x, 0, bottomright.z - i)
        end
    end

    local items = {
        "treasurechest",
        "treasurechest",
        "treasurechest",
        "researchlab",
        "researchlab",
        "researchlab2",
        "firepit",
        "slow_farmplot",
        "slow_farmplot",
        "slow_farmplot",
        "fast_farmplot",
        "fast_farmplot",
        "fast_farmplot",
        "meatrack",
        "meatrack",
        "meatrack",
        "meatrack",
        "cookpot",
        "cookpot",
        "cookpot",
        "cookpot",
        "pighouse",
        "birdcage",
        "firesuppressor",
    }
    for i,v in ipairs(items) do
        local pos = topleft + Vector3(width.x*math.random(), 0, width.z*math.random())
        SpawnPrefab(items[i]).Transform:SetPosition(pos.x, pos.y, pos.z)
    end
    local group_items = {
        "grass",
        "berrybush",
        "sapling",
        "evergreen",
        "evergreen",
    }
    for i,v in ipairs(group_items) do
        local pos = topleft + Vector3(width.x*math.random(), 0, width.z*math.random())
        for z=-2,2 do
            for x=-2,2 do
                local sub_pos = Vector3(pos.x + x, 0, pos.z + z)
                SpawnPrefab(group_items[i]).Transform:SetPosition(sub_pos.x, sub_pos.y, sub_pos.z)
            end
        end
    end
    ConsoleCommandPlayer().components.inventory:Equip( c_spawn("backpack") ) -- do this first so other things can get put in it
    ConsoleCommandPlayer().components.inventory:Equip( c_spawn("axe") )
    ConsoleCommandPlayer().components.inventory:Equip( c_spawn("flowerhat") )
    local invitems = {
        meat = 10,
        carrot = 20,
        berries = 20,
        twigs = 20,
        cutgrass = 20,
        flint = 20,
        rocks = 40,
        log = 40,
        spear = 2,
        armorwood = 2,
        footballhat = 1,
        torch = 2,
        axe = 1,
        pickaxe = 1,
        shovel = 1,
        silk = 10,
        spidergland = 5,
        smallmeat = 8,
        meat = 4,
        meatballs = 4,
    }
    for k,v in pairs(invitems) do
        c_give(k, v)
    end
end)

AddGameDebugKey(KEY_F5, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local pos = TheInput:GetWorldPosition()
        local met = SpawnPrefab("shadowmeteor")
        if TheInput:IsKeyDown(KEY_SHIFT) then
            met:SetSize("large", 1)
        else
            met:SetSize("small", 1)
            met:SetPeripheral(true)
        end
        met.Transform:SetPosition(pos.x, pos.y, pos.z)
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        local pos = TheInput:GetWorldPosition()
        TheWorld:PushEvent("ms_sendlightningstrike", pos)
    else
        TheWorld:PushEvent("ms_setseasonlength", {season="autumn", length=12})
        TheWorld:PushEvent("ms_setseasonlength", {season="winter", length=10})
        TheWorld:PushEvent("ms_setseasonlength", {season="spring", length=12})
        TheWorld:PushEvent("ms_setseasonlength", {season="summer", length=10})
    end
    return true
end)

AddGameDebugKey(KEY_F6, function()
    -- F6 is used by the hot-reload functionality!
end)

AddGameDebugKey(KEY_F12, function()
    local positions = {}
    for i = 1, 100 do
        local s = i/32.0--(num/2) -- 32.0
        local a = math.sqrt(s*512.0)
        local b = math.sqrt(s)
        table.insert(positions, Vector3(math.sin(a)*b, 0, math.cos(a)*b))
    end

    local pos = DebugKeyPlayer():GetPosition()
    local delay = 0
    for i = 1, #positions do
        local sp = pos + (positions[i] * 1.2)
        DebugKeyPlayer():DoTaskInTime(delay, function() 
            local prefab = SpawnPrefab("carrot_planted")
            prefab.Transform:SetPosition(sp:Get())
        end)
        --delay = delay + 0.03
    end
end)

AddGameDebugKey(KEY_F7, function()
    local player = ConsoleCommandPlayer()
    if player then
        local x, y, z = player.Transform:GetWorldPosition()

        if TheInput:IsKeyDown(KEY_SHIFT) and TheInput:IsKeyDown(KEY_CTRL) then
            local idx = 0
            local nidx = 1
            local nextpoint = nil
            nextpoint = function()
                if TheWorld.topology.nodes[nidx] ~= nil then
                    if idx == 0 then
                        if TheWorld.topology.nodes[nidx].cent ~= nil then
                            c_teleport(TheWorld.topology.nodes[nidx].cent[1], 0, TheWorld.topology.nodes[nidx].cent[2], player)
                        end
                    else
                        if TheWorld.topology.nodes[nidx].poly ~= nil then
                            c_teleport(TheWorld.topology.nodes[nidx].poly[idx][1], 0, TheWorld.topology.nodes[nidx].poly[idx][2], player)
                        end
                    end
                    idx = idx + 1
                    if false then--idx <= #TheWorld.topology.nodes[nidx].poly then
                        -- continue
                        --nextpoint()
                        player:DoTaskInTime(0.0, nextpoint)
                    elseif nidx <= #TheWorld.topology.nodes then
                        nidx = nidx + 1
                        idx = 0
                        --nextpoint()
                        player:DoTaskInTime(0.0, nextpoint)
                    end
                else
                    nidx = nidx + 1
                    --nextpoint()
                    player:DoTaskInTime(0.0, nextpoint)
                end
            end
            nextpoint()
        else

            for i, node in ipairs(TheWorld.topology.nodes) do
                if TheSim:WorldPointInPoly(x, z, node.poly) then
                    print("/********************\\")
                    print("Standing in", i)
                    print("id", TheWorld.topology.ids[i])
                    print("type", node.type)
                    print("story depth", TheWorld.topology.story_depths[i])
                    print("area", node.area)
                    print("tags", table.concat(node.tags or {}, ", "))

                    dumptable(TheWorld.generated.densities[ TheWorld.topology.ids[i] ])

                    if TheInput:IsKeyDown(KEY_SHIFT) and TheInput:IsKeyDown(KEY_CTRL) then
                        -- eat this, handled above
                    elseif TheInput:IsKeyDown(KEY_SHIFT) then
                        c_teleport(node.cent[1], 0, node.cent[2], player)
                        print("center", unpack(node.cent))
                    elseif TheInput:IsKeyDown(KEY_CTRL) then
                        print("poly size", #node.poly)
                        for _,v in ipairs(node.poly) do
                            print("\t", unpack(v))
                        end

                        local idx = 1
                        local nextpoint = nil
                        nextpoint = function()
                            c_teleport(node.poly[idx][1], 0, node.poly[idx][2], player)
                            idx = idx + 1
                            if idx <= #node.poly then
                                player:DoTaskInTime(0.3, nextpoint)
                            end
                        end
                        nextpoint()
                    elseif TheInput:IsKeyDown(KEY_ALT) then
                        print("densities")
                        if TheWorld.generated.densities[TheWorld.topology.ids[i]] == nil then
                            print("\t<nil>")
                        elseif GetTableSize(TheWorld.generated.densities[TheWorld.topology.ids[i]]) == 0 then
                            print("\t<zero densities>")
                        else
                            for k,v in pairs(TheWorld.generated.densities[TheWorld.topology.ids[i]]) do
                                print("\t",k,v)
                            end
                        end
                    end
                    print("\\********************/")
                end
            end

        end
    end
end)

---Spawn random items from the "items" table in a circles around me.
AddGameDebugKey(KEY_F8, function()
    --Spawns a lot of prefabs around you in rings.
    local items = {"flower"} --Which items spawn. 
    local player = DebugKeyPlayer()
    local pt = Vector3(player.Transform:GetWorldPosition())
    local theta = math.random() * 2 * PI
    local numrings = 10 --How many rings of stuff you spawn
    local radius = 2 --Initial distance from player
    local radius_step_distance = 1 --How much the radius increases per ring.
    local itemdensity = 1 --(X items per unit)
    local map = TheWorld.Map
    
    local finalRad = (radius + (radius_step_distance * numrings))
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, finalRad + 2)

    local numspawned = 0
    -- Walk the circle trying to find a valid spawn point
    for i = 1, numrings do
        local circ = 2*PI*radius
        local numitems = circ * itemdensity

        for i = 1, numitems do
            numspawned = numspawned + 1
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            local wander_point = pt + offset
           
            if map:IsPassableAtPoint(wander_point:Get()) then
                local spawn = SpawnPrefab(GetRandomItem(items))
                spawn.Transform:SetPosition(wander_point:Get())
            end
            theta = theta - (2 * PI / numitems)
        end
        radius = radius + radius_step_distance
    end
    print("Made: ".. numspawned .." items")
    return true
end)

AddGameDebugKey(KEY_PAGEUP, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        TheWorld:PushEvent("ms_deltawetness", 5)
    elseif TheInput:IsKeyDown(KEY_CTRL) then
        TheWorld:PushEvent("ms_deltamoisture", 100)
    elseif TheInput:IsKeyDown(KEY_ALT) then
        TheWorld:PushEvent("ms_setsnowlevel", TheWorld.state.snowlevel + .5)
    else
        TheWorld:PushEvent("ms_advanceseason")
    end
    return true
end)

AddGameDebugKey(KEY_PAGEDOWN, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        TheWorld:PushEvent("ms_deltawetness", -5)
    elseif TheInput:IsKeyDown(KEY_CTRL) then
        TheWorld:PushEvent("ms_deltamoisture", -100)
    elseif TheInput:IsKeyDown(KEY_ALT) then
        TheWorld:PushEvent("ms_setsnowlevel", TheWorld.state.snowlevel - .5)
    else
        TheWorld:PushEvent("ms_retreatseason")
    end
    return true
end)


AddGameDebugKey(KEY_O, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        print("Finding rooms with chester")
        local Levels = require('map/levels')
        local Tasks = require('map/tasks')
        local TaskSets = require('map/tasksets')
        local Rooms = require('map/rooms')
        
        local locationdata = Levels.GetDataForLocation("cave")
        local taskset = locationdata.overrides.task_set
        local tasksetdata = TaskSets.GetGenTasks(taskset)
        local taskcount = 0
        local roomcount = 0
        local tagcount = 0
        for i,taskname in ipairs(ArrayUnion(tasksetdata.tasks, tasksetdata.optionaltasks)) do
            taskcount = taskcount+1
            local taskdata = Tasks.GetTaskByName(taskname)
            for roomname,count in pairs(taskdata.room_choices) do
                roomcount = roomcount + 1
                local roomdata = Rooms.GetRoomByName(roomname)
                if roomdata.tags then
                    tagcount = tagcount+1
                    for i,tag in ipairs(roomdata.tags) do
                        if tag == "Chester_Eyebone" then
                            print("FOUND CHESTER EYEBONE",taskname,roomname)
                        end
                    end
                end
            end
        end
        print("DONE", taskcount, roomcount, tagcount)


    elseif TheInput:IsKeyDown(KEY_ALT) then
    end
    
    return true
end)

AddGameDebugKey(KEY_F9, function()
    LongUpdate(TUNING.TOTAL_DAY_TIME*.25)
    return true
end)

AddGameDebugKey(KEY_F10, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        TheWorld:PushEvent("ms_nextnightmarephase")
    else
        TheWorld:PushEvent("ms_nextphase")
    end
    return true
end)


AddGameDebugKey(KEY_F11, function()
    for k,v in pairs(Ents) do
        if v.prefab == "carrot_planted" then
            v.components.pickable:Pick()
        end
    end

    return true
end)

local potatoparts = { "teleportato_ring", "teleportato_box", "teleportato_crank", "teleportato_potato", "teleportato_base", "adventure_portal" }
local potatoindex = 1

AddGameDebugKey(KEY_1, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MainCharacter = DebugKeyPlayer()
        local part = nil
        for k,v in pairs(Ents) do
            if v.prefab == potatoparts[potatoindex] then
                part = v
                break
            end
        end
        potatoindex = ((potatoindex) % #potatoparts)+1
        if MainCharacter and part then
            MainCharacter.Transform:SetPosition(part.Transform:GetWorldPosition())
        end
        return true
    end
    
end)

AddGameDebugKey(KEY_X, function()
    currentlySelected = TheInput:GetWorldEntityUnderMouse()
    if currentlySelected then
        c_ent = currentlySelected
        dprint(c_ent)
    end
    if TheInput:IsKeyDown(KEY_CTRL) and c_ent then
        dtable(c_ent,1)
    end
    return true
end)

AddGlobalDebugKey(KEY_LEFTBRACKET, function()
    TheSim:SetTimeScale(TheSim:GetTimeScale() - .25)
    return true
end)

AddGlobalDebugKey(KEY_RIGHTBRACKET, function()
    TheSim:SetTimeScale(TheSim:GetTimeScale() + .25)
    return true
end)

AddGameDebugKey(KEY_KP_PLUS, function()
    local MainCharacter = DebugKeyPlayer()
    if MainCharacter ~= nil then
        if TheInput:IsKeyDown(KEY_CTRL) then
            MainCharacter.components.sanity:DoDelta(5)
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
            MainCharacter.components.hunger:DoDelta(50)
        elseif TheInput:IsKeyDown(KEY_ALT) then
            MainCharacter.components.sanity:DoDelta(50)
        else
            MainCharacter.components.health:DoDelta(50, nil, "debug_key")
            c_sethunger(1)
            c_sethealth(1)
            c_setsanity(1)
        end
    end
    return true
end)

AddGameDebugKey(KEY_KP_MINUS, function()
    local MainCharacter = DebugKeyPlayer()
    if MainCharacter and TheWorld.ismastersim then
        if TheInput:IsKeyDown(KEY_CTRL) then
            --MainCharacter.components.temperature:DoDelta(-10)
            --TheSim:SetTimeScale(TheSim:GetTimeScale() - .25)
            MainCharacter.components.sanity:DoDelta(-5)
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
            MainCharacter.components.hunger:DoDelta(-25)
        elseif TheInput:IsKeyDown(KEY_ALT) then
            MainCharacter.components.sanity:SetPercent(0)
        else
            MainCharacter.components.health:DoDelta(-25, nil, "debug_key")
        end
    end
    return true
end)

local wormholetarget = nil
local tentaholetarget = nil
AddGameDebugKey(KEY_T, function()
    -- Moving Teleport to just plain T as I am getting a sore hand from CTRL-T - Alia
    if TheInput:IsKeyDown(KEY_CTRL) then
        local x,y,z = TheInput:GetWorldPosition():Get()
        local w1 = SpawnPrefab("wormhole")
        w1.Transform:SetPosition(x, y, z-3)

        if wormholetarget ~= nil then
            w1.components.teleporter:Target(wormholetarget)
            wormholetarget.components.teleporter:Target(w1)
            wormholetarget = nil
        else
            wormholetarget = w1
        end

        local t1 = SpawnPrefab("tentacle_pillar_hole")
        t1.Transform:SetPosition(x, y, z+3)

        if tentaholetarget ~= nil then
            t1.components.teleporter:Target(tentaholetarget)
            tentaholetarget.components.teleporter:Target(t1)
            tentaholetarget = nil
        else
            tentaholetarget = t1
        end
    else
        local MainCharacter = DebugKeyPlayer()
        if MainCharacter then
            local topscreen = TheFrontEnd:GetActiveScreen()
            if topscreen.minimap ~= nil then

                local mousepos = TheInput:GetScreenPosition()
                local mousewidgetpos = topscreen:ScreenPosToWidgetPos( mousepos )
                local mousemappos = topscreen:WidgetPosToMapPos( mousewidgetpos )

                local x,y,z = topscreen.minimap:MapPosToWorldPos( mousemappos:Get() )

                MainCharacter.Physics:Teleport(x, 0, y)
            else
                MainCharacter.Physics:Teleport(TheInput:GetWorldPosition():Get())
            end
        end
    end
    return true
end)

AddGameDebugKey(KEY_G, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
        if MouseCharacter then
            if MouseCharacter.components.growable then
                MouseCharacter.components.growable:DoGrowth()
            elseif MouseCharacter.components.fueled then
                MouseCharacter.components.fueled:SetPercent(1)
            elseif MouseCharacter.components.harvestable then
                MouseCharacter.components.harvestable:Grow()
            elseif MouseCharacter.components.pickable then
                MouseCharacter.components.pickable:Regen()
            elseif MouseCharacter.components.setter then
                MouseCharacter.components.setter:SetSetTime(0.01)
                MouseCharacter.components.setter:StartSetting()
            elseif MouseCharacter.components.cooldown then
                MouseCharacter.components.cooldown:LongUpdate(MouseCharacter.components.cooldown.cooldown_duration)
            elseif MouseCharacter.components.domesticatable then
                if MouseCharacter.components.domesticatable:IsDomesticated() then
                    MouseCharacter.components.domesticatable:BecomeFeral()
                else
                    MouseCharacter.components.domesticatable:BecomeDomesticated()
                end
            end
        end
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
		c_supergodmode()
    else
        c_godmode()
    end
    return true
end)

AddGameDebugKey(KEY_D, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
        if MouseCharacter and MouseCharacter.components.diseaseable ~= nil then
            MouseCharacter.components.diseaseable:ForceDiseased(1*TUNING.TOTAL_DAY_TIME, 1*TUNING.TOTAL_DAY_TIME)
        end
    end
end)

AddGameDebugKey(KEY_P, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
        MouseCharacter = MouseCharacter or DebugKeyPlayer()
        if MouseCharacter then
            local pinnable = MouseCharacter.components.pinnable 
            if pinnable then
                if pinnable:IsStuck() then
                    pinnable:Unstick()
                else
                    pinnable:Stick()
                end
            end
        end
    end
    return true
end)

AddGlobalDebugKey(KEY_W, function()
    -- Only respond to plain ctrl-w
    if TheInput:IsKeyDown(KEY_CTRL)
        and not TheInput:IsKeyDown(KEY_SHIFT)
        and not TheInput:IsKeyDown(KEY_ALT)
        then
        TheFrontEnd:EnableWidgetDebugging()
        return true
    end
    return false
end)

AddGameDebugKey(KEY_W, function()
    -- Only respond to ctrl-shift-w
    if TheInput:IsKeyDown(KEY_CTRL)
        and TheInput:IsKeyDown(KEY_SHIFT)
        and not TheInput:IsKeyDown(KEY_ALT)
        then
        c_select()
        TheFrontEnd:EnableEntityDebugging()
        return true
    end
    return false
end)

AddGameDebugKey(KEY_K, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
        if MouseCharacter and MouseCharacter ~= DebugKeyPlayer() then
            if MouseCharacter.components.health then
                MouseCharacter.components.health:Kill()
            elseif MouseCharacter.Remove then
                MouseCharacter:Remove()
            end
        end
    end
    return true
end)


AddGameDebugKey(KEY_L, function()
    if not ThePlayer then
        -- ThePlayer is nil in lobby screens (which count as GameDebug).
        return
    end
	--local pt = TheInput:GetWorldPosition()
	local pt = ThePlayer:GetPosition()
	
--    local tile = TheWorld.Map:GetTileAtPoint(pt:Get())

    local x, _, z = pt:Get()
    local k = 1.3
    local str = "\n"
    local target_tile = 34
    local valid = nil
	for _z = 1, -1, -1 do
	    for _x = -1, 1 do
			local tile = TheWorld.Map:GetTileAtPoint(x+_x*k, 0, z+_z*k)
			if tile == 33 then -- this would be tile.sort > target_tile.sort
				valid = false
			elseif valid == nil and tile == target_tile then
				valid = true
			end
			
			str = str .. tostring(tile) .. "\t"
		end
		str = str .. "\n"
	end
    
    print (str .. tostring(valid == true))
    
--	print ("", TheWorld.Map:GetTileAtPoint(x-k, 0, z+k), TheWorld.Map:GetTileAtPoint(x, 0, z+k), TheWorld.Map:GetTileAtPoint(x+k, 0, z+k))
--	print ("", TheWorld.Map:GetTileAtPoint(x-k, 0, z), TheWorld.Map:GetTileAtPoint(x, 0, z), TheWorld.Map:GetTileAtPoint(x+k, 0, z))
--	print ("", TheWorld.Map:GetTileAtPoint(x-k, 0, z-k), TheWorld.Map:GetTileAtPoint(x, 0, z-k), TheWorld.Map:GetTileAtPoint(x+k, 0, z-k))
    
--[[
    local x, y = TheWorld.Map:GetTileCoordsAtPoint((pt - Vector3(4,0,4)):Get())


    print ("", TheWorld.Map:GetTile(x, y+1), TheWorld.Map:GetTile(x+1, y+1))
    print ("", TheWorld.Map:GetTile(x, y), TheWorld.Map:GetTile(x+1, y))
]]
--    print ("", TheWorld.Map:GetTile(x-1, y), TheWorld.Map:GetTile(x, y))
--    print ("", TheWorld.Map:GetTile(x-1, y-1), TheWorld.Map:GetTile(x, y-1))
end)

local DebugTextureVisible = false
local MapLerpVal = 0.0

AddGlobalDebugKey(KEY_KP_DIVIDE, function()
    if TheInput:IsKeyDown(KEY_ALT) then
        print("ToggleFrameProfiler")
        TheSim:ToggleFrameProfiler()
    else
        TheSim:ToggleDebugTexture()

        DebugTextureVisible = not DebugTextureVisible
        print("DebugTextureVisible",DebugTextureVisible)
    end
    return true
end)

AddGlobalDebugKey(KEY_EQUALS, function()
    if DebugTextureVisible then
        local val = 1
        if TheInput:IsKeyDown(KEY_ALT) then
            val = 10
        elseif TheInput:IsKeyDown(KEY_CTRL) then
            val = 100
        end
        TheSim:UpdateDebugTexture(val)
    else
        if TheWorld then
            MapLerpVal = MapLerpVal + 0.1
            TheWorld.Map:SetOverlayLerp(MapLerpVal)
        end
    end
    return true
end)

AddGlobalDebugKey(KEY_MINUS, function()
    if DebugTextureVisible then
        local val = 1
        if TheInput:IsKeyDown(KEY_ALT) then
            val = 10
        elseif TheInput:IsKeyDown(KEY_CTRL) then
            val = 100
        end
        TheSim:UpdateDebugTexture(-val)
    else
        if TheWorld then
            MapLerpVal = MapLerpVal - 0.1 
            TheWorld.Map:SetOverlayLerp(MapLerpVal)
        end
    end
    
    return true
end)

local enable_fog = true
local hide_revealed = false
AddGameDebugKey(KEY_M, function()
    local MainCharacter = DebugKeyPlayer()
    if MainCharacter then
        if TheInput:IsKeyDown(KEY_CTRL) then
            enable_fog = not enable_fog
            TheWorld.minimap.MiniMap:EnableFogOfWar(enable_fog)
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
            hide_revealed = not hide_revealed
            TheWorld.minimap.MiniMap:ContinuouslyClearRevealedAreas(hide_revealed)
        end
    end

    return true
end)

AddGameDebugKey(KEY_N, function()
    c_gonext()
end)

AddGameDebugKey(KEY_S, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        TheWorld:PushEvent("ms_save")
        return true
    end
end)

AddGameDebugKey(KEY_A, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MainCharacter = DebugKeyPlayer()
        if MainCharacter.components.builder ~= nil then
            MainCharacter.components.builder:GiveAllRecipes()
            MainCharacter:PushEvent("techlevelchange")
        end
        return true
    end
end)

AddGameDebugKey(KEY_KP_MULTIPLY, function()
    if TheInput:IsDebugToggleEnabled() then
        c_give("devtool")
        return true
    end
end)

AddGameDebugKey(KEY_KP_DIVIDE, function()
    if TheInput:IsDebugToggleEnabled() then
        DebugKeyPlayer().components.inventory:DropEverything(false, true)
        return true
    end
end)

AddGameDebugKey(KEY_C, function()
    if userName ~= "David Forsey" then
        if TheInput:IsKeyDown(KEY_CTRL) then
            local IDENTITY_COLOURCUBE = "images/colour_cubes/identity_colourcube.tex"
            PostProcessor:SetColourCubeData( 0, IDENTITY_COLOURCUBE, IDENTITY_COLOURCUBE )
            PostProcessor:SetColourCubeLerp( 0, 0 )
        end
    else
        if not c_ent then return end

        global("c_ent_mood")
        local pos = c_ent.components.knownlocations.GetLocation and c_ent.components.knownlocations:GetLocation("rookery")
        if pos and TheInput:IsKeyDown(KEY_CTRL) then
            c_teleport(pos.x, pos.y, pos.z)
        elseif pos then
            c_teleport(pos.x, pos.y, pos.z, c_ent)
        end
    end
    
    return true
end)

AddGlobalDebugKey(KEY_PAUSE, function()
    print("Toggle pause")
    
    TheSim:ToggleDebugPause()
    TheSim:ToggleDebugCamera()
    
    if TheSim:IsDebugPaused() then
        TheSim:SetDebugRenderEnabled(true)
        if TheCamera.targetpos then
            TheSim:SetDebugCameraTarget(TheCamera.targetpos.x, TheCamera.targetpos.y, TheCamera.targetpos.z)
        end
        
        if TheCamera.headingtarget then
            TheSim:SetDebugCameraRotation(-TheCamera.headingtarget-90)  
        end
    end
    return true
end)

local frommember = nil
AddGameDebugKey(KEY_H, function()
    if TheInput:IsKeyDown(KEY_LCTRL) then
        ThePlayer.HUD:Toggle()
    elseif TheInput:IsKeyDown(KEY_ALT) then
        TheWorld.components.hounded:ForceNextWave()
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        if c_sel() ~= nil and c_sel().components.herdmember ~= nil and c_sel().components.herdmember.herd ~= nil then
            frommember = c_sel()
            c_select(c_sel().components.herdmember.herd)
        elseif c_sel() ~= nil and c_sel().components.herd ~= nil then
            c_select(frommember) -- just assume it's the same herd and we're reversing..
        end
    else
        if c_sel() ~= nil and c_sel().components.herdmember ~= nil and c_sel().components.herdmember.herd ~= nil then
            print("me:", c_sel())
            for k,v in pairs(c_sel().components.herdmember.herd.components.herd.members) do
                print("  ", k)
            end
            local first, _ = next(c_sel().components.herdmember.herd.components.herd.members)
            print("first", first)
            local current, _ = next(c_sel().components.herdmember.herd.components.herd.members, first)
            local prev = first
            while current ~= nil do
                print("testing", current, "prev", prev, "csel", c_sel())
                if prev == c_sel() then
                    print("selecting", current)
                    c_select(current)
                    break
                else
                    prev = current
                    current, _ = next(c_sel().components.herdmember.herd.components.herd.members, current)
                    if current == nil then
                        if prev == c_sel() then
                            print("got to the end, selecting first!")
                            c_select(first)
                        end
                    end
                end
            end
        elseif c_sel() ~= nil and c_sel().components.herd ~= nil then
            c_select(next(c_sel().components.herd.members))
        end
    end
    return true
end)

AddGameDebugKey(KEY_J, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        if c_sel() ~= nil and c_sel().components.periodicspawner ~= nil then
            c_sel().components.periodicspawner:TrySpawn()
        end
    else
        if c_sel() ~= nil and c_sel().components.mood ~= nil then
            c_sel().components.mood:SetIsInMood(true)
        end
    end
    return true
end)

AddGameDebugKey(KEY_INSERT, function()
    if TheInput:IsDebugToggleEnabled() then
        if not TheSim:GetDebugRenderEnabled() then
            TheSim:SetDebugRenderEnabled(true)
        end
        if TheInput:IsKeyDown(KEY_SHIFT) then
            TheSim:ToggleDebugCamera()
        else
            TheSim:SetDebugPhysicsRenderEnabled(not TheSim:GetDebugPhysicsRenderEnabled())
        end
    end
    return true
end)

AddGameDebugKey(KEY_I, function()
    if TheInput:IsKeyDown(KEY_SHIFT) and not TheInput:IsKeyDown(KEY_CTRL) then
        c_spawn("dragonfly")
    elseif TheInput:IsKeyDown(KEY_CTRL) and not TheInput:IsKeyDown(KEY_SHIFT) then
        c_spawn("light_flower"):TurnOn()
    elseif TheInput:IsKeyDown(KEY_CTRL) and TheInput:IsKeyDown(KEY_SHIFT) then
        local lavae = {}
        for k, v in pairs(Ents) do
            if v.prefab == "lavae" then
                table.insert(lavae, v)
            end
        end

        for k,v in pairs(lavae) do
            v.LockTargetFn(v, ConsoleCommandPlayer())
        end
    end

    return true
end)

local GROUND_LOOKUP = table.invert(GROUND)

AddGameDebugKey(KEY_0, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        local pos = TheInput:GetWorldPosition()
        local x, y = TheWorld.Map:GetTileCoordsAtPoint(pos:Get())
        local original_tile = TheWorld.Map:GetTileAtPoint(pos:Get())
        print("Original tile", GROUND_LOOKUP[original_tile])
        local tile = original_tile+1
        while GROUND_LOOKUP[tile] == nil do
            if tile > 255 then
                tile = 0
            end
            tile = tile + 1
        end
        print("Changing tile to "..GROUND_LOOKUP[tile])
        TheWorld.Map:SetTile(x, y, tile)
        TheWorld.Map:RebuildLayer(original_tile,x,y)
        TheWorld.Map:RebuildLayer(tile,x,y)
    end
end)

AddGameDebugKey(KEY_9, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        local pos = TheInput:GetWorldPosition()
        local x, y = TheWorld.Map:GetTileCoordsAtPoint(pos:Get())
        local original_tile = TheWorld.Map:GetTileAtPoint(pos:Get())
        print("Original tile", GROUND_LOOKUP[original_tile])
        local tile = original_tile-1
        while GROUND_LOOKUP[tile] == nil do
            if tile < 1 then
                tile = 255
            end
            tile = tile - 1
        end
        print("Changing tile to "..GROUND_LOOKUP[tile])
        TheWorld.Map:SetTile(x, y, tile)
        TheWorld.Map:RebuildLayer(original_tile,x,y)
        TheWorld.Map:RebuildLayer(tile,x,y)
    end
end)

-------------------------------------------MOUSE HANDLING

local function DebugRMB(x,y)
    local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
    local pos = TheInput:GetWorldPosition()

    if TheInput:IsKeyDown(KEY_CTRL) and
       TheInput:IsKeyDown(KEY_SHIFT) and
       c_sel() and c_sel().prefab then
        local spawn = c_spawn(c_sel().prefab)
        if spawn then
            spawn.Transform:SetPosition(pos:Get())
        end
    elseif TheInput:IsKeyDown(KEY_CTRL) and TheWorld.ismastersim then
        if MouseCharacter then
            if MouseCharacter.components.health and MouseCharacter ~= DebugKeyPlayer() then
                MouseCharacter.components.health:Kill()
            elseif MouseCharacter.Remove then
                MouseCharacter:Remove()
            end
        else
            local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 5, nil, {"wall"})
            for k,v in pairs(ents) do
                if v.components.health and v ~= DebugKeyPlayer() then
                    v.components.health:Kill()
                end
            end
        end
    elseif TheInput:IsKeyDown(KEY_ALT) then
        local player = DebugKeyPlayer()
        if player then
            print(player:GetAngleToPoint(pos))
        end
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        if MouseCharacter then
            SetDebugEntity(MouseCharacter)
        else
            SetDebugEntity(TheWorld)
        end
    end
end

local function DebugLMB(x,y)
    if TheSim:IsDebugPaused() then
        SetDebugEntity(TheInput:GetWorldEntityUnderMouse())
    end
end

function DoDebugMouse(button, down,x,y)
    if not down then return false end
    
    if button == MOUSEBUTTON_RIGHT then
        DebugRMB(x,y)
    elseif button == MOUSEBUTTON_LEFT then
        DebugLMB(x,y)   
    end
    
end

function DoReload()
    dofile("scripts/reload.lua")
end
