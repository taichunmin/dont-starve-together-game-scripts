local prefabs_basic =
{
    "hound",
    "icehound",
    "firehound",
    "monstermeat",
    "houndstooth",
    "wargcorpse",
    "koalefantcorpse_prop",
    "koalefant_carcass",
    "meat",
    "trunk_summer",
    "trunk_winter",
}

local prefabs_wave = prefabs_basic

local prefabs_clay =
{
    "redpouch",
    "eyeflame",
    "clayhound",
}

local prefabs_gingerbread =
{
    "warg_gooicing",
    "wintersfeastfuel",
    "houndstooth",
    "crumbs",
	"wargcorpse",
}

local prefabs_mutated =
{
    "warg",
    "hound",
    "icehound",
    "firehound",
	"warg_mutated_breath_fx",
	"warg_mutated_ember_fx",
	"spoiled_food",
	"purebrilliance",
    "chesspiece_warg_mutated_sketch",
    "winter_ornament_boss_mutatedwarg",
}

local brain = require("brains/wargbrain")

local sounds =
{
    idle = "dontstarve_DLC001/creatures/vargr/idle",
    howl = "dontstarve_DLC001/creatures/vargr/howl",
    hit = "dontstarve_DLC001/creatures/vargr/hit",
    attack = "dontstarve_DLC001/creatures/vargr/attack",
    death = "dontstarve_DLC001/creatures/vargr/death",
    sleep = "dontstarve_DLC001/creatures/vargr/sleep",
}

local sounds_gingerbread =
{
    idle = "dontstarve_DLC001/creatures/vargr/idle",
    howl = "dontstarve_DLC001/creatures/vargr/howl",
    hit = "dontstarve_DLC001/creatures/vargr/hit",
    attack = "dontstarve_DLC001/creatures/vargr/attack",
    death = "dontstarve_DLC001/creatures/vargr/death",
    sleep = "dontstarve_DLC001/creatures/vargr/sleep",
}

local sounds_clay =
{
    idle = "dontstarve_DLC001/creatures/together/claywarg/idle",
    howl = "dontstarve_DLC001/creatures/together/claywarg/howl",
    hit = "dontstarve_DLC001/creatures/together/claywarg/hit",
    attack = "dontstarve_DLC001/creatures/together/claywarg/attack",
    death = "dontstarve_DLC001/creatures/together/claywarg/death",
    sleep = "dontstarve_DLC001/creatures/together/claywarg/sleep",
    alert = "dontstarve_DLC001/creatures/together/claywarg/alert",
}

local sounds_mutated =
{
	idle = "rifts3/mutated_varg/idle",
	howl = "rifts3/mutated_varg/howl",
	hit = "rifts3/mutated_varg/hit",
	attack = "rifts3/mutated_varg/attack",
	death = "rifts3/mutated_varg/death",
	sleep = "rifts3/mutated_varg/sleep",
}

SetSharedLootTable('warg',
{
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             0.50},
    {'monstermeat',             0.50},

    {'houndstooth',             1.00},
    {'houndstooth',             0.66},
    {'houndstooth',             0.33},
})

SetSharedLootTable('claywarg',
{
    {'redpouch',                1.00},
    {'redpouch',                1.00},
    {'redpouch',                1.00},
    {'redpouch',                1.00},
    {'redpouch',                0.50},
    {'redpouch',                0.50},

    {'houndstooth',             1.00},
    {'houndstooth',             0.66},
    {'houndstooth',             0.33},
})

SetSharedLootTable('gingerbreadwarg',
{
    {'wintersfeastfuel',		1.00},
    {'wintersfeastfuel',		1.00},
    {'wintersfeastfuel',		1.00},
    {'wintersfeastfuel',		1.00},
    {'wintersfeastfuel',		1.00},
    {'wintersfeastfuel',        0.66},
    {'wintersfeastfuel',        0.33},
    {'crumbs',					1.00},
    {'crumbs',					1.00},
    {'crumbs',					0.50},
    {'crumbs',					0.50},

    {'houndstooth',             1.00},
    {'houndstooth',             0.66},
    {'houndstooth',             0.33},
})

SetSharedLootTable('mutatedwarg',
{
	{ "spoiled_food",				  1.0  },
	{ "spoiled_food",				  1.0  },
	{ "spoiled_food",				  0.5  },
	{ "purebrilliance",				  1.0  },
	{ "purebrilliance",				  0.75 },
    {'chesspiece_warg_mutated_sketch',1.00},
})

