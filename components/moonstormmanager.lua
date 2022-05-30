--------------------------------------------------------------------------
--[[ moon storm manager class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Moon Storm Manager should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------
local SPARKLIMIT = 3
--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst
self.metplayers = {}

--Private
local _alterguardian_defeated_count = 0

local _activeplayers = {}
local _currentbasenodeindex = nil
local _currentnodes = nil

local _moonstyle_altar = nil

local _nummoonstormpropagationsteps = 3

local _basenodemindistancefromprevious = 50

local function ontimerdone(inst, data)
	if data.name == "moonstorm_experiment_complete" then
		self:EndExperiment()
	end
end

self.inst:ListenForEvent("timerdone", ontimerdone)

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------
local function getlightningtime()
	return math.random()*30+10
end

local function onremovewagstaff()

	if self.wagstaff then
		self.wagstaff = nil
	end
end


local SPAWNDIST = 40
local SCREENDIST = 30
local MIN_NODES = 4
local MAX_NODES = 10

local BIRDBLOCKER_TAGS = {"birdblocker"}
local function customcheckfn(pt)
	return #(TheSim:FindEntities(pt.x, 0, pt.z, 4, BIRDBLOCKER_TAGS)) == 0 and TheWorld.net.components.moonstorms ~= nil and TheWorld.net.components.moonstorms:IsPointInMoonstorm(pt) or false
end

local function screencheckfn(pt)
	if customcheckfn(pt) then
		for i,player in pairs(_activeplayers)do
			if player:GetDistanceSqToPoint(pt.x, pt.y, pt.z) < SCREENDIST*SCREENDIST then
				return false
			end
		end
		return true
	end
	return false
end

local function findnewcluelocation(currentpos, finalhunt, spawndist)
	if not spawndist then
		spawndist = SPAWNDIST
	end
	local pos = nil
	local testfn = screencheckfn
	local center = TheWorld.net.components.moonstorms and TheWorld.net.components.moonstorms:GetMoonstormCenter()
	local dist
	local function finalhuntcheckfn(pt)
		if testfn(pt) then
			local currdist = pt:DistSq(center)
			if dist == nil or dist > currdist then
				dist = currdist
				pos = pt
			end
		end
		return false
	end

	for i = 1, 4 do
		dist = nil
		if finalhunt then
			--pos isn't gotten directly from the function, as we want the best position closest to the moonstorm.
			FindWalkableOffset(currentpos, math.random()*2*PI, SPAWNDIST, 16, true, nil, finalhuntcheckfn, nil, nil)
		else
			pos = FindWalkableOffset(currentpos, math.random()*2*PI, SPAWNDIST, 16, true, nil, testfn, nil, nil)
		end

		if pos then
			pos = currentpos + pos
			break
		end
		if i >= 2 then
			testfn = customcheckfn
		end
	end
	return pos
end

--[[
local function OnPlayerChangeStorm(player, data)
	if data.level < TUNING.SANDSTORM_FULL_LEVEL then
		-- player left storm
	else
		-- player enter storm
	end
end
]]
local function NodeCanHaveMoonstorm(node)
	return (not self.lastnodes or not table.contains(self.lastnodes, node.area))
		and not table.contains(node.tags, "lunacyarea")
		and not table.contains(node.tags, "sandstorm")
		and not TheWorld.Map:IsOceanAtPoint(node.cent[1], 0, node.cent[2])
end

local function AltarAngleTest(altar, other_altar1, other_altar2)
    local x, _, z = altar.Transform:GetWorldPosition()
    local x1, _, z1 = other_altar1.Transform:GetWorldPosition()
    local x2, _, z2 = other_altar2.Transform:GetWorldPosition()

    local delta_normalized_this_to_other1_x, delta_normalized_this_to_other1_z = VecUtil_Normalize(x1 - x, z1 - z)
    local delta_normalized_this_to_other2_x, delta_normalized_this_to_other2_z = VecUtil_Normalize(x2 - x, z2 - z)
    local dot_this_to_other1_other2 = VecUtil_Dot(
        delta_normalized_this_to_other1_x, delta_normalized_this_to_other1_z,
        delta_normalized_this_to_other2_x, delta_normalized_this_to_other2_z)
    return math.abs(dot_this_to_other1_other2) <= TUNING.MOON_ALTAR_LINK_MAX_ABS_DOT
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerJoined(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)

	if TheWorld.net.components.moonstorms and next(TheWorld.net.components.moonstorms._moonstorm_nodes:value()) ~= nil then
		player.components.moonstormwatcher:ToggleMoonstorms({setting=true})
	end
end

local function OnPlayerLeft(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            table.remove(_activeplayers, i)
            return
        end
    end
end

local function setmoonphasestyle()

	TheWorld:PushEvent("ms_setmoonphasestyle", {style = _alterguardian_defeated_count == 0 and "alter_active" or "glassed_alter_active"})
    TheWorld:PushEvent("ms_lockmoonphase", {lock = true})

end

local function StartTheMoonstorms()
    TheWorld:PushEvent("ms_setclocksegs", {day = 0, dusk = 0, night = 16})
    TheWorld:PushEvent("ms_setmoonphase", {moonphase = "full", iswaxing = false})
	setmoonphasestyle()
    _moonstyle_altar = true
    self:StartMoonstorm()
end

local function StopTheMoonstorms()
	_alterguardian_defeated_count = _alterguardian_defeated_count + 1

	TheWorld:PushEvent("ms_setclocksegs", {day = 0, dusk = 0, night = 16})
	TheWorld:PushEvent("ms_setmoonphase", {moonphase = "new", iswaxing = true})
	TheWorld:PushEvent("ms_setmoonphasestyle", {style = "glassed_default"})
	TheWorld:PushEvent("ms_lockmoonphase", {lock = false})
	_moonstyle_altar = nil

    self:StopCurrentMoonstorm()
end

local function on_day_change()
	if self.wagstaff and self.wagstaff.hunt_stage and self.wagstaff.hunt_stage == "experiment" then
		return
	end
	if TheWorld.net.components.moonstorms and next(TheWorld.net.components.moonstorms:GetMoonstormNodes()) then
		self.stormdays = self.stormdays + 1
		if self.stormdays >= TUNING.MOONSTORM_MOVE_TIME then
			if math.random() < Remap(self.stormdays, TUNING.MOONSTORM_MOVE_TIME, TUNING.MOONSTORM_MOVE_MAX,0.1,1) then
				self:StopCurrentMoonstorm()

				if self.wagstaff then
			        self.wagstaff.busy = self.wagstaff.busy and self.wagstaff.busy + 1 or 1

			        self.wagstaff:PushEvent("talk")
  					self.wagstaff.components.talker:Say(self.wagstaff.getline(STRINGS.WAGSTAFF_NPC_NO_WAY1))

			        self.wagstaff:DoTaskInTime(3,function()

			        	self.wagstaff:PushEvent("talk")
  						self.wagstaff.components.talker:Say(self.wagstaff.getline(STRINGS.WAGSTAFF_NPC_NO_WAY2))

						self.wagstaff:DoTaskInTime(3,function()

							self.wagstaff:PushEvent("talk")
  							self.wagstaff.components.talker:Say(self.wagstaff.getline(STRINGS.WAGSTAFF_NPC_NO_WAY3))

				            self.wagstaff:DoTaskInTime(2,function()
				                self.wagstaff:erode(2,nil,true)
				            end)
				        end)
			        end)
				end

				self.startstormtask = inst:DoTaskInTime(0,function() self:StartMoonstorm() end)
			end
		end
	end
end
--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined)
--Register events

inst:ListenForEvent("ms_playerleft", OnPlayerLeft)
inst:ListenForEvent("ms_startthemoonstorms", StartTheMoonstorms)
inst:ListenForEvent("ms_stopthemoonstorms", StopTheMoonstorms)
inst:WatchWorldState("cycles", on_day_change)


inst.moonstormwindowovertask = inst:DoTaskInTime(0,function()  TheWorld:PushEvent("ms_moonstormwindowover") end)
--------------------------------------------------------------------------
--[[ Public getters and setters ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------


-- STORM FUNCTIONS

function self:CalcNewMoonstormBaseNodeIndex()
	local num_nodes = #TheWorld.topology.nodes
	local index_offset = math.random(1, num_nodes)
	local mindistsq = _basenodemindistancefromprevious * _basenodemindistancefromprevious

	for i = 1, num_nodes do
		local ind = math.fmod(i + index_offset, num_nodes) + 1
		local new_node = TheWorld.topology.nodes[ind]

		if ind ~= _currentbasenodeindex then
			local current_node = TheWorld.topology.nodes[_currentbasenodeindex]

			if _currentbasenodeindex ~= nil then
				local new_x, new_z = new_node.cent[1], new_node.cent[2]
				local current_x, current_z = current_node.cent[1], current_node.cent[2]

				if NodeCanHaveMoonstorm(new_node) and VecUtil_LengthSq(new_x - current_x, new_z - current_z) > mindistsq then
					return ind
				end
			else
				if NodeCanHaveMoonstorm(new_node) then
					return ind
				end
			end
		end
	end

	print("MoonstormManager failed to find a valid moonstorm base node")
end

function self:StartMoonstorm(set_first_node_index,nodes)
	self:StopCurrentMoonstorm()

	if self.startstormtask then
		self.startstormtask:Cancel()
		self.startstormtask = nil
	end

	if not TheWorld.net or not TheWorld.net.components.moonstorms == nil then
		print("NO COMPONENT  TheWorld.net.components.moonstorms")
		return
	end

	local checked_nodes = {}
	local new_storm_nodes = nodes or {}
	local first_node_index = set_first_node_index or nil

	local function propagatestorm(node, steps, nodelist)
		if not checked_nodes[node] and NodeCanHaveMoonstorm(TheWorld.topology.nodes[node]) then
			checked_nodes[node] = true

			table.insert(nodelist, node)

			local node_edges = TheWorld.topology.nodes[node].validedges
			-- print("		adding node:", node, "		steps remaining:", steps)

			-- print("iterating", #node_edges, "node edges")
			for _, edge_index in ipairs(node_edges) do
				local edge_nodes = TheWorld.topology.edgeToNodes[edge_index]
				local other_node_index = edge_nodes[1] ~= node and edge_nodes[1] or edge_nodes[2]

				if steps > 0 and #nodelist < MAX_NODES then
					propagatestorm(other_node_index, steps - 1, nodelist)
				end
			end
		else
			return
		end
	end
	local trial = 0
	if not new_storm_nodes or #new_storm_nodes < MIN_NODES then
		while #new_storm_nodes < MIN_NODES do
			new_storm_nodes = {}
			if set_first_node_index and trial < 1 then
				trial = trial + 1
			else
				if trial > 0 then
					print("SET_FIRST_NODE_INDEX failed to generate enough nodes, using random")
				end
				first_node_index = self:CalcNewMoonstormBaseNodeIndex()
			end
			if first_node_index == nil then
				print("MoonstormManager failed to start moonstorm")
				return
			end
			--end
			propagatestorm(first_node_index, _nummoonstormpropagationsteps, new_storm_nodes)
		end
	end

	_currentbasenodeindex = first_node_index
	_currentnodes = new_storm_nodes

	TheWorld.net.components.moonstorms:ClearMoonstormNodes()
	TheWorld.net.components.moonstorms:AddMoonstormNodes(new_storm_nodes, _currentbasenodeindex)

	self.spawn_wagstaff_test_task = self.inst:DoPeriodicTask(10,function() self:DoTestForWagstaff() end)
	self.moonstorm_spark_task = self.inst:DoPeriodicTask(30,function() self:DoTestForSparks() end)
	self.moonstorm_lightning_task = self.inst:DoTaskInTime(getlightningtime(),function() self:DoTestForLightning() end)

	self.stormdays = 0
end

function self:StopCurrentMoonstorm()
	self.lastnodes = TheWorld.net.components.moonstorms.convertlist(TheWorld.net.components.moonstorms:GetMoonstormNodes()) or {}
	if self.spawn_wagstaff_test_task then
		self.spawn_wagstaff_test_task:Cancel()
		self.spawn_wagstaff_test_task = nil
	end
	if self.moonstorm_spark_task then
		self.moonstorm_spark_task:Cancel()
		self.moonstorm_spark_task = nil
	end
	if self.moonstorm_lightning_task then
		self.moonstorm_lightning_task:Cancel()
		self.moonstorm_lightning_task = nil
	end

	if TheWorld.net.components.moonstorms ~= nil then
		local is_relocating = _moonstyle_altar ~= nil
		TheWorld.net.components.moonstorms:StopMoonstorm(is_relocating)
	end
	_currentbasenodeindex = nil
	_currentnodes = nil
	self.MoonStorm_Ending = true

end

function self:StopExperimentTasks()

	self.inst.components.timer:StopTimer("moonstorm_experiment_complete")

	if self.tools_task then
		self.tools_task:Cancel()
		self.tools_task = nil
	end
	if self.tools_need then
		self.tools_need:Cancel()
		self.tools_need = nil
	end

	if self.defence_task then
		self.defence_task:Cancel()
		self.defence_task = nil
	end
	if self.wagstaff and self.wagstaff.need_tool_task then
		self.wagstaff.need_tool_task:Cancel()
		self.wagstaff.need_tool_task = nil
	end

end

-- WAGSTAFF HUNT FUNCTIONS
function self:StopExperiment()
	self:StopExperimentTasks()
	if self.wagstaff_tools then
		for i=#self.wagstaff_tools,1,-1 do
			local tool = self.wagstaff_tools[i]
			if tool:IsInLimbo() then
				tool:Remove()
			else
				tool:RemoveComponent("inventoryitem")
				tool:erode(2,nil,true)
			end

		end
		self.wagstaff_tools = nil
	end
end

function self:FailExperiment()

    if self.wagstaff and not self.wagstaff.failtasks then
    	self.wagstaff:StopMusic()
    	self.wagstaff.busy = self.wagstaff.busy and self.wagstaff.busy + 1 or 1
        self.wagstaff.failtasks = self.wagstaff:DoTaskInTime(1,function()
            self.wagstaff:PushEvent("talk")
            self.wagstaff.components.talker:Say(self.wagstaff.getline(STRINGS.WAGSTAFF_NPC_EXPERIMENT_FAIL_1))
            self.wagstaff.failtasks = self.wagstaff:DoTaskInTime(4,function()
                self.wagstaff:PushEvent("talk")
                self.wagstaff.components.talker:Say(self.wagstaff.getline(STRINGS.WAGSTAFF_NPC_EXPERIMENT_FAIL_2))
                self.wagstaff:erode(3,nil,true)
            end)
        end)
    end


	self:StopExperiment()
end

function self:EndExperiment()
	if self.wagstaff then
		self.wagstaff:StopMusic()
		self.wagstaff.busy = self.wagstaff.busy and self.wagstaff.busy + 1 or 1
		self.wagstaff.donexperiment = true
		self.wagstaff:PushEvent("doneexperiment")
		self.wagstaff:PushEvent("talk")
		self.wagstaff.components.talker:Say(self.wagstaff.getline(STRINGS.WAGSTAFF_NPC_EXPERIMENT_DONE_1))
		self.wagstaff:DoTaskInTime(4,function()
			self.wagstaff:PushEvent("talk")
			self.wagstaff.components.talker:Say(self.wagstaff.getline(STRINGS.WAGSTAFF_NPC_EXPERIMENT_DONE_2))
			self.wagstaff:DoTaskInTime(4,function()

				self.wagstaff:erode(2,nil,true)
			end)
		end)

		-- SPAWN THING
		if self.wagstaff.static then
			self.wagstaff.static:finished()
		end

		self:StartMoonstorm()
	end

	self:StopExperiment()
end

function self:beginWagstaffHunt(player)
	local playerpos = Vector3(player.Transform:GetWorldPosition())
	local pos = findnewcluelocation(playerpos)
	if pos then
		local wagstaff = SpawnPrefab("wagstaff_npc")
		wagstaff.hunt_stage = "hunt"
	    wagstaff.hunt_count = 0
		wagstaff.Transform:SetPosition(pos.x,pos.y,pos.z)

		wagstaff.components.timer:StartTimer("expiretime",TUNING.WAGSTAFF_NPC_EXPIRE_TIME)
		wagstaff.components.timer:StartTimer("wagstaff_movetime",10 + (math.random()*5))
		wagstaff:ListenForEvent("onremove", onremovewagstaff)
		self.wagstaff = wagstaff
	end
end

function self:AdvanceWagstaff()
	if self.wagstaff then
		local pos = self:GetNewWagstaffLocation(self.wagstaff)
		if pos and self.wagstaff.hunt_stage == "hunt" then
			self.wagstaff.components.timer:SetTimeLeft("expiretime",TUNING.WAGSTAFF_NPC_EXPIRE_TIME)
			return pos
		end
	end
end

function self:FindUnmetCharacter()
	local players = {}
	local player = nil
	for i, v in ipairs(_activeplayers) do
		local pt = Vector3(v.Transform:GetWorldPosition())
		if TheWorld.net.components.moonstorms and TheWorld.net.components.moonstorms:IsPointInMoonstorm(pt) then
			if not self.metplayers[v.userid] then
				table.insert(players,v)
			end
		end
	end
	if #players > 0 then
		player = players[math.random(1,#players)]
	end
 	if player then
		return Vector3(player.Transform:GetWorldPosition())
	end
end

function self:GetNewWagstaffLocation(wagstaff)
	local newpos = Vector3(wagstaff.Transform:GetWorldPosition())
	return findnewcluelocation(newpos, wagstaff.hunt_count and wagstaff.hunt_count >= TUNING.WAGSTAFF_NPC_HUNTS)
end


function self:startNeedTool()
	if self.wagstaff then
		self.inst.components.timer:PauseTimer("moonstorm_experiment_complete")
		self.wagstaff:WaitForTool()
	end
end

function self:foundTool()
	self.inst.components.timer:ResumeTimer("moonstorm_experiment_complete")
	self.wagstaff:PushEvent("doexperiment")
	self.tools_need = inst:DoTaskInTime(10 + (math.random()*10), function() self:startNeedTool() end)
	if self.wagstaff.need_tool_task then
		self.wagstaff.need_tool_task:Cancel()
		self.wagstaff.need_tool_task = nil
	end
end

function self:AddMetplayer(id)
	self.metplayers[id] = true
end

function self:beginWagstaffDefence()

	self.wagstaff.components.timer:StopTimer("expiretime")

	if not self.wagstaff_tools then
		self.wagstaff_tools_original = {
			"wagstaff_tool_1",
			"wagstaff_tool_2",
			"wagstaff_tool_3",
			"wagstaff_tool_4",
			"wagstaff_tool_5",
		}
		self.wagstaff_tools = {}
		self.tools_task = inst:DoTaskInTime(10,function() self:spawnTool() end)
		self.inst.components.timer:StartTimer("moonstorm_experiment_complete", TUNING.WAGSTAFF_EXPERIMENT_TIME )
		self.tools_need = inst:DoTaskInTime(10 + (math.random()*5), function() self:startNeedTool() end)
		self.wagstaff:PushEvent("doexperiment")
	end
	if not self.defence_task then
		self.defence_task = inst:DoTaskInTime(1,function() self:spawnGestaltWave() end)
	end
end


function self:SpawnGestalt(angle, prefab)
	if self.wagstaff and self.wagstaff:IsValid() then
		local pos = Vector3(self.wagstaff.Transform:GetWorldPosition())
		local gestalt = SpawnPrefab(prefab)

		local newpos = FindWalkableOffset(pos, angle + (math.random()*PI/4), 16 + math.random()*8 , 16, nil, nil, customcheckfn, nil, nil)

		if newpos then
			pos = pos + newpos
			pos.y = 15
			gestalt.Transform:SetPosition(pos.x,pos.y,pos.z)
			if self.wagstaff.static then
				gestalt.components.entitytracker:TrackEntity("swarmTarget", self.wagstaff.static)
			end
			gestalt:PushEvent("arrive")
		end
	end
end

local MUTANT_BIRD_MUST_HAVE = {"bird_mutant"}
local MUTANT_BIRD_MUST_NOT_HAVE = {"INLIMBO"}

function self:spawnGestaltWave()

	if self.wagstaff then
		local x,y,z = self.wagstaff.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 30, MUTANT_BIRD_MUST_HAVE,MUTANT_BIRD_MUST_NOT_HAVE)

		if #ents < 16 then
			local currentpos = Vector3(self.wagstaff.Transform:GetWorldPosition())
			local angle =  math.random()*2*PI

			for i=1,math.random(3,5) do
				inst:DoTaskInTime(math.random()*0.5,function() self:SpawnGestalt(angle,"bird_mutant") end)
			end
			for i=1,math.random(1,3) do
				inst:DoTaskInTime(math.random()*0.5,function() self:SpawnGestalt(angle, "bird_mutant_spitter") end)
			end
		end
		local timeleft = self.inst.components.timer:GetTimeLeft("moonstorm_experiment_complete")
		local time = Remap(timeleft,TUNING.WAGSTAFF_EXPERIMENT_TIME,0,15,7)
		if self.defence_task then
			self.defence_task:Cancel()
			self.defence_task = nil
		end
		self.defence_task = inst:DoTaskInTime(time,function() self:spawnGestaltWave() end)
	end
end

function self:spawnTool()
	if not self.wagstaff then
		return
	end

	if self.wagstaff_tools and #self.wagstaff_tools_original > 0 then

		local idx = math.random(1,#self.wagstaff_tools_original)
		local toolname = self.wagstaff_tools_original[idx]
		table.remove(self.wagstaff_tools_original,idx)

		local tool = SpawnPrefab(toolname)
		tool:ListenForEvent("onremove", function()
				if self.wagstaff_tools then
					for i,settool in ipairs(self.wagstaff_tools) do
						if settool == tool then
							table.insert(self.wagstaff_tools_original,tool.prefab)
							table.remove(self.wagstaff_tools, i)
							break
						end
					end
				end
			end)
		local currentpos = Vector3(self.wagstaff.Transform:GetWorldPosition())
		local pos = FindWalkableOffset(currentpos, math.random()*2*PI, 6+ (math.random()* 4), 16, nil, nil, customcheckfn, nil, nil) or Vector3(0,0,0)
		local newpos = currentpos + pos
		tool.Transform:SetPosition(newpos.x,0,newpos.z)
		table.insert(self.wagstaff_tools,tool)

		--[[
		if #self.wagstaff_tools >= 4 then
			local oldtool = self.wagstaff_tools[1]
			table.insert(self.wagstaff_tools_original,oldtool.prefab)
			table.remove(self.wagstaff_tools, 1)
			oldtool:Remove()
		end
		]]
	end
	self.tools_task = inst:DoTaskInTime(8,function() self:spawnTool() end)
end

function self:DoTestForWagstaff()
	if not self.wagstaff  then

		local eligible_players = {}
		for i, v in ipairs(_activeplayers) do
			local valid = v:IsValid() and v.components.health ~= nil and not v.components.health:IsDead()
			if valid then
				local pt = Vector3(v.Transform:GetWorldPosition())
				if TheWorld.net.components.moonstorms and TheWorld.net.components.moonstorms:IsPointInMoonstorm(pt) then
					table.insert(eligible_players,v)
				end
			end
		end
		if #eligible_players > 0 then
			self:beginWagstaffHunt(eligible_players[math.random(1,#eligible_players)])
		end
	end
end

local MOONSTORM_SPARKS_MUST_HAVE= {"moonstorm_spark"}
local MOONSTORM_SPARKS_CANT_HAVE= {"INLIMBO"}

function self:DoTestForSparks()
	for i, v in ipairs(_activeplayers) do
		local pt = Vector3(v.Transform:GetWorldPosition())
		if TheWorld.net.components.moonstorms and TheWorld.net.components.moonstorms:IsPointInMoonstorm(pt) then
			local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 30, MOONSTORM_SPARKS_MUST_HAVE,MOONSTORM_SPARKS_CANT_HAVE)
			if #ents < SPARKLIMIT then
				local pos = FindWalkableOffset(pt, math.random()*2*PI, 5 + math.random()* 20, 16, nil, nil, customcheckfn, nil, nil)
				if pos then
					local spark = SpawnPrefab("moonstorm_spark")
					spark.Transform:SetPosition(pt.x + pos.x,0,pt.z + pos.z)
				end
			end
		end
	end
end

function self:DoTestForLightning()
	local candidates = {}
	for i, v in ipairs(_activeplayers) do
		local pt = Vector3(v.Transform:GetWorldPosition())
		if TheWorld.net.components.moonstorms and TheWorld.net.components.moonstorms:IsPointInMoonstorm(pt) then
			table.insert(candidates,v)
		end
	end

	if #candidates > 0 then
		local candidate = candidates[math.random(1,#candidates)]
		local pt = Vector3(candidate.Transform:GetWorldPosition())
		local pos = FindWalkableOffset(pt, math.random()*2*PI, 5 + math.random()* 10, 16, nil, nil, customcheckfn, nil, nil)
		if pos then
			local spark = SpawnPrefab("moonstorm_lightning")
			spark.Transform:SetPosition(pt.x + pos.x,0,pt.z + pos.z)
		end
	end
	self.moonstorm_lightning_task = self.inst:DoTaskInTime(getlightningtime(),function() self:DoTestForLightning() end)
end

function self:TestMoonAltarLinkPositionValid(pt)
	local link_x, link_z = pt.x, pt.z

	if not TheWorld.Map:IsPassableAtPoint(link_x, 0, link_z, false, true)
		or not TheWorld.Map:IsAboveGroundAtPoint(link_x, 0, link_z, false) then

		return false
	end

	local ents = TheSim:FindEntities(link_x, 0, link_z, 10) -- 10: at least the size of the largest deploy_extra_spacing
	for _, v in ipairs(ents) do
		if (v:HasTag("antlion_sinkhole_blocker") and v:GetDistanceSqToPoint(link_x, 0, link_z) <= TUNING.MOON_ALTAR_LINK_POINT_VALID_RADIUS_SQ)
			or (v.deploy_extra_spacing ~= nil and v:GetDistanceSqToPoint(link_x, 0, link_z) <= v.deploy_extra_spacing * v.deploy_extra_spacing) then

			return false
		end
	end

	return true
end

function self:TestAltarTriangleValid(altar0, altar1, altar2, center_pt)
	-- center_pt should be nil if testing whether a newly completed triangle of altars
	-- should create a moon_altar_link instance, and a value if testing if an existing
	-- moon_altar_link instance is in a valid position (e.g. on loading the world)

	local altar0_x, _, altar0_z = altar0.Transform:GetWorldPosition()
	local altar1_x, _, altar1_z = altar1.Transform:GetWorldPosition()
	local altar2_x, _, altar2_z = altar2.Transform:GetWorldPosition()

	if altar0:GetDistanceSqToPoint(altar1_x, 0, altar1_z) < TUNING.MOON_ALTAR_LINK_ALTAR_MIN_RADIUS_SQ
		or altar0:GetDistanceSqToPoint(altar2_x, 0, altar2_z) < TUNING.MOON_ALTAR_LINK_ALTAR_MIN_RADIUS_SQ
		or altar1:GetDistanceSqToPoint(altar2_x, 0, altar2_z) < TUNING.MOON_ALTAR_LINK_ALTAR_MIN_RADIUS_SQ then

		return false
	end

	if not AltarAngleTest(altar0, altar1, altar2)
		or not AltarAngleTest(altar1, altar2, altar0) then

		return false
	end

	local center_x, center_z
	if center_pt ~= nil then
		center_x, center_z = center_pt.x, center_pt.z
	else
		center_x, center_z = (altar0_x + altar1_x + altar2_x) / 3, (altar0_z + altar1_z + altar2_z) / 3
	end

	if not self:TestMoonAltarLinkPositionValid(Point(center_x, 0, center_z)) then
		return false
	end

	return true
end

self.LongUpdate = self.OnUpdate

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	local data = {}
	data.stormdays = self.stormdays
	data.currentbasenodeindex = self.currentbasenodeindextemp or _currentbasenodeindex
	data.currentnodes = _currentnodes
	data.metplayers = self.metplayers
	data.startstormtask = self.startstormtask and true or nil
	data._alterguardian_defeated_count = _alterguardian_defeated_count
	data.moonstyle_altar = _moonstyle_altar

	return data
end

function self:OnLoad(data)
	if data ~= nil then
		if data._alterguardian_defeated_count then
			_alterguardian_defeated_count = data._alterguardian_defeated_count
			if _alterguardian_defeated_count > 0 then
				self.inst:DoTaskInTime(0,function()
					TheWorld:PushEvent("ms_setmoonphasestyle", {style = "glassed_default"})
				end)
			end
		end

		-- THIS MUST COME AFTER THE _alterguardian_defeated_count IS SET
		if data.moonstyle_altar then
			_moonstyle_altar = data.moonstyle_altar
			self.inst:DoTaskInTime(0,setmoonphasestyle)
		end

		if data.metplayers then
			self.metplayers = data.metplayers
		end
		if data.stormdays then
			self.stormdays = data.stormdays
		end

		if data.startstormtask or data.currentbasenodeindex ~= nil then
			if inst.moonstormwindowovertask then
				inst.moonstormwindowovertask:Cancel()
				inst.moonstormwindowovertask = nil
			end
			if data.currentbasenodeindex ~= nil then
				self.currentbasenodeindextemp = data.currentbasenodeindex
				self.inst:DoTaskInTime(1,function()
						self:StartMoonstorm(data.currentbasenodeindex, data.currentnodes)
						self.currentbasenodeindextemp = nil
					end)
			else
				self.startstormtask = self.inst:DoTaskInTime(1,function() self:StartMoonstorm() end)
			end
		end
	end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()

	if true then
		return nil
	end

end

end)

