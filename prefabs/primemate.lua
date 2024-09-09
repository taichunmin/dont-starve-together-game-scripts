local assets =
{
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
    Asset("ANIM", "anim/ds_pig_attacks.zip"),
    Asset("ANIM", "anim/ds_pig_elite.zip"),
    Asset("ANIM", "anim/ds_pig_boat_jump.zip"),
    Asset("ANIM", "anim/ds_pig_monkey.zip"),
    Asset("ANIM", "anim/monkeymen_build.zip"),

    --for water fx build overrides
    Asset("ANIM", "anim/slide_puff.zip"),
    Asset("ANIM", "anim/splash_water_rot.zip"),

    Asset("SOUND", "sound/monkey.fsb"),
}

local prefabs =
{
    "poop",
    "monkeyprojectile",
    "smallmeat",
    "cave_banana",
    "pirate_stash",
    "monkey_mediumhat",
    "stash_map",
    "cursed_monkey_token",
	"oar_monkey",
}

local brain = require "brains/primematebrain"

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 80
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40


SetSharedLootTable('primemate',
{
    {'meat',     1.0},
    {'bananajuice',  0.2},
})

local function _ForgetTarget(inst)
    inst.components.combat:SetTarget(nil)
end

local MONKEY_TAGS = { "monkey" }
local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(math.random(55, 65), _ForgetTarget) --Forget about target after a minute

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, MONKEY_TAGS)
    for i, v in ipairs(ents) do
        if v ~= inst and v.components.combat then
            v.components.combat:SuggestTarget(data.attacker)
            if v.task ~= nil then
                v.task:Cancel()
            end
            v.task = v:DoTaskInTime(math.random(55, 65), _ForgetTarget) --Forget about target after a minute
        end
    end
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "playerghost" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local function retargetfn(inst)
    return FindEntity(
                inst,
                20,
                function(guy)
                    if guy:HasTag("monkey") then
                        return nil
                    end
                    return inst.components.combat:CanTarget(guy) and inst:GetCurrentPlatform() and inst:GetCurrentPlatform() == guy:GetCurrentPlatform() 
                end,
                RETARGET_MUST_TAGS, --see entityreplica.lua
                RETARGET_CANT_TAGS,
                RETARGET_ONEOF_TAGS
            )
        or nil
end

local function shouldKeepTarget(inst)
    --[[if inst:HasTag("nightmare") then
        return true
    end]]
    return true
end

local function OnPickup(inst, data)
	local item = data ~= nil and data.item or nil
    if item ~= nil and
        item.components.equippable ~= nil and
        item.components.equippable.equipslot == EQUIPSLOTS.HEAD and
        not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) then
        --Ugly special case for how the PICKUP action works.
        --Need to wait until PICKUP has called "GiveItem" before equipping item.
        inst:DoTaskInTime(0, function()
            if item:IsValid() and
                item.components.inventoryitem ~= nil and
                item.components.inventoryitem.owner == inst then
                inst.components.inventory:Equip(item)
            end
        end)
    end
end

local function OnDropItem(inst, data)
	if data ~= nil and data.item ~= nil then
		data.item:RemoveTag("personal_possession")
	end
end

local function OnSave(inst, data)
	local personal_item = {}
	for k, v in pairs(inst.components.inventory.itemslots) do
		if v.persists and v:HasTag("personal_possession") then
			personal_item[k] = v.prefab
		end
	end
	local personal_equip = {}
	for k, v in pairs(inst.components.inventory.equipslots) do
		if v.persists and v:HasTag("personal_possession") then
			personal_equip[k] = v.prefab
		end
	end
	data.personal_item = next(personal_item) ~= nil and personal_item or nil
	data.personal_equip = next(personal_equip) ~= nil and personal_equip or nil
end

local function OnLoad(inst, data)
	if data ~= nil then
		if data.personal_item ~= nil then
			for k, v in pairs(data.personal_item) do
				local item = inst.components.inventory:GetItemInSlot(k)
				if item ~= nil and item.prefab == v then
					item:AddTag("personal_possession")
				end
			end
		end
		if data.personal_equip ~= nil then
			for k, v in pairs(data.personal_equip) do
				local item = inst.components.inventory:GetEquippedItem(k)
				if item ~= nil and item.prefab == v then
					item:AddTag("personal_possession")
				end
			end
		end
	end
end

local function getboattargetscore(inst,boat)
    local score = 0
    for k in pairs(boat.components.walkableplatform:GetEntitiesOnPlatform()) do
        if k:HasTag("player") then
            score = score + 10
        end
        if k:HasTag("inventoryitem") then
            score = score + 1
        end
    end
    return score
end

