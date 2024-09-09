local trunkassets =
{
    Asset("ANIM", "anim/petrified_trunk_break.zip"),
}

local treeassets =
{
    Asset("ANIM", "anim/petrified_tree_fx.zip"),
}

local function SerializeDarken(inst, r, g, b)--, a)
    inst._darken:set(math.clamp(math.floor(14 * (r + g + b) / 3 - 6.5), 0, 7))
end

local function DeserializeDarken(inst)
    local val = inst._darken:value() / 14 + .5
    return val, val, val, 1
end

local function PlayFX(proxy, assetname, animname, soundname)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank(assetname)
    inst.AnimState:SetBuild(assetname)
    inst.AnimState:PlayAnimation(animname)
    inst.AnimState:SetMultColour(DeserializeDarken(proxy))
    inst.AnimState:SetFinalOffset(1)

    inst.SoundEmitter:PlaySound("dontstarve/common/together/petrified/"..soundname)

    inst:ListenForEvent("animover", inst.Remove)
end

local function SetDarkened(inst, val)
    inst._darken:set(math.clamp(math.floor((2 * val - 1) * 7 + .5), 0, 7))
end

local function makefx(assetname, animname, soundname)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            inst:DoTaskInTime(0, PlayFX, assetname, animname, soundname)
        end

        inst._darken = net_tinybyte(inst.GUID, "petrifyfx._darken")
        inst._darken:set(7)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.InheritColour = SerializeDarken

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end
end

local ret = { Prefab("petrified_trunk_break_fx", makefx("petrified_trunk_break", "break_apart", "post_stump"), trunkassets) }
for i, v in ipairs({ "_short", "_normal", "_tall", "_old" }) do
    table.insert(ret, Prefab("petrified_tree_fx"..v, makefx("petrified_tree_fx", "rock_scatter"..v, "post"), treeassets))
end
return unpack(ret)
