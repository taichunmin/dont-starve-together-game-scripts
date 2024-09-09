local prefabs_fossil =
{
    "lavaarena_fossilizing",
    "reticuleaoe",
    "reticuleaoeping",
    "reticuleaoecctarget",
}

local prefabs_elemental =
{
    "lavaarena_elemental",
    "reticuleaoesummon",
    "reticuleaoesummonping",
    "reticuleaoesummontarget",
}

--------------------------------------------------------------------------

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 7, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function MakeBook(booktype, reticule, prefabs)
    local name = "book_"..booktype
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("ANIM", "anim/swap_"..name..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation(name)

        inst:AddTag("book")

        --weapon (from weapon component) added to pristine state for optimization
        inst:AddTag("weapon")

        --rechargeable (from rechargeable component) added to pristine state for optimization
        inst:AddTag("rechargeable")

        inst:AddComponent("aoetargeting")
        inst.components.aoetargeting.reticule.reticuleprefab = reticule
        inst.components.aoetargeting.reticule.pingprefab = reticule.."ping"
        inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
        inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
        inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
        inst.components.aoetargeting.reticule.ease = true
        inst.components.aoetargeting.reticule.mouseenabled = true

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        event_server_data("lavaarena", "prefabs/books_lavaarena")[booktype.."_postinit"](inst)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

--For searching: "book_fossil", "book_elemental"
return MakeBook("fossil", "reticuleaoe", prefabs_fossil),
    MakeBook("elemental", "reticuleaoesummon", prefabs_elemental)
