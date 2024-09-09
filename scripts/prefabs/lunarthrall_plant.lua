require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/lunarthrall_plant_front.zip"),
    Asset("ANIM", "anim/lunarthrall_plant_back.zip"),
    Asset("MINIMAP_IMAGE", "lunarthrall_plant"),
}

local vineassets =
{
    Asset("ANIM", "anim/lunarthrall_plant_vine.zip"),
    Asset("ANIM", "anim/lunarthrall_plant_vine_big.zip"),
}

local prefabs =
{
    "lunarthrall_plant_back",
    "lunarthrall_plant_gestalt",
    "lunarplant_husk",
    "lunarthrall_plant_vine",
    "lunarthrall_plant_vine_end",
}

local loot = {
    "lunarplant_husk",
    "lunarplant_husk",
    "plantmeat",
    "plantmeat",
}

local function customPlayAnimation(inst,anim,loop)
    inst.AnimState:PlayAnimation(anim,loop)
    if inst.back then
        inst.back.AnimState:PlayAnimation(anim,loop)
    end
end

local function customPushAnimation(inst,anim,loop)
    inst.AnimState:PushAnimation(anim,loop)
    if inst.back then
        inst.back.AnimState:PushAnimation(anim,loop)
    end
end

local function customSetRandomFrame(inst)
    local frame = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) -1
    inst.AnimState:SetFrame(frame)
    
    if inst.back then
        inst.back.AnimState:SetFrame(frame)
    end
end

local function back_onentityreplicated(inst)
	local parent = inst.entity:GetParent()
	if parent ~= nil and parent.prefab == "lunarthrall_plant" then
		table.insert(parent.highlightchildren, inst)
	end
end

local function back_onremoveentity(inst)
	local parent = inst.entity:GetParent()
	if parent ~= nil and parent.highlightchildren ~= nil then
		table.removearrayvalue(parent.highlightchildren, inst)
	end
end

local function backfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lunarthrall_plant_back")
    inst.AnimState:SetBuild("lunarthrall_plant_back")
    inst.AnimState:PlayAnimation("idle_med", true)

    inst:AddTag("fx")

	inst.OnRemovedEntity = back_onremoveentity

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
		inst.OnEntityReplicated = back_onentityreplicated

        return inst
    end

    inst.persists = false

    return inst
end

local function spawnback(inst)
    local back = SpawnPrefab("lunarthrall_plant_back")
    back.AnimState:SetFinalOffset(-1)
    inst.back = back
	table.insert(inst.highlightchildren, back)

    back:ListenForEvent("death", function()
        local self = inst.components.burnable
        if self ~= nil and self:IsBurning() and not self.nocharring then
            back.AnimState:SetMultColour(.2, .2, .2, 1)
        end
    end, inst)

    if math.random() < 0.5 then
        inst.AnimState:SetScale(-1,1)
        back.AnimState:SetScale(-1,1)
    end
    local color = .6 + math.random() * .4
    inst.tintcolor = color
    inst.AnimState:SetMultColour(color, color, color, 1)
    back.AnimState:SetMultColour(color, color, color, 1)

	back.entity:SetParent(inst.entity)
    inst.components.colouradder:AttachChild(back)
end

local function infest(inst,target)
    if target then
        
        if target.components.pickable then
            target.components.pickable.caninteractwith = false
        end

        if target.components.growable then
            target.components.growable:Pause("lunarthrall_plant")
        end
        
        target:AddTag("NOCLICK")

        inst.components.entitytracker:TrackEntity("targetplant", target)
        target.lunarthrall_plant = inst
        inst.Transform:SetPosition(target.Transform:GetWorldPosition())
        local bbx1, bby1, bbx2, bby2 = target.AnimState:GetVisualBB()
        local bby = bby2 - bby1
        if bby < 2 then
            inst.targetsize = "short"
        elseif bby < 4 then
            inst.targetsize = "med"
        else
            inst.targetsize = "tall"
        end
        inst:customPlayAnimation("idle_"..inst.targetsize )
        inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
        TheWorld:PushEvent("lunarthrallplant_infested",target)
    end
end

