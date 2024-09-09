local assets =
{
    Asset("ANIM", "anim/moonstorm_groundlight.zip"),
}

local prefabs =
{

}

local ENDPOINTS = 5

local function convertnodelist(data)
    local newdata = {}
    for i,entry in ipairs(data)do
        newdata[entry] = true
    end
    return newdata
end

local function checkspawn(inst)

    if not ThePlayer then
        return
    end

    local pos = Vector3(inst.Transform:GetWorldPosition())

    local radius = 8
    local anglemod = 0

    if inst.anglemod then
        anglemod = inst.anglemod
    else
        anglemod = (math.random()*40 -20) *DEGREES
    end

    local angle = (inst.Transform:GetRotation() * DEGREES) + (PI/2) + anglemod
    local newpos = Vector3(pos.x + math.cos(angle) * radius, 0, pos.z - math.sin(angle) * radius)

    if not TheWorld.Map:IsVisualGroundAtPoint(newpos.x, 0, newpos.z) then
        return false
    end

    local dist = ThePlayer:GetDistanceSqToPoint(newpos.x, 0, newpos.z)

    local node_index = TheWorld.Map:GetNodeIdAtPoint(newpos.x, 0, newpos.z)
    local nodes = TheWorld.net.components.moonstorms._moonstorm_nodes:value()

    local test = false
    for i, node in pairs(nodes) do
        if node == node_index then
            test = true
            break
        end
    end
    if dist < 30*30 and test then
        local newfx = SpawnPrefab("moonstorm_ground_lightning_fx")
        newfx.Transform:SetPosition(newpos.x,newpos.y,newpos.z)
        newfx.Transform:SetRotation(inst.Transform:GetRotation() + (anglemod/DEGREES))
        newfx.anglemod = anglemod
    end

end

local function fn(pondtype)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBuild("moonstorm_groundlight")
    inst.AnimState:SetBank("moonstorm_groundlight")
    local anim = math.random() < 0.5 and "strike" or "strike2"

    inst.AnimState:PlayAnimation(anim)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.AnimState:SetMultColour(0.5,0.5,1,1)

    inst.Transform:SetScale(1,1,1)
    inst.Transform:SetRotation(math.random()*360)
    --inst.Transform:SetRotation(90)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    -- From watersource component
    inst:AddTag("fx")
    inst:AddTag("NOCLICK")

    inst:DoTaskInTime(13*FRAMES,function() checkspawn(inst) end)
    inst:ListenForEvent("animover", function() inst:Remove() end)

    inst.SoundEmitter:PlaySound("moonstorm/common/moonstorm/electricity")

    inst.persists = false

    return inst
end

return Prefab("moonstorm_ground_lightning_fx", fn, assets, prefabs)