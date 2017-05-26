include('shared.lua')

local PhysBeam = Material("sprites/physbeama.vmt")
local Energy = Material("effects/energyball")
local Flare = Material("sprites/light_glow01")
local Combine = Material("effects/ar2_altfire1")

function ENT:Draw()
    PhysBeam:SetInt("$spriterendermode", 7)
    Energy:SetInt("$spriterendermode", 7)
    Flare:SetInt("$spriterendermode", 7)
    Combine:SetInt("$spriterendermode", 7)
    
    self:SetModelScale(100)
    render.SetMaterial(PhysBeam)
    render.DrawBeam(self:GetPos(),self:GetPos() + Vector(0,0,20000),1000,CurTime()*2,CurTime()*2 + 4,self:GetColor())
    render.SetMaterial(Energy)
    render.DrawSprite(self:GetPos(),750,750,Color(255,255,255))
    render.SetMaterial(Flare)
    render.DrawSprite(self:GetPos(),1000,1000,Color(255,255,255))
    render.SetMaterial(Combine)
    render.DrawSprite(self:GetPos(),750,750,Color(255,255,255))
end