local scrapbook_removedeps_basic =
{
    "meat",
    "trunk_summer",
    "trunk_winter",
}

local RETARGET_MUST_TAGS = { "character" }
local RETARGET_CANT_TAGS = { "wall", "warg", "hound" }
local function RetargetFn(inst)
	return not (inst:IsInLimbo() or inst.sg:HasStateTag("hidden") or inst.sg:HasStateTag("statue"))
        and FindEntity(
                inst,
                TUNING.WARG_TARGETRANGE,
                function(guy)
                    return inst.components.combat:CanTarget(guy)
                end,
                inst.sg:HasStateTag("intro_state") and RETARGET_MUST_TAGS or nil,
                RETARGET_CANT_TAGS
            )
        or nil
end

local function KeepTargetFn(inst, target)
    return target ~= nil
		and not (inst:IsInLimbo() or inst.sg:HasStateTag("hidden") or inst.sg:HasStateTag("statue"))
        and inst:IsNear(target, 40)
        and inst.components.combat:CanTarget(target)
        and not target.components.health:IsDead()
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, TUNING.WARG_MAXHELPERS,
        function(dude)
            return not (dude.components.health ~= nil and dude.components.health:IsDead())
                and (dude:HasTag("hound") or dude:HasTag("warg"))
                and data.attacker ~= (dude.components.follower ~= nil and dude.components.follower.leader or nil)
        end, TUNING.WARG_TARGETRANGE)
end

local TARGETS_MUST_TAGS = {"player"}
local TARGETS_CANT_TAGS = {"playerghost"}
local function NumHoundsToSpawn(inst)
    local numHounds = inst.base_hound_num

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.WARG_NEARBY_PLAYERS_DIST, TARGETS_MUST_TAGS, TARGETS_CANT_TAGS)
    for i, player in ipairs(ents) do
        local playerAge = player.components.age:GetAgeInDays()
        local addHounds = math.clamp(Lerp(1, 4, playerAge/100), 1, 4)
        if inst.spawn_fewer_hounds then
            addHounds = math.ceil(addHounds/2)
        end
        numHounds = numHounds + addHounds
    end
	local numFollowers = inst.components.leader:CountFollowers() + inst.numfollowercorpses
    local num = math.min(numFollowers+numHounds/2, numHounds) -- only spawn half the hounds per howl
    num = (math.log(num)/0.4)+1 -- 0.4 is approx log(1.5)

    num = RoundToNearest(num, 1)

    if inst.max_hound_spawns then
        num = math.min(num,inst.max_hound_spawns)
    end

    return num - numFollowers
end

local function NoHoundsToSpawn(inst)
    return 0
end

local TOSSITEMS_MUST_TAGS = {"_inventoryitem"}
local TOSSITEMS_CANT_TAGS ={ "locomotor", "INLIMBO" }
local function TossItems(inst, x, z, minradius, maxradius)
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, maxradius + 3, TOSSITEMS_MUST_TAGS, TOSSITEMS_CANT_TAGS)) do
        local x1, y1, z1 = v.Transform:GetWorldPosition()
        local dx, dz = x1 - x, z1 - z
        local dsq = dx * dx + dz * dz
        local range = GetRandomMinMax(minradius, maxradius) + v:GetPhysicsRadius(.5)
        if dsq < range * range and y1 < .2 then
            if v.components.mine ~= nil then
                v.components.mine:Deactivate()
            end
            if dsq > 0 then
                range = range / math.sqrt(dsq)
                x1 = x + dx * range
                z1 = z + dz * range
            else
                local angle = TWOPI * math.random()
                x1 = x + math.cos(angle) * range
                z1 = z + math.sin(angle) * range
            end
            if v.Physics ~= nil then
                v.Physics:Teleport(x1, y1, z1)
            else
                v.Transform:SetPosition(x1, y1, z1)
            end
        end
    end
end

local SPAWNCLAYHOUND_CANT_TAGS = { "_inventoryitem", "NOBLOCK", "FX", "INLIMBO", "DECOR" }
local function DoSpawnClayHound(inst, x, z, rot)
    if TheWorld.Map:IsPassableAtPoint(x, 0, z) then
        for i, v in ipairs(TheSim:FindEntities(x, 0, z, 4, nil, SPAWNCLAYHOUND_CANT_TAGS)) do
            if v.components.locomotor == nil or (v.sg ~= nil and v.sg:HasStateTag("statue")) then
                local range = .5 + v:GetPhysicsRadius(.5)
                if v:GetDistanceSqToPoint(x, 0, z) < range * range then
                    return
                end
            end
        end
        TossItems(inst, x, z, .5, 1)
        local hound = SpawnPrefab("clayhound")
        hound.Transform:SetRotation(rot)
        hound.Transform:SetPosition(x, 0, z)
        hound.components.follower:SetLeader(inst)
    end
