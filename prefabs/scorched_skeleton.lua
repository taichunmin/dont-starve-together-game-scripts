local assets =
{
    Asset("ANIM", "anim/scorched_skeletons.zip"),
}

local animstates = { 1, 2, 3, 4, 5, 6 }

local function onsave(inst, data)
    data.anim = inst.animnum
end

local function onload(inst, data)
    if data ~= nil then
        if data.anim ~= nil then
            inst.animnum = data.anim
            inst.AnimState:PlayAnimation("idle"..inst.animnum)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeSmallObstaclePhysics(inst, 0.25)

    inst.AnimState:SetBank("skeleton")
    inst.AnimState:SetBuild("scorched_skeletons")

    inst.animnum = animstates[math.random(#animstates)]
    inst.AnimState:PlayAnimation("idle"..inst.animnum)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return Prefab("scorched_skeleton", fn, assets)