local function deinfest(inst)
    local target = inst.components.entitytracker:GetEntity("targetplant")
    if target then
        if target.components.pickable then
            target.components.pickable.caninteractwith = true
        end
        if target.components.growable then
            target.components.growable:Resume("lunarthrall_plant")
        end            
        target:RemoveTag("NOCLICK")
    end
end

local function playSpawnAnimation(inst)
    inst.sg:GoToState("spawn")
end

local function OnLoadPostPass(inst)

    if inst.components.entitytracker:GetEntity("targetplant") then
        inst:infest(inst.components.entitytracker:GetEntity("targetplant"),true)
    end
end

local function OnFreeze(inst)
	if inst.waketask ~= nil then
		inst.waketask:Cancel()
		inst.waketask = nil
	end
	if inst.resttask ~= nil then
		inst.resttask:Cancel()
		inst.resttask = nil
	end
	if inst.tired or inst.wake then
		inst.wake = nil
		inst.tired = nil
		inst.vinelimit = TUNING.LUNARTHRALL_PLANT_VINE_LIMIT
	end
end

local function OnDeath(inst)
    inst:killvines()
    local target = inst.components.entitytracker:GetEntity("targetplant")
    if target then
        target.lunarthrall_plant = nil
    end    
    if inst.waketask then
        inst.waketask:Cancel()
        inst.waketask = nil
    end
    if inst.resttask then
        inst.resttask:Cancel()
        inst.resttask = nil
    end    
    inst.components.lootdropper:DropLoot()
    inst:customPlayAnimation("death_"..inst.targetsize )
    inst:ListenForEvent("animover", function()
        if inst.AnimState:IsCurrentAnimation("death_"..inst.targetsize) then
            inst:Remove()
        end
    end)
end

local function OnRemove(inst)
    inst:deinfest()
    inst:killvines()
end

local function vineremoved(inst,vine,killed)
    for i,localvine in ipairs(inst.vines)do
        if localvine == vine then
            table.remove(inst.vines,i)
            if not killed then
                inst.vinelimit = inst.vinelimit + 1
            end
			break
        end
    end
end

local function OnWakeTask(inst)
	inst.waketask = nil
	inst.wake = nil
	inst.tired = nil
	inst.vinelimit = TUNING.LUNARTHRALL_PLANT_VINE_LIMIT
	inst.sg:GoToState("attack")
end

local function OnRestTask(inst)
	inst.resttask = nil

	if not inst.components.health:IsDead() then
		inst.sg:GoToState("tired_wake")

		if inst.waketask ~= nil then
			inst.waketask:Cancel()
		end
		inst.waketask = inst:DoTaskInTime(TUNING.LUNARTHRALL_PLANT_WAKE_TIME, OnWakeTask)
	end
end

local function vinekilled(inst,vine)
    for i,localvine in ipairs(inst.vines)do
        if localvine == vine then
            vineremoved(inst,vine, true)
            if inst.vinelimit <= 0 and #inst.vines <= 0 then
                if not inst.components.health:IsDead() then
                    inst.sg:GoToState("tired_pre")
                end
				if inst.waketask ~= nil then
					inst.waketask:Cancel()
					inst.waketask = nil
				end
				if inst.resttask ~= nil then
					inst.resttask:Cancel()
				end
				inst.resttask = inst:DoTaskInTime(TUNING.LUNARTHRALL_PLANT_REST_TIME + (math.random()*1), OnRestTask)
            end
        end
    end  
end

local function killvines(inst)
    for i,localvine in ipairs(inst.vines)do
        if localvine:IsValid() then
            localvine.components.health:Kill()
        end
    end
end

local function OnAttacked(inst,data)
    if data.attacker then
        if (
                not inst.components.combat.target 
                or (inst.components.combat.target ~= data.attacker and not inst.components.timer:TimerExists("targetswitched"))
            ) 
            and not data.attacker.components.complexprojectile
            and not data.attacker.components.projectile then

			inst.components.timer:StopTimer("targetswitched")
            inst.components.timer:StartTimer("targetswitched",20)
            inst.components.combat:SetTarget(data.attacker)
        end
    end
end

