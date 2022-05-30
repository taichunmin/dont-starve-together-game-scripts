local timePerStep = 3
local scanAheadRadius = 15
local moveRadius = 10
local poundChance = 0 -- 0.05
local dropsPerMeterChance = 0.05
local traildrop = "furtuft"
-- pound disabled for now. Seems it would become too messy
local poundTrailDropBase = 3
local poundTrailDropVariance= 3
local poundTrailDropRadiusBase = 3
local poundTrailDropRadiusVariance = 8
local numNodesForInitialRoamingRegion = 8
local numNodesForNewRoamingRegion = 4

BeargerOffScreen = Class(BehaviourNode, function(self, inst)
	BehaviourNode._ctor(self, "BeargerOffScreen")
	self.inst = inst
	self.waittime = 0

--	SetDebugEntity(self.inst)
--	self.draw = self.inst.entity:AddDebugRender()
--	self.draw:SetZ(0.1)
end)

local function distSquared(p1, p2)
	local dx = p1.x - p2.x
	local dy = p1.y - p2.y
	return dx*dx + dy*dy
end

local function distPointToSegmentSquared(p, v1, v2)
	local l2 = distSquared(v1, v2)
	if (l2 == 0) then
		return distSquared(p, v1)
	end
	local t = ((p.x - v1.x) * (v2.x - v1.x) + (p.y - v1.y) * (v2.y - v1.y)) / l2
	if (t < 0) then
		return distSquared(p, v1)
	end
	if (t > 1) then
		return distSquared(p, v2)
	end
	return distSquared(p, { x = v1.x + t * (v2.x - v1.x), y =v1.y + t * (v2.y - v1.y) });
end

local function distPointToSegment(p, v1, v2)
	return math.sqrt(distPointToSegmentSquared(p, v2, v2));
end

