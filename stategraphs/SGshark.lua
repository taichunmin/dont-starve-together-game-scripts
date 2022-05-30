require("stategraphs/commonstates")

local function groundsound(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    if inst:GetCurrentPlatform() then
        inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/boat_land")
    elseif TheWorld.Map:IsVisualGroundAtPoint(x,y,z) then
        PlayFootstep(inst)
    end
end

local actionhandlers =
{

}

local events =
{
    EventHandler("leap", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("leap") end end),
    EventHandler("dobite", function(inst) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) and not inst.sg:HasStateTag("attack") and not inst.sg:HasStateTag("jumping") then inst.sg:GoToState("bite") end end),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") and not inst.sg:HasStateTag("jumping") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death", inst.sg.statemem.dead) end),
    EventHandler("doattack", function(inst, data) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack", data.target) end end),
    EventHandler("dive_eat", function(inst)
        if inst.foodtoeat then
            local x,y,z = inst.foodtoeat.Transform:GetWorldPosition()
            if inst.foodtoeat:IsValid() and not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) and not inst.foodtoeat:GetCurrentPlatform() then
                inst.sg:GoToState("eat_pre")
            end
        end
    end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnHop(),
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnFreeze(),
}

local function startleap(inst)

end

local function endleap(inst)

end

local function  DoAttack(inst)
    local targetavailable = false
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.SHARK.AOE_RANGE, nil,{"FX", "NOCLICK", "DECOR", "INLIMBO", "notarget",""} )
    for i, ent in pairs(ents)do
        if inst.components.combat:CanAttack(ent) then
            targetavailable = true
            break
        end
    end
    if targetavailable then
       inst.notargets = nil
    else
        inst.notargets = true
    end
    inst.components.combat:DoAttack()
    if inst:GetCurrentPlatform() then
        ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, 0.2, 0.05, 0.10, inst:GetCurrentPlatform())
    end
end


local function findwater(inst)
    local foundwater = false
    local position = Vector3(inst.Transform:GetWorldPosition())

    local start_angle = inst.Transform:GetRotation() * DEGREES

    local foundwater = false
    local radius = 4

    local test_fn = function(offset)
        local x = position.x + offset.x
        local z = position.z + offset.z
        return not TheWorld.Map:IsVisualGroundAtPoint(x,0,z)
    end

    local offset = nil

    while foundwater == false do
        offset = FindValidPositionByFan(start_angle, radius, 16, test_fn)
        if offset and offset.x and offset.z then
            foundwater = true
        else
            radius = radius + 4
        end
    end

    return offset
end

