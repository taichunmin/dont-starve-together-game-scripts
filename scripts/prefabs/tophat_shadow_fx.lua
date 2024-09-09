local assets =
{
	Asset("ANIM", "anim/tophat_fx.zip"),
}

--------------------------------------------------------------------------

local function shadow_particle_onanimover(inst)
	if inst.pool.invalid then
		inst:Remove()
	else
		inst:Hide()
		table.insert(inst.pool, inst)
	end
end

local function shadow_releasesparticle(inst)
	inst.Follower:StopFollowing()
end

local function shadow_spawnparticles(base, name, front, x_scale, y_scale)
	local parent = base
	repeat
		if not parent.entity:IsVisible() then
			return
		end
		parent = parent.entity:GetParent()
	until parent == nil

	local inst
	if #base.pool > 0 then
		inst = table.remove(base.pool)
		inst:Show()
	else
		inst = CreateEntity()

		inst:AddTag("NOCLICK")
		inst:AddTag("FX")
		--[[Non-networked entity]]
		--inst.entity:SetCanSleep(false)
		if TheNet:GetIsClient() then
			inst.entity:AddClientSleepable()
		end
		inst.persists = false

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddFollower()

		inst.AnimState:SetBank("tophat_fx")
		inst.AnimState:SetBuild("tophat_fx")
		inst.AnimState:SetMultColour(1, 1, 1, .5)

		inst.pool = base.pool
		inst:ListenForEvent("animover", shadow_particle_onanimover)
	end

	inst.AnimState:PlayAnimation("particle_"..name)
	inst.AnimState:SetFinalOffset(front and 1 or -1)
	inst.AnimState:SetScale(x_scale, y_scale)

	inst.Follower:FollowSymbol(base.GUID, front and "swap_front" or "swap_back", 0, 0, 0)

	inst:DoTaskInTime(0, shadow_releasesparticle)
end

local function shadow_spawnpartciels_atframe(inst, frame, name, front, x_scale, y_scale)
	if frame >= 0 then
		inst:DoTaskInTime(frame * FRAMES, shadow_spawnparticles, name, front, x_scale, y_scale)
	end
end

local function shadow_fxfrontloop(inst, frame)
	frame = frame or 0
	inst.AnimState:PlayAnimation("hatfx")
	inst.AnimState:SetFrame(frame)
	shadow_spawnpartciels_atframe(inst, 13 - frame, "top", true, 1.34, 1)
	shadow_spawnpartciels_atframe(inst, 15 - frame, "mid", true, 1.34, 1)
	shadow_spawnpartciels_atframe(inst, 17 - frame, "btm", true, 1.34, 1)
	shadow_spawnpartciels_atframe(inst, 27 - frame, "top", true, 1.22, 1.36)
	shadow_spawnpartciels_atframe(inst, 29 - frame, "mid", true, 1.22, 1.36)
	shadow_spawnpartciels_atframe(inst, 31 - frame, "btm", true, 1.22, 1.36)
end

local function shadow_fxbackloop(inst, frame)
	frame = frame or 0
	inst.AnimState:PlayAnimation("hatfx")
	inst.AnimState:SetFrame(frame)
	shadow_spawnpartciels_atframe(inst, 9 - frame, "top", false, -1.09, 1.16)
	shadow_spawnpartciels_atframe(inst, 11 - frame, "mid", false, -1.09, 1.16)
	shadow_spawnpartciels_atframe(inst, 13 - frame, "btm", false, -1.09, 1.16)
	shadow_spawnpartciels_atframe(inst, 23 - frame, "top", false, -1.09, 1.49)
	shadow_spawnpartciels_atframe(inst, 25 - frame, "mid", false, -1.09, 1.49)
	shadow_spawnpartciels_atframe(inst, 27 - frame, "btm", false, -1.09, 1.49)
end

local function shadow_onremoveentity(inst)
	for i, v in ipairs(inst.pool) do
		v:Remove()
	end
	inst.pool.invalid = true
end

local function shadow_createfx(front, frame)
	local inst = CreateEntity()

	inst:AddTag("NOCLICK")
	--inst:AddTag("FX")
	inst:AddTag("CLASSIFIED") --unfortunately, in DST, "FX" still makes it mouseover when parented
	--[[Non-networked entity]]
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("tophat_fx")
	inst.AnimState:SetBuild("tophat_fx")
	inst.AnimState:SetMultColour(1, 1, 1, .5)

	inst.pool = {}

	if front then
		inst.AnimState:Hide("back")
		inst.AnimState:SetFinalOffset(1)
		inst:ListenForEvent("animover", shadow_fxfrontloop)
		shadow_fxfrontloop(inst, frame)
	else
		inst.AnimState:Hide("front")
		inst.AnimState:SetFinalOffset(-1)
		inst:ListenForEvent("animover", shadow_fxbackloop)
		shadow_fxbackloop(inst, frame)
	end

	inst.OnRemoveEntity = shadow_onremoveentity

	return inst
end

local function shadow_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	--Dedicated server does not need to spawn the local fx
	if not TheNet:IsDedicated() then
		local frame = math.random(32) - 1
		shadow_createfx(true, frame).entity:SetParent(inst.entity)
		shadow_createfx(false, frame).entity:SetParent(inst.entity)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	return inst
end

--------------------------------------------------------------------------

local function swirl_attachfn(inst, owner, front)
	if owner.components.rider ~= nil and owner.components.rider:IsRiding() then
		inst.Transform:SetSixFaced()
	end
	inst.entity:SetParent(owner.entity)
	if front then
		inst.Follower:FollowSymbol(owner.GUID, "swap_tophat_swirl_front", 0, 0, 0, true)
	else
		inst.AnimState:PlayAnimation("swirl_back", true)
		inst.Follower:FollowSymbol(owner.GUID, "swap_tophat_swirl_back", 0, 0, 0, true)
	end
end

local function swirl_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	--inst:AddTag("FX")
	inst:AddTag("CLASSIFIED") --unfortunately, in DST, "FX" still makes it mouseover when parented
	inst:AddTag("NOCLICK")

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("tophat_fx")
	inst.AnimState:SetBuild("tophat_fx")
	inst.AnimState:PlayAnimation("swirl_front", true)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.AttachToTopHatUser = swirl_attachfn

	inst.persists = false

	return inst
end

--------------------------------------------------------------------------

local function using_shadow_attachfn(inst, owner, front)
	if owner.components.rider ~= nil and owner.components.rider:IsRiding() then
		inst.Transform:SetSixFaced()
	end
	inst.entity:SetParent(owner.entity)
	inst.Follower:FollowSymbol(owner.GUID, "swap_fx_particles_using_tophat", 0, 0, 0, true)
end

local function using_shadow_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.entity:AddNetwork()

	--inst:AddTag("FX")
	inst:AddTag("CLASSIFIED") --unfortunately, in DST, "FX" still makes it mouseover when parented
	inst:AddTag("NOCLICK")

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("tophat_fx")
	inst.AnimState:SetBuild("tophat_fx")
	inst.AnimState:SetMultColour(1, 1, 1, .5)
	inst.AnimState:PlayAnimation("using_particles", true)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.AttachToTopHatUser = using_shadow_attachfn

	inst.persists = false

	return inst
end

--------------------------------------------------------------------------

return Prefab("tophat_shadow_fx", shadow_fn, assets),
	Prefab("tophat_swirl_fx", swirl_fn, assets),
	Prefab("tophat_using_shadow_fx", using_shadow_fn, assets)
