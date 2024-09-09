
local CARNIVALGAME_COMMON = require "prefabs/carnivalgame_common"

local assets =
{
    Asset("ANIM", "anim/carnival_plaza.zip"),
    Asset("ANIM", "anim/carnival_plaza_floor.zip"),
	Asset("ANIM", "anim/firefighter_placement.zip"),
}

local prefabs =
{
	"carnival_crowkid",
	"carnivalgame_placementblocker",
	"yellow_leaves_chop",
	"orange_leaves_chop",
}

local function IsSafeToSpawnCrowKid(inst)
    return true -- check for danger
end

local function OnSpawnCrowKid(inst, child)
	child.sg:GoToState("glide")
end

local function chop_tree(inst, chopper, chopsleft, numchops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree"
        )
    end

    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)

    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab(math.random() < 0.5 and "orange_leaves_chop" or "yellow_leaves_chop").Transform:SetPosition(x, y + math.random(), z)
end

local function chop_down_tree_shake(inst)
	inst.SoundEmitter:PlaySound("summerevent/plaza/hit")
    ShakeAllCameras(CAMERASHAKE.FULL, .25, .03, .5, inst, 6)
end

local function chop_down_tree(inst, chopper)
    local pt = inst:GetPosition()

    local he_right = true
    if chopper then
        local hispos = chopper:GetPosition()
        he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0
    else
        if math.random() > 0.5 then
            he_right = false
        end
    end
    if he_right then
        inst.AnimState:PlayAnimation("fallright")
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
        inst.SoundEmitter:PlaySound("summerevent/plaza/fall")
    else
        inst.AnimState:PlayAnimation("fallleft")
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
        inst.SoundEmitter:PlaySound("summerevent/plaza/fall")
    end

	if inst.components.activatable ~= nil then
		inst.components.activatable.inactive = false
	end

	inst._choppeddown = true

	inst:RemoveTag("shelter")

	inst.persists = false
	inst:DoTaskInTime(14*FRAMES, chop_down_tree_shake)
	inst:ListenForEvent("animover", inst.Remove)
end

local function UpdateArtForRank(inst, rank, prev_rank, snap_animations)

	if rank >= 3 then
		if not snap_animations and inst.entity:IsAwake() then
			inst.AnimState:PlayAnimation("upgrade_2to3")
			inst.AnimState:PushAnimation("idle", true)
			inst.SoundEmitter:PlaySound("summerevent/plaza/upgrade_2to3")
		end

		inst.AnimState:Hide("trunk")
		inst.AnimState:Show("trunk_painted")

		inst.AnimState:Show("level2")
		inst.AnimState:Show("level3")

	elseif rank == 2 then
		if not snap_animations and inst.entity:IsAwake() then
			if rank > prev_rank then
				inst.AnimState:PlayAnimation("upgrade_1to2")
				inst.AnimState:PushAnimation("idle", true)
				inst.SoundEmitter:PlaySound("summerevent/plaza/upgrade_1to2")
			else
				inst.AnimState:PlayAnimation("downgrade_3to2")
				inst.AnimState:PushAnimation("idle", true)
				inst.SoundEmitter:PlaySound("summerevent/plaza/downgrade_3to2")
			end
		end

		inst.AnimState:Hide("trunk")
		inst.AnimState:Show("trunk_painted")

		inst.AnimState:Show("level2")
		inst.AnimState:Hide("level3")
	else -- rank == 1
		if not snap_animations and inst.entity:IsAwake() then
			if rank < prev_rank then
				inst.AnimState:PlayAnimation("downgrade_2to1")
				inst.AnimState:PushAnimation("idle", true)
				inst.SoundEmitter:PlaySound("summerevent/plaza/downgrade_2to1")
			end
		end

		inst.AnimState:Hide("trunk_painted")
		inst.AnimState:Show("trunk")

		inst.AnimState:Hide("level2")
		inst.AnimState:Hide("level3")
	end

end

local function onbuilt(inst, data)
	local rot = data ~= nil and data.rot or 0
	inst.Transform:SetRotation(rot)

    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:PlaySound("summerevent/plaza/place")
end

