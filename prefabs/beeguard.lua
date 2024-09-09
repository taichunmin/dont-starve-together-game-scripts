local assets =
{
    Asset("ANIM", "anim/bee_guard.zip"),
    Asset("ANIM", "anim/bee_guard_build.zip"),
    Asset("ANIM", "anim/bee_guard_puffy_build.zip"),
}

local prefabs =
{
    "bee_poof_big",
    "bee_poof_small",
    "stinger",
	"ocean_splash_med1",
	"ocean_splash_med2",
}

--------------------------------------------------------------------------

local brain = require("brains/beeguardbrain")

--------------------------------------------------------------------------

local normalsounds =
{
    attack = "dontstarve/bee/killerbee_attack",
    --attack = "dontstarve/creatures/together/bee_queen/beeguard/attack",
    buzz = "dontstarve/bee/bee_fly_LP",
    hit = "dontstarve/creatures/together/bee_queen/beeguard/hurt",
    death = "dontstarve/creatures/together/bee_queen/beeguard/death",
}

local poofysounds =
{
    attack = "dontstarve/bee/killerbee_attack",
    --attack = "dontstarve/creatures/together/bee_queen/beeguard/attack",
    buzz = "dontstarve/bee/killerbee_fly_LP",
    hit = "dontstarve/creatures/together/bee_queen/beeguard/hurt",
    death = "dontstarve/creatures/together/bee_queen/beeguard/death",
}

local function EnableBuzz(inst, enable)
    if enable then
        if not inst.buzzing then
            inst.buzzing = true
            if not inst:IsAsleep() then
                inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
            end
        end
    elseif inst.buzzing then
        inst.buzzing = false
        inst.SoundEmitter:KillSound("buzz")
    end
end


local function AddFriendListener(inst, friend)
    inst._friendref = friend
    inst._friendrefcallback = function()
        inst._friendref = nil
        inst:StartFindingPlayerQueenTasks()
    end
    inst._friendreflistener = inst:ListenForEvent("onremove", inst._friendrefcallback, inst._friendref)
end

local function RemoveFriendListener(inst)
    if inst._friendreflistener then
        inst:RemoveEventCallback("onremove", inst._friendrefcallback, inst._friendref)
        inst._friendref = nil
        inst._friendrefcallback = nil
        inst._friendreflistener = nil
    end
end

local function IsFriendly(inst)
    return inst._friendid ~= nil
end

local function MakeFriendly(inst, userid)
    if not inst._friendid then
        inst._friendid = userid
        inst:RemoveTag("hostile")
        inst:AddTag("NOBLOCK")
        inst:AddTag("companion")
    end
end

local function MakeHostile(inst)
    if inst._friendid then
        inst._friendid = nil
        inst:AddTag("hostile")
        inst:RemoveTag("NOBLOCK")
        inst:RemoveTag("companion")
    end
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end

    if inst.buzzing then
        inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
    end
end

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end

    if not inst:IsFriendly() then
        inst._sleeptask = not inst.components.health:IsDead() and inst:DoTaskInTime(10, inst.Remove) or nil
    end

    inst.SoundEmitter:KillSound("buzz")
end

--------------------------------------------------------------------------

local function CheckFocusTarget(inst)
    if inst._focustarget ~= nil and (
            not inst._focustarget:IsValid() or
            (inst._focustarget.components.health ~= nil and inst._focustarget.components.health:IsDead()) or
            inst._focustarget:HasTag("playerghost")
        ) then
        inst._focustarget = nil
        inst:RemoveTag("notaunt")
    end
    return inst._focustarget
end

