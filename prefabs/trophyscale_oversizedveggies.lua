require "prefabutil"
local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS

local assets =
{
	Asset("ANIM", "anim/trophyscale_oversizedveggies.zip"),
}

local prefabs =
{
	"collapse_small",
}

local sounds =
{
	onbuilt = "farming/common/farm/veggie_scale/place",
	newtrophy = "farming/common/farm/veggie_scale/oversized",
	spin = "hookline/common/trophyscale_fish/ticker_LP",
	bell = "hookline/common/trophyscale_fish/bell",
}
local sound_delay_place =
{
	spin = 2,
	spin_stop = 50,
	bell = 52,
}
local sound_delay_replace =
{
	spin = 4,
	spin_stop = 46,
	bell = 48,
}

local DROP_OFFSET = 1.5

local DIGIT_COLORS =
{
	"_black",
	"_black",
	"_black",
	"_white",
	"_white",
}

local function IsHoldingItem(inst)
	return inst.components.trophyscale.item_data ~= nil and not inst:HasTag("burnt")
end

local function DropItem(inst, data)
	if data ~= nil then
		local item = inst.components.trophyscale:SpawnItemFromData(data)

		if item ~= nil then
			local x, y, z = inst.Transform:GetWorldPosition()
			local dir = math.random() * PI * 2
			item.Transform:SetPosition(x + math.cos(dir) * DROP_OFFSET, y, z + math.sin(dir) * DROP_OFFSET)
		end
	end
end

local function SetDigits(inst, weight)
	if weight == nil or weight == 0 then
		inst.AnimState:ClearOverrideSymbol("column1")
		inst.AnimState:OverrideSymbol("column2", "trophyscale_oversizedveggies", "lessthansign_black")
		inst.AnimState:OverrideSymbol("column3", "trophyscale_oversizedveggies", "number1_black")
		inst.AnimState:OverrideSymbol("column4", "trophyscale_oversizedveggies", "number0_white")
		inst.AnimState:OverrideSymbol("column5", "trophyscale_oversizedveggies", "number0_white")
	else
		if type(weight) == "number" then
			local formatted = string.format("%06.2f", weight)

			-- Decimal point at ind 4
			weight = string.sub(formatted, 1, 3)..string.sub(formatted, 5)
		end

		for i=1,5 do
			inst.AnimState:OverrideSymbol("column"..i, "trophyscale_oversizedveggies", "number"..string.sub(weight, i, i)..(DIGIT_COLORS[i] or "_black"))
		end
	end
end

local function onspawnitemfromdata(item, data)
	if item then
		item.from_plant = (data and data.from_plant) ~= false
		if data then
			if item.components.perishable ~= nil and data.perish_percent then
				item.components.perishable:SetPercent(data.perish_percent or 1)
			end
		end
	end
end

local function CancelNewTrophySounds(inst)
	if inst.SoundEmitter:PlayingSound("new_trophy") then inst.SoundEmitter:KillSound("new_trophy") end
	if inst.SoundEmitter:PlayingSound("spin_loop") then inst.SoundEmitter:KillSound("spin_loop") end
	if inst.SoundEmitter:PlayingSound("bell") then inst.SoundEmitter:KillSound("bell") end
end

local function CancelNewTrophyTasks(inst)
	if inst.task_setdigits ~= nil then
		inst.task_setdigits:Cancel()
		inst.task_setdigits = nil
	end

	if inst.soundtask_playspin ~= nil then
		inst.soundtask_playspin:Cancel()
		inst.soundtask_playspin = nil
	end
	if inst.soundtask_stopspin ~= nil then
		inst.soundtask_stopspin:Cancel()
		inst.soundtask_stopspin = nil
	end
	if inst.soundtask_playbell ~= nil then
		inst.soundtask_playbell:Cancel()
		inst.soundtask_playbell = nil
	end

	if inst.task_newtrophyweighed ~= nil then
		inst.task_newtrophyweighed:Cancel()
		inst.task_newtrophyweighed = nil
	end
	inst.components.trophyscale.accepts_items = true
end

