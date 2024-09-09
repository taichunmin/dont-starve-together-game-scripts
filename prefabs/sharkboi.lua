local assets =
{
	Asset("ANIM", "anim/sharkboi_build.zip"),
	Asset("ANIM", "anim/sharkboi_build_brows.zip"),
	Asset("ANIM", "anim/sharkboi_build_manes.zip"),
	Asset("ANIM", "anim/sharkboi_basic.zip"),
	Asset("ANIM", "anim/sharkboi_action.zip"),
	Asset("ANIM", "anim/sharkboi_actions1.zip"),
}

local prefabs =
{
	"sharkboi_icehole_fx",
	"sharkboi_iceimpact_fx",
	"sharkboi_iceplow_fx",
	"sharkboi_icespike",
	"sharkboi_icetrail_fx",
	"sharkboi_icetunnel_fx",
	"sharkboi_swipe_fx",
	"splash_green_large",
	"bootleg",
	"chesspiece_sharkboi_sketch",
	"sharkboi_water",
}

local brain = require("brains/sharkboibrain")

--[[SetSharedLootTable("sharkboi",
{
	{ "bootleg", 1 },
	{ "bootleg", 1 },
	{ "bootleg", 0.5 },
})]]

local MAX_TRADES = 5
local MIN_REWARDS = 1
local MAX_REWARDS = 2

local OFFSCREEN_DESPAWN_DELAY = 60

local FIN_MASS = 99999
local FIN_RADIUS = 0.5

local STANDING_MASS = 1000
local STANDING_RADIUS = 1

local function OnFinModeDirty(inst)
	inst:SetPhysicsRadiusOverride(inst.finmode:value() and FIN_RADIUS or STANDING_RADIUS)
end

local function ChangeRadius(inst, radius)
	inst:SetPhysicsRadiusOverride(radius)
	if inst.sg.mem.isobstaclepassthrough then
		if inst.sg.mem.radius ~= radius then
			inst.sg.mem.radius = radius
			inst.Physics:SetCapsule(radius, 1)
		end
	elseif inst.sg.mem.physicstask == nil then
		if inst.sg.mem.ischaracterpassthrough then
			if inst.sg.mem.radius ~= radius then
				inst.Physics:SetCapsule(STANDING_RADIUS, 1)
				if inst.sg.mem.radius < radius then
					inst.Physics:Teleport(inst.Transform:GetWorldPosition())
				end
				inst.sg.mem.radius = STANDING_RADIUS
			end
		else
			ToggleOffAllObjectCollisions(inst)
			local x, y, z = inst.Transform:GetWorldPosition()
			ToggleOnAllObjectCollisionsAt(inst, x, z)
		end
	end
end

local function OnNewState(inst)
	if inst.sg:HasAnyStateTag("fin", "digging", "dizzy", "jumping", "invisible", "sleeping", "waking") and not inst.sg:HasStateTag("cantalk") then
		inst.components.talker:IgnoreAll("busycombat")
	else
		inst.components.talker:StopIgnoringAll("busycombat")
	end

	local dochangemass
	if inst.sg:HasStateTag("digging") then
		if not (inst.sg.lasttags and inst.sg.lasttags["digging"]) then
			inst.Physics:SetMass(0)
			inst.components.talker:ShutUp()
		end
	elseif inst.sg.lasttags and inst.sg.lasttags["digging"] then
		if inst.sg:HasStateTag("fin") then
			inst.Physics:SetMass(FIN_MASS)
		else
			inst.Physics:SetMass(STANDING_MASS)
		end
	else
		dochangemass = true
	end

	if inst.sg:HasStateTag("fin") then
		if not inst.finmode:value() then
			inst.finmode:set(true)
			inst.Transform:SetEightFaced()
			inst.DynamicShadow:Enable(false)
			if dochangemass then
				inst.Physics:SetMass(FIN_MASS)
			end
			ChangeRadius(inst, FIN_RADIUS)
			inst.components.health:SetInvincible(true)
			inst.components.combat:RestartCooldown()
			inst.components.locomotor.runspeed = TUNING.SHARKBOI_FINSPEED
			inst.components.talker:ShutUp()
		end
	elseif inst.finmode:value() then
		inst.finmode:set(false)
		inst.Transform:SetFourFaced()
		if not inst.sg:HasStateTag("invisible") then
			inst.DynamicShadow:Enable(true)
		end
		if dochangemass then
			inst.Physics:SetMass(STANDING_MASS)
		end
		ChangeRadius(inst, STANDING_RADIUS)
		inst.components.health:SetInvincible(false)
		inst.components.locomotor.runspeed = TUNING.SHARKBOI_RUNSPEED
	end
