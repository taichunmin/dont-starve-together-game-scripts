local assets =
{
    Asset("ANIM", "anim/scrappile.zip"),
	Asset("MINIMAP_IMAGE", "junk_pile"),
}

local prefabs =
{
	"junk_break_fx",
    "storage_robot",
}

---------------------------------------------------------------------------------------------------

local CRITTER_SPAWN_CHANCE = 0.1
local LOOT_PERISHABLE_PERCENT = 0.25

local RUMMAGE_SOUND_NAME = "rummage"
local START_PICKING_LOOT_TIME = 0.2
local NUM_VARIANCES = 3

---------------------------------------------------------------------------------------------------

local EMPTY = "EMPTY"

local LOOT = {
    CRITTERS = {
        { weight=4, prefab = "spider",         targetplayer=true, state="warrior_attack" }, -- 57.14%
        { weight=1, prefab = "spider_warrior", targetplayer=true, state="warrior_attack" }, -- 14.29%
        { weight=2, prefab = "catcoon",        targetplayer=true, state="pounceattack"   }, -- 28.57%
        { weight=2, prefab = "mole",                              state="peek"           }, -- 28.57%
    },

    ITEMS = {
        { weight=8, prefab = EMPTY          }, -- 25%
        { weight=8, prefab = "wagpunk_bits" }, -- 25%
        { weight=4, prefab = "rocks"        }, -- 12.5%
        { weight=4, prefab = "log"          }, -- 12.5%
        { weight=2, prefab = "boards"       }, -- 6.25%
        { weight=2, prefab = "potato"       }, -- 6.25%
        { weight=1, prefab = "transistor"   }, -- 3.125%
        { weight=1, prefab = "trinket_6"    }, -- 3.125%
        { weight=1, prefab = "blueprint"    }, -- 3.125%
        { weight=1, prefab = "gears"        }, -- 3.125%
    },
}

local WEIGHTED_CRITTER_TABLE = {}
local WEIGHTED_ITEM_TABLE = {}

for _, critter in ipairs(LOOT.CRITTERS) do
    WEIGHTED_CRITTER_TABLE[critter] = critter.weight

    if critter.prefab ~= EMPTY then
        table.insert(prefabs, critter.prefab)
    end
end

for _, item in ipairs(LOOT.ITEMS) do
    WEIGHTED_ITEM_TABLE[item] = item.weight

    if item.prefab ~= EMPTY then
        table.insert(prefabs, item.prefab)
    end
end

---------------------------------------------------------------------------------------------------

local function UpdatePhysics(inst, workleft)
	local radius = workleft < 2 and 0.5 or 1
	if inst.Physics:GetRadius() ~= radius then
		inst.Physics:SetCapsule(radius, 2)
	end
end

local function GetAnimLevel(inst, workleft)
	return (workleft > 2 and tostring(inst.variant_num))
		or (workleft > 1 and "med")
		or "low"
end

local function UpdateArt(inst, workleft)
	workleft = workleft or inst.components.workable:GetWorkLeft()

	inst.AnimState:PlayAnimation("idle"..GetAnimLevel(inst, workleft))

	UpdatePhysics(inst, workleft)
end

local function Shake(inst, workleft, nosound)
	workleft = workleft or inst.components.workable:GetWorkLeft()

	local animlevel = GetAnimLevel(inst, workleft)
	if inst._pickingloop then
		inst.AnimState:PlayAnimation("loop"..animlevel, true)
	else
		inst.AnimState:PlayAnimation("loop"..animlevel)
		inst.AnimState:PushAnimation("idle"..animlevel, false)
	end

	if not nosound then
		inst.SoundEmitter:PlaySound("qol1/wagstaff_ruins/rummagepile_pst")
	end

	UpdatePhysics(inst, workleft)
end

local function WorkMultiplierFn(inst, worker, numworks)
	return worker:HasTag("junk") and 0 or nil
end

local JUNK_MOB_TAGS = { "junkmob" }

local function SpawnLootForWorkedLevels(inst, worker, workleft, numwork)
	local new_level = math.ceil(workleft)
	local old_level = math.ceil(math.min(workleft + numwork, TUNING.JUNK_PILE_STAGES))
	for i = new_level, old_level - 1 do
		inst:SpawnLoot(worker)
	end
