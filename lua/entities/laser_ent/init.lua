AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local dis = 5000

sound.Add({
  name = "turbolaser",
  channel = CHAN_AUTO,
  pitch = {95,110},
  volume = 1.0,
  level = 511,
  sound = "weapons/turbolaser.wav"
})

sound.Add({
  name = "forcefield_whine",
  channel = CHAN_AUTO,
  pitch = {95,110},
  volume = 1.0,
  level = 511,
  sound = "ambient/energy/force_field_loop1.wav"
})

function ENT:Initialize()
    self:DrawShadow(false)
    self:EmitSound("turbolaser",511)
    self:EmitSound("forcefield_whine",511)
    self.DieTime = CurTime() + 5
end

function ENT:Think()
  util.ScreenShake( self:GetPos(), 5, 150, 4, 4000)

  for k,v in pairs(ents.FindInSphere(self:GetPos(),dis)) do
    if (v:IsPlayer() or v:IsNPC()) then
      local damage = 4000/v:GetPos():Distance(self:GetPos())
      v:TakeDamage(damage,self,"laser_weapon")
    end
  end

  if self.DieTime < CurTime() then
    self:StopSound("turbolaser")
    self:StopSound("forcefield_whine")
    self:Remove()
  end
end
