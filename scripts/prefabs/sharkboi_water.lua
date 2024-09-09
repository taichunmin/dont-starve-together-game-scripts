local assets =
{
	Asset("ANIM", "anim/sharkboi_build.zip"),
	Asset("ANIM", "anim/sharkboi_build_brows.zip"),
	Asset("ANIM", "anim/sharkboi_build_manes.zip"),
	Asset("ANIM", "anim/sharkboi_basic_water.zip"),
}

local prefabs =
{
	"wake_small",
}

local brain = require("brains/sharkboi_waterbrain")

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeGiantCharacterPhysics(inst, 1000, 1)
	inst.Transform:SetFourFaced()

	inst:AddTag("scarytoprey")
	inst:AddTag("scarytooceanprey")
	inst:AddTag("monster")
	inst:AddTag("animal")
	inst:AddTag("largecreature")
	inst:AddTag("shark")
	inst:AddTag("wet")
	inst:AddTag("epic")
	inst:AddTag("swimming")

	inst.no_wet_prefix = true

	--Sneak these into pristine state for optimization
	inst:AddTag("_named")

	inst.AnimState:SetBank("sharkboi_water")
	inst.AnimState:SetBuild("sharkboi_build")
	inst.AnimState:PlayAnimation("idle", true)

	inst:AddComponent("talker")
	inst.components.talker.fontsize = 40
	inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(unpack(WET_TEXT_COLOUR))
	inst.components.talker.offset = Vector3(0, -400, 0)
	inst.components.talker.symbol = "sharkboi_cloak"
	inst.components.talker:MakeChatter()

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	--Remove these tags so that they can be added properly when replicating components below
	inst:RemoveTag("_named")

	inst:AddComponent("named")
	inst.components.named.possiblenames = STRINGS.SHARKBOINAMES
	inst.components.named:PickNewName()

	inst:AddComponent("inspectable")

	--[[inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(4)
	inst.components.sleeper:SetSleepTest(ShouldSleep)
	inst.components.sleeper:SetWakeTest(ShouldWake)
	inst.components.sleeper.diminishingreturns = true]]

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.SHARKBOI_WATER_WALKSPEED
	inst.components.locomotor.runspeed = TUNING.SHARKBOI_WATER_RUNSPEED
	inst.components.locomotor.softstop = true
	inst.components.locomotor.pathcaps = { allowocean = true, ignoreLand = true }

	inst:SetStateGraph("SGsharkboi_water")
	inst:SetBrain(brain)

	return inst
end

return Prefab("sharkboi_water", fn, assets, prefabs)
