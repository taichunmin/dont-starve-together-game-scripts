require("stategraphs/commonstates")

local function nub_addcoldness(nub, ...)
	local inst = nub.headplant --NOTE: this is the vine end, not the parentplant
	if inst ~= nil and inst:IsValid() then
		inst.components.freezable:AddColdness(...)
		return true
	end
	return false
end

local function onmovetailtask(inst, tail, anim)
	tail.sg.mem.movetailtask = nil
	tail.sg:GoToState(anim)
end

local function cancelmovetail(tail)
	if tail.sg.mem.movetailtask ~= nil then
		tail.sg.mem.movetailtask:Cancel()
		tail.sg.mem.movetailtask = nil
	end
end

local function movetail(inst,anim)
    if inst.tails and #inst.tails > 0 then
        local time = 0   
        for i=#inst.tails, 1,-1 do
            local tail = inst.tails[i]
            --for i, tail in ipairs(inst.tails)do
            time = time + 0.1
			if tail.sg.mem.movetailtask ~= nil then
				tail.sg.mem.movetailtask:Cancel()
			end
			tail.sg.mem.movetailtask = inst:DoTaskInTime(time, onmovetailtask, tail, anim)
        end
    end
end

local function teleportback(inst)
    if #inst.tails > 0 then
		local last_tail = table.remove(inst.tails)
		inst.Transform:SetPosition(last_tail.Transform:GetWorldPosition())
		if last_tail:HasTag("weakvine") then
            inst:setweakstate(true)
			inst.Transform:SetRotation(last_tail.Transform:GetRotation())
        else
            inst:setweakstate(false)
			inst.Transform:SetRotation(last_tail.Transform:GetRotation())
        end 
		last_tail:Remove()
        inst.sg:GoToState("nub_idle")
    else
        inst:Remove()
    end
end

local function teleportahead(inst,pos)
    local nub = SpawnPrefab("lunarthrall_plant_vine")
    nub.Transform:SetPosition(inst.Transform:GetWorldPosition())
	nub.Transform:SetRotation(inst.Transform:GetRotation())

    if inst:HasTag("weakvine") then
		nub:makeweak(inst)
    end
    nub.sg:GoToState("nub_idle")
    nub.headplant = inst

	local parent = inst.parentplant or inst
	parent.components.colouradder:AttachChild(nub)
	nub.components.freezable:SetRedirectFn(nub_addcoldness)

    if inst.tintcolor then
        nub.tintcolor = inst.tintcolor
        nub.AnimState:SetMultColour(inst.tintcolor, inst.tintcolor, inst.tintcolor, 1)
    end

    table.insert(inst.tails,nub)

    local dist = inst:GetDistanceSqToPoint(pos)
    local newpos = pos
    if dist > TUNING.LUNARTHRALL_PLANT_MOVEDIST * TUNING.LUNARTHRALL_PLANT_MOVEDIST then
        local theta = inst:GetAngleToPoint(newpos)*DEGREES
        local radius = 2.5
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        newpos = Vector3(inst.Transform:GetWorldPosition()) + offset
    end
    local angle = nub:GetAngleToPoint(newpos)
    inst.Transform:SetPosition(newpos.x,newpos.y,newpos.z)
    inst.Transform:SetRotation(angle)

    inst.sg:RemoveStateTag("nub")
    inst.sg:RemoveStateTag("busy")

    inst:ChooseAction()
end

local WEAKVINE_CAN = {"weakvine","lunarthrall_plant"}

local MUST_TAGS =  {"_combat"}
local CANT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "invisible", "wall", "notarget", "noattack", "lunarthrall_plant", "lunarthrall_plant_end","lunarthrall_plant_segment" }

local TOSSITEM_MUST_TAGS = { "_inventoryitem" }
local TOSSITEM_CANT_TAGS = { "locomotor", "INLIMBO" }
local TOSS_RADIUS = .2
local TOSS_RADIUS_PADDING = .5
local function DoToss(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local totoss = TheSim:FindEntities(x, 0, z, TOSS_RADIUS + TOSS_RADIUS_PADDING, TOSSITEM_MUST_TAGS, TOSSITEM_CANT_TAGS)
	for i, v in ipairs(totoss) do
		if v.components.mine ~= nil then
			v.components.mine:Deactivate()
		end
		if not v.components.inventoryitem.nobounce then
			Launch2(v, inst, .5, 1, .1, TOSS_RADIUS + v:GetPhysicsRadius(0))
		end
	end
end

local events =
{
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() then
			if inst.sg:HasStateTag("caninterrupt") or not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("hit")
            end
        end
    end),
    EventHandler("doattack", function(inst, data)
        if not inst.sg:HasStateTag("busy") and not inst.components.health:IsDead() then
            if inst.sg:HasStateTag("emerged") then
                inst.sg:GoToState("attack")
            elseif inst.sg:HasStateTag("nub") then
                inst.sg:GoToState("nub_retract",nil,true)
            else
                inst.sg:GoToState("emerge")
            end
        else
            inst:DoTaskInTime(0,function()
                inst:ChooseAction()
            end)
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),

    EventHandler("moveback", function(inst)
        if (inst.sg:HasStateTag("caninterrupt") or not inst.sg:HasStateTag("busy")) and not inst.components.health:IsDead() then
            if inst.sg:HasStateTag("emerged") then
                inst.sg:GoToState("retract")
            elseif inst.sg:HasStateTag("nub") then
                inst.sg:GoToState("nub_retract")
            else
                teleportback(inst)
            end
        end
    end),

    EventHandler("moveforward", function(inst,data)
        if (inst.sg:HasStateTag("caninterrupt") or not inst.sg:HasStateTag("busy")) and not inst.components.health:IsDead() then
            if inst.sg:HasStateTag("emerged") then
                inst.sg:GoToState("retract", data.newpos)
            elseif inst.sg:HasStateTag("nub") then
                teleportahead(inst,data.newpos)
            else
                inst.sg:GoToState("nub_spawn",data.newpos)
            end
        end
    end),

    EventHandler("emerge", function(inst)
        if (inst.sg:HasStateTag("caninterrupt") or not inst.sg:HasStateTag("busy")) and not inst.components.health:IsDead() and not inst.sg:HasStateTag("emerged") then
            inst.sg:GoToState("emerge")
        end
    end),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate","emerged"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("breach_idle")

            if not inst.components.timer:TimerExists("idletimer") then
                inst.components.timer:StartTimer("idletimer",2)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg.statemem.gotoidle = true
                inst.sg:GoToState("idle")
                inst:ChooseAction()
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.gotoidle then
                inst.components.timer:StopTimer("idletimer")
            end
        end,
    },

    State{
        name = "emerge",
        tags = {"busy", "canrotate","emerged"},

        onenter = function(inst)
            if inst:HasTag("weakvine") then
                inst:setweakstate(false)
            end
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/vine_breach")
            inst.AnimState:PlayAnimation("breach_pre")
			DoToss(inst)
        end,

        timeline=
        {
            TimeEvent(7*FRAMES, function(inst) inst.sg:AddStateTag("caninterrupt") end ),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst:ChooseAction()
                inst.sg:GoToState("idle") 
            end),
        },
    },

    State{
        name = "retract",
        tags = {"busy", "canrotate", "retracting", "emerged"},

        onenter = function(inst, pos)
            inst.sg.statemem.pos = pos
            inst.AnimState:PlayAnimation("breach_pst")
        end,

        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) 
                inst.sg:AddStateTag("noattack")
                if inst.components.burnable and inst.components.burnable:IsBurning() then
                    inst.components.burnable:Extinguish()
                end
            end ),
        },

        events =
        {
            EventHandler("animover", function(inst) 
                if inst.sg.statemem.pos then
                    -- moving forward
                    inst.sg:GoToState("nub_spawn",inst.sg.statemem.pos)
                elseif #inst.tails > 0 then
                    -- moving backward
					local last_tail = table.remove(inst.tails)
					inst.Transform:SetPosition(last_tail.Transform:GetWorldPosition())
					inst:setweakstate(last_tail:HasTag("weakvine"))
					last_tail:Remove()
                    inst.sg:GoToState("nub_idle")
                    inst:ChooseAction()
                else
                    inst:Remove()
                end
            end),
        },
    },

    State{
        name = "attack",
        tags = {"busy", "canrotate","emerged"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("atk")
            inst.components.timer:StartTimer("attack_cooldown",TUNING.LUNARTHRALL_PLANT_ATTACK_PERIOD)
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("rifts/lunarthrall/vine_attack")
            end),
            TimeEvent(17*FRAMES, function(inst)
                local x,y,z = inst.Transform:GetWorldPosition()
                local targets = TheSim:FindEntities(x, y, z, TUNING.LUNARTHRALL_PLANT_VINE_ATTACK_RANGE, MUST_TAGS, CANT_TAGS )
                for i,target in ipairs(targets)do
                    inst.components.combat:DoAttack(target)
                end
            end ),
        },

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
                inst:ChooseAction()
            end),
        },
    },

    State{
        name = "hit",
        tags = {"busy","caninterrupt"},

        onenter = function(inst)
            if inst:HasTag("weakvine") then
                inst.AnimState:PlayAnimation("hit_arch")
            else
                inst.sg:AddStateTag("emerged")
                inst.AnimState:PlayAnimation("hit")
            end
        end,

        timeline=
        {
            --TimeEvent(25*FRAMES, function(inst) end ),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst:HasTag("weakvine") or not inst:HasTag("lunarthrall_plant_end") then
                    inst.sg:GoToState("nub_idle")
                else
                    inst.sg:GoToState("idle")
                end
                if inst:HasTag("lunarthrall_plant_end") then
                    inst:ChooseAction()
                end
            end),
        },
    },
    
    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
			cancelmovetail(inst)

            if inst:HasTag("weakvine") then
                if inst.setweakstate then
                    inst:setweakstate(false)
                end
            else
                inst.sg:AddStateTag("emerged")
            end

            if inst.parentplant and inst.parentplant:IsValid() then
                inst.parentplant:vinekilled(inst)
            end
            if inst.indirectdamage then 
                inst.AnimState:PlayAnimation("death2")
            else
                inst.AnimState:PlayAnimation("death")
            end
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/vine_death")
        end,
    },

    State{
        name = "nub_spawn",
        tags = {"busy", "noattack","nub"},

        onenter = function(inst,pos)
            local pt = Vector3(inst.Transform:GetWorldPosition())
            local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil,nil, WEAKVINE_CAN)

            if #ents <= 0 then
                inst:setweakstate(true)
                inst.sg:RemoveStateTag("noattack")
            else
                inst:setweakstate(false)
            end

            inst.sg.statemem.pos = pos
            inst.AnimState:PlayAnimation("spawn")
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/vine_spawn")

            movetail(inst,"nub_forward")
			DoToss(inst)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.pos then
                    teleportahead(inst,inst.sg.statemem.pos)
                else
                    inst:ChooseAction()
                end
            end),
        },

        onexit = function(inst)
            if inst:HasTag("lunarthrall_plant_end") then
                inst:setweakstate(false)
            end
        end,
    },

    State{
        name = "nub_idle",
        tags = {"idle", "noattack","nub"},

        onenter = function(inst)
            if inst:HasTag("weakvine") then
                inst.sg:RemoveStateTag("noattack")
            end
            inst.AnimState:PlayAnimation("idle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.ChooseAction then
                    inst:ChooseAction()
                end
                inst.sg:GoToState("nub_idle")
            end),
        },
    },

    State{
        name = "nub_reverse",
        tags = {"noattack","nub"},

        onenter = function(inst)
            if inst:HasTag("weakvine") then
                inst.sg:RemoveStateTag("noattack")
            end
            inst.AnimState:PlayAnimation("retract_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("nub_idle") 
            end),
        },
    },  

    State{
        name = "nub_forward",
        tags = {"noattack","nub"},

        onenter = function(inst)
            if inst:HasTag("weakvine") then
                inst.sg:RemoveStateTag("noattack")
            end
            inst.AnimState:PlayAnimation("loop")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("nub_idle")
            end),
        },
    },  

    State{
        name = "nub_retract",
        tags = {"noattack","nub"},

        onenter = function(inst,pos,notailmove)
            if inst:HasTag("weakvine") then
                inst.sg:RemoveStateTag("noattack")
            end
            inst.sg.statemem.pos = pos
            inst.AnimState:PlayAnimation("retract")
            inst.SoundEmitter:PlaySound("rifts/lunarthrall/vine_retract")
            if not notailmove and not pos then
                movetail(inst,"nub_reverse")
            end
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.pos then
                    inst.sg:GoToState("nub_spawn",inst.sg.statemem.pos)
                else
                    teleportback(inst)
                end
            end),
        },
    },

	State{
		name = "sync_frozen",
		tags = { "busy", "frozen" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("frozen", true)
			inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
			inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

			cancelmovetail(inst)

			if inst.tails ~= nil then
				for i, v in ipairs(inst.tails) do
					if v.components.health ~= nil and not v.components.health:IsDead() then
						v.sg:GoToState("sync_frozen")
					end
				end
			end
		end,

		onexit = function(inst)
			if not inst.sg.statemem.thawing then
				inst.components.freezable:SpawnShatterFX()
				inst.AnimState:ClearOverrideSymbol("swap_frozen")
				if inst.tails ~= nil then
					for i, v in ipairs(inst.tails) do
						if v.sg:HasStateTag("frozen") or v.sg:HasStateTag("thawing") then
							v.sg:GoToState("hit")
						else
							v.components.freezable:SpawnShatterFX()
						end
					end
				end
			end
		end,
	},

	State{
		name = "sync_thaw",
		tags = { "busy", "thawing" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("frozen_loop_pst", true)
			inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
			inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")

			cancelmovetail(inst)

			if inst.tails ~= nil then
				for i, v in ipairs(inst.tails) do
					if v.components.health ~= nil and not v.components.health:IsDead() then
						v.sg.statemem.thawing = true
						v.sg:GoToState("sync_thaw")
					end
				end
			end
		end,

		onexit = function(inst)
			inst.components.freezable:SpawnShatterFX()
			inst.SoundEmitter:KillSound("thawing")
			inst.AnimState:ClearOverrideSymbol("swap_frozen")
			if inst.tails ~= nil then
				for i, v in ipairs(inst.tails) do
					if v.sg:HasStateTag("frozen") or v.sg:HasStateTag("thawing") then
						v.sg:GoToState("hit")
					else
						v.components.freezable:SpawnShatterFX()
					end
				end
			end
		end,
	},
}

return StateGraph("lunarthrall_plant_vine", states, events, "nub_idle")