end

local function GenerateClayFormation(rot, count)
    local ret = {}
    local xangle = rot * DEGREES
    local zangle = (rot + 90) * DEGREES
    local sin_xangle = math.sin(xangle)
    local cos_xangle = math.cos(xangle)
    local sin_zangle = math.sin(zangle)
    local cos_zangle = math.cos(zangle)
    local zoffsabs = (count < 3 and 0) or ((count < 5 or count == 7 or count == 8) and 2) or 3

    for zoffs = -zoffsabs, zoffsabs, 3 do
        for xoffs = 4, count > 6 and 7 or 4, 3 do
            table.insert(ret, Vector3(zoffs * sin_zangle + xoffs * sin_xangle, 0, zoffs * cos_zangle + xoffs * cos_xangle))
            table.insert(ret, Vector3(zoffs * sin_zangle - xoffs * sin_xangle, 0, zoffs * cos_zangle - xoffs * cos_xangle))
        end
    end
    return ret
end

local function OnSpawnedForHunt_Clay(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    --rot snaps to nearest 45 degrees
    --rot_facing has 15 degree offset (for better facing update during camera rotation)
    local rot = 45 * math.random(0, 7)
    local rot_facing = rot + 15
    inst.Transform:SetRotation(rot_facing)

    for i, v in ipairs(GenerateClayFormation(rot, 12)) do
        DoSpawnClayHound(inst, x + v.x, z + v.z, rot_facing)
    end

    TossItems(inst, x, z, 1, 2)
end

local function OnForceSleep_Normal(inst, hounds)
    if inst.components.sleeper ~= nil then
        inst.components.sleeper:AddSleepiness(10 + 3 * math.random(), TUNING.PANFLUTE_SLEEPTIME)
    end
    for _, hound in ipairs(hounds) do
        if hound:IsValid() and hound.components.sleeper ~= nil then
            hound.components.sleeper:AddSleepiness(10 + 3 * math.random(), TUNING.PANFLUTE_SLEEPTIME)
        end
    end
end

local function OnVisibleFn_Normal(inst)
	inst.sg:GoToState("spawn_shake")
end

local function WillUnhideFn_Normal(inst)
    local player, distsq = inst:GetNearestPlayer(true)
    if player and distsq < 225 then -- 15 * 15
        return player
    end

    return nil
end

local function OnUnhideFn_Normal(inst, player)
    if inst.components.combat ~= nil then
        -- NOTES(JBK): ReturnToScene can activate a brain and cause the warg to target something else clear it by force now.
        inst.components.combat:DropTarget()
        inst.components.combat:SuggestTarget(player)
    end
end

local function PropCreationFn_Normal(inst)
    local ent = SpawnPrefab("koalefantcorpse_prop")
    if TheWorld.state.iswinter then
        ent:SetAltBuild()
    end
    ent.Transform:SetPosition(inst.Transform:GetWorldPosition())

    return ent
end

local function CarcassCreationFn_Normal(inst, score)
    local ent = SpawnPrefab("koalefant_carcass")
    if TheWorld.state.iswinter then
        ent:MakeWinter()
    end
    ent.Transform:SetPosition(inst.Transform:GetWorldPosition())

	if ent.SetMeatPct ~= nil then
		score = math.clamp(1 - score, 0, 1)
		score = 1 - score * score
		ent:SetMeatPct(Remap(score, 0, 1, 1 / 3, 1))
	end

    return ent
end

local function OnSpawnedForHunt_Normal(inst, data)
    if data == nil then
        return
    end

    -- NOTES(JBK): This came from a hunt investigation so let us make it a bit more special.

    -- First spawn meats from a fake koalefant.
    SimulateKoalefantDrops(inst)

    -- Then check if this is spring loaded.
    if data.action == HUNT_ACTIONS.PROP then
        -- Took too long, make it an ambush!
        if inst.components.prophider ~= nil then
            inst.components.prophider:HideWithProp()
        end
    elseif data.action == HUNT_ACTIONS.SLEEP then
        local radius = math.random() * 2 + 6
        local hounds = inst:SpawnHounds(radius)

        inst:DoTaskInTime(0, OnForceSleep_Normal, hounds) -- NOTES(JBK): Delay a frame for initialization to complete.
    elseif data.action == HUNT_ACTIONS.SUCCESS then
        local radius = math.random() * 2 + 6
        local hounds = inst:SpawnHounds(radius)

        local rescaled_score = (data.score - TUNING.HUNT_SCORE_SLEEP_RATIO) / (1 - TUNING.HUNT_SCORE_SLEEP_RATIO) -- Back to 0 to 1.
        CarcassCreationFn_Normal(inst, rescaled_score)
    else
        -- FIXME(JBK): Unhandled state.
    end
end

local function Clay_OnEyeFlamesDirty(inst)
    if TheWorld.ismastersim then
        if not inst._eyeflames:value() then
            inst.AnimState:SetLightOverride(0)
            inst.SoundEmitter:KillSound("eyeflames")
        else
            inst.AnimState:SetLightOverride(.07)
            if not inst.SoundEmitter:PlayingSound("eyeflames") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "eyeflames")
                inst.SoundEmitter:SetParameter("eyeflames", "intensity", 1)
            end
        end
        if TheNet:IsDedicated() then
            return
        end
    end

    if inst._eyeflames:value() then
        if inst.eyefxl == nil then
            inst.eyefxl = SpawnPrefab("eyeflame")
            inst.eyefxl.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
            inst.eyefxl.entity:AddFollower()
            inst.eyefxl.Follower:FollowSymbol(inst.GUID, "warg_eye_left", 0, 0, 0)
        end
        if inst.eyefxr == nil then
            inst.eyefxr = SpawnPrefab("eyeflame")
            inst.eyefxr.entity:SetParent(inst.entity) --prevent 1st frame sleep on clients
            inst.eyefxr.entity:AddFollower()
            inst.eyefxr.Follower:FollowSymbol(inst.GUID, "warg_eye_right", 0, 0, 0)
        end
    else
        if inst.eyefxl ~= nil then
            inst.eyefxl:Remove()
            inst.eyefxl = nil
        end
        if inst.eyefxr ~= nil then
            inst.eyefxr:Remove()
            inst.eyefxr = nil
        end
    end
