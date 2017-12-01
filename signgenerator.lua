require "strings"

local function GenerateRandomDescription(inst, doer)
    local quant = nil
    if math.random() < .4 then
        quant = GetRandomItem(STRINGS.SIGNS.QUANTIFIERS)
    end

    local adj = GetRandomItem(STRINGS.SIGNS.ADJECTIVES)

    local ground_type = doer:GetCurrentTileType()
    local noun = ""
    if STRINGS.SIGNS.NOUNS[ground_type] then
        noun = GetRandomItem(STRINGS.SIGNS.NOUNS[ground_type])
    else
        noun = GetRandomItem(STRINGS.SIGNS.DEFAULT_NOUNS)
    end

    local add = nil
    if math.random() < .2 then
        add = GetRandomItem(STRINGS.SIGNS.ADDITIONS)
    end

    local fmt = quant ~= nil
                and (add ~= nil
                     and STRINGS.SIGNS.QUANT_ADJ_NOUN_ADD_FMT
                     or STRINGS.SIGNS.QUANT_ADJ_NOUN_FMT)
                or (add ~= nil
                    and STRINGS.SIGNS.ADJ_NOUN_ADD_FMT
                    or STRINGS.SIGNS.ADJ_NOUN_FMT)

    return subfmt(fmt, {noun=noun, adjective=adj, quantifier=quant, addition=add})
end

return GenerateRandomDescription
