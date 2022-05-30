local assets =
{
    Asset("ANIM", "anim/abigail_flower.zip"),
    Asset("ANIM", "anim/abigail_flower_rework.zip"),

	Asset("INV_IMAGE", "abigail_flower_level0"),
	Asset("INV_IMAGE", "abigail_flower_level2"),
	Asset("INV_IMAGE", "abigail_flower_level3"),

    Asset("INV_IMAGE", "abigail_flower_old"),		-- deprecated, left in for mods
    Asset("INV_IMAGE", "abigail_flower2"),			-- deprecated, left in for mods
    Asset("INV_IMAGE", "abigail_flower_haunted"),	-- deprecated, left in for mods
    Asset("INV_IMAGE", "abigail_flower_wilted"),	-- deprecated, left in for mods
}

local function UpdateGroundAnimation(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
    local players = {}
	if not POPULATING then
		for i, v in ipairs(AllPlayers) do
			if v:HasTag("ghostlyfriend") and not IsEntityDeadOrGhost(v) and v.components.ghostlybond ~= nil and v.entity:IsVisible() and (v.sg == nil or not v.sg:HasStateTag("ghostbuild")) then
				local dist = v:GetDistanceSqToPoint(x, y, z)
				if dist < TUNING.ABIGAIL_FLOWER_PROX_DIST then
					table.insert(players, {player = v, dist = dist})
				end
			end
		end
	end

	if #players > 1 then
		table.sort(players, function(a, b) return a.dist < b.dist end)
	end

	local level = players[1] ~= nil and players[1].player.components.ghostlybond.bondlevel or 0
	if inst._bond_level ~= level then
		if inst._bond_level == 0 then
			inst.AnimState:PlayAnimation("level"..level.."_pre")
			inst.AnimState:PushAnimation("level"..level.."_loop", true)
			inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/haunted_flower_LP", "floating")
		elseif inst._bond_level > 0 and level == 0 then
			inst.AnimState:PlayAnimation("level"..inst._bond_level.."_pst")
			inst.AnimState:PushAnimation("level0_loop", true)
            inst.SoundEmitter:KillSound("floating")
		else
			inst.AnimState:PlayAnimation("level"..level.."_loop", true)
			inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/abigail/haunted_flower_LP", "floating")
		end
	end

	inst._bond_level = level
end

local function topocket(inst, owner)
	if inst._ongroundupdatetask ~= nil then
		inst._ongroundupdatetask:Cancel()
		inst._ongroundupdatetask = nil
	end
end

local function toground(inst)
	inst._bond_level = -1 --to force the animation to update
	UpdateGroundAnimation(inst)
	if inst._ongroundupdatetask == nil then
		inst._ongroundupdatetask = inst:DoPeriodicTask(0.5, UpdateGroundAnimation)
	end
end

local function OnEntitySleep(inst)
	if inst._ongroundupdatetask ~= nil then
		inst._ongroundupdatetask:Cancel()
		inst._ongroundupdatetask = nil
	end
end

local function OnEntityWake(inst)
	if not inst.inlimbo and inst._ongroundupdatetask == nil then
		inst._ongroundupdatetask = inst:DoPeriodicTask(0.5, UpdateGroundAnimation, math.random()*0.5)
	end
end

local function GetElixirTarget(inst, doer, elixir)
	return (doer ~= nil and doer.components.ghostlybond ~= nil) and doer.components.ghostlybond.ghost or nil
end

local function getstatus(inst, viewer)
	local _bondlevel = inst._bond_level
	if inst.components.inventoryitem.owner then
		_bondlevel = viewer ~= nil and viewer.components.ghostlybond ~= nil and viewer.components.ghostlybond.bondlevel
	end
	return _bondlevel == 3 and "LEVEL3"
		or _bondlevel == 2 and "LEVEL2"
		or _bondlevel == 1 and "LEVEL1"
		or nil
end

local function OnSkinIDDirty(inst)
	inst.skin_id = inst.flower_skin_id:value()

	inst:DoTaskInTime(0, function()
		local image_name = string.gsub(inst.AnimState:GetBuild(), "abigail_", "abigail_flower_")
		if not inst.clientside_imageoverrides[image_name] then
			inst:SetClientSideInventoryImageOverride("bondlevel0", image_name..".tex", image_name.."_level0.tex")
			inst:SetClientSideInventoryImageOverride("bondlevel2", image_name..".tex", image_name.."_level2.tex")
			inst:SetClientSideInventoryImageOverride("bondlevel3", image_name..".tex", image_name.."_level3.tex")
			inst.clientside_imageoverrides[image_name] = true
		end
	end)
end

local function drawimageoverride(inst)
	local level = inst._bond_level or 0
	if level == 1 then
		return inst:GetSkinName() or "abigail_flower"
	else
		return (inst:GetSkinName() or "abigail_flower").."_level" ..tostring(level)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("abigail_flower_rework")
    inst.AnimState:SetBuild("abigail_flower_rework")
    inst.AnimState:PlayAnimation("level0_loop")
    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("abigail_flower.png")

    MakeInventoryFloatable(inst, "small", 0.15, 0.9)

	inst:AddTag("abigail_flower")
	inst:AddTag("give_dolongaction")
	inst:AddTag("ghostlyelixirable") -- for ghostlyelixirable component

    inst:SetClientSideInventoryImageOverride("bondlevel0", "abigail_flower.tex", "abigail_flower_level0.tex")
    inst:SetClientSideInventoryImageOverride("bondlevel2", "abigail_flower.tex", "abigail_flower_level2.tex")
    inst:SetClientSideInventoryImageOverride("bondlevel3", "abigail_flower.tex", "abigail_flower_level3.tex")

	inst.clientside_imageoverrides = {
		abigail_flower_flower_rework = true
	}

    inst.flower_skin_id = net_hash(inst.GUID, "abi_flower_skin_id", "abiflowerskiniddirty")
	inst:ListenForEvent("abiflowerskiniddirty", OnSkinIDDirty)
	OnSkinIDDirty(inst)

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("summoningitem")

	inst:AddComponent("ghostlyelixirable")
	inst.components.ghostlyelixirable.overrideapplytotargetfn = GetElixirTarget

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
	inst.components.burnable.fxdata = {}
    inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 0, 0))

    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

	inst._ongroundupdatetask = inst:DoPeriodicTask(0.5, UpdateGroundAnimation, math.random()*0.5)
	inst._bond_level = 0

    inst.drawimageoverride = drawimageoverride

    return inst
