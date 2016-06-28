//include("stun_function.lua")
//include("vaporize_function.lua")

if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
end

if ( CLIENT ) then

	SWEP.PrintName			= "DC-15S Universal"			
	SWEP.Author				= "Doctor Jew"
	SWEP.ViewModelFOV      	= 50
	SWEP.Slot				= 2
	SWEP.SlotPos			= 3
	SWEP.WepSelectIcon = surface.GetTextureID("HUD/killicons/DC15S")
	
	killicon.Add( "weapon_752_dc15s", "HUD/killicons/DC15S", Color( 255, 80, 0, 255 ) )
	
end

SWEP.HoldType				= "ar2"
SWEP.Base					= "weapon_jew_base"

SWEP.Category				= "Star Wars (Updated)"

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= "models/weapons/v_DC15S.mdl"
SWEP.WorldModel				= "models/weapons/w_DC15S.mdl"

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

local FireSound 			= Sound ("weapons/DC15S_fire.wav");
local ReloadSound			= Sound ("weapons/DC15S_reload.wav");

SWEP.Primary.Recoil			= 0.5
SWEP.Primary.Damage			= 18.75
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.0125
SWEP.Primary.ClipSize		= 50
SWEP.Primary.Delay			= 0.25
SWEP.Primary.DefaultClip	= 150
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "ar2"
SWEP.Primary.Tracer 		= "effect_sw_laser_blue"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightsPos 			= Vector (-4.7, -6, 2.4)

// Custom values for fire switching
SWEP.SelectiveFire = true
SWEP.NextFireSelect = CurTime()
SWEP.SMode = 1

function SWEP:Precache()
	util.PrecacheSound("weapons/DC15S_fire.wav")
	util.PrecacheSound("weapons/DC19_fire.wav")
	util.PrecacheSound("weapons/DC15S_reload.wav")
end

function SWEP:Think()
	if self.SelectiveFire and self.NextFireSelect < CurTime() then
				if self.Owner:KeyDown(IN_SPEED) and self.Owner:KeyDown(IN_USE) then
					self:SelectFireMode()
				elseif self.Owner:KeyDown(IN_WALK) then
					self:PrintMode()
				end
	end
end

local FireModeMessage = {"Stun mode selected.","Vaporize mode selected.","Normal mode selected."}
local FireModeSound = {"Weapon_AR2.Empty"}
function SWEP:SelectFireMode()
	if CLIENT then
	self.Owner:PrintMessage(HUD_PRINTTALK,FireModeMessage[self.SMode])
	self.Weapon:EmitSound(FireModeSound[1])
	end
	self.NextFireSelect = CurTime() + 3
	self.SMode = (self.SMode + 1) % 4
	if self.SMode < 1 then
		self.SMode = 1
	end
end

local PrintModeMessage = {"Normal mode selected.","Stun mode selected.","Vaporize mode selected."}
function SWEP:PrintMode()
	if CLIENT and self.SelectiveFire then
		self.Owner:PrintMessage(HUD_PRINTTALK,PrintModeMessage[self.SMode])
		self.NextFireSelect = CurTime() + 1.5
	end
end

function SWEP:PrimaryAttack()
	if self.SMode == 1 then
		self:NormalFire()
	elseif self.SMode == 2 then
		self:Stun()
	elseif self.SMode == 3 then
		self:Vaporize()
	end	
end

function SWEP:NormalFire()
	self.Primary.Recoil			= 0.5
	self.Primary.Damage			= 40
	self.Primary.NumShots		= 1
	self.Primary.Cone			= 0.0125
	self.Primary.ClipSize		= 50
	self.Primary.Delay			= 0.25
	self.Primary.DefaultClip	= 50
	self.Primary.Automatic		= true
	self.Primary.Ammo			= "ar2"
	self.Primary.Tracer 		= "effect_sw_laser_blue"

	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if ( !self:CanPrimaryAttack() ) then return end
	
	self.Weapon:EmitSound( FireSound )
	
	self:CSShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self.Primary.Cone )
	
	self:TakePrimaryAmmo( 1 )
	
	if ( self.Owner:IsNPC() ) then return end
	
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	
	// In singleplayer this function doesn't get called on the client, so we use a networked float
	// to send the last shoot time. In multiplayer this is predicted clientside so we don't need to 
	// send the float.
	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
end

function SWEP:CSShootBullet( dmg, recoil, numbul, cone )

	numbul 	= numbul 	or 1
	cone 	= cone 		or 0.01

	local bullet = {}
	bullet.Num 		= numbul
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( cone, cone, 0 )			// Aim Cone
	bullet.Tracer	= 1								// Show a tracer on every x bullets 
	bullet.TracerName 	= self.Primary.Tracer
	bullet.Force	= 5									// Amount of force to give to phys objects
	bullet.Damage	= dmg
	
	self.Owner:FireBullets( bullet )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation
	
	if ( self.Owner:IsNPC() ) then return end
	
	// CUSTOM RECOIL !
	if ( (game.SinglePlayer() && SERVER) || ( !game.SinglePlayer() && CLIENT && IsFirstTimePredicted() ) ) then
	
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles( eyeang )
	
	end

end

function SWEP:Reload()
	if (self.Weapon:Clip1() < self.Primary.ClipSize) then
		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
			self.Weapon:EmitSound( ReloadSound )
		end
		self.Weapon:DefaultReload( ACT_VM_RELOAD );
		self:SetIronsights( false )
	end
end
