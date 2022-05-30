local assets =
{
    Asset("ANIM", "anim/stalker_shield.zip"),
}

local REPEL_RADIUS = 3
local REPEL_RADIUS_SQ = REPEL_RADIUS * REPEL_RADIUS

local function UpdateRepel(inst, x, z, creatures)
    for i = #creatures, 1, -1 do
        local v = creatures[i]
        if not (v.inst:IsValid() and v.inst.entity:IsVisible()) then
            table.remove(creatures, i)
        elseif v.speed == nil then
            local distsq = v.inst:GetDistanceSqToPoint(x, 0, z)
            if distsq < REPEL_RADIUS_SQ then
                if distsq > 0 then
                    v.inst:ForceFacePoint(x, 0, z)
                end
                local k = .5 * distsq / REPEL_RADIUS_SQ - 1
                v.speed = 25 * k
                v.dspeed = 2
                v.inst.Physics:SetMotorVelOverride(v.speed, 0, 0)
            end
        else
            v.speed = v.speed + v.dspeed
            if v.speed < 0 then
                local x1, y1, z1 = v.inst.Transform:GetWorldPosition()
                if x1 ~= x or z1 ~= z then
                    v.inst:ForceFacePoint(x, 0, z)
                end
                v.dspeed = v.dspeed + .25
                v.inst.Physics:SetMotorVelOverride(v.speed, 0, 0)
            else
                v.inst.Physics:ClearMotorVelOverride()
                v.inst.Physics:Stop()
                table.remove(creatures, i)
            end
        end
    end
end

local function TimeoutRepel(inst, creatures, task)
    task:Cancel()

    for i, v in ipairs(creatures) do
        if v.speed ~= nil then
            v.inst.Physics:ClearMotorVelOverride()
            v.inst.Physics:Stop()
        end
    end
end

local SLEEPREPEL_MUST_TAGS = { "locomotor" }
local SLEEPREPEL_CANT_TAGS = { "fossil", "shadow", "playerghost", "INLIMBO" }

local function StartRepel(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local creatures = {}
    for i, v in ipairs(TheSim:FindEntities(x, y, z, REPEL_RADIUS, SLEEPREPEL_MUST_TAGS, SLEEPREPEL_CANT_TAGS)) do
        if v:IsValid() and v.entity:IsVisible() and not (v.components.health ~= nil and v.components.health:IsDead()) then
            if v:HasTag("player") then
                v:PushEvent("repelled", { repeller = inst, radius = REPEL_RADIUS })
            elseif v.components.combat ~= nil then
                v.components.combat:GetAttacked(inst, 10)
                if v.Physics ~= nil then
                    table.insert(creatures, { inst = v })
                end
            end
        end
    end

    if #creatures > 0 then
        inst:DoTaskInTime(10 * FRAMES, TimeoutRepel, creatures,
            inst:DoPeriodicTask(0, UpdateRepel, nil, x, z, creatures)
        )
    end
end

local function MakeShield(name, num, prefabs)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        local n = num or math.random(4)

        inst.AnimState:SetBank("stalker_shield")
        inst.AnimState:SetBuild("stalker_shield")
        inst.AnimState:PlayAnimation("idle"..tostring(math.min(3, n)))
        inst.AnimState:SetFinalOffset(2)
        inst.AnimState:SetScale(n == 4 and -2.36 or 2.36, 2.36, 2.36)

        if num == nil then
            inst:SetPrefabName(name..tostring(n))
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/shield")

        inst.persists = false
        inst:ListenForEvent("animover", inst.Remove)
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)

        inst:DoTaskInTime(2 * FRAMES, StartRepel)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local ret = {}
local prefs = {}
for i = 1, 4 do
    local name = "stalker_shield"..tostring(i)
    table.insert(prefs, name)
    table.insert(ret, MakeShield(name, i))
end
table.insert(ret, MakeShield("stalker_shield", nil, prefs))
prefs = nil

--For searching: "stalker_shield1", "stalker_shield2", "stalker_shield3"
return unpack(ret)
