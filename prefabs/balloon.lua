local assets =
{
    Asset("ANIM", "anim/balloon.zip"),
    Asset("ANIM", "anim/balloon_shapes.zip"),
}

local colours =
{
    { 198/255,  43/255,  43/255, 1 },
    {  79/255, 153/255,  68/255, 1 },
    {  35/255, 105/255, 235/255, 1 },
    { 233/255, 208/255,  69/255, 1 },
    { 109/255,  50/255, 163/255, 1 },
    { 222/255, 126/255,  39/255, 1 },
}

local easing = require("easing")

local balloons = {}
local MAX_BALLOONS = 100
local num_balloons = 0

local function onsave(inst, data)
    data.num = inst.balloon_num
    data.colour_idx = inst.colour_idx
end

local function onload(inst, data)
    if data ~= nil then
        if data.num ~= nil and inst.balloon_num ~= data.num then
            inst.balloon_num = data.num
            inst.AnimState:OverrideSymbol("swap_balloon", "balloon_shapes", "balloon_"..tostring(inst.balloon_num))
        end
        if data.colour_idx ~= nil and inst.colour_idx ~= data.colour_idx then
            inst.colour_idx = math.clamp(data.colour_idx, 1, #colours)
            inst.AnimState:SetMultColour(unpack(colours[inst.colour_idx]))
        end
    end
end

local function oncollide(inst, other)    
    if (inst:IsValid() and Vector3(inst.Physics:GetVelocity()):LengthSq() > .1) or
        (other ~= nil and other:IsValid() and other.Physics ~= nil and Vector3(other.Physics:GetVelocity()):LengthSq() > .1) then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
        --inst.SoundEmitter:PlaySound("dontstarve/common/balloon_bounce")
    end
end

local function updatemotorvel(inst, xvel, yvel, zvel, t0)
    local x, y, z = inst.Transform:GetWorldPosition()
    if y >= 35 then
        inst:Remove()
        return
    end
    local time = GetTime() - t0
    if time >= 15 then
        inst:Remove()
        return
    elseif time < 1 then
        local scale = easing.inQuad(time, 1, -1, 1)
        inst.DynamicShadow:SetSize(scale, .5 * scale)
    else
        inst.DynamicShadow:Enable(false)
    end
    local hthrottle = easing.inQuad(math.clamp(time - 1, 0, 3), 0, 1, 3)
    yvel = easing.inQuad(math.min(time, 3), 1, yvel - 1, 3)
    inst.Physics:SetMotorVel(xvel * hthrottle, yvel, zvel * hthrottle)
end

local function UnregisterBalloon(inst)
    if balloons[inst] == nil then
        return
    end
    balloons[inst] = nil
    num_balloons = num_balloons - 1
    inst.OnRemoveEntity = nil
end

local function flyoff(inst)
    UnregisterBalloon(inst)
    inst:AddTag("notarget")
    inst.Physics:SetCollisionCallback(nil)
    inst.persists = false

    local xvel = math.random() * 2 - 1
    local yvel = 5
    local zvel = math.random() * 2 - 1

    inst:DoPeriodicTask(FRAMES, updatemotorvel, nil, xvel, yvel, zvel, GetTime())
end

local function RegisterBalloon(inst)
    if balloons[inst] then
        return
    end
    if num_balloons >= TUNING.BALLOON_MAX_COUNT then
        local rand = math.random(num_balloons)
        for k, v in pairs(balloons) do
            if rand > 1 then
                rand = rand - 1
            else
                flyoff(k)
                break
            end
        end
    end
    balloons[inst] = true
    num_balloons = num_balloons + 1
    inst.OnRemoveEntity = UnregisterBalloon
end

--local function ontimerdone(inst, data)
--    if data.name == "flyoff" then
--        flyoff(inst)
--    end
--end

local function DoAreaAttack(inst)
    inst.components.combat:DoAreaAttack(inst, 2, nil, nil, nil, { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" })
end

local function OnDeath(inst)
    UnregisterBalloon(inst)
    RemovePhysicsColliders(inst)
    inst.AnimState:PlayAnimation("pop")
    inst.SoundEmitter:PlaySound("dontstarve/common/balloon_pop")
    inst.DynamicShadow:Enable(false)
    inst:AddTag("NOCLICK")
    inst.persists = false
    local attack_delay = .1 + math.random() * .2
    local remove_delay = math.max(attack_delay, inst.AnimState:GetCurrentAnimationLength()) + FRAMES
    inst:DoTaskInTime(attack_delay, DoAreaAttack)
    inst:DoTaskInTime(remove_delay, inst.Remove)
end

local function OnHaunt(inst)
    inst.components.health:Kill()
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .25)
    inst.Physics:SetFriction(.3)
    inst.Physics:SetDamping(0)
    inst.Physics:SetRestitution(1)

    inst.AnimState:SetBank("balloon")
    inst.AnimState:SetBuild("balloon")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetRayTestOnBB(true)

    inst.DynamicShadow:SetSize(1, .5)

    inst:AddTag("cattoyairborne")
    inst:AddTag("balloon")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(oncollide)

    inst.AnimState:SetTime(math.random() * 2)

    inst.balloon_num = math.random(4)
    inst.AnimState:OverrideSymbol("swap_balloon", "balloon_shapes", "balloon_"..tostring(inst.balloon_num))
    inst.colour_idx = math.random(#colours)
    inst.AnimState:SetMultColour(unpack(colours[inst.colour_idx]))

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(5)
    inst:ListenForEvent("death", OnDeath)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1)
    inst.components.health.nofadeout = true

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown_on_successful_haunt = false
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    --inst:AddComponent("timer")
    --inst:ListenForEvent("timerdone", ontimerdone)

    inst.OnSave = onsave
    inst.OnLoad = onload

    RegisterBalloon(inst)

    return inst
end

return Prefab("balloon", fn, assets)
