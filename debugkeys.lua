local DebugNodes = CAN_USE_DBUI and require "dbui_no_package/debug_nodes" or nil
if CAN_USE_DBUI then
    require "dbui_no_package/debug_entity"
    require "dbui_no_package/debug_prefabs"
    require "dbui_no_package/debug_audio"
    require "dbui_no_package/debug_weather"
    require "dbui_no_package/debug_skins"
    require "dbui_no_package/debug_widget"
    require "dbui_no_package/debug_player"
    require "dbui_no_package/debug_input"
    require "dbui_no_package/debug_strings"
end

require "consolecommands"

local fcts = {
    string = function(value) return string_format('%q', value) end,
    number = function(value) return value end,
    boolean = function(value) return tostring(value) end,
    ['nil'] = function(value) return 'nil' end,
}
local function dumpvariabletostr(var)
    local fct = fcts[type(var)]
    assert(fct)
    return fct(var)
end

local function d_c_spawn(prefab, count, dontselect)
    if not TheWorld.ismastersim then
        ConsoleRemote("c_spawn(%s,%s,%s)", {dumpvariabletostr(prefab), dumpvariabletostr(count), dumpvariabletostr(dontselect)})
    else
        c_spawn(prefab, count, dontselect)
    end
end

local function d_c_give(prefab, count, dontselect)
    if not TheWorld.ismastersim then
        ConsoleRemote("c_give(%s,%s,%s)", {dumpvariabletostr(prefab), dumpvariabletostr(count), dumpvariabletostr(dontselect)})
    else
        c_give(prefab, count, dontselect)
    end
end

local function d_c_remove(entity)
    if not TheWorld.ismastersim then
        local mouseentity = entity or TheInput:GetWorldEntityUnderMouse()

        if TheWorld == nil or mouseentity == nil or mouseentity.Network == nil then
            c_remove()
            return
        end

        local networkid = mouseentity.Network:GetNetworkID()
        local x, y, z = mouseentity.Transform:GetWorldPosition()
        ConsoleRemote('d_removeentitywithnetworkid(%s, %s, %s, %s)', {dumpvariabletostr(networkid), dumpvariabletostr(x), dumpvariabletostr(y), dumpvariabletostr(z)})
    else
        c_remove(entity)
    end
end

local function DebugKeyPlayer()
    return (TheWorld and TheWorld.ismastersim and ConsoleCommandPlayer()) or nil
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

function DoDebugMouse(button, down,x,y)
	-- delcaring this here so that it doesn't crash on steam deck, look farther down for the real fucntion
end

function DoReload()
    dofile("scripts/reload.lua")
end

-------------------------------------DEBUG KEYS

if IsSteamDeck() then
	return
end


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