local function onrankchanged(inst, new_rank, prev_rank, snap_animations)
	if inst._choppeddown then
		return
	end

	UpdateArtForRank(inst, new_rank, prev_rank, snap_animations)

	if inst.components.childspawner ~= nil then
		local max_crows = new_rank + (new_rank == TUNING.CARNIVAL_DECOR_RANK_MAX and 1 or 0)
		if POPULATING then
			inst.components.childspawner.maxchildren = max_crows
		else
			inst.components.childspawner:SetMaxChildren(max_crows)
		end
		local totoal_children = inst.components.childspawner.childreninside + inst.components.childspawner.numchildrenoutside
		if totoal_children > max_crows then
			local delta = totoal_children - max_crows
			inst.components.childspawner.childreninside = math.max(0,  inst.components.childspawner.childreninside - delta)

			for i = max_crows + 1, inst.components.childspawner.numchildrenoutside do
				local child = next(inst.components.childspawner.childrenoutside)
				if child ~= nil then
					child.ShouldFlyAway = true
	                child:PushEvent("detachchild")
				end
			end
		end
	end
end

local function GetStatus(inst)
	return "LEVEL_" .. tostring(inst.components.carnivaldecorranker.rank)
end

local function onremove(inst)
    if TheWorld.components.carnivalevent then
        TheWorld.components.carnivalevent:UnregisterPlaza(inst)
    end
end


local function CreateFloor(parent)
	local inst = CreateEntity()

	--[[Non-networked entity]]
	inst.entity:SetCanSleep(false)
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("CLASSIFIED")
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")
	inst:AddTag("event_trigger")

	--local s = .9
	--inst.Transform:SetScale(s, s, s)

	inst.AnimState:SetBank("carnival_plaza_floor")
	inst.AnimState:SetBuild("carnival_plaza_floor")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(-2)

	inst.entity:SetParent(parent.entity)
	if parent.components.placer ~= nil then
		parent.components.placer:LinkEntity(inst, 0.25)
	end

	inst:ListenForEvent("onbuilt", function() inst.AnimState:PlayAnimation("place") inst.AnimState:PushAnimation("idle", false) end, parent)

	return inst
end

local function GetActivateVerb(inst, doer)
	return "SUMMONHOST"
end

local function UpdateGameMusic(inst)
	if ThePlayer ~= nil and ThePlayer:IsValid() and ThePlayer:IsNear(inst, TUNING.CARNIVAL_THEME_MUSIC_RANGE) then
		ThePlayer:PushEvent("playcarnivalmusic", false)
	end
end

local function OnEntityWake(inst)
	if not TheNet:IsDedicated() then
		inst._musiccheck = inst:DoPeriodicTask(1, UpdateGameMusic)
	end
end

local function OnEntitySleep(inst)
	if inst._musiccheck ~= nil then
		inst._musiccheck:Cancel()
		inst._musiccheck = nil
	end
end

local function OnActivate(inst, doer)
	if inst._choppeddown then
		return false
	end

	inst.AnimState:PlayAnimation("ringing")
	inst.SoundEmitter:PlaySound("summerevent/plaza/ringing")
	inst.AnimState:PushAnimation("idle", true)
	
	inst.components.activatable.inactive = true
    if TheWorld.components.carnivalevent then
        return TheWorld.components.carnivalevent:SummonHost(inst)
    end
    return false, "NOCARNIVAL"
end

-- Deploy helper ring that shows up when placing decor items
local function DeployHelperRing_OnUpdate(helperinst)
	helperinst.parent.highlited = nil

	if not helperinst.placerinst:IsValid() then
		helperinst.components.updatelooper:RemoveOnUpdateFn(DeployHelperRing_OnUpdate)
		helperinst.AnimState:SetAddColour(0, 0, 0, 0)
	elseif helperinst.placerinst:GetCurrentPlatform() == nil and helperinst:IsNear(helperinst.placerinst, TUNING.CARNIVAL_DECOR_RANK_RANGE) then
		helperinst.AnimState:SetAddColour(.25, .75, .25, 0)
		helperinst.parent.highlited = true
	else
		helperinst.AnimState:SetAddColour(0, 0, 0, 0)
	end
end

local function CreateDeployHelperRing()
    local inst = CreateEntity()

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")

    inst.AnimState:SetBank("firefighter_placement")
    inst.AnimState:SetBuild("firefighter_placement")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetAddColour(0, .2, .5, 0)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
	inst.AnimState:SetScale(1.3, 1.3)

    return inst
end

