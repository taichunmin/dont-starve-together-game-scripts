local prefabs =
{
	"daywalker",
	"daywalker_pillar",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("daywalkerspawningground")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    TheWorld:PushEvent("ms_registerdaywalkerspawningground", inst)

    return inst
end

return Prefab("daywalkerspawningground", fn, nil, prefabs)
