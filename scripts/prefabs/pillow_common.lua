local fn_table = {}

local NOPUSH_TAGS = {"epic", "nopush"}
fn_table.DoKnockback = function(target, source, knockback_data)
    for _, tag in ipairs(NOPUSH_TAGS) do
        if target:HasTag(tag) then
            return false
        end
    end

    local target_body_item = (target.components.inventory and target.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY))
        or nil
    local knockback_defense_amount = (target_body_item and target_body_item._defense_amount) or 0

    local knockback_amount = math.max(0.025, ((knockback_data and knockback_data.amount) or 0.5))
    local knockback_strengthmult = math.max(0.5, ((knockback_data and knockback_data.strengthmult) or 1) - knockback_defense_amount)

    target:PushEvent("knockback", {
        knocker = source,
        radius = source:GetPhysicsRadius(0.5) + knockback_amount,
        strengthmult = knockback_strengthmult,
        forcelanded = (target_body_item ~= nil and target_body_item:HasTag("bodypillow")),
    })

    return true
end

return fn_table