end

local function OnSave(inst, data)
	data.looted = inst.looted
end

local function OnLoad(inst, data, ents)
	inst.looted = data ~= nil and data.looted or nil
	if inst.looted and inst.components.health:IsDead() then
		inst.sg:GoToState("corpse")
	end
end

local function OnClaySave(inst, data)
	OnSave(inst, data)
    data.reanimated = not inst.sg:HasStateTag("statue") or nil
end

local function OnClayPreLoad(inst, data)--, newents)
    if data ~= nil and data.reanimated then
        inst.sg:GoToState("idle")
    end
end

local function FindClosestOffset(hound, x, z, offsets)
    if #offsets > 0 then
        local mindsq = math.huge
        local mini = nil
        for i, offset in ipairs(offsets) do
            local dsq = hound:GetDistanceSqToPoint(x + offset.x, 0, z + offset.z)
            if dsq < mindsq then
                mindsq = dsq
                mini = i
            end
        end
        hound:OnUpdateOffset(table.remove(offsets, mini))
    else
        hound:OnUpdateOffset()
    end
end

local function UpdateClayFormation(inst, count)
    local x, y, z = inst.Transform:GetWorldPosition()
    local offsets = GenerateClayFormation(inst.Transform:GetRotation(), count or inst.components.leader:CountFollowers())
    local running = {}
    for hound, _ in pairs(inst.components.leader.followers) do
        if hound.OnUpdateOffset ~= nil then
            if hound.sg:HasStateTag("statue") then
                FindClosestOffset(hound, x, z, offsets)
            else
                table.insert(running, hound)
            end
        end
    end
    for i, hound in ipairs(running) do
        FindClosestOffset(hound, x, z, offsets)
    end
end

local function OnRestoredFollower(inst, data)
    if inst.formationtask == nil then
        UpdateClayFormation(inst, 12)
    end
end

local function OnClayReanimated(inst)
    if inst.formationtask == nil and not inst:IsAsleep() then
        inst.formationtask = inst:DoPeriodicTask(.5, UpdateClayFormation)
    end
end

