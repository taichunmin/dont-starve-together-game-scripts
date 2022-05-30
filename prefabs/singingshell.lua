local prefabs =
{
	"slurtle_shellpieces",
	"singingshell_critterfx",
	"singingshell_creature_woodfx",
	"singingshell_creature_rockfx",
}

local critterprefabs =
{
}

local critterassets =
{
	Asset("ANIM", "anim/singingshell_creature_basic.zip"),
}

local singingshellloot = { "slurtle_shellpieces" }

local FLOATER_SIZES =
{
	octave3 = {size = "med", scale = 0.68},
	octave4 = {size = "med", scale = 0.58},
	octave5 = {size = "small", scale = 0.95},
}

local NOTES =
{
	"C",
	"C#",
	"D",
	"D#",
	"E",
	"F",
	"F#",
	"G",
	"G#",
	"A",
	"A#",
	"B",
}

local TRIGGER_DIST_SQ = 3*3

local PLANT_TAGS = {"tendable_farmplant"}

local function PlaySound(inst, doer)
	inst.SoundEmitter:PlaySoundWithParams(inst._sound, {note = inst.components.cyclable.step - 1 + 0.1})

	inst.AnimState:PlayAnimation("music")

    local x,y,z = inst.Transform:GetWorldPosition()
    for _, v in pairs(TheSim:FindEntities(x, y, z, TUNING.SINGINGSHELL_FARM_PLANT_INTERACT_RANGE, PLANT_TAGS)) do
		if v.components.farmplanttendable ~= nil then
			v.components.farmplanttendable:TendTo(doer)
		end
	end
end

local function OnCycle(inst, step, doer)
	PlaySound(inst, doer)
end

local function OnActivate(inst)
	inst.components.cyclable:Cycle()
	inst.components.cyclable.inactive = true
end

