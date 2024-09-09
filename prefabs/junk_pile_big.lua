local assets =
{
	Asset("ANIM", "anim/scrappile.zip"),
}

local assets_big = {
	Asset("ANIM", "anim/scrappile.zip"),
	Asset("MINIMAP_IMAGE", "junk_pile_big"),
}

local prefabs =
{
	"junk_pile_side",
	"junkball_fx",
	"junk_break_fx",
	"daywalker2",
}

local SIDE_SPAWN_RADIUS = 2
local SIDE_ANGLE_OFFSET = 36--degrees
local HEAD_SPAWN_RADIUS = 1.8
local HEAD_ANGLE_OFFSET = 45--degrees

-- Loot copy paste from junk_pile this should be in its own common if they are to remain the same.
local CRITTER_SPAWN_CHANCE = 0.1
local LOOT_PERISHABLE_PERCENT = 0.25

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
-- Loot

local function spawn_sides(inst)
	inst.sides = {}

	local angles =
	{
		PI2 * 0.1,
		PI2 * 0.35,
		PI2 * 0.60,
		PI2 * 0.85,
	}
	for i = 1, 4 do
		local side = SpawnPrefab("junk_pile_side")
		local angle = (90 * i + SIDE_ANGLE_OFFSET) * DEGREES
		side.Transform:SetPosition(SIDE_SPAWN_RADIUS * math.cos(angle), 0, -SIDE_SPAWN_RADIUS * math.sin(angle))
		side.entity:SetParent(inst.entity)
		table.insert(inst.sides, side)
		table.insert(inst.highlightchildren, side)
	end
end

local function set_variations(inst, variations)
	variations = variations or math.random(0, 0xF)
	inst.variations = variations

	for i, v in ipairs(inst.sides) do
		local variation = (variations % 2) == 1 and "1" or "2"
		variations = math.floor(variations / 2)
		if v.variation ~= variation then
			v.variation = variation
			v.AnimState:PlayAnimation("side_idle"..tostring(variation))
		end
	end
end

local function spawn_daywalker(inst, side, state)
	inst.daywalker_side = side
	inst.daywalker_state = state
	if state then
		inst.sides[side]:Hide()

		local x, y, z = inst.Transform:GetWorldPosition()
		local angle = 90 * side + HEAD_ANGLE_OFFSET

		inst.daywalker = SpawnPrefab("daywalker2")
		inst.daywalker.Transform:SetRotation(angle)
		angle = angle * DEGREES
		inst.daywalker.Transform:SetPosition(x + HEAD_SPAWN_RADIUS * math.cos(angle), 0, z - HEAD_SPAWN_RADIUS * math.sin(angle))
		inst.daywalker:MakeBuried(inst)
		inst.daywalker.sg.mem.level = state
        if inst.shaketask ~= nil then
            inst.shaketask:Cancel()
            inst.shaketask = nil
        end
	end
	--otherwise daywalker is already freed and prefab persists
end

local function startpickingloop(inst)
	inst._pickingtask = nil
	inst._pickingloop = true

	for k, v in pairs(inst._pickers) do
		if k:HasTag("junkmob") then
			inst._mobloop = true
			break
		end
	end
	inst.SoundEmitter:PlaySound(inst._mobloop and "qol1/daywalker_scrappy/rummage_lp" or "qol1/wagstaff_ruins/rummagepile_lrg", "rummage")
	inst.AnimState:PlayAnimation("loopbig", true)

	if inst.sides then
		for i, v in ipairs(inst.sides) do
			v.AnimState:PlayAnimation("loopside"..tostring(v.variation), true)
			v.AnimState:SetFrame(math.random(v.AnimState:GetCurrentAnimationNumFrames()) - 1)
		end
	end
	if inst.daywalker_side and inst.daywalker_state == 2 then
		inst.daywalker.sg:GoToState("tryemerge")
	end
end

