local function EndBlockSoulHealFX(v)
    v.blocksoulhealfxtask = nil
end

local function DoHeal(inst)
    local targets = {}
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(AllPlayers) do
        if not (v.components.health:IsDead() or v:HasTag("playerghost")) and
            v.entity:IsVisible() and
            v:GetDistanceSqToPoint(x, y, z) < TUNING.WORTOX_SOULHEAL_RANGE * TUNING.WORTOX_SOULHEAL_RANGE then
            table.insert(targets, v)
        end
    end
    if #targets > 0 then
        local amt = TUNING.HEALING_MED - math.min(8, #targets) + 1
        for i, v in ipairs(targets) do
            --always heal, but don't stack visual fx
            v.components.health:DoDelta(amt, nil, inst.prefab)
            if v.blocksoulhealfxtask == nil and v.components.combat then
                v.blocksoulhealfxtask = v:DoTaskInTime(.5, EndBlockSoulHealFX)
                local fx = SpawnPrefab("wortox_soul_heal_fx")
                fx.entity:AddFollower():FollowSymbol(v.GUID, v.components.combat.hiteffectsymbol, 0, -50, 0)
                fx:Setup(v)
            end
        end
    end
end

local function HasSoul(victim)
    return not (victim:HasTag("veggie") or
                victim:HasTag("structure") or
                victim:HasTag("wall") or
                victim:HasTag("balloon") or
                victim:HasTag("soulless") or
                victim:HasTag("chess") or
                victim:HasTag("shadow") or
                victim:HasTag("shadowcreature") or
                victim:HasTag("shadowminion") or
                victim:HasTag("shadowchesspiece") or
                victim:HasTag("groundspike") or
                victim:HasTag("smashable"))
        and (  (victim.components.combat ~= nil and victim.components.health ~= nil)
            or victim.components.murderable ~= nil )
end

local function GetNumSouls(victim)
    --V2C: assume HasSoul is checked separately
    return (victim:HasTag("dualsoul") and 2)
        or (victim:HasTag("epic") and math.random(7, 8))
        or 1
end

return {
    DoHeal = DoHeal,
    HasSoul = HasSoul,
    GetNumSouls = GetNumSouls,
}