end

local function teleport_override_fn(inst)
    local sharkboimanager = TheWorld.components.sharkboimanager
    if sharkboimanager == nil then
        return nil
    end

    return sharkboimanager:FindWalkableOffsetInArena(inst)
end

local function OnTalk(inst)
	if not inst.sg:HasStateTag("notalksound") then
		if inst.sg:HasStateTag("defeated") then
			inst.SoundEmitter:PlaySound(inst.voicepath.."stunned_hit")
		else
			inst.SoundEmitter:PlaySound(inst.voicepath.."talk")
		end
	end
end

--------------------------------------------------------------------------

local function UpdatePlayerTargets(inst)
	local toadd = {}
	local toremove = {}
	local x, y, z = inst.Transform:GetWorldPosition()

	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		toremove[k] = true
	end

	local sharkboimanager = TheWorld.components.sharkboimanager
	if sharkboimanager and sharkboimanager:IsPointInArena(inst.Transform:GetWorldPosition()) then
		for i, v in ipairs(AllPlayers) do
			if not (v.components.health:IsDead() or v:HasTag("playerghost")) and
				v.entity:IsVisible() and
				sharkboimanager:IsPointInArena(v.Transform:GetWorldPosition())
			then
				if toremove[v] then
					toremove[v] = nil
				else
					table.insert(toadd, v)
				end
			end
		end
	else
		for i, v in ipairs(FindPlayersInRange(x, y, z, TUNING.SHARKBOI_DEAGGRO_DIST, true)) do
			if toremove[v] then
				toremove[v] = nil
			else
				table.insert(toadd, v)
			end
		end
	end

	for k in pairs(toremove) do
		inst.components.grouptargeter:RemoveTarget(k)
	end
	for i, v in ipairs(toadd) do
		inst.components.grouptargeter:AddTarget(v)
	end
end

local function RetargetFn(inst)
	if not inst:HasTag("hostile") then
		return
	end

	UpdatePlayerTargets(inst)

	local target = inst.components.combat.target
	local inrange = target and inst:IsNear(target, TUNING.SHARKBOI_ATTACK_RANGE + target:GetPhysicsRadius(0))

	if target and target:HasTag("player") then
		local newplayer = inst.components.grouptargeter:TryGetNewTarget()
		return newplayer
			and newplayer:IsNear(inst, inrange and TUNING.SHARKBOI_ATTACK_RANGE + newplayer:GetPhysicsRadius(0) or TUNING.SHARKBOI_KEEP_AGGRO_DIST)
			and newplayer
			or nil,
			true
	end

	local nearplayers = {}
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		if inst:IsNear(k, inrange and TUNING.SHARKBOI_ATTACK_RANGE + k:GetPhysicsRadius(0) or TUNING.SHARKBOI_AGGRO_DIST) then
			table.insert(nearplayers, k)
		end
	end
	return #nearplayers > 0 and nearplayers[math.random(#nearplayers)] or nil, true
end

