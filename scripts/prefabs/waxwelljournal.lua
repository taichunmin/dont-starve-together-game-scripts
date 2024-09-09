local assets =
{
	Asset("ANIM", "anim/book_maxwell.zip"),
	Asset("INV_IMAGE", "waxwelljournal_open"),

	Asset("ATLAS", "images/spell_icons.xml"),
	Asset("IMAGE", "images/spell_icons.tex"),
}

local prefabs =
{
	"shadow_pillar_spell",
	"reticuleaoe",
	"reticuleaoeping",
	"reticuleaoecctarget",

	"shadow_trap",
	"reticuleaoe_1_6",
	"reticuleaoeping_1_6",
	"reticuleaoesummontarget_1",

	"shadowworker",
	"shadowprotector",
	"reticuleaoe_1d2_12",
	"reticuleaoeping_1d2_12",
	"reticuleaoesummontarget_1d2",
}

local IDLE_SOUND_VOLUME = .5

--------------------------------------------------------------------------

local function SpellCost(pct)
	return pct * TUNING.LARGE_FUEL * -4
end

local function PillarsSpellFn(inst, doer, pos)
	if inst.components.fueled:IsEmpty() then
		return false, "NO_FUEL"
	end
	local spell = SpawnPrefab("shadow_pillar_spell")
	spell.caster = doer
	spell.item = inst
	local platform = TheWorld.Map:GetPlatformAtPoint(pos.x, pos.z)
	if platform ~= nil then
		spell.entity:SetParent(platform.entity)
		spell.Transform:SetPosition(platform.entity:WorldToLocalSpace(pos:Get()))
	else
		spell.Transform:SetPosition(pos:Get())
	end
	inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_PILLARS), doer)
	doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
	return true
end

local function TrapSpellFn(inst, doer, pos)
	if inst.components.fueled:IsEmpty() then
		return false, "NO_FUEL"
	end
	local trap = SpawnPrefab("shadow_trap")
	trap.Transform:SetPosition(pos:Get())
	if TheWorld.Map:GetPlatformAtPoint(pos.x, pos.z) ~= nil then
		trap:RemoveTag("ignorewalkableplatforms")
	end
	inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_TRAP), doer)
	doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
	return true
end

local function NotBlocked(pt)
	return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local function FindSpawnPoints(doer, pos, num, radius)
	local ret = {}
	local theta, delta, attempts
	if num > 1 then
		delta = TWOPI / num
		attempts = 3
		theta = doer:GetAngleToPoint(pos) * DEGREES
		if num == 2 then
			theta = theta + PI * (math.random() < .5 and .5 or -.5)
		else
			theta = theta + PI
			if math.random() < .5 then
				delta = -delta
			end
		end
	else
		theta = 0
		delta = 0
		attempts = 1
		radius = 0
	end
	for i = 1, num do
		local offset = FindWalkableOffset(pos, theta, radius, attempts, false, false, NotBlocked, true, true)
		if offset ~= nil then
			table.insert(ret, Vector3(pos.x + offset.x, 0, pos.z + offset.z))
		end
		theta = theta + delta
	end
	return ret
end

local NUM_MINIONS_PER_SPAWN = 1
local function TrySpawnMinions(prefab, doer, pos)
	if doer.components.petleash ~= nil then
		local spawnpts = FindSpawnPoints(doer, pos, NUM_MINIONS_PER_SPAWN, 1)
		if #spawnpts > 0 then
			for i, v in ipairs(spawnpts) do
				local pet = doer.components.petleash:SpawnPetAt(v.x, 0, v.z, prefab)
				if pet ~= nil then
					if pet.SaveSpawnPoint ~= nil then
						pet:SaveSpawnPoint()
					end
					if #spawnpts > 1 and i <= 3 then
						--restart "spawn" state with specified time multiplier
						pet.sg.statemem.spawn = true
						pet.sg:GoToState("spawn",
							(i == 1 and 1) or
							(i == 2 and .8) or
							.87 + math.random() * .06
						)
					end
				end
			end
			return true
		end
	end
	return false
end

local function _CheckMaxSanity(sanity, minionprefab)
	return sanity ~= nil and sanity:GetPenaltyPercent() + (TUNING.SHADOWWAXWELL_SANITY_PENALTY[string.upper(minionprefab)] or 0) * NUM_MINIONS_PER_SPAWN <= TUNING.MAXIMUM_SANITY_PENALTY
end

local function CheckMaxSanity(doer, minionprefab)
	return _CheckMaxSanity(doer.components.sanity, minionprefab)
end