end


local assets_summonfx =
{
    Asset("ANIM", "anim/wendy_channel_flower.zip"),
    Asset("ANIM", "anim/wendy_mount_channel_flower.zip"),
}

local assets_unsummonfx =
{
    Asset("ANIM", "anim/wendy_recall_flower.zip"),
    Asset("ANIM", "anim/wendy_mount_recall_flower.zip"),
}

local assets_levelupfx =
{
    Asset("ANIM", "anim/abigail_flower_change.zip"),
}

local function AlignToTarget(inst)
	local parent = inst.entity:GetParent()
	if parent ~= nil then
	    inst.Transform:SetRotation(parent.Transform:GetRotation())
	end
end

local function MakeSummonFX(anim, use_anim_for_build, is_mounted)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

		if is_mounted then
	        inst.Transform:SetSixFaced()
		else
	        inst.Transform:SetFourFaced()
		end


        inst.AnimState:SetBank(anim)
		if use_anim_for_build then
	        inst.AnimState:SetBuild(anim)
	        inst.AnimState:OverrideSymbol("flower", "abigail_flower_rework", "flower")
		else
	        inst.AnimState:SetBuild("abigail_flower_rework")
		end
        inst.AnimState:PlayAnimation(anim)

		if is_mounted then
			inst:AddComponent("updatelooper")
			inst.components.updatelooper:AddOnWallUpdateFn(AlignToTarget)
		end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        --Anim is padded with extra blank frames at the end
        inst:ListenForEvent("animover", inst.Remove)

        return inst
    end
end

return Prefab("abigail_flower", fn, assets),
	Prefab("abigailsummonfx", MakeSummonFX("wendy_channel_flower", true, false), assets_summonfx),
    Prefab("abigailsummonfx_mount", MakeSummonFX("wendy_mount_channel_flower", true, true), assets_summonfx),
	Prefab("abigailunsummonfx", MakeSummonFX("wendy_recall_flower", false, false), assets_unsummonfx),
    Prefab("abigailunsummonfx_mount", MakeSummonFX("wendy_mount_recall_flower", false, true), assets_unsummonfx),
	Prefab("abigaillevelupfx", MakeSummonFX("abigail_flower_change", false, false), assets_levelupfx)