local function onnewtrophy(inst, data_old_and_new)
	local data_old = data_old_and_new.old
	local data_new = data_old_and_new.new

	local sound_delay = nil

	if data_old ~= nil and data_old.prefab ~= nil then
		DropItem(inst, data_old)
		sound_delay = sound_delay_place
	else
		sound_delay = sound_delay_replace
	end

	local play_bell_sound = false
	local bell_sound_param = 0
	if data_new ~= nil then
		if data_new.weight == nil or data_new.weight <= 0 then
			inst.AnimState:PlayAnimation("placeveg_light")

			inst.AnimState:ClearOverrideSymbol("swap_body")
			inst.AnimState:OverrideSymbol("swap_normal", data_new.build, data_new.build.."01")

			inst.AnimState:PushAnimation("veg_light_idle", false)
		else
			if data_old == nil or data_old.weight == nil or data_old.weight <= 0 then
				inst.AnimState:PlayAnimation("placeveg")
			else
				inst.AnimState:PlayAnimation("replaceveg")
			end

			inst.AnimState:ClearOverrideSymbol("swap_normal")
			inst.AnimState:OverrideSymbol("swap_body", data_new.build, "swap_body")

			inst.AnimState:PushAnimation("veg_idle", false)

			play_bell_sound = true

			local doer = data_old_and_new.doer
			if doer and data_new.from_plant then
				local string_weight = data_new.weight
				if type(string_weight) == "number" then
					local formatted = string.format("%06.2f", string_weight)
					-- Decimal point at ind 4
					string_weight = string.sub(formatted, 1, 3)..string.sub(formatted, 5)
				end
				local eventdata = {plant = data_new.base_name, weight = string_weight}
				if doer.components.beard then
					--pretty disgusting, but probably the best time to get this data.
					eventdata.beardskin, eventdata.beardlength = doer.components.beard:GetBeardSkinAndLength()
				end
				doer:PushEvent("takeoversizedpicture", eventdata)
			end
		end

		-- Delay makes sure digits aren't switched in the first few
		-- frames of the animation before the spinning starts.
		inst.task_setdigits = inst:DoTaskInTime(5*FRAMES, SetDigits, data_new.weight)
		bell_sound_param = math.clamp(data_new.weight / 1000, 0, 1)
	end

	-- Turning off this sound for now
	inst.SoundEmitter:PlaySound(sounds.newtrophy, "new_trophy")

	inst.soundtask_playspin = inst:DoTaskInTime(sound_delay.spin*FRAMES, function() inst.SoundEmitter:PlaySound(sounds.spin, "spin_loop") end)
	inst.soundtask_stopspin = inst:DoTaskInTime(sound_delay.spin_stop*FRAMES, function() inst.SoundEmitter:KillSound("spin_loop") end)
	if play_bell_sound then
		inst.soundtask_playbell = inst:DoTaskInTime(sound_delay.bell*FRAMES, function() inst.SoundEmitter:PlaySound(sounds.bell, "bell", bell_sound_param) end)
	end

	inst.components.trophyscale.accepts_items = false
	inst.task_newtrophyweighed = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, function()
		if inst.components.trophyscale ~= nil then
			inst.components.trophyscale.accepts_items = true
		end
	end)
end

local function comparepostfn(item_data, new_inst)
	if new_inst:HasTag("heavy") then
		item_data.build = PLANT_DEFS[new_inst._base_name].build
		if item_data.build == nil then
			item_data.build = "farm_plant_"..new_inst._base_name
		end
	end

	item_data.base_name = new_inst._base_name
	item_data.from_plant = new_inst.from_plant

	if new_inst.components.perishable ~= nil then
		item_data.perish_percent = new_inst.components.perishable:GetPercent()
	end

	item_data.day = new_inst.harvested_on_day or 1
end

local function ondeconstructstructure(inst)
	DropItem(inst, inst.components.trophyscale:GetItemData())
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()

	DropItem(inst, inst.components.trophyscale:GetItemData())

    local fx = SpawnPrefab("collapse_small")
	local x, y, z = inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("wood")

    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") and not (inst.AnimState:IsCurrentAnimation("placeveg") or inst.AnimState:IsCurrentAnimation("replaceveg")) then
		if IsHoldingItem(inst) then
			if inst.components.trophyscale.item_data == nil
				or inst.components.trophyscale.item_data.weight == nil
				or inst.components.trophyscale.item_data.weight <= 0 then

				inst.AnimState:PlayAnimation("veg_light_hit")
				inst.AnimState:PushAnimation("veg_light_idle", true)
			else
				inst.AnimState:PlayAnimation("veg_hit")
				inst.AnimState:PushAnimation("veg_idle", true)
			end
		else
			inst.AnimState:PlayAnimation("noveg_hit")
			inst.AnimState:PushAnimation("noveg_idle", false)
		end
    end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("spawn")
	inst.AnimState:PushAnimation("noveg_idle", false)
	inst.SoundEmitter:PlaySound(sounds.onbuilt)