local function vine_addcoldness(vine, ...)
	local inst = vine.parentplant
	if inst ~= nil and inst:IsValid() then
		inst.components.freezable:AddColdness(...)
		return true
	end
	return false
end

local PLANT_MUST = {"lunarthrall_plant"}
local TARGET_MUST_TAGS = { "_combat", "character" }
local TARGET_CANT_TAGS = { "INLIMBO","lunarthrall_plant", "lunarthrall_plant_end" }
local function Retarget(inst)
    --print("RETARGET")
    if not inst.no_targeting then
        local target = FindEntity(
            inst,
            TUNING.LUNARTHRALL_PLANT_RANGE,
            function(guy)
                local total = 0
                local x,y,z = inst.Transform:GetWorldPosition()

                if inst.tired then
                    return nil
                end

                local plants = TheSim:FindEntities(x,y,z, 15, PLANT_MUST)
                for i, plant in ipairs(plants)do
                    if plant ~= inst then
                        if plant.components.combat.target and plant.components.combat.target == guy then
                            total = total +1
                        end
                    end
                end
                if total < 3 then
                    return inst.components.combat:CanTarget(guy)
                end
            end,
            TARGET_MUST_TAGS,
            TARGET_CANT_TAGS
        )

        if inst.vinelimit > 0 then
            if target and ( not inst.components.freezable or not inst.components.freezable:IsFrozen()) then

                local pos = inst:GetPosition()

                local theta = math.random()*TWOPI
                local radius = TUNING.LUNARTHRALL_PLANT_MOVEDIST
                local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                pos = pos + offset

                if TheWorld.Map:IsVisualGroundAtPoint(pos.x,pos.y,pos.z) then

                    local vine = SpawnPrefab("lunarthrall_plant_vine_end")
                    vine.Transform:SetPosition(pos.x,pos.y,pos.z)
                    vine.Transform:SetRotation(inst:GetAngleToPoint(pos.x, pos.y, pos.z))
    				vine.components.freezable:SetRedirectFn(vine_addcoldness)
                    vine.sg:RemoveStateTag("nub")
                    if inst.tintcolor then
                        vine.AnimState:SetMultColour(inst.tintcolor, inst.tintcolor, inst.tintcolor, 1)
                        vine.tintcolor = inst.tintcolor
                    end

    				inst.components.colouradder:AttachChild(vine)

                    vine.parentplant = inst
                    table.insert(inst.vines,vine)
                    inst.vinelimit = inst.vinelimit -1
                    inst:DoTaskInTime(0,function() vine:ChooseAction() end)

                    return target
                end
            end
        end
    end
end

local function keeptargetfn(inst, target)
   return target ~= nil
        and target:GetDistanceSqToInst(inst) < TUNING.LUNARTHRALL_PLANT_GIVEUPRANGE* TUNING.LUNARTHRALL_PLANT_GIVEUPRANGE
        and target.components.combat ~= nil
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and not (inst.components.follower ~= nil and
                (inst.components.follower.leader == target or inst.components.follower:IsLeaderSame(target)))
end

