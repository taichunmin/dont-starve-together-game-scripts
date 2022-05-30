require("worldsettingsutil")

local prefabs =
{
	"kitcoonden_kit_placer",
}

local decor_prefabs = {}

local sounds = 
{
	kitcoondecor1 = 
	{
		place = "yotc_2022_1/decor1/place",
		play1 = "yotc_2022_1/decor1/play1",
		play2 = "yotc_2022_1/decor1/play2",
		play3 = "yotc_2022_1/decor1/play3",
	},

	kitcoondecor2 = 
	{
		place = "yotc_2022_2/common/decor2/place",
		play1 = "yotc_2022_2/common/decor2/play1",
		play2 = "yotc_2022_2/common/decor2/play2",
	},

}

-------------------------------------------------------------------------------
local function on_finished_hammering(inst)
    local ipos = inst:GetPosition()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(ipos:Get())
    fx:SetMaterial("wood")

    inst.components.lootdropper:DropLoot(ipos)

    inst:Remove()
end

local function on_hammered(inst)
    inst.AnimState:PlayAnimation("hit", false)
end

local function get_inspectable_status(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or nil
end

local function OnBurnt(inst)
	DefaultBurntStructureFn(inst)

	inst:RemoveComponent("cattoy")
    inst:RemoveComponent("activatable")
end

local function on_cattoy_play(inst)
    if inst.num_play_states and inst.num_play_states > 1 then
		local num = tostring(math.random(inst.num_play_states))
        inst.AnimState:PlayAnimation("play_"..num, false)
	    inst.SoundEmitter:PlaySound(sounds[inst.prefab]["play"..num] or sounds[inst.prefab].play1)
    else
        inst.AnimState:PlayAnimation("play", false)
	    inst.SoundEmitter:PlaySound(sounds[inst.prefab].play1)
    end
	inst.AnimState:PushAnimation("idle", true)

	return true
end

local function on_cattoy_activate(inst, doer)
    inst.components.activatable.inactive = true
    return on_cattoy_play(inst)
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle", true)

    inst.SoundEmitter:PlaySound(sounds[inst.prefab].place)
end

local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function OnLoad(inst, data)
	if data ~= nil then
        if data.burnt and not inst:HasTag("burnt") then
            OnBurnt(inst)
        end
	end
end

local function MakeKitcoonDecor(name, airborne_toy, num_play_states)
	local build_bank = name

	local assets = 
	{
		Asset("ANIM", "anim/"..build_bank..".zip"),
	}

	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()

		MakeSmallObstaclePhysics(inst, .25)

		inst.AnimState:SetBank(build_bank)
		inst.AnimState:SetBuild(build_bank)
		inst.AnimState:PlayAnimation("idle")

		inst:AddTag("structure")
		inst:AddTag("no_hideandseek")

		if airborne_toy then	
			inst:AddTag("cattoyairborne")
		else
			inst:AddTag("cattoy")
		end

		MakeSnowCoveredPristine(inst)

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		-------------------
        inst.num_play_states = num_play_states

		-------------------
		inst:AddComponent("cattoy")
		inst.components.cattoy:SetOnPlay(on_cattoy_play)

		-------------------
		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(4)
		inst.components.workable:SetOnFinishCallback(on_finished_hammering)
		inst.components.workable:SetOnWorkCallback(on_hammered)

		-------------------
        inst:AddComponent("activatable")
        inst.components.activatable.standingaction = true
        inst.components.activatable.OnActivate = on_cattoy_activate

		-------------------
		inst:AddComponent("lootdropper")

		-------------------
		inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = get_inspectable_status

		-------------------
		MakeMediumBurnable(inst)
		inst.components.burnable:SetOnBurntFn(OnBurnt)

		MakeMediumPropagator(inst)

		-------------------
		MakeSnowCovered(inst)

		inst.OnSave = OnSave
		inst.OnLoad = OnLoad

		MakeHauntableWork(inst)

	    inst:ListenForEvent("onbuilt", onbuilt)

		return inst
	end

	table.insert(decor_prefabs, Prefab(name, fn, assets, prefabs))
	table.insert(decor_prefabs, MakeDeployableKitItem(name.."_kit", name, build_bank, build_bank, "kit_item", nil, {size = "small", scale = 1.1}, nil, {fuelvalue = TUNING.SMALL_FUEL}))
	table.insert(decor_prefabs, MakePlacer(name.."_kit_placer", build_bank, build_bank, "placer"))
end

MakeKitcoonDecor("kitcoondecor1", true, 3)
MakeKitcoonDecor("kitcoondecor2", true, 2)

return unpack(decor_prefabs)