local function onfinishwork(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("singingshell_critterfx").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_pot")
	inst:Remove()
end

local function OnHaunt(inst, haunter)
	if math.random() > TUNING.HAUNT_CHANCE_OCCASIONAL then
		inst.components.cyclable:Cycle(haunter, math.random() > 0.5)-- 50% chance to cycle backwards
		inst:PushEvent("ontuned")
	end
end

local function RegisterActiveShell(inst)
	if TheWorld.components.singingshellmanager == nil then
		TheWorld:AddComponent("singingshellmanager")
	end

	TheWorld.components.singingshellmanager:RememberActiveShell(inst)
end

local function UnregisterActiveShell(inst)
	if TheWorld.components.singingshellmanager ~= nil then
		TheWorld.components.singingshellmanager:ForgetActiveShell(inst)
	end
end

local function getdescription(inst, viewer)
	return subfmt(GetDescription(viewer, inst, "GENERIC"), {note = NOTES[inst.components.cyclable.step]})
end

local function OnSave(inst, data)
	data.variation = inst._variation
end

local function OnLoad(inst, data)
	if data ~= nil and data.variation ~= nil then
		inst._variation = data.variation
		inst.AnimState:OverrideSymbol("shell_placeholder", "singingshell", "octave"..inst._octave.."_"..inst._variation)
		inst.components.inventoryitem:ChangeImageName("singingshell_octave"..inst._octave.."_"..inst._variation)
	end
end

local TRIGGER_MUST_TAGS = { "singingshelltrigger" }
local TRIGGER_CANT_TAGS = { "playerghost" }
local function PreventImmediateActivate(inst)
	if inst.entity:IsAwake() then
		local x, y, z = inst.Transform:GetWorldPosition()
		for _, v in ipairs(TheSim:FindEntities(x, y, z, TUNING.SINGINGSHELL_TRIGGER_RANGE, TRIGGER_MUST_TAGS, TRIGGER_CANT_TAGS)) do
			v.components.singingshelltrigger.overlapping[inst] = true
		end
	end
end

local function MakeShell(octave, common_postinit, master_postinit, prefabs)
	local octave_str = "octave"..octave
	local inv_image_name = "singingshell_"..octave_str.."_"

	local assets =
	{
		Asset("ANIM", "anim/singingshell.zip"),
		Asset("INV_IMAGE", inv_image_name.."1"),
		Asset("INV_IMAGE", inv_image_name.."2"),
		Asset("INV_IMAGE", inv_image_name.."3"),
	}

	local function fn()
		local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("singingshell")
        inst.AnimState:SetBuild("singingshell")
		inst.AnimState:PlayAnimation("idle")

		inst:AddTag("singingshell")

		MakeInventoryFloatable(inst, FLOATER_SIZES[octave_str].size, 0, FLOATER_SIZES[octave_str].scale)

		if common_postinit ~= nil then
			common_postinit(inst)
		end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		-- Called from singingshelltrigger
		inst._activatefn = PlaySound

		-- Prevents shell from immediately playing if spawning within range of a singingshelltrigger
		inst:DoTaskInTime(0, PreventImmediateActivate)

		inst._sound = "hookline_2/common/shells/sea_sound_"..(octave == 3 and 1 or octave == 4 and 2 or 3).."_LP"

		inst._octave = octave
		inst._variation = math.random(3)

		inst:AddComponent("inspectable")
		inst.components.inspectable.descriptionfn = getdescription

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem:SetOnDroppedFn(RegisterActiveShell)
		inst.components.inventoryitem:SetOnPickupFn(UnregisterActiveShell)
		inst.components.inventoryitem:SetSinks(false)

		inst.AnimState:OverrideSymbol("shell_placeholder", "singingshell", octave_str.."_"..inst._variation)
		inst.components.inventoryitem:ChangeImageName("singingshell_"..octave_str.."_"..inst._variation)

		inst:AddComponent("lootdropper")
		inst.components.lootdropper:SetLoot(singingshellloot)

		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(1)
		inst.components.workable:SetOnFinishCallback(onfinishwork)
		inst.components.workable.savestate = false

		inst:AddComponent("cyclable")
		inst.components.cyclable:SetOnCycleFn(OnCycle)
		inst.components.cyclable:SetNumSteps(12)
		inst.components.cyclable:SetStep(math.random(inst.components.cyclable.num_steps), nil, true)

		inst:AddComponent("hauntable")
		inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
		inst.components.hauntable:SetOnHauntFn(OnHaunt)

		inst:ListenForEvent("onremove", UnregisterActiveShell)

		inst.OnSave = OnSave
		inst.OnLoad = OnLoad

		inst.OnEntityWake = RegisterActiveShell
		inst.OnEntitySleep = UnregisterActiveShell

		inst:ListenForEvent("exitlimbo", PreventImmediateActivate)

		if master_postinit ~= nil then
			master_postinit(inst)
		end

		return inst
	end

	return Prefab("singingshell_octave"..octave, fn, assets, prefabs)
end


local function critterfn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

    inst.AnimState:SetBank("singingshell_creature")
    inst.AnimState:SetBuild("singingshell_creature_basic")
    local breaknum = math.random(1,3)
	inst.AnimState:PlayAnimation("break_"..breaknum, false)


	local times = {12}
	if breaknum == 2 then
		times = {3,6}
	elseif breaknum == 3 then
		times = {20}
	end

	for i,time in ipairs(times)do
		inst:DoTaskInTime(time/30,function()
			if inst.AnimState:IsCurrentAnimation("break_1") or inst.AnimState:IsCurrentAnimation("break_2") or inst.AnimState:IsCurrentAnimation("break_3") then
				inst.SoundEmitter:PlaySound("hookline_2/common/shells/creature/scared")
			end
		end)
	end

	inst:AddTag("NOCLICK")
	inst:AddTag("FX")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:ListenForEvent("animover", function()

		if inst.AnimState:IsCurrentAnimation("jump_pre") then

			inst.AnimState:PlayAnimation("jump_lag")
			inst:DoTaskInTime(math.random()*7/30,function()
				inst.AnimState:PlayAnimation("jump_post")
				inst:DoTaskInTime(3/30,function()
					inst.SoundEmitter:PlaySound("hookline_2/common/shells/creature/dig")
					local boat = inst:GetCurrentPlatform()
					if boat and boat:HasTag("wood") then
						SpawnPrefab("singingshell_creature_woodfx").Transform:SetPosition(inst.Transform:GetWorldPosition())
					else
						SpawnPrefab("singingshell_creature_rockfx").Transform:SetPosition(inst.Transform:GetWorldPosition())
					end
				end)
			end)
		end
		if inst.AnimState:IsCurrentAnimation("break_1") or inst.AnimState:IsCurrentAnimation("break_2") or inst.AnimState:IsCurrentAnimation("break_3") then

			inst.AnimState:PlayAnimation("jump_pre",false)
			inst:DoTaskInTime(7/30,function()
				if inst.AnimState:IsCurrentAnimation("jump_pre") then
					inst.SoundEmitter:PlaySound("hookline_2/common/shells/creature/scared")
				end
			end)
		end

	end)

	inst:ListenForEvent("animover", function()
		if inst.AnimState:IsCurrentAnimation("jump_post") then
			inst:Remove()
		end
	end)

	inst:DoTaskInTime(0,function()
		local pos = Vector3(inst.Transform:GetWorldPosition())
		local platform = inst:GetCurrentPlatform()

		if platform then
			local platform_x, platform_y, platform_z = platform.entity:WorldToLocalSpace(pos.x, pos.y, pos.z)
			inst.entity:SetParent(platform.entity)
			inst.Transform:SetPosition(platform_x, platform_y, platform_z)
		elseif not TheWorld.Map:IsVisualGroundAtPoint(pos.x,pos.y,pos.z) then
			SpawnPrefab("splash_green_small").Transform:SetPosition(pos.x,pos.y,pos.z)
			inst:Remove()
		end

	end)

    inst.persists = false

	return inst
end

return MakeShell(5, nil, nil, prefabs),
	MakeShell(4, nil, nil, prefabs),
	MakeShell(3, nil, nil, prefabs),
	Prefab("singingshell_critterfx", critterfn, critterassets, critterprefabs)