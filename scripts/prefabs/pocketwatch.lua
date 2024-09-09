
local assets =
{
    Asset("SCRIPT", "scripts/prefabs/pocketwatch_common.lua"),

    Asset("ANIM", "anim/pocketwatch.zip"),
    Asset("ANIM", "anim/pocketwatch_marble.zip"),
    Asset("ANIM", "anim/pocketwatch_recall.zip"),
    Asset("ANIM", "anim/pocketwatch_warp.zip"),
    Asset("ANIM", "anim/pocketwatch_wood.zip"),
}

local prefabs = 
{
	"pocketwatch_cast_fx",
	"pocketwatch_cast_fx_mount",
	"pocketwatch_heal_fx",
	"pocketwatch_heal_fx_mount",
	"pocketwatch_ground_fx",
	"pocketwatch_warp_marker",
	"pocketwatch_warpback_fx",
	"pocketwatch_warpbackout_fx",
	"pocketwatch_revive_reviver",
}

local PocketWatchCommon = require "prefabs/pocketwatch_common"

-------------------------------------------------------------------------------
local function Heal_DoCastSpell(inst, doer)
	local health = doer.components.health
	if health ~= nil and not health:IsDead() then
		doer.components.oldager:StopDamageOverTime()
		health:DoDelta(TUNING.POCKETWATCH_HEAL_HEALING, true, inst.prefab)

		local fx = SpawnPrefab((doer.components.rider ~= nil and doer.components.rider:IsRiding()) and "pocketwatch_heal_fx_mount" or "pocketwatch_heal_fx")
		fx.entity:SetParent(doer.entity)

		inst.components.rechargeable:Discharge(TUNING.POCKETWATCH_HEAL_COOLDOWN)
		return true
	end
end

local MOUNTED_CAST_TAGS = {"pocketwatch_mountedcast"}

local function healfn()
	local inst = PocketWatchCommon.common_fn("pocketwatch", "pocketwatch_marble", Heal_DoCastSpell, true, MOUNTED_CAST_TAGS)

    if not TheWorld.ismastersim then
        return inst
    end

	inst.castfxcolour = {255 / 255, 241 / 255, 236 / 255}

    return inst
end

-------------------------------------------------------------------------------
local PLAYERSKELETON_TAG = {"playerskeleton"}
local function revive_onActivateResurrection(inst, target)
	local x, y, z = target.Transform:GetWorldPosition()
	local playerskeletons = TheSim:FindEntities(x, y, z, 1, PLAYERSKELETON_TAG)
	for i, skeleton in ipairs(playerskeletons) do
		if skeleton.userid == target.userid then
			if skeleton.components.lootdropper ~= nil then
				skeleton.components.lootdropper:DropLoot()
			end
			skeleton:Remove()
			break
		end
	end
end

local function revive_revivier_onActivateResurrection(inst, target)
	revive_onActivateResurrection(inst, target)
	inst:Remove()
end

local function ReviveOwner(inst)
	local owner = inst.components.inventoryitem:GetGrandOwner()
	if owner == nil or not owner:HasTag("playerghost") then
		inst:Remove()
		return
	end
	if owner.last_death_shardid == TheShard:GetShardId() then
		owner:PushEvent("respawnfromghost", { source = inst })
	end
end

local function revive_reviverfn() -- this is used to revive players after pocketwatch_revive migrates them to another shard
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

	inst:ListenForEvent("activateresurrection", revive_revivier_onActivateResurrection)

	inst:DoTaskInTime(0, ReviveOwner)

	return inst
end

-------------------------------------------------------------------------------

local function Revive_CanTarget(inst, doer, target)
	-- This is a client side function
	return target ~= nil and target:HasTag("playerghost") and not target:HasTag("reviving")
end

local function Revive_DoCastSpell(inst, doer, target)
	if Revive_CanTarget(inst, doer, target) and inst.components.pocketwatch.inactive then
		if target.last_death_shardid ~= nil and target.last_death_shardid ~= TheShard:GetShardId() then
			-- if the player is about to get teleported to another shard, give them this item so they will revive on the other side
			target.components.inventory:GiveItem(SpawnPrefab("pocketwatch_revive_reviver"))
		end

		target:PushEvent("respawnfromghost", { source = inst, from_haunt = doer == target })

		inst.components.rechargeable:Discharge(TUNING.POCKETWATCH_REVIVE_COOLDOWN)
		return true
	end

	return false, "REVIVE_FAILED"

end

