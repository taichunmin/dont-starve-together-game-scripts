local assets =
{
    Asset("ANIM", "anim/carnival_host.zip"),
}

local prefabs =
{
    "carnival_gametoken",
	"carnival_prizeticket",
    "carnival_prizebooth",
}

local brain = require "brains/carnival_hostbrain"

local function AddPlazaWares(inst)
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.CARNIVAL_HOSTSHOP_PLAZA
end

local function RemovePlazaWares(inst)
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.CARNIVAL_HOSTSHOP_WANDER
end

local function DoPrototyperChatter(inst)
	local chatlines =  inst.hassold_plaza and "CARNIVAL_HOST_SELL_GENERIC" or "CARNIVAL_HOST_SELL_PLAZA"
    local strtbl = STRINGS[chatlines]
    if strtbl ~= nil then
        local strid = math.random(#strtbl)
        inst.components.talker:Chatter(chatlines, strid)

		if inst.prototyper_chatter_task ~= nil then
			inst.prototyper_chatter_task:Cancel()
		end
		inst.prototyper_chatter_task = inst:DoTaskInTime(5 + math.random() * 5, DoPrototyperChatter)
    end
end

local function prototyper_onturnon(inst)
	if not inst.components.minigame_spectator then
		inst.components.locomotor:StopMoving()
		if inst.brain ~= nil then
			inst.brain:ForceUpdate()
		end
		DoPrototyperChatter(inst)
	end
end

local function prototyper_onturnoff(inst)
	if inst.prototyper_chatter_task ~= nil then
		inst.prototyper_chatter_task:Cancel()
		inst.prototyper_chatter_task = nil
	end
end

local function prototyper_onactivate(inst, doer, recipe)
	if recipe ~= nil then
		if recipe.name == "carnival_plaza_kit" then
			if not inst.hassold_plaza then
				inst.hassold_plaza = true
				AddPlazaWares(inst)
				DoPrototyperChatter(inst)
			end
		elseif recipe.name == "carnival_prizebooth_kit" then
			inst.hassold_prizebooth = true
		end
	end
end

local function SummonCooldownTask(inst)
	inst.summoncooldown = nil
end

local MAX_WANDER_DIST_SQ = 15*15

local function OnSummonedToPlaza(inst, plaza)
	if plaza == nil or plaza == nil or not plaza:HasTag("carnival_plaza") then
		return false
	end

	local cur_home = inst.components.knownlocations:GetLocation("home")
	local new_home = plaza:GetPosition()

	--if cur_home == new_home and inst:GetDistanceSqToPoint(new_home.x, new_home.y, new_home.z) <= MAX_WANDER_DIST_SQ then
	--	return false, "CARNIVAL_HOST_HERE"
	--end

	if inst.summoncooldown ~= nil or inst:HasTag("busy") or inst.sg:HasStateTag("flight") then
		return false, "HOSTBUSY"
	end

    inst.hassold_plaza = true
	inst.hasbeento_plaza = true
	AddPlazaWares(inst)

	inst.components.knownlocations:RememberLocation("home", new_home)
	inst.summoncooldown = inst:DoTaskInTime(15, SummonCooldownTask)

	if inst:IsAsleep() then
		inst.sg:GoToState("glide")
	else
		--if cur_home == nil or inst:GetDistanceSqToPoint(new_home.x, new_home.y, new_home.z) > MAX_WANDER_DIST_SQ then
			inst.sg:GoToState("flyaway")
		--end
	end

	return true
end

local function OnFirstPlazaBuiltImpl(inst, plaza)
    inst.hassold_plaza = true
	inst.hasbeento_plaza = true
	AddPlazaWares(inst)
	inst:RemoveEventCallback("ms_carnivalplazabuilt", inst.OnFirstPlazaBuilt, TheWorld)
	OnSummonedToPlaza(inst, plaza)
end

local function OnSave(inst, data)
    data.hassold_plaza = inst.hassold_plaza
    data.hassold_prizebooth = inst.hassold_prizebooth
	data.hasbeento_plaza = inst.hasbeento_plaza
end

local function OnLoad(inst, data)
    inst.hassold_plaza = data.hassold_plaza
    inst.hassold_prizebooth = data.hassold_prizebooth
	inst.hasbeento_plaza = data.hasbeento_plaza

	if inst.hassold_plaza then
		AddPlazaWares(inst)
	end
	if inst.hasbeento_plaza then
		inst:RemoveEventCallback("ms_carnivalplazabuilt", inst.OnFirstPlazaBuilt, TheWorld)
	end
end

local function OnLoadPostPass(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
	if y > 0.1 then
		inst.Transform:SetPosition(x, 0, z)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("carnival_host")
    inst.AnimState:SetBuild("carnival_host")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 30
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(165/255, 180/255, 200/255)
    inst.components.talker.offset = Vector3(0, -600, 0)
    inst.components.talker:MakeChatter()

    inst:AddTag("character")

	inst.MiniMapEntity:SetIcon("carnival_host.png")
	inst.MiniMapEntity:SetPriority(5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.givenplazakit = false

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2 -- this is modified throughtout the walk cycle

    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = prototyper_onturnon
    inst.components.prototyper.onturnoff = prototyper_onturnoff
    inst.components.prototyper.onactivate = prototyper_onactivate
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.CARNIVAL_HOSTSHOP_WANDER

    inst:AddComponent("knownlocations")

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    MakeHauntablePanic(inst)

	inst.OnFirstPlazaBuilt = function(world, plaza) OnFirstPlazaBuiltImpl(inst, plaza) end
	inst.SummonedToPlaza = OnSummonedToPlaza

    inst:ListenForEvent("ms_carnivalplazabuilt", inst.OnFirstPlazaBuilt, TheWorld)

    inst:SetStateGraph("SGcarnival_host")
    inst:SetBrain(brain)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

	if not IsSpecialEventActive(SPECIAL_EVENTS.CARNIVAL) then
		inst:DoTaskInTime(0, inst.Remove)
	end

    return inst
end

return Prefab("carnival_host", fn, assets, prefabs)