local FRIENDLYBEES_MUST = { "_combat", "_health" }
local FRIENDLYBEES_CANT = { "INLIMBO", "noauradamage", "bee", "companion" }
local FRIENDLYBEES_MUST_ONE = { "monster", "prey" }
local FRIENDLYBEES_PVP = nil
local BEE_STUCK_MUST = { "_combat" }
local function RetargetFn(inst)
    if inst:IsFriendly() then
        if inst:GetQueen() == nil then -- NOTES(JBK): A friendly bee must wait for its queen to take action.
            return nil
        end
        local pvpon = TheNet:GetPVPEnabled()
        if FRIENDLYBEES_PVP ~= pvpon then
            if pvpon then
                table.removearrayvalue(FRIENDLYBEES_CANT, "player")
                table.insert(FRIENDLYBEES_MUST_ONE, "player")
            else
                table.insert(FRIENDLYBEES_CANT, "player")
                table.removearrayvalue(FRIENDLYBEES_MUST_ONE, "player")
            end
            FRIENDLYBEES_PVP = pvpon
        end
        local ix, iy, iz = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(
            ix, iy, iz, TUNING.BOOK_BEES_MAX_ATTACK_RANGE,
            FRIENDLYBEES_MUST, FRIENDLYBEES_CANT, FRIENDLYBEES_MUST_ONE
        )

        local queen = inst:GetQueen()
        for _, v in ipairs(ents) do
            if v ~= queen then
                return v
            end
        end

        return nil
    end

	local focustarget = CheckFocusTarget(inst)
	if focustarget ~= nil then
		return focustarget, not inst.components.combat:TargetIs(focustarget)
	end

	if inst.components.combat:HasTarget() and inst.components.stuckdetection:IsStuck() then
		local queen = inst:GetQueen()
		if queen ~= nil then
			local commander = queen.components.commander
			local x, y, z = inst.Transform:GetWorldPosition()
			for i, v in ipairs(TheSim:FindEntities(x, 0, z, TUNING.BEEGUARD_ATTACK_RANGE + 3, BEE_STUCK_MUST)) do
				if v ~= inst then
					local target = v.components.combat.target
					if target == queen or (commander ~= nil and commander:IsSoldier(target)) then
						return v, true
					end
				end
			end
		end
	end

	local player, distsq = inst:GetNearestPlayer()
	return (distsq ~= nil and distsq < 225) and player or nil
end

local function KeepTargetFn(inst, target)
    local focustarget = CheckFocusTarget(inst)
    return (focustarget ~= nil and
            inst.components.combat:TargetIs(focustarget))
        or (inst.components.combat:CanTarget(target) and
            inst:IsNear(target, 40))
end

local function bonus_damage_via_allergy(inst, target, damage, weapon)
    return (target:HasTag("allergictobees") and TUNING.BEE_ALLERGY_EXTRADAMAGE) or 0
end

local function CanShareTarget(dude)
    return dude:HasTag("bee") and not (dude:IsInLimbo() or dude.components.health:IsDead() or dude:HasTag("epic"))
end

local function GetQueen(inst)
    return inst.components.entitytracker:GetEntity("queen") or inst._friendref or nil
end

local function OnAttacked(inst, data)
    local commander = inst:GetQueen()
    if data.attacker == commander then
        return
    end

    inst.components.combat:SetTarget(CheckFocusTarget(inst) or data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 20, CanShareTarget, 6)
end

local function OnAttackOther(inst, data)
	inst.components.stuckdetection:Reset()

    if data.target ~= nil and data.target.components.inventory ~= nil then
        for k, eslot in pairs(EQUIPSLOTS) do
            local equip = data.target.components.inventory:GetEquippedItem(eslot)
            if equip ~= nil and equip.components.armor ~= nil and equip.components.armor.tags ~= nil then
                for i, tag in ipairs(equip.components.armor.tags) do
                    if tag == "bee" then
                        inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.OFTEN)
                        return
                    end
                end
            end
        end
    end
    inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.ALWAYS)
end

--------------------------------------------------------------------------

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

--------------------------------------------------------------------------

local function OnSave(inst, data)
    data.friendid = inst._friendid -- This variable is set to nil when not a userid.
end

local function OnLoad(inst, data)
    if data and data.friendid then
        inst:MakeFriendly(data.friendid) -- Function handles setting the value stored.
    end
end

local function AddToArmy(inst, queen)
    if queen:HasTag("player") then
        queen:MakeGenericCommander()
        if inst.components.follower == nil then
            inst:AddComponent("follower")
            inst.components.follower:SetLeader(queen)
        end
    else
        if inst.components.follower ~= nil then
            inst.components.follower:StopFollowing()
            inst:RemoveComponent("follower")
        end
    end
    if queen.components.commander ~= nil then
        queen.components.commander:AddSoldier(inst)
    end
end