local function GetEntitiesAlongLine(x1,y1,x2,y2,r,musthavetags, canthavetags, musthaveoneoftags)
	local cx = (x2 + x1) / 2
	local cy = (y2 + y1) / 2
	local dx = x2 - x1
	local dy = y2 - y1
	local radius = (math.sqrt(dx*dx+dy*dy) / 2) + r
	local ret = {}
	local v = {x=x1, y=y1}
	local w = {x=x2, y=y2}
        local ents = TheSim:FindEntities(cx, 0, cy, 8, musthavetags, canthavetags, musthaveoneoftags)
	for i,ent in ipairs(ents) do
		local x,y,z = ent.Transform:GetWorldPosition()
		local p = {x=x,y=z}
		local dist = distPointToSegment(p,v,w)
		if dist < r then
			ret[#ret+1]=ent
		end
	end
	return ret
end

function ApplyToEntities(ents, func)
	for i,ent in pairs(ents) do
		func(ent)
	end
end

function BeargerOffScreen:WorkEntitiesAlongLine(x1,y1,x2,y2,r)
	local ents = GetEntitiesAlongLine(x1,y1,x2,y2,r,nil,nil,{"running","tree"})
	ApplyToEntities(ents,
			function(ent)
				if ent.components.workable ~= nil and ent.components.workable:CanBeWorked() then
                    if ent.components.lootdropper ~= nil and (ent:HasTag("tree") or ent:HasTag("boulder")) then
                        ent.components.lootdropper:SetLoot({})
                    end
					ent.components.workable:Destroy(self.inst)
				end
			end
		)
end

function BeargerOffScreen:DropTrailItem(x,y,z)
	SpawnPrefab(traildrop).Transform:SetPosition(x, 0, z)
end

function BeargerOffScreen:DropTrail(x1,y1,x2,y2,dropsPerUnitChance)
	local dx = x2 - x1
	local dy = y2 - y1
	local dist = math.sqrt(dx*dx+dy*dy)
	for i=1,dist do
		if math.random() < dropsPerUnitChance then
			local spread = i - 0.5 + math.random()
			local px = x1 + spread * (dx/dist)
			local pz = y1 + spread * (dy/dist)
			self:DropTrailItem(px,0,pz)
		end
	end
end

function BeargerOffScreen:DropGroundPoundTrail()
	local count = poundTrailDropBase + math.random() * poundTrailDropVariance
	local x,y,z = self.inst.Transform:GetWorldPosition()
	for i=1,count do
		local radius = poundTrailDropRadiusBase + math.random() * poundTrailDropRadiusVariance
		local angle = math.random() * 2 * PI
		local offset = Vector3(radius * math.cos(angle), 0, radius * math.sin(angle))
		self:DropTrailItem(x+offset.x, y, z+offset.z)
	end
end

function BeargerOffScreen:SetupRoaming()
	local x,_,y = self.inst.Transform:GetWorldPosition()
	local node = GetClosestNode(x,y)
	local nodes
	if not self.roamedBefore then
		self.roamedBefore = true
		nodes = GrabSubGraphAroundNode(node, numNodesForInitialRoamingRegion)
	else
		nodes = GrabSubGraphAroundNode(node, numNodesForNewRoamingRegion)
	end
	local points = {}
	for i,v in pairs(nodes) do
		table.insert(points, {v.x, v.y})
	end
	local ressorted =  convexHull(points)
	--[[
	MapHideAll()
	for i=1,#ressorted do
		local p1i = i
		local p2i = (i % #ressorted)+1
		local p1 = ressorted[p1i]
		local p2 = ressorted[p2i]
		local srcx = p1[1]
		local srcy = p1[2]
		local dstx = p2[1]
		local dsty = p2[2]
		local dx = dstx - srcx
		local dy = dsty - srcy
		local len = math.sqrt(dx*dx+dy*dy)
		dx = dx / len
		dy = dy / len
		for pt = 1,len/5 do
			local x = srcx + dx * 5 * pt
			local y = srcy + dy * 5 * pt
			TheWorld.minimap.MiniMap:ShowArea(x,0,y,8)
		end

	end
	]]

	self.boundary = ressorted
	self.roamAreaNode = node
	self.roamAreaReached = false
	self:PickNewDirection_Rampage()
end

function BeargerOffScreen:Roam()
	local x,origy,y = self.inst.Transform:GetWorldPosition()
	local newx = self.destpos.x
	local newy = self.destpos.z

	self.inst.Transform:SetPosition(newx,origy,newy)

	self:WorkEntitiesAlongLine(x,y,newx,newy,3)
	self:DropTrail(x,y,newx,newy,dropsPerMeterChance)
--	self.draw:Line(x,y,newx,newy, 255, 0, 0, 255)
--	TheWorld.minimap.MiniMap:ShowArea(x,0,y,3)
--	TheWorld.minimap.MiniMap:ShowArea((x+newx)/2,0,(y+newy)/2,3)
	self:PickNewDirection_Rampage()
end

function BeargerOffScreen:Visit()
	if self.status == READY then
		self.status = RUNNING
		self:SetupRoaming()
        	local t = GetTime()
		if t >= self.waittime or not self.waittime then
			self.waittime = t + timePerStep
		end
		self:Sleep(0.01)
	else
        	local t = GetTime()
		if t >= self.waittime or not self.waittime then
			self:Roam()
			self.waittime = t + timePerStep
		end
		self:Sleep(0.01)
	end
end

function FindWalkableOffsetWithBoundary(position, start_angle, radius, attempts, check_los, ignore_walls, boundarypoints)
    	if ignore_walls == nil then
        	ignore_walls = true
    	end

	local test = function(offset)
		local run_point = position+offset
		if not TheSim:WorldPointInPoly(run_point.x, run_point.z, boundarypoints) then
			--print("\tfailed, would cross boundary.")
			return false
		end

		local ground = TheWorld
		local tile = ground.Map:GetTileAtPoint(run_point.x, run_point.y, run_point.z)
		if tile == GROUND.IMPASSABLE or tile >= GROUND.UNDERGROUND then
			--print("\tfailed, unwalkable ground.")
			return false
		end
		if check_los and not ground.Pathfinder:IsClear(position.x, position.y, position.z,
		                                                 run_point.x, run_point.y, run_point.z,
		                                                 {ignorewalls = ignore_walls, ignorecreep = true}) then
			--print("\tfailed, no clear path.")
			return false
		end
		return true

	end

	return FindValidPositionByFan(start_angle, radius, attempts, test)
end

function BeargerOffScreen:GetRandomWanderDestWithinBoundary(lookAhead, moveRadius, curAngle)
        local attempts = 8
        local angle = self.lastangle or math.random() * 2 * PI
	angle = angle + math.random() - 0.5

        local pt = Point(self.inst.Transform:GetWorldPosition())
        local offset, check_angle, deflected = FindWalkableOffsetWithBoundary(pt, angle, lookAhead, attempts, true, true,self.boundary) -- if we can't avoid walls, at least avoid water
	--self.lastangle = check_angle

	local x,y,z = self.inst.Transform:GetWorldPosition()
	local fraction = moveRadius / lookAhead
	if offset then
		x = x + offset.x * fraction
		y = y + offset.y * fraction
		z = z + offset.z * fraction
	end
	return Point(x,y,z), check_angle
end

function BeargerOffScreen:PickNewDirection_Rampage()
	if not self.roamAreaReached then
		-- we're not inside our roaming area yet - let's try to go there by trying to walk to the center
		local x,y,z = self.inst.Transform:GetWorldPosition()
		local dstx = self.roamAreaNode.x
		local dsty = y
		local dstz = self.roamAreaNode.y
		-- if we're not inside the boundary, head to the closest point inside the boundary first
		-- (alternatively, see if we can reach any of the verts first, if all fails, random walk and find a new roamspot later on?)
		if TheWorld.Pathfinder:IsClear(x, y, z,
						dstx, dsty, dstz,
		                               {ignorewalls = true, ignorecreep = true}) then
			-- yay, we can go there
			local dx = dstx - x
			local dz = dstz - z
			local len = math.sqrt(dx*dx+dz*dz)
			dx = dx / len
			dz = dz / len
			x = x + dx * moveRadius
			z = z + dz * moveRadius
		end
		self.destpos = Point(x,y,z)
		if TheSim:WorldPointInPoly(x, z, self.boundary) then
			self.roamAreaReached = true
		end
	else
		self.destpos, self.lastangle = self:GetRandomWanderDestWithinBoundary(scanAheadRadius, moveRadius, self.lastAngle)
	end
end

-- walking along gridlines
function BeargerOffScreen:PickNewDirection()
	if not self.finaldest then
		-- First time here
		-- find the closest node we can reach
		local x,y,z = self.inst.Transform:GetWorldPosition()
		local node = GetClosestNode(x,z)
		self.finaldest = {node = node, x=node.x, y=node.y}
	else
		-- reached our destination
		-- pick a node that's connected to this node
		-- TODO: don't pick the edge that we had before
		local node = self.finaldest.node
		local allEdges = node.validedges
		local choices = {}
		for i,v in pairs(node.neighbours) do
			local node = TheWorld.topology.nodes[v]
			choices[node] = true
		end

		local allChoices = {}

		for i,v in pairs(choices) do
			table.insert(allChoices,i)
		end

		local nodeToPick = math.random(1,#allChoices)
		local destnode = allChoices[nodeToPick]
		-- prefer not to take the route we came from, unless it's the only option
		if destnode == self.lastvisitednode then
			nodeToPick = nodeToPick + 1
			nodeToPick = ((nodeToPick-1) % #allChoices) + 1
			destnode = allChoices[nodeToPick]
		end
		self.lastvisitednode = node
		self.finaldest = {node = destnode, x=destnode.x, y=destnode.y}
	end
end

