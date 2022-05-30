--require_health being true means an entity is considered "dead" if it lacks the health replica.
function IsEntityDead(inst, require_health)
    if inst.replica.health == nil then
        return require_health == true
    end
    return inst.replica.health:IsDead()
end

function IsEntityDeadOrGhost(inst, require_health)
    if inst:HasTag("playerghost") then
        return true
    end
    return IsEntityDead(inst, require_health)
end

function GetStackSize(inst)
    if inst.replica.stackable == nil then
        return 1
    end
    return inst.replica.stackable:StackSize()
end