local function TryToFindQueen(inst) -- Only should be called with a player and has a _friendid stored.
    local queen = LookupPlayerInstByUserID(inst._friendid)
    if queen then
        AddFriendListener(inst, queen)
        inst:AddToArmy(queen)
        if inst._findqueentask then
            inst._findqueentask:Cancel()
            inst._findqueentask = nil
        end
        if inst._fleetask then
            inst._fleetask:Cancel()
            inst._fleetask = nil
        end
    end
end

local function Flee(inst)
    inst._fleetask = nil
    if inst._findqueentask then
        inst._findqueentask:Cancel()
        inst._findqueentask = nil
    end
    inst:PushEvent("flee")
end

local function StartFindingPlayerQueenTasks(inst)
    if inst._fleetask then
        inst._fleetask:Cancel()
        inst._fleetask = nil
    end
    if inst._findqueentask then
        inst._findqueentask:Cancel()
        inst._findqueentask = nil
    end
    if not inst:IsFriendly() then
        return
    end
    inst._findqueentask = inst:DoPeriodicTask(1 + math.random(), TryToFindQueen)
    inst._fleetask = inst:DoTaskInTime(TUNING.BOOK_BEES_MAX_TIME_TO_LINGER, Flee)
end

local function OnLoadPostPass(inst)
    local queen = inst:GetQueen()
    if queen ~= nil then
        inst:AddToArmy(queen)
    else
        inst:StartFindingPlayerQueenTasks()
    end
end

local function OnSpawnedGuard(inst, queen)
    inst.sg:GoToState("spawnin", queen)
    if queen.components.commander ~= nil then
        queen.components.commander:AddSoldier(inst)
    end
end

--------------------------------------------------------------------------

