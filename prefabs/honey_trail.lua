local assets =
{
    Asset("ANIM", "anim/honey_trail.zip"),
}

local HONEYTRAILSLOWDOWN_MUST_TAGS = { "locomotor" }
local HONEYTRAILSLOWDOWN_CANT_TAGS = { "flying", "playerghost", "INLIMBO" }

local function OnUpdate(inst, x, y, z, rad)
    for i, v in ipairs(TheSim:FindEntities(x, y, z, rad, HONEYTRAILSLOWDOWN_MUST_TAGS, HONEYTRAILSLOWDOWN_CANT_TAGS)) do
        if v.components.locomotor ~= nil then
            v.components.locomotor:PushTempGroundSpeedMultiplier(TUNING.BEEQUEEN_HONEYTRAIL_SPEED_PENALTY, WORLD_TILES.MUD)
        end
    end
end

local function OnUpdateClient(inst, x, y, z, rad)
    local player = ThePlayer
    if player ~= nil and
        player.components.locomotor ~= nil and
        not player:HasTag("playerghost") and
        player:GetDistanceSqToPoint(x, 0, z) < rad * rad then
        player.components.locomotor:PushTempGroundSpeedMultiplier(TUNING.BEEQUEEN_HONEYTRAIL_SPEED_PENALTY, WORLD_TILES.MUD)
    end
end

local function OnIsFadingDirty(inst)
    if inst._isfading:value() then
        inst.task:Cancel()
    end
end

local function OnStartFade(inst)
    inst.AnimState:PlayAnimation(inst.trailname.."_pst")
    inst._isfading:set(true)
    inst.task:Cancel()
end

local function OnAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation(inst.trailname.."_pre") then
        inst.AnimState:PlayAnimation(inst.trailname)
        inst:DoTaskInTime(inst.duration, OnStartFade)
    elseif inst.AnimState:IsCurrentAnimation(inst.trailname.."_pst") then
        inst:Remove()
    end
end

local function OnInit(inst, scale)
    local x, y, z = inst.Transform:GetWorldPosition()
    if scale == nil then
        scale = inst.Transform:GetScale()
    end
    inst.task:Cancel()
    local onupdatefn = TheWorld.ismastersim and OnUpdate or OnUpdateClient
    inst.task = inst:DoPeriodicTask(0, onupdatefn, nil, x, y, z, scale)
    onupdatefn(inst, x, y, z, scale)
end

local function SetVariation(inst, rand, scale, duration)
    if inst.trailname == nil then
        inst.Transform:SetScale(scale, scale, scale)

        inst.trailname = "trail"..tostring(rand)
        inst.duration = duration
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/honey_drip")
        inst.AnimState:PlayAnimation(inst.trailname.."_pre")
        inst:ListenForEvent("animover", OnAnimOver)

        OnInit(inst, scale)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("honey_trail")
    inst.AnimState:SetBuild("honey_trail")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst._isfading = net_bool(inst.GUID, "honey_trail._isfading", "isfadingdirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("isfadingdirty", OnIsFadingDirty)
        inst.task = inst:DoPeriodicTask(0, OnInit)

        return inst
    end

    inst.SetVariation = SetVariation

    inst.persists = false
    inst.task = inst:DoTaskInTime(0, inst.Remove)

    return inst
end

return Prefab("honey_trail", fn, assets)