local function OnClayBecameStatue(inst)
    if inst.formationtask ~= nil then
        inst.formationtask:Cancel()
        inst.formationtask = nil
        UpdateClayFormation(inst, 12)
    end
end

local function OnClayEntityWake(inst)
    if inst.formationtask == nil and not inst.sg:HasStateTag("statue") then
        inst.formationtask = inst:DoPeriodicTask(.5, UpdateClayFormation)
    end
end

local function OnClayEntitySleep(inst)
    if inst.formationtask ~= nil then
        inst.formationtask:Cancel()
        inst.formationtask = nil
    end
end

local function GetStatus(inst)
    return (inst.sg:HasStateTag("statue") and "STATUE")
        or nil
end

local function LaunchGooIcing(inst)
    local theta = math.random() * TWOPI
    local r = inst:GetPhysicsRadius(0) + 0.25 + math.sqrt(math.random()) * TUNING.WARG_GINGERBREAD_GOO_DIST_VAR
    local x, y, z = inst.Transform:GetWorldPosition()
    local dest_x, dest_z = math.cos(theta) * r + x, math.sin(theta) * r + z

    local goo = SpawnPrefab("warg_gooicing")
    goo.Transform:SetPosition(x, y, z)
    goo.Transform:SetRotation(theta / DEGREES)
    goo._caster = inst

    Launch2(goo, inst, 1.5, 1, 3, .75)

    inst._next_goo_time = GetTime() + TUNING.WARG_GINGERBREAD_GOO_COOLDOWN
end

local function NoGooIcing()
end

local function OnDead(inst)
	--V2C: make sure we're still burning by the time we actually reach death in stategraph
	if inst.components.burnable:IsBurning() then
		inst.components.burnable:SetBurnTime(nil)
		inst.components.burnable:ExtendBurning()
	end
end

local function Mutated_OnDead(inst)
	OnDead(inst)
    if TheWorld ~= nil and TheWorld.components.lunarriftmutationsmanager ~= nil then
        TheWorld.components.lunarriftmutationsmanager:SetMutationDefeated(inst)
    end
end

local function Mutated_OnRemove(inst)
	if inst.flame_pool ~= nil then
		for i, v in ipairs(inst.flame_pool) do
			v:Remove()
		end
		inst.flame_pool = nil
	end
	if inst.ember_pool ~= nil then
		for i, v in ipairs(inst.ember_pool) do
			v:Remove()
		end
		inst.ember_pool = nil
	end
end

local function Mutated_OnTemp8Faced(inst)
	if inst.temp8faced:value() then
		inst.gestalt.Transform:SetEightFaced()
		inst.eyeL.Transform:SetEightFaced()
		inst.eyeR.Transform:SetEightFaced()
		inst.mouthL.Transform:SetEightFaced()
		inst.mouthR.Transform:SetEightFaced()
	else
		inst.gestalt.Transform:SetSixFaced()
		inst.eyeL.Transform:SetSixFaced()
		inst.eyeR.Transform:SetSixFaced()
		inst.mouthL.Transform:SetSixFaced()
		inst.mouthR.Transform:SetSixFaced()
	end
end

local function Mutated_SwitchToEightFaced(inst)
	if not inst.temp8faced:value() then
		inst.temp8faced:set(true)
		if not TheNet:IsDedicated() then
			Mutated_OnTemp8Faced(inst)
		end
		inst.Transform:SetEightFaced()
	end
end

local function Mutated_SwitchToSixFaced(inst)
	if inst.temp8faced:value() then
		inst.temp8faced:set(false)
		if not TheNet:IsDedicated() then
			Mutated_OnTemp8Faced(inst)
		end
		inst.Transform:SetSixFaced()
	end
end

