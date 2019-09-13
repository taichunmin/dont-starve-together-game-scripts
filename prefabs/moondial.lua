require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/moondial.zip"),
    Asset("ANIM", "anim/moondial_build.zip"),
    Asset("ANIM", "anim/moondial_waning_build.zip"),
}

local prefabs =
{
    "rock_break_fx",
    "globalmapicon",
}

local lightstates =
{
    new                 = {override=0.00,   enabled=false,  radius=0.00},
    quarter             = {override=0.00,   enabled=false,  radius=0.00},
    half                = {override=0.10,   enabled=true,   radius=0.70},
    threequarter        = {override=0.10,   enabled=true,   radius=1.50},
    full                = {override=0.50,   enabled=true,   radius=5.00},
}

local function onmoonphasechagned(inst, phase)
    if (TheWorld.state.iswaxingmoon and TheWorld.state.moonphase ~= "new") or TheWorld.state.moonphase == "full" then
        inst.AnimState:ClearOverrideSymbol("reflection_quarter")
        inst.AnimState:ClearOverrideSymbol("reflection_half")
        inst.AnimState:ClearOverrideSymbol("reflection_threequarter")
    else
        inst.AnimState:OverrideSymbol("reflection_quarter", "moondial_waning_build", "reflection_quarter")
        inst.AnimState:OverrideSymbol("reflection_half", "moondial_waning_build", "reflection_half")
        inst.AnimState:OverrideSymbol("reflection_threequarter", "moondial_waning_build", "reflection_threequarter")
    end

    local lightstate = lightstates[TheWorld.state.moonphase]
    inst.AnimState:SetLightOverride(lightstate.override)
    inst.Light:Enable(lightstate.enabled)
    inst.Light:SetRadius(lightstate.radius)

    if phase ~= nil then
        inst.sg:GoToState("next")
    end
end

local function onhammered(inst)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("rock_break_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function getstatus(inst, viewer)
    return TheWorld:HasTag("cave") and "CAVE"
            or (TheWorld.state.moonphase == "full" and viewer:HasTag("wereness")) and "WEREBEAVER"
            or (not TheWorld.state.isnight) and "GENERIC"
            or TheWorld.state.isnewmoon and "NIGHT_NEW"
            or TheWorld.state.isfullmoon and "NIGHT_FULL"
            or TheWorld.state.iswaxingmoon and "NIGHT_WAX"
            or "NIGHT_WANE"
end

local function init(inst)
    if inst.icon == nil then
        inst.icon = SpawnPrefab("globalmapicon")
        inst.icon:TrackEntity(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()

    MakeObstaclePhysics(inst, .45)

    inst:AddTag("structure")

    inst.AnimState:SetBank("moondial")
    inst.AnimState:SetBuild("moondial_build")
    inst.AnimState:PlayAnimation("idle_new")

    inst.Light:Enable(false)
    inst.Light:SetFalloff(.7)
    inst.Light:SetIntensity(0.6)
    inst.Light:SetColour(15 / 255, 160 / 255, 180 / 255)

    inst.MiniMapEntity:SetIcon("moondial.png")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeHauntableWork(inst)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")

    inst:WatchWorldState("moonphase", onmoonphasechagned)

    onmoonphasechagned(inst)

    inst:SetStateGraph("SGmoondial")

    inst:DoTaskInTime(0, init)

    return inst
end

return Prefab("moondial", fn, assets, prefabs),
       MakePlacer("moondial_placer", "moondial", "moondial_build", "idle_new")