GLOBAL_KEY_BINDINGS = 
{
    {
        binding = { key = KEY_HOME },
        name = "Pause / Step Game",
        fn = function()
            if not TheSim:IsDebugPaused() then
                print("Home key pressed PAUSING GAME")
                TheSim:ToggleDebugPause()
            else
                print("Home key pressed STEPPING")
                TheSim:Step()
            end
        end
    },
    {
        binding = { key = KEY_HOME, CTRL=true },
        name = "Toggle Pause Game",
        fn = function()
            print("Home key pressed TOGGLING")
            TheSim:ToggleDebugPause()
        end
    },
    {
        binding = { key = KEY_G },
        name = "God Mode",
        fn = function()
            c_godmode()
        end
    },
    {
        binding = { key = KEY_G, SHIFT=true },
        name = "Super God Mode",
        fn = function()
            c_supergodmode()
        end,
        tooltip = "Also restores are health, hunger, sanity, moisture"
    },
    {
        binding = { key = KEY_A, CTRL=true },
        name = "Unlock All Recipes",
        fn = function()
            c_freecrafting()
        end
    },
    {
        binding = { key = KEY_F1 },
        name = "Select Entity under mouse",
        fn = function()
            c_select()
            if c_sel() ~= nil then
                if c_sel().prefab == "beefalo" then
                    c_sel():DoPeriodicTask(1, function(inst)
                        --[[]
                        if inst.components.domesticatable ~= nil then
                            print("Tendencies:",
                                "default", inst.components.domesticatable.tendencies.DEFAULT or 'nil',
                                "ornery", inst.components.domesticatable.tendencies.ORNERY or 'nil',
                                "rider", inst.components.domesticatable.tendencies.RIDER or 'nil',
                                "pudgy", inst.components.domesticatable.tendencies.PUDGY or 'nil')
                        end
                        ]]
                    end)
                elseif c_sel():HasTag("player") then
                    c_sel():ListenForEvent("onattackother", function(inst)
                        --print("I DID ATTTACCCCKED")
                    end)
                end
            end
        end
    },
    {
        binding = { key = KEY_W, CTRL=true },
        name = "Toggle IMGUI",
        fn = function()
            TheFrontEnd:ToggleImgui()    
        end
    },
    {
        binding = { key = KEY_F10, SHIFT=true },
        name = "Next Nightmare Phase",
        fn = function()
            if TheWorld ~= nil then
                if not TheWorld.ismastersim then
                    ConsoleRemote('TheWorld:PushEvent("ms_nextnightmarephase")')
                else
                    TheWorld:PushEvent("ms_nextnightmarephase")
                end
            end
        end
    },
    {
        binding = { key = KEY_F10 },
        name = "Next Day Phase",
        fn = function()
            if TheWorld ~= nil then
                if not TheWorld.ismastersim then
                    ConsoleRemote('TheWorld:PushEvent("ms_nextphase")')
                else
                    TheWorld:PushEvent("ms_nextphase")
                end
            end
        end
    },
}

PROGRAMMER_KEY_BINDINGS = 
{
    {
        binding = { key = KEY_F1, ALT=true },
        name = "Select World",
        fn = function()
            c_select(TheWorld)
        end
    },
    {
        binding = { key = KEY_F1, CTRL=true },
        name = "Toggle Perf Graph",
        fn = function()
            TheSim:TogglePerfGraph()
        end
    },    
}

WINDOW_KEY_BINDINGS = 
{
    {
        binding = { key = KEY_P, SHIFT=true },
        name = "Prefabs",
        fn = function()
            TheFrontEnd:CreateDebugPanel( DebugNodes.DebugPrefabs() )            
        end
    },
    {
        binding = { key = KEY_A, SHIFT=true },
        name = "Audio",
        fn = function()
            TheFrontEnd:CreateDebugPanel( DebugNodes.DebugAudio() )            
        end
    },
    {
        binding = { key = KEY_W, SHIFT=true },
        name = "UI",
        fn = function()
            TheFrontEnd:CreateDebugPanel( DebugNodes.DebugWidget() )            
        end
    },
    {
        name = "Entity",
        fn = function()
            TheFrontEnd:CreateDebugPanel( DebugNodes.DebugEntity() )            
        end
    },
    {
        name = "Player",
        fn = function()
            TheFrontEnd:CreateDebugPanel( DebugNodes.DebugPlayer() )            
        end
    },
    {
        name = "Weather",
        fn = function()
            TheFrontEnd:CreateDebugPanel( DebugNodes.DebugWeather() )            
        end
    },
    {
        binding = { key = KEY_S, SHIFT=true, ALT=true },
        name = "Skins",
        fn = function()
            TheFrontEnd:CreateDebugPanel( DebugNodes.DebugSkins() )            
        end
    },
    {
        name = "Input",
        fn = function()
            TheFrontEnd:CreateDebugPanel( DebugNodes.DebugInput() )            
        end
    },
    {
        name = "Character Examine Strings",
        fn = function()
            TheFrontEnd:CreateDebugPanel( DebugNodes.DebugStrings() )            
        end
    },
}