end

local function OnWork(inst, worker, workleft, numwork)
	local x, y, z
	local workerisjunkmob = worker:HasTag("junkmob")
	if numwork == 0 then
		if worker:HasTag("junk") then
			--junk piles up
			workleft = math.min(workleft + 1, TUNING.JUNK_PILE_STAGES)
			inst.components.workable:SetWorkLeft(workleft)
			inst:Shake(workleft, true)
			return
		elseif workerisjunkmob then
			x, y, z = inst.Transform:GetWorldPosition()
			local x1, y1, z1 = worker.Transform:GetWorldPosition()
			if x ~= x1 or z ~= z1 then
				local dx = x1 - x
				local dz = z1 - z
				local distscale = inst:GetPhysicsRadius(0) / math.sqrt(dx * dx + dz * dz)
				x1 = x + dx * distscale
				z1 = z + dz * distscale
			end
			SpawnPrefab("junk_break_fx").Transform:SetPosition(x1, y, z1)
			inst:CancelPicking(worker, true)
			inst:Shake(workleft, true)
		end
	end

	if (worker.components.follower and worker.components.follower:GetLeader() or worker).isplayer then
		if x == nil then
			x, y, z = inst.Transform:GetWorldPosition()
		end
		for i, v in ipairs(TheSim:FindEntities(x, y, z, 16, JUNK_MOB_TAGS)) do
			v:PushEvent("ms_junkstolen", worker)
		end
	end

    if workleft <= 0 then
		SpawnPrefab("junk_break_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
		if not workerisjunkmob then
			SpawnLootForWorkedLevels(inst, worker, workleft, numwork)
		end
        inst:Remove()
        return
    end

	inst:CancelPicking(worker, true)
	inst:Shake(workleft)

	if not workerisjunkmob then
		SpawnLootForWorkedLevels(inst, worker, workleft, numwork)
	end
end

local function SetRandomStage(inst)
    local rand = math.random()
    local workleft = rand <= 0.2 and 1 or rand <= 0.4 and 2 or 3

    inst.components.workable:SetWorkLeft(workleft)

    inst:UpdateArt(workleft)
end

---------------------------------------------------------------------------------------------------

local function OnSave(inst, data)
    if inst.variant_num ~= nil then
        data.variant_num = inst.variant_num
    end
end

local function OnLoad(inst, data)
    if data == nil then
        return
    end

    if data.variant_num ~= nil then
        inst.variant_num = data.variant_num
        inst:UpdateArt()
    end

    if data.random then -- Note: this is set by world gen.
        inst:SetRandomStage()
    end
end

---------------------------------------------------------------------------------------------------

local function SpawnLoot(inst, digger, nopickup)
    if math.random() <= CRITTER_SPAWN_CHANCE then
        local choice = weighted_random_choice(WEIGHTED_CRITTER_TABLE)

        if choice.prefab ~= nil and choice.prefab ~= EMPTY then
            local critter = SpawnPrefab(choice.prefab)

            inst.components.lootdropper:FlingItem(critter)

            if choice.targetplayer and critter.components.combat ~= nil then
                critter.components.combat:SetTarget(digger)
            end

            SpawnPrefab("junk_break_fx").Transform:SetPosition(critter.Transform:GetWorldPosition())

            if choice.state ~= nil then
                critter.sg:GoToState(choice.state, digger)
            end
        end
    end

    local choice = weighted_random_choice(WEIGHTED_ITEM_TABLE)

    if choice.prefab ~= nil and choice.prefab ~= EMPTY then
        local item = SpawnPrefab(choice.prefab)

        if item.components.perishable ~= nil then
            item.components.perishable:SetPercent(LOOT_PERISHABLE_PERCENT)
        end

		if not nopickup and digger.components.inventory and digger.components.inventory:IsOpenedBy(digger) then
            digger.components.inventory:GiveItem(item, nil, inst:GetPosition())
        else
            inst.components.lootdropper:FlingItem(item)
        end
    end
end

---------------------------------------------------------------------------------------------------

local function StartPickingLoot(inst)
    if inst._pickingtask ~= nil then
        inst._pickingtask:Cancel()
        inst._pickingtask = nil
    end
	inst._pickingloop = true

    local workleft = inst.components.workable:GetWorkLeft()

    inst.SoundEmitter:PlaySound(
        (workleft > 2 and "qol1/wagstaff_ruins/rummagepile_lrg") or 
        (workleft > 1 and "qol1/wagstaff_ruins/rummagepile_med") or
        (workleft >= 0 and "qol1/wagstaff_ruins/rummagepile_sml") ,
        RUMMAGE_SOUND_NAME
    )

	inst.AnimState:PlayAnimation("loop"..GetAnimLevel(inst, workleft), true)
end

local function StopPickingLoot(inst, nosound)
    if inst._pickingtask ~= nil then
        inst._pickingtask:Cancel()
        inst._pickingtask = nil

        return -- Loop hadn't actually started yet.
    end
	inst._pickingloop = nil

    inst.SoundEmitter:KillSound(RUMMAGE_SOUND_NAME)
	if not nosound then
		inst.SoundEmitter:PlaySound("qol1/wagstaff_ruins/rummagepile_pst", nil, 0.3)
	end

    inst:UpdateArt()
end

local function OnStartPicking(inst, doer)
    if inst._pickingtask == nil then
        inst._pickingtask = inst:DoTaskInTime(START_PICKING_LOOT_TIME, StartPickingLoot)
    end

    inst._pickers = inst._pickers or {}

    if inst._pickers[doer] ~= nil then
        return
    end

    local pickingstate = doer.sg.currentstate.name

    local cb = function(doer, data)
        if not (data and data.statename == pickingstate) then
            inst:CancelPicking(doer)
        end
    end

    inst._pickers[doer] = cb

    inst:ListenForEvent("newstate", cb, doer)
    inst:ListenForEvent("onremove", cb, doer)
end

local function CancelPicking(inst, doer, nosound)
	local cb = inst._pickers and inst._pickers[doer] or nil
	if cb == nil then
		return
	end

    inst:RemoveEventCallback("newstate", cb, doer)
    inst:RemoveEventCallback("onremove", cb, doer)
    inst._pickers[doer] = nil

    if next(inst._pickers) == nil then
        inst._pickers = nil
		inst:StopPickingLoot(nosound)
    end
end

---------------------------------------------------------------------------------------------------

local function OnPickedFn(inst, digger)
    inst.components.workable:WorkedBy(digger, 1)
end

---------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.MiniMapEntity:SetIcon("junk_pile.png")

    inst.AnimState:SetBank("scrappile")
    inst.AnimState:SetBuild("scrappile")
    inst.AnimState:PlayAnimation("idle1")

	inst:AddTag("junk_pile")
    inst:AddTag("pickable_rummage_str")
	inst:AddTag("NPC_workable")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local colour = 0.5 + math.random() * 0.5
    inst.AnimState:SetMultColour(colour, colour, colour, 1)

    inst.variant_num = math.random(NUM_VARIANCES)

	inst._runcollisions = {}

    -- Mods
    inst.SpawnLoot = SpawnLoot
    inst.UpdateArt = UpdateArt
	inst.Shake = Shake
    inst.SetRandomStage = SetRandomStage
    inst.StartPickingLoot = StartPickingLoot
    inst.StopPickingLoot  = StopPickingLoot
    inst.OnStartPicking = OnStartPicking
    inst.CancelPicking  = CancelPicking

    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")

    inst:AddComponent("pickable")
    inst.components.pickable:SetUp(nil, 0)
    inst.components.pickable.onpickedfn = OnPickedFn
    inst.components.pickable.max_cycles  = TUNING.JUNK_PILE_STAGES
    inst.components.pickable.cycles_left = TUNING.JUNK_PILE_STAGES
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"

    inst:AddComponent("workable")
    inst.components.workable.savestate = true
	inst.components.workable:SetWorkAction(nil)
    inst.components.workable:SetWorkLeft(TUNING.JUNK_PILE_STAGES)
	inst.components.workable:SetWorkMultiplierFn(WorkMultiplierFn)
    inst.components.workable:SetOnWorkCallback(OnWork)

    inst:ListenForEvent("startlongaction", inst.OnStartPicking)

    inst:UpdateArt()

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("junk_pile", fn, assets, prefabs)
