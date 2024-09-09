local assets =
{
    Asset("ANIM", "anim/crystalblast_fx.zip"),
}

local HIT_BY_EXPLOSION_MUST_TAGS = {"_combat"}
local HIT_BY_EXPLOSION_CANT_TAGS = {"DECOR", "FX", "flight", "INLIMBO", "invisible", "lunar_aligned", "noattack", "NOCLICK", "notarget", "playerghost"}
local HIT_BY_EXPLOSION_ONEOF_TAGS = {"animal", "character", "monster", "structure"}

-- Pythag of tile scale, reigned in a little bit.
local HIT_BY_EXPLOSION_RANGE = math.sqrt((TILE_SCALE * TILE_SCALE) + (TILE_SCALE * TILE_SCALE)) / 2

local function do_explosion(inst)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local hit_by_explosion_entities = TheSim:FindEntities(
        ix, iy, iz, HIT_BY_EXPLOSION_RANGE,
        HIT_BY_EXPLOSION_MUST_TAGS,
        HIT_BY_EXPLOSION_CANT_TAGS,
        HIT_BY_EXPLOSION_ONEOF_TAGS
    )

    for _, hit_entity in ipairs(hit_by_explosion_entities) do
        -- NOTE: need to add `hit_entity ~= inst` if the FX tag gets removed from the test list or this prefab

        -- We can accept hitting things without a health component, but if they have one, they shouldn't be dead already.
        local hit_entity_is_dead = (hit_entity.components.health ~= nil and hit_entity.components.health:IsDead())
        if not hit_entity_is_dead then
            -- Hit entity should have a combat component because of the _combat tag.
            hit_entity.components.combat:GetAttacked(inst, TUNING.RIFT_LUNAR1_TERRAFORM_EXPLOSION_DAMAGE, nil)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("crystalblast")
    inst.AnimState:SetBuild("crystalblast_fx")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:PlayAnimation("blast")

    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:DoTaskInTime(5*FRAMES, do_explosion)

    inst:ListenForEvent("animover", inst.Remove)

    inst.SoundEmitter:PlaySound("rifts/fx/crystal_explode")

    return inst
end

return Prefab("lunarrift_terraformer_explosion", fn, assets)