local function ShouldRepeatCastWorker(inst, doer)
	return _CheckMaxSanity(doer.replica.sanity, "shadowworker")
end

local function ShouldRepeatCastProtector(inst, doer)
	return _CheckMaxSanity(doer.replica.sanity, "shadowprotector")
end

local function WorkerSpellFn(inst, doer, pos)
	if inst.components.fueled:IsEmpty() then
		return false, "NO_FUEL"
	elseif not CheckMaxSanity(doer, "shadowworker") then
		return false, "NO_MAX_SANITY"
	elseif TrySpawnMinions("shadowworker", doer, pos) then
		inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_WORKER), doer)
		return true
	end
	return false
end

local function ProtectorSpellFn(inst, doer, pos)
	if inst.components.fueled:IsEmpty() then
		return false, "NO_FUEL"
	elseif not CheckMaxSanity(doer, "shadowprotector") then
		return false, "NO_MAX_SANITY"
	elseif TrySpawnMinions("shadowprotector", doer, pos) then
		inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_PROTECTOR), doer)
		return true
	end
	return false
end

--[[local function IsTopHat(item)
	return item.prefab == "tophat" and item.components.magiciantool == nil
end

local function TopHatSpellFn(inst, doer)
	if inst.components.fueled:IsEmpty() then
		return false, "NO_FUEL"
	elseif doer.components.inventory ~= nil then
		local tophat = doer.components.inventory:FindItem(IsTopHat)
		if tophat == nil then
			return false, "NO_TOPHAT"
		elseif tophat.ConvertToMagician ~= nil then
			tophat:ConvertToMagician()
			if tophat.components.fueled ~= nil then
				tophat.components.fueled:SetPercent(1)
			end
			local container = tophat.components.inventoryitem:GetContainer()
			if container ~= nil then
				local slot = container:GetItemSlot(tophat)
				container:RemoveItem(tophat, true)
				container:GiveItem(tophat, slot, doer:GetPosition())
			end
			inst.components.fueled:DoDelta(SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_TOPHAT), doer)
			doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
			return true
		end
	end
	return false
end]]

--[[local function ReticuleTargetFn()
	local player = ThePlayer
	local ground = TheWorld.Map
	local pos = Vector3()
	--Cast range is 8, leave room for error
	--4 is the aoe range
	for r = 7, 0, -.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if ground:IsPassableAtPoint(pos.x, 0, pos.z) and not ground:IsGroundTargetBlocked(pos) then
			return pos
		end
	end
	return pos
end]]

local function ReticuleTargetAllowWaterFn()
	local player = ThePlayer
	local ground = TheWorld.Map
	local pos = Vector3()
	--Cast range is 8, leave room for error
	--4 is the aoe range
	for r = 7, 0, -.25 do
		pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
		if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
			return pos
		end
	end
	return pos
end

local function StartAOETargeting(inst)
	local playercontroller = ThePlayer.components.playercontroller
	if playercontroller ~= nil then
		playercontroller:StartAOETargetingUsing(inst)
	end
end

