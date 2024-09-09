local assets =
{
    Asset("ANIM", "anim/lunar_rift_crystals.zip"),

    Asset("MINIMAP_IMAGE", "lunar_rift_crystals"),
}

local prefabs =
{
    "collapse_small",
    "lunarrift_crystal_spawn_fx",
    "mining_crystal_fx",
    "purebrilliance",
}

local HALF_WORK = 0.5*TUNING.LUNARRIFT_CRYSTAL_MINES

--------------------------------------------------------------------------
local CRYSTAL_SPAWNIN_BLOCK_RADIUS = 1.0
local REGISTERED_CRYSTAL_SPAWNIN_BLOCK_TAGS = nil
local function finish_crystal_spawnin(inst)
    REGISTERED_CRYSTAL_SPAWNIN_BLOCK_TAGS = REGISTERED_CRYSTAL_SPAWNIN_BLOCK_TAGS or TheSim:RegisterFindTags(
        nil,
        {"flying", "ghost", "playerghost", "INLIMBO", "FX", "DECOR"},
        {"character", "structure"}
    )

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local blockers = TheSim:FindEntities_Registered(ix, iy, iz, CRYSTAL_SPAWNIN_BLOCK_RADIUS, REGISTERED_CRYSTAL_SPAWNIN_BLOCK_TAGS)
    if #blockers == 0 then
        inst:ReturnToScene()
        inst.AnimState:PlayAnimation(inst._anim_prefix, true)

        local spawn_fx = SpawnPrefab("lunarrift_crystal_spawn_fx")
        spawn_fx.entity:SetParent(inst.entity)

        inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
    else
        inst._spawnin_attempts = (inst._spawnin_attempts or 0) + 1

        if inst._spawnin_attempts > 30 then
            inst:Remove()
        else
            inst.components.timer:StartTimer("finish_spawnin", 1.0)
        end
    end
end

local function do_crystal_spawnin(inst, time)
    inst.AnimState:PlayAnimation("empty")
    inst.components.timer:StopTimer("finish_spawnin")
    inst.components.timer:StartTimer("finish_spawnin", time)
    inst:RemoveFromScene()
end

--------------------------------------------------------------------------
-- An extra-safe cleanup in case the terraformer reverting fails to find & destroy us.
local function do_deterraform_cleanup(inst)
    if inst:IsInLimbo() then
        inst:Remove()
    else
        inst.components.lootdropper:SetLoot(nil)
        inst.components.lootdropper:SetChanceLootTable(nil)
        inst.components.workable:Destroy(inst)
    end
end

--------------------------------------------------------------------------
local function on_crystal_timerdone(inst, data)
    if data.name == "finish_spawnin" then
        finish_crystal_spawnin(inst)
    elseif data.name == "do_deterraform_cleanup" then
        do_deterraform_cleanup(inst)
    end
end

--------------------------------------------------------------------------
local function ShouldRecoil(inst, worker, tool, numworks)
	if inst.components.workable:GetWorkLeft() > math.max(1, numworks) and
		not (worker ~= nil and (worker:HasTag("toughworker") or worker:HasTag("explosive"))) and
		not (tool ~= nil and tool.components.tool ~= nil and tool.components.tool:CanDoToughWork())
		then
		--
		local t = GetTime()
		if inst._recoils == nil then
			inst._recoils = {}
		end
		for k, v in pairs(inst._recoils) do
			if t - v > 10 then
				inst._recoils[k] = nil
			end
		end
		if inst._recoils[worker] == nil then
			inst._recoils[worker] = t - (2 + math.random())
		elseif t - inst._recoils[worker] > 3 then
			inst._recoils[worker] = t - math.random()
			return true, numworks * .1 --recoil and only do a tiny bit of work
		end
	end
	return false, numworks
end

-- Save/Load -------------------------------------------------------------
local function OnSave(inst, data)
    if inst._spawnin_attempts then
        data.spawnin_attempts = inst._spawnin_attempts
    end
end

local function OnLoad(inst, data)
    if data then
        if inst.components.timer:TimerExists("finish_spawnin") then
            inst.AnimState:PlayAnimation("empty")
            inst:RemoveFromScene()
        end

        if data.spawnin_attempts then
            inst._spawnin_attempts = data.spawnin_attempts
        end
    end
