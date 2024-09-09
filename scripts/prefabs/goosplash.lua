local assets =
{
    Asset("ANIM", "anim/lavaarena_hits_splash.zip"),
    Asset("ANIM", "anim/gooball_fx.zip"),
}

local BASE_SCALE = 1 / 3
local NUM_SPLASH_VARS = 2
local NUM_BASE_VARS = 4

local function DoSplash(inst, variation)
    inst.AnimState:PlayAnimation("player_hit_"..tostring(4 + variation))
end

local function CreateSplash(variation, flip)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("gooball_fx")
    inst.AnimState:SetBuild("gooball_fx")
    inst.AnimState:SetMultColour(.2, 1, 0, 1)
    inst.AnimState:SetFinalOffset(3)
    if flip then
        inst.AnimState:SetScale(-1, 1)
    end

    inst:ListenForEvent("animover", inst.Remove)
    inst:DoTaskInTime(.1, DoSplash, variation)

    return inst
end

local function CreateBase(variation, flip)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lavaarena_hits_splash")
    inst.AnimState:SetBuild("lavaarena_hits_splash")
    inst.AnimState:PlayAnimation("player_hit_"..tostring(variation))
    inst.AnimState:SetMultColour(.2, 1, 0, 1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(flip and -BASE_SCALE or BASE_SCALE, BASE_SCALE)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function PlaySplashAnim(proxy, num)
    --Splash
    local variation = math.ceil(num / NUM_BASE_VARS)
    local fx = CreateSplash(variation, proxy.flip:value() == 2 or proxy.flip:value() == 4)
    fx.Transform:SetFromProxy(proxy.GUID)
    local x, y, z = fx.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x, y + .7, z)

    CreateBase(num - (variation - 1) * NUM_BASE_VARS, proxy.flip:value() > 2).Transform:SetFromProxy(proxy.GUID)
end

local function MakeSplash(name, num, prefabs)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        local n = num or math.random(NUM_SPLASH_VARS * NUM_BASE_VARS)

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed
            inst:DoTaskInTime(.15 + math.random() * .05, PlaySplashAnim, n)
        end

        inst.flip = net_tinybyte(inst.GUID, "goosplash.flip")

        if num == nil then
            inst:SetPrefabName(name..tostring(n))
        end
        inst:SetPrefabNameOverride("goosplash")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.flip:set(math.random(4))

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local ret = {}
local prefs = {}
for i = 1, NUM_SPLASH_VARS * NUM_BASE_VARS do
    local name = "goosplash"..tostring(i)
    table.insert(prefs, name)
    table.insert(ret, MakeSplash(name, i))
end
table.insert(ret, MakeSplash("goosplash", nil, prefs))
prefs = nil

--For searching: "goosplash1", "goosplash2", "goosplash3", "goosplash4"
return unpack(ret)