local ICON_SCALE = .6
local ICON_RADIUS = 50
local SPELLBOOK_RADIUS = 100
local SPELLBOOK_FOCUS_RADIUS = SPELLBOOK_RADIUS + 2
local SPELLS =
{
	{
		label = STRINGS.SPELLS.SHADOW_WORKER,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.SPELLS.SHADOW_WORKER)
			inst.components.aoetargeting:SetDeployRadius(0)
			inst.components.aoetargeting:SetShouldRepeatCastFn(ShouldRepeatCastWorker)
			inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1d2_12"
			inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1d2_12"
			if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX("reticuleaoesummontarget_1d2")
				inst.components.aoespell:SetSpellFn(WorkerSpellFn)
				inst.components.spellbook:SetSpellFn(nil)
			end
		end,
		execute = StartAOETargeting,
		atlas = "images/spell_icons.xml",
		normal = "shadow_worker.tex",
		widget_scale = ICON_SCALE,
		hit_radius = ICON_RADIUS,
	},
	{
		label = STRINGS.SPELLS.SHADOW_PROTECTOR,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.SPELLS.SHADOW_PROTECTOR)
			inst.components.aoetargeting:SetDeployRadius(0)
			inst.components.aoetargeting:SetShouldRepeatCastFn(ShouldRepeatCastProtector)
			inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1d2_12"
			inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1d2_12"
			if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX("reticuleaoesummontarget_1d2")
				inst.components.aoespell:SetSpellFn(ProtectorSpellFn)
				inst.components.spellbook:SetSpellFn(nil)
			end
		end,
		execute = StartAOETargeting,
		atlas = "images/spell_icons.xml",
		normal = "shadow_protector.tex",
		widget_scale = ICON_SCALE,
		hit_radius = ICON_RADIUS,
	},
	{
		label = STRINGS.SPELLS.SHADOW_TRAP,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.SPELLS.SHADOW_TRAP)
			inst.components.aoetargeting:SetDeployRadius(1)
			inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
			inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
			inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1_6"
			if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX("reticuleaoesummontarget_1")
				inst.components.aoespell:SetSpellFn(TrapSpellFn)
				inst.components.spellbook:SetSpellFn(nil)
			end
		end,
		execute = StartAOETargeting,
		atlas = "images/spell_icons.xml",
		normal = "shadow_trap.tex",
		widget_scale = ICON_SCALE,
		hit_radius = ICON_RADIUS,
	},
	{
		label = STRINGS.SPELLS.SHADOW_PILLARS,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.SPELLS.SHADOW_PILLARS)
			inst.components.aoetargeting:SetDeployRadius(0)
			inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
			inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
			inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
			if TheWorld.ismastersim then
				inst.components.aoetargeting:SetTargetFX("reticuleaoecctarget")
				inst.components.aoespell:SetSpellFn(PillarsSpellFn)
				inst.components.spellbook:SetSpellFn(nil)
			end
		end,
		execute = StartAOETargeting,
		atlas = "images/spell_icons.xml",
		normal = "shadow_pillars.tex",
		widget_scale = ICON_SCALE,
		hit_radius = ICON_RADIUS,
	},
	--[[{
		label = STRINGS.SPELLS.SHADOW_TOPHAT,
		onselect = function(inst)
			inst.components.spellbook:SetSpellName(STRINGS.SPELLS.SHADOW_TOPHAT)
			if TheWorld.ismastersim then
				inst.components.aoespell:SetSpellFn(nil)
				inst.components.spellbook:SetSpellFn(TopHatSpellFn)
			end
		end,
		execute = function(inst)
			local inventory = ThePlayer.replica.inventory
			if inventory ~= nil then
				inventory:CastSpellBookFromInv(inst)
			end
		end,
		atlas = "images/spell_icons.xml",
		normal = "shadow_tophat.tex",
		widget_scale = ICON_SCALE,
		hit_radius = ICON_RADIUS,
	},]]
}

local function OnOpenSpellBook(inst)
	local inventoryitem = inst.replica.inventoryitem
	if inventoryitem ~= nil then
		inventoryitem:OverrideImage("waxwelljournal_open")
	end
end

local function OnCloseSpellBook(inst)
	local inventoryitem = inst.replica.inventoryitem
	if inventoryitem ~= nil then
		inventoryitem:OverrideImage(nil)
	end
end

local function GetStatus(inst, viewer)
	return inst.components.fueled:IsEmpty()
		and inst.components.spellbook:CanBeUsedBy(viewer)
		and "NEEDSFUEL"
		or nil
end

--------------------------------------------------------------------------

local function tryplaysound(inst, id, sound)
	inst._soundtasks[id] = nil
	if inst.AnimState:IsCurrentAnimation("proximity_pst") then
		inst.SoundEmitter:PlaySound(sound)
	end
end

local function trykillsound(inst, id, sound)
	inst._soundtasks[id] = nil
	if inst.AnimState:IsCurrentAnimation("proximity_pst") then
		inst.SoundEmitter:KillSound(sound)
	end
end

local function queueplaysound(inst, delay, id, sound)
	if inst._soundtasks[id] ~= nil then
		inst._soundtasks[id]:Cancel()
	end
	inst._soundtasks[id] = inst:DoTaskInTime(delay, tryplaysound, id, sound)
end

local function queuekillsound(inst, delay, id, sound)
	if inst._soundtasks[id] ~= nil then
		inst._soundtasks[id]:Cancel()
	end
	inst._soundtasks[id] = inst:DoTaskInTime(delay, trykillsound, id, sound)
end

local function tryqueueclosingsounds(inst, onanimover)
	inst._soundtasks.animover = nil
	if inst.AnimState:IsCurrentAnimation("proximity_pst") then
		inst:RemoveEventCallback("animover", onanimover)
		--Delay one less frame, since this task is delayed one frame already
		queueplaysound(inst, 4 * FRAMES, "close", "dontstarve/common/together/book_maxwell/close")
		queuekillsound(inst, 5 * FRAMES, "killidle", "idlesound")
		queueplaysound(inst, 14 * FRAMES, "drop", "dontstarve/common/together/book_maxwell/drop")
	end
