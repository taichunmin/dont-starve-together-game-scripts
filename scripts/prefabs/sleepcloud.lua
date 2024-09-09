local assets =
{
    Asset("ANIM", "anim/sleepcloud.zip"),
    Asset("ANIM", "anim/sporecloud_base.zip"),
}

local prefabs =
{
    "sleepcloud_overlay",
}

local TICK_PERIOD = .5

local TICK_VALUE = 10
local MAX_SLEEP_TIME = 5
local MIN_SLEEP_TIME = 1.5

local PLAYER_TICK_VALUE = 1
local PLAYER_MAX_SLEEP_TIME = 4
local PLAYER_MIN_SLEEP_TIME = 1

local ATTACK_SLEEP_DELAY = 2
local CHAIN_SLEEP_DELAY = 4

local OVERLAY_COORDS =
{
    { 0,0,0,               1 },
    { 5/2,0,0,             0.8, 0 },
    { 2.5/2,0,-4.330/2,    0.8 , 5/3*180 },
    { -2.5/2,0,-4.330/2,   0.8, 4/3*180 },
    { -5/2,0,0,            0.8, 3/3*180 },
    { 2.5/2,0,4.330/2,     0.8, 1/3*180 },
    { -2.5/2,0,4.330/2,    0.8, 2/3*180 },
}

local function SpawnOverlayFX(inst, i, set, isnew)
    if i ~= nil then
        inst._overlaytasks[i] = nil
        if next(inst._overlaytasks) == nil then
            inst._overlaytasks = nil
        end
    end

    local fx = SpawnPrefab("sleepcloud_overlay")
    fx.entity:SetParent(inst.entity)
    fx.Transform:SetPosition(set[1] * .85, 0, set[3] * .85)
    fx.Transform:SetScale(set[4], set[4], set[4])
    if set[5] ~= nil then
        fx.Transform:SetRotation(set[4])
    end

    if not isnew then
        fx.AnimState:PlayAnimation("sleepcloud_overlay_loop")
        fx.AnimState:SetTime(math.random() * .7)
    end

    if inst._overlayfx == nil then
        inst._overlayfx = { fx }
    else
        table.insert(inst._overlayfx, fx)
    end
end

local function CreateBase(isnew)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("sporecloud_base")
    inst.AnimState:SetBuild("sporecloud_base")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetMultColour(.5/.6, .45/.6, .45/.6, .6)

    if isnew then
        inst.AnimState:PlayAnimation("sporecloud_base_pre")
		inst.AnimState:SetFrame(12)
        inst.AnimState:PushAnimation("sporecloud_base_idle", false)
    else
        inst.AnimState:PlayAnimation("sporecloud_base_idle")
    end

    return inst
end

local LUNAR_R, LUNAR_G, LUNAR_B, LUNAR_A = 0.2/0.6, 0.25/0.6, 1.0, 0.6
local function CreateBaseLunar(isnew)
    local inst = CreateBase(isnew)

    inst.AnimState:SetMultColour(LUNAR_R, LUNAR_G, LUNAR_B, LUNAR_A)

    return inst
end

----

local function OnStateDirty(inst)
    if inst._state:value() > 0 then
        if inst._inittask ~= nil then
            inst._inittask:Cancel()
            inst._inittask = nil
        end
        if inst._state:value() == 1 then
            if inst._basefx == nil then
                inst._basefx = inst._create_base_fn(false)
                inst._basefx.entity:SetParent(inst.entity)
            end
        elseif inst._basefx ~= nil then
            inst._basefx.AnimState:PlayAnimation("sporecloud_base_pst")
        end
    end
end

local function OnAnimOver(inst)
    inst:RemoveEventCallback("animover", OnAnimOver)
    inst._state:set(1)
end

local function OnOverlayAnimOver(fx)
    fx.AnimState:PlayAnimation("sleepcloud_overlay_loop")
end

local function KillOverlayFX(fx)
    fx:RemoveEventCallback("animover", OnOverlayAnimOver)
    fx.AnimState:PlayAnimation("sleepcloud_overlay_pst")
end

