local function VolleyData(data)
	local skilltreeupdater = data.doer and data.doer.components.skilltreeupdater or nil
	return
	{
		doer = data.doer,
		pos = data.targetpos,
		mega = data.element, --only elementalvolley has this
		aoe = skilltreeupdater and
			(	(skilltreeupdater:IsActivated("winona_catapult_aoe_3") and 3) or
				(skilltreeupdater:IsActivated("winona_catapult_aoe_2") and 2) or
				(skilltreeupdater:IsActivated("winona_catapult_aoe_1") and 1)
			) or 0,
	}
end

local events =
{
    EventHandler("doattack", function(inst, data)
        if inst.sg.mem.ison and
            data ~= nil and
            data.target ~= nil and
            not inst.components.health:IsDead() and
            (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) and
            data.target:IsValid() and
			not inst:IsTargetTooClose(data.target)
		then
            inst.sg:GoToState("attack", data.target)
        end
    end),
	EventHandler("dovolley", function(inst, data)
		if inst.sg.mem.ison and data and data.targetpos and not inst.components.health:IsDead() then
			inst.sg.mem.elemvolleyqueue = nil
			if not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit") then
				inst.sg:GoToState("attack", VolleyData(data))
			elseif inst.sg.mem.volleyqueue then
				if #inst.sg.mem.volleyqueue >= TUNING.WINONA_CATAPULT_VOLLEY_QUEUE_SIZE then
					table.remove(inst.sg.mem.volleyqueue, 1)
				end
				table.insert(inst.sg.mem.volleyqueue, VolleyData(data))
			else
				inst.sg.mem.volleyqueue = { VolleyData(data) }
			end
		end
	end),
	EventHandler("doelementalvolley", function(inst, data)
		if inst.sg.mem.ison and data and data.targetpos and not inst.components.health:IsDead() then
			inst.sg.mem.volleyqueue = nil
			if not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit") then
				inst.sg:GoToState("attack", VolleyData(data))
			elseif inst.sg.mem.elemvolleyqueue then
				if #inst.sg.mem.elemvolleyqueue >= TUNING.WINONA_CATAPULT_VOLLEY_QUEUE_SIZE then
					table.remove(inst.sg.mem.elemvolleyqueue, 1)
				end
				table.insert(inst.sg.mem.elemvolleyqueue, VolleyData(data))
			else
				inst.sg.mem.elemvolleyqueue = { VolleyData(data) }
			end
		end
	end),
    EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() and
            (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and
            (data == nil or data.damage ~= 0 or data.weapon == nil or not data.weapon._nocatapulthit) then
            --V2C: last line of conditions is for fire/ice staffs, since those generally don't trigger hit state on structures
            inst.sg:GoToState("hit")
        end
    end),
}

local function TryQueuedVolley(inst)
	if inst:IsActiveMode() then
		if inst.sg.mem.elemvolleyqueue then
			local data = table.remove(inst.sg.mem.elemvolleyqueue, 1)
			if #inst.sg.mem.elemvolleyqueue <= 0 then
				inst.sg.mem.elemvolleyqueue = nil
			end
			if data then
				inst.sg:GoToState("attack", data)
				return true
			end
		end
		if inst.sg.mem.volleyqueue then
			local data = table.remove(inst.sg.mem.volleyqueue, 1)
			if #inst.sg.mem.volleyqueue <= 0 then
				inst.sg.mem.volleyqueue = nil
			end
			if data then
				inst.sg:GoToState("attack", data)
				return true
			end
		end
	end
	return false
end

local function ClearQueuedVolley(inst)
	inst.sg.mem.volleyqueue = nil
	inst.sg.mem.elemvolleyqueue = nil
end