end

--------------------------------------------------------------------------
local function basecrystal_fn(anim_prefix, physics_size)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, physics_size or 0.6)

    inst.MiniMapEntity:SetIcon("lunar_rift_crystals.png")

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("lunar_rift_crystals")
    inst.AnimState:SetBuild("lunar_rift_crystals")
    inst.AnimState:PlayAnimation(anim_prefix, true)
    inst.AnimState:SetLightOverride(0.1)

    inst.pickupsound = "gem"

    inst:AddTag("birdblocker")
    inst:AddTag("boulder")
    inst:AddTag("crystal")

    inst.scrapbook_specialinfo = "LUNARRIFTCRYSTAL"

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------------------------
    local inspectable = inst:AddComponent("inspectable")
    inspectable.nameoverride = "LUNARRIFT_CRYSTAL"

    -----------------------------------------
    inst:AddComponent("lootdropper")

    -----------------------------------------
    local workable = inst:AddComponent("workable")
    workable:SetWorkAction(ACTIONS.MINE)
	workable:SetShouldRecoilFn(ShouldRecoil)
    workable.savestate = true

    -----------------------------------------
    inst:AddComponent("savedrotation")

    -----------------------------------------
    inst:AddComponent("timer")

    -----------------------------------------
    inst:ListenForEvent("docrystalspawnin", do_crystal_spawnin)
    inst:ListenForEvent("timerdone", on_crystal_timerdone)

    -----------------------------------------
    MakeHauntableWork(inst)

    -----------------------------------------
    MakeSnowCovered(inst)

    -----------------------------------------
    inst._anim_prefix = anim_prefix

    -----------------------------------------
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    -----------------------------------------
    return inst
end

--------------------------------------------------------------------------------
SetSharedLootTable("lunarrift_crystal_big",
{
    {"purebrilliance", 1.00},
    {"purebrilliance", 0.75},
})

local function on_big_crystal_worked(inst, worker, work_left)
    if work_left <= 0 then
        local position = inst:GetPosition()
        SpawnPrefab("mining_moonglass_fx").Transform:SetPosition(position:Get())
        SpawnPrefab("collapse_small").Transform:SetPosition(position:Get())

        inst.components.lootdropper:DropLoot(position)

        inst:Remove()
    else
		local anim = work_left <= HALF_WORK and "half" or "full"
		if not inst.AnimState:IsCurrentAnimation(anim) then
			inst.AnimState:PlayAnimation(anim, true)
		end
    end
end

local function big_fn()
    local crystal = basecrystal_fn("full", 1.0)
    crystal.scrapbook_anim = "full"
    if not TheWorld.ismastersim then
        return crystal
    end

    crystal.components.lootdropper:SetChanceLootTable("lunarrift_crystal_big")

    crystal.components.workable:SetWorkLeft(TUNING.LUNARRIFT_CRYSTAL_MINES)
    crystal.components.workable:SetOnWorkCallback(on_big_crystal_worked)

    return crystal
end

--------------------------------------------------------------------------------
SetSharedLootTable("lunarrift_crystal_small",
{
    {"purebrilliance", 0.75},
})

local function on_small_crystal_worked(inst, worker, work_left)
    if work_left <= 0 then
        local position = inst:GetPosition()
        SpawnPrefab("mining_moonglass_fx").Transform:SetPosition(position:Get())
        SpawnPrefab("collapse_small").Transform:SetPosition(position:Get())

        inst.components.lootdropper:DropLoot(position)

        inst:Remove()
    end
end

local SMALL_LOOT = {"purebrilliance"}
local function small_fn()
    local crystal = basecrystal_fn("small", 0.25, SMALL_LOOT)
    crystal.scrapbook_anim = "small"
    if not TheWorld.ismastersim then
        return crystal
    end

    crystal.components.lootdropper:SetChanceLootTable("lunarrift_crystal_small")

    crystal.components.workable:SetWorkLeft(HALF_WORK)
    crystal.components.workable:SetOnWorkCallback(on_small_crystal_worked)

    return crystal
end

return Prefab("lunarrift_crystal_big", big_fn, assets, prefabs),
    Prefab("lunarrift_crystal_small", small_fn, assets, prefabs)
