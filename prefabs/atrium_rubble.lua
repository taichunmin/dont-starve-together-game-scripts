local assets =
{
    Asset("ANIM", "anim/atrium_rubble.zip"),
}

local _storyprogress = 0
local NUM_STORY_LINES = 5

local function SetAnimId(inst, id)
    if inst.animid ~= id then
        inst.animid = id
        inst.AnimState:PlayAnimation("idle"..tostring(id))
    end
end

local function getstatus(inst)
    if inst.storyprogress == nil then
        _storyprogress = (_storyprogress % NUM_STORY_LINES) + 1
        inst.storyprogress = _storyprogress
    end

    return "LINE_"..tostring(inst.storyprogress)
end

local function OnSave(inst, data)
    data.storyprogress = inst.storyprogress
    data.animid = inst.animid
end

local function OnLoad(inst, data)
    if data ~= nil and data.animid ~= nil then
        SetAnimId(inst, data.animid)
    end

    if data ~= nil and data.storyprogress ~= nil then
        inst.storyprogress = data.storyprogress
        _storyprogress = (_storyprogress % NUM_STORY_LINES) + 1
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("atrium_rubble")
    inst.AnimState:SetBuild("atrium_rubble")
    inst.AnimState:PlayAnimation("idle1")

    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("atrium_rubble.png")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    MakeHauntableWork(inst)

    inst.animid = 1
    SetAnimId(inst, math.random(2))

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("atrium_rubble", fn, assets)
