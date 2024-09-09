require("stategraphs/commonstates")


local DESTROYSTUFF_IGNORE_TAGS = { "INLIMBO", "mushroomsprout", "NET_workable" }
local BOUNCESTUFF_MUST_TAGS = { "_inventoryitem" }
local BOUNCESTUFF_CANT_TAGS = { "locomotor", "INLIMBO" }

local function DestroyStuff(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3, nil, DESTROYSTUFF_IGNORE_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() and
            v.components.workable ~= nil and
            v.components.workable:CanBeWorked() and
            v.components.workable.action ~= ACTIONS.NET then
            SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
            v.components.workable:Destroy(inst)
        end
    end
end

local function ClearRecentlyBounced(inst, other)
    inst.sg.mem.recentlybounced[other] = nil
end

local function SmallLaunch(inst, launcher, basespeed)
    local hp = inst:GetPosition()
    local pt = launcher:GetPosition()
    local vel = (hp - pt):GetNormalized()
    local speed = basespeed * 2 + math.random() * 2
    local angle = math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
    inst.Physics:Teleport(hp.x, .1, hp.z)
    inst.Physics:SetVel(math.cos(angle) * speed, 1.5 * speed + math.random(), math.sin(angle) * speed)

    launcher.sg.mem.recentlybounced[inst] = true
    launcher:DoTaskInTime(.6, ClearRecentlyBounced, inst)
end

local function BounceStuff(inst)
    if inst.sg.mem.recentlybounced == nil then
        inst.sg.mem.recentlybounced = {}
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 6, BOUNCESTUFF_MUST_TAGS, BOUNCESTUFF_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() and not (v.components.inventoryitem.nobounce or inst.sg.mem.recentlybounced[v]) and v.Physics ~= nil and v.Physics:IsActive() then
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            local intensity = math.clamp((36 - distsq) / 27, 0, 1)
            SmallLaunch(v, inst, intensity)
        end
    end
end

local function hit_recovery_delay(inst, delay, max_hitreacts, skip_cooldown_fn)
    local on_cooldown = false
    if (inst._last_hitreact_time ~= nil and inst._last_hitreact_time + (delay or inst.hit_recovery or TUNING.DEFAULT_HIT_RECOVERY) >= GetTime()) then   -- is hit react is on cooldown?
        max_hitreacts = max_hitreacts or inst._max_hitreacts
        if max_hitreacts then
            if inst._hitreact_count == nil then
                inst._hitreact_count = 2
                return false
            elseif inst._hitreact_count < max_hitreacts then
                inst._hitreact_count = inst._hitreact_count + 1
                return false
            end
        end

        skip_cooldown_fn = skip_cooldown_fn or inst._hitreact_skip_cooldown_fn
        if skip_cooldown_fn ~= nil then
            on_cooldown = not skip_cooldown_fn(inst, inst._last_hitreact_time, delay)
        elseif inst.components.combat ~= nil then
            on_cooldown = not (inst.components.combat:InCooldown() and inst.sg:HasStateTag("idle"))     -- skip the hit react cooldown if the creature is ready to attack
        else
            on_cooldown = true
        end
    end

    if inst._hitreact_count ~= nil and not on_cooldown then
        inst._hitreact_count = 1
    end
    return on_cooldown
end


local events =
{
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnDeath(),


    EventHandler("collision_stun", function(inst,data)
        
        if data.light_stun == true then
            inst.sg:GoToState("hit")
        elseif data.land_stun == true then
            inst.sg:GoToState("stun",{land_stun=true})
        else
            inst.sg:GoToState("stun")
        end
    end),

    EventHandler("land_stun", function(inst,data)
        inst.sg:GoToState("land_stun")
    end),

    EventHandler("attacked", function(inst,data)    
        if inst.components.health ~= nil and not inst.components.health:IsDead()
            and not hit_recovery_delay(inst)
            and (not inst.sg:HasStateTag("busy")
            or inst.sg:HasStateTag("caninterrupt")
            or inst.sg:HasStateTag("frozen")) then    
                inst.sg:GoToState("hit")
        elseif inst.sg:HasStateTag("stunned") then
            inst:PushEvent("stunned_hit")
        end
    end),
    
    EventHandler("doattack", function(inst)

        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState(inst.sg:HasStateTag("running") and "runningattack" or "attack")
        end
    end),

    EventHandler("dostomp", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("stomp", data.time)
        end
    end), 

    EventHandler("doleapattack", function(inst,data)
        if inst.components.health and not inst.components.health:IsDead()  then -- and not inst.sg:HasStateTag("busy")
            inst.sg:GoToState("leap_attack_pre", data.target)
        end
    end), 

}

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

            --inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/voice")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "run_start",
        tags = { "moving", "running", "busy", "atk_pre", "canrotate" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/scuff")
            inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/voice")
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PlayAnimation("paw_loop", true)
            inst.sg:SetTimeout(1.5)
            inst.chargecount = 0
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/scuff") end),
            TimeEvent(30 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/scuff") end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
            inst:PushEvent("attackstart")
        end,
    },

    State{
        name = "run",
        tags = { "moving", "running" },

        onenter = function(inst)
            inst.components.timer:StartTimer("rammed", 3)
            inst.components.locomotor:RunForward()
            if not inst.AnimState:IsCurrentAnimation("atk") then
                inst.AnimState:PlayAnimation("atk", true)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/step")
        end,

        onupdate = function(inst, dt)
            inst.chargecount = inst.chargecount + dt
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/step") end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "canrotate", "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("gore")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

   State{
        name = "taunt",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/taunt")
        end,

        timeline =
        {
            --TimeEvent(10 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/taunt") end),
            TimeEvent(27 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/taunt") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "runningattack",
        tags = { "runningattack" },

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("gore")
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.components.combat:DoAttack()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "attack",
        tags = { "attack", "busy" },

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("bite")
        end,

        timeline =

        { 
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/scuff") end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/bite") end),
            TimeEvent(16 * FRAMES, function(inst) inst.components.combat:DoAttack()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        timeline =
        {
            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/hurt") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "death",
        tags = { "death", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("death")
            inst.persists = false
            inst.components.lootdropper:DropLoot()

            local chest = SpawnPrefab("minotaurchestspawner")
            chest.Transform:SetPosition(inst.Transform:GetWorldPosition())
            for i = 1, 8 do
                if chest:PutBackOnGround(TILE_SCALE * i) then
                    break
                end
            end
            chest.minotaur = inst

            inst:AddTag("NOCLICK")
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/death")
                --inst.SoundEmitter:PlaySound("")
            end),
            TimeEvent(2, ErodeAway),
        },

        onexit = function(inst)
            --Should NOT happen!
            inst:RemoveTag("NOCLICK")
        end,
    },

    State{
        name = "stomp",
        tags = { "busy" },

        onenter = function(inst, time)
            inst.components.timer:StartTimer("stomptimer", 30 + (math.random()*10))
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("jump_atk_pre")
            inst.AnimState:PushAnimation("jump_atk_loop",false)
            inst.AnimState:PushAnimation("jump_atk_pst",false)
        end,

        timeline =
        {
			FrameEvent(52, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/groundpound") end),
			FrameEvent(58, function(inst)
                inst.components.groundpounder:GroundPound()
                BounceStuff(inst)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "bite",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("bite")
           .target = target
        end,

        timeline=

        { 
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/step") end),
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/step") end),
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/bite") end),


            TimeEvent(16*FRAMES, function(inst) 
                inst.components.combat:DoAttack(inst.sg.statemem.target) 
                inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/bite")
            end),  
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "leap_attack_pre",
        tags = {"attack", "busy","leapattack"},
        
        onenter = function(inst)
            inst.hasrammed = true
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jump_atk_pre")
            inst.sg.statemem.startpos = Vector3(inst.Transform:GetWorldPosition())
            inst:DoTaskInTime(1,function()
                if inst:IsValid() and not inst.components.health:IsDead() and inst.sg and inst.sg:HasStateTag("leapattack") then
                    local target = inst.components.combat.target or nil
                    if target then
                        inst.sg.statemem.targetpos = Vector3(inst.components.combat.target.Transform:GetWorldPosition())
                        inst:ForceFacePoint(inst.sg.statemem.targetpos)
                    else
                        local range = 6 -- overshoot range
                        local theta = inst.Transform:GetRotation()*DEGREES
                        local offset = Vector3(range * math.cos( theta ), 0, -range * math.sin( theta ))            
                        inst.sg.statemem.targetpos = Vector3(inst.sg.statemem.startpos.x + offset.x, 0, inst.sg.statemem.startpos.z + offset.z)
                    end
                end
            end)
            inst.sg:SetTimeout(1.5)
        end,

        onexit = function(inst)
            
        end,

        ontimeout = function(inst, target)
            inst.sg:GoToState("leap_attack",{targetpos = inst.sg.statemem.targetpos}) 
        end,
    },

    State{
        name = "leap_attack",
        tags = {"attack", "busy", "leapattack"},
        
        onenter = function(inst,data)
			if inst.components.timer:TimerExists("leapattack_cooldown") then
				inst.components.timer:SetTimeLeft("leapattack_cooldown", TUNING.MINOTAUR_LEAP_CD)
			else
				inst.components.timer:StartTimer("leapattack_cooldown", TUNING.MINOTAUR_LEAP_CD)
			end

            inst.sg.statemem.targetpos = data.targetpos
            
            inst.AnimState:PlayAnimation("jump_atk_loop")
            inst.components.locomotor:Stop()

            inst.sg.statemem.startpos = Vector3(inst.Transform:GetWorldPosition())

            inst.components.combat:StartAttack()

            inst:ForceFacePoint(inst.sg.statemem.targetpos)
            
            local range = 2
            local theta = inst.Transform:GetRotation()*DEGREES
            local offset = Vector3(range * math.cos( theta ), 0, -range * math.sin( theta ))
            local newloc = Vector3(inst.sg.statemem.targetpos.x + offset.x, 0, inst.sg.statemem.targetpos.z + offset.z)

            local time = inst.AnimState:GetCurrentAnimationLength()
            local dist = math.sqrt(distsq(inst.sg.statemem.startpos.x, inst.sg.statemem.startpos.z, newloc.x, newloc.z))
            local vel = dist/time

            inst.sg.statemem.vel = vel

            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.Physics:SetMotorVelOverride(vel,0,0)

            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.WORLD)
        end,

		timeline =
		{
			FrameEvent(8, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/groundpound") end),
			FrameEvent(14, function(inst)
				inst.components.groundpounder:GroundPound()
				BounceStuff(inst)
			end),
		},

        onexit = function(inst)
            inst.Physics:ClearMotorVelOverride()

            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.sg.statemem.startpos = nil
            inst.sg.statemem.targetpos = nil

			inst:OnChangeToObstacle()
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
				if inst:jumpland() then
                    inst.sg:GoToState("leap_attack_pst")
                else
                    inst.sg:GoToState("stun",{land_stun=true})
                end
            end),
        },
    },

    State{

        name = "leap_attack_pst",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("jump_atk_pst")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("taunt") end),
        },
    },

    State{
        name = "stun",
        tags = {"busy","stunned"},
        
        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            if data and data.land_stun then
                inst.AnimState:PlayAnimation("stun_jump_pre")
            else
                inst.sg.statemem.playlandsound = true
                inst.AnimState:PlayAnimation("stun_pre")
            end
            local stuntime = math.max(1.5,Remap(inst.chargecount,0, 1, 0, 6 ) )
            inst.components.timer:StartTimer("endstun", stuntime)
            inst:StopBrain()
        end,

        timeline=
        { 
            TimeEvent(11*FRAMES, function(inst) 
                if inst.sg.statemem.playlandsound then
                    inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/step")
                end
             end), 
        },

        events=
        {
            EventHandler("stunned_hit", function(inst) inst.sg:GoToState("stun_hit") end),
            EventHandler("animover", function(inst) inst.sg:GoToState("stun_loop") end),
        },    
    },

    State{
        name = "stun_loop",
        tags = {"busy","stunned"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("stun_loop")
        end,
        
        timeline=
        { 
            TimeEvent(8*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/recover")
             end), 
        },

        events=
        {
            EventHandler("stunned_hit", function(inst) inst.sg:GoToState("stun_hit") end),
            EventHandler("animover", function(inst) inst.sg:GoToState("stun_loop") end),
        },
    },

    State{
        name = "stun_hit",
        tags = {"busy","stunned"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("stun_hit")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("stun_loop") end),
        },
    },

    State{
        name = "stun_pst",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("stun_pst")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/scuff") end),
            TimeEvent(27 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/scuff") end),
            TimeEvent(30 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/step") end),
            TimeEvent(38 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/scuff") end),
        },
    },
}

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            inst.Physics:Stop()
        end),
    },
    walktimeline =
    {
        TimeEvent(0, function(inst)
            inst.Physics:Stop()
        end),
        TimeEvent(7 * FRAMES, function(inst)
            inst.components.locomotor:WalkForward()
        end),
        TimeEvent(18 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/walk")
        end),
        TimeEvent(20 * FRAMES, function(inst)
            ShakeAllCameras(CAMERA.VERTICAL, .5, .05, .1, inst, 40)
            inst.Physics:Stop()
        end),
    },
}, nil, true)

CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        TimeEvent(11 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/rook_minotaur/liedown") end),
    },
    sleeptimeline =
    {
        TimeEvent(18 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ancientguardian_rework/minotaur2/sleep") end),
    },
})

CommonStates.AddFrozenStates(states)

return StateGraph("minotaur", states, events, "idle")