local function DoDisperse(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end

    if inst._drowsytask ~= nil then
        inst._drowsytask:Cancel()
        inst._drowsytask = nil
    end

    inst:RemoveEventCallback("animover", OnAnimOver)
    inst._state:set(2)

    inst.AnimState:PlayAnimation("sleepcloud_pst")
    inst.SoundEmitter:KillSound("spore_loop")
    inst.persists = false
    inst:DoTaskInTime(3, inst.Remove) --anim len + 1.5 sec

    if inst._basefx ~= nil then
        inst._basefx.AnimState:PlayAnimation("sporecloud_base_pst")
    end

    if inst._overlaytasks ~= nil then
        for k, v in pairs(inst._overlaytasks) do
            v:Cancel()
        end
        inst._overlaytasks = nil
    end
    if inst._overlayfx ~= nil then
        for i, v in ipairs(inst._overlayfx) do
            v:DoTaskInTime(i == 1 and 0 or math.random() * .5, KillOverlayFX)
        end
    end
end

local function OnTimerDone(inst, data)
    if data.name == "disperse" then
        DoDisperse(inst)
    end
end

local function OnLoad(inst, data)
    --Not a brand new cloud, cancel initial sound and pre-anims
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end

    inst:RemoveEventCallback("animover", OnAnimOver)

    if inst._overlaytasks ~= nil then
        for k, v in pairs(inst._overlaytasks) do
            v:Cancel()
        end
        inst._overlaytasks = nil
    end
    if inst._overlayfx ~= nil then
        for i, v in ipairs(inst._overlayfx) do
            v:Remove()
        end
        inst._overlayfx = nil
    end

    local t = inst.components.timer:GetTimeLeft("disperse")
    if t == nil or t <= 0 then
        if inst._drowsytask ~= nil then
            inst._drowsytask:Cancel()
            inst._drowsytask = nil
        end
        inst._state:set(2)
        inst.SoundEmitter:KillSound("spore_loop")
        inst:Hide()
        inst.persists = false
        inst:DoTaskInTime(0, inst.Remove)
    else
        inst._state:set(1)
        inst.AnimState:PlayAnimation("sleepcloud_loop", true)

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            inst._basefx = inst._create_base_fn(false)
            inst._basefx.entity:SetParent(inst.entity)
        end

        for i, v in ipairs(OVERLAY_COORDS) do
            SpawnOverlayFX(inst, nil, v, false)
        end
    end
end

local function InitFX(inst)
    inst._inittask = nil

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst._basefx = inst._create_base_fn(true)
        inst._basefx.entity:SetParent(inst.entity)
    end
end

local TARGET_PVP_ONEOF_TAGS = { "sleeper", "player" }
local TARGET_PVP_CANT_TAGS = { "playerghost", "FX", "DECOR", "INLIMBO" }
local TARGET_MUST_TAGS = { "sleeper" }
local TARGET_CANT_TAGS = { "player", "FX", "DECOR", "INLIMBO" }
local function DoAreaDrowsy(inst, sleeptimecache, sleepdelaycache)
    local x, y, z = inst.Transform:GetWorldPosition()
    local range = 3.5
    local t = GetTime()
    local ents =
        TheNet:GetPVPEnabled() and
        TheSim:FindEntities(x, y, z, range, nil, TARGET_PVP_CANT_TAGS, TARGET_PVP_ONEOF_TAGS) or
        TheSim:FindEntities(x, y, z, range, TARGET_MUST_TAGS, TARGET_CANT_TAGS)
    for i, v in ipairs(ents) do
		if v ~= inst.owner then
			local delayed = false
			if (sleepdelaycache[v] or 0) > TICK_PERIOD then
				if v.components.sleeper ~= nil then
					if not v.components.sleeper:IsAsleep() then
						sleepdelaycache[v] = sleepdelaycache[v] - TICK_PERIOD
						delayed = true
					end
				elseif v.components.grogginess ~= nil
					and not v.components.grogginess:IsKnockedOut() then
					sleepdelaycache[v] = sleepdelaycache[v] - TICK_PERIOD
					delayed = true
				end
			end
			if not delayed and
				not (v.components.combat ~= nil and v.components.combat:GetLastAttackedTime() + ATTACK_SLEEP_DELAY > t) and
				not (v.components.burnable ~= nil and v.components.burnable:IsBurning()) and
				not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and
				not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) and
				not (v.components.fossilizable ~= nil and v.components.fossilizable:IsFossilized()) then
				local mount = v.components.rider ~= nil and v.components.rider:GetMount() or nil
				if mount ~= nil then
					mount:PushEvent("ridersleep", { sleepiness = TICK_VALUE, sleeptime = MAX_SLEEP_TIME })
				end
				if v.components.sleeper ~= nil then
					local sleeptime = sleeptimecache[v] or MAX_SLEEP_TIME
					v.components.sleeper:AddSleepiness(TICK_VALUE, sleeptime / v.components.sleeper:GetSleepTimeMultiplier())
					if v.components.sleeper:IsAsleep() then
						sleeptimecache[v] = math.max(MIN_SLEEP_TIME, sleeptime - TICK_PERIOD)
						sleepdelaycache[v] = CHAIN_SLEEP_DELAY
					else
						sleeptimecache[v] = nil
					end
				elseif v.components.grogginess ~= nil then
					local sleeptime = sleeptimecache[v] or PLAYER_MAX_SLEEP_TIME
					if v.components.grogginess:IsKnockedOut() then
						v.components.grogginess:ExtendKnockout(sleeptime)
						sleeptimecache[v] = math.max(PLAYER_MIN_SLEEP_TIME, sleeptime - TICK_PERIOD)
						sleepdelaycache[v] = CHAIN_SLEEP_DELAY
					else
						v.components.grogginess:AddGrogginess(PLAYER_TICK_VALUE, sleeptime)
						if v.components.grogginess:IsKnockedOut() then
							sleeptimecache[v] = math.max(PLAYER_MIN_SLEEP_TIME, sleeptime - TICK_PERIOD)
							sleepdelaycache[v] = CHAIN_SLEEP_DELAY
						else
							sleeptimecache[v] = nil
						end
					end
				else
					v:PushEvent("knockedout")
				end
			else
				sleeptimecache[v] = nil
			end
		end
    end
