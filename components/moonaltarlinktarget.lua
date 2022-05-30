local link_search_tags = { "moonaltarlinktarget" }

local function breaklink(inst)
    if inst.components.moonaltarlinktarget.link ~= nil then
        inst.components.moonaltarlinktarget.link.components.moonaltarlink:BreakLink()
    end
end

local MoonAltarLinkTarget = Class(function(self, inst)
    self.inst = inst
    self.link = nil
    self.link_radius = 20

    -- self.onlinkfn = nil
    -- self.onlinkbrokenfn = nil

    -- self.onfoundotheraltarfn = nil

    -- self.canbelinkedfn = nil

    self.inst:AddTag("moonaltarlinktarget")

    self.inst:ListenForEvent("onremove", breaklink)
end)

function MoonAltarLinkTarget:OnRemoveFromEntity()
    self.inst:RemoveTag("moonaltarlinktarget")

    self.inst:RemoveEventCallback("onremove", breaklink)
end

function MoonAltarLinkTarget:TryEstablishLink()
    local x, y, z = self.inst.Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, self.link_radius, link_search_tags)

    local looking_for_altars = { moon_altar = true, moon_altar_cosmic = true, moon_altar_astral = true }
    looking_for_altars[self.inst.prefab] = nil

    local altars = { self.inst }
    local altars_found = 1

    for i, v in ipairs(ents) do
        if looking_for_altars[v.prefab] and v.components.moonaltarlinktarget:CanBeLinked() then
            local tx, _, tz = v.Transform:GetWorldPosition()
            if VecUtil_LengthSq(tx - x, tz - z) >= TUNING.MOON_ALTAR_LINK_ALTAR_MIN_RADIUS_SQ then
                table.insert(altars, v)
                looking_for_altars[v.prefab] = nil
                altars_found = altars_found + 1

                if self.onfoundotheraltarfn ~= nil then
                    self.onfoundotheraltarfn(self.inst, v)
                end

                if altars_found == 3 then
                    if TheWorld.components.moonstormmanager:TestAltarTriangleValid(altars[1], altars[2], altars[3]) then
                        SpawnPrefab("moon_altar_link").components.moonaltarlink:EstablishLink(altars)
                    end

                    return
                end
            end
        end
    end
end

function MoonAltarLinkTarget:CanBeLinked()
    return self.canbelinkedfn == nil or self.canbelinkedfn(self.inst)
end

return MoonAltarLinkTarget