local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,

        timeline =
        {
            TimeEvent(1*FRAMES,  function(inst) groundsound(inst) end),
            TimeEvent(11*FRAMES, function(inst) groundsound(inst) end),
            TimeEvent(23*FRAMES, function(inst) groundsound(inst) end),
            TimeEvent(34*FRAMES, function(inst) groundsound(inst) end),
        },

    },

    State{
        name = "bite",
        tags = { "busy","attack"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()

            inst.AnimState:PlayAnimation("attack", true)
        end,
        timeline =
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bark") end),
            TimeEvent(12*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bite")
                DoAttack(inst)
            end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bark") end),
            TimeEvent(18*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bite")
                DoAttack(inst)
            end),
            TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bark") end),
            TimeEvent(26*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bite")
                DoAttack(inst)
            end),
        },


        events =
        {
            EventHandler("animover", function(inst)
                if math.random() < 0.3 then
                    inst.sg:GoToState("bite")
                else
                    inst.sg:GoToState("rest")
                end
            end),
        },
    },

    State{
        name = "rest",
        tags = { "busy", "attack" },
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
            inst.sg:SetTimeout(0.2*math.random()+1)
        end,

        timeline =
        {
            TimeEvent(1*FRAMES,  function(inst) groundsound(inst) end),
            TimeEvent(11*FRAMES, function(inst) groundsound(inst) end),
            TimeEvent(23*FRAMES, function(inst) groundsound(inst) end),
            TimeEvent(34*FRAMES, function(inst) groundsound(inst) end),
        },

        ontimeout = function(inst)
            inst.readytoswim = true
            inst:PushEvent("leap")
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("attack", false)
        end,

        timeline =
        {
            TimeEvent(12*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bite")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
        },

        onexit = function(inst)
            inst.components.timer:StartTimer("getdistance", 3)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "gobble",
        tags = { "busy" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dive",false) -- 14 frames
            inst.AnimState:PushAnimation("eat",false)
            inst.components.timer:StartTimer("gobble_cooldown", 2 + math.random()*15)
        end,

        timeline =
        {
            TimeEvent(17*FRAMES, function(inst)
                local action = inst:GetBufferedAction()
                if action and action.target and action.target:IsValid() then
                    action.target:Remove()
                end
                inst:ClearBufferedAction()
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bark")
            end),
            TimeEvent(21*FRAMES, function(inst)
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bite")
            end)
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("leap_pst") end),
        },
    },

    State{
        name = "hit",
        tags = { "busy", "hit" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/hit")
        end,

        events =
        {
        EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "leap",
        tags = { "busy","jumping" },

        onenter = function(inst)
            if not inst.readytoswim then
                if inst.components.combat.target then
                    local x,y,z =  inst.components.combat.target.Transform:GetWorldPosition()
                    inst:ForceFacePoint(x, y, z)
                end
            else
                -- find water, jump to that.
                local offset = findwater(inst)
                local position = Vector3(inst.Transform:GetWorldPosition())
                inst:ForceFacePoint(position.x + offset.x, 0, position.z + offset.z)
                inst.components.timer:StartTimer("getdistance", 3)
            end
            inst.readytoswim = nil
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)


            inst.AnimState:PlayAnimation("jump")
            inst.AnimState:PushAnimation("jump_loop",true)

            inst.sg.statemem.collisionmask = inst.Physics:GetCollisionMask()
            inst.Physics:SetCollisionMask(COLLISION.GROUND)

            if inst:HasTag("swimming") then
                inst.Physics:SetMotorVelOverride(15,0,0)
            end
            inst.components.timer:StartTimer("minleaptime", 0.5)
            inst.sg:SetTimeout(0.65)
            startleap()
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
                    else
                    inst.Physics:SetMotorVelOverride(15,0,0)
                end
            end),
        },

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()

            if inst.sg.statemem.collisionmask ~= nil then
                inst.Physics:SetCollisionMask(inst.sg.statemem.collisionmask)
            end
        end,

        onupdate = function(inst)
            local target = inst.components.combat.target
            if target and not inst.components.timer:TimerExists("getdistance") then
                local x,y,z = inst.Transform:GetWorldPosition()
                if target:GetDistanceSqToInst(inst) < TUNING.SHARK.ATTACK_RANGE * TUNING.SHARK.ATTACK_RANGE and (TheWorld.Map:IsVisualGroundAtPoint(x,y,z) or inst:GetCurrentPlatform() ) then
                    inst.sg.dropnow = true
                end
                if not inst.components.timer:TimerExists("minleaptime") and inst.sg.dropnow == true then
                    inst.sg:GoToState("leap_pst")
                end
            end
        end,

        ontimeout = function(inst)
           inst.sg:GoToState("leap_pst")
        end,
    },

    State{
        name = "leap_pst",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("jump_pst")
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    SpawnPrefab("splash_green_large").Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
            end),
            TimeEvent(9*FRAMES, function(inst)
                if not inst:HasTag("swimming") then
                    if inst:GetCurrentPlatform() then
                        ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, 0.3, 0.03, 0.15, inst:GetCurrentPlatform())
                    end
                    groundsound(inst)
                end
            end),
        },

        onexit = function(inst)
            if inst:HasTag("swimming") then
                if inst.notargets then
                    if not inst.missedtargets then
                        inst.missedtargets = 0
                    end
                    inst.missedtargets = inst.missedtargets + 1
                end

                if inst.missedtargets and inst.missedtargets > 2 then
                    inst.missedtargets = nil
                    inst.components.combat:DropTarget()
                    inst.components.timer:StartTimer("calmtime", 2)
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("dead",false)
            inst.AnimState:PushAnimation("dead_loop",false)
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/death") end),
        },

        onexit = function(inst)
            if not inst:IsInLimbo() then
                inst.AnimState:Resume()
            end
        end,
    },

    State{
        name = "eat_pre",
        tags = { "busy","jumping" },

        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("dive")
        end,

        onexit = function(inst)
            inst.Physics:SetActive(true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.Physics:SetActive(false)
                inst.sg:SetTimeout(2)
            end),
        },
        ontimeout = function(inst)
            local targetpt = Vector3(inst.Transform:GetWorldPosition())
            if inst.foodtoeat and inst.foodtoeat:IsValid() then
                targetpt = Vector3(inst.foodtoeat.Transform:GetWorldPosition())
            end
            inst.Transform:SetPosition(targetpt.x,0,targetpt.z)
            inst.sg:GoToState("eat_pst")
        end,
    },

    State{
        name = "eat_pst",
        tags = { "busy","jumping" },

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
           -- SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                if inst.foodtoeat then
                    inst.foodtoeat:Remove()
                end
                inst.foodtoeat = nil
            end),
            TimeEvent(7*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bite")
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),

            TimeEvent(30*FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    SpawnPrefab("splash_green_large").Transform:SetPosition(inst.Transform:GetWorldPosition())
                else
                    groundsound(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

CommonStates.AddAmphibiousCreatureHopStates(states,
{ -- config
	swimming_clear_collision_frame = 9 * FRAMES,
},
{ -- anims
},
{ -- timeline
	hop_pre =
	{
		TimeEvent(0, function(inst)
			if inst:HasTag("swimming") then
				SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
			end
		end),
	},
	hop_pst = {
		TimeEvent(4 * FRAMES, function(inst)
			if inst:HasTag("swimming") then
				inst.components.locomotor:Stop()
				SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
			end
            groundsound(inst)
		end),
		TimeEvent(6 * FRAMES, function(inst)
			if not inst:HasTag("swimming") then
                inst.components.locomotor:StopMoving()
			end
		end),
	}
})

CommonStates.AddSleepStates(states,
{
    sleeptimeline =
    {
        -- TimeEvent(30 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end),
    },
})

CommonStates.AddRunStates(states,
{
    runtimeline =
    {
        TimeEvent(0, function(inst)
            -- inst.SoundEmitter:PlaySound(inst.sounds.growl)
            if inst:HasTag("swimming") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
            else
                PlayFootstep(inst)
            end

            if inst:HasTag("swimming") then
                inst.waketask = inst:DoPeriodicTask(0.25, function()
                    local wake = SpawnPrefab("wake_small")
                    local rotation = inst.Transform:GetRotation()

                    local theta = rotation * DEGREES
                    local offset = Vector3(math.cos( theta ), 0, -math.sin( theta ))
                    local pos = Vector3(inst.Transform:GetWorldPosition()) + offset
                    wake.Transform:SetPosition(pos.x,pos.y,pos.z)
                    wake.Transform:SetScale(1.35,1.36,1.35)

                    wake.Transform:SetRotation(rotation - 90)
                end)
            end

        end),
        TimeEvent(4 * FRAMES, function(inst)
            if inst:HasTag("swimming") then
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small",nil,.25)
            else
                PlayFootstep(inst)
            end
        end),
    }
},nil,nil,nil,
{
    runonexit = function(inst)
        if inst.waketask then
            inst.waketask:Cancel()
            inst.waketask = nil
        end
    end,
    runonupdate = function(inst)

        inst:testfooddist()
    end,
})
CommonStates.AddWalkStates(states,
{
    walktimeline =
    {
        --TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/swim") end),
    },
},nil,nil,nil,
{
    startonenter = function(inst)
        inst:AddTag("walking")
    end,
    startonexit = function(inst)
        inst:RemoveTag("walking")
    end,

    walkonenter = function(inst)
        inst:AddTag("walking")
    end,
    walkonexit = function(inst)
        inst:RemoveTag("walking")
    end,

    exitonenter = function(inst)
        inst:AddTag("walking")
    end,
    endonexit = function(inst)
        inst:RemoveTag("walking")
    end,

    walkonupdate = function(inst)
        inst:testfooddist()
    end,
})
CommonStates.AddFrozenStates(states)

return StateGraph("shark", states, events, "idle", actionhandlers)