local function stoppickingloop(inst)
	if inst._pickingtask then
		inst._pickingtask:Cancel()
		inst._pickingtask = nil
		return --loop hadn't actually started yet
	end
	inst._pickingloop = nil
	inst._mobloop = nil

	inst.SoundEmitter:KillSound("rummage")
	inst.SoundEmitter:PlaySound("qol1/wagstaff_ruins/rummagepile_pst", nil, 0.3)

	inst.AnimState:PlayAnimation("big_idle")

	if inst.sides then
		for i, v in ipairs(inst.sides) do
			v.AnimState:PlayAnimation("side_idle"..tostring(v.variation))
		end
	end
	if inst.daywalker and inst.daywalker.sg.currentstate.name == "tryemerge" then
		inst.daywalker.sg:GoToState("cancelemerge")
	end
end

local function cancelpicker(inst, doer)
	local pickerdata = inst._pickers[doer]
	if pickerdata then
		inst:RemoveEventCallback("newstate", pickerdata.cb, doer)
		inst:RemoveEventCallback("onremove", pickerdata.cb, doer)
		inst._pickers[doer] = nil
		if next(inst._pickers) == nil then
			inst._pickers = nil
			stoppickingloop(inst)
		elseif inst._mobloop then
			inst._mobloop = nil
			for k, v in pairs(inst._pickers) do
				if k:HasTag("junkmob") then
					inst._mobloop = true
					break
				end
			end
			if not inst._mobloop then
				inst._mobloop = nil
				inst.SoundEmitter:KillSound("rummage")
				inst.SoundEmitter:PlaySound("qol1/wagstaff_ruins/rummagepile_lrg", "rummage")
			end
		end
	end
end

local function onstartpicking(inst, doer)
	if not (inst._pickingtask or inst._pickingloop) then
		inst._pickingtask = inst:DoTaskInTime(0.2, startpickingloop)
	end

	if inst._pickers == nil then
		inst._pickers = {}
	end
	if inst._pickers[doer] == nil then
		local tick = GetTick()
		local pickingstate = doer.sg.currentstate.name
		local cb = function(doer, data)
			if not (data and data.statename == pickingstate) then
				cancelpicker(inst, doer)
			end
		end
		inst._pickers[doer] = { cb = cb, startstate = inst.daywalker_state }
		inst:ListenForEvent("newstate", cb, doer)
		inst:ListenForEvent("onremove", cb, doer)

		if inst._pickingloop then
			if not inst._mobloop and doer:HasTag("junkmob") then
				inst._mobloop = true
				inst.SoundEmitter:KillSound("rummage")
				inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/rummage_lp", "rummage")
			end
			if inst.daywalker_side and inst.daywalker_state == 2 and not inst.daywalker.sg.currentstate.name == "tryemerge" then
				inst.daywalker.sg:GoToState("tryemerge")
			end
		end
	end
end

local function toss_junk(inst, x, z)
	local theta0 = math.random() * PI2
	local count = 5
	for i = 1, count do
		local theta = theta0 + (i + math.random() * 0.5) * PI2 / count
		local cos_theta = math.cos(theta)
		local sin_theta = math.sin(theta)
		local rangea = GetRandomMinMax(2, 3)
		local rangeb = GetRandomMinMax(5, 9)
		local xa = x + cos_theta * rangea
		local za = z - sin_theta * rangea
		local xb = x + cos_theta * rangeb
		local zb = z - sin_theta * rangeb
		SpawnPrefab("junkball_fx"):SetupJunkTossFromPile(xa, za, xb, zb)
	end
end

local KNOCKBACK_TAGS = { "_combat" }
local KNOCKBACK_CANT_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost", "epic" }

