require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/scale_o_matic.zip"),
}

local prefabs =
{
	"collapse_small",
	"splash",
	"wave_splash",
}

local sounds =
{
	onbuilt = "hookline/common/trophyscale_fish/place",
	newtrophy = "hookline/common/trophyscale_fish/place_fish",
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

local TROPHY_LAUNCH_BASESPEED = 2
local TROPHY_LAUNCH_STARTHEIGHT = 3

local ONHIT_SPLASH_Y_OFFSET = 4
local ONHAMMERED_SPLASH_Y_OFFSET = 3.25

local DIGIT_COLORS =
{
	"_black",
	"_black",
	"_black",
	"_white",
	"_white",
}

local function GetItemData(inst)
	return inst.components.trophyscale:GetItemData()
end

local function IsHoldingItem(inst)
	return inst.components.trophyscale.item_data ~= nil and not inst:HasTag("burnt")
end

local function DropItem(inst, data)
	if data ~= nil then
		local item = inst.components.trophyscale:SpawnItemFromData(data)

		if item ~= nil then
			local x, y, z = inst.Transform:GetWorldPosition()
			item.Transform:SetPosition(x, y, z)
			Launch2(item, inst, TROPHY_LAUNCH_BASESPEED, 1, TROPHY_LAUNCH_STARTHEIGHT,
				inst.Physics ~= nil and inst.Physics:GetRadius() or 1
				+ item.Physics ~= nil and item.Physics:GetRadius() or 0)
		end
	end
end

local function SetDigits(inst, weight)
	if weight == nil then
		weight = "00000"
	elseif type(weight) == "number" then
		local formatted = string.format("%06.2f", weight)

		-- Decimal point at ind 4
		weight = string.sub(formatted, 1, 3)..string.sub(formatted, 5)
	end

	for i=1,5 do
		inst.AnimState:OverrideSymbol("column"..i, "scale_o_matic", "number"..string.sub(weight, i, i)..(DIGIT_COLORS[i] or "_black"))
	end
end

local function onspawnitemfromdata(item, data)
	if item ~= nil and data ~= nil then
		if item.components.perishable ~= nil and data.perish_percent then
			item.components.perishable:SetPercent(data.perish_percent or 1)
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
	local build_to_clear = nil

	if data_old ~= nil and data_old.prefab ~= nil then
		DropItem(inst, data_old)
		inst.AnimState:PlayAnimation("replacefish")
		sound_delay = sound_delay_place
		build_to_clear = data_old.build
	else
		inst.AnimState:PlayAnimation("placefish")
		sound_delay = sound_delay_replace
	end
	inst.AnimState:PushAnimation("fish_idle", true)

	local bell_sound_param = 0
	if data_new ~= nil then
		if build_to_clear ~= nil then
			inst.AnimState:ClearOverrideBuild(build_to_clear)
		end
		inst.AnimState:AddOverrideBuild(data_new.build)

		-- Delay makes sure digits aren't switched in the first few
		-- frames of the animation before the spinning starts.
		inst.task_setdigits = inst:DoTaskInTime(5*FRAMES, SetDigits, data_new.weight)
		bell_sound_param = math.clamp(data_new.weight / 1000, 0, 1)
	end

	inst.SoundEmitter:PlaySound(sounds.newtrophy, "new_trophy")

	inst.soundtask_playspin = inst:DoTaskInTime(sound_delay.spin*FRAMES, function() inst.SoundEmitter:PlaySound(sounds.spin, "spin_loop") end)
	inst.soundtask_stopspin = inst:DoTaskInTime(sound_delay.spin_stop*FRAMES, function() inst.SoundEmitter:KillSound("spin_loop") end)
	inst.soundtask_playbell = inst:DoTaskInTime(sound_delay.bell*FRAMES, function() inst.SoundEmitter:PlaySound(sounds.bell, "bell", bell_sound_param) end)

	inst.components.trophyscale.accepts_items = false
	inst.task_newtrophyweighed = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, function()
		if inst.components.trophyscale ~= nil then
			inst.components.trophyscale.accepts_items = true
		end
	end)