local function Mutated_CreateGestaltFlame()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false) --commented out; follow parent sleep instead
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetSixFaced()

	inst.AnimState:SetBank("lunar_flame")
	inst.AnimState:SetBuild("lunar_flame")
	inst.AnimState:PlayAnimation("gestalt_eye", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:UsePointFiltering(true)

	return inst
end

local function Mutated_CreateEyeFlame()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false) --commented out; follow parent sleep instead
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetSixFaced()

	inst.AnimState:SetBank("lunar_flame")
	inst.AnimState:SetBuild("lunar_flame")
	inst.AnimState:PlayAnimation("flameanim", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

	return inst
end

local function Mutated_CreateMouthFlame()
	local inst = CreateEntity()

	inst:AddTag("FX")
	--[[Non-networked entity]]
	--inst.entity:SetCanSleep(false) --commented out; follow parent sleep instead
	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetSixFaced()

	inst.AnimState:SetBank("lunar_flame")
	inst.AnimState:SetBuild("lunar_flame")
	inst.AnimState:PlayAnimation("mouthflameanim", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

	return inst
end

local function Mutated_PushMusic(inst)
	if inst.AnimState:IsCurrentAnimation("mutate") then
		inst._playingmusic = false
	elseif ThePlayer == nil then
		inst._playingmusic = false
	elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
		inst._playingmusic = true
		ThePlayer:PushEvent("triggeredevent", { name = "gestaltmutant" })
	elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
		inst._playingmusic = false
	end
end

local function SpawnHounds(inst, radius_override)
    local hounds = nil
    local hounded = TheWorld.components.hounded
    if hounded == nil then
        return hounds
    end

    local num = inst:NumHoundsToSpawn()
    if inst.max_hound_spawns then
        num = math.min(num,inst.max_hound_spawns)
        inst.max_hound_spawns = inst.max_hound_spawns - num
    end

	local forcemutate = inst:HasTag("lunar_aligned") or nil
    local pt = inst:GetPosition()
    for i = 1, num do
        local hound = hounded:SummonSpawn(pt, radius_override)
        if hound ~= nil then
            if hound.components.follower ~= nil then
                hound.components.follower:SetLeader(inst)
            end
            if hounds == nil then
                hounds = {}
            end
            table.insert(hounds, hound)
        end
    end
    return hounds
end

local function OnCorpseRemoved(corpse)
	local inst = corpse._warg
	inst.followercorpses[corpse] = nil
	inst.numfollowercorpses = inst.numfollowercorpses - 1
end

local function RememberFollowerCorpse(inst, corpse)
	if inst.followercorpses[corpse] == nil then
		corpse._warg = inst
		inst.followercorpses[corpse] = true
		inst.numfollowercorpses = inst.numfollowercorpses + 1
		inst:ListenForEvent("onremove", OnCorpseRemoved, corpse)
	end
end

local function ForgetFollowerCorpse(inst, corpse)
	if inst.followercorpses[corpse] ~= nil then
		inst:RemoveEventCallback("onremove", OnCorpseRemoved, corpse)
		OnCorpseRemoved(corpse)
		corpse._warg = nil
	end
end

local mutated_scrapbook_overridedata = {
    { "flameL",      "lunar_flame", "flameanim",      0.6 },
    { "flameR",      "lunar_flame", "flameanim",      0.6 },
    { "mouthflameL", "lunar_flame", "mouthflameanim", 0.6 },
    { "mouthflameR", "lunar_flame", "mouthflameanim", 0.6 },
}

local function MakeWarg(data)
    local name     = data.name
    local bank     = data.bank
    local build    = data.build
    local prefabs  = data.prefabs
    local tag      = data.tag
	local epic     = data.epic

    local assets =
    {
        Asset("SOUND", "sound/vargr.fsb"),
    }
    if bank == "warg" then
        table.insert(assets, Asset("ANIM", "anim/warg_actions.zip"))
    elseif bank ~= build then
        table.insert(assets, Asset("ANIM", "anim/"..bank..".zip"))
    end
    if tag == "gingerbread" then
        table.insert(assets, Asset("ANIM", "anim/warg_gingerbread.zip"))
    elseif tag == "lunar_aligned" then
        table.insert(assets, Asset("ANIM", "anim/warg_mutated_actions.zip"))
		table.insert(assets, Asset("ANIM", "anim/lunar_flame.zip"))
    end
    table.insert(assets, Asset("ANIM", "anim/"..build..".zip"))

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        inst.DynamicShadow:SetSize(2.5, 1.5)

        inst.Transform:SetSixFaced()

        MakeCharacterPhysics(inst, 1000, 1)

        inst:AddTag("monster")
		inst:AddTag("hostile")
        inst:AddTag("warg")
        inst:AddTag("scarytoprey")
        inst:AddTag("houndfriend")
        inst:AddTag("largecreature")

		if epic then
			inst:AddTag("epic")
		end

        if tag ~= nil then
            inst:AddTag(tag)

            if tag == "clay" then
                inst._eyeflames = net_bool(inst.GUID, "claywarg._eyeflames", "eyeflamesdirty")
				inst:ListenForEvent("eyeflamesdirty", Clay_OnEyeFlamesDirty)
			elseif tag == "lunar_aligned" then
				if epic then
					inst:AddTag("noepicmusic")
				end

				inst.temp8faced = net_bool(inst.GUID, name..".temp8faced", "temp8faceddirty")

				inst.AnimState:SetSymbolBloom("breath_02")
				inst.AnimState:SetSymbolBrightness("breath_02", 1.5)

				--Dedicated server does not need to trigger music
				--Dedicated server does not need to spawn the local fx
				if not TheNet:IsDedicated() then
					inst._playingmusic = false
					inst:DoPeriodicTask(1, Mutated_PushMusic, 0)

					inst.gestalt = Mutated_CreateGestaltFlame()
					inst.gestalt.entity:SetParent(inst.entity)
					inst.gestalt.Follower:FollowSymbol(inst.GUID, "swap_gestalt_flame", 0, 0, 0, true)
					local frames = inst.gestalt.AnimState:GetCurrentAnimationNumFrames()
					local rnd = math.random(frames) - 1
					inst.gestalt.AnimState:SetFrame(rnd)

					inst.eyeL = Mutated_CreateEyeFlame()
					inst.eyeL.entity:SetParent(inst.entity)
					inst.eyeL.Follower:FollowSymbol(inst.GUID, "flameL", 0, 0, 0, true)
					frames = inst.eyeL.AnimState:GetCurrentAnimationNumFrames()
					rnd = math.random(frames) - 1
					inst.eyeL.AnimState:SetFrame(rnd)

					inst.eyeR = Mutated_CreateEyeFlame()
					inst.eyeR.entity:SetParent(inst.entity)
					inst.eyeR.Follower:FollowSymbol(inst.GUID, "flameR", 0, 0, 0, true)
					rnd = (rnd + math.floor((0.35 + math.random() * 0.35) * frames)) % frames
					inst.eyeR.AnimState:SetFrame(rnd)

					inst.mouthL = Mutated_CreateMouthFlame()
					inst.mouthL.entity:SetParent(inst.entity)
					inst.mouthL.Follower:FollowSymbol(inst.GUID, "mouthflameL", 0, 0, 0, true)
					frames = inst.mouthL.AnimState:GetCurrentAnimationNumFrames()
					rnd = math.random(frames) - 1
					inst.mouthL.AnimState:SetFrame(rnd)

					inst.mouthR = Mutated_CreateMouthFlame()
					inst.mouthR.entity:SetParent(inst.entity)
					inst.mouthR.Follower:FollowSymbol(inst.GUID, "mouthflameR", 0, 0, 0, true)
					rnd = (rnd + math.floor((0.35 + math.random() * 0.35) * frames)) % frames
					inst.mouthR.AnimState:SetFrame(rnd)

					if not TheWorld.ismastersim then
						inst:ListenForEvent("temp8faceddirty", Mutated_OnTemp8Faced)
					end
				end
            end
        end

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle_loop", true)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = GetStatus

        inst:AddComponent("leader")

        inst:AddComponent("locomotor")
        inst.components.locomotor.runspeed = tag == "clay" and TUNING.CLAYWARG_RUNSPEED or TUNING.WARG_RUNSPEED
        inst.components.locomotor:SetShouldRun(true)

        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(TUNING.WARG_DAMAGE)
        inst.components.combat:SetRange(TUNING.WARG_ATTACKRANGE)
        inst.components.combat:SetAttackPeriod(TUNING.WARG_ATTACKPERIOD)
        inst.components.combat:SetRetargetFunction(1, RetargetFn)
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
		inst.components.combat.lastwasattackedtime = -math.huge --for brain
        inst:ListenForEvent("attacked", OnAttacked)

        inst:AddComponent("health")
		if tag == "lunar_aligned" then
			inst.components.health:SetMaxHealth(TUNING.MUTATED_WARG_HEALTH)
		else
			inst.components.health:SetMaxHealth(TUNING.WARG_HEALTH)
		end
		if tag ~= "clay" then
			inst.components.health.nofadeout = true
		end

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable(name)

        inst.base_hound_num = TUNING.WARG_BASE_HOUND_AMOUNT

		inst.OnSave = OnSave
		inst.OnLoad = OnLoad
        inst.SpawnHounds = SpawnHounds

        if tag == "clay" then
            inst.NumHoundsToSpawn = NoHoundsToSpawn
            inst.LaunchGooIcing = NoGooIcing
			inst.OnSave = OnClaySave --Overriding, but does call the default OnSave as well
            inst.OnPreLoad = OnClayPreLoad
            inst.OnReanimated = OnClayReanimated
            inst.OnBecameStatue = OnClayBecameStatue
            inst.OnEntitySleep = OnClayEntitySleep
            inst.OnEntityWake = OnClayEntityWake

            inst.sounds = sounds_clay
            inst.noidlesound = true

            inst:ListenForEvent("spawnedforhunt", OnSpawnedForHunt_Clay)
            inst:ListenForEvent("restoredfollower", OnRestoredFollower)
        elseif tag == "gingerbread" then
            inst.NumHoundsToSpawn = NoHoundsToSpawn
            inst.LaunchGooIcing = LaunchGooIcing
            inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/vargr/hit")
            inst:AddComponent("sleeper")
            inst.sounds = sounds_gingerbread
            inst.AnimState:AddOverrideBuild("gingerbread_pigman")
            MakeLargeBurnableCharacter(inst, "swap_fire")

			inst:ListenForEvent("death", OnDead)
        elseif tag == "lunar_aligned" then
            inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/vargr/hit")

			inst:AddComponent("planarentity")
			inst:AddComponent("planardamage")
			inst.components.planardamage:SetBaseDamage(TUNING.MUTATED_WARG_PLANAR_DAMAGE)

			inst:AddComponent("timer")
			inst.components.timer:StartTimer("flamethrower_cd", TUNING.MUTATED_WARG_FLAMETHROWER_CD + math.random() * 2)

			inst.NumHoundsToSpawn = NumHoundsToSpawn
            inst.LaunchGooIcing = NoGooIcing

			inst.sounds = sounds_mutated
			inst.flame_pool = {}
			inst.ember_pool = {}
			inst.canflamethrower = true

            MakeLargeBurnableCharacter(inst, "swap_fire")
			inst.components.burnable.nocharring = true

            inst:ListenForEvent("death", Mutated_OnDead)
			inst.OnRemoveEntity = Mutated_OnRemove

			inst.SwitchToEightFaced = Mutated_SwitchToEightFaced
			inst.SwitchToSixFaced = Mutated_SwitchToSixFaced

            inst.scrapbook_overridedata = mutated_scrapbook_overridedata
        else
            inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/vargr/hit")

            inst:AddComponent("sleeper")

            local prophider = inst:AddComponent("prophider")
            prophider:SetPropCreationFn(PropCreationFn_Normal)
            prophider:SetOnVisibleFn(OnVisibleFn_Normal)
            prophider:SetWillUnhideFn(WillUnhideFn_Normal)
            prophider:SetOnUnhideFn(OnUnhideFn_Normal)

            inst.NumHoundsToSpawn = NumHoundsToSpawn
            inst.LaunchGooIcing = NoGooIcing

            inst.sounds = sounds

            inst.scrapbook_removedeps = scrapbook_removedeps_basic

            MakeLargeBurnableCharacter(inst, "swap_fire")

			inst:ListenForEvent("death", OnDead)
            inst:ListenForEvent("spawnedforhunt", OnSpawnedForHunt_Normal)
        end

        MakeLargeFreezableCharacter(inst)

		inst:SetStateGraph("SGwarg")

		inst:AddComponent("hauntable")
		inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        if tag == "gingerbread" then
            inst.sg:GoToState("gingerbread_intro")
        end

        inst:SetBrain(brain)

        if tag == "clay" then
            inst.noidlesound = false
            inst.sg:GoToState("statue")
        end

		inst.numfollowercorpses = 0
		inst.followercorpses = {}
		inst.RememberFollowerCorpse = RememberFollowerCorpse
		inst.ForgetFollowerCorpse = ForgetFollowerCorpse

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return
        MakeWarg({
            name = "warg",
            bank = "warg",
            build = "warg_build",
            prefabs = prefabs_basic,
        }),

        MakeWarg({
            name = "claywarg",
            bank = "claywarg",
            build = "claywarg",
            prefabs = prefabs_clay,
            tag = "clay",
        }),

        MakeWarg({
            name = "gingerbreadwarg",
            bank = "warg",
            build = "warg_gingerbread_build",
            prefabs = prefabs_gingerbread,
            tag = "gingerbread",
        }),

        MakeWarg({
            name = "mutatedwarg",
            bank = "warg",
            build = "warg_mutated_actions",
            prefabs = prefabs_mutated,
            tag = "lunar_aligned",
			epic = true,
        })