end

local function SetOwner(inst, owner)
	inst.owner = owner
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sleepcloud")
    inst.AnimState:SetBuild("sleepcloud")
    inst.AnimState:PlayAnimation("sleepcloud_pre")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")

    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_cloud_LP", "spore_loop")

    inst._state = net_tinybyte(inst.GUID, "sleepcloud._state", "statedirty")

    inst._inittask = inst:DoTaskInTime(0, InitFX)

    inst._create_base_fn = CreateBase

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("statedirty", OnStateDirty)

        return inst
    end

    inst._drowsytask = inst:DoPeriodicTask(TICK_PERIOD, DoAreaDrowsy, nil, {}, {})

    inst.AnimState:PushAnimation("sleepcloud_loop", true)
    inst:ListenForEvent("animover", OnAnimOver)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("disperse", TUNING.SLEEPBOMB_DURATION)

    inst:ListenForEvent("timerdone", OnTimerDone)

	inst.SetOwner = SetOwner
    inst.OnLoad = OnLoad

    inst._overlaytasks = {}
    for i, v in ipairs(OVERLAY_COORDS) do
        inst._overlaytasks[i] = inst:DoTaskInTime(i == 1 and 0 or math.random() * .7, SpawnOverlayFX, i, v, true)
    end

    return inst
end

----
local function lunar_fn()
    local inst = fn()

    inst._create_base_fn = CreateBaseLunar

    return inst
end

----

local function overlayfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("sleepcloud")
    inst.AnimState:SetBuild("sleepcloud")
    inst.AnimState:PlayAnimation("sleepcloud_overlay_pre")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", OnOverlayAnimOver)

    inst.persists = false

    return inst
end

return Prefab("sleepcloud", fn, assets, prefabs),
    Prefab("sleepcloud_overlay", overlayfn, assets),
    Prefab("sleepcloud_lunar", lunar_fn, assets, prefabs)