local function Revive_OnHaunt(inst, haunter)
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
	if haunter:HasTag("pocketwatchcaster") and inst.components.pocketwatch:CastSpell(haunter, haunter) then
		inst.components.lootdropper:DropLoot()
	    SpawnPrefab("brokentool").Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst:Remove() -- cannot withstand the paradox of being haunted by Wanda�s timeline
	else
        Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
	end
end

local function revivefn()
	local inst = PocketWatchCommon.common_fn("pocketwatch", "pocketwatch_wood", Revive_DoCastSpell, false, MOUNTED_CAST_TAGS)

	inst.GetActionVerb_CAST_POCKETWATCH = "REVIVER"
	inst.pocketwatch_CanTarget = Revive_CanTarget

    if not TheWorld.ismastersim then
        return inst
    end

	inst.castfxcolour = {219 / 255, 153 / 255, 109 / 255}

	inst.components.pocketwatch.CanCastFn = Revive_CanTarget

    inst.components.hauntable:SetOnHauntFn(Revive_OnHaunt)

	inst:ListenForEvent("activateresurrection", revive_onActivateResurrection)

    return inst
end

-------------------------------------------------------------------------------

local function recallmarker_ShowMarker(inst, viewer)
    inst.Network:SetClassifiedTarget(viewer)
    if viewer ~= ThePlayer then
		-- hide it from the locally hosted server player
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)
	end
end

local function recallmarker_RemoveMarker(inst, viewer)
	if inst:IsAsleep() then
		inst:Remove()
	else
		inst.AnimState:PlayAnimation("idle_pst")
		inst.AnimState:PushAnimation("off", false)
		inst:DoTaskInTime(0.5, inst.Remove) 
	end
end

local function recallmarkerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("pocketwatch_warp_marker")
    inst.AnimState:SetBank("pocketwatch_warp_marker")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:PlayAnimation("idle_pre")
	inst.AnimState:PushAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(1.0, 1.0, 1.0, 0.6)

	inst:AddTag("NOBLOCK")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	inst.ShowMarker = recallmarker_ShowMarker
	inst.RemoveMarker = recallmarker_RemoveMarker

    return inst
end

local function DelayedMarkTalker(player)
	-- if the player starts moving right away then we can skip this
	if player.sg == nil or player.sg:HasStateTag("idle") then 
		player.components.talker:Say(GetString(player, "ANNOUNCE_POCKETWATCH_MARK"))
	end 
end

local function Recall_DoCastSpell(inst, doer, target, pos)
	local recallmark = inst.components.recallmark

	if recallmark:IsMarked() then
		if Shard_IsWorldAvailable(recallmark.recall_worldid) then
			inst.components.rechargeable:Discharge(TUNING.POCKETWATCH_RECALL_COOLDOWN)

			doer.sg.statemem.warpback = {dest_worldid = recallmark.recall_worldid, dest_x = recallmark.recall_x, dest_y = 0, dest_z = recallmark.recall_z, reset_warp = true}
			return true
		else
			return false, "SHARD_UNAVAILABLE"
		end
	else
		local x, y, z = doer.Transform:GetWorldPosition()
		inst.components.recallmark:MarkPosition(x, y, z)
		inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/MarkPosition")

		doer:DoTaskInTime(12 * FRAMES, DelayedMarkTalker) 

		return true
	end
end

local function Recall_ItemTradeTest(inst, item, giver)
    if item == nil then
        return false
    elseif string.sub(item.prefab, -3) ~= "gem" then
        return false, "NOTGEM"
	elseif item.prefab ~= "purplegem" then
        return false, "WRONGGEM"
    end
    return true
end

local function Recall_OnGemGiven(inst, giver, item)
    local portal_watch = SpawnPrefab("pocketwatch_portal")
	portal_watch:onPreBuilt(giver, {pocketwatch_recall = {[inst] = 1}})

    local container = inst.components.inventoryitem:GetContainer()
    if container ~= nil then
        local slot = inst.components.inventoryitem:GetSlotNum()
        inst:Remove()
        container:GiveItem(portal_watch, slot)
    else
        local x, y, z = inst.Transform:GetWorldPosition()
        inst:Remove()
        portal_watch.Transform:SetPosition(x, y, z)
    end
    portal_watch.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
end

local function Recall_OnBuiltFn(inst, builder)
	builder.components.builder:AddRecipe("pocketwatch_portal")
end

local function Recall_GetActionVerb(inst, doer, target)
	return inst:HasTag("recall_unmarked") and "RECALL_MARK"
			or "RECALL"
end