local function FocusTarget(inst, target)
    inst._focustarget = target
    inst:AddTag("notaunt")

    if target ~= nil then
        if inst.components.locomotor.walkspeed ~= TUNING.BEEGUARD_DASH_SPEED then
            inst.AnimState:SetBuild("bee_guard_puffy_build")
            inst.components.locomotor.walkspeed = TUNING.BEEGUARD_DASH_SPEED
            inst.components.combat:SetDefaultDamage(TUNING.BEEGUARD_PUFFY_DAMAGE)
            inst.components.combat:SetAttackPeriod(TUNING.BEEGUARD_PUFFY_ATTACK_PERIOD)
            inst.sounds = poofysounds
            if inst.SoundEmitter:PlayingSound("buzz") then
                inst.SoundEmitter:KillSound("buzz")
                inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
            end
            SpawnPrefab("bee_poof_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
        inst.components.combat:SetTarget(target)
    elseif inst.components.locomotor.walkspeed ~= TUNING.BEEGUARD_SPEED then
        inst.AnimState:SetBuild("bee_guard_build")
        inst.components.locomotor.walkspeed = TUNING.BEEGUARD_SPEED
        inst.components.combat:SetDefaultDamage(TUNING.BEEGUARD_PUFFY_DAMAGE)
        inst.components.combat:SetAttackPeriod(TUNING.BEEGUARD_PUFFY_ATTACK_PERIOD)
        inst.sounds = normalsounds
        if inst.SoundEmitter:PlayingSound("buzz") then
            inst.SoundEmitter:KillSound("buzz")
            inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
        end
        SpawnPrefab("bee_poof_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

local function BeeSort(a, b) -- Better than assumption!
    return a.GUID < b.GUID
end

local function OnGotCommander(inst, data)
    local queen = inst:GetQueen()
    if queen ~= data.commander then
        inst.components.entitytracker:ForgetEntity("queen")
        RemoveFriendListener(inst)
        local realqueen = false
        if data.commander:HasTag("player") then
            inst:MakeFriendly(data.commander.userid)
            AddFriendListener(inst, data.commander)
        else
            inst.components.entitytracker:TrackEntity("queen", data.commander)
            inst:MakeHostile()
            realqueen = true
        end

        local allbeeguards = data.commander.components.commander:GetAllSoldiers("beeguard")
        local totalbeeguards = #allbeeguards
        if totalbeeguards > 0 then
            table.sort(allbeeguards, BeeSort)
            local radius = TUNING.BEEGUARD_GUARD_RANGE
            local qx, qy, qz = data.commander.Transform:GetWorldPosition()
            for i, v in ipairs(allbeeguards) do
                local angle = PI2 * (i - math.random()) / totalbeeguards
                local radiusoffset = math.random() * 2 - 1 + 2 * (i % 2)
                local offset = Vector3((radius + radiusoffset) * math.cos(angle), 0, (radius + radiusoffset) * math.sin(angle))
                v.components.knownlocations:RememberLocation("queenoffset", offset, false)

				-- NOTES(JBK): This is an edge case hack fixup so these bees do not get lost from being too far from a real Bee Queen.
				-- V2C: Updated hack to use sleep status instead of range.
				if realqueen and v:IsAsleep() then
					if v.components.health:IsDead() or v.sg:HasStateTag("flight") then
						v:Remove()
					elseif v.components.rooted == nil then
						v.Physics:Teleport(qx + offset.x, qy + offset.y, qz + offset.z)
						if not data.commander:IsAsleep() then
							v.sg:GoToState("spawnin", data.commander)
						end
					end
                end
            end
        end
    end
end

local function OnLostCommander(inst, data)
    local queen = inst:GetQueen()
    if queen == data.commander then
        inst._friendref = nil
        inst.components.entitytracker:ForgetEntity("queen")
        inst.components.knownlocations:ForgetLocation("queenoffset")
        FocusTarget(inst, nil)
        inst:StartFindingPlayerQueenTasks()
    end
end

local function CheckBeeQueen(inst, data)
    local commander = inst:GetQueen()
    local target = data.target
    
    if target ~= nil and commander ~= nil and commander:HasTag("player") and target:HasTag("beequeen") then
        inst:MakeHostile()
        commander.components.commander:RemoveSoldier(inst)
        inst:AddToArmy(target)

        if target.components.combat:HasTarget() then
            inst.components.combat:SetTarget(target.components.combat.target)
        else
            inst.components.combat:SetTarget(commander)
        end
    end
end

local function OnNewTarget(inst, data)
    inst:DoTaskInTime(0, CheckBeeQueen, data)
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(1.4, 1.4, 1.4)

    inst.DynamicShadow:SetSize(1.2, .75)

    MakeFlyingCharacterPhysics(inst, 1.5, .75)

    inst.AnimState:SetBank("bee_guard")
    inst.AnimState:SetBuild("bee_guard_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("insect")
    inst:AddTag("bee")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")

    MakeInventoryFloatable(inst)

    --Sneak this into pristine state for optimization
    inst:AddTag("__follower")

    inst.entity:SetPristine()

    inst.scrapbook_removedeps = {"stinger"}

    if not TheWorld.ismastersim then
        return inst
    end

    inst.recentlycharged = {}

    --Remove this tag so that they can be added properly when replicating below
    inst:RemoveTag("__follower")
    inst:PrereplicateComponent("follower")

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddChanceLoot("stinger", 0.01)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper.diminishingreturns = true

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = TUNING.BEEGUARD_SPEED
    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BEEGUARD_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BEEGUARD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BEEGUARD_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.BEEGUARD_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(2, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat.battlecryenabled = false
    inst.components.combat.hiteffectsymbol = "mane"
    inst.components.combat.bonusdamagefn = bonus_damage_via_allergy

	inst:AddComponent("stuckdetection")
	inst.components.stuckdetection:SetTimeToStuck(2)

    inst:AddComponent("entitytracker")
    inst:AddComponent("knownlocations")

    MakeSmallBurnableCharacter(inst, "mane")
    MakeSmallFreezableCharacter(inst, "mane")
    inst.components.freezable:SetResistance(2)
    inst.components.freezable.diminishingreturns = true

    inst:SetStateGraph("SGbeeguard")
    inst:SetBrain(brain)

    MakeHauntablePanic(inst)

    inst.hit_recovery = 1

    inst:ListenForEvent("gotcommander", OnGotCommander)
    inst:ListenForEvent("lostcommander", OnLostCommander)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    inst.buzzing = true
    inst.sounds = normalsounds
    inst.EnableBuzz = EnableBuzz
    inst.IsFriendly = IsFriendly
    inst.MakeFriendly = MakeFriendly
    inst.StartFindingPlayerQueenTasks = StartFindingPlayerQueenTasks
    inst.GetQueen = GetQueen
    inst.MakeHostile = MakeHostile
    inst.AddToArmy = AddToArmy
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnSpawnedGuard = OnSpawnedGuard

    inst._focustarget = nil
    inst.FocusTarget = FocusTarget

    return inst
end

return Prefab("beeguard", fn, assets, prefabs)
