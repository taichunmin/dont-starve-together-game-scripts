require "behaviours/follow"
require "behaviours/wander"
require "behaviours/standstill"
require "behaviours/faceentity"

local ATTACH_DIST = 1
local CLOSE_DIST = 8

local SCREEN_DIST_SQ = PLAYER_CAMERA_SEE_DISTANCE_SQ

local function MoveToPointAction(inst)
	local pos = nil

	if inst.plant_target ~= nil and (TheWorld.components.lunarthrall_plantspawner == nil or not inst.plant_target:IsValid()) then
		inst.plant_target = nil
	end

	if inst.plant_target and inst.plant_target.lunarthrall_plant then
		local plant = TheWorld.components.lunarthrall_plantspawner:FindPlant()
		if plant then
			local dist = plant:GetDistanceSqToInst(inst)
			if dist < SCREEN_DIST_SQ then
				inst.plant_target = plant
			else
				inst.plant_target = nil
			end
		else
			inst.plant_target = nil
		end
	end
	local movetoplant = false
	if inst.plant_target and inst.plant_target:IsValid() then
		movetoplant = true
		-- go to LunarThrall_Plant_Gestalt_Brain		
		local dist = inst.plant_target:GetDistanceSqToInst(inst)
		if dist <= ATTACH_DIST * ATTACH_DIST then
			inst.Transform:SetPosition(inst.plant_target.Transform:GetWorldPosition())
			inst.sg:GoToState("infest")
		elseif dist <= CLOSE_DIST * CLOSE_DIST then

			pos = Vector3(inst.plant_target.Transform:GetWorldPosition())

		elseif dist > SCREEN_DIST_SQ and inst.components.timer:TimerExists("justspawned") then

			movetoplant = false
		else

			local x,y,z = inst.plant_target.Transform:GetWorldPosition()
			local anglediff = math.random() * (PI*.45)
			if math.random() < 0.5 then
				anglediff = -anglediff
			end
			local angle = inst:GetAngleToPoint(x, y, z)*DEGREES
			local theta = angle + anglediff
			local radius = math.min((math.random()*8) + 4, math.sqrt(dist)*.75)
			local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

			pos = Vector3(inst.Transform:GetWorldPosition()) + offset
		end
	end

	if not movetoplant then
        local x, y, z = inst.Transform:GetWorldPosition()
        local inview = IsAnyPlayerInRangeSq(x, y, z, SCREEN_DIST_SQ)

		if not inview then
			if TheWorld.components.lunarthrall_plantspawner then
				TheWorld.components.lunarthrall_plantspawner:MoveGestaltToPlant(inst)
			else
				inst:Remove()
			end
		else

			if not inst.randomdirection then
				inst.randomdirection = math.random()*TWOPI
			end

			local anglediff = math.random() * (PI*.45)

			if math.random() < 0.5 then
				anglediff = -anglediff
			end

			local angle = inst.randomdirection
			local theta = angle + anglediff
			local radius = (math.random()*8) + 4
			local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
			
			pos = Vector3(x, y, z) + offset

		end
		-- go out of sight and then find a plan to teleport to
	end
	if pos and inst:IsValid() then
		return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pos, nil, .2)
	end
end

local LunarThrall_Plant_Gestalt_Brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function LunarThrall_Plant_Gestalt_Brain:OnStart()
    local root = PriorityNode(
    {
    	WhileNode(function() return self.inst.sg:HasStateTag("idle")  end, "move",
    		DoAction(self.inst, MoveToPointAction, "Move", true )),
    	--DoAction(self.inst, MoveToPointAction, "Move", true ),
    }, .25)
    self.bt = BT(self.inst, root)
end

return LunarThrall_Plant_Gestalt_Brain