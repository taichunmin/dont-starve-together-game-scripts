local waveassets =
{
	Asset( "ANIM", "anim/wave_ripple.zip" ),
}

local rogueassets = 
{
    Asset( "ANIM", "anim/wave_rogue.zip" ),
}

local prefabs_ripple = 
{
	"splash_water",
}

local prefabs_rogue = 
{
	"splash_water",
}

local function DebugDraw(inst)
	if not inst.draw then
		TheSim:SetDebugRenderEnabled(true)
		inst.draw = inst.entity:AddDebugRender()
	end
	if inst.draw then
		inst.draw:Flush()
		inst.draw:SetRenderLoop(true)
		inst.draw:SetZ(0.15)

		local px, py, pz = inst.Transform:GetWorldPosition()
		local cx, cy, cz = TheWorld.components.ocean:GetCurrentVec3()

		inst.draw:Line(px, pz, 50 * cx + px, 50 * cz + pz, 255, 0, 0, 255)
	end
end

local function wetanddamage(inst, other)
    --get wet and take damage 
    if other and other.components.moisture then
        local hitmoisturerate = 1.0
        if other.components.driver and other.components.driver.vehicle and other.components.driver.vehicle.components.drivable then
            hitmoisturerate = other.components.driver.vehicle.components.drivable:GetHitMoistureRate()
        end
        local waterproofMultiplier = 1 
        if other.components.inventory then 
            waterproofMultiplier = 1 - other.components.inventory:GetWaterproofness()
        end 
        other.components.moisture:DoDelta(inst.hitmoisture * hitmoisturerate * waterproofMultiplier)
    end 
    if other and other.components.driver and other.components.driver.vehicle then 
        local vehicle = other.components.driver.vehicle
        if vehicle.components.boathealth then
            vehicle.components.boathealth:DoDelta(inst.hitdamage, "wave")
        end
    end 
end

local function splash(inst)

    local splash = SpawnPrefab("splash_water")
    local pos = inst:GetPosition()
    splash.Transform:SetPosition(pos.x, pos.y, pos.z)

    inst:Remove()

end 

local function oncollidewave(inst, other)

    local boostThreshold = TUNING.WAVE_BOOST_ANGLE_THRESHOLD
    if other == GetPlayer() then-- and inst.sg:HasStateTag("idle") then
        local moving = GetPlayer().sg:HasStateTag("moving") 
        local playerAngle =  other.Transform:GetRotation()
        if playerAngle < 0 then playerAngle = playerAngle + 360 end 

        local waveAngle = inst.Transform:GetRotation()
        if waveAngle < 0 then waveAngle = waveAngle + 360 end 

        local angleDiff = math.abs(waveAngle - playerAngle)
        inst.SoundEmitter:PlaySound( "dontstarve_DLC002/common/wave_break")
        if angleDiff > 180 then angleDiff = 360 - angleDiff end

		local surfer = false
		if other.components.locomotor then
			surfer = other.components.locomotor:HasSpeedModifier("SURF")
		end

        if (angleDiff < boostThreshold or surfer) and moving then
            --Do boost
            local rogueboost
            local player = GetPlayer()
            if other == player then
                if player.components.driver.vehicle and player.components.driver.vehicle.prefab == "surfboard" then
                    rogueboost = TUNING.SURFBOARD_ROGUEBOOST
                end
            end
            other:PushEvent("boostbywave", {position = inst.Transform:GetWorldPosition(), velocity = inst.Physics:GetVelocity(), boost = rogueboost})
            inst.SoundEmitter:PlaySound( "dontstarve_DLC002/common/wave_boost")
        elseif not surfer then
            wetanddamage(inst, other)
        end 

        splash(inst)
    elseif other and other.components.waveobstacle then
        other.components.waveobstacle:OnCollide(inst)
        wetanddamage(inst, other)
        splash(inst)
    end
end 


