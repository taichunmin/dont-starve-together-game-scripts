local assets =
{
    Asset("ANIM", "anim/trinkets.zip"),
}

local toy_trinket_nums =
{
    1,
    2,
    7,
    10,
    11,
    14,
    18,
    19,
    42,
    43,
}
local MIN_FADE_VALUE = 0.00
local MIN_FADE_COLOUR = {1.00, 1.00, 1.00, MIN_FADE_VALUE}
local MAX_FADE_VALUE = 0.70
local MAX_FADE_COLOUR = {1.00, 1.00, 1.00, MAX_FADE_VALUE}
local FADE_DIFFERENCE = MAX_FADE_VALUE - MIN_FADE_VALUE
local FADE_TIME = 1.5

local function on_player_near(inst)
    local current_colour = inst.AnimState:GetMultColour()
    if current_colour ~= nil then
        local _fade_time = FADE_TIME * ((MAX_FADE_VALUE - current_colour) / FADE_DIFFERENCE)
        inst.components.colourtweener:StartTween( MAX_FADE_COLOUR, _fade_time )
    else
        inst.components.colourtweener:StartTween( MAX_FADE_COLOUR, FADE_TIME )
    end
end

local function on_player_far(inst)
    local current_colour = inst.AnimState:GetMultColour()
    if current_colour ~= nil then
        local _fade_time = FADE_TIME * ((current_colour - MIN_FADE_VALUE) / FADE_DIFFERENCE)
        inst.components.colourtweener:StartTween( MIN_FADE_COLOUR, _fade_time )
    else
        inst.components.colourtweener:StartTween( MIN_FADE_COLOUR, FADE_TIME )
    end
end

local function MakeTrinket(num)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        local entity_physics = inst.entity:AddPhysics()
        entity_physics:SetMass(1.0)
        entity_physics:SetFriction(0.1)
        entity_physics:SetDamping(0.0)
        entity_physics:SetRestitution(0.5)
        entity_physics:SetCollisionGroup(COLLISION.ITEMS)
        entity_physics:ClearCollisionMask()
        entity_physics:CollidesWith(COLLISION.WORLD)
        entity_physics:SetSphere(0.5)

        inst.entity:AddNetwork()

        inst.AnimState:SetBank("trinkets")
        inst.AnimState:SetBuild("trinkets")
        inst.AnimState:PlayAnimation(tostring(num))        
        inst.AnimState:SetMultColour(unpack(MIN_FADE_COLOUR))
        inst.AnimState:SetHaunted(true)

        -- Lost toys are permanently haunted.
        inst:AddTag("haunted")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst.scrapbook_anim = tostring(num)
        inst.scrapbook_specialinfo = "LOSTTOY"
        inst.scrapbook_alpha = 0.4

        inst._current_fade = MIN_FADE_VALUE

        -- Lost toys are saved & spawned by the ghost that creates them; see "smallghost"
        inst.persists = false

        inst:AddComponent("inspectable")

        inst:AddComponent("playerprox")
        inst.components.playerprox:SetDist(TUNING.GHOST_HUNT.TOY_FADE.IN, TUNING.GHOST_HUNT.TOY_FADE.IN)
        inst.components.playerprox:SetOnPlayerNear(on_player_near)
        inst.components.playerprox:SetOnPlayerFar(on_player_far)

        inst:AddComponent("colourtweener")

        return inst
    end

    return Prefab("lost_toy_"..tostring(num), fn, assets)
end

local ret = {}
for _, k in ipairs(toy_trinket_nums) do
    table.insert(ret, MakeTrinket(k))
end

return unpack(ret)