local function DoReleaseDaywalker(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local x1, y1, z1 = inst.daywalker.Transform:GetWorldPosition()
	local x2, z2
	local dist1 = inst:GetPhysicsRadius(0) + inst.daywalker:GetPhysicsRadius(0)
	if x == x1 and z == z1 then
		local theta = inst.daywalker.Transform:GetRotation() * DEGREES
		x2 = x + math.cos(theta) * dist1
		z2 = z - math.sin(theta) * dist1
	else
		local dx = x1 - x
		local dz = z1 - z
		local dscale = dist1 / math.sqrt(dx * dx + dz * dz)
		x2 = x + dx * dscale
		z2 = z + dz * dscale
	end
	inst.daywalker.Physics:Teleport(x2, 0, z2)
	inst.daywalker:MakeFreed()
	inst.daywalker = nil
	inst.daywalker_state = nil
	inst.sides[inst.daywalker_side]:Show()
	inst.SoundEmitter:PlaySound("qol1/wagstaff_ruins/rummagepile_pst")

	local r = 3
	for i, v in ipairs(TheSim:FindEntities(x2, 0, z2, r + 3, KNOCKBACK_TAGS, KNOCKBACK_CANT_TAGS)) do
		if not (v.components.health and v.components.health:IsDead()) and v:GetDistanceSqToPoint(x2, 0, z2) < r * r then
			local strengthmult = (v.components.inventory and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and 1 or 1.4
			--use the pile as knocker so we go in the right direction
			v:PushEvent("knockback", { knocker = inst, radius = dist1 + r, strengthmult = strengthmult, forcelanded = true })
		end
	end
end

local JUNK_MOB_TAGS = { "junkmob" }

local function onpickedfn(inst, picker, loot)
	local junkstolen
	if inst.daywalker_side then
		local pickerdata = inst._pickers and inst._pickers[picker] or nil
		local startstate = pickerdata and pickerdata.startstate or nil
		if inst.daywalker_state ~= startstate then
			--ignore this pick; could be multiple players started picking around the same time
		elseif inst.daywalker_state == 1 then
			inst.daywalker_state = 2
			inst.daywalker.sg.mem.level = 2
			inst.daywalker.sg:GoToState("idle")
			SpawnPrefab("junk_break_fx").Transform:SetPosition(inst.daywalker.Transform:GetWorldPosition())
		elseif inst.daywalker_state == 2 then
			local x1, y1, z1 = inst.daywalker.Transform:GetWorldPosition()
			DoReleaseDaywalker(inst)
			toss_junk(inst, x1, z1)
        else
			junkstolen = true
		end
	elseif picker and picker:IsValid() then
		local forestdaywalkerspawner = TheWorld.components.forestdaywalkerspawner
		if forestdaywalkerspawner and forestdaywalkerspawner:CanSpawnFromJunk() then
			--find nearest side to picker
			local x, y, z = picker.Transform:GetWorldPosition()
			local mindsq = math.huge
			local nearest_side
			for i, v in ipairs(inst.sides) do
				local dsq = v:GetDistanceSqToPoint(x, y, z)
				if dsq < mindsq then
					mindsq = dsq
					nearest_side = i
				end
			end
			if nearest_side then
				spawn_daywalker(inst, nearest_side, 1)
				if inst.daywalker then
					SpawnPrefab("junk_break_fx").Transform:SetPosition(inst.daywalker.Transform:GetWorldPosition())
					forestdaywalkerspawner:WatchDaywalker(inst.daywalker)
				end
			else
				inst.SoundEmitter:PlaySound("qol1/wagstaff_ruins/rummagepile_pst")
			end
		else
			junkstolen = true
		end
	end

	if junkstolen then
		if not inst.components.timer:TimerExists("loot_spawn_cd") then
			inst.components.timer:StartTimer("loot_spawn_cd", TUNING.TOTAL_DAY_TIME * 0.25)
			inst:SpawnLoot(picker)
		end
		--stolen even if no loot dropped!
		local x, y, z = inst.Transform:GetWorldPosition()
		for i, v in ipairs(TheSim:FindEntities(x, y, z, 16, JUNK_MOB_TAGS)) do
			v:PushEvent("ms_junkstolen", picker)
		end
	end
end

local function onshake(inst)
	--make sure not looping
	if not inst._pickingloop then
		inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/buried_rustle")
		inst.SoundEmitter:PlaySound("qol1/daywalker_scrappy/vocalization_muffled")

		inst.AnimState:PlayAnimation("loopbig")
		inst.AnimState:PushAnimation("big_idle", false)

		if inst.sides then
			for i, v in ipairs(inst.sides) do
				v.AnimState:PlayAnimation("loopside"..tostring(v.variation))
				v.AnimState:SetFrame(math.random(0, 6))
				v.AnimState:PushAnimation("side_idle"..tostring(v.variation), false)
			end
		end
	end
end

local function WorkMultiplierFn(inst, worker, numworks)
	return 0
end

local function OnWork(inst, worker, workleft, numworks)
	if inst._pickingloop then
		inst.SoundEmitter:PlaySound("qol1/wagstaff_ruins/rummagepile_pst")
	else
		onshake(inst)
	end
	local x, y, z = inst.Transform:GetWorldPosition()
	local x1, y1, z1 = worker.Transform:GetWorldPosition()
	if x ~= x1 or z ~= z1 then
		local dx = x1 - x
		local dz = z1 - z
		local distscale = inst:GetPhysicsRadius(0) / math.sqrt(dx * dx + dz * dz)
		x1 = x + dx * distscale
		z1 = z + dz * distscale
	end
	SpawnPrefab("junk_break_fx").Transform:SetPosition(x1, y, z1)
end

local function OnSave(inst, data)
	data.variations = inst.variations
	data.daywalker_side = inst.daywalker_side
	if inst.daywalker_state then
		data.daywalker_state = inst.daywalker_state
		if inst.daywalker and inst.daywalker.components.health and inst.daywalker.components.health:IsHurt() then
			data.daywalker_hp = inst.daywalker.components.health:GetPercent()
		end
	end
end

local function OnLoad(inst, data)
	if data then
		if data.variations then
			set_variations(inst, data.variations)
		end
		local side = data.daywalker_side
		if side and inst.sides[side] then
			local state = data.daywalker_state
			if state == nil or state == 1 or state == 2 then
				spawn_daywalker(inst, side, state)
				if data.daywalker_hp and inst.daywalker and inst.daywalker.components.health then
					inst.daywalker.components.health:SetPercent(data.daywalker_hp)
				end
			end
		end
	end
end

local function Shaker(inst)
    inst:PushEvent("shake")
    inst.shaketask = inst:DoTaskInTime(5 + math.random() * 4, Shaker)
end

local function StartDaywalkerBuried(inst)
    if not inst:IsAsleep() then
        if inst.shaketask ~= nil then
            inst.shaketask:Cancel()
            inst.shaketask = nil
        end
        inst.shaketask = inst:DoTaskInTime(5 + math.random() * 4, Shaker)
    end
    inst.daywalker_side = nil
end

local function UpdateShaker(inst)
    if inst.daywalker_state == nil then
        local forestdaywalkerspawner = TheWorld.components.forestdaywalkerspawner
        if forestdaywalkerspawner and forestdaywalkerspawner:ShouldShakeJunk() then
            if inst.shaketask ~= nil then
                inst.shaketask:Cancel()
                inst.shaketask = nil
            end
            inst.shaketask = inst:DoTaskInTime(5 + math.random() * 4, Shaker)
        end
    end
end

--Trigger on wake; it can only gain cannon if Wagstaff went there, which happens off-screen
local function OnEntityWake(inst)
	if not inst.hascannon and TheWorld.components.moonstormmanager and (TheWorld.components.moonstormmanager:GetCelestialChampionsKilled() or 0) > 0 then
		inst.hascannon = true
	end
    inst:UpdateShaker()
end

local function OnEntitySleep(inst)
    if inst.shaketask ~= nil then
        inst.shaketask:Cancel()
        inst.shaketask = nil
    end
end

local function CanBuryDaywalker(inst, daywalker)
	return inst.daywalker_side ~= nil and inst.daywalker == nil
end

local function TryBuryDaywalker(inst, daywalker)
	local side = inst.daywalker_side
	if side and inst.daywalker == nil then
		inst.sides[side]:Hide()

		local x, y, z = inst.Transform:GetWorldPosition()
		local angle = 90 * side + HEAD_ANGLE_OFFSET

		inst.daywalker_state = 1
		inst.daywalker = daywalker
		inst.daywalker.Transform:SetRotation(angle)
		angle = angle * DEGREES
		x = x + HEAD_SPAWN_RADIUS * math.cos(angle)
		z = z - HEAD_SPAWN_RADIUS * math.sin(angle)
		inst.daywalker:MakeBuried(inst)
		inst.daywalker.Transform:SetPosition(x, 0, z)
		inst.daywalker.sg.mem.level = 1

		SpawnPrefab("junk_break_fx").Transform:SetPosition(x, 1, z)
		return true
	end
end

local function TryReleaseDaywalker(inst, daywalker)
	if inst.daywalker == daywalker then
		local x1, y1, z1 = daywalker.Transform:GetWorldPosition()
		DoReleaseDaywalker(inst)
		SpawnPrefab("junk_break_fx").Transform:SetPosition(x1, y1 + 2, z1)
		return true
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("junk_pile_big.png")
    inst.MiniMapEntity:SetPriority(1)

	inst.AnimState:SetBank("scrappile")
	inst.AnimState:SetBuild("scrappile")
	inst.AnimState:PlayAnimation("big_idle")
	inst.AnimState:SetFinalOffset(-1)

	inst:AddTag("junk_pile_big")
	inst:AddTag("pickable_rummage_str")
	inst:AddTag("NPC_workable")
	inst:AddTag("noquickpick")
	inst:AddTag("event_trigger")

	MakeObstaclePhysics(inst, 3.6)

	inst.highlightchildren = {}

	if not TheNet:IsDedicated() then
        inst:AddComponent("pointofinterest")
        inst.components.pointofinterest:SetHeight(75)
    end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.scrapbook_anim = "scrapbook"

	inst:AddComponent("inspectable")

	inst:AddComponent("pickable")
	inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable:SetUp(nil, 0)

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(nil)
	inst.components.workable:SetWorkMultiplierFn(WorkMultiplierFn)
	inst.components.workable:SetOnWorkCallback(OnWork)

    inst:AddComponent("timer")

	spawn_sides(inst)
	set_variations(inst)

	inst:ListenForEvent("startlongaction", onstartpicking)
	inst:ListenForEvent("shake", onshake)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep

	inst.CanBuryDaywalker = CanBuryDaywalker
	inst.TryBuryDaywalker = TryBuryDaywalker
	inst.TryReleaseDaywalker = TryReleaseDaywalker
    inst.UpdateShaker = UpdateShaker
    inst.StartDaywalkerBuried = StartDaywalkerBuried

    inst:AddComponent("lootdropper")
    inst.SpawnLoot = SpawnLoot

    TheWorld:PushEvent("ms_register_junk_pile_big", inst)

	return inst
end

local function side_OnRemoveEntity(inst)
	local parent = inst.entity:GetParent()
	if parent and parent.highlightchildren then
		table.removearrayvalue(parent.highlightchildren, inst)
	end
end

local function side_OnEntityReplicated(inst)
	local parent = inst.entity:GetParent()
	if parent and parent.prefab == "junk_pile_big" then
		table.insert(parent.highlightchildren, inst)
	end
end

local function side_fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("junk_pile")

	inst.AnimState:SetBank("scrappile")
	inst.AnimState:SetBuild("scrappile")
	inst.AnimState:PlayAnimation("side_idle1")

	inst.entity:SetPristine()

	inst.OnRemoveEntity = side_OnRemoveEntity

	if not TheWorld.ismastersim then
		inst.OnEntityReplicated = side_OnEntityReplicated

	    return inst
	end

	inst.persists = false

	return inst
end

return Prefab("junk_pile_big", fn, assets_big, prefabs),
	Prefab("junk_pile_side", side_fn, assets)