local function OnEnableHelper(inst, enabled, recipename, placerinst)
	if enabled then
		if inst.helper == nil then
			inst.helper = CreateDeployHelperRing()
			inst.helper.parent = inst
			inst.helper.entity:SetParent(inst.entity)
			if placerinst ~= nil then
				inst.helper:AddComponent("updatelooper")
				inst.helper.components.updatelooper:AddOnUpdateFn(DeployHelperRing_OnUpdate)
				inst.helper.placerinst = placerinst
				DeployHelperRing_OnUpdate(inst.helper)
			end
		end
	elseif inst.helper ~= nil then
		inst.helper:Remove()
		inst.helper = nil
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --match kit item
    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("carnival_plaza.png")

    inst.AnimState:SetBank("carnival_plaza")
    inst.AnimState:SetBuild("carnival_plaza")
    inst.AnimState:PlayAnimation("idle", true)

	inst:AddTag("carnivaldecor_ranker")
	inst:AddTag("carnival_plaza")
    inst:AddTag("structure")
	inst:AddTag("carnivalgame_part")
    inst:AddTag("shelter")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

	inst.GetActivateVerb = GetActivateVerb

	if not TheNet:IsDedicated() then
		CreateFloor(inst)

		inst:AddComponent("deployhelper")
		inst.components.deployhelper:AddKeyFilter("carnival_plaza_decor")
		inst.components.deployhelper.onenablehelper = OnEnableHelper
	end

    if not TheWorld.ismastersim then
		inst._musiccheck = inst:DoPeriodicTask(1, UpdateGameMusic)

        return inst
    end

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("savedrotation")
	inst:AddComponent("lootdropper")

	inst:AddComponent("carnivaldecorranker")
	inst.components.carnivaldecorranker.onrankchanged = onrankchanged

	if IsSpecialEventActive(SPECIAL_EVENTS.CARNIVAL) then
		inst:AddComponent("activatable")
		inst.components.activatable.standingaction = true
		inst.components.activatable.OnActivate = OnActivate

		if TheWorld.components.carnivalevent ~= nil then
			inst:DoTaskInTime(0, function()
				if TheWorld.components.carnivalevent then
					TheWorld.components.carnivalevent:RegisterPlaza(inst)
				end
			end)
			inst:ListenForEvent("onremove", onremove)

			inst:AddComponent("childspawner")
			inst.components.childspawner.childname = "carnival_crowkid"
			inst.components.childspawner:SetMaxChildren(1)
			inst.components.childspawner.childreninside = 0
			inst.components.childspawner:SetRegenPeriod(4, 0)
			inst.components.childspawner:SetSpawnPeriod(5, 5)
			inst.components.childspawner.allowboats = false
			inst.components.childspawner.spawnradius = {min = 2, max = 6}
			inst.components.childspawner.spawn_height = 30
			inst.components.childspawner.canspawnfn = IsSafeToSpawnCrowKid
			inst.components.childspawner:SetSpawnedFn(OnSpawnCrowKid)
			inst.components.childspawner:StartSpawning()
		end
	end

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetOnWorkCallback(chop_tree)
    inst.components.workable:SetOnFinishCallback(chop_down_tree)

    MakeSnowCovered(inst)

	UpdateArtForRank(inst, 1, 1, true)

	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep

    inst:ListenForEvent("onbuilt", onbuilt)

	local r = 5
	for i = 0, 8 do
		CARNIVALGAME_COMMON.CreateGameBlocker(inst, r * math.sin(i * 45*DEGREES), r * math.cos(i * 45*DEGREES))
	end

    return inst
end

local CARNIVALGAMEPART_TAG = {"carnivalgame_part"}
local deployable_data =
{
	deploymode = DEPLOYMODE.CUSTOM,
	custom_candeploy_fn = function(inst, pt, mouseover, deployer)
		local x, y, z = pt:Get()
		local r = 6
		for i = 0, 8 do
			if not TheWorld.Map:IsAboveGroundAtPoint(x + r * math.sin(i * 45*DEGREES), 0, z + r * math.cos(i * 45*DEGREES), false) then
				return false
			end
		end

		return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover) and TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false) and TheSim:CountEntities(x, y, z, 8, CARNIVALGAMEPART_TAG) == 0
	end,
}

local function placerdecor(inst)
	CreateFloor(inst)
end

return Prefab("carnival_plaza", fn, assets, prefabs),
		MakeDeployableKitItem("carnival_plaza_kit", "carnival_plaza", "carnival_plaza", "carnival_plaza", "kit_item", assets, {size = "med", scale = 0.77}, nil, {fuelvalue = TUNING.LARGE_FUEL}, deployable_data),
		MakePlacer("carnival_plaza_kit_placer", "carnival_plaza", "carnival_plaza", "idle", nil, nil, nil, nil, 90, nil, placerdecor)