local function CreateFlame()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    if not TheWorld.ismastersim then
        inst.entity:SetCanSleep(false)
    end
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()

    inst.AnimState:SetBank("lunarthrall_plant")
    inst.AnimState:SetBuild("lunarthrall_plant_front")
    inst.AnimState:PlayAnimation("gestalt_fx", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	inst.AnimState:SetLightOverride(0.1)
    inst.AnimState:SetFrame( math.random(inst.AnimState:GetCurrentAnimationNumFrames()) -1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    return inst
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, .8)
	inst:SetPhysicsRadiusOverride(.4) --V2C: WARNING intentionally reducing range for incoming attacks; make sure everyone can still reach!

    inst.MiniMapEntity:SetIcon("lunarthrall_plant.png")
    inst.MiniMapEntity:SetPriority(5)

    inst.AnimState:SetBank("lunarthrall_plant")
    inst.AnimState:SetBuild("lunarthrall_plant_front")
    inst.AnimState:PlayAnimation("idle_med", true)
    inst.AnimState:SetFinalOffset(1)
    inst.scrapbook_anim = "scrapbook"
    inst.scrapbook_specialinfo = "LUNARTHRALLPLANT"
    inst.scrapbook_planardamage = TUNING.LUNARTHRALL_PLANT_PLANAR_DAMAGE


    inst.customPlayAnimation = customPlayAnimation
    inst.customPushAnimation = customPushAnimation
    inst.customSetRandomFrame = customSetRandomFrame

    inst:AddTag("plant")
    inst:AddTag("lunar_aligned")
    inst:AddTag("hostile")
    inst:AddTag("lunarthrall_plant")
    inst:AddTag("retaliates")
    inst:AddTag("NPCcanaggro")

	inst.highlightchildren = {}

    inst.entity:SetPristine()

    inst.targetsize = "med"

    if not TheNet:IsDedicated() then
        inst.flame = CreateFlame()
        inst.flame.entity:SetParent(inst.entity)
        inst.flame.Follower:FollowSymbol(inst.GUID, "follow_gestalt_fx", nil, nil, nil, true)
    end

    if not TheWorld.ismastersim then
        return inst
    end

    inst:customSetRandomFrame()

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.LUNARTHRALL_PLANT_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(keeptargetfn)
    inst.components.combat:SetDefaultDamage(TUNING.LUNARTHRALL_PLANT_DAMAGE)

	inst:AddComponent("planarentity")
	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.LUNARTHRALL_PLANT_PLANAR_DAMAGE)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("inspectable")
    inst:AddComponent("entitytracker")

    inst:AddComponent("colouradder")
    inst:AddComponent("timer")

    inst:ListenForEvent("death", OnDeath)
	inst:ListenForEvent("freeze", OnFreeze)
    inst:ListenForEvent("onremove",OnRemove)
    inst:ListenForEvent("attacked",OnAttacked)

    inst.vines = {}
    inst.vinekilled = vinekilled
    inst.vineremoved = vineremoved
    inst.killvines = killvines
    inst.vinelimit = TUNING.LUNARTHRALL_PLANT_VINE_LIMIT

    inst.infest = infest
    inst.deinfest = deinfest
    inst.playSpawnAnimation = playSpawnAnimation
    inst.OnLoadPostPass = OnLoadPostPass

    MakeMediumFreezableCharacter(inst)
    inst.components.freezable:SetResistance(6)
    MakeLargeBurnableCharacter(inst,"follow_gestalt_fx")

    inst:SetStateGraph("SGlunarthrall_plant")

	spawnback(inst)

    return inst
end

local function OnWeakVineAttacked(inst)
	if inst.headplant ~= nil and inst.headplant:IsValid() then
		local parent = inst.headplant.parentplant
		if parent ~= nil and parent:IsValid() and parent.components.freezable:IsFrozen() then
			parent.components.freezable:Unfreeze()
		end
	end
end