local function BindKeys( bindings )
    for _,v in pairs(bindings) do
        if v.binding then
            AddGlobalDebugKey( v.binding.key, 
                function() 
                    if (v.binding.CTRL and not TheInput:IsKeyDown(KEY_CTRL)) or 
                        (v.binding.CTRL == nil and TheInput:IsKeyDown(KEY_CTRL)) then  
                        return false
                    end

                    if (v.binding.SHIFT and not TheInput:IsKeyDown(KEY_SHIFT)) or 
                        (v.binding.SHIFT == nil and TheInput:IsKeyDown(KEY_SHIFT)) then  
                        return false
                    end

                    if (v.binding.ALT and not TheInput:IsKeyDown(KEY_ALT)) or 
                        (v.binding.ALT == nil and TheInput:IsKeyDown(KEY_ALT)) then  
                        return false
                    end

                    --print("Activating hotkey: "..v.name)
                    return v.fn() 
                end, v.down)
        end
    end
end

BindKeys( GLOBAL_KEY_BINDINGS )
BindKeys( PROGRAMMER_KEY_BINDINGS )
if CAN_USE_DBUI then
    BindKeys( WINDOW_KEY_BINDINGS )
end

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
        if not TheWorld.ismastersim then
            ConsoleRemote('TheWorld:PushEvent("ms_advanceseason")')
        else
            TheWorld:PushEvent("ms_advanceseason")
        end
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
        d_c_spawn("researchlab")
        return true
    end
end)