end

local function onignite(inst)
    DefaultBurnFn(inst)
end

local function onextinguish(inst)
    DefaultExtinguishFn(inst)
end

local function onburnt(inst)
	CancelNewTrophySounds(inst)
	CancelNewTrophyTasks(inst)

	DropItem(inst, inst.components.trophyscale.item_data)
	inst.components.trophyscale:ClearItemData()
    DefaultBurntStructureFn(inst)
end

local function getdesc(inst, viewer)
	if inst:HasTag("burnt") then
		return GetDescription(viewer, inst, "BURNT")
	elseif inst:HasTag("fire") then
		return GetDescription(viewer, inst, "BURNING")
	elseif IsHoldingItem(inst) then
		local data = inst.components.trophyscale.item_data

		if data.weight == nil or data.weight <= 0 then
			return GetDescription(viewer, inst, "HAS_ITEM_LIGHT")
		end

		local heavy_postfix =  (data.is_heavy and "_HEAVY" or "")
		return subfmt(GetDescription(viewer, inst, "HAS_ITEM"..heavy_postfix), {weight = data.weight or "", day = data.day or ""})
	end

	return GetDescription(viewer, inst) or nil
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        elseif IsHoldingItem(inst) then
			local item_data = inst.components.trophyscale.item_data

			if item_data ~= nil then
				if item_data.weight ~= nil and item_data.weight > 0 then
					SetDigits(inst, item_data.weight)
					if item_data.build ~= nil then
						inst.AnimState:OverrideSymbol("swap_body", item_data.build, "swap_body")
					end
					inst.AnimState:PlayAnimation("veg_idle", true)
				else
					SetDigits(inst, nil)
					if item_data.build ~= nil then
						inst.AnimState:OverrideSymbol("swap_normal", item_data.build, item_data.build.."01")
					end
					inst.AnimState:PlayAnimation("veg_light_idle", true)
				end
			end
		end
    end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, .4)

	inst.MiniMapEntity:SetPriority(5)
	inst.MiniMapEntity:SetIcon("trophyscale_oversizedveggies.png")

	inst.AnimState:SetBuild("trophyscale_oversizedveggies")
	inst.AnimState:SetBank("trophyscale_oversizedveggies")
	inst.AnimState:PlayAnimation("noveg_idle")

	SetDigits(inst, "00000")

	inst:AddTag("structure")

	--trophyscale_oversizedveggies (from trophyscale component) added to pristine state for optimization
	inst:AddTag("trophyscale_oversizedveggies")

	MakeSnowCoveredPristine(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	--inst.task_setdigits = nil
	--inst.soundtask_playspin = nil
	--inst.soundtask_stopspin = nil
	--inst.soundtask_playbell = nil
	--inst.task_newtrophyweighed = nil

	inst:AddComponent("inspectable")
	inst.components.inspectable.getspecialdescription = getdesc

	inst:AddComponent("trophyscale")
	inst.components.trophyscale.type = TROPHYSCALE_TYPES.OVERSIZEDVEGGIES
	inst.components.trophyscale:SetComparePostFn(comparepostfn)
	inst.components.trophyscale:SetOnSpawnItemFromDataFn(onspawnitemfromdata)
	inst.components.trophyscale:SetItemCanBeTaken(false)

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	MakeLargeBurnable(inst, nil, nil, true)
	inst.components.burnable:SetOnBurntFn(onburnt)
	inst.components.burnable:SetOnIgniteFn(onignite)
	inst.components.burnable:SetOnExtinguishFn(onextinguish)

	MakeLargePropagator(inst)

	MakeSnowCovered(inst)

	inst.OnSave = onsave
	inst.OnLoad = onload

	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("onnewtrophy", onnewtrophy)
    inst:ListenForEvent("ondeconstructstructure", ondeconstructstructure)

	return inst
end

return Prefab("trophyscale_oversizedveggies", fn, assets, prefabs),
    MakePlacer("trophyscale_oversizedveggies_placer", "trophyscale_oversizedveggies", "trophyscale_oversizedveggies", "noveg_idle")
