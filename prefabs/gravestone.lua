local assets =
{
    Asset("ANIM", "anim/gravestones.zip"),
    Asset("MINIMAP_IMAGE", "gravestones"),
}

local prefabs =
{
    "ghost",
    "mound",
}

local function onsave(inst, data)
    if inst.mound then
        data.mounddata = inst.mound:GetSaveRecord()
    end
    data.setepitaph = inst.setepitaph
end

local function onload(inst, data, newents)
    if data then
        if inst.mound and data.mounddata then
            if newents and data.mounddata.id then
                newents[data.mounddata.id] = {entity=inst.mound, data=data.mounddata} 
            end
            inst.mound:SetPersistData(data.mounddata.data, newents)
        end

        if data.setepitaph then
            --this handles custom epitaphs set in the tile editor
            inst.components.inspectable:SetDescription("'"..data.setepitaph.."'")
            inst.setepitaph = data.setepitaph
        end
    end
end

local function OnHaunt(inst)
    if inst.setepitaph == nil and #STRINGS.EPITAPHS > 1 then
        --change epitaph (if not a set custom epitaph)
        --guarantee it's not the same as b4!
        local oldepitaph = inst.components.inspectable.description
        local newepitaph = STRINGS.EPITAPHS[math.random(#STRINGS.EPITAPHS - 1)]
        if newepitaph == oldepitaph then
            newepitaph = STRINGS.EPITAPHS[#STRINGS.EPITAPHS]
        end
        inst.components.inspectable:SetDescription(newepitaph)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
    else
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    end
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .25)

    inst.MiniMapEntity:SetIcon("gravestones.png")

    inst:AddTag("grave")

    inst.AnimState:SetBank("gravestone")
    inst.AnimState:SetBuild("gravestones")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PlayAnimation("grave"..tostring(math.random(4)))

    inst:AddComponent("inspectable")
    inst.components.inspectable:SetDescription(STRINGS.EPITAPHS[math.random(#STRINGS.EPITAPHS)])

    inst.mound = inst:SpawnChild("mound")

    --local pos = Vector3(0,0,0)
    --pos.x = pos.x -.407
    --pos.z = pos.z -.407

    inst.OnLoad = onload
    inst.OnSave = onsave

    inst.mound.Transform:SetPosition((TheCamera:GetDownVec()*.5):Get())

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    return inst
end

return Prefab("gravestone", fn, assets, prefabs)