local function KeepTargetFn(inst, target)
	if inst:HasTag("hostile") and inst.components.combat:CanTarget(target) then
		local sharkboimanager = TheWorld.components.sharkboimanager
		if sharkboimanager and sharkboimanager:IsPointInArena(inst.Transform:GetWorldPosition()) then
			return sharkboimanager:IsPointInArena(target.Transform:GetWorldPosition())
		end
		return inst:IsNear(target, TUNING.SHARKBOI_DEAGGRO_DIST)
	end
	return false
end

local function StartAggro(inst)
	if not inst:HasTag("hostile") then
        inst:AddTag("hostile")
		inst.components.timer:StopTimer("standing_dive_cd")
		inst.components.timer:StartTimer("standing_dive_cd", TUNING.SHARKBOI_STANDING_DIVE_CD / 2)
		inst.components.timer:StopTimer("torpedo_cd")
		inst.components.timer:StartTimer("torpedo_cd", TUNING.SHARKBOI_TORPEDO_CD / 2)
	end
end

local function StopAggro(inst)
	if inst:HasTag("hostile") then
        inst:RemoveTag("hostile")
		inst.components.timer:StopTimer("standing_dive_cd")
		inst.components.timer:StopTimer("torpedo_cd")
	end
end

local function OnAttacked(inst, data)
	if data.attacker and inst.components.trader == nil then
		local target = inst.components.combat.target
		if not (target and
				target:HasTag("player") and
				target:IsNear(inst, TUNING.SHARKBOI_ATTACK_RANGE + target:GetPhysicsRadius(0))
		) then
			if inst.components.health.currenthealth > inst.components.health.minhealth then
				inst:StartAggro()
			end
			inst.components.combat:SetTarget(data.attacker)
		end
	end
end

local function EndGloat(inst)
	inst.components.talker:StopIgnoringAll("gloat")
end

