local Distancefade = Class(function(self, inst) 
    self.inst = inst

    self.range =  25
    self.fadedist = 15
end)

function Distancefade:Setup(range,fadedist)
  self.range = range
  self.fadedist = fadedist
end

function Distancefade:SetExtraFn(fn)
  self.extrafn = fn
end


function Distancefade:OnEntitySleep()
  self.inst:StopUpdatingComponent(self)
end

function Distancefade:OnEntityWake()
  self.inst:StartUpdatingComponent(self)
end

function Distancefade:OnUpdate(dt)
    if ThePlayer == nil then
      self.inst.AnimState:SetMultColour(1,1,1,1)
      return
    end

    local fc = ThePlayer
    if fc:GetCurrentPlatform() then
      fc = fc:GetCurrentPlatform()
    end

    local campos = Vector3(fc.Transform:GetWorldPosition())
    local treepos = Vector3(self.inst.Transform:GetWorldPosition())
    local down = TheCamera:GetDownVec()
    local diffcoords = treepos-campos

    local mody = 0

    --(0.71, 0.71)
    if down.x < 0.8 and down.x > 0.6 and down.z < 0.8 and down.z > 0.6 then
        mody = diffcoords:Dot(Vector3(1,0,1):GetNormalized())
    end

    --(1.00, 0.00)
    if down.x > 0.8 and down.z < 0.1 and down.z > -0.1 then
        mody = diffcoords:Dot(Vector3(1,0,0):GetNormalized())
    end

    --(0.71,-0.71)
    if down.x < 0.8 and down.x > 0.6 and down.z > -0.8 and down.z < -0.6 then
        mody = diffcoords:Dot(Vector3(1,0,-1):GetNormalized())
    end

    --(0.0,-1)
    if down.x < 0.1 and down.x > -0.1 and down.z < -0.8 then
        mody = diffcoords:Dot(Vector3(0,0,-1):GetNormalized())
    end

    --(-0.71, -0.71)
    if down.x > -0.8 and down.x < -0.6 and down.z > -0.8 and down.z < -0.6 then
        mody = diffcoords:Dot(Vector3(-1,0,-1):GetNormalized())
    end

    --(-1.00, 0.00)
    if down.x < -0.8 and down.z < 0.1 and down.z > -0.1 then
        mody = diffcoords:Dot(Vector3(-1,0,0):GetNormalized())
    end

    --(-0.71, 0.71)
    if down.x > -0.8 and down.x < -0.6 and down.z < 0.8 and down.z > 0.6 then
        mody = diffcoords:Dot(Vector3(-1,0,1):GetNormalized())
    end

    --(0.00, 1.00)
    if down.x < 0.1 and down.x > -0.1 and down.z > 0.9 then
        mody = diffcoords:Dot(Vector3(0,0,1):GetNormalized())
    end

    local extrapercent = 1
    if self.extrafn then
      extrapercent = self.extrafn(self.inst, dt)
    end

    if mody > self.range then
      mody = mody - (self.range)
      mody = math.min(mody,self.fadedist) * 1.7
      local percent = 1- (mody/(self.fadedist))
      percent = percent *  extrapercent

      self.inst.AnimState:SetMultColour(1,1,1,percent)
    else
      local percent = 1 * extrapercent
      self.inst.AnimState:SetMultColour(1,1,1,percent)
    end      
end

return Distancefade

 