AddGameDebugKey(KEY_F4, function()
    if TheWorld and not TheWorld.ismastersim then
        return
    end

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
    ConsoleCommandPlayer().components.inventory:Equip( d_c_spawn("backpack") ) -- do this first so other things can get put in it
    ConsoleCommandPlayer().components.inventory:Equip( d_c_spawn("axe") )
    ConsoleCommandPlayer().components.inventory:Equip( d_c_spawn("flowerhat") )
    local invitems = {
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
        d_c_give(k, v)
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

    if DebugKeyPlayer() then
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
    if player == nil then
        return true
    end
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

AddGameDebugKey(KEY_F11, function()
    for k,v in pairs(Ents) do
        if v.prefab == "carrot_planted" and v.components.pickable then
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

	if TheInput:IsKeyDown(KEY_CTRL) then
		local inventory = ConsoleCommandPlayer().components and ConsoleCommandPlayer().components.inventory
						or ConsoleCommandPlayer().replica and ConsoleCommandPlayer().replica.inventory
						or nil
		if inventory then
			c_select(inventory:GetEquippedItem(EQUIPSLOTS.HANDS))
		end
    elseif currentlySelected then
        c_ent = currentlySelected
    end
    return true
end)

AddGlobalDebugKey(KEY_LEFTBRACKET, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        TheSim:SetTimeScale(1)
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        TheSim:SetTimeScale(0)
    else
        TheSim:SetTimeScale(TheSim:GetTimeScale() - .25)
    end
    return true
end)

AddGlobalDebugKey(KEY_RIGHTBRACKET, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        TheSim:SetTimeScale(1)
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        TheSim:SetTimeScale(4)
    else
        TheSim:SetTimeScale(TheSim:GetTimeScale() + .25)
    end
    return true
end)

AddGameDebugKey(KEY_KP_PLUS, function()
    local MainCharacter = DebugKeyPlayer()

    if TheWorld ~= nil and not TheWorld.ismastersim then
        if TheInput:IsKeyDown(KEY_CTRL) then
            if TheInput:IsKeyDown(KEY_SHIFT) then
                ConsoleRemote("ThePlayer.components.health:DoDelta(%d)", {50})
                ConsoleRemote("c_sethunger(%d)", {1})
                ConsoleRemote("c_sethealth(%d)", {1})
                ConsoleRemote("c_setsanity(%d)", {1})
            else
                ConsoleRemote("ThePlayer.components.sanity:DoDelta(%d)", {5})
            end
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
            ConsoleRemote("ThePlayer.components.hunger:DoDelta(%d)", {25})
        elseif TheInput:IsKeyDown(KEY_ALT) then
            ConsoleRemote("ThePlayer.components.sanity:DoDelta(%d)", {25})
        else
            ConsoleRemote("ThePlayer.components.health:DoDelta(%d)", {25})
        end
    elseif MainCharacter ~= nil then
        if TheInput:IsKeyDown(KEY_CTRL) then
            if TheInput:IsKeyDown(KEY_SHIFT) then
                MainCharacter.components.health:DoDelta(50, nil, "debug_key")
                c_sethunger(1)
                c_sethealth(1)
                c_setsanity(1)
            else
                MainCharacter.components.sanity:DoDelta(5)
            end
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
            MainCharacter.components.hunger:DoDelta(25)
        elseif TheInput:IsKeyDown(KEY_ALT) then
            MainCharacter.components.sanity:DoDelta(25)
        else
            MainCharacter.components.health:DoDelta(25, nil, "debug_key")
        end
    end
    return true
end)

AddGameDebugKey(KEY_KP_MINUS, function()
    local MainCharacter = DebugKeyPlayer()
    if TheWorld ~= nil and not TheWorld.ismastersim then
        if TheInput:IsKeyDown(KEY_CTRL) then
            --ConsoleRemote("ThePlayer.components.temperature:DoDelta(%d)", {-10})
            --ConsoleRemote("TheSim:SetTimeScale(%d)", {TheSim:GetTimeScale() - .25})
            ConsoleRemote("ThePlayer.components.sanity:DoDelta(%d)", {-5})
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
            ConsoleRemote("ThePlayer.components.hunger:DoDelta(%d)", {-25})
        elseif TheInput:IsKeyDown(KEY_ALT) then
            ConsoleRemote("ThePlayer.components.sanity:SetPercent(%d)", {0})
        else
            ConsoleRemote("ThePlayer.components.health:DoDelta(%d)", {-25})
        end
    elseif MainCharacter ~= nil then
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
    if TheInput:IsKeyDown(KEY_ALT) then
		if c_sel() ~= nil and c_sel().components.locomotor ~= nil then
			c_sel().Transform:SetPosition(TheInput:GetWorldPosition():Get())
		end
    else
        local player = ConsoleCommandPlayer()
        if player then
            local topscreen = TheFrontEnd:GetActiveScreen()
            if topscreen.minimap ~= nil then

                local mousepos = TheInput:GetScreenPosition()
                local mousewidgetpos = topscreen:ScreenPosToWidgetPos( mousepos )
                local mousemappos = topscreen:WidgetPosToMapPos( mousewidgetpos )

                local x,y,z = topscreen.minimap:MapPosToWorldPos( mousemappos:Get() )

                if TheWorld ~= nil and not TheWorld.ismastersim then
                    ConsoleRemote("c_teleport(%d, %d, %d)", {x, 0, y})
                else
                    player.Physics:Teleport(x, 0, y)
                end
            else
                if TheWorld ~= nil and not TheWorld.ismastersim then
                    local x, y, z = ConsoleWorldPosition():Get()
                    player.Transform:SetPosition(x, y, z)
                    ConsoleRemote("c_teleport(%d, %d, %d)", {x, y, z})
                else
                    player.Physics:Teleport(TheInput:GetWorldPosition():Get())
                end
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
            elseif MouseCharacter.components.perishable then
                MouseCharacter.components.perishable:Perish()
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
    elseif TheInput:IsKeyDown(KEY_ALT) then
		c_armor()
    end
    return true
end)

AddGameDebugKey(KEY_D, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
        if MouseCharacter and MouseCharacter.components.diseaseable ~= nil then
            MouseCharacter.components.diseaseable:Disease()
        end
    end
end)

--AddGameDebugKey(KEY_P, function()
--    if TheInput:IsKeyDown(KEY_CTRL) then
--        local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
--        MouseCharacter = MouseCharacter or DebugKeyPlayer()
--        if MouseCharacter then
--            local pinnable = MouseCharacter.components.pinnable
--            if pinnable then
--                if pinnable:IsStuck() then
--                    pinnable:Unstick()
--                else
--                    pinnable:Stick()
--                end
--            end
--        end
--    end
--    return true
--end)

AddGameDebugKey(KEY_K, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        d_c_remove()
    end
    return true
end)


AddGlobalDebugKey(KEY_L, function()
	if not TheWorld then
		-- Debug loading screens. Need to re-create the loading screen as hot reload doesn't work with loaded widgets.
		if global_loading_widget then
			global_loading_widget:Kill()
			local image = global_loading_widget.image_random
			global_loading_widget = LoadingWidget(image)
			global_loading_widget:SetHAnchor(ANCHOR_LEFT)
			global_loading_widget:SetVAnchor(ANCHOR_BOTTOM)
			global_loading_widget:SetScaleMode(SCALEMODE_PROPORTIONAL)

			TheFrontEnd:SetFadeLevel(1)
            if not TheNet:IsDedicated() then
			    global_loading_widget:SetEnabled(true)
            end
		end
	else
	    if not ThePlayer then
			-- ThePlayer is nil in lobby screens (which count as GameDebug).
			return
		end
		--local pt = TheInput:GetWorldPosition()
		local pt = ThePlayer:GetPosition()

		if TheInput:IsKeyDown(KEY_SHIFT) then
			local node_index = TheWorld.Map:GetNodeIdAtPoint(pt:Get())
			print("Node (" .. tostring(node_index) .. "): " .. tostring(TheWorld.topology.ids[node_index]))
			print("Node Tags:", (TheWorld.topology.nodes[node_index] == nil or #TheWorld.topology.nodes[node_index].tags == 0) and "<empty>" or unpack(TheWorld.topology.nodes[node_index].tags))

			return
		end

		local GROUND_NAMES = table.invert(GROUND)

		local x, _, z = pt:Get()
		local k = 4
		local str = "\n"
		local name_space = 20
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

				str = str .. tostring(GROUND_NAMES[tile])
				for i = #(GROUND_NAMES[tile]), name_space, 1 do
					str = str .. " "
				end
			end
			str = str .. "\n"
		end

		print (str)
		--print (str .. tostring(valid == true))

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
	end
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
    local MainCharacter = ConsoleCommandPlayer()
    if MainCharacter then
        if TheInput:IsKeyDown(KEY_CTRL) then
            enable_fog = not enable_fog
            TheWorld.minimap.MiniMap:EnableFogOfWar(enable_fog)
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
            hide_revealed = not hide_revealed
            TheWorld.minimap.MiniMap:ContinuouslyClearRevealedAreas(hide_revealed)
		elseif TheInput:IsKeyDown(KEY_ALT) then
            enable_fog = false
            TheWorld.minimap.MiniMap:EnableFogOfWar(enable_fog)

			for x=-1000,1000,30 do
				for y=-1000,1000,30 do
					ThePlayer.player_classified.MapExplorer:RevealArea(x ,0, y)
				end
			end
        end
    end

    return true
end)

AddGameDebugKey(KEY_N, function()
    c_gonext()
end)

AddGameDebugKey(KEY_S, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        if TheWorld and not TheWorld.ismastersim then
            ConsoleRemote("c_save()")
        else
            TheWorld:PushEvent("ms_save")
        end
        return true
    end
end)

AddGameDebugKey(KEY_KP_MULTIPLY, function()
    if TheInput:IsDebugToggleEnabled() then
        d_c_give("devtool")
        return true
    end
end)

AddGameDebugKey(KEY_KP_DIVIDE, function()
    if TheInput:IsDebugToggleEnabled() and DebugKeyPlayer() ~= nil then
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
		if TheWorld.components.hounded ~= nil then
	        TheWorld.components.hounded:ForceNextWave()
		end
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
        d_c_spawn("dragonfly")
    elseif TheInput:IsKeyDown(KEY_CTRL) and not TheInput:IsKeyDown(KEY_SHIFT) then
        d_c_spawn("light_flower"):TurnOn()
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

AddGameDebugKey(KEY_5, function()
	if TheWorld.components.farming_manager then
		local pos = TheInput:GetWorldPosition()
		local x, y = TheWorld.Map:GetTileCoordsAtPoint(pos:Get())
		local n1, n2, n3 = TheWorld.components.farming_manager:GetTileNutrients(x,y)
		if TheInput:IsKeyDown(KEY_SHIFT) then
			local _n1, _n2, _n3 = 1, 1, 1
			if TheInput:IsKeyDown(KEY_ALT) then
				_n1 = 4
				_n2 = 4
				_n3 = 4
			end
			if TheInput:IsKeyDown(KEY_CTRL) then
				_n1 = _n1 * -1
				_n2 = _n2 * -1
				_n3 = _n3 * -1
			end
			TheWorld.components.farming_manager:AddTileNutrients(x, y, _n1, _n2, _n3)
			n1, n2, n3 = TheWorld.components.farming_manager:GetTileNutrients(x,y)
		end
		print(string.format("Tile nutrients: %u, %u, %u", n1, n2, n3))
	end
end)
AddGameDebugKey(KEY_6, function()
	if TheWorld.components.farming_manager then
		local pos = TheInput:GetWorldPosition()
		local x, y = TheWorld.Map:GetTileCoordsAtPoint(pos:Get())
		local n1, n2, n3 = TheWorld.components.farming_manager:GetTileNutrients(x,y)
		if TheInput:IsKeyDown(KEY_SHIFT) then
			local _n1 = 1
			if TheInput:IsKeyDown(KEY_ALT) then
				_n1 = 4
			end
			if TheInput:IsKeyDown(KEY_CTRL) then
				_n1 = _n1 * -1
			end
			TheWorld.components.farming_manager:AddTileNutrients(x, y, _n1, 0, 0)
			n1, n2, n3 = TheWorld.components.farming_manager:GetTileNutrients(x,y)
		end
		print(string.format("Tile nutrients: %u, %u, %u", n1, n2, n3))
	end
end)
AddGameDebugKey(KEY_7, function()
	if TheWorld.components.farming_manager then
		local pos = TheInput:GetWorldPosition()
		local x, y = TheWorld.Map:GetTileCoordsAtPoint(pos:Get())
		local n1, n2, n3 = TheWorld.components.farming_manager:GetTileNutrients(x,y)
		if TheInput:IsKeyDown(KEY_SHIFT) then
			local _n2 = 1
			if TheInput:IsKeyDown(KEY_ALT) then
				_n2 = 4
			end
			if TheInput:IsKeyDown(KEY_CTRL) then
				_n2 = _n2 * -1
			end
			TheWorld.components.farming_manager:AddTileNutrients(x, y, 0, _n2, 0)
			n1, n2, n3 = TheWorld.components.farming_manager:GetTileNutrients(x,y)
		end
		print(string.format("Tile nutrients: %u, %u, %u", n1, n2, n3))
	end
end)
AddGameDebugKey(KEY_8, function()
	if TheWorld.components.farming_manager then
		local pos = TheInput:GetWorldPosition()
		local x, y = TheWorld.Map:GetTileCoordsAtPoint(pos:Get())
		local n1, n2, n3 = TheWorld.components.farming_manager:GetTileNutrients(x,y)
		if TheInput:IsKeyDown(KEY_SHIFT) then
			local _n3 = 1
			if TheInput:IsKeyDown(KEY_ALT) then
				_n3 = 4
			end
			if TheInput:IsKeyDown(KEY_CTRL) then
				_n3 = _n3 * -1
			end
			TheWorld.components.farming_manager:AddTileNutrients(x, y, 0, 0, _n3)
			n1, n2, n3 = TheWorld.components.farming_manager:GetTileNutrients(x,y)
		end
		print(string.format("Tile nutrients: %u, %u, %u", n1, n2, n3))
	end
end)

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
    else
        if not ThePlayer.shownothightlight then
            ThePlayer.shownothightlight = true
            TheWorld.speechdisabled = true
        else
            TheWorld.speechdisabled = nil
            ThePlayer.shownothightlight = nil
        end
        ThePlayer.HUD:Toggle(true)
    end
end)

local invaliddebugspawnprefabs =
{
    ["forest"] = true,
    ["cave"] = true,
    ["quagmire"] = true,
    ["lavaarena"] = true,
    ["world"] = true,
}

-------------------------------------------MOUSE HANDLING
local DEBUGRMB_IGNORE_TAGS = {"wall", "INLIMBO"}
local function DebugRMB(x,y)
    local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
    local pos = TheInput:GetWorldPosition()

    if TheInput:IsKeyDown(KEY_CTRL) and
       TheInput:IsKeyDown(KEY_SHIFT) and
       c_sel() and c_sel().prefab and not invaliddebugspawnprefabs[c_sel().prefab] then
        local spawn = d_c_spawn(c_sel().prefab)
        if spawn then
            spawn.Transform:SetPosition(pos:Get())
        end
    elseif TheInput:IsKeyDown(KEY_CTRL) and TheWorld then
        if not TheWorld.ismastersim or MouseCharacter then
            d_c_remove()
        else
            local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 5, nil, DEBUGRMB_IGNORE_TAGS)
            for k,v in pairs(ents) do
                if v.components.health and v ~= ConsoleCommandPlayer() then
                    v.components.health:Kill()
                end
            end
        end
    elseif TheInput:IsKeyDown(KEY_ALT) then
        local player = c_sel() or ConsoleCommandPlayer()
        if player then
            print(tostring(player) .. " to " .. tostring(pos) .. ": Dist = " .. tostring(math.sqrt(player:GetDistanceSqToPoint(pos))) .. ", Angle = " .. tostring(player:GetAngleToPoint(pos)))
        end
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        if MouseCharacter then
            SetDebugEntity(MouseCharacter)
        elseif TheWorld then
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

---------------------------------------------------

function d_addemotekeys()
	local UserCommands = require("usercommands")

	AddGameDebugKey(KEY_KP_0, function() UserCommands.RunUserCommand("sit", {}, ThePlayer, false) end)
	AddGameDebugKey(KEY_KP_1, function() UserCommands.RunUserCommand("happy", {}, ThePlayer, false) end)
	AddGameDebugKey(KEY_KP_2, function() UserCommands.RunUserCommand("joy", {}, ThePlayer, false) end)
	AddGameDebugKey(KEY_KP_3, function() UserCommands.RunUserCommand("slowclap", {}, ThePlayer, false) end)
	AddGameDebugKey(KEY_KP_4, function() UserCommands.RunUserCommand("no", {}, ThePlayer, false) end)
	AddGameDebugKey(KEY_KP_5, function() UserCommands.RunUserCommand("angry", {}, ThePlayer, false) end)
	AddGameDebugKey(KEY_KP_6, function() UserCommands.RunUserCommand("facepalm", {}, ThePlayer, false) end)
	AddGameDebugKey(KEY_KP_7, function() UserCommands.RunUserCommand("impatient", {}, ThePlayer, false) end)
	AddGameDebugKey(KEY_KP_8, function() UserCommands.RunUserCommand("shrug", {}, ThePlayer, false) end)
	AddGameDebugKey(KEY_KP_9, function() UserCommands.RunUserCommand("wave", {}, ThePlayer, false) end)
	AddGameDebugKey(KEY_KP_PERIOD, function() UserCommands.RunUserCommand("fistshake", {}, ThePlayer, false) end)

end