local function OnKilledOther(inst, data)
	if data and data.victim and data.victim:HasTag("player") then
		if not inst:HasTag("ignoretalking") then
			inst.components.talker:Chatter("SHARKBOI_TALK_GLOAT", math.random(#STRINGS.SHARKBOI_TALK_GLOAT), nil, true, CHATPRIORITIES.LOW)
			inst.components.talker:IgnoreAll("gloat")
			inst:DoTaskInTime(3, EndGloat)
		end
	end
end

--------------------------------------------------------------------------

local function ShouldSleep(inst)
	return false
end

local function ShouldWake(inst)
	return true
end

--------------------------------------------------------------------------

local function AcceptTest(inst, item)
	return inst.pendingreward == nil
		and inst.stock > 0
		and item:HasTag("oceanfish")
		and item.components.weighable
		and item.components.weighable:GetWeight() >= 150
end

local function OnGivenItem(inst, giver, item)
	if item.components.weighable and item.components.weighable:GetWeightPercent() >= TUNING.WEIGHABLE_HEAVY_WEIGHT_PERCENT then
		inst.pendingreward = MAX_REWARDS
	else
		inst.pendingreward = MIN_REWARDS
	end
end

local function OnRefuseItem(inst, giver, item)
	local reason
	if inst.stock <= 0 then
		reason = "EMPTY"
	elseif item then
		reason = item:HasTag("oceanfish") and "TOO_SMALL" or "NOT_OCEANFISH"
	end
	inst:PushEvent("onrefuseitem", { giver = giver, reason = reason })
end

local function MakeTrader(inst)
	if inst.components.trader == nil then
		inst:AddComponent("trader")
		inst.components.trader:SetAcceptTest(AcceptTest)
		inst.components.trader.onaccept = OnGivenItem
		inst.components.trader.onrefuse = OnRefuseItem

		inst.stock = MAX_TRADES

		inst:AddTag("notarget")

		if inst:IsAsleep() and inst.sleeptask == nil then
			inst.sleeptask = inst:DoTaskInTime(OFFSCREEN_DESPAWN_DELAY, inst.Remove)
		end
	end
end

local function GiveReward(inst, target)
	if inst.pendingreward then
		if target and not target:IsValid() then
			target = nil
		end
		inst.stock = inst.stock - 1

		-- If we got a good item, give them a picture of ourselves, to remember.
		if inst.sketchgiven == nil and inst.pendingreward == MAX_REWARDS then
			inst.sketchgiven = true
			LaunchAt(SpawnPrefab("chesspiece_sharkboi_sketch"), inst, target, 1, 2, 1)
		end

		for i = 1, inst.pendingreward do
			LaunchAt(SpawnPrefab("bootleg"), inst, target, 1, 2, 1)
		end

		inst.SoundEmitter:PlaySound("dontstarve/common/dropGeneric")
		inst.pendingreward = nil
	end
end

local function EndTradeTalkTask(inst)
	inst._tradetalktask = nil
	inst.components.talker:StopIgnoringAll("trading")
end

local function SetIsTradingFlag(inst, flag, timeout)
	if inst._tradingtask then
		inst._tradingtask:Cancel()
		inst._tradingtask = nil
	end

	if flag then
		if not inst.trading then
			inst.trading = true
			inst._tradingtask = inst:DoTaskInTime(timeout, SetIsTradingFlag, false)

			--make sure talking is not suppressed when entering trading brain node
			if inst._tradetalktask then
				inst._tradetalktask:Cancel()
				EndTradeTalkTask(inst)
			end
		end
	elseif inst.trading then
		inst.trading = false

		--suppress talking for a few seconds after leaving the trading brain node
		if inst._tradetalktask then
			inst._tradetalktask:Cancel()
		else
			inst.components.talker:IgnoreAll("trading")
		end
		inst._tradetalktask = inst:DoTaskInTime(3, EndTradeTalkTask)
	end
end

--------------------------------------------------------------------------

local SKINTONE_SATURATION = 3
local SKINTONE_DESATURATION = 1 / SKINTONE_SATURATION
local SKINTONE_MIN_BRIGHTNESS = 0.8

local SKINTONE_EXCLUDE_SYMBOLS =
{
	"sharkboi_jaw",
	"sharkboi_cloak",
	"sharkboi_eye_white",
	"sharkboi_fin_middle_ice",
	"sharkboi_fin_back_ice",
	"sharkboi_tail_end_ice",
	"sharkboi_fin_ice",
	"ice_crack",
	"ice_ol",
}

local function InvertSymbolHue(inst, symbol)
	inst.AnimState:SetSymbolHue(symbol, -inst.hue)
	inst.AnimState:SetSymbolSaturation(symbol, SKINTONE_DESATURATION)
end

local function ResetSymbolHue(inst, symbol)
	inst.AnimState:SetSymbolHue(symbol, 0)
	inst.AnimState:SetSymbolSaturation(symbol, 1)
end

local function InvertSymbolBrightness(inst, symbol)
	inst.AnimState:SetSymbolBrightness(symbol, 1 / inst.brightness)
end

local function ResetSymbolBrightness(inst, symbol)
	inst.AnimState:SetSymbolBrightness(symbol, 1)
end

local function HasWarPaint(inst)
	return inst.brow and inst.brow >= 4 and inst.brow <= 7
end

local function RefreshWarPaintHue(inst)
	--don't want skintone to affect war paint style brows
	if inst.hue and HasWarPaint(inst) then
		InvertSymbolHue(inst, "sharkboi_scarHead")
		InvertSymbolHue(inst, "sharkboi_scarHead_centre")
	else
		ResetSymbolHue(inst, "sharkboi_scarHead")
		ResetSymbolHue(inst, "sharkboi_scarHead_centre")
	end
end

local function RefreshWarPaintBrightness(inst)
	--don't want skintone to affect war paint style brows
	if inst.brightness and HasWarPaint(inst) then
		InvertSymbolBrightness(inst, "sharkboi_scarHead")
		InvertSymbolBrightness(inst, "sharkboi_scarHead_centre")
	else
		ResetSymbolBrightness(inst, "sharkboi_scarHead")
		ResetSymbolBrightness(inst, "sharkboi_scarHead_centre")
	end
end

local function SetHue(inst, hue)
	if hue and hue > 0 and hue < 1 then
		if inst.hue ~= hue then
			inst.hue = hue
			inst.AnimState:SetHue(hue)
			inst.AnimState:SetSaturation(SKINTONE_SATURATION)
			--inverted hue/saturation for the symbols that we don't want affected
			for i, v in ipairs(SKINTONE_EXCLUDE_SYMBOLS) do
				InvertSymbolHue(inst, v)
			end
			RefreshWarPaintHue(inst)
		end
	elseif inst.hue then
		inst.hue = nil
		inst.AnimState:SetHue(0)
		inst.AnimState:SetSaturation(1)
		for i, v in ipairs(SKINTONE_EXCLUDE_SYMBOLS) do
			ResetSymbolHue(inst, v)
		end
		RefreshWarPaintHue(inst)
	end
end

local function SetBrightness(inst, brightness)
	if brightness and brightness < 1 then
		brightness = math.max(brightness, SKINTONE_MIN_BRIGHTNESS)
		if inst.brightness ~= brightness then
			inst.brightness = brightness
			inst.AnimState:SetBrightness(brightness)
			--inverted brightness for the symbols that we don't want affected
			for i, v in ipairs(SKINTONE_EXCLUDE_SYMBOLS) do
				InvertSymbolBrightness(inst, v)
			end
			RefreshWarPaintBrightness(inst)
		end
	elseif inst.brightness then
		inst.brightness = nil
		inst.AnimState:SetBrightness(1)
		for i, v in ipairs(SKINTONE_EXCLUDE_SYMBOLS) do
			ResetSymbolBrightness(inst, v)
		end
		RefreshWarPaintBrightness(inst)
	end
end

local function SetBrow(inst, brow)
	if brow and brow >= 1 and brow <= 8 then
		if inst.brow ~= brow then
			inst.brow = brow
			inst.AnimState:OverrideSymbol("sharkboi_scarHead", "sharkboi_build_brows", "sharkboi_scarHead_"..tostring(brow))
			inst.AnimState:OverrideSymbol("sharkboi_scarHead_centre", "sharkboi_build_brows", "sharkboi_scarHead_centre_"..tostring(brow))
			RefreshWarPaintHue(inst)
		end
	elseif inst.brow then
		inst.brow = nil
		inst.AnimState:ClearOverrideSymbol("sharkboi_scarHead")
		inst.AnimState:ClearOverrideSymbol("sharkboi_scarHead_centre")
		RefreshWarPaintHue(inst)
	end
end

local function SetMane(inst, mane)
	if mane == 1 or mane == 2 then
		if inst.mane ~= mane then
			inst.mane = mane
			inst.AnimState:OverrideSymbol("sharkboi_cloak", "sharkboi_build_manes", "sharkboi_cloak_"..tostring(mane))
		end
	elseif inst.mane then
		inst.mane = nil
		inst.AnimState:ClearOverrideSymbol("sharkboi_cloak")
	end
end

local VOICE_PATHS =
{
	"meta3/sharkboi/sharkboi_a/",
	"meta3/sharkboi/sharkboi_b/",
	"meta3/sharkboi/sharkboi_c/",
}

local function SetVoice(inst, voice)
	inst.voicepath = VOICE_PATHS[voice]
	if inst.voicepath then
		inst.voice = voice
	else
		inst.voice = nil
		inst.voicepath = "meta3/sharkboi/"
	end
end

local function OnSave(inst, data)
	data.hue = inst.hue
	data.brightness = inst.brightness
	data.brow = inst.brow
	data.mane = inst.mane
	data.voice = inst.voice
	data.aggro = inst:HasTag("hostile") or nil
	data.reward = inst.pendingreward or nil
	data.sketchgiven = inst.sketchgiven or nil
	if inst.stock and inst.stock < MAX_TRADES then
		data.stock = inst.stock
	end
end

local function OnLoad(inst, data)
	SetHue(inst, data and data.hue or nil)
	SetBrightness(inst, data and data.brightness or nil)
	SetBrow(inst, data and data.brow or nil)
	SetMane(inst, data and data.mane or nil)
	SetVoice(inst, data and data.voice or nil)

	if inst.components.health.currenthealth <= inst.components.health.minhealth then
		MakeTrader(inst)
		if data then
			if data.reward then
				inst.pendingreward = math.clamp(data.reward, MIN_REWARDS, MAX_REWARDS)
			end
			if data.stock and data.stock < MAX_TRADES then
				inst.stock = data.stock
			end

			if data.sketchgiven then
				inst.sketchgiven = data.sketchgiven
			end
		end
	elseif data and data.aggro then
		inst:StartAggro()
	end
end

local function OnEntitySleep(inst)
	StopAggro(inst)
	if inst.sg:HasAnyStateTag("fin", "digging", "busy") then
		inst.sg:GoToState("idle")
		if inst.components.health.currenthealth <= inst.components.health.minhealth then
			MakeTrader(inst)
		end
	end
	if inst.components.trader and inst.sleeptask == nil then
		inst.sleeptask = inst:DoTaskInTime(OFFSCREEN_DESPAWN_DELAY, inst.Remove)
	end
end

local function OnEntityWake(inst)
	if inst.sleeptask then
		inst.sleeptask:Cancel()
		inst.sleeptask = nil
	end
end

local function TrackFishingHole(inst, hole)
	if inst.hole then
		inst:RemoveEventCallback("onremove", inst._onremovehole, inst.hole)
		inst._onremovehole = nil
		inst.hole = nil
	end
	if hole then
		inst.hole = hole
		inst._onremovehole = function() inst.hole = nil end
		inst:ListenForEvent("onremove", inst._onremovehole, hole)
	end
end

--------------------------------------------------------------------------

local function PushMusic(inst)
	if ThePlayer == nil or not inst:HasTag("hostile") then
		inst._playingmusic = false
	else
		--client safe
		local sharkboimanagerhelper = TheWorld and TheWorld.net and TheWorld.net.components.sharkboimanagerhelper
		if sharkboimanagerhelper and sharkboimanagerhelper:IsPointInArena(inst.Transform:GetWorldPosition()) then
			if sharkboimanagerhelper:IsPointInArena(ThePlayer.Transform:GetWorldPosition()) then
				inst._playingmusic = true
				ThePlayer:PushEvent("triggeredevent", { name = "sharkboi" })
			else
				inst._playingmusic = false
			end
		elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
			inst._playingmusic = true
			ThePlayer:PushEvent("triggeredevent", { name = "sharkboi" })
		elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
			inst._playingmusic = false
		end
	end
end

--------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddDynamicShadow()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:SetPhysicsRadiusOverride(STANDING_RADIUS)
	MakeGiantCharacterPhysics(inst, STANDING_MASS, inst.physicsradiusoverride)
	inst.DynamicShadow:SetSize(3.5, 1.5)
	inst.Transform:SetFourFaced()

	inst:AddTag("scarytoprey")
	inst:AddTag("scarytooceanprey")
	inst:AddTag("monster")
	inst:AddTag("animal")
	inst:AddTag("largecreature")
	inst:AddTag("shark")
	inst:AddTag("wet")
	inst:AddTag("epic")
	inst:AddTag("noepicmusic") --add this when we have custom music!

	inst.no_wet_prefix = true

	--Sneak these into pristine state for optimization
	inst:AddTag("_named")

	inst.AnimState:SetBank("sharkboi")
	inst.AnimState:SetBuild("sharkboi_build")
	inst.AnimState:PlayAnimation("idle", true)

	local talker = inst:AddComponent("talker")
	talker.fontsize = 40
	talker.font = TALKINGFONT
	talker.colour = Vector3(unpack(WET_TEXT_COLOUR))
	talker.offset = Vector3(0, -400, 0)
	talker.symbol = "sharkboi_cloak"
	talker.name_colour = Vector3(131/256, 153/256, 172/256)
	talker.chaticon = "npcchatflair_sharkboi"
	talker:MakeChatter()

	inst.finmode = net_bool(inst.GUID, "sharkboi.finmode", "finmodedirty")

	inst.entity:SetPristine()

	--Dedicated server does not need to trigger music
	if not TheNet:IsDedicated() then
		inst._playingmusic = false
		inst:DoPeriodicTask(1, PushMusic, 0)
	end

	if not TheWorld.ismastersim then
		inst:ListenForEvent("finmodedirty", OnFinModeDirty)

		return inst
	end

	--Remove these tags so that they can be added properly when replicating components below
	inst:RemoveTag("_named")

	inst:AddComponent("named")
	inst.components.named.possiblenames = STRINGS.SHARKBOINAMES
	inst.components.named:PickNewName()

	SetHue(inst, 0)--math.random())
	SetBrightness(inst, 1)--1 - math.random() * (1  - SKINTONE_MIN_BRIGHTNESS))
	SetMane(inst, 0)--math.random(0, 2))
	SetBrow(inst, 0)--math.random(0, 8))
	SetVoice(inst, 0)--math.random(0, 3))

	inst:AddComponent("inspectable")

	inst.components.talker.ontalk = OnTalk

	--[[inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable("sharkboi")
	inst.components.lootdropper.min_speed = 1
	inst.components.lootdropper.max_speed = 3
	inst.components.lootdropper.y_speed = 14
	inst.components.lootdropper.y_speed_variance = 4
	inst.components.lootdropper.spawn_loot_inside_prefab = true]]

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(4)
	inst.components.sleeper:SetSleepTest(ShouldSleep)
	inst.components.sleeper:SetWakeTest(ShouldWake)
	inst.components.sleeper.diminishingreturns = true

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.SHARKBOI_WALKSPEED
	inst.components.locomotor.runspeed = TUNING.SHARKBOI_RUNSPEED

	inst:AddComponent("health")
	inst.components.health:SetMinHealth(1)
	inst.components.health:SetMaxHealth(TUNING.SHARKBOI_HEALTH)
	--inst.components.health.nofadeout = true

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.SHARKBOI_DAMAGE)
	inst.components.combat:SetAttackPeriod(TUNING.SHARKBOI_ATTACK_PERIOD)
	inst.components.combat.playerdamagepercent = .5
	inst.components.combat:SetRange(TUNING.SHARKBOI_MELEE_RANGE)
	inst.components.combat:SetRetargetFunction(3, RetargetFn)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	inst.components.combat.hiteffectsymbol = "sharkboi_torso"
	inst.components.combat.battlecryenabled = false
	inst.components.combat.forcefacing = false

	inst:AddComponent("timer")
	inst:AddComponent("grouptargeter")

	local teleportedoverride = inst:AddComponent("teleportedoverride")
    teleportedoverride:SetDestPositionFn(teleport_override_fn)

	MakeLargeFreezableCharacter(inst, "sharkboi_torso")
	inst.components.freezable:SetResistance(4)
	inst.components.freezable.diminishingreturns = true

	inst:SetStateGraph("SGsharkboi")
	inst:SetBrain(brain)

	inst:ListenForEvent("newstate", OnNewState)
	inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("killed", OnKilledOther)

	inst.trading = false
    inst.StartAggro = StartAggro
	inst.StopAggro = StopAggro
	inst.MakeTrader = MakeTrader
	inst.GiveReward = GiveReward
	inst.SetIsTradingFlag = SetIsTradingFlag
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
	inst.TrackFishingHole = TrackFishingHole

	return inst
end

return Prefab("sharkboi", fn, assets, prefabs)
