local prefabs_basic =
{
    "hound",
    "icehound",
    "firehound",
    "monstermeat",
    "houndstooth",
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

local RETARGET_MUST_TAGS = { "character" }
local RETARGET_CANT_TAGS = { "wall", "warg", "hound" }
local function RetargetFn(inst)
    return not (inst.sg:HasStateTag("hidden") or inst.sg:HasStateTag("statue"))
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
        and not (inst.sg:HasStateTag("hidden") or inst.sg:HasStateTag("statue"))
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

    local pt = Vector3(inst.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.WARG_NEARBY_PLAYERS_DIST, TARGETS_MUST_TAGS, TARGETS_CANT_TAGS)
    for i,player in ipairs(ents) do
        local playerAge = player.components.age:GetAgeInDays()
        local addHounds = math.clamp(Lerp(1, 4, playerAge/100), 1, 4)
        if inst.spawn_fewer_hounds then
            addHounds = math.ceil(addHounds/2)
        end
        numHounds = numHounds + addHounds
    end
    local numFollowers = inst.components.leader:CountFollowers()
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
                local angle = 2 * PI * math.random()
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

local function OnSpawnedForHunt(inst)
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

local function OnEyeFlamesDirty(inst)
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

local function OnClaySave(inst, data)
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
	local theta = math.random() * 2 * PI
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

local function MakeWarg(name, bank, build, prefabs, tag)
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
        inst:AddTag("warg")
        inst:AddTag("scarytoprey")
        inst:AddTag("houndfriend")
        inst:AddTag("largecreature")

        if tag ~= nil then
            inst:AddTag(tag)

            if tag == "clay" then
                inst._eyeflames = net_bool(inst.GUID, "claywarg._eyeflames", "eyeflamesdirty")
                inst:ListenForEvent("eyeflamesdirty", OnEyeFlamesDirty)
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
        inst:ListenForEvent("attacked", OnAttacked)

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.WARG_HEALTH)

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable(name)

        inst.base_hound_num = TUNING.WARG_BASE_HOUND_AMOUNT

        if tag == "clay" then
            inst.NumHoundsToSpawn = NoHoundsToSpawn
			inst.LaunchGooIcing = NoGooIcing
            inst.OnSave = OnClaySave
            inst.OnPreLoad = OnClayPreLoad
            inst.OnReanimated = OnClayReanimated
            inst.OnBecameStatue = OnClayBecameStatue
            inst.OnEntitySleep = OnClayEntitySleep
            inst.OnEntityWake = OnClayEntityWake

            inst.sounds = sounds_clay
            inst.noidlesound = true

            inst:ListenForEvent("spawnedforhunt", OnSpawnedForHunt)
            inst:ListenForEvent("restoredfollower", OnRestoredFollower)
		elseif tag == "gingerbread" then
            inst.NumHoundsToSpawn = NoHoundsToSpawn
			inst.LaunchGooIcing = LaunchGooIcing
            inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/vargr/hit")
            inst:AddComponent("sleeper")
            inst.sounds = sounds_gingerbread
            inst.AnimState:AddOverrideBuild("gingerbread_pigman")
            MakeLargeBurnableCharacter(inst, "swap_fire")
        else
            inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/vargr/hit")

            inst:AddComponent("sleeper")

            inst.NumHoundsToSpawn = NumHoundsToSpawn
			inst.LaunchGooIcing = NoGooIcing

            inst.sounds = sounds

            MakeLargeBurnableCharacter(inst, "swap_fire")
        end

        MakeLargeFreezableCharacter(inst)

        inst:SetStateGraph("SGwarg")

        if tag == "clay" or tag == "gingerbread" then
            inst:AddComponent("hauntable")
            inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
        else
            MakeHauntableGoToState(inst, "howl", TUNING.HAUNT_CHANCE_OCCASIONAL, TUNING.HAUNT_COOLDOWN_MEDIUM, TUNING.HAUNT_CHANCE_LARGE)
        end

		if tag == "gingerbread" then
            inst.sg:GoToState("gingerbread_intro")
		end

        inst:SetBrain(brain)

        if tag == "clay" then
            inst.noidlesound = false
            inst.sg:GoToState("statue")
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeWarg("warg", "warg", "warg_build", prefabs_basic, nil),
    MakeWarg("claywarg", "claywarg", "claywarg", prefabs_clay, "clay"),
    MakeWarg("gingerbreadwarg", "warg", "warg_gingerbread_build", prefabs_gingerbread, "gingerbread")
