if SERVER then
	AddCSLuaFile ("shared.lua")
	SWEP.Weight = 5

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false

elseif CLIENT then

	SWEP.PrintName = "Star Wars Laser"
	SWEP.Slot = 4
	SWEP.SlotPos = 5

	SWEP.DrawAmmo = false

	SWEP.DrawCrosshair = true

	SWEP.WepSelectIcon = surface.GetTextureID("HUD/killicons/starwars_laser")

	killicon.Add( "laser_weapon", "HUD/killicons/starwars_laser", Color( 255, 80, 0, 255 ) )

end

SWEP.Author = "Dannelor"
SWEP.Purpose = "Creates a laser"
SWEP.Instructions = "Left Click: Republic laser. Right Click: CIS laser"

SWEP.Category = "Star Wars (Updated)"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"
SWEP.HoldType   = "rpg"

SWEP.UseHands = true

SWEP.Primary.ClipSize = -1

SWEP.Primary.DefaultClip = -1

SWEP.Primary.Automatic = false

SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	if not CLIENT then return end
	self.Owner:PrintMessage(HUD_PRINTTALK, "WARNING! THIS WEAPON IS VERY DANGEROUS!")
	return true
end

function SWEP:PrimaryAttack()
  if CLIENT then return end
  local laser = ents.Create("laser_ent")
    laser:SetPos(self.Owner:GetEyeTrace().HitPos)
    laser:Spawn()
		laser:SetColor(Color(50,50,255))
    laser.Owner = self.Owner
end

function SWEP:SecondaryAttack()
  if CLIENT then return end
  local laser = ents.Create("laser_ent")
    laser:SetPos(self.Owner:GetEyeTrace().HitPos)
    laser:Spawn()
		laser:SetColor(Color(255,50,50))
    laser.Owner = self.Owner
end
