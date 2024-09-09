local assets =
{
	Asset("ANIM", "anim/vine_bridge.zip"),
}

local prefabs =
{
	"vine_bridge_decor_fx",
}

local NUM_BRIDGE_VARIATIONS = 3
local NUM_DECOR_VARIATIONS = 3

local function SpawnDecor(inst, index)
	local decor = SpawnPrefab("vine_bridge_decor_fx")
	decor.entity:SetParent(inst.entity)
	decor.Transform:SetPosition(4 * math.random() - 2, 0, 4 * math.random() - 2)
	inst.decor[index] = decor
	return decor
end

local function SkipPre(inst)
	inst.AnimState:PlayAnimation("bridge"..tostring(inst.variation).."_idle", true)
	inst.AnimState:SetFrame(math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1)
	for i, v in ipairs(inst.decor) do
		if not v:is_a(EntityScript) then
			v:Cancel()
			v = SpawnDecor(inst, i)
		end
		v.AnimState:PlayAnimation("extra_"..tostring(v.variation).."_idle", true)
		v.AnimState:SetFrame(math.random(v.AnimState:GetCurrentAnimationNumFrames()) - 1)
	end

	if inst.soundtask then
		inst.soundtask:Cancel()
		inst.soundtask = nil
	end
end

local function KillFX(inst)
	inst.AnimState:PlayAnimation("bridge"..tostring(inst.variation).."_pst")
	inst:ListenForEvent("animover", inst.Remove)
	for i, v in ipairs(inst.decor) do
		if v:is_a(EntityScript) then
			v.AnimState:PlayAnimation("extra_"..tostring(v.variation).."_pst")
		else
			v:Cancel()
		end
	end

	inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:PlaySound("meta4/charlie_residue/vine_bridge_pst")
end

local function StartSound(inst)
	inst.soundtask = nil
	inst.SoundEmitter:PlaySound("meta4/charlie_residue/vine_bridge_pre")
end

local function ShakeIt(inst)
	inst.AnimState:PlayAnimation("bridge"..tostring(inst.variation).."_shake", true)
	for i, v in ipairs(inst.decor) do
		if v:is_a(EntityScript) then
			v.AnimState:PlayAnimation("extra_"..tostring(v.variation).."_shake", true)
		end
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.AnimState:SetBank("vine_bridge")
	inst.AnimState:SetBuild("vine_bridge")
	inst.AnimState:PlayAnimation("bridge1_pre")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(1)

	inst.SoundEmitter:PlaySound("meta4/charlie_residue/vine_bridge_lp", "loop")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.animbase = "bridge"
	inst.variation = math.random(NUM_BRIDGE_VARIATIONS)
	if inst.variation ~= 1 then
		inst.AnimState:PlayAnimation("bridge"..tostring(inst.variation).."_pre")
	end
	inst.AnimState:PushAnimation("bridge"..tostring(inst.variation).."_idle")

	inst.persists = false

	inst.decor = {}
	for i = 1, math.random(4, 6) do
		table.insert(inst.decor, inst:DoTaskInTime(0.9 + math.random() * 0.2, SpawnDecor, i))
	end

	inst.soundtask = inst:DoTaskInTime(0, StartSound)

	inst.SkipPre = SkipPre
	inst.KillFX = KillFX
    inst.ShakeIt = ShakeIt

	return inst
end

--------------------------------------------------------------------------

local function decorfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("DECOR")

	inst.AnimState:SetBank("vine_bridge")
	inst.AnimState:SetBuild("vine_bridge")
	inst.AnimState:PlayAnimation("extra_1_pre")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.animbase = "extra_"
	inst.variation = math.random(NUM_DECOR_VARIATIONS)
	if inst.variation ~= 1 then
		inst.AnimState:PlayAnimation("extra_"..tostring(inst.variation).."_pre")
	end
	inst.AnimState:PushAnimation("extra_"..tostring(inst.variation).."_idle")

	if math.random() < 0.5 then
		inst.AnimState:SetScale(-1, 1)
	end

	inst.persists = false

	return inst
end

return Prefab("vine_bridge_fx", fn, assets, prefabs),
	Prefab("vine_bridge_decor_fx", decorfn, assets)
