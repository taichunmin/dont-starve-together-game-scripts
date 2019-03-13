local Explosive = Class(function(self,inst)
    self.inst = inst
    self.explosiverange = 3
    self.explosivedamage = 200
    self.buildingdamage = 10
    self.lightonexplode = true
    self.onexplodefn = nil
end)

function Explosive:SetOnExplodeFn(fn)
    self.onexplodefn = fn
end

function Explosive:OnBurnt()
	if not self.skip_camera_flash then
		for i, v in ipairs(AllPlayers) do
			local distSq = v:GetDistanceSqToInst(self.inst)
			local k = math.max(0, math.min(1, distSq / 1600))
			local intensity = k * (k - 2) + 1 --easing.outQuad(k, 1, -1, 1)
			if intensity > 0 then
				v:ScreenFlash(intensity)
				v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, intensity / 2)
			end
		end
	end

    if self.onexplodefn ~= nil then
        self.onexplodefn(self.inst)
    end

    local stacksize = self.inst.components.stackable ~= nil and self.inst.components.stackable:StackSize() or 1
    local totaldamage = self.explosivedamage * stacksize

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.explosiverange, nil, { "INLIMBO" })

    for i, v in ipairs(ents) do
        if v ~= self.inst and v:IsValid() and not v:IsInLimbo() then
            if v.components.workable ~= nil and v.components.workable:CanBeWorked() then
                v.components.workable:WorkedBy(self.inst, self.buildingdamage)
            end

            --Recheck valid after work
            if v:IsValid() and not v:IsInLimbo() then
                if self.lightonexplode and
                    v.components.fueled == nil and
                    v.components.burnable ~= nil and
                    not v.components.burnable:IsBurning() and
                    not v:HasTag("burnt") then
                    v.components.burnable:Ignite()
                end

                if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
                    local dmg = totaldamage
                    if v.components.explosiveresist ~= nil then
                        dmg = dmg * (1 - v.components.explosiveresist:GetResistance())
                        v.components.explosiveresist:OnExplosiveDamage(dmg, self.inst)
                    end
                    v.components.combat:GetAttacked(self.inst, dmg, nil)
                end

                v:PushEvent("explosion", { explosive = self.inst })
            end
        end
    end

    local world = TheWorld
    for i = 1, stacksize do
        world:PushEvent("explosion", { damage = self.explosivedamage })
    end

    if self.inst.components.health ~= nil then
        self.inst:PushEvent("death")
    end

    self.inst:Remove()
end

return Explosive