local BOAT_MUST = {"boat"}
local function commandboat(inst)
    if inst.components.crewmember then
        local boat = inst:GetCurrentPlatform()
        if boat ~= inst.components.crewmember.boat then
            boat = nil
        end
        if boat then
            local bc = boat.components.boatcrew
            if bc then
                if bc.status == "delivery" then
                    if boat:GetDistanceSqToPoint(bc.target) < 4*4 then
                        bc:SetTarget(nil)
                        bc.status = "hunting"
                    end                    
                elseif bc.status == "hunting" then
                    local x,y,z = inst.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x, y, z, 40, BOAT_MUST)
                    local target = nil
                    local score = 0
                    for i,ent in ipairs(ents) do
                        if ent ~= inst.components.crewmember.boat then
                            local newscore = getboattargetscore(inst,ent)
                            if newscore > score then
                                score = newscore
                                target = ent
                            end
                        end
                    end

                    bc:SetTarget(nil)

                    if target then
                        if not bc.target or (bc.valid and not bc:IsValid()) then
                            bc:SetTarget(target)
                            inst:PushEvent("command")
                        end
                    end
                else
                    -- find boats with crew that are not this boat. Target closest.
                    local boats = {}
                    for member,bool in pairs(bc.members) do
                        if member ~= inst and member:GetCurrentPlatform() and member:GetCurrentPlatform() ~= inst:GetCurrentPlatform() then
                            table.insert(boats,member:GetCurrentPlatform())
                        end
                    end

                    local dist = 999999
                    local targetboat = nil
                    if #boats > 0 and inst:GetCurrentPlatform() then
                        for i,boat in ipairs(boats)do
                            local thisdist = boat:GetDistanceSqToInst(inst:GetCurrentPlatform())
                            if thisdist < dist then
                                targetboat = boat
                            end
                        end
                    end
                    if targetboat then
                        bc:SetTarget(targetboat)
                    end
                end
            end
        end
    end
end

local function OnAbandonShip(inst)
    inst:DoTaskInTime((math.random()*1.5)+0.3, function() inst.abandon = true end)
end

local function speech_override_fn(inst, speech)
    if not ThePlayer or ThePlayer:HasTag("wonkey") then
        return speech
    else
        return CraftMonkeySpeech()
    end 
end

local function battlecry(combatcmp, target)
    local strtbl = nil
    
    if target ~= nil then
        if target:HasTag("monkey") ~= nil then
            strtbl = "MONKEY_MONKEY_BATTLECRY"
        elseif target.components.inventory ~= nil and target.components.inventory:NumItems() > 0 then
            strtbl = "MONKEY_STUFF_BATTLECRY"
        else
            strtbl = "MONKEY_BATTLECRY"
        end

        return strtbl, math.random(#STRINGS[strtbl])
    end
end

local function onmonkeychange(inst, data)
    if data and data.player then
        if inst.components.combat and inst.components.combat.target and inst.components.combat.target == data.player then
            inst.components.combat:DropTarget()
        end
    end
end

local function ontalk(inst, script)
    inst.SoundEmitter:PlaySound("monkeyisland/primemate/speak")
end

local function OnDeath(inst,data)
    local item = SpawnPrefab("cursed_monkey_token")
    inst.components.inventory:DropItem(item, nil, true)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, 1.25)

    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 10, 0.25)

    inst.AnimState:SetBank("pigman")
    inst.AnimState:SetBuild("monkeymen_build")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.Transform:SetScale(1.2,1.2,1.2)

    inst.AnimState:Hide("ARM_carry_up")

    inst.AnimState:OverrideSymbol("fx_slidepuff01", "slide_puff", "fx_slidepuff01")
    inst.AnimState:OverrideSymbol("splash_water_rot", "splash_water_rot", "splash_water_rot")
    inst.AnimState:OverrideSymbol("fx_water_spot", "splash_water_rot", "fx_water_spot")
    inst.AnimState:OverrideSymbol("fx_splash_wide", "splash_water_rot", "fx_splash_wide")
    inst.AnimState:OverrideSymbol("fx_water_spray", "splash_water_rot", "fx_water_spray")

    inst:AddTag("character")
    inst:AddTag("monkey")
    inst:AddTag("hostile")
	inst:AddTag("scarytoprey")
    inst:AddTag("pirate")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()
    inst.components.talker.ontalk = ontalk    

    inst.speech_override_fn = speech_override_fn

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.soundtype = ""

    MakeMediumBurnableCharacter(inst,"pig_torso")
    MakeMediumFreezableCharacter(inst)

    inst:AddComponent("bloomer")

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")

    inst:AddComponent("thief")

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = false }
    inst.components.locomotor.walkspeed = TUNING.MONKEY_MOVE_SPEED/2

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.PRIME_MATE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.PRIME_MATE_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.MONKEY_MELEE_RANGE)
    inst.components.combat:SetRetargetFunction(1, retargetfn)
    inst.components.combat.GetBattleCryString = battlecry

    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    inst.components.combat:SetDefaultDamage(0)  --This doesn't matter, monkey uses weapon damage

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.PRIME_MATE_HEALTH)

    inst:AddComponent("timer")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("primemate")

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })

    inst:AddComponent("sleeper")
    inst.components.sleeper.sleeptestfn = onmonkeychange
    inst.components.sleeper.waketestfn = DefaultWakeTest

    inst:AddComponent("drownable")

    inst:SetBrain(brain)
    inst:SetStateGraph("SGprimemate")

    inst:AddComponent("knownlocations")

    inst:ListenForEvent("onpickupitem", OnPickup)
	inst:ListenForEvent("dropitem", OnDropItem)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("abandon_ship", OnAbandonShip)
    inst:ListenForEvent("death", OnDeath)

    MakeHauntablePanic(inst)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

    inst:DoPeriodicTask(1,commandboat)

    return inst
end

return Prefab("prime_mate", fn, assets, prefabs)