local states =
{
    State{
        name = "place",
        tags = { "busy", "noattack" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("place")
            inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/place")
            inst:AddTag("NOCLICK")
            inst.sg.mem.recentlyplaced = true
            inst.sg.mem.ison = nil
        end,

        timeline =
        {
            TimeEvent(18 * FRAMES, function(inst)
                inst.sg:AddStateTag("caninterrupt")
                inst.sg:RemoveStateTag("noattack")
                if not inst.components.health:IsDead() then
                    inst:RemoveTag("NOCLICK")
                    if not inst:HasTag("burnt") then
						inst:OnReadyForConnection()
                    end
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("noattack") and not inst.components.health:IsDead() then
                inst:RemoveTag("NOCLICK")
                if not inst:HasTag("burnt") then
					inst:OnReadyForConnection()
                end
            end
        end,
    },

	State{
		name = "deploy",
		tags = { "busy", "noattack" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("deploy")
			inst:AddTag("NOCLICK")
			inst.sg.mem.recentlyplaced = true
			inst.sg.mem.ison = nil
		end,

		timeline =
		{
			SoundFrameEvent(4, "meta4/winona_catapult/deploy_f4"),
			FrameEvent(17, function(inst)
				inst.sg:AddStateTag("caninterrupt")
				inst.sg:RemoveStateTag("noattack")
				if not inst.components.health:IsDead() then
					inst:RemoveTag("NOCLICK")
					if not inst:HasTag("burnt") then
						inst:OnReadyForConnection()
					end
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if inst.sg:HasStateTag("noattack") and not inst.components.health:IsDead() then
				inst:RemoveTag("NOCLICK")
				if not inst:HasTag("burnt") then
					inst:OnReadyForConnection()
				end
			end
		end,
	},

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, loading)
            if inst.sg.mem.ison then
				if inst:IsActiveMode() then
                    local anim = inst.sg.mem.recentlyplaced and "idle_nodir" or "idle"
                    if not inst.AnimState:IsCurrentAnimation(anim) then
                        inst.AnimState:PlayAnimation(anim, true)
                    end
                else
                    inst.sg:GoToState("powerdown")
					return
                end
			elseif inst:IsActiveMode() then
                if loading then
                    inst.sg.mem.ison = true
                    inst.sg.mem.recentlyplaced = nil
                    if not inst.AnimState:IsCurrentAnimation("idle") then
                        inst.AnimState:PlayAnimation("idle", true)
						inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
                    end
                else
                    inst.sg:GoToState("powerup")
					return
                end
            else
            	ClearQueuedVolley(inst)
                inst.AnimState:PlayAnimation(inst.sg.mem.recentlyplaced and "idle_off_nodir" or "idle_off")
            end

			TryQueuedVolley(inst)
        end,

        events =
        {
            EventHandler("togglepower", function(inst, data)
                if inst.sg.mem.ison then
                    if not data.ison then
                        inst.sg:GoToState("powerdown")
                    end
                elseif data.ison then
                    inst.sg:GoToState("powerup")
                end
            end),
        },
    },

    State{
        name = "powerup",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit", nil, .5)
            inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/ratchet_LP", "power")
            inst.AnimState:PlayAnimation(inst.sg.mem.recentlyplaced and "idle_trans_nodir" or "idle_trans")
            inst.sg.mem.ison = true
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("power")
        end,
    },

    State{
        name = "powerdown",
        tags = { "busy", "caninterrupt" },

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/ratchet_LP", "power")
            inst.AnimState:PlayAnimation(inst.sg.mem.recentlyplaced and "idle_trans_off_nodir" or "idle_trans_off")
            inst.sg.mem.ison = false
            ClearQueuedVolley(inst)
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit", nil, .35) end),
            TimeEvent(11 * FRAMES, function(inst) inst.SoundEmitter:KillSound("power") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("power")
        end,
    },

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation((inst.sg.mem.ison and "hit" or "hit_off")..(inst.sg.mem.recentlyplaced and "_nodir" or ""))
            inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/hit")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:AddStateTag("caninterrupt")
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

        onenter = function(inst, target)
            inst.sg.mem.recentlyplaced = nil

			if EntityScript.is_instance(target) then
				if target:IsValid() then
					inst.sg.statemem.target = target
					inst.sg.statemem.targetpos = target:GetPosition()
					inst:ForceFacePoint(inst.sg.statemem.targetpos)
				end
			elseif target then
				inst.sg.statemem.caster = target.doer
				inst.sg.statemem.mega = target.mega
				inst.sg.statemem.aoe = target.aoe
				inst.sg.statemem.targetpos = Vector3(target.pos:Get())
				inst:ForceFacePoint(inst.sg.statemem.targetpos)
			end

			local numshadow, numlunar, numtotal = 0, 0, 0
			inst.components.circuitnode:ForEachNode(function(inst, node)
				if node.components.fueled and not node.components.fueled:IsEmpty() and not (node.IsOverloaded and node:IsOverloaded()) then
					local elem = node:CheckElementalBattery()
					if elem == "horror" then
						numshadow = numshadow + 1
					elseif elem == "brilliance" then
						numlunar = numlunar + 1
					end
					numtotal = numtotal + 1
				end
			end)
			if numtotal > 0 then
				local cost, share
				local costhorror, sharehorror
				local costbrilliance, sharebrilliance

				if inst.sg.statemem.mega == "shadow" then
					if numshadow > 0 then
						cost = TUNING.WINONA_CATAPULT_MEGA_SHADOW_POWER_COST
						share = numshadow
						inst.sg.statemem.elemental = "shadow"
					else
						inst.sg.statemem.mega = nil
					end
				elseif inst.sg.statemem.mega == "lunar" then
					if numlunar > 0 then
						cost = TUNING.WINONA_CATAPULT_MEGA_LUNAR_POWER_COST
						share = numlunar
						inst.sg.statemem.elemental = "lunar"
					else
						inst.sg.statemem.mega = nil
					end
				elseif inst.sg.statemem.mega == "hybrid" then
					if numshadow == 0 and numlunar == 0 then
						inst.sg.statemem.mega = nil
					elseif numshadow == 0 then
						cost = TUNING.WINONA_CATAPULT_MEGA_LUNAR_POWER_COST
						share = numlunar
						inst.sg.statemem.elemental = "lunar"
					elseif numlunar == 0 then
						cost = TUNING.WINONA_CATAPULT_MEGA_SHADOW_POWER_COST
						share = numshadow
						inst.sg.statemem.elemental = "shadow"
					else
						costhorror = TUNING.WINONA_CATAPULT_MEGA_SHADOW_POWER_COST
						costbrilliance = TUNING.WINONA_CATAPULT_MEGA_LUNAR_POWER_COST
						sharehorror = numshadow
						sharebrilliance = numlunar
						inst.sg.statemem.elemental = "hybrid"
					end
				end

				if inst.sg.statemem.mega == nil then
					cost = TUNING.WINONA_CATAPULT_ATTACK_POWER_COST
					if inst._engineerid == nil or (numshadow == 0 and numlunar == 0) then
						share = numtotal
					else
						share = numshadow + numlunar
						inst.sg.statemem.elemental = numshadow > 0 and (numlunar > 0 and "hybrid" or "shadow") or "lunar"
					end
				end

				inst.components.circuitnode:ForEachNode(function(inst, node)
					if node.components.fueled and not node.components.fueled:IsEmpty() and not (node.IsOverloaded and node:IsOverloaded()) then
						if inst.sg.statemem.elemental == "shadow" then
							if node:CheckElementalBattery() == "horror" then
								node:ConsumeBatteryAmount(cost, share, inst)
							end
						elseif inst.sg.statemem.elemental == "lunar" then
							if node:CheckElementalBattery() == "brilliance" then
								node:ConsumeBatteryAmount(cost, share, inst)
							end
						elseif inst.sg.statemem.elemental == "hybrid" then
							local elem = node:CheckElementalBattery()
							if elem == "horror" then
								node:ConsumeBatteryAmount(costhorror or cost, sharehorror or share, inst)
							elseif elem == "brilliance" then
								node:ConsumeBatteryAmount(costbrilliance or cost, sharebrilliance or share, inst)
							end
						else
							node:ConsumeBatteryAmount(cost, share, inst)
						end
					end
				end)
			else
				inst.sg.statemem.mega = nil
			end

            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/ratchet_LP", "attack_pre")
			inst:OnStartAttack(inst.sg.statemem.elemental)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil then
                if inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.targetpos.x, inst.sg.statemem.targetpos.y, inst.sg.statemem.targetpos.z = inst.sg.statemem.target.Transform:GetWorldPosition()
                    inst:ForceFacePoint(inst.sg.statemem.targetpos)
                else
                    inst.sg.statemem.target = nil
                end
            end
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/fire")
            end),
            TimeEvent(21 * FRAMES, function(inst)
                inst.components.combat:StartAttack()

                inst.sg.statemem.rock = SpawnPrefab("winona_catapult_projectile")
				inst.sg.statemem.rock:SetElementalRock(inst.sg.statemem.elemental, inst.sg.statemem.mega ~= nil)

				local aoe = inst._aoe
				local radius = inst.AOE_RADIUS
				if inst.sg.statemem.aoe then
					--override to volley caster's skills
					aoe = inst.sg.statemem.aoe
					radius = TUNING.WINONA_CATAPULT_AOE_RADIUS * (TUNING.SKILLS.WINONA.CATAPULT_AOE_RADIUS_MULT[aoe] or 1)
				end
				inst.sg.statemem.rock:SetAoeRadius(
					(not inst.sg.statemem.mega and radius) or
					(inst.sg.statemem.elemental ~= "shadow" and radius * 2) or
					TUNING.WINONA_CATAPULT_AOE_RADIUS, --mega shadow is always smallest hit, but spawns vines in larger area
					aoe --this is the aoe level, used separately from the calulated radius
				)

				if inst.sg.statemem.caster then
					inst.sg.statemem.rock.caster = inst.sg.statemem.caster
				elseif inst._engineerid then
					for i, v in ipairs(AllPlayers) do
						if v.userid == inst._engineerid then
							inst.sg.statemem.rock.caster = v
							break
						end
					end
				end

				local x, y, z = inst.Transform:GetWorldPosition()
                inst.sg.statemem.rock.Transform:SetPosition(x, y, z)

                local pos = inst.sg.statemem.targetpos
                if pos == nil then
                    --in case of missing target, toss a rock random distance in front of current facing
                    local theta = (inst.Transform:GetRotation() + 90) * DEGREES
                    local len = GetRandomMinMax(TUNING.WINONA_CATAPULT_MIN_RANGE, TUNING.WINONA_CATAPULT_MAX_RANGE)
                    pos = inst:GetPosition()
                    pos.x = pos.x + math.sin(theta) * len
                    pos.z = pos.z + math.cos(theta) * len
                else
                    if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() then
                        pos.x, pos.y, pos.z = inst.sg.statemem.target.Transform:GetWorldPosition()
                    end
                    local dx = pos.x - x
                    local dz = pos.z - z
                    local l = dx * dx + dz * dz
                    if l < TUNING.WINONA_CATAPULT_MIN_RANGE * TUNING.WINONA_CATAPULT_MIN_RANGE then
                        l = TUNING.WINONA_CATAPULT_MIN_RANGE / math.sqrt(l)
                        pos.x = x + dx * l
                        pos.z = z + dz * l
					elseif l > TUNING.WINONA_CATAPULT_MAX_RANGE * TUNING.WINONA_CATAPULT_MAX_RANGE then
						l = TUNING.WINONA_CATAPULT_MAX_RANGE / math.sqrt(l)
						pos.x = x + dx * l
						pos.z = z + dz * l
                    end
                end
                pos.y = 0
                inst.sg.statemem.target = nil --stop onupdate
                inst:ForceFacePoint(pos)
                inst.sg.statemem.rock.components.complexprojectile:Launch(pos, inst)
                inst.sg.statemem.rock:Hide()
                --inst.sg.statemem.damageself = true
            end),
            TimeEvent(24 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("attack_pre")
                if inst.sg.statemem.rock:IsValid() then
                    inst.AnimState:Hide("rock")
                    inst.sg.statemem.rock:Show()
                end
                inst.sg.statemem.rock = nil
            end),
            TimeEvent(34 * FRAMES, function(inst)
				if TryQueuedVolley(inst) then
					return
				end
                inst.sg:RemoveStateTag("busy")
            end),
            --[[TimeEvent(36 * FRAMES, function(inst)
                inst.sg.statemem.damageself = nil
                if not inst.components.health:IsDead() then
                    local state = inst._state
                    inst.components.health:DoDelta(TUNING.WINONA_CATAPULT_HEALTH / -8)
                    if state ~= inst._state then
                        inst.sg:GoToState("hit")
                    end
                end
            end),]]
            TimeEvent(38 * FRAMES, function(inst)
                inst.sg:AddStateTag("canrotate")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("attack_pre")
            if inst.sg.statemem.rock ~= nil then
                inst.sg.statemem.rock:Remove()
            end
            inst.AnimState:Show("rock")
            --[[if inst.sg.statemem.damageself and not inst.components.health:IsDead() then
                local state = inst._state
                inst.components.health:DoDelta(TUNING.WINONA_CATAPULT_HEALTH / -8)
                if state ~= inst._state then
                    inst.sg:GoToState("hit")
                end
            end]]
        end,
    },

    State{
        name = "death",
        tags = { "death", "busy" },

        onenter = function(inst)
			inst:AddTag("NOCLICK")
			inst:AddTag("notarget")
            inst.AnimState:PlayAnimation("death")
            inst.SoundEmitter:PlaySound("dontstarve/common/together/catapult/destroy")
        end,
    },
}

return StateGraph("winona_catapult", states, events, "idle")