local function oncolliderogue(inst, other)
    -- check for surfboard, which actually just boosts
    local player = GetPlayer()
    if other == player then
		local surfer = false
		if other.components.locomotor then
			surfer = other.components.locomotor:HasSpeedModifier("SURF")
		end

        if surfer or (player.components.driver.vehicle and player.components.driver.vehicle.prefab == "surfboard") then
            oncollidewave(inst, other)
            return
        else
            wetanddamage(inst, other)
            splash(inst)
            return 
        end
    end

    if other and other.components.waveobstacle then
        other.components.waveobstacle:OnCollide(inst)
        wetanddamage(inst, other)
        splash(inst)
    end
   
end 

local function CheckGround(inst, dt)
    --Check if I'm about to hit land 
    local x, y, z = inst.Transform:GetWorldPosition()
    local vx, vy, vz = inst.Physics:GetVelocity()
    

    local checkx = x + vx 
    local checky = y
    local checkz = z + vz 

    local ground = TheWorld
    local tile = GROUND.GRASS
    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(checkx, checky, checkz)
    end

    if not IsOceanTile(tile) then 
        splash(inst)
    end
end 

local function onsave(inst, data)
    if inst and data then
        data.speed = inst.Physics:GetMotorSpeed()
        data.angle = inst.Transform:GetRotation()
        if inst.sg and inst.sg.currentstate and inst.sg.currentstate.name then
            data.state = inst.sg.currentstate.name
        end
    end
end

local function onload(inst, data)
    if inst and data then
        inst.Transform:SetRotation(data.angle or 0)
        inst.Physics:SetMotorVel(data.speed or 0, 0, 0)
        if inst.sg and data.state then
            inst.sg:GoToState(data.state)
        end
    end
end

local function activate_collision(inst)
    inst.Physics:SetCollides(false) --Still will get collision callback, just not dynamic collisions.
    inst.Physics:SetCollisionGroup(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
end

local function onRemove(inst)
    if inst and inst.soundloop then
        inst.SoundEmitter:KillSound(inst.soundloop)
    end
end

local function onSleep(inst)
    inst:Remove()
end

local function common(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    trans:SetFourFaced()

    inst.entity:AddPhysics()
    inst.Physics:SetSphere(1)
    inst.Physics:ClearCollisionMask()

    inst:AddTag( "FX" )

    inst.checkgroundtask = inst:DoPeriodicTask(0.5, CheckGround)

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnEntitySleep = onSleep    
    inst.done = false

    return inst
end


local function ripple(Sim)
    local inst = common(Sim)
    inst.Physics:SetCollisionCallback(oncollidewave)

	inst.persists = false
    
    local anim = inst.entity:AddAnimState()
    anim:SetBuild( "wave_ripple" )
    anim:SetBank( "wave_ripple" )
    
    inst.hitdamage = -TUNING.WAVE_HIT_DAMAGE
    inst.hitmoisture = TUNING.WAVE_HIT_MOISTURE

    inst:SetStateGraph("SGwave")
    inst.soundrise = "small"
    inst.activate_collision = activate_collision
    
    return inst
end 

local function rogue(Sim)
    local inst = common(Sim)
    inst.Physics:SetCollisionCallback(oncolliderogue)
    
    local anim = inst.entity:AddAnimState()
    anim:SetBuild("wave_rogue" )
    anim:SetBank( "wave_rogue" )
    
    inst.hitdamage = -TUNING.ROGUEWAVE_HIT_DAMAGE
    inst.hitmoisture = TUNING.ROGUEWAVE_HIT_MOISTURE

    inst:SetStateGraph("SGwave")

    inst.idle_time = 1
    
    inst.soundrise = "large"
    inst.soundloop = "large_LP"
    inst.soundtidal = "tidal_wave"

    inst.activate_collision = activate_collision
    inst:ListenForEvent("onremove", onRemove)

    return inst
end

return Prefab( "wave_ripple", ripple, waveassets, prefabs_ripple ), 
       Prefab( "rogue_wave", rogue, rogueassets, prefabs_rogue )
