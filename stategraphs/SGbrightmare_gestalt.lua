require("stategraphs/commonstates")

local actionhandlers =
{
}

local events =
{
    CommonHandlers.OnDeath(),
    CommonHandlers.OnLocomote(false, true),

    EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("attack")
        end
    end),
}

local function FindBestAttackTarget(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
    local closestPlayer = nil
	local rangesq = TUNING.GESTALT.ATTACK_HIT_RANGE_SQ
    for i, v in ipairs(AllPlayers) do
        if (not(v.replica.health:IsDead() or v:HasTag("playerghost"))) and
			not (v.sg:HasStateTag("knockout") or v.sg:HasStateTag("sleeping") or v.sg:HasStateTag("bedroll") or v.sg:HasStateTag("tent") or v.sg:HasStateTag("waking")) and
            v.entity:IsVisible() then
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            if distsq < rangesq then
                rangesq = distsq
                closestPlayer = v
            end
        end
    end
    return closestPlayer
end

local function DoSpecialAttack(inst, target)
	if target.components.sanity ~= nil then 
		target.components.sanity:DoDelta(TUNING.GESTALT.ATTACK_DAMAGE_SANITY)
	end
	local grogginess = target.components.grogginess
	if grogginess ~= nil then 
		grogginess:AddGrogginess(TUNING.GESTALT.ATTACK_DAMAGE_GROGGINESS, TUNING.GESTALT.ATTACK_DAMAGE_KO_TIME)
		if grogginess.knockoutduration == 0 then
			target:PushEvent("attacked", {attacker = inst, damage = 0})
		else
			-- TODO: turn on special hud overlay while asleep in enlightened dream land
		end
	else
		target:PushEvent("attacked", {attacker = inst, damage = 0})
	end
end

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
		
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "emerge",
        tags = {"busy", "noattack", "canrotate"},
		
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("emerge")
        end,

        timeline=
        {
            --TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/rabbit/hop") end ),
        },
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "disappear",
        tags = {"busy", "noattack"},
		
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("melt")
            inst.persists = false
        end,

        events =
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },

        onexit = function(inst)
        end,
    },

    State{
        name = "relocate",
        tags = {"busy", "noattack", "canrotate"},
		
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("melt")
        end,

        timeline=
        {
            --TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/rabbit/hop") end ),
        },
        
        events =
        {
            EventHandler("animover", function(inst)
				inst.sg:GoToState("relocating") 
			end),
        },
    },

    State{
        name = "relocating",
        tags = {"busy", "noattack", "hidden"},
		
        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst:Hide()
            inst.sg:SetTimeout(math.random() * 0.5 + 0.25)
        end,
        
        ontimeout = function(inst)
			inst.sg.statemem.dest = TheWorld.components.brightmarespawner:FindRelocatePoint(inst) or nil
			if inst.sg.statemem.dest ~= nil then
				inst.sg:GoToState("emerge") 
			else
				inst:Remove()
			end
		end,

		onexit = function(inst)
			if inst.sg.statemem.dest ~= nil then
				inst.Transform:SetPosition(inst.sg.statemem.dest:Get())
				inst:Show()
			else
				inst:Remove()
			end
		end
    },

    State{
        name = "attack",
        tags = { "busy", "attack", "jumping" },
		
        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack")

			inst.components.locomotor:Stop()
			if inst.components.combat.target ~= nil then
				inst:ForceFacePoint(inst.components.combat.target.Transform:GetWorldPosition())
			end
	        inst.components.combat:StartAttack()
		end,
        
        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) 
					inst.Physics:SetMotorVelOverride(20, 0, 0)
					inst.sg.statemem.enable_attack = true
				end ),
            TimeEvent(25*FRAMES, function(inst) 
					inst.Physics:ClearMotorVelOverride()
					inst.components.locomotor:Stop()
					inst.sg.statemem.enable_attack = false
					inst.components.combat:DropTarget()
				end ),
        },
        
        onupdate = function(inst)
			if inst.sg.statemem.enable_attack then
				local target = FindBestAttackTarget(inst)
				if target ~= nil then
					DoSpecialAttack(inst, target)
					inst.sg.statemem.attack_landed = true
					inst.components.combat:DropTarget()
					inst.sg:GoToState("mutate_pre")
				end
			end
        end,
        
        events =
        {
            EventHandler("animover", function(inst) 
				inst.sg:GoToState("idle") 
			end),
        },

        onexit = function(inst)
			inst.Physics:ClearMotorVelOverride()
			inst.components.locomotor:Stop()
			if not inst.sg.statemem.attack_landed then
				inst.components.combat:DropTarget()
			end
		end,
    },

    State{
        name = "mutate_pre",
        tags = {"busy", "jumping"},
		
        onenter = function(inst)
			inst.Physics:SetMotorVelOverride(2, 0, 0)
            inst.AnimState:PlayAnimation("mutate")
			inst.persists = false
        end,

        timeline=
        {
            --TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/rabbit/hop") end ),
        },
        
        events =
        {
            EventHandler("animover", function(inst)
				inst:Remove()
			end),
        },

    },
}

local function SpawnTrail(inst)
	local trail = SpawnPrefab("gestalt_trail")
	trail.Transform:SetPosition(inst.Transform:GetWorldPosition())
	trail.Transform:SetRotation(inst.Transform:GetRotation())
end

CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
    },
    walktimeline =
    {
        TimeEvent(0*FRAMES, SpawnTrail),
        --TimeEvent(5*FRAMES, SpawnTrail),
    },
    endtimeline =
    {
    },
}
, nil, nil, true)


return StateGraph("gestalt", states, events, "idle", actionhandlers)
