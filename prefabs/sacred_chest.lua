require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/ui_chest_3x2.zip"),
    Asset("ANIM", "anim/sacred_chest.zip"),
}

local prefabs =
{
	"statue_transition",
	"statue_transition_2",
}

local offering_recipe =
{
	ruinsrelic_plate_blueprint		= { "nightmare_timepiece", "cutstone", "nightmarefuel", "petals", "berries", "carrot" },
	ruinsrelic_chipbowl_blueprint	= { "nightmare_timepiece", "cutstone", "nightmarefuel", "carrot", "berries", "petals" },
	ruinsrelic_bowl_blueprint		= { "nightmare_timepiece", "cutstone", "nightmarefuel", "rabbit", "carrot", "petals" },
	ruinsrelic_vase_blueprint		= { "nightmare_timepiece", "cutstone", "nightmarefuel", "redgem", "butterfly", "petals" },
	ruinsrelic_chair_blueprint		= { "nightmare_timepiece", "cutstone", "nightmarefuel", "purplegem", "rabbit", "petals"},
	ruinsrelic_table_blueprint		= { "nightmare_timepiece", "cutstone", "nightmarefuel", "purplegem", "crow", "rabbit" },
}

for k, _ in pairs(offering_recipe) do
	table.insert(prefabs, k)
end

local function CheckOffering(items)
	for k, recipe in pairs(offering_recipe) do
		local valid = true
		for i, item in ipairs(items) do
			if recipe[i] ~= item.prefab then
				valid = false
				break
			end
		end
		if valid then
			return k
		end
	end

	return nil
end


local MIN_LOCK_TIME = 2.5

local function UnlockChest(inst, param, doer)
	inst:DoTaskInTime(math.max(0, MIN_LOCK_TIME - (GetTime() - inst.lockstarttime)), function()
	    inst.SoundEmitter:KillSound("loop")

		if param == 1 then
			inst.AnimState:PushAnimation("closed", false)
			inst.components.container.canbeopened = true
			if doer ~= nil and doer:IsValid() and doer.components.talker ~= nil then
				doer.components.talker:Say(GetString(doer, "ANNOUNCE_SACREDCHEST_NO"))
			end
		elseif param == 3 then
			inst.AnimState:PlayAnimation("open")
		    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
			SpawnPrefab("statue_transition").Transform:SetPosition(inst.Transform:GetWorldPosition())
			SpawnPrefab("statue_transition_2").Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst:DoTaskInTime(0.75, function()
				inst.AnimState:PlayAnimation("close")
			    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
				inst.components.container.canbeopened = true

				if doer ~= nil and doer:IsValid() and doer.components.talker ~= nil then
					doer.components.talker:Say(GetString(doer, "ANNOUNCE_SACREDCHEST_YES"))
				end
				TheNet:Announce(STRINGS.UI.HUD.REPORT_RESULT_ANNOUCEMENT)
			end)
		else
			inst.AnimState:PlayAnimation("open")
		    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
			inst:DoTaskInTime(.2, function()
				inst.components.container:DropEverything()
				inst:DoTaskInTime(0.2, function()
					inst.AnimState:PlayAnimation("close")
				    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
					inst.components.container.canbeopened = true

					if doer ~= nil and doer:IsValid() and doer.components.talker ~= nil then
						doer.components.talker:Say(GetString(doer, "ANNOUNCE_SACREDCHEST_NO"))
					end
				end)
			end)
		end
	end)

	if param == 3 then
		inst.components.container:DestroyContents()
	end
end

local function LockChest(inst)
	inst.components.container.canbeopened = false
	inst.lockstarttime = GetTime()
	inst.AnimState:PlayAnimation("hit", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/sacred_chest/shake_LP", "loop")
end

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function DoNetworkOffering(inst, doer)
	if (not TheNet:IsOnlineMode()) or
		(not inst.components.container:IsFull()) or
		doer == nil or
		not doer:IsValid() then
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
		return
	end

	LockChest(inst)

	local x, y, z = inst.Transform:GetWorldPosition()
	local players = FindPlayersInRange(x, y, z, 40)
	if #players <= 1 then
		UnlockChest(inst, 2, doer)
		return
	end

	local items = {}
	local counts = {}
	for i, k in ipairs(inst.components.container.slots) do
		if k ~= nil then
			table.insert(items, k.prefab)
			table.insert(counts, k.components.stackable ~= nil and k.components.stackable:StackSize() or 1)
		end
    end

	local userids = {}
	for i,p in ipairs(players) do
		if p ~= doer and p.userid then
			table.insert(userids, p.userid)
		end
	end

	ReportAction(doer.userid, items, counts, userids, function(param) if inst:IsValid() then UnlockChest(inst, param, doer) end end)
end

local function DoLocalOffering(inst, doer)
	if inst.components.container:IsFull() then
		local rewarditem = CheckOffering(inst.components.container.slots)
		if rewarditem then
			LockChest(inst)
			inst.components.container:DestroyContents()
			inst.components.container:GiveItem(SpawnPrefab(rewarditem))
			inst.components.timer:StartTimer("localoffering", MIN_LOCK_TIME)
			return true
		end
	end

	return false
end

local function OnLocalOffering(inst)
	inst.AnimState:PlayAnimation("open")
	inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    inst.components.timer:StartTimer("localoffering_pst", 0.2)
end

local function OnLocalOfferingPst(inst)
	inst.components.container:DropEverything()
	inst:DoTaskInTime(0.2, function()
		inst.AnimState:PlayAnimation("close")
	    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
		inst.components.container.canbeopened = true
	end)
end

local function onclose(inst, doer)
    inst.AnimState:PlayAnimation("close")

	if not DoLocalOffering(inst, doer) then
		DoNetworkOffering(inst, doer)
	end
end

local function OnTimerDone(inst, data)
	if data ~= nil then
		if data.name == "localoffering" then
			OnLocalOffering(inst)
		elseif data.name == "localoffering_pst" then
			OnLocalOfferingPst(inst)
		end

	end
end

local function getstatus(inst)
    return (inst.components.container.canbeopened == false and "LOCKED") or
			nil
end

local function OnLoadPostPass(inst)
    if inst.components.timer:TimerExists("localoffering") then
    	LockChest(inst)
    elseif inst.components.timer:TimerExists("localoffering_pst") then
    	LockChest(inst)
    	inst.components.timer:StopTimer("localoffering_pst")
    	OnLocalOffering(inst)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sacred_chest.png")

    inst:AddTag("chest")
    inst.AnimState:SetBank("sacred_chest")
    inst.AnimState:SetBuild("sacred_chest")
    inst.AnimState:PlayAnimation("closed")
    inst.scrapbook_anim = "closed"
    inst.scrapbook_specialinfo = "SACREDCHEST"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("sacred_chest")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)

	inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("sacred_chest", fn, assets, prefabs)