end

local function onanimover(inst)
	if inst._soundtasks.animover ~= nil then
		inst._soundtasks.animover:Cancel()
	end
	inst._soundtasks.animover = inst:DoTaskInTime(FRAMES, tryqueueclosingsounds, onanimover)
end

local function stopclosingsounds(inst)
	inst:RemoveEventCallback("animover", onanimover)
	for k, v in pairs(inst._soundtasks) do
		v:Cancel()
		inst._soundtasks[k] = nil
	end
end

local function startclosingsounds(inst)
	stopclosingsounds(inst)
	inst:ListenForEvent("animover", onanimover)
	onanimover(inst)
end

local function onturnon(inst)
	if inst.isfloating then
		return
	end
	inst.isfloating = true
	if inst._activetask ~= nil then
		return
	end
	stopclosingsounds(inst)
	if inst.AnimState:IsCurrentAnimation("proximity_loop") then
		--In case other animations were still in queue
		local t = inst.AnimState:GetCurrentAnimationTime()
		inst.AnimState:PlayAnimation("proximity_loop", true)
		inst.AnimState:SetTime(t)
	else
		inst.AnimState:PlayAnimation("proximity_pre")
		inst.AnimState:PushAnimation("proximity_loop", true)
	end
	if not inst.SoundEmitter:PlayingSound("idlesound") then
		inst.SoundEmitter:PlaySound("dontstarve/common/together/book_maxwell/active_LP", "idlesound")
		inst.SoundEmitter:SetVolume("idlesound", IDLE_SOUND_VOLUME)
	end
end

local function onturnoff(inst, instant)
	if instant then
		inst.AnimState:PlayAnimation("idle")
		inst.SoundEmitter:KillSound("idlesound")
		stopclosingsounds(inst)
		inst.isfloating = nil
		if inst._activetask ~= nil then
			inst._activetask:Cancel()
			inst._activetask = nil
		end
		return
	elseif not inst.isfloating then
		return
	end
	inst.isfloating = nil
	if inst._activetask ~= nil then
		return
	end
	inst.AnimState:PushAnimation("proximity_pst")
	inst.AnimState:PushAnimation("idle", false)
	startclosingsounds(inst)
end

local function IsPlayerInRange(inst, range)
	local x, y, z = inst.Transform:GetWorldPosition()
	local closestdsq = math.huge
	range = range * range
	for i, v in ipairs(AllPlayers) do
		if v:HasTag("shadowmagic") and not (v.components.health:IsDead() or v:HasTag("playerghost")) then
			local dsq = v:GetDistanceSqToPoint(x, y, z)
			if dsq < range then
				return true
			elseif dsq < closestdsq then
				closestdsq = dsq
			end
		end
	end
	return false, closestdsq
end

local function UpdateFloatNear(inst, farfn)
	local isnear, closestdsq = IsPlayerInRange(inst, inst.isfloating and 3 or 2)
	if isnear then
		onturnon(inst)
	else
		onturnoff(inst)
		if closestdsq >= 100 then
			--switch to slower task period
			inst._floattask:Cancel()
			inst._floattask = inst:DoPeriodicTask(1, farfn)
		end
	end
end

local function UpdateFloatFar(inst)
	if IsPlayerInRange(inst, 8) then
		--switch to faster task period
		inst._floattask:Cancel()
		inst._floattask = inst:DoPeriodicTask(.1, UpdateFloatNear, .5, UpdateFloatFar)
	end
end

local function OnEntitySleep(inst)
	if inst._floattask ~= nil then
		inst._floattask:Cancel()
		inst._floattask = nil
	end
	onturnoff(inst, true)
end

local function OnEntityWake(inst)
	if inst._floattask == nil and not (inst.components.inventoryitem:IsHeld() or inst.components.fueled:IsEmpty() or inst:IsAsleep()) then
		inst._floattask = inst:DoPeriodicTask(.1, UpdateFloatNear, 0, UpdateFloatFar)
	end
end

local function doneact(inst)
	inst._activetask = nil
	if inst.isfloating then
		inst.AnimState:PlayAnimation("proximity_loop", true)
		if not inst.SoundEmitter:PlayingSound("idlesound") then
			inst.SoundEmitter:PlaySound("dontstarve/common/together/book_maxwell/active_LP", "idlesound")
			inst.SoundEmitter:SetVolume("idlesound", IDLE_SOUND_VOLUME)
		end
	else
		inst.AnimState:PushAnimation("proximity_pst")
		inst.AnimState:PushAnimation("idle", false)
		startclosingsounds(inst)
	end
end