end

local function comparepostfn(item_data, new_inst)
	if new_inst.components.perishable ~= nil then
		item_data.perish_percent = new_inst.components.perishable:GetPercent()
	end
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

	if not inst:HasTag("burnt") then
		SpawnPrefab("wave_splash").Transform:SetPosition(x, y + ONHAMMERED_SPLASH_Y_OFFSET, z)
	end

    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") and not (inst.AnimState:IsCurrentAnimation("placefish") or inst.AnimState:IsCurrentAnimation("replacefish")) then
		if IsHoldingItem(inst) then
			inst.AnimState:PlayAnimation("fish_hit")
			inst.AnimState:PushAnimation("fish_idle", true)
		else
			inst.AnimState:PlayAnimation("nofish_hit")
			inst.AnimState:PushAnimation("nofish_idle", false)
		end

		if inst.components.workable.workleft > 0 then
			local x, y, z = inst.Transform:GetWorldPosition()
			SpawnPrefab("splash").Transform:SetPosition(x, y + ONHIT_SPLASH_Y_OFFSET, z)
		end
    end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("spawn")
	inst.AnimState:PushAnimation("nofish_idle", false)
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
		local heavy_postfix =  (data.is_heavy and "_HEAVY" or "")

		if data.prefab_override_owner ~= nil then
			return subfmt(GetDescription(viewer, inst, "HAS_ITEM"..heavy_postfix), {weight = data.weight or "",
				owner = STRINGS.UI.HUD.TROPHYSCALE_PREFAB_OVERRIDE_OWNER[data.prefab_override_owner] ~= nil and STRINGS.UI.HUD.TROPHYSCALE_PREFAB_OVERRIDE_OWNER[data.prefab_override_owner]
				or STRINGS.UI.HUD.TROPHYSCALE_UNKNOWN_OWNER})
		else
			local name = data.owner_userid == nil and STRINGS.UI.HUD.TROPHYSCALE_UNKNOWN_OWNER or data.owner_name
			return data.owner_userid ~= nil and data.owner_userid == viewer.userid and subfmt(GetDescription(viewer, inst, "OWNER"..heavy_postfix), {weight = data.weight or "", owner = name or ""}) or
				subfmt(GetDescription(viewer, inst, "HAS_ITEM"..heavy_postfix), {weight = data.weight or "", owner = name or ""})
		end
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
			inst.AnimState:PlayAnimation("fish_idle", true)

			local item_data = inst.components.trophyscale.item_data

			if item_data ~= nil then
				if item_data.build ~= nil then
					inst.AnimState:AddOverrideBuild(item_data.build)
				end

				if item_data.weight ~= nil then
					SetDigits(inst, item_data.weight)
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

	inst:SetDeploySmartRadius(1.25) --recipe min_spacing/2
	MakeObstaclePhysics(inst, .4)

	inst.MiniMapEntity:SetPriority(5)
	inst.MiniMapEntity:SetIcon("trophyscale_fish.png")

	inst.AnimState:SetBuild("scale_o_matic")
	inst.AnimState:SetBank("scale_o_matic")
	inst.AnimState:PlayAnimation("nofish_idle")
	inst.scrapbook_anim = "nofish_idle"

	SetDigits(inst, nil)

	inst:AddTag("structure")

	--trophyscale_fish (from trophyscale component) added to pristine state for optimization
	inst:AddTag("trophyscale_fish")

	MakeSnowCoveredPristine(inst)

	inst.scrapbook_specialinfo = "TROPHYSCALEFISH"

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
	inst.components.trophyscale.type = TROPHYSCALE_TYPES.FISH
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

return Prefab("trophyscale_fish", fn, assets, prefabs),
    MakePlacer("trophyscale_fish_placer", "scale_o_matic", "scale_o_matic", "nofish_idle")
