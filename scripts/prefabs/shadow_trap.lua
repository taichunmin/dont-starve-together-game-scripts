local assets =
{
	Asset("ANIM", "anim/shadow_trap.zip"),
	Asset("ANIM", "anim/mushroombomb_base.zip"),
}

local assets_fx =
{
	Asset("ANIM", "anim/shadow_trap_debuff.zip"),
}

local prefabs =
{
	"shadow_despawn",
	"shadow_glob_fx",
	"reticuleaoeshadowtarget_6",
	"ocean_splash_small1",
	"ocean_splash_small2",
	"shadow_pillar_base_fx",
	"shadow_trap_debuff_fx",
}

--V2C: decided not to use the "mine" component because we may be different enough

--------------------------------------------------------------------------

local TRAIL_TAGS = { "shadowtrail" }
local function TryFX(inst, offsets, map)
	local offs1, offs2, offs3 = unpack(offsets)
	while true do --should we limit number of tries?
		local offset = table.remove(offs1, math.random(#offs1))
		local x, y, z = inst.entity:LocalToWorldSpaceIncParent(offset:Get())
		table.insert(offs3, offset)
		if map:IsPassableAtPoint(x, 0, z, true) and not map:IsGroundTargetBlocked(Vector3(x, 0, z)) then
			if #TheSim:FindEntities(x, 0, z, .7, TRAIL_TAGS) <= 0 then
				local fx = SpawnPrefab("shadow_glob_fx")
				if map:IsOceanAtPoint(x, 0, z, true) then
					local platform = map:GetPlatformAtPoint(x, z)
					if platform ~= nil then
						fx.entity:SetParent(platform.entity)
						x, y, z = platform.entity:WorldToLocalSpace(x, 0, z)
					else
						fx:EnableRipples(true)
					end
				end
				fx.Transform:SetPosition(x, 0, z)
			end
			break
		elseif #offs1 <= 0 then
			if #offs2 > 0 then
				--Swap in page 2 offsets
				offsets[1] = offs2
				offsets[2] = offs1
				offs1 = offs2
				offs2 = offsets[2]
			else
				--Tried all offsets, none valid
				offsets[1] = offs3
				offsets[3] = offs1
				return
			end
		end
	end

	for i = 1, #offs3 do
		table.insert(offs2, offs3[i])
		offs3[i] = nil
	end
	if #offs1 <= 0 then
		offsets[1] = offs2
		offsets[2] = offs1
	end
end

local function EnableGroundFX(inst, enable)
	if enable then
		if inst.groundfxtask ~= nil then
			return
		end
		local angle = math.random() * PI2
		local offsets = {}
		for i = 2, 4 do
			local radius = (i - 1) * 1.7
			local count = i > 1 and i * i - 1 or 1
			local delta = PI2 / count
			for j = 1, count do
				angle = angle + delta
				table.insert(offsets, Vector3(math.cos(angle) * radius, 0, -math.sin(angle) * radius))
			end
			angle = angle + delta * .5
		end
		inst.groundfxtask = inst:DoPeriodicTask(FRAMES, TryFX, 0, { offsets, {}, {} }, TheWorld.Map)
	elseif inst.groundfxtask ~= nil then
		inst.groundfxtask:Cancel()
		inst.groundfxtask = nil
	end
end

--------------------------------------------------------------------------

local function EnableTargetFX(inst, enable)
	if enable then
		if inst.targetfx == nil then
			inst.targetfx = SpawnPrefab("reticuleaoeshadowtarget_6")
			inst.targetfx.entity:SetParent(inst.entity)
		end
	elseif inst.targetfx ~= nil then
		inst.targetfx:KillFX()
		inst.targetfx = nil
	end
end

--------------------------------------------------------------------------

local DETECT_RADIUS = 3
local DETECT_MUST_TAGS = { "locomotor" }
local DETECT_NO_TAGS = { "epic", "notraptrigger", "ghost", "player", "INLIMBO", "flight", "invisible", "notarget", "noattack", "bird", "butterfly" }
local DETECT_ONE_OF_TAGS = { "monster", "character", "animal", "smallcreature" }

local TARGET_RADIUS = 6
local TARGET_MUST_TAGS = nil
local TARGET_NO_TAGS = { "epic", "notraptrigger", "ghost", "player", "INLIMBO", "flight", "invisible", "notarget" }
local TARGET_ONE_OF_TAGS = DETECT_ONE_OF_TAGS

local function CanPanic(target)
	if target.components.hauntable ~= nil and target.components.hauntable.panicable or target.has_nightmare_state then
		return true
	end
end

local function EndSpeedMult(target)
	target._shadow_trap_task = nil
	target._shadow_trap_fx:KillFX()
	target._shadow_trap_fx = nil
	if target.components.locomotor ~= nil then
		target.components.locomotor:RemoveExternalSpeedMultiplier(target, "shadow_trap")
	end
end

local function TryTrapTarget(inst, targets)
	local x, y, z = inst.Transform:GetWorldPosition()
	for i, v in ipairs(TheSim:FindEntities(x, 0, z, TARGET_RADIUS, TARGET_MUST_TAGS, TARGET_NO_TAGS, TARGET_ONE_OF_TAGS)) do
		if not targets[v] and
			CanPanic(v) and
			not (v.components.health ~= nil and v.components.health:IsDead()) and
			v.entity:IsVisible()
			then
			targets[v] = true
			local x1, y1, z1 = v.Transform:GetWorldPosition()
			local fx = SpawnPrefab("shadow_despawn")
			local platform = v:GetCurrentPlatform()
			if platform ~= nil then
				fx.entity:SetParent(platform.entity)
				fx.Transform:SetPosition(platform.entity:WorldToLocalSpace(x1, y1, z1))
				fx:ListenForEvent("onremove", function()
					fx.Transform:SetPosition(fx.Transform:GetWorldPosition())
					fx.entity:SetParent(nil)
				end, platform)
			else
				fx.Transform:SetPosition(x1, y1, z1)
			end
			if v.has_nightmare_state then
				v:PushEvent("ms_forcenightmarestate", { duration = TUNING.SHADOW_TRAP_NIGHTMARE_TIME + math.random() })
			end
			if not (v.sg ~= nil and v.sg:HasStateTag("noattack")) then
				v:PushEvent("attacked", { attacker = nil, damage = 0 })
			end
			if not v.has_nightmare_state and v.components.hauntable ~= nil and v.components.hauntable.panicable then
				v.components.hauntable:Panic(TUNING.SHADOW_TRAP_PANIC_TIME)
				if v.components.locomotor ~= nil then
					if v._shadow_trap_task ~= nil then
						v._shadow_trap_task:Cancel()
					else
						v._shadow_trap_fx = SpawnPrefab("shadow_trap_debuff_fx")
						v._shadow_trap_fx.entity:SetParent(v.entity)
						v._shadow_trap_fx:OnSetTarget(v)
					end
					v._shadow_trap_task = v:DoTaskInTime(TUNING.SHADOW_TRAP_PANIC_TIME, EndSpeedMult)
					v.components.locomotor:SetExternalSpeedMultiplier(v, "shadow_trap", TUNING.SHADOW_TRAP_SPEED_MULT)
				end
			end
		end
	end
end

local function StopTask(inst, task)
	task:Cancel()
end

local function TriggerTrap(inst)
	if not inst.persists then
		return
	elseif not inst.sg:HasStateTag("activated") then
		if inst.task ~= nil then
			inst.task:Cancel()
			inst.task = nil
		end
		inst.sg:GoToState("activate")
		return
	end
	inst.persists = false
	inst:AddTag("NOBLOCK")
	local task = inst:DoPeriodicTask(.25, TryTrapTarget, 0, {})
	inst:DoTaskInTime(.75, StopTask, task)
	inst:DoTaskInTime(.5, EnableGroundFX, false)
	inst:DoTaskInTime(1.2 + 10 * FRAMES, inst.Remove) -- wait for target fx fadeout
end

local function DispellTrap(inst, collidewithboat)
	if not inst.persists then
		return
	elseif not inst.sg:HasStateTag("activated") then
		if inst:IsAsleep() then
			inst:Remove()
			return
		elseif inst.task ~= nil then
			inst.task:Cancel()
			inst.task = nil
		end
		inst.sg:GoToState("dispell", collidewithboat)
		inst.persists = false
		inst:AddTag("NOBLOCK")
	end
end

local function Detect(inst, map)
	if inst.sg:HasStateTag("activated") then
		inst.task:Cancel()
		inst.task = nil
	elseif inst.sg:HasStateTag("canactivate") and FindEntity(inst, DETECT_RADIUS, CanPanic, DETECT_MUST_TAGS, DETECT_NO_TAGS, DETECT_ONE_OF_TAGS) ~= nil then
		inst.task:Cancel()
		inst.task = nil
		inst.sg:GoToState("activate")
	elseif inst:HasTag("ignorewalkableplatforms") and map:GetPlatformAtPoint(inst.Transform:GetWorldPosition()) ~= nil then
		DispellTrap(inst, true)
	elseif inst.sg:HasStateTag("candetect") then
		if FindEntity(inst, TARGET_RADIUS, CanPanic, DETECT_MUST_TAGS, DETECT_NO_TAGS, DETECT_ONE_OF_TAGS) ~= nil then
			if not inst.sg:HasStateTag("near") then
				inst.sg:GoToState("near_idle_pre")
			end
		elseif inst.sg:HasStateTag("near") then
			inst.sg:GoToState("near_idle_pst")
		end
	end
end

local function OnTimerDone(inst, data)
	if data ~= nil and data.name == "lifetime" then
		DispellTrap(inst)
	end
end

local function OnWake(inst)
	if inst.task == nil and not inst.sg:HasStateTag("activated") then
		inst.task = inst:DoPeriodicTask(.1, Detect, math.random() * .1, TheWorld.Map)
	end
end

local function OnSleep(inst)
	if inst.task ~= nil then
		inst.task:Cancel()
		inst.task = nil
	end
end

local function OnLoad(inst)
	inst.sg:GoToState("idle", true) --true to randomize
	inst.base.Transform:SetRotation(math.random() * 360)
	inst.base.AnimState:PlayAnimation("idle", true)
	inst.base.AnimState:SetFrame(math.random(inst.base.AnimState:GetCurrentAnimationNumFrames()) - 1)
end

local function OnShockwave(inst)
	local fx = CreateEntity()

	fx:AddTag("FX")
	--[[Non-networked entity]]
	--fx.entity:SetCanSleep(false)
	fx.persists = false

	fx.entity:AddTransform()
	fx.entity:AddAnimState()

	fx.AnimState:SetBank("mushroombomb_base")
	fx.AnimState:SetBuild("mushroombomb_base")
	fx.AnimState:PlayAnimation("idle")
	fx.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	fx.AnimState:SetLayer(LAYER_BACKGROUND)
	fx.AnimState:SetSortOrder(3)
	fx.AnimState:SetFinalOffset(3)
	fx.AnimState:SetScale(1.9, 1.9)
	fx.AnimState:SetMultColour(0, 0, 0, .5)

	fx:ListenForEvent("animover", fx.Remove)

	fx.entity:SetParent(inst.entity)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("ignorewalkableplatforms")
	inst:AddTag("ignorewalkableplatformdrowning")

	inst.AnimState:SetBank("shadow_trap")
	inst.AnimState:SetBuild("shadow_trap")
	inst.AnimState:PlayAnimation("spawn")

	inst.shockwave = net_event(inst.GUID, "shadow_trap.shockwave")

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		inst:ListenForEvent("shadow_trap.shockwave", OnShockwave)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.base = SpawnPrefab("shadow_pillar_base_fx")
	inst.base.entity:SetParent(inst.entity)
	inst.base.Transform:SetScale(.7, .7, .7)
	inst.base.Transform:SetRotation(math.random() * 360)

	inst:AddComponent("timer")
	inst.components.timer:StartTimer("lifetime", TUNING.SHADOW_TRAP_LIFETIME)

	inst:ListenForEvent("timerdone", OnTimerDone)
	inst:ListenForEvent("onsink", DispellTrap)

	inst:SetStateGraph("SGshadow_trap")

	inst.EnableGroundFX = EnableGroundFX
	inst.EnableTargetFX = EnableTargetFX
	inst.TriggerTrap = TriggerTrap

	inst.OnEntitySleep = OnSleep
	inst.OnEntityWake = OnWake
	inst.OnLoad = OnLoad

	return inst
end

local function KillFX(inst)
	if inst:IsAsleep() then
		inst:Remove()
	elseif not inst.killed then
		inst.killed = true
		inst.AnimState:PlayAnimation("debuff_pst_"..(inst.size or "medium"))
		inst:ListenForEvent("animover", inst.Remove)
	end
end

local function OnSetTarget(inst, target)
	if target:HasTag("smallcreature") then
		inst.size = "small"
	elseif target:HasTag("largecreature") then
		inst.size = "large"
	end
	if inst.size ~= nil then
		inst.AnimState:PlayAnimation("debuff_pre_"..inst.size)
		inst.AnimState:PushAnimation("debuff_loop_"..inst.size)
	end

	inst:ListenForEvent("death", function()
		inst:KillFX()
	end, target)
	inst:ListenForEvent("onremove", function()
		local x, y, z = inst.Transform:GetWorldPosition()
		inst.entity:SetParent(nil)
		inst.Transform:SetPosition(x, y, z)
		inst:KillFX()
	end, target)
end

local function fxfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("NOCLICK")
	--inst:AddTag("FX")
	inst:AddTag("CLASSIFIED") --unfortunately, in DST, "FX" still makes it mouseover when parented

	inst.AnimState:SetBank("shadow_trap_debuff")
	inst.AnimState:SetBuild("shadow_trap_debuff")
	inst.AnimState:PlayAnimation("debuff_pre_medium")
	inst.AnimState:SetMultColour(1, 1, 1, .5)
	inst.AnimState:SetFinalOffset(7)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.AnimState:PushAnimation("debuff_loop_medium")

	inst.OnSetTarget = OnSetTarget
	inst.KillFX = KillFX
	inst.persists = false

	return inst
end

return Prefab("shadow_trap", fn, assets, prefabs),
	Prefab("shadow_trap_debuff_fx", fxfn, assets_fx)