local function onuse(inst, hasfx)
	stopclosingsounds(inst)
	inst.AnimState:PlayAnimation("use")
	if hasfx then
		inst.AnimState:Show("FX")
	else
		inst.AnimState:Hide("FX")
	end
	inst.SoundEmitter:PlaySound("dontstarve/common/together/book_maxwell/use")
	if inst._activetask ~= nil then
		inst._activetask:Cancel()
	end
	inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), doneact)
end

local function CLIENT_PlayFuelSound(inst)
	local parent = inst.entity:GetParent()
	local container = parent ~= nil and (parent.replica.inventory or parent.replica.container) or nil
	if container ~= nil and container:IsOpenedBy(ThePlayer) then
		TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	end
end

local function SERVER_PlayFuelSound(inst)
	if not inst.components.inventoryitem:IsHeld() then
		inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
	else
		inst.playfuelsound:push()
		--Dedicated server does not need to trigger sfx
		if not TheNet:IsDedicated() then
			CLIENT_PlayFuelSound(inst)
		end
	end
end

local function OnTakeFuel(inst)
	SERVER_PlayFuelSound(inst)
	if inst.isfloating then
		onuse(inst, true)
	end
	OnEntityWake(inst)
end

local function OnFuelDepleted(inst)
	if inst._floattask ~= nil then
		inst._floattask:Cancel()
		inst._floattask = nil
		onturnoff(inst)
	end
end

local topocket = OnEntitySleep
local toground = OnEntityWake

--------------------------------------------------------------------------

local function OnHaunt(inst, haunter)
	if inst.isfloating then
		onuse(inst, false)
	else
		Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
	end
	inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
	return true
end

--------------------------------------------------------------------------

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("book_maxwell")
	inst.AnimState:SetBuild("book_maxwell")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("book")
	inst:AddTag("shadowmagic")

	MakeInventoryFloatable(inst, "med", nil, 0.75)

	inst:AddComponent("spellbook")
	inst.components.spellbook:SetRequiredTag("shadowmagic")
	inst.components.spellbook:SetRadius(SPELLBOOK_RADIUS)
	inst.components.spellbook:SetFocusRadius(SPELLBOOK_FOCUS_RADIUS)
	inst.components.spellbook:SetItems(SPELLS)
	inst.components.spellbook:SetOnOpenFn(OnOpenSpellBook)
	inst.components.spellbook:SetOnCloseFn(OnCloseSpellBook)
	inst.components.spellbook.opensound = "dontstarve/common/together/book_maxwell/use"
	inst.components.spellbook.closesound = "dontstarve/common/together/book_maxwell/close"
	--inst.components.spellbook.executesound = "dontstarve/common/together/book_maxwell/close"

	inst:AddComponent("aoetargeting")
	inst.components.aoetargeting:SetAllowWater(true)
	inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
	inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
	inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
	inst.components.aoetargeting.reticule.ease = true
	inst.components.aoetargeting.reticule.mouseenabled = true
	inst.components.aoetargeting.reticule.twinstickmode = 1
	inst.components.aoetargeting.reticule.twinstickrange = 8

	inst.playfuelsound = net_event(inst.GUID, "waxwelljournal.playfuelsound")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		--delayed because we don't want any old events
		inst:DoTaskInTime(0, inst.ListenForEvent, "waxwelljournal.playfuelsound", CLIENT_PlayFuelSound)

		return inst
	end

	inst.scrapbook_fueled_rate = SpellCost(TUNING.WAXWELLJOURNAL_SPELL_COST.SHADOW_PILLARS)
	inst.scrapbook_fueled_uses = true

	inst.swap_build = "book_maxwell"

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("inventoryitem")

	inst:AddComponent("fueled")
	inst.components.fueled.accepting = true
	inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE
	inst.components.fueled:SetTakeFuelFn(OnTakeFuel)
	inst.components.fueled:SetDepletedFn(OnFuelDepleted)
	inst.components.fueled:InitializeFuelLevel(TUNING.LARGE_FUEL * 4)

	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.MED_FUEL

	inst:AddComponent("aoespell")

	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
	MakeSmallPropagator(inst)

	inst:AddComponent("hauntable")
	inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
	inst.components.hauntable:SetOnHauntFn(OnHaunt)

	inst._activetask = nil
	inst._soundtasks = {}
	inst:ListenForEvent("onputininventory", topocket)
	inst:ListenForEvent("ondropped", toground)
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

	inst.castsound = "maxwell_rework/shadow_magic/cast"

	return inst
end

return Prefab("waxwelljournal", fn, assets, prefabs)