local function makeweak(inst, headplant)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.LUNARTHRALL_PLANT_VINE_HEALTH)
    inst.components.health.redirect = function(target, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
        if inst.headplant and inst.headplant:IsValid() then
            inst.headplant.indirectdamage = inst.GUID
            local result = inst.headplant.components.health:DoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
            if not inst.headplant.components.health:IsDead() then
                inst.headplant.indirectdamage = nil
            end
            return result
        end
    end
    inst:AddComponent("combat")
    inst:AddComponent("planarentity")

	inst:ListenForEvent("attacked", OnWeakVineAttacked)

	if headplant ~= nil then
		local target = headplant.components.combat.target
		if target ~= nil then
			inst.components.combat:SetTarget(target)
		end
		inst:ListenForEvent("newcombattarget", function(headplant, data)
			inst.components.combat:SetTarget(data.target)
		end, headplant)
		inst:ListenForEvent("droppedtarget", function(headplant, data)
			inst.components.combat:DropTarget()
		end, headplant)
	end

    inst:AddTag("weakvine")
    inst.AnimState:SetBank("lunarthrall_plant_vine_big")
    inst.AnimState:SetBuild("lunarthrall_plant_vine_big")

    inst:RemoveTag("fx")
    inst:RemoveTag("NOCLICK")
    inst:AddTag("hostile")
    inst:AddTag("lunarthrall_plant_segment")
    inst:AddTag("lunar_aligned")      
end

local function vine_onremoveentity(inst)
	if inst.headplant ~= nil and inst.headplant.tails ~= nil then
		table.removearrayvalue(inst.headplant.tails, inst)
	end
end

local function vinefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lunarthrall_plant_vine")
    inst.AnimState:SetBuild("lunarthrall_plant_vine")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetFinalOffset(1)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetScale(1.2,1.2,1.2)

    inst:AddTag("fx")
    inst:AddTag("NOCLICK")
    inst:AddTag("soulless")

    inst:SetPrefabNameOverride("lunarthrall_plant_vine_end")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("colouradder")

    MakeMediumFreezableCharacter(inst)
    inst.components.freezable:SetResistance(6)
    MakeMediumBurnableCharacter(inst)

    inst.persists = false
    inst.makeweak = makeweak

    inst:SetStateGraph("SGlunarthrall_plant_vine")

	inst.OnRemoveEntity = vine_onremoveentity

    return inst
end

local function ChooseAction(inst)
    --print("===== CHOSE ACTION")
    inst.target = inst.parentplant and inst.parentplant.components.combat.target
    if inst.target then
        inst.components.combat:SetTarget(inst.target)
    end
    
    if inst.mode == "retreat" then
        -- just keep going
    elseif not inst.target or not inst.target:IsValid() or not inst.target.components.health or inst.target.components.health:IsDead() then
        inst.target = nil
        inst.mode = "return"
        --print("vine: NO TARGET, GO HOME")
    elseif inst.mode ~= "avoid" then
        inst.mode = "attack"
    end

    if inst.target and inst.mode == "attack" then
        --print("vine: in ATTACK mode")
        local dist = inst:GetDistanceSqToInst(inst.target)
        if dist < TUNING.LUNARTHRALL_PLANT_VINE_INITIATE_ATTACK * TUNING.LUNARTHRALL_PLANT_VINE_INITIATE_ATTACK then
            --print("vine: ATTACK")
            if not inst.components.timer:TimerExists("attack_cooldown") then
                inst:PushEvent("doattack")
            end
        else
            local pos = Vector3(inst.target.Transform:GetWorldPosition())
            local theta = inst:GetAngleToPoint(pos)*DEGREES
            local radius = math.sqrt(dist) - TUNING.LUNARTHRALL_PLANT_CLOSEDIST
            local ITERATIONS = 5
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

            local newpos = Vector3(inst.Transform:GetWorldPosition())

            local onwater = false
            for i = 1, ITERATIONS do
                local testpos = newpos + offset * (i / ITERATIONS)
                if not TheWorld.Map:IsVisualGroundAtPoint(testpos.x, testpos.y, testpos.z) then
                    onwater = true
                    break
                end
            end

            newpos = newpos + offset

            dist = inst:GetDistanceSqToPoint(newpos)
            local moveback = nil
            for i,nub in ipairs(inst.tails)do
                local nubdist = nub:GetDistanceSqToPoint(newpos)
                if nubdist < dist then
                    dist = nubdist
                    moveback = true
                    break
                end
            end
            if moveback and not onwater then
                --print("vine: MOVEBACK")
                inst:PushEvent("moveback")
            else
                if #inst.tails < 7 and not onwater then
                    --print("vine: MOVE FORWARD")
                    inst:PushEvent("moveforward", {newpos=newpos})
                else
                    --print("EMERGE")
                    inst:PushEvent("emerge")
                end
            end
        end
    elseif inst.mode == "avoid" then
        --print("vine: in AVOID mode")
            local pos = Vector3(inst.Transform:GetWorldPosition())
            local theta = (inst:GetAngleToPoint(pos)*DEGREES) - PI
            local radius = 4 * TUNING.LUNARTHRALL_PLANT_MOVEDIST
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

            local newpos = pos + offset

            local dist = inst:GetDistanceSqToPoint(newpos)
            local moveback = nil
            for i,nub in ipairs(inst.tails)do
                local nubdist = nub:GetDistanceSqToPoint(newpos)
                if nubdist < dist then
                    dist = nubdist
                    moveback = true
                    break
                end
            end
            if moveback then
                --print("MOVE BACKWARD")
                inst:PushEvent("moveback")
            else
                if #inst.tails < 7 then
                    --print("MOVE FOREWARD")
                    inst:PushEvent("moveforward", {newpos=newpos})
                else
                    --print("EMERGE")
                    inst:PushEvent("emerge")
                end
            end
        -- move away from target and wait.
    elseif inst.mode == "return" or inst.mode == "retreat" then
       -- print("vine: in RETURN mode")
        inst:PushEvent("moveback")
    end
end

local function removetail(inst)
    if #inst.tails > 0 then
        local time = 0
        for i=#inst.tails,1,-1 do
            time = time + 0.1
            local tail = inst.tails[i]
            if not tail.errodetask then
                if tail:HasTag("weakvine") and inst.indirectdamage == tail.GUID then
                    tail.sg:GoToState("death")
                end
				if tail.components.combat ~= nil then
					tail:AddTag("NOCLICK")
					tail:AddTag("notarget")
				end
                tail.errodetask = tail:DoTaskInTime(time,ErodeAway)
            end
        end
    end
end

local function setweakstate(inst, weak )
    if weak then
        inst:AddTag("weakvine")
        inst.AnimState:SetBank("lunarthrall_plant_vine_big")
        inst.AnimState:SetBuild("lunarthrall_plant_vine_big")
    else
        inst:RemoveTag("weakvine")
        inst.AnimState:SetBank("lunarthrall_plant_vine")
        inst.AnimState:SetBuild("lunarthrall_plant_vine")
    end
end

local function vineendfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("plant")
    inst:AddTag("lunar_aligned")
    inst:AddTag("lunarthrall_plant_end")
    inst:AddTag("hostile")
    inst:AddTag("soulless")
    inst:AddTag("NPCcanaggro")

    inst.AnimState:SetBank("lunarthrall_plant_vine")
    inst.AnimState:SetBuild("lunarthrall_plant_vine")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetFinalOffset(1)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetScale(1.2,1.2,1.2)

    inst.customPlayAnimation = customPlayAnimation
    inst.customPushAnimation = customPushAnimation

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.LUNARTHRALL_PLANT_VINE_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.LUNARTHRALL_PLANT_END_DAMAGE)

	inst:AddComponent("planarentity")
	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(TUNING.LUNARTHRALL_PLANT_END_PLANAR_DAMAGE)

	inst:AddComponent("colouradder")
    inst:AddComponent("timer")

    inst:AddComponent("inspectable")
    inst.tails = {}
    inst.mode = "attack"
    inst.ChooseAction = ChooseAction
    inst.persists = false
    inst.setweakstate = setweakstate
    inst:ListenForEvent("attacked", function()
        if inst.mode == "attack" then
            inst.mode = "avoid"
            inst:DoTaskInTime(math.random()*3 + 1, function()
                inst.mode = "attack"
            end)
        end
		if inst.parentplant ~= nil and inst.parentplant:IsValid() and inst.parentplant.components.freezable:IsFrozen() then
			inst.parentplant.components.freezable:Unfreeze()
		end
    end)
    inst:ListenForEvent("timerdone", function(inst,data)
        if data.name == "idletimer" then
            inst.mode = "retreat"
        end
    end)
    inst:ListenForEvent("death", function() 
        removetail(inst)
        if inst.parentplant and inst.parentplant:IsValid() then
            inst.parentplant:vinekilled(inst)
        end
    end)
    inst:ListenForEvent("onremove", function() 
        removetail(inst)
        --vine.parentplant do something
        if inst.parentplant and inst.parentplant:IsValid() then
            inst.parentplant:vineremoved(inst)
        end
    end)

    MakeMediumFreezableCharacter(inst)
    inst.components.freezable:SetResistance(6)
    MakeMediumBurnableCharacter(inst)

    inst:SetStateGraph("SGlunarthrall_plant_vine")

    return inst
end

return Prefab("lunarthrall_plant", fn, assets, prefabs),
       Prefab("lunarthrall_plant_back", backfn, assets),
       Prefab("lunarthrall_plant_vine", vinefn, vineassets ),
       Prefab("lunarthrall_plant_vine_end", vineendfn, vineassets )