local RECALL_WATCH_TAGS = {"pocketwatch_warp_casting", "gemsocket"}

local function recallfn()
	local inst = PocketWatchCommon.common_fn("pocketwatch", "pocketwatch_recall", Recall_DoCastSpell, true, RECALL_WATCH_TAGS)

	inst.GetActionVerb_CAST_POCKETWATCH = Recall_GetActionVerb

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(Recall_ItemTradeTest)
    inst.components.trader.onaccept = Recall_OnGemGiven

	inst.OnBuiltFn = Recall_OnBuiltFn

	PocketWatchCommon.MakeRecallMarkable(inst)

    return inst
end

-------------------------------------------------------------------------------
local function warpmarker_SetMarkerViewer(inst, viewer)
    inst.Network:SetClassifiedTarget(viewer)
    if viewer ~= ThePlayer then
		-- hide it from the locally hosted server player
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)
    end
end

local function warpmarker_HideMarker(inst)
	if inst.inuse then
		inst.inuse = false
		inst.AnimState:PlayAnimation("mark"..inst.anim_id.."_pst")
		inst.AnimState:PushAnimation("off", false)
	end
end

local function warpmarker_ShowMarker(inst)
	inst.anim_id = math.random(4)
	inst.AnimState:PlayAnimation("mark"..inst.anim_id.."_pre")
	inst.AnimState:PushAnimation("mark"..inst.anim_id.."_loop", true)
	inst.inuse = true
	inst.Transform:SetRotation(math.random(360))
	inst:Show()
end

local function warpmarkerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("pocketwatch_warp_marker")
    inst.AnimState:SetBank("pocketwatch_warp_marker")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:PlayAnimation("off")
    inst.AnimState:SetMultColour(1.0, 1.0, 1.0, 0.6)

	inst:Hide()

	inst:AddTag("NOBLOCK")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	inst.SetMarkerViewer = warpmarker_SetMarkerViewer
	inst.ShowMarker = warpmarker_ShowMarker
	inst.HideMarker = warpmarker_HideMarker

    return inst
end

local function Warp_DoCastSpell(inst, doer)
	local tx, ty, tz = doer.components.positionalwarp:GetHistoryPosition(false)
	if tx ~= nil then
		inst.components.rechargeable:Discharge(TUNING.POCKETWATCH_WARP_COOLDOWN)
		doer.sg.statemem.warpback = {dest_x = tx, dest_y = ty, dest_z = tz}
		return true
	end

	return false, "WARP_NO_POINTS_LEFT"
end

local WARP_WATCH_TAGS = {"pocketwatch_warp", "pocketwatch_warp_casting"}

local function warp_hidemarker(inst)
	if inst.marker_owner ~= nil and inst.marker_owner:IsValid() then
		inst.marker_owner:PushEvent("hide_warp_marker")
	end
	inst.marker_owner = nil
end


local function warp_showmarker(inst)
	warp_hidemarker(inst)

	inst.marker_owner = inst.components.inventoryitem:GetGrandOwner()
	if inst.marker_owner ~= nil then
		inst.marker_owner:PushEvent("show_warp_marker")
	end
end

local function warpfn()
	local inst = PocketWatchCommon.common_fn("pocketwatch", "pocketwatch_warp", Warp_DoCastSpell, true, WARP_WATCH_TAGS)

	inst.GetActionVerb_CAST_POCKETWATCH = "WARP"

    if not TheWorld.ismastersim then
        return inst
    end

	inst:ListenForEvent("onputininventory", warp_showmarker)
	inst:ListenForEvent("onownerputininventory", warp_showmarker)
	inst:ListenForEvent("ondropped", warp_hidemarker)
	inst:ListenForEvent("onownerdropped", warp_hidemarker)
	inst:ListenForEvent("onremove", warp_hidemarker)

    return inst
end

--------------------------------------------------------------------------------

return Prefab("pocketwatch_heal", healfn, assets, prefabs),
		Prefab("pocketwatch_revive", revivefn, assets, prefabs),
		Prefab("pocketwatch_revive_reviver", revive_reviverfn),
		Prefab("pocketwatch_warp", warpfn, assets, prefabs),
		Prefab("pocketwatch_warp_marker", warpmarkerfn, {Asset("ANIM", "anim/pocketwatch_warp_marker.zip")}),
		Prefab("pocketwatch_recall", recallfn, assets, prefabs),
		Prefab("pocketwatch_recall_marker", recallmarkerfn, {Asset("ANIM", "anim/pocketwatch_warp_marker.